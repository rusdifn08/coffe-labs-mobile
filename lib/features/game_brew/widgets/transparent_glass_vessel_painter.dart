import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Renders a Crystal-Clear Transparent Borosilicate Glass Gooseneck Kettle
/// OR Transparent Milk Pitcher with Fresnel rim reflection, 2-axis dynamic
/// sloshing internal fluid surface, printed `ml` markings, and dual-layer
/// liquid milk + floating velvety microfoam for Latte Art 3D!
class TransparentGlassVesselPainter extends CustomPainter {
  final bool isMilkPitcher;
  final double fillFraction; // 0..1
  final double capacityMl;
  final double remainingMl;
  final double tiltAngleRad; // Vessel tilt
  final double sloshAngleRad; // Dynamic pendulum fluid tilt
  final double wavePhase;
  final double flowRateMlS;
  final double foamLayerFraction; // Milk pitcher microfoam ratio

  const TransparentGlassVesselPainter({
    required this.isMilkPitcher,
    required this.fillFraction,
    required this.capacityMl,
    required this.remainingMl,
    required this.tiltAngleRad,
    required this.sloshAngleRad,
    required this.wavePhase,
    required this.flowRateMlS,
    this.foamLayerFraction = 0.28,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final center = Offset(size.width * 0.54, size.height * 0.54);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-tiltAngleRad.clamp(-0.65, 0.65));

    final double bodyW = size.width * 0.56;
    final double bodyH = size.height * 0.64;
    final Rect bodyRect = Rect.fromCenter(
      center: Offset.zero,
      width: bodyW,
      height: bodyH,
    );

    // 1. Gooseneck Spout (Kettle) OR Sharp V-Spout (Milk Pitcher)
    if (!isMilkPitcher) {
      final spoutPath = Path()
        ..moveTo(bodyRect.left + 2, bodyRect.bottom - 10)
        ..cubicTo(
          bodyRect.left - 18,
          bodyRect.bottom - 10,
          bodyRect.left - 18,
          bodyRect.top + 8,
          bodyRect.left - 24,
          bodyRect.top - 4,
        );
      canvas.drawPath(
        spoutPath,
        Paint()
          ..color = const Color(0xFF94A3B8).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        spoutPath,
        Paint()
          ..color = flowRateMlS > 0.25
              ? const Color(0xFF38BDF8).withValues(alpha: 0.78)
              : Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      );
    } else {
      final spoutPath = Path()
        ..moveTo(bodyRect.left + 4, bodyRect.top + 4)
        ..lineTo(bodyRect.left - 12, bodyRect.top - 3)
        ..lineTo(bodyRect.left + 2, bodyRect.top + 14)
        ..close();
      canvas.drawPath(
        spoutPath,
        Paint()..color = Colors.white.withValues(alpha: 0.65),
      );
    }

    // 2. Ergonomic Handle (right side)
    final handleRect = Rect.fromLTWH(
      bodyRect.right - 2,
      bodyRect.top + 10,
      14,
      bodyH * 0.64,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(8)),
      Paint()
        ..color = AppTheme.primaryBrown.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2,
    );

    // 3. Borosilicate Glass Outer Body Shape
    final vesselRRect = RRect.fromRectAndCorners(
      bodyRect,
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
      bottomLeft: const Radius.circular(14),
      bottomRight: const Radius.circular(14),
    );

    // Subtle glass background tint
    canvas.drawRRect(
      vesselRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.75),
            const Color(0xFFE2E8F0).withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.68),
          ],
        ).createShader(bodyRect),
    );

    // 4. Clipped Dynamic Sloshing Fluid Inside Glass Vessel!
    canvas.save();
    canvas.clipRRect(vesselRRect);

    final double liquidHeight = bodyH * fillFraction.clamp(0.0, 1.0);
    final double surfaceY = bodyRect.bottom - liquidHeight;
    final double sloshSlope =
        math.tan((sloshAngleRad - tiltAngleRad * 0.45).clamp(-0.65, 0.65)) *
            (bodyW * 0.48);

    if (liquidHeight > 1.0) {
      final Path liquidPath = Path()
        ..moveTo(bodyRect.left - 6, bodyRect.bottom + 4);
      const int samples = 14;
      for (int i = 0; i <= samples; i++) {
        final double t = i / samples;
        final double x = bodyRect.left + t * bodyW;
        final double relX = (t - 0.5) * 2.0;
        final double wave = math.sin(wavePhase + t * math.pi * 2.0) * 2.2;
        final double y = surfaceY + relX * sloshSlope + wave;
        liquidPath.lineTo(x, y);
      }
      liquidPath
        ..lineTo(bodyRect.right + 6, bodyRect.bottom + 4)
        ..close();

      if (!isMilkPitcher) {
        // Hot crystal water inside borosilicate kettle
        canvas.drawPath(
          liquidPath,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF7DD3FC).withValues(alpha: 0.62),
                const Color(0xFF0284C7).withValues(alpha: 0.72),
              ],
            ).createShader(bodyRect),
        );
      } else {
        // Layer 1: Steamed Liquid Milk (warm ivory bottom)
        canvas.drawPath(
          liquidPath,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [
                Color(0xFFFDFBF7),
                Color(0xFFF3E8D8),
              ],
            ).createShader(bodyRect),
        );

        // Layer 2: Floating Velvety Microfoam Layer on Top!
        final double foamThickness =
            math.max(5.0, liquidHeight * foamLayerFraction.clamp(0.12, 0.42));
        final Path foamPath = Path();
        for (int i = 0; i <= samples; i++) {
          final double t = i / samples;
          final double x = bodyRect.left + t * bodyW;
          final double relX = (t - 0.5) * 2.0;
          final double wave = math.sin(wavePhase + t * math.pi * 2.0) * 2.2;
          final double y = surfaceY + relX * sloshSlope + wave;
          if (i == 0) {
            foamPath.moveTo(x, y);
          } else {
            foamPath.lineTo(x, y);
          }
        }
        for (int i = samples; i >= 0; i--) {
          final double t = i / samples;
          final double x = bodyRect.left + t * bodyW;
          final double relX = (t - 0.5) * 2.0;
          final double wave = math.sin(wavePhase + t * math.pi * 2.0) * 1.4;
          final double y =
              surfaceY + foamThickness + relX * sloshSlope * 0.8 + wave;
          foamPath.lineTo(x, y);
        }
        foamPath.close();
        canvas.drawPath(
          foamPath,
          Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.96),
        );
      }

      // Bright Meniscus Surface Line
      final Path meniscus = Path();
      for (int i = 0; i <= samples; i++) {
        final double t = i / samples;
        final double x = bodyRect.left + t * bodyW;
        final double relX = (t - 0.5) * 2.0;
        final double wave = math.sin(wavePhase + t * math.pi * 2.0) * 2.2;
        final double y = surfaceY + relX * sloshSlope + wave;
        if (i == 0) {
          meniscus.moveTo(x, y);
        } else {
          meniscus.lineTo(x, y);
        }
      }
      canvas.drawPath(
        meniscus,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    // 5. Printed Graduated ml Measurement Markings on Glass Wall!
    final markPaint = Paint()
      ..color = AppTheme.textDark.withValues(alpha: 0.45)
      ..strokeWidth = 1.0;
    for (int step = 1; step <= 4; step++) {
      final double frac = step / 5.0;
      final double y = bodyRect.bottom - bodyH * frac;
      final double markLen = step.isEven ? 11.0 : 7.0;
      canvas.drawLine(
        Offset(bodyRect.right - markLen - 3, y),
        Offset(bodyRect.right - 3, y),
        markPaint,
      );
      if (step.isEven) {
        final int mlVal = (capacityMl * frac).round();
        final tp = TextPainter(
          text: TextSpan(
            text: '$mlVal',
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark.withValues(alpha: 0.65),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(bodyRect.right - markLen - tp.width - 5, y - 4.5));
      }
    }

    // 6. Fresnel Specular Glass Vertical Glare
    canvas.drawLine(
      Offset(bodyRect.left + 6, bodyRect.top + 6),
      Offset(bodyRect.left + 6, bodyRect.bottom - 8),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.72)
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();

    // Crisp Glass Rim Outline
    canvas.drawRRect(
      vesselRRect,
      Paint()
        ..color = const Color(0xFF64748B).withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TransparentGlassVesselPainter oldDelegate) =>
      true;
}
