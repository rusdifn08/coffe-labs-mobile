import 'package:coffee_hub_mobile/features/brew_methods/models/brew_method_item.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/domain/active_long_brew_batch.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/domain/arrhenius_coldbrew_calculator.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/domain/brew_archetype.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/presentation/controllers/cold_brew_alarm_hub_controller.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/presentation/screens/cold_brew_and_drip_studio_screen.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/presentation/screens/flash_chill_iced_brew_screen.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/presentation/screens/sca_cupping_multi_bowl_screen.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/presentation/screens/steep_and_release_immersion_screen.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/presentation/screens/thermal_cue_brewer_screen.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/presentation/widgets/active_cold_brew_floating_banner.dart';
import 'package:coffee_hub_mobile/features/multi_method_brewing/presentation/widgets/cold_brew_alarm_ringing_modal.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/widgets/recipe_detail_bottom_bar.dart';
import 'package:coffee_hub_mobile/features/recipe_feed/utils/recipe_filter_matcher.dart';
import 'package:coffee_hub_mobile/services/seed_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('18-Method Visual & Seed Data Audit', () {
    test('Cold Brew & Syphon have dedicated assets and all 18 filterKeys match recipes', () {
      expect(BrewMethodItem.allMethods.length, equals(18));
      final syphon = BrewMethodItem.allMethods.firstWhere((e) => e.id == 'syphon');
      final coldBrew = BrewMethodItem.allMethods.firstWhere((e) => e.id == 'cold_brew');
      expect(syphon.imageAsset, equals('assets/images/methods/syphon.png'));
      expect(coldBrew.imageAsset, equals('assets/images/methods/cold_brew.png'));

      final allSeeds = SeedData.getDefaultRecipes();
      expect(allSeeds.length, equals(478));
      for (final item in BrewMethodItem.allMethods) {
        final matched = allSeeds
            .where((r) => RecipeFilterMatcher.matchesMethod(r, item.filterKey))
            .toList();
        expect(
          matched,
          isNotEmpty,
          reason: 'Method ${item.id} (${item.filterKey}) returned zero matching recipes',
        );
      }
    });

    test('All 478 recipes pass strict water & time step sums and preserve V60 champions', () {
      final allSeeds = SeedData.getDefaultRecipes();
      for (final r in allSeeds) {
        final id = r['id'];
        final totalW = (r['totalWaterWeightGrams'] as num).toDouble();
        final totalT = (r['totalTimeSeconds'] as num).toDouble();
        final steps = (r['steps'] as List).cast<Map>();
        final stepW = steps.fold<double>(
          0,
          (acc, s) => acc + ((s['waterAddedGrams'] as num?)?.toDouble() ?? 0),
        );
        final stepT = steps.fold<double>(
          0,
          (acc, s) => acc + ((s['durationSeconds'] as num?)?.toDouble() ?? 0),
        );
        expect(
          (stepW - totalW).abs(),
          lessThanOrEqualTo(0.1),
          reason: 'Recipe $id step water sum $stepW != $totalW',
        );
        expect(
          (stepT - totalT).abs(),
          lessThanOrEqualTo(0.1),
          reason: 'Recipe $id step time sum $stepT != $totalT',
        );

        final cls = MethodArchetypeMapper.classify(r);
        if (cls.isColdBrewAlarmOnly) {
          expect(
            totalT,
            greaterThanOrEqualTo(21600),
            reason: 'Cold Brew ID=$id should reflect realistic hours (>=21600s)',
          );
        }
      }

      // Verifikasi resep juara dunia V60 tetap utuh tanpa perubahan
      final kasuya46 = allSeeds.firstWhere((r) => r['id'] == 4);
      expect(kasuya46['coffeeWeightGrams'], equals(20));
      expect(kasuya46['totalWaterWeightGrams'], equals(300));
      expect(kasuya46['totalTimeSeconds'], equals(210));
      expect(MethodArchetypeMapper.classify(kasuya46).isProtectedV60, isTrue);

      final oddSteinar = allSeeds.firstWhere((r) => r['id'] == 1);
      expect(oddSteinar['method'], equals('Hario V60'));
      expect(MethodArchetypeMapper.classify(oddSteinar).isProtectedV60, isTrue);

      final kyotoIcedV60 = allSeeds.firstWhere((r) => r['id'] == 148);
      final kyotoCls = MethodArchetypeMapper.classify(kyotoIcedV60);
      expect(kyotoCls.isProtectedV60, isTrue);
      expect(kyotoCls.isColdBrewAlarmOnly, isFalse);

      final kyotoLatte = allSeeds.firstWhere((r) => r['id'] == 524);
      final latteCls = MethodArchetypeMapper.classify(kyotoLatte);
      expect(latteCls.archetype, equals(BrewExecutionArchetype.subSecondPressureEspresso));
      expect(latteCls.isColdBrewAlarmOnly, isFalse);

      // Verifikasi perbaikan juara non-V60 & cupping SCA 15 menit
      final wallgren = allSeeds.firstWhere((r) => r['id'] == 5);
      expect(wallgren['totalTimeSeconds'], equals(155));
      expect(wallgren['steps'][0]['waterAddedGrams'], equals(30));

      final scaCupping = allSeeds.firstWhere((r) => r['id'] == 343);
      expect(scaCupping['totalTimeSeconds'], equals(900));
    });
  });

  group('Archetype Classifier & Cold Brew Arrhenius Physics', () {
    test('Maps all archetypes accurately while protecting V60 and isolating Cold Brew', () {
      final cb = MethodArchetypeMapper.classify({
        'method': 'Cold Brew',
        'category': 'Cold Brew',
        'title': 'Toddy 16h',
      });
      expect(cb.archetype, equals(BrewExecutionArchetype.longHorizonPersistentAlarm));
      expect(cb.isColdBrewAlarmOnly, isTrue);

      final v60 = MethodArchetypeMapper.classify({
        'method': 'Hario V60',
        'category': 'V60 Pour Over',
        'title': '4:6 Method',
      });
      expect(v60.archetype, equals(BrewExecutionArchetype.percolationPourOver));
      expect(v60.isProtectedV60, isTrue);
      expect(v60.isColdBrewAlarmOnly, isFalse);

      final jap = MethodArchetypeMapper.classify({
        'method': 'Bee House Dripper',
        'category': 'Japanese Iced',
        'iceWeightGrams': 100,
      });
      expect(jap.archetype, equals(BrewExecutionArchetype.flashChillIcedFilter));

      final moka = MethodArchetypeMapper.classify({
        'method': 'Moka Pot',
        'category': 'Moka Pot',
      });
      expect(moka.archetype, equals(BrewExecutionArchetype.thermalCuePhaseBrewer));

      final cup = MethodArchetypeMapper.classify({
        'method': 'Cupping Bowl',
        'category': 'Cupping',
      });
      expect(cup.archetype, equals(BrewExecutionArchetype.steepAndReleaseImmersion));
      expect(cup.immersionSubMethod, equals(ImmersionSubMethod.cuppingBowl));
    });

    test('Arrhenius Q10=1.48 and Kyoto BPM durations calculate accurately', () {
      final fridge =
          ArrheniusColdBrewCalculator.calculateImmersionDuration(tempCelsius: 4);
      final room =
          ArrheniusColdBrewCalculator.calculateImmersionDuration(tempCelsius: 22);
      expect(fridge.inHours, greaterThan(room.inHours));
      expect(fridge.inHours, greaterThanOrEqualTo(18));

      final kyoto = ArrheniusColdBrewCalculator.calculateKyotoDripDuration(
        waterMl: 500,
        dripRateBpm: 40,
      );
      expect(kyoto.inSeconds, greaterThanOrEqualTo(14400));
      expect(ArrheniusColdBrewCalculator.dripIntervalMs(40), equals(1500));

      final dilution = ArrheniusColdBrewCalculator.calculateDilution(
        coffeeDoseG: 60,
        waterMl: 480,
      );
      expect(dilution.brewRatioLabel, equals('1:8.0'));
      expect(dilution.concentrateYieldMl, greaterThan(0));
      expect(dilution.suggestedDilutionMl, greaterThan(0));
    });
  });

  group('Multi-Archetype UI & Cold Brew OS Alarm Workflow at 375x780', () {
    testWidgets('Bottom bar shows Pasang Alarm Cold Brew for Cold Brew and Start Brew for V60', (tester) async {
      tester.view.physicalSize = const Size(375, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RecipeDetailBottomBar(
                  scaledRecipe: const {'method': 'Cold Brew', 'category': 'Cold Brew'},
                  scaledCoffeeGrams: 50,
                  baseCoffeeGrams: 50,
                  coffeeWeight: 50,
                  totalWater: 500,
                  onStartBrew: () {},
                ),
                RecipeDetailBottomBar(
                  scaledRecipe: const {'method': 'Hario V60', 'category': 'V60 Pour Over'},
                  scaledCoffeeGrams: 15,
                  baseCoffeeGrams: 15,
                  coffeeWeight: 15,
                  totalWater: 250,
                  onStartBrew: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Pasang Alarm Cold Brew'), findsOneWidget);
      expect(find.text('Start Brew'), findsOneWidget);
    });

    testWidgets('ColdBrewAndDripStudioScreen renders step-by-step & schedules alarm banner cleanly', (tester) async {
      tester.view.physicalSize = const Size(375, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coldRecipe = {
        'id': 446,
        'title': 'Toddy 16h Concentrate',
        'method': 'Cold Brew',
        'category': 'Cold Brew',
        'coffeeWeightGrams': 80,
        'totalWaterWeightGrams': 640,
        'waterTempCelsius': 4,
        'totalTimeSeconds': 57600,
        'steps': [
          {'stepOrder': 1, 'title': 'Campur Kopi', 'waterAddedGrams': 640, 'durationSeconds': 60, 'instruction': 'Tuang rata.'},
        ],
      };

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ColdBrewAndDripStudioScreen(recipe: coldRecipe),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('MODE STEP-BY-STEP + ALARM OS'), findsOneWidget);
      expect(find.textContaining('Mulai & Pasang Alarm'), findsOneWidget);

      await tester.ensureVisible(find.textContaining('Mulai & Pasang Alarm'));
      await tester.tap(find.textContaining('Mulai & Pasang Alarm'));
      await tester.pumpAndSettle();

      // Verifikasi banner beranda menampilkan batch aktif dan modal dapat dibuka tanpa overflow
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(coldBrewAlarmHubProvider.notifier).hydrate();
      final loaded = container.read(coldBrewAlarmHubProvider);
      expect(loaded, isNotEmpty);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const ActiveColdBrewFloatingBanner(),
                  Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () {
                        ColdBrewAlarmRingingModal.show(
                          context,
                          loaded.first.copyWith(status: 'RINGING'),
                        );
                      },
                      child: const Text('Inspect Modal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('Toddy 16h Concentrate'), findsOneWidget);

      await tester.tap(find.text('Inspect Modal'));
      await tester.pumpAndSettle();
      expect(find.text('Selesai & Saring'), findsOneWidget);
      expect(find.text('Snooze +15m'), findsOneWidget);

      // Verifikasi jadwal alarm langsung via ActiveLongBrewBatch model
      final dueBatch = ActiveLongBrewBatch(
        id: 'due_1',
        recipeTitle: 'Due Test',
        methodSlug: 'cold_brew',
        brewMode: 'IMMERSION_FRIDGE',
        coffeeDoseG: 60,
        waterMl: 480,
        ambientTempC: 4,
        startedAt: DateTime.now().subtract(const Duration(hours: 17)),
        targetFinishAt: DateTime.now().subtract(const Duration(minutes: 1)),
        totalDurationSec: 57600,
      );
      expect(dueBatch.isDueAt(DateTime.now()), isTrue);
    });

    testWidgets('All non-Cold-Brew archetype screens render without overflow at 375x780', (tester) async {
      tester.view.physicalSize = const Size(375, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FlashChillIcedBrewScreen(
              recipe: {
                'title': 'Bonmac Iced Stone Fruit',
                'coffeeWeightGrams': 18,
                'totalWaterWeightGrams': 190,
                'iceWeightGrams': 110,
              },
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('110 g'), findsOneWidget);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SteepAndReleaseImmersionScreen(
              recipe: {
                'title': 'WAC 2018 Inverted',
                'coffeeWeightGrams': 34.9,
                'totalWaterWeightGrams': 200,
              },
              subMethod: ImmersionSubMethod.aeropress,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('Peringatan Keamanan Inverted'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: ThermalCueBrewerScreen(
            recipe: {'title': 'Moka Pot Classics'},
            subMethod: ThermalCueSubMethod.mokaPot,
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('Matikan Api Sebelum Sputtering'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: ScaCuppingMultiBowlScreen(
            recipe: {'title': 'SCA Standard Cupping'},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('00:00 / 15:00'), findsOneWidget);
      expect(find.textContaining('Final:'), findsOneWidget);
    });
  });
}
