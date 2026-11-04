import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CuppingHeroScoreCard extends StatelessWidget {
  final bool hasEvaluated;
  final double totalCuppingScore;
  final Color cuppingGradeColor;
  final String cuppingGradeLabel;
  final double aromaScore;
  final double acidityScore;
  final double sweetnessScore;
  final double mouthfeelScore;
  final double aftertasteScore;
  final VoidCallback onStartEvaluate;
  final VoidCallback onLoadDemo;
  final VoidCallback onReset;

  const CuppingHeroScoreCard({
    super.key,
    required this.hasEvaluated,
    required this.totalCuppingScore,
    required this.cuppingGradeColor,
    required this.cuppingGradeLabel,
    required this.aromaScore,
    required this.acidityScore,
    required this.sweetnessScore,
    required this.mouthfeelScore,
    required this.aftertasteScore,
    required this.onStartEvaluate,
    required this.onLoadDemo,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL CUPPING SCORE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        hasEvaluated ? totalCuppingScore.toStringAsFixed(2) : '--',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: cuppingGradeColor,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '/ 100',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: cuppingGradeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cuppingGradeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  cuppingGradeLabel.split('(').first.trim(),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: cuppingGradeColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Mini Metrics Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('Aroma', hasEvaluated ? aromaScore : null),
              _buildMiniMetric('Acidity', hasEvaluated ? acidityScore : null),
              _buildMiniMetric('Sweet', hasEvaluated ? sweetnessScore : null),
              _buildMiniMetric('Mouthfeel', hasEvaluated ? mouthfeelScore : null),
              _buildMiniMetric('Aftertaste', hasEvaluated ? aftertasteScore : null),
            ],
          ),
          if (!hasEvaluated) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onStartEvaluate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBrown,
                      side: const BorderSide(color: AppTheme.primaryBrown, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(CupertinoIcons.play_fill, size: 14),
                    label: const Text('Mulai Penilaian', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onLoadDemo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.2),
                      foregroundColor: AppTheme.primaryBrown,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(CupertinoIcons.sparkles, size: 14, color: AppTheme.primaryBrown),
                    label: const Text('Muat Contoh Demo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(CupertinoIcons.arrow_counterclockwise, size: 13, color: AppTheme.textMuted),
                  label: const Text('Reset Form', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, double? val) {
    return Column(
      children: [
        Text(
          val != null ? val.toStringAsFixed(2) : '--',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
