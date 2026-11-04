import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';

class RecipeChecklistCard extends StatelessWidget {
  final bool showPrepChecklist;
  final Set<int> checkedPrep;
  final List<String> prepChecklist;
  final VoidCallback onToggleExpand;
  final ValueChanged<int> onToggleItem;

  const RecipeChecklistCard({
    super.key,
    required this.showPrepChecklist,
    required this.checkedPrep,
    required this.prepChecklist,
    required this.onToggleExpand,
    required this.onToggleItem,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.checkmark_seal_fill, size: 16, color: AppTheme.primaryBrown),
                      const SizedBox(width: 8),
                      Text(
                        isEn ? 'Pre-Brew Preparation Checklist' : 'Checklist Persiapan Sebelum Brew',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${checkedPrep.length}/${prepChecklist.length}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      showPrepChecklist ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                      size: 20,
                      color: showPrepChecklist ? AppTheme.primaryBrown : AppTheme.textMuted,
                    ),
                    tooltip: showPrepChecklist
                        ? (isEn ? 'Hide Prep Checklist' : 'Sembunyikan Persiapan')
                        : (isEn ? 'Show Prep Checklist' : 'Tampilkan Persiapan'),
                    onPressed: onToggleExpand,
                  ),
                ],
              ),
            ),
          ),
          if (showPrepChecklist) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...prepChecklist.asMap().entries.map((entry) {
              final idx = entry.key;
              final text = entry.value;
              final done = checkedPrep.contains(idx);
              return InkWell(
                onTap: () => onToggleItem(idx),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Icon(
                        done ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                        size: 18,
                        color: done ? Colors.green : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 12,
                            color: done ? AppTheme.textMuted : AppTheme.textDark,
                            decoration: done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
