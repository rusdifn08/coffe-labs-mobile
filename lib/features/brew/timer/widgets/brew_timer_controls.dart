import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';

class BrewTimerControls extends StatelessWidget {
  final int activeIndex;
  final int stepsCount;
  final bool isRunning;
  final bool isPreparing;
  final VoidCallback? onPrevStep;
  final VoidCallback? onNextStep;
  final VoidCallback onReset;
  final VoidCallback onToggle;
  final VoidCallback onAdd10Sec;

  const BrewTimerControls({
    super.key,
    required this.activeIndex,
    required this.stepsCount,
    required this.isRunning,
    required this.isPreparing,
    required this.onPrevStep,
    required this.onNextStep,
    required this.onReset,
    required this.onToggle,
    required this.onAdd10Sec,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: isEn ? 'Previous Step' : 'Tahap Sebelumnya',
            onPressed: onPrevStep,
            icon: const Icon(CupertinoIcons.backward_end_fill, color: AppTheme.primaryBrown),
          ),
          FloatingActionButton.small(
            heroTag: 'reset',
            tooltip: isEn ? 'Reset Timer' : 'Reset Timer',
            backgroundColor: AppTheme.bgCream,
            elevation: 0,
            onPressed: onReset,
            child: const Icon(CupertinoIcons.refresh, color: AppTheme.primaryBrown, size: 18),
          ),
          SizedBox(
            width: 68,
            height: 68,
            child: FloatingActionButton(
              heroTag: 'playpause',
              backgroundColor: AppTheme.primaryBrown,
              elevation: 4,
              onPressed: onToggle,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              child: Icon(
                isRunning || isPreparing ? CupertinoIcons.pause_solid : CupertinoIcons.play_arrow_solid,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          TextButton(
            onPressed: onAdd10Sec,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.bgCream,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isEn ? '+10s' : '+10d',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBrown),
            ),
          ),
          IconButton(
            tooltip: isEn ? 'Next Step' : 'Tahap Berikutnya',
            onPressed: onNextStep,
            icon: const Icon(CupertinoIcons.forward_end_fill, color: AppTheme.primaryBrown),
          ),
        ],
      ),
    );
  }
}
