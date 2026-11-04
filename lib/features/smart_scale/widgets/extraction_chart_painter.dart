import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/smart_scale_model.dart';
import '../../../theme/app_theme.dart';

class ExtractionChartPainter extends CustomPainter {
  final List<WeightDataPoint> dataPoints;

  const ExtractionChartPainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double maxWeight = math.max(50.0, dataPoints.map((d) => d.weight).reduce(math.max));
    const double maxFlow = 8.0;

    final weightPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final flowPaint = Paint()
      ..color = AppTheme.accentGold
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path weightPath = Path();
    final Path flowPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length > 1 ? dataPoints.length - 1 : 1)) * size.width;
      final yWeight = size.height - ((dataPoints[i].weight / maxWeight) * size.height).clamp(0.0, size.height);
      final yFlow = size.height - ((dataPoints[i].flowRate / maxFlow) * size.height).clamp(0.0, size.height);

      if (i == 0) {
        weightPath.moveTo(x, yWeight);
        flowPath.moveTo(x, yFlow);
      } else {
        weightPath.lineTo(x, yWeight);
        flowPath.lineTo(x, yFlow);
      }
    }

    canvas.drawPath(weightPath, weightPaint);
    canvas.drawPath(flowPath, flowPaint);
  }

  @override
  bool shouldRepaint(covariant ExtractionChartPainter oldDelegate) {
    return true;
  }
}
