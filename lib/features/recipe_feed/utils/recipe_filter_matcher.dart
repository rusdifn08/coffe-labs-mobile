import '../../../data/brew_visual_catalog.dart';
import '../../brew_methods/models/brew_method_item.dart';
import '../models/note_category_item.dart';

/// Core flavor option displayed in the streamlined Tasting Notes filter.
class CoreFlavorOption {
  final String key;
  final String labelId;
  final String labelEn;
  final String emoji;
  final List<String> keywords;

  const CoreFlavorOption({
    required this.key,
    required this.labelId,
    required this.labelEn,
    required this.emoji,
    required this.keywords,
  });
}

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

  /// Pilihan inti Tasting Notes yang ringkas & mudah dipilih.
  static const List<CoreFlavorOption> coreTastingNotes = [
    CoreFlavorOption(
      key: 'Floral',
      labelId: 'Floral',
      labelEn: 'Floral',
      emoji: '🌸',
      keywords: [
        'floral', 'flower', 'jasmine', 'rose', 'hibiscus', 'blossom',
        'lavender', 'chamomile', 'elderflower', 'bunga',
      ],
    ),
    CoreFlavorOption(
      key: 'Fruity',
      labelId: 'Fruity',
      labelEn: 'Fruity',
      emoji: '🍑',
      keywords: [
        'fruit', 'fruity', 'peach', 'apricot', 'plum', 'mango', 'passion',
        'pineapple', 'lychee', 'guava', 'papaya', 'melon', 'apple', 'pear',
        'grape', 'tropical', 'buah',
      ],
    ),
    CoreFlavorOption(
      key: 'Citrus',
      labelId: 'Citrus',
      labelEn: 'Citrus',
      emoji: '🍋',
      keywords: [
        'citrus', 'lemon', 'bergamot', 'orange', 'grapefruit', 'lime',
        'mandarin', 'yuzu', 'tangerine', 'jeruk',
      ],
    ),
    CoreFlavorOption(
      key: 'Berry',
      labelId: 'Berry',
      labelEn: 'Berry',
      emoji: '🍓',
      keywords: [
        'berry', 'strawberry', 'blueberry', 'currant', 'raspberry', 'cherry',
        'blackberry', 'cranberry',
      ],
    ),
    CoreFlavorOption(
      key: 'Chocolaty',
      labelId: 'Chocolaty',
      labelEn: 'Chocolaty',
      emoji: '🍫',
      keywords: [
        'choco', 'chocolaty', 'chocolate', 'cocoa', 'cacao', 'cokelat',
        'mocha', 'fudge', 'brownie',
      ],
    ),
    CoreFlavorOption(
      key: 'Sweet',
      labelId: 'Sweet',
      labelEn: 'Sweet',
      emoji: '🍯',
      keywords: [
        'sweet', 'honey', 'caramel', 'toffee', 'maple', 'sugar', 'vanilla',
        'butterscotch', 'creamy', 'madu', 'karamel', 'gula', 'manis',
      ],
    ),
    CoreFlavorOption(
      key: 'Nutty',
      labelId: 'Nutty',
      labelEn: 'Nutty',
      emoji: '🥜',
      keywords: [
        'nut', 'nutty', 'almond', 'hazelnut', 'walnut', 'pecan', 'peanut',
        'roasted', 'kacang', 'spice', 'cinnamon', 'rempah',
      ],
    ),
    CoreFlavorOption(
      key: 'Tea-Like',
      labelId: 'Tea-Like',
      labelEn: 'Tea-Like',
      emoji: '🍵',
      keywords: [
        'tea', 'earl grey', 'oolong', 'black tea', 'green tea', 'herbal',
        'lemongrass', 'teh',
      ],
    ),
  ];

  static const int maxPourCount = 10;

  static List<String> pourFilterOptions(bool isEnglish) => isEnglish
      ? const ['All', '1x Pour', '2x Pour', '3x Pour', '4x Pour', '5x Pour']
      : const ['Semua', '1x Pour', '2x Pour', '3x Pour', '4x Pour', '5x Pour'];

  static List<String> originFilterOptions(bool isEnglish) => isEnglish
      ? const [
          'All',
          'Indonesia',
          'International',
          '❄️ Iced',
          '⚡ Fast (≤ 2:15)',
        ]
      : const [
          'Semua',
          'Indonesia',
          'Internasional',
          '❄️ Es',
          '⚡ Cepat (≤ 2:15)',
        ];

  /// Mengonversi string filter jumlah pouring ke bilangan bulat (0 = Semua/All).
  static int parsePourCount(String selectedPour) {
    final trimmed = selectedPour.trim();
    if (trimmed.isEmpty || trimmed == 'Semua' || trimmed == 'All') return 0;
    final lower = trimmed.toLowerCase();
    if (lower == 'single pour') return 1;
    final match = RegExp(r'^(\d+)x\s*pour', caseSensitive: false).firstMatch(trimmed);
    if (match != null) {
      return (int.tryParse(match.group(1) ?? '0') ?? 0).clamp(0, maxPourCount);
    }
    return 0;
  }

  /// Memformat bilangan jumlah pouring menjadi label filter baku.
  static String formatPourFilter(int count, {required bool isEnglish}) {
    if (count <= 0) return isEnglish ? 'All' : 'Semua';
    return '${count.clamp(1, maxPourCount)}x Pour';
  }

  static bool matchesPour(Map<String, dynamic> r, String selectedPour) {
    if (selectedPour.isEmpty || selectedPour == 'Semua' || selectedPour == 'All') {
      return true;
    }
    final pours = BrewVisualCatalog.countPours(r);
    final cat = (r['category'] ?? '').toString().toLowerCase();
    final lower = selectedPour.trim().toLowerCase();

    if (lower == 'full immersion') {
      return cat.contains('immersion');
    }
    if (lower == 'single pour') return pours == 1;
    if (lower == '1-2x pour') return pours <= 2;
    if (lower == '5x+ pouring' || lower == '5x+ pour') return pours >= 5;

    final exactMatch = RegExp(r'^(\d+)x\s*pour', caseSensitive: false).firstMatch(lower);
    if (exactMatch != null) {
      final target = int.tryParse(exactMatch.group(1) ?? '');
      if (target != null && target > 0) {
        return pours == target;
      }
    }
    return true;
  }

  /// Mencocokkan filter Metode Seduh (termasuk 18 metode 3D di BrewMethodItem maupun dripper legacy).
  static bool matchesDripper(Map<String, dynamic> r, String selectedDripper) {
    if (selectedDripper.isEmpty ||
        selectedDripper == 'Semua' ||
        selectedDripper == 'All') {
      return true;
    }

    final lower = selectedDripper.trim().toLowerCase();
    for (final item in BrewMethodItem.allMethods) {
      if (item.filterKey.toLowerCase() == lower ||
          item.title.toLowerCase() == lower ||
          item.titleId.toLowerCase() == lower ||
          item.id.toLowerCase() == lower) {
        return matchesMethod(r, item.filterKey);
      }
    }

    if (matchesMethod(r, selectedDripper)) return true;

    final matched = BrewVisualCatalog.matchDripper(
      r['method']?.toString(),
      category: r['category']?.toString(),
    );
    return matched.shortName.toLowerCase() == lower;
  }

  /// Mencari label tampilan ramah pengguna untuk key Metode Seduh terpilih.
  static String displayMethodLabel(String filterKey, {required bool isEnglish}) {
    final lower = filterKey.trim().toLowerCase();
    for (final item in BrewMethodItem.allMethods) {
      if (item.filterKey.toLowerCase() == lower ||
          item.title.toLowerCase() == lower ||
          item.titleId.toLowerCase() == lower) {
        return isEnglish ? item.title : item.titleId;
      }
    }
    return filterKey;
  }

  static bool matchesNote(Map<String, dynamic> r, String selectedNote) {
    if (selectedNote.isEmpty || selectedNote == 'Semua' || selectedNote == 'All') {
      return true;
    }
    final notesStr =
        '${r['tastingNotes'] ?? ''} ${r['beanName'] ?? ''} ${r['description'] ?? ''}'
            .toLowerCase();
    final cleanedSelected = selectedNote
        .replaceAll(RegExp(r'[^\w\s\-&/]+', unicode: true), '')
        .trim()
        .toLowerCase();

    for (final core in coreTastingNotes) {
      if (cleanedSelected == core.key.toLowerCase() ||
          cleanedSelected == core.labelId.toLowerCase() ||
          cleanedSelected == core.labelEn.toLowerCase()) {
        return core.keywords.any((kw) => notesStr.contains(kw));
      }
    }

    for (final cat in noteCategories) {
      if (selectedNote == '${cat.emoji} ${cat.label}' ||
          selectedNote == '${cat.emoji} ${cat.labelEn}' ||
          selectedNote == 'Semua ${cat.label}' ||
          selectedNote == 'All ${cat.labelEn}' ||
          selectedNote == cat.label ||
          selectedNote == cat.labelEn) {
        if (cat.keywords.any((kw) => notesStr.contains(kw.toLowerCase()))) return true;
        final catNotes =
            BrewVisualCatalog.flavorNotes.where((fn) => cat.groups.contains(fn.group));
        return catNotes.any((fn) {
          final l = fn.label.toLowerCase();
          return notesStr.contains(l) || notesStr.contains(l.split(' ').first);
        });
      }
    }

    final target = cleanedSelected.isNotEmpty ? cleanedSelected : selectedNote.toLowerCase();
    final firstWord = target.split(' ').first;
    return notesStr.contains(target) || notesStr.contains(firstWord);
  }

  static bool matchesMethod(Map<String, dynamic> r, String selectedMethod) {
    if (selectedMethod.isEmpty ||
        selectedMethod == 'All' ||
        selectedMethod == 'Semua') {
      return true;
    }
    final lower = selectedMethod.trim().toLowerCase();
    final method = (r['method'] ?? '').toString().toLowerCase();
    final category = (r['category'] ?? '').toString().toLowerCase();
    final title = (r['title'] ?? '').toString().toLowerCase();
    final ice = (r['iceWeightGrams'] as num?)?.toDouble() ?? 0;

    if (lower == 'v60' || lower == 'hario v60') {
      return method.contains('v60') ||
          method.contains('switch') ||
          method.contains('mugen') ||
          category.contains('v60');
    }
    if (lower == 'japanese drip' || lower == 'japanese') {
      return method.contains('japanese') ||
          category.contains('japanese') ||
          category.contains('es di server') ||
          title.contains('japanese') ||
          (ice > 0 && !method.contains('cold brew') && !method.contains('espresso'));
    }
    if (lower == 'vietnam drip') {
      return method.contains('vietnam') ||
          method.contains('phin') ||
          category.contains('vietnam') ||
          category.contains('phin');
    }
    if (lower == 'cold brew') {
      return method.contains('cold brew') ||
          method.contains('cold drip') ||
          method.contains('kyoto') ||
          category.contains('cold brew') ||
          title.contains('cold brew');
    }
    if (lower == 'turkish coffee') {
      return method.contains('turkish') ||
          method.contains('cezve') ||
          method.contains('ibrik') ||
          category.contains('turkish');
    }
    if (lower == 'kalita wave') {
      return method.contains('kalita') ||
          method.contains('wave') ||
          category.contains('flat bottom');
    }
    if (lower == 'syphon') {
      return method.contains('syphon') ||
          method.contains('siphon') ||
          method.contains('vacuum') ||
          category.contains('syphon');
    }
    if (lower == 'moka pot') {
      return method.contains('moka') ||
          method.contains('bialetti') ||
          category.contains('moka');
    }
    if (lower == 'drip coffee maker') {
      return method.contains('drip coffee') ||
          method.contains('drip maker') ||
          method.contains('moccamaster') ||
          method.contains('batch') ||
          category.contains('drip maker');
    }
    if (lower == 'bee house') {
      return method.contains('bee house') ||
          method.contains('beehouse') ||
          method.contains('melitta');
    }
    if (lower == 'french press') {
      return method.contains('french press') ||
          method.contains('plunger') ||
          category.contains('french press');
    }

    return method.contains(lower) || category.contains(lower) || title.contains(lower);
  }
}
