import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../domain/annotated_training_sample.dart';

/// Item citra hasil augmentasi siap pakai untuk ekstraksi fitur MobileNetV3.
class AugmentedImageTensor {
  final String sampleId;
  final String transformName;
  final img.Image image224;
  final Float32List normalizedFloats; // 224 * 224 * 3 (ImageNet Normalized)
  final Uint8List previewJpegBytes; // Thumbnail untuk UI progress feed

  const AugmentedImageTensor({
    required this.sampleId,
    required this.transformName,
    required this.image224,
    required this.normalizedFloats,
    required this.previewJpegBytes,
  });
}

/// Status kemajuan augmentasi data untuk Riverpod controller
class AugmentationTelemetry {
  final int current;
  final int total;
  final String currentTransform;
  final Uint8List? latestPreviewBytes;

  const AugmentationTelemetry({
    required this.current,
    required this.total,
    required this.currentTransform,
    this.latestPreviewBytes,
  });
}

/// Pipeline 15x Augmentasi Data Profesional Berjalan di Background Isolate.
class AugmentationPipelineIsolate {
  /// Mengeksekusi augmentasi data dari sampel foto asli:
  /// Minimal 3 foto x 15 variasi = 45 foto training bervariasi tinggi.
  static Future<List<AugmentedImageTensor>> runPipeline({
    required List<AnnotatedTrainingSample> samples,
    void Function(AugmentationTelemetry)? onProgress,
  }) async {
    final sampleDataList = samples.map((s) {
      return _SampleInputDto(
        id: s.id,
        imagePath: s.imagePath,
        left: s.boundingBoxNormalized.left,
        top: s.boundingBoxNormalized.top,
        right: s.boundingBoxNormalized.right,
        bottom: s.boundingBoxNormalized.bottom,
      );
    }).toList();

    // Jalankan dalam Isolate.run agar UI tetap 120 FPS tanpa lag
    final rawResults = await Isolate.run(() {
      return _executeIsolateWork(sampleDataList);
    });

    final results = <AugmentedImageTensor>[];
    for (int i = 0; i < rawResults.length; i++) {
      final r = rawResults[i];
      final decoded = img.decodeImage(r.jpegBytes);
      if (decoded != null) {
        final tensor = AugmentedImageTensor(
          sampleId: r.sampleId,
          transformName: r.transformName,
          image224: decoded,
          normalizedFloats: r.normalizedFloats,
          previewJpegBytes: r.jpegBytes,
        );
        results.add(tensor);

        onProgress?.call(AugmentationTelemetry(
          current: i + 1,
          total: rawResults.length,
          currentTransform: r.transformName,
          latestPreviewBytes: r.jpegBytes,
        ));
      }
    }

    return results;
  }

  static List<_RawIsolateResult> _executeIsolateWork(List<_SampleInputDto> samples) {
    final outputList = <_RawIsolateResult>[];

    for (final sample in samples) {
      final file = File(sample.imagePath);
      if (!file.existsSync()) continue;

      final fullBytes = file.readAsBytesSync();
      final fullImage = img.decodeImage(fullBytes);
      if (fullImage == null) continue;

      // 1. Crop area bounding box dengan context margin
      final w = fullImage.width;
      final h = fullImage.height;

      final cropX = (sample.left * w).clamp(0, w - 1).toInt();
      final cropY = (sample.top * h).clamp(0, h - 1).toInt();
      final cropW = ((sample.right - sample.left) * w).clamp(1, w - cropX).toInt();
      final cropH = ((sample.bottom - sample.top) * h).clamp(1, h - cropY).toInt();

      final baseCrop = img.copyCrop(fullImage, x: cropX, y: cropY, width: cropW, height: cropH);
      final base224 = img.copyResize(baseCrop, width: 224, height: 224, interpolation: img.Interpolation.linear);

      // 2. Jalankan 15 Transformasi Augmentasi Profesional
      final variations = _generate15Transforms(base224);

      for (final entry in variations.entries) {
        final transformed224 = entry.value;
        final normFloats = _normalizeImageNet(transformed224);
        final jpegBytes = Uint8List.fromList(img.encodeJpg(transformed224, quality: 78));

        outputList.add(_RawIsolateResult(
          sampleId: sample.id,
          transformName: entry.key,
          normalizedFloats: normFloats,
          jpegBytes: jpegBytes,
        ));
      }
    }

    return outputList;
  }

  /// Menghasilkan 15 variasi citra dari 1 base crop 224x224
  static Map<String, img.Image> _generate15Transforms(img.Image base) {
    final transforms = <String, img.Image>{};

    // 1. Base Clean Crop
    transforms['orig_clean'] = img.Image.from(base);

    // 2. Clockwise Tilt (+12 derajat)
    transforms['rot_pos_12'] = _rotateSafe(base, 12);

    // 3. Counter-Clockwise Tilt (-12 derajat)
    transforms['rot_neg_12'] = _rotateSafe(base, -12);

    // 4. Top-Down Perspective Warp (Simulasi kemasan di atas meja bar)
    transforms['persp_top_down'] = _skewVertical(base, 0.14);

    // 5. Side-Angle Perspective Warp (Simulasi kemasan cembung CO2)
    transforms['persp_side_skew'] = _skewHorizontal(base, 0.14);

    // 6. Warm Café Lamp 2700K (Tungsten Warm Ambient)
    transforms['warm_cafe_2700k'] = _shiftRgbGamma(base, rMul: 1.14, gMul: 1.05, bMul: 0.86, gamma: 1.10);

    // 7. Low-Light Dim Bar (-28% brightness, +15% contrast, gamma 1.3)
    transforms['dim_bar_lowlight'] = _adjustLight(base, brightness: -0.28, contrast: 1.15, gamma: 1.30);

    // 8. Bright Window Overexposed (+22% brightness, gamma 0.78)
    transforms['bright_window_overexposed'] = _adjustLight(base, brightness: 0.22, contrast: 0.95, gamma: 0.78);

    // 9. Foil Specular Glare 1 (Pantulan lampu foil di kuadran kiri-atas)
    transforms['foil_specular_glare_1'] = _applyFoilGlare(base, cxRatio: 0.32, cyRatio: 0.30);

    // 10. Foil Specular Glare 2 (Pantulan lampu foil di tengah-kanan)
    transforms['foil_specular_glare_2'] = _applyFoilGlare(base, cxRatio: 0.70, cyRatio: 0.55);

    // 11. Finger Cutout Occlusion (Sebagian bungkus tertutup jari barista)
    transforms['finger_cutout_occlusion'] = _applyFingerOcclusion(base);

    // 12. Tight Center Zoom (88% crop di-upscale ke 224x224)
    transforms['zoom_in_90'] = _zoomIn(base, 0.88);

    // 13. Wide Context Zoom (112% scaled down dengan neutral frame)
    transforms['zoom_out_112'] = _zoomOut(base, 0.88);

    // 14. Motion Blur 3x3 (Getaran tangan barista saat memotret)
    transforms['motion_blur_3x3'] = _applyMotionBlur(base);

    // 15. Compound Hard Augmentation (Rotasi +6° + Warm Light + Sensor Noise)
    transforms['iso_gaussian_noise_combo'] = _applyCompoundHard(base);

    return transforms;
  }

  // --- Helper Operasi Transformasi Matematika Citra ---

  static img.Image _rotateSafe(img.Image src, num angleDeg) {
    final rotated = img.copyRotate(src, angle: angleDeg, interpolation: img.Interpolation.linear);
    return img.copyResize(rotated, width: 224, height: 224);
  }

  static img.Image _skewVertical(img.Image src, double factor) {
    final out = img.Image(width: 224, height: 224);
    for (int y = 0; y < 224; y++) {
      final scaleX = 1.0 - (factor * (y / 224.0));
      for (int x = 0; x < 224; x++) {
        final srcX = ((x - 112) / scaleX + 112).clamp(0, 223).toInt();
        out.setPixel(x, y, src.getPixel(srcX, y));
      }
    }
    return out;
  }

  static img.Image _skewHorizontal(img.Image src, double factor) {
    final out = img.Image(width: 224, height: 224);
    for (int x = 0; x < 224; x++) {
      final scaleY = 1.0 - (factor * (x / 224.0));
      for (int y = 0; y < 224; y++) {
        final srcY = ((y - 112) / scaleY + 112).clamp(0, 223).toInt();
        out.setPixel(x, y, src.getPixel(x, srcY));
      }
    }
    return out;
  }

  static img.Image _shiftRgbGamma(img.Image src,
      {required double rMul, required double gMul, required double bMul, required double gamma}) {
    final out = img.Image.from(src);
    for (final p in out) {
      var r = math.pow((p.r / 255.0) * rMul, gamma) * 255.0;
      var g = math.pow((p.g / 255.0) * gMul, gamma) * 255.0;
      var b = math.pow((p.b / 255.0) * bMul, gamma) * 255.0;
      p.r = r.clamp(0, 255);
      p.g = g.clamp(0, 255);
      p.b = b.clamp(0, 255);
    }
    return out;
  }

  static img.Image _adjustLight(img.Image src,
      {required double brightness, required double contrast, required double gamma}) {
    final out = img.Image.from(src);
    for (final p in out) {
      var r = math.pow(((p.r / 255.0 + brightness - 0.5) * contrast + 0.5), gamma) * 255.0;
      var g = math.pow(((p.g / 255.0 + brightness - 0.5) * contrast + 0.5), gamma) * 255.0;
      var b = math.pow(((p.b / 255.0 + brightness - 0.5) * contrast + 0.5), gamma) * 255.0;
      p.r = r.clamp(0, 255);
      p.g = g.clamp(0, 255);
      p.b = b.clamp(0, 255);
    }
    return out;
  }

  static img.Image _applyFoilGlare(img.Image src, {required double cxRatio, required double cyRatio}) {
    final out = img.Image.from(src);
    final cx = cxRatio * 224.0;
    final cy = cyRatio * 224.0;
    const rx = 36.0;
    const ry = 22.0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final dx = (x - cx) / rx;
        final dy = (y - cy) / ry;
        final dist = dx * dx + dy * dy;
        if (dist < 1.0) {
          final alpha = (1.0 - dist) * 0.62;
          final p = out.getPixel(x, y);
          p.r = (p.r * (1.0 - alpha) + 255 * alpha).clamp(0, 255);
          p.g = (p.g * (1.0 - alpha) + 255 * alpha).clamp(0, 255);
          p.b = (p.b * (1.0 - alpha) + 255 * alpha).clamp(0, 255);
        }
      }
    }
    return out;
  }

  static img.Image _applyFingerOcclusion(img.Image src) {
    final out = img.Image.from(src);
    // Tutup 14% pojok kanan-bawah dengan blok warna netral/kulit gelap
    const startX = 160;
    const startY = 165;
    for (int y = startY; y < 224; y++) {
      for (int x = startX; x < 224; x++) {
        final p = out.getPixel(x, y);
        p.r = 65;
        p.g = 48;
        p.b = 38;
      }
    }
    return out;
  }

  static img.Image _zoomIn(img.Image src, double factor) {
    final cropSize = (224 * factor).toInt();
    final offset = (224 - cropSize) ~/ 2;
    final cropped = img.copyCrop(src, x: offset, y: offset, width: cropSize, height: cropSize);
    return img.copyResize(cropped, width: 224, height: 224);
  }

  static img.Image _zoomOut(img.Image src, double factor) {
    final targetSize = (224 * factor).toInt();
    final resized = img.copyResize(src, width: targetSize, height: targetSize);
    final out = img.Image(width: 224, height: 224);
    // Background netral
    img.fill(out, color: img.ColorRgb8(24, 18, 14));
    final offset = (224 - targetSize) ~/ 2;
    img.compositeImage(out, resized, dstX: offset, dstY: offset);
    return out;
  }

  static img.Image _applyMotionBlur(img.Image src) {
    final out = img.Image(width: 224, height: 224);
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        int rSum = 0, gSum = 0, bSum = 0;
        int count = 0;
        for (int k = -1; k <= 1; k++) {
          final nx = (x + k).clamp(0, 223);
          final ny = (y + k).clamp(0, 223);
          final p = src.getPixel(nx, ny);
          rSum += p.r.toInt();
          gSum += p.g.toInt();
          bSum += p.b.toInt();
          count++;
        }
        out.setPixelRgb(x, y, rSum ~/ count, gSum ~/ count, bSum ~/ count);
      }
    }
    return out;
  }

  static img.Image _applyCompoundHard(img.Image src) {
    final rotated = _rotateSafe(src, 6);
    final warm = _shiftRgbGamma(rotated, rMul: 1.10, gMul: 1.03, bMul: 0.90, gamma: 1.05);
    final rng = math.Random(42);
    for (final p in warm) {
      final noise = (rng.nextDouble() - 0.5) * 18.0;
      p.r = (p.r + noise).clamp(0, 255);
      p.g = (p.g + noise).clamp(0, 255);
      p.b = (p.b + noise).clamp(0, 255);
    }
    return warm;
  }

  /// Normalisasi standar ImageNet (RGB): (val / 255 - mean) / std
  static Float32List _normalizeImageNet(img.Image src) {
    final floats = Float32List(224 * 224 * 3);
    int idx = 0;
    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final p = src.getPixel(x, y);
        floats[idx++] = ((p.r / 255.0) - mean[0]) / std[0];
        floats[idx++] = ((p.g / 255.0) - mean[1]) / std[1];
        floats[idx++] = ((p.b / 255.0) - mean[2]) / std[2];
      }
    }
    return floats;
  }
}

class _SampleInputDto {
  final String id;
  final String imagePath;
  final double left;
  final double top;
  final double right;
  final double bottom;

  const _SampleInputDto({
    required this.id,
    required this.imagePath,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}

class _RawIsolateResult {
  final String sampleId;
  final String transformName;
  final Float32List normalizedFloats;
  final Uint8List jpegBytes;

  const _RawIsolateResult({
    required this.sampleId,
    required this.transformName,
    required this.normalizedFloats,
    required this.jpegBytes,
  });
}
