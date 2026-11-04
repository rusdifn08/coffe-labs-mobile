import os
import re
from PIL import Image, ImageDraw, ImageFont, ImageFilter

p_roasteries = r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\roasteries'
out_roasteries_dir = r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\assets\images\roasteries'
out_beans_dir = r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\assets\images\beans'

os.makedirs(out_roasteries_dir, exist_ok=True)
os.makedirs(out_beans_dir, exist_ok=True)

# Parse all 50 roasteries and their lineups
all_roasteries = []
for f in sorted(os.listdir(p_roasteries)):
    if f.endswith('.dart'):
        txt = open(os.path.join(p_roasteries, f), encoding='utf-8').read()
        blocks = re.findall(r"Roastery\(\s*id:\s*['\"]([^'\"]+)['\"],\s*name:\s*['\"]([^'\"]+)['\"].*?lineups:\s*\[(.*?)\]\s*\),", txt, re.DOTALL)
        for r_id, r_name, lineups_block in blocks:
            items = re.findall(r"CoffeeLineupItem\(\s*name:\s*['\"]([^'\"]+)['\"].*?origin:\s*['\"]([^'\"]+)['\"].*?roastProfile:\s*['\"]([^'\"]+)['\"].*?process:\s*['\"]([^'\"]+)['\"].*?tastingNotes:\s*['\"]([^'\"]+)['\"]", lineups_block, re.DOTALL)
            all_roasteries.append({
                'id': r_id,
                'name': r_name,
                'items': items
            })

print(f"Parsed {len(all_roasteries)} roasteries and {sum(len(r['items']) for r in all_roasteries)} lineup items.")
