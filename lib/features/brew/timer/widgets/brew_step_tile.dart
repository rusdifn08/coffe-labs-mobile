import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../../../../services/coffee_translator.dart';
import '../utils/brew_method_helper.dart';

class BrewStepTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> step;
  final bool isActive;
  final bool isDone;
  final int stepWater;
  final int stepDur;
  final int startSec;
  final int endSec;
  final int cumulativeTarget;
  final Color stepColor;
  final VoidCallback onTap;
  final String Function(int) formatTime;
  final BrewMethodFamily methodFamily;

  const BrewStepTile({
    super.key,
    required this.index,
    required this.step,
    required this.isActive,
    required this.isDone,
    required this.stepWater,
    required this.stepDur,
    required this.startSec,
    required this.endSec,
    required this.cumulativeTarget,
    required this.stepColor,
    required this.onTap,
    required this.formatTime,
    this.methodFamily = BrewMethodFamily.pourOver,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final rawTitle = step['title']?.toString() ?? 'Step ${index + 1}';
    final stepTitle = isEn ? CoffeeTranslator.translateStepTitle(rawTitle) : rawTitle;
    final rawInstruction = step['instruction']?.toString() ?? '';
    final instruction = isEn ? CoffeeTranslator.translateInstruction(rawInstruction) : rawInstruction;

    final actionLabel = BrewMethodHelper.getStepActionLabel(
      family: methodFamily,
      stepTitle: rawTitle,
      stepWater: stepWater,
      cumulativeTarget: cumulativeTarget,
      isEnglish: isEn,
    );

    final effectiveInstruction = instruction.isNotEmpty
        ? instruction
        : BrewMethodHelper.getFallbackInstruction(
            family: methodFamily,
            stepTitle: rawTitle,
            isEnglish: isEn,
          );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppTheme.accentAmber : AppTheme.primaryBrown.withValues(alpha: 0.1),
            width: isActive ? 1.8 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.green.shade600
                        : (isActive
                            ? AppTheme.accentAmber
                            : stepColor.withValues(alpha: 0.2)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(CupertinoIcons.check_mark, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : stepColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stepTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isActive ? 15 : 13.5,
                          color: isActive ? Colors.white : AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            methodFamily.icon,
                            size: 13,
                            color: isActive
                                ? AppTheme.accentAmber
                                : (stepWater > 0 ? Colors.blueAccent : methodFamily.primaryColor),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              actionLabel,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isActive ? Colors.white.withValues(alpha: 0.9) : AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatTime(stepDur),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isActive ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${formatTime(startSec)}-${formatTime(endSec)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? Colors.white70 : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (effectiveInstruction.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.black.withValues(alpha: 0.18)
                      : AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      methodFamily.icon,
                      size: 12,
                      color: isActive ? AppTheme.accentAmber : methodFamily.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        effectiveInstruction,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isActive ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF4A3E31),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
