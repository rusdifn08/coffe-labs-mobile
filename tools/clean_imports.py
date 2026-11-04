path = 'coffe-labs-mobile/lib/screens/recipe_feed_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = [
    line for line in lines
    if "import '../data/brew_visual_catalog.dart';" not in line and
       "import '../features/recipe_feed/models/note_category_item.dart';" not in line
]

with open(path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f"Done! Before: {len(lines)}, After: {len(new_lines)}")
