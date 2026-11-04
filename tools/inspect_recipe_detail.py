import re

with open('lib/screens/recipe_detail_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")
for idx, line in enumerate(lines):
    if re.match(r'^\s*(Widget\s+_[a-zA-Z0-9]+|void\s+_[a-zA-Z0-9]+|class\s+[a-zA-Z0-9]+)', line):
        print(f"{idx+1:4d}: {line.strip()}")
