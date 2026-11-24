import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_hot_content_sync_service.dart';
import 'auth_service.dart';
import '../widgets/app_update_dialog.dart';

enum ShorebirdPatchOutcome {
  downloaded,
  restartRequired,
  upToDate,
  unavailable,
  error,
}

class VersionCheckResult {
  final String actionCode; // "UP_TO_DATE", "SILENT_OTA_PATCH", "FORCE_OTA_PATCH", "FLEXIBLE_STORE_UPDATE", "FORCE_STORE_UPDATE"
  final String updateChannel; // "up_to_date" | "shorebird_ota" | "native_browser"
  final int? targetPatch;
  final String latestBaseVersion;
  final int latestBuildNumber;
  final int? normalizedClientBuild;
  final bool isForceUpdate;
  final String releaseNotes;
  final String? downloadUrl;
  final String? checksumSha256;
  final int contentManifestVersion;

  const VersionCheckResult({
    required this.actionCode,
    this.updateChannel = 'up_to_date',
    this.targetPatch,
    required this.latestBaseVersion,
    required this.latestBuildNumber,
    this.normalizedClientBuild,
    required this.isForceUpdate,
    required this.releaseNotes,
    this.downloadUrl,
    this.checksumSha256,
    this.contentManifestVersion = 1,
  });

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) {
    final code = json['action_code']?.toString() ?? 'UP_TO_DATE';
    final rawUrl = json['download_url']?.toString().trim();
    final sanitizedUrl = (rawUrl != null &&
            rawUrl.isNotEmpty &&
            !rawUrl.contains('rusdi-labs/coffee-hub-mobile'))
        ? rawUrl
        : null;
    final inferredChannel = json['update_channel']?.toString() ??
        ((code == 'SILENT_OTA_PATCH' || code == 'FORCE_OTA_PATCH')
            ? 'shorebird_ota'
            : ((code == 'FLEXIBLE_STORE_UPDATE' || code == 'FORCE_STORE_UPDATE')
                ? 'native_browser'
                : 'up_to_date'));

    return VersionCheckResult(
      actionCode: code,
      updateChannel: inferredChannel,
      targetPatch: (json['target_patch'] as num?)?.toInt(),
      latestBaseVersion: json['latest_base_version']?.toString() ?? '2.5.1',
      latestBuildNumber: (json['latest_build_number'] as num?)?.toInt() ?? 9,
      normalizedClientBuild: (json['normalized_client_build'] as num?)?.toInt(),
      isForceUpdate: json['is_force_update'] == true,
      releaseNotes: json['release_notes']?.toString() ??
          'Pembaruan stabilitas dan optimasi performa.',
      downloadUrl: sanitizedUrl,
      checksumSha256: json['checksum_sha256']?.toString(),
      contentManifestVersion:
          (json['content_manifest_version'] as num?)?.toInt() ?? 1,
    );
  }

  bool get isUpToDate => actionCode == 'UP_TO_DATE';
  bool get isShorebirdPatch =>
      actionCode == 'SILENT_OTA_PATCH' || actionCode == 'FORCE_OTA_PATCH';
  bool get isStoreUpdate =>
      actionCode == 'FLEXIBLE_STORE_UPDATE' || actionCode == 'FORCE_STORE_UPDATE';
}

class AppUpdateService {
  static const String officialReleasesUrl =
      'https://github.com/rusdifn08/coffe-labs-mobile/releases/latest';
  static const String officialAndroidApkUrl =
      'https://github.com/rusdifn08/coffe-labs-mobile/releases/latest/download/Coffe_Labs_25.apk';
  static const String officialIosIpaUrl =
      'https://github.com/rusdifn08/coffe-labs-mobile/releases/latest/download/CoffeLabs25.ipa';

  static const String _cachedVersionCheckKey = 'gatekeeper_cached_version_check_v2';
  static const String _snoozedVersionKey = 'gatekeeper_snoozed_version_v1';
  static const String _snoozedUntilKey = 'gatekeeper_snoozed_until_ms_v1';
  static const Duration _cacheTtl = Duration(hours: 24);
  static const Duration _flexibleSnoozeDuration = Duration(hours: 24);

  static final ShorebirdUpdater _shorebird = ShorebirdUpdater();
  static final ValueNotifier<bool> patchReadyNotifier = ValueNotifier<bool>(false);
  static bool _isChecking = false;

  /// Menormalkan Android `--split-per-abi` versionCode (contoh: 2009 -> 9, 1008 -> 8).
  static int normalizeAbiBuildNumber(int raw) {
    if (raw >= 1000 && raw < 10000) {
      final rem = raw % 1000;
      if (rem > 0) return rem;
    }
    return raw > 0 ? raw : 1;
  }

  /// URL unduhan resmi sesuai platform aktif (Android APK / iOS IPA / Desktop Releases).
  static String defaultPlatformDownloadUrl() {
    if (kIsWeb) return officialReleasesUrl;
    if (Platform.isAndroid) return officialAndroidApkUrl;
    if (Platform.isIOS) return officialIosIpaUrl;
    return officialReleasesUrl;
  }

  /// Cek apakah Shorebird Code Push updater aktif di binary rilis ini.
  static bool get isShorebirdAvailable {
    try {
      return _shorebird.isAvailable;
    } catch (_) {
      return false;
    }
  }

  /// Dapatkan nomor patch Shorebird yang sedang berjalan.
  static Future<int> getCurrentPatchNumber() async {
    try {
      if (isShorebirdAvailable) {
        final patch = await _shorebird.readCurrentPatch();
        return patch?.number ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  /// Dapatkan info versi aplikasi saat ini (termasuk raw & normalized buildNumber).
  static Future<Map<String, dynamic>> getAppVersionInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final patchNum = await getCurrentPatchNumber();
      final rawBuild = int.tryParse(info.buildNumber) ?? 9;
      return {
        'version': info.version,
        'buildNumber': normalizeAbiBuildNumber(rawBuild),
        'rawBuildNumber': rawBuild,
        'patchNumber': patchNum,
        'appName': info.appName,
      };
    } catch (_) {
      return {
        'version': '2.5.1',
        'buildNumber': 9,
        'rawBuildNumber': 9,
        'patchNumber': 0,
        'appName': 'Coffee Labs',
      };
    }
  }

  /// Simpan snooze 24 jam agar pengguna yang memilih "Nanti Saja" tidak terus terganggu.
  static Future<void> snoozeFlexibleUpdate(String targetVersion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final untilMs =
          DateTime.now().add(_flexibleSnoozeDuration).millisecondsSinceEpoch;
      await prefs.setString(_snoozedVersionKey, targetVersion.trim());
      await prefs.setInt(_snoozedUntilKey, untilMs);
    } catch (_) {}
  }

  static Future<bool> isUpdateSnoozed(String targetVersion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVer = prefs.getString(_snoozedVersionKey);
      final untilMs = prefs.getInt(_snoozedUntilKey) ?? 0;
      if (savedVer != targetVersion.trim()) return false;
      return DateTime.now().millisecondsSinceEpoch < untilMs;
    } catch (_) {
      return false;
    }
  }

  /// Pengecekan versi ke Rust Axum Version Gatekeeper dengan cache ber-TTL & version-aware.
  static Future<VersionCheckResult?> checkVersionFromGatekeeper({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final versionInfo = await getAppVersionInfo();
    final appVersion = versionInfo['version']?.toString() ?? '2.5.1';
    final buildNumber = (versionInfo['buildNumber'] as num?)?.toInt() ?? 9;
    final patchNumber = (versionInfo['patchNumber'] as num?)?.toInt() ?? 0;

    try {
      final baseUrl = await AuthService.getBaseUrl();

      String platformName = 'android';
      if (kIsWeb) {
        platformName = 'web';
      } else if (Platform.isIOS) {
        platformName = 'ios';
      } else if (Platform.isWindows) {
        platformName = 'windows';
      }

      final uri = Uri.parse(
        '$baseUrl/api/v1/app/version-check'
        '?platform=$platformName'
        '&base_version=$appVersion'
        '&build_number=$buildNumber'
        '&patch_number=$patchNumber',
      );

      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            _cachedVersionCheckKey,
            json.encode({
              'checkedVersion': appVersion,
              'checkedBuild': buildNumber,
              'checkedPatch': patchNumber,
              'cachedAtMs': DateTime.now().millisecondsSinceEpoch,
              'payload': data,
            }),
          );
        } catch (_) {}
        return VersionCheckResult.fromJson(data);
      }
      return _getCachedVersionResult(
        currentVersion: appVersion,
        currentBuild: buildNumber,
        currentPatch: patchNumber,
      );
    } on TimeoutException {
      debugPrint('Gatekeeper timeout ($timeout). Memakai fallback cache aman.');
      return _getCachedVersionResult(
        currentVersion: appVersion,
        currentBuild: buildNumber,
        currentPatch: patchNumber,
      );
    } catch (e) {
      debugPrint('Catatan Gatekeeper: $e. Memakai fallback cache aman.');
      return _getCachedVersionResult(
        currentVersion: appVersion,
        currentBuild: buildNumber,
        currentPatch: patchNumber,
      );
    }
  }

  /// Ambil cache hanya jika belum expired (< 24 jam) DAN cocok dengan versi aplikasi terpasang.
  static Future<VersionCheckResult?> _getCachedVersionResult({
    required String currentVersion,
    required int currentBuild,
    required int currentPatch,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cachedVersionCheckKey);
      if (raw != null && raw.isNotEmpty) {
        final envelope = json.decode(raw) as Map<String, dynamic>;
        final cachedAtMs = (envelope['cachedAtMs'] as num?)?.toInt() ?? 0;
        final ageMs = DateTime.now().millisecondsSinceEpoch - cachedAtMs;
        final sameClient = envelope['checkedVersion'] == currentVersion &&
            envelope['checkedBuild'] == currentBuild &&
            envelope['checkedPatch'] == currentPatch;
        if (sameClient && ageMs >= 0 && ageMs <= _cacheTtl.inMilliseconds) {
          final payload = envelope['payload'];
          if (payload is Map<String, dynamic>) {
            return VersionCheckResult.fromJson(payload);
          }
        } else {
          await prefs.remove(_cachedVersionCheckKey);
        }
      }
    } catch (_) {}

    return VersionCheckResult(
      actionCode: 'UP_TO_DATE',
      updateChannel: 'up_to_date',
      targetPatch: null,
      latestBaseVersion: currentVersion,
      latestBuildNumber: currentBuild,
      normalizedClientBuild: currentBuild,
      isForceUpdate: false,
      releaseNotes: 'Aplikasi berjalan normal dengan versi stabil saat ini.',
      downloadUrl: defaultPlatformDownloadUrl(),
      contentManifestVersion: 1,
    );
  }

  /// Eksekutor Hybrid 3-Layer Delta Update:
  /// 1) 0-Second Hot Content Delta Sync (katalog/kebijakan JSON KB tanpa restart)
  /// 2) Shorebird Delta OTA Patch (hanya diff kode Dart ~1-5 MB tanpa install ulang)
  /// 3) Native Release Update (Play-Protect clean browser/store handoff jika engine/plugin berubah)
  static Future<void> checkForUpdate({
    required BuildContext context,
    bool isManual = false,
  }) async {
    if (_isChecking) return;
    _isChecking = true;

    if (isManual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memeriksa pembaruan OTA & versi ke server...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    try {
      final result = await checkVersionFromGatekeeper();
      if (!context.mounted) return;

      if (result == null) {
        if (isManual) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat terhubung ke server pembaruan. Cek koneksi internet.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      // Layer 1: Sinkronkan konten ringan (0-second hot sync tanpa restart)
      unawaited(
        AppHotContentSyncService.syncIfNeeded(result.contentManifestVersion),
      );

      switch (result.actionCode) {
        case 'UP_TO_DATE':
          // Layer 2 Proaktif: cek apakah Shorebird CDN punya delta patch baru
          final otaOutcome = await _checkAndDownloadShorebirdProactively();
          if (!context.mounted) return;
          if (otaOutcome == ShorebirdPatchOutcome.downloaded ||
              otaOutcome == ShorebirdPatchOutcome.restartRequired) {
            _notifyPatchReadySnackBar(context);
            return;
          }
          if (isManual) {
            final info = await getAppVersionInfo();
            if (!context.mounted) return;
            _showUpToDateDialog(context, info);
          }
          break;

        case 'SILENT_OTA_PATCH':
          final outcome = await runShorebirdPatchUpdate();
          if (!context.mounted) return;
          if (outcome == ShorebirdPatchOutcome.downloaded ||
              outcome == ShorebirdPatchOutcome.restartRequired) {
            _notifyPatchReadySnackBar(context);
          } else if (isManual) {
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (_) => AppUpdateDialog(
                result: result,
                isShorebirdPatch: true,
              ),
            );
          }
          break;

        case 'FORCE_OTA_PATCH':
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => AppUpdateDialog(
              result: result,
              isShorebirdPatch: true,
            ),
          );
          break;

        case 'FLEXIBLE_STORE_UPDATE':
          if (!isManual && await isUpdateSnoozed(result.latestBaseVersion)) {
            return;
          }
          if (!context.mounted) return;
          showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => AppUpdateDialog(
              result: result,
              isShorebirdPatch: false,
            ),
          );
          break;

        case 'FORCE_STORE_UPDATE':
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => AppUpdateDialog(
              result: result,
              isShorebirdPatch: false,
            ),
          );
          break;
      }
    } finally {
      _isChecking = false;
    }
  }

  static void _notifyPatchReadySnackBar(BuildContext context) {
    patchReadyNotifier.value = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '⚡ Pembaruan ringan (Delta OTA) selesai diunduh! Tutup & buka kembali aplikasi untuk langsung menerapkannya tanpa install ulang.',
        ),
        backgroundColor: Color(0xFF6D28D9),
        duration: Duration(seconds: 5),
      ),
    );
  }

  static void _showUpToDateDialog(
    BuildContext context,
    Map<String, dynamic> info,
  ) {
    final patchNum = (info['patchNumber'] as num?)?.toInt() ?? 0;
    final shorebirdBadge = isShorebirdAvailable
        ? 'Delta OTA Aktif (Patch #$patchNum)'
        : 'Rilis Native Standar';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.green, size: 26),
            SizedBox(width: 10),
            Text('Aplikasi Terkini', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Coffee Labs v${info['version']} (Build #${info['buildNumber']})\n'
          'Status Mesin Update: $shorebirdBadge\n\n'
          'Anda sudah menggunakan versi paling mutakhir.',
          style: const TextStyle(fontSize: 13.5, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static Future<ShorebirdPatchOutcome> _checkAndDownloadShorebirdProactively() async {
    if (!isShorebirdAvailable) return ShorebirdPatchOutcome.unavailable;
    return runShorebirdPatchUpdate();
  }

  /// Jalankan pengecekan & unduh delta patch Shorebird dengan status hasil yang jujur & presisi.
  static Future<ShorebirdPatchOutcome> runShorebirdPatchUpdate() async {
    if (!isShorebirdAvailable) {
      return ShorebirdPatchOutcome.unavailable;
    }
    try {
      final status = await _shorebird.checkForUpdate();
      if (status == UpdateStatus.restartRequired) {
        patchReadyNotifier.value = true;
        return ShorebirdPatchOutcome.restartRequired;
      }
      if (status == UpdateStatus.outdated) {
        await _shorebird.update();
        patchReadyNotifier.value = true;
        return ShorebirdPatchOutcome.downloaded;
      }
      return ShorebirdPatchOutcome.upToDate;
    } catch (e) {
      debugPrint('⚠️ Shorebird delta patch error: $e');
      return ShorebirdPatchOutcome.error;
    }
  }

  /// Alias kompatibilitas untuk memicu unduh delta patch Shorebird.
  static Future<bool> performShorebirdUpdate() async {
    final outcome = await runShorebirdPatchUpdate();
    return outcome == ShorebirdPatchOutcome.downloaded ||
        outcome == ShorebirdPatchOutcome.restartRequired;
  }

  /// Buka URL unduhan rilis resmi di browser/Download Manager OS (100% aman Google Play Protect).
  static Future<bool> openDownloadUrl(String? url) async {
    final raw = url?.trim();
    final target = (raw != null &&
            raw.isNotEmpty &&
            !raw.contains('rusdi-labs/coffee-hub-mobile'))
        ? raw
        : defaultPlatformDownloadUrl();
    final uri = Uri.tryParse(target);
    if (uri == null) return false;
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  // ================= ADMIN VERSION MANAGEMENT =================

  static Future<Map<String, dynamic>?> adminGetConfig() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/app-version');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Admin config fetch error: $e');
      return null;
    }
  }

  static Future<bool> adminUpdateConfig(Map<String, dynamic> payload) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/app-version');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Admin config update error: $e');
      return false;
    }
  }

  /// Sinkronisasi 1-klik konfigurasi Gatekeeper dari GitHub Release terbaru (`rusdifn08/coffe-labs-mobile`).
  static Future<Map<String, dynamic>?> adminSyncFromGitHub() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/app-version/sync-github');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Admin GitHub sync error: $e');
      return null;
    }
  }
}
