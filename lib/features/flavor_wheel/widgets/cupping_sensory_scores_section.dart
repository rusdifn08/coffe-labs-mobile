import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CuppingSensoryScoresSection extends StatelessWidget {
  final double aromaScore;
  final double acidityScore;
  final double sweetnessScore;
  final double balanceScore;
  final bool hasEvaluated;
  final TextEditingController cuppingNotesController;
  final ValueChanged<double> onAromaChanged;
  final ValueChanged<double> onAcidityChanged;
  final ValueChanged<double> onSweetnessChanged;
  final ValueChanged<double> onBalanceChanged;
  final VoidCallback onFirstEvaluation;

  const CuppingSensoryScoresSection({
    super.key,
    required this.aromaScore,
    required this.acidityScore,
    required this.sweetnessScore,
    required this.balanceScore,
    required this.hasEvaluated,
    required this.cuppingNotesController,
    required this.onAromaChanged,
    required this.onAcidityChanged,
    required this.onSweetnessChanged,
    required this.onBalanceChanged,
    required this.onFirstEvaluation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 5. ATRIBUT SENSORI SCA LENGKAP
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '5. Atribut Sensori SCA Lengkap',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildScoreRow(context, 'Aroma & Fragrance (Wangi Kering / Basah)', aromaScore, onAromaChanged),
              const Divider(height: 18),

              _buildScoreRow(context, 'Acidity (Kecerahan Asam Buah)', acidityScore, onAcidityChanged),
              const Divider(height: 18),

              _buildScoreRow(context, 'Sweetness (Kemanisan Alami)', sweetnessScore, onSweetnessChanged),
              const Divider(height: 18),

              _buildScoreRow(context, 'Overall Balance (Keseimbangan Cangkir)', balanceScore, onBalanceChanged),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 6. CATATAN CUPPER
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.pencil_ellipsis_rectangle, color: AppTheme.primaryBrown, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '6. Kesimpulan & Catatan Cupper',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cuppingNotesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tuliskan evaluasi sensoris, kebersihan cangkir (clean cup), atau rekomendasi resep seduh...',
                  filled: true,
                  fillColor: AppTheme.bgCream,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(BuildContext context, String label, double score, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                score.toStringAsFixed(2),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
              ),
            ),
          ],
        ),
        _buildCuppingSlider(context, score, onChanged),
      ],
    );
  }

  Widget _buildCuppingSlider(BuildContext context, double value, Function(double) onChanged) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppTheme.primaryBrown,
        inactiveTrackColor: AppTheme.primaryBrown.withValues(alpha: 0.12),
        thumbColor: AppTheme.primaryBrown,
        overlayColor: AppTheme.primaryBrown.withValues(alpha: 0.18),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        trackHeight: 4,
      ),
      child: Slider(
        value: value,
        min: 6.0,
        max: 10.0,
        divisions: 16,
        onChanged: (v) {
          if (!hasEvaluated) {
            onFirstEvaluation();
          }
          onChanged(v);
        },
      ),
    );
  }
}
