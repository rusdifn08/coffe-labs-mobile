import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../models/social_coffee.dart';
import '../../../../theme/app_theme.dart';

class SocialEmbeddedRecipeCard extends StatelessWidget {
  final SocialPost post;
  final VoidCallback onCopyRecipe;

  const SocialEmbeddedRecipeCard({
    super.key,
    required this.post,
    required this.onCopyRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final snap = post.recipeSnapshot!;
    final title = snap['title']?.toString() ?? 'Resep Seduh';
    final method = snap['method']?.toString() ?? 'Hario V60 02';
    final coffee = snap['coffeeWeightGrams'] ?? 15;
    final water = snap['totalWaterWeightGrams'] ?? 225;
    final temp = snap['waterTempCelsius'] ?? 92;
    final notes = snap['tastingNotes']?.toString() ?? '';

    final ratio = (water is num && coffee is num && coffee > 0)
        ? (water / coffee).toStringAsFixed(1)
        : '15.0';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCream.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4), width: 1.2),
      ),
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(CupertinoIcons.drop_fill, color: AppTheme.primaryBrown, size: 13),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          method,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    if (snap['isCustom'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '✍️ Resep Kustom',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '🏆 World Recipe',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF9E6500)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // COPY RESEP BUTTON - CUKUP ICON COPY SAJA SESUAI INSTRUKSI USER
              Material(
                color: Colors.transparent,
                child: Tooltip(
                  message: 'Copy Resep',
                  child: InkWell(
                    onTap: onCopyRecipe,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.doc_on_clipboard_fill,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Judul Resep: Bisa turun ke baris baru jika card tidak cukup
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
          const SizedBox(height: 8),
          // Metric row: Wrap agar tidak overflow pada layar kecil
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _metricPill(CupertinoIcons.circle_grid_hex, '${coffee}g Kopi'),
              _metricPill(CupertinoIcons.drop, '${water}ml Air'),
              _metricPill(CupertinoIcons.gauge, '1:$ratio'),
              _metricPill(CupertinoIcons.thermometer, '$temp°C'),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: $notes',
              style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppTheme.primaryBrown),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}
