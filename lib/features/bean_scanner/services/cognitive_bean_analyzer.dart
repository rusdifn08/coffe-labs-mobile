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
    'diproduksi oleh',
    'diproduksi',
    'p-irt',
    'pirt',
    'halal',
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
      keywords: ['gunung halu', 'halu', 'gn halu', 'gununghalu', 'haloe', 'sindangkerta'],
    ),
    TerroirProfile(
      canonicalName: 'Kamojang Garut',
      regionProvince: 'Kamojang, Garut, Jawa Barat',
      defaultAltitude: '1400 - 1750 MDPL',
      defaultVarietals: 'Typica, Sigararutang, Mixed Variety',
      keywords: ['kamojang', 'garut', 'amojang', 'wanoja', 'papandayan', 'cikuray', 'wanoja coffee'],
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
      keywords: ['malabar', 'pangalengan', 'ciwidey'],
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
    'Watermelon': ['watermelon', 'water melon', 'laterrnelo', 'watermelo', 'watermalo', 'watermalen', 'semangka', 'melon'],
    'Banana': ['banana', 'banan', 'banani', 'pisang'],
    'Sweet Caramel': ['sweet caramel', 'caramel', 'karamel', 'toffee', 'dulce de leche'],
    'Mandarin Orange': ['mandarin orange', 'mandarin', 'landarir )range', 'landarjn )range', 'landarjn range', 'landarjn', 'landarir', 'orange', 'tangerine', 'jeruk mandarin'],
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
    'Guava': ['guava', 'jambu'],
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
    'Floral': ['floral', 'flower', 'bunga', 'rose', 'chamomile'],
  };

  static bool isNoise(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length <= 1) return true;
    final lower = trimmed.toLowerCase();

    // Checkbox noise: [ ] washed, [ ] wine (unselected)
    if ((lower.startsWith('[ ]') || lower.startsWith('( )') || lower.startsWith('[]')) &&
        !lower.contains('x') &&
        !lower.contains('v') &&
        !lower.contains('✓')) {
      return true;
    }

    for (final noise in _noisePhrases) {
      if (lower == noise) return true;
    }

    // Slogan & marketing lines (termasuk variasi typo OCR)
    if (lower.contains('fresh bean') || lower.contains('better brew')) return true;
    if (lower.contains('dari gunung') || lower.contains('dart gunung')) return true;
    if (lower.contains('cita rasa') || lower.contains('citai terbaik') || lower.contains('terbaik wine') || lower.contains('cita rasa terbaik')) return true;
    if (lower.contains('roasting date') || lower.contains('roast date') || lower.contains('tgl roasting')) return true;
    if (lower.contains('best before') || lower.contains('exp date') || lower.contains('production date')) return true;
    if (lower.contains('netto') || lower.contains('net weight') || lower.contains('berat bersih')) return true;
    if (lower.contains('p-irt') || lower.contains('pirt') || lower.contains('halal') || lower.contains('bpom')) return true;
    if (lower.contains('diproduksi') || lower.contains('produced by') || lower.contains('roasted by')) return true;
    if (lower.contains('100% arabica') || lower.contains('100% arabika') || lower.contains('premium quality')) return true;
    if (lower.contains('single origin') || lower.contains('specialty coffee') || lower.contains('whole bean') || lower.contains('whole beans')) return true;

    // Angka/tanggal saja (e.g. "26/10", "200g", "250 gr")
    if (RegExp(r'^\d+[\s]*(g|gr|gram|kg|oz|ml)?$', caseSensitive: false).hasMatch(lower)) return true;
    if (RegExp(r'^\d{1,2}[/\-\.]\d{1,2}([/\-\.]\d{2,4})?$').hasMatch(lower)) return true;

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

    // 1. Direct substring matching — keyword terpanjang menang (longest-match-wins).
    //    Ini mencegah "gunung halu" kalah oleh keyword longgar "halu", dan
    //    "gunung puntang" kalah oleh "puntang".
    TerroirProfile? bestProfile;
    int bestLen = 0;
    for (final profile in _terroirProfiles) {
      for (final kw in profile.keywords) {
        if (clean.contains(kw) && kw.length > bestLen) {
          bestLen = kw.length;
          bestProfile = profile;
        }
      }
    }
    if (bestProfile != null) return bestProfile;

    // 2. Fuzzy token matching — tetap utamakan keyword terpanjang.
    final words = clean.split(RegExp(r'[^a-zA-Z0-9]')).where((w) => w.length >= 3);
    TerroirProfile? fuzzyProfile;
    int fuzzyLen = 0;
    double fuzzyScore = 0.0;
    for (final profile in _terroirProfiles) {
      for (final kw in profile.keywords) {
        for (final word in words) {
          final score = jaroWinkler(word, kw);
          if (score >= 0.85) {
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
    final lines = fullText.split(RegExp(r'[\r\n]+'));

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Tasting notes
      final notesMatch = RegExp(r'(?:TASTING\s*NOTES?|TASTINGNOTES?|FLAVOR\s*PROFILE|TASTE\s*NOTES?)\s*[:\-\s]\s*(.+)|(?:NOTES?|FLAVOR|CITA\s*RASA)\s*[:\-]\s*(.+)', caseSensitive: false).firstMatch(trimmed);
      if (notesMatch != null && !fields.containsKey('notes')) {
        String val = (notesMatch.group(1) ?? notesMatch.group(2))?.trim() ?? '';
        val = val.split(RegExp(r'\b(?:FARMER|PRODUCER|ORIGIN|ASAL|PROCESS|PROSES|VARIETY|UARIETY|ALTITUDE)\b', caseSensitive: false)).first.trim();
        if (val.isNotEmpty && !isNoise(val)) fields['notes'] = val;
      }

      // Origin
      final originMatch = RegExp(r'(?:ORIGIN|ASAL|TERROIR|REGION|LOKASI)\s*[:\-\s]\s*(.+)', caseSensitive: false).firstMatch(trimmed);
      if (originMatch != null && !fields.containsKey('origin')) {
        String val = originMatch.group(1)?.trim() ?? '';
        val = val.split(RegExp(r'\b(?:FARMER|PRODUCER|PROCESS|PROSES|VARIETY|UARIETY|ALTITUDE|TASTING)\b', caseSensitive: false)).first.trim();
        if (val.isNotEmpty) fields['origin'] = val;
      }

      // Farmer / Producer / Roastery
      final roasterMatch = RegExp(r'(?:FARMER|PRODUCER|PROCESSOR|PETANI|ROASTERY|ROASTER|ROASTED\s*BY|DIPRODUKSI\s*OLEH)\s*[:\-\s]\s*(.+)', caseSensitive: false).firstMatch(trimmed);
      if (roasterMatch != null && !fields.containsKey('roastery')) {
        String val = roasterMatch.group(1)?.trim() ?? '';
        val = val.split(RegExp(r'\b(?:PROCESS|PROSES|VARIETY|UARIETY|ALTITUDE|TASTING|ORIGIN)\b', caseSensitive: false)).first.trim();
        if (val.isNotEmpty) fields['roastery'] = val;
      }

      // Pattern: "BY <BRAND>" (e.g. "BY TIGA IKAT COFFEE SUPPLY")
      final byMatch = RegExp(r'^\s*BY\s+([A-Za-z0-9\s]{3,40})\b', caseSensitive: false).firstMatch(trimmed);
      if (byMatch != null && !fields.containsKey('roastery')) {
        fields['roastery'] = byMatch.group(1)?.trim() ?? '';
      }

      // Process
      final procMatch = RegExp(r'(?:PROCESS|PROSES|PASCAPANEN|METODE)\s*[:\-\s]\s*(.+)', caseSensitive: false).firstMatch(trimmed);
      if (procMatch != null && !fields.containsKey('process')) {
        String val = procMatch.group(1)?.trim() ?? '';
        val = val.split(RegExp(r'\b(?:VARIETY|UARIETY|ALTITUDE|TASTING|ORIGIN|FARMER)\b', caseSensitive: false)).first.trim();
        if (val.isNotEmpty) fields['process'] = val;
      }

      // Altitude
      final altMatch = RegExp(r'(?:ALTITUDE|ELEVATION|KETINGGIAN)\s*[:\-\s]\s*(.+)', caseSensitive: false).firstMatch(trimmed);
      if (altMatch != null && !fields.containsKey('altitude')) {
        String val = altMatch.group(1)?.trim() ?? '';
        val = val.split(RegExp(r'\b(?:VARIETY|UARIETY|PROCESS|PROSES|TASTING|ORIGIN|FARMER)\b', caseSensitive: false)).first.trim();
        if (val.isNotEmpty) fields['altitude'] = val;
      }

      // Variety
      final varMatch = RegExp(r'(?:VARIETY|VARIETAS|UARIETY|KULTIVAR)\s*[:\-\s]\s*(.+)', caseSensitive: false).firstMatch(trimmed);
      if (varMatch != null && !fields.containsKey('variety')) {
        String val = varMatch.group(1)?.trim() ?? '';
        val = val.split(RegExp(r'\b(?:PROCESS|PROSES|ALTITUDE|TASTING|ORIGIN|FARMER|NOTES)\b', caseSensitive: false)).first.trim();
        val = val.split(RegExp(r'\d{3,4}\s*(?:masl|mdpl|mas|m\b)', caseSensitive: false)).first.trim();
        if (val.isNotEmpty) fields['variety'] = val;
      }
    }
    return fields;
  }

  static String _cleanTitleCandidate(String text) {
    String cleaned = text.trim();
    final lower = cleaned.toLowerCase();
    if (lower.contains('watermelon smash')) {
      return 'Watermelon Smash';
    }
    if (lower.contains('halu banana')) {
      return 'Halu Banana';
    }
    cleaned = cleaned.replaceAll(RegExp(r'^(?:100%\s*arabica|arabica|kopi|coffee)\s+', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+(?:natural|washed|wine|honey|process|proses)$', caseSensitive: false), '');
    return _titleCase(cleaned.trim());
  }

  static ProcessSensoryProfile detectProcess(String text) {
    final structured = _extractStructuredFields(text);
    final target = (structured['process'] != null && structured['process']!.isNotEmpty)
        ? '${structured['process']} $text'
        : text;

    final clean = target.toLowerCase();

    // 1. Checkbox matching: [x] NATURAL, [v] WINE, [x] WASHED.
    //    Hanya aktif jika checkbox memang menandai proses spesifik.
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

    // 2. Deteksi anaerobik natural (paling spesifik lebih dulu).
    final hasAnaerobic = clean.contains('anaerob') || clean.contains('carbonic') || clean.contains('lactic');
    final hasNatural = clean.contains('natural') || clean.contains('natura') || clean.contains('dry process');
    if (hasAnaerobic && hasNatural) return _anaerobicNaturalProfile;
    if (clean.contains('thermal shock')) return _anaerobicProfile;

    // 3. Wine / extended fermentation.
    if (clean.contains('wine') || clean.contains('winery') || clean.contains('extended fermentation')) {
      return _wineProfile;
    }

    // 4. Wet hulled / giling basah (harus dievaluasi SEBELUM 'washed' agar
    //    "semi washed" tidak salah dikenali sebagai Full Washed).
    if (clean.contains('giling basah') || clean.contains('wet hulled') || clean.contains('semi washed')) {
      return _wetHulledProfile;
    }

    // 5. Natural (termasuk varian OCR terpotong "natura", "natur", "nutural").
    if (hasNatural || clean.contains('sun dried')) {
      return _naturalProfile;
    }

    // 6. Honey (dievaluasi sebelum washed agar "honey washed" → Honey).
    if (clean.contains('honey') || clean.contains('madu')) {
      return _honeyProfile;
    }

    // 7. Anaerobic tanpa natural (mis. "Anaerobic Washed").
    if (hasAnaerobic) return _anaerobicProfile;

    // 8. Washed eksplisit.
    if (clean.contains('washed') || clean.contains('wet process') || clean.contains('fully washed')) {
      return _washedProfile;
    }

    // 9. Fallback aman: Full Washed hanya jika benar-benar tidak ada sinyal proses.
    return _washedProfile;
  }

  static List<String> matchTastingNotes(String text) {
    final results = <String>[];
    final structured = _extractStructuredFields(text);

    // 1. Prioritas Utama: Field terstruktur TASTING NOTES
    if (structured.containsKey('notes')) {
      final noteLine = structured['notes']!;
      final parts = noteLine.split(RegExp(r'[,•/\-;]')).map((s) => s.trim()).where((s) => s.length >= 3);
      for (final part in parts) {
        final pLower = part.toLowerCase();
        String matchedKey = '';
        for (final entry in _flavorLexicon.entries) {
          for (final syn in entry.value) {
            final isShort = syn.length <= 3;
            if (isShort) {
              if (pLower == syn) {
                matchedKey = entry.key;
                break;
              }
            } else {
              if (pLower == syn || (pLower.contains(syn) && (pLower.length - syn.length).abs() <= 4) || jaroWinkler(pLower, syn) >= 0.84) {
                matchedKey = entry.key;
                break;
              }
            }
          }
          if (matchedKey.isNotEmpty) break;
        }
        final noteToAdd = matchedKey.isNotEmpty ? matchedKey : _titleCase(part);
        if (!results.contains(noteToAdd)) {
          results.add(noteToAdd);
        }
      }
    }

    // 2. Scan lines di dalam teks
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);

    for (final line in lines) {
      if (isNoise(line)) continue;

      final lower = line.toLowerCase();
      // Skip lines yang hanya berisi proses atau checkbox
      if (lower == 'wine' ||
          lower == 'natural' ||
          lower == 'washed' ||
          lower == 'honey' ||
          lower.contains('[ ]') ||
          lower.contains('( )') ||
          lower.startsWith('proses') ||
          lower.startsWith('process')) {
        continue;
      }

      final tokens = line.split(RegExp(r'[,•/\-;]')).map((s) => s.trim().toLowerCase()).where((s) => s.length >= 3);

      for (final token in tokens) {
        for (final entry in _flavorLexicon.entries) {
          if (results.contains(entry.key)) continue;
          bool matched = false;
          for (final syn in entry.value) {
            // Syarat pencocokan ketat untuk kata pendek (e.g. "tea" tidak boleh sembarang cocok)
            if (token == syn || (token.contains(syn) && syn.length >= 4) || jaroWinkler(token, syn) >= 0.84) {
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
    final structured = _extractStructuredFields(rawFullText);
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

      // 1. Check Process
      final isProc = lower.contains('wine') ||
          lower.contains('natural') ||
          lower.contains('washed') ||
          lower.contains('honey') ||
          lower.contains('anaerobic') ||
          lower.contains('giling basah');

      // 2. Check Origin (Prioritas tinggi agar tidak tertelan roastery / tasting notes)
      final originMatch = findOrigin(text);

      // 3. Check Tasting Notes (Hanya jika benar-benar cocok ke flavor lexicon)
      final notesMatched = matchTastingNotes(text);

      // 4. Check Altitude
      final hasAlt = _extractAltitude(text) != null;

      // 5. Check Variety
      final hasVar = _extractVarietal(text) != null;

      // 6. Check Roastery
      final isRoastery = (lower.contains('roastery') ||
              lower.contains('roasters') ||
              lower.contains('coffee roastery') ||
              lower.contains('coffee supply') ||
              lower.startsWith('by ') ||
              (lower.contains('coffee') && originMatch == null && !isProc) ||
              (lower.contains('bean') && originMatch == null && !isProc)) &&
          originMatch == null &&
          (topY <= 0.45 || lower.startsWith('by '));

      final isExplicitMetadata = lower.startsWith('origin:') ||
          lower.startsWith('asal:') ||
          lower.startsWith('terroir:') ||
          lower.startsWith('farmer:') ||
          lower.startsWith('producer:') ||
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

      // Headline banner check: block dengan lebar/tinggi besar yang mewakili nama kopi
      final isHeadlineBanner = (normW >= 0.35 || normH >= 0.05) &&
          !isNoise(text) &&
          !isExplicitMetadata &&
          !isRoastery &&
          titleCandidate == null &&
          topY <= 0.70 &&
          !RegExp(r'\d+[\s]*(ml|g|gr|gram|kg|oz)', caseSensitive: false).hasMatch(lower);

      if (originMatch != null) {
        role = BlockRole.originOrTitle;
        if (!isExplicitMetadata) {
          String cleaned = _titleCase(text);
          if (cleaned.toLowerCase().startsWith('kopi ')) {
            cleaned = cleaned.substring(5).trim();
          }
          titleCandidate ??= cleaned;
        }
      } else if (isRoastery) {
        String cleaned = text.trim();
        if (cleaned.toLowerCase().startsWith('by ')) {
          cleaned = cleaned.substring(3).trim();
        }
        detectedRoastery ??= _titleCase(cleaned);
        role = BlockRole.roastery;
      } else if (isHeadlineBanner) {
        // Prioritaskan headline banner sebagai nama kopi utama
        titleCandidate ??= _cleanTitleCandidate(text);
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
        // Solusi Bug 2: Default ke ignoredNoise, JANGAN PERNAH tastingNote!
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

    if (titleCandidate == null || titleCandidate.isEmpty) {
      for (final line in rawFullText.split(RegExp(r'[\r\n]+'))) {
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
            !lower.contains('roastery') &&
            !lower.contains('filter roast') &&
            !lower.contains('espresso roast') &&
            !RegExp(r'^\d+[\s]*(g|gr|gram|kg|oz|ml)?$', caseSensitive: false).hasMatch(lower)) {
          titleCandidate = _cleanTitleCandidate(trimmed);
          break;
        }
      }
    }

    final processProf = detectProcess(rawFullText);
    final originProf = findOrigin(rawFullText);

    final roastery = detectedRoastery ??
        _extractRoasteryFromText(rawFullText) ??
        (structured.containsKey('roastery') ? _titleCase(structured['roastery']!) : null) ??
        (structured.containsKey('farmer') ? _titleCase(structured['farmer']!) : null) ??
        'Specialty Roastery';

    final origin = structured['origin']?.trim().isNotEmpty == true
        ? _titleCase(structured['origin']!)
        : (originProf?.regionProvince ?? 'Single Origin, Indonesia');

    final explicitAlt = _extractAltitude(rawFullText);
    final altitude = explicitAlt ?? originProf?.defaultAltitude ?? '1400 - 1800 MDPL';
    final isAiInferredAlt = explicitAlt == null;

    final explicitVar = _extractVarietal(rawFullText);
    final variety = explicitVar ?? originProf?.defaultVarietals ?? 'Arabica Specialty';
    final isAiInferredVar = explicitVar == null;

    final explicitNotes = matchTastingNotes(rawFullText);
    // Jika hanya ada 1 note dan itu sama persis dengan proses (mis. 'Winey' dari 'WINE PROCESS')
    // tanpa ada structured notes line, anggap itu inferensi sommelier
    final filteredNotes = explicitNotes.where((n) {
      if (n == 'Winey' && processProf.canonicalName == 'Wine Process' && explicitNotes.length == 1 && !structured.containsKey('notes')) {
        return false;
      }
      return true;
    }).toList();

    final bool hasExplicit = filteredNotes.isNotEmpty;
    final notesSource = hasExplicit ? 'OCR_EXPLICIT' : 'AI_SOMMELIER_INFERRED';

    final List<String> notes;
    if (hasExplicit) {
      notes = filteredNotes;
    } else {
      notes = List<String>.from(processProf.signatureNotes);
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
    // Buang prefix generik "Arabica"/"Kopi"/"Coffee" yang sering muncul menempel
    // pada nama produk (mis. "Arabica Halu Banana" → "Halu Banana").
    base = base
        .replaceAll(RegExp(r'^(?:100%\s*)?(?:arabica|arabika|kopi|coffee)\s+', caseSensitive: false), '')
        .trim();
    if (base.isEmpty) {
      base = origin?.canonicalName ?? 'Specialty Coffee';
    }

    final bLow = base.toLowerCase();
    // Nama produk yang sudah lengkap (mengandung origin + flavor signature)
    // dipertahankan apa adanya tanpa penambahan suffix proses.
    // Catatan: origin saja (mis. "Malabar") TIDAK cukup — harus ada elemen
    // nama produk (flavor/varietal) agar tidak menghilangkan label proses.
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
    final structured = _extractStructuredFields(text);
    if (structured.containsKey('roastery') && structured['roastery']!.trim().length >= 3) {
      String r = structured['roastery']!.trim();
      if (r.toLowerCase().startsWith('by ')) {
        r = r.substring(3).trim();
      }
      r = r.replaceAll(RegExp(r'[\-_:;]+$'), '').trim();
      final rLow = r.toLowerCase();
      if (rLow.contains('wanoja') || rLow.contains('vanoja')) {
        return 'Wanoja Coffee';
      }
      return _titleCase(r);
    }

    if (structured.containsKey('farmer') && structured['farmer']!.trim().length >= 3) {
      final f = structured['farmer']!.trim();
      final fLow = f.toLowerCase();
      if (fLow.contains('wanoja') || fLow.contains('vanoja')) {
        return 'Wanoja Coffee';
      }
      return _titleCase(f);
    }

    final byMatch = RegExp(r'\bBY\s+([A-Za-z0-9\s]{3,35})(?:\s+(?:COFFEE|SUPPLY|ROASTERY|ROASTERS|CO|LAB))?', caseSensitive: false).firstMatch(text);
    if (byMatch != null) {
      final raw = byMatch.group(0)!.trim();
      final cleaned = raw.replaceAll(RegExp(r'^by\s+', caseSensitive: false), '').trim();
      if (cleaned.length >= 3 && findOrigin(cleaned) == null && !isNoise(cleaned)) {
        return _titleCase(cleaned);
      }
    }

    for (final line in text.split(RegExp(r'[\r\n]+')).take(8)) {
      final lower = line.trim().toLowerCase();
      if ((lower.contains('coffee') || lower.contains('bean') || lower.contains('roastery') || lower.contains('roasters') || lower.contains('supply')) &&
          !isNoise(line) &&
          findOrigin(line) == null) {
        String cleaned = line.trim();
        if (cleaned.toLowerCase().startsWith('by ')) {
          cleaned = cleaned.substring(3).trim();
        }
        return _titleCase(cleaned);
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
    const known = [
      'mixed variety', 'heirloom', 'geisha', 'gesha', 'pink bourbon', 'bourbon',
      'typica', 'sl28', 'sl34', 'sigararutang', 'kartika', 'andungsari', 'lini s795',
      'caturra', 'catimor', 'timtim', 'abyssinia', 'ateng super', 'ateng'
    ];

    final structured = _extractStructuredFields(text);
    if (structured.containsKey('variety') && structured['variety']!.trim().isNotEmpty) {
      final rawVar = structured['variety']!.trim();
      final firstPart = rawVar.split(RegExp(r'[,;•]')).first.trim();
      final varLower = firstPart.toLowerCase();
      for (final k in known) {
        if (varLower == k || varLower.contains(k) || jaroWinkler(varLower, k) >= 0.80) {
          return _titleCase(k);
        }
      }
      return _titleCase(firstPart);
    }

    final lower = text.toLowerCase();
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
