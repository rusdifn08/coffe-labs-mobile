import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Compact, zero-overflow SCA Cupping Live Score card.
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
  final double balanceScore;
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
    this.balanceScore = 8.00,
    required this.onStartEvaluate,
    required this.onLoadDemo,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL SCA SCORE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            hasEvaluated
                                ? totalCuppingScore.toStringAsFixed(2)
                                : '--',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: cuppingGradeColor,
                              letterSpacing: -0.8,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '/ 100',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 5,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: cuppingGradeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: cuppingGradeColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    cuppingGradeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.8,
                      fontWeight: FontWeight.w800,
                      color: cuppingGradeColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: AppTheme.dividerColor),
          Row(
            children: [
              _buildMiniMetric('Aroma', hasEvaluated ? aromaScore : null),
              _buildMiniMetric('Acid', hasEvaluated ? acidityScore : null),
              _buildMiniMetric('Sweet', hasEvaluated ? sweetnessScore : null),
              _buildMiniMetric('Body', hasEvaluated ? mouthfeelScore : null),
              _buildMiniMetric('After', hasEvaluated ? aftertasteScore : null),
              _buildMiniMetric('Bal', hasEvaluated ? balanceScore : null),
            ],
          ),
          if (!hasEvaluated) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onStartEvaluate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBrown,
                      side: const BorderSide(
                        color: AppTheme.primaryBrown,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.play_fill, size: 13),
                    label: const Text(
                      'Mulai Nilai',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onLoadDemo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.accentAmber.withValues(alpha: 0.2),
                      foregroundColor: AppTheme.primaryBrown,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                    icon: const Icon(
                      CupertinoIcons.sparkles,
                      size: 13,
                      color: AppTheme.primaryBrown,
                    ),
                    label: const Text(
                      'Contoh Demo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, double? val) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val != null ? val.toStringAsFixed(1) : '--',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              color: AppTheme.textDark,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9.5,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
