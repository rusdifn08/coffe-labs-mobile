import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/grinder/models/grinder_models.dart';
import 'package:coffee_hub_mobile/features/water/models/water_profile.dart';
import 'package:coffee_hub_mobile/features/bean_freshness/models/freshness_models.dart';
import 'package:coffee_hub_mobile/features/water/widgets/water_buffer_card.dart';
import 'package:coffee_hub_mobile/features/bean_freshness/widgets/freshness_dial_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Toolkit Deep Upgrades Tests', () {
    test('Grinder Models: 10 commercial grinders & accurate click conversion', () {
      final grinders = GrinderCatalog.getProfiles();
      expect(grinders.length, equals(10));

      // EK43 test
      final ek43 = grinders.firstWhere((g) => g.name.contains('EK43'));
      expect(ek43.calculateSetting(800), equals('Dial 10.3'));

      // Comandante C40 test
      final c40 = grinders.firstWhere((g) => g.name == 'Comandante C40 MK3/MK4');
      expect(c40.calculateSetting(810), equals('25 clicks'));

      // Red Clix (15 micron per click)
      final redClix = grinders.firstWhere((g) => g.name.contains('Red Clix'));
      expect(redClix.calculateSetting(810), equals('50 clicks'));
    });

    test('Bypass Rescue: Calculates required hot water to salvage over-extracted brew', () {
      // 15g coffee brewed to 225g beverage at 1.60% TDS (Over-extracted EY = 24%)
      // Dilution required to bring TDS from 1.60% down to target 1.35%
      final currentBeverageGrams = 200.0;
      final currentTds = 1.60;
      final targetTds = 1.35;

      final targetBeverageGrams = (currentBeverageGrams * currentTds) / targetTds;
      final bypassHotWater = targetBeverageGrams - currentBeverageGrams;

      expect(bypassHotWater, greaterThan(30.0));
      expect(bypassHotWater, lessThan(40.0)); // ~37g hot bypass water
    });

    test('Water Chemistry: GH:KH buffer ratio and sensory diagnosis', () {
      const brightProfile = WaterProfile(
        name: 'Scott Rao Light Roast Clarity',
        origin: 'Low Buffer',
        ghPpm: 85,
        khPpm: 25,
        description: 'High Clarity',
        calciumDropsPerLiter: 3,
        magnesiumDropsPerLiter: 6,
        sodiumDropsPerLiter: 2,
        potassiumDropsPerLiter: 1,
        bakingSodaGramsPerLiter: 0.04,
        epsomSaltGramsPerLiter: 0.21,
        accentColor: Colors.purple,
      );

      expect(brightProfile.bufferRatio, closeTo(3.4, 0.05));
      expect(brightProfile.sensoryDiagnosis, contains('High Clarity & Bright Acidity'));
    });

    test('Bean Freshness: Storage methods & adaptive extraction adjustments', () {
      // Deep freeze vacuum slows aging to 0.15x
      const freezer = StorageMethod.freezerVacuum;
      expect(freezer.agingMultiplier, equals(0.15));

      // Open hopper accelerates staling to 2.5x
      const hopper = StorageMethod.openHopper;
      expect(hopper.agingMultiplier, equals(2.5));

      // Adaptive adjustment for Resting Light roast V60
      final adjResting = BrewAdjustment.calculate(
        stage: FreshnessStage.resting,
        roastLevel: 'Light',
        isEspresso: false,
      );
      expect(adjResting.bloomTimeSeconds, equals(50));
      expect(adjResting.bloomWaterRatio, equals(3.5));
      expect(adjResting.grindAdvice, contains('+1 klik lebih kasar'));
    });

    testWidgets('WaterBufferCard renders GH:KH ratio badge correctly', (tester) async {
      const p = WaterProfile(
        name: 'SCA Standard Water',
        origin: 'SCA',
        ghPpm: 68,
        khPpm: 40,
        description: 'Balanced',
        calciumDropsPerLiter: 4,
        magnesiumDropsPerLiter: 5,
        sodiumDropsPerLiter: 3,
        potassiumDropsPerLiter: 2,
        bakingSodaGramsPerLiter: 0.07,
        epsomSaltGramsPerLiter: 0.17,
        accentColor: Colors.blue,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaterBufferCard(profile: p),
          ),
        ),
      );

      expect(find.text('Rasio Buffer Kimia (GH:KH)'), findsOneWidget);
      expect(find.textContaining('1.7:1'), findsOneWidget);
    });

    testWidgets('FreshnessDialCard renders dynamic bloom and temp correctly', (tester) async {
      const adj = BrewAdjustment(
        bloomTimeSeconds: 45,
        bloomWaterRatio: 3.0,
        recommendedTempC: 93,
        grindAdvice: 'Ideal standard click',
        agitationAdvice: 'Swirl gently',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreshnessDialCard(adjustment: adj, isEspresso: false),
          ),
        ),
      );

      expect(find.text('Kalibrasi Parameter Seduh (Adaptif)'), findsOneWidget);
      expect(find.text('45s'), findsOneWidget);
      expect(find.text('93°C'), findsOneWidget);
    });
  });
}
