import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class EditorLiveSummaryBanner extends StatelessWidget {
  final String selectedCategory;
  final num coffee;
  final int water;
  final int ice;
  final bool isIcedMethod;
  final String ratio;
  final String totalTimeFormatted;

  const EditorLiveSummaryBanner({
    super.key,
    required this.selectedCategory,
    required this.coffee,
    required this.water,
    required this.ice,
    required this.isIcedMethod,
    required this.ratio,
    required this.totalTimeFormatted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Kalkulasi Resep',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedCategory,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryStat('Kopi', '${coffee}g'),
              _summaryStat('Air Panas', '${water}g'),
              if (isIcedMethod) _summaryStat('Es Batu', '${ice}g'),
              _summaryStat('Rasio', '1:$ratio'),
              _summaryStat('Durasi', totalTimeFormatted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
