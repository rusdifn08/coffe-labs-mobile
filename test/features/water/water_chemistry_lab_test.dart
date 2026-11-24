import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/water/services/water_chemistry_engine.dart';
import 'package:coffee_hub_mobile/screens/water_recipe_screen.dart';

void main() {
  group('WaterChemistryEngine — Stoichiometry & Boiler Safety', () {
    test('computes exact stoichiometric GH/KH/ions for Epsom, CaCl2, NaHCO3, and KHCO3', () {
      const zeroWater = BaseWaterPreset(
        id: 'pure_zero',
        name: 'Zero Pure',
        subtitle: '0 ppm',
        ghPpm: 0,
        khPpm: 0,
        tdsPpm: 0,
      );

      final epsomRes = WaterChemistryEngine.analyze(
        baseWater: zeroWater,
        addition: const MineralAddition(epsomSaltMgPerL: 100),
      );
      expect(epsomRes.mgGhPpm, closeTo(40.61, 0.1));
      expect(epsomRes.mgIonMgL, closeTo(9.86, 0.1));
      expect(epsomRes.so4IonMgL, closeTo(38.97, 0.1));

      final caRes = WaterChemistryEngine.analyze(
        baseWater: zeroWater,
        addition: const MineralAddition(calciumChlorideMgPerL: 100),
      );
      expect(caRes.caGhPpm, closeTo(68.08, 0.1));
      expect(caRes.clIonMgL, closeTo(48.23, 0.1));

      final sodaRes = WaterChemistryEngine.analyze(
        baseWater: zeroWater,
        addition: const MineralAddition(bakingSodaMgPerL: 100),
      );
      expect(sodaRes.khPpm, closeTo(59.57, 0.1));
      expect(sodaRes.naIonMgL, closeTo(27.37, 0.1));

      final kRes = WaterChemistryEngine.analyze(
        baseWater: zeroWater,
        addition: const MineralAddition(potassiumBicarbMgPerL: 100),
      );
      expect(kRes.khPpm, closeTo(49.99, 0.1));
      expect(kRes.kIonMgL, closeTo(39.05, 0.1));
      expect(kRes.naIonMgL, 0.0);
    });

    test('detects boiler scaling, chloride corrosion, and SCA optimal zones accurately', () {
      final roBase = WaterChemistryEngine.baseWaters.first;

      // Optimal SCA
      final optimal = WaterChemistryEngine.analyze(
        baseWater: roBase,
        addition: const MineralAddition(
          epsomSaltMgPerL: 110,
          calciumChlorideMgPerL: 34,
          bakingSodaMgPerL: 42,
          potassiumBicarbMgPerL: 30,
        ),
      );
      expect(optimal.boilerStatus, BoilerSafetyStatus.optimal);
      expect(optimal.readinessScore, greaterThanOrEqualTo(90));

      // Chloride corrosion risk (Cl- > 50 mg/L)
      final corrosive = WaterChemistryEngine.analyze(
        baseWater: roBase,
        addition: const MineralAddition(
          calciumChlorideMgPerL: 130, // ~62.7 mg/L Cl-
          bakingSodaMgPerL: 20,
        ),
      );
      expect(corrosive.boilerStatus, BoilerSafetyStatus.corrosionRisk);

      // Scaling risk (Ca-GH > 75 & KH > 60)
      final scaling = WaterChemistryEngine.analyze(
        baseWater: WaterChemistryEngine.baseWaters.last, // Air Sumur Sadah
        addition: const MineralAddition(),
      );
      expect(scaling.boilerStatus, BoilerSafetyStatus.corrosionRisk); // Cl- 52 mg/L on well_hard
      final pureScale = WaterChemistryEngine.analyze(
        baseWater: const BaseWaterPreset(
          id: 'hard_no_cl',
          name: 'Hard CaCO3',
          subtitle: 'High Ca & KH',
          ghPpm: 200,
          khPpm: 140,
          tdsPpm: 300,
          clMgL: 10,
          mgShare: 0.2,
        ),
        addition: const MineralAddition(),
      );
      expect(pureScale.boilerStatus, BoilerSafetyStatus.scalingRisk);
    });

    test('diagnoses TDS/EC, ISE contaminants (Cl2, NO3-, NH4+, Na+), and E-Tongue channels', () {
      final cleanReport = WaterChemistryEngine.diagnoseSensors(
        const WaterSensorReadings(
          ecUsCm: 156.25, // 100 ppm @ 0.64
          tdsFactor: 0.64,
          freeChlorineMgL: 0.0,
          chlorideMgL: 12.0,
          nitrateMgL: 2.0,
          ammoniumMgL: 0.0,
          sodiumSalinityMgL: 8.0,
          measuredPh: 7.1,
        ),
      );
      expect(cleanReport.tdsPpm, closeTo(100.0, 0.5));
      expect(cleanReport.hasContaminantAlert, isFalse);
      expect(cleanReport.overallScore, greaterThanOrEqualTo(95));
      expect(cleanReport.eTongueChannels.length, 5);

      final dirtyReport = WaterChemistryEngine.diagnoseSensors(
        const WaterSensorReadings(
          ecUsCm: 650,
          tdsFactor: 0.64,
          freeChlorineMgL: 0.5,
          chlorideMgL: 65,
          nitrateMgL: 55,
          ammoniumMgL: 0.9,
          sodiumSalinityMgL: 40,
          measuredPh: 8.3,
        ),
      );
      expect(dirtyReport.hasContaminantAlert, isTrue);
      expect(dirtyReport.iseAlerts.length, greaterThanOrEqualTo(5));
      expect(dirtyReport.overallScore, lessThan(40));
    });
  });

  group('WaterRecipeScreen Mobile-First UI (360px Viewport)', () {
    testWidgets('renders all 3 tabs (Lab Kustom, Deteksi Air, Resep Pro) with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: WaterRecipeScreen()));
      await tester.pumpAndSettle();

      // Tab 1: Lab Kustom
      expect(tester.takeException(), isNull);
      expect(find.text('Lab Kustom'), findsOneWidget);
      expect(find.text('Deteksi Air'), findsOneWidget);
      expect(find.text('Resep Pro'), findsOneWidget);
      expect(find.text('SIMULASI KIMIA AIR REAL-TIME'), findsOneWidget);

      // Switch to Tab 2: Deteksi Air (TDS/EC, ISE, E-Tongue)
      await tester.tap(find.text('Deteksi Air'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('HASIL DETEKSI MULTI-SENSOR AIR'), findsOneWidget);
      expect(find.text('Sensor TDS / Konduktivitas (EC)'), findsOneWidget);

      // Bridge 1-tap from Sensor Tab back to Lab Kustom
      await tester.tap(find.text('Optimasi & Racik Air Ini di Lab Kustom'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Hasil Deteksi Sensor'), findsWidgets);

      // Switch to Tab 3: Resep Pro (formerly had 37px overflow in WaterBufferCard!)
      await tester.tap(find.text('Resep Pro'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Rasio Buffer Kimia (GH:KH)'), findsOneWidget);
    });
  });
}
