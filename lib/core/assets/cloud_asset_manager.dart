import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../network/backend_endpoint_manager.dart';

/// Pengelola aset media Object Storage / Multi-CDN untuk Coffee Labs.
///
/// Aset media berat (gambar biji kopi, cover & portrait barista, logo roastery,
/// ilustrasi metode seduh, dan musik lounge) di-offload keluar dari APK ke
/// Object Storage / Multi-CDN (jsDelivr -> GitHub Raw / Cloudflare R2 / Cloudinary / VPS)
/// dan otomatis di-cache ke disk lokal perangkat melalui [CachedNetworkImage].
class CloudAssetManager {
  CloudAssetManager._();

  static const String defaultPrimaryCdnBase =
      'https://cdn.jsdelivr.net/gh/rusdifn08/coffe-labs-mobile@main/cloud_assets';
  static const String defaultFallbackCdnBase =
      'https://raw.githubusercontent.com/rusdifn08/coffe-labs-mobile/main/cloud_assets';

  /// Prefix aset yang sudah di-offload keluar dari bundel APK ke Object Storage / CDN.
  static const List<String> offloadedPrefixes = [
    'assets/images/beans/',
    'assets/images/avatars/covers/',
    'assets/images/avatars/portraits/',
    'assets/images/roasteries/',
    'assets/images/methods/',
    'assets/audio/calm_music.m4a',
  ];

  static String get primaryCdnBase {
    final dynamicBase =
        BackendEndpointManager.instance.cachedManifest?.assetCdnBaseUrl;
    if (dynamicBase != null && dynamicBase.isNotEmpty) {
      return dynamicBase;
    }
    return defaultPrimaryCdnBase;
  }

  static List<String> get fallbackCdnBases {
    final dynamicFallbacks =
        BackendEndpointManager.instance.cachedManifest?.assetCdnFallbackUrls;
    final list = <String>[
      ...?dynamicFallbacks,
      defaultFallbackCdnBase,
    ];
    final seen = <String>{primaryCdnBase};
    final deduped = <String>[];
    for (final url in list) {
      if (seen.add(url)) deduped.add(url);
    }
    return deduped;
  }

  /// Cek apakah path asset sudah dipindahkan ke Object Storage / Multi-CDN.
  static bool isCloudAsset(String rawPath) {
    final normalized = _normalizePath(rawPath);
    if (normalized.isEmpty) return false;
    for (final prefix in offloadedPrefixes) {
      if (normalized.startsWith(prefix)) return true;
    }
    return false;
  }

  static String _normalizePath(String rawPath) {
    var p = rawPath.trim().replaceAll('\\', '/');
    while (p.startsWith('/')) {
      p = p.substring(1);
    }
    return p;
  }

  static String _toCloudRelativePath(String rawPath) {
    final normalized = _normalizePath(rawPath);
    if (normalized.startsWith('assets/')) {
      return normalized.substring('assets/'.length);
    }
    return normalized;
  }

  /// Konversi path asset lokal (mis. `assets/images/beans/x.jpg`) menjadi URL HTTPS Object Storage.
  static String resolveUrl(String rawPath, {String? cdnBaseOverride}) {
    final trimmed = rawPath.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final rel = _toCloudRelativePath(trimmed);
    final base = (cdnBaseOverride ?? primaryCdnBase).replaceAll(RegExp(r'/+$'), '');
    return '$base/$rel';
  }

  /// Mengembalikan daftar kandidat URL (Primary CDN -> Fallback Mirrors) untuk retry otomatis.
  static List<String> resolveCandidateUrls(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return [trimmed];
    }
    return [
      resolveUrl(trimmed, cdnBaseOverride: primaryCdnBase),
      for (final fb in fallbackCdnBases)
        resolveUrl(trimmed, cdnBaseOverride: fb),
    ];
  }

  /// Drop-in replacement untuk `AssetImage(...)` yang mendukung bundel lokal & Object Storage CDN.
  static ImageProvider imageProvider(
    String rawPath, {
    String fallbackAsset = 'assets/images/coffee_labs_emblem.png',
  }) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty) {
      return AssetImage(fallbackAsset);
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return CachedNetworkImageProvider(trimmed);
    }
    if (isCloudAsset(trimmed)) {
      return CachedNetworkImageProvider(resolveUrl(trimmed));
    }
    return AssetImage(trimmed);
  }

  /// Mengunduh bytes aset baik dari bundel lokal maupun Multi-CDN Object Storage.
  static Future<Uint8List?> downloadBytes(String rawPath) async {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty) return null;
    if (!isCloudAsset(trimmed) && !trimmed.startsWith('http')) {
      try {
        final data = await rootBundle.load(trimmed);
        return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      } catch (_) {}
    }
    for (final url in resolveCandidateUrls(trimmed)) {
      try {
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          return res.bodyBytes;
        }
      } catch (_) {}
    }
    return null;
  }
}

/// Widget gambar serbaguna pengganti `Image.asset` yang otomatis mengambil aset
/// ter-offload dari Object Storage / Multi-CDN dengan caching disk permanen.
class CloudAssetImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final int? cacheWidth;
  final int? cacheHeight;
  final Color? color;
  final BlendMode? colorBlendMode;
  final FilterQuality filterQuality;
  final bool gaplessPlayback;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const CloudAssetImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.cacheHeight,
    this.color,
    this.colorBlendMode,
    this.filterQuality = FilterQuality.low,
    this.gaplessPlayback = true,
    this.errorBuilder,
  });

  Widget _defaultFallback(BuildContext context, Object error) {
    if (errorBuilder != null) {
      return errorBuilder!(context, error, null);
    }
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF4EFE6),
      alignment: Alignment.center,
      child: const Icon(
        Icons.coffee_rounded,
        size: 24,
        color: Color(0xFF8C6D53),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return _defaultFallback(context, 'empty_asset_path');
    }

    final bool isNetwork =
        trimmed.startsWith('http://') || trimmed.startsWith('https://');
    if (isNetwork || CloudAssetManager.isCloudAsset(trimmed)) {
      final urls = CloudAssetManager.resolveCandidateUrls(trimmed);
      final primaryUrl = urls.first;
      final fallbackUrl = urls.length > 1 ? urls[1] : null;
      final effectiveAlignment = alignment is Alignment
          ? alignment as Alignment
          : Alignment.center;

      return CachedNetworkImage(
        imageUrl: primaryUrl,
        width: width,
        height: height,
        fit: fit,
        alignment: effectiveAlignment,
        color: color,
        colorBlendMode: colorBlendMode,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        maxWidthDiskCache: cacheWidth,
        maxHeightDiskCache: cacheHeight,
        filterQuality: filterQuality,
        fadeInDuration: const Duration(milliseconds: 120),
        fadeOutDuration: Duration.zero,
        placeholder: (context, _) => Container(
          width: width,
          height: height,
          color: const Color(0xFFF4EFE6),
        ),
        errorWidget: (context, _, err) {
          if (fallbackUrl != null && fallbackUrl != primaryUrl) {
            return CachedNetworkImage(
              imageUrl: fallbackUrl,
              width: width,
              height: height,
              fit: fit,
              alignment: effectiveAlignment,
              color: color,
              colorBlendMode: colorBlendMode,
              memCacheWidth: cacheWidth,
              memCacheHeight: cacheHeight,
              fadeInDuration: const Duration(milliseconds: 120),
              errorWidget: (ctx, _, err2) => _defaultFallback(ctx, err2),
            );
          }
          return _defaultFallback(context, err);
        },
      );
    }

    return Image.asset(
      trimmed,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      color: color,
      colorBlendMode: colorBlendMode,
      filterQuality: filterQuality,
      gaplessPlayback: true,
      errorBuilder: errorBuilder ??
          (ctx, err, _) => _defaultFallback(ctx, err),
    );
  }
}
