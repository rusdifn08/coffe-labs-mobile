import 'dart:math';

import '../models/resolved_coffee_bean.dart';
import 'coffee_knowledge_graph_service.dart';
import 'scanned_bean_recipe_planner.dart';

class TerroirProfile {
  final String canonicalName;
  final String regionProvince;
  final String defaultAltitude;
  final String defaultVarietals;
  final List<String> keywords;

  const TerroirProfile({
    required this.canonicalName,
    required this.regionProvince,
    required this.defaultAltitude,
    required this.defaultVarietals,
    required this.keywords,
  });
}

class ProcessSensoryProfile {
  final String canonicalName;
  final int recommendedTempC;
  final String topRecipeName;
  final String topRecipeSlug;
  final List<String> signatureNotes;

  const ProcessSensoryProfile({
    required this.canonicalName,
    required this.recommendedTempC,
    required this.topRecipeName,
    required this.topRecipeSlug,
    required this.signatureNotes,
  });
}

class CognitiveBeanAnalyzer {
  static const List<String> _noisePhrases = [
    'fresh bean',
    'better brew',
    'fresh bean better brew',
    'roasting date',
    'roast date',
    'tgl roasting',
    'best before',
    'production date',
    'exp date',
    'expired date',
    'net weight',
    'netto',
    'berat bersih',
    '100% arabica',
    '100% arabika',
    'pure arabica',
    'specialty coffee',
    'specialty coffee arabica beans',
    'arabica beans',
    'arabika beans',
    'roasted beans',
    'single origin',
    'whole bean',
    'whole beans',
    'biji kopi',
    'biji kopi pilihan',
    'bubuk kopi',
    'ground coffee',
    'drip coffee',
    'filter coffee',
    'espresso roast',
    'espresso',
    'filter roast',
    'omni roast',
    'official store',
    'diproduksi oleh',
    'diproduksi',
    'p-irt',
    'pirt',
    'halal',
    'bpom',
    'dari gunung',
    'untuk cita rasa terbaik',
    'dari gunung, untuk cita rasa terbaik',
    'dart gunung',
    'citai terbaik',
    'cita rasa terbaik',
    'terbaik wine',
    'premium quality',
    'fresh roasted',
    'master your brew',
    'indonesia',
    'coffee bean',
    'coffee beans',
    'proses',
    'process',
  ];

  static const List<TerroirProfile> _terroirProfiles = [
    TerroirProfile(
      canonicalName: 'Gunung Halu',
      regionProvince: 'Gunung Halu, Bandung Barat, Jawa Barat',
      defaultAltitude: '1350 - 1650 MDPL',
      defaultVarietals: 'Sigararutang, Lini S795, Ateng Super',
      keywords: ['gunung halu', 'halu', 'gn halu', 'gununghalu', 'haloe', 'sindangkerta', 'halu banana'],
    ),
    TerroirProfile(
      canonicalName: 'Kamojang Garut',
      regionProvince: 'Kamojang, Garut, Jawa Barat',
      defaultAltitude: '1400 - 1750 MDPL',
      defaultVarietals: 'Typica, Sigararutang, Mixed Variety',
      keywords: ['kamojang', 'garut', 'amojang', 'wanoja', 'papandayan', 'cikuray', 'wanoja coffee', 'west java', 'west jav', 'jawa barat'],
    ),
    TerroirProfile(
      canonicalName: 'West Java',
      regionProvince: 'Jawa Barat, Indonesia',
      defaultAltitude: '1350 - 1700 MDPL',
      defaultVarietals: 'Sigararutang, Lini S795, Typica',
      keywords: ['west java', 'jawa barat', 'priangan', 'preanger'],
    ),
    TerroirProfile(
      canonicalName: 'Gunung Puntang',
      regionProvince: 'Gunung Puntang, Bandung Selatan, Jawa Barat',
      defaultAltitude: '1200 - 1600 MDPL',
      defaultVarietals: 'Java Typica, Sigararutang, Lini S795',
      keywords: ['gunung puntang', 'gn puntang', 'puntang', 'puntan'],
    ),
    TerroirProfile(
      canonicalName: 'Malabar',
      regionProvince: 'Gunung Malabar / Pangalengan, Jawa Barat',
      defaultAltitude: '1400 - 1800 MDPL',
      defaultVarietals: 'Sigararutang, Lini S795, Kartika',
      keywords: ['malabar', 'pangalengan', 'ciwidey', 'gunung tilu', 'tilu'],
    ),
    TerroirProfile(
      canonicalName: 'Aceh Gayo',
      regionProvince: 'Dataran Tinggi Gayo, Aceh',
      defaultAltitude: '1400 - 1750 MDPL',
      defaultVarietals: 'Abyssinia, Timtim, Bourbon, Ateng Super',
      keywords: ['gayo', 'aceh', 'takengon', 'bener meriah', 'pantan musara', 'kenawat', 'avatara'],
    ),
    TerroirProfile(
      canonicalName: 'Bali Kintamani',
      regionProvince: 'Kintamani, Bali',
      defaultAltitude: '1200 - 1500 MDPL',
      defaultVarietals: 'Kartika, Kopyol, USDA 762',
      keywords: ['kintamani', 'bali', 'ulian', 'batur', 'mengani'],
    ),
    TerroirProfile(
      canonicalName: 'Toraja',
      regionProvince: 'Toraja, Sulawesi Selatan',
      defaultAltitude: '1500 - 1900 MDPL',
      defaultVarietals: 'Lini S795 (Jember), Typica',
      keywords: ['toraja', 'sapan', 'pulu pulu', 'enrekang', 'mamasa'],
    ),
    TerroirProfile(
      canonicalName: 'Flores Bajawa',
      regionProvince: 'Flores Bajawa, NTT',
      defaultAltitude: '1300 - 1600 MDPL',
      defaultVarietals: 'Juria (Typica), Kartika, Lini S795',
      keywords: ['flores', 'bajawa', 'manggarai', 'ngada', 'jurang'],
    ),
    TerroirProfile(
      canonicalName: 'Kerinci',
      regionProvince: 'Gunung Kerinci, Sumatera',
      defaultAltitude: '1400 - 1700 MDPL',
      defaultVarietals: 'Andungsari, Sigararutang',
      keywords: ['kerinci', 'solok', 'koerintji', 'jambi', 'kayu aro', 'gunung tujuh'],
    ),
    TerroirProfile(
      canonicalName: 'Temanggung',
      regionProvince: 'Temanggung, Jawa Tengah',
      defaultAltitude: '1300 - 1600 MDPL',
      defaultVarietals: 'Kartika, Lini S795',
      keywords: ['temanggung', 'sindoro', 'sumbing', 'wonosobo', 'dieng'],
    ),
    TerroirProfile(
      canonicalName: 'Java Ijen',
      regionProvince: 'Kawah Ijen, Jawa Timur',
      defaultAltitude: '1300 - 1600 MDPL',
      defaultVarietals: 'USDA 762, Kartika, Blue Mountain',
      keywords: ['ijen', 'raung', 'argopuro', 'wonosalam', 'bromo'],
    ),
    TerroirProfile(
      canonicalName: 'Papua Wamena',
      regionProvince: 'Pegunungan Tengah / Wamena, Papua',
      defaultAltitude: '1500 - 2000 MDPL',
      defaultVarietals: 'Typica, Bourbon',
      keywords: ['wamena', 'bpiri', 'jayawijaya', 'papua', 'moanemani', 'halmahera'],
    ),
    TerroirProfile(
      canonicalName: 'Ethiopia',
      regionProvince: 'Sidama / Yirgacheffe / Guji, Ethiopia',
      defaultAltitude: '1850 - 2200 MDPL',
      defaultVarietals: 'Ethiopian Heirloom (74110 / 74158)',
      keywords: ['ethiopia', 'yirgacheffe', 'guji', 'sidama', 'sidamo', 'chelbesa', 'bombe'],
    ),
    TerroirProfile(
      canonicalName: 'Colombia',
      regionProvince: 'Huila / Cauca / Tolima, Colombia',
      defaultAltitude: '1600 - 2000 MDPL',
      defaultVarietals: 'Pink Bourbon, Caturra, Castillo',
      keywords: ['colombia', 'huila', 'cauca', 'tolima', 'quindio'],
    ),
    TerroirProfile(
      canonicalName: 'Panama Boquete',
      regionProvince: 'Chiriquí, Panama',
      defaultAltitude: '1650 - 1950 MDPL',
      defaultVarietals: 'Panama Geisha, Catuai',
      keywords: ['panama', 'boquete', 'volcan'],
    ),
  ];

  static const Map<String, List<String>> _flavorLexicon = {
    'Watermelon': ['watermelon', 'water melon', 'laterrnelo', 'watermelo', 'watermalon', 'waternelon', 'watermalo', 'watermalen', 'semangka', 'melon'],
    'Banana': ['banana', 'banan', 'banani', 'pisang'],
    'Sweet Caramel': ['sweet caramel', 'caramel', 'karamel', 'toffee', 'dulce de leche'],
    'Mandarin Orange': ['mandarin orange', 'mandarin', 'landarir )range', 'landarjn )range', 'landarjn range', 'landarjn orange', 'landarjn', 'landarir', 'orange', 'tangerine', 'jeruk mandarin'],
    'Strawberry': ['strawberry', 'starberry', 'strawbery', 'trawben', 'trawbern', 'stroberi', 'strawberries'],
    'Blueberry': ['blueberry', 'bluberry', 'bluebery', 'beri', 'berries'],
    'Raspberry': ['raspberry', 'rasberry', 'frambos'],
    'Blackberry': ['blackberry', 'black berry'],
    'Jasmine': ['jasmine', 'jasmin', 'jasmne', 'melati'],
    'Black Tea': ['tea', 'blacktea', 'earlgrey', 'teh', 'black tea', 'floral tea'],
    'Earl Grey': ['earl grey', 'earlgrey', 'bergamot tea'],
    'Winey': ['wine', 'winey', 'winery', 'red wine', 'fermented'],
    'Red Grape': ['grape', 'red grape', 'anggur'],
    'Blackcurrant': ['blackcurrant', 'currant', 'kismis'],
    'Peach': ['peach', 'apricot', 'persik', 'stone fruit'],
    'Mango': ['mango', 'mangga', 'tropical mango'],
    'Pineapple': ['pineapple', 'nanas', 'passion fruit', 'markisa'],
    'Passion Fruit': ['passion fruit', 'markisa'],
    'Papaya': ['papaya', 'pepaya'],
    'Guava': ['guava', 'jambu', 'water guava', 'jambu air'],
    'Lychee': ['lychee', 'litchi', 'lengkeng', 'longan'],
    'Apple': ['apple', 'red apple', 'green apple', 'apel', 'malus'],
    'Lemon Citrus': ['lemon', 'lime', 'citrus', 'jeruk', 'bergamot'],
    'Milk Chocolate': ['milk chocolate', 'chocolate', 'choco', 'cokelat'],
    'Dark Cocoa': ['dark cocoa', 'cacao', 'dark chocolate', 'cocoa nibs'],
    'Caramel': ['caramel', 'karamel', 'toffee'],
    'Brown Sugar': ['brown sugar', 'gula aren', 'palm sugar', 'cane sugar'],
    'Wild Honey': ['honey', 'madu', 'wild honey'],
    'Chestnut': ['chestnut', 'almond', 'hazelnut', 'kacang'],
    'Hazelnut': ['hazelnut', 'almond', 'pecan'],
    'Red Fruit': ['red fruit', 'buah merah', 'plum', 'cherry'],
    'Cherry': ['cherry', 'black cherry', 'ceri'],
    'Plum': ['plum', 'black plum'],
    'Cinnamon': ['cinnamon', 'kayu manis', 'spice'],
    'Vanilla': ['vanilla', 'vanila'],
    'Floral': ['floral', 'flower', 'bunga', 'rose', 'chamomile', 'osmanthus'],
  };

  /// Kamus terroir terpadu (bawaan + `coffee_knowledge_graph.json`).
  static List<TerroirProfile> _mergedTerroirs() {
    final kg = CoffeeKnowledgeGraphService.instance;
    kg.ensureSyncInitialized();
    if (kg.terroirs.isEmpty) return _terroirProfiles;
    final merged = List<TerroirProfile>.from(_terroirProfiles);
    for (final ext in kg.terroirs) {
      final exists = merged.indexWhere(
        (m) => m.canonicalName.toLowerCase() == ext.canonicalName.toLowerCase(),
      );
      if (exists == -1) {
        merged.add(ext);
      } else {
        final base = merged[exists];
        merged[exists] = TerroirProfile(
          canonicalName: base.canonicalName,
          regionProvince: base.regionProvince,
          defaultAltitude: base.defaultAltitude,
          defaultVarietals: base.defaultVarietals,
          keywords: {...base.keywords, ...ext.keywords}.toList(),
        );
      }
    }
    return merged;
  }

  /// Kamus flavor terpadu (bawaan + 355+ cluster Knowledge Graph & 1,000+ katalog biji).
  static Map<String, List<String>> _mergedFlavorLexicon() {
    final kg = CoffeeKnowledgeGraphService.instance;
    kg.ensureSyncInitialized();
    final map = <String, List<String>>{};
    for (final entry in _flavorLexicon.entries) {
      map[entry.key] = List<String>.from(entry.value);
    }
    for (final entry in kg.flavorLexicon.entries) {
      final key = entry.key.trim();
      if (key.length < 3 || key.contains('...') || key.contains(':')) continue;
      final existing = map.putIfAbsent(key, () => [key.toLowerCase()]);
      for (final syn in entry.value) {
        final s = syn.trim().toLowerCase();
        if (s.length >= 3 && !s.contains('...') && !existing.contains(s)) {
          existing.add(s);
        }
      }
    }
    return map;
  }

  /// Mendeteksi token rusak/sampah hasil salah baca OCR (mis. `Full01`, `Gnowvrba`).
  static bool isGarbledToken(String token) {
    final clean = token.replaceAll(RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'), '');
    if (clean.length < 3) return false;
    final lower = clean.toLowerCase();

    // Pengecualian untuk kode kultivar / angka berat resmi kopi
    if (RegExp(r'^(s795|sl28|sl34|usda\d*|74110|74158|\d+[gm]l?|c40|20fr)$', caseSensitive: false)
        .hasMatch(lower)) {
      return false;
    }

    // Huruf bercampur angka di dalam 1 kata (mis. `Full01`, `Wa7er`)
    if (RegExp(r'[a-zA-Z]+\d+|\d+[a-zA-Z]+').hasMatch(clean) &&
        !RegExp(r'^\d{1,4}(?:g|gr|gram|kg|oz|ml|mdpl|masl)$', caseSensitive: false).hasMatch(lower)) {
      return true;
    }

    // Kata panjang tanpa vokal wajar (contoh: `Gnowvrba`, `xkjvq`) bila tidak dikenal Knowledge Graph
    final alphaOnly = lower.replaceAll(RegExp(r'[^a-z]'), '');
    if (alphaOnly.length >= 6) {
      final vowels = RegExp(r'[aeiou]').allMatches(alphaOnly).length;
      if (vowels / alphaOnly.length < 0.20) {
        return true;
      }
      if (RegExp(r'[bcdfghjklmnpqrstvwxyz]{5,}').hasMatch(alphaOnly)) {
        return true;
      }
    }

    return false;
  }

  static bool isNoise(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length <= 1) return true;
    final lower = trimmed.toLowerCase();

    if ((lower.startsWith('[ ]') || lower.startsWith('( )') || lower.startsWith('[]')) &&
        !lower.contains('x') &&
        !lower.contains('v') &&
        !lower.contains('✓')) {
      return true;
    }

    if (CoffeeKnowledgeGraphService.instance.noisePhrases.contains(lower)) {
      return true;
    }

    for (final noise in _noisePhrases) {
      if (lower == noise) return true;
    }

    if (lower.contains('fresh bean') || lower.contains('better brew')) return true;
    if (lower.contains('dari gunung') || lower.contains('dart gunung')) return true;
    if (lower.contains('cita rasa') ||
        lower.contains('citai terbaik') ||
        lower.contains('terbaik wine') ||
        lower.contains('cita rasa terbaik')) {
      return true;
    }
    if (lower.contains('roasting date') || lower.contains('roast date') || lower.contains('tgl roasting')) {
      return true;
    }
    if (lower.contains('best before') || lower.contains('exp date') || lower.contains('production date')) {
      return true;
    }
    if (lower.contains('netto') || lower.contains('net weight') || lower.contains('berat bersih')) {
      return true;
    }
    if (lower.contains('p-irt') || lower.contains('pirt') || lower.contains('halal') || lower.contains('bpom')) {
      return true;
    }
    if (lower.contains('diproduksi') || lower.contains('produced by') || lower.contains('roasted by')) {
      return true;
    }
    if (lower.contains('100% arabica') ||
        lower.contains('100% arabika') ||
        lower.contains('premium quality') ||
        lower.contains('arabica beans') ||
        lower.contains('specialty coffee')) {
      // Hati-hati: jangan anggap noise bila baris mengandung merek roastery atau nama kopi spesifik
      final hasRoastery = CoffeeKnowledgeGraphService.instance.matchKnownRoastery(lower) != null;
      final hasOrigin = _hasAnyTerroirKeyword(lower);
      if (!hasRoastery && !hasOrigin && !lower.contains('watermelon') && !lower.contains('smash')) {
        return true;
      }
    }
    if (lower.contains('single origin') || lower.contains('whole bean') || lower.contains('whole beans')) {
      final hasOrigin = _hasAnyTerroirKeyword(lower);
      final hasRoastery = CoffeeKnowledgeGraphService.instance.matchKnownRoastery(lower) != null;
      if (!hasOrigin && !hasRoastery && !lower.startsWith('origin:')) {
        return true;
      }
    }

    if (RegExp(r'^\d+[\s]*(g|gr|gram|kg|oz|ml)?$', caseSensitive: false).hasMatch(lower)) return true;
    if (RegExp(r'^\d{1,2}[/\-\.]\d{1,2}([/\-\.]\d{2,4})?$').hasMatch(lower)) return true;

    // Baris pendek yang seluruh katanya merupakan token garbled OCR
    final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isNotEmpty && words.every(isGarbledToken)) {
      return true;
    }

    return false;
  }

  static bool _hasAnyTerroirKeyword(String lowerText) {
    for (final p in _terroirProfiles) {
      for (final kw in p.keywords) {
        if (lowerText.contains(kw)) return true;
      }
    }
    return false;
  }

  static double jaroWinkler(String s1, String s2) =>
      CoffeeKnowledgeGraphService.jaroWinkler(s1, s2);

  static TerroirProfile? findOrigin(String text) {
    final clean = CoffeeKnowledgeGraphService.repairOcrText(text).toLowerCase();
    final profiles = _mergedTerroirs();

    // 1. Direct word-boundary / phrase matching — longest-match-wins.
    TerroirProfile? bestProfile;
    int bestLen = 0;
    for (final profile in profiles) {
      for (final kw in profile.keywords) {
        if (kw.length < 3) continue;
        final matched = RegExp(r'(?:^|[^a-z0-9])' + RegExp.escape(kw) + r'(?:$|[^a-z0-9])').hasMatch(clean);
        if (matched && kw.length > bestLen) {
          bestLen = kw.length;
          bestProfile = profile;
        }
      }
    }
    if (bestProfile != null) return bestProfile;

    // 2. Fuzzy token matching — abaikan kata generik kopi (`arabica`, `beans`) & token rusak OCR.
    const originFuzzyStopWords = {
      'arabica',
      'arabika',
      'robusta',
      'excelsa',
      'liberica',
      'kopi',
      'coffee',
      'beans',
      'bean',
      'roast',
      'roaster',
      'roastery',
      'roasters',
      'specialty',
      'single',
      'origin',
      'natural',
      'washed',
      'honey',
      'filter',
      'espresso',
      'process',
      'proses',
      'smash',
      'watermelon',
      'strawberry',
      'banana',
      'water',
      'mdpl',
      'masl',
    };
    final words = clean
        .split(RegExp(r'[^a-zA-Z0-9]'))
        .where((w) => w.length >= 5 && !originFuzzyStopWords.contains(w) && !isGarbledToken(w));
    TerroirProfile? fuzzyProfile;
    int fuzzyLen = 0;
    double fuzzyScore = 0.0;
    for (final profile in profiles) {
      for (final kw in profile.keywords) {
        if (kw.length < 5) continue;
        for (final word in words) {
          final score = jaroWinkler(word, kw);
          if (score >= 0.91) {
            final isBetter = fuzzyProfile == null ||
                kw.length > fuzzyLen ||
                (kw.length == fuzzyLen && score > fuzzyScore);
            if (isBetter) {
              fuzzyProfile = profile;
              fuzzyLen = kw.length;
              fuzzyScore = score;
            }
          }
        }
      }
    }
    return fuzzyProfile;
  }

  static Map<String, String> _extractStructuredFields(String fullText) {
    final fields = <String, String>{};
    final lines = fullText
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i];
      final nextLine = (i + 1 < lines.length) ? lines[i + 1] : '';

      // Multi-line header check: label header berdiri sendiri pada 1 baris
      final isFarmerHeader = RegExp(
        r'^(?:FARMER|PRODUCER|PROCESSOR|PETANI|ROASTERY|ROASTER|ROASTED\s*BY|DIPRODUKSI\s*OLEH)\s*[:\-]?$',
        caseSensitive: false,
      ).hasMatch(trimmed);
      if (isFarmerHeader && !fields.containsKey('roastery') && nextLine.isNotEmpty) {
        fields['roastery'] = nextLine;
      }

      final isVarietyHeader = RegExp(
        r'^(?:VARIETY|VARIETAS|UARIETY|KULTIVAR)\s*[:\-]?$',
        caseSensitive: false,
      ).hasMatch(trimmed);
      if (isVarietyHeader && !fields.containsKey('variety') && nextLine.isNotEmpty) {
        fields['variety'] = nextLine;
      }

      final isProcessHeader = RegExp(
        r'^(?:PROCESS|PROSES|PASCAPANEN|METODE)\s*[:\-]?$',
        caseSensitive: false,
      ).hasMatch(trimmed);
      if (isProcessHeader && !fields.containsKey('process') && nextLine.isNotEmpty) {
        fields['process'] = nextLine;
      }

      final isOriginHeader = RegExp(
        r'^(?:ORIGIN|ASAL|TERROIR|REGION|LOKASI)\s*[:\-]?$',
        caseSensitive: false,
      ).hasMatch(trimmed);
      if (isOriginHeader && !fields.containsKey('origin') && nextLine.isNotEmpty) {
        fields['origin'] = nextLine;
      }

      final isAltitudeHeader = RegExp(
        r'^(?:ALTITUDE|ELEVATION|KETINGGIAN)\s*[:\-]?$',
        caseSensitive: false,
      ).hasMatch(trimmed);
      if (isAltitudeHeader && !fields.containsKey('altitude') && nextLine.isNotEmpty) {
        fields['altitude'] = nextLine;
      }

      final isNotesHeader = RegExp(
        r'^(?:TASTING\s*NOTES?|TASTINGNOTES?|FLAVOR\s*PROFILE|TASTE\s*NOTES?|NOTES?|FLAVOR|CITA\s*RASA)\s*[:\-]?$',
        caseSensitive: false,
      ).hasMatch(trimmed);
      if (isNotesHeader && !fields.containsKey('notes') && nextLine.isNotEmpty) {
        fields['notes'] = nextLine;
      }

      // Tasting notes (butuh ':' / '-' atau frasa multi-kata TASTING NOTES)
      final notesMatch = RegExp(
        r'(?:^|\b)(?:TASTING\s*NOTES?|TASTINGNOTES?|FLAVOR\s*PROFILE|TASTE\s*NOTES?)\s*[:\-\s]\s*(.+)|(?:^|\b)(?:NOTES?|FLAVOR|CITA\s*RASA)\s*[:\-]\s*(.+)',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (notesMatch != null && !fields.containsKey('notes')) {
        String val = (notesMatch.group(1) ?? notesMatch.group(2))?.trim() ?? '';
        val = val
            .split(RegExp(r'\b(?:FARMER|PRODUCER|ORIGIN|ASAL|PROCESS|PROSES|VARIETY|UARIETY|ALTITUDE)\b', caseSensitive: false))
            .first
            .trim();
        if (val.isNotEmpty && !isNoise(val)) fields['notes'] = val;
      }

      // Origin: WAJIB di awal baris atau diikuti ':' / '-' agar tidak menelan "Single Origin Specialty Coffee..."!
      final originMatch = RegExp(
        r'^(?:ORIGIN|ASAL|TERROIR|REGION|LOKASI)\s*[:\-–]\s*(.+)',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (originMatch != null && !fields.containsKey('origin')) {
        String val = originMatch.group(1)?.trim() ?? '';
        val = val
            .split(RegExp(r'\b(?:FARMER|PRODUCER|PROCESS|PROSES|VARIETY|UARIETY|ALTITUDE|TASTING)\b', caseSensitive: false))
            .first
            .trim();
        if (val.isNotEmpty && !isNoise(val)) fields['origin'] = val;
      }

      // Farmer / Producer / Roastery
      final roasterMatch = RegExp(
        r'^(?:FARMER|PRODUCER|PROCESSOR|PETANI|ROASTERY|ROASTER|ROASTED\s*BY|DIPRODUKSI\s*OLEH)\s*[:\-–]\s*(.+)',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (roasterMatch != null && !fields.containsKey('roastery')) {
        String val = roasterMatch.group(1)?.trim() ?? '';
        val = val
            .split(RegExp(r'\b(?:PROCESS|PROSES|VARIETY|UARIETY|ALTITUDE|TASTING|ORIGIN)\b', caseSensitive: false))
            .first
            .trim();
        if (val.isNotEmpty) fields['roastery'] = val;
      }

      // Pattern: "BY <BRAND>" (e.g. "BY TIGA IKAT COFFEE SUPPLY")
      final byMatch = RegExp(r'^\s*BY\s+([A-Za-z0-9\s]{3,40})\b', caseSensitive: false).firstMatch(trimmed);
      if (byMatch != null && !fields.containsKey('roastery')) {
        fields['roastery'] = byMatch.group(1)?.trim() ?? '';
      }

      // Process
      final procMatch = RegExp(
        r'^(?:PROCESS|PROSES|PASCAPANEN|METODE)\s*[:\-–]\s*(.+)',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (procMatch != null && !fields.containsKey('process')) {
        String val = procMatch.group(1)?.trim() ?? '';
        val = val
            .split(RegExp(r'\b(?:VARIETY|UARIETY|ALTITUDE|TASTING|ORIGIN|FARMER)\b', caseSensitive: false))
            .first
            .trim();
        if (val.isNotEmpty) fields['process'] = val;
      }

      // Altitude
      final altMatch = RegExp(
        r'^(?:ALTITUDE|ELEVATION|KETINGGIAN)\s*[:\-–]\s*(.+)',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (altMatch != null && !fields.containsKey('altitude')) {
        String val = altMatch.group(1)?.trim() ?? '';
        val = val
            .split(RegExp(r'\b(?:VARIETY|UARIETY|PROCESS|PROSES|TASTING|ORIGIN|FARMER)\b', caseSensitive: false))
            .first
            .trim();
        if (val.isNotEmpty) fields['altitude'] = val;
      }

      // Variety
      final varMatch = RegExp(
        r'^(?:VARIETY|VARIETAS|UARIETY|KULTIVAR)\s*[:\-–]\s*(.+)',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (varMatch != null && !fields.containsKey('variety')) {
        String val = varMatch.group(1)?.trim() ?? '';
        val = val
            .split(RegExp(r'\b(?:PROCESS|PROSES|ALTITUDE|TASTING|ORIGIN|FARMER|NOTES)\b', caseSensitive: false))
            .first
            .trim();
        val = val.split(RegExp(r'\d{3,4}\s*(?:masl|mdpl|mas|m\b)', caseSensitive: false)).first.trim();
        if (val.isNotEmpty) fields['variety'] = val;
      }
    }
    return fields;
  }

  static String _stripGarbledAndMarketingWords(String raw) {
    final repaired = CoffeeKnowledgeGraphService.repairOcrText(raw);
    var tokens = repaired.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    tokens = tokens.where((t) => !isGarbledToken(t)).toList();
    var joined = tokens.join(' ').trim();
    joined = joined
        .replaceAll(
          RegExp(
            r'\b(?:100%\s*)?(?:specialty\s*coffee|single\s*origin|whole\s*beans?|official\s*store|arabica\s*beans?|arabika\s*beans?|roasted\s*beans?|kopi\s*arabika|kopi\s*arabica)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return joined;
  }

  static String _cleanTitleCandidate(String text, {String? roasteryToStrip}) {
    String cleaned = _stripGarbledAndMarketingWords(text);
    if (roasteryToStrip != null && roasteryToStrip.isNotEmpty && roasteryToStrip != 'Specialty Roastery') {
      final lowerR = roasteryToStrip.toLowerCase();
      if (cleaned.toLowerCase().contains(lowerR)) {
        cleaned = cleaned.replaceAll(RegExp(RegExp.escape(roasteryToStrip), caseSensitive: false), '').trim();
      }
      final shortBrand = lowerR.split(' ').first;
      if (shortBrand.length >= 4 && cleaned.toLowerCase().startsWith('$shortBrand ')) {
        cleaned = cleaned.substring(shortBrand.length).trim();
      }
    }

    final lower = cleaned.toLowerCase();
    if (lower.contains('watermelon') && (lower.contains('smash') || lower.split(' ').length <= 3)) {
      return 'Watermelon Smash';
    }
    if (lower.contains('halu') && lower.contains('banana')) {
      return 'Halu Banana';
    }
    cleaned = cleaned.replaceAll(RegExp(r'^(?:100%\s*)?(?:arabica|arabika|kopi|coffee)\s+', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+(?:natural|washed|wine|honey|process|proses)$', caseSensitive: false), '');
    cleaned = _stripGarbledAndMarketingWords(cleaned);
    return _titleCase(cleaned.trim());
  }

  /// Mendeteksi apakah teks secara eksplisit menyebut metode pascapanen.
  static bool hasExplicitProcessCue(String text) {
    final clean = CoffeeKnowledgeGraphService.repairOcrText(text).toLowerCase();
    if (clean.contains('[x]') || clean.contains('[v]') || clean.contains('[✓]')) return true;
    return clean.contains('anaerob') ||
        clean.contains('carbonic') ||
        clean.contains('thermal shock') ||
        clean.contains('wine') ||
        clean.contains('giling basah') ||
        clean.contains('wet hulled') ||
        clean.contains('semi washed') ||
        clean.contains('natural') ||
        clean.contains('sun dried') ||
        clean.contains('honey') ||
        clean.contains('madu') ||
        clean.contains('washed') ||
        clean.contains('wet process');
  }

  static ProcessSensoryProfile detectProcess(String text) {
    final repaired = CoffeeKnowledgeGraphService.repairOcrText(text);
    final structured = _extractStructuredFields(repaired);
    final target = (structured['process'] != null && structured['process']!.isNotEmpty)
        ? '${structured['process']} $repaired'
        : repaired;

    final clean = target.toLowerCase();

    // 1. Checkbox matching: [x] NATURAL, [v] WINE, [x] WASHED.
    final checkIndex = clean.indexOf('[x]');
    final checkVIndex = clean.indexOf('[v]');
    final checkTickIndex = clean.indexOf('[✓]');
    final activeCheck = checkIndex != -1 ? checkIndex : (checkVIndex != -1 ? checkVIndex : checkTickIndex);

    if (activeCheck != -1) {
      final after = clean.substring(activeCheck);
      if (after.contains('natural')) return _naturalProfile;
      if (after.contains('wine')) return _wineProfile;
      if (after.contains('washed')) return _washedProfile;
    }

    // 2. Anaerobik natural (paling spesifik lebih dulu).
    final hasAnaerobic = clean.contains('anaerob') || clean.contains('carbonic') || clean.contains('lactic');
    final hasNatural = clean.contains('natural') || clean.contains('natura') || clean.contains('dry process');
    if (hasAnaerobic && hasNatural) return _anaerobicNaturalProfile;
    if (clean.contains('thermal shock')) return _anaerobicProfile;

    // 3. Wine / extended fermentation.
    if (clean.contains('wine') || clean.contains('winery') || clean.contains('extended fermentation')) {
      return _wineProfile;
    }

    // 4. Wet hulled / giling basah (dievaluasi sebelum washed).
    if (clean.contains('giling basah') || clean.contains('wet hulled') || clean.contains('semi washed')) {
      return _wetHulledProfile;
    }

    // 5. Natural (termasuk variasi OCR terpotong/typo).
    if (hasNatural || clean.contains('sun dried')) {
      return _naturalProfile;
    }

    // 6. Honey (dievaluasi sebelum washed).
    if (clean.contains('honey') || clean.contains('madu')) {
      return _honeyProfile;
    }

    // 7. Anaerobic tanpa natural.
    if (hasAnaerobic) return _anaerobicProfile;

    // 8. Washed eksplisit.
    if (clean.contains('washed') || clean.contains('wet process') || clean.contains('fully washed')) {
      return _washedProfile;
    }

    // 9. Smart Inference: bila proses tidak tertulis jelas, lihat sinyal rasa tropis/buah manis kuat
    if (clean.contains('watermelon') ||
        clean.contains('blueberry') ||
        clean.contains('strawberry candy') ||
        clean.contains('tropical fruit') ||
        clean.contains('smash')) {
      return _naturalProfile;
    }

    return _washedProfile;
  }

  static ProcessSensoryProfile _profileForCanonicalProcess(String processName) {
    final p = processName.toLowerCase();
    if (p.contains('anaerobic') && p.contains('natural')) return _anaerobicNaturalProfile;
    if (p.contains('anaerobic') || p.contains('carbonic')) return _anaerobicProfile;
    if (p.contains('wine')) return _wineProfile;
    if (p.contains('wet hulled') || p.contains('giling basah')) return _wetHulledProfile;
    if (p.contains('honey')) return _honeyProfile;
    if (p.contains('natural')) return _naturalProfile;
    return _washedProfile;
  }

  static List<String> matchTastingNotes(String text, [List<Map<String, dynamic>>? blocksDto]) {
    final results = <String>[];
    final lexicon = _mergedFlavorLexicon();
    final repairedText = CoffeeKnowledgeGraphService.repairOcrText(text);
    final structured = _extractStructuredFields(repairedText);

    // 1. Prioritas Utama: Field terstruktur TASTING NOTES
    if (structured.containsKey('notes')) {
      final noteLine = structured['notes']!;
      final parts = noteLine.split(RegExp(r'[,•/\-;]')).map((s) => s.trim()).where((s) => s.length >= 3);
      for (final part in parts) {
        final pLower = CoffeeKnowledgeGraphService.repairOcrText(part).toLowerCase();
        String matchedKey = '';
        for (final entry in lexicon.entries) {
          for (final syn in entry.value) {
            final isShort = syn.length <= 3;
            if (isShort) {
              if (pLower == syn) {
                matchedKey = entry.key;
                break;
              }
            } else {
              if (pLower == syn ||
                  (pLower.contains(syn) && (pLower.length - syn.length).abs() <= 5) ||
                  jaroWinkler(pLower, syn) >= 0.84) {
                matchedKey = entry.key;
                break;
              }
            }
          }
          if (matchedKey.isNotEmpty) break;
        }
        final noteToAdd = matchedKey.isNotEmpty ? matchedKey : _titleCase(part);
        if (!results.contains(noteToAdd) && !isNoise(noteToAdd) && !isGarbledToken(part)) {
          results.add(noteToAdd);
        }
      }
    }

    void scanTokensForFlavors(Iterable<String> tokens) {
      for (final tok in tokens) {
        final tClean = CoffeeKnowledgeGraphService.repairOcrText(tok.trim()).toLowerCase();
        if (tClean.length < 3 || isNoise(tClean) || isGarbledToken(tClean)) continue;
        for (final entry in lexicon.entries) {
          if (results.contains(entry.key)) continue;
          bool matched = false;
          for (final syn in entry.value) {
            if (syn.length <= 3) {
              if (tClean == syn) {
                matched = true;
                break;
              }
            } else {
              if (tClean == syn || (tClean.contains(syn) && syn.length >= 4) || jaroWinkler(tClean, syn) >= 0.85) {
                matched = true;
                break;
              }
            }
          }
          if (matched && !results.contains(entry.key)) {
            results.add(entry.key);
          }
        }
      }
    }

    // 2. Scan blocks directly (Ground Truth visual blocks)
    if (blocksDto != null && blocksDto.isNotEmpty) {
      for (final b in blocksDto) {
        final bText = b['text']?.toString().trim() ?? '';
        if (bText.isEmpty || isNoise(bText)) continue;
        final bLower = bText.toLowerCase();

        if (bLower.startsWith('origin') ||
            bLower.startsWith('asal') ||
            bLower.startsWith('process') ||
            bLower.startsWith('proses') ||
            bLower.startsWith('variety') ||
            bLower.startsWith('varietas') ||
            bLower.startsWith('farmer') ||
            bLower.startsWith('producer') ||
            bLower.startsWith('altitude') ||
            bLower.startsWith('elevation') ||
            bLower.startsWith('by ') ||
            bLower.contains('[x]') ||
            bLower.contains('[v]') ||
            bLower.contains('[ ]') ||
            bLower.contains('( )') ||
            bLower.contains('kopi ') ||
            bLower.contains('coffee') ||
            bLower.contains('bottle') ||
            bLower == 'wine' ||
            bLower == 'natural' ||
            bLower == 'washed') {
          continue;
        }

        final cleanBlock = bText
            .replaceAll(RegExp(r'^(?:TASTING\s*NOTES?|TASTINGNOTES?|FLAVOR|NOTES)\s*[:\-]?\s*', caseSensitive: false), '')
            .trim();
        final tokens = cleanBlock.split(RegExp(r'[,•/\-;]')).map((s) => s.trim()).where((s) => s.length >= 3);
        scanTokensForFlavors(tokens);
      }
    }

    // 3. Scan lines di dalam teks
    final lines = repairedText.split(RegExp(r'[\r\n]+')).map((l) => l.trim()).where((l) => l.isNotEmpty);
    for (final line in lines) {
      if (isNoise(line)) continue;
      final lower = line.toLowerCase();
      if (lower == 'wine' ||
          lower == 'natural' ||
          lower == 'washed' ||
          lower == 'honey' ||
          lower.contains('[ ]') ||
          lower.contains('( )') ||
          lower.contains('[x]') ||
          lower.contains('[v]') ||
          lower.startsWith('proses') ||
          lower.startsWith('process')) {
        continue;
      }

      final tokens = line.split(RegExp(r'[,•/\-;]')).map((s) => s.trim().toLowerCase()).where((s) => s.length >= 3);
      scanTokensForFlavors(tokens);
    }

    return results;
  }

  /// Pecah blok OCR multi-baris menjadi sub-baris dengan koordinat Y terinterpolasi & urut spasial.
  static List<Map<String, dynamic>> _expandAndSortBlocks(List<Map<String, dynamic>> blocksDto) {
    final expanded = <Map<String, dynamic>>[];
    for (final b in blocksDto) {
      final rawText = (b['text']?.toString() ?? '').trim();
      if (rawText.isEmpty) continue;
      final subLines = rawText
          .split(RegExp(r'[\r\n]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (subLines.length <= 1) {
        expanded.add(b);
        continue;
      }

      final baseTopY = (b['top_y'] as num?)?.toDouble() ?? 0.0;
      final baseLeftX = (b['left_x'] as num?)?.toDouble() ?? 0.0;
      final baseW = (b['normalized_width'] as num?)?.toDouble() ?? 0.5;
      final baseH = (b['normalized_height'] as num?)?.toDouble() ?? 0.06;
      final lineH = (baseH / subLines.length).clamp(0.015, 0.25);

      for (int i = 0; i < subLines.length; i++) {
        expanded.add({
          'text': subLines[i],
          'top_y': (baseTopY + (i * lineH)).clamp(0.0, 1.0),
          'left_x': baseLeftX,
          'normalized_width': baseW,
          'normalized_height': lineH,
          'confidence': (b['confidence'] as num?)?.toDouble() ?? 0.95,
        });
      }
    }
    return expanded;
  }

  static ResolvedCoffeeBean analyze({
    required String rawFullText,
    required List<Map<String, dynamic>> blocksDto,
    String? localImagePath,
  }) {
    final kg = CoffeeKnowledgeGraphService.instance;
    kg.ensureSyncInitialized();

    final repairedFullText = CoffeeKnowledgeGraphService.repairOcrText(rawFullText);
    final normalizedBlocks = _expandAndSortBlocks(blocksDto);
    final structured = _extractStructuredFields(repairedFullText);

    final classified = <ClassifiedOcrBlock>[];
    String? detectedRoastery;
    String? titleCandidate;

    for (final b in normalizedBlocks) {
      final text = b['text']?.toString().trim() ?? '';
      final topY = (b['top_y'] as num?)?.toDouble() ?? 0.0;
      final leftX = (b['left_x'] as num?)?.toDouble() ?? 0.0;
      final normW = (b['normalized_width'] as num?)?.toDouble() ?? 0.0;
      final normH = (b['normalized_height'] as num?)?.toDouble() ?? 0.0;

      if (isNoise(text)) {
        classified.add(ClassifiedOcrBlock(
          text: text,
          role: BlockRole.ignoredNoise,
          topY: topY,
          leftX: leftX,
          normalizedWidth: normW,
          normalizedHeight: normH,
        ));
        continue;
      }

      final repairedLine = CoffeeKnowledgeGraphService.repairOcrText(text);
      final lower = repairedLine.toLowerCase();
      BlockRole role;

      final isProc = lower.contains('wine') ||
          lower.contains('natural') ||
          lower.contains('washed') ||
          lower.contains('honey') ||
          lower.contains('anaerobic') ||
          lower.contains('giling basah');

      final originMatch = findOrigin(repairedLine);
      final notesMatched = matchTastingNotes(repairedLine);
      final hasAlt = _extractAltitude(repairedLine) != null;
      final hasVar = _extractVarietal(repairedLine) != null;
      final knownRoasterHit = originMatch == null ? kg.matchKnownRoastery(repairedLine) : null;

      final isExplicitMetadata = lower.startsWith('origin:') ||
          lower.startsWith('asal:') ||
          lower.startsWith('terroir:') ||
          lower.startsWith('farmer:') ||
          lower.startsWith('producer:') ||
          lower.startsWith('roastery:') ||
          lower.startsWith('process:') ||
          lower.startsWith('proses:') ||
          lower.startsWith('altitude:') ||
          lower.startsWith('elevation:') ||
          lower.startsWith('variety:') ||
          lower.startsWith('varietas:') ||
          lower.startsWith('tasting notes:') ||
          lower.startsWith('notes:') ||
          lower.startsWith('filter roast') ||
          lower.startsWith('espresso roast');

      final isRoastery = !isExplicitMetadata &&
          originMatch == null &&
          (knownRoasterHit != null ||
              ((lower.contains('roastery') ||
                      lower.contains('roasters') ||
                      lower.contains('coffee supply') ||
                      lower.startsWith('by ') ||
                      (lower.contains('coffee') && !isProc) ||
                      (lower.contains('bean') && !isProc)) &&
                  (topY <= 0.45 || lower.startsWith('by '))));

      final isHeadlineBanner = (normW >= 0.25 ||
              normH >= 0.04 ||
              lower.contains('watermelon') ||
              (lower.contains('halu') && lower.contains('banana'))) &&
          !isNoise(text) &&
          !isExplicitMetadata &&
          !isRoastery &&
          titleCandidate == null &&
          topY <= 0.75 &&
          !RegExp(r'^\d+[\s]*(ml|g|gr|gram|kg|oz)$', caseSensitive: false).hasMatch(lower);

      if (originMatch != null) {
        role = BlockRole.originOrTitle;
        if (!isExplicitMetadata) {
          String cleaned = _titleCase(repairedLine);
          if (cleaned.toLowerCase().startsWith('kopi ')) {
            cleaned = cleaned.substring(5).trim();
          }
          titleCandidate ??= cleaned;
        }
      } else if (isRoastery) {
        String resolvedBrand;
        if (knownRoasterHit != null) {
          resolvedBrand = knownRoasterHit.canonicalName;
          // Cek apakah di baris yang sama ikut menempel nama produk (mis. "Fugol Coffee Roasters Kopi Arabika Watermelon Smash")
          final residualTitle = _cleanTitleCandidate(
            repairedLine,
            roasteryToStrip: knownRoasterHit.canonicalName,
          );
          if (residualTitle.isNotEmpty &&
              residualTitle.length >= 4 &&
              !isNoise(residualTitle) &&
              residualTitle.toLowerCase() != resolvedBrand.toLowerCase()) {
            titleCandidate ??= residualTitle;
          }
        } else {
          String cleaned = _stripGarbledAndMarketingWords(repairedLine);
          if (cleaned.toLowerCase().startsWith('by ')) {
            cleaned = cleaned.substring(3).trim();
          }
          resolvedBrand = _titleCase(cleaned);
        }
        if (resolvedBrand.isNotEmpty) {
          detectedRoastery ??= resolvedBrand;
        }
        role = BlockRole.roastery;
      } else if (isHeadlineBanner) {
        final cand = _cleanTitleCandidate(text, roasteryToStrip: detectedRoastery);
        if (cand.isNotEmpty && !isNoise(cand)) {
          titleCandidate ??= cand;
        }
        role = BlockRole.originOrTitle;
      } else if (isProc) {
        role = BlockRole.process;
      } else if (hasAlt) {
        role = BlockRole.altitude;
      } else if (hasVar) {
        role = BlockRole.variety;
      } else if (notesMatched.isNotEmpty) {
        role = BlockRole.tastingNote;
      } else {
        role = BlockRole.ignoredNoise;
      }

      classified.add(ClassifiedOcrBlock(
        text: text,
        role: role,
        topY: topY,
        leftX: leftX,
        normalizedWidth: normW,
        normalizedHeight: normH,
      ));
    }

    // Ekstraksi fallback roastery lebih dulu agar bisa memisahkan roastery & judul dari teks mentah
    final rawRoastery = detectedRoastery ??
        _extractRoasteryFromText(repairedFullText) ??
        (structured.containsKey('roastery') ? _titleCase(structured['roastery']!) : null) ??
        (structured.containsKey('farmer') ? _titleCase(structured['farmer']!) : null) ??
        'Specialty Roastery';

    if (titleCandidate == null || titleCandidate.isEmpty) {
      for (final line in repairedFullText.split(RegExp(r'[\r\n]+'))) {
        final trimmed = line.trim();
        final lower = trimmed.toLowerCase();
        if (trimmed.length >= 4 &&
            !isNoise(trimmed) &&
            !lower.startsWith('origin') &&
            !lower.startsWith('asal') &&
            !lower.startsWith('process') &&
            !lower.startsWith('proses') &&
            !lower.startsWith('tasting') &&
            !lower.startsWith('notes') &&
            !lower.startsWith('farmer') &&
            !lower.startsWith('variety') &&
            !lower.startsWith('uariety') &&
            !lower.startsWith('altitude') &&
            !lower.startsWith('by ') &&
            !lower.contains('coffee supply') &&
            !lower.contains('filter roast') &&
            !lower.contains('espresso roast') &&
            !RegExp(r'^\d+[\s]*(g|gr|gram|kg|oz|ml)?$', caseSensitive: false).hasMatch(lower)) {
          final extracted = _cleanTitleCandidate(trimmed, roasteryToStrip: rawRoastery);
          if (extracted.isNotEmpty && !isNoise(extracted)) {
            titleCandidate = extracted;
            break;
          }
        }
      }
    }

    final bool hasExplicitProc = hasExplicitProcessCue(repairedFullText);
    var processProf = detectProcess(repairedFullText);
    final originProf = findOrigin(repairedFullText);
    final explicitAlt = _extractAltitude(repairedFullText);
    final explicitVar = _extractVarietal(repairedFullText);

    final explicitNotes = matchTastingNotes(repairedFullText, normalizedBlocks);
    final filteredNotes = explicitNotes.where((n) {
      if (n == 'Winey' &&
          processProf.canonicalName == 'Wine Process' &&
          explicitNotes.length == 1 &&
          !structured.containsKey('notes')) {
        return false;
      }
      return true;
    }).toList();

    // ── Smart Catalog Fusion across CoffeeKnowledgeGraph (v3.0: 2,461+ beans, 750+ roasteries, 88+ Sabang-Merauke & World terroirs) ──
    final catalogHit = kg.matchBestCatalogEntry(
      rawFullText: repairedFullText,
      detectedRoastery: rawRoastery,
      titleCandidate: titleCandidate,
      detectedProcess: hasExplicitProc ? processProf.canonicalName : null,
      detectedOrigin: originProf?.canonicalName,
      detectedNotes: filteredNotes,
    );

    // ── Strict Zero-Hallucination Evidence Gate ──
    final int evidenceSignals = (originProf != null ? 1 : 0) +
        (hasExplicitProc ? 1 : 0) +
        (rawRoastery != 'Specialty Roastery' ? 1 : 0) +
        (explicitVar != null ? 1 : 0) +
        (explicitAlt != null ? 1 : 0) +
        (filteredNotes.isNotEmpty ? 1 : 0) +
        (catalogHit != null ? 2 : 0) +
        (structured['origin']?.trim().isNotEmpty == true ? 1 : 0);

    if (evidenceSignals == 0) {
      return ResolvedCoffeeBean(
        beanId: null,
        isCatalogVerified: false,
        confidenceScore: 25.0,
        roasteryName: 'Belum Terdeteksi',
        beanName: 'Kemasan Kopi Belum Terbaca',
        origin: 'Belum Terdeteksi',
        variety: 'Belum Terdeteksi',
        process: 'Belum Terdeteksi',
        roastLevel: 'Belum Terdeteksi',
        altitudeMasl: null,
        tastingNotes: const [],
        recommendedWaterTempC: 91,
        recommendedRecipes: const [],
        notesSource: 'LOW_CONFIDENCE_NO_MATCH',
        isAiInferredAltitude: false,
        isAiInferredVariety: false,
        classifiedBlocks: classified,
      );
    }

    String finalRoastery = rawRoastery;
    String finalOrigin = originProf?.regionProvince ??
        (structured['origin']?.trim().isNotEmpty == true && !isNoise(structured['origin']!)
            ? _titleCase(_stripGarbledAndMarketingWords(structured['origin']!))
            : 'Single Origin, Indonesia');
    if (finalOrigin.isEmpty) finalOrigin = 'Single Origin, Indonesia';

    String finalAltitude = explicitAlt ?? originProf?.defaultAltitude ?? '1400 - 1800 MDPL';
    bool isAiInferredAlt = explicitAlt == null;

    String finalVariety = explicitVar ?? originProf?.defaultVarietals ?? 'Arabica Specialty';
    bool isAiInferredVar = explicitVar == null;

    String finalProcessName = processProf.canonicalName;
    String finalRoastLevel = _detectRoastLevelFromText(repairedFullText) ?? 'Light to Medium';
    int finalRecommendedTemp = processProf.recommendedTempC;
    String? preferredDripper;
    String? baristaOpinion;
    String? beanId;
    bool isCatalogVerified = false;
    double confidenceScore = (62.0 + (evidenceSignals * 6.5)).clamp(62.0, 96.5);

    List<String> finalNotes;
    String finalNotesSource;

    if (catalogHit != null) {
      final entry = catalogHit.entry;
      beanId = entry.slug;
      isCatalogVerified = true;
      confidenceScore = min(99.2, 72.0 + (catalogHit.score * 0.25));

      if (finalRoastery == 'Specialty Roastery' ||
          finalRoastery.length > entry.roasteryName.length + 10 ||
          catalogHit.matchedBrand) {
        finalRoastery = entry.roasteryName;
      }

      if (titleCandidate == null ||
          titleCandidate.isEmpty ||
          isNoise(titleCandidate) ||
          titleCandidate.toLowerCase().contains('wa...') ||
          entry.beanName.toLowerCase().contains(titleCandidate.toLowerCase())) {
        titleCandidate = entry.beanName;
      }

      if (originProf == null &&
          finalOrigin == 'Single Origin, Indonesia' &&
          entry.origin.trim().isNotEmpty) {
        finalOrigin = entry.origin;
      }

      if (!hasExplicitProc && entry.process.trim().isNotEmpty) {
        finalProcessName = entry.process;
        processProf = _profileForCanonicalProcess(finalProcessName);
      }

      if (explicitVar == null && entry.variety.trim().isNotEmpty) {
        finalVariety = entry.variety;
        isAiInferredVar = false;
      }

      if (explicitAlt == null && entry.altitude.trim().isNotEmpty) {
        finalAltitude = entry.altitude;
        isAiInferredAlt = false;
      }

      if (_detectRoastLevelFromText(repairedFullText) == null && entry.roastLevel.trim().isNotEmpty) {
        finalRoastLevel = entry.roastLevel;
      }

      preferredDripper = entry.recommendedDripper;
      baristaOpinion = entry.baristaOpinion;

      if (filteredNotes.length >= 2) {
        finalNotes = filteredNotes;
        finalNotesSource = 'OCR_EXPLICIT';
      } else if (entry.tastingNotes.isNotEmpty) {
        final merged = <String>[...filteredNotes];
        for (final cn in entry.tastingNotes) {
          if (!merged.any((m) => m.toLowerCase() == cn.toLowerCase())) {
            merged.add(cn);
          }
        }
        finalNotes = merged;
        finalNotesSource = filteredNotes.isNotEmpty ? 'OCR_EXPLICIT' : 'CATALOG_VERIFIED';
      } else {
        finalNotes = filteredNotes.isNotEmpty
            ? filteredNotes
            : List<String>.from(processProf.signatureNotes);
        finalNotesSource = filteredNotes.isNotEmpty ? 'OCR_EXPLICIT' : 'AI_SOMMELIER_INFERRED';
      }

      finalRecommendedTemp = hasExplicitProc && entry.recommendedTempC == 91
          ? processProf.recommendedTempC
          : entry.recommendedTempC;
    } else {
      final hasExplicit = filteredNotes.isNotEmpty;
      finalNotesSource = hasExplicit ? 'OCR_EXPLICIT' : 'AI_SOMMELIER_INFERRED';
      finalNotes = hasExplicit ? filteredNotes : List<String>.from(processProf.signatureNotes);
    }

    final beanName = catalogHit != null && catalogHit.matchedProduct
        ? catalogHit.entry.beanName
        : _composeBeanName(
            titleCandidate,
            originProf,
            finalProcessName,
            finalRoastery,
          );

    final tempBeanForName = ResolvedCoffeeBean(
      isCatalogVerified: isCatalogVerified,
      confidenceScore: confidenceScore,
      roasteryName: finalRoastery,
      beanName: beanName,
      origin: finalOrigin,
      variety: finalVariety,
      process: finalProcessName,
      roastLevel: finalRoastLevel,
      tastingNotes: finalNotes,
      recommendedWaterTempC: finalRecommendedTemp,
      recommendedRecipes: const [],
    );

    final recipes = ScannedBeanRecipePlanner.buildRecommendations(
      displayBeanName: tempBeanForName.fullDisplayName,
      origin: finalOrigin,
      variety: finalVariety,
      processRaw: finalProcessName,
      roastRaw: finalRoastLevel,
      altitudeMasl: finalAltitude,
      tastingNotes: finalNotes,
      targetTempOverride: finalRecommendedTemp,
      preferredDripper: preferredDripper,
      baristaOpinion: baristaOpinion,
    );

    return ResolvedCoffeeBean(
      beanId: beanId,
      isCatalogVerified: isCatalogVerified,
      confidenceScore: double.parse(confidenceScore.toStringAsFixed(1)),
      roasteryName: finalRoastery,
      beanName: beanName,
      origin: finalOrigin,
      variety: finalVariety,
      process: finalProcessName,
      roastLevel: finalRoastLevel,
      altitudeMasl: finalAltitude,
      tastingNotes: finalNotes,
      recommendedWaterTempC: finalRecommendedTemp,
      recommendedRecipes: recipes,
      localCroppedImagePath: localImagePath,
      notesSource: finalNotesSource,
      isAiInferredAltitude: isAiInferredAlt,
      isAiInferredVariety: isAiInferredVar,
      classifiedBlocks: classified,
    );
  }

  static String? _detectRoastLevelFromText(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('medium-dark') || lower.contains('medium dark')) return 'Medium-Dark';
    if (lower.contains('dark roast') || lower.contains('espresso roast')) return 'Dark Roast';
    if (lower.contains('medium-light') || lower.contains('light-medium') || lower.contains('light to medium')) {
      return 'Light-Medium';
    }
    if (lower.contains('light roast') || lower.contains('filter roast')) return 'Light Roast';
    if (lower.contains('medium roast') || lower.contains('omni roast')) return 'Medium Roast';
    return null;
  }

  static String _composeBeanName(String? title, TerroirProfile? origin, String process, String roastery) {
    String base = title ?? origin?.canonicalName ?? 'Specialty Coffee';
    if (isNoise(base) ||
        base.toLowerCase().contains('cita rasa') ||
        base.toLowerCase().contains('dari gunung') ||
        base.toLowerCase().contains('dart gunung') ||
        base.toLowerCase().contains('citai terbaik')) {
      base = origin?.canonicalName ?? 'Specialty Coffee';
    }
    final rLow = roastery.toLowerCase();
    if (base.toLowerCase().startsWith(rLow)) {
      base = base.substring(rLow.length).trim();
    }
    for (final noise in _noisePhrases) {
      final pos = base.toLowerCase().indexOf(noise);
      if (pos != -1) {
        base = '${base.substring(0, pos)} ${base.substring(pos + noise.length)}'.trim();
      }
    }
    base = base
        .replaceAll(RegExp(r'^(?:100%\s*)?(?:arabica|arabika|kopi|coffee)\s+', caseSensitive: false), '')
        .trim();
    base = _stripGarbledAndMarketingWords(base);
    if (base.isEmpty) {
      base = origin?.canonicalName ?? 'Specialty Coffee';
    }

    final bLow = base.toLowerCase();
    final hasFlavorSignature = bLow.contains('watermelon smash') ||
        bLow.contains('halu banana') ||
        bLow.contains('banana') ||
        bLow.contains('puntang');
    if (hasFlavorSignature) {
      return base;
    }

    String pShort = process;
    if (process == 'Wine Process') pShort = 'Wine';
    if (process == 'Honey Process') pShort = 'Honey';
    if (process == 'Full Washed') pShort = 'Washed';
    if (process == 'Anaerobic Natural') pShort = 'Anaerobic Natural';

    if (!base.toLowerCase().contains(pShort.toLowerCase())) {
      return '$base $pShort';
    }
    return base;
  }

  static String? _extractRoasteryFromText(String text) {
    final kg = CoffeeKnowledgeGraphService.instance;
    final structured = _extractStructuredFields(text);
    if (structured.containsKey('roastery') && structured['roastery']!.trim().length >= 3) {
      String r = structured['roastery']!.trim();
      if (r.toLowerCase().startsWith('by ')) {
        r = r.substring(3).trim();
      }
      r = r.replaceAll(RegExp(r'[\-_:;]+$'), '').trim();
      final hit = kg.matchKnownRoastery(r);
      if (hit != null) return hit.canonicalName;
      final rLow = r.toLowerCase();
      if (rLow.contains('wanoja') || rLow.contains('vanoja')) {
        return 'Wanoja Coffee';
      }
      return _titleCase(r);
    }

    if (structured.containsKey('farmer') && structured['farmer']!.trim().length >= 3) {
      final f = structured['farmer']!.trim();
      final hit = kg.matchKnownRoastery(f);
      if (hit != null) return hit.canonicalName;
      final fLow = f.toLowerCase();
      if (fLow.contains('wanoja') || fLow.contains('vanoja')) {
        return 'Wanoja Coffee';
      }
      return _titleCase(f);
    }

    final knownOverall = kg.matchKnownRoastery(text);
    if (knownOverall != null) {
      return knownOverall.canonicalName;
    }

    final byMatch = RegExp(
      r'\bBY\s+([A-Za-z0-9\s]{3,35})(?:\s+(?:COFFEE|SUPPLY|ROASTERY|ROASTERS|CO|LAB))?',
      caseSensitive: false,
    ).firstMatch(text);
    if (byMatch != null) {
      final raw = byMatch.group(0)!.trim();
      final cleaned = raw.replaceAll(RegExp(r'^by\s+', caseSensitive: false), '').trim();
      if (cleaned.length >= 3 && findOrigin(cleaned) == null && !isNoise(cleaned)) {
        return _titleCase(cleaned);
      }
    }

    for (final line in text.split(RegExp(r'[\r\n]+')).take(8)) {
      final lower = line.trim().toLowerCase();
      if ((lower.contains('coffee') ||
              lower.contains('bean') ||
              lower.contains('roastery') ||
              lower.contains('roasters') ||
              lower.contains('supply')) &&
          !isNoise(line) &&
          findOrigin(line) == null) {
        final hit = kg.matchKnownRoastery(line);
        if (hit != null) return hit.canonicalName;
        String cleaned = _stripGarbledAndMarketingWords(line);
        if (cleaned.toLowerCase().startsWith('by ')) {
          cleaned = cleaned.substring(3).trim();
        }
        if (cleaned.length >= 3 && !isNoise(cleaned)) {
          return _titleCase(cleaned);
        }
      }
    }
    return null;
  }

  static String? _extractAltitude(String text) {
    final structured = _extractStructuredFields(text);
    if (structured.containsKey('altitude') && structured['altitude']!.trim().isNotEmpty) {
      final raw = structured['altitude']!.trim();
      final match = RegExp(r'(\d{3,4})\s*(?:-\s*(\d{3,4}))?\s*(?:mdpl|masl|m\b)?', caseSensitive: false).firstMatch(raw);
      if (match != null) {
        return match.group(0)?.trim().toUpperCase();
      }
      return raw.toUpperCase();
    }
    final match = RegExp(r'(\d{3,4})\s*(?:-\s*(\d{3,4}))?\s*(?:mdpl|masl|m\b)', caseSensitive: false).firstMatch(text);
    return match?.group(0)?.trim().toUpperCase();
  }

  static String? _extractVarietal(String text) {
    final baseKnown = <String>{
      'mixed variety',
      'mixed variet',
      'mixeci variet',
      'heirloom',
      'geisha',
      'gesha',
      'pink bourbon',
      'bourbon',
      'typica',
      'sl28',
      'sl34',
      'sigararutang',
      'kartika',
      'andungsari',
      'lini s795',
      'caturra',
      'catimor',
      'timtim',
      'abyssinia',
      'ateng super',
      'ateng',
      ...CoffeeKnowledgeGraphService.instance.knownVarieties,
    };

    final structured = _extractStructuredFields(text);
    if (structured.containsKey('variety') && structured['variety']!.trim().isNotEmpty) {
      final rawVar = structured['variety']!.trim();
      final firstPart = rawVar.split(RegExp(r'[,;•]')).first.trim();
      final varLower = CoffeeKnowledgeGraphService.repairOcrText(firstPart).toLowerCase();
      if (varLower.contains('mix') || varLower.contains('mixed') || varLower.contains('mixeci')) {
        return 'Mixed Variety';
      }
      for (final k in baseKnown) {
        if (k.length < 3) continue;
        if (varLower == k || varLower.contains(k) || jaroWinkler(varLower, k) >= 0.84) {
          return k.contains('mix') ? 'Mixed Variety' : _titleCase(k);
        }
      }
      return _titleCase(firstPart);
    }

    const genericSpecies = {
      'arabica',
      'arabika',
      'robusta',
      'excelsa',
      'liberica',
      'arabica specialty',
      'arabika specialty',
      'specialty selection',
      'specialty blend',
      'specialty single origin',
      'arabika single origin',
      'arabica single origin',
      'mix',
      'mixed',
    };

    final lower = CoffeeKnowledgeGraphService.repairOcrText(text).toLowerCase();
    if (lower.contains('mixed variety') || lower.contains('mixeci variet') || lower.contains('mixed variet')) {
      return 'Mixed Variety';
    }
    for (final v in baseKnown) {
      if (v.length < 4 || genericSpecies.contains(v)) continue;
      if (RegExp('\\b${RegExp.escape(v)}\\b').hasMatch(lower)) {
        return v.contains('mix') ? 'Mixed Variety' : _titleCase(v);
      }
    }
    return null;
  }

  static String _titleCase(String s) {
    return s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).map((word) {
      if (RegExp(r'^(mknd|20fr|twentyfr|ibrc|wbrc)$', caseSensitive: false).hasMatch(word)) {
        return word.toUpperCase();
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static const _wineProfile = ProcessSensoryProfile(
    canonicalName: 'Wine Process',
    recommendedTempC: 89,
    topRecipeName: 'Dual-Temperature Thermal Drop V60 (93°C -> 70°C)',
    topRecipeSlug: 'dual-temperature-thermal-drop-v60',
    signatureNotes: ['Winey', 'Red Grape', 'Strawberry', 'Blackcurrant', 'Dark Cocoa'],
  );

  static const _naturalProfile = ProcessSensoryProfile(
    canonicalName: 'Natural',
    recommendedTempC: 90,
    topRecipeName: 'Tetsu Kasuya 4:6 Method (Sweet Focus)',
    topRecipeSlug: 'tetsu-kasuya-46',
    signatureNotes: ['Blueberry', 'Strawberry Jam', 'Tropical Fruit', 'Milk Chocolate'],
  );

  static const _honeyProfile = ProcessSensoryProfile(
    canonicalName: 'Honey Process',
    recommendedTempC: 91,
    topRecipeName: 'Smoking Barrels V60',
    topRecipeSlug: 'smoking-barrels-v60',
    signatureNotes: ['Wild Honey', 'Sweet Peach', 'Brown Sugar', 'Caramel', 'Plum'],
  );

  static const _anaerobicNaturalProfile = ProcessSensoryProfile(
    canonicalName: 'Anaerobic Natural',
    recommendedTempC: 90,
    topRecipeName: 'Dual-Temperature Thermal Drop V60 (92°C -> 75°C)',
    topRecipeSlug: 'dual-temperature-thermal-drop-v60',
    signatureNotes: ['Watermelon', 'Strawberry', 'Winey Berry', 'Tropical Mango', 'Caramel'],
  );

  static const _anaerobicProfile = ProcessSensoryProfile(
    canonicalName: 'Anaerobic Maceration',
    recommendedTempC: 89,
    topRecipeName: 'Dual-Temperature Thermal Drop V60 (93°C -> 70°C)',
    topRecipeSlug: 'dual-temperature-thermal-drop-v60',
    signatureNotes: ['Strawberry Candy', 'Tropical Mango', 'Winey Berry', 'Cinnamon', 'Floral'],
  );

  static const _washedProfile = ProcessSensoryProfile(
    canonicalName: 'Full Washed',
    recommendedTempC: 92,
    topRecipeName: 'WBrC Sandwich Technique',
    topRecipeSlug: 'wbrc-sandwich-v60',
    signatureNotes: ['Jasmine', 'Black Tea', 'Lemon Citrus', 'Bergamot', 'Cane Sugar'],
  );

  static const _wetHulledProfile = ProcessSensoryProfile(
    canonicalName: 'Wet Hulled (Giling Basah)',
    recommendedTempC: 91,
    topRecipeName: 'Tetsu Kasuya 4:6 Method (Rich Body)',
    topRecipeSlug: 'tetsu-kasuya-46',
    signatureNotes: ['Dark Cocoa', 'Caramel', 'Earthy Spice', 'Herbal Tea'],
  );
}
