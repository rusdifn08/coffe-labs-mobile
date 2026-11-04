import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/models/bean_ai_customization_models.dart';
import 'package:coffee_hub_mobile/models/bean_recommendation_models.dart';
import 'package:coffee_hub_mobile/models/curated_roastery_bean.dart';

void main() {
  group('BeanRecommenderEngine & Models (Smart Brew AI)', () {
    test('calculate returns balanced recipe for Light Washed Ethiopia V60', () {
      final recipe = BeanRecommenderEngine.calculate(
        beanName: 'Ethiopia Yirgacheffe (Heirloom)',
        roast: BeanRoastLevel.light,
        process: BeanProcess.washed,
        goal: FlavorGoal.highAcidity,
        dripper: BeanDripper.v60,
        dose: 15.0,
      );

      expect(recipe.coffeeDose, equals(15.0));
      expect(recipe.totalWater, equals(240.0)); // 1:16 ratio for light washed floral
      expect(recipe.waterTemp, greaterThanOrEqualTo(93));
      expect(recipe.grindMicrons, inInclusiveRange(550, 750));
      expect(recipe.steps.length, greaterThanOrEqualTo(3));
      expect(recipe.expectedAcidity, greaterThanOrEqualTo(4.0));
      expect(recipe.steps.first['title'], contains('Blooming'));

      final recipeMap = recipe.toRecipeMap();
      expect(recipeMap['title'], contains('Ethiopia Yirgacheffe'));
      expect(recipeMap['coffeeWeightGrams'], equals(15));
      expect(recipeMap['totalWaterWeightGrams'], equals(240));
      expect(recipeMap['steps'], isNotEmpty);
    });

    test('calculate adapts grind & temperature for Dark Natural French/Aeropress', () {
      final recipe = BeanRecommenderEngine.calculate(
        beanName: 'Sumatra Mandheling',
        roast: BeanRoastLevel.dark,
        process: BeanProcess.natural,
        goal: FlavorGoal.heavyBody,
        dripper: BeanDripper.aeropress,
        dose: 18.0,
      );

      // Dark roast requires lower temp to avoid harsh bitterness
      expect(recipe.waterTemp, inInclusiveRange(84, 90));
      expect(recipe.expectedBody, greaterThanOrEqualTo(4.0));
      expect(recipe.expectedBitterness, inInclusiveRange(2.0, 3.5));
      expect(recipe.grindMicrons, greaterThan(700));
    });

    test('CuratedRoasteryBean parses all catalog beans with barista intelligence', () {
      final beans = CuratedRoasteryBean.getAllCatalogBeans();
      expect(beans, isNotEmpty);
      expect(beans.length, greaterThanOrEqualTo(200));

      final first = beans.first;
      expect(first.roasteryName, isNotEmpty);
      expect(first.name, isNotEmpty);
      expect(first.tastingNotes, isNotEmpty);
      expect(first.tastingNotesList, isNotEmpty);
      expect(first.baristaOpinion, isNotEmpty);
      expect(first.packageImageUrl, isNotEmpty);
      expect(first.roasteryLogoUrl, isNotEmpty);
      expect(first.soldCount, greaterThan(0));
      expect(first.tempNotesHot, isNotEmpty);
      expect(first.tempNotesWarm, isNotEmpty);
      expect(first.tempNotesCool, isNotEmpty);

      // Verify Serkop Roastery beans have matching Serkop packaging and logo
      final serkopBeans = beans.where((b) => b.roasteryName.contains('Serkop')).toList();
      expect(serkopBeans, isNotEmpty);
      for (final sb in serkopBeans) {
        expect(sb.packageImageUrl, contains('serkop_roastery'));
        expect(sb.roasteryLogoUrl, contains('serkop_roastery'));
      }
    });

    test('Different beans from the same roastery produce distinct sensory radar & notes', () {
      final beans = CuratedRoasteryBean.getAllCatalogBeans();
      final mkndBeans = beans.where((b) => b.roasteryName.toUpperCase().contains('MKND')).toList();
      expect(mkndBeans.length, greaterThanOrEqualTo(2));

      final beanA = mkndBeans.firstWhere((b) => b.name.contains('Excelsa') || b.name.contains('Bali'));
      final beanB = mkndBeans.firstWhere((b) => b != beanA);

      final recipeA = BeanRecommenderEngine.calculate(
        beanName: '${beanA.roasteryName} • ${beanA.name}',
        origin: beanA.origin,
        variety: beanA.variety,
        tastingNotes: beanA.tastingNotesList,
        roast: beanA.roastLevel,
        process: beanA.process,
        goal: FlavorGoal.sweetBalanced,
        dripper: BeanDripper.v60,
        dose: 15.0,
      );

      final recipeB = BeanRecommenderEngine.calculate(
        beanName: '${beanB.roasteryName} • ${beanB.name}',
        origin: beanB.origin,
        variety: beanB.variety,
        tastingNotes: beanB.tastingNotesList,
        roast: beanB.roastLevel,
        process: beanB.process,
        goal: FlavorGoal.sweetBalanced,
        dripper: BeanDripper.v60,
        dose: 15.0,
      );

      // Testing notes must NOT be identical
      expect(recipeA.predictedTastingNotes, isNot(equals(recipeB.predictedTastingNotes)));

      // Sensory profile (radar chart) values must differentiate based on bean characteristics
      final hasDifferentRadar = (recipeA.expectedAcidity != recipeB.expectedAcidity) ||
          (recipeA.expectedSweetness != recipeB.expectedSweetness) ||
          (recipeA.expectedBody != recipeB.expectedBody) ||
          (recipeA.expectedClarity != recipeB.expectedClarity);
      expect(hasDifferentRadar, isTrue, reason: 'Sensory radar chart values must not be identical for different beans');

      // Notes must contain the bean\'s official notes
      expect(recipeA.predictedTastingNotes.any((n) => beanA.tastingNotesList.contains(n)), isTrue);
      expect(recipeB.predictedTastingNotes.any((n) => beanB.tastingNotesList.contains(n)), isTrue);
    });

    test('AI Customization: Tetsu Kasuya 4:6 generates 5 championship pour steps', () {
      final recipe = BeanRecommenderEngine.calculate(
        beanName: 'Fugol Panama Geisha',
        roast: BeanRoastLevel.light,
        process: BeanProcess.washed,
        goal: FlavorGoal.highAcidity,
        dripper: BeanDripper.v60,
        dose: 20.0,
        pouringParadigm: PouringParadigm.tetsu46,
      );

      expect(recipe.steps.length, equals(5));
      expect(recipe.steps[0]['title'], contains('Blooming'));
      expect(recipe.steps[1]['title'], contains('4:6'));
      expect(recipe.steps[2]['title'], contains('4:6'));
      expect(recipe.steps[3]['title'], contains('4:6'));
      expect(recipe.steps[4]['title'], contains('4:6'));
    });

    test('AI Customization: Fresh roast age (< 7 days) gets higher bloom water & time', () {
      final peakRecipe = BeanRecommenderEngine.calculate(
        beanName: 'Ethiopia Yirgacheffe',
        roast: BeanRoastLevel.light,
        process: BeanProcess.washed,
        goal: FlavorGoal.sweetBalanced,
        dripper: BeanDripper.v60,
        dose: 15.0,
        roastAge: BeanRoastAge.peak,
      );

      final freshRecipe = BeanRecommenderEngine.calculate(
        beanName: 'Ethiopia Yirgacheffe',
        roast: BeanRoastLevel.light,
        process: BeanProcess.washed,
        goal: FlavorGoal.sweetBalanced,
        dripper: BeanDripper.v60,
        dose: 15.0,
        roastAge: BeanRoastAge.fresh,
      );

      expect(freshRecipe.bloomWater, greaterThan(peakRecipe.bloomWater));
      expect(freshRecipe.bloomSeconds, greaterThan(peakRecipe.bloomSeconds));
    });

    test('AI Science: AiExtractionScience calculates SCA TDS and Yield within valid ranges', () {
      final science = AiExtractionScience.calculate(
        coffeeDose: 15.0,
        totalWater: 240.0,
        waterTemp: 92,
        grindMicrons: 620,
        roast: BeanRoastLevel.light,
        roastAge: BeanRoastAge.peak,
        water: WaterProfile.scaStandard,
      );

      expect(science.estimatedTds, inInclusiveRange(1.15, 1.55));
      expect(science.estimatedExtractionYield, inInclusiveRange(18.0, 22.5));
      expect(science.goldenCupStatus, isNotEmpty);
      expect(science.targetFlowRate, greaterThan(1.5));
    });
  });
}
