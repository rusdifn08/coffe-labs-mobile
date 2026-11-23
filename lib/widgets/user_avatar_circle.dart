import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Avatar lingkaran serbaguna untuk Social Chat, daftar peer, dan bubble pesan.
/// Mendukung URL HTTPS (Cloudinary/CDN), asset karakter lokal (`assets/`), file galeri lokal,
/// serta fallback inisial nama/ikon grup secara aman tanpa pernah crash saat offline.
class UserAvatarCircle extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final double radius;
  final bool isGroup;
  final bool isOnline;
  final double? onlineDotSize;
  final Color? backgroundColor;

  const UserAvatarCircle({
    super.key,
    required this.avatarUrl,
    required this.displayName,
    this.radius = 20,
    this.isGroup = false,
    this.isOnline = false,
    this.onlineDotSize,
    this.backgroundColor,
  });

  String get _initial {
    final trimmed = displayName.trim();
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : 'B';
  }

  Widget _buildFallback() {
    final bg = backgroundColor ?? AppTheme.primaryBrown.withValues(alpha: 0.14);
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: bg,
      alignment: Alignment.center,
      child: isGroup
          ? Icon(
              CupertinoIcons.person_3_fill,
              size: (radius * 0.92).clamp(13.0, 26.0),
              color: AppTheme.primaryBrown,
            )
          : Text(
              _initial,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: (radius * 0.78).clamp(10.0, 20.0),
                color: AppTheme.primaryBrown,
              ),
            ),
    );
  }

  Widget _buildImageContent() {
    final raw = avatarUrl?.trim() ?? '';
    if (raw.isEmpty || raw.contains('rusdi.png')) {
      return _buildFallback();
    }

    final size = radius * 2;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: raw,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 160),
        placeholder: (_, _) => _buildFallback(),
        errorWidget: (_, _, _) => _buildFallback(),
      );
    }

    if (raw.startsWith('assets/')) {
      return Image.asset(
        raw,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(),
      );
    }

    final file = File(raw);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(),
      );
    }

    return _buildFallback();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = onlineDotSize ?? (radius >= 22 ? 12.5 : 10.0);
    final circle = ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: _buildImageContent(),
      ),
    );

    if (!isOnline) return circle;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        circle,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
