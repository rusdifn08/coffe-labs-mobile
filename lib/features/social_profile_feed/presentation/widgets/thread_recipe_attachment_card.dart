import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/social_thread_models.dart';

class ThreadRecipeAttachmentCard extends StatelessWidget {
  final InteractiveRecipeCardAttachment card;
  final int tryCount;
  final VoidCallback onTryRecipe;

  const ThreadRecipeAttachmentCard({
    super.key,
    required this.card,
    required this.tryCount,
    required this.onTryRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = card.coffeeDoseG > 0
        ? (card.totalWaterMl / card.coffeeDoseG).toStringAsFixed(1)
        : '16.0';
    final tempText = card.secondaryTempC != null
        ? '${card.primaryTempC}°C → ${card.secondaryTempC}°C'
        : '${card.primaryTempC}°C';
    final mins = card.targetDurationSec ~/ 60;
    final secs = (card.targetDurationSec % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryBrown.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  CupertinoIcons.flame_fill,
                  size: 15,
                  color: AppTheme.primaryBrown,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${card.brewerName} • ${card.method} • Rasio 1:$ratio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Pill(
                icon: Icons.scale_rounded,
                text: '${card.coffeeDoseG.toStringAsFixed(0)}g',
              ),
              _Pill(
                icon: CupertinoIcons.drop,
                text: '${card.totalWaterMl.toStringAsFixed(0)}ml',
              ),
              _Pill(
                icon: CupertinoIcons.thermometer,
                text: tempText,
              ),
              _Pill(
                icon: CupertinoIcons.timer,
                text: '$mins:$secs',
              ),
            ],
          ),
          if (card.stepsPreview.isNotEmpty) ...[
            const SizedBox(height: 9),
            ...card.stepsPreview.take(3).map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '${s.stepNumber}. ${s.title} — ${s.waterAddedMl.toStringAsFixed(0)}ml (${s.durationSec}s)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTryRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: const Icon(CupertinoIcons.play_arrow_solid, size: 14),
              label: Text(
                'Try This Recipe (Dipakai ${tryCount}x)',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryBrown),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
