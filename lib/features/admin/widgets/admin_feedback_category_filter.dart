import 'package:flutter/material.dart';
import '../../../models/feedback_item.dart';
import '../../../theme/app_theme.dart';

class AdminFeedbackCategoryFilter extends StatelessWidget {
  final String? selectedCategoryFilter;
  final ValueChanged<String?> onSelectCategory;

  const AdminFeedbackCategoryFilter({
    super.key,
    required this.selectedCategoryFilter,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Semua Kategori'),
            selected: selectedCategoryFilter == null,
            onSelected: (_) => onSelectCategory(null),
            selectedColor: AppTheme.primaryBrown,
            labelStyle: TextStyle(
              color: selectedCategoryFilter == null ? Colors.white : AppTheme.textDark,
              fontWeight: selectedCategoryFilter == null ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          ...FeedbackCategory.all.map((cat) {
            final isSelected = selectedCategoryFilter == cat.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text('${cat.emoji} ${cat.label}'),
                selected: isSelected,
                onSelected: (_) => onSelectCategory(isSelected ? null : cat.key),
                selectedColor: cat.color,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
