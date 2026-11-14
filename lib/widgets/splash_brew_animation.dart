import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom Painter yang menggambar cincin telemetri orbital laboratorium
/// beresolusi presisi + nodus mikropartikel emas/kopi/sage yang mengorbit
/// di belakang emblem transparan Coffee Labs.
class SplashOrbitalTelemetryPainter extends CustomPainter {
  final double introProgress;
  final double loopProgress;
  final Color espressoColor;
  final Color goldAccent;
  final Color sageAccent;

  SplashOrbitalTelemetryPainter({
    required this.introProgress,
    required this.loopProgress,
    required this.espressoColor,
    required this.goldAccent,
    required this.sageAccent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.shortestSide * 0.46;
    final reveal = Curves.easeOutCubic.transform(introProgress.clamp(0.0, 1.0));
    if (reveal <= 0.01) return;

    // 1. Cincin kalibrasi luar tipis dengan garis derajat laboratorium
    final ringPaint = Paint()
      ..color = goldAccent.withValues(alpha: 0.22 * reveal)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, baseRadius * (0.88 + 0.12 * reveal), ringPaint);

    final tickPaint = Paint()
      ..color = espressoColor.withValues(alpha: 0.14 * reveal)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    const int tickCount = 24;
    final tickOuter = baseRadius * 0.99;
    final tickInner = baseRadius * 0.955;
    for (int i = 0; i < tickCount; i++) {
      final angle = (i / tickCount) * math.pi * 2 + loopProgress * 0.18;
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      canvas.drawLine(
        Offset(center.dx + cosA * tickInner, center.dy + sinA * tickInner),
        Offset(center.dx + cosA * tickOuter, center.dy + sinA * tickOuter),
        tickPaint,
      );
    }

    // 2. Tiga lintasan elips orbital (0, +58, -58 deg) selaras dengan atom Coffee Labs
    final orbitAngles = [0.0, math.pi / 3.1, -math.pi / 3.1];
    final orbitColors = [goldAccent, sageAccent, espressoColor];
    final rx = baseRadius * 0.92 * (0.85 + 0.15 * reveal);
    final ry = baseRadius * 0.36 * (0.85 + 0.15 * reveal);

    for (int i = 0; i < orbitAngles.length; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(orbitAngles[i]);

      final orbitPaint = Paint()
        ..color = orbitColors[i].withValues(alpha: 0.16 * reveal)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1;

      final rect = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2);
      // Sapuan busur masuk saat fase intro
      final sweep = math.pi * 2 * math.min(1.0, reveal * 1.15);
      canvas.drawArc(rect, -math.pi / 2 + i * 0.8, sweep, false, orbitPaint);

      // Titik satelit bercahaya kecil yang mengorbit sepanjang lintasan
      final theta = loopProgress * math.pi * 2 + (i * math.pi * 2 / 3);
      final nodePos = Offset(rx * math.cos(theta), ry * math.sin(theta));
      final glowPaint = Paint()
        ..color = orbitColors[i].withValues(alpha: 0.24 * reveal)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final dotPaint = Paint()..color = orbitColors[i].withValues(alpha: 0.72 * reveal);

      canvas.drawCircle(nodePos, 4.2, glowPaint);
      canvas.drawCircle(nodePos, 2.2, dotPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SplashOrbitalTelemetryPainter oldDelegate) {
    return oldDelegate.introProgress != introProgress ||
        oldDelegate.loopProgress != loopProgress;
  }
}

/// Custom Painter yang menggambar partikel uap aroma (steam wisps)
/// dan riak ekstraksi emas yang elegan di sekitar bejana Chemex & Erlenmeyer.
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
    final cy = size.height * 0.24; // area atas leher Chemex

    // 1. Tiga helai uap aroma yang melayang anggun
    final paintSteam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final t = (progress + i * 0.33) % 1.0;
      final alpha = (math.sin(t * math.pi) * 185).clamp(0, 255).toInt();
      if (alpha <= 0) continue;

      paintSteam.color = steamColor.withValues(alpha: alpha / 255.0);
      paintSteam.strokeWidth = 1.4 + (1.0 - t) * 1.4;

      final startY = cy - 8 - (t * 42.0);
      final spreadX = (i - 1) * 14.0;
      final sway = math.sin(t * math.pi * 2 + i * 1.5) * 7.5;

      final path = Path()
        ..moveTo(cx + spreadX, startY)
        ..cubicTo(
          cx + spreadX + sway,
          startY - 12,
          cx + spreadX - sway,
          startY - 24,
          cx + spreadX + (sway * 0.5),
          startY - 36,
        );

      canvas.drawPath(path, paintSteam);
    }

    // 2. Riak ekstraksi emas di bawah tetesan kopi emblem
    if (progress > 0.12 && progress < 0.88) {
      final rippleT = (progress - 0.12) / 0.76;
      final rippleRadius = 14.0 + rippleT * 48.0;
      final rippleAlpha = ((1.0 - rippleT) * 130).clamp(0, 255).toInt();

      final ripplePaint = Paint()
        ..color = goldAccent.withValues(alpha: rippleAlpha / 255.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25 * (1.0 - rippleT);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, size.height * 0.71),
          width: rippleRadius * 1.9,
          height: rippleRadius * 0.58,
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

/// Widget Shimmer / Kilau Emas-Krem yang bergerak menyapu bagian solid logo transparan.
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
        final shimmerWidth = bounds.width * 0.55;
        final startX = (bounds.width + shimmerWidth * 2) * animationValue - shimmerWidth;

        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            const Color(0xFFFFF1C1).withValues(alpha: 0.42),
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

/// Helper matrix slide transform untuk shader kilau.
class GradientSlideTransform extends GradientTransform {
  final double offsetPercent;
  const GradientSlideTransform(this.offsetPercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offsetPercent, 0.0, 0.0);
  }
}
