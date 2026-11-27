import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_hub_mobile/features/bean_dial_in/widgets/roastery_bean_picker_modal.dart';
import 'package:coffee_hub_mobile/features/home/widgets/home_bean_recommender_banner.dart';
import 'package:coffee_hub_mobile/models/bean_ai_customization_models.dart';
import 'package:coffee_hub_mobile/models/bean_recommendation_models.dart';
import 'package:coffee_hub_mobile/models/curated_roastery_bean.dart';
import 'package:coffee_hub_mobile/screens/bean_recipe_recommender_screen.dart';

CuratedRoasteryBean _sampleBean({
  required String id,
  required String roasteryName,
  required String name,
  String origin = 'Ethiopia Yirgacheffe',
  BeanRoastLevel roast = BeanRoastLevel.light,
  BeanProcess process = BeanProcess.washed,
  String variety = 'Geisha',
  String tastingNotes = 'Jasmine, Bergamot, White Peach',
}) {
  return CuratedRoasteryBean(
    id: id,
    roasteryName: roasteryName,
    roasteryLocation: 'Bandung, ID',
    roasteryImageUrl: 'assets/images/placeholder_coffee.png',
    roasteryLogoUrl: 'assets/images/placeholder_coffee.png',
    packageImageUrl: 'assets/images/placeholder_coffee.png',
    name: name,
    origin: origin,
    roastProfileRaw: roast.label,
    roastLevel: roast,
    processRaw: process.label,
    process: process,
    variety: variety,
    tastingNotes: tastingNotes,
    tastingNotesList: tastingNotes.split(',').map((e) => e.trim()).toList(),
    originalPackage: '200g',
    soldCount: 120,
    recommendedDripper: BeanDripper.v60,
    baristaOpinion: 'Cocok diseduh manual pour-over dengan air lembut standar SCA.',
    tempNotesHot: 'Floral jasmine',
    tempNotesWarm: 'Bergamot & peach',
    tempNotesCool: 'Honey tea clean finish',
  );
}

void main() {
  group('BeanRecommenderEngine — International SCA / WBC Intelligence', () {
    test('calibrates Light Roast Washed Geisha with high extraction clarity & multi-grinder clicks', () {
      final recipe = BeanRecommenderEngine.calculate(
        beanName: 'Ethiopia Yirgacheffe Geisha',
        origin: 'Ethiopia',
        variety: 'Geisha',
        tastingNotes: const ['Jasmine', 'Bergamot', 'White Peach'],
        roast: BeanRoastLevel.light,
        process: BeanProcess.washed,
        goal: FlavorGoal.highAcidity,
        dripper: BeanDripper.v60,
        dose: 15.0,
      );

      expect(recipe.waterTemp, inInclusiveRange(93, 96));
      expect(recipe.grindMicrons, inInclusiveRange(500, 660));
      expect(recipe.iceWeightGrams, 0);
      expect(recipe.hotWaterGrams, recipe.totalWater.round());
      expect(recipe.roastGuidanceSummary, isNotEmpty);
      expect(recipe.recommendedWaterChemistry, contains('ppm'));
      expect(recipe.agitationGuidance, isNotEmpty);
      expect(recipe.recommendedRestWindow, isNotEmpty);
      expect(recipe.estimatedDrawdownRange, isNotEmpty);
      expect(recipe.internationalBrewTips.length, greaterThanOrEqualTo(3));
      expect(recipe.grindClickLabel, contains('C40'));
      expect(recipe.grindClickLabel, contains('K-Ultra'));
      expect(recipe.grindClickLabel, contains('Ode 2'));
    });

    test('compensates Anaerobic Natural with lower water temperature to avoid astringency', () {
      final washedLight = BeanRecommenderEngine.calculate(
        beanName: 'Kenya SL28',
        origin: 'Kenya',
        variety: 'SL28',
        roast: BeanRoastLevel.light,
        process: BeanProcess.washed,
        goal: FlavorGoal.sweetBalanced,
        dripper: BeanDripper.v60,
        dose: 15.0,
      );
      final anaerobic = BeanRecommenderEngine.calculate(
        beanName: 'Gayo Thermal Shock Anaerobic',
        origin: 'Aceh Gayo',
        variety: 'Abyssinia',
        roast: BeanRoastLevel.mediumLight,
        process: BeanProcess.anaerobic,
        goal: FlavorGoal.sweetBalanced,
        dripper: BeanDripper.v60,
        dose: 15.0,
      );

      expect(anaerobic.waterTemp, lessThan(washedLight.waterTemp));
      expect(anaerobic.waterTemp, lessThanOrEqualTo(91));
      expect(anaerobic.grindMicrons, greaterThan(washedLight.grindMicrons));
    });

    test('calibrates Dark Roast with low temperature, coarser grind & tighter ratio', () {
      final dark = BeanRecommenderEngine.calculate(
        beanName: 'Mandheling Classic Dark',
        origin: 'Sumatra',
        roast: BeanRoastLevel.dark,
        process: BeanProcess.wetHulled,
        goal: FlavorGoal.heavyBody,
        dripper: BeanDripper.kalita,
        dose: 15.0,
      );

      expect(dark.waterTemp, inInclusiveRange(82, 88));
      expect(dark.grindMicrons, greaterThanOrEqualTo(680));
      expect(dark.brewRatio, lessThanOrEqualTo(14.5));
      expect(dark.recommendedParadigm, PouringParadigm.osmoticFlow);
    });

    test('computes Japanese Iced 60% hot water + 40% ice with finer grind & ice step guidance', () {
      final hot = BeanRecommenderEngine.calculate(
        beanName: 'Puntang Washed',
        origin: 'Java Puntang',
        roast: BeanRoastLevel.light,
        process: BeanProcess.washed,
        goal: FlavorGoal.sweetBalanced,
        dripper: BeanDripper.v60,
        dose: 15.0,
      );
      final iced = BeanRecommenderEngine.calculate(
        beanName: 'Puntang Washed',
        origin: 'Java Puntang',
        roast: BeanRoastLevel.light,
        process: BeanProcess.washed,
        goal: FlavorGoal.japaneseIced,
        dripper: BeanDripper.v60,
        dose: 15.0,
      );

      expect(iced.iceWeightGrams, greaterThan(0));
      expect(iced.hotWaterGrams + iced.iceWeightGrams, iced.totalWater.round());
      expect(iced.grindMicrons, lessThan(hot.grindMicrons));
      expect(iced.toRecipeMap()['category'], 'Japanese Iced');
      expect(iced.toRecipeMap()['iceWeightGrams'], iced.iceWeightGrams);
      expect(iced.steps.isNotEmpty, isTrue);
      expect(
        iced.steps.first['instruction'].toString().toLowerCase(),
        contains('es'),
      );
    });
  });

  group('Smart Brew UI Flow — Non-Auto-Select, Roastery-First Picker & Clean Copy', () {
    testWidgets('BeanRecipeRecommenderScreen starts with NO catalog bean auto-selected', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BeanRecipeRecommenderScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Belum Ada Biji Kopi Dipilih'), findsOneWidget);
      expect(find.text('Pilih Roastery & Biji Kopi'), findsAtLeastNWidgets(1));
      expect(find.text('Mulai Seduh'), findsNothing);
    });

    testWidgets('RoasteryBeanPickerModal enforces Step 1 Roastery -> Step 2 Beans -> Step 3 Preview -> Confirm', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      final beans = [
        _sampleBean(
          id: 'b1',
          roasteryName: 'Fugol Coffee Roasters',
          name: 'Ethiopia Yirgacheffe Geisha',
        ),
        _sampleBean(
          id: 'b2',
          roasteryName: 'Fugol Coffee Roasters',
          name: 'Kenya Nyeri SL28',
          origin: 'Kenya',
          variety: 'SL28',
        ),
        _sampleBean(
          id: 'b3',
          roasteryName: 'Space Roastery',
          name: 'Gayo Anaerobic Natural',
          origin: 'Aceh Gayo',
          roast: BeanRoastLevel.mediumLight,
          process: BeanProcess.anaerobic,
          variety: 'Abyssinia',
          tastingNotes: 'Blackberry, Winey, Cacao',
        ),
      ];

      CuratedRoasteryBean? chosen;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  RoasteryBeanPickerModal.show(
                    context: context,
                    allBeans: beans,
                    selectedBean: null,
                    onBeanSelected: (b) => chosen = b,
                  );
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Step 1: Roastery Directory — roasteries shown, individual beans NOT dumped yet
      expect(find.text('Fugol Coffee Roasters'), findsOneWidget);
      expect(find.text('Space Roastery'), findsOneWidget);
      expect(find.text('Ethiopia Yirgacheffe Geisha'), findsNothing);
      expect(find.text('Gayo Anaerobic Natural'), findsNothing);

      // Tap Fugol Coffee Roasters -> Step 2: ONLY Fugol's beans shown
      await tester.tap(find.text('Fugol Coffee Roasters'));
      await tester.pumpAndSettle();

      expect(find.text('Ethiopia Yirgacheffe Geisha'), findsOneWidget);
      expect(find.text('Kenya Nyeri SL28'), findsOneWidget);
      expect(find.text('Gayo Anaerobic Natural'), findsNothing);

      // Tap bean card -> Step 3: Detail Preview before confirming
      await tester.tap(find.text('Ethiopia Yirgacheffe Geisha'));
      await tester.pumpAndSettle();

      expect(find.text('Gunakan Biji Ini untuk Smart Brew'), findsOneWidget);
      expect(chosen, isNull);

      // Confirm selection
      await tester.tap(find.text('Gunakan Biji Ini untuk Smart Brew'));
      await tester.pumpAndSettle();

      expect(chosen, isNotNull);
      expect(chosen!.id, 'b1');
    });

    testWidgets('HomeBeanRecommenderBanner displays Pilih Biji without hardcoded 230+ count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HomeBeanRecommenderBanner(isEn: false),
                HomeBeanRecommenderBanner(isEn: true),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Pilih Biji'), findsOneWidget);
      expect(find.text('Pick Bean'), findsOneWidget);
      expect(find.textContaining('230'), findsNothing);
    });
  });
}
