import 'package:coffee_hub_mobile/features/brew/timer/widgets/brew_timer_side_controls.dart';
import 'package:coffee_hub_mobile/features/brew/timer/widgets/circular_brew_timer.dart';
import 'package:coffee_hub_mobile/features/brew/tts/brewing_tts_service.dart';
import 'package:coffee_hub_mobile/models/smart_scale_model.dart';
import 'package:coffee_hub_mobile/screens/brew_timer_screen.dart';
import 'package:coffee_hub_mobile/services/audio_service.dart';
import 'package:coffee_hub_mobile/services/smart_scale_service.dart';
import 'package:coffee_hub_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final sampleRecipe = <String, dynamic>{
    'id': 'test_gesha_v60',
    'title': 'Inovasi Pemecahan Biji Gesha',
    'beanName': 'Ninety Plus Perci Pinnacle Gesha',
    'method': 'V60',
    'coffeeWeightGrams': 20,
    'totalWaterWeightGrams': 300,
    'waterTempCelsius': 92,
    'grindSize': 'Coarse',
    'totalTimeSeconds': 180,
    'steps': [
      {
        'title': 'Blooming',
        'durationSeconds': 30,
        'waterAddedGrams': 60,
        'instruction': 'Tuang 60g air secara merata untuk fase blooming.',
      },
      {
        'title': 'Main Pour',
        'durationSeconds': 150,
        'waterAddedGrams': 240,
        'instruction': 'Tuang 240g air secara spiral stabil hingga 300g.',
      },
    ],
  };

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SmartScaleService.instance.debugResetForTest();
    await AudioService.setBgmEnabled(true);
    AudioService.setMuted(false);
    BrewingTTSService.instance.setEnabled(true);
  });

  tearDown(() async {
    SmartScaleService.instance.debugResetForTest();
    await AudioService.setBgmEnabled(true);
    AudioService.setMuted(false);
    BrewingTTSService.instance.setEnabled(true);
  });

  Color? buttonBgColor(WidgetTester tester, Key key) {
    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(key),
        matching: find.byType(AnimatedContainer),
      ),
    );
    return (container.decoration as BoxDecoration?)?.color;
  }

  group('BrewTimerScreen Redesigned Controls & Menu', () {
    testWidgets(
      'keeps CircularBrewTimer strictly centered, removes connect banner, shows 3 side icon buttons with green/default states, and collapses AppBar actions into 1 menu popup',
      (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: BrewTimerScreen(recipeData: sampleRecipe),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 1. Disconnected "Hubungkan Smart Scale" pill is completely removed
        expect(find.textContaining('Hubungkan Smart Scale'), findsNothing);

        // 2. CircularBrewTimer remains dead-center horizontally (left == right)
        final timerRect = tester.getRect(find.byType(CircularBrewTimer));
        final screenCenterX = 360.0 / 2.0;
        expect(timerRect.center.dx, closeTo(screenCenterX, 0.5));

        // 3. All 3 vertical icon buttons exist on the right side of the timer
        final musicRect = tester.getRect(find.byKey(const Key('brew_side_music_btn')));
        final speaksRect = tester.getRect(find.byKey(const Key('brew_side_speaks_btn')));
        final btRect = tester.getRect(find.byKey(const Key('brew_side_bluetooth_btn')));
        expect(musicRect.left, greaterThanOrEqualTo(timerRect.center.dx));
        expect(speaksRect.top, greaterThan(musicRect.bottom));
        expect(btRect.top, greaterThan(speaksRect.bottom));

        // 4. Unified color states: Music ON = green, Speaks ON = green, Bluetooth disconnected = default white
        expect(buttonBgColor(tester, const Key('brew_side_music_btn')), BrewTimerSideControls.activeGreen);
        expect(buttonBgColor(tester, const Key('brew_side_speaks_btn')), BrewTimerSideControls.activeGreen);
        expect(buttonBgColor(tester, const Key('brew_side_bluetooth_btn')), BrewTimerSideControls.defaultBg);

        // Toggle Music OFF -> default white, does NOT turn off Speaks
        await tester.tap(find.byKey(const Key('brew_side_music_btn')));
        await tester.pumpAndSettle();
        expect(AudioService.isBgmEnabled, isFalse);
        expect(BrewingTTSService.instance.isEnabled, isTrue);
        expect(buttonBgColor(tester, const Key('brew_side_music_btn')), BrewTimerSideControls.defaultBg);
        expect(buttonBgColor(tester, const Key('brew_side_speaks_btn')), BrewTimerSideControls.activeGreen);

        // Toggle Speaks OFF -> default white
        await tester.tap(find.byKey(const Key('brew_side_speaks_btn')));
        await tester.pumpAndSettle();
        expect(BrewingTTSService.instance.isEnabled, isFalse);
        expect(buttonBgColor(tester, const Key('brew_side_speaks_btn')), BrewTimerSideControls.defaultBg);

        // Real BLE scale connects -> Bluetooth button turns GREEN, and reverts to default on disconnect
        SmartScaleService.instance.debugAttachTestDevice(
          const SmartScaleDevice(
            id: 'TM:AA:BB:CC:DD:01',
            name: 'TIMEMORE Black Mirror Dot',
            rssi: -49,
            brand: ScaleBrand.timemore,
          ),
        );
        await tester.pumpAndSettle();
        expect(buttonBgColor(tester, const Key('brew_side_bluetooth_btn')), BrewTimerSideControls.activeGreen);

        SmartScaleService.instance.debugSimulateHardwareDisconnect();
        await tester.pumpAndSettle();
        expect(buttonBgColor(tester, const Key('brew_side_bluetooth_btn')), BrewTimerSideControls.defaultBg);

        // 5. Top AppBar has single 3-line menu button that opens popup with Live Brew, Cetak Struk, Brew Doctor
        expect(find.byKey(const Key('brew_appbar_menu_btn')), findsOneWidget);
        expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
        // Individual top bar icons are no longer directly in the AppBar
        expect(find.byIcon(Icons.qr_code_2_rounded), findsNothing);

        await tester.tap(find.byKey(const Key('brew_appbar_menu_btn')));
        await tester.pumpAndSettle();
        expect(find.text('Live Brew'), findsOneWidget);
        expect(find.text('Cetak Struk'), findsOneWidget);
        expect(find.text('Brew Doctor'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('SmartScaleService Strict Real-Data Integrity', () {
    test('ignores raw weight bytes when disconnected and resets readings to zero on disconnect', () {
      final scale = SmartScaleService.instance;
      expect(scale.isConnected, isFalse);
      expect(scale.currentWeight, 0.0);

      // Feeding bytes while disconnected must have zero effect
      scale.debugFeedRawBytes([0x02, 0x00, 0x03, 0x84, 0x00, 0x00, 0x03]);
      expect(scale.currentWeight, 0.0);
      expect(scale.hasLiveTelemetry, isFalse);

      // Connect real scale and feed valid frame
      scale.debugAttachTestDevice(
        const SmartScaleDevice(
          id: 'TM:01:02:03',
          name: 'TIMEMORE Dot',
          rssi: -52,
          brand: ScaleBrand.timemore,
        ),
      );
      scale.debugFeedRawBytes([0x02, 0x00, 0x03, 0x84, 0x00, 0x00, 0x03]);
      expect(scale.isConnected, isTrue);
      expect(scale.currentWeight, closeTo(90.0, 0.1));
      expect(scale.hasLiveTelemetry, isTrue);

      // Hardware disconnect resets everything cleanly to 0
      scale.debugSimulateHardwareDisconnect();
      expect(scale.isConnected, isFalse);
      expect(scale.currentWeight, 0.0);
      expect(scale.flowRate, 0.0);
      expect(scale.hasLiveTelemetry, isFalse);
    });

    test('parses Decent/DiFluid 0x03CE and Generic ASCII BLE scale frames accurately', () {
      // Decent/DiFluid: 145.6g => 1456 = 0x05B0
      expect(
        SmartScaleService.parseRawWeightBytes(
          [0x03, 0xCE, 0x05, 0xB0, 0x00, 0x00],
          ScaleBrand.generic,
        ),
        closeTo(145.6, 0.01),
      );

      // Generic ASCII UART payload: "+0045.2g\r\n"
      final asciiBytes = '+0045.2g\r\n'.codeUnits;
      expect(
        SmartScaleService.parseRawWeightBytes(asciiBytes, ScaleBrand.generic),
        closeTo(45.2, 0.01),
      );
    });
  });
}
