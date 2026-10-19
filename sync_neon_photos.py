"""
Sync foto barista (portrait + cover) ke Neon PostgreSQL sebagai BYTEA.
"""
from __future__ import annotations

import re
from pathlib import Path

import psycopg2

CONN = (
    "postgresql://neondb_owner:npg_xVRfo1T4kMXO@"
    "ep-rough-scene-aose2qfm-pooler.c-2.ap-southeast-1.aws.neon.tech/"
    "neondb?sslmode=require"
)

ROOT = Path(__file__).resolve().parent
PORTRAIT_DIR = ROOT / "assets" / "images" / "avatars" / "portraits"
COVER_DIR = ROOT / "assets" / "images" / "avatars" / "covers"

NAME_MAP = {
    "tetsu_kasuya": "Tetsu Kasuya",
    "odd_steinar_tollefsen": "Odd-Steinar Tollefsen",
    "konstantinos_iatridis": "Konstantinos Iatridis",
    "benjamin_prager": "Benjamin Prager",
    "mikaela_wallgren": "Mikaela Wallgren",
    "chad_wang": "Chad Wang",
    "sam_corra": "Sam Corra",
    "stathis_koremtas": "Stathis Koremtas",
    "emi_fukahori": "Emi Fukahori",
    "regine_wai_yee_beng": "Regine Wai Yee Beng",
    "du_jianing": "Du Jianing",
    "patrik_rolf": "Patrik Rolf",
    "alessandro_galtieri": "Alessandro Galtieri",
    "matt_winton": "Matt Winton",
    "daiki_hatakeyama": "Daiki Hatakeyama",
    "elika_liftee": "Elika Liftee",
    "shih_yuan_hsu": "Shih Yuan Hsu",
    "elysia_tan": "Elysia Tan",
    "carlos_medina": "Carlos Medina",
    "savina_giachgia": "Savina Giachgia",
    "garam_victor_um": "Garam Victor Um",
    "martin_wolfl": "Martin Wolfl",
    "wataru_iidaka": "Wataru Iidaka",
    "ryan_wibawa": "Ryan Wibawa",
    "peng_jinyang": "Peng Jinyang",
    "bayu_prawiro": "Bayu Prawiro",
    "carlos_escobar": "Carlos Escobar",
    "nas_jaafar": "Nas Jaafar",
    "simon_gautherin": "Simon Gautherin",
    "bavis_kwong": "Bavis Kwong",
}


def slugify_author(author: str) -> str:
    name = re.sub(r"\s*\([^)]*\)", "", author or "")
    name = re.sub(r"[\U0001F1E0-\U0001F1FF]+", "", name)
    name = name.strip().lower()
    for a, b in (("ø", "o"), ("ö", "o"), ("ä", "a"), ("ü", "u")):
        name = name.replace(a, b)
    return re.sub(r"[^a-z0-9]+", "_", name).strip("_")


def table_exists(cur, name: str) -> bool:
    cur.execute("SELECT to_regclass(%s)", (f"public.{name}",))
    return cur.fetchone()[0] is not None


def column_exists(cur, table: str, column: str) -> bool:
    cur.execute(
        """
        SELECT 1 FROM information_schema.columns
        WHERE table_schema='public' AND table_name=%s AND column_name=%s
        """,
        (table, column),
    )
    return cur.fetchone() is not None


def ensure_columns(cur, table: str, columns: list[str]):
    if not table_exists(cur, table):
        return
    for col in columns:
        if not column_exists(cur, table, col):
            cur.execute(f'ALTER TABLE {table} ADD COLUMN IF NOT EXISTS {col} TEXT')
            print(f"Added column {table}.{col}")


def main():
    conn = psycopg2.connect(CONN)
    cur = conn.cursor()
    print("Connected to Neon.")

    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS barista_photo (
            slug TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            avatar BYTEA NOT NULL,
            cover BYTEA NOT NULL,
            avatar_mime TEXT DEFAULT 'image/jpeg',
            cover_mime TEXT DEFAULT 'image/jpeg',
            updated_at TIMESTAMPTZ DEFAULT NOW()
        );
        """
    )

    # Hibernate often lowercases field names without underscores
    ensure_columns(cur, "recipe", ["coverimageurl", "authoravatarurl", "authorimageurl", "author"])
    ensure_columns(cur, "barista", ["coverimageurl", "authoravatarurl", "imageurl", "slug", "name"])

    uploaded = 0
    for slug, name in NAME_MAP.items():
        avatar_path = PORTRAIT_DIR / f"{slug}.jpg"
        cover_path = COVER_DIR / f"{slug}.jpg"
        if not avatar_path.exists() or not cover_path.exists():
            print(f"SKIP missing: {slug}")
            continue

        avatar_bytes = avatar_path.read_bytes()
        cover_bytes = cover_path.read_bytes()
        cur.execute(
            """
            INSERT INTO barista_photo (slug, name, avatar, cover, updated_at)
            VALUES (%s, %s, %s, %s, NOW())
            ON CONFLICT (slug) DO UPDATE SET
                name = EXCLUDED.name,
                avatar = EXCLUDED.avatar,
                cover = EXCLUDED.cover,
                updated_at = NOW();
            """,
            (slug, name, psycopg2.Binary(avatar_bytes), psycopg2.Binary(cover_bytes)),
        )

        if table_exists(cur, "barista") and column_exists(cur, "barista", "slug"):
            avatar_url = f"/api/baristas/{slug}/avatar"
            cover_url = f"/api/baristas/{slug}/cover"
            cur.execute("SELECT id FROM barista WHERE slug=%s", (slug,))
            row = cur.fetchone()
            if row:
                cur.execute(
                    """
                    UPDATE barista SET
                        name=%s,
                        imageurl=%s,
                        authoravatarurl=%s,
                        coverimageurl=%s
                    WHERE slug=%s
                    """,
                    (name, avatar_url, avatar_url, cover_url, slug),
                )
            else:
                # Get next id from sequence or max+1
                cur.execute("SELECT COALESCE(MAX(id),0)+1 FROM barista")
                new_id = cur.fetchone()[0]
                cur.execute(
                    """
                    INSERT INTO barista (id, name, slug, imageurl, authoravatarurl, coverimageurl)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (new_id, name, slug, avatar_url, avatar_url, cover_url),
                )

        uploaded += 1
        print(f"OK {slug} ({len(avatar_bytes)} / {len(cover_bytes)} bytes)")

    if table_exists(cur, "recipe"):
        cur.execute("SELECT id, author FROM recipe WHERE author IS NOT NULL")
        rows = cur.fetchall()
        updated = 0
        for rid, author in rows:
            slug = slugify_author(author)
            if slug not in NAME_MAP:
                for s, n in NAME_MAP.items():
                    if n.lower() in (author or "").lower():
                        slug = s
                        break
            if slug not in NAME_MAP:
                continue
            cur.execute(
                """
                UPDATE recipe SET
                    authoravatarurl=%s,
                    coverimageurl=%s,
                    authorimageurl=%s
                WHERE id=%s
                """,
                (
                    f"/api/baristas/{slug}/avatar",
                    f"/api/baristas/{slug}/cover",
                    f"/api/baristas/{slug}/cover",
                    rid,
                ),
            )
            updated += 1
        print(f"Recipe rows linked: {updated}")

    conn.commit()
    cur.execute("SELECT COUNT(*) FROM barista_photo")
    count = cur.fetchone()[0]
    cur.close()
    conn.close()
    print(f"Done. barista_photo={count}, uploaded={uploaded}")


if __name__ == "__main__":
    main()
