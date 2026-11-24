import 'package:coffee_hub_mobile/services/app_hot_content_sync_service.dart';
import 'package:coffee_hub_mobile/services/app_update_service.dart';
import 'package:coffee_hub_mobile/widgets/app_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppUpdateService Hybrid Delta-OTA & Version Gatekeeper', () {
    test('normalizes Android split-per-abi versionCode accurately', () {
      expect(AppUpdateService.normalizeAbiBuildNumber(2009), 9);
      expect(AppUpdateService.normalizeAbiBuildNumber(2008), 8);
      expect(AppUpdateService.normalizeAbiBuildNumber(1012), 12);
      expect(AppUpdateService.normalizeAbiBuildNumber(4007), 7);
      expect(AppUpdateService.normalizeAbiBuildNumber(9), 9);
      expect(AppUpdateService.normalizeAbiBuildNumber(0), 1);
    });

    test('VersionCheckResult sanitizes legacy wrong repo URL & parses new fields', () {
      final result = VersionCheckResult.fromJson({
        'action_code': 'FLEXIBLE_STORE_UPDATE',
        'update_channel': 'native_browser',
        'latest_base_version': '2.5.1',
        'latest_build_number': 9,
        'normalized_client_build': 8,
        'is_force_update': false,
        'release_notes': 'Perbaikan routing & email reset.',
        'download_url': 'https://github.com/rusdi-labs/coffee-hub-mobile/releases/latest',
        'content_manifest_version': 4,
      });

      expect(result.isStoreUpdate, isTrue);
      expect(result.downloadUrl, isNull); // Legacy broken URL sanitized cleanly
      expect(result.contentManifestVersion, 4);
      expect(result.normalizedClientBuild, 8);
    });

    test('24-hour flexible update snooze suppresses repeated nags for same version', () async {
      expect(await AppUpdateService.isUpdateSnoozed('2.5.2'), isFalse);
      await AppUpdateService.snoozeFlexibleUpdate('2.5.2');
      expect(await AppUpdateService.isUpdateSnoozed('2.5.2'), isTrue);
      expect(await AppUpdateService.isUpdateSnoozed('2.6.0'), isFalse);
    });

    test('AppHotContentSyncService tracks manifest version & avoids redundant sync', () async {
      expect(await AppHotContentSyncService.getLocalManifestVersion(), 0);
      final synced = await AppHotContentSyncService.syncIfNeeded(3);
      expect(synced, isTrue);
      expect(await AppHotContentSyncService.getLocalManifestVersion(), 3);

      final redundant = await AppHotContentSyncService.syncIfNeeded(3);
      expect(redundant, isFalse);
    });
  });

  group('AppUpdateDialog Honest Delta-OTA & Play-Protect Native Handoff UI', () {
    testWidgets('Shorebird OTA dialog downloads delta patch & shows restart-ready state', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 780 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const res = VersionCheckResult(
        actionCode: 'SILENT_OTA_PATCH',
        updateChannel: 'shorebird_ota',
        targetPatch: 3,
        latestBaseVersion: '2.5.1',
        latestBuildNumber: 9,
        isForceUpdate: false,
        releaseNotes: 'Perbaikan cepat timer seduh (~2 MB).',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppUpdateDialog(
              result: res,
              isShorebirdPatch: true,
              shorebirdRunner: () async => ShorebirdPatchOutcome.downloaded,
            ),
          ),
        ),
      );

      expect(find.textContaining('Delta OTA Patch #3'), findsOneWidget);
      await tester.tap(find.text('Unduh Delta Patch Sekarang'));
      await tester.pumpAndSettle();

      expect(find.text('Siap — Mulai Ulang Aplikasi'), findsOneWidget);
      expect(find.textContaining('tanpa install ulang'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Non-Shorebird build never fakes patch success and offers clean official download fallback', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 780 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? launchedUrl;
      const res = VersionCheckResult(
        actionCode: 'FORCE_OTA_PATCH',
        updateChannel: 'shorebird_ota',
        targetPatch: 2,
        latestBaseVersion: '2.5.1',
        latestBuildNumber: 9,
        isForceUpdate: true,
        releaseNotes: 'Patch penting.',
        downloadUrl: 'https://github.com/rusdifn08/coffe-labs-mobile/releases/download/v2.5.1/Coffe_Labs_25.apk',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppUpdateDialog(
              result: res,
              isShorebirdPatch: true,
              shorebirdRunner: () async => ShorebirdPatchOutcome.unavailable,
              downloadLauncher: (url) async {
                launchedUrl = url;
                return true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('belum memuat mesin Delta OTA'), findsOneWidget);
      expect(find.text('Unduh Rilis Resmi Terbaru'), findsOneWidget);

      await tester.tap(find.text('Unduh Rilis Resmi Terbaru'));
      await tester.pumpAndSettle();
      expect(launchedUrl, contains('Coffe_Labs_25.apk'));
      expect(tester.takeException(), isNull);
    });
  });
}
