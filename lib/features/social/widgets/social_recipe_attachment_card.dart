import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/barista_utils.dart';

class SocialRecipeAttachmentCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onSelectOther;
  final VoidCallback onRemove;

  const SocialRecipeAttachmentCard({
    super.key,
    required this.recipe,
    required this.onSelectOther,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final title = recipe['title']?.toString() ?? 'Resep Seduh';
    final author = recipe['author']?.toString() ?? 'Barista';
    final cleanAuthor = BaristaUtils.cleanName(author);
    final method = recipe['method']?.toString() ?? recipe['category']?.toString() ?? 'V60';
    final coffee = recipe['coffeeWeightGrams'] ?? 15;
    final water = recipe['totalWaterWeightGrams'] ?? 225;
    final temp = recipe['waterTempCelsius'] ?? 92;
    final ratio = (water is num && coffee is num && coffee > 0)
        ? (water / coffee).toStringAsFixed(1)
        : '15.0';
    final isCustom = recipe['isCustom'] == true || (recipe['id'] is int && (recipe['id'] as int) >= 500);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCustom
              ? const Color(0xFF2E7D32).withValues(alpha: 0.35)
              : AppTheme.accentGold.withValues(alpha: 0.5),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.person_crop_circle_badge_checkmark, size: 12, color: Color(0xFF2E7D32)),
                              SizedBox(width: 4),
                              Text(
                                'Resep Kustom Anda',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.rosette, size: 12, color: Color(0xFF9E6500)),
                              SizedBox(width: 4),
                              Text(
                                '🏆 World Recipe',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF9E6500)),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          method,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: onSelectOther,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 12, color: AppTheme.primaryBrown),
                      label: const Text(
                        'Ganti',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 18, color: AppTheme.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                height: 1.3,
              ),
              softWrap: true,
              maxLines: 4,
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
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _metricMini(CupertinoIcons.circle_grid_hex, '${coffee}g', 'Kopi'),
                  _metricMini(CupertinoIcons.drop, '${water}ml', 'Air'),
                  _metricMini(CupertinoIcons.gauge, '1:$ratio', 'Rasio'),
                  _metricMini(CupertinoIcons.thermometer, '$temp°C', 'Suhu'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricMini(IconData icon, String val, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppTheme.primaryBrown),
            const SizedBox(width: 3),
            Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ],
    );
  }
}
