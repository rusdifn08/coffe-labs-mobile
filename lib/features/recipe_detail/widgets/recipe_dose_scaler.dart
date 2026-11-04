import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';

class RecipeDoseScaler extends StatelessWidget {
  final int scaledCoffeeGrams;
  final int baseCoffeeGrams;
  final List<int> dosePresets;
  final ValueChanged<int> onDoseChanged;
  final VoidCallback onReset;

  const RecipeDoseScaler({
    super.key,
    required this.scaledCoffeeGrams,
    required this.baseCoffeeGrams,
    required this.dosePresets,
    required this.onDoseChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.slider_horizontal_3, size: 16, color: AppTheme.primaryBrown),
                  const SizedBox(width: 6),
                  Text(
                    isEn ? 'Adjust Coffee Dose (Auto-Scale)' : 'Sesuaikan Dosis Kopi (Auto-Scale)',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              if (scaledCoffeeGrams != baseCoffeeGrams)
                GestureDetector(
                  onTap: onReset,
                  child: Text(
                    isEn ? 'Reset Original' : 'Reset Asli',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: scaledCoffeeGrams > 8 ? () => onDoseChanged(scaledCoffeeGrams - 1) : null,
                icon: const Icon(CupertinoIcons.minus_circle_fill, color: AppTheme.primaryBrown),
              ),
              Text(
                '${scaledCoffeeGrams}g',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: scaledCoffeeGrams < 60 ? () => onDoseChanged(scaledCoffeeGrams + 1) : null,
                icon: const Icon(CupertinoIcons.plus_circle_fill, color: AppTheme.primaryBrown),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: dosePresets.map((dose) {
                      final selected = scaledCoffeeGrams == dose;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => onDoseChanged(dose),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.primaryBrown
                                    : AppTheme.primaryBrown.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              '${dose}g',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: selected ? Colors.white : AppTheme.textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
