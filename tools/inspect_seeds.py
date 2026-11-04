import glob
import re

ids = []
for sf in glob.glob(r'coffe-labs-mobile/lib/data/seeds/seeds_part_*.dart'):
    with open(sf, 'r', encoding='utf-8') as f:
        c = f.read()
    found = [int(x) for x in re.findall(r'\"id\":\s*(\d+)', c)]
    ids.extend(found)

print(f"Total existing recipes: {len(ids)}")
print(f"Min ID: {min(ids)}, Max ID: {max(ids)}")
print(f"Sorted IDs preview: {sorted(ids)[:10]} ... {sorted(ids)[-10:]}")
