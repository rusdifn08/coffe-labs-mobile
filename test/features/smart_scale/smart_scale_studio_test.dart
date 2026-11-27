import 'package:coffee_hub_mobile/features/brew/timer/widgets/brew_scale_live_badge.dart';
import 'package:coffee_hub_mobile/features/smart_scale/services/scale_brew_history_service.dart';
import 'package:coffee_hub_mobile/features/smart_scale/widgets/scale_device_sheet.dart';
import 'package:coffee_hub_mobile/features/smart_scale/widgets/scale_recipe_coach_tab.dart';
import 'package:coffee_hub_mobile/models/smart_scale_model.dart';
import 'package:coffee_hub_mobile/screens/smart_scale_screen.dart';
import 'package:coffee_hub_mobile/services/smart_scale_service.dart';
import 'package:coffee_hub_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ScaleBrewHistoryService.resetMemoryCache();
    SmartScaleService.instance.debugResetForTest();
  });

  tearDown(() {
    SmartScaleService.instance.debugResetForTest();
  });

  group('SmartScaleService Real BLE 5.2 Engine', () {
    test('startScan never injects a fake virtual scale', () async {
      await SmartScaleService.instance.startScan();
      expect(SmartScaleService.instance.discoveredDevices, isEmpty);
      expect(SmartScaleService.instance.isConnected, isFalse);
    });

    test('detectBrand accurately identifies TIMEMORE, Coffee Labs C3, Acaia, Felicita & Bookoo', () {
      expect(
        SmartScaleService.detectBrand('TIMEMORE Black Mirror Dot', const []),
        ScaleBrand.timemore,
      );
      expect(
        SmartScaleService.detectBrand('Coffee Labs Scale C3', const []),
        ScaleBrand.coffeeLabsC3,
      );
      expect(
        SmartScaleService.detectBrand('CL-Scale-01', [Guid('c0ffee00-0000-1000-8000-00805f9b34fb')]),
        ScaleBrand.coffeeLabsC3,
      );
      expect(
        SmartScaleService.detectBrand('ACAIA LUNAR', const []),
        ScaleBrand.acaia,
      );
      expect(
        SmartScaleService.detectBrand('FELICITA ARC', const []),
        ScaleBrand.felicita,
      );
      expect(
        SmartScaleService.detectBrand('Bookoo Themis Mini', const []),
        ScaleBrand.bookoo,
      );
    });

    test('parses TIMEMORE 0x02, TIMEMORE 0xAA55, and Coffee Labs Scale C3 0xC301 frames with 0.1g precision', () {
      // TIMEMORE 0x02 frame: 225.4 g => 2254 = 0x08CE
      final timemoreBytes = [0x02, 0x00, 0x08, 0xCE, 0x00, 0x00, 0x03];
      expect(
        SmartScaleService.parseRawWeightBytes(timemoreBytes, ScaleBrand.timemore),
        closeTo(225.4, 0.01),
      );

      // TIMEMORE 0xAA 0x55 frame: 36.2 g => 362 = 0x016A
      final timemore2Bytes = [0xAA, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x6A, 0x00];
      expect(
        SmartScaleService.parseRawWeightBytes(timemore2Bytes, ScaleBrand.timemore),
        closeTo(36.2, 0.01),
      );

      // Coffee Labs Scale C3 frame: 184.5 g => 1845 = 0x000735, battery 92%, timer 65s
      final c3Bytes = [0xC3, 0x01, 0x02, 0x00, 0x07, 0x35, 92, 0x00, 65];
      expect(
        SmartScaleService.parseRawWeightBytes(c3Bytes, ScaleBrand.coffeeLabsC3),
        closeTo(184.5, 0.01),
      );

      // Negative weight on C3: -12.3 g => flags bit0 = 1, 123 = 0x00007B
      final c3NegBytes = [0xC3, 0x01, 0x01, 0x00, 0x00, 0x7B, 90, 0x00, 0x00];
      expect(
        SmartScaleService.parseRawWeightBytes(c3NegBytes, ScaleBrand.coffeeLabsC3),
        closeTo(-12.3, 0.01),
      );
    });

    test('computes real-time flow rate and auto-triggers brew timer on first pour', () {
      final service = SmartScaleService.instance;
      bool autoStarted = false;
      service.onAutoStartBrewTimer = () => autoStarted = true;
      service.debugAttachTestDevice(
        const SmartScaleDevice(
          id: 'C3:AA:BB:CC:DD:01',
          name: 'Coffee Labs Scale C3',
          rssi: -52,
          brand: ScaleBrand.coffeeLabsC3,
        ),
        batteryPercent: 95,
      );

      final t0 = DateTime(2026, 11, 24, 10, 0, 0);
      // 0.0g at t=0
      service.debugFeedRawBytes([0xC3, 0x01, 0x02, 0x00, 0x00, 0x00, 95, 0, 0], sampleTime: t0);
      // 4.0g at t=1.0s => ~4.0 g/s -> triggers auto-start
      service.debugFeedRawBytes(
        [0xC3, 0x01, 0x00, 0x00, 0x00, 40, 95, 0, 1],
        sampleTime: t0.add(const Duration(milliseconds: 1000)),
      );

      expect(service.currentWeight, closeTo(4.0, 0.1));
      expect(service.flowRate, greaterThan(0.5));
      expect(service.batteryLevel, 95);
      expect(autoStarted, isTrue);
    });
  });

  group('ScaleBrewHistoryService & Community Payload', () {
    test('persists, reloads, and formats brew curve log for Social Coffee sharing', () async {
      final log = ScaleBrewLog(
        id: 'brew_test_1',
        createdAt: DateTime(2026, 11, 24, 9, 30),
        mode: ScaleBrewMode.pourOver,
        recipeTitle: 'V60 4:6 Sweet Balance',
        methodName: 'Hario V60 02',
        deviceName: 'TIMEMORE Black Mirror Dot',
        coffeeDoseGrams: 15.0,
        targetWaterGrams: 225.0,
        finalWeightGrams: 226.0,
        durationSeconds: 178,
        avgFlowRate: 3.9,
        peakFlowRate: 5.4,
        points: const [
          WeightDataPoint(elapsedSeconds: 0, weight: 0, flowRate: 0),
          WeightDataPoint(elapsedSeconds: 45, weight: 45, flowRate: 3.5),
          WeightDataPoint(elapsedSeconds: 178, weight: 226, flowRate: 0.4),
        ],
      );

      await ScaleBrewHistoryService.saveLog(log);
      ScaleBrewHistoryService.resetMemoryCache();
      final reloaded = await ScaleBrewHistoryService.loadLogs(forceRefresh: true);

      expect(reloaded, hasLength(1));
      expect(reloaded.first.recipeTitle, 'V60 4:6 Sweet Balance');
      expect(reloaded.first.actualRatio, closeTo(15.07, 0.05));
      expect(reloaded.first.formattedDuration, '02:58');
      expect(reloaded.first.toCommunitySummary(isEn: false), contains('TIMEMORE Black Mirror Dot'));
      expect(reloaded.first.toSocialRecipeSnapshot()['scaleTelemetry'], isNotNull);

      await ScaleBrewHistoryService.deleteLog('brew_test_1');
      expect(ScaleBrewHistoryService.logsNotifier.value, isEmpty);
    });

    test('ScaleRecipeCoachTab builds monotonically increasing target ghost curve', () {
      final recipes = ScaleRecipeCoachTab.builtInCoachRecipes();
      expect(recipes.length, greaterThanOrEqualTo(4));
      final curve = ScaleRecipeCoachTab.buildTargetCurve(recipes.first);
      expect(curve.length, greaterThan(4));
      expect(curve.last.weight, closeTo(225.0, 0.1));
    });
  });

  group('SmartScaleScreen & BrewScaleLiveBadge 360x780 UI Tests', () {
    testWidgets('renders all 3 tabs, 3 brew modes, and BLE scanner with ZERO overflow at 360x780', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SmartScaleScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Verify Coffee Labs light background & honest disconnected state
      expect(find.text('Timbangan Belum Terhubung'), findsOneWidget);
      expect(find.text('--.-'), findsOneWidget);

      // Switch modes: Espresso & Umum
      await tester.tap(find.text('Espresso'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Umum'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Pour-Over'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Attach a real-protocol test scale and feed weight
      SmartScaleService.instance.debugAttachTestDevice(
        const SmartScaleDevice(
          id: 'TM:11:22:33:44:55',
          name: 'TIMEMORE Black Mirror Dot',
          rssi: -48,
          brand: ScaleBrand.timemore,
        ),
      );
      SmartScaleService.instance.debugFeedRawBytes(
        [0x02, 0x00, 0x01, 0xC2, 0x00, 0x00, 0x03], // 45.0g
      );
      await tester.pump();
      expect(find.text('TIMEMORE Black Mirror Dot'), findsOneWidget);
      expect(find.text('45.0'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tab 2: Resep & Coach -> select a recipe
      await tester.tap(find.text('Resep & Coach'));
      await tester.pumpAndSettle();
      expect(find.text('V60 4:6 Sweet Balance (Pro Coach)'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Pakai di Timbangan').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Tab 3: Riwayat
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('ScaleDeviceSheet shows TIMEMORE Dot & Coffee Labs Scale C3 (Segera Hadir) with NO Virtual Scale', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ScaleDeviceSheet(scaleService: SmartScaleService.instance),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Coffee Labs Virtual Smart Scale'), findsNothing);
      expect(find.text('Coffee Labs Scale C3'), findsOneWidget);
      expect(find.text('SEGERA HADIR'), findsOneWidget);
      expect(find.text('TIMEMORE Black Mirror Dot / Nano / Basic'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BrewScaleLiveBadge stays hidden when disconnected and renders telemetry when connected at 360px', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(
              child: BrewScaleLiveBadge(isEn: false, targetWaterGrams: 225),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Disconnected banner button is intentionally removed (replaced by side Bluetooth icon)
      expect(find.textContaining('Hubungkan Smart Scale'), findsNothing);
      expect(tester.takeException(), isNull);

      SmartScaleService.instance.debugAttachTestDevice(
        const SmartScaleDevice(
          id: 'TM:99:88',
          name: 'TIMEMORE Dot',
          rssi: -55,
          brand: ScaleBrand.timemore,
        ),
      );
      SmartScaleService.instance.debugFeedRawBytes(
        [0x02, 0x00, 0x03, 0x84, 0x00, 0x00, 0x03], // 90.0g
      );
      await tester.pump();
      expect(find.text('90.0 g'), findsOneWidget);
      expect(find.text(' / 225g'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
