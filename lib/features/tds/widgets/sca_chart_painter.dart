import 'package:flutter/material.dart';

/// Painter untuk grafik 2D SCA Brewing Control Chart
class ScaChartPainter extends CustomPainter {
  final double ey;
  final double tds;

  const ScaChartPainter({required this.ey, required this.tds});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background chart
    final bgPaint = Paint()..color = const Color(0xFFF9F6F2);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(10)), bgPaint);

    // Ey range: 14% to 26%
    // Tds range: 0.8% to 1.8%
    double toX(double valEy) => ((valEy - 14.0) / 12.0).clamp(0.0, 1.0) * w;
    double toY(double valTds) => h - (((valTds - 0.80) / 1.00).clamp(0.0, 1.0) * h);

    // Golden Cup Target Box (18% - 22% EY, 1.15% - 1.45% TDS)
    final goldenRect = Rect.fromLTRB(toX(18.0), toY(1.45), toX(22.0), toY(1.15));
    final goldenPaint = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawRect(goldenRect, goldenPaint);
    final goldenStroke = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRect(goldenRect, goldenStroke);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    canvas.drawLine(Offset(toX(18.0), 0), Offset(toX(18.0), h), gridPaint);
    canvas.drawLine(Offset(toX(22.0), 0), Offset(toX(22.0), h), gridPaint);
    canvas.drawLine(Offset(0, toY(1.15)), Offset(w, toY(1.15)), gridPaint);
    canvas.drawLine(Offset(0, toY(1.45)), Offset(w, toY(1.45)), gridPaint);

    // Current Brew Dot with glowing ring
    final curX = toX(ey);
    final curY = toY(tds);

    final glowPaint = Paint()
      ..color = const Color(0xFFE65100).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(curX, curY), 12, glowPaint);

    final dotPaint = Paint()
      ..color = const Color(0xFFE65100)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(curX, curY), 5.5, dotPaint);

    final dotRing = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(Offset(curX, curY), 5.5, dotRing);
  }

  @override
  bool shouldRepaint(covariant ScaChartPainter oldDelegate) {
    return oldDelegate.ey != ey || oldDelegate.tds != tds;
  }
}
