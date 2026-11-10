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

/// Pure Dart background Isolate preprocessing and 15x augmentation pipeline
class ImageTensorIsolate {
  static const int targetSize = 256;
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

  /// Runs multi-sample augmentation in Isolate: generates 5 augmented variations per photo
  /// (e.g. 3 photos -> 15 tensors, 5 photos -> 25 tensors)
  static Future<List<ImageTensorSample>> augmentPhotos({
    required List<PreprocessInputDto> inputs,
    void Function(int current, int total)? onProgress,
  }) async {
    final expectedTotal = inputs.length * 5;
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
      }

      onProgress?.call(allResults.length, expectedTotal);
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

    // 1. Original 256x256
    results.add(_toBatchDto(input.sampleId, 'original', base256));

    // 2. Horizontal Flip (Mirrored Invariance)
    final flipped = img.flipHorizontal(img.Image.from(base256));
    results.add(_toBatchDto(input.sampleId, 'horizontal_flip', flipped));

    // 3. Rotation (+8 deg) + 90% Center Zoom Crop
    final rotated = img.copyRotate(base256, angle: 8, interpolation: img.Interpolation.linear);
    final zoomW = (rotated.width * 0.90).toInt();
    final zoomH = (rotated.height * 0.90).toInt();
    final zoomX = (rotated.width - zoomW) ~/ 2;
    final zoomY = (rotated.height - zoomH) ~/ 2;
    final zoomCrop = img.copyCrop(rotated, x: zoomX, y: zoomY, width: zoomW, height: zoomH);
    final zoomResized = img.copyResize(zoomCrop, width: targetSize, height: targetSize);
    results.add(_toBatchDto(input.sampleId, 'rotate_zoom', zoomResized));

    // 4. Warm Cafe Lighting Jitter (+8% brightness, +10% contrast)
    final warm = _adjustBrightnessContrast(base256, brightnessMul: 1.08, contrastMul: 1.10, warmFilter: true);
    results.add(_toBatchDto(input.sampleId, 'warm_lighting', warm));

    // 5. Dim Shadow Simulation (-8% brightness)
    final dim = _adjustBrightnessContrast(base256, brightnessMul: 0.92, contrastMul: 1.02, warmFilter: false);
    results.add(_toBatchDto(input.sampleId, 'dim_shadow', dim));

    return results;
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

  static img.Image _adjustBrightnessContrast(
    img.Image src, {
    required double brightnessMul,
    required double contrastMul,
    required bool warmFilter,
  }) {
    final out = img.Image(width: src.width, height: src.height);
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        var r = pixel.r.toDouble();
        var g = pixel.g.toDouble();
        var b = pixel.b.toDouble();

        // Brightness & Contrast adjustment
        r = ((r - 128.0) * contrastMul + 128.0) * brightnessMul;
        g = ((g - 128.0) * contrastMul + 128.0) * brightnessMul;
        b = ((b - 128.0) * contrastMul + 128.0) * brightnessMul;

        // Warm tint simulation (tungsten shift)
        if (warmFilter) {
          r = r * 1.05;
          b = b * 0.95;
        }

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
