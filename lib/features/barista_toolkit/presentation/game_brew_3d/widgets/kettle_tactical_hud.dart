import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../theme/app_theme.dart';
import '../engine/gyro_kettle_physics_engine.dart';
import '../engine/v60_3d_scene_renderer.dart';

/// Gyroscope Kettle Pitch Arc Gauge + Flow Speedometer ml/s + Liquid Metrics.
class KettleTiltArcGauge extends StatelessWidget {
  final V603DSimulationSnapshot snapshot;

  const KettleTiltArcGauge({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final Color regimeColor;
    final String regimeText;
    if (snapshot.isBypassWarning) {
      regimeColor = const Color(0xFFEF4444);
      regimeText = 'BYPASS';
    } else if (snapshot.flowRegime == KettleFlowRegime.turbulent) {
      regimeColor = const Color(0xFFF97316);
      regimeText = 'TURBULEN';
    } else if (snapshot.flowRegime == KettleFlowRegime.laminar) {
      regimeColor = const Color(0xFF22C55E);
      regimeText = 'LAMINAR';
    } else {
      regimeColor = Colors.white54;
      regimeText = 'SIAGA';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F140E).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: regimeColor.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 38,
            child: CustomPaint(
              painter: _TiltArcPainter(
                pitchDeg: snapshot.pitchDeg,
                critDeg: snapshot.critSpoutAngleDeg,
                accentColor: regimeColor,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  '${snapshot.pitchDeg.toStringAsFixed(0)}°',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: regimeColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${snapshot.flowRateMlS.toStringAsFixed(1)} ml/s',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: regimeColor.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        regimeText,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: regimeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Ambang: ${snapshot.critSpoutAngleDeg.toStringAsFixed(0)}° • Ketel ${snapshot.remainingKettleMl.toInt()}ml',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9.5, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TiltArcPainter extends CustomPainter {
  final double pitchDeg;
  final double critDeg;
  final Color accentColor;

  const _TiltArcPainter({
    required this.pitchDeg,
    required this.critDeg,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 6);
    final radius = math.min(size.width / 2 - 4, size.height - 8);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Latar belakang busur 0..60 derajat
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Zona hijau Laminar Sweet Spot (sekitar critDeg+4 .. 38°)
    final sweetStart = math.pi + ((critDeg + 3) / 60.0).clamp(0.0, 1.0) * math.pi;
    final sweetSweep = (22.0 / 60.0) * math.pi;
    canvas.drawArc(
      rect,
      sweetStart,
      sweetSweep,
      false,
      Paint()
        ..color = const Color(0xFF22C55E).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // Jarum posisi sudut kemiringan saat ini
    final ratio = (pitchDeg / 60.0).clamp(0.0, 1.0);
    final angle = math.pi + ratio * math.pi;
    final tip = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = accentColor
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(tip, 3.2, Paint()..color = accentColor);

    // Penanda kritis theta_crit(V_k)
    final critAngle = math.pi + (critDeg / 60.0).clamp(0.0, 1.0) * math.pi;
    final critTip = center + Offset(math.cos(critAngle), math.sin(critAngle)) * (radius + 3);
    canvas.drawCircle(critTip, 2.2, Paint()..color = AppTheme.accentGold);
  }

  @override
  bool shouldRepaint(covariant _TiltArcPainter oldDelegate) =>
      oldDelegate.pitchDeg != pitchDeg ||
      oldDelegate.critDeg != critDeg ||
      oldDelegate.accentColor != accentColor;
}
