import 'package:flutter/material.dart';
import '../../../models/bean_recommendation_models.dart';
import '../../../theme/app_theme.dart';

/// Card for customizing flavor goal and dripper device when in Custom Bean mode.
class BeanCustomGoalCard extends StatelessWidget {
  final FlavorGoal selectedGoal;
  final BeanDripper selectedDripper;
  final ValueChanged<FlavorGoal> onGoalChanged;
  final ValueChanged<BeanDripper> onDripperChanged;

  const BeanCustomGoalCard({
    super.key,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. Target Rasa & Alat Seduh',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
          ),
          const SizedBox(height: 10),
          const Text(
            'Profil Rasa yang Diinginkan',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: FlavorGoal.values.map((g) {
              final isSel = selectedGoal == g;
              return ChoiceChip(
                label: Text(
                  g.label,
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
                  if (val) onGoalChanged(g);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BeanDripper>(
            initialValue: selectedDripper,
            decoration: InputDecoration(
              labelText: 'Dripper / Alat Seduh',
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: BeanDripper.values
                .map((d) => DropdownMenuItem(value: d, child: Text(d.label, style: const TextStyle(fontSize: 12))))
                .toList(),
            onChanged: (val) {
              if (val != null) onDripperChanged(val);
            },
          ),
        ],
      ),
    );
  }
}
