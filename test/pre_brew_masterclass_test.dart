import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/masterclass/models/recipe_walkthrough_step.dart';
import 'package:coffee_hub_mobile/features/masterclass/services/masterclass_data_service.dart';

void main() {
  group('Pre-Brew Masterclass Architecture & Models', () {
    test('Resolves WBrC 2026 Sandwich Technique masterclass with double filter steps', () {
      final recipe = {
        'title': 'WBrC 2026 Sandwich Technique',
        'method': 'v60',
        'description': 'Advanced separation technique with fines & coarse sandwich layers.',
      };

      final masterclass = MasterclassDataService.getMasterclassForRecipe(recipe);

      expect(masterclass.title, contains('Sandwich Technique'));
      expect(masterclass.brewerName, contains('WBrC'));
      expect(masterclass.steps.length, greaterThanOrEqualTo(5));

      expect(masterclass.steps[0].phaseName, equals('Persiapan Bubuk'));
      expect(masterclass.steps[0].animationState, equals('fines_separation'));
      expect(masterclass.steps[0].ttsText, contains('fines'));
      expect(masterclass.steps[1].animationState, equals('first_filter'));
      expect(masterclass.steps[2].animationState, equals('fines_bed'));
      expect(masterclass.steps[3].animationState, equals('second_filter'));
      expect(masterclass.steps[4].animationState, equals('coarse_bed'));
    });

    test('Resolves Tetsu Kasuya 4:6 Method masterclass with adjustable pour ratio', () {
      final recipe = {
        'title': 'Tetsu Kasuya 4:6 Method',
        'method': 'v60',
        'description': 'Championship 4:6 balance technique.',
      };

      final masterclass = MasterclassDataService.getMasterclassForRecipe(recipe);

      expect(masterclass.title, contains('4:6 Method'));
      expect(masterclass.brewerName, contains('Tetsu Kasuya'));
      expect(masterclass.steps.length, greaterThanOrEqualTo(4));
      expect(masterclass.steps.any((s) => s.ttsText.contains('40 persen')), isTrue);
      expect(masterclass.steps.any((s) => s.ttsText.contains('60 persen')), isTrue);
    });

    test('Generates distinct method-specific animations for Pour Over, Moka Pot, and Espresso', () {
      final osmoticRecipe = {
        'title': 'Cafec Osmotic Flow V60',
        'method': 'Hario V60',
        'coffeeWeightGrams': 15,
        'totalWaterWeightGrams': 240,
        'waterTempCelsius': 90,
        'grindSize': 'Medium-Coarse 850 µm',
        'steps': [
          {'title': '1. Blooming', 'waterAddedGrams': 45, 'durationSeconds': 30, 'instruction': 'Tuang 45g air 90°C di tengah'},
          {'title': '2. Osmotic Center Pour', 'waterAddedGrams': 105, 'durationSeconds': 55, 'instruction': 'Tuang di tengah kubah'},
        ],
      };

      final mokaRecipe = {
        'title': 'Bialetti Stovetop Crema',
        'method': 'Moka Pot',
        'coffeeWeightGrams': 18,
        'totalWaterWeightGrams': 180,
        'waterTempCelsius': 95,
        'steps': [
          {'title': '1. Pemanasan Kompor', 'waterAddedGrams': 180, 'durationSeconds': 90, 'instruction': 'Panaskan api kecil'},
        ],
      };

      final espressoRecipe = {
        'title': 'Modern Specialty 1:2 Espresso',
        'method': 'Espresso Machine',
        'coffeeWeightGrams': 18,
        'totalWaterWeightGrams': 36,
        'waterTempCelsius': 93,
        'steps': [
          {'title': '1. 9-Bar Extraction', 'waterAddedGrams': 36, 'durationSeconds': 28, 'instruction': 'Ekstraksi 36g'},
        ],
      };

      final osmoticMc = MasterclassDataService.getMasterclassForRecipe(osmoticRecipe);
      final mokaMc = MasterclassDataService.getMasterclassForRecipe(mokaRecipe);
      final espressoMc = MasterclassDataService.getMasterclassForRecipe(espressoRecipe);

      // Verify non-Sandwich recipes do NOT use fines_separation
      expect(osmoticMc.steps[0].animationState, equals('grind_calibrate'));
      expect(osmoticMc.steps[1].animationState, equals('filter_rinse'));
      expect(osmoticMc.steps[2].animationState, equals('bloom_pour'));
      expect(osmoticMc.steps[2].stepWaterGrams, equals(45));
      expect(osmoticMc.steps[3].animationState, equals('osmotic_pour'));
      expect(osmoticMc.steps[3].cumulativeWaterGrams, equals(150));

      // Verify Moka Pot uses moka_boiler_prep and moka_flame_erupt
      expect(mokaMc.steps[0].animationState, equals('moka_boiler_prep'));
      expect(mokaMc.steps[2].animationState, equals('moka_flame_erupt'));

      // Verify Espresso uses espresso_puck_prep and espresso_9bar_shot
      expect(espressoMc.steps[0].animationState, equals('espresso_puck_prep'));
      expect(espressoMc.steps[2].animationState, equals('espresso_9bar_shot'));
    });

    test('RecipeWalkthroughStep copyWith and properties integrity', () {
      const step = RecipeWalkthroughStep(
        stepIndex: 1,
        title: 'Step 1',
        phaseName: 'Phase A',
        ttsText: 'Narration text',
        visualCues: ['Cue 1', 'Cue 2'],
        animationState: 'state_1',
        durationSeconds: 15,
        autoAdvance: true,
        stepWaterGrams: 50,
        cumulativeWaterGrams: 50,
      );

      final updated = step.copyWith(durationSeconds: 20, autoAdvance: false, stepWaterGrams: 60);

      expect(updated.stepIndex, equals(1));
      expect(updated.durationSeconds, equals(20));
      expect(updated.autoAdvance, isFalse);
      expect(updated.stepWaterGrams, equals(60));
    });
  });
}
