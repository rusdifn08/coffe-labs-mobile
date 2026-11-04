import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Japanese Iced preparation guide banner shown when recipe contains ice.
class BrewIcedBanner extends StatelessWidget {
  final int iceWeightGrams;
  final int totalWaterGrams;
  final int waterTempCelsius;
  final bool isPreparing;
  final int elapsedSeconds;
  final bool isEn;

  const BrewIcedBanner({
    super.key,
    required this.iceWeightGrams,
    required this.totalWaterGrams,
    required this.waterTempCelsius,
    required this.isPreparing,
    required this.elapsedSeconds,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    if (iceWeightGrams <= 0 || (!isPreparing && elapsedSeconds > 0)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.snow, size: 16, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEn
                  ? 'Japanese Iced: Prepare ${iceWeightGrams}g Ice in Server + ${totalWaterGrams}g Hot Water ($waterTempCelsius°C)'
                  : 'Japanese Iced: Siapkan ${iceWeightGrams}g Es di Server + ${totalWaterGrams}g Air Panas ($waterTempCelsius°C)',
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
