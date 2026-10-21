import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Professional SVG-quality vector icons for Barista Toolkit
class ToolkitVectorIcon extends StatelessWidget {
  final String type;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const ToolkitVectorIcon({
    super.key,
    required this.type,
    this.size = 24,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ToolkitIconPainter(
          type: type,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
      ),
    );
  }
}

class _ToolkitIconPainter extends CustomPainter {
  final String type;
  final Color primaryColor;
  final Color secondaryColor;

  _ToolkitIconPainter({
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (type) {
      case 'favorite':
        _paintFavorite(canvas, w, h);
        break;
      case 'cupping':
        _paintCupping(canvas, w, h);
        break;
      case 'roastery':
        _paintRoastery(canvas, w, h);
        break;
      case 'radar':
        _paintRadar(canvas, w, h);
        break;
      case 'journal':
        _paintJournal(canvas, w, h);
        break;
      case 'scale':
        _paintScale(canvas, w, h);
        break;
      case 'social':
        _paintSocial(canvas, w, h);
        break;
    }
  }

  // 1. Favorite: Modern Coffee Heart with Steam Wave
  void _paintFavorite(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final path = Path();
    // Heart Shape
    path.moveTo(w * 0.5, h * 0.85);
    path.cubicTo(w * 0.15, h * 0.65, 0, h * 0.45, 0, h * 0.28);
    path.cubicTo(0, h * 0.1, w * 0.22, 0, w * 0.42, h * 0.08);
    path.cubicTo(w * 0.46, h * 0.1, w * 0.5, h * 0.16, w * 0.5, h * 0.16);
    path.cubicTo(w * 0.5, h * 0.16, w * 0.54, h * 0.1, w * 0.58, h * 0.08);
    path.cubicTo(w * 0.78, 0, w, h * 0.1, w, h * 0.28);
    path.cubicTo(w, h * 0.45, w * 0.85, h * 0.65, w * 0.5, h * 0.85);
    path.close();

    canvas.drawPath(path, paint);

    // Inner coffee bean crease
    final creasePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    final crease = Path();
    crease.moveTo(w * 0.5, h * 0.3);
    crease.cubicTo(w * 0.42, h * 0.45, w * 0.58, h * 0.55, w * 0.5, h * 0.7);
    canvas.drawPath(crease, creasePaint);
  }

  // 2. Cupping Flavour: Radial Flavor Wheel with Center Drop
  void _paintCupping(Canvas canvas, double w, double h) {
    final center = Offset(w * 0.5, h * 0.5);
    final radius = w * 0.44;
    final strokeWidth = w * 0.18;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 4 vibrant flavor sectors
    final colors = [
      primaryColor,
      secondaryColor,
      const Color(0xFFFFB300),
      const Color(0xFFD84315),
    ];

    for (int i = 0; i < 4; i++) {
      arcPaint.color = colors[i];
      final startAngle = i * (math.pi / 2) + 0.12;
      final sweepAngle = (math.pi / 2) - 0.24;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth * 0.5),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }

    // Center coffee droplet
    final dropPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final dropPath = Path();
    dropPath.moveTo(w * 0.5, h * 0.36);
    dropPath.cubicTo(w * 0.42, h * 0.46, w * 0.42, h * 0.58, w * 0.5, h * 0.62);
    dropPath.cubicTo(w * 0.58, h * 0.58, w * 0.58, h * 0.46, w * 0.5, h * 0.36);
    dropPath.close();

    canvas.drawPath(dropPath, dropPaint);
  }

  // 3. Coffee Roastery: Dual Roasting Flame & Artisan Bean
  void _paintRoastery(Canvas canvas, double w, double h) {
    final flamePaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Outer flame
    final flame = Path();
    flame.moveTo(w * 0.5, 0);
    flame.cubicTo(w * 0.72, h * 0.25, w * 0.95, h * 0.55, w * 0.85, h * 0.82);
    flame.cubicTo(w * 0.75, h, w * 0.25, h, w * 0.15, h * 0.82);
    flame.cubicTo(w * 0.05, h * 0.55, w * 0.28, h * 0.25, w * 0.5, 0);
    flame.close();

    canvas.drawPath(flame, flamePaint);

    // Inner ember core
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final core = Path();
    core.moveTo(w * 0.5, h * 0.42);
    core.cubicTo(w * 0.65, h * 0.58, w * 0.65, h * 0.78, w * 0.5, h * 0.88);
    core.cubicTo(w * 0.35, h * 0.78, w * 0.35, h * 0.58, w * 0.5, h * 0.42);
    core.close();

    canvas.drawPath(core, corePaint);
  }

  // 4. Beans Radar: High-Tech Radar Dish & Target Pin
  void _paintRadar(Canvas canvas, double w, double h) {
    final center = Offset(w * 0.5, h * 0.5);

    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07;

    // Outer radar ring
    canvas.drawCircle(center, w * 0.42, linePaint);

    // Inner radar ring
    linePaint.color = primaryColor.withValues(alpha: 0.75);
    canvas.drawCircle(center, w * 0.26, linePaint);

    // Crosshair axis
    final axisPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..strokeWidth = w * 0.05;
    canvas.drawLine(Offset(w * 0.1, h * 0.5), Offset(w * 0.9, h * 0.5), axisPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, h * 0.9), axisPaint);

    // Center focal dot
    final centerDot = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.1, centerDot);

    // Target Ping Blip
    final pingDot = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.72, h * 0.32), w * 0.09, pingDot);
  }

  // 5. Jurnal Brew: Minimalist Brewing Logbook & Waveform
  void _paintJournal(Canvas canvas, double w, double h) {
    final bgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.08, w * 0.7, h * 0.84),
      Radius.circular(w * 0.15),
    );
    canvas.drawRRect(rect, bgPaint);

    // Log lines
    final linePaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.3, h * 0.32), Offset(w * 0.7, h * 0.32), linePaint);
    canvas.drawLine(Offset(w * 0.3, h * 0.5), Offset(w * 0.7, h * 0.5), linePaint);
    canvas.drawLine(Offset(w * 0.3, h * 0.68), Offset(w * 0.55, h * 0.68), linePaint);

    // Checklist checkmark
    final checkPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.7, h * 0.68), w * 0.08, checkPaint);
  }

  // 6. Smart Scale: Precision Digital Scale & Platform
  void _paintScale(Canvas canvas, double w, double h) {
    final scalePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale outer plate
    final plate = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, h * 0.18, w * 0.8, h * 0.64),
      Radius.circular(w * 0.18),
    );
    canvas.drawRRect(plate, scalePaint);

    // Digital LED screen
    final screenPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.52, w * 0.44, h * 0.2),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(screenRect, screenPaint);

    // LED readout line
    final ledPaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.35, h * 0.62), Offset(w * 0.65, h * 0.62), ledPaint);

    // Circular weighing tray marker
    final circlePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05;
    canvas.drawCircle(Offset(w * 0.5, h * 0.34), w * 0.12, circlePaint);
  }

  // 7. Social Coffee: Community Dialogue & Coffee Network
  void _paintSocial(Canvas canvas, double w, double h) {
    // Back speech bubble (community network)
    final backBubblePaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    final backBubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.35, h * 0.12, w * 0.55, h * 0.45),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(backBubble, backBubblePaint);

    // Front main speech bubble with gradient
    final frontPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final frontBubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.32, w * 0.65, h * 0.52),
      Radius.circular(w * 0.18),
    );
    canvas.drawRRect(frontBubble, frontPaint);

    // Speech bubble tail
    final tailPath = Path();
    tailPath.moveTo(w * 0.22, h * 0.82);
    tailPath.lineTo(w * 0.14, h * 0.94);
    tailPath.lineTo(w * 0.34, h * 0.84);
    tailPath.close();
    canvas.drawPath(tailPath, frontPaint);

    // Miniature coffee cup in front bubble
    final cupPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;

    final cupPath = Path();
    cupPath.moveTo(w * 0.28, h * 0.48);
    cupPath.lineTo(w * 0.30, h * 0.66);
    cupPath.cubicTo(w * 0.30, h * 0.72, w * 0.50, h * 0.72, w * 0.50, h * 0.66);
    cupPath.lineTo(w * 0.52, h * 0.48);
    canvas.drawPath(cupPath, cupPaint);

    // Cup handle
    final handlePath = Path();
    handlePath.moveTo(w * 0.52, h * 0.52);
    handlePath.cubicTo(w * 0.60, h * 0.52, w * 0.60, h * 0.62, w * 0.51, h * 0.62);
    canvas.drawPath(handlePath, cupPaint);

    // Rising steam wave (social discussion vibe)
    final steamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    final steam1 = Path();
    steam1.moveTo(w * 0.36, h * 0.44);
    steam1.cubicTo(w * 0.34, h * 0.40, w * 0.38, h * 0.38, w * 0.36, h * 0.34);
    canvas.drawPath(steam1, steamPaint);

    final steam2 = Path();
    steam2.moveTo(w * 0.44, h * 0.44);
    steam2.cubicTo(w * 0.42, h * 0.40, w * 0.46, h * 0.38, w * 0.44, h * 0.34);
    canvas.drawPath(steam2, steamPaint);
  }

  @override
  bool shouldRepaint(covariant _ToolkitIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
