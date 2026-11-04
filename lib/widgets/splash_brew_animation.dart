import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom Painter yang menggambar partikel uap aroma (steam wisps)
/// dan riak ekstraksi emas yang elegan di atas bejana laboratorium kopi.
class SplashAromaPainter extends CustomPainter {
  final double progress;
  final Color steamColor;
  final Color goldAccent;

  SplashAromaPainter({
    required this.progress,
    required this.steamColor,
    required this.goldAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.35; // area leher labu / spout

    // 1. Gambar 3 helai uap aroma yang melayang anggun (steam ribbons)
    final paintSteam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final t = (progress + i * 0.33) % 1.0;
      final alpha = (math.sin(t * math.pi) * 220).clamp(0, 255).toInt();
      if (alpha <= 0) continue;

      paintSteam.color = steamColor.withValues(alpha: alpha / 255.0);
      paintSteam.strokeWidth = 1.5 + (1.0 - t) * 1.8;

      final startY = cy - 25 - (t * 55.0);
      final spreadX = (i - 1) * 16.0;
      final sway = math.sin(t * math.pi * 2 + i * 1.5) * 8.0;

      final path = Path();
      path.moveTo(cx + spreadX, startY);
      path.cubicTo(
        cx + spreadX + sway,
        startY - 15,
        cx + spreadX - sway,
        startY - 30,
        cx + spreadX + (sway * 0.5),
        startY - 45,
      );

      canvas.drawPath(path, paintSteam);
    }

    // 2. Gambar riak ekstraksi emas (subtle extraction pulse)
    if (progress > 0.15 && progress < 0.85) {
      final rippleT = (progress - 0.15) / 0.70;
      final rippleRadius = 15.0 + rippleT * 55.0;
      final rippleAlpha = ((1.0 - rippleT) * 140).clamp(0, 255).toInt();

      final ripplePaint = Paint()
        ..color = goldAccent.withValues(alpha: rippleAlpha / 255.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * (1.0 - rippleT);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, size.height * 0.56),
          width: rippleRadius * 1.8,
          height: rippleRadius * 0.65,
        ),
        ripplePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SplashAromaPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Widget Shimmer / Kilau Emas yang bergerak menyapu logo
class ShimmerGlance extends StatelessWidget {
  final Widget child;
  final double animationValue;

  const ShimmerGlance({
    super.key,
    required this.child,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        final shimmerWidth = bounds.width * 0.6;
        final startX = (bounds.width + shimmerWidth * 2) * animationValue - shimmerWidth;

        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            const Color(0xFFFFE8A3).withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientSlideTransform(startX / bounds.width),
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

/// Helper matrix slide transform untuk shader
class GradientSlideTransform extends GradientTransform {
  final double offsetPercent;
  const GradientSlideTransform(this.offsetPercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offsetPercent, 0.0, 0.0);
  }
}
