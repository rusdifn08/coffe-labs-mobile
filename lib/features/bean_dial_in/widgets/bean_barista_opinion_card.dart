import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../models/curated_roastery_bean.dart';
import '../../../theme/app_theme.dart';

/// Card presenting Coffe Labs Barista Intelligence, brew strategy rationale,
/// flavor target tuning, and temperature-based sensory tasting notes.
class BeanBaristaOpinionCard extends StatelessWidget {
  final CuratedRoasteryBean selectedBean;
  final FlavorGoal selectedGoal;
  final BeanDripper selectedDripper;
  final ValueChanged<FlavorGoal> onGoalChanged;
  final ValueChanged<BeanDripper> onDripperChanged;

  const BeanBaristaOpinionCard({
    super.key,
    required this.selectedBean,
    required this.selectedGoal,
    required this.selectedDripper,
    required this.onGoalChanged,
    required this.onDripperChanged,
  });

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
          // Header Barista Opinion
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.sparkles, size: 16, color: Colors.deepOrange),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Rekomendasi Barista Coffe Labs',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                    ),
                    Text(
                      'Saran racikan terbaik untuk memaksimalkan potensi biji ini',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Enaknya Dibuat Seperti Apa (Barista Recommendation Box)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.lightbulb_fill, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Enaknya Dibuat Seperti Apa?',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6B4800)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Alat: ${selectedBean.recommendedDripper.label.split('(').first.trim()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  selectedBean.baristaOpinion,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF4A3E31),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Target Karakter Rasa
          const Text(
            'Target Karakter Rasa yang Diinginkan',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: FlavorGoal.values.map((goal) {
              final isSel = selectedGoal == goal;
              return ChoiceChip(
                label: Text(
                  goal.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel ? Colors.white : AppTheme.textDark,
                  ),
                ),
                selected: isSel,
                selectedColor: AppTheme.primaryBrown,
                backgroundColor: AppTheme.bgCream,
                onSelected: (val) {
                  if (val) onGoalChanged(goal);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Alat Seduh yang Digunakan
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alat Seduh (Dripper)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    Text('Bisa disesuaikan dengan alat di rumah Anda', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                  ],
                ),
              ),
              DropdownButton<BeanDripper>(
                value: selectedDripper,
                underline: const SizedBox(),
                items: BeanDripper.values.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text(d.label.split('(').first.trim(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onDripperChanged(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Evolusi Suhu & Tasting Notes (Sensory Journey)
          const Text(
            'Evolusi Rasa & Tasting Notes saat Diminum',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          _buildTempRow(
            icon: CupertinoIcons.flame_fill,
            color: Colors.red.shade700,
            bgColor: Colors.red.shade50,
            title: 'Suhu Panas (>65°C)',
            notes: selectedBean.tempNotesHot,
          ),
          const SizedBox(height: 4),
          _buildTempRow(
            icon: CupertinoIcons.sparkles,
            color: Colors.amber.shade800,
            bgColor: Colors.amber.shade50,
            title: 'Suhu Hangat (50–60°C) • Puncak Manis',
            notes: selectedBean.tempNotesWarm,
          ),
          const SizedBox(height: 4),
          _buildTempRow(
            icon: CupertinoIcons.snow,
            color: Colors.blue.shade700,
            bgColor: Colors.blue.shade50,
            title: 'Suhu Sejuk (<40°C) • Aftertaste',
            notes: selectedBean.tempNotesCool,
          ),
        ],
      ),
    );
  }

  Widget _buildTempRow({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String notes,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  notes,
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade800, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
