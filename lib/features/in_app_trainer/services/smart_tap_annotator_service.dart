import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image/image.dart' as img;

/// Service cerdas untuk mendeteksi batas bungkusan kopi otomatis ala Roboflow
/// saat pengguna mengetuk (tap) produk di layar.
class SmartTapAnnotatorService {
  /// Mendeteksi bounding box bungkusan kopi yang diketuk pada koordinat [tapNormalized] (0.0 .. 1.0).
  static Future<Rect> snapBoundingBox({
    required File imageFile,
    required Offset tapNormalized,
  }) async {
    // 1. Tier 1: On-Device ML Kit Object Detection (Paling Cepat & Akurat)
    try {
      final mlKitBox = await _detectWithMlKit(imageFile, tapNormalized);
      if (mlKitBox != null) {
        return _applyContextMargin(mlKitBox, marginPercent: 0.02);
      }
    } catch (e) {
      debugPrint('ML Kit Object Detection fallback: $e');
    }

    // 2. Tier 2: Background Isolate Edge-Snap Gradient Solver (Fallback Offline Roboflow)
    try {
      final edgeSnapBox = await Isolate.run(() {
        return _isolateEdgeSnapSolver(imageFile.path, tapNormalized.dx, tapNormalized.dy);
      });
      if (edgeSnapBox != null) {
        return _applyContextMargin(edgeSnapBox, marginPercent: 0.02);
      }
    } catch (e) {
      debugPrint('Edge snap fallback error: $e');
    }

    // 3. Fallback Default jika gambar homogen/tidak terbaca
    return _createCentroidBox(tapNormalized, sizeRatio: 0.55);
  }

  static Future<Rect?> _detectWithMlKit(File imageFile, Offset tapNormalized) async {
    final bool isMobilePlatform = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobilePlatform) return null;

    final options = ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: false,
      multipleObjects: true,
    );
    final detector = ObjectDetector(options: options);

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final objects = await detector.processImage(inputImage);
      if (objects.isEmpty) return null;

      // Ambil dimensi asli gambar
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final imgW = decoded.width.toDouble();
      final imgH = decoded.height.toDouble();

      final tapPixelX = tapNormalized.dx * imgW;
      final tapPixelY = tapNormalized.dy * imgH;

      // 1. Cari objek yang membungkus titik tap
      for (final obj in objects) {
        final box = obj.boundingBox;
        if (box.contains(Offset(tapPixelX, tapPixelY))) {
          return Rect.fromLTRB(
            box.left / imgW,
            box.top / imgH,
            box.right / imgW,
            box.bottom / imgH,
          );
        }
      }

      // 2. Jika tidak ada yang persis membungkus titik, ambil objek terdekat dengan tap
      objects.sort((a, b) {
        final distA = (Offset(a.boundingBox.center.dx, a.boundingBox.center.dy) -
                Offset(tapPixelX, tapPixelY))
            .distanceSquared;
        final distB = (Offset(b.boundingBox.center.dx, b.boundingBox.center.dy) -
                Offset(tapPixelX, tapPixelY))
            .distanceSquared;
        return distA.compareTo(distB);
      });

      final bestBox = objects.first.boundingBox;
      return Rect.fromLTRB(
        bestBox.left / imgW,
        bestBox.top / imgH,
        bestBox.right / imgW,
        bestBox.bottom / imgH,
      );
    } finally {
      try {
        await detector.close();
      } catch (e) {
        debugPrint('ML Kit Object Detector close safely ignored: $e');
      }
    }
  }

  /// Edge-Snap Solver di background isolate menggunakan gradient flood-fill
  static Rect? _isolateEdgeSnapSolver(String imagePath, double tapX, double tapY) {
    final file = File(imagePath);
    if (!file.existsSync()) return null;

    final bytes = file.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final w = decoded.width;
    final h = decoded.height;

    final startX = (tapX * w).clamp(0, w - 1).toInt();
    final startY = (tapY * h).clamp(0, h - 1).toInt();

    // Hitung luminance rata-rata pada titik tap sebagai seed
    final seedPixel = decoded.getPixel(startX, startY);
    final seedLum = seedPixel.luminanceNormalized;

    // Expand 4 arah (Left, Right, Top, Bottom) hingga gradient delta melebihi threshold tepi
    const threshold = 0.28;
    int minX = startX;
    int maxX = startX;
    int minY = startY;
    int maxY = startY;

    // Scan ke kiri
    for (int x = startX; x >= 0; x--) {
      final p = decoded.getPixel(x, startY);
      if ((p.luminanceNormalized - seedLum).abs() > threshold) {
        minX = x;
        break;
      }
      minX = x;
    }

    // Scan ke kanan
    for (int x = startX; x < w; x++) {
      final p = decoded.getPixel(x, startY);
      if ((p.luminanceNormalized - seedLum).abs() > threshold) {
        maxX = x;
        break;
      }
      maxX = x;
    }

    // Scan ke atas
    for (int y = startY; y >= 0; y--) {
      final p = decoded.getPixel(startX, y);
      if ((p.luminanceNormalized - seedLum).abs() > threshold) {
        minY = y;
        break;
      }
      minY = y;
    }

    // Scan ke bawah
    for (int y = startY; y < h; y++) {
      final p = decoded.getPixel(startX, y);
      if ((p.luminanceNormalized - seedLum).abs() > threshold) {
        maxY = y;
        break;
      }
      maxY = y;
    }

    final boxW = maxX - minX;
    final boxH = maxY - minY;

    // Pastikan ukuran kotak masuk akal (minimal 10% lebar gambar)
    if (boxW < w * 0.1 || boxH < h * 0.1) {
      return null;
    }

    return Rect.fromLTRB(
      minX / w,
      minY / h,
      maxX / w,
      maxY / h,
    );
  }

  static Rect _applyContextMargin(Rect box, {required double marginPercent}) {
    final left = math.max(0.0, box.left - marginPercent);
    final top = math.max(0.0, box.top - marginPercent);
    final right = math.min(1.0, box.right + marginPercent);
    final bottom = math.min(1.0, box.bottom + marginPercent);
    return Rect.fromLTRB(left, top, right, bottom);
  }

  static Rect _createCentroidBox(Offset tap, {required double sizeRatio}) {
    final half = sizeRatio / 2.0;
    final left = (tap.dx - half).clamp(0.0, 1.0 - sizeRatio);
    final top = (tap.dy - half).clamp(0.0, 1.0 - sizeRatio);
    return Rect.fromLTWH(left, top, sizeRatio, sizeRatio);
  }
}
