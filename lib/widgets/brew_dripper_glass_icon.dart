import 'package:flutter/material.dart';

/// Icon vektor presisi tinggi Pour Over Specialty Coffee:
/// Dripper kerucut V60 di bagian atas dengan sudut 60 derajat yang tajam dan alur spiral,
/// tetesan ekstraksi kopi di tengah, serta server/gelas seduh berhandle di bawahnya.
class BrewDripperGlassIcon extends StatelessWidget {
  final double size;
  final Color color;

  const BrewDripperGlassIcon({
    super.key,
    this.size = 28,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrewDripperGlassPainter(color: color),
      ),
    );
  }
}

class _BrewDripperGlassPainter extends CustomPainter {
  final Color color;

  const _BrewDripperGlassPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Stroke garis utama
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Dripper Cone (V60 Kerucut Presisi Tajam)
    // Bibir atas dripper (Top Rim)
    final topRimPath = Path()
      ..moveTo(w * 0.18, h * 0.13)
      ..lineTo(w * 0.82, h * 0.13);
    canvas.drawPath(topRimPath, strokePaint);

    // Dinding kerucut V60 (Tapered 60-degree cone)
    // Meruncing tajam ke bawah menuju lubang ekstraksi
    final conePath = Path()
      ..moveTo(w * 0.22, h * 0.13)
      ..lineTo(w * 0.46, h * 0.43)
      ..lineTo(w * 0.54, h * 0.43)
      ..lineTo(w * 0.78, h * 0.13);
    canvas.drawPath(conePath, strokePaint);

    // Dudukan / Collar dripper di bawah kerucut
    final baseCollar = Path()
      ..moveTo(w * 0.32, h * 0.44)
      ..lineTo(w * 0.68, h * 0.44);
    canvas.drawPath(baseCollar, strokePaint);

    // 3 alur spiral V60 di dalam kerucut (jelas dan tajam)
    final ribPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    // Spiral kiri
    final leftRib = Path()
      ..moveTo(w * 0.34, h * 0.18)
      ..cubicTo(w * 0.38, h * 0.26, w * 0.44, h * 0.34, w * 0.47, h * 0.40);
    canvas.drawPath(leftRib, ribPaint);

    // Garis vertikal tengah
    canvas.drawLine(Offset(w * 0.50, h * 0.17), Offset(w * 0.50, h * 0.35), ribPaint);

    // Spiral kanan
    final rightRib = Path()
      ..moveTo(w * 0.66, h * 0.18)
      ..cubicTo(w * 0.62, h * 0.26, w * 0.56, h * 0.34, w * 0.53, h * 0.40);
    canvas.drawPath(rightRib, ribPaint);

    // 2. Tetesan Air / Ekstraksi Kopi (Crisp Drop)
    // Tetesan air yang menetes tepat di bawah ujung kerucut
    final dropPath = Path()
      ..moveTo(w * 0.50, h * 0.48)
      ..cubicTo(w * 0.43, h * 0.53, w * 0.43, h * 0.58, w * 0.50, h * 0.58)
      ..cubicTo(w * 0.57, h * 0.58, w * 0.57, h * 0.53, w * 0.50, h * 0.48)
      ..close();
    canvas.drawPath(dropPath, fillPaint);

    // 3. Server / Gelas Seduh (Carafe)
    // Bibir server
    final serverRim = Path()
      ..moveTo(w * 0.34, h * 0.65)
      ..lineTo(w * 0.66, h * 0.65);
    canvas.drawPath(serverRim, strokePaint);

    // Badan gelas server
    final glassPath = Path()
      ..moveTo(w * 0.36, h * 0.65)
      ..lineTo(w * 0.28, h * 0.85)
      ..cubicTo(w * 0.28, h * 0.92, w * 0.72, h * 0.92, w * 0.72, h * 0.85)
      ..lineTo(w * 0.64, h * 0.65);
    canvas.drawPath(glassPath, strokePaint);

    // Meniskus cairan kopi di dalam gelas
    final liquidPaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final liquidPath = Path()
      ..moveTo(w * 0.31, h * 0.80)
      ..lineTo(w * 0.69, h * 0.80)
      ..cubicTo(w * 0.69, h * 0.90, w * 0.31, h * 0.90, w * 0.31, h * 0.80)
      ..close();
    canvas.drawPath(liquidPath, liquidPaint);

    // Gagang gelas server
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    final handlePath = Path()
      ..moveTo(w * 0.67, h * 0.70)
      ..cubicTo(w * 0.82, h * 0.70, w * 0.82, h * 0.82, w * 0.69, h * 0.82);
    canvas.drawPath(handlePath, handlePaint);
  }

  @override
  bool shouldRepaint(covariant _BrewDripperGlassPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
