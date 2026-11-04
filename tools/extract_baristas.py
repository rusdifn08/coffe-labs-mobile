import os
import re
import glob
from collections import defaultdict

seed_files = sorted(glob.glob(r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\seeds\seeds_part_*.dart'))

baristas_to_recipes = defaultdict(list)
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

        recipe_info = {
            'id': rec_id,
            'title': title,
            'author': author,
            'method': method,
            'category': category,
            'source_file': os.path.basename(sf)
        }
        all_recipes.append(recipe_info)
        baristas_to_recipes[author].append(recipe_info)

# Also check BaristaCatalog profiles
catalog_profiles = {}
for p in [r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\baristas\baristas_part_1.dart',
          r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\baristas\baristas_part_2.dart']:
    with open(p, 'r', encoding='utf-8') as f:
        c = f.read()
    # match: 'slug': BaristaProfile(name: '...', slug: '...', country: '...', countryCode: '...', specialty: '...', bio: '...'
    profile_matches = re.findall(r'BaristaProfile\(\s*name:\s*[\'"]([^\'"]+)[\'"].*?country:\s*[\'"]([^\'"]+)[\'"].*?countryCode:\s*[\'"]([^\'"]+)[\'"].*?specialty:\s*[\'"]([^\'"]+)[\'"].*?bio:\s*[\'"]([^\'"]+)[\'"]', c, re.DOTALL)
    for pm in profile_matches:
        catalog_profiles[pm[0].strip()] = {
            'name': pm[0].strip(),
            'country': pm[1].strip(),
            'countryCode': pm[2].strip(),
            'specialty': pm[3].strip(),
            'bio': pm[4].strip(),
        }

with open(r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\tools\barista_summary.txt', 'w', encoding='utf-8') as out:
    out.write(f"Total recipes: {len(all_recipes)}\n")
    out.write(f"Total unique authors in recipes: {len(baristas_to_recipes)}\n")
    out.write(f"Total profiles in BaristaCatalog: {len(catalog_profiles)}\n\n")

    for author, recs in sorted(baristas_to_recipes.items()):
        # clean author name
        clean_name = re.sub(r'[\U00010000-\U0010ffff]', '', author).strip() # remove emojis
        clean_name = re.sub(r'[^\w\s\.\-\'\,\(\)]', '', clean_name).strip()
        out.write(f"### {author} ({len(recs)} resep)\n")
        profile = catalog_profiles.get(clean_name)
        if profile:
            out.write(f"- Negara: {profile['country']} ({profile['countryCode']})\n")
            out.write(f"- Spesialisasi: {profile['specialty']}\n")
        for r in recs:
            out.write(f"  * #{r['id']} {r['title']} ({r['method']} - {r['category']})\n")
        out.write("\n")

print("Summary written to tools/barista_summary.txt")
