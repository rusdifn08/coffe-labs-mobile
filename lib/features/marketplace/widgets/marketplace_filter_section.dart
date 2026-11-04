import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class MarketplaceFilterSection extends StatelessWidget {
  final bool isEn;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;
  final List<String> roastFilters;
  final String selectedRoast;
  final ValueChanged<String> onSelectRoast;

  const MarketplaceFilterSection({
    super.key,
    required this.isEn,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.roastFilters,
    required this.selectedRoast,
    required this.onSelectRoast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category Filter Chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final cat = categories[idx];
              final isSelected = selectedCategory == cat;
              return ChoiceChip(
                label: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.primaryBrown,
                backgroundColor: Colors.white,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryBrown : Colors.grey.withValues(alpha: 0.25),
                  ),
                ),
                onSelected: (val) => onSelectCategory(cat),
              );
            },
          ),
        ),

        // Roast Profile Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              Text(
                isEn ? 'Roast:' : 'Sangrai:',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: roastFilters.map((rf) {
                      final isSel = selectedRoast == rf;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => onSelectRoast(rf),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.accentGold.withValues(alpha: 0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppTheme.accentGold : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              rf,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.normal,
                                color: isSel ? AppTheme.primaryBrown : AppTheme.textMuted,
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
        ),
      ],
    );
  }
}
