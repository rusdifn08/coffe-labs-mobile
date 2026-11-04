import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../services/smart_scale_service.dart';
import '../../../../theme/app_theme.dart';

/// Live Bluetooth Smart Scale weight badge displayed during brewing.
class BrewScaleLiveBadge extends StatelessWidget {
  final bool isEn;

  const BrewScaleLiveBadge({super.key, required this.isEn});

  @override
  Widget build(BuildContext context) {
    if (!SmartScaleService.instance.isConnected) return const SizedBox.shrink();

    final scale = SmartScaleService.instance;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.gauge, size: 14, color: AppTheme.primaryBrown),
          const SizedBox(width: 6),
          Text(
            '${scale.currentWeight.toStringAsFixed(1)} g',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primaryBrown),
          ),
          const SizedBox(width: 8),
          Text(
            '(${scale.flowRate.toStringAsFixed(1)} g/s)',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => SmartScaleService.instance.tare(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isEn ? 'TARE' : 'NOL-KAN',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
