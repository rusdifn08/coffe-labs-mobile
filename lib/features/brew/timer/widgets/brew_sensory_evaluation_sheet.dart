import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/language_service.dart';
import '../../../../services/coffee_translator.dart';
import '../../../../services/api_service.dart';
import '../../../../widgets/thermal_receipt_sheet.dart';
import '../../../../screens/brew_journal_screen.dart';
import '../../../gamification/services/gamification_service.dart';
import '../../widgets/brew_flow_curve_chart.dart';
import '../../widgets/brew_radar_chart.dart';

class BrewSensoryEvaluationSheet {
  static void show(BuildContext context, Map<String, dynamic> recipe) {
    double acidity = 3.5;
    double sweetness = 3.8;
    double bitterness = 2.0;
    double body = 3.2;
    double clarity = 4.0;
    double overallScore = 4.5;
    int tabIndex = 0; // 0 = Grafik Hasil Seduh, 1 = Penilaian Slider

    final isEn = LanguageService.isEnglish;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          String status = isEn ? 'Harmonious & Balanced 👍' : 'Harmonis & Nikmat 👍';
          String badge = 'SWEET SPOT';
          IconData icon = CupertinoIcons.checkmark_circle_fill;
          Color color = Colors.green.shade700;
          Color bgColor = Colors.green.withValues(alpha: 0.08);
          String advice = isEn
              ? '✨ Sweetness and acidity balance is spot-on!'
              : '✨ Keseimbangan rasa manis dan keasaman sangat ideal!';

          if (bitterness >= 4.0 || (bitterness - sweetness >= 1.5)) {
            status = isEn ? 'Over-Extracted (Too Bitter & Astringent)' : 'Over-Extracted (Terlalu Pahit & Sepat)';
            badge = 'OVER-EXTRACTED';
            icon = CupertinoIcons.exclamationmark_triangle_fill;
            color = Colors.redAccent;
            bgColor = Colors.red.withValues(alpha: 0.08);
            advice = isEn
                ? '💡 Coarsen grind 1-2 clicks or lower water temp -2°C.'
                : '💡 Kasarkan gilingan 1-2 klik atau turunkan suhu air -2°C.';
          } else if (acidity >= 4.0 && sweetness <= 2.5) {
            status = isEn ? 'Under-Extracted (Sharp Acidity / Hollow)' : 'Under-Extracted (Asam Tajam / Tipis)';
            badge = 'UNDER-EXTRACTED';
            icon = CupertinoIcons.bolt_fill;
            color = Colors.orange.shade800;
            bgColor = Colors.orange.withValues(alpha: 0.08);
            advice = isEn
                ? '💡 Fine grind 1-2 clicks or raise water temp +2°C.'
                : '💡 Haluskan gilingan 1-2 klik atau naikkan suhu air +2°C.';
          } else if (body <= 1.5) {
            status = isEn ? 'Low Body (Watery Brew)' : 'Under-Body (Seduhan Terlalu Encer)';
            badge = 'LOW BODY';
            icon = CupertinoIcons.drop;
            color = Colors.blueGrey;
            bgColor = Colors.blueGrey.withValues(alpha: 0.08);
            advice = isEn
                ? '💡 Extend bloom by 10-15s or adjust pour agitation.'
                : '💡 Perpanjang waktu blooming 10-15s atau percepat tuang pour.';
          } else if (sweetness >= 3.5 && bitterness <= 2.5 && acidity >= 2.5 && acidity <= 3.8) {
            status = isEn ? 'Sweet Spot! Balanced Extraction 🎯' : 'Sweet Spot! Ekstraksi Seimbang 🎯';
            badge = 'SWEET SPOT';
            icon = CupertinoIcons.checkmark_circle_fill;
            color = Colors.green.shade700;
            bgColor = Colors.green.withValues(alpha: 0.08);
            advice = isEn
                ? '✨ Sweetness and acidity balance is spot-on!'
                : '✨ Keseimbangan rasa manis dan keasaman sangat ideal!';
          }

          final displayRecipeTitle = isEn
              ? CoffeeTranslator.translateTitle(recipe['title']?.toString() ?? 'Brewed Coffee')
              : (recipe['title']?.toString() ?? 'Seduhan Kopi');

          final recipeSteps = recipe['steps'] as List<dynamic>? ?? [];
          final totalWater = (recipe['totalWaterWeightGrams'] as num?)?.toInt() ?? 225;
          final totalTime = (recipe['totalTimeSeconds'] as num?)?.toInt() ?? 150;

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(CupertinoIcons.flame_fill, color: AppTheme.primaryBrown, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn ? 'Brew Result & Evaluation' : 'Hasil & Evaluasi Seduhan',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                            ),
                            Text(
                              displayRecipeTitle,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.star_fill, size: 12, color: AppTheme.accentAmber),
                            const SizedBox(width: 4),
                            Text(
                              overallScore.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Segmented Switcher: Grafik Seduh vs Slider
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.bgCream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => tabIndex = 0),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: tabIndex == 0 ? AppTheme.primaryBrown : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                isEn ? '📊 Brew Charts' : '📊 Grafik Hasil Seduh',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: tabIndex == 0 ? Colors.white : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => tabIndex = 1),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: tabIndex == 1 ? AppTheme.primaryBrown : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                isEn ? '🎛️ Sensory Sliders' : '🎛️ Penilaian Rasa',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: tabIndex == 1 ? Colors.white : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tab View 0: Visual Charts (Radar & Flow Curve)
                  if (tabIndex == 0) ...[
                    Center(
                      child: BrewRadarChart(
                        acidity: acidity,
                        sweetness: sweetness,
                        body: body,
                        bitterness: bitterness,
                        clarity: clarity,
                        size: 200,
                      ),
                    ),
                    const SizedBox(height: 10),
                    BrewFlowCurveChart(
                      steps: recipeSteps,
                      totalWaterGrams: totalWater,
                      totalTimeSeconds: totalTime,
                      height: 110,
                    ),
                  ] else ...[
                    // Tab View 1: Sliders
                    _buildSlider(
                      label: isEn ? 'Acidity' : 'Keasaman (Acidity)',
                      value: acidity,
                      activeColor: Colors.amber.shade700,
                      onChanged: (v) => setDialogState(() => acidity = v),
                    ),
                    _buildSlider(
                      label: isEn ? 'Sweetness' : 'Kemanisan (Sweetness)',
                      value: sweetness,
                      activeColor: Colors.deepOrangeAccent,
                      onChanged: (v) => setDialogState(() => sweetness = v),
                    ),
                    _buildSlider(
                      label: isEn ? 'Bitterness' : 'Kepahitan (Bitterness)',
                      value: bitterness,
                      activeColor: Colors.brown.shade700,
                      onChanged: (v) => setDialogState(() => bitterness = v),
                    ),
                    _buildSlider(
                      label: isEn ? 'Body & Texture' : 'Ketebalan (Body)',
                      value: body,
                      activeColor: Colors.teal.shade700,
                      onChanged: (v) => setDialogState(() => body = v),
                    ),
                    _buildSlider(
                      label: isEn ? 'Cleanliness / Clarity' : 'Kejernihan (Clarity)',
                      value: clarity,
                      activeColor: Colors.blue.shade700,
                      onChanged: (v) => setDialogState(() => clarity = v),
                    ),
                    _buildSlider(
                      label: isEn ? 'Overall Score' : 'Skor Keseluruhan',
                      value: overallScore,
                      activeColor: AppTheme.primaryBrown,
                      onChanged: (v) => setDialogState(() => overallScore = v),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(icon, size: 13, color: color),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          advice,
                          style: const TextStyle(fontSize: 10.5, color: AppTheme.textDark, height: 1.25),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.25)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(isEn ? 'Skip' : 'Lewati', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
                        ),
                        child: IconButton(
                          tooltip: isEn ? 'Print Bluetooth Receipt' : 'Print Struk Bluetooth',
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          constraints: const BoxConstraints(),
                          icon: const Icon(CupertinoIcons.printer_fill, size: 18, color: AppTheme.primaryBrown),
                          onPressed: () {
                            ThermalReceiptSheet.show(
                              context,
                              recipe,
                              tastingNotes: [
                                status,
                                '${isEn ? "Acidity" : "Asam"}: ${acidity.toStringAsFixed(1)} | ${isEn ? "Sweetness" : "Manis"}: ${sweetness.toStringAsFixed(1)} | ${isEn ? "Bitterness" : "Pahit"}: ${bitterness.toStringAsFixed(1)} | Body: ${body.toStringAsFixed(1)}',
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 1,
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await ApiService.addJournalEntry({
                              'recipeId': recipe['id'],
                              'recipeTitle': recipe['title'],
                              'author': recipe['author'],
                              'authorAvatarUrl': recipe['authorAvatarUrl'],
                              'authorImageUrl': recipe['coverImageUrl'],
                              'grindNote': '${recipe['grindSize'] ?? ''} • $badge',
                              'rating': overallScore,
                              'notes': '$status | ${isEn ? "Acidity" : "Asam"}: ${acidity.toStringAsFixed(1)}, ${isEn ? "Sweetness" : "Manis"}: ${sweetness.toStringAsFixed(1)}, ${isEn ? "Bitterness" : "Pahit"}: ${bitterness.toStringAsFixed(1)}, Body: ${body.toStringAsFixed(1)}, Clarity: ${clarity.toStringAsFixed(1)}. $advice',
                            });
                            await GamificationService.instance.recordCuppingCompleted();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEn ? 'Saved to Brew Journal.' : 'Tersimpan di Jurnal Seduh.'),
                                action: SnackBarAction(
                                  label: isEn ? 'View' : 'Buka',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(CupertinoIcons.bookmark_fill, size: 13),
                          label: Text(isEn ? 'Save to Journal' : 'Simpan ke Jurnal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildSlider({
    required String label,
    required double value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: activeColor,
                inactiveTrackColor: activeColor.withValues(alpha: 0.18),
                thumbColor: activeColor,
                overlayColor: activeColor.withValues(alpha: 0.15),
              ),
              child: Slider(
                value: value,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 26,
            child: Text(
              value.toStringAsFixed(1),
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: activeColor),
            ),
          ),
        ],
      ),
    );
  }
}
