import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class BrewFlowCurveChart extends StatelessWidget {
  final List<dynamic> steps;
  final int totalWaterGrams;
  final int totalTimeSeconds;
  final double height;

  const BrewFlowCurveChart({
    super.key,
    required this.steps,
    required this.totalWaterGrams,
    required this.totalTimeSeconds,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty || totalWaterGrams <= 0 || totalTimeSeconds <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(10, 10, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.waveform_path, size: 14, color: AppTheme.primaryBrown),
              const SizedBox(width: 6),
              const Text(
                'Kurva Penuangan & Alur Ekstraksi',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const Spacer(),
              Text(
                '${totalWaterGrams}g / ${_formatSeconds(totalTimeSeconds)}',
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _FlowCurvePainter(
                steps: steps,
                totalWater: totalWaterGrams,
                totalTime: totalTimeSeconds,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Legend fase ekstraksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend('Bloom (Asam)', Colors.orange.shade700),
              _buildLegend('Mid (Kemanisan)', Colors.amber.shade800),
              _buildLegend('Drawdown (Body)', Colors.brown.shade700),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 9.5, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
      ],
    );
  }

  static String _formatSeconds(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

class _FlowCurvePainter extends CustomPainter {
  final List<dynamic> steps;
  final int totalWater;
  final int totalTime;

  _FlowCurvePainter({
    required this.steps,
    required this.totalWater,
    required this.totalTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Grid Horizontal
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.8;
    for (int i = 1; i <= 3; i++) {
      final y = h * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 2. Hitung titik koordinat (Time, Water)
    final List<Offset> points = [Offset(0, h)];
    int cumulativeWater = 0;
    int cumulativeTime = 0;

    for (final s in steps) {
      final int stepWater = (s['waterAddedGrams'] as num?)?.toInt() ?? 0;
      final int stepDur = (s['durationSeconds'] as num?)?.toInt() ?? 30;

      cumulativeWater += stepWater;
      cumulativeTime += stepDur;

      final double px = (cumulativeTime / totalTime).clamp(0.0, 1.0) * w;
      final double py = h - ((cumulativeWater / totalWater).clamp(0.0, 1.0) * h);
      points.add(Offset(px, py));
    }

    // 3. Gambar Area Gradasi di Bawah Kurva
    final fillPath = Path();
    fillPath.moveTo(0, h);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(w, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.orange.withValues(alpha: 0.25),
          AppTheme.accentGold.withValues(alpha: 0.15),
          Colors.brown.withValues(alpha: 0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 4. Gambar Garis Kurva Utama
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final linePaint = Paint()
      ..color = AppTheme.primaryBrown
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // 5. Gambar Titik Node Tiap Tahap Seduh
    final nodePaint = Paint()..color = AppTheme.primaryBrown;
    final innerPaint = Paint()..color = Colors.white;
    for (final p in points) {
      canvas.drawCircle(p, 4.0, nodePaint);
      canvas.drawCircle(p, 2.0, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlowCurvePainter oldDelegate) {
    return oldDelegate.totalWater != totalWater || oldDelegate.totalTime != totalTime;
  }
}
