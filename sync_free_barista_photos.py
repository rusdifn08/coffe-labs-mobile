"""
Unduh foto barista gratis (Wikimedia Commons / Unsplash Source) sesuai nama di seed.
Sumber legal & gratis — bukan scrape Google Images.
"""
import json
import os
import re
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
AVATAR_DIR = ROOT / "assets" / "images" / "avatars"
SEED = ROOT / "lib" / "services" / "seed_data.dart"
UA = "CoffeeHubAvatarBot/1.0 (educational; barista recipe app)"

# Nama bersih -> slug file yang sudah dipakai di seed
BARISTAS = [
    ("Tetsu Kasuya", "tetsu_kasuya", "World Brewers Cup 2016 champion"),
    ("Odd-Steinar Tøllefsen", "odd_steinar_tollefsen", "World Brewers Cup 2015 champion"),
    ("Konstantinos Iatridis", "konstantinos_iatridis", "World Brewers Cup barista"),
    ("Benjamin Prager", "benjamin_prager", "World Brewers Cup barista"),
    ("Mikaela Wallgren", "mikaela_wallgren", "World Brewers Cup barista Finland"),
    ("Chad Wang", "chad_wang", "World Brewers Cup champion Taiwan"),
    ("Sam Corra", "sam_corra", "World Brewers Cup barista Australia"),
    ("Stathis Koremtas", "stathis_koremtas", "World Brewers Cup barista Greece"),
    ("Emi Fukahori", "emi_fukahori", "World Brewers Cup 2018 champion"),
    ("Regine Wai Yee Beng", "regine_wai_yee_beng", "World Brewers Cup Malaysia"),
    ("Du Jianing", "du_jianing", "World Brewers Cup China"),
    ("Patrik Rolf", "patrik_rolf", "World Brewers Cup Sweden"),
    ("Alessandro Galtieri", "alessandro_galtieri", "World Brewers Cup Italy"),
    ("Matt Winton", "matt_winton", "World Brewers Cup 2021 champion"),
    ("Daiki Hatakeyama", "daiki_hatakeyama", "World Brewers Cup Japan"),
    ("Elika Liftee", "elika_liftee", "World Brewers Cup USA champion"),
    ("Shih Yuan Hsu", "shih_yuan_hsu", "World Brewers Cup Taiwan"),
    ("Elysia Tan", "elysia_tan", "World Brewers Cup Singapore"),
    ("Carlos Medina", "carlos_medina", "World Brewers Cup Chile"),
    ("Savina Giachgia", "savina_giachgia", "World Brewers Cup Greece"),
    ("Garam Victor Um", "garam_victor_um", "World Brewers Cup Brazil"),
    ("Martin Wölfl", "martin_wolfl", "World Brewers Cup Austria"),
    ("Wataru Iidaka", "wataru_iidaka", "World Brewers Cup Japan"),
    ("Ryan Wibawa", "ryan_wibawa", "World Brewers Cup Indonesia"),
    ("Peng Jinyang", "peng_jinyang", "World Brewers Cup China"),
    ("Bayu Prawiro", "bayu_prawiro", "World Brewers Cup Indonesia"),
    ("Carlos Escobar", "carlos_escobar", "World Brewers Cup Colombia"),
    ("Nas Jaafar", "nas_jaafar", "World Brewers Cup Malaysia"),
    ("Simon Gautherin", "simon_gautherin", "World Brewers Cup Australia"),
    ("Bavis Kwong", "bavis_kwong", "World Brewers Cup Hong Kong"),
]

# Fallback Unsplash (gratis, lisensi Unsplash) — potret profesional / coffee context
UNSPLASH_FALLBACKS = {
    "tetsu_kasuya": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop",
    "odd_steinar_tollefsen": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
    "konstantinos_iatridis": "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop",
    "benjamin_prager": "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&h=400&fit=crop",
    "mikaela_wallgren": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop",
    "chad_wang": "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
    "sam_corra": "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&h=400&fit=crop",
    "stathis_koremtas": "https://images.unsplash.com/photo-1463453091185-61582044d556?w=400&h=400&fit=crop",
    "emi_fukahori": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
    "regine_wai_yee_beng": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop",
    "du_jianing": "https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=400&h=400&fit=crop",
    "patrik_rolf": "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400&h=400&fit=crop",
    "alessandro_galtieri": "https://images.unsplash.com/photo-1522075469751-3a6694fb2f47?w=400&h=400&fit=crop",
    "matt_winton": "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&h=400&fit=crop",
    "daiki_hatakeyama": "https://images.unsplash.com/photo-1552058544-f2b08422138a?w=400&h=400&fit=crop",
    "elika_liftee": "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
    "shih_yuan_hsu": "https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=400&h=400&fit=crop",
    "elysia_tan": "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=400&h=400&fit=crop",
    "carlos_medina": "https://images.unsplash.com/photo-1545167622-3a6ac756afa4?w=400&h=400&fit=crop",
    "savina_giachgia": "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400&h=400&fit=crop",
    "garam_victor_um": "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=400&h=400&fit=crop",
    "martin_wolfl": "https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=400&h=400&fit=crop",
    "wataru_iidaka": "https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=400&h=400&fit=crop",
    "ryan_wibawa": "https://images.unsplash.com/photo-1557862921-37829c790f19?w=400&h=400&fit=crop",
    "peng_jinyang": "https://images.unsplash.com/photo-1542178243-bc20204b769f?w=400&h=400&fit=crop",
    "bayu_prawiro": "https://images.unsplash.com/photo-1595152772835-219674b2a8a6?w=400&h=400&fit=crop",
    "carlos_escobar": "https://images.unsplash.com/photo-1603415526960-f7e0328c63b1?w=400&h=400&fit=crop",
    "nas_jaafar": "https://images.unsplash.com/photo-1614283233556-f35b0c764185?w=400&h=400&fit=crop",
    "simon_gautherin": "https://images.unsplash.com/photo-1552374196-c4e2ffc6e0f0?w=400&h=400&fit=crop",
    "bavis_kwong": "https://images.unsplash.com/photo-1615109398623-88346a601842?w=400&h=400&fit=crop",
}


def download(url: str, dest: Path) -> bool:
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=20) as resp:
            data = resp.read()
        if len(data) < 2000:
            return False
        dest.write_bytes(data)
        return True
    except Exception as e:
        print(f"  fail download: {e}")
        return False


def wikimedia_search(name: str) -> str | None:
    q = urllib.parse.quote(f"{name} coffee OR barista OR brew")
    api = (
        "https://commons.wikimedia.org/w/api.php"
        f"?action=query&generator=search&gsrsearch={q}&gsrnamespace=6"
        "&gsrlimit=5&prop=imageinfo&iiprop=url|mime&format=json"
    )
    try:
        req = urllib.request.Request(api, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=15) as resp:
            payload = json.loads(resp.read().decode("utf-8"))
        pages = payload.get("query", {}).get("pages", {})
        for page in pages.values():
            info = (page.get("imageinfo") or [{}])[0]
            mime = info.get("mime", "")
            url = info.get("url")
            if url and mime.startswith("image/") and "svg" not in mime:
                return url
    except Exception as e:
        print(f"  wikimedia miss: {e}")
    return None


def existing_path(slug: str) -> Path | None:
    for ext in (".webp", ".jpg", ".jpeg", ".png"):
        p = AVATAR_DIR / f"{slug}{ext}"
        if p.exists() and p.stat().st_size > 2000:
            return p
    return None


def main():
    AVATAR_DIR.mkdir(parents=True, exist_ok=True)
    mapping = {}  # slug -> relative asset path

    for name, slug, hint in BARISTAS:
        existing = existing_path(slug)
        # Refresh only if missing or tiny; keep good local portraits
        if existing and existing.stat().st_size > 8000:
            mapping[slug] = f"assets/images/avatars/{existing.name}"
            print(f"OK keep {name} -> {existing.name}")
            continue

        dest = AVATAR_DIR / f"{slug}.jpg"
        print(f"Fetch {name}...")
        url = wikimedia_search(name) or wikimedia_search(hint)
        ok = False
        if url:
            ok = download(url, dest)
            if ok:
                print(f"  Wikimedia -> {dest.name}")
        if not ok:
            fallback = UNSPLASH_FALLBACKS.get(slug)
            if fallback and download(fallback, dest):
                ok = True
                print(f"  Unsplash free -> {dest.name}")
        if ok:
            mapping[slug] = f"assets/images/avatars/{dest.name}"
        else:
            mapping[slug] = "assets/images/avatars/generic_fallback.jpg"
            print(f"  FALLBACK generic for {name}")
        time.sleep(0.4)

    # Sync authorImageUrl di seed ke ekstensi aktual
    content = SEED.read_text(encoding="utf-8")
    for slug, path in mapping.items():
        content = re.sub(
            rf'"authorImageUrl":\s*"assets/images/avatars/{slug}\.[^"]+"',
            f'"authorImageUrl": "{path}"',
            content,
        )

    SEED.write_text(content, encoding="utf-8")
    print("\nSeed authorImageUrl diselaraskan.")
    print(json.dumps(mapping, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
