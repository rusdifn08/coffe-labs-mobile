import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../models/recipe_step_draft.dart';

class EditorStepCard extends StatelessWidget {
  final int index;
  final RecipeStepDraft step;
  final int stepWater;
  final int currentTarget;
  final VoidCallback onRemove;

  const EditorStepCard({
    super.key,
    required this.index,
    required this.step,
    required this.stepWater,
    required this.currentTarget,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBrown,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    step.titleCtrl.text.isEmpty ? 'Tuangan ${index + 1}' : step.titleCtrl.text,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  if (stepWater > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Target: ${currentTarget}g',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 18),
                    onPressed: onRemove,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _inputField(
            step.titleCtrl,
            'Nama Tuangan (contoh: Bloom, Second Pour)',
            CupertinoIcons.pen,
          ),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  step.waterCtrl,
                  'Air Ditambah (+g)',
                  CupertinoIcons.drop_fill,
                  isNumber: true,
                  allowZero: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  step.durationCtrl,
                  'Durasi (detik)',
                  CupertinoIcons.timer,
                  isNumber: true,
                ),
              ),
            ],
          ),
          _inputField(
            step.instructionCtrl,
            'Instruksi Teknik (contoh: Tuang spiral lalu swirl 2x)',
            CupertinoIcons.info_circle,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool allowZero = false,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        validator: (value) {
          final trimmed = value?.trim() ?? '';
          if (!isRequired && trimmed.isEmpty) return null;
          if (trimmed.isEmpty) return 'Wajib diisi';
          if (isNumber) {
            final parsed = num.tryParse(trimmed);
            if (parsed == null) return 'Angka tidak valid';
            if (!allowZero && parsed <= 0) return 'Harus > 0';
            if (allowZero && parsed < 0) return 'Minimal 0';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: AppTheme.primaryBrown),
          filled: true,
          fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
          ),
        ),
      ),
    );
  }
}
