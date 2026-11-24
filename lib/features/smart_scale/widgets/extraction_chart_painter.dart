import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/smart_scale_model.dart';
import '../../../theme/app_theme.dart';

/// Coffee Labs bright-theme Dual-Curve Extraction Graph:
/// 1. Weight / Yield curve (`g`) in Espresso Brown with soft warm area fill
/// 2. Flow Rate curve (`g/s`) in Lab Teal `#0F766E`
/// 3. Optional Recipe Target Ghost Curve (`g`) in dashed Amber `#D97706`
class ExtractionChartPainter extends CustomPainter {
  final List<WeightDataPoint> dataPoints;
  final List<WeightDataPoint> targetCurve;
  final double? targetMaxWeight;
  final double? targetMaxSeconds;
  final double maxFlowScale;

  const ExtractionChartPainter({
    required this.dataPoints,
    this.targetCurve = const [],
    this.targetMaxWeight,
    this.targetMaxSeconds,
    this.maxFlowScale = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 34.0;
    const double rightPad = 28.0;
    const double topPad = 10.0;
    const double bottomPad = 20.0;

    final chartWidth = math.max(10.0, size.width - leftPad - rightPad);
    final chartHeight = math.max(10.0, size.height - topPad - bottomPad);
    final chartRect = Rect.fromLTWH(leftPad, topPad, chartWidth, chartHeight);

    // Determine Y-weight max and X-time max
    double maxWeight = targetMaxWeight ?? 60.0;
    double maxTime = targetMaxSeconds ?? 30.0;

    for (final p in targetCurve) {
      if (p.weight > maxWeight) maxWeight = p.weight;
      if (p.elapsedSeconds > maxTime) maxTime = p.elapsedSeconds;
    }
    for (final p in dataPoints) {
      if (p.weight > maxWeight) maxWeight = p.weight;
      if (p.elapsedSeconds > maxTime) maxTime = p.elapsedSeconds;
    }
    maxWeight = math.max(40.0, (maxWeight * 1.12).ceilToDouble());
    maxTime = math.max(30.0, maxTime);

    double maxFlow = maxFlowScale;
    for (final p in dataPoints) {
      if (p.flowRate > maxFlow) maxFlow = (p.flowRate + 1.0).ceilToDouble();
    }

    // 1. Soft horizontal gridlines + axis labels
    final gridPaint = Paint()
      ..color = AppTheme.borderWarm
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final frac = i / 4.0;
      final y = chartRect.bottom - (frac * chartHeight);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );

      // Left axis: Weight (g)
      if (i % 2 == 0) {
        final weightLabel = '${(maxWeight * frac).round()}g';
        _drawLabel(
          canvas,
          weightLabel,
          Offset(0, y - 6),
          const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
          ),
          maxWidth: leftPad - 4,
          align: TextAlign.right,
        );

        // Right axis: Flow (g/s)
        final flowLabel = '${(maxFlow * frac).toStringAsFixed(0)}/s';
        _drawLabel(
          canvas,
          flowLabel,
          Offset(chartRect.right + 4, y - 6),
          const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F766E),
          ),
          maxWidth: rightPad - 2,
          align: TextAlign.left,
        );
      }
    }

    // Bottom time markers (00:00, mid, end)
    for (int i = 0; i <= 2; i++) {
      final sec = ((maxTime * i) / 2.0).round();
      final x = chartRect.left + ((i / 2.0) * chartWidth);
      final label = _formatTime(sec);
      final align = i == 0
          ? TextAlign.left
          : (i == 2 ? TextAlign.right : TextAlign.center);
      final dx = i == 0 ? x : (i == 2 ? x - 34 : x - 17);
      _drawLabel(
        canvas,
        label,
        Offset(dx, chartRect.bottom + 4),
        const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppTheme.textMuted,
        ),
        maxWidth: 34,
        align: align,
      );
    }

    // 2. Target Recipe Ghost Curve (Dashed Amber)
    if (targetCurve.length >= 2) {
      final ghostPaint = Paint()
        ..color = const Color(0xFFD97706).withValues(alpha: 0.65)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final ghostPoints = targetCurve.map((p) {
        final x = chartRect.left +
            ((p.elapsedSeconds / maxTime).clamp(0.0, 1.0) * chartWidth);
        final y = chartRect.bottom -
            ((p.weight / maxWeight).clamp(0.0, 1.0) * chartHeight);
        return Offset(x, y);
      }).toList();

      _drawDashedPolyline(canvas, ghostPoints, ghostPaint, dash: 5, gap: 4);
    }

    if (dataPoints.isEmpty) return;

    // 3. Build Weight & Flow Paths
    final weightPath = Path();
    final weightAreaPath = Path();
    final flowPath = Path();

    Offset? lastWeightPt;
    Offset? lastFlowPt;

    for (int i = 0; i < dataPoints.length; i++) {
      final p = dataPoints[i];
      final x = chartRect.left +
          ((p.elapsedSeconds / maxTime).clamp(0.0, 1.0) * chartWidth);
      final yWeight = chartRect.bottom -
          ((p.weight / maxWeight).clamp(0.0, 1.0) * chartHeight);
      final yFlow = chartRect.bottom -
          ((p.flowRate / maxFlow).clamp(0.0, 1.0) * chartHeight);

      if (i == 0) {
        weightPath.moveTo(x, yWeight);
        weightAreaPath.moveTo(x, chartRect.bottom);
        weightAreaPath.lineTo(x, yWeight);
        flowPath.moveTo(x, yFlow);
      } else {
        weightPath.lineTo(x, yWeight);
        weightAreaPath.lineTo(x, yWeight);
        flowPath.lineTo(x, yFlow);
      }
      lastWeightPt = Offset(x, yWeight);
      lastFlowPt = Offset(x, yFlow);
    }

    if (lastWeightPt != null) {
      weightAreaPath.lineTo(lastWeightPt.dx, chartRect.bottom);
      weightAreaPath.close();

      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryBrown.withValues(alpha: 0.22),
            AppTheme.primaryBrown.withValues(alpha: 0.02),
          ],
        ).createShader(chartRect);
      canvas.drawPath(weightAreaPath, areaPaint);
    }

    final weightPaint = Paint()
      ..color = AppTheme.primaryBrown
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final flowPaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeWidth = 1.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(weightPath, weightPaint);
    canvas.drawPath(flowPath, flowPaint);

    // 4. Terminal live indicator dots
    if (lastWeightPt != null) {
      canvas.drawCircle(
        lastWeightPt,
        4.0,
        Paint()..color = AppTheme.primaryBrown,
      );
      canvas.drawCircle(
        lastWeightPt,
        2.0,
        Paint()..color = Colors.white,
      );
    }
    if (lastFlowPt != null) {
      canvas.drawCircle(
        lastFlowPt,
        3.2,
        Paint()..color = const Color(0xFF0F766E),
      );
    }
  }

  void _drawDashedPolyline(
    Canvas canvas,
    List<Offset> points,
    Paint paint, {
    double dash = 5,
    double gap = 4,
  }) {
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final delta = p2 - p1;
      final dist = delta.distance;
      if (dist <= 0.1) continue;
      final dir = delta / dist;
      double current = 0;
      while (current < dist) {
        final next = math.min(current + dash, dist);
        canvas.drawLine(p1 + dir * current, p1 + dir * next, paint);
        current = next + gap;
      }
    }
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    required double maxWidth,
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: maxWidth, maxWidth: maxWidth);
    tp.paint(canvas, offset);
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  bool shouldRepaint(covariant ExtractionChartPainter oldDelegate) {
    return true;
  }
}
