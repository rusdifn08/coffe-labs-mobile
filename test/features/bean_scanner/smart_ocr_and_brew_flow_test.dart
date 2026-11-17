import 'dart:io';

import 'package:coffee_hub_mobile/features/bean_scanner/controllers/bean_scanner_controller.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/controllers/selected_brew_bean_controller.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/models/bean_scan_state.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/services/coffee_knowledge_graph_service.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/services/cognitive_bean_analyzer.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/widgets/smart_bean_camera_popup_modal.dart';
import 'package:coffee_hub_mobile/screens/brew_timer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Smart OCR + Unified Knowledge Graph Upgrade Tests', () {
    test('Knowledge Graph aggregates coffee.json, initial_classes.json, RoasteryCatalog & flavor lexicon', () async {
      await CoffeeKnowledgeGraphService.instance.initialize();
      final kg = CoffeeKnowledgeGraphService.instance;

      expect(kg.catalogEntries.length, greaterThanOrEqualTo(900));
      expect(kg.knownRoasteries.length, greaterThanOrEqualTo(120));
      expect(kg.flavorLexicon.length, greaterThanOrEqualTo(300));
      expect(kg.matchKnownRoastery('Fugol Coffee Roasters Kopi Arabika')?.canonicalName, 'Fugol Coffee Roasters');
    });

    test('Screenshot regression: Fugol Coffee Roasters Watermalon Smash noisy OCR resolves cleanly', () async {
      await CoffeeKnowledgeGraphService.instance.initialize();

      // Simulasi persis teks berantakan pada screenshot user
      const noisyOcrText = '''
Fugol Coffee Roasters Kopi Arabika Watermalon Smash
Specialty Coffee Arabica Beans Full01 Gnowvrba
1500 mdpl
''';

      final blocks = [
        {
          'text': 'Fugol Coffee Roasters\nKopi Arabika Watermalon Smash',
          'normalized_height': 0.14,
          'top_y': 0.22,
          'left_x': 0.12,
          'normalized_width': 0.76,
        },
        {
          'text': 'Specialty Coffee Arabica Beans Full01 Gnowvrba',
          'normalized_height': 0.05,
          'top_y': 0.42,
          'left_x': 0.12,
          'normalized_width': 0.76,
        },
        {
          'text': '1500 mdpl',
          'normalized_height': 0.03,
          'top_y': 0.56,
          'left_x': 0.18,
          'normalized_width': 0.30,
        },
      ];

      final resolved = CognitiveBeanAnalyzer.analyze(
        rawFullText: noisyOcrText,
        blocksDto: blocks,
      );

      expect(resolved.isCatalogVerified, isTrue);
      expect(resolved.roasteryName, 'Fugol Coffee Roasters');
      expect(resolved.beanName, 'Watermelon Smash');
      expect(resolved.fullDisplayName, 'Fugol Watermelon Smash');
      expect(resolved.origin, contains('Kamojang'));
      expect(resolved.origin.toLowerCase(), isNot(contains('full01')));
      expect(resolved.origin.toLowerCase(), isNot(contains('gnowvrba')));
      expect(resolved.origin.toLowerCase(), isNot(contains('specialty coffee')));
      expect(resolved.process, 'Natural');
      expect(resolved.tastingNotes, containsAll(['Watermelon', 'Strawberry', 'Mandarin Orange']));
      expect(resolved.tastingNotes, isNot(contains('Jasmine')));
      expect(resolved.recommendedWaterTempC, 91);

      expect(resolved.recommendedRecipes.length, greaterThanOrEqualTo(1));
      final primary = resolved.recommendedRecipes.first;
      expect(primary.steps, isNotEmpty);
      expect(primary.suggestedTempC, 91);

      final timerMap = primary.toBrewTimerRecipeMap(resolved);
      expect(timerMap['beanName'], 'Fugol Watermelon Smash');
      expect(timerMap['scannedRoastery'], 'Fugol Coffee Roasters');
      expect((timerMap['steps'] as List).length, greaterThanOrEqualTo(2));
    });

    test('Knowledge Graph matches catalog SKUs with minor OCR typos across brands', () async {
      await CoffeeKnowledgeGraphService.instance.initialize();

      final spaceResolved = CognitiveBeanAnalyzer.analyze(
        rawFullText: 'SPACE COFFEE ROASTERY\nBombe Flower Bomb\nNatural 21 Days Drying',
        blocksDto: const [
          {
            'text': 'SPACE COFFEE ROASTERY',
            'normalized_height': 0.06,
            'top_y': 0.18,
            'left_x': 0.15,
            'normalized_width': 0.70,
          },
          {
            'text': 'Bombe Flower Bomb',
            'normalized_height': 0.10,
            'top_y': 0.35,
            'left_x': 0.15,
            'normalized_width': 0.70,
          },
        ],
      );

      expect(spaceResolved.isCatalogVerified, isTrue);
      expect(spaceResolved.roasteryName, 'Space Coffee Roastery');
      expect(spaceResolved.beanName, 'Bombe Flower Bomb');
      expect(spaceResolved.fullDisplayName, 'Space Bombe Flower Bomb');
      expect(spaceResolved.tastingNotes, contains('Jasmine'));
    });

    testWidgets('1-Tap recommended recipe in SmartBeanCameraPopupModal opens BrewTimerScreen with Roastery + Bean Name',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await CoffeeKnowledgeGraphService.instance.initialize();

      final resolvedBean = CognitiveBeanAnalyzer.analyze(
        rawFullText: 'Fugol Coffee Roasters\nWatermelon Smash\nNatural',
        blocksDto: const [
          {
            'text': 'Fugol Coffee Roasters',
            'normalized_height': 0.06,
            'top_y': 0.2,
            'left_x': 0.15,
            'normalized_width': 0.7,
          },
          {
            'text': 'Watermelon Smash',
            'normalized_height': 0.1,
            'top_y': 0.35,
            'left_x': 0.15,
            'normalized_width': 0.7,
          },
        ],
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(beanScannerControllerProvider.notifier).state = BeanScanStateResolved(
        bean: resolvedBean,
        imageFile: File('non_existent_test_bag.jpg'),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SmartBeanCameraPopupModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Judul hasil scan menggunakan Roastery + Nama Kopi
      expect(find.text('Fugol Watermelon Smash'), findsOneWidget);
      expect(find.textContaining('Rekomendasi Resep Presisi'), findsOneWidget);

      // Scroll ke kartu rekomendasi utama & klik
      final scrollFinder = find.byType(SingleChildScrollView).first;
      await tester.drag(scrollFinder, const Offset(0, -450));
      await tester.pumpAndSettle();

      await tester.tap(find.text('★ Utama'));
      await tester.pumpAndSettle();

      // Berhasil masuk langsung ke BrewTimerScreen dan nama kopinya "Fugol Watermelon Smash"
      expect(find.byType(BrewTimerScreen), findsOneWidget);
      expect(find.text('Fugol Watermelon Smash'), findsOneWidget);
      expect(container.read(selectedBrewBeanProvider)?.fullDisplayName, 'Fugol Watermelon Smash');
      expect(tester.takeException(), isNull);
    });
  });
}
