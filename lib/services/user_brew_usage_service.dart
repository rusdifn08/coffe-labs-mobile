import '../features/brew_methods/models/brew_method_item.dart';
import '../utils/barista_utils.dart';

/// Service untuk menganalisis frekuensi penggunaan seduh oleh user
/// dan menyusun urutan metode seduh serta barista spotlight secara personal.
class UserBrewUsageService {
  /// Mengurutkan metode seduh berdasarkan seberapa sering user menyeduhnya.
  /// Metode dengan frekuensi seduh tertinggi ditempatkan di urutan paling depan
  /// (misal: Hario V60 5x, AeroPress 3x, dst).
  static List<BrewMethodItem> sortMethodsByUserUsage(
    List<BrewMethodItem> allMethods,
    List<dynamic> brewHistory,
  ) {
    final usageCounts = <String, int>{};
    for (final method in allMethods) {
      usageCounts[method.id] = 0;
    }

    // Hitung frekuensi tiap metode dari riwayat seduh
    for (final record in brewHistory) {
      if (record is! Map) continue;
      final rawMethod = (record['method'] ?? record['brewMethod'] ?? '').toString();
      final rawCategory = (record['category'] ?? '').toString();
      final rawTitle = (record['title'] ?? '').toString();
      final combined = '$rawMethod $rawCategory $rawTitle'.toLowerCase();

      for (final method in allMethods) {
        if (_matchesMethod(combined, method)) {
          usageCounts[method.id] = (usageCounts[method.id] ?? 0) + 1;
        }
      }
    }

    final mapped = allMethods.map((m) {
      final count = usageCounts[m.id] ?? 0;
      return m.copyWith(userBrewCount: count);
    }).toList();

    mapped.sort((a, b) {
      if (a.userBrewCount != b.userBrewCount) {
        return b.userBrewCount.compareTo(a.userBrewCount); // Terbanyak seduh di depan (5x, 3x, dst)
      }
      return _defaultPopularity(a.id).compareTo(_defaultPopularity(b.id));
    });

    return mapped;
  }

  /// Mengurutkan barista spotlight berdasarkan seberapa sering user menyeduh resep barista tersebut.
  /// Barista yang resepnya paling sering diseduh user akan berada di urutan paling depan
  /// (misal: Tetsu Kasuya 5x, Ryan Wibawa 3x, dst).
  static List<Map<String, dynamic>> sortBaristasByUserUsage(
    List<Map<String, dynamic>> baristas,
    List<dynamic> brewHistory,
  ) {
    if (baristas.isEmpty) return [];

    final authorCounts = <String, int>{};
    final slugCounts = <String, int>{};

    for (final record in brewHistory) {
      if (record is! Map) continue;
      final rawAuthor = (record['author'] ?? record['brewer'] ?? '').toString();
      final clean = BaristaUtils.cleanName(rawAuthor).trim().toLowerCase();
      final slug = BaristaUtils.slugFromAuthor(rawAuthor);
      if (clean.isNotEmpty) {
        authorCounts[clean] = (authorCounts[clean] ?? 0) + 1;
      }
      if (slug.isNotEmpty) {
        slugCounts[slug] = (slugCounts[slug] ?? 0) + 1;
      }
    }

    final list = baristas.map((b) {
      final item = Map<String, dynamic>.from(b);
      final rawAuthor = b['author']?.toString() ?? b['name']?.toString() ?? '';
      final clean = BaristaUtils.cleanName(rawAuthor).trim().toLowerCase();
      final slug = BaristaUtils.slugFromAuthor(rawAuthor);

      int count = authorCounts[clean] ?? slugCounts[slug] ?? 0;
      if (count == 0) {
        for (final entry in authorCounts.entries) {
          if (entry.key.isNotEmpty && (clean.contains(entry.key) || entry.key.contains(clean))) {
            count = entry.value;
            break;
          }
        }
      }

      item['userBrewCount'] = count;
      return item;
    }).toList();

    list.sort((a, b) {
      final countA = (a['userBrewCount'] as num?)?.toInt() ?? 0;
      final countB = (b['userBrewCount'] as num?)?.toInt() ?? 0;
      if (countA != countB) {
        return countB.compareTo(countA); // Terbanyak seduh di depan (5x, 3x, dst)
      }
      // Peringkat barista terkemuka/prestise dunia jika sama-sama belum diseduh
      final prioA = _baristaPrestigePriority(a['author']?.toString() ?? a['name']?.toString() ?? '');
      final prioB = _baristaPrestigePriority(b['author']?.toString() ?? b['name']?.toString() ?? '');
      if (prioA != prioB) {
        return prioA.compareTo(prioB);
      }
      final recipesA = (a['recipeCount'] as num?)?.toInt() ?? 0;
      final recipesB = (b['recipeCount'] as num?)?.toInt() ?? 0;
      if (recipesA != recipesB) {
        return recipesB.compareTo(recipesA);
      }
      return (a['name'] as String).compareTo(b['name'] as String);
    });

    return list;
  }

  static bool _matchesMethod(String text, BrewMethodItem item) {
    final m = text.toLowerCase();
    switch (item.id) {
      case 'hario_v60':
        if (m.contains('japanese') || m.contains('flash') || m.contains('es drip') || m.contains('iced drip') || m.contains('ice drip')) {
          return false;
        }
        return m.contains('v60') || m.contains('hario') || m.contains('switch');
      case 'aeropress':
        return m.contains('aero') || m.contains('aeropress');
      case 'kalita_wave':
        return m.contains('kalita') || m.contains('wave');
      case 'moka_pot':
        return m.contains('moka') || m.contains('bialetti') || m.contains('stovetop');
      case 'chemex':
        return m.contains('chemex');
      case 'espresso':
        return m.contains('espresso') || m.contains('mesin');
      case 'french_press':
        return m.contains('french') || m.contains('plunger') || m.contains('press pot');
      case 'clever':
        return m.contains('clever');
      case 'syphon':
        return m.contains('syphon') || m.contains('siphon') || m.contains('vacuum');
      case 'cold_brew':
        return m.contains('cold brew') || m.contains('cold drip') || m.contains('kyoto');
      case 'cupping':
        return m.contains('cupping') || m.contains('tasting');
      case 'drip_maker':
        return m.contains('drip maker') || m.contains('batch') || m.contains('moccamaster');
      case 'bee_house':
        return m.contains('bee house') || m.contains('beehouse');
      case 'bonmac':
        return m.contains('bonmac');
      case 'japanese_drip':
        return m.contains('japanese') || m.contains('flash') || m.contains('iced drip') || m.contains('es drip') || m.contains('ice drip');
      case 'vietnam_drip':
        return m.contains('vietnam') || m.contains('phin');
      case 'origami_dripper':
        return m.contains('origami');
      case 'turkish_coffee':
        return m.contains('turkish') || m.contains('turki') || m.contains('cezve') || m.contains('ibrik');
      default:
        return m.contains(item.id.toLowerCase()) || m.contains(item.filterKey.toLowerCase());
    }
  }

  static int _defaultPopularity(String methodId) {
    switch (methodId) {
      case 'hario_v60':
        return 1;
      case 'aeropress':
        return 2;
      case 'kalita_wave':
        return 3;
      case 'japanese_drip':
        return 4;
      case 'origami_dripper':
        return 5;
      case 'vietnam_drip':
        return 6;
      case 'espresso':
        return 7;
      case 'moka_pot':
        return 8;
      case 'french_press':
        return 9;
      case 'chemex':
        return 10;
      case 'turkish_coffee':
        return 11;
      case 'clever':
        return 12;
      case 'cold_brew':
        return 13;
      case 'syphon':
        return 14;
      case 'bee_house':
        return 15;
      case 'bonmac':
        return 16;
      case 'drip_maker':
        return 17;
      case 'cupping':
        return 18;
      default:
        return 99;
    }
  }

  static int _baristaPrestigePriority(String rawAuthor) {
    final clean = BaristaUtils.cleanName(rawAuthor).toLowerCase();
    if (clean.contains('tetsu kasuya')) return 1;
    if (clean.contains('ryan wibawa')) return 2;
    if (clean.contains('mikael jasin')) return 3;
    if (clean.contains('odd-steinar') || clean.contains('tollefsen')) return 4;
    if (clean.contains('konstantinos') || clean.contains('iatridis')) return 5;
    if (clean.contains('chad wang')) return 6;
    if (clean.contains('emi fukahori')) return 7;
    if (clean.contains('du jianing')) return 8;
    if (clean.contains('patrik rolf')) return 9;
    if (clean.contains('benjamin prager')) return 10;
    if (clean.contains('mikaela wallgren')) return 11;
    if (clean.contains('james hoffmann')) return 12;
    if (clean.contains('lance hedrick')) return 13;
    if (clean.contains('john christopher')) return 14;
    if (clean.contains('hiro lesmana')) return 15;
    if (clean.contains('harison chandra')) return 16;
    return 99;
  }
}
