import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QrisImageSaveResult {
  final bool success;
  final String displayMessage;
  final String? savedFilePath;

  const QrisImageSaveResult({
    required this.success,
    required this.displayMessage,
    this.savedFilePath,
  });
}

/// Layanan tangguh lintas-platform (Android, iOS, Windows, macOS) untuk menangkap
/// kartu QRIS Dinamis `RepaintBoundary` menjadi PNG HD (3x DPI) dan menyimpannya ke Galeri/Pictures.
class QrisImageSaverService {
  QrisImageSaverService._();

  static Future<Uint8List> captureRepaintBoundaryPng(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    final ctx = boundaryKey.currentContext;
    if (ctx == null || !ctx.mounted) {
      throw Exception('Kartu QRIS belum terpasang di layar.');
    }
    final renderObj = ctx.findRenderObject();
    if (renderObj is! RenderRepaintBoundary) {
      throw Exception('RenderRepaintBoundary kartu QRIS tidak ditemukan.');
    }
    final image = await renderObj.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) {
      throw Exception('Gagal mengonversi gambar QRIS menjadi PNG.');
    }
    return byteData.buffer.asUint8List();
  }

  /// Menyimpan gambar PNG QRIS ke Galeri (Android/iOS) atau folder Pictures/CoffeeLabs (Windows/Desktop)
  /// dengan fallback otomatis ke folder aplikasi + Share Sheet agar 100% tidak pernah gagal!
  static Future<QrisImageSaveResult> saveQrisImage({
    required Uint8List pngBytes,
    required String baseFileName,
    required String merchantName,
    required String formattedAmount,
  }) async {
    final safeName = baseFileName.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');

    if (kIsWeb) {
      return const QrisImageSaveResult(
        success: false,
        displayMessage:
            'Pada browser web, silakan screenshot kartu QRIS di atas untuk memindai.',
      );
    }

    // 1. Mobile (Android / iOS): utamakan Galeri foto resmi via `gal`
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final hasPerm = await Gal.hasPermission(toAlbum: false);
        if (!hasPerm) {
          await Gal.requestPermission(toAlbum: false);
        }
        await Gal.putImageBytes(pngBytes, name: safeName);
        return QrisImageSaveResult(
          success: true,
          displayMessage:
              'QRIS $merchantName ($formattedAmount) tersimpan di Galeri! Buka GoPay/DANA/OVO/BCA/Livin\' -> Scan QR -> Pilih dari Galeri.',
        );
      } catch (_) {
        // Fallback aman: simpan ke direktori lokal & buka share sheet agar user tetap bisa menyimpan/kirim
        final fallbackFile = await _writeToSafeLocalFile(pngBytes, '$safeName.png');
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(fallbackFile.path, mimeType: 'image/png')],
            text: 'QRIS $merchantName sebesar $formattedAmount',
          ),
        );
        return QrisImageSaveResult(
          success: true,
          savedFilePath: fallbackFile.path,
          displayMessage:
              'QRIS $merchantName ($formattedAmount) siap disimpan/dibagikan (${p.basename(fallbackFile.path)}).',
        );
      }
    }

    // 2. Desktop (Windows / macOS / Linux): simpan langsung ke folder Pictures/CoffeeLabs (atau Downloads)
    final savedFile = await _writeToDesktopPicturesOrDownloads(
      pngBytes,
      '$safeName.png',
    );
    return QrisImageSaveResult(
      success: true,
      savedFilePath: savedFile.path,
      displayMessage:
          'Gambar QRIS $merchantName ($formattedAmount) berhasil disimpan ke:\n${savedFile.path}',
    );
  }

  static Future<void> shareQrisImage({
    required Uint8List pngBytes,
    required String baseFileName,
    required String shareText,
  }) async {
    final safeName = baseFileName.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    final file = await _writeToSafeLocalFile(pngBytes, '$safeName.png');
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: shareText,
      ),
    );
  }

  static Future<File> _writeToDesktopPicturesOrDownloads(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null && userProfile.isNotEmpty) {
          final picsDir = Directory(p.join(userProfile, 'Pictures', 'CoffeeLabs'));
          if (!await picsDir.exists()) {
            await picsDir.create(recursive: true);
          }
          final out = File(p.join(picsDir.path, fileName));
          await out.writeAsBytes(bytes, flush: true);
          return out;
        }
      }
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        final targetDir = Directory(p.join(downloads.path, 'CoffeeLabs'));
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        final out = File(p.join(targetDir.path, fileName));
        await out.writeAsBytes(bytes, flush: true);
        return out;
      }
    } catch (_) {}
    return _writeToSafeLocalFile(bytes, fileName);
  }

  static Future<File> _writeToSafeLocalFile(
    Uint8List bytes,
    String fileName,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final qrisDir = Directory(p.join(dir.path, 'qris_cards'));
    if (!await qrisDir.exists()) {
      await qrisDir.create(recursive: true);
    }
    final file = File(p.join(qrisDir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
