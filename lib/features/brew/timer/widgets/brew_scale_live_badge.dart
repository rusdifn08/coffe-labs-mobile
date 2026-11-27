import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../services/smart_scale_service.dart';
import '../../../../theme/app_theme.dart';

/// Live Bluetooth 5.2 Smart Scale telemetry bar displayed inside Brewing Time
/// (`BrewTimerScreen`) ONLY when a real physical BLE coffee scale is connected.
/// Shows real-time weight (0.1g), flow rate (g/s), target step water progress,
/// and 1-tap TARE. Renders nothing when disconnected because pairing is now
/// handled via the side Bluetooth icon button beside the timer.
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
            return const SizedBox.shrink();
          }

          final weight = scale.currentWeight;
          final flow = scale.flowRate;
          final target = targetWaterGrams ?? 0;
          final progress =
              target > 0 ? (weight / target).clamp(0.0, 1.0) : null;

          return Container(
            margin: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.08),
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
                      color: Color(0xFF16A34A),
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
                                color: Color(0xFF15803D),
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
                            ? const Color(0xFF16A34A)
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
