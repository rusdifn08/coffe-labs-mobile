import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/api_service.dart';
import '../../../../services/language_service.dart';
import '../../../../services/coffee_translator.dart';
import '../../../../utils/barista_utils.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../../../../shared/design_system/atoms/coffee_bean_icon.dart';
import '../../../../screens/brew_timer_screen.dart';

class RecipeFeedGridCard extends StatelessWidget {
  final dynamic rawRecipe;
  final int index;
  final bool isTrial;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onBaristaTap;
  final VoidCallback onTrialLocked;

  const RecipeFeedGridCard({
    super.key,
    required this.rawRecipe,
    required this.index,
    required this.isTrial,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
    required this.onBaristaTap,
    required this.onTrialLocked,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final recipe = rawRecipe is Map ? ApiService.sanitizeRecipe(rawRecipe) : <String, dynamic>{};
    final bool isLocked = isTrial && index >= 10;
    String rawTitle = recipe['title'] as String;
    String title = isEn ? CoffeeTranslator.translateTitle(rawTitle) : rawTitle;
    String rawAuthor = recipe['author'] as String;
    String authorName = BaristaUtils.cleanName(rawAuthor);
    String countryCode = BaristaUtils.countryCode(rawAuthor);
    String category = recipe['category'] as String;
    String rawDescription = recipe['description'] as String;
    String description = isEn ? CoffeeTranslator.translatePhilosophy(rawDescription) : rawDescription;
    String shortGrind = BaristaUtils.shortGrindLabel(recipe['grindSize']?.toString());
    num coffeeWeight = (recipe['coffeeWeightGrams'] as num?) ?? 15;
    num totalWater = (recipe['totalWaterWeightGrams'] as num?) ?? 225;
    int iceWeight = (recipe['iceWeightGrams'] as num?)?.toInt() ?? 0;
    int pourCount = BrewVisualCatalog.countPours(recipe);
    final rawNotes = (recipe['tastingNotes'] ?? '').toString().split(',');
    final noteVisuals = rawNotes
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .take(3)
        .map((n) => BrewVisualCatalog.matchNote(n))
        .toList();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: isLocked ? onTrialLocked : onLongPress,
      onTap: isLocked ? onTrialLocked : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLocked ? const Color(0xFFE2E2E2) : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentGold
                : (isLocked ? Colors.grey.shade400 : AppTheme.primaryBrown.withValues(alpha: 0.1)),
            width: isSelected ? 2.0 : (isLocked ? 1.2 : 1.0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : (isLocked
                  ? null
                  : [
                      BoxShadow(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: isLocked ? onTrialLocked : onBaristaTap,
                    child: BaristaAvatar(
                      imageUrl: BaristaUtils.imageUrlFromRecipe(recipe),
                      radius: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLocked) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(CupertinoIcons.lock_fill, size: 7.5, color: Colors.white),
                                  const SizedBox(width: 2),
                                  Text(
                                    isEn ? 'Locked' : 'Terkunci',
                                    style: const TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLocked ? Colors.grey.shade300 : const Color(0xFFF6EFEA),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isLocked ? Colors.grey.shade400 : AppTheme.primaryBrown.withValues(alpha: 0.22),
                                width: 0.7,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CoffeeBeanIcon(
                                  size: 8.5,
                                  color: isLocked ? Colors.grey.shade600 : AppTheme.primaryBrown,
                                ),
                                const SizedBox(width: 2.5),
                                Text(
                                  '${coffeeWeight}g',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: isLocked ? Colors.grey.shade700 : AppTheme.primaryBrown,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLocked ? Colors.grey.shade300 : const Color(0xFFE8F3FA),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isLocked ? Colors.grey.shade400 : Colors.blue.withValues(alpha: 0.25),
                                width: 0.7,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  iceWeight > 0 ? CupertinoIcons.snow : CupertinoIcons.drop_fill,
                                  size: 8.5,
                                  color: isLocked ? Colors.grey.shade600 : const Color(0xFF1976D2),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  iceWeight > 0 ? '${totalWater + iceWeight}g' : '${totalWater}ml',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: isLocked ? Colors.grey.shade700 : const Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isLocked ? onTrialLocked : onBaristaTap,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isLocked ? Colors.grey.shade700 : AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (countryCode.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Flag.fromString(countryCode, height: 10, width: 14),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 13.5,
                            height: 1.2,
                            color: isLocked ? Colors.grey.shade800 : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (noteVisuals.isNotEmpty) ...[
                            ...noteVisuals.take(2).map((nv) {
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isLocked
                                      ? Colors.grey.shade300
                                      : nv.color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isLocked
                                        ? Colors.grey.shade400
                                        : nv.color.withValues(alpha: 0.25),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(nv.emoji, style: const TextStyle(fontSize: 11)),
                              );
                            }),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLocked
                                  ? Colors.grey.shade300
                                  : AppTheme.primaryBrown.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${pourCount}x Pour',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isLocked ? Colors.grey.shade700 : AppTheme.primaryBrown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isLocked ? Colors.grey.shade600 : AppTheme.textMuted,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      category
                          .replaceAll('V60 Pour Over', 'V60')
                          .replaceAll('Japanese Iced', 'Japanese'),
                      style: TextStyle(
                        color: isLocked ? Colors.grey.shade600 : AppTheme.textMuted,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.circle_grid_hex,
                          size: 10,
                          color: isLocked ? Colors.grey.shade600 : AppTheme.primaryBrown,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            shortGrind,
                            style: TextStyle(
                              color: isLocked ? Colors.grey.shade700 : AppTheme.primaryBrown,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLocked
                      ? onTrialLocked
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BrewTimerScreen(recipeData: recipe),
                            ),
                          );
                        },
                  icon: Icon(
                    isLocked ? CupertinoIcons.lock_fill : CupertinoIcons.play_arrow_solid,
                    size: 12,
                    color: Colors.white,
                  ),
                  label: Text(
                    isLocked ? (isEn ? 'Locked' : 'Terkunci') : 'Brew',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked ? Colors.grey.shade600 : AppTheme.primaryBrown,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
