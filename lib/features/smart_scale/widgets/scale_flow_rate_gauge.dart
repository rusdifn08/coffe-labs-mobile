import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/smart_scale_model.dart';
import '../../../theme/app_theme.dart';

/// Coffee Labs bright-theme mode-aware Flow Rate meter (g/s).
class ScaleFlowRateGauge extends StatelessWidget {
  final double flowRate;
  final ScaleBrewMode mode;
  final bool isEn;

  const ScaleFlowRateGauge({
    super.key,
    required this.flowRate,
    this.mode = ScaleBrewMode.pourOver,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final minIdeal = mode.idealFlowMin;
    final maxIdeal = mode.idealFlowMax;
    final maxScale = mode == ScaleBrewMode.espresso ? 4.5 : 10.0;

    Color badgeColor = AppTheme.textMuted;
    Color badgeBg = AppTheme.bgCream;
    String status = isEn ? 'Idle / Pause' : 'Stabil / Jeda';

    if (flowRate > 0.1 && flowRate < minIdeal) {
      badgeColor = const Color(0xFF0369A1);
      badgeBg = const Color(0xFFE0F2FE);
      status = isEn ? 'Gentle Flow' : 'Aliran Halus';
    } else if (flowRate >= minIdeal && flowRate <= maxIdeal) {
      badgeColor = const Color(0xFF0F766E);
      badgeBg = const Color(0xFFCCFBF1);
      status = mode == ScaleBrewMode.espresso
          ? (isEn ? 'Sweet Spot Shot' : 'Sweet Spot Shot')
          : (isEn ? 'Ideal Pour Rate' : 'Debit Ideal');
    } else if (flowRate > maxIdeal) {
      badgeColor = const Color(0xFFC2410C);
      badgeBg = const Color(0xFFFFEDD5);
      status = mode == ScaleBrewMode.espresso
          ? (isEn ? 'Fast Channeling' : 'Terlalu Cepat')
          : (isEn ? 'High Agitation' : 'Agitasi Tinggi');
    }

    final barFraction = (flowRate / maxScale).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.drop_fill,
                size: 15,
                color: Color(0xFF0F766E),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isEn ? 'Live Flow' : 'Debit Air',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${flowRate.toStringAsFixed(1)} g/s',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: badgeColor,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.8,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: barFraction,
              minHeight: 7,
              backgroundColor: AppTheme.bgCream,
              valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Text(
                '0 g/s',
                style: TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
              ),
              Expanded(
                child: Text(
                  '${isEn ? 'Ideal' : 'Ideal'}: ${minIdeal.toStringAsFixed(1)}–${maxIdeal.toStringAsFixed(1)} g/s',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ),
              Text(
                '${maxScale.toStringAsFixed(0)} g/s',
                style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
