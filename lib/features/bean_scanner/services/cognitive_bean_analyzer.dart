import 'dart:math';
import '../models/resolved_coffee_bean.dart';

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
    'roasting date',
    'roast date',
    'best before',
    'production date',
    'exp date',
    'net weight',
    'netto',
    'berat bersih',
    '100% arabica',
    'pure arabica',
    'specialty coffee',
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
    'diproduksi oleh',
    'p-irt',
    'pirt',
    'halal',
    'dari gunung',
    'untuk cita rasa terbaik',
    'premium quality',
    'fresh roasted',
    'master your brew',
    'indonesia',
    'coffee bean',
    'coffee beans',
  ];

  static const List<TerroirProfile> _terroirProfiles = [
    TerroirProfile(
      canonicalName: 'Malabar',
      regionProvince: 'Gunung Malabar / Halu, Jawa Barat',
      defaultAltitude: '1400 - 1800 MDPL',
      defaultVarietals: 'Sigararutang, Lini S795, Kartika',
      keywords: ['malabar', 'pangalengan', 'puntang', 'ciwidey', 'preanger', 'gunung halu', 'halu'],
    ),
    TerroirProfile(
      canonicalName: 'Aceh Gayo',
      regionProvince: 'Dataran Tinggi Gayo, Aceh',
      defaultAltitude: '1400 - 1750 MDPL',
      defaultVarietals: 'Abyssinia, Timtim, Bourbon, Ateng Super',
      keywords: ['gayo', 'aceh', 'takengon', 'bener meriah', 'pantan musara', 'kenawat'],
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
      keywords: ['flores', 'bajawa', 'manggarai', 'jurang'],
    ),
    TerroirProfile(
      canonicalName: 'Kerinci',
      regionProvince: 'Gunung Kerinci, Sumatera',
      defaultAltitude: '1400 - 1700 MDPL',
      defaultVarietals: 'Andungsari, Sigararutang',
      keywords: ['kerinci', 'solok', 'koerintji', 'jambi', 'kayu aro'],
    ),
    TerroirProfile(
      canonicalName: 'Temanggung',
      regionProvince: 'Temanggung, Jawa Tengah',
      defaultAltitude: '1300 - 1600 MDPL',
      defaultVarietals: 'Kartika, Lini S795',
      keywords: ['temanggung', 'sindoro', 'sumbing', 'wonosobo'],
    ),
    TerroirProfile(
      canonicalName: 'Java Ijen',
      regionProvince: 'Kawah Ijen, Jawa Timur',
      defaultAltitude: '1300 - 1600 MDPL',
      defaultVarietals: 'USDA 762, Kartika, Blue Mountain',
      keywords: ['ijen', 'raung', 'argopuro', 'wonosalam'],
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
      keywords: ['ethiopia', 'yirgacheffe', 'guji', 'sidamo', 'chelbesa'],
    ),
    TerroirProfile(
      canonicalName: 'Colombia',
      regionProvince: 'Huila / Cauca / Tolima, Colombia',
      defaultAltitude: '1600 - 2000 MDPL',
      defaultVarietals: 'Pink Bourbon, Caturra, Castillo',
      keywords: ['colombia', 'huila', 'cauca', 'tolima'],
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
    'Blueberry': ['blueberry', 'bluberry', 'bluebery', 'beri', 'berries'],
    'Strawberry': ['strawberry', 'starberry', 'strawbery', 'stroberi'],
    'Jasmine': ['jasmine', 'jasmin', 'jasmne', 'melati'],
    'Black Tea': ['tea', 'blacktea', 'earlgrey', 'teh', 'black tea', 'floral tea'],
    'Winey': ['wine', 'winey', 'winery', 'red wine', 'fermented'],
    'Red Grape': ['grape', 'red grape', 'anggur'],
    'Blackcurrant': ['blackcurrant', 'currant', 'kismis'],
    'Peach': ['peach', 'apricot', 'persik', 'stone fruit'],
    'Mango': ['mango', 'mangga', 'tropical mango'],
    'Pineapple': ['pineapple', 'nanas', 'passion fruit', 'markisa'],
    'Lemon Citrus': ['lemon', 'lime', 'citrus', 'jeruk', 'bergamot', 'orange'],
    'Milk Chocolate': ['milk chocolate', 'chocolate', 'choco', 'cokelat'],
    'Dark Cocoa': ['dark cocoa', 'cacao', 'dark chocolate', 'cocoa nibs'],
    'Caramel': ['caramel', 'karamel', 'toffee'],
    'Brown Sugar': ['brown sugar', 'gula aren', 'palm sugar', 'cane sugar'],
    'Wild Honey': ['honey', 'madu', 'wild honey'],
    'Chestnut': ['chestnut', 'almond', 'hazelnut', 'kacang'],
    'Red Fruit': ['red fruit', 'buah merah', 'plum', 'cherry'],
    'Cinnamon': ['cinnamon', 'kayu manis', 'spice'],
    'Vanilla': ['vanilla', 'vanila'],
    'Floral': ['floral', 'flower', 'bunga', 'rose', 'chamomile'],
  };

  static bool isNoise(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length <= 1) return true;
    final lower = trimmed.toLowerCase();

    for (final noise in _noisePhrases) {
      if (lower == noise) return true;
    }
    if (lower.contains('fresh bean') && lower.contains('better brew')) return true;
    if (lower.contains('roasting date') || lower.contains('roast date')) return true;
    if (lower.contains('dari gunung') || lower.contains('cita rasa')) return true;
    if (lower.contains('diproduksi oleh') || lower.contains('p-irt')) return true;

    // Checkbox noise: [ ] washed, [ ] wine (unselected)
    if ((lower.startsWith('[ ]') || lower.startsWith('( )') || lower.startsWith('[]')) &&
        !lower.contains('x') &&
        !lower.contains('v') &&
        !lower.contains('✓')) {
      return true;
    }

    return false;
  }

  static double jaroWinkler(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final matchDistance = (max(s1.length, s2.length) ~/ 2) - 1;
    final s1Matches = List<bool>.filled(s1.length, false);
    final s2Matches = List<bool>.filled(s2.length, false);

    int matches = 0;
    for (int i = 0; i < s1.length; i++) {
      final start = max(0, i - matchDistance);
      final end = min(i + matchDistance + 1, s2.length);

      for (int j = start; j < end; j++) {
        if (!s2Matches[j] && s1[i] == s2[j]) {
          s1Matches[i] = true;
          s2Matches[j] = true;
          matches++;
          break;
        }
      }
    }

    if (matches == 0) return 0.0;

    double transpositions = 0.0;
    int k = 0;
    for (int i = 0; i < s1.length; i++) {
      if (!s1Matches[i]) continue;
      while (!s2Matches[k]) {
        k++;
      }
      if (s1[i] != s2[k]) transpositions += 0.5;
      k++;
    }

    final m = matches.toDouble();
    final jaro = (m / s1.length + m / s2.length + (m - transpositions) / m) / 3.0;

    int prefixLength = 0;
    for (int i = 0; i < min(4, min(s1.length, s2.length)); i++) {
      if (s1[i] == s2[i]) {
        prefixLength++;
      } else {
        break;
      }
    }

    return jaro + prefixLength * 0.1 * (1.0 - jaro);
  }

  static TerroirProfile? findOrigin(String text) {
    final clean = text.toLowerCase();
    for (final profile in _terroirProfiles) {
      for (final kw in profile.keywords) {
        if (clean.contains(kw)) return profile;
      }
    }
    final words = clean.split(RegExp(r'[^a-zA-Z0-9]')).where((w) => w.length >= 3);
    for (final profile in _terroirProfiles) {
      for (final kw in profile.keywords) {
        for (final word in words) {
          if (jaroWinkler(word, kw) >= 0.85) return profile;
        }
      }
    }
    return null;
  }

  static ProcessSensoryProfile detectProcess(String text) {
    final clean = text.toLowerCase();

    // Checkbox matching: [x] NATURAL, [v] WINE, [x] WASHED
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

    if (clean.contains('wine') || clean.contains('winery') || clean.contains('extended fermentation')) {
      return _wineProfile;
    }
    if (clean.contains('anaerobic') || clean.contains('carbonic') || clean.contains('lactic') || clean.contains('thermal shock')) {
      return _anaerobicProfile;
    }
    if (clean.contains('honey')) {
      return _honeyProfile;
    }
    if (clean.contains('natural') || clean.contains('dry process')) {
      return _naturalProfile;
    }
    if (clean.contains('washed') || clean.contains('wet process')) {
      return _washedProfile;
    }
    if (clean.contains('giling basah') || clean.contains('wet hulled') || clean.contains('semi washed')) {
      return _wetHulledProfile;
    }

    return _washedProfile;
  }

  static List<String> matchTastingNotes(String text) {
    final results = <String>[];
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);

    for (final line in lines) {
      if (isNoise(line)) continue;

      final lower = line.toLowerCase();
      if (lower == 'wine' ||
          lower == 'natural' ||
          lower == 'washed' ||
          lower == 'honey' ||
          lower.startsWith('[x]') ||
          lower.startsWith('proses') ||
          lower.startsWith('process')) {
        continue;
      }

      final tokens = line.split(RegExp(r'[,•/\-;]')).map((s) => s.trim().toLowerCase()).where((s) => s.length >= 3);

      for (final token in tokens) {
        for (final entry in _flavorLexicon.entries) {
          bool matched = false;
          for (final syn in entry.value) {
            if (token == syn || token.contains(syn) || jaroWinkler(token, syn) >= 0.83) {
              matched = true;
              break;
            }
          }
          if (matched && !results.contains(entry.key)) {
            results.add(entry.key);
          }
        }
      }
    }
    return results;
  }

  static ResolvedCoffeeBean analyze({
    required String rawFullText,
    required List<Map<String, dynamic>> blocksDto,
    String? localImagePath,
  }) {
    final classified = <ClassifiedOcrBlock>[];
    String? detectedRoastery;
    String? titleCandidate;

    for (final b in blocksDto) {
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

      final lower = text.toLowerCase();
      BlockRole role;
      if ((lower.contains('coffee') || lower.contains('bean') || lower.contains('roastery') || lower.contains('kopi')) &&
          topY <= 0.45) {
        detectedRoastery ??= _titleCase(text);
        role = BlockRole.roastery;
      } else if (lower.contains('wine') ||
          lower.contains('natural') ||
          lower.contains('washed') ||
          lower.contains('honey') ||
          lower.contains('anaerobic')) {
        role = BlockRole.process;
      } else if (findOrigin(text) != null || normH >= 0.10) {
        titleCandidate ??= _titleCase(text);
        role = BlockRole.originOrTitle;
      } else {
        role = BlockRole.tastingNote;
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

    final processProf = detectProcess(rawFullText);
    final originProf = findOrigin(rawFullText);

    final roastery = detectedRoastery ?? _extractRoasteryFromText(rawFullText) ?? 'Specialty Roastery';
    final origin = originProf?.regionProvince ?? 'Single Origin, Indonesia';

    final explicitAlt = _extractAltitude(rawFullText);
    final altitude = explicitAlt ?? originProf?.defaultAltitude ?? '1400 - 1800 MDPL';
    final isAiInferredAlt = explicitAlt == null;

    final explicitVar = _extractVarietal(rawFullText);
    final variety = explicitVar ?? originProf?.defaultVarietals ?? 'Arabica Specialty';
    final isAiInferredVar = explicitVar == null;

    final explicitNotes = matchTastingNotes(rawFullText);
    final bool hasExplicit = explicitNotes.length >= 2;
    final notesSource = hasExplicit ? 'OCR_EXPLICIT' : 'AI_SOMMELIER_INFERRED';

    final List<String> notes;
    if (hasExplicit) {
      notes = explicitNotes;
    } else {
      final inferred = List<String>.from(processProf.signatureNotes);
      if (explicitNotes.isNotEmpty && !inferred.contains(explicitNotes.first)) {
        inferred.insert(0, explicitNotes.first);
      }
      notes = inferred;
    }

    final beanName = _composeBeanName(
      titleCandidate,
      originProf,
      processProf.canonicalName,
      roastery,
    );

    final recipes = <RecommendedRecipeSummary>[
      RecommendedRecipeSummary(
        slug: processProf.topRecipeSlug,
        name: processProf.topRecipeName,
        targetNotes: 'Suhu ${processProf.recommendedTempC}°C untuk menonjolkan sweetness ${processProf.canonicalName}',
        suggestedTempC: processProf.recommendedTempC,
        ratio: '1:15 (15g : 225g)',
      ),
    ];

    return ResolvedCoffeeBean(
      beanId: null,
      isCatalogVerified: false,
      confidenceScore: 94.5,
      roasteryName: roastery,
      beanName: beanName,
      origin: origin,
      variety: variety,
      process: processProf.canonicalName,
      roastLevel: 'Light to Medium',
      altitudeMasl: altitude,
      tastingNotes: notes,
      recommendedWaterTempC: processProf.recommendedTempC,
      recommendedRecipes: recipes,
      localCroppedImagePath: localImagePath,
      notesSource: notesSource,
      isAiInferredAltitude: isAiInferredAlt,
      isAiInferredVariety: isAiInferredVar,
      classifiedBlocks: classified,
    );
  }

  static String _composeBeanName(String? title, TerroirProfile? origin, String process, String roastery) {
    String base = title ?? origin?.canonicalName ?? 'Specialty Coffee';
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
    if (base.isEmpty) {
      base = origin?.canonicalName ?? 'Specialty Coffee';
    }

    String pShort = process;
    if (process == 'Wine Process') pShort = 'Wine';
    if (process == 'Honey Process') pShort = 'Honey';
    if (process == 'Full Washed') pShort = 'Washed';

    if (!base.toLowerCase().contains(pShort.toLowerCase())) {
      return '$base $pShort';
    }
    return base;
  }

  static String? _extractRoasteryFromText(String text) {
    for (final line in text.split('\n').take(4)) {
      final lower = line.trim().toLowerCase();
      if ((lower.contains('coffee') || lower.contains('bean') || lower.contains('roastery') || lower.contains('roasters')) &&
          !isNoise(line)) {
        return _titleCase(line.trim());
      }
    }
    return null;
  }

  static String? _extractAltitude(String text) {
    final match = RegExp(r'(\d{3,4})\s*(?:-\s*(\d{3,4}))?\s*(?:mdpl|masl|m\b)', caseSensitive: false).firstMatch(text);
    return match?.group(0)?.trim().toUpperCase();
  }

  static String? _extractVarietal(String text) {
    final lower = text.toLowerCase();
    const known = ['geisha', 'gesha', 'pink bourbon', 'bourbon', 'typica', 'sl28', 'sl34', 'sigararutang', 'kartika', 'andungsari', 'lini s795', 'caturra', 'catimor'];
    for (final v in known) {
      if (lower.contains(v)) return _titleCase(v);
    }
    return null;
  }

  static String _titleCase(String s) {
    return s.split(' ').map((word) {
      if (word.isEmpty) return '';
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
