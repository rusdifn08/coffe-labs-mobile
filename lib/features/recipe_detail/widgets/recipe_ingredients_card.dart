import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../../brew/timer/utils/brew_method_helper.dart';

class RecipeIngredientsCard extends StatelessWidget {
  final List<dynamic>? ingredients;
  final BrewMethodFamily family;
  final num coffeeWeight;
  final int totalWater;
  final int iceWeight;
  final String title;

  const RecipeIngredientsCard({
    super.key,
    required this.ingredients,
    required this.family,
    required this.coffeeWeight,
    required this.totalWater,
    required this.iceWeight,
    required this.title,
  });

  IconData _getIconForRole(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'coffee_beans':
        return Icons.coffee_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'milk':
        return Icons.local_cafe_rounded;
      case 'syrup':
        return Icons.invert_colors_rounded;
      case 'chocolate':
        return Icons.cookie_rounded;
      case 'ice':
        return CupertinoIcons.snow;
      case 'icecream':
        return Icons.icecream_rounded;
      case 'citrus':
        return Icons.eco_rounded;
      case 'topping':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color _getColorForRole(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'coffee_beans':
        return AppTheme.primaryBrown;
      case 'water':
        return Colors.blueAccent;
      case 'milk':
        return Colors.deepOrangeAccent;
      case 'syrup':
        return AppTheme.accentAmber;
      case 'chocolate':
        return const Color(0xFF5D4037);
      case 'ice':
        return Colors.cyan;
      case 'icecream':
        return Colors.pinkAccent;
      case 'citrus':
        return Colors.green;
      case 'topping':
        return Colors.purple;
      default:
        return AppTheme.primaryBrown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final items = (ingredients != null && ingredients!.isNotEmpty)
        ? ingredients!
        : <dynamic>[];

    if (items.isEmpty) return const SizedBox.shrink();

    final isEspresso = family == BrewMethodFamily.espresso;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isEspresso ? CupertinoIcons.square_list_fill : Icons.restaurant_menu_rounded,
                    size: 20,
                    color: isEspresso ? Colors.amber[800] : AppTheme.primaryBrown,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? 'Ingredients & Formula' : 'Komposisi & Bahan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isEspresso ? Colors.amber[800]! : AppTheme.primaryBrown).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isEn ? '${items.length} Items' : '${items.length} Bahan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isEspresso ? Colors.amber[900] : AppTheme.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isEn
                ? 'Specialty barista recipe measurements for authentic taste balance.'
                : 'Formula takaran presisi barista specialty untuk keseimbangan citarasa asli.',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
          ),
          const SizedBox(height: 14),

          // Ingredient Cards (Two-tier stacked layout: zero text cramping or character wrapping)
          ...items.map((item) {
            final Map<String, dynamic> ing = item is Map
                ? Map<String, dynamic>.from(item)
                : {'name': item.toString(), 'amount': '', 'role': 'Bahan', 'icon': 'coffee_beans'};

            final name = ing['name']?.toString() ?? 'Bahan';
            final amount = ing['amount']?.toString() ?? '';
            final role = ing['role']?.toString() ?? 'Komposisi';
            final iconKey = ing['icon']?.toString() ?? 'coffee_beans';

            final iconData = _getIconForRole(iconKey);
            final roleColor = _getColorForRole(iconKey);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgCream.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon + Full-Width Name + Role Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(iconData, size: 17, color: roleColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                            height: 1.25,
                          ),
                        ),
                      ),
                      if (role.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: roleColor.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Bottom Tier: Full-Width Takaran Formula Box
                  if (amount.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.slider_horizontal_below_rectangle,
                            size: 13,
                            color: AppTheme.primaryBrown,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isEn ? 'Measurement: ' : 'Takaran: ',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              amount,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Barista Specs Footer Pill
          if (isEspresso) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.sparkles, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEn
                          ? 'Espresso Standard: 9-Bar Extraction · 1:2 Ratio · Milk 60–65°C Glossy Microfoam'
                          : 'Standar Espresso: Ekstraksi 9-Bar · Rasio 1:2 · Susu 60–65°C Glossy Microfoam',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
