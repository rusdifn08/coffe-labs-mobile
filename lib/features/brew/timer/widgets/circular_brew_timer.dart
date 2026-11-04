import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../utils/brew_method_helper.dart';
import 'segmented_timer_painter.dart';

class CircularBrewTimer extends StatelessWidget {
  final List<dynamic> steps;
  final int totalSeconds;
  final int elapsedSeconds;
  final bool isPreparing;
  final int prepSeconds;
  final int activeTargetWater;
  final bool isEndingSoon;
  final VoidCallback onSkipCountdown;
  final String Function(int) formatTime;
  final BrewMethodFamily methodFamily;

  const CircularBrewTimer({
    super.key,
    required this.steps,
    required this.totalSeconds,
    required this.elapsedSeconds,
    required this.isPreparing,
    required this.prepSeconds,
    required this.activeTargetWater,
    required this.isEndingSoon,
    required this.onSkipCountdown,
    required this.formatTime,
    this.methodFamily = BrewMethodFamily.pourOver,
  });

  String _formatTargetSubtitle(bool isEn) {
    final timeStr = formatTime(totalSeconds);
    switch (methodFamily) {
      case BrewMethodFamily.mokaPot:
        return 'Target $timeStr · Stovetop Heat 🔥';
      case BrewMethodFamily.espresso:
        return 'Target $timeStr · Yield ~${activeTargetWater}g ⚡';
      case BrewMethodFamily.syphon:
        return 'Target $timeStr · Vacuum Infusion 🌪️';
      case BrewMethodFamily.coldBrew:
        return 'Target $timeStr · Cold Extraction ❄️';
      case BrewMethodFamily.turkish:
        return 'Target $timeStr · Cezve Ibrik Crema ✨';
      case BrewMethodFamily.vietnamesePhin:
        return 'Target $timeStr · Phin Gravity Drip ⏳';
      default:
        return 'Target $timeStr · ${activeTargetWater}g Air';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Center(
      child: SizedBox(
        width: 245,
        height: 245,
        child: CustomPaint(
          painter: SegmentedTimerPainter(
            steps: steps,
            totalSeconds: totalSeconds,
            elapsedSeconds: elapsedSeconds,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isPreparing) ...[
                  Text(
                    isEn ? 'GET READY' : 'SIAP SEDUH',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$prepSeconds',
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentAmber,
                    ),
                  ),
                  TextButton(
                    onPressed: onSkipCountdown,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    ),
                    child: Text(
                      isEn ? 'Skip Countdown →' : 'Lewati Hitung Mundur →',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                    ),
                  ),
                ] else if (elapsedSeconds > 0 && elapsedSeconds >= totalSeconds) ...[
                  const Text(
                    'Enjoy your',
                    style: TextStyle(color: AppTheme.primaryBrown, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'coffee!',
                    style: TextStyle(color: AppTheme.primaryBrown, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ] else ...[
                  Text(
                    formatTime(elapsedSeconds),
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                      color: isEndingSoon ? Colors.red : AppTheme.primaryBrown,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    _formatTargetSubtitle(isEn),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
