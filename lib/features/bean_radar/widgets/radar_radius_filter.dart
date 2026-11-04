import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class RadarRadiusFilter extends StatelessWidget {
  final double selectedRadiusKm;
  final ValueChanged<double> onRadiusChanged;

  const RadarRadiusFilter({
    super.key,
    required this.selectedRadiusKm,
    required this.onRadiusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppTheme.bgCream,
      child: Row(
        children: [
          const Text(
            'Radius: ',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [10.0, 25.0, 50.0, 150.0, 500.0].map((radius) {
                  final isSel = selectedRadiusKm == radius;
                  final label = radius >= 500.0 ? 'Semua' : '${radius.toInt()} km';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppTheme.primaryBrown)),
                      selected: isSel,
                      selectedColor: AppTheme.primaryBrown,
                      backgroundColor: AppTheme.surfaceWhite,
                      onSelected: (val) {
                        if (val) onRadiusChanged(radius);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
