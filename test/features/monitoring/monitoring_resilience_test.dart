import 'dart:convert';
import 'dart:typed_data';

import 'package:coffee_hub_mobile/core/network/dio_client.dart';
import 'package:coffee_hub_mobile/features/monitoring/data/monitoring_admin_api_service.dart';
import 'package:coffee_hub_mobile/features/monitoring/data/telemetry_batch_outbox_service.dart';
import 'package:coffee_hub_mobile/features/monitoring/presentation/screens/platform_monitoring_dashboard_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockMonitoringAdapter implements HttpClientAdapter {
  int ingestCallCount = 0;
  bool monitoring404Mode;
  Uint8List? lastIngestBytes;
  String? lastContentEncoding;

  _MockMonitoringAdapter({this.monitoring404Mode = true});

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path;
    if (path.contains('/api/v1/monitoring/')) {
      if (path.contains('ingest-batch')) {
        ingestCallCount++;
        lastContentEncoding = options.headers['Content-Encoding']?.toString();
        if (requestStream != null) {
          final chunks = await requestStream.toList();
          lastIngestBytes = Uint8List.fromList(chunks.expand((e) => e).toList());
        }
      }
      if (monitoring404Mode) {
        return ResponseBody.fromString(
          '',
          404,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }
      if (path.contains('overview')) {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'online_now': 2,
              'total_accounts': 7,
              'trial_accounts': 5,
              'pro_accounts': 0,
              'business_accounts': 2,
              'dau_today': 2,
              'wau_7d': 5,
              'mau_30d': 7,
              'stickiness_pct': 28.5,
              'avg_today_screen_time_sec': 420,
              'total_brews_7d': 18,
              'at_risk_high_count': 0,
              'dormant_count': 0,
              'feature_adoption': [],
              'cohorts': [],
              'top_brew_recipes': [],
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }
      if (path.contains('accounts') && !path.contains('dossier')) {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'items': [
                {
                  'user_id': '1de33d23-2fac-42ce-877a-378abbc594df',
                  'username': 'rusdifn08',
                  'full_name': 'Admin Rusdi',
                  'role': 'admin',
                  'account_tier': 'Business',
                  'is_online': true,
                  'is_brewing_now': false,
                  'platform': 'android',
                  'today_screen_time_sec': 540,
                  'today_aod_time_sec': 0,
                  'total_7d_screen_time_sec': 1200,
                  'total_30d_screen_time_sec': 3000,
                  'total_lifetime_screen_time_sec': 5000,
                  'total_brews_executed': 12,
                  'total_recipes_created': 3,
                  'total_social_posts': 2,
                  'health_score': 92,
                  'churn_risk_level': 'LOW',
                },
              ],
              'total': 1,
              'page': 1,
              'online_now': 1,
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }
      return ResponseBody.fromString(
        jsonEncode({'success': true, 'data': {'accepted_events': 1}}),
        202,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    if (path == '/api/admin/users') {
      return ResponseBody.fromString(
        jsonEncode({
          'success': true,
          'data': [
            {
              'id': '1de33d23-2fac-42ce-877a-378abbc594df',
              'username': 'rusdifn08',
              'full_name': 'Admin Rusdi',
              'role': 'admin',
              'status': 'approved',
              'tier': 'business',
              'trial_brews_count': 4,
            },
            {
              'id': '31214eda-4b63-4a71-b348-3524711cc37d',
              'username': 'risaha15',
              'full_name': 'Risaha',
              'role': 'user',
              'status': 'approved',
              'tier': 'trial',
              'trial_brews_count': 2,
            },
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    return ResponseBody.fromString('', 404);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TelemetryBatchOutboxService.instance.resetEndpointCooldown();
  });

  group('Monitoring 404 Cooldown & Admin Users Fallback', () {
    test('GlobalErrorAndLoggingInterceptor maps 404 concisely without Mozilla boilerplate', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/v1/monitoring/overview'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/monitoring/overview'),
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
        message: 'verbose framework text',
      );
      final mapped = GlobalErrorAndLoggingInterceptor.mapDioException(err);
      expect(mapped.statusCode, equals(404));
      expect(mapped.message, contains('404'));
      expect(mapped.message.contains('mozilla.org'), isFalse);
    });

    test('TelemetryBatchOutboxService uses replayable bytes and activates 404 cooldown', () async {
      final adapter = _MockMonitoringAdapter(monitoring404Mode: true);
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter;

      final svc = TelemetryBatchOutboxService.instance;
      svc.attachDio(dio);
      svc.enqueueScreenDwell(routeName: '/recipes', elapsedSeconds: 15);
      expect(svc.queuedCount, greaterThanOrEqualTo(1));

      // Panggilan pertama mengirim gzip bytes & terkena 404 -> mengaktifkan cooldown
      await svc.flushNow(bypassTestGuard: true);
      expect(adapter.ingestCallCount, equals(1));
      expect(adapter.lastContentEncoding, equals('gzip'));
      expect(adapter.lastIngestBytes, isNotEmpty);
      expect(svc.isEndpointInCooldown, isTrue);

      // Panggilan kedua selama cooldown TIDAK menghantam server dengan 404 berulang
      await svc.flushNow(bypassTestGuard: true);
      expect(adapter.ingestCallCount, equals(1));
    });

    test('MonitoringAdminApiService falls back to /api/admin/users smoothly when /api/v1/monitoring returns 404', () async {
      final adapter = _MockMonitoringAdapter(monitoring404Mode: true);
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter;
      final api = MonitoringAdminApiService(dio);

      final res = await api.fetchDashboardData();
      expect(res.isLegacyFallback, isTrue);
      expect(res.overview.totalAccounts, equals(2));
      expect(res.overview.businessAccounts, equals(1));
      expect(res.overview.trialAccounts, equals(1));
      expect(res.accountsPage.items.length, equals(2));
      expect(res.accountsPage.items.first.username, equals('rusdifn08'));

      // Ketuk akun di mode fallback tidak error 404 melainkan mengembalikan dossier kompatibel
      final dossier = await api.fetchAccountDossier(
        res.accountsPage.items.first.userId,
        fallbackAccount: res.accountsPage.items.first,
      );
      expect(dossier.account.username, equals('rusdifn08'));
    });

    testWidgets('PlatformMonitoringDashboardScreen renders legacy fallback accounts cleanly at 375x780 without raw red 404 crash', (tester) async {
      tester.view.physicalSize = const Size(375, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final adapter = _MockMonitoringAdapter(monitoring404Mode: true);
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monitoringAdminApiProvider.overrideWithValue(MonitoringAdminApiService(dio)),
          ],
          child: const MaterialApp(
            home: PlatformMonitoringDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Harus menampilkan banner fallback + daftar akun nyata dari fallback, tanpa error 404 mentah
      expect(find.textContaining('/api/admin/users'), findsOneWidget);
      expect(find.textContaining('@rusdifn08'), findsOneWidget);
      expect(find.textContaining('@risaha15'), findsOneWidget);
      expect(find.textContaining('mozilla.org'), findsNothing);

      // Tap akun di mode fallback -> membuka Account360DossierSheet tanpa crash 404
      await tester.tap(find.textContaining('@rusdifn08'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Proporsi Fitur'), findsOneWidget);
    });

    testWidgets('PlatformMonitoringDashboardScreen renders v2 telemetry overview when /api/v1/monitoring/* is active', (tester) async {
      tester.view.physicalSize = const Size(375, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final adapter = _MockMonitoringAdapter(monitoring404Mode: false);
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            monitoringAdminApiProvider.overrideWithValue(MonitoringAdminApiService(dio)),
          ],
          child: const MaterialApp(
            home: PlatformMonitoringDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 / 7'), findsOneWidget);
      expect(find.textContaining('@rusdifn08'), findsOneWidget);
      expect(find.textContaining('/api/admin/users'), findsNothing);
    });
  });
}
