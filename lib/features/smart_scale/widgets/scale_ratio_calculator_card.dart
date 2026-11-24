import 'package:flutter/material.dart';
import '../../../models/smart_scale_model.dart';
import '../../../theme/app_theme.dart';

/// Coffee Labs bright-theme mode-aware Dose, Ratio & Yield Target Calculator.
class ScaleRatioCalculatorCard extends StatelessWidget {
  final bool isEn;
  final ScaleBrewMode mode;
  final double coffeeDoseGrams;
  final double selectedRatio;
  final double currentWeight;
  final ValueChanged<double> onDoseChanged;
  final ValueChanged<double> onRatioChanged;

  const ScaleRatioCalculatorCard({
    super.key,
    required this.isEn,
    this.mode = ScaleBrewMode.pourOver,
    required this.coffeeDoseGrams,
    required this.selectedRatio,
    required this.currentWeight,
    required this.onDoseChanged,
    required this.onRatioChanged,
  });

  double get targetWater => coffeeDoseGrams * selectedRatio;
  double get progress =>
      targetWater > 0 ? (currentWeight / targetWater).clamp(0.0, 1.0) : 0.0;
  double get liveRatio =>
      coffeeDoseGrams > 0 ? (currentWeight / coffeeDoseGrams) : 0.0;

  @override
  Widget build(BuildContext context) {
    final isEspresso = mode == ScaleBrewMode.espresso;
    final dosePresets = isEspresso
        ? const [16.0, 18.0, 19.0, 20.0]
        : const [12.0, 15.0, 18.0, 20.0];
    final ratioPresets = isEspresso
        ? const [1.5, 2.0, 2.5, 3.0]
        : const [14.0, 15.0, 16.0, 16.7, 17.0];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isEspresso
                      ? (isEn
                          ? 'Espresso Yield Target'
                          : 'Target Yield Espresso')
                      : (isEn
                          ? 'Brew Ratio & Water Target'
                          : 'Target Rasio & Air Seduh'),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '1:${selectedRatio.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dose row with stepper & quick chips
          Row(
            children: [
              Text(
                isEn ? 'Coffee Dose' : 'Dosis Kopi',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                ),
              ),
              const Spacer(),
              _buildStepperButton(
                label: '−',
                onTap: () => onDoseChanged(
                  (coffeeDoseGrams - 0.5).clamp(5.0, 60.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${coffeeDoseGrams.toStringAsFixed(1)} g',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              _buildStepperButton(
                label: '+',
                onTap: () => onDoseChanged(
                  (coffeeDoseGrams + 0.5).clamp(5.0, 60.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: dosePresets.map(_buildDoseChip).toList(),
          ),
          const SizedBox(height: 12),

          Text(
            isEspresso
                ? (isEn ? 'Shot Ratio' : 'Rasio Ekstraksi')
                : (isEn ? 'Brew Ratio' : 'Rasio Seduh'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ratioPresets.map(_buildRatioChip).toList(),
          ),
          const Divider(height: 22, color: AppTheme.dividerColor),

          // Live Target vs Current Progress
          Row(
            children: [
              Expanded(
                child: Text(
                  '${currentWeight.toStringAsFixed(1)} g / ${targetWater.toStringAsFixed(1)} g',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Text(
                'Live 1:${liveRatio.toStringAsFixed(1)}  •  ${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: progress >= 0.98
                      ? const Color(0xFF0F766E)
                      : AppTheme.primaryBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.bgCream,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.98
                    ? const Color(0xFF0F766E)
                    : AppTheme.primaryBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderWarm),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryBrown,
          ),
        ),
      ),
    );
  }

  Widget _buildDoseChip(double dose) {
    final isSel = (coffeeDoseGrams - dose).abs() < 0.05;
    return InkWell(
      onTap: () => onDoseChanged(dose),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.primaryBrown : AppTheme.bgCream,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSel ? AppTheme.primaryBrown : AppTheme.borderWarm,
          ),
        ),
        child: Text(
          '${dose.toInt()}g',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSel ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildRatioChip(double ratio) {
    final isSel = (selectedRatio - ratio).abs() < 0.05;
    return InkWell(
      onTap: () => onRatioChanged(ratio),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSel
              ? AppTheme.accentAmber.withValues(alpha: 0.2)
              : AppTheme.bgCream,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSel ? AppTheme.accentAmber : AppTheme.borderWarm,
          ),
        ),
        child: Text(
          '1:${ratio.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSel ? AppTheme.primaryBrown : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
