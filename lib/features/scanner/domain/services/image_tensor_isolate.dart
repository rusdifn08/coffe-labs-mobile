import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Represents an ImageNet-normalized 4D tensor [1, 256, 256, 3]
class ImageTensorSample {
  final String sampleId;
  final String transformName;
  final List<List<List<List<double>>>> tensor; // [1, 256, 256, 3]
  final Uint8List? previewJpegBytes;

  const ImageTensorSample({
    required this.sampleId,
    required this.transformName,
    required this.tensor,
    this.previewJpegBytes,
  });
}

/// DTO for passing image paths and bounding boxes across Isolate boundaries
class PreprocessInputDto {
  final String sampleId;
  final String imagePath;
  final double left;
  final double top;
  final double right;
  final double bottom;

  const PreprocessInputDto({
    required this.sampleId,
    required this.imagePath,
    this.left = 0.075,
    this.top = 0.075,
    this.right = 0.925,
    this.bottom = 0.925,
  });
}

/// Pure Dart background Isolate preprocessing and 10x augmentation pipeline (3 photos -> 30 tensors)
class ImageTensorIsolate {
  static const int targetSize = 256;
  static const int transformsPerPhoto = 10;
  static const double meanR = 0.485;
  static const double meanG = 0.456;
  static const double meanB = 0.406;
  static const double stdR = 0.229;
  static const double stdG = 0.224;
  static const double stdB = 0.225;

  /// Crops and ImageNet-normalizes a single image into [1, 256, 256, 3] tensor
  static Future<List<List<List<List<double>>>>> preprocessSingleImage(
    File imageFile, {
    Rect? boundingBox,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final leftNorm = boundingBox != null ? boundingBox.left : 0.075;
    final topNorm = boundingBox != null ? boundingBox.top : 0.075;
    final rightNorm = boundingBox != null ? boundingBox.right : 0.925;
    final bottomNorm = boundingBox != null ? boundingBox.bottom : 0.925;

    return await Isolate.run<List<List<List<List<double>>>>>(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        return _emptyTensor();
      }
      final upright = img.bakeOrientation(decoded);
      final w = upright.width;
      final h = upright.height;

      final cropX = (leftNorm * w).clamp(0, w - 1).toInt();
      final cropY = (topNorm * h).clamp(0, h - 1).toInt();
      final cropW = ((rightNorm - leftNorm) * w).clamp(1, w - cropX).toInt();
      final cropH = ((bottomNorm - topNorm) * h).clamp(1, h - cropY).toInt();

      final cropped = img.copyCrop(upright, x: cropX, y: cropY, width: cropW, height: cropH);
      final resized = img.copyResize(
        cropped,
        width: targetSize,
        height: targetSize,
        interpolation: img.Interpolation.linear,
      );

      return _imageToTensor(resized);
    });
  }

  /// Runs multi-sample augmentation in Isolate: generates exactly 10 augmented variations per photo
  /// (e.g. 3 photos -> 30 distinct tensors, 5 photos -> 50 tensors)
  static Future<List<ImageTensorSample>> augmentPhotos({
    required List<PreprocessInputDto> inputs,
    void Function(int current, int total, String transformName, Uint8List? previewBytes)? onProgress,
  }) async {
    final expectedTotal = inputs.length * transformsPerPhoto;
    final allResults = <ImageTensorSample>[];

    for (final dto in inputs) {
      final batch = await Isolate.run<List<_AugmentedBatchDto>>(() {
        return _isolateAugmentSingle(dto);
      });

      for (final item in batch) {
        allResults.add(ImageTensorSample(
          sampleId: item.sampleId,
          transformName: item.transformName,
          tensor: item.tensor,
          previewJpegBytes: item.previewBytes,
        ));

        onProgress?.call(
          allResults.length,
          expectedTotal,
          item.transformName,
          item.previewBytes,
        );
      }
    }

    return allResults;
  }

  // --- Internal Isolate Pipeline ---

  static List<_AugmentedBatchDto> _isolateAugmentSingle(PreprocessInputDto input) {
    final file = File(input.imagePath);
    if (!file.existsSync()) return [];

    final bytes = file.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return [];

    final upright = img.bakeOrientation(decoded);
    final w = upright.width;
    final h = upright.height;

    final cropX = (input.left * w).clamp(0, w - 1).toInt();
    final cropY = (input.top * h).clamp(0, h - 1).toInt();
    final cropW = ((input.right - input.left) * w).clamp(1, w - cropX).toInt();
    final cropH = ((input.bottom - input.top) * h).clamp(1, h - cropY).toInt();

    final baseCrop = img.copyCrop(upright, x: cropX, y: cropY, width: cropW, height: cropH);
    final base256 = img.copyResize(
      baseCrop,
      width: targetSize,
      height: targetSize,
      interpolation: img.Interpolation.linear,
    );

    final results = <_AugmentedBatchDto>[];

    // 1. Original 256x256 Base Normalized Pouch
    results.add(_toBatchDto(input.sampleId, 'original_crop', base256));

    // 2. Horizontal Flip (Package Symmetry Invariance)
    final flipped = img.flipHorizontal(img.Image.from(base256));
    results.add(_toBatchDto(input.sampleId, 'mirror_flip', flipped));

    // 3. Rotation (+8 deg) + 92% Center Zoom Crop
    final rotPos = img.copyRotate(base256, angle: 8, interpolation: img.Interpolation.linear);
    results.add(_toBatchDto(input.sampleId, 'rotate_cw_8', _centerZoomCrop(rotPos, 0.92)));

    // 4. Rotation (-8 deg) + 92% Center Zoom Crop
    final rotNeg = img.copyRotate(base256, angle: -8, interpolation: img.Interpolation.linear);
    results.add(_toBatchDto(input.sampleId, 'rotate_ccw_8', _centerZoomCrop(rotNeg, 0.92)));

    // 5. Warm Cafe Ambient Lighting (+12% Red, -6% Blue, +8% Contrast)
    final warm = _adjustLightingTone(base256, rMul: 1.12, gMul: 1.02, bMul: 0.94, brightness: 1.05, contrast: 1.08);
    results.add(_toBatchDto(input.sampleId, 'warm_cafe_ambient', warm));

    // 6. Cool Fluorescent Supermarket Lighting (+10% Blue, -5% Red, +5% Brightness)
    final cool = _adjustLightingTone(base256, rMul: 0.95, gMul: 1.01, bMul: 1.10, brightness: 1.05, contrast: 1.02);
    results.add(_toBatchDto(input.sampleId, 'cool_fluorescent', cool));

    // 7. Dim Shadow Crease Simulation (-14% brightness, +10% contrast)
    final dim = _adjustLightingTone(base256, rMul: 1.0, gMul: 1.0, bMul: 1.0, brightness: 0.86, contrast: 1.10);
    results.add(_toBatchDto(input.sampleId, 'dim_shadow_crease', dim));

    // 8. Bright Window Glare (Soft radial highlight simulation)
    final glare = _applyWindowGlare(base256);
    results.add(_toBatchDto(input.sampleId, 'bright_window_glare', glare));

    // 9. Directional Motion Blur (Simulating slight hand tremor)
    final blur = _applyMotionBlur(base256);
    results.add(_toBatchDto(input.sampleId, 'hand_held_motion_blur', blur));

    // 10. Sensor Noise & Corner Occlusion (High ISO sensor grain + subtle barista thumb/sticker cutout)
    final noise = _applySensorNoiseAndCutout(base256);
    results.add(_toBatchDto(input.sampleId, 'sensor_noise_cutout', noise));

    return results;
  }

  static img.Image _centerZoomCrop(img.Image src, double scaleRatio) {
    final zoomW = (src.width * scaleRatio).toInt().clamp(1, src.width);
    final zoomH = (src.height * scaleRatio).toInt().clamp(1, src.height);
    final zoomX = (src.width - zoomW) ~/ 2;
    final zoomY = (src.height - zoomH) ~/ 2;
    final zoomCrop = img.copyCrop(src, x: zoomX, y: zoomY, width: zoomW, height: zoomH);
    return img.copyResize(zoomCrop, width: targetSize, height: targetSize, interpolation: img.Interpolation.linear);
  }

  static _AugmentedBatchDto _toBatchDto(String sampleId, String name, img.Image image) {
    final tensor = _imageToTensor(image);
    final jpeg = Uint8List.fromList(img.encodeJpg(image, quality: 78));
    return _AugmentedBatchDto(
      sampleId: sampleId,
      transformName: name,
      tensor: tensor,
      previewBytes: jpeg,
    );
  }

  static img.Image _adjustLightingTone(
    img.Image src, {
    required double rMul,
    required double gMul,
    required double bMul,
    required double brightness,
    required double contrast,
  }) {
    final out = img.Image(width: src.width, height: src.height);
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        var r = pixel.r.toDouble();
        var g = pixel.g.toDouble();
        var b = pixel.b.toDouble();

        // Brightness & Contrast adjustment
        r = ((r - 128.0) * contrast + 128.0) * brightness * rMul;
        g = ((g - 128.0) * contrast + 128.0) * brightness * gMul;
        b = ((b - 128.0) * contrast + 128.0) * brightness * bMul;

        out.setPixelRgb(
          x,
          y,
          r.clamp(0.0, 255.0).toInt(),
          g.clamp(0.0, 255.0).toInt(),
          b.clamp(0.0, 255.0).toInt(),
        );
      }
    }
    return out;
  }

  static img.Image _applyWindowGlare(img.Image src) {
    final out = img.Image.from(src);
    const cx = targetSize * 0.35;
    const cy = targetSize * 0.30;
    const radius = targetSize * 0.40;

    for (int y = 0; y < targetSize; y++) {
      for (int x = 0; x < targetSize; x++) {
        final dx = x - cx;
        final dy = y - cy;
        final dist = (dx * dx + dy * dy) / (radius * radius);
        if (dist < 1.0) {
          final factor = (1.0 - dist) * 0.35;
          final p = out.getPixel(x, y);
          final r = (p.r * (1.0 - factor) + 255 * factor).clamp(0, 255).toInt();
          final g = (p.g * (1.0 - factor) + 255 * factor).clamp(0, 255).toInt();
          final b = (p.b * (1.0 - factor) + 255 * factor).clamp(0, 255).toInt();
          out.setPixelRgb(x, y, r, g, b);
        }
      }
    }
    return out;
  }

  static img.Image _applyMotionBlur(img.Image src) {
    final out = img.Image(width: src.width, height: src.height);
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        // Horizontal 3-tap box filter
        final p0 = src.getPixel(x > 0 ? x - 1 : x, y);
        final p1 = src.getPixel(x, y);
        final p2 = src.getPixel(x < src.width - 1 ? x + 1 : x, y);

        final r = ((p0.r + p1.r * 2 + p2.r) ~/ 4).clamp(0, 255);
        final g = ((p0.g + p1.g * 2 + p2.g) ~/ 4).clamp(0, 255);
        final b = ((p0.b + p1.b * 2 + p2.b) ~/ 4).clamp(0, 255);

        out.setPixelRgb(x, y, r, g, b);
      }
    }
    return out;
  }

  static img.Image _applySensorNoiseAndCutout(img.Image src) {
    final out = img.Image.from(src);
    // 1. Subtle high-ISO noise
    for (int y = 0; y < src.height; y += 2) {
      for (int x = 0; x < src.width; x += 2) {
        final noise = ((x * 13 + y * 17) % 19) - 9;
        final p = out.getPixel(x, y);
        out.setPixelRgb(
          x,
          y,
          (p.r + noise).clamp(0, 255).toInt(),
          (p.g + noise).clamp(0, 255).toInt(),
          (p.b + noise).clamp(0, 255).toInt(),
        );
      }
    }

    // 2. Subtle corner thumb occlusion (bottom-right 12%)
    final startX = (targetSize * 0.88).toInt();
    final startY = (targetSize * 0.88).toInt();
    for (int y = startY; y < targetSize; y++) {
      for (int x = startX; x < targetSize; x++) {
        out.setPixelRgb(x, y, 55, 42, 33);
      }
    }

    return out;
  }

  /// Converts img.Image to [1, 256, 256, 3] ImageNet-normalized double tensor
  static List<List<List<List<double>>>> _imageToTensor(img.Image image) {
    final height = image.height;
    final width = image.width;

    final plane = List.generate(
      height,
      (y) => List.generate(
        width,
        (x) {
          final pixel = image.getPixel(x, y);
          final normR = (pixel.r / 255.0 - meanR) / stdR;
          final normG = (pixel.g / 255.0 - meanG) / stdG;
          final normB = (pixel.b / 255.0 - meanB) / stdB;
          return [normR, normG, normB];
        },
        growable: false,
      ),
      growable: false,
    );

    return [plane];
  }

  static List<List<List<List<double>>>> _emptyTensor() {
    return [
      List.generate(
        targetSize,
        (_) => List.generate(
          targetSize,
          (_) => [0.0, 0.0, 0.0],
          growable: false,
        ),
        growable: false,
      )
    ];
  }
}

class _AugmentedBatchDto {
  final String sampleId;
  final String transformName;
  final List<List<List<List<double>>>> tensor;
  final Uint8List previewBytes;

  const _AugmentedBatchDto({
    required this.sampleId,
    required this.transformName,
    required this.tensor,
    required this.previewBytes,
  });
}
