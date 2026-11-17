import 'package:coffee_hub_mobile/features/live_brew/data/live_brew_api_service.dart';
import 'package:coffee_hub_mobile/features/live_brew/domain/live_brew_models.dart';
import 'package:coffee_hub_mobile/features/live_brew/presentation/screens/customer_live_brew_tracker_screen.dart';
import 'package:coffee_hub_mobile/features/live_brew/presentation/widgets/table_qr_manager_modal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

class _FakeLiveBrewApiService extends LiveBrewApiService {
  _FakeLiveBrewApiService() : super(Dio());

  @override
  Future<List<LiveBrewTableModel>> listTables() async => const [
        LiveBrewTableModel(
          id: 'tbl-4',
          tableNumber: 'Meja 04',
          staticAddressCode: '7104928374615',
          livebrewUrl: 'https://coffeelabs.app/livebrew/7104928374615',
          deepLinkUrl: 'coffeelabs://livebrew/7104928374615',
        ),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Modul 2.2 Live Brewing Tracker & QR Architecture Tests', () {
    test('EwmaFlowFilter smooths 10Hz weight readings with alpha=0.28', () {
      final filter = EwmaFlowFilter();
      expect(filter.update(0.0, 0), 0.0);
      final q1 = filter.update(1.0, 100);
      expect(q1, closeTo(2.8, 0.05));
      final q2 = filter.update(1.5, 200);
      expect(q2, closeTo(3.42, 0.05));
    });

    test('interpolateCubicHermiteWeight preserves C1 endpoints and smooth curve', () {
      const p0 = LiveBrewCurvePoint(tMs: 0, wG: 10.0, flow: 4.0, tempC: 92.0);
      const p1 = LiveBrewCurvePoint(tMs: 1000, wG: 15.0, flow: 6.0, tempC: 92.0);
      expect(interpolateCubicHermiteWeight(p0, p1, 0.0), closeTo(10.0, 0.001));
      expect(interpolateCubicHermiteWeight(p0, p1, 1.0), closeTo(15.0, 0.001));
      final mid = interpolateCubicHermiteWeight(p0, p1, 0.5);
      expect(mid, inInclusiveRange(11.0, 14.0));
    });

    test('LiveBrewApiService extracts 13-digit address codes from Landing Page & Deep Links', () {
      expect(
        LiveBrewApiService.extractAddressCode('https://coffeelabs.app/livebrew/3201923849204'),
        '3201923849204',
      );
      expect(
        LiveBrewApiService.extractAddressCode('coffeelabs://livebrew/7104928374615'),
        '7104928374615',
      );
      expect(LiveBrewApiService.extractAddressCode('  3201923849204 '), '3201923849204');
    });

    test('Snapshot & Table DTOs preserve coffeelabs.app Landing Page URLs', () {
      final tbl = LiveBrewTableModel.fromJson({
        'id': 'tbl-1',
        'table_number': 'Meja 04',
        'static_address_code': '7104928374615',
      });
      expect(tbl.livebrewUrl, 'https://coffeelabs.app/livebrew/7104928374615');
      expect(tbl.deepLinkUrl, 'coffeelabs://livebrew/7104928374615');
    });

    testWidgets('CustomerLiveBrewTrackerScreen runs Live Simulation cleanly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [liveBrewApiProvider.overrideWithValue(_FakeLiveBrewApiService())],
          child: const MaterialApp(home: CustomerLiveBrewTrackerScreen()),
        ),
      );
      await tester.pump();
      expect(find.text('Lacak Seduhan Barista Live (10Hz)'), findsOneWidget);

      await tester.tap(find.text('Jalankan Simulasi Live Brew'));
      await tester.pump();
      expect(find.text('Malabar Wine Dual-Temp V60'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);
    });

    testWidgets('TableQrManagerModal renders QR & Static Table list cleanly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [liveBrewApiProvider.overrideWithValue(_FakeLiveBrewApiService())],
          child: const MaterialApp(
            home: Scaffold(body: TableQrManagerModal()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Live Brew QR & Meja Slow Bar'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.textContaining('coffeelabs.app/livebrew/'), findsOneWidget);
      expect(find.text('Meja 04 • 710492..'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
