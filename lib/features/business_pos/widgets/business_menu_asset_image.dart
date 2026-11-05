import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Universal image widget for Business POS and AMOLED Menu Display.
/// Safely renders:
/// 1. Remote HTTP/HTTPS URLs (PNG, JPEG, WebP, SVG) via CachedNetworkImage / SvgPicture.network
/// 2. Local Filesystem paths (from Gallery / Camera / Internal Storage) via Image.file / SvgPicture.file
/// 3. Bundled Flutter assets via Image.asset / SvgPicture.asset
/// 4. Graceful fallback icon if source is empty, corrupted, or unreachable
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

  @override
  Widget build(BuildContext context) {
    final cleanUrl = assetUrl.trim();
    if (cleanUrl.isEmpty) {
      return _buildFallbackIcon();
    }

    final isSvg = assetFormat.toUpperCase() == 'SVG' || cleanUrl.toLowerCase().endsWith('.svg');

    // Case 1: Remote HTTP/HTTPS URL
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      if (isSvg) {
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

    // Case 2: Bundled Flutter asset (assets/...)
    if (cleanUrl.startsWith('assets/')) {
      if (isSvg) {
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

    // Case 3: Local Filesystem File (Windows, Android, iOS)
    try {
      final sanitizedPath = cleanUrl.startsWith('file://')
          ? cleanUrl.replaceFirst('file://', '')
          : cleanUrl;
      final file = File(sanitizedPath);

      if (file.existsSync()) {
        if (isSvg) {
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
