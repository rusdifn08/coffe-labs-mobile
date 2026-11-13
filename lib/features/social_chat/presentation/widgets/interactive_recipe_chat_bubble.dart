import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/chat_protocol.dart';

class InteractiveRecipeChatBubble extends StatelessWidget {
  final V60RecipeCardAttachment card;
  final bool isMine;

  const InteractiveRecipeChatBubble({
    super.key,
    required this.card,
    required this.isMine,
  });

  String _formatDuration(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _openInBrewTimer(BuildContext context) async {
    Map<String, dynamic>? matched;
    try {
      final recipes = await ApiService.getRecipes();
      for (final raw in recipes) {
        if (raw is Map) {
          final m = Map<String, dynamic>.from(raw);
          if (m['id']?.toString() == card.recipeId ||
              m['title']?.toString().toLowerCase() ==
                  card.title.toLowerCase()) {
            matched = m;
            break;
          }
        }
      }
    } catch (_) {}

    final payload = matched ?? _buildSyntheticRecipeMap();
    if (context.mounted) {
      context.push(AppRoutes.brewTimer, extra: payload);
    }
  }

  Map<String, dynamic> _buildSyntheticRecipeMap() {
    final dose = card.doseGrams.round().clamp(5, 100);
    final totalWater = card.waterMl.round().clamp(30, 1500);
    final totalSec = card.targetDurationSec.clamp(45, 600);
    final bloomWater = (dose * 3).clamp(20, (totalWater * 0.3).round());
    final restWater = ((totalWater - bloomWater) / 2).round();
    final finalWater = totalWater - bloomWater - restWater;
    final stepSec = (totalSec / 3).round();

    return {
      'id': int.tryParse(card.recipeId) ?? 9001,
      'title': card.title,
      'author': 'Social Coffee Share',
      'method': card.brewerName,
      'coffeeWeightGrams': dose,
      'totalWaterWeightGrams': totalWater,
      'waterTempCelsius': card.tempC,
      'totalTimeSeconds': totalSec,
      'tastingNotes': 'Dibagikan lewat Social Coffee Chat',
      'steps': [
        {
          'title': 'Bloom',
          'instruction': 'Tuang perlahan merata untuk membasahi seluruh bubuk kopi.',
          'waterAddedGrams': bloomWater,
          'durationSeconds': stepSec,
        },
        {
          'title': 'Main Pour',
          'instruction': 'Tuang melingkar stabil menjaga ketinggian air dripper.',
          'waterAddedGrams': restWater,
          'durationSeconds': stepSec,
        },
        {
          'title': 'Drawdown',
          'instruction': 'Tuangan akhir & tunggu air tiris sempurna.',
          'waterAddedGrams': finalWater,
          'durationSeconds': totalSec - (stepSec * 2),
        },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final ratio = card.doseGrams > 0
        ? (card.waterMl / card.doseGrams).toStringAsFixed(1)
        : '15.0';

    return Container(
      constraints: const BoxConstraints(maxWidth: 270),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMine ? AppTheme.bgCream : AppTheme.bgCream.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.48),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.drop_fill,
                  color: AppTheme.primaryBrown,
                  size: 13,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  card.brewerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '1:$ratio',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            card.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _SpecChip(
                icon: Icons.scale_rounded,
                label: '${card.doseGrams.toStringAsFixed(0)}g kopi',
              ),
              _SpecChip(
                icon: CupertinoIcons.drop,
                label: '${card.waterMl.toStringAsFixed(0)}ml air',
              ),
              _SpecChip(
                icon: CupertinoIcons.thermometer,
                label: '${card.tempC}°C',
              ),
              _SpecChip(
                icon: CupertinoIcons.timer,
                label: _formatDuration(card.targetDurationSec),
              ),
            ],
          ),
          if (card.stepsPreview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              card.stepsPreview.take(2).join(' • '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openInBrewTimer(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(CupertinoIcons.play_arrow_solid, size: 14),
              label: const Text(
                'Buka di Brewing Timer',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppTheme.lightBrown),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
