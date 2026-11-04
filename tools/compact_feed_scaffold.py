with open('lib/screens/recipe_feed_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

import_stmt = "import '../features/recipe_feed/widgets/recipe_feed_search_bar.dart';\n"
c = import_stmt + c

start_str = "          // Search Bar + Filter Modal Button"
end_str = "          const SizedBox(height: 4),\n          // Feed Grid"

start_idx = c.find(start_str)
end_idx = c.find(end_str)

if start_idx != -1 and end_idx != -1:
    replacement = '''          RecipeFeedSearchBar(
            activeFilterCount: _activeFilterCount,
            categories: _categories,
            selectedCategory: _selectedCategory,
            selectedPourFilter: _selectedPourFilter,
            selectedDripperFilter: _selectedDripperFilter,
            selectedBaristaFilter: _selectedBaristaFilter,
            selectedNoteFilter: _selectedNoteFilter,
            selectedOriginFilter: _selectedOriginFilter,
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            onOpenFilter: _openFilterModal,
            onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
            onRemovePourFilter: () => setState(() => _selectedPourFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
            onRemoveDripperFilter: () => setState(() => _selectedDripperFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
            onRemoveBaristaFilter: () => setState(() => _selectedBaristaFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
            onRemoveNoteFilter: () => setState(() => _selectedNoteFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
            onRemoveOriginFilter: () => setState(() => _selectedOriginFilter = LanguageService.isEnglish ? 'All' : 'Semua'),
            onResetAll: _resetAllFilters,
          ),\n'''
    c = c[:start_idx] + replacement + c[end_idx:]
    
    # Remove _activeFilterChip method
    chip_start = c.find("  Widget _activeFilterChip(String label, VoidCallback onRemove) {")
    if chip_start != -1:
        chip_end = c.find("  Widget _buildGridCard", chip_start)
        if chip_end != -1:
            c = c[:chip_start] + c[chip_end:]
    
    with open('lib/screens/recipe_feed_screen.dart', 'w', encoding='utf-8') as f:
        f.write(c)
    print("Successfully compacted recipe_feed_screen.dart!")
else:
    print(f"Indices not found: start={start_idx}, end={end_idx}")
