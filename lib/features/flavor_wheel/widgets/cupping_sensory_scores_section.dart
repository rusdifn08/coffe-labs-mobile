import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Step 3 of SCA Cupping Flow: Full SCA Sensory Scoring (0.25 increments),
/// Defect Deduction check, and Cupper Summary Notes (no duplicate notes card).
class CuppingSensoryScoresSection extends StatelessWidget {
  final double aromaScore;
  final double acidityScore;
  final double sweetnessScore;
  final double balanceScore;
  final int defectDeduction;
  final bool hasEvaluated;
  final TextEditingController cuppingNotesController;
  final ValueChanged<double> onAromaChanged;
  final ValueChanged<double> onAcidityChanged;
  final ValueChanged<double> onSweetnessChanged;
  final ValueChanged<double> onBalanceChanged;
  final ValueChanged<int> onDefectDeductionChanged;
  final VoidCallback onFirstEvaluation;

  const CuppingSensoryScoresSection({
    super.key,
    required this.aromaScore,
    required this.acidityScore,
    required this.sweetnessScore,
    required this.balanceScore,
    this.defectDeduction = 0,
    required this.hasEvaluated,
    required this.cuppingNotesController,
    required this.onAromaChanged,
    required this.onAcidityChanged,
    required this.onSweetnessChanged,
    required this.onBalanceChanged,
    required this.onDefectDeductionChanged,
    required this.onFirstEvaluation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: AppTheme.primaryBrown,
                    size: 18,
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Atribut Sensori SCA (Skala 6.00 – 10.00)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildScoreRow(
                context,
                'Fragrance & Aroma',
                'Wangi bubuk kering & saat breaking crust',
                aromaScore,
                onAromaChanged,
              ),
              const Divider(height: 14, color: AppTheme.dividerColor),

              _buildScoreRow(
                context,
                'Acidity (Keasaman)',
                'Kecerahan & kualitas asam buah alami',
                acidityScore,
                onAcidityChanged,
              ),
              const Divider(height: 14, color: AppTheme.dividerColor),

              _buildScoreRow(
                context,
                'Sweetness (Kemanisan)',
                'Kemanisan penuh dari panas hingga dingin',
                sweetnessScore,
                onSweetnessChanged,
              ),
              const Divider(height: 14, color: AppTheme.dividerColor),

              _buildScoreRow(
                context,
                'Balance & Overall',
                'Harmoni rasa, konsistensi, dan kesan menyeluruh',
                balanceScore,
                onBalanceChanged,
              ),
              const Divider(height: 16, color: AppTheme.dividerColor),

              // SCA Defect / Clean Cup Deduction
              const Text(
                'Pengurangan Cacat Cangkir (SCA Defects / Taint / Fault)',
                style: TextStyle(
                  fontSize: 11.8,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _defectChip(0, 'Clean (0)'),
                  _defectChip(2, 'Taint (-2)'),
                  _defectChip(4, 'Fault (-4)'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Single clean Cupper Notes & Conclusion card
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.pencil_ellipsis_rectangle,
                    color: AppTheme.primaryBrown,
                    size: 18,
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Kesimpulan & Catatan Cupper',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              TextField(
                controller: cuppingNotesController,
                maxLines: 3,
                style: const TextStyle(fontSize: 12.8, color: AppTheme.textDark),
                decoration: InputDecoration(
                  hintText:
                      'Tuliskan evolusi rasa (panas → hangat → dingin), clean cup, atau saran seduh...',
                  hintStyle: const TextStyle(
                    fontSize: 11.8,
                    color: AppTheme.textMuted,
                  ),
                  filled: true,
                  fillColor: AppTheme.bgCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _defectChip(int deduction, String label) {
    final isSel = defectDeduction == deduction;
    final activeColor =
        deduction == 0 ? const Color(0xFF0F766E) : const Color(0xFFB91C1C);
    return InkWell(
      onTap: () {
        if (!hasEvaluated) onFirstEvaluation();
        onDefectDeductionChanged(deduction);
      },
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? activeColor : AppTheme.bgCream,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSel ? activeColor : AppTheme.borderWarm,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSel ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(
    BuildContext context,
    String title,
    String subtitle,
    double score,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                score.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryBrown,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryBrown,
            inactiveTrackColor: AppTheme.primaryBrown.withValues(alpha: 0.14),
            thumbColor: AppTheme.primaryBrown,
            overlayColor: AppTheme.primaryBrown.withValues(alpha: 0.18),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.5),
            trackHeight: 4,
          ),
          child: Slider(
            value: score,
            min: 6.0,
            max: 10.0,
            divisions: 16,
            onChanged: (v) {
              if (!hasEvaluated) {
                onFirstEvaluation();
              }
              onChanged(double.parse(v.toStringAsFixed(2)));
            },
          ),
        ),
      ],
    );
  }
}
