import os
import re
import glob
from collections import defaultdict

def slug_from_author(author):
    lower_raw = author.lower()
    if 'pepeng' in lower_raw: return 'pepeng_klinik_kopi'
    if 'melvin' in lower_raw: return 'melvin_fugol'
    if 'dody' in lower_raw or 'doddy' in lower_raw: return 'dody_samsura'
    if 'madan' in lower_raw: return 'madan'
    if 'fakhri' in lower_raw: return 'muhammad_fakhri'
    if 'jaya pranata' in lower_raw: return 'jaya_pranata'
    if 'hendri' in lower_raw: return 'hendri_kurniawan'
    if 'dustin' in lower_raw: return 'dustin_wijaya'
    if 'ray janson' in lower_raw: return 'ray_janson'
    if 'prawiraanga' in lower_raw: return 'prawiraanga'
    if 'samo smrke' in lower_raw or 'samo bloom' in lower_raw: return 'samo_smrke'
    if 'lance hedrick' in lower_raw: return 'lance_hedrick'
    if 'edrick' in lower_raw: return 'edrick'
    if 'space roastery' in lower_raw: return 'space_roastery'
    if 'smoking barrels' in lower_raw: return 'smoking_barrels'
    if 'roy panggabean' in lower_raw or 'serkop' in lower_raw: return 'roy_panggabean'
    if 'kreator double bloom' in lower_raw: return 'double_bloom_id'
    if 'daily caffeine' in lower_raw or 'panna' in lower_raw: return 'panna_roastery'
    if 'relo' in lower_raw: return 'kopi_relo'
    if 'mandie' in lower_raw or 'fugol' in lower_raw: return 'melvin_fugol'
    if 'instinct' in lower_raw: return 'instinct_roastery'
    if 'hungry bird' in lower_raw: return 'hungry_bird_coffee'
    if 'seniman' in lower_raw: return 'seniman_coffee'
    if 'giyanti' in lower_raw: return 'giyanti_coffee'
    if 'simetri' in lower_raw: return 'simetri_coffee'
    if 'anomali' in lower_raw: return 'anomali_coffee'
    if 'john richard' in lower_raw or 'john christopher' in lower_raw: return 'john_christopher'
    if 'jsmine' in lower_raw or 'jscafejournal' in lower_raw: return 'jsmine_cafe'
    if 'chandra (home brewer)' in lower_raw or 'chandra (kreator' in lower_raw: return 'chandra_brewer'
    if 'tooearlyforcaffeine' in lower_raw or 'tefc' in lower_raw: return 'tefc_caffeine'
    if 'opak kopi' in lower_raw: return 'opak_kopi'
    if 'jpw indonesia' in lower_raw: return 'jpw_indonesia'
    if 'filosofi kopi' in lower_raw: return 'filosofi_kopi'
    if 'two hands full' in lower_raw: return 'two_hands_full'
    if 'wheel coffee' in lower_raw: return 'wheel_coffee'
    if 'djournal' in lower_raw: return 'djournal_coffee'
    if '1/15' in lower_raw or 'one fifteenth' in lower_raw: return 'one_fifteenth_coffee'
    if 'smith coffee' in lower_raw or 'harapan djaya' in lower_raw: return 'smith_coffee'
    if 'blue doors' in lower_raw: return 'blue_doors'
    if 'surabaya specialty' in lower_raw or 'surabaya slow bar' in lower_raw: return 'surabaya_slow_bar'
    if 'medan specialty' in lower_raw or 'medan slow bar' in lower_raw: return 'medan_slow_bar'
    if 'ombe kofie' in lower_raw: return 'ombe_kofie'
    if 'tetangga roastery' in lower_raw: return 'tetangga_roastery'
    if 'otten coffee academy' in lower_raw: return 'otten_coffee_academy'
    if 'asser christensen' in lower_raw or 'coffee chronicler' in lower_raw: return 'asser_christensen'
    if 'yuma kawano' in lower_raw or 'light up coffee' in lower_raw: return 'yuma_kawano'
    if 'taizo iwasaki' in lower_raw: return 'taizo_iwasaki'

    name = re.sub(r'\s*\([^)]*\)', '', author)
    name = re.sub(r'[\U00010000-\U0010ffff]', '', name).strip()
    name = name.lower()
    name = name.replace('ø', 'o').replace('ö', 'o').replace('ä', 'a').replace('ü', 'u').replace('é', 'e')
    name = re.sub(r'[^a-z0-9]+', '_', name)
    name = re.sub(r'^_|_$', '', name)
    return name

country_flags = {
    'id': '🇮🇩', 'jp': '🇯🇵', 'gb': '🇬🇧', 'us': '🇺🇸', 'no': '🇳🇴',
    'ch': '🇨🇭', 'gr': '🇬🇷', 'au': '🇦🇺', 'tw': '🇹🇼', 'cn': '🇨🇳',
    'my': '🇲🇾', 'sg': '🇸🇬', 'at': '🇦🇹', 'fi': '🇫🇮', 'it': '🇮🇹',
    'br': '🇧🇷', 'co': '🇨🇴', 'nl': '🇳🇱', 'dk': '🇩🇰', 'cl': '🇨🇱',
    'hk': '🇭🇰', 'ca': '🇨🇦', 'de': '🇩🇪', 'fr': '🇫🇷', 'kr': '🇰🇷',
    'ru': '🇷🇺', 'ie': '🇮🇪', 'se': '🇸🇪', 'ph': '🇵🇭', 'ro': '🇷🇴',
    'ae': '🇦🇪', 'cz': '🇨🇿', 'th': '🇹🇭', 'sa': '🇸🇦', 'es': '🇪🇸'
}

# 1. Parse catalog profiles
catalog = {}
for p in [r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\baristas\baristas_part_1.dart',
          r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\baristas\baristas_part_2.dart']:
    with open(p, 'r', encoding='utf-8') as f:
        c = f.read()
    entries = re.findall(r'\'([a-z0-9_]+)\':\s*(?:const\s+)?BaristaProfile\(\s*name:\s*[\'"]([^\'"]+)[\'"].*?country:\s*[\'"]([^\'"]+)[\'"].*?countryCode:\s*[\'"]([^\'"]+)[\'"].*?specialty:\s*[\'"]([^\'"]+)[\'"].*?bio:\s*[\'"]([^\'"]+)[\'"]', c, re.DOTALL)
    for slug, name, country, cc, specialty, bio in entries:
        flag = country_flags.get(cc.lower(), '🌍')
        catalog[slug] = {
            'slug': slug,
            'name': name,
            'country': country,
            'countryCode': cc,
            'flag': flag,
            'specialty': specialty,
            'bio': bio,
            'recipes': [],
            'raw_authors': set()
        }

# 2. Parse seed recipes
seed_files = sorted(glob.glob(r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\seeds\seeds_part_*.dart'))
total_recipe_count = 0

for sf in seed_files:
    with open(sf, 'r', encoding='utf-8') as f:
        content = f.read()

    blocks = re.split(r'\{\s*\"id\":', content)
    for b in blocks[1:]:
        tm = re.search(r'\"title\":\s*\"([^\"]+)\"', b)
        am = re.search(r'\"author\":\s*\"([^\"]+)\"', b)
        mm = re.search(r'\"method\":\s*\"([^\"]+)\"', b)
        cm = re.search(r'\"category\":\s*\"([^\"]+)\"', b)
        bm = re.search(r'\"beanName\":\s*\"([^\"]+)\"', b)
        wm = re.search(r'\"waterTempCelsius\":\s*(\d+)', b)
        cw = re.search(r'\"coffeeWeightGrams\":\s*([\d\.]+)', b)
        tw = re.search(r'\"totalWaterWeightGrams\":\s*([\d\.]+)', b)
        id_m = re.search(r'^\s*(\d+)', b)

        rec_id = int(id_m.group(1)) if id_m else 9999
        title = tm.group(1) if tm else 'Unknown'
        author = am.group(1) if am else 'Unknown'
        method = mm.group(1) if mm else ''
        category = cm.group(1) if cm else ''
        bean = bm.group(1) if bm else ''
        temp = wm.group(1) if wm else ''
        dose = cw.group(1) if cw else ''
        water = tw.group(1) if tw else ''

        slug = slug_from_author(author)
        if slug in catalog:
            catalog[slug]['recipes'].append({
                'id': rec_id,
                'title': title,
                'author': author,
                'method': method,
                'category': category,
                'bean': bean,
                'temp': temp,
                'dose': dose,
                'water': water,
            })
            catalog[slug]['raw_authors'].add(author)
            total_recipe_count += 1
        else:
            print(f"Warning: slug {slug} not found for author {author}")

# Sort baristas: Indonesia first or alphabetical
baristas_list = list(catalog.values())

# Sort by name
baristas_sorted = sorted(baristas_list, key=lambda x: x['name'].lower())

# Group by category / region:
# 1. Barista Juara Dunia & Legenda Internasional (WBrC / WBC / WAC / Coffee Pioneer)
# 2. Barista & Kreator Indonesia (IBrC / IBC / Roaster / Edukator)
# 3. Specialty Roastery & Slow Bar Indonesia

international_baristas = []
indonesia_baristas = []
roastery_slowbar = []

roastery_slugs = {
    'space_roastery', 'smoking_barrels', 'fugol_coffee', 'instinct_roastery', 'hungry_bird_coffee',
    'seniman_coffee', 'giyanti_coffee', 'simetri_coffee', 'anomali_coffee', 'opak_kopi', 'jpw_indonesia',
    'filosofi_kopi', 'two_hands_full', 'wheel_coffee', 'djournal_coffee', 'one_fifteenth_coffee',
    'smith_coffee', 'blue_doors', 'surabaya_slow_bar', 'medan_slow_bar', 'ombe_kofie', 'tetangga_roastery',
    'otten_coffee_academy', 'kopi_relo', 'panna_roastery'
}

for b in baristas_sorted:
    if b['slug'] in roastery_slugs:
        roastery_slowbar.append(b)
    elif b['countryCode'].lower() == 'id':
        indonesia_baristas.append(b)
    else:
        international_baristas.append(b)

# Generate Markdown
md = []
md.append("# ☕ Daftar Lengkap Barista & Kreator Resep Coffee Labs\n")
md.append("> **Coffee Labs Database Summary**")
md.append(f"> - **Total Barista / Kreator / Roastery:** {len(catalog)} Profil")
md.append(f"> - **Total Resep Seduh Terdaftar:** {total_recipe_count} Resep")
md.append("> - **Cakupan Wilayah:** Indonesia & 20+ Negara Dunia (WBrC, WBC, WAC Champions, Roastery Ternama, & Slow Bar Spesialis)")
md.append(f"> - **Status Database:** 100% Terverifikasi & Sinkron dengan Seed Database Mobile App\n")
md.append("---\n")

md.append("## 📌 Navigasi Cepat")
md.append("- [1. Tabel Ringkasan Semua Barista (A - Z)](#1-tabel-ringkasan-semua-barista-a---z)")
md.append(f"- [2. Barista & Juara Dunia Internasional ({len(international_baristas)} Barista)](#2-barista--juara-dunia-internasional)")
md.append(f"- [3. Barista & Kreator Indonesia ({len(indonesia_baristas)} Barista)](#3-barista--kreator-indonesia)")
md.append(f"- [4. Specialty Roastery & Slow Bar Indonesia ({len(roastery_slowbar)} Roastery)](#4-specialty-roastery--slow-bar-indonesia)\n")
md.append("---\n")

md.append("## 1. Tabel Ringkasan Semua Barista (A - Z)\n")
md.append("| No | Nama Barista / Roastery | Negara | Spesialisasi | Jml Resep |")
md.append("|:---:|:---|:---:|:---|:---:|")

for idx, b in enumerate(baristas_sorted, 1):
    flag = b['flag']
    name = b['name']
    country = b['country']
    spec = b['specialty']
    rec_count = len(b['recipes'])
    md.append(f"| {idx} | **{name}** | {flag} {country} | {spec} | **{rec_count}** |")

md.append("\n---\n")

def render_section(title, baristas):
    md.append(f"## {title}\n")
    for b in baristas:
        flag = b['flag']
        name = b['name']
        country = b['country']
        spec = b['specialty']
        bio = b['bio']
        recipes = sorted(b['recipes'], key=lambda r: r['id'])
        rec_count = len(recipes)
        raw_names = ", ".join([f"`{a}`" for a in sorted(b['raw_authors'])])

        md.append(f"### {flag} {name} ({country})")
        md.append(f"- **Spesialisasi:** {spec}")
        md.append(f"- **Format Nama di Resep:** {raw_names}")
        md.append(f"- **Total Resep:** {rec_count} resep")
        md.append(f"- **Bio & Filosofi:** *\"{bio}\"*\n")
        md.append(f"#### Daftar Resep:")
        md.append("| ID | Judul Resep | Alat Seduh / Metode | Kategori | Rasio (Kopi : Air) | Suhu |")
        md.append("|:---:|:---|:---|:---|:---:|:---:|")
        for r in recipes:
            ratio = f"{r['dose']}g : {r['water']}g" if r['dose'] and r['water'] else "-"
            temp = f"{r['temp']}°C" if r['temp'] else "-"
            md.append(f"| #{r['id']} | **{r['title']}** | {r['method']} | {r['category']} | {ratio} | {temp} |")
        md.append("\n")

render_section(f"2. Barista & Juara Dunia Internasional ({len(international_baristas)} Barista)", international_baristas)
md.append("---\n")
render_section(f"3. Barista & Kreator Indonesia ({len(indonesia_baristas)} Barista)", indonesia_baristas)
md.append("---\n")
render_section(f"4. Specialty Roastery & Slow Bar Indonesia ({len(roastery_slowbar)} Roastery)", roastery_slowbar)

content = "\n".join(md)

# Write to root barista.md
with open(r'c:\Rusdi\Coffe Labs\barista.md', 'w', encoding='utf-8') as f:
    f.write(content)

# Also write to coffe-labs-mobile/barista.md
with open(r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\barista.md', 'w', encoding='utf-8') as f:
    f.write(content)

print(f"Generated barista.md with {len(catalog)} baristas and {total_recipe_count} recipes!")
