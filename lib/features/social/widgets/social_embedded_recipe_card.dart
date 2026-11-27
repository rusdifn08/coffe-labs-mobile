import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../models/social_coffee.dart';
import '../../../../theme/app_theme.dart';

/// Kotak kutipan resep minimalis ala quoted-post Threads (tanpa tombol Salin — langsung bisa diseduh atau disimpan di aksi bawah).
class SocialEmbeddedRecipeCard extends StatelessWidget {
  final SocialPost post;
  final VoidCallback onBrewRecipe;

  const SocialEmbeddedRecipeCard({
    super.key,
    required this.post,
    required this.onBrewRecipe,
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

    return Material(
      color: AppTheme.surfaceWhite.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onBrewRecipe,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderWarm, width: 1),
          ),
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.drop_fill,
                    color: AppTheme.primaryBrown,
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '$method • ${snap['isCustom'] == true ? 'Resep Kustom' : 'World Recipe'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.play_fill,
                          size: 10.5,
                          color: AppTheme.primaryBrown,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Seduh',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  height: 1.3,
                ),
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                '${coffee}g kopi • ${water}ml air • Rasio 1:$ratio • $temp°C',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  notes,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
