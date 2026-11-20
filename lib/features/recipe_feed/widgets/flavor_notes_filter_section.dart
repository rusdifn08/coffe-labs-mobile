import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../utils/recipe_filter_matcher.dart';

/// Bagian filter Tasting Notes yang ringkas: hanya menampilkan pilihan rasa inti
/// (Floral, Fruity, Citrus, Berry, Chocolaty, Sweet, Nutty, Tea-Like).
class FlavorNotesFilterSection extends StatelessWidget {
  final String activeNoteCategoryModal;
  final String selectedNoteFilter;
  final ValueChanged<String> onCategoryTabChanged;
  final ValueChanged<String> onNoteFilterChanged;

  const FlavorNotesFilterSection({
    super.key,
    required this.activeNoteCategoryModal,
    required this.selectedNoteFilter,
    required this.onCategoryTabChanged,
    required this.onNoteFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final hasSelection =
        selectedNoteFilter != 'Semua' && selectedNoteFilter != 'All' && selectedNoteFilter.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.sparkles, size: 16, color: AppTheme.primaryBrown),
                const SizedBox(width: 6),
                Text(
                  isEn ? 'Tasting Notes' : 'Tasting Notes',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            if (hasSelection)
              GestureDetector(
                onTap: () => onNoteFilterChanged(isEn ? 'All' : 'Semua'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.xmark_circle_fill, size: 13, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text(
                      isEn ? 'Clear' : 'Hapus',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RecipeFilterMatcher.coreTastingNotes.map((opt) {
            final label = isEn ? opt.labelEn : opt.labelId;
            final isSelected = selectedNoteFilter.toLowerCase() == opt.key.toLowerCase() ||
                selectedNoteFilter.toLowerCase() == label.toLowerCase() ||
                selectedNoteFilter.toLowerCase() == '${opt.emoji} $label'.toLowerCase();

            return GestureDetector(
              onTap: () {
                onNoteFilterChanged(isSelected ? (isEn ? 'All' : 'Semua') : opt.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBrown
                        : AppTheme.primaryBrown.withValues(alpha: 0.16),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(opt.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
