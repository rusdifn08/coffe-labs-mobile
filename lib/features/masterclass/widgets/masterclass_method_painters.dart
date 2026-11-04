import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/recipe_walkthrough_step.dart';

/// Custom vector painter that renders recipe-specific, step-specific, and method-specific
/// brewing animations (V60 Osmotic/Spiral/Bloom, Sandwich, 4:6, Moka Pot, Espresso, AeroPress, Syphon, etc.).
class MasterclassEquipmentPainter extends CustomPainter {
  final RecipeWalkthroughStep step;
  final double pulse;

  MasterclassEquipmentPainter({
    required this.step,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 4;
    final state = step.animationState;

    // Subtle background radial glow
    final bgGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD4AF37).withValues(alpha: 0.11 + pulse * 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 110));
    canvas.drawCircle(Offset(cx, cy), 110, bgGlow);

    switch (state) {
      case 'grind_calibrate':
        _drawGrindAndScaleCalibration(canvas, cx, cy);
        break;
      case 'filter_rinse':
        _drawFilterRinseSetup(canvas, cx, cy, withIce: false);
        break;
      case 'ice_server_prep':
        _drawFilterRinseSetup(canvas, cx, cy, withIce: true);
        break;
      case 'fines_separation':
        _drawKruveSieveSeparation(canvas, cx, cy);
        break;
      case 'first_filter':
        _drawDripperAndServer(canvas, cx, cy, fillRatio: 0.05);
        _drawFilterPaper(canvas, cx, cy);
        _drawWaterStream(canvas, cx, cy, mode: 'spiral');
        break;
      case 'fines_bed':
        _drawDripperAndServer(canvas, cx, cy, fillRatio: 0.05);
        _drawFilterPaper(canvas, cx, cy);
        _drawFinesLayer(canvas, cx, cy);
        break;
      case 'second_filter':
        _drawDripperAndServer(canvas, cx, cy, fillRatio: 0.05);
        _drawFilterPaper(canvas, cx, cy);
        _drawFinesLayer(canvas, cx, cy);
        _drawSecondSandwichFilter(canvas, cx, cy);
        break;
      case 'coarse_bed':
        _drawDripperAndServer(canvas, cx, cy, fillRatio: 0.05);
        _drawFilterPaper(canvas, cx, cy);
        _drawFinesLayer(canvas, cx, cy);
        _drawSecondSandwichFilter(canvas, cx, cy);
        _drawCoarseLayer(canvas, cx, cy);
        break;
      case 'bloom_pour':
        _drawDripperAndServer(canvas, cx, cy, fillRatio: _serverRatio(0.18), withIce: step.iceGrams > 0);
        _drawFilterPaper(canvas, cx, cy);
        _drawBloomingDome(canvas, cx, cy);
        _drawWaterStream(canvas, cx, cy, mode: 'bloom');
        break;
      case 'osmotic_pour':
        _drawDripperAndServer(canvas, cx, cy, fillRatio: _serverRatio(0.55), withIce: step.iceGrams > 0);
        _drawFilterPaper(canvas, cx, cy);
        _drawOsmoticDome(canvas, cx, cy);
        _drawWaterStream(canvas, cx, cy, mode: 'center');
        break;
      case 'pulse_46_pour':
        _drawDripperAndServer(canvas, cx, cy, fillRatio: _serverRatio(0.65), show46Markers: true);
        _drawFilterPaper(canvas, cx, cy);
        _drawCoarseLayer(canvas, cx, cy);
        _drawWaterStream(canvas, cx, cy, mode: 'spiral');
        break;
      case 'swirl_drawdown':
        _drawDripperAndServer(canvas, cx, cy, fillRatio: _serverRatio(0.92), withIce: step.iceGrams > 0);
        _drawFilterPaper(canvas, cx, cy);
        _drawSwirlAndDrawdown(canvas, cx, cy);
        break;
      case 'moka_boiler_prep':
        _drawMokaPot(canvas, cx, cy, isErupting: false);
        break;
      case 'moka_flame_erupt':
        _drawMokaPot(canvas, cx, cy, isErupting: true);
        break;
      case 'espresso_puck_prep':
        _drawEspressoPortafilter(canvas, cx, cy, isExtracting: false);
        break;
      case 'espresso_9bar_shot':
        _drawEspressoPortafilter(canvas, cx, cy, isExtracting: true);
        break;
      case 'aeropress_plunge':
        _drawAeroPress(canvas, cx, cy);
        break;
      case 'syphon_vacuum':
        _drawSyphonGlobe(canvas, cx, cy);
        break;
      case 'french_press_steep':
        _drawFrenchPress(canvas, cx, cy);
        break;
      case 'cold_brew_tower':
        _drawDripperAndServer(canvas, cx, cy, fillRatio: 0.65, withIce: true);
        _drawWaterStream(canvas, cx, cy, mode: 'center');
        break;
      case 'hybrid_switch_valve':
        _drawDripperAndServer(canvas, cx, cy, fillRatio: _serverRatio(0.5));
        _drawFilterPaper(canvas, cx, cy);
        canvas.drawCircle(
          Offset(cx + 26, cy + 40),
          7,
          Paint()..color = step.stepWaterGrams > 0 ? Colors.orangeAccent : Colors.greenAccent,
        );
        _drawWaterStream(canvas, cx, cy, mode: 'spiral');
        break;
      case 'ibrik_phin_brew':
        _drawMokaPot(canvas, cx, cy, isErupting: true);
        break;
      case 'spiral_pour':
      default:
        _drawDripperAndServer(canvas, cx, cy, fillRatio: _serverRatio(0.6), withIce: step.iceGrams > 0);
        _drawFilterPaper(canvas, cx, cy);
        _drawCoarseLayer(canvas, cx, cy);
        _drawWaterStream(canvas, cx, cy, mode: 'spiral');
        break;
    }
  }

  double _serverRatio(double fallback) {
    if (step.totalWaterGrams <= 0 || step.cumulativeWaterGrams <= 0) return fallback;
    return (step.cumulativeWaterGrams / step.totalWaterGrams).clamp(0.12, 0.95);
  }

  void _drawGrindAndScaleCalibration(Canvas canvas, double cx, double cy) {
    final stroke = Paint()
      ..color = const Color(0xFFFAF3EC).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final hopper = Path()
      ..moveTo(cx - 95, cy - 55)
      ..lineTo(cx - 45, cy - 55)
      ..lineTo(cx - 58, cy - 20)
      ..lineTo(cx - 82, cy - 20)
      ..close();
    canvas.drawPath(hopper, stroke);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 88, cy - 20, 36, 48), const Radius.circular(6)),
      stroke,
    );
    final groundPaint = Paint()..color = const Color(0xFFD4AF37);
    for (int i = 0; i < 6; i++) {
      final dy = cy + 32 + ((pulse * 22 + i * 4) % 20);
      canvas.drawCircle(Offset(cx - 70 + (i % 3 - 1) * 5.0, dy), 2.0, groundPaint);
    }

    final scaleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 48), width: 78, height: 22),
      const Radius.circular(6),
    );
    canvas.drawRRect(scaleRect, Paint()..color = const Color(0xFF3E3028));
    canvas.drawRRect(scaleRect, stroke);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + 22), width: 52, height: 30),
      0,
      math.pi,
      true,
      Paint()..color = const Color(0xFF8D6E63),
    );

    final kettle = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 70, cy + 12), width: 44, height: 50),
      const Radius.circular(8),
    );
    canvas.drawRRect(kettle, stroke);
    final steamPaint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    for (int i = 0; i < 3; i++) {
      final sx = cx + 58 + i * 11.0;
      final sy = cy - 22 - (pulse * 8);
      canvas.drawArc(Rect.fromCircle(center: Offset(sx, sy), radius: 5), 0.3, 2.4, false, steamPaint);
    }
  }

  void _drawFilterRinseSetup(Canvas canvas, double cx, double cy, {required bool withIce}) {
    _drawDripperAndServer(canvas, cx, cy, fillRatio: 0.12, withIce: withIce);
    _drawFilterPaper(canvas, cx, cy);
    _drawWaterStream(canvas, cx, cy, mode: 'spiral');
  }

  void _drawKruveSieveSeparation(Canvas canvas, double cx, double cy) {
    final shift = math.sin(pulse * math.pi * 2) * 3.5;
    final boxPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - 48 + shift, cy + 5), width: 68, height: 64), const Radius.circular(10)),
      boxPaint,
    );
    final finePaint = Paint()..color = const Color(0xFFD4AF37);
    for (int i = 0; i < 20; i++) {
      canvas.drawCircle(Offset(cx - 66 + shift + (i % 5) * 9, cy - 6 + (i ~/ 5) * 9), 1.8, finePaint);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 48 - shift, cy + 5), width: 68, height: 64), const Radius.circular(10)),
      boxPaint,
    );
    final coarsePaint = Paint()..color = const Color(0xFFA1887F);
    for (int i = 0; i < 12; i++) {
      canvas.drawCircle(Offset(cx + 32 - shift + (i % 4) * 11, cy - 6 + (i ~/ 4) * 11), 3.4, coarsePaint);
    }
  }

  void _drawDripperAndServer(
    Canvas canvas,
    double cx,
    double cy, {
    required double fillRatio,
    bool withIce = false,
    bool show46Markers = false,
  }) {
    final dripperPaint = Paint()
      ..color = const Color(0xFFFAF3EC).withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final cone = Path()
      ..moveTo(cx - 72, cy - 42)
      ..lineTo(cx + 72, cy - 42)
      ..lineTo(cx + 24, cy + 42)
      ..lineTo(cx - 24, cy + 42)
      ..close();
    canvas.drawPath(cone, dripperPaint);

    final serverRect = Rect.fromCenter(center: Offset(cx, cy + 68), width: 78, height: 38);
    final serverRRect = RRect.fromRectAndRadius(serverRect, const Radius.circular(8));

    final liquidHeight = (36.0 * fillRatio).clamp(4.0, 34.0);
    final liquidRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(serverRect.left + 2, serverRect.bottom - liquidHeight, serverRect.width - 4, liquidHeight),
      const Radius.circular(6),
    );
    canvas.drawRRect(liquidRect, Paint()..color = const Color(0xFFB86B28).withValues(alpha: 0.78));

    if (withIce) {
      final icePaint = Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.75);
      for (int i = 0; i < 4; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx - 18 + i * 12.0, serverRect.bottom - 10), width: 9, height: 9),
            const Radius.circular(2),
          ),
          icePaint,
        );
      }
    }

    canvas.drawRRect(
      serverRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    if (show46Markers) {
      final y40 = serverRect.bottom - 36 * 0.4;
      canvas.drawLine(
        Offset(serverRect.right + 4, y40),
        Offset(serverRect.right + 14, y40),
        Paint()..color = const Color(0xFFD4AF37)..strokeWidth = 1.5,
      );
    }
  }

  void _drawFilterPaper(Canvas canvas, double cx, double cy) {
    final path = Path()
      ..moveTo(cx - 64, cy - 36)
      ..lineTo(cx + 64, cy - 36)
      ..lineTo(cx + 20, cy + 38)
      ..lineTo(cx - 20, cy + 38)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  void _drawFinesLayer(Canvas canvas, double cx, double cy) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 30), width: 36, height: 11), const Radius.circular(3)),
      Paint()..color = const Color(0xFFD4AF37),
    );
  }

  void _drawSecondSandwichFilter(Canvas canvas, double cx, double cy) {
    canvas.drawLine(
      Offset(cx - 24, cy + 22),
      Offset(cx + 24, cy + 22),
      Paint()..color = Colors.cyanAccent..strokeWidth = 2.8,
    );
  }

  void _drawCoarseLayer(Canvas canvas, double cx, double cy) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 12), width: 58, height: 22), const Radius.circular(4)),
      Paint()..color = const Color(0xFF6D4C41),
    );
  }

  void _drawBloomingDome(Canvas canvas, double cx, double cy) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 16), width: 64, height: 20.0 + pulse * 7.0),
      Paint()..color = const Color(0xFF795548),
    );
    final bubblePaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = -2; i <= 2; i++) {
      final bx = cx + i * 11.0;
      final by = cy + 6 - ((pulse * 18 + i.abs() * 5) % 18);
      canvas.drawCircle(Offset(bx, by), 3.0, bubblePaint);
    }
  }

  void _drawOsmoticDome(Canvas canvas, double cx, double cy) {
    final domePath = Path()
      ..moveTo(cx - 38, cy + 28)
      ..quadraticBezierTo(cx, cy - 12 - pulse * 6, cx + 38, cy + 28)
      ..close();
    canvas.drawPath(domePath, Paint()..color = const Color(0xFF6D4C41));
    canvas.drawPath(
      domePath,
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _drawWaterStream(Canvas canvas, double cx, double cy, {required String mode}) {
    final double sweepX = mode == 'center'
        ? 0.0
        : (mode == 'bloom' ? math.sin(pulse * math.pi * 2) * 10 : math.sin(pulse * math.pi * 2) * 24);

    canvas.drawLine(
      Offset(cx + sweepX * 0.5, cy - 75),
      Offset(cx + sweepX, cy + 4),
      Paint()
        ..color = Colors.lightBlueAccent.withValues(alpha: 0.85)
        ..strokeWidth = mode == 'center' ? 3.8 : 3.0
        ..strokeCap = StrokeCap.round,
    );

    if (mode == 'spiral') {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + 4), width: 22 + pulse * 30, height: 8 + pulse * 10),
        Paint()
          ..color = Colors.lightBlueAccent.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    canvas.drawCircle(Offset(cx, cy + 42 + (pulse * 14)), 3.0, Paint()..color = const Color(0xFFD4AF37));
  }

  void _drawSwirlAndDrawdown(Canvas canvas, double cx, double cy) {
    _drawCoarseLayer(canvas, cx, cy);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy - 6), width: 76, height: 22),
      pulse * math.pi,
      math.pi * 0.8,
      false,
      Paint()
        ..color = const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _drawMokaPot(Canvas canvas, double cx, double cy, {required bool isErupting}) {
    final metal = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final boiler = Path()
      ..moveTo(cx - 32, cy + 12)..lineTo(cx + 32, cy + 12)
      ..lineTo(cx + 42, cy + 64)..lineTo(cx - 42, cy + 64)..close();
    canvas.drawPath(boiler, metal);
    canvas.drawRect(Rect.fromLTWH(cx - 34, cy + 32, 68, 30), Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.35));

    final top = Path()
      ..moveTo(cx - 40, cy - 52)..lineTo(cx + 40, cy - 52)
      ..lineTo(cx + 30, cy + 10)..lineTo(cx - 30, cy + 10)..close();
    canvas.drawPath(top, metal);
    canvas.drawLine(Offset(cx, cy + 45), Offset(cx, cy - 30), metal);

    if (isErupting) {
      final flamePaint = Paint()..color = Colors.deepOrangeAccent.withValues(alpha: 0.75 + pulse * 0.25);
      for (int i = -2; i <= 2; i++) {
        canvas.drawCircle(Offset(cx + i * 14.0, cy + 72 - pulse * 4), 5.0, flamePaint);
      }
      final fountainPaint = Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.stroke..strokeWidth = 3.0;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx - 10, cy - 30), radius: 10), -math.pi, math.pi * 0.8, false, fountainPaint);
      canvas.drawArc(Rect.fromCircle(center: Offset(cx + 10, cy - 30), radius: 10), -math.pi * 0.8, math.pi * 0.8, false, fountainPaint);
    }
  }

  void _drawEspressoPortafilter(Canvas canvas, double cx, double cy, {required bool isExtracting}) {
    final steel = Paint()..color = const Color(0xFFE0E0E0)..style = PaintingStyle.stroke..strokeWidth = 2.5;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - 15), width: 76, height: 28), const Radius.circular(6)), steel);
    canvas.drawLine(Offset(cx + 38, cy - 15), Offset(cx + 95, cy - 15), steel..strokeWidth = 5);

    if (!isExtracting) {
      final tamperY = cy - 48 + pulse * 12;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, tamperY), width: 64, height: 14), const Radius.circular(3)), Paint()..color = const Color(0xFFD4AF37));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, tamperY - 22), width: 22, height: 30), const Radius.circular(8)), Paint()..color = const Color(0xFF8D6E63));
    } else {
      final crema = Path()..moveTo(cx - 16, cy)..lineTo(cx + 16, cy)..lineTo(cx + 4, cy + 54)..lineTo(cx - 4, cy + 54)..close();
      canvas.drawPath(crema, Paint()..color = const Color(0xFFD4AF37));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 56), width: 52, height: 40), const Radius.circular(6)), steel..strokeWidth = 2.0);
    }
  }

  void _drawAeroPress(Canvas canvas, double cx, double cy) {
    final tube = Paint()..color = Colors.white.withValues(alpha: 0.7)..style = PaintingStyle.stroke..strokeWidth = 2.2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 10), width: 56, height: 86), const Radius.circular(4)), tube);
    final plungeY = cy - 42 + pulse * 26;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, plungeY), width: 48, height: 56), const Radius.circular(3)), Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.45));
  }

  void _drawSyphonGlobe(Canvas canvas, double cx, double cy) {
    final glass = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.65)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    canvas.drawCircle(Offset(cx, cy + 36), 30, glass);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - 26), width: 56, height: 50), const Radius.circular(14)), glass);
    canvas.drawLine(Offset(cx, cy - 2), Offset(cx, cy + 52), glass);
  }

  void _drawFrenchPress(Canvas canvas, double cx, double cy) {
    final glass = Paint()..color = Colors.white.withValues(alpha: 0.7)..style = PaintingStyle.stroke..strokeWidth = 2.2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 12), width: 66, height: 90), const Radius.circular(6)), glass);
    final meshY = cy - 18 + pulse * 32;
    canvas.drawLine(Offset(cx, cy - 56), Offset(cx, meshY), glass);
    canvas.drawLine(Offset(cx - 28, meshY), Offset(cx + 28, meshY), Paint()..color = const Color(0xFFD4AF37)..strokeWidth = 3.5);
  }

  @override
  bool shouldRepaint(covariant MasterclassEquipmentPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.pulse != pulse;
  }
}
