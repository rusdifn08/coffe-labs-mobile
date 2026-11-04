import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../../../../services/coffee_translator.dart';
import '../../brew/timer/utils/brew_method_helper.dart';

class RecipeStepsList extends StatelessWidget {
  final List<dynamic> steps;
  final int iceWeight;
  final int totalWater;
  final String description;
  final String Function(int) formatTime;
  final String? method;
  final String? category;

  const RecipeStepsList({
    super.key,
    required this.steps,
    required this.iceWeight,
    required this.totalWater,
    required this.description,
    required this.formatTime,
    this.method,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final family = BrewMethodHelper.detectFamily(method: method, category: category);
    int cumulativeWater = 0;
    int cumulativeTime = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description / Philosophy
        Text(
          isEn ? 'Brew Philosophy & Extraction Technique' : 'Filosofi & Teknik Ekstraksi',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          CoffeeTranslator.translatePhilosophy(description),
          style: const TextStyle(color: AppTheme.textDark, height: 1.6, fontSize: 14),
        ),
        const SizedBox(height: 28),

        // Pour Steps Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(family.icon, size: 20, color: family.primaryColor),
                const SizedBox(width: 8),
                Text(isEn ? 'Brewing Steps' : 'Tahapan Seduh', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: family.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isEn ? '${steps.length} Steps · ${family.label}' : '${steps.length} Tahap · ${family.label}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: family.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (iceWeight > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.lightBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.snow, color: Colors.blueAccent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Japanese Iced Preparation: Place ${iceWeight}g ice in server before hot water pour (${totalWater}g).'
                        : 'Persiapan Japanese Iced: Masukkan ${iceWeight}g es batu ke dalam server sebelum memulai tuangan air panas (${totalWater}g).',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                ),
              ],
            ),
          ),
        ...steps.asMap().entries.map((entry) {
          final int idx = entry.key;
          final Map<String, dynamic> s = Map<String, dynamic>.from(entry.value as Map);
          final int waterAdded = (s['waterAddedGrams'] ?? s['waterGrams'] ?? 0) as int;
          final int duration = (s['durationSeconds'] ?? s['timeSeconds'] ?? 30) as int;
          final int startSec = cumulativeTime;
          cumulativeTime += duration;
          final int endSec = cumulativeTime;
          cumulativeWater += waterAdded;
          final int targetScale = cumulativeWater;
          final String rawTitle = s['title']?.toString() ?? 'Step ${idx + 1}';
          final String actionLabel = BrewMethodHelper.getStepActionLabel(
            family: family,
            stepTitle: rawTitle,
            stepWater: waterAdded,
            cumulativeTarget: targetScale,
            isEnglish: isEn,
          );
          final String rawInstruction = (s['instruction'] ?? '').toString();
          final String effectiveInstruction = rawInstruction.isNotEmpty
              ? CoffeeTranslator.translateInstruction(rawInstruction)
              : BrewMethodHelper.getFallbackInstruction(
                  family: family,
                  stepTitle: rawTitle,
                  isEnglish: isEn,
                );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: family.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CoffeeTranslator.translateStepTitle(rawTitle),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(family.icon, size: 12, color: family.primaryColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  actionLabel,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: family.primaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCream,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${formatTime(startSec)}-${formatTime(endSec)}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (effectiveInstruction.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCream.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
                    ),
                    child: Text(
                      effectiveInstruction,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.45),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
