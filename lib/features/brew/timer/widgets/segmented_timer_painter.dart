import 'dart:math';
import 'package:flutter/material.dart';

Color getColorForStep(int index) {
  const List<Color> colors = [
    Colors.blueAccent,
    Colors.green,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.amber,
    Colors.redAccent,
  ];
  return colors[index % colors.length];
}

class SegmentedTimerPainter extends CustomPainter {
  final List<dynamic> steps;
  final num totalSeconds;
  final num elapsedSeconds;

  SegmentedTimerPainter({
    required this.steps,
    required this.totalSeconds,
    required this.elapsedSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 18.0;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - strokeWidth / 2,
    );

    final Paint trackPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - strokeWidth / 2, trackPaint);

    if (totalSeconds <= 0) return;

    double startAngle = -pi / 2;
    double currentElapsed = elapsedSeconds.toDouble();

    for (int i = 0; i < steps.length; i++) {
      final double stepSecs = (steps[i]['durationSeconds'] ?? steps[i]['timeSeconds'] ?? 0).toDouble();
      final double sweepAngle = (stepSecs / totalSeconds) * 2 * pi;

      final Color stepColor = getColorForStep(i);

      final Paint segmentPaint = Paint()
        ..color = stepColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = strokeWidth;

      canvas.drawArc(rect, startAngle, max(0.01, sweepAngle - 0.05), false, segmentPaint);

      if (currentElapsed > 0) {
        final double filledSecs = min(currentElapsed, stepSecs);
        final double filledSweepAngle = (filledSecs / totalSeconds) * 2 * pi;

        final Paint filledPaint = Paint()
          ..color = stepColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth + 2;

        canvas.drawArc(rect, startAngle, filledSweepAngle, false, filledPaint);
        currentElapsed -= filledSecs;
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant SegmentedTimerPainter oldDelegate) {
    return oldDelegate.elapsedSeconds != elapsedSeconds || oldDelegate.totalSeconds != totalSeconds;
  }
}
