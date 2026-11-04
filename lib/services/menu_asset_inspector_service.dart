import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class InspectionResult {
  final bool isValid;
  final String format; // PNG, WEBP, SVG
  final String? errorMessage;
  final bool hasAlpha;

  const InspectionResult({
    required this.isValid,
    required this.format,
    this.errorMessage,
    required this.hasAlpha,
  });
}

class MenuAssetInspectorService {
  /// Memvalidasi transparansi aset gambar sebelum diunggah ke backend
  static Future<InspectionResult> inspectFile(File file) async {
    final path = file.path.toLowerCase();
    final bytes = await file.readAsBytes();

    if (path.endsWith('.svg')) {
      return _inspectSvg(bytes);
    } else if (path.endsWith('.png') || path.endsWith('.webp')) {
      return compute(_inspectRasterBytes, bytes);
    } else {
      return const InspectionResult(
        isValid: false,
        format: 'UNKNOWN',
        hasAlpha: false,
        errorMessage: 'Format tidak didukung. Mohon gunakan PNG, WebP transparan, atau SVG.',
      );
    }
  }

  static InspectionResult _inspectSvg(Uint8List bytes) {
    try {
      final text = String.fromCharCodes(bytes);
      if (!text.contains('<svg') || !text.contains('</svg>')) {
        return const InspectionResult(
          isValid: false,
          format: 'SVG',
          hasAlpha: false,
          errorMessage: 'Struktur SVG tidak valid atau korup.',
        );
      }
      return const InspectionResult(
        isValid: true,
        format: 'SVG',
        hasAlpha: true,
      );
    } catch (e) {
      return InspectionResult(
        isValid: false,
        format: 'SVG',
        hasAlpha: false,
        errorMessage: 'Gagal memproses file SVG: $e',
      );
    }
  }

  /// Dijalankan di Isolate terpisah agar UI tablet tidak lag/freeze saat decode image
  static InspectionResult _inspectRasterBytes(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) {
      return const InspectionResult(
        isValid: false,
        format: 'RASTER',
        hasAlpha: false,
        errorMessage: 'Gagal mendekode byte gambar raster.',
      );
    }

    if (!image.hasAlpha) {
      return const InspectionResult(
        isValid: false,
        format: 'PNG',
        hasAlpha: false,
        errorMessage: 'Gambar tidak memiliki kanal Alpha (transparansi). Gunakan PNG/WebP transparan.',
      );
    }

    final width = image.width;
    final height = image.height;

    // Periksa 4 sudut gambar
    final corners = [
      image.getPixel(0, 0),
      image.getPixel(width - 1, 0),
      image.getPixel(0, height - 1),
      image.getPixel(width - 1, height - 1),
    ];

    int opaqueCorners = 0;
    for (final pixel in corners) {
      if (pixel.a > 15) {
        opaqueCorners++;
      }
    }

    if (opaqueCorners >= 2) {
      return const InspectionResult(
        isValid: false,
        format: 'PNG',
        hasAlpha: true,
        errorMessage: 'Sudut gambar terdeteksi padat (tidak transparan). Pastikan background sudah di-cutout/dihapus.',
      );
    }

    return const InspectionResult(
      isValid: true,
      format: 'PNG',
      hasAlpha: true,
    );
  }
}
