import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/live_brew_mirror_models.dart';
import '../../domain/services/ntp_synced_timer_engine.dart';

class MirroredCircularTimerCard extends StatelessWidget {
  final LiveSessionMirrorSnapshot snapshot;
  final NtpSyncedTimerEngine timerEngine;
  final Color accentColor;
  final int clockOffsetMs;

  const MirroredCircularTimerCard({
    super.key,
    required this.snapshot,
    required this.timerEngine,
    this.accentColor = const Color(0xFFD4A373),
    this.clockOffsetMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final targetMs = math.max(1000, snapshot.targetDurationSeconds * 1000);
    final isRunning = snapshot.timerStatus == LiveTimerStatus.running;
    final isPaused = snapshot.timerStatus == LiveTimerStatus.paused;
    final isDone = snapshot.timerStatus == LiveTimerStatus.finished;

    final badgeColor = isDone
        ? const Color(0xFF16A34A)
        : (isRunning
            ? const Color(0xFFDC2626)
            : (isPaused ? const Color(0xFFD97706) : accentColor));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.55)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          snapshot.phaseLabelId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF9F5EE),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'v${snapshot.stateVersion} • NTP ${clockOffsetMs >= 0 ? '+$clockOffsetMs' : '$clockOffsetMs'}ms',
                style: TextStyle(
                  color: const Color(0xFFF9F5EE).withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Isolated 60fps RepaintBoundary driven ONLY by elapsedMsNotifier
          RepaintBoundary(
            child: ValueListenableBuilder<int>(
              valueListenable: timerEngine.elapsedMsNotifier,
              builder: (_, elapsedMs, _) {
                final progress = (elapsedMs / targetMs).clamp(0.0, 1.0);
                return SizedBox(
                  width: 176,
                  height: 176,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(176, 176),
                        painter: _CircularBrewArcPainter(
                          progress: progress,
                          trackColor: Colors.white.withValues(alpha: 0.1),
                          progressColor: isDone ? const Color(0xFF22C55E) : accentColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    NtpSyncedTimerEngine.formatMmSs(elapsedMs),
                                    style: const TextStyle(
                                      color: Color(0xFFF9F5EE),
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  Text(
                                    NtpSyncedTimerEngine.formatTenths(elapsedMs),
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Target ${NtpSyncedTimerEngine.formatMmSs(targetMs)}',
                                style: TextStyle(
                                  color: const Color(0xFFF9F5EE).withValues(alpha: 0.65),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: CupertinoIcons.drop_fill,
                  label: 'Berat Air',
                  value: '${snapshot.currentWeightG.toStringAsFixed(1)} g',
                  accent: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  icon: CupertinoIcons.speedometer,
                  label: 'Laju Tuang',
                  value: '${snapshot.currentFlowRateMlS.toStringAsFixed(1)} ml/s',
                  accent: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  icon: CupertinoIcons.thermometer,
                  label: 'Suhu',
                  value: '${snapshot.currentTempC.toStringAsFixed(0)}°C',
                  accent: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF9F5EE),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFFF9F5EE).withValues(alpha: 0.58),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularBrewArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const _CircularBrewArcPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularBrewArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.progressColor != progressColor;
}
