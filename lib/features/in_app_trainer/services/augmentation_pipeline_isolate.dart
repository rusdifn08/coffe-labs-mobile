import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../domain/annotated_training_sample.dart';
import 'visual_bag_embedder.dart';

/// Item citra hasil augmentasi beserta embedding visual 512-D (dihitung di isolate).
class AugmentedImageTensor {
  final String sampleId;
  final String transformName;
  final Float32List embedding; // VisualBagEmbedder.dim, L2-normalized
  final Uint8List previewJpegBytes; // Thumbnail untuk UI progress feed

  const AugmentedImageTensor({
    required this.sampleId,
    required this.transformName,
    required this.embedding,
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

/// Pipeline 10x Augmentasi Data Profesional Berjalan di Background Isolate.
class AugmentationPipelineIsolate {
  /// Mengeksekusi augmentasi data dari sampel foto asli:
  /// Minimal 3 foto x 10 variasi = 30 foto training bervariasi tinggi.
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

    // Satu Isolate.run per foto: UI tetap mulus dan progres dilaporkan per batch nyata.
    final expectedTotal = sampleDataList.length * transformsPerSample;
    final results = <AugmentedImageTensor>[];
    for (final dto in sampleDataList) {
      final batch = await Isolate.run(() => _executeIsolateWork([dto]));
      for (final r in batch) {
        results.add(AugmentedImageTensor(
          sampleId: r.sampleId,
          transformName: r.transformName,
          embedding: r.embedding,
          previewJpegBytes: r.jpegBytes,
        ));
      }
      if (batch.isNotEmpty) {
        onProgress?.call(AugmentationTelemetry(
          current: results.length,
          total: expectedTotal,
          currentTransform: '${batch.last.transformName} (foto ${dto.id})',
          latestPreviewBytes: batch.last.jpegBytes,
        ));
      }
    }

    return results;
  }

  static const int transformsPerSample = 10;

  static List<_RawIsolateResult> _executeIsolateWork(List<_SampleInputDto> samples) {
    final outputList = <_RawIsolateResult>[];

    for (final sample in samples) {
      final file = File(sample.imagePath);
      if (!file.existsSync()) continue;

      final fullBytes = file.readAsBytesSync();
      final decodedImage = img.decodeImage(fullBytes);
      if (decodedImage == null) continue;
      // Bounding box dinormalisasi terhadap foto tegak (EXIF), sama seperti scanner.
      final fullImage = img.bakeOrientation(decodedImage);

      // 1. Crop area bounding box dengan context margin
      final w = fullImage.width;
      final h = fullImage.height;

      final cropX = (sample.left * w).clamp(0, w - 1).toInt();
      final cropY = (sample.top * h).clamp(0, h - 1).toInt();
      final cropW = ((sample.right - sample.left) * w).clamp(1, w - cropX).toInt();
      final cropH = ((sample.bottom - sample.top) * h).clamp(1, h - cropY).toInt();

      final baseCrop = img.copyCrop(fullImage, x: cropX, y: cropY, width: cropW, height: cropH);
      final base224 = img.copyResize(baseCrop, width: 224, height: 224, interpolation: img.Interpolation.linear);

      // 2. Jalankan 10 Transformasi Augmentasi Profesional (3 Foto -> 30 Citra)
      final variations = generate10Transforms(base224);

      for (final entry in variations.entries) {
        final transformed224 = entry.value;
        final jpegBytes = Uint8List.fromList(img.encodeJpg(transformed224, quality: 78));

        outputList.add(_RawIsolateResult(
          sampleId: sample.id,
          transformName: entry.key,
          embedding: VisualBagEmbedder.embed(transformed224),
          jpegBytes: jpegBytes,
        ));
      }
    }

    return outputList;
  }

  /// Menghasilkan 10 variasi citra dari 1 base crop 224x224 (3 sampel x 10 = 30 variasi)
  static Map<String, img.Image> generate10Transforms(img.Image base) {
    final transforms = <String, img.Image>{};

    // 1. Base Clean Crop
    transforms['orig_clean'] = img.Image.from(base);

    // 2. Clockwise Tilt (+8 derajat)
    transforms['rot_pos_8'] = _rotateSafe(base, 8);

    // 3. Counter-Clockwise Tilt (-8 derajat)
    transforms['rot_neg_8'] = _rotateSafe(base, -8);

    // 4. Top-Down Perspective Warp (Simulasi kemasan di atas meja bar)
    transforms['persp_top_down'] = _skewVertical(base, 0.12);

    // 5. Side-Angle Perspective Warp (Simulasi kemasan cembung)
    transforms['persp_side_skew'] = _skewHorizontal(base, 0.12);

    // 6. Warm Café Lamp 2700K (Tungsten Warm Ambient)
    transforms['warm_cafe_2700k'] = _shiftRgbGamma(base, rMul: 1.14, gMul: 1.05, bMul: 0.86, gamma: 1.10);

    // 7. Cool Retail Daylight (Fluorescent Supermarket)
    transforms['cool_retail_daylight'] = _shiftRgbGamma(base, rMul: 0.94, gMul: 1.02, bMul: 1.12, gamma: 0.95);

    // 8. Low-Light Dim Bar & Crease (-22% brightness, +15% contrast)
    transforms['dim_bar_crease'] = _adjustLight(base, brightness: -0.22, contrast: 1.15, gamma: 1.20);

    // 9. Bright Window Glare (Pantulan cahaya jendela cafe)
    transforms['bright_window_glare'] = _applyFoilGlare(base, cxRatio: 0.35, cyRatio: 0.30);

    // 10. Motion Blur 3x3 (Getaran tangan barista saat memotret)
    transforms['motion_blur_3x3'] = _applyMotionBlur(base);

    return transforms;
  }

  // Alias kompatibilitas
  static Map<String, img.Image> generate15Transforms(img.Image base) => generate10Transforms(base);

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
  final Float32List embedding;
  final Uint8List jpegBytes;

  const _RawIsolateResult({
    required this.sampleId,
    required this.transformName,
    required this.embedding,
    required this.jpegBytes,
  });
}
