import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Grafik Radar / Spider Sensorik (120 FPS CustomPainter) untuk memvisualisasikan
/// keseimbangan rasa Asam, Manis, Pahit, Body, Clarity (atau metrik SCA Cupping).
class BrewJournalSensoryRadarChart extends StatelessWidget {
  final Map<String, double> metrics;
  final double maxScale;
  final double size;

  const BrewJournalSensoryRadarChart({
    super.key,
    required this.metrics,
    this.maxScale = 5.0,
    this.size = 215,
  });

  @override
  Widget build(BuildContext context) {
    if (metrics.length < 3) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SensoryRadarPainter(
          entries: metrics.entries.toList(growable: false),
          maxScale: maxScale <= 0 ? 5.0 : maxScale,
        ),
      ),
    );
  }
}

class _SensoryRadarPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double maxScale;

  _SensoryRadarPainter({
    required this.entries,
    required this.maxScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 34;
    if (radius <= 12) return;

    final n = entries.length;
    final angleStep = (2 * math.pi) / n;

    final gridPaint = Paint()
      ..color = AppTheme.primaryBrown.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = AppTheme.primaryBrown.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    // 1. Cincin poligon konsentris (4 level)
    for (int level = 1; level <= 4; level++) {
      final r = radius * (level / 4);
      final ringPath = Path();
      for (int i = 0; i < n; i++) {
        final angle = -math.pi / 2 + i * angleStep;
        final pt = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          ringPath.moveTo(pt.dx, pt.dy);
        } else {
          ringPath.lineTo(pt.dx, pt.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    // 2. Garis sumbu & label titik
    final dataPoints = <Offset>[];
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * angleStep;
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, outer, axisPaint);

      final norm = (entries[i].value / maxScale).clamp(0.0, 1.0);
      dataPoints.add(
        Offset(
          center.dx + (radius * norm) * math.cos(angle),
          center.dy + (radius * norm) * math.sin(angle),
        ),
      );

      final labelOffset = Offset(
        center.dx + (radius + 20) * math.cos(angle),
        center.dy + (radius + 20) * math.sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${entries[i].key}\n',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
                height: 1.15,
              ),
            ),
            TextSpan(
              text: entries[i].value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBrown,
                height: 1.15,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          labelOffset.dx - tp.width / 2,
          labelOffset.dy - tp.height / 2,
        ),
      );
    }

    // 3. Poligon nilai sensorik
    final dataPath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      if (i == 0) {
        dataPath.moveTo(dataPoints[i].dx, dataPoints[i].dy);
      } else {
        dataPath.lineTo(dataPoints[i].dx, dataPoints[i].dy);
      }
    }
    dataPath.close();

    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.accentGold.withValues(alpha: 0.45),
          AppTheme.primaryBrown.withValues(alpha: 0.28),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppTheme.primaryBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    final dotFill = Paint()..color = AppTheme.primaryBrown;
    final dotBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    for (final pt in dataPoints) {
      canvas.drawCircle(pt, 4.2, dotFill);
      canvas.drawCircle(pt, 4.2, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _SensoryRadarPainter oldDelegate) {
    return oldDelegate.entries != entries || oldDelegate.maxScale != maxScale;
  }
}

/// Grafik Batang Horizontal metrik sensorik dengan warna khas tiap dimensi rasa.
class BrewJournalSensoryBarChart extends StatelessWidget {
  final Map<String, double> metrics;
  final double maxScale;

  const BrewJournalSensoryBarChart({
    super.key,
    required this.metrics,
    this.maxScale = 5.0,
  });

  Color _colorForMetric(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('asam') || lower.contains('acid')) return const Color(0xFFE65100);
    if (lower.contains('manis') || lower.contains('sweet')) return const Color(0xFFD97706);
    if (lower.contains('pahit') || lower.contains('bitter')) return const Color(0xFF5D4037);
    if (lower.contains('body') || lower.contains('mouth')) return const Color(0xFF8D4E2A);
    if (lower.contains('clarity')) return const Color(0xFF0F766E);
    if (lower.contains('aroma')) return const Color(0xFF7C3AED);
    return AppTheme.primaryBrown;
  }

  @override
  Widget build(BuildContext context) {
    final denom = maxScale <= 0 ? 5.0 : maxScale;
    return Column(
      children: metrics.entries.map((e) {
        final ratio = (e.value / denom).clamp(0.0, 1.0);
        final color = _colorForMetric(e.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.key,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    '${e.value.toStringAsFixed(1)} / ${denom.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.13),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Grafik Tren Rating ringkas pada bagian atas Jurnal Seduh (menampilkan hingga 10 seduhan terakhir).
class BrewJournalRatingTrendCard extends StatelessWidget {
  final List<double> recentRatings;
  final double averageRating;
  final int totalEntries;
  final int totalFollowUps;

  const BrewJournalRatingTrendCard({
    super.key,
    required this.recentRatings,
    required this.averageRating,
    required this.totalEntries,
    required this.totalFollowUps,
  });

  @override
  Widget build(BuildContext context) {
    final ordered = recentRatings.take(10).toList().reversed.toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tren Kualitas Seduhan',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalEntries jurnal • $totalFollowUps catatan tambahan',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 15, color: AppTheme.accentAmber),
                    const SizedBox(width: 3),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (ordered.length >= 2) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: CustomPaint(
                painter: _RatingTrendPainter(ratings: ordered),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RatingTrendPainter extends CustomPainter {
  final List<double> ratings;

  _RatingTrendPainter({required this.ratings});

  @override
  void paint(Canvas canvas, Size size) {
    if (ratings.length < 2) return;
    final stepX = size.width / (ratings.length - 1);
    final points = <Offset>[];
    for (int i = 0; i < ratings.length; i++) {
      final norm = ((ratings[i] - 1.0) / 4.0).clamp(0.0, 1.0);
      final y = size.height - 8 - (norm * (size.height - 16));
      points.add(Offset(i * stepX, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
      fillPath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.accentAmber.withValues(alpha: 0.30),
          AppTheme.accentAmber.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final strokePaint = Paint()
      ..color = AppTheme.primaryBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, strokePaint);

    final dotPaint = Paint()..color = AppTheme.accentAmber;
    final dotStroke = Paint()
      ..color = AppTheme.primaryBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final pt in points) {
      canvas.drawCircle(pt, 3.6, dotPaint);
      canvas.drawCircle(pt, 3.6, dotStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _RatingTrendPainter oldDelegate) =>
      oldDelegate.ratings != ratings;
}
