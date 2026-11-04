import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../theme/app_theme.dart';
import '../../brew/widgets/brew_radar_chart.dart';

/// Card showing the 5-axis sensory polygon (Acidity, Sweetness, Body, Bitterness, Clarity)
/// and real cup predicted tasting notes.
class BeanSensoryRadarCard extends StatelessWidget {
  final RecommendedBrewRecipe recipe;

  const BeanSensoryRadarCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.chart_pie_fill, size: 16, color: Colors.deepOrangeAccent),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prediksi Sensorik Radar Cangkir 📊',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.textDark),
                    ),
                    Text(
                      'Evaluasi cita rasa 5-dimensi berdasarkan profil kimia seduh',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: BrewRadarChart(
              acidity: recipe.expectedAcidity,
              sweetness: recipe.expectedSweetness,
              body: recipe.expectedBody,
              bitterness: recipe.expectedBitterness,
              clarity: recipe.expectedClarity,
              size: 210,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Catatan Rasa Alami (Tasting Notes Terdeteksi):',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: recipe.predictedTastingNotes.map((note) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Text(
                  note,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.brown.shade800),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
