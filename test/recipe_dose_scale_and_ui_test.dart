import 'package:coffee_hub_mobile/features/brew/timer/utils/brew_method_helper.dart';
import 'package:coffee_hub_mobile/features/brew/timer/widgets/brew_step_tile.dart';
import 'package:coffee_hub_mobile/features/brew/timer/widgets/segmented_timer_painter.dart';
import 'package:coffee_hub_mobile/features/brew/tts/voice_text_normalizer.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/utils/recipe_dose_scale_utils.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/widgets/recipe_detail_bottom_bar.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/widgets/recipe_steps_list.dart';
import 'package:coffee_hub_mobile/screens/recipe_detail_screen.dart';
import 'package:coffee_hub_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _neoBrewRecipe() => {
      'id': 99,
      'title': 'Metode Multi-Pour Neo Brew (2026)',
      'author': 'Tetsu Kasuya 🇯🇵',
      'beanName': 'Light Roast Single Origin',
      'method': 'Hario V60 / Neo',
      'category': 'V60',
      'waterTempCelsius': 96,
      'grindSize': 'Super Coarse',
      'coffeeWeightGrams': 20,
      'totalWaterWeightGrams': 300,
      'iceWeightGrams': 0,
      'totalTimeSeconds': 210,
      'waterPpm': '70-85 ppm',
      'tastingNotes': 'Floral, Citrus, Tea-Like',
      'description': 'Resep 20g kopi dan 300g air panas suhu 96°C rasio 1:15 dalam 10 tuangan.',
      'steps': [
        {
          'stepOrder': 1,
          'title': 'Blooming',
          'durationSeconds': 30,
          'waterAddedGrams': 30,
          'instruction':
              'Tuang 30g air (96°C) secara merata untuk fase blooming & degassing selama 30s.',
        },
        {
          'stepOrder': 2,
          'title': 'Tuang 2',
          'durationSeconds': 15,
          'waterAddedGrams': 30,
          'instruction':
              'Tuang 30g air secara spiral stabil hingga mencapai total 60g pada timbangan dalam 15s.',
        },
        {
          'stepOrder': 3,
          'title': 'Tuang 3',
          'durationSeconds': 15,
          'waterAddedGrams': 30,
          'instruction':
              'Tuang 30g air secara spiral stabil hingga mencapai total 90g pada timbangan dalam 15s.',
        },
      ],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ApiService.clearMemoryCache();
  });

  group('RecipeDoseScaleUtils & Voice Over Synchronization', () {
    test('scales step instructions, cumulative targets, and description when dose changes 20g -> 12g while preserving temp/time/ratio', () {
      final scaled = RecipeDoseScaleUtils.scaleRecipe(
        _neoBrewRecipe(),
        baseCoffeeGrams: 20,
        scaledCoffeeGrams: 12,
      );

      expect(scaled['coffeeWeightGrams'], 12);
      final steps = scaled['steps'] as List<Map<String, dynamic>>;

      expect(steps[0]['waterAddedGrams'], 18);
      expect(
        steps[0]['instruction'],
        'Tuang 18g air (96°C) secara merata untuk fase blooming & degassing selama 30s.',
      );

      expect(steps[1]['waterAddedGrams'], 18);
      expect(steps[1]['cumulativeWaterGrams'], 36);
      expect(
        steps[1]['instruction'],
        'Tuang 18g air secara spiral stabil hingga mencapai total 36g pada timbangan dalam 15s.',
      );

      expect(steps[2]['waterAddedGrams'], 18);
      expect(steps[2]['cumulativeWaterGrams'], 54);
      expect(
        steps[2]['instruction'],
        'Tuang 18g air secara spiral stabil hingga mencapai total 54g pada timbangan dalam 15s.',
      );

      // Voice Over TTS reads the scaled numbers accurately (never stale 30/60/90)
      final voiceStep1 = VoiceTextNormalizer.buildStepPrompt(
        title: steps[0]['title'] as String,
        instruction: steps[0]['instruction'] as String,
        stepIndex: 0,
        stepWaterGrams: steps[0]['waterAddedGrams'] as int,
        cumulativeWaterGrams: steps[0]['cumulativeWaterGrams'] as int,
        waterTempCelsius: 96,
        durationSeconds: 30,
      );
      expect(voiceStep1, contains('18 gram air'));
      expect(voiceStep1, contains('96 derajat celcius'));
      expect(voiceStep1, isNot(contains('30 gram')));

      final voiceStep2 = VoiceTextNormalizer.buildStepPrompt(
        title: steps[1]['title'] as String,
        instruction: steps[1]['instruction'] as String,
        stepIndex: 1,
        stepWaterGrams: steps[1]['waterAddedGrams'] as int,
        cumulativeWaterGrams: steps[1]['cumulativeWaterGrams'] as int,
        waterTempCelsius: 96,
        durationSeconds: 15,
      );
      expect(voiceStep2, contains('18 gram air'));
      expect(voiceStep2, contains('total 36 gram'));
      expect(voiceStep2, isNot(contains('60 gram')));
    });

    test('protects non-weight values (kg, °C, s, ratios, 0.0g, microns) when scaling', () {
      final result = RecipeDoseScaleUtils.scaleStepInstruction(
        'Giling 20g kopi (900µm), Tare 0.0g, tamp 15–20 kg, tuang 40g air suhu 93°C rasio 1:15 selama 30s hingga 40g.',
        scaleFactor: 0.75,
        baseCoffeeGrams: 20,
        scaledCoffeeGrams: 15,
        baseTotalWater: 300,
        scaledTotalWater: 225,
        origStepWater: 40,
        scaledStepWater: 30,
        origCumulativeWater: 40,
        scaledCumulativeWater: 30,
      );

      expect(
        result,
        'Giling 15g kopi (900µm), Tare 0.0g, tamp 15–20 kg, tuang 30g air suhu 93°C rasio 1:15 selama 30s hingga 30g.',
      );
    });
  });

  group('RecipeDetail UI: Dynamic Step Text, Start Brew Label, Step Colors & Blue Water Text', () {
    testWidgets(
      'Changing dose to 12g updates step descriptions, keeps Start Brew clean, matches timer step colors, and keeps water text blue',
      (tester) async {
        tester.view.physicalSize = const Size(375, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: RecipeDetailScreen(recipeData: _neoBrewRecipe()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Tap 12g preset button
        await tester.tap(find.text('12g'));
        await tester.pumpAndSettle();

        // Bottom CTA button remains strictly 'Start Brew' (no '12g → ...')
        expect(
          find.descendant(
            of: find.byType(RecipeDetailBottomBar),
            matching: find.text('Start Brew'),
          ),
          findsOneWidget,
        );
        expect(find.textContaining('Start Brew ('), findsNothing);

        // Scroll to step list and verify scaled step descriptions
        final verticalScrollable = find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        );
        await tester.scrollUntilVisible(
          find.text('Blooming'),
          250,
          scrollable: verticalScrollable.first,
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Tuang 18g air (96°C) secara merata untuk fase blooming & degassing selama 30s.'),
          findsOneWidget,
        );
        expect(find.textContaining('Tuang 30g'), findsNothing);

        await tester.scrollUntilVisible(
          find.text('Tuang 2'),
          250,
          scrollable: verticalScrollable.first,
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Tuang 18g air secara spiral stabil hingga mencapai total 36g pada timbangan dalam 15s.'),
          findsOneWidget,
        );

        // Verify step number colors match BrewTimerScreen (getColorForStep)
        final step1NumText = tester.widget<Text>(
          find.descendant(of: find.byType(RecipeStepsList), matching: find.text('1')).first,
        );
        final step2NumText = tester.widget<Text>(
          find.descendant(of: find.byType(RecipeStepsList), matching: find.text('2')).first,
        );
        expect(step1NumText.style?.color, getColorForStep(0));
        expect(step2NumText.style?.color, getColorForStep(1));

        // Verify water text stays blueAccent
        final waterTextWidget = tester.widget<Text>(
          find.text('+18g Air (Target: 36g)').first,
        );
        expect(waterTextWidget.style?.color, Colors.blueAccent);
      },
    );

    testWidgets('BrewStepTile keeps water action text blueAccent when inactive', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrewStepTile(
              index: 1,
              step: const {
                'title': 'Tuang 2',
                'instruction': 'Tuang 18g air hingga total 36g.',
              },
              isActive: false,
              isDone: false,
              stepWater: 18,
              stepDur: 15,
              startSec: 30,
              endSec: 45,
              cumulativeTarget: 36,
              stepColor: getColorForStep(1),
              onTap: () {},
              formatTime: (s) => '00:${s.toString().padLeft(2, '0')}',
              methodFamily: BrewMethodFamily.pourOver,
            ),
          ),
        ),
      );

      final actionText = tester.widget<Text>(find.text('+18g Air (Target: 36g)'));
      expect(actionText.style?.color, Colors.blueAccent);
    });
  });
}
