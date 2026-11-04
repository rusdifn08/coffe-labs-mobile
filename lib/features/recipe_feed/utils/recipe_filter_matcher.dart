import '../../../data/brew_visual_catalog.dart';
import '../models/note_category_item.dart';

/// Helper matching functions and filter options for RecipeFeedScreen.
class RecipeFilterMatcher {
  static const List<String> categories = [
    'All',
    'Espresso',
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

  static List<String> pourFilterOptions(bool isEnglish) => isEnglish
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

  static List<String> originFilterOptions(bool isEnglish) => isEnglish
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
        ];

  static bool matchesPour(Map<String, dynamic> r, String selectedPour) {
    if (selectedPour == 'Semua' || selectedPour == 'All') return true;
    final pours = BrewVisualCatalog.countPours(r);
    final cat = (r['category'] ?? '').toString().toLowerCase();
    if (selectedPour == 'Full Immersion') {
      return cat.contains('immersion');
    }
    if (selectedPour == '1-2x Pour') return pours <= 2;
    if (selectedPour == '3x Pouring') return pours == 3;
    if (selectedPour == '4x Pouring') return pours == 4;
    if (selectedPour == '5x+ Pouring') return pours >= 5;
    return true;
  }

  static bool matchesDripper(Map<String, dynamic> r, String selectedDripper) {
    if (selectedDripper == 'Semua' || selectedDripper == 'All') return true;
    final matched = BrewVisualCatalog.matchDripper(
      r['method']?.toString(),
      category: r['category']?.toString(),
    );
    return matched.shortName == selectedDripper;
  }

  static bool matchesNote(Map<String, dynamic> r, String selectedNote) {
    if (selectedNote == 'Semua' || selectedNote == 'All') return true;
    final notesStr = '${r['tastingNotes'] ?? ''} ${r['beanName'] ?? ''} ${r['description'] ?? ''}'.toLowerCase();

    for (final cat in noteCategories) {
      if (selectedNote == '${cat.emoji} ${cat.label}' ||
          selectedNote == '${cat.emoji} ${cat.labelEn}' ||
          selectedNote == 'Semua ${cat.label}' ||
          selectedNote == 'All ${cat.labelEn}' ||
          selectedNote == cat.label ||
          selectedNote == cat.labelEn) {
        if (cat.keywords.any((kw) => notesStr.contains(kw.toLowerCase()))) return true;
        final catNotes = BrewVisualCatalog.flavorNotes.where((fn) => cat.groups.contains(fn.group));
        return catNotes.any((fn) {
          final l = fn.label.toLowerCase();
          return notesStr.contains(l) || notesStr.contains(l.split(' ').first);
        });
      }
    }

    final target = selectedNote.toLowerCase();
    final firstWord = target.split(' ').first;
    return notesStr.contains(target) || notesStr.contains(firstWord);
  }

  static bool matchesMethod(Map<String, dynamic> r, String selectedMethod) {
    if (selectedMethod == 'All') return true;
    final lower = selectedMethod.toLowerCase();
    return (r['method'] ?? '').toString().toLowerCase().contains(lower) ||
        (r['category'] ?? '').toString().toLowerCase().contains(lower);
  }
}
