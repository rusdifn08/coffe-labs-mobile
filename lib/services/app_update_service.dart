import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_service.dart';
import '../widgets/app_update_dialog.dart';

class VersionCheckResult {
  final String actionCode; // "UP_TO_DATE", "SILENT_OTA_PATCH", "FORCE_OTA_PATCH", "FLEXIBLE_STORE_UPDATE", "FORCE_STORE_UPDATE"
  final int? targetPatch;
  final String latestBaseVersion;
  final int latestBuildNumber;
  final bool isForceUpdate;
  final String releaseNotes;
  final String? downloadUrl;
  final String? checksumSha256;

  const VersionCheckResult({
    required this.actionCode,
    this.targetPatch,
    required this.latestBaseVersion,
    required this.latestBuildNumber,
    required this.isForceUpdate,
    required this.releaseNotes,
    this.downloadUrl,
    this.checksumSha256,
  });

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) {
    return VersionCheckResult(
      actionCode: json['action_code']?.toString() ?? 'UP_TO_DATE',
      targetPatch: (json['target_patch'] as num?)?.toInt(),
      latestBaseVersion: json['latest_base_version']?.toString() ?? '1.0.0',
      latestBuildNumber: (json['latest_build_number'] as num?)?.toInt() ?? 1,
      isForceUpdate: json['is_force_update'] == true,
      releaseNotes: json['release_notes']?.toString() ?? 'Pembaruan stabilitas dan optimasi performa.',
      downloadUrl: json['download_url']?.toString(),
      checksumSha256: json['checksum_sha256']?.toString(),
    );
  }

  bool get isUpToDate => actionCode == 'UP_TO_DATE';
  bool get isShorebirdPatch => actionCode == 'SILENT_OTA_PATCH' || actionCode == 'FORCE_OTA_PATCH';
  bool get isStoreUpdate => actionCode == 'FLEXIBLE_STORE_UPDATE' || actionCode == 'FORCE_STORE_UPDATE';
}

class AppUpdateService {
  static final ShorebirdUpdater _shorebird = ShorebirdUpdater();
  static bool _isChecking = false;

  /// Cek apakah Shorebird Code Push updater aktif di environment ini
  static bool get isShorebirdAvailable {
    try {
      return _shorebird.isAvailable;
    } catch (_) {
      return false;
    }
  }

  /// Dapatkan nomor patch Shorebird saat ini
  static Future<int> getCurrentPatchNumber() async {
    try {
      if (isShorebirdAvailable) {
        final patch = await _shorebird.readCurrentPatch();
        return patch?.number ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  /// Dapatkan info versi aplikasi saat ini
  static Future<Map<String, dynamic>> getAppVersionInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final patchNum = await getCurrentPatchNumber();
      return {
        'version': info.version,
        'buildNumber': int.tryParse(info.buildNumber) ?? 1,
        'patchNumber': patchNum,
        'appName': info.appName,
      };
    } catch (_) {
      return {
        'version': '1.0.0',
        'buildNumber': 1,
        'patchNumber': 0,
        'appName': 'Coffee Labs',
      };
    }
  }

  /// Melakukan pengecekan versi ke Rust Axum Version Gatekeeper
  static Future<VersionCheckResult?> checkVersionFromGatekeeper() async {
    try {
      final baseUrl = await AuthService.getBaseUrl();
      final versionInfo = await getAppVersionInfo();

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
        '&base_version=${versionInfo['version']}'
        '&build_number=${versionInfo['buildNumber']}'
        '&patch_number=${versionInfo['patchNumber']}',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return VersionCheckResult.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error checking version from Gatekeeper: $e');
      return null;
    }
  }

  /// Eksekutor Orkestrasi Update (The Hybrid 3-Tier Execution)
  static Future<void> checkForUpdate({
    required BuildContext context,
    bool isManual = false,
  }) async {
    if (_isChecking) return;
    _isChecking = true;

    if (isManual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memeriksa pembaruan versi ke Version Gatekeeper...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    final result = await checkVersionFromGatekeeper();
    _isChecking = false;

    if (!context.mounted) return;

    if (result == null) {
      if (isManual) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat terhubung ke Version Gatekeeper. Pastikan server backend aktif.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Eksekusi berdasarkan Action dari Rust Axum
    switch (result.actionCode) {
      case 'UP_TO_DATE':
        if (isManual) {
          final info = await getAppVersionInfo();
          if (context.mounted) {
            showDialog(
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
                  'Coffee Labs v${info['version']} (Build #${info['buildNumber']}${info['patchNumber'] > 0 ? ', Patch #${info['patchNumber']}' : ''}) telah menggunakan versi terbaru yang paling optimal.',
                  style: const TextStyle(fontSize: 14, height: 1.4),
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
        }
        break;

      case 'SILENT_OTA_PATCH':
        // Unduh patch Shorebird secara diam-diam di latar belakang
        _downloadShorebirdPatchSilently();
        break;

      case 'FORCE_OTA_PATCH':
        // Tampilkan dialog proses unduh patch Shorebird
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AppUpdateDialog(
            result: result,
            isShorebirdPatch: true,
          ),
        );
        break;

      case 'FLEXIBLE_STORE_UPDATE':
      case 'FORCE_STORE_UPDATE':
        // Tampilkan dialog pembaruan native / APK Streaming
        showDialog(
          context: context,
          barrierDismissible: result.actionCode != 'FORCE_STORE_UPDATE',
          builder: (ctx) => AppUpdateDialog(
            result: result,
            isShorebirdPatch: false,
          ),
        );
        break;
    }
  }

  /// Unduh patch Shorebird secara silent
  static Future<void> _downloadShorebirdPatchSilently() async {
    try {
      if (isShorebirdAvailable) {
        final status = await _shorebird.checkForUpdate();
        if (status == UpdateStatus.outdated) {
          await _shorebird.update();
          debugPrint('Shorebird silent patch download completed successfully.');
        }
      }
    } catch (e) {
      debugPrint('Error downloading silent patch: $e');
    }
  }

  /// Unduh patch Shorebird dengan laporan progres
  static Future<bool> performShorebirdUpdate() async {
    try {
      if (isShorebirdAvailable) {
        final status = await _shorebird.checkForUpdate();
        if (status == UpdateStatus.outdated) {
          await _shorebird.update();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error performing Shorebird update: $e');
      return false;
    }
  }

  /// Buka URL unduhan APK / Play Store di browser eksternal
  static Future<void> openDownloadUrl(String? url) async {
    final target = url ?? 'https://github.com/rusdi-labs/coffee-hub-mobile/releases/latest';
    final uri = Uri.parse(target);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ================= ADMIN VERSION MANAGEMENT =================

  /// Ambil konfigurasi Version Gatekeeper dari backend (Khusus Admin)
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
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Perbarui konfigurasi Version Gatekeeper di backend (Khusus Admin)
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
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
