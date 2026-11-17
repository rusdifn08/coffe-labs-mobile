import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Thumbnail gambar grinder dengan ukuran terkunci dan fallback vektor aman
/// agar error loading asset tidak pernah menimbulkan overflow layout.
class GrinderThumbnailImage extends StatelessWidget {
  final String imagePath;
  final bool isElectric;
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const GrinderThumbnailImage({
    super.key,
    required this.imagePath,
    this.isElectric = false,
    this.size = 58,
    this.borderRadius = 10,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = imagePath.trim();
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: trimmed.isEmpty
            ? _buildFallback()
            : Image.asset(
                trimmed,
                width: size,
                height: size,
                fit: fit,
                errorBuilder: (context, error, stackTrace) => _buildFallback(),
              ),
      ),
    );
  }

  Widget _buildFallback() {
    final accent = isElectric ? Colors.blue.shade700 : AppTheme.primaryBrown;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isElectric
              ? const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)]
              : const [Color(0xFFFAF3E8), Color(0xFFF3E5D0)],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isElectric
                ? CupertinoIcons.bolt_fill
                : CupertinoIcons.slider_horizontal_3,
            size: (size * 0.42).clamp(16.0, 32.0),
            color: accent,
          ),
          if (size >= 52) ...[
            const SizedBox(height: 2),
            Text(
              isElectric ? 'ELECTRIC' : 'MANUAL',
              style: TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
                color: accent,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
