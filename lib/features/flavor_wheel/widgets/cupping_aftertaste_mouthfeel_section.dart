import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CuppingAftertasteMouthfeelSection extends StatelessWidget {
  final double aftertasteScore;
  final String effectiveAftertaste;
  final String selectedAftertasteDesc;
  final bool isCustomAftertaste;
  final List<String> aftertastePresets;
  final TextEditingController customAftertasteController;
  final ValueChanged<double> onAftertasteScoreChanged;
  final ValueChanged<String> onSelectAftertastePreset;

  final double mouthfeelScore;
  final String effectiveMouthfeel;
  final String selectedMouthfeelDesc;
  final bool isCustomMouthfeel;
  final List<String> mouthfeelPresets;
  final TextEditingController customMouthfeelController;
  final ValueChanged<double> onMouthfeelScoreChanged;
  final ValueChanged<String> onSelectMouthfeelPreset;

  const CuppingAftertasteMouthfeelSection({
    super.key,
    required this.aftertasteScore,
    required this.effectiveAftertaste,
    required this.selectedAftertasteDesc,
    required this.isCustomAftertaste,
    required this.aftertastePresets,
    required this.customAftertasteController,
    required this.onAftertasteScoreChanged,
    required this.onSelectAftertastePreset,
    required this.mouthfeelScore,
    required this.effectiveMouthfeel,
    required this.selectedMouthfeelDesc,
    required this.isCustomMouthfeel,
    required this.mouthfeelPresets,
    required this.customMouthfeelController,
    required this.onMouthfeelScoreChanged,
    required this.onSelectMouthfeelPreset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 3. AFTERTASTE
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.drop_triangle_fill, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '3. Aftertaste (Sensasi Akhir)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                  Text(
                    'Skor: ${aftertasteScore.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Karakter rasa yang tertinggal di langit-langit mulut setelah kopi ditelan:',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 8),

              _buildCuppingSlider(aftertasteScore, onAftertasteScoreChanged),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Text('Karakter Aftertaste: ', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  Text(effectiveAftertaste, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.accentAmber)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: aftertastePresets.map((desc) {
                  final isSelected = (selectedAftertasteDesc == desc && !isCustomAftertaste) || (desc == 'Custom...' && isCustomAftertaste);
                  return ChoiceChip(
                    label: Text(desc),
                    selected: isSelected,
                    selectedColor: AppTheme.accentAmber,
                    backgroundColor: AppTheme.bgCream,
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                    onSelected: (_) => onSelectAftertastePreset(desc),
                  );
                }).toList(),
              ),

              if (isCustomAftertaste) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: customAftertasteController,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan deskripsi aftertaste kustom (misal: Juicy apel malang, lingering chocolate)...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4. MOUTHFEEL
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.circle_bottomthird_split, color: Color(0xFF00ACC1), size: 20),
                      SizedBox(width: 8),
                      Text(
                        '4. Mouthfeel / Body (Tekstur)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                  Text(
                    'Skor: ${mouthfeelScore.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Sensasi bobot, kekentalan, dan kehalusan cairan kopi di lidah:',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 8),

              _buildCuppingSlider(mouthfeelScore, onMouthfeelScoreChanged),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Text('Tekstur Lidah: ', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  Text(effectiveMouthfeel, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF00ACC1))),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: mouthfeelPresets.map((desc) {
                  final isSelected = (selectedMouthfeelDesc == desc && !isCustomMouthfeel) || (desc == 'Custom...' && isCustomMouthfeel);
                  return ChoiceChip(
                    label: Text(desc),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00ACC1),
                    backgroundColor: AppTheme.bgCream,
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                    onSelected: (_) => onSelectMouthfeelPreset(desc),
                  );
                }).toList(),
              ),

              if (isCustomMouthfeel) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: customMouthfeelController,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan tekstur mouthfeel kustom (misal: Silky lembut seperti teh hijau, creamy mentega)...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCuppingSlider(double value, Function(double) onChanged) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: AppTheme.primaryBrown,
        inactiveTrackColor: AppTheme.primaryBrown.withValues(alpha: 0.15),
        thumbColor: AppTheme.primaryBrown,
        overlayColor: AppTheme.primaryBrown.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      child: Slider(
        value: value,
        min: 6.0,
        max: 10.0,
        divisions: 16,
        label: value.toStringAsFixed(2),
        onChanged: (v) => onChanged(double.parse(v.toStringAsFixed(2))),
      ),
    );
  }
}
