with open('lib/screens/recipe_feed_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(350, min(len(lines), 530)):
    print(f"{i+1:4d}: {lines[i].strip()[:80]}")
