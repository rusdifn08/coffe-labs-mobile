import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Universal image widget for Business POS and AMOLED Menu Display.
/// Safely renders:
/// 1. Base64 Data URIs (data:image/png;base64,..., data:image/webp;base64,..., data:image/svg+xml;base64,...)
/// 2. Raw Base64 string representations
/// 3. Remote HTTP/HTTPS URLs (PNG, JPEG, WebP, SVG) via CachedNetworkImage / SvgPicture.network
/// 4. Bundled Flutter assets via Image.asset / SvgPicture.asset
/// 5. Local Filesystem paths (Windows, Android, iOS) via Image.file / SvgPicture.file
/// 6. Graceful fallback icon if source is empty, corrupted, or unreachable
class BusinessMenuAssetImage extends StatelessWidget {
  final String assetUrl;
  final String assetFormat;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color fallbackIconColor;
  final double fallbackIconSize;

  const BusinessMenuAssetImage({
    super.key,
    required this.assetUrl,
    this.assetFormat = 'PNG',
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackIconColor = const Color(0xFFD4AF37),
    this.fallbackIconSize = 36,
  });

  Widget _buildFallbackIcon() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      child: Icon(
        Icons.local_cafe,
        color: fallbackIconColor,
        size: fallbackIconSize,
      ),
    );
  }

  bool _isSvgBytes(Uint8List bytes) {
    if (bytes.length < 5) return false;
    final prefix = String.fromCharCodes(bytes.take(120)).toLowerCase();
    return prefix.contains('<svg') || prefix.contains('<?xml') || prefix.contains('<!doctype svg');
  }

  Widget _buildFromMemoryBytes(Uint8List bytes, {required bool isSvg}) {
    if (isSvg) {
      return SvgPicture.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => _buildFallbackIcon(),
      );
    }
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = assetUrl.trim();
    if (cleanUrl.isEmpty) {
      return _buildFallbackIcon();
    }

    final isSvgFormat = assetFormat.toUpperCase() == 'SVG' || cleanUrl.toLowerCase().endsWith('.svg');

    // Case 1: Data URI (base64 or encoded svg)
    if (cleanUrl.startsWith('data:')) {
      try {
        final commaIndex = cleanUrl.indexOf(',');
        if (commaIndex != -1) {
          final metadata = cleanUrl.substring(0, commaIndex).toLowerCase();
          final payload = cleanUrl.substring(commaIndex + 1);

          if (metadata.contains(';base64')) {
            final cleanBase64 = payload.replaceAll(RegExp(r'\s+'), '');
            final bytes = base64Decode(cleanBase64);
            if (bytes.isNotEmpty) {
              final isSvg = isSvgFormat || metadata.contains('image/svg') || _isSvgBytes(bytes);
              return _buildFromMemoryBytes(bytes, isSvg: isSvg);
            }
          } else if (metadata.contains('image/svg') || isSvgFormat) {
            final svgContent = Uri.decodeComponent(payload);
            return SvgPicture.string(
              svgContent,
              width: width,
              height: height,
              fit: fit,
              placeholderBuilder: (_) => _buildFallbackIcon(),
            );
          }
        }
      } catch (e) {
        debugPrint('Error decoding Data URI asset: $e');
        return _buildFallbackIcon();
      }
    }

    // Case 2: Raw Base64 string without data: prefix
    final isRawBase64 = !cleanUrl.startsWith('http://') &&
        !cleanUrl.startsWith('https://') &&
        !cleanUrl.startsWith('assets/') &&
        !cleanUrl.startsWith('file://') &&
        !cleanUrl.contains('\n') &&
        cleanUrl.length > 80 &&
        (cleanUrl.startsWith('iVBORw0KGgo') || // PNG
            cleanUrl.startsWith('/9j/') || // JPEG
            cleanUrl.startsWith('UklGR') || // WebP
            cleanUrl.startsWith('PHN2Zy') || // SVG <svg
            cleanUrl.startsWith('PD94bWw') || // XML <?xml
            cleanUrl.startsWith('R0lG') || // GIF
            RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(cleanUrl.substring(0, cleanUrl.length > 100 ? 100 : cleanUrl.length)));

    if (isRawBase64) {
      try {
        final cleanBase64 = cleanUrl.replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(cleanBase64);
        if (bytes.isNotEmpty) {
          final isSvg = isSvgFormat || _isSvgBytes(bytes);
          return _buildFromMemoryBytes(bytes, isSvg: isSvg);
        }
      } catch (e) {
        debugPrint('Error decoding raw base64 menu asset: $e');
        return _buildFallbackIcon();
      }
    }

    // Case 3: Remote HTTP/HTTPS URL
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      if (isSvgFormat) {
        return SvgPicture.network(
          cleanUrl,
          width: width,
          height: height,
          fit: fit,
          placeholderBuilder: (_) => const Center(
            child: CupertinoActivityIndicator(color: Colors.white24),
          ),
        );
      }
      return CachedNetworkImage(
        imageUrl: cleanUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => const Center(
          child: CupertinoActivityIndicator(color: Colors.white24),
        ),
        errorWidget: (context, url, error) => _buildFallbackIcon(),
      );
    }

    // Case 4: Bundled Flutter asset (assets/...)
    if (cleanUrl.startsWith('assets/')) {
      if (isSvgFormat) {
        return SvgPicture.asset(
          cleanUrl,
          width: width,
          height: height,
          fit: fit,
        );
      }
      return Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }

    // Case 5: Local Filesystem File (Windows, Android, iOS)
    try {
      String sanitizedPath = cleanUrl;
      if (sanitizedPath.startsWith('file:///')) {
        try {
          sanitizedPath = Uri.parse(cleanUrl).toFilePath();
        } catch (_) {
          sanitizedPath = cleanUrl.replaceFirst('file:///', '');
        }
      } else if (sanitizedPath.startsWith('file://')) {
        sanitizedPath = sanitizedPath.replaceFirst('file://', '');
        if (Platform.isWindows && sanitizedPath.startsWith('/')) {
          sanitizedPath = sanitizedPath.substring(1);
        }
      }

      final file = File(sanitizedPath);
      if (file.existsSync()) {
        if (isSvgFormat) {
          return SvgPicture.file(
            file,
            width: width,
            height: height,
            fit: fit,
          );
        }
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
        );
      }
    } catch (_) {
      // Ignore filesystem exception and fall through to fallback icon
    }

    return _buildFallbackIcon();
  }
}
