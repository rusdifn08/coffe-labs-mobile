import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/barista_utils.dart';

class SocialRecipePickerTile extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final bool isSelected;
  final VoidCallback onTap;

  const SocialRecipePickerTile({
    super.key,
    required this.recipe,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final id = recipe['id'] as int?;
    final title = recipe['title']?.toString() ?? 'Resep Kopi';
    final author = recipe['author']?.toString() ?? 'Barista';
    final cleanAuthor = BaristaUtils.cleanName(author);
    final method = recipe['method']?.toString() ?? recipe['category']?.toString() ?? 'V60';
    final bean = recipe['beanName']?.toString() ?? '';
    final coffee = recipe['coffeeWeightGrams'] ?? 15;
    final water = recipe['totalWaterWeightGrams'] ?? 225;
    final temp = recipe['waterTempCelsius'] ?? 92;
    final ratio = (water is num && coffee is num && coffee > 0)
        ? (water / coffee).toStringAsFixed(1)
        : '15.0';
    final isCustom = recipe['isCustom'] == true || (id != null && id >= 500);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accentGold.withValues(alpha: 0.08) : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.accentGold : AppTheme.primaryBrown.withValues(alpha: 0.12),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar / Method Icon
                if (!isCustom)
                  BaristaAvatar(
                    imageUrl: BaristaUtils.imageUrlFromRecipe(recipe),
                    radius: 22,
                  )
                else
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      color: Color(0xFF2E7D32),
                      size: 22,
                    ),
                  ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              method,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (isCustom)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '✍️ Resep Kustom',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '🏆 World Recipe',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9E6500),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (cleanAuthor.isNotEmpty && cleanAuthor != 'Barista') ...[
                        const SizedBox(height: 2),
                        Text(
                          cleanAuthor,
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (bean.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          bean,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Parameter Row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _smallParamPill('⚖️ ${coffee}g'),
                          _smallParamPill('💧 ${water}ml'),
                          _smallParamPill('📐 1:$ratio'),
                          _smallParamPill('🌡️ $temp°C'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Check / Select indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppTheme.primaryBrown : AppTheme.bgCream,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    isSelected ? CupertinoIcons.checkmark : CupertinoIcons.add,
                    size: 14,
                    color: isSelected ? Colors.white : AppTheme.primaryBrown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallParamPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textDark),
      ),
    );
  }
}
