import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/grinder/models/grinder_spec.dart';
import 'package:coffee_hub_mobile/features/grinder/services/grinder_conversion_engine.dart';
import 'package:coffee_hub_mobile/screens/grinder_converter_screen.dart';
import 'package:coffee_hub_mobile/utils/barista_utils.dart';

void main() {
  group('Grinder Database Integrity (102 Verified Grinders)', () {
    test('contains exactly 70 manual and 32 electric grinders with unique IDs', () {
      final all = GrinderConversionEngine.allGrinders;
      final manual = GrinderConversionEngine.grindersByCategory(GrinderCategory.manual);
      final electric = GrinderConversionEngine.grindersByCategory(GrinderCategory.electric);

      expect(manual.length, 70);
      expect(electric.length, 32);
      expect(all.length, 102);

      final ids = all.map((g) => g.id).toSet();
      expect(ids.length, all.length, reason: 'Every grinder must have a unique ID');

      for (final g in all) {
        if (g.calibrationTier == CalibrationTier.specOnly) {
          expect(g.anchors, isEmpty, reason: '${g.id} specOnly must never fabricate anchors');
        } else {
          expect(g.anchors.length, greaterThanOrEqualTo(2), reason: '${g.id} needs >=2 anchors');
          for (int i = 0; i < g.anchors.length - 1; i++) {
            expect(
              g.anchors[i + 1].microns,
              greaterThan(g.anchors[i].microns),
              reason: '${g.id} microns must strictly increase',
            );
            expect(
              g.anchors[i + 1].setting,
              greaterThanOrEqualTo(g.anchors[i].setting),
              reason: '${g.id} settings must be monotonically non-decreasing',
            );
          }
        }
      }
    });

    test('groups brands cleanly for 2-step Brand -> Model selection', () {
      final brands = GrinderConversionEngine.getBrands();
      expect(brands.first, '1Zpresso');
      expect(GrinderConversionEngine.getModelsForBrand('1Zpresso').length, 16);
      expect(
        GrinderConversionEngine.getModelsForBrand('Timemore', category: GrinderCategory.manual).length,
        14,
      );
      expect(
        GrinderConversionEngine.getModelsForBrand('Timemore', category: GrinderCategory.electric).length,
        6,
      );
      expect(GrinderConversionEngine.getModelsForBrand('KINGrinder').length, 10);
      expect(GrinderConversionEngine.getModelsForBrand('Baratza').length, 4);
    });
  });

  group('Physical Dial Mapping (Putaran.Angka.Klik) Accuracy', () {
    test('maps Click 20 accurately across every dial architecture', () {
      final normcore = GrinderConversionEngine.findById('normcore_manual_v2')!;
      expect(GrinderConversionEngine.formatDialReading(normcore, 20).physicalNotation, '0.10.0');

      final q2 = GrinderConversionEngine.findById('1zpresso_q2')!;
      expect(GrinderConversionEngine.formatDialReading(q2, 20).physicalNotation, '0.6.2');

      final c3Esp = GrinderConversionEngine.findById('timemore_c3_esp')!;
      expect(GrinderConversionEngine.formatDialReading(c3Esp, 20).physicalNotation, '0.6.2');

      final k2 = GrinderConversionEngine.findById('kingrinder_k2')!;
      expect(GrinderConversionEngine.formatDialReading(k2, 20).physicalNotation, '0.5.0');
      expect(GrinderConversionEngine.formatDialReading(k2, 86).physicalNotation, '2.1.2');

      final jxPro = GrinderConversionEngine.findById('1zpresso_jx_pro')!;
      expect(GrinderConversionEngine.formatDialReading(jxPro, 20).physicalNotation, '0.5.0');
      expect(GrinderConversionEngine.formatDialReading(jxPro, 145).physicalNotation, '3.6.1');

      final bladeR3 = GrinderConversionEngine.findById('mhw3bomber_blade_r3')!;
      expect(GrinderConversionEngine.formatDialReading(bladeR3, 20).physicalNotation, '0.4.0');
      expect(GrinderConversionEngine.formatDialReading(bladeR3, 69).physicalNotation, '1.1.4');

      final kUltra = GrinderConversionEngine.findById('1zpresso_k_ultra')!;
      expect(GrinderConversionEngine.formatDialReading(kUltra, 20).physicalNotation, '0.2.0');
      expect(GrinderConversionEngine.formatDialReading(kUltra, 82).physicalNotation, '0.8.2');

      final k6 = GrinderConversionEngine.findById('kingrinder_k6')!;
      expect(GrinderConversionEngine.formatDialReading(k6, 20).physicalNotation, '0.20');
      expect(GrinderConversionEngine.formatDialReading(k6, 100).physicalNotation, '1.40');

      final c3 = GrinderConversionEngine.findById('timemore_c3')!;
      expect(GrinderConversionEngine.formatDialReading(c3, 20).physicalNotation, '1 put + 8 klik');
    });

    test('matches worked conversion examples from reference document', () {
      // Contoh 1: Timemore C3 (17 klik) -> KINGrinder K6 = 114 klik (1.54)
      final c3 = GrinderConversionEngine.findById('timemore_c3')!;
      final k6 = GrinderConversionEngine.findById('kingrinder_k6')!;
      final res1 = GrinderConversionEngine.convert(source: c3, sourceSetting: 17, target: k6);

      expect(res1.targetReading, isNotNull);
      expect(res1.targetReading!.primaryDisplay, '114 klik');
      expect(res1.targetReading!.physicalNotation, '1.54');

      // Contoh 2: Normcore V2 (20 klik = 0.10.0) -> DF64 Gen 2 (~29.8 - 32.0)
      final normcore = GrinderConversionEngine.findById('normcore_manual_v2')!;
      final df64 = GrinderConversionEngine.findById('df64_gen2')!;
      final res2 = GrinderConversionEngine.convert(source: normcore, sourceSetting: 20, target: df64);

      expect(res2.sourceReading.physicalNotation, '0.10.0');
      expect(res2.targetReading, isNotNull);
      expect(res2.targetReading!.rawValue, inInclusiveRange(29.0, 32.5));

      // Eureka Mignon Specialità multi-turn (0+2.5 Espresso, 1+1.5 V60)
      final eureka = GrinderConversionEngine.findById('eureka_mignon_specialita')!;
      final eurekaEsp = GrinderConversionEngine.micronsToSetting(eureka, BrewMicronAnchors.espresso)!;
      final eurekaV60 = GrinderConversionEngine.micronsToSetting(eureka, BrewMicronAnchors.v60)!;
      expect(GrinderConversionEngine.formatDialReading(eureka, eurekaEsp).primaryDisplay, '0+2.5');
      expect(GrinderConversionEngine.formatDialReading(eureka, eurekaV60).primaryDisplay, '1+1.5');

      // Baratza Encore ESP dual-range zone labels
      final esp = GrinderConversionEngine.findById('baratza_encore_esp')!;
      expect(
        GrinderConversionEngine.formatDialReading(esp, 15).physicalNotation,
        contains('Zona Mikro Espresso'),
      );
      expect(
        GrinderConversionEngine.formatDialReading(esp, 25).physicalNotation,
        contains('Zona Filter'),
      );
    });

    test('enforces filter-only warnings and zero-hallucination for spec-only grinders', () {
      final jUltra = GrinderConversionEngine.findById('1zpresso_j_ultra')!;
      final zp6 = GrinderConversionEngine.findById('1zpresso_zp6_special')!;
      final resFilter = GrinderConversionEngine.convert(source: jUltra, sourceSetting: 139, target: zp6);
      expect(resFilter.targetReading?.warning, contains('khusus Filter'));

      final sumba = GrinderConversionEngine.findById('latina_sumba_v7')!;
      final resSpec = GrinderConversionEngine.convert(source: jUltra, sourceSetting: 288, target: sumba);
      expect(resSpec.targetReading?.primaryDisplay, 'Kalibrasi Visual');
      expect(resSpec.notice, contains('belum memiliki tabel granulometri independen'));

      // BaristaUtils now returns accurate JX-Pro V60 (~145 klik (3.6.1)), never broken 34 klik!
      final recipeMap = BaristaUtils.grinderConversions('Medium (V60)');
      expect(recipeMap['1Zpresso JX-Pro'], contains('145 klik'));
      expect(recipeMap['1Zpresso JX-Pro'], contains('3.6.1'));
      expect(recipeMap['KINGrinder K6'], contains('100 klik'));
      expect(recipeMap['KINGrinder K6'], contains('1.40'));
    });
  });

  group('GrinderConverterScreen UI (360px Mobile Viewport)', () {
    testWidgets('renders Brand->Model converter & 102-grinder matrix cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: GrinderConverterScreen(initialMicrons: 650),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('1. MEREK'), findsNWidgets(2));
      expect(find.text('100 klik'), findsOneWidget);
      expect(find.text('Posisi Dial Fisik: 1.40'), findsOneWidget);

      // Pindah ke Tab 2: Matriks 102 Grinder
      await tester.tap(find.text('Matriks 102 Grinder'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.textContaining('Menampilkan 102 Grinder'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Menampilkan 102 Grinder'), findsOneWidget);
    });
  });
}
