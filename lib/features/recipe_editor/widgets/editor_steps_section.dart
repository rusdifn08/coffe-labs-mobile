import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../models/recipe_step_draft.dart';
import 'editor_step_card.dart';

class EditorStepsSection extends StatelessWidget {
  final List<RecipeStepDraft> steps;
  final bool autoSyncWater;
  final VoidCallback onAddStep;
  final ValueChanged<int> onRemoveStep;
  final ValueChanged<bool?> onAutoSyncChanged;

  const EditorStepsSection({
    super.key,
    required this.steps,
    required this.autoSyncWater,
    required this.onAddStep,
    required this.onRemoveStep,
    required this.onAutoSyncChanged,
  });

  @override
  Widget build(BuildContext context) {
    int runningWater = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                '6. Tahapan Tuangan (Steps)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: onAddStep,
              icon: const Icon(CupertinoIcons.add_circled_solid, color: AppTheme.primaryBrown),
              label: const Text(
                'Tambah Step',
                style: TextStyle(color: AppTheme.primaryBrown, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Checkbox(
                value: autoSyncWater,
                activeColor: AppTheme.primaryBrown,
                onChanged: onAutoSyncChanged,
              ),
              const Expanded(
                child: Text(
                  'Otomatis jumlahkan air step ke total air',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          final stepWater = int.tryParse(step.waterCtrl.text.trim()) ?? 0;
          runningWater += stepWater;
          final currentTarget = runningWater;

          return EditorStepCard(
            index: index,
            step: step,
            stepWater: stepWater,
            currentTarget: currentTarget,
            onRemove: () => onRemoveStep(index),
          );
        }),
      ],
    );
  }
}
