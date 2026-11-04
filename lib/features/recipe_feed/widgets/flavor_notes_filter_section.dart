import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../models/note_category_item.dart';

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
    final curCat = noteCategories.firstWhere(
      (c) => c.id == activeNoteCategoryModal,
      orElse: () => noteCategories.first,
    );
    final categoryNotes = BrewVisualCatalog.flavorNotes
        .where((fn) => curCat.groups.contains(fn.group))
        .toList();
    final isCategorySelected = selectedNoteFilter == '${curCat.emoji} ${curCat.label}' ||
        selectedNoteFilter == '${curCat.emoji} ${curCat.labelEn}' ||
        selectedNoteFilter == 'Semua ${curCat.label}' ||
        selectedNoteFilter == 'All ${curCat.labelEn}' ||
        selectedNoteFilter == curCat.label ||
        selectedNoteFilter == curCat.labelEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(CupertinoIcons.sparkles, size: 16, color: AppTheme.primaryBrown),
            const SizedBox(width: 6),
            Text(
              LanguageService.isEnglish ? '5. Tasting Notes & Flavor Profile' : '5. Tasting Notes & Karakter Rasa',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          selectedNoteFilter == 'Semua' || selectedNoteFilter == 'All'
              ? (LanguageService.isEnglish
                  ? 'Select a flavor category to explore relevant notes:'
                  : 'Pilih kategori rasa untuk menampilkan pilihan notes yang relevan:')
              : (LanguageService.isEnglish
                  ? 'Active filter: $selectedNoteFilter'
                  : 'Filter aktif: $selectedNoteFilter'),
          style: TextStyle(
            fontSize: 11.5,
            color: (selectedNoteFilter == 'Semua' || selectedNoteFilter == 'All')
                ? AppTheme.textMuted
                : AppTheme.primaryBrown,
            fontWeight: (selectedNoteFilter == 'Semua' || selectedNoteFilter == 'All')
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: noteCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (ctx, idx) {
              final cat = noteCategories[idx];
              final isCatActive = activeNoteCategoryModal == cat.id;
              return ChoiceChip(
                label: Text(
                  '${cat.emoji} ${cat.localizedLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCatActive ? Colors.white : AppTheme.textDark,
                  ),
                ),
                selected: isCatActive,
                selectedColor: AppTheme.primaryBrown,
                backgroundColor: AppTheme.surfaceWhite,
                side: BorderSide(
                  color: isCatActive ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
                ),
                onSelected: (_) => onCategoryTabChanged(cat.id),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryBrown.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LanguageService.isEnglish
                        ? '${curCat.emoji} ${curCat.localizedLabel} Notes (${categoryNotes.length})'
                        : '${curCat.emoji} Pilihan Notes ${curCat.label} (${categoryNotes.length})',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  if (selectedNoteFilter != 'Semua' && selectedNoteFilter != 'All')
                    GestureDetector(
                      onTap: () => onNoteFilterChanged(LanguageService.isEnglish ? 'All' : 'Semua'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.clear_circled_solid, size: 13, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(
                            LanguageService.isEnglish ? 'Clear Notes' : 'Hapus Notes',
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
                children: [
                  ChoiceChip(
                    label: Text(
                      LanguageService.isEnglish
                          ? 'All ${curCat.localizedLabel} ${curCat.emoji}'
                          : 'Semua ${curCat.label} ${curCat.emoji}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isCategorySelected ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    selected: isCategorySelected,
                    selectedColor: AppTheme.primaryBrown,
                    backgroundColor: AppTheme.bgCream,
                    side: BorderSide(
                      color: isCategorySelected ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
                    ),
                    onSelected: (_) {
                      onNoteFilterChanged(isCategorySelected
                          ? (LanguageService.isEnglish ? 'All' : 'Semua')
                          : '${curCat.emoji} ${curCat.localizedLabel}');
                    },
                  ),
                  ...categoryNotes.map((fn) {
                    final sel = selectedNoteFilter == fn.label;
                    return FlavorNoteVisualBadge(
                      noteText: fn.label,
                      selected: sel,
                      onTap: () {
                        onNoteFilterChanged(sel ? (LanguageService.isEnglish ? 'All' : 'Semua') : fn.label);
                      },
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
