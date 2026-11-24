import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../core/assets/cloud_dataset_service.dart';
import '../../../core/network/isolate_json_transformer.dart';
import '../../../data/roastery_catalog.dart';
import '../../../data/visual/beans_part_1.dart';
import '../../../data/visual/beans_part_2.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../models/curated_roastery_bean.dart';
import 'cognitive_bean_analyzer.dart';

/// Entri kopi terpadu di dalam Knowledge Graph Smart OCR, mengagregasi
/// `coffee.json`, `initial_classes.json`, `RoasteryCatalog` (127 roastery / 761+ lineup),
/// `featuredScreenshotBeans`, serta daftar regional bean aplikasi.
class CoffeeCatalogEntry {
  final String slug;
  final String roasteryName;
  final String beanName;
  final String origin;
  final String variety;
  final String process;
  final String roastLevel;
  final String altitude;
  final List<String> tastingNotes;
  final int recommendedTempC;
  final String? recommendedDripper;
  final String? baristaOpinion;
  final int priority;
  final List<String> brandTokens;
  final List<String> productTokens;

  const CoffeeCatalogEntry({
    required this.slug,
    required this.roasteryName,
    required this.beanName,
    required this.origin,
    required this.variety,
    required this.process,
    required this.roastLevel,
    required this.altitude,
    required this.tastingNotes,
    required this.recommendedTempC,
    this.recommendedDripper,
    this.baristaOpinion,
    this.priority = 2,
    this.brandTokens = const [],
    this.productTokens = const [],
  });
}

class CatalogMatchResult {
  final CoffeeCatalogEntry entry;
  final double score;
  final bool matchedBrand;
  final bool matchedProduct;

  const CatalogMatchResult({
    required this.entry,
    required this.score,
    required this.matchedBrand,
    required this.matchedProduct,
  });
}

/// Service singleton pengelola Knowledge Graph Kopi Global + App Database Sync.
/// Menggabungkan ontologi JSON (`assets/data/coffee_knowledge_graph.json`,
/// `assets/data/coffee.json`, `assets/data/initial_classes.json`) dengan seluruh
/// Roastery Catalog, Curated Roastery Beans, & regional coffee visual catalog.
class CoffeeKnowledgeGraphService {
  static final CoffeeKnowledgeGraphService _instance =
      CoffeeKnowledgeGraphService._internal();
  factory CoffeeKnowledgeGraphService() => _instance;
  CoffeeKnowledgeGraphService._internal();

  static CoffeeKnowledgeGraphService get instance => _instance;

  bool _isSyncInitialized = false;
  bool _isJsonLoaded = false;

  final List<TerroirProfile> _terroirs = [];
  final Set<String> _knownRoasteries = {};
  final Map<String, String> _roasteryAliasMap = {}; // alias_lower -> Canonical Name
  final Set<String> _knownVarieties = {};
  final Set<String> _knownProcesses = {};
  final Map<String, List<String>> _flavorLexicon = {};
  final Set<String> _noisePhrases = {};
  final List<CoffeeCatalogEntry> _catalogEntries = [];
  final Set<String> _catalogKeys = {};

  bool get isLoaded => _isSyncInitialized && _isJsonLoaded;
  List<TerroirProfile> get terroirs => List.unmodifiable(_terroirs);
  Set<String> get knownRoasteries => Set.unmodifiable(_knownRoasteries);
  Set<String> get knownVarieties => Set.unmodifiable(_knownVarieties);
  Set<String> get knownProcesses => Set.unmodifiable(_knownProcesses);
  Map<String, List<String>> get flavorLexicon => Map.unmodifiable(_flavorLexicon);
  Set<String> get noisePhrases => Set.unmodifiable(_noisePhrases);
  List<CoffeeCatalogEntry> get catalogEntries => List.unmodifiable(_catalogEntries);

  static const Set<String> _genericTokens = {
    'kopi',
    'coffee',
    'arabika',
    'arabica',
    'robusta',
    'excelsa',
    'liberica',
    'beans',
    'bean',
    'biji',
    'specialty',
    'single',
    'origin',
    'roastery',
    'roasters',
    'roaster',
    'roasting',
    'roas',
    'roast',
    'date',
    'better',
    'brew',
    'quality',
    'dari',
    'untuk',
    'cita',
    'rasa',
    'terbaik',
    'filter',
    'espresso',
    'whole',
    'official',
    'store',
    'supply',
    'natural',
    'washed',
    'full',
    'fully',
    'honey',
    'wine',
    'process',
    'proses',
    'anaerobic',
    'indonesia',
    'blend',
    'house',
    'premium',
    'fresh',
    'sample',
    'lot',
    // Non-coffee receipt/packaging/UI stopwords (anti-hallucination guard)
    'struk',
    'belanja',
    'total',
    'subtotal',
    'terima',
    'kasih',
    'harga',
    'bayar',
    'tunai',
    'kembalian',
    'diskon',
    'promo',
    'tanggal',
    'waktu',
    'kasir',
    'invoice',
    'receipt',
    'change',
    'thank',
    'thanks',
  };

  /// Kamus normalisasi kesalahan pembacaan OCR umum pada kemasan kopi.
  static const Map<String, String> ocrTypoCorrections = {
    'watermalon': 'watermelon',
    'waternelon': 'watermelon',
    'watermelo': 'watermelon',
    'watermellon': 'watermelon',
    'laterrnelo': 'watermelon',
    'wtermelon': 'watermelon',
    'smah': 'smash',
    '5mash': 'smash',
    'srnash': 'smash',
    'nutural': 'natural',
    'natura1': 'natural',
    'naturol': 'natural',
    'naturai': 'natural',
    'anaer0bic': 'anaerobic',
    'anaerob1c': 'anaerobic',
    'anacrobic': 'anaerobic',
    'anaer0b': 'anaerob',
    'trawbern': 'strawberry',
    'starberry': 'strawberry',
    'strawbery': 'strawberry',
    'bluberry': 'blueberry',
    'bluebery': 'blueberry',
    'jasmin': 'jasmine',
    'jasmne': 'jasmine',
    'landarjn': 'mandarin',
    'landarir': 'mandarin',
    ')range': 'orange',
    'vanoja': 'wanoja',
    'cotte-': 'coffee',
    'mixeci': 'mixed',
    'variet': 'variety',
    'kam0jang': 'kamojang',
    'amojang': 'kamojang',
    'puntan': 'puntang',
    'haloe': 'halu',
    'dart': 'dari',
    'citai': 'cita rasa',
    'kintarnani': 'kintamani',
    'toraj4': 'toraja',
    'f1ores': 'flores',
    'fug0l': 'fugol',
  };

  static String repairOcrText(String input) {
    if (input.isEmpty) return input;
    var out = input;
    for (final entry in ocrTypoCorrections.entries) {
      out = out.replaceAll(
        RegExp(r'\b' + RegExp.escape(entry.key) + r'\b', caseSensitive: false),
        entry.value,
      );
    }
    // Khusus tanda kutip / kurung OCR yang tidak terbatasi word-boundary seperti ")range" & "Watermelo ,"
    out = out
        .replaceAll(')range', 'orange')
        .replaceAll('laterrnelo', 'watermelon')
        .replaceAll('watermalon', 'watermelon')
        .replaceAll('watermelo', 'watermelon');
    return out;
  }

  /// Sinkronisasi langsung (tanpa `await`) seluruh katalog in-memory + file asset lokal jika tersedia.
  void ensureSyncInitialized() {
    if (_isSyncInitialized) return;
    _isSyncInitialized = true;

    _syncBuiltInVisualDatasets();
    _syncRoasteryCatalogAndFeatured();

    // Fallback sinkron untuk VM unit test & desktop saat aset lokal tersedia di disk
    if (!_isJsonLoaded && !kIsWeb) {
      _tryLoadLocalJsonSync('assets/data/coffee_knowledge_graph.json', _loadKnowledgeGraphJson);
      _tryLoadLocalJsonSync('assets/data/initial_classes.json', _loadInitialClassesJson);
      _tryLoadLocalJsonSync('assets/data/coffee.json', _loadCoffeeCatalogJson);
      _isJsonLoaded = true;
    }
  }

  /// Inisialisasi lengkap asinkron via `rootBundle` + sinkronisasi katalog in-memory.
  Future<void> initialize() async {
    ensureSyncInitialized();
    if (_isJsonLoaded && _catalogEntries.length >= 250) {
      return;
    }

    try {
      final kgStr = await CloudDatasetService.loadDatasetString('coffee_knowledge_graph');
      if (kgStr != null && kgStr.isNotEmpty) {
        final decoded = await IsolateJsonTransformer.parseJsonInBackground(kgStr);
        _loadKnowledgeGraphJson(decoded);
      }
    } catch (e) {
      debugPrint('CoffeeKnowledgeGraphService kg notice: $e');
    }

    try {
      final initStr = await CloudDatasetService.loadDatasetString('initial_classes');
      if (initStr != null && initStr.isNotEmpty) {
        final decoded = await IsolateJsonTransformer.parseJsonInBackground(initStr);
        _loadInitialClassesJson(decoded);
      }
    } catch (e) {
      debugPrint('CoffeeKnowledgeGraphService initial_classes notice: $e');
    }

    try {
      final coffeeStr = await CloudDatasetService.loadDatasetString('coffee');
      if (coffeeStr != null && coffeeStr.isNotEmpty) {
        final decoded = await IsolateJsonTransformer.parseJsonInBackground(coffeeStr);
        _loadCoffeeCatalogJson(decoded);
      }
    } catch (e) {
      debugPrint('CoffeeKnowledgeGraphService coffee.json notice: $e');
    }

    _isJsonLoaded = true;
  }

  void _tryLoadLocalJsonSync(String relPath, void Function(dynamic data) loader) {
    try {
      final raw = CloudDatasetService.loadDatasetSyncForTest(relPath);
      if (raw != null && raw.isNotEmpty) {
        loader(json.decode(raw));
      }
    } catch (_) {}
  }

  void _syncBuiltInVisualDatasets() {
    for (final v in defaultVarieties) {
      for (final part in v.split('/')) {
        final t = part.trim().toLowerCase();
        if (t.length >= 3) _knownVarieties.add(t);
      }
    }
    for (final p in defaultProcesses) {
      _knownProcesses.add(p.toLowerCase().trim());
    }
    for (final b in [...defaultBeansPart1, ...defaultBeansPart2]) {
      for (final n in b.defaultNotes) {
        _addFlavorCluster(n);
      }
      _addCatalogEntry(
        CoffeeCatalogEntry(
          slug: 'visual_${_slugify(b.name)}',
          roasteryName: 'Specialty Roastery',
          beanName: b.name,
          origin: b.region.replaceAll(RegExp(r'[\u{1F1E6}-\u{1F1FF}]', unicode: true), '').trim(),
          variety: b.defaultVariety,
          process: b.process,
          roastLevel: b.roast,
          altitude: '1350 - 1750 MDPL',
          tastingNotes: b.defaultNotes,
          recommendedTempC: b.process.toLowerCase().contains('natural') || b.process.toLowerCase().contains('wine')
              ? 90
              : 92,
          priority: 1,
          brandTokens: const [],
          productTokens: _meaningfulTokens(b.name),
        ),
      );
    }
  }

  void _syncRoasteryCatalogAndFeatured() {
    // 1. Register all 127 Roasteries & aliases
    try {
      for (final roastery in RoasteryCatalog.list) {
        _registerRoasteryName(roastery.name, roasteryId: roastery.id);
      }
    } catch (_) {}

    // 2. Register all CuratedRoasteryBean entries (featured + 761 lineups)
    try {
      final allBeans = CuratedRoasteryBean.getAllCatalogBeans();
      for (final bean in allBeans) {
        _registerRoasteryName(bean.roasteryName);
        for (final v in bean.variety.split(RegExp(r'[,/&]'))) {
          final vt = v.trim().toLowerCase();
          if (vt.length >= 3) _knownVarieties.add(vt);
        }
        for (final n in bean.tastingNotesList) {
          _addFlavorCluster(n);
        }
        final cleanBeanName = _stripProductPrefix(bean.name, bean.roasteryName);
        _addCatalogEntry(
          CoffeeCatalogEntry(
            slug: bean.id,
            roasteryName: bean.roasteryName,
            beanName: cleanBeanName,
            origin: bean.origin,
            variety: bean.variety,
            process: bean.processRaw,
            roastLevel: bean.roastProfileRaw,
            altitude: _extractAltitudeOrDefault(bean.origin),
            tastingNotes: bean.tastingNotesList,
            recommendedTempC: bean.process == BeanProcess.natural || bean.process == BeanProcess.anaerobic
                ? 90
                : (bean.process == BeanProcess.honey ? 91 : 92),
            recommendedDripper: bean.recommendedDripper.label,
            baristaOpinion: bean.baristaOpinion,
            priority: bean.id.endsWith('_feat') ? 3 : 2,
            brandTokens: _brandTokens(bean.roasteryName),
            productTokens: _meaningfulTokens(cleanBeanName),
          ),
        );
      }
    } catch (_) {}
  }

  void _loadKnowledgeGraphJson(dynamic data) {
    if (data is! Map<String, dynamic>) return;

    final originsList = data['origins'] as List? ?? [];
    for (final item in originsList) {
      if (item is Map<String, dynamic>) {
        final canonicalName = item['canonical_name']?.toString() ?? '';
        final regionProvince = item['region_province']?.toString() ?? '';
        final defaultAltitude = item['default_altitude']?.toString() ?? '1400 - 1800 MDPL';
        final defaultVarieties = item['default_varieties']?.toString() ?? 'Arabica Specialty';
        final keywordsRaw = (item['keywords'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
        final aliasesRaw = (item['aliases'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
        final allKws = {...keywordsRaw, ...aliasesRaw}.where((k) => k.length >= 3).toList();
        if (canonicalName.isEmpty) continue;
        final profile = TerroirProfile(
          canonicalName: canonicalName,
          regionProvince: regionProvince,
          defaultAltitude: defaultAltitude,
          defaultVarietals: defaultVarieties,
          keywords: allKws,
        );
        _terroirs.removeWhere((t) => t.canonicalName.toLowerCase() == canonicalName.toLowerCase());
        _terroirs.add(profile);
      }
    }

    for (final r in (data['known_roasteries'] as List? ?? [])) {
      _registerRoasteryName(r.toString());
    }
    for (final v in (data['known_varieties'] as List? ?? [])) {
      final clean = v.toString().toLowerCase().trim();
      if (clean.length >= 2) _knownVarieties.add(clean);
    }
    for (final p in (data['known_processes'] as List? ?? [])) {
      final clean = p.toString().toLowerCase().trim();
      if (clean.length >= 3) _knownProcesses.add(clean);
    }
    final flavors = data['flavor_lexicon'] as Map<String, dynamic>? ?? {};
    for (final entry in flavors.entries) {
      final list = (entry.value as List?)?.map((e) => e.toString().toLowerCase().trim()).toList() ?? [];
      _addFlavorCluster(entry.key, synonyms: list);
    }
    for (final n in (data['noise_patterns'] as List? ?? [])) {
      final clean = n.toString().toLowerCase().trim();
      if (clean.isNotEmpty) _noisePhrases.add(clean);
    }
  }

  void _loadInitialClassesJson(dynamic data) {
    if (data is! List) return;
    for (final item in data) {
      if (item is! Map) continue;
      final roasteryRaw = item['roastery']?.toString() ?? 'Specialty Roastery';
      final canonicalRoastery = _resolveCanonicalRoasteryDisplay(roasteryRaw);
      final coffeeName = _stripProductPrefix(item['coffee_name']?.toString() ?? '', canonicalRoastery);
      final notes = (item['tasting_notes'] as List?)?.map((e) => e.toString()).toList() ?? [];
      for (final n in notes) {
        _addFlavorCluster(n);
      }
      _registerRoasteryName(canonicalRoastery, extraAlias: roasteryRaw);
      _addCatalogEntry(
        CoffeeCatalogEntry(
          slug: item['class_slug']?.toString() ?? _slugify('$canonicalRoastery $coffeeName'),
          roasteryName: canonicalRoastery,
          beanName: coffeeName,
          origin: item['origin']?.toString() ?? 'Single Origin, Indonesia',
          variety: item['variety']?.toString() ?? 'Arabica Specialty',
          process: item['process']?.toString() ?? 'Natural',
          roastLevel: 'Light-Medium',
          altitude: item['altitude']?.toString() ?? '1350 - 1750 MDPL',
          tastingNotes: notes,
          recommendedTempC: (item['recommended_temp'] as num?)?.toInt() ?? 91,
          priority: 4,
          brandTokens: _brandTokens(canonicalRoastery, extraAlias: roasteryRaw),
          productTokens: _meaningfulTokens(coffeeName),
        ),
      );
    }
  }

  void _loadCoffeeCatalogJson(dynamic data) {
    if (data is! List) return;
    for (final item in data) {
      if (item is! Map) continue;
      final brandRaw = (item['brand']?.toString() ?? '').replaceAll('_', ' ').trim();
      final displayNameRaw = (item['display_name']?.toString() ?? '').trim();
      final canonicalRoastery = _resolveCanonicalRoasteryDisplay(
        brandRaw.isNotEmpty ? brandRaw : displayNameRaw,
      );

      final coffeeRaw = (item['coffee_name']?.toString() ?? '').replaceAll('_', ' ').trim();
      String cleanBean = _extractCleanBeanFromDisplay(
        displayNameRaw,
        canonicalRoastery,
        fallbackRaw: coffeeRaw,
      );
      if (cleanBean.isEmpty) continue;

      final rawProc = (item['process']?.toString() ?? 'washed').replaceAll('_', ' ').trim();
      final normProc = _normalizeProcessLabel(rawProc);
      final notes = (item['tasting_notes'] as List?)?.map((e) => e.toString()).toList() ?? [];
      for (final n in notes) {
        _addFlavorCluster(n);
      }
      final variety = (item['variety']?.toString() ?? '').trim();
      if (variety.isNotEmpty) {
        for (final v in variety.split(RegExp(r'[,/&]'))) {
          final vt = v.trim().toLowerCase();
          if (vt.length >= 3) _knownVarieties.add(vt);
        }
      }

      _registerRoasteryName(canonicalRoastery, extraAlias: brandRaw);
      _addCatalogEntry(
        CoffeeCatalogEntry(
          slug: item['class_slug']?.toString() ?? _slugify('$canonicalRoastery $cleanBean'),
          roasteryName: canonicalRoastery,
          beanName: cleanBean,
          origin: (item['origin']?.toString() ?? '').trim().isNotEmpty
              ? item['origin'].toString().trim()
              : 'Single Origin, Indonesia',
          variety: variety.isNotEmpty ? variety : 'Arabica Specialty',
          process: normProc,
          roastLevel: normProc.toLowerCase().contains('natural') || normProc.toLowerCase().contains('anaerobic')
              ? 'Light-Medium'
              : 'Light to Medium',
          altitude: (item['altitude']?.toString() ?? '1350 - 1750 MDPL').trim(),
          tastingNotes: notes,
          recommendedTempC: (item['recommended_temp'] as num?)?.toInt() ?? 91,
          priority: 3,
          brandTokens: _brandTokens(canonicalRoastery, extraAlias: brandRaw),
          productTokens: _meaningfulTokens(cleanBean),
        ),
      );
    }
  }

  void _registerRoasteryName(String rawName, {String? roasteryId, String? extraAlias}) {
    final trimmed = _cleanSpaces(rawName);
    if (trimmed.length < 3) return;
    final lower = trimmed.toLowerCase();
    if (_genericTokens.contains(lower) || lower == 'specialty roastery') return;

    _knownRoasteries.add(lower);
    _roasteryAliasMap[lower] = _preferCanonicalDisplay(_roasteryAliasMap[lower], trimmed);

    if (roasteryId != null && roasteryId.isNotEmpty) {
      final cleanId = roasteryId.replaceAll('_', ' ').trim().toLowerCase();
      if (cleanId.length >= 3 && !_genericTokens.contains(cleanId)) {
        _knownRoasteries.add(cleanId);
        _roasteryAliasMap[cleanId] = _preferCanonicalDisplay(_roasteryAliasMap[cleanId], trimmed);
      }
    }

    if (extraAlias != null && extraAlias.trim().length >= 3) {
      final aLow = extraAlias.replaceAll('_', ' ').trim().toLowerCase();
      if (!_genericTokens.contains(aLow)) {
        _knownRoasteries.add(aLow);
        _roasteryAliasMap[aLow] = _preferCanonicalDisplay(_roasteryAliasMap[aLow], trimmed);
      }
    }

    var stripped = lower;
    for (final suffix in const [
      'official store',
      'coffee roasters',
      'coffee roastery',
      'coffee supply',
      'coffee house',
      'coffee lab',
      'roasters',
      'roastery',
      'roaster',
      'coffee',
      'beans',
      'bean',
      'supply',
    ]) {
      stripped = stripped.replaceAll(RegExp('\\b${RegExp.escape(suffix)}\\b'), ' ').trim();
    }
    stripped = _cleanSpaces(stripped);
    if (stripped.length >= 4 && !_genericTokens.contains(stripped)) {
      _knownRoasteries.add(stripped);
      _roasteryAliasMap[stripped] = _preferCanonicalDisplay(_roasteryAliasMap[stripped], trimmed);
      final compactStripped = stripped.replaceAll(' ', '');
      if (compactStripped.length >= 4 && compactStripped != stripped) {
        _knownRoasteries.add(compactStripped);
        _roasteryAliasMap[compactStripped] =
            _preferCanonicalDisplay(_roasteryAliasMap[compactStripped], trimmed);
      }
    }
    final compactFull = lower.replaceAll(' ', '');
    if (compactFull.length >= 4 && compactFull != lower) {
      _knownRoasteries.add(compactFull);
      _roasteryAliasMap[compactFull] = _preferCanonicalDisplay(_roasteryAliasMap[compactFull], trimmed);
    }
  }

  String _preferCanonicalDisplay(String? existing, String candidate) {
    if (existing == null || existing.isEmpty) return _titleCase(candidate);
    // Prefer richer formal roastery name (e.g. "Fugol Coffee Roasters" > "Fugol")
    return candidate.length > existing.length ? _titleCase(candidate) : existing;
  }

  String _resolveCanonicalRoasteryDisplay(String raw) {
    final clean = _cleanSpaces(raw.replaceAll('_', ' '));
    final lower = clean.toLowerCase();
    if (_roasteryAliasMap.containsKey(lower)) {
      return _roasteryAliasMap[lower]!;
    }
    for (final entry in _roasteryAliasMap.entries) {
      if (lower == entry.key || (entry.key.length >= 5 && lower.startsWith('${entry.key} '))) {
        return entry.value;
      }
    }
    return _titleCase(clean);
  }

  void _addFlavorCluster(String canonical, {List<String> synonyms = const []}) {
    final c = canonical.trim();
    if (c.length < 3 || isNoise(c)) return;
    final list = _flavorLexicon.putIfAbsent(c, () => [c.toLowerCase()]);
    final cLow = c.toLowerCase();
    if (!list.contains(cLow)) list.add(cLow);
    for (final syn in synonyms) {
      final sLow = syn.trim().toLowerCase();
      if (sLow.length >= 3 && !list.contains(sLow)) {
        list.add(sLow);
      }
    }
  }

  void _addCatalogEntry(CoffeeCatalogEntry entry) {
    final key = '${entry.roasteryName.toLowerCase()}|${entry.beanName.toLowerCase()}|${entry.process.toLowerCase()}';
    if (_catalogKeys.contains(key)) {
      // Replace only if higher priority
      final idx = _catalogEntries.indexWhere(
        (e) =>
            e.roasteryName.toLowerCase() == entry.roasteryName.toLowerCase() &&
            e.beanName.toLowerCase() == entry.beanName.toLowerCase() &&
            e.process.toLowerCase() == entry.process.toLowerCase(),
      );
      if (idx != -1 && entry.priority > _catalogEntries[idx].priority) {
        _catalogEntries[idx] = entry;
      }
      return;
    }
    _catalogKeys.add(key);
    _catalogEntries.add(entry);
  }

  /// Mencari roastery dikenal di dalam teks/baris (mengembalikan Canonical Name + span match).
  ({String canonicalName, String matchedAlias})? matchKnownRoastery(String text) {
    ensureSyncInitialized();
    final repaired = repairOcrText(text).toLowerCase();
    String? bestAlias;
    String? bestCanonical;

    // Sort longest keys first conceptually by tracking max alias length
    for (final entry in _roasteryAliasMap.entries) {
      final alias = entry.key;
      if (alias.length < 4 || _genericTokens.contains(alias)) continue;
      final pattern = RegExp(r'(?:^|[^a-z0-9])' + RegExp.escape(alias) + r'(?:$|[^a-z0-9])');
      if (pattern.hasMatch(repaired)) {
        if (bestAlias == null || alias.length > bestAlias.length) {
          bestAlias = alias;
          bestCanonical = entry.value;
        }
      }
    }

    if (bestCanonical != null && bestAlias != null) {
      return (canonicalName: bestCanonical, matchedAlias: bestAlias);
    }

    // Fuzzy token check HANYA terhadap single-word brand alias non-generik >= 5 huruf
    // dengan verifikasi ganda (Jaro-Winkler >= 0.93 + Levenshtein <= 1/2) agar NOL halusinasi.
    final words = repaired
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.length >= 5 && !_genericTokens.contains(w))
        .toList();
    double bestScore = 0.0;
    for (final w in words) {
      for (final entry in _roasteryAliasMap.entries) {
        final alias = entry.key;
        if (alias.contains(' ') || alias.length < 5 || _genericTokens.contains(alias)) continue;
        final maxDist = alias.length >= 9 ? 2 : 1;
        if ((w.length - alias.length).abs() > maxDist) continue;
        final score = jaroWinkler(w, alias);
        if (score >= 0.93 && _levenshtein(w, alias) <= maxDist && score > bestScore) {
          bestScore = score;
          bestCanonical = entry.value;
          bestAlias = w;
        }
      }
    }

    if (bestCanonical != null && bestAlias != null) {
      return (canonicalName: bestCanonical, matchedAlias: bestAlias);
    }
    return null;
  }

  /// Pencocokan multimodal cerdas ke seluruh katalog (~1,000+ kopi & roastery) dengan proteksi konflik merek.
  CatalogMatchResult? matchBestCatalogEntry({
    required String rawFullText,
    String? detectedRoastery,
    String? titleCandidate,
    String? detectedProcess,
    String? detectedOrigin,
    List<String> detectedNotes = const [],
  }) {
    ensureSyncInitialized();
    final repairedFull = repairOcrText(rawFullText).toLowerCase();
    final fullTokens = _tokenizeAlpha(repairedFull);
    final titleTokens = _meaningfulTokens(repairOcrText(titleCandidate ?? ''));
    final explicitRoastMatch = detectedRoastery != null && detectedRoastery != 'Specialty Roastery'
        ? detectedRoastery.toLowerCase()
        : null;
    final roasteryBrandHit = matchKnownRoastery(repairedFull);
    final procLow = (detectedProcess ?? '').toLowerCase();

    CatalogMatchResult? best;

    const originOnlyTokens = {
      'gunung',
      'halu',
      'malabar',
      'puntang',
      'gayo',
      'aceh',
      'bali',
      'kintamani',
      'toraja',
      'sapan',
      'flores',
      'bajawa',
      'kerinci',
      'wamena',
      'papua',
      'ijen',
      'temanggung',
      'garut',
      'kamojang',
      'bandung',
      'west',
      'java',
      'jawa',
      'barat',
      'sulawesi',
      'sumatra',
      'sumatera',
    };

    for (final entry in _catalogEntries) {
      if (entry.productTokens.isEmpty ||
          entry.brandTokens.isEmpty ||
          entry.roasteryName == 'Specialty Roastery') {
        continue;
      }

      // Guard proses eksplisit: jika kemasan jelas menyebut proses berbeda (mis. [x] NATURAL vs Honey),
      // tolak entri yang bertentangan kecuali brand cocok sekaligus phrase cocok persis.
      final entryProcLow = entry.process.toLowerCase();
      final bool hasProcConflict = procLow.isNotEmpty &&
          !entryProcLow.contains(procLow.split(' ').first) &&
          !(procLow.contains('anaerobic') && entryProcLow.contains('natural'));
      if (hasProcConflict) {
        continue;
      }

      // 1. Cek konflik roastery eksplisit (jangan sampai Tiga Ikat Halu Banana ditimpa Fugol!)
      bool brandMatched = false;
      if (roasteryBrandHit != null) {
        final hitLow = roasteryBrandHit.canonicalName.toLowerCase();
        final entryRoastLow = entry.roasteryName.toLowerCase();
        final sharesBrand = entryRoastLow == hitLow ||
            entry.brandTokens.any((bt) => bt.length >= 4 && hitLow.contains(bt));
        if (sharesBrand) {
          brandMatched = true;
        } else {
          // Kemasan menyebut roastery resmi LAIN -> lewati kandidat roastery yang bertentangan
          continue;
        }
      } else if (explicitRoastMatch != null) {
        final hasAnyBrand = entry.brandTokens.any((bt) => bt.length >= 4 && explicitRoastMatch.contains(bt));
        if (hasAnyBrand) {
          brandMatched = true;
        } else if (explicitRoastMatch.split(' ').any((w) => w.length >= 5 && !_genericTokens.contains(w))) {
          // Ada nama roastery eksplisit di kemasan yang berbeda
          continue;
        }
      }

      // Cek apakah ada token brand di teks lengkap (verifikasi ketat: exact atau JW>=0.93 + edit<=1/2)
      if (!brandMatched && entry.brandTokens.isNotEmpty) {
        brandMatched = entry.brandTokens.any(
          (bt) =>
              bt.length >= 4 &&
              !_genericTokens.contains(bt) &&
              fullTokens.any((ft) {
                if (ft == bt) return true;
                if (ft.length < 5 || bt.length < 5) return false;
                final maxDist = bt.length >= 9 ? 2 : 1;
                return (ft.length - bt.length).abs() <= maxDist &&
                    jaroWinkler(ft, bt) >= 0.93 &&
                    _levenshtein(ft, bt) <= maxDist;
              }),
        );
      }

      // 2. Hitung kecocokan token produk unik
      int matchedProdCount = 0;
      double prodTokenScoreSum = 0.0;
      bool hasNonOriginMatchedToken = false;
      final candidatePool = {...fullTokens, ...titleTokens};

      for (final pt in entry.productTokens) {
        double bestTok = 0.0;
        for (final tok in candidatePool) {
          if (tok == pt) {
            bestTok = 1.0;
            break;
          }
          if (tok.length >= 5 && pt.length >= 5) {
            final maxDist = pt.length >= 9 ? 2 : 1;
            if ((tok.length - pt.length).abs() <= maxDist && _levenshtein(tok, pt) <= maxDist) {
              final jw = jaroWinkler(tok, pt);
              if (jw >= 0.89 && jw > bestTok) {
                bestTok = jw;
              }
            }
          }
        }
        if (bestTok > 0) {
          matchedProdCount++;
          prodTokenScoreSum += bestTok;
          if (!originOnlyTokens.contains(pt)) {
            hasNonOriginMatchedToken = true;
          }
        }
      }

      if (matchedProdCount == 0) continue;

      final prodCoverage = matchedProdCount / entry.productTokens.length;
      final exactPhraseHit = repairedFull.contains(entry.beanName.toLowerCase()) &&
          entry.beanName.length >= 6;

      // Jangan mengklaim kecocokan katalog terverifikasi bila brand TIDAK disebut di kemasan
      // dan kata yang cocok hanyalah nama wilayah geografis umum (mis. "Gunung Halu").
      if (!brandMatched && !hasNonOriginMatchedToken) {
        continue;
      }

      // Memerlukan kecocokan produk yang kuat:
      // - Brand cocok + minimal 1 token produk kuat (atau phrase match), ATAU
      // - Minimal 2 token produk unik non-wilayah cocok (>= 85% coverage) tanpa konflik roastery
      final bool qualified = (brandMatched && (matchedProdCount >= 1 && prodCoverage >= 0.5)) ||
          (matchedProdCount >= 2 && prodCoverage >= 0.85 && hasNonOriginMatchedToken) ||
          (exactPhraseHit && (brandMatched || hasNonOriginMatchedToken));

      if (!qualified) continue;

      double score = 0.0;
      if (brandMatched) score += 42.0;
      score += (prodTokenScoreSum / entry.productTokens.length) * 48.0;
      if (exactPhraseHit) score += 16.0;

      // 3. Bonus kecocokan proses (tanpa menghukum bila proses OCR terbaca default washed atau kosong)
      if (procLow.isNotEmpty && entryProcLow.contains(procLow.split(' ').first)) {
        score += 12.0;
      }

      // 4. Bonus kecocokan notes & origin
      int notesHit = 0;
      final entryNotesLow = entry.tastingNotes.map((e) => e.toLowerCase()).toList();
      for (final n in detectedNotes) {
        if (entryNotesLow.any((en) => en.contains(n.toLowerCase()) || n.toLowerCase().contains(en))) {
          notesHit++;
        }
      }
      score += min(notesHit, 3) * 6.0;

      if (detectedOrigin != null &&
          detectedOrigin != 'Single Origin, Indonesia' &&
          entry.origin.toLowerCase().contains(detectedOrigin.toLowerCase().split(',').first)) {
        score += 8.0;
      }

      // Prefer verified JSON / featured priority on ties
      score += entry.priority * 0.8;

      if (best == null || score > best.score) {
        best = CatalogMatchResult(
          entry: entry,
          score: score,
          matchedBrand: brandMatched,
          matchedProduct: exactPhraseHit || prodCoverage >= 0.5,
        );
      }
    }

    if (best != null && best.score >= 58.0) {
      return best;
    }
    return null;
  }

  /// Memeriksa apakah teks adalah slogan, marketing noise, atau metadata bungkus non-spesifik.
  bool isNoise(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length <= 1) return true;
    final lower = trimmed.toLowerCase();

    if ((lower.startsWith('[ ]') || lower.startsWith('( )') || lower.startsWith('[]')) &&
        !lower.contains('x') &&
        !lower.contains('v') &&
        !lower.contains('✓')) {
      return true;
    }

    if (_noisePhrases.contains(lower)) return true;

    if (lower.contains('fresh bean') || lower.contains('better brew')) return true;
    if (lower.contains('dari gunung') || lower.contains('dart gunung')) return true;
    if (lower.contains('cita rasa') || lower.contains('citai terbaik') || lower.contains('cita rasa terbaik')) {
      return true;
    }
    if (lower.contains('roasting date') || lower.contains('roast date') || lower.contains('tgl roasting')) {
      return true;
    }
    if (lower.contains('best before') || lower.contains('exp date') || lower.contains('production date')) return true;
    if (lower.contains('netto') || lower.contains('net weight') || lower.contains('berat bersih')) return true;
    if (lower.contains('p-irt') || lower.contains('pirt') || lower.contains('halal') || lower.contains('bpom')) {
      return true;
    }
    if (lower.contains('diproduksi') || lower.contains('produced by') || lower.contains('roasted by')) return true;
    if (lower.contains('100% arabica') || lower.contains('100% arabika') || lower.contains('premium quality')) {
      return true;
    }
    if (lower.contains('single origin') || lower.contains('specialty coffee') || lower.contains('whole bean')) {
      return true;
    }

    if (RegExp(r'^\d+[\s]*(g|gr|gram|kg|oz|ml)?$', caseSensitive: false).hasMatch(lower)) return true;
    if (RegExp(r'^\d{1,2}[/\-\.]\d{1,2}([/\-\.]\d{2,4})?$').hasMatch(lower)) return true;

    return false;
  }

  /// Memeriksa apakah suatu teks benar-benar merujuk pada Tasting Note kopi.
  bool isTastingNote(String text) {
    ensureSyncInitialized();
    final lower = repairOcrText(text.trim()).toLowerCase();
    if (isNoise(lower)) return false;
    if (lower == 'wine' || lower == 'natural' || lower == 'washed' || lower == 'honey') return false;

    for (final entry in _flavorLexicon.entries) {
      if (lower == entry.key.toLowerCase()) return true;
      for (final syn in entry.value) {
        if (lower == syn || (lower.length >= 4 && syn.length >= 4 && jaroWinkler(lower, syn) >= 0.88)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Menemukan Terroir Origin dari teks, dengan penanganan longest-match-wins & typo tolerance.
  TerroirProfile? findOrigin(String text) {
    ensureSyncInitialized();
    final clean = repairOcrText(text).toLowerCase();

    TerroirProfile? bestProfile;
    int bestLen = 0;
    for (final profile in _terroirs) {
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

    final words = clean
        .split(RegExp(r'[^a-zA-Z0-9]'))
        .where((w) => w.length >= 5 && !_genericTokens.contains(w));
    for (final profile in _terroirs) {
      for (final kw in profile.keywords) {
        if (kw.length < 5 || kw.contains(' ')) continue;
        final maxDist = kw.length >= 9 ? 2 : 1;
        for (final word in words) {
          if ((word.length - kw.length).abs() > maxDist) continue;
          if (jaroWinkler(word, kw) >= 0.93 && _levenshtein(word, kw) <= maxDist) {
            return profile;
          }
        }
      }
    }

    return null;
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);
    for (int i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        curr[j] = min(min(curr[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[b.length];
  }

  bool isKnownRoastery(String text) => matchKnownRoastery(text) != null;

  static double jaroWinkler(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final matchDistance = max(0, (max(s1.length, s2.length) ~/ 2) - 1);
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

  static Set<String> _tokenizeAlpha(String text) {
    return text
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length >= 3 && !_genericTokens.contains(t))
        .toSet();
  }

  static List<String> _meaningfulTokens(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length >= 3 && !_genericTokens.contains(t))
        .toList();
  }

  static List<String> _brandTokens(String roasteryName, {String? extraAlias}) {
    final combined = '${roasteryName.toLowerCase()} ${(extraAlias ?? '').toLowerCase()}';
    return combined
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.length >= 3 && !_genericTokens.contains(t))
        .toSet()
        .toList();
  }

  static String _cleanSpaces(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _slugify(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  static String _extractCleanBeanFromDisplay(
    String displayName,
    String canonicalRoastery, {
    String fallbackRaw = '',
  }) {
    var out = displayName;
    if (out.isEmpty) out = fallbackRaw;
    for (final brandPart in [
      canonicalRoastery,
      canonicalRoastery.split(' ').first,
    ]) {
      if (brandPart.length >= 3) {
        out = out.replaceFirst(RegExp('^${RegExp.escape(brandPart)}\\s*', caseSensitive: false), '').trim();
      }
    }
    out = out
        .replaceAll(RegExp(r'^(?:kopi\s*arabika|kopi\s*arabica|arabika|arabica|kopi|coffee|beans)\s+', caseSensitive: false), '')
        .trim();
    if (out.isEmpty && fallbackRaw.isNotEmpty) {
      out = _titleCase(fallbackRaw);
    }
    return _titleCase(out);
  }

  static String _stripProductPrefix(String rawName, String roastery) {
    var s = rawName.trim();
    if (s.toLowerCase().startsWith(roastery.toLowerCase())) {
      s = s.substring(roastery.length).trim();
    }
    s = s
        .replaceAll(RegExp(r'^(?:kopi\s*arabika|kopi\s*arabica|100%\s*arabica|arabika|arabica|kopi)\s+', caseSensitive: false), '')
        .trim();
    return s.isEmpty ? rawName.trim() : s;
  }

  static String _normalizeProcessLabel(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('anaerobic') && lower.contains('natural')) return 'Anaerobic Natural';
    if (lower.contains('anaerobic')) return 'Anaerobic Maceration';
    if (lower.contains('wine')) return 'Wine Process';
    if (lower.contains('giling basah') || lower.contains('wet hulled')) {
      return 'Wet Hulled (Giling Basah)';
    }
    if (lower.contains('honey')) return 'Honey Process';
    if (lower.contains('natural') && lower.contains('21')) return 'Natural (21 Days Drying)';
    if (lower.contains('natural')) return 'Natural';
    if (lower.contains('washed')) return 'Full Washed';
    return _titleCase(raw);
  }

  static String _extractAltitudeOrDefault(String origin) {
    final m = RegExp(r'(\d{3,4}(?:\s*[-–]\s*\d{3,4})?\s*(?:mdpl|masl))', caseSensitive: false).firstMatch(origin);
    if (m != null) return m.group(1)!.toUpperCase();
    return '1350 - 1750 MDPL';
  }

  static String _titleCase(String s) {
    return _cleanSpaces(s).split(' ').map((word) {
      if (word.isEmpty) return '';
      if (RegExp(r'^(mknd|20fr|twentyfr|ibrc|wbrc)$', caseSensitive: false).hasMatch(word)) {
        return word.toUpperCase();
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
