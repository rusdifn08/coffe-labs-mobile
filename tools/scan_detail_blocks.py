with open('lib/screens/recipe_detail_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(660, 882):
    print(f"{i+1:4d}: {lines[i].strip()[:85]}")
