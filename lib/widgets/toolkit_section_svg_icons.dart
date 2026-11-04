import 'package:flutter/material.dart';

/// Professional SVG-grade vector icon for the Ecosystem & Community section
class EcosystemSectionIcon extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const EcosystemSectionIcon({
    super.key,
    this.size = 20,
    this.primaryColor = const Color(0xFF6D4C41),
    this.secondaryColor = const Color(0xFFD7A86E),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EcosystemPainter(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
      ),
    );
  }
}

class _EcosystemPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _EcosystemPainter({required this.primaryColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final linePaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final hubFill = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final nodeFill = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final center = Offset(w * 0.5, h * 0.52);
    final topNode = Offset(w * 0.5, h * 0.18);
    final leftNode = Offset(w * 0.18, h * 0.72);
    final rightNode = Offset(w * 0.82, h * 0.72);

    // Connecting network lines
    canvas.drawLine(center, topNode, linePaint);
    canvas.drawLine(center, leftNode, linePaint);
    canvas.drawLine(center, rightNode, linePaint);

    // Outer subtle orbit ring
    final orbitPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, w * 0.38, orbitPaint);

    // Center Coffee Hub (Stylized coffee bean with crease)
    canvas.drawCircle(center, w * 0.18, hubFill);
    final creasePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final crease = Path();
    crease.moveTo(center.dx - w * 0.08, center.dy - h * 0.06);
    crease.cubicTo(
      center.dx + w * 0.02,
      center.dy - h * 0.02,
      center.dx - w * 0.02,
      center.dy + h * 0.02,
      center.dx + w * 0.08,
      center.dy + h * 0.06,
    );
    canvas.drawPath(crease, creasePaint);

    // Peripheral nodes
    canvas.drawCircle(topNode, w * 0.10, nodeFill);
    canvas.drawCircle(leftNode, w * 0.09, nodeFill);
    canvas.drawCircle(rightNode, w * 0.09, nodeFill);

    // Inner node highlights
    final whiteDot = Paint()..color = Colors.white;
    canvas.drawCircle(topNode, w * 0.04, whiteDot);
    canvas.drawCircle(leftNode, w * 0.035, whiteDot);
    canvas.drawCircle(rightNode, w * 0.035, whiteDot);
  }

  @override
  bool shouldRepaint(covariant _EcosystemPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor || oldDelegate.secondaryColor != secondaryColor;
}

/// Professional SVG-grade vector icon for the Extraction & Dial-In Lab section
class LabSectionIcon extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const LabSectionIcon({
    super.key,
    this.size = 20,
    this.primaryColor = const Color(0xFFC2185B),
    this.secondaryColor = const Color(0xFFFF80AB),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LabPainter(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
      ),
    );
  }
}

class _LabPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _LabPainter({required this.primaryColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final trackPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final thumbFill = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final thumbBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final gaugeRing = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    // 1. Top slider track & thumb (Dial-In Grinder click)
    final topTrackY = h * 0.28;
    canvas.drawLine(Offset(w * 0.12, topTrackY), Offset(w * 0.88, topTrackY), trackPaint);
    final topThumbPos = Offset(w * 0.65, topTrackY);
    canvas.drawCircle(topThumbPos, w * 0.11, thumbFill);
    canvas.drawCircle(topThumbPos, w * 0.11, thumbBorder);

    // 2. Bottom slider track & thumb (Extraction ratio)
    final bottomTrackY = h * 0.72;
    canvas.drawLine(Offset(w * 0.12, bottomTrackY), Offset(w * 0.88, bottomTrackY), trackPaint);
    final bottomThumbPos = Offset(w * 0.35, bottomTrackY);
    canvas.drawCircle(bottomThumbPos, w * 0.11, thumbFill);
    canvas.drawCircle(bottomThumbPos, w * 0.11, thumbBorder);

    // 3. Center precision dial indicator (Pressure / TDS target)
    final center = Offset(w * 0.5, h * 0.5);
    canvas.drawCircle(center, w * 0.18, gaugeRing);
    final needlePaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    // Angled needle pointing ~45 degrees
    final needleEnd = Offset(center.dx + w * 0.11, center.dy - h * 0.11);
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, w * 0.04, thumbFill);
  }

  @override
  bool shouldRepaint(covariant _LabPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor || oldDelegate.secondaryColor != secondaryColor;
}

/// Professional SVG-grade vector icon for the Coffee Science & Freshness section
class ScienceSectionIcon extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const ScienceSectionIcon({
    super.key,
    this.size = 20,
    this.primaryColor = const Color(0xFF00838F),
    this.secondaryColor = const Color(0xFF80DEEA),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SciencePainter(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
      ),
    );
  }
}

class _SciencePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _SciencePainter({required this.primaryColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Erlenmeyer Flask Outline
    final flaskPath = Path();
    // Spout lip
    flaskPath.moveTo(w * 0.40, h * 0.18);
    flaskPath.lineTo(w * 0.60, h * 0.18);
    // Neck down
    flaskPath.lineTo(w * 0.60, h * 0.38);
    // Body slope right
    flaskPath.lineTo(w * 0.88, h * 0.82);
    // Bottom curve
    flaskPath.quadraticBezierTo(w * 0.88, h * 0.88, w * 0.80, h * 0.88);
    // Bottom line
    flaskPath.lineTo(w * 0.20, h * 0.88);
    // Bottom left curve
    flaskPath.quadraticBezierTo(w * 0.12, h * 0.88, w * 0.12, h * 0.82);
    // Body slope left
    flaskPath.lineTo(w * 0.40, h * 0.38);
    flaskPath.close();

    final flaskOutlinePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    // Liquid in flask
    final liquidPath = Path();
    liquidPath.moveTo(w * 0.25, h * 0.62);
    // Meniscus curve
    liquidPath.quadraticBezierTo(w * 0.50, h * 0.65, w * 0.75, h * 0.62);
    liquidPath.lineTo(w * 0.85, h * 0.82);
    liquidPath.quadraticBezierTo(w * 0.85, h * 0.87, w * 0.80, h * 0.87);
    liquidPath.lineTo(w * 0.20, h * 0.87);
    liquidPath.quadraticBezierTo(w * 0.15, h * 0.87, w * 0.15, h * 0.82);
    liquidPath.close();

    final liquidPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawPath(liquidPath, liquidPaint);
    canvas.drawPath(flaskPath, flaskOutlinePaint);

    // Graduation ticks on side
    final tickPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w * 0.36, h * 0.68), Offset(w * 0.44, h * 0.68), tickPaint);
    canvas.drawLine(Offset(w * 0.39, h * 0.56), Offset(w * 0.46, h * 0.56), tickPaint);

    // Rising vapor / degassing wave above flask
    final vaporPaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final vaporPath = Path();
    vaporPath.moveTo(w * 0.48, h * 0.14);
    vaporPath.cubicTo(w * 0.44, h * 0.09, w * 0.52, h * 0.05, w * 0.48, 0);
    canvas.drawPath(vaporPath, vaporPaint);

    final vaporPath2 = Path();
    vaporPath2.moveTo(w * 0.56, h * 0.13);
    vaporPath2.cubicTo(w * 0.60, h * 0.08, w * 0.54, h * 0.04, w * 0.58, 0);
    canvas.drawPath(vaporPath2, vaporPaint);
  }

  @override
  bool shouldRepaint(covariant _SciencePainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor || oldDelegate.secondaryColor != secondaryColor;
}
