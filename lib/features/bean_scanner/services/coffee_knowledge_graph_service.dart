import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../data/roastery_catalog.dart';
import '../../../models/curated_roastery_bean.dart';
import 'cognitive_bean_analyzer.dart';

/// Service singleton pengelola Knowledge Graph Kopi Global + App Database Sync.
/// Menggabungkan ontologi JSON (assets/data/coffee_knowledge_graph.json) dengan
/// 50 Roastery Katalog, Curated Roastery Beans, dan Seed Recipes aplikasi.
class CoffeeKnowledgeGraphService {
  static final CoffeeKnowledgeGraphService _instance = CoffeeKnowledgeGraphService._internal();
  factory CoffeeKnowledgeGraphService() => _instance;
  CoffeeKnowledgeGraphService._internal();

  static CoffeeKnowledgeGraphService get instance => _instance;

  bool _isLoaded = false;
  final List<TerroirProfile> _terroirs = [];
  final Set<String> _knownRoasteries = {};
  final Set<String> _knownVarieties = {};
  final Set<String> _knownProcesses = {};
  final Map<String, List<String>> _flavorLexicon = {};
  final Set<String> _noisePhrases = {};

  bool get isLoaded => _isLoaded;
  List<TerroirProfile> get terroirs => List.unmodifiable(_terroirs);
  Set<String> get knownRoasteries => Set.unmodifiable(_knownRoasteries);
  Map<String, List<String>> get flavorLexicon => Map.unmodifiable(_flavorLexicon);

  /// Inisialisasi awal & sinkronisasi otomatis dari JSON dan database in-memory aplikasi.
  Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString('assets/data/coffee_knowledge_graph.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      _loadFromJson(data);
    } catch (e) {
      debugPrint('CoffeeKnowledgeGraphService: using built-in defaults ($e)');
    }

    _syncWithAppDatabase();
    _isLoaded = true;
  }

  void _loadFromJson(Map<String, dynamic> data) {
    // 1. Origins & Terroirs
    final originsList = data['origins'] as List? ?? [];
    for (final item in originsList) {
      if (item is Map<String, dynamic>) {
        final canonicalName = item['canonical_name']?.toString() ?? '';
        final regionProvince = item['region_province']?.toString() ?? '';
        final defaultAltitude = item['default_altitude']?.toString() ?? '1400 - 1800 MDPL';
        final defaultVarieties = item['default_varieties']?.toString() ?? 'Arabica Specialty';
        final keywordsRaw = (item['keywords'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
        final aliasesRaw = (item['aliases'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];

        final allKws = {...keywordsRaw, ...aliasesRaw}.toList();
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

    // 2. Roasteries
    final roasteries = data['known_roasteries'] as List? ?? [];
    for (final r in roasteries) {
      _knownRoasteries.add(r.toString().toLowerCase().trim());
    }

    // 3. Varieties
    final varieties = data['known_varieties'] as List? ?? [];
    for (final v in varieties) {
      _knownVarieties.add(v.toString().toLowerCase().trim());
    }

    // 4. Processes
    final processes = data['known_processes'] as List? ?? [];
    for (final p in processes) {
      _knownProcesses.add(p.toString().toLowerCase().trim());
    }

    // 5. Flavor Lexicon
    final flavors = data['flavor_lexicon'] as Map<String, dynamic>? ?? {};
    for (final entry in flavors.entries) {
      final list = (entry.value as List?)?.map((e) => e.toString().toLowerCase().trim()).toList() ?? [];
      _flavorLexicon[entry.key] = list;
    }

    // 6. Noise Patterns
    final noise = data['noise_patterns'] as List? ?? [];
    for (final n in noise) {
      _noisePhrases.add(n.toString().toLowerCase().trim());
    }
  }

  /// Dynamic Sync dengan database in-memory katalog aplikasi (Roasteries & Curated Beans)
  void _syncWithAppDatabase() {
    // Sync 50 Roastery resmi dari RoasteryCatalog
    try {
      for (final roastery in RoasteryCatalog.list) {
        final name = roastery.name.toLowerCase().trim();
        _knownRoasteries.add(name);
        // Tambahkan varian tanpa kata coffe/roastery
        final stripped = name.replaceAll('coffee', '').replaceAll('roastery', '').replaceAll('roasters', '').trim();
        if (stripped.length >= 3) {
          _knownRoasteries.add(stripped);
        }
      }
    } catch (_) {}

    // Sync Curated Roastery Beans
    try {
      final catalogBeans = CuratedRoasteryBean.getAllCatalogBeans();
      for (final bean in catalogBeans) {
        if (bean.roasteryName.isNotEmpty) {
          _knownRoasteries.add(bean.roasteryName.toLowerCase().trim());
        }
        if (bean.variety.isNotEmpty) {
          for (final v in bean.variety.split(RegExp(r'[,/&]'))) {
            final vt = v.trim().toLowerCase();
            if (vt.length >= 3) _knownVarieties.add(vt);
          }
        }
        for (final note in bean.tastingNotesList) {
          final nt = note.trim();
          if (nt.length >= 3) {
            _flavorLexicon.putIfAbsent(nt, () => [nt.toLowerCase()]);
            if (!_flavorLexicon[nt]!.contains(nt.toLowerCase())) {
              _flavorLexicon[nt]!.add(nt.toLowerCase());
            }
          }
        }
      }
    } catch (_) {}
  }

  // --- Core Domain Inference & Heuristics ---

  /// Memeriksa apakah teks adalah slogan, marketing noise, atau metadata bungkus non-spesifik.
  bool isNoise(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length <= 1) return true;
    final lower = trimmed.toLowerCase();

    // Checkbox kosong (belum dipilih)
    if ((lower.startsWith('[ ]') || lower.startsWith('( )') || lower.startsWith('[]')) &&
        !lower.contains('x') &&
        !lower.contains('v') &&
        !lower.contains('✓')) {
      return true;
    }

    // Cek kecocokan langsung ke bank noise
    if (_noisePhrases.contains(lower)) return true;

    // Slogan spesifik & marketing lines (termasuk variasi typo OCR)
    if (lower.contains('fresh bean') || lower.contains('better brew')) return true;
    if (lower.contains('dari gunung') || lower.contains('dart gunung')) return true;
    if (lower.contains('cita rasa') || lower.contains('citai terbaik') || lower.contains('cita rasa terbaik')) return true;
    if (lower.contains('roasting date') || lower.contains('roast date') || lower.contains('tgl roasting')) return true;
    if (lower.contains('best before') || lower.contains('exp date') || lower.contains('production date')) return true;
    if (lower.contains('netto') || lower.contains('net weight') || lower.contains('berat bersih')) return true;
    if (lower.contains('p-irt') || lower.contains('pirt') || lower.contains('halal') || lower.contains('bpom')) return true;
    if (lower.contains('diproduksi') || lower.contains('produced by') || lower.contains('roasted by')) return true;
    if (lower.contains('100% arabica') || lower.contains('100% arabika') || lower.contains('premium quality')) return true;
    if (lower.contains('single origin') || lower.contains('specialty coffee') || lower.contains('whole bean')) return true;

    // Angka/tanggal saja (e.g. "26/10", "200g", "250 gr")
    if (RegExp(r'^\d+[\s]*(g|gr|gram|kg|oz|ml)?$', caseSensitive: false).hasMatch(lower)) return true;
    if (RegExp(r'^\d{1,2}[/\-\.]\d{1,2}([/\-\.]\d{2,4})?$').hasMatch(lower)) return true;

    return false;
  }

  /// Memeriksa apakah suatu teks benar-benar merujuk pada Tasting Note kopi.
  /// Mencegah kata sembarang (slogan, botol, roastery, origin) menjadi tag "Tasting Note".
  bool isTastingNote(String text) {
    final lower = text.trim().toLowerCase();
    if (isNoise(lower)) return false;
    if (lower == 'wine' || lower == 'natural' || lower == 'washed' || lower == 'honey') return false;

    for (final entry in _flavorLexicon.entries) {
      if (lower == entry.key.toLowerCase()) return true;
      for (final syn in entry.value) {
        if (lower == syn || (lower.length >= 4 && syn.length >= 4 && _jaroWinkler(lower, syn) >= 0.88)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Menemukan Terroir Origin dari teks, dengan penanganan prioritas kata kunci & typo.
  TerroirProfile? findOrigin(String text) {
    final clean = text.toLowerCase();

    // 1. Prioritas string match
    for (final profile in _terroirs) {
      for (final kw in profile.keywords) {
        if (clean.contains(kw)) return profile;
      }
    }

    // 2. Fuzzy token match
    final words = clean.split(RegExp(r'[^a-zA-Z0-9]')).where((w) => w.length >= 4);
    for (final profile in _terroirs) {
      for (final kw in profile.keywords) {
        for (final word in words) {
          if (_jaroWinkler(word, kw) >= 0.88) return profile;
        }
      }
    }

    return null;
  }

  /// Memeriksa apakah teks merupakan nama roastery yang diketahui
  bool isKnownRoastery(String text) {
    final lower = text.trim().toLowerCase();
    for (final r in _knownRoasteries) {
      if (lower == r || (lower.contains(r) && r.length >= 4)) return true;
      if (lower.length >= 5 && _jaroWinkler(lower, r) >= 0.90) return true;
    }
    return false;
  }

  static double _jaroWinkler(String s1, String s2) {
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
}
