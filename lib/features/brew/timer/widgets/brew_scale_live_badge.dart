import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../services/smart_scale_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../smart_scale/widgets/scale_device_sheet.dart';

/// Live Bluetooth 5.2 Smart Scale telemetry bar displayed inside Brewing Time
/// (`BrewTimerScreen`). Shows real-time weight (0.1g), flow rate (g/s),
/// target step water progress, and 1-tap TARE when connected — or a compact
/// Bluetooth pairing button when disconnected.
class BrewScaleLiveBadge extends StatelessWidget {
  final bool isEn;
  final int? targetWaterGrams;

  const BrewScaleLiveBadge({
    super.key,
    required this.isEn,
    this.targetWaterGrams,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListenableBuilder(
        listenable: SmartScaleService.instance,
        builder: (context, _) {
          final scale = SmartScaleService.instance;

          if (!scale.isConnected) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: InkWell(
                onTap: () => ScaleDeviceSheet.show(context, scale),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderWarm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.bluetooth,
                        size: 14,
                        color: AppTheme.primaryBrown,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isEn
                              ? 'Connect Smart Scale (TIMEMORE Dot / C3)'
                              : 'Hubungkan Smart Scale (TIMEMORE Dot / C3)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.2,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 13,
                        color: AppTheme.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final weight = scale.currentWeight;
          final flow = scale.flowRate;
          final target = targetWaterGrams ?? 0;
          final progress =
              target > 0 ? (weight / target).clamp(0.0, 1.0) : null;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF0F766E).withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.gauge,
                      size: 15,
                      color: AppTheme.primaryBrown,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${weight.toStringAsFixed(1)} g',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                  color: AppTheme.textDark,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              if (target > 0)
                                Text(
                                  ' / ${target}g',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              '${flow.toStringAsFixed(1)} g/s',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => scale.tare(),
                      borderRadius: BorderRadius.circular(7),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          isEn ? 'TARE' : 'NOL-KAN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (progress != null) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4.5,
                      backgroundColor: AppTheme.bgCream,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 0.98
                            ? const Color(0xFF0F766E)
                            : AppTheme.primaryBrown,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
