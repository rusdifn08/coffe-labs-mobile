import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ScaleRatioCalculatorCard extends StatelessWidget {
  final bool isEn;
  final double coffeeDoseGrams;
  final double selectedRatio;
  final double currentWeight;
  final ValueChanged<double> onDoseChanged;
  final ValueChanged<double> onRatioChanged;

  const ScaleRatioCalculatorCard({
    super.key,
    required this.isEn,
    required this.coffeeDoseGrams,
    required this.selectedRatio,
    required this.currentWeight,
    required this.onDoseChanged,
    required this.onRatioChanged,
  });

  double get targetWater => coffeeDoseGrams * selectedRatio;
  double get progress => targetWater > 0 ? (currentWeight / targetWater).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1B18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEn ? 'Target Ratio Calculator' : 'Kalkulator Target Rasio',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                '1:${selectedRatio.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.accentGold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Dose selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Coffee Dose' : 'Dosis Kopi',
                      style: const TextStyle(fontSize: 10.5, color: Colors.white54),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildDoseChip(12.0),
                        const SizedBox(width: 4),
                        _buildDoseChip(15.0),
                        const SizedBox(width: 4),
                        _buildDoseChip(18.0),
                        const SizedBox(width: 4),
                        _buildDoseChip(20.0),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Ratio selectors
          Row(
            children: [
              _buildRatioChip(14.0),
              const SizedBox(width: 6),
              _buildRatioChip(15.0),
              const SizedBox(width: 6),
              _buildRatioChip(16.0),
              const SizedBox(width: 6),
              _buildRatioChip(16.6),
              const SizedBox(width: 6),
              _buildRatioChip(17.0),
            ],
          ),
          const Divider(height: 20, color: Colors.white12),
          // Target vs Current Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentWeight.toStringAsFixed(1)}g / ${targetWater.toStringAsFixed(1)}g',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: progress >= 1.0 ? Colors.greenAccent : AppTheme.accentGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.greenAccent : AppTheme.accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoseChip(double dose) {
    final isSel = coffeeDoseGrams == dose;
    return InkWell(
      onTap: () => onDoseChanged(dose),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.accentGold : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${dose.toInt()}g',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRatioChip(double ratio) {
    final isSel = selectedRatio == ratio;
    return InkWell(
      onTap: () => onRatioChanged(ratio),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.primaryBrown : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSel ? AppTheme.accentGold : Colors.transparent,
          ),
        ),
        child: Text(
          '1:${ratio.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
