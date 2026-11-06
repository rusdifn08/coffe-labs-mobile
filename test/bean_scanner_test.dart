import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/controllers/bean_scanner_controller.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/controllers/selected_brew_bean_controller.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/models/bean_scan_state.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/models/resolved_coffee_bean.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/services/cognitive_bean_analyzer.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/widgets/home_header_scanner_button.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/widgets/home_floating_scanner_fab.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/widgets/scanned_bag_bounding_box_overlay.dart';

void main() {
  group('CognitiveBeanAnalyzer Smart AI Tests', () {
    test('BAK COFFEE BEAN - MALABAR WINE (Human-like reasoning & AI Sommelier inference)', () {
      const rawText = '''
BAK COFFEE BEAN
MALABAR
WINE
FRESH BEAN
BETTER BREW
ROASTING DATE
''';

      final blocks = [
        {
          'text': 'BAK COFFEE BEAN',
          'normalized_height': 0.05,
          'top_y': 0.36,
          'left_x': 0.20,
          'normalized_width': 0.60,
        },
        {
          'text': 'MALABAR',
          'normalized_height': 0.14,
          'top_y': 0.44,
          'left_x': 0.25,
          'normalized_width': 0.50,
        },
        {
          'text': 'WINE',
          'normalized_height': 0.08,
          'top_y': 0.52,
          'left_x': 0.35,
          'normalized_width': 0.30,
        },
        {
          'text': 'FRESH BEAN',
          'normalized_height': 0.03,
          'top_y': 0.78,
          'left_x': 0.15,
          'normalized_width': 0.30,
        },
        {
          'text': 'BETTER BREW',
          'normalized_height': 0.03,
          'top_y': 0.82,
          'left_x': 0.15,
          'normalized_width': 0.30,
        },
        {
          'text': 'ROASTING DATE',
          'normalized_height': 0.03,
          'top_y': 0.88,
          'left_x': 0.15,
          'normalized_width': 0.35,
        },
      ];

      final result = CognitiveBeanAnalyzer.analyze(
        rawFullText: rawText,
        blocksDto: blocks,
      );

      expect(result.roasteryName, 'Bak Coffee Bean');
      expect(result.beanName, 'Malabar Wine');
      expect(result.origin, contains('Malabar'));
      expect(result.process, 'Wine Process');
      expect(result.notesSource, 'AI_SOMMELIER_INFERRED');
      expect(result.isAiInferredAltitude, isTrue);
      expect(result.isAiInferredVariety, isTrue);

      // AI Sommelier inferred notes for Wine Process
      expect(result.tastingNotes, contains('Winey'));
      expect(result.tastingNotes, contains('Red Grape'));
      expect(result.tastingNotes, contains('Strawberry'));
      expect(result.tastingNotes, contains('Blackcurrant'));
      expect(result.tastingNotes, contains('Dark Cocoa'));

      // Recommended temperature for Wine process
      expect(result.recommendedWaterTempC, 89);
      expect(result.classifiedBlocks.length, 6);
    });

    test('KOPI GUNUNG HALU (Checkbox detection & Natural process)', () {
      const rawText = '''
KOPI GUNUNG HALU
FRESH BEAN BETTER BREW
DARI GUNUNG, UNTUK CITA RASA TERBAIK
ROASTING DATE 26/10
PROSES
[x] NATURAL
[ ] WASHED
[ ] WINE
100% ARABICA PREMIUM QUALITY
''';

      final blocks = [
        {
          'text': 'KOPI GUNUNG HALU',
          'normalized_height': 0.12,
          'top_y': 0.35,
          'left_x': 0.2,
          'normalized_width': 0.6,
        },
        {
          'text': '[x] NATURAL',
          'normalized_height': 0.04,
          'top_y': 0.70,
          'left_x': 0.5,
          'normalized_width': 0.25,
        },
        {
          'text': '[ ] WASHED',
          'normalized_height': 0.04,
          'top_y': 0.75,
          'left_x': 0.5,
          'normalized_width': 0.25,
        },
        {
          'text': '[ ] WINE',
          'normalized_height': 0.04,
          'top_y': 0.80,
          'left_x': 0.5,
          'normalized_width': 0.25,
        },
      ];

      final result = CognitiveBeanAnalyzer.analyze(
        rawFullText: rawText,
        blocksDto: blocks,
      );

      expect(result.process, 'Natural');
      expect(result.origin, anyOf(contains('Halu'), contains('Malabar')));
      expect(result.tastingNotes, contains('Blueberry'));
      expect(result.recommendedWaterTempC, 90);
    });

    test('Otten COFFEE - WAMENA BPIRI washed (Explicit notes & altitude extraction)', () {
      const rawText = '''
Otten COFFEE
WAMENA BPIRI washed
Palm Sugar • Red Fruit • Chestnut
Region: Distrik Bpiri, Jayawijaya/Wamena, Papua
Altitude: 2068 Masl
200g
''';

      final blocks = [
        {
          'text': 'Otten COFFEE',
          'normalized_height': 0.10,
          'top_y': 0.25,
          'left_x': 0.2,
          'normalized_width': 0.6,
        },
        {
          'text': 'WAMENA BPIRI washed',
          'normalized_height': 0.08,
          'top_y': 0.55,
          'left_x': 0.2,
          'normalized_width': 0.6,
        },
        {
          'text': 'Palm Sugar • Red Fruit • Chestnut',
          'normalized_height': 0.04,
          'top_y': 0.65,
          'left_x': 0.2,
          'normalized_width': 0.6,
        },
        {
          'text': 'Altitude: 2068 Masl',
          'normalized_height': 0.03,
          'top_y': 0.75,
          'left_x': 0.2,
          'normalized_width': 0.4,
        },
      ];

      final result = CognitiveBeanAnalyzer.analyze(
        rawFullText: rawText,
        blocksDto: blocks,
      );

      expect(result.roasteryName, 'Otten Coffee');
      expect(result.process, 'Full Washed');
      expect(result.notesSource, 'OCR_EXPLICIT');
      expect(result.isAiInferredAltitude, isFalse);
      expect(result.altitudeMasl, '2068 MASL');
      expect(
        result.tastingNotes,
        anyOf(contains('Brown Sugar'), contains('Red Fruit'), contains('Chestnut')),
      );
    });

    test('Fuzzy typo-tolerant flavor matching', () {
      const typos = 'bluberry, starberry, jasmin, tea';
      final matched = CognitiveBeanAnalyzer.matchTastingNotes(typos);

      expect(matched, contains('Blueberry'));
      expect(matched, contains('Strawberry'));
      expect(matched, contains('Jasmine'));
      expect(matched, contains('Black Tea'));
    });
  });

  group('ScannedBagBoundingBoxOverlay Widget Tests', () {
    testWidgets('renders bounding boxes overlay cleanly', (tester) async {
      final dummyFile = File('dummy_scan.jpg');
      const blocks = [
        ClassifiedOcrBlock(
          text: 'BAK COFFEE BEAN',
          role: BlockRole.roastery,
          topY: 0.1,
          leftX: 0.2,
          normalizedWidth: 0.6,
          normalizedHeight: 0.08,
        ),
        ClassifiedOcrBlock(
          text: 'MALABAR',
          role: BlockRole.originOrTitle,
          topY: 0.3,
          leftX: 0.2,
          normalizedWidth: 0.6,
          normalizedHeight: 0.12,
        ),
        ClassifiedOcrBlock(
          text: 'WINE',
          role: BlockRole.process,
          topY: 0.5,
          leftX: 0.3,
          normalizedWidth: 0.4,
          normalizedHeight: 0.08,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScannedBagBoundingBoxOverlay(
              imageFile: dummyFile,
              blocks: blocks,
              height: 250,
            ),
          ),
        ),
      );

      expect(find.byType(ScannedBagBoundingBoxOverlay), findsOneWidget);
      expect(find.text('Roastery'), findsOneWidget);
      expect(find.text('Origin'), findsOneWidget);
      expect(find.text('Proses'), findsOneWidget);
    });
  });

  group('ResolvedCoffeeBean Model & Logic Tests', () {
    test('JSON serialization & deserialization handles verified catalog and fallback data cleanly', () {
      final json = {
        'bean_id': '00000000-0000-0000-0000-000000000001',
        'is_catalog_verified': true,
        'confidence_score': 98.5,
        'roastery_name': 'Smoking Barrels',
        'bean_name': 'Halmahera Spice Island',
        'origin': 'Halmahera',
        'variety': 'Kartika & Abyssinia',
        'process': 'Natural Anaerobic',
        'roast_level': 'Light',
        'altitude_masl': '1500 - 1700 MDPL',
        'tasting_notes': ['Strawberry Jam', 'Cacao Nibs', 'Rose Wine'],
        'recommended_water_temp_c': 90,
        'recommended_recipes': [
          {
            'slug': 'dual-temperature-thermal-drop-v60',
            'name': 'Dual-Temperature Thermal Drop V60',
            'target_notes': 'Highlight sweetness',
            'suggested_temp_c': 90,
            'ratio': '1:15',
          }
        ],
      };

      final bean = ResolvedCoffeeBean.fromJson(json, localImagePath: 'dummy_path.jpg');

      expect(bean.isCatalogVerified, isTrue);
      expect(bean.confidenceScore, 98.5);
      expect(bean.roasteryName, 'Smoking Barrels');
      expect(bean.beanName, 'Halmahera Spice Island');
      expect(bean.process, 'Natural Anaerobic');
      expect(bean.recommendedWaterTempC, 90);
      expect(bean.recommendedRecipes.length, 1);
      expect(bean.recommendedRecipes.first.slug, 'dual-temperature-thermal-drop-v60');

      final serialized = bean.toJson();
      expect(serialized['roastery_name'], 'Smoking Barrels');
      expect(serialized['is_catalog_verified'], isTrue);

      final modified = bean.copyWith(roasteryName: 'Custom Roastery');
      expect(modified.roasteryName, 'Custom Roastery');
      expect(modified.beanName, 'Halmahera Spice Island');
    });
  });

  group('SelectedBrewBeanController Tests', () {
    test('Stores and clears scanned bean correctly in Riverpod container', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedBrewBeanProvider), isNull);

      const bean = ResolvedCoffeeBean(
        isCatalogVerified: false,
        confidenceScore: 89.0,
        roasteryName: 'Instinct Roastery',
        beanName: 'Gayo Honey Reserve',
        origin: 'Aceh Gayo',
        variety: 'Abyssinia & Typica',
        process: 'Black Honey',
        roastLevel: 'Light to Medium',
        tastingNotes: ['Melon', 'Sweet Orange'],
        recommendedWaterTempC: 91,
        recommendedRecipes: [],
      );

      container.read(selectedBrewBeanProvider.notifier).setBean(bean);
      expect(container.read(selectedBrewBeanProvider)?.beanName, 'Gayo Honey Reserve');

      container.read(selectedBrewBeanProvider.notifier).clear();
      expect(container.read(selectedBrewBeanProvider), isNull);
    });
  });

  group('BeanScannerController Tests', () {
    test('State management transitions and updates notes cleanly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(beanScannerControllerProvider), isA<BeanScanStateIdle>());

      const bean = ResolvedCoffeeBean(
        isCatalogVerified: true,
        confidenceScore: 95.0,
        roasteryName: 'Fuglen',
        beanName: 'Ethiopia Yirgacheffe Chelchele',
        origin: 'Yirgacheffe',
        variety: 'Heirloom',
        process: 'Full Washed',
        roastLevel: 'Ultra Light',
        tastingNotes: ['Floral', 'Earl Grey', 'Lemon Peel'],
        recommendedWaterTempC: 93,
        recommendedRecipes: [],
      );

      final dummyFile = File('dummy.jpg');
      container.read(beanScannerControllerProvider.notifier).state =
          BeanScanStateResolved(bean: bean, imageFile: dummyFile);

      final current = container.read(beanScannerControllerProvider);
      expect(current, isA<BeanScanStateResolved>());

      // Modify notes
      final updatedBean = bean.copyWith(tastingNotes: ['Floral', 'Earl Grey']);
      container.read(beanScannerControllerProvider.notifier).updateResolvedBean(updatedBean);

      final resolvedState = container.read(beanScannerControllerProvider) as BeanScanStateResolved;
      expect(resolvedState.bean.tastingNotes.length, 2);

      // Reset
      container.read(beanScannerControllerProvider.notifier).reset();
      expect(container.read(beanScannerControllerProvider), isA<BeanScanStateIdle>());
    });
  });

  group('Diagnostic Bug Fix Tests (Bugs 1, 2, 3)', () {
    test('Bug 2 & 3: KOPI GUNUNG HALU categorizes origin properly and ignores slogan', () {
      const rawText = '''
KOPI GUNUNG HALU
FRESH BEAN BETTER BREW
DARI GUNUNG, UNTUK CITA RASA TERBAIK
PROSES
[x] NATURAL
[ ] WASHED
[ ] WINE
100% ARABICA PREMIUM QUALITY
''';

      final blocks = [
        {
          'text': 'KOPI GUNUNG HALU',
          'normalized_height': 0.12,
          'top_y': 0.35,
          'left_x': 0.2,
          'normalized_width': 0.6,
        },
        {
          'text': 'FRESH BEAN BETTER BREW',
          'normalized_height': 0.04,
          'top_y': 0.48,
          'left_x': 0.2,
          'normalized_width': 0.6,
        },
        {
          'text': 'Dart Gunung, Untuk Citai Terbaik Wine', // OCR Typo Slogan
          'normalized_height': 0.10,
          'top_y': 0.55,
          'left_x': 0.2,
          'normalized_width': 0.6,
        },
        {
          'text': '[x] NATURAL',
          'normalized_height': 0.04,
          'top_y': 0.70,
          'left_x': 0.5,
          'normalized_width': 0.25,
        },
        {
          'text': '[ ] WASHED',
          'normalized_height': 0.04,
          'top_y': 0.75,
          'left_x': 0.5,
          'normalized_width': 0.25,
        },
      ];

      final result = CognitiveBeanAnalyzer.analyze(
        rawFullText: rawText,
        blocksDto: blocks,
      );

      // Slogan is NOT the bean name! Origin is used!
      expect(result.beanName, equals('Gunung Halu Natural'));
      expect(result.origin, contains('Halu'));

      // Block roles: KOPI GUNUNG HALU must be Origin (NOT Roastery!)
      final originBlock = result.classifiedBlocks.firstWhere((b) => b.text == 'KOPI GUNUNG HALU');
      expect(originBlock.role, equals(BlockRole.originOrTitle));

      // Slogans & boilerplate must be ignoredNoise (NOT tastingNote!)
      final sloganBlock = result.classifiedBlocks.firstWhere((b) => b.text.contains('Gunung, Untuk Citai'));
      expect(sloganBlock.role, equals(BlockRole.ignoredNoise));

      final freshBeanBlock = result.classifiedBlocks.firstWhere((b) => b.text == 'FRESH BEAN BETTER BREW');
      expect(freshBeanBlock.role, equals(BlockRole.ignoredNoise));
    });

    test('Bug 2: Unrecognized arbitrary text NEVER defaults to tastingNote', () {
      const rawText = 'BAK COFFEE BEAN MALABAR WINE BOTTLE LABEL 500ML';
      final blocks = [
        {
          'text': 'MALABAR',
          'normalized_height': 0.10,
          'top_y': 0.40,
          'left_x': 0.2,
          'normalized_width': 0.6,
        },
        {
          'text': 'BOTTLE LABEL 500ML',
          'normalized_height': 0.04,
          'top_y': 0.85,
          'left_x': 0.2,
          'normalized_width': 0.5,
        },
      ];

      final result = CognitiveBeanAnalyzer.analyze(
        rawFullText: rawText,
        blocksDto: blocks,
      );

      // MALABAR is origin
      final malabarBlock = result.classifiedBlocks.firstWhere((b) => b.text == 'MALABAR');
      expect(malabarBlock.role, equals(BlockRole.originOrTitle));

      // BOTTLE LABEL 500ML is ignored noise, NOT a tasting note
      final bottleBlock = result.classifiedBlocks.firstWhere((b) => b.text == 'BOTTLE LABEL 500ML');
      expect(bottleBlock.role, equals(BlockRole.ignoredNoise));
    });
  });

  group('HomeHeaderScannerButton Widget Tests', () {
    testWidgets('renders compact button without crashing', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeHeaderScannerButton(compact: true),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.center_focus_strong_rounded), findsOneWidget);
    });

    testWidgets('renders full scanner banner button without crashing', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HomeHeaderScannerButton(compact: false, animate: false),
            ),
          ),
        ),
      );

      expect(find.text('Scan Kemasan Kopi (AI Vision)'), findsOneWidget);
      expect(find.text('AI OCR'), findsOneWidget);
    });

    testWidgets('renders HomeFloatingScannerFab floating camera button in bottom corner', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              floatingActionButton: HomeFloatingScannerFab(animate: false),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.center_focus_strong_rounded), findsOneWidget);
      expect(find.byType(HomeFloatingScannerFab), findsOneWidget);
    });
  });
}
