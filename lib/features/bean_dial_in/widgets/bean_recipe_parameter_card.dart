import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../theme/app_theme.dart';

class BeanRecipeParameterCard extends StatelessWidget {
  final RecommendedBrewRecipe recipe;

  const BeanRecipeParameterCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.orange, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Parameter Resep Rekomendasi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rasio 1:${recipe.brewRatio.toStringAsFixed(1)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBrown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildParamTile('Air Panas', '${recipe.totalWater.round()}g', CupertinoIcons.drop_fill, Colors.blue),
              _buildParamTile('Suhu Air', '${recipe.waterTemp}°C', CupertinoIcons.flame_fill, Colors.deepOrange),
              _buildParamTile('Gilingan', '${recipe.grindMicrons} µm', CupertinoIcons.circle_grid_hex_fill, Colors.purple),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.info_circle_fill, size: 14, color: AppTheme.primaryBrown),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recipe.grindClickLabel,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            recipe.scientificReason,
            style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildParamTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
