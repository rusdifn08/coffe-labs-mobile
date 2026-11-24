import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coffee_hub_mobile/core/network/backend_endpoint_manager.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BackendEndpointManager — Zero-Downtime VPS Migration & Auto-Failover', () {
    test('validates HTTPS endpoints & blocks insecure/retired URLs', () {
      expect(
        BackendEndpointManager.normalizeAndValidateUrl('https://api.vps-coffeelabs.id/'),
        'https://api.vps-coffeelabs.id',
      );
      expect(
        BackendEndpointManager.normalizeAndValidateUrl('http://api.vps-coffeelabs.id'),
        isNull,
      );
      expect(
        BackendEndpointManager.normalizeAndValidateUrl('https://coffe-labs-backend.onrender.com'),
        isNull,
      );
      expect(
        BackendEndpointManager.normalizeAndValidateUrl('http://localhost:3000'),
        isNull,
      );
      expect(
        BackendEndpointManager.normalizeAndValidateUrl('https://10.0.2.2:8080'),
        isNull,
      );
    });

    test('falls back across free CDN mirrors & migrates seamlessly to healthy VPS', () async {
      final manager = BackendEndpointManager.forTest(
        manifestMirrors: const [
          'https://brewingcoffee.vercel.app/runtime-endpoints.json',
          'https://cdn.jsdelivr.net/gh/rusdifn08/coffe-labs-mobile@main/config/runtime-endpoints.json',
        ],
        httpGet: (uri, {headers}) async {
          if (uri.host == 'brewingcoffee.vercel.app') {
            return http.Response('Service Unavailable', 503);
          }
          if (uri.host == 'cdn.jsdelivr.net') {
            return http.Response(
              jsonEncode({
                'schema_version': 1,
                'manifest_revision': 2,
                'primary_api_url': 'https://api.vps-pribadi.id',
                'fallback_api_urls': [
                  'https://coffe-labs-backend-production.up.railway.app',
                ],
                'health_path': '/api/health',
                'force_switch': true,
              }),
              200,
            );
          }
          if (uri.toString() == 'https://api.vps-pribadi.id/api/health') {
            return http.Response(
              jsonEncode({
                'status': 'ok',
                'app': 'Coffee Labs Enterprise API',
                'db_ok': true,
              }),
              200,
            );
          }
          return http.Response('Not Found', 404);
        },
      );

      final report = await manager.syncManifestFromMirrors(force: true);

      expect(report.switched, isTrue);
      expect(report.activeBaseUrl, 'https://api.vps-pribadi.id');
      expect(report.manifestRevision, 2);
      expect(report.source, 'jsDelivr Global CDN');
      expect(await manager.getActiveBaseUrl(), 'https://api.vps-pribadi.id');
      expect(
        manager.buildWebSocketUri('/api/v1/system/control-ws').toString(),
        'wss://api.vps-pribadi.id/api/v1/system/control-ws',
      );
    });

    test('rejects Wi-Fi captive portal fake HTTP 200 HTML during health check', () async {
      final manager = BackendEndpointManager.forTest(
        manifestMirrors: const [
          'https://brewingcoffee.vercel.app/runtime-endpoints.json',
        ],
        httpGet: (uri, {headers}) async {
          if (uri.host == 'brewingcoffee.vercel.app') {
            return http.Response(
              jsonEncode({
                'manifest_revision': 3,
                'primary_api_url': 'https://hijacked-portal.example.com',
                'fallback_api_urls': [],
              }),
              200,
            );
          }
          // Simulasi captive portal Wi-Fi kafe yang membalas HTML 200 OK
          return http.Response('<html><body>Login Wi-Fi Kafe</body></html>', 200);
        },
      );

      final report = await manager.syncManifestFromMirrors(force: true);

      expect(report.switched, isFalse);
      expect(
        await manager.getActiveBaseUrl(),
        BackendEndpointManager.defaultProductionUrl,
      );
    });

    test('auto-failover switches from dead Railway to healthy VPS on transport error', () async {
      final manager = BackendEndpointManager.forTest(
        manifestMirrors: const [
          'https://raw.githubusercontent.com/rusdifn08/coffe-labs-mobile/main/config/runtime-endpoints.json',
        ],
        httpGet: (uri, {headers}) async {
          if (uri.host == 'raw.githubusercontent.com') {
            return http.Response(
              jsonEncode({
                'manifest_revision': 4,
                'primary_api_url': 'https://coffe-labs-backend-production.up.railway.app',
                'fallback_api_urls': ['https://vps-backup.coffeelabs.id'],
              }),
              200,
            );
          }
          if (uri.toString() == 'https://vps-backup.coffeelabs.id/api/health') {
            return http.Response(
              jsonEncode({'status': 'ok', 'app': 'Coffee Labs Enterprise API'}),
              200,
            );
          }
          return http.Response('Bad Gateway', 502);
        },
      );

      final recovered = await manager.failoverOnTransportError(
        failedUrl: 'https://coffe-labs-backend-production.up.railway.app',
      );

      expect(recovered, 'https://vps-backup.coffeelabs.id');
      expect(await manager.getActiveBaseUrl(), 'https://vps-backup.coffeelabs.id');
    });

    test('blocks rollback to older manifest_revision from stale CDN mirror', () async {
      int callCount = 0;
      final manager = BackendEndpointManager.forTest(
        manifestMirrors: const [
          'https://brewingcoffee.vercel.app/runtime-endpoints.json',
        ],
        httpGet: (uri, {headers}) async {
          if (uri.host == 'brewingcoffee.vercel.app') {
            callCount++;
            if (callCount == 1) {
              return http.Response(
                jsonEncode({
                  'manifest_revision': 5,
                  'primary_api_url': 'https://vps-new.coffeelabs.id',
                }),
                200,
              );
            }
            // Mirror cache basi mengembalikan revisi lebih lama (v2)
            return http.Response(
              jsonEncode({
                'manifest_revision': 2,
                'primary_api_url': 'https://old-server.coffeelabs.id',
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({'status': 'ok', 'app': 'Coffee Labs Enterprise API'}),
            200,
          );
        },
      );

      final first = await manager.syncManifestFromMirrors(force: true);
      expect(first.activeBaseUrl, 'https://vps-new.coffeelabs.id');

      // Reset TTL untuk menguji panggilan non-force berikutnya
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('coffeehub_endpoint_last_sync_ms_v1', 0);

      final second = await manager.syncManifestFromMirrors(force: false);
      expect(second.switched, isFalse);
      expect(await manager.getActiveBaseUrl(), 'https://vps-new.coffeelabs.id');
    });
  });
}
