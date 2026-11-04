import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Card for adjusting coffee dose (grams) with live water & ratio display.
class BeanDoseSliderCard extends StatelessWidget {
  final double dose;
  final double totalWater;
  final double brewRatio;
  final ValueChanged<double> onDoseChanged;

  const BeanDoseSliderCard({
    super.key,
    required this.dose,
    required this.totalWater,
    required this.brewRatio,
    required this.onDoseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.circle_grid_3x3_fill, size: 15, color: AppTheme.primaryBrown),
                  const SizedBox(width: 6),
                  const Text(
                    'Dosis Bubuk Kopi',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.brown.shade200),
                ),
                child: Text(
                  '${dose.toStringAsFixed(dose.truncateToDouble() == dose ? 0 : 1)}g Kopi  •  ${totalWater.round()}g Air (1:${brewRatio.toStringAsFixed(1)})',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: dose,
            min: 12,
            max: 30,
            divisions: 18,
            activeColor: AppTheme.primaryBrown,
            inactiveColor: AppTheme.bgCream,
            onChanged: onDoseChanged,
          ),
        ],
      ),
    );
  }
}
