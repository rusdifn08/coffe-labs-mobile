import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/controllers/bean_scanner_controller.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/controllers/selected_brew_bean_controller.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/models/bean_scan_state.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/models/resolved_coffee_bean.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/widgets/home_header_scanner_button.dart';

void main() {
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
  });
}
