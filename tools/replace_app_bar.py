with open('lib/screens/recipe_detail_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Add import
import_stmt = "import '../features/recipe_detail/widgets/recipe_detail_app_bar.dart';\n"
c = import_stmt + c

# Find SliverAppBar block
start_str = "          SliverAppBar("
end_str = "          ),\n          SliverToBoxAdapter("

start_pos = c.find(start_str)
end_pos = c.find(end_str)

if start_pos != -1 and end_pos != -1:
    replacement = '''          RecipeDetailAppBar(
            coverImageUrl: coverImageUrl,
            authorName: authorName,
            countryCode: countryCode,
            isFavorite: _isFavorite,
            scaledRecipe: scaledRecipe,
            onToggleFavorite: _toggleFavorite,
          '''
    c = c[:start_pos] + replacement + c[end_pos:]
    with open('lib/screens/recipe_detail_screen.dart', 'w', encoding='utf-8') as f:
        f.write(c)
    print("Replaced SliverAppBar successfully!")
else:
    print(f"Could not find indices: start={start_pos}, end={end_pos}")
