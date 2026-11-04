import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import '../../../../data/brew_visual_catalog.dart';
import '../../../../screens/brew_timer_screen.dart';
import '../../../../services/api_service.dart';
import '../../../../services/coffee_translator.dart';
import '../../../../services/language_service.dart';
import '../../../../shared/design_system/atoms/coffee_bean_icon.dart';
import '../../../../theme/app_theme.dart';
import '../../../../utils/barista_utils.dart';

/// Panel Inspeksi Barista Khusus Mode Landscape (Master-Detail).
/// Memberikan pengalaman cockpit barista profesional pada layar lebar / rotasi landscape.
class LandscapeRecipeInspector extends StatefulWidget {
  final dynamic rawRecipe;
  final bool isTrial;
  final VoidCallback onTrialLocked;
  final VoidCallback onOpenFullDetail;
  final VoidCallback? onClose;

  const LandscapeRecipeInspector({
    super.key,
    required this.rawRecipe,
    required this.isTrial,
    required this.onTrialLocked,
    required this.onOpenFullDetail,
    this.onClose,
  });

  @override
  State<LandscapeRecipeInspector> createState() => _LandscapeRecipeInspectorState();
}

class _LandscapeRecipeInspectorState extends State<LandscapeRecipeInspector> {
  num _currentCoffeeDose = 15;
  num _baseCoffeeDose = 15;
  num _baseTotalWater = 225;

  @override
  void initState() {
    super.initState();
    _initDose();
  }

  @override
  void didUpdateWidget(covariant LandscapeRecipeInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rawRecipe != widget.rawRecipe) {
      _initDose();
    }
  }

  void _initDose() {
    final recipe = widget.rawRecipe is Map ? ApiService.sanitizeRecipe(widget.rawRecipe) : <String, dynamic>{};
    _baseCoffeeDose = (recipe['coffeeWeightGrams'] as num?) ?? 15;
    _baseTotalWater = (recipe['totalWaterWeightGrams'] as num?) ?? 225;
    _currentCoffeeDose = _baseCoffeeDose;
  }

  void _adjustDose(num delta) {
    setState(() {
      final newDose = _currentCoffeeDose + delta;
      if (newDose >= 8 && newDose <= 40) {
        _currentCoffeeDose = newDose;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final recipe = widget.rawRecipe is Map ? ApiService.sanitizeRecipe(widget.rawRecipe) : <String, dynamic>{};
    if (recipe.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.doc_text_search, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                isEn ? 'Select a recipe to inspect' : 'Pilih resep untuk inspeksi langsung',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final String rawTitle = recipe['title'] as String? ?? 'Resep Kopi';
    final String title = isEn ? CoffeeTranslator.translateTitle(rawTitle) : rawTitle;
    final String rawAuthor = recipe['author'] as String? ?? 'Barista';
    final String authorName = BaristaUtils.cleanName(rawAuthor);
    final String countryCode = BaristaUtils.countryCode(rawAuthor);
    final String category = recipe['category'] as String? ?? 'Pour Over';
    final String rawDescription = recipe['description'] as String? ?? '';
    final String description = isEn ? CoffeeTranslator.translatePhilosophy(rawDescription) : rawDescription;
    final String shortGrind = BaristaUtils.shortGrindLabel(recipe['grindSize']?.toString());
    final int waterTemp = (recipe['waterTemperatureCelsius'] as num?)?.toInt() ?? 92;
    final int pourCount = BrewVisualCatalog.countPours(recipe);
    final rawNotes = (recipe['tastingNotes'] ?? '').toString().split(',');
    final noteVisuals = rawNotes
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .take(5)
        .map((n) => BrewVisualCatalog.matchNote(n))
        .toList();

    // Scale air berdasarkan rasio
    final scaleRatio = _baseCoffeeDose > 0 ? (_currentCoffeeDose / _baseCoffeeDose) : 1.0;
    final scaledWater = (_baseTotalWater * scaleRatio).round();
    final brewRatio = _currentCoffeeDose > 0 ? (scaledWater / _currentCoffeeDose).toStringAsFixed(1) : '15.0';

    final steps = (recipe['steps'] as List?)?.map((s) => s.toString()).toList() ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Barista & Quick Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBrown.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: AppTheme.dividerColor, width: 1)),
            ),
            child: Row(
              children: [
                BaristaAvatar(
                  imageUrl: BaristaUtils.imageUrlFromRecipe(recipe),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              authorName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (countryCode.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            Flag.fromString(countryCode, height: 10, width: 14),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        category,
                        style: const TextStyle(fontSize: 11, color: AppTheme.primaryBrown, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.sparkles, size: 11, color: AppTheme.primaryBrown),
                      const SizedBox(width: 3),
                      Text(
                        '${pourCount}x Pour',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                      ),
                    ],
                  ),
                ),
                if (widget.onClose != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark, size: 16),
                    onPressed: widget.onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Tutup Panel',
                  ),
                ],
              ],
            ),
          ),

          // Konten Tengah Scrollable (Parameter & Langkah)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Judul Resep & Filosofi
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),

                // Matrix Parameter Seduh (Kopi, Air, Rasio, Grind, Suhu)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEDE5DE)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildParamChip(
                            icon: const CoffeeBeanIcon(size: 13, color: AppTheme.primaryBrown),
                            label: 'Kopi',
                            value: '${_currentCoffeeDose}g',
                          ),
                          _buildParamChip(
                            icon: const Icon(CupertinoIcons.drop_fill, size: 13, color: Color(0xFF1976D2)),
                            label: 'Air',
                            value: '${scaledWater}ml',
                          ),
                          _buildParamChip(
                            icon: const Icon(CupertinoIcons.divide, size: 13, color: Colors.deepPurple),
                            label: 'Rasio',
                            value: '1:$brewRatio',
                          ),
                          _buildParamChip(
                            icon: const Icon(CupertinoIcons.circle_grid_hex, size: 13, color: AppTheme.primaryBrown),
                            label: 'Gilingan',
                            value: shortGrind,
                          ),
                          _buildParamChip(
                            icon: const Icon(CupertinoIcons.thermometer, size: 13, color: Colors.redAccent),
                            label: 'Suhu',
                            value: '$waterTemp°C',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Auto-scale dose slider baris mikro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Auto-Scale Dosis: ', style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                          InkWell(
                            onTap: () => _adjustDose(-1),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Text('−1g', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('${_currentCoffeeDose}g', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryBrown)),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _adjustDose(1),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Text('+1g', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          if (_currentCoffeeDose != _baseCoffeeDose) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => setState(() => _currentCoffeeDose = _baseCoffeeDose),
                              child: const Text('Reset', style: TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Sensory Flavor Radar Bubbles
                if (noteVisuals.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(CupertinoIcons.heart_fill, size: 11, color: Colors.pinkAccent),
                      const SizedBox(width: 5),
                      Text(
                        isEn ? 'Sensory Tasting Notes' : 'Karakter Rasa Sensorik',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: noteVisuals.map((nv) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: nv.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: nv.color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(nv.emoji, style: const TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(nv.label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: nv.color)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Timeline Tuangan / Steps Preview
                if (steps.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(CupertinoIcons.timer, size: 11, color: AppTheme.primaryBrown),
                      const SizedBox(width: 5),
                      Text(
                        isEn ? 'Pour Timeline Breakdown' : 'Alur Panduan Tuangan',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...steps.take(4).map((step) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBrown,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.25),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

          // Tombol Aksi Bawah: Mulai Seduh & Buka Detail Lengkap
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: OutlinedButton(
                    onPressed: widget.onOpenFullDetail,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBrown,
                      side: const BorderSide(color: AppTheme.primaryBrown),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isEn ? 'Full Recipe' : 'Detail Resep',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.isTrial) {
                        widget.onTrialLocked();
                        return;
                      }
                      // Clone recipe dengan scaled dose jika di-scale
                      final scaledRecipe = Map<String, dynamic>.from(recipe);
                      scaledRecipe['coffeeWeightGrams'] = _currentCoffeeDose;
                      scaledRecipe['totalWaterWeightGrams'] = scaledWater;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BrewTimerScreen(recipeData: scaledRecipe),
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.play_arrow_solid, size: 14, color: Colors.white),
                    label: Text(
                      isEn ? 'Start Brewing' : 'Mulai Seduh Sekarang',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamChip({
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ],
    );
  }
}
