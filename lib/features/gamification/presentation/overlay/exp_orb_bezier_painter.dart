import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 120 FPS CustomPainter drawing 12 glowing gold-and-blue EXP orbs
/// along staggered quadratic Bézier arcs into the progress bar tip.
class ExpOrbBezierPainter extends CustomPainter {
  final double progress;
  final Offset startCenter;
  final Offset targetTip;

  ExpOrbBezierPainter({
    required this.progress,
    required this.startCenter,
    required this.targetTip,
  });

  static const int orbCount = 12;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    for (int i = 0; i < orbCount; i++) {
      final delay = (i / orbCount) * 0.42;
      final localT = ((progress - delay) / 0.58).clamp(0.0, 1.0);
      if (localT <= 0.0 || localT >= 1.0) continue;

      final u = Curves.easeInOutCubic.transform(localT);
      final spreadAngle = (i - orbCount / 2) * 0.35;
      final control = Offset(
        (startCenter.dx + targetTip.dx) * 0.5 + math.sin(spreadAngle) * 110,
        (startCenter.dy + targetTip.dy) * 0.5 + math.cos(spreadAngle) * 60,
      );

      final oneMinusU = 1.0 - u;
      final pos = Offset(
        oneMinusU * oneMinusU * startCenter.dx +
            2 * oneMinusU * u * control.dx +
            u * u * targetTip.dx,
        oneMinusU * oneMinusU * startCenter.dy +
            2 * oneMinusU * u * control.dy +
            u * u * targetTip.dy,
      );

      final isGold = i.isEven;
      final baseColor =
          isGold ? const Color(0xFFD4AF37) : const Color(0xFF2563EB);
      final alpha = math.sin(localT * math.pi).clamp(0.0, 1.0);

      canvas.drawCircle(
        pos,
        8.0,
        Paint()..color = baseColor.withValues(alpha: 0.25 * alpha),
      );
      canvas.drawCircle(
        pos,
        4.2,
        Paint()..color = baseColor.withValues(alpha: 0.92 * alpha),
      );
      canvas.drawCircle(
        pos,
        1.8,
        Paint()..color = Colors.white.withValues(alpha: 0.95 * alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ExpOrbBezierPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.targetTip != targetTip ||
      oldDelegate.startCenter != startCenter;
}
