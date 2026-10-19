"""
Generate portrait wajah jelas + cover terpisah.
Untuk banner WBrC (logo kiri, orang kanan): crop setengah kanan dulu.
"""
from __future__ import annotations

import json
import re
import time
import urllib.request
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

try:
    from duckduckgo_search import DDGS
except Exception:
    DDGS = None

ROOT = Path(__file__).resolve().parent
AVATAR_DIR = ROOT / "assets" / "images" / "avatars"
PORTRAIT_DIR = AVATAR_DIR / "portraits"
COVER_DIR = AVATAR_DIR / "covers"
SEED = ROOT / "lib" / "services" / "seed_data.dart"
CATALOG = ROOT / "lib" / "data" / "barista_catalog.dart"

BARISTAS = {
    "tetsu_kasuya": "Tetsu Kasuya coffee barista",
    "odd_steinar_tollefsen": "Odd-Steinar Tollefsen barista",
    "konstantinos_iatridis": "Konstantinos Iatridis barista",
    "benjamin_prager": "Benjamin Prager barista",
    "mikaela_wallgren": "Mikaela Wallgren barista",
    "chad_wang": "Chad Wang World Brewers Cup",
    "sam_corra": "Sam Corra barista",
    "stathis_koremtas": "Stathis Koremtas barista",
    "emi_fukahori": "Emi Fukahori World Brewers Cup",
    "regine_wai_yee_beng": "Regine Wai Yee Beng barista",
    "du_jianing": "Du Jianing barista",
    "patrik_rolf": "Patrik Rolf barista",
    "alessandro_galtieri": "Alessandro Galtieri barista",
    "matt_winton": "Matt Winton World Brewers Cup",
    "daiki_hatakeyama": "Daiki Hatakeyama barista",
    "elika_liftee": "Elika Liftee World Brewers Cup",
    "shih_yuan_hsu": "Shih Yuan Hsu barista",
    "elysia_tan": "Elysia Tan barista",
    "carlos_medina": "Carlos Medina World Brewers Cup",
    "savina_giachgia": "Savina Giachgia barista",
    "garam_victor_um": "Garam Victor Um barista",
    "martin_wolfl": "Martin Wolfl barista",
    "wataru_iidaka": "Wataru Iidaka barista",
    "ryan_wibawa": "Ryan Wibawa barista Indonesia",
    "peng_jinyang": "Peng Jinyang barista",
    "bayu_prawiro": "Bayu Prawiro barista Indonesia",
    "carlos_escobar": "Carlos Escobar barista Colombia",
    "nas_jaafar": "Nas Jaafar barista Malaysia",
    "simon_gautherin": "Simon Gautherin barista",
    "bavis_kwong": "Bavis Kwong World Brewers Cup Hong Kong",
}

# (x_ratio, y_ratio, scale) relatif ke FULL image — fokus area orang di kanan banner
MANUAL_FACE = {
    "bavis_kwong": (0.78, 0.42, 0.42),
    "stathis_koremtas": (0.72, 0.40, 0.45),
    "nas_jaafar": (0.70, 0.40, 0.45),
    "simon_gautherin": (0.70, 0.40, 0.45),
    "benjamin_prager": (0.72, 0.38, 0.40),
    "alessandro_galtieri": (0.55, 0.38, 0.45),
    "daiki_hatakeyama": (0.72, 0.40, 0.45),
    "chad_wang": (0.55, 0.35, 0.50),
    "tetsu_kasuya": (0.50, 0.35, 0.55),
    "odd_steinar_tollefsen": (0.50, 0.32, 0.50),
    "bayu_prawiro": (0.55, 0.35, 0.50),
    "emi_fukahori": (0.50, 0.32, 0.50),
    "matt_winton": (0.50, 0.35, 0.55),
    "elika_liftee": (0.50, 0.40, 0.70),
    "sam_corra": (0.50, 0.40, 0.70),
    "mikaela_wallgren": (0.50, 0.40, 0.70),
    "carlos_medina": (0.50, 0.40, 0.65),
    "ryan_wibawa": (0.55, 0.35, 0.50),
    "peng_jinyang": (0.55, 0.35, 0.50),
    "garam_victor_um": (0.55, 0.35, 0.50),
    "martin_wolfl": (0.55, 0.35, 0.50),
    "wataru_iidaka": (0.55, 0.35, 0.50),
    "elysia_tan": (0.55, 0.35, 0.50),
    "savina_giachgia": (0.55, 0.35, 0.50),
    "shih_yuan_hsu": (0.55, 0.35, 0.50),
    "regine_wai_yee_beng": (0.55, 0.35, 0.50),
    "du_jianing": (0.55, 0.35, 0.50),
    "patrik_rolf": (0.55, 0.35, 0.50),
    "carlos_escobar": (0.55, 0.35, 0.50),
    "konstantinos_iatridis": (0.50, 0.35, 0.55),
}

UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"


def find_source(slug: str) -> Path | None:
    for ext in (".webp", ".jpg", ".jpeg", ".png"):
        p = AVATAR_DIR / f"{slug}{ext}"
        if p.exists() and p.stat().st_size > 3000:
            return p
    for p in AVATAR_DIR.glob("odd_steinar*"):
        if slug.startswith("odd_steinar") and p.suffix.lower() in {".jpg", ".jpeg", ".webp", ".png"}:
            if p.stat().st_size > 100000:
                return p
    return None


def detect_faces(bgr: np.ndarray):
    gray = cv2.cvtColor(bgr, cv2.COLOR_BGR2GRAY)
    cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
    faces = cascade.detectMultiScale(gray, scaleFactor=1.08, minNeighbors=5, minSize=(80, 80))
    if len(faces) == 0:
        cascade2 = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_alt2.xml")
        faces = cascade2.detectMultiScale(gray, scaleFactor=1.05, minNeighbors=4, minSize=(60, 60))
    return list(faces)


def crop_square(img: Image.Image, cx: float, cy: float, side: float) -> Image.Image:
    w, h = img.size
    side = max(80, min(side, min(w, h)))
    left = int(max(0, min(cx - side / 2, w - side)))
    top = int(max(0, min(cy - side / 2, h - side)))
    return img.crop((left, top, left + int(side), top + int(side)))


def is_banner_graphic(img: Image.Image) -> bool:
    """Deteksi banner WBrC: landscape + banyak biru flat."""
    w, h = img.size
    if w / max(h, 1) < 1.35:
        return False
    small = img.resize((80, 45))
    arr = np.array(small)
    # Rasio pixel biru-cyan
    b = arr[:, :, 2].astype(np.int16)
    g = arr[:, :, 1].astype(np.int16)
    r = arr[:, :, 0].astype(np.int16)
    blueish = (b > 140) & (b > r + 30) & (b > g - 10)
    return blueish.mean() > 0.18


def portrait_from_image(slug: str, img: Image.Image) -> tuple[Image.Image, str]:
    w, h = img.size
    bgr_full = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

    # 1) Banner WBrC: cari wajah di setengah KANAN
    if is_banner_graphic(img) or (w / max(h, 1) >= 1.4):
        right = img.crop((int(w * 0.45), 0, w, h))
        bgr_r = cv2.cvtColor(np.array(right), cv2.COLOR_RGB2BGR)
        faces = detect_faces(bgr_r)
        if faces:
            x, y, fw, fh = max(faces, key=lambda f: f[2] * f[3])
            # koordinat ke full image
            cx = int(w * 0.45) + x + fw / 2
            cy = y + fh / 2
            side = max(fw, fh) * 2.4
            return crop_square(img, cx, cy, side), "right-half+haar"

        if slug in MANUAL_FACE:
            xr, yr, sc = MANUAL_FACE[slug]
            return crop_square(img, w * xr, h * yr, min(w, h) * sc), "manual-banner"

        # fallback kanan atas
        return crop_square(img, w * 0.75, h * 0.40, min(w, h) * 0.45), "right-fallback"

    # 2) Manual prioritas untuk slug tertentu
    if slug in MANUAL_FACE:
        # Coba haar dulu; kalau wajah kecil/salah, pakai manual
        faces = detect_faces(bgr_full)
        if faces:
            x, y, fw, fh = max(faces, key=lambda f: f[2] * f[3])
            if fw >= 70 and fh >= 70:
                return crop_square(img, x + fw / 2, y + fh / 2, max(fw, fh) * 2.3), "haar"
        xr, yr, sc = MANUAL_FACE[slug]
        return crop_square(img, w * xr, h * yr, min(w, h) * sc), "manual"

    # 3) Haar biasa
    faces = detect_faces(bgr_full)
    if faces:
        x, y, fw, fh = max(faces, key=lambda f: f[2] * f[3])
        return crop_square(img, x + fw / 2, y + fh / 2, max(fw, fh) * 2.3), "haar"

    return crop_square(img, w * 0.5, h * 0.35, min(w, h) * 0.55), "upper-center"


def download_headshot(query: str, dest: Path) -> bool:
    if DDGS is None:
        return False
    try:
        results = list(DDGS().images(keywords=f'{query} portrait face', max_results=5, type_image="photo"))
        for r in results:
            url = r.get("image")
            if not url:
                continue
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=15) as resp:
                data = resp.read()
            if len(data) < 8000:
                continue
            dest.write_bytes(data)
            # Validasi ada wajah
            arr = np.frombuffer(data, dtype=np.uint8)
            bgr = cv2.imdecode(arr, cv2.IMREAD_COLOR)
            if bgr is None:
                continue
            faces = detect_faces(bgr)
            if faces:
                x, y, fw, fh = max(faces, key=lambda f: f[2] * f[3])
                if fw >= 60:
                    return True
        return False
    except Exception as e:
        print(f"  download fail: {e}")
        return False


def make_pair(slug: str, query: str) -> dict[str, str] | None:
    PORTRAIT_DIR.mkdir(parents=True, exist_ok=True)
    COVER_DIR.mkdir(parents=True, exist_ok=True)

    src = find_source(slug)
    if not src:
        print(f"MISSING {slug}")
        return None

    with Image.open(src) as im0:
        im = im0.convert("RGB")

        # Cover = full banner/action
        cover_path = COVER_DIR / f"{slug}.jpg"
        cover = im.copy()
        if cover.width > 1280:
            ratio = 1280 / cover.width
            cover = cover.resize((1280, int(cover.height * ratio)), Image.Resampling.LANCZOS)
        cover.save(cover_path, quality=88, optimize=True)

        portrait, method = portrait_from_image(slug, im)
        portrait = portrait.resize((512, 512), Image.Resampling.LANCZOS)

        # Jika hasil portrait terlalu "flat biru" (logo), unduh headshot
        arr = np.array(portrait.resize((64, 64)))
        b = arr[:, :, 2].astype(np.int16)
        r = arr[:, :, 0].astype(np.int16)
        g = arr[:, :, 1].astype(np.int16)
        blueish = ((b > 140) & (b > r + 25)).mean()
        if blueish > 0.35:
            print(f"  {slug}: portrait looks like logo ({blueish:.2f}), fetching headshot...")
            tmp = PORTRAIT_DIR / f"_tmp_{slug}.jpg"
            if download_headshot(query, tmp):
                with Image.open(tmp) as shot:
                    shot = shot.convert("RGB")
                    bgr = cv2.cvtColor(np.array(shot), cv2.COLOR_RGB2BGR)
                    faces = detect_faces(bgr)
                    if faces:
                        x, y, fw, fh = max(faces, key=lambda f: f[2] * f[3])
                        portrait = crop_square(shot, x + fw / 2, y + fh / 2, max(fw, fh) * 2.4)
                        portrait = portrait.resize((512, 512), Image.Resampling.LANCZOS)
                        method = "ddg-headshot"
                tmp.unlink(missing_ok=True)
                time.sleep(0.6)

        out = PORTRAIT_DIR / f"{slug}.jpg"
        portrait.save(out, quality=92, optimize=True)
        print(f"{slug}: {method}")
        return {
            "cover": f"assets/images/avatars/covers/{slug}.jpg",
            "avatar": f"assets/images/avatars/portraits/{slug}.jpg",
        }


def update_seed(mapping: dict[str, dict[str, str]]):
    content = SEED.read_text(encoding="utf-8")

    def replacer(match: re.Match) -> str:
        # Match salah satu dari tiga field; kita rewrite blok dari cover/avatar/authorImage
        return match.group(0)

    # Replace setiap trio jika ada, atau authorImageUrl saja
    # Lebih sederhana: ganti authorAvatarUrl dan coverImageUrl per slug
    for slug, info in mapping.items():
        content = re.sub(
            rf'"coverImageUrl":\s*"assets/images/avatars/covers/{slug}\.[^"]+"',
            f'"coverImageUrl": "{info["cover"]}"',
            content,
        )
        content = re.sub(
            rf'"authorAvatarUrl":\s*"assets/images/avatars/portraits/{slug}\.[^"]+"',
            f'"authorAvatarUrl": "{info["avatar"]}"',
            content,
        )
        content = re.sub(
            rf'"authorImageUrl":\s*"assets/images/avatars/(?:covers/)?{slug}\.[^"]+"',
            f'"authorImageUrl": "{info["cover"]}"',
            content,
        )
        # legacy path tanpa covers/
        content = re.sub(
            rf'"authorImageUrl":\s*"assets/images/avatars/{slug}\.[^"]+"',
            f'"authorImageUrl": "{info["cover"]}"',
            content,
        )

    SEED.write_text(content, encoding="utf-8")

    cat = CATALOG.read_text(encoding="utf-8")
    for slug, info in mapping.items():
        cat = re.sub(
            rf"imageAsset:\s*'assets/images/avatars/(?:portraits/)?{slug}\.[^']+'",
            f"imageAsset: '{info['avatar']}'",
            cat,
        )
    CATALOG.write_text(cat, encoding="utf-8")
    print("seed + catalog updated")


def main():
    mapping = {}
    for slug, query in BARISTAS.items():
        info = make_pair(slug, query)
        if info:
            mapping[slug] = info
    update_seed(mapping)
    (PORTRAIT_DIR / "mapping.json").write_text(json.dumps(mapping, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
