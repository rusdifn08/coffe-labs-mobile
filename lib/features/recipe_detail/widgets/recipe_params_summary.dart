import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';

class RecipeParamsSummary extends StatelessWidget {
  final num coffeeWeight;
  final num totalWater;
  final int iceWeight;
  final String ratio;
  final int waterTemp;
  final int totalTimeSeconds;
  final String waterPpm;
  final String Function(int) formatTime;

  const RecipeParamsSummary({
    super.key,
    required this.coffeeWeight,
    required this.totalWater,
    required this.iceWeight,
    required this.ratio,
    required this.waterTemp,
    required this.totalTimeSeconds,
    required this.waterPpm,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildParamItem(
                CupertinoIcons.circle_bottomthird_split,
                isEn ? 'Coffee Dose' : 'Dose Kopi',
                '${coffeeWeight}g',
              ),
              _buildParamItem(
                CupertinoIcons.drop_fill,
                isEn
                    ? (iceWeight > 0 ? 'Water + Ice' : 'Total Water')
                    : (iceWeight > 0 ? 'Air + Es' : 'Total Air'),
                iceWeight > 0 ? '${totalWater}g + ${iceWeight}g' : '${totalWater}g',
              ),
              _buildParamItem(CupertinoIcons.divide, isEn ? 'Ratio' : 'Rasio', ratio),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildParamItem(CupertinoIcons.thermometer, isEn ? 'Water Temp' : 'Suhu Air', '$waterTemp°C'),
              _buildParamItem(CupertinoIcons.timer, isEn ? 'Total Time' : 'Total Waktu', formatTime(totalTimeSeconds)),
              _buildParamItem(CupertinoIcons.drop, isEn ? 'Water TDS' : 'Mineral Air', waterPpm),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParamItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryBrown, size: 20),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}
