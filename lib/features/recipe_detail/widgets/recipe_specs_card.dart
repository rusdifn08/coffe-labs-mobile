import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../../../../utils/barista_utils.dart';
import '../../../../data/brew_visual_catalog.dart';

class RecipeSpecsCard extends StatelessWidget {
  final String grindSize;
  final String method;
  final String beanNameOnly;
  final String variety;
  final String process;
  final IconData processIcon;
  final List<String> notesList;
  final VoidCallback onGrinderConverterPressed;

  const RecipeSpecsCard({
    super.key,
    required this.grindSize,
    required this.method,
    required this.beanNameOnly,
    required this.variety,
    required this.process,
    required this.processIcon,
    required this.notesList,
    required this.onGrinderConverterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final shortGrind = BaristaUtils.shortGrindLabel(grindSize);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gilingan Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.circle_grid_hex, size: 19, color: AppTheme.primaryBrown),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  shortGrind,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              InkWell(
                onTap: onGrinderConverterPressed,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.compass, size: 13, color: AppTheme.primaryBrown),
                      const SizedBox(width: 5),
                      Text(
                        isEn ? 'Grinder Converter' : 'Konversi Grinder',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF2ECE4)),
          ),

          // 2. Alat Dripper Row
          Row(
            children: [
              DripperGraphicBadge(
                item: BrewVisualCatalog.matchDripper(method),
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  method,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF2ECE4)),
          ),

          // 3. Biji Kopi Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.coffee_rounded, size: 20, color: AppTheme.primaryBrown),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  beanNameOnly,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF2ECE4)),
          ),

          // 4. Varietas Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.eco_rounded, size: 20, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  variety,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF2ECE4)),
          ),

          // 5. Proses Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE65100).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(processIcon, size: 20, color: const Color(0xFFD84315)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  process,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),

          // 6. Tasting Notes Row
          if (notesList.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFF2ECE4)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.sparkles, size: 14, color: AppTheme.accentAmber),
                  const SizedBox(width: 6),
                  Text(
                    isEn ? 'Tasting Notes & Flavor Profile' : 'Profil Rasa (Tasting Notes)',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: notesList
                  .map((note) => FlavorNoteVisualBadge(noteText: note))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
