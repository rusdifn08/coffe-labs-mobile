with open('coffe-labs-mobile/lib/screens/recipe_feed_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Add import for RecipeDeleteDialog
if 'recipe_delete_dialog.dart' not in c:
    c = "import '../features/recipe_feed/widgets/recipe_delete_dialog.dart';\n" + c

# Replace _confirmDelete implementation with call to RecipeDeleteDialog
old_delete = """  void _confirmDelete(int id, String title) {
    final isEn = LanguageService.isEnglish;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEn ? 'Delete Recipe?' : 'Hapus Resep?'),
        content: Text(isEn ? 'Are you sure you want to delete "$title"?' : 'Yakin ingin menghapus "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isEn ? 'Cancel' : 'Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteRecipe(id);
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEn ? 'Recipe deleted' : 'Resep dihapus')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: Text(isEn ? 'Delete' : 'Hapus', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }"""

new_delete = """  Future<void> _confirmDelete(int id, String title) async {
    final deleted = await RecipeDeleteDialog.show(context, id: id, title: title);
    if (deleted == true) _loadData();
  }"""

c = c.replace(old_delete, new_delete)

# Add method filter banner in body Column right after RecipeFeedSearchBar
target_search_bar = """            onResetAll: _resetAllFilters,
          ),
          const SizedBox(height: 4),"""

replacement_search_bar = """            onResetAll: _resetAllFilters,
          ),
          if (_selectedMethodFilter != 'All')
            Container(
              margin: const EdgeInsets.fromLTRB(24, 6, 24, 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.slider_horizontal_3, size: 14, color: AppTheme.primaryBrown),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isEn ? 'Method: ${widget.initialMethodTitle ?? _selectedMethodFilter}' : 'Metode: ${widget.initialMethodTitle ?? _selectedMethodFilter}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedMethodFilter = 'All'),
                    child: const Icon(CupertinoIcons.xmark_circle_fill, size: 16, color: AppTheme.primaryBrown),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),"""

c = c.replace(target_search_bar, replacement_search_bar)

with open('coffe-labs-mobile/lib/screens/recipe_feed_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print('Updated recipe_feed_screen.dart, lines:', len(c.splitlines()))
