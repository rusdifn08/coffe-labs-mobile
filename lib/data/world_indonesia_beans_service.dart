import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/network/isolate_json_transformer.dart';
import '../features/flavor_wheel/data/coffee_varieties_catalog.dart';
import '../models/bean_recommendation_models.dart';
import '../models/curated_roastery_bean.dart';
import 'brew_visual_catalog.dart';

/// Layanan katalog biji kopi terpadu Nusantara (Sabang–Merauke, 38 Provinsi) & Dunia (65+ Negara).
/// Memuat `assets/data/world_indonesia_beans_catalog.json` (hasil scraping CQI, Nomad, & Atlas)
/// secara asinkron di isolate agar 60–120 FPS tetap mulus, dipakai serentak oleh:
///   - Create Recipe (`EditorBeanSelectorModal`)
///   - Dial-In Smart Brew (`BeanRecipeRecommenderScreen` & `RoasteryBeanPickerModal`)
///   - Flavor Wheel Varieties (`CoffeeVarietiesCatalog`)
class WorldIndonesiaBeansService {
  static final WorldIndonesiaBeansService instance = WorldIndonesiaBeansService._();
  WorldIndonesiaBeansService._();

  bool _loaded = false;
  List<BeanVisualItem> _atlasVisualBeans = const [];
  List<CuratedRoasteryBean> _atlasCuratedBeans = const [];
  List<CoffeeVarietyInfo> _varieties = const [];
  List<String> _processes = const [];

  bool get isLoaded => _loaded;
  List<CoffeeVarietyInfo> get extraVarieties => _varieties;
  List<String> get extraProcesses => _processes;

  List<BeanVisualItem> get allMergedVisualBeans {
    if (_atlasVisualBeans.isEmpty) return BrewVisualCatalog.beans;
    final seen = <String>{};
    final merged = <BeanVisualItem>[];
    for (final b in [...BrewVisualCatalog.beans, ..._atlasVisualBeans]) {
      final k = b.name.trim().toLowerCase();
      if (seen.add(k)) merged.add(b);
    }
    return merged;
  }

  List<CuratedRoasteryBean> mergeWithCuratedBeans(List<CuratedRoasteryBean> base) {
    if (_atlasCuratedBeans.isEmpty) return base;
    final seen = <String>{};
    final merged = <CuratedRoasteryBean>[];
    for (final b in [...base, ..._atlasCuratedBeans]) {
      final k = '${b.roasteryName.toLowerCase()}|${b.name.toLowerCase()}';
      if (seen.add(k)) merged.add(b);
    }
    return merged;
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      String raw = '';
      try {
        raw = await rootBundle.loadString('assets/data/world_indonesia_beans_catalog.json');
      } catch (_) {
        if (!kIsWeb) {
          final f = File('assets/data/world_indonesia_beans_catalog.json');
          if (f.existsSync()) raw = f.readAsStringSync();
        }
      }
      if (raw.isEmpty) return;
      final decoded = await IsolateJsonTransformer.parseJsonInBackground(raw);
      _ingestDecoded(decoded);
      _loaded = true;
    } catch (e) {
      debugPrint('WorldIndonesiaBeansService notice: $e');
    }
  }

  void ensureLoadedSyncForTest() {
    if (_loaded || kIsWeb) return;
    try {
      final f = File('assets/data/world_indonesia_beans_catalog.json');
      if (f.existsSync()) {
        _ingestDecoded(jsonDecode(f.readAsStringSync()));
        _loaded = true;
      }
    } catch (_) {}
  }

  void _ingestDecoded(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return;

    final rawVars = decoded['varieties'] as List? ?? const [];
    final parsedVars = <CoffeeVarietyInfo>[];
    for (final v in rawVars) {
      if (v is Map) {
        parsedVars.add(
          CoffeeVarietyInfo(
            name: (v['name'] ?? '').toString(),
            category: (v['category'] ?? 'Nusantara').toString(),
            origin: (v['origin'] ?? 'Indonesia').toString(),
            tasteProfile: (v['tasteProfile'] ?? '').toString(),
          ),
        );
      }
    }
    _varieties = parsedVars;

    final rawProcs = decoded['processes'] as List? ?? const [];
    _processes = rawProcs.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();

    final rawBeans = decoded['beans'] as List? ?? const [];
    final visual = <BeanVisualItem>[];
    final curated = <CuratedRoasteryBean>[];

    const palette = <Color>[
      Color(0xFF6D4C41),
      Color(0xFF8E24AA),
      Color(0xFFD84315),
      Color(0xFF2E7D32),
      Color(0xFF1565C0),
      Color(0xFFC2185B),
      Color(0xFF00695C),
      Color(0xFFEF6C00),
    ];

    for (var i = 0; i < rawBeans.length; i++) {
      final item = rawBeans[i];
      if (item is! Map) continue;
      final name = (item['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      final region = (item['region'] ?? 'Indonesia 🇮🇩').toString();
      final variety = (item['variety'] ?? 'Arabica Specialty').toString();
      final processRaw = (item['process'] ?? 'Full Washed').toString();
      final roastRaw = (item['roast'] ?? 'Light-Medium').toString();
      final notes = (item['notes'] as List? ?? const [])
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList();
      final emoji = (item['emoji'] ?? '☕').toString();
      final roastery = (item['roastery'] ??
              ((item['country']?.toString().toLowerCase() == 'indonesia')
                  ? 'Nusantara Single Origin'
                  : 'World Specialty Origin'))
          .toString();

      visual.add(
        BeanVisualItem(
          name: name,
          region: region,
          defaultVariety: variety,
          process: processRaw,
          roast: roastRaw,
          defaultNotes: notes.isNotEmpty ? notes : const ['Caramel', 'Citrus', 'Chocolate'],
          color: palette[i % palette.length],
          emoji: emoji,
        ),
      );

      curated.add(
        CuratedRoasteryBean(
          id: (item['id'] ?? 'atlas_$i').toString(),
          roasteryName: roastery,
          roasteryLocation: region,
          roasteryImageUrl: '',
          roasteryLogoUrl: '',
          packageImageUrl: '',
          name: name,
          origin: region,
          roastProfileRaw: roastRaw,
          roastLevel: _mapRoast(roastRaw),
          processRaw: processRaw,
          process: _mapProcess(processRaw),
          variety: variety,
          tastingNotes: notes.join(', '),
          tastingNotesList: notes,
          badge: item['country']?.toString().toLowerCase() == 'indonesia'
              ? '🇮🇩 Nusantara'
              : '🌍 World Lot',
          originalPackage: '200g',
          soldCount: 120 + (i % 80),
          recommendedDripper: processRaw.toLowerCase().contains('natural') ||
                  processRaw.toLowerCase().contains('anaerobic')
              ? BeanDripper.origami
              : BeanDripper.v60,
          baristaOpinion:
              'Terroir $region ($variety • $processRaw). Rekomendasi suhu seduh ${item['temp'] ?? 91}°C untuk menonjolkan karakter ${notes.take(3).join(', ')}.',
          tempNotesHot: 'Aroma awal ${notes.isNotEmpty ? notes.first : 'floral'} bersih dan ekspresif.',
          tempNotesWarm: 'Kemanisan puncak & keseimbangan rasa ${notes.skip(1).take(2).join(', ')}.',
          tempNotesCool: 'Aftertaste bersih, juicy dan manis panjang.',
        ),
      );
    }

    _atlasVisualBeans = visual;
    _atlasCuratedBeans = curated;
  }

  static BeanRoastLevel _mapRoast(String raw) {
    final l = raw.toLowerCase();
    if (l.contains('medium-dark') || l.contains('medium dark')) return BeanRoastLevel.mediumDark;
    if (l.contains('dark')) return BeanRoastLevel.dark;
    if (l.contains('light-medium') || l.contains('medium-light')) return BeanRoastLevel.mediumLight;
    if (l.contains('light')) return BeanRoastLevel.light;
    return BeanRoastLevel.medium;
  }

  static BeanProcess _mapProcess(String raw) {
    final l = raw.toLowerCase();
    if (l.contains('giling basah') || l.contains('wet hulled') || l.contains('wet-hulled') || l.contains('monsoon')) {
      return BeanProcess.wetHulled;
    }
    if (l.contains('anaerobic') || l.contains('carbonic') || l.contains('thermal') || l.contains('wine') || l.contains('koji') || l.contains('co-ferment') || l.contains('lactic') || l.contains('yeast')) {
      return BeanProcess.anaerobic;
    }
    if (l.contains('honey') || l.contains('pulped')) return BeanProcess.honey;
    if (l.contains('natural') || l.contains('dry')) return BeanProcess.natural;
    return BeanProcess.washed;
  }
}
