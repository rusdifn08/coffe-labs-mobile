import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/bean_ai_customization_models.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../theme/app_theme.dart';

/// Scientific Barista Extraction Dashboard
/// Renders calculated TDS, Extraction Yield (EY), flow rate, and Golden Cup status.
class BeanAiExtractionMetricsCard extends StatelessWidget {
  final RecommendedBrewRecipe recipe;
  final BeanRoastAge roastAge;
  final WaterProfile waterProfile;

  const BeanAiExtractionMetricsCard({
    super.key,
    required this.recipe,
    required this.roastAge,
    required this.waterProfile,
  });

  @override
  Widget build(BuildContext context) {
    final science = AiExtractionScience.calculate(
      coffeeDose: recipe.coffeeDose,
      totalWater: recipe.totalWater,
      waterTemp: recipe.waterTemp,
      grindMicrons: recipe.grindMicrons,
      roast: recipe.roastLevel,
      roastAge: roastAge,
      water: waterProfile,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Science
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.chart_bar_alt_fill, size: 16, color: Colors.teal),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prediksi Hasil Ekstraksi & Sains Seduh 🔬',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.textDark),
                    ),
                    Text(
                      'Kalkulasi kelarutan senyawa rasa berbasis SCA Golden Cup',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4-Grid Key Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Estimasi TDS',
                  value: '${science.estimatedTds}%',
                  sub: 'Ideal: 1.25–1.45%',
                  color: Colors.teal.shade800,
                  bgColor: Colors.teal.shade50,
                  icon: CupertinoIcons.drop_fill,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Extraction Yield',
                  value: '${science.estimatedExtractionYield}%',
                  sub: 'Target: 18–22%',
                  color: const Color(0xFF007A87),
                  bgColor: const Color(0xFFE6F7F9),
                  icon: CupertinoIcons.speedometer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Target Flow Rate',
                  value: '~${science.targetFlowRate} ml/s',
                  sub: 'Aliran laminer stabil',
                  color: Colors.indigo.shade800,
                  bgColor: Colors.indigo.shade50,
                  icon: CupertinoIcons.timer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Efisiensi Mineral',
                  value: science.waterEfficiency.split('(').first.trim(),
                  sub: science.waterEfficiency.contains('(') ? science.waterEfficiency.split('(').last.replaceAll(')', '') : 'Buffer optimal',
                  color: Colors.amber.shade900,
                  bgColor: Colors.amber.shade50,
                  icon: CupertinoIcons.sparkles,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_seal_fill, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Status Ekstraksi: ${science.goldenCupStatus}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Scientific Rationale
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CupertinoIcons.lightbulb, size: 14, color: AppTheme.primaryBrown),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    recipe.scientificReason,
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF4A3E31), height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String sub,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 1),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
