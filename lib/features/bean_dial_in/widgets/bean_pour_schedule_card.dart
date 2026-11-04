import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../theme/app_theme.dart';
import '../../brew/widgets/brew_flow_curve_chart.dart';

class BeanPourScheduleCard extends StatelessWidget {
  final RecommendedBrewRecipe recipe;

  const BeanPourScheduleCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.waveform_path_ecg, size: 16, color: AppTheme.primaryBrown),
              const SizedBox(width: 8),
              const Text(
                'Jadwal Penuangan (Pour Schedule)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
              ),
              const Spacer(),
              Text(
                '${recipe.steps.length} Tahap',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BrewFlowCurveChart(
            steps: recipe.steps,
            totalWaterGrams: recipe.totalWater.round(),
            totalTimeSeconds: recipe.totalTimeSeconds,
            height: 140,
          ),
          const SizedBox(height: 12),
          ...recipe.steps.map((st) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${st["stepOrder"]}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          st['title'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        Text(
                          '${st["durationSeconds"]} detik • +${st["waterAddedGrams"]}g air',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
