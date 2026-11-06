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
      case 'marketplace':
        _paintMarketplace(canvas, w, h);
        break;
      case 'smart_brew_ai':
        _paintSmartBrewAi(canvas, w, h);
        break;
      case 'studio_ai':
        _paintStudioAi(canvas, w, h);
        break;
      case 'dialin':
        _paintDialin(canvas, w, h);
        break;
      case 'grinder':
        _paintGrinder(canvas, w, h);
        break;
      case 'foursix':
        _paintFourSix(canvas, w, h);
        break;
      case 'tds':
        _paintTds(canvas, w, h);
        break;
      case 'water':
        _paintWater(canvas, w, h);
        break;
      case 'freshness':
        _paintFreshness(canvas, w, h);
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

  // 8. Marketplace: Specialty Coffee Shopping Bag & Beans
  void _paintMarketplace(Canvas canvas, double w, double h) {
    // Bag body with gradient
    final bagPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final bagRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.30, w * 0.64, h * 0.58),
      Radius.circular(w * 0.14),
    );
    canvas.drawRRect(bagRect, bagPaint);

    // Bag handles
    final handlePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    final handlePath = Path();
    handlePath.moveTo(w * 0.34, h * 0.30);
    handlePath.cubicTo(w * 0.34, h * 0.10, w * 0.66, h * 0.10, w * 0.66, h * 0.30);
    canvas.drawPath(handlePath, handlePaint);

    // White Coffee bean emblem on bag center
    final beanPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.58), width: w * 0.22, height: w * 0.28), beanPaint);

    final seamPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    final seamPath = Path();
    seamPath.moveTo(w * 0.5, h * 0.47);
    seamPath.cubicTo(w * 0.46, h * 0.56, w * 0.54, h * 0.60, w * 0.5, h * 0.69);
    canvas.drawPath(seamPath, seamPaint);
  }

  // 9. Smart Brew AI: Specialty V60 Dripper with AI Holographic Intelligence Spark
  void _paintSmartBrewAi(Canvas canvas, double w, double h) {
    // V60 Cone body with gradient
    final dripperPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cone = Path();
    cone.moveTo(w * 0.16, h * 0.30);
    cone.lineTo(w * 0.84, h * 0.30);
    cone.lineTo(w * 0.58, h * 0.70);
    cone.lineTo(w * 0.42, h * 0.70);
    cone.close();
    canvas.drawPath(cone, dripperPaint);

    // Dripper base collar
    final collarPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.28, h * 0.76), Offset(w * 0.72, h * 0.76), collarPaint);

    // Internal spiral extraction ribs
    final ribPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.7)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.36, h * 0.38), Offset(w * 0.46, h * 0.62), ribPaint);
    canvas.drawLine(Offset(w * 0.64, h * 0.38), Offset(w * 0.54, h * 0.62), ribPaint);

    // Extraction drip falling
    final dripPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final drip = Path();
    drip.moveTo(w * 0.50, h * 0.82);
    drip.cubicTo(w * 0.44, h * 0.88, w * 0.44, h * 0.94, w * 0.50, h * 0.96);
    drip.cubicTo(w * 0.56, h * 0.94, w * 0.56, h * 0.88, w * 0.50, h * 0.82);
    drip.close();
    canvas.drawPath(drip, dripPaint);

    // Floating 4-point AI Star above dripper
    final starPaint = Paint()..color = secondaryColor;
    final star = Path();
    final sx = w * 0.50;
    final sy = h * 0.16;
    star.moveTo(sx, sy - h * 0.13);
    star.cubicTo(sx + w * 0.03, sy - h * 0.03, sx + w * 0.03, sy - h * 0.03, sx + w * 0.13, sy);
    star.cubicTo(sx + w * 0.03, sy + h * 0.03, sx + w * 0.03, sy + h * 0.03, sx, sy + h * 0.13);
    star.cubicTo(sx - w * 0.03, sy + h * 0.03, sx - w * 0.03, sy + h * 0.03, sx - w * 0.13, sy);
    star.cubicTo(sx - w * 0.03, sy - h * 0.03, sx - w * 0.03, sy - h * 0.03, sx, sy - h * 0.13);
    star.close();
    canvas.drawPath(star, starPaint);

    // Inner bright center dot
    canvas.drawCircle(Offset(sx, sy), w * 0.035, Paint()..color = Colors.white);
  }

  // 10. Studio AI: Computer Vision Viewfinder & Neural Packaging Detector
  void _paintStudioAi(Canvas canvas, double w, double h) {
    final bracketPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arm = w * 0.22;
    // Top-Left Corner
    final tl = Path()
      ..moveTo(w * 0.10, h * 0.10 + arm)
      ..lineTo(w * 0.10, h * 0.10)
      ..lineTo(w * 0.10 + arm, h * 0.10);
    canvas.drawPath(tl, bracketPaint);

    // Top-Right Corner
    final tr = Path()
      ..moveTo(w * 0.90 - arm, h * 0.10)
      ..lineTo(w * 0.90, h * 0.10)
      ..lineTo(w * 0.90, h * 0.10 + arm);
    canvas.drawPath(tr, bracketPaint);

    // Bottom-Left Corner
    final bl = Path()
      ..moveTo(w * 0.10, h * 0.90 - arm)
      ..lineTo(w * 0.10, h * 0.90)
      ..lineTo(w * 0.10 + arm, h * 0.90);
    canvas.drawPath(bl, bracketPaint);

    // Bottom-Right Corner
    final br = Path()
      ..moveTo(w * 0.90 - arm, h * 0.90)
      ..lineTo(w * 0.90, h * 0.90)
      ..lineTo(w * 0.90, h * 0.90 - arm);
    canvas.drawPath(br, bracketPaint);

    // Center Coffee Bag Silhouette
    final bagPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: 0.85),
          secondaryColor,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final bag = Path();
    bag.moveTo(w * 0.32, h * 0.30);
    bag.lineTo(w * 0.68, h * 0.30);
    bag.lineTo(w * 0.74, h * 0.78);
    bag.cubicTo(w * 0.74, h * 0.82, w * 0.70, h * 0.84, w * 0.66, h * 0.84);
    bag.lineTo(w * 0.34, h * 0.84);
    bag.cubicTo(w * 0.30, h * 0.84, w * 0.26, h * 0.82, w * 0.26, h * 0.78);
    bag.close();
    canvas.drawPath(bag, bagPaint);

    // Top Seal Fold
    final sealPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.34, h * 0.32), Offset(w * 0.66, h * 0.32), sealPaint);

    // Center Scanning AI Laser Line & Dot
    final laserPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.22, h * 0.54), Offset(w * 0.78, h * 0.54), laserPaint);

    final focalDot = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.50, h * 0.54), w * 0.08, focalDot);
    canvas.drawCircle(Offset(w * 0.50, h * 0.54), w * 0.045, Paint()..color = const Color(0xFF5C3A21));
  }

  // 11. Asisten Dial-In: Precision Espresso & Filter Calibration Gauge & Adjustment Dial
  void _paintDialin(Canvas canvas, double w, double h) {
    final center = Offset(w * 0.50, h * 0.52);
    final radius = w * 0.40;

    // Outer Gauge Arc (260 degrees)
    final gaugePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..color = primaryColor.withValues(alpha: 0.25);

    const startAngle = 0.75 * math.pi;
    const sweepAngle = 1.50 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      gaugePaint,
    );

    // Sweet Spot Active Zone (Golden Green / Bright Magenta highlight)
    final sweetSpotPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle * 0.45,
      sweepAngle * 0.35,
      false,
      sweetSpotPaint,
    );

    // Tick Marks (Coarse to Fine)
    final tickPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= 6; i++) {
      final angle = startAngle + (sweepAngle * (i / 6.0));
      final innerR = radius - w * 0.12;
      final outerR = radius - w * 0.05;
      final p1 = Offset(center.dx + innerR * math.cos(angle), center.dy + innerR * math.sin(angle));
      final p2 = Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle));
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Dial Needle pointing to Sweet Spot
    final needleAngle = startAngle + sweepAngle * 0.62;
    final needleEnd = Offset(
      center.dx + (radius - w * 0.06) * math.cos(needleAngle),
      center.dy + (radius - w * 0.06) * math.sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Central Precision Hub
    canvas.drawCircle(center, w * 0.12, Paint()..color = primaryColor);
    canvas.drawCircle(center, w * 0.05, Paint()..color = Colors.white);
  }

  // 12. Matriks Grinder: Coffee Burr Blades & Micron Click Calibration Mechanism
  void _paintGrinder(Canvas canvas, double w, double h) {
    final center = Offset(w * 0.50, h * 0.50);

    // Outer Burr Ring
    final ringPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075;
    canvas.drawCircle(center, w * 0.42, ringPaint);

    // 8 Conical Cutting Blades radiating outward
    final bladePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.065
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      final p1 = Offset(center.dx + w * 0.18 * math.cos(angle), center.dy + w * 0.18 * math.sin(angle));
      final p2 = Offset(
        center.dx + w * 0.40 * math.cos(angle + 0.28),
        center.dy + w * 0.40 * math.sin(angle + 0.28),
      );
      canvas.drawLine(p1, p2, bladePaint);
    }

    // Inner Cone Hub
    final hubPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.18, hubPaint);

    // Center Click Hex Adjustment Nut
    final hexPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, w * 0.07, hexPaint);

    // Micron Click Indicator Dots on outer perimeter
    final dotPaint = Paint()..color = secondaryColor;
    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4) + (math.pi / 8);
      final p = Offset(center.dx + w * 0.35 * math.cos(angle), center.dy + w * 0.35 * math.sin(angle));
      canvas.drawCircle(p, w * 0.025, dotPaint);
    }
  }

  // 13. Kalkulator 4:6: Tetsu Kasuya 4:6 Segmented Ratio Ring & Precision Pour Steps
  void _paintFourSix(Canvas canvas, double w, double h) {
    final center = Offset(w * 0.50, h * 0.50);
    final radius = w * 0.40;
    final strokeWidth = w * 0.11;

    // Phase 1 (40% Sweetness/Acidity) - 2 Pours
    final phase1Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = primaryColor;

    const start1 = -math.pi * 0.5;
    const sweep1 = (144.0 / 180.0) * math.pi - 0.15;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start1,
      sweep1,
      false,
      phase1Paint,
    );

    // Phase 2 (60% Strength/Body) - 3 Pours
    final phase2Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = secondaryColor;

    final start2 = start1 + sweep1 + 0.30;
    const sweep2 = (216.0 / 180.0) * math.pi - 0.30;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start2,
      sweep2,
      false,
      phase2Paint,
    );

    // Center Pour Drop
    final dropPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final drop = Path();
    drop.moveTo(w * 0.50, h * 0.30);
    drop.cubicTo(w * 0.38, h * 0.46, w * 0.38, h * 0.65, w * 0.50, h * 0.70);
    drop.cubicTo(w * 0.62, h * 0.65, w * 0.62, h * 0.46, w * 0.50, h * 0.30);
    drop.close();
    canvas.drawPath(drop, dropPaint);

    // High clarity white core
    canvas.drawCircle(Offset(w * 0.50, h * 0.56), w * 0.05, Paint()..color = Colors.white);
  }

  // 14. Ekstraksi & TDS: SCA Extraction Yield % Refractometer Prism & Golden Cup Graph
  void _paintTds(Canvas canvas, double w, double h) {
    // Coordinate Graph Box (Golden Cup Region)
    final gridPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05;

    final graphRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.15, w * 0.76, h * 0.72),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(graphRect, gridPaint);

    // Ideal SCA Golden Zone (18% - 22% EY) Target Fill
    final goldenZonePaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;

    final targetZone = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.34, h * 0.30, w * 0.38, h * 0.38),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(targetZone, goldenZonePaint);

    // Extraction Yield Curve climbing across axes
    final curvePaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    final curve = Path();
    curve.moveTo(w * 0.22, h * 0.72);
    curve.cubicTo(w * 0.35, h * 0.68, w * 0.42, h * 0.52, w * 0.53, h * 0.46);
    curve.lineTo(w * 0.72, h * 0.32);
    canvas.drawPath(curve, curvePaint);

    // Focal Target Bullseye in Golden Cup Zone
    final bullseye = Offset(w * 0.53, h * 0.46);
    canvas.drawCircle(bullseye, w * 0.09, Paint()..color = primaryColor);
    canvas.drawCircle(bullseye, w * 0.045, Paint()..color = Colors.white);

    // Axis indicator tick marks
    final axisPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.12, h * 0.87), Offset(w * 0.88, h * 0.87), axisPaint);
    canvas.drawLine(Offset(w * 0.12, h * 0.15), Offset(w * 0.12, h * 0.87), axisPaint);
  }

  // 15. Kimia Air Seduh: Mineral Water Droplet with Chemical Bond Ion Core
  void _paintWater(Canvas canvas, double w, double h) {
    final dropPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final drop = Path();
    drop.moveTo(w * 0.50, h * 0.10);
    drop.cubicTo(w * 0.22, h * 0.45, w * 0.15, h * 0.70, w * 0.28, h * 0.86);
    drop.cubicTo(w * 0.38, h * 0.96, w * 0.62, h * 0.96, w * 0.72, h * 0.86);
    drop.cubicTo(w * 0.85, h * 0.70, w * 0.78, h * 0.45, w * 0.50, h * 0.10);
    drop.close();
    canvas.drawPath(drop, dropPaint);

    // Mineral Molecule Bond Ring (Ca2+ / Mg2+ Buffer)
    final bondPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    final c = Offset(w * 0.50, h * 0.65);
    canvas.drawCircle(c, w * 0.14, bondPaint);

    final ionPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.51), w * 0.045, ionPaint);
    canvas.drawCircle(Offset(w * 0.38, h * 0.73), w * 0.045, ionPaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.73), w * 0.045, ionPaint);
  }

  // 16. Kesegaran Biji: Roasted Specialty Coffee Bean with Ascending CO2 Degassing Curve
  void _paintFreshness(Canvas canvas, double w, double h) {
    final beanCenter = Offset(w * 0.50, h * 0.68);
    final beanPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: beanCenter, width: w * 0.62, height: h * 0.44),
      beanPaint,
    );

    // Bean center crease
    final seamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = w * 0.06
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final seam = Path();
    seam.moveTo(beanCenter.dx - w * 0.22, beanCenter.dy);
    seam.cubicTo(
      beanCenter.dx - w * 0.05,
      beanCenter.dy - h * 0.08,
      beanCenter.dx + w * 0.05,
      beanCenter.dy + h * 0.08,
      beanCenter.dx + w * 0.22,
      beanCenter.dy,
    );
    canvas.drawPath(seam, seamPaint);

    // Rising CO2 Degassing Wavelets
    final co2Paint = Paint()
      ..color = secondaryColor
      ..strokeWidth = w * 0.06
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wave1 = Path();
    wave1.moveTo(w * 0.36, h * 0.42);
    wave1.cubicTo(w * 0.32, h * 0.32, w * 0.40, h * 0.24, w * 0.34, h * 0.14);
    canvas.drawPath(wave1, co2Paint);

    final wave2 = Path();
    wave2.moveTo(w * 0.64, h * 0.42);
    wave2.cubicTo(w * 0.68, h * 0.32, w * 0.60, h * 0.24, w * 0.66, h * 0.14);
    canvas.drawPath(wave2, co2Paint);

    // Peak flavor sparkle at top
    canvas.drawCircle(Offset(w * 0.50, h * 0.16), w * 0.045, Paint()..color = primaryColor);
  }

  @override
  bool shouldRepaint(covariant _ToolkitIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
