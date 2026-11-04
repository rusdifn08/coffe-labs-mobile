import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../../../../theme/app_theme.dart';

class EditorGrinderSection extends StatelessWidget {
  final GrinderModel selectedGrinder;
  final String selectedGrindPreset;
  final int currentClicks;
  final List<Map<String, String>> grindPresets;
  final TextEditingController descController;
  final VoidCallback onOpenGrinderPicker;
  final ValueChanged<String> onPresetSelected;
  final ValueChanged<int> onClicksChanged;

  const EditorGrinderSection({
    super.key,
    required this.selectedGrinder,
    required this.selectedGrindPreset,
    required this.currentClicks,
    required this.grindPresets,
    required this.descController,
    required this.onOpenGrinderPicker,
    required this.onPresetSelected,
    required this.onClicksChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            '5. Pemilihan Grinder & Ukuran Gilingan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Grinder yang Digunakan:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),

              // VISUAL SELECTED GRINDER CARD
              GestureDetector(
                onTap: onOpenGrinderPicker,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          selectedGrinder.imagePath,
                          width: 58,
                          height: 58,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: selectedGrinder.isElectric ? AppTheme.accentAmber : AppTheme.primaryBrown,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    selectedGrinder.isElectric ? 'ELEKTRIK' : 'MANUAL',
                                    style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${selectedGrinder.minClicks} - ${selectedGrinder.maxClicks} Klik',
                                  style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedGrinder.name,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                            ),
                            Text(
                              selectedGrinder.typeDescription,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(CupertinoIcons.square_grid_2x2, size: 14),
                        label: const Text('Pilih', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: onOpenGrinderPicker,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Presets
              const Text(
                'Preset Kehalusan:',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: grindPresets.map((g) {
                  final label = g['label']!;
                  final selected = selectedGrindPreset == label;
                  return ChoiceChip(
                    label: Text(label, style: const TextStyle(fontSize: 11)),
                    selected: selected,
                    selectedColor: AppTheme.accentAmber,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => onPresetSelected(label),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // INTERACTIVE STEPPER & CLICK DISPLAY
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Minus Button
                        Material(
                          color: currentClicks > selectedGrinder.minClicks
                              ? AppTheme.primaryBrown
                              : Colors.grey.shade400,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: currentClicks > selectedGrinder.minClicks
                                ? () => onClicksChanged(currentClicks - 1)
                                : null,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(CupertinoIcons.minus, color: Colors.white, size: 20),
                            ),
                          ),
                        ),

                        // Center Info
                        Column(
                          children: [
                            Text(
                              '$currentClicks Klik',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                            Text(
                              '${selectedGrinder.estimateMicrons(currentClicks)} • $selectedGrindPreset',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                            ),
                            Text(
                              selectedGrinder.name,
                              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                            ),
                          ],
                        ),

                        // Plus Button
                        Material(
                          color: currentClicks < selectedGrinder.maxClicks
                              ? AppTheme.primaryBrown
                              : Colors.grey.shade400,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: currentClicks < selectedGrinder.maxClicks
                                ? () => onClicksChanged(currentClicks + 1)
                                : null,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(CupertinoIcons.plus, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Continuous Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.primaryBrown,
                        inactiveTrackColor: Colors.grey.shade300,
                        thumbColor: AppTheme.accentAmber,
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: currentClicks.toDouble().clamp(
                              selectedGrinder.minClicks.toDouble(),
                              selectedGrinder.maxClicks.toDouble(),
                            ),
                        min: selectedGrinder.minClicks.toDouble(),
                        max: selectedGrinder.maxClicks.toDouble(),
                        divisions: selectedGrinder.maxClicks - selectedGrinder.minClicks,
                        onChanged: (val) => onClicksChanged(val.round()),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Catatan Filosofi & Teknik Seduh (Opsional)',
                  labelStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(CupertinoIcons.text_quote, size: 18, color: AppTheme.primaryBrown),
                  filled: true,
                  fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
