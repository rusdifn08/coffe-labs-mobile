import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../brew_methods/models/brew_method_item.dart';
import '../../../services/main_navigation_service.dart';
import '../../../theme/app_theme.dart';

/// Horizontal Brew Methods showcase section on HomeScreen.
/// Displays methods ordered by user's brewing frequency.
class HomeBrewMethodsSection extends StatelessWidget {
  final bool isEn;
  final VoidCallback onSeeAll;
  final List<BrewMethodItem>? methods;

  const HomeBrewMethodsSection({
    super.key,
    required this.isEn,
    required this.onSeeAll,
    this.methods,
  });

  void _openMethodFilter(BrewMethodItem item) {
    MainNavigationService.openRecipesWithMethod(
      item.filterKey,
      methodTitle: item.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewMethods = methods ?? BrewMethodItem.allMethods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with "See All"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                isEn ? 'Brew Methods' : 'Metode Seduh',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(
                    isEn ? 'See All' : 'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBrown.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 13,
                    color: AppTheme.primaryBrown.withValues(alpha: 0.85),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal list of method cards ordered by user frequency
        SizedBox(
          height: 112,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: previewMethods.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final item = previewMethods[index];
              return Container(
                width: 82,
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _openMethodFilter(item),
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.05),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Center(
                              child: Image.asset(
                                item.imageAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.coffee_rounded,
                                  size: 32,
                                  color: Colors.brown.shade300,
                                ),
                              ),
                            ),
                            if (item.userBrewCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white, width: 1.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${item.userBrewCount}x',
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isEn ? item.title : item.titleId,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2B2824),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
