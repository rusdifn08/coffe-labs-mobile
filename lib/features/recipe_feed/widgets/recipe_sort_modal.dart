import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../models/recipe_sort_option.dart';

class RecipeSortModal {
  static void show({
    required BuildContext context,
    required RecipeSortOption currentSort,
    required ValueChanged<RecipeSortOption> onSortSelected,
  }) {
    final isEn = LanguageService.isEnglish;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.arrow_up_arrow_down,
                            size: 17,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn ? 'Sort Recipes' : 'Urutkan Resep',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Text(
                              isEn
                                  ? 'Select category priority for recipes'
                                  : 'Pilih kategori urutan tampilan resep',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Scrollable Sort Options List to prevent overflow on any screen height
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: RecipeSortOption.values.map((opt) {
                        final isSelected = opt == currentSort;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: isSelected
                                ? AppTheme.accentGold.withValues(alpha: 0.14)
                                : AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                onSortSelected(opt);
                                Navigator.pop(ctx);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.accentGold
                                        : AppTheme.primaryBrown.withValues(alpha: 0.08),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryBrown
                                            : AppTheme.primaryBrown.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        opt.icon,
                                        size: 19,
                                        color: isSelected ? Colors.white : AppTheme.primaryBrown,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            opt.label,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight:
                                                  isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: isSelected
                                                  ? AppTheme.primaryBrown
                                                  : AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            opt.description,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isSelected
                                                  ? AppTheme.primaryBrown.withValues(alpha: 0.8)
                                                  : AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        CupertinoIcons.checkmark_circle_fill,
                                        color: AppTheme.accentGold,
                                        size: 20,
                                      ),
                                  ],
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
        );
      },
    );
  }
}
