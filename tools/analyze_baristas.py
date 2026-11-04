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
    if 'samo smrke' in lower_raw or 'samo bloom' in lower_raw: return 'samo_smrke'
    if 'asser christensen' in lower_raw or 'coffee chronicler' in lower_raw: return 'asser_christensen'
    if 'yuma kawano' in lower_raw or 'light up coffee' in lower_raw: return 'yuma_kawano'
    if 'taizo iwasaki' in lower_raw: return 'taizo_iwasaki'

    # fallback clean
    name = re.sub(r'\s*\([^)]*\)', '', author)
    name = re.sub(r'[\U00010000-\U0010ffff]', '', name).strip()
    name = name.lower()
    name = name.replace('ø', 'o').replace('ö', 'o').replace('ä', 'a').replace('ü', 'u').replace('é', 'e')
    name = re.sub(r'[^a-z0-9]+', '_', name)
    name = re.sub(r'^_|_$', '', name)
    return name

# Parse profiles from baristas_part_1.dart and baristas_part_2.dart
catalog = {}
for p in [r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\baristas\baristas_part_1.dart',
          r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\baristas\baristas_part_2.dart']:
    with open(p, 'r', encoding='utf-8') as f:
        c = f.read()
    # Match: 'slug': const BaristaProfile(name: '...', slug: '...', country: '...', countryCode: '...', specialty: '...', bio: '...'
    entries = re.findall(r'\'([a-z0-9_]+)\':\s*(?:const\s+)?BaristaProfile\(\s*name:\s*[\'"]([^\'"]+)[\'"].*?country:\s*[\'"]([^\'"]+)[\'"].*?countryCode:\s*[\'"]([^\'"]+)[\'"].*?specialty:\s*[\'"]([^\'"]+)[\'"].*?bio:\s*[\'"]([^\'"]+)[\'"]', c, re.DOTALL)
    for slug, name, country, cc, specialty, bio in entries:
        catalog[slug] = {
            'slug': slug,
            'name': name,
            'country': country,
            'countryCode': cc,
            'specialty': specialty,
            'bio': bio
        }

# Parse seed recipes
seed_files = sorted(glob.glob(r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\seeds\seeds_part_*.dart'))
recipes_by_slug = defaultdict(list)
raw_authors_by_slug = defaultdict(set)
all_recipes = []

for sf in seed_files:
    with open(sf, 'r', encoding='utf-8') as f:
        content = f.read()

    blocks = re.split(r'\{\s*\"id\":', content)
    for b in blocks[1:]:
        tm = re.search(r'\"title\":\s*\"([^\"]+)\"', b)
        am = re.search(r'\"author\":\s*\"([^\"]+)\"', b)
        mm = re.search(r'\"method\":\s*\"([^\"]+)\"', b)
        cm = re.search(r'\"category\":\s*\"([^\"]+)\"', b)
        id_m = re.search(r'^\s*(\d+)', b)

        rec_id = id_m.group(1) if id_m else '?'
        title = tm.group(1) if tm else 'Unknown'
        author = am.group(1) if am else 'Unknown'
        method = mm.group(1) if mm else ''
        category = cm.group(1) if cm else ''

        slug = slug_from_author(author)
        raw_authors_by_slug[slug].add(author)

        recipe_item = {
            'id': int(rec_id) if rec_id.isdigit() else 9999,
            'title': title,
            'author_raw': author,
            'method': method,
            'category': category,
        }
        recipes_by_slug[slug].append(recipe_item)
        all_recipes.append(recipe_item)

print(f"Total recipes: {len(all_recipes)}")
print(f"Total unique slugs from recipes: {len(recipes_by_slug)}")
print(f"Catalog size: {len(catalog)}")

missing = set(recipes_by_slug.keys()) - set(catalog.keys())
print(f"Slugs in recipes not in catalog: {missing}")
