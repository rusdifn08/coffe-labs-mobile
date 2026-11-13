import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/social_thread_models.dart';

class ThreadPouringCurveCard extends StatelessWidget {
  final PouringTelemetryCurveAttachment telemetry;

  const ThreadPouringCurveCard({
    super.key,
    required this.telemetry,
  });

  @override
  Widget build(BuildContext context) {
    final mins = telemetry.totalDurationSec ~/ 60;
    final secs = (telemetry.totalDurationSec % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1612),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.waveform_path_ecg,
                size: 16,
                color: Color(0xFFFDE68A),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      telemetry.recipeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${telemetry.beanName} • $mins:$secs',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '${telemetry.accuracyScorePct.toStringAsFixed(1)}% Akurasi',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6EE7B7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            width: double.infinity,
            child: CustomPaint(
              painter: _PourCurvePainter(telemetry.curvePoints),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _LegendDot(color: const Color(0xFFFDE68A), label: 'Target (ml)'),
              const SizedBox(width: 14),
              _LegendDot(color: const Color(0xFF34D399), label: 'Aktual Tuangan'),
              const Spacer(),
              Text(
                '${telemetry.curvePoints.length} titik telemetri',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}

class _PourCurvePainter extends CustomPainter {
  final List<PourCurvePoint> points;

  _PourCurvePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.length < 2) {
      final line = Paint()
        ..color = const Color(0xFF34D399)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(0, size.height * 0.85)
        ..quadraticBezierTo(
          size.width * 0.45,
          size.height * 0.4,
          size.width,
          size.height * 0.15,
        );
      canvas.drawPath(path, line);
      return;
    }

    final maxT = points
        .map((p) => p.tSec)
        .fold<int>(1, (a, b) => math.max(a, b))
        .toDouble();
    final maxW = points
        .map((p) => math.max(p.actualMl, p.targetMl))
        .fold<double>(10.0, (a, b) => math.max(a, b));

    final targetPath = Path();
    final actualPath = Path();
    final actualFill = Path();

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = (p.tSec / maxT).clamp(0.0, 1.0) * size.width;
      final yt = size.height - (p.targetMl / maxW).clamp(0.0, 1.0) * (size.height - 8) - 4;
      final ya = size.height - (p.actualMl / maxW).clamp(0.0, 1.0) * (size.height - 8) - 4;

      if (i == 0) {
        targetPath.moveTo(x, yt);
        actualPath.moveTo(x, ya);
        actualFill.moveTo(x, size.height);
        actualFill.lineTo(x, ya);
      } else {
        targetPath.lineTo(x, yt);
        actualPath.lineTo(x, ya);
        actualFill.lineTo(x, ya);
      }
      if (i == points.length - 1) {
        actualFill.lineTo(x, size.height);
        actualFill.close();
      }
    }

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF34D399).withValues(alpha: 0.35),
          const Color(0xFF34D399).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(actualFill, fillPaint);

    // Draw dashed target line
    final targetPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.7)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    for (final metric in targetPath.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final end = math.min(dist + 5, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), targetPaint);
        dist += 9;
      }
    }

    final actualPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.accentGold, Color(0xFF34D399)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(actualPath, actualPaint);
  }

  @override
  bool shouldRepaint(covariant _PourCurvePainter oldDelegate) =>
      oldDelegate.points != points;
}
