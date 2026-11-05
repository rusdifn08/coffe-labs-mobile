import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../../../../widgets/thermal_receipt_sheet.dart';

class RecipeDetailBottomBar extends StatelessWidget {
  final Map<String, dynamic> scaledRecipe;
  final int scaledCoffeeGrams;
  final int baseCoffeeGrams;
  final num coffeeWeight;
  final num totalWater;
  final VoidCallback onStartBrew;
  final VoidCallback? onOpenMasterclass;

  const RecipeDetailBottomBar({
    super.key,
    required this.scaledRecipe,
    required this.scaledCoffeeGrams,
    required this.baseCoffeeGrams,
    required this.coffeeWeight,
    required this.totalWater,
    required this.onStartBrew,
    this.onOpenMasterclass,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Print Receipt Button
          Container(
            height: 52,
            width: 46,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderWarm),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              tooltip: isEn ? 'Print Recipe Receipt' : 'Print Struk Resep Bluetooth',
              icon: const Icon(CupertinoIcons.printer_fill, color: AppTheme.primaryBrown, size: 20),
              onPressed: () => ThermalReceiptSheet.show(context, scaledRecipe),
            ),
          ),

          // Learning / Pre-Brew Masterclass Button with Learning Icon
          Container(
            height: 52,
            width: 52,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              tooltip: isEn ? 'Learning Video / Animation Masterclass' : 'Animasi Learning Seduh (Pre-Brew Masterclass)',
              icon: const Icon(CupertinoIcons.book_fill, color: AppTheme.primaryBrown, size: 22),
              onPressed: onOpenMasterclass,
            ),
          ),

          // Start Guided Brewing Button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onStartBrew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 20),
                label: Text(
                  scaledCoffeeGrams != baseCoffeeGrams
                      ? 'Start Brew (${coffeeWeight}g → ${totalWater}g)'
                      : 'Start Brew',
                  style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
