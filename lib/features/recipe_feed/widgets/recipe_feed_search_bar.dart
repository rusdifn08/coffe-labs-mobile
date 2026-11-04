import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';

class RecipeFeedSearchBar extends StatelessWidget {
  final int activeFilterCount;
  final List<String> categories;
  final String selectedCategory;
  final String selectedPourFilter;
  final String selectedDripperFilter;
  final String selectedBaristaFilter;
  final String selectedNoteFilter;
  final String selectedOriginFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilter;
  final VoidCallback onOpenSort;
  final bool isSortActive;
  final String? activeSortLabel;
  final VoidCallback? onResetSort;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onRemovePourFilter;
  final VoidCallback onRemoveDripperFilter;
  final VoidCallback onRemoveBaristaFilter;
  final VoidCallback onRemoveNoteFilter;
  final VoidCallback onRemoveOriginFilter;
  final VoidCallback onResetAll;

  const RecipeFeedSearchBar({
    super.key,
    required this.activeFilterCount,
    required this.categories,
    required this.selectedCategory,
    required this.selectedPourFilter,
    required this.selectedDripperFilter,
    required this.selectedBaristaFilter,
    required this.selectedNoteFilter,
    required this.selectedOriginFilter,
    required this.onSearchChanged,
    required this.onOpenFilter,
    required this.onOpenSort,
    this.isSortActive = false,
    this.activeSortLabel,
    this.onResetSort,
    required this.onCategorySelected,
    required this.onRemovePourFilter,
    required this.onRemoveDripperFilter,
    required this.onRemoveBaristaFilter,
    required this.onRemoveNoteFilter,
    required this.onRemoveOriginFilter,
    required this.onResetAll,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar + Filter Modal Button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: isEn ? 'Search barista, beans, dripper, notes...' : 'Cari barista, biji, dripper, notes...',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                      border: InputBorder.none,
                      icon: const Icon(CupertinoIcons.search, color: AppTheme.textMuted, size: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onOpenFilter,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: activeFilterCount > 0 ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.slider_horizontal_3,
                        size: 18,
                        color: activeFilterCount > 0 ? Colors.white : AppTheme.primaryBrown,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        activeFilterCount > 0 ? 'Filter ($activeFilterCount)' : 'Filter',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: activeFilterCount > 0 ? Colors.white : AppTheme.primaryBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onOpenSort,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSortActive ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSortActive
                          ? AppTheme.primaryBrown
                          : AppTheme.primaryBrown.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    CupertinoIcons.arrow_up_arrow_down,
                    size: 18,
                    color: isSortActive ? Colors.white : AppTheme.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Category Quick Chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              String cat = categories[index];
              bool isSelected = selectedCategory == cat;
              return GestureDetector(
                onTap: () => onCategorySelected(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Active Filters & Sort Banner
        if (activeFilterCount > 0 || isSortActive)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 2),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (isSortActive && activeSortLabel != null)
                          _activeFilterChip(activeSortLabel!, onResetSort ?? () {}),
                        if (selectedPourFilter != 'Semua' && selectedPourFilter != 'All')
                          _activeFilterChip(selectedPourFilter, onRemovePourFilter),
                        if (selectedDripperFilter != 'Semua' && selectedDripperFilter != 'All')
                          _activeFilterChip(selectedDripperFilter, onRemoveDripperFilter),
                        if (selectedBaristaFilter != 'Semua' && selectedBaristaFilter != 'All')
                          _activeFilterChip(selectedBaristaFilter, onRemoveBaristaFilter),
                        if (selectedNoteFilter != 'Semua' && selectedNoteFilter != 'All')
                          _activeFilterChip(selectedNoteFilter, onRemoveNoteFilter),
                        if (selectedOriginFilter != 'Semua' && selectedOriginFilter != 'All')
                          _activeFilterChip(selectedOriginFilter, onRemoveOriginFilter),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onResetAll,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      isEn ? 'Reset All' : 'Reset Semua',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static Widget _activeFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accentAmber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(CupertinoIcons.xmark_circle_fill, size: 12, color: AppTheme.primaryBrown),
          ),
        ],
      ),
    );
  }
}
