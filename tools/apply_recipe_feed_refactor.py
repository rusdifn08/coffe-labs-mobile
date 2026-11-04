with open('coffe-labs-mobile/lib/screens/recipe_feed_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Add import
if 'recipe_filter_matcher.dart' not in c:
    c = "import '../features/recipe_feed/utils/recipe_filter_matcher.dart';\n" + c

# Remove constant getters and categories list
old_lists = """  final List<String> _categories = const [
    'All',
    'V60',
    'Japanese',
    'AeroPress',
    'French Press',
    'Immersion',
    'Hybrid',
    'Flat Bottom',
    'Origami',
    'Cone',
  ];

  List<String> get _pourFilterOptions => LanguageService.isEnglish
      ? const [
          'All',
          '1-2x Pour',
          '3x Pouring',
          '4x Pouring',
          '5x+ Pouring',
          'Full Immersion',
        ]
      : const [
          'Semua',
          '1-2x Pour',
          '3x Pouring',
          '4x Pouring',
          '5x+ Pouring',
          'Full Immersion',
        ];

  List<String> get _originFilterOptions => LanguageService.isEnglish
      ? const [
          'All',
          '🇮🇩 Indonesian Baristas',
          '🌍 International Baristas',
          '❄️ Iced Recipes',
          '⚡ Fast (≤ 2:15)',
        ]
      : const [
          'Semua',
          '🇮🇩 Barista Indonesia',
          '🌍 Barista Internasional',
          '❄️ Resep Pakai Es',
          '⚡ Cepat (≤ 2:15)',
        ];"""

new_lists = """  List<String> get _categories => RecipeFilterMatcher.categories;
  List<String> get _pourFilterOptions => RecipeFilterMatcher.pourFilterOptions(LanguageService.isEnglish);
  List<String> get _originFilterOptions => RecipeFilterMatcher.originFilterOptions(LanguageService.isEnglish);"""

c = c.replace(old_lists, new_lists)

# Remove the 3 helper methods (_matchesPourFilter, _matchesDripperFilter, _matchesNoteFilter)
import re
c = re.sub(r'  bool _matchesPourFilter\(Map<String, dynamic> r\) \{.*?return notesStr\.contains\(target\) \|\| notesStr\.contains\(firstWord\);\s*\}\n', '', c, flags=re.DOTALL)

# Update the build filter call to use RecipeFilterMatcher
old_match_calls = """          RecipeFilterMatcher.matchesPour(r, _selectedPourFilter) &&
          RecipeFilterMatcher.matchesDripper(r, _selectedDripperFilter) &&
          RecipeFilterMatcher.matchesNote(r, _selectedNoteFilter) &&"""

c = c.replace("_matchesPourFilter(r)", "RecipeFilterMatcher.matchesPour(r, _selectedPourFilter)")
c = c.replace("_matchesDripperFilter(r)", "RecipeFilterMatcher.matchesDripper(r, _selectedDripperFilter)")
c = c.replace("_matchesNoteFilter(r)", "RecipeFilterMatcher.matchesNote(r, _selectedNoteFilter)")

# Also update matchesMethod call
old_mf = """      final mfLower = _selectedMethodFilter.toLowerCase();
      bool matchesMethod = _selectedMethodFilter == 'All' ||
          (r['method'] ?? '').toString().toLowerCase().contains(mfLower) ||
          (r['category'] ?? '').toString().toLowerCase().contains(mfLower);"""

new_mf = """      final matchesMethod = RecipeFilterMatcher.matchesMethod(r, _selectedMethodFilter);"""

c = c.replace(old_mf, new_mf)

with open('coffe-labs-mobile/lib/screens/recipe_feed_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print('Refactored recipe_feed_screen.dart! Lines:', len(c.splitlines()))
