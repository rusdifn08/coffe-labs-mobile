import os
import re

p = r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\roasteries'
roasteries = []
for f in sorted(os.listdir(p)):
    if f.endswith('.dart'):
        txt = open(os.path.join(p, f), encoding='utf-8').read()
        names = re.findall(r'Roastery\(\s*id:\s*[\'"]([^\'"]+)[\'"],\s*name:\s*[\'"]([^\'"]+)[\'"]', txt)
        roasteries.extend(names)

print(f'Total roasteries: {len(roasteries)}')
for r_id, r_name in roasteries:
    print(f'{r_id}: {r_name}')
