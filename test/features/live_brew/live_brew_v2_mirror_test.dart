import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:coffee_hub_mobile/features/live_brew/data/live_brew_v2_api_service.dart';
import 'package:coffee_hub_mobile/features/live_brew/domain/live_brew_mirror_models.dart';
import 'package:coffee_hub_mobile/features/live_brew/domain/services/ntp_synced_timer_engine.dart';
import 'package:coffee_hub_mobile/features/live_brew/presentation/controllers/live_brew_mirror_controller.dart';
import 'package:coffee_hub_mobile/features/live_brew/presentation/screens/customer_live_brew_tracker_screen.dart';
import 'package:coffee_hub_mobile/features/live_brew/presentation/screens/live_brew_viewer_mirror_screen.dart';
import 'package:coffee_hub_mobile/features/live_brew/presentation/services/cafe_seat_qr_print_service.dart';
import 'package:coffee_hub_mobile/features/live_brew/presentation/widgets/table_qr_manager_modal.dart';
import 'package:coffee_hub_mobile/theme/app_theme.dart';
import 'package:dio/dio.dart';

LiveSessionMirrorSnapshot _sampleSnapshot({
  int stateVersion = 4,
  LiveBrewMirrorPhase phase = LiveBrewMirrorPhase.brewingActive,
  LiveTimerStatus timerStatus = LiveTimerStatus.running,
  int timerAccumulatedMs = 15000,
  int? timerAnchorServerMs = 1000000,
}) {
  return LiveSessionMirrorSnapshot(
    sessionId: 'sess-real-001',
    shareCode: '8492019384726',
    shareUrl: 'https://coffeelabs.com/livebrew/kopi-senja/meja-04',
    deepLinkUrl: 'coffeelabs://livebrew/kopi-senja/meja-04',
    isBusinessSession: true,
    storeId: 'store-001',
    seatId: 'seat-004',
    posOrderNumber: '#POS-204',
    posOrderStatus: 'BREWING',
    brewerDisplayName: 'Barista Raka',
    customerName: 'Ayu Lestari',
    phase: phase,
    phaseLabelId: phase.labelId,
    stateVersion: stateVersion,
    selectedMethodId: 'v60',
    selectedMethodName: 'V60 Pour Over',
    selectedRecipeTitle: 'V60 Kasuya 4:6 Sweet',
    recipeSnapshot: const {
      'coffeeWeightGrams': 15,
      'totalWaterWeightGrams': 225,
      'totalTimeSeconds': 180,
      'steps': [
        {'title': 'Blooming 45ml', 'durationSeconds': 45},
        {'title': 'Tuangan Manis 90ml', 'durationSeconds': 45},
        {'title': 'Ekstraksi Akhir 90ml', 'durationSeconds': 90},
      ],
    },
    beanSnapshot: const {
      'name': 'Flores Manggarai Washed',
      'roastery': 'Kopi Senja Roastery',
      'origin': 'NTT, Indonesia',
      'process': 'Full Washed',
      'roast_level': 'Light-Medium',
      'tasting_notes': ['Jasmine', 'Honey', 'Orange Blossom'],
    },
    timerStatus: timerStatus,
    timerAccumulatedMs: timerAccumulatedMs,
    timerAnchorServerMs: timerAnchorServerMs,
    currentStepIndex: 1,
    currentWeightG: 112.4,
    currentFlowRateMlS: 4.8,
    currentTempC: 92.0,
    cheersCount: 7,
    activeViewersCount: 3,
    serverEpochMs: 1005000,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Live Brewing 2.0 — Cristian NTP Timer & URL Parser', () {
    test('NtpSyncedTimerEngine calibrates clock offset and enforces monotonic stateVersion', () {
      final engine = NtpSyncedTimerEngine();
      addTearDown(engine.dispose);

      // High-RTT noisy sample (+500ms offset)
      engine.recordNtpPong(
        clientSendMs: 1000,
        serverRecvMs: 1600,
        serverSendMs: 1602,
        clientRecvMs: 1202,
      );
      expect(engine.clockOffsetMs, 500);

      // Lower-RTT clean sample (+200ms offset, RTT = 20ms) should win
      engine.recordNtpPong(
        clientSendMs: 2000,
        serverRecvMs: 2210,
        serverSendMs: 2212,
        clientRecvMs: 2022,
      );
      expect(engine.clockOffsetMs, 200);

      // Apply RUNNING snapshot at version 5
      final applied = engine.applyAuthoritativeSnapshot(
        _sampleSnapshot(
          stateVersion: 5,
          timerStatus: LiveTimerStatus.running,
          timerAccumulatedMs: 10000,
          timerAnchorServerMs: 50000,
        ),
      );
      expect(applied, isTrue);

      // localNow = 53000 -> serverNow = 53200 -> delta = 3200 -> total = 13200ms
      expect(engine.computeDisplayMsAt(53000), 13200);

      // Stale out-of-order snapshot (version 4 <= 5) MUST be rejected
      final rejected = engine.applyAuthoritativeSnapshot(
        _sampleSnapshot(
          stateVersion: 4,
          timerStatus: LiveTimerStatus.paused,
          timerAccumulatedMs: 2000,
        ),
      );
      expect(rejected, isFalse);
      expect(engine.lastStateVersion, 5);

      // Newer PAUSED snapshot (version 6) freezes cleanly at accumulated_ms
      final paused = engine.applyAuthoritativeSnapshot(
        _sampleSnapshot(
          stateVersion: 6,
          timerStatus: LiveTimerStatus.paused,
          timerAccumulatedMs: 24500,
          timerAnchorServerMs: null,
        ),
      );
      expect(paused, isTrue);
      expect(engine.computeDisplayMsAt(99999), 24500);
    });

    test('LiveBrewV2ApiService.parseUserInputOrUrl handles 13-digit codes, HTTPS URLs, deep links, and short slugs', () {
      final t1 = LiveBrewV2ApiService.parseUserInputOrUrl('7123456789012');
      expect(t1.isValid, isTrue);
      expect(t1.isBrandedSeat, isFalse);
      expect(t1.shareCode, '7123456789012');

      final t2 = LiveBrewV2ApiService.parseUserInputOrUrl(
        'https://coffeelabs.com/livebrew/kopi-senja/meja-04',
      );
      expect(t2.isBrandedSeat, isTrue);
      expect(t2.cafeSlug, 'kopi-senja');
      expect(t2.seatSlug, 'meja-04');
      expect(t2.streamTargetKey, 'kopi-senja__meja-04');

      final t3 = LiveBrewV2ApiService.parseUserInputOrUrl('kopi-senja/kursi-bar-02');
      expect(t3.isBrandedSeat, isTrue);
      expect(t3.cafeSlug, 'kopi-senja');
      expect(t3.seatSlug, 'kursi-bar-02');

      final t4 = LiveBrewV2ApiService.parseUserInputOrUrl(
        'coffeelabs://livebrew/kopi-senja/meja-01',
      );
      expect(t4.isBrandedSeat, isTrue);
      expect(t4.cafeSlug, 'kopi-senja');
      expect(t4.seatSlug, 'meja-01');

      final t5 = LiveBrewV2ApiService.parseUserInputOrUrl(
        'https://brewingcoffee.vercel.app/livebrew/3456789012345',
      );
      expect(t5.isValid, isTrue);
      expect(t5.isBrandedSeat, isFalse);
      expect(t5.shareCode, '3456789012345');

      expect(
        LiveBrewV2ApiService.normalizePublicShareUrl(
          'https://coffeelabs.com/livebrew/kopi-senja/meja-01',
        ),
        'https://brewingcoffee.vercel.app/livebrew/kopi-senja/meja-01',
      );
    });

    test('LiveBrewMirrorController.mapFriendlyError never exposes raw DioException text on 401/403', () {
      final err401 = DioException(
        requestOptions: RequestOptions(path: '/api/v1/livebrew/business/seats/batch'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/livebrew/business/seats/batch'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );
      final mapped401 = LiveBrewMirrorController.mapFriendlyError(
        err401,
        fallback: 'Fallback',
      );
      expect(mapped401.isAuthExpired, isTrue);
      expect(mapped401.message, isNot(contains('DioException')));
      expect(mapped401.message, contains('login'));
    });

    test('CafeSeatQrPrintService generates valid %PDF- bytes for all 3 vector layouts', () async {
      const branding = BusinessBrandingModel(
        storeId: 'store-001',
        cafeSlug: 'kopi-senja',
        cafeDisplayName: 'Kopi Senja Slow Bar',
        wifiSsid: 'KopiSenja_5G',
        wifiPassword: 'manualbrew',
      );
      const seats = [
        CafeSeatModel(
          id: 's1',
          storeId: 'store-001',
          seatKind: CafeSeatKind.meja,
          seatLabel: 'Meja 01',
          seatSlug: 'meja-01',
          zoneArea: 'Lantai 1',
          capacityPersons: 2,
          numericFallbackCode: '7000000000001',
          brandedUrl: 'https://coffeelabs.com/livebrew/kopi-senja/meja-01',
          deepLinkUrl: 'coffeelabs://livebrew/kopi-senja/meja-01',
        ),
        CafeSeatModel(
          id: 's2',
          storeId: 'store-001',
          seatKind: CafeSeatKind.kursiBar,
          seatLabel: 'Kursi Bar 02',
          seatSlug: 'kursi-bar-02',
          zoneArea: 'Slow Bar',
          capacityPersons: 1,
          numericFallbackCode: '7000000000002',
          brandedUrl: 'https://coffeelabs.com/livebrew/kopi-senja/kursi-bar-02',
          deepLinkUrl: 'coffeelabs://livebrew/kopi-senja/kursi-bar-02',
        ),
      ];

      for (final layout in SeatQrPrintLayout.values) {
        final pdfBytes = await CafeSeatQrPrintService.buildSeatQrPdfBytes(
          branding: branding,
          seats: seats,
          layout: layout,
        );
        expect(pdfBytes.length, greaterThan(500));
        expect(ascii.decode(pdfBytes.sublist(0, 5)), '%PDF-');
      }
    });
  });

  group('Live Brewing 2.0 — UI Contrast, Zero Simulation & 360px No-Overflow Gate', () {
    testWidgets('LiveBrewHubScreen renders high-contrast dark header, 3 tabs, ZERO simulation at 360x780', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CustomerLiveBrewTrackerScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));

      // Verify Bright Coffee Labs AppBar (AppTheme.bgCream with AppTheme.textDark foreground)
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppTheme.bgCream);
      expect(appBar.foregroundColor, AppTheme.textDark);

      // Verify ZERO simulation UI anywhere
      expect(find.textContaining('Jalankan Simulasi'), findsNothing);
      expect(find.textContaining('Demo Seduh'), findsNothing);

      // Verify all 3 tabs present
      expect(find.text('Siarkan'), findsOneWidget);
      expect(find.text('Pindai / Lacak'), findsOneWidget);
      expect(find.text('Studio Meja'), findsOneWidget);

      // Switch across all 3 tabs and assert zero overflow / exception
      await tester.tap(find.text('Pindai / Lacak'));
      await tester.pumpAndSettle();
      expect(find.text('Pindai QR dengan Kamera'), findsOneWidget);
      expect(find.textContaining('Jalankan Simulasi'), findsNothing);

      await tester.tap(find.text('Studio Meja'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('LiveBrewViewerMirrorScreen renders branded seat + POS stepper + 1:1 mirror cleanly at 360x780', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final resolution = BrandedSeatResolution(
        resolutionKind: 'ACTIVE_BREW_MIRROR',
        branding: const BusinessBrandingModel(
          storeId: 'store-001',
          cafeSlug: 'kopi-senja',
          cafeDisplayName: 'Kopi Senja Slow Bar',
          accentColorHex: '#D4A373',
          welcomeMessage: 'Selamat datang di Slow Bar Kopi Senja!',
          wifiSsid: 'KopiSenja_Guest',
          wifiPassword: 'kopienak',
        ),
        seat: const CafeSeatModel(
          id: 'seat-004',
          storeId: 'store-001',
          seatKind: CafeSeatKind.meja,
          seatLabel: 'Meja 04',
          seatSlug: 'meja-04',
          zoneArea: 'Slow Bar',
          capacityPersons: 2,
          numericFallbackCode: '7000000000004',
          brandedUrl: 'https://coffeelabs.com/livebrew/kopi-senja/meja-04',
          deepLinkUrl: 'coffeelabs://livebrew/kopi-senja/meja-04',
        ),
        posOrderProgress: const PosOrderProgressModel(
          posOrderNumber: '#POS-204',
          posOrderStatus: 'BREWING',
          queuePositionAhead: 1,
          itemsSummary: '1x V60 Flores Manggarai',
          customerName: 'Ayu Lestari',
        ),
        activeBrewSession: _sampleSnapshot(),
        serverEpochMs: 1005000,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              backgroundColor: const Color(0xFF12100E),
              body: LiveBrewViewerMirrorScreen(
                target: const ParsedLiveBrewTarget(
                  cafeSlug: 'kopi-senja',
                  seatSlug: 'meja-04',
                ),
                initialResolution: resolution,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.text('Kopi Senja Slow Bar'), findsOneWidget);
      expect(find.textContaining('Meja 04'), findsOneWidget);
      expect(find.textContaining('#POS-204'), findsOneWidget);
      expect(find.textContaining('Jalankan Simulasi'), findsNothing);
      expect(tester.takeException(), isNull);

      // Scroll down to verify Live Recipe & Live Bean Passport cards below the fold
      await tester.drag(find.byType(ListView), const Offset(0, -520));
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text('V60 Kasuya 4:6 Sweet'), findsOneWidget);
      expect(find.text('Flores Manggarai Washed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TableQrManagerModal renders bright Coffee Labs broadcast modal cleanly at 360x780', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TableQrManagerModal(
                activeRecipe: {
                  'title': 'V60 Gesha Sweet',
                  'method': 'V60',
                  'beanName': 'Gesha Anaerobic',
                },
                isTimerRunning: true,
                elapsedSeconds: 42,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Live Brew & Bagikan QR'), findsOneWidget);
      expect(find.text('Mulai Siaran Live & Buat QR'), findsOneWidget);
      expect(find.textContaining('V60 Gesha Sweet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
