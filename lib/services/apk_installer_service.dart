import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ApkInstallerService {
  static const MethodChannel _channel = MethodChannel('com.coffeelabs.app/apk_installer');

  /// Cek apakah izin pasang aplikasi dari sumber tidak dikenal sudah aktif
  static Future<bool> canRequestPackageInstalls() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    try {
      final bool allowed = await _channel.invokeMethod('canRequestPackageInstalls') ?? true;
      return allowed;
    } catch (e) {
      debugPrint('Error checking package install permission: $e');
      return true;
    }
  }

  /// Buka pengaturan izin pasang aplikasi tidak dikenal di Android
  static Future<bool> openInstallPermissionSettings() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final bool opened = await _channel.invokeMethod('openInstallPermissionSettings') ?? false;
      return opened;
    } catch (e) {
      debugPrint('Error opening install settings: $e');
      return false;
    }
  }

  /// Pasang file APK secara native menggunakan Intent dan FileProvider
  static Future<bool> installApk(String filePath) async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final bool success = await _channel.invokeMethod('installApk', {'filePath': filePath}) ?? false;
      return success;
    } catch (e) {
      debugPrint('Error installing APK: $e');
      return false;
    }
  }

  /// Unduh APK dengan pelaporan progres real-time lalu otomatis buka penginstal Android
  static Future<bool> downloadAndInstallApk({
    required String downloadUrl,
    required void Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      // Fallback untuk platform non-Android (membuka link browser)
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return true;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/coffee_labs_update.apk';

      // Hapus file sisa unduhan sebelumnya jika ada
      final oldFile = File(savePath);
      if (await oldFile.exists()) {
        try {
          await oldFile.delete();
        } catch (_) {}
      }

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(minutes: 5),
          headers: {
            'User-Agent': 'CoffeeLabs-Mobile-AutoUpdater',
          },
        ),
      );

      await dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
        deleteOnError: true,
      );

      // Verifikasi bahwa file berhasil ditulis
      final downloadedFile = File(savePath);
      if (!await downloadedFile.exists() || await downloadedFile.length() == 0) {
        throw Exception('File APK yang diunduh kosong atau tidak ditemukan.');
      }

      // Jalankan Intent instalasi sistem Android
      return await installApk(savePath);
    } catch (e) {
      debugPrint('Gagal mengunduh atau memasang APK: $e');
      rethrow;
    }
  }
}
