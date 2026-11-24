import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'trial_service.dart';

/// Layanan sinkronisasi konten ringan (0-Second Hot Content Delta Sync).
///
/// Saat server menaikkan `content_manifest_version`, aplikasi hanya menarik
/// pembaruan data/kebijakan/katalog JSON (beberapa KB) secara senyap tanpa
/// perlu mengunduh APK maupun memulai ulang aplikasi.
class AppHotContentSyncService {
  AppHotContentSyncService._();

  static const String _manifestVersionKey = 'coffeehub_content_manifest_version_v1';
  static const String _lastSyncedAtKey = 'coffeehub_content_manifest_synced_at_v1';

  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);
  static bool _isSyncing = false;

  static Future<int> getLocalManifestVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_manifestVersionKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Sinkronkan konten ringan jika server memiliki `serverManifestVersion` lebih baru.
  /// Mengembalikan `true` jika sinkronisasi delta berhasil dijalankan.
  static Future<bool> syncIfNeeded(int serverManifestVersion) async {
    if (serverManifestVersion <= 0 || _isSyncing) return false;
    _isSyncing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getInt(_manifestVersionKey) ?? 0;
      if (localVersion >= serverManifestVersion) {
        return false;
      }

      // Segarkan kebijakan & cache katalog ringan di latar belakang tanpa restart
      ApiService.clearMemoryCache();
      await TrialService.getPolicy(refreshFromBackend: true)
          .timeout(const Duration(seconds: 6))
          .catchError((_) => TrialService.currentPolicySync);

      await prefs.setInt(_manifestVersionKey, serverManifestVersion);
      await prefs.setString(_lastSyncedAtKey, DateTime.now().toUtc().toIso8601String());
      ApiService.changeNotifier.value++;
      changeNotifier.value++;
      debugPrint('⚡ Hot Content Delta Sync selesai -> manifest v$serverManifestVersion');
      return true;
    } catch (e) {
      debugPrint('⚠️ Hot Content Delta Sync dilewati: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }
}
