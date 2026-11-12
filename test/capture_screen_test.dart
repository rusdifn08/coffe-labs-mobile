import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/brew/timer/widgets/circular_brew_timer.dart';
import 'package:coffee_hub_mobile/features/brew/timer/widgets/brew_step_tile.dart';
import 'package:coffee_hub_mobile/features/brew/timer/widgets/brew_spec_header_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture Pixel-Perfect Coffee Labs Mobile Brew Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);

    final recipe = {
      'id': 'bayu_prawiro_triangle',
      'title': 'The Extraction Triangle',
      'beanName': '70% Panama Geisha + 20% Anaerobic + 10% Sumedang',
      'author': 'Bayu Prawiro (Runner-Up WBrC 2025)',
      'method': 'Hario Switch + Drip Assist',
      'category': 'Filter Drip Assist',
      'grindSize': 'Medium-Coarse 850 µm',
      'coffeeWeightGrams': 15,
      'totalWaterWeightGrams': 220,
      'waterTempCelsius': 93,
      'iceWeightGrams': 0,
      'steps': [
        {
          'title': '0:00 (Buka) 40g Air 93°C - Aperture Bloom',
          'durationSeconds': 40,
          'waterAddedGrams': 40,
          'instruction': 'Katup Switch OPEN. Tuang 40g air 93°C via Drip Assist untuk ekstraksi asam bunga.',
        },
        {
          'title': '0:40 (Tutup) +80g Air 88°C - Shutter Immersion I',
          'durationSeconds': 40,
          'waterAddedGrams': 80,
          'instruction': 'Katup Switch CLOSED. Tuang +80g air 88°C (total 120g). Rendam imersi hingga 1:20.',
        },
        {
          'title': '1:20 (Tutup) +100g Air 88°C - ISO Immersion II',
          'durationSeconds': 40,
          'waterAddedGrams': 100,
          'instruction': 'Katup Switch CLOSED. Tuang +100g air 88°C (total 220g). Imersi hingga 2:00 kunci sweetness.',
        },
        {
          'title': '2:00 (Buka) Tiris Drawdown s/d 2:20 - Release',
          'durationSeconds': 20,
          'waterAddedGrams': 0,
          'instruction': 'Buka katup Switch ke OPEN di 2:00. Tiriskan tuntas ke server hingga 2:20.',
        },
      ],
    };

    final steps = recipe['steps'] as List<Map<String, dynamic>>;

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF9F6F0),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6B4423),
            secondary: Color(0xFFECA400),
            surface: Colors.white,
          ),
        ),
        home: Scaffold(
          backgroundColor: const Color(0xFFF9F6F0),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF9F6F0),
            elevation: 0,
            leading: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF332B25), size: 22),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coffee Labs Brew Timer',
                  style: TextStyle(
                    color: Color(0xFF332B25),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'The Extraction Triangle • Bayu Prawiro 🏆',
                  style: TextStyle(
                    color: Color(0xFF6B4423),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECA400).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFECA400)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.scale, size: 16, color: Color(0xFF6B4423)),
                    SizedBox(width: 4),
                    Text(
                      'SCALE 120.0g',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B4423),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Spec header
                  BrewSpecHeaderBar(
                    recipe: recipe,
                    onMuteToggled: () {},
                  ),
                  const SizedBox(height: 24),

                  // Circular Timer
                  CircularBrewTimer(
                    steps: steps,
                    totalSeconds: 140,
                    elapsedSeconds: 38,
                    isPreparing: false,
                    prepSeconds: 0,
                    activeTargetWater: 120,
                    isEndingSoon: false,
                    onSkipCountdown: () {},
                    formatTime: (s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 24),

                  // Steps list
                  BrewStepTile(
                    index: 0,
                    step: steps[0],
                    isActive: true,
                    isDone: false,
                    stepWater: 120,
                    stepDur: 80,
                    startSec: 0,
                    endSec: 80,
                    cumulativeTarget: 120,
                    stepColor: const Color(0xFFECA400),
                    onTap: () {},
                    formatTime: (s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}',
                  ),
                  BrewStepTile(
                    index: 1,
                    step: steps[1],
                    isActive: false,
                    isDone: false,
                    stepWater: 100,
                    stepDur: 40,
                    startSec: 80,
                    endSec: 120,
                    cumulativeTarget: 220,
                    stepColor: const Color(0xFF9A7B4F),
                    onTap: () {},
                    formatTime: (s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}',
                  ),
                  BrewStepTile(
                    index: 2,
                    step: steps[2],
                    isActive: false,
                    isDone: false,
                    stepWater: 0,
                    stepDur: 20,
                    startSec: 120,
                    endSec: 140,
                    cumulativeTarget: 220,
                    stepColor: const Color(0xFF6B4423),
                    onTap: () {},
                    formatTime: (s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/bayu_brew_timer_screen.png'),
    );
  });
}
