import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

enum RoasteryAssetKind {
  logo,
  banner,
  lineup;

  String get apiValue => name;

  double get aspectRatio {
    switch (this) {
      case RoasteryAssetKind.logo:
        return 1.0;
      case RoasteryAssetKind.lineup:
        return 0.8; // 4:5 bag portrait ratio
      case RoasteryAssetKind.banner:
        return 16 / 9;
    }
  }

  int get maxDimensionPx {
    switch (this) {
      case RoasteryAssetKind.logo:
        return 720;
      case RoasteryAssetKind.lineup:
        return 1080;
      case RoasteryAssetKind.banner:
        return 1280;
    }
  }
}

class RoasteryUploadedAsset {
  final String secureUrl;
  final String publicId;
  final Uint8List previewBytes;

  const RoasteryUploadedAsset({
    required this.secureUrl,
    required this.publicId,
    required this.previewBytes,
  });
}

class RoasteryMediaUploader {
  final Dio _apiDio;
  final Dio _cloudinaryDio;
  final ImagePicker _picker;

  RoasteryMediaUploader({
    required Dio apiDio,
    Dio? cloudinaryDio,
    ImagePicker? picker,
  })  : _apiDio = apiDio,
        _cloudinaryDio = cloudinaryDio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 25),
                sendTimeout: const Duration(seconds: 60),
                receiveTimeout: const Duration(seconds: 35),
              ),
            ),
        _picker = picker ?? ImagePicker();

  /// Memilih foto dari Galeri atau Kamera lalu memproses crop + kompresi di background Isolate,
  /// dilanjutkan Direct Upload ke Cloudinary menggunakan Signed Parameters dari backend Rust.
  Future<RoasteryUploadedAsset?> pickAndUpload({
    required RoasteryAssetKind kind,
    required ImageSource source,
    void Function(double progress)? onProgress,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 92,
    );
    if (picked == null) return null;

    final rawBytes = await File(picked.path).readAsBytes();
    return compressAndUploadBytes(
      rawBytes: rawBytes,
      kind: kind,
      onProgress: onProgress,
    );
  }

  /// Crop rasio presisi & kompresi JPEG hemat kuota di background Isolate.
  static Future<Uint8List> cropAndCompressInIsolate({
    required Uint8List sourceBytes,
    required double targetAspectRatio,
    int maxDimension = 1080,
    int quality = 84,
  }) {
    return Isolate.run(() {
      final decoded = img.decodeImage(sourceBytes);
      if (decoded == null) {
        throw const FormatException('Format gambar tidak dapat didekode.');
      }
      final oriented = img.bakeOrientation(decoded);

      final srcW = oriented.width;
      final srcH = oriented.height;
      final srcRatio = srcW / srcH;

      int cropW = srcW;
      int cropH = srcH;
      if (srcRatio > targetAspectRatio) {
        cropW = (srcH * targetAspectRatio).round().clamp(1, srcW);
      } else if (srcRatio < targetAspectRatio) {
        cropH = (srcW / targetAspectRatio).round().clamp(1, srcH);
      }

      final offsetX = ((srcW - cropW) / 2).round();
      final offsetY = ((srcH - cropH) / 2).round();
      final cropped = img.copyCrop(
        oriented,
        x: offsetX,
        y: offsetY,
        width: cropW,
        height: cropH,
      );

      final largest = cropped.width > cropped.height ? cropped.width : cropped.height;
      final resized = largest > maxDimension
          ? img.copyResize(
              cropped,
              width: cropped.width >= cropped.height ? maxDimension : null,
              height: cropped.height > cropped.width ? maxDimension : null,
              interpolation: img.Interpolation.average,
            )
          : cropped;

      return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    });
  }

  Future<RoasteryUploadedAsset> compressAndUploadBytes({
    required Uint8List rawBytes,
    required RoasteryAssetKind kind,
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.08);
    final compressed = await cropAndCompressInIsolate(
      sourceBytes: rawBytes,
      targetAspectRatio: kind.aspectRatio,
      maxDimension: kind.maxDimensionPx,
    );

    onProgress?.call(0.22);
    final sigRes = await _apiDio.post<Map<String, dynamic>>(
      '/api/v1/roasteries/media/upload-signature',
      data: {'asset_kind': kind.apiValue},
    );
    final sigData = sigRes.data?['data'] as Map<String, dynamic>?;
    if (sigData == null) {
      throw StateError('Signature upload Cloudinary kosong dari server.');
    }

    final uploadUrl = sigData['upload_url']?.toString() ?? '';
    final apiKey = sigData['api_key']?.toString() ?? '';
    final signature = sigData['signature']?.toString() ?? '';
    final folder = sigData['folder']?.toString() ?? '';
    final timestamp = sigData['timestamp'];
    final publicId = sigData['public_id']?.toString();

    if (uploadUrl.isEmpty || apiKey.isEmpty || signature.isEmpty) {
      throw StateError('Parameter signed upload Cloudinary tidak lengkap.');
    }

    final formMap = <String, dynamic>{
      'file': MultipartFile.fromBytes(
        compressed,
        filename: 'roastery_${kind.apiValue}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
      'api_key': apiKey,
      'timestamp': timestamp.toString(),
      'signature': signature,
      'folder': folder,
    };
    if (publicId != null && publicId.isNotEmpty) {
      formMap['public_id'] = publicId;
    }

    final formData = FormData.fromMap(formMap);
    final cloudRes = await _cloudinaryDio.post<Map<String, dynamic>>(
      uploadUrl,
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0 && onProgress != null) {
          final uploadFrac = (sent / total).clamp(0.0, 1.0);
          onProgress(0.25 + uploadFrac * 0.75);
        }
      },
    );

    final body = cloudRes.data ?? const <String, dynamic>{};
    final secureUrl = body['secure_url']?.toString() ?? '';
    final resPublicId = body['public_id']?.toString() ?? '';
    if (secureUrl.isEmpty) {
      throw StateError('Cloudinary tidak mengembalikan secure_url.');
    }

    onProgress?.call(1.0);
    return RoasteryUploadedAsset(
      secureUrl: secureUrl,
      publicId: resPublicId,
      previewBytes: compressed,
    );
  }
}
