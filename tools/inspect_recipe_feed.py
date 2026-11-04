with open('lib/screens/recipe_feed_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(1040, 1270):
    l = lines[i]
    if any(k in l for k in ['GridView', 'ListView', 'Sliver', 'SearchBar', 'TextField', 'body:', 'SingleChildScrollView']):
        print(f"{i+1:4d}: {l.strip()[:80]}")
