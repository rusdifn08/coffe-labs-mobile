import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class BrewRadarChart extends StatelessWidget {
  final double acidity;
  final double sweetness;
  final double body;
  final double bitterness;
  final double clarity;
  final double? targetAcidity;
  final double? targetSweetness;
  final double? targetBody;
  final double? targetBitterness;
  final double? targetClarity;
  final double size;

  const BrewRadarChart({
    super.key,
    required this.acidity,
    required this.sweetness,
    required this.body,
    required this.bitterness,
    required this.clarity,
    this.targetAcidity,
    this.targetSweetness,
    this.targetBody,
    this.targetBitterness,
    this.targetClarity,
    this.size = 230,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarChartPainter(
          values: [
            acidity.clamp(1.0, 5.0),
            sweetness.clamp(1.0, 5.0),
            body.clamp(1.0, 5.0),
            bitterness.clamp(1.0, 5.0),
            clarity.clamp(1.0, 5.0),
          ],
          targetValues: (targetAcidity != null && targetSweetness != null)
              ? [
                  targetAcidity!.clamp(1.0, 5.0),
                  targetSweetness!.clamp(1.0, 5.0),
                  (targetBody ?? 3.0).clamp(1.0, 5.0),
                  (targetBitterness ?? 2.0).clamp(1.0, 5.0),
                  (targetClarity ?? 4.0).clamp(1.0, 5.0),
                ]
              : null,
          labels: const ['Asam', 'Manis', 'Body', 'Pahit', 'Clarity'],
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<double> values;
  final List<double>? targetValues;
  final List<String> labels;

  _RadarChartPainter({
    required this.values,
    this.targetValues,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.38;
    const int sides = 5;

    final gridPaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Gambar 5 Ring Konsentris Pentagon (Level 1..5)
    for (int step = 1; step <= 5; step++) {
      final r = radius * (step / 5);
      final path = Path();
      for (int i = 0; i < sides; i++) {
        final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 2. Gambar 5 Sumbu Jari-Jari (Rays) & Label
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);

      // Label teks di luar poligon
      final labelX = center.dx + (radius + 20) * math.cos(angle);
      final labelY = center.dy + (radius + 20) * math.sin(angle);
      final labelText = '${labels[i]} (${values[i].toStringAsFixed(1)})';

      textPainter.text = TextSpan(
        text: labelText,
        style: TextStyle(
          color: AppTheme.textDark,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - (textPainter.width / 2), labelY - (textPainter.height / 2)),
      );
    }

    // 3. Gambar Poligon Target (Jika ada - Garis Putus-putus Biru Kehijauan)
    if (targetValues != null && targetValues!.length == sides) {
      _drawPolygon(
        canvas,
        center,
        radius,
        targetValues!,
        fillColor: Colors.blue.withValues(alpha: 0.10),
        strokeColor: Colors.blue.shade600,
        strokeWidth: 1.5,
      );
    }

    // 4. Gambar Poligon Hasil Seduh Aktual (Amber / Coffee Palette Emas)
    _drawPolygon(
      canvas,
      center,
      radius,
      values,
      fillColor: AppTheme.accentGold.withValues(alpha: 0.35),
      strokeColor: AppTheme.primaryBrown,
      strokeWidth: 2.5,
      drawNodes: true,
    );
  }

  void _drawPolygon(
    Canvas canvas,
    Offset center,
    double radius,
    List<double> vals, {
    required Color fillColor,
    required Color strokeColor,
    required double strokeWidth,
    bool drawNodes = false,
  }) {
    const int sides = 5;
    final path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < sides; i++) {
      final v = (vals[i] / 5.0).clamp(0.2, 1.0);
      final r = radius * v;
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final p = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      points.add(p);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();

    // Isi bidang
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Garis keliling
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Titik node
    if (drawNodes) {
      final nodePaint = Paint()..color = AppTheme.primaryBrown;
      final ringPaint = Paint()..color = Colors.white;
      for (final p in points) {
        canvas.drawCircle(p, 4.0, nodePaint);
        canvas.drawCircle(p, 2.0, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.targetValues != targetValues;
  }
}
