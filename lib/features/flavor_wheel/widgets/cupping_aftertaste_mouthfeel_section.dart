import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Compact Aftertaste & Mouthfeel/Body cards using clean popup selectors
/// for multi-select sensory descriptors (no messy inline chip walls).
class CuppingAftertasteMouthfeelSection extends StatelessWidget {
  final double aftertasteScore;
  final Set<String> selectedAftertaste;
  final ValueChanged<double> onAftertasteScoreChanged;
  final VoidCallback onOpenAftertastePopup;
  final ValueChanged<String> onRemoveAftertaste;

  final double mouthfeelScore;
  final Set<String> selectedMouthfeel;
  final ValueChanged<double> onMouthfeelScoreChanged;
  final VoidCallback onOpenMouthfeelPopup;
  final ValueChanged<String> onRemoveMouthfeel;

  const CuppingAftertasteMouthfeelSection({
    super.key,
    required this.aftertasteScore,
    required this.selectedAftertaste,
    required this.onAftertasteScoreChanged,
    required this.onOpenAftertastePopup,
    required this.onRemoveAftertaste,
    required this.mouthfeelScore,
    required this.selectedMouthfeel,
    required this.onMouthfeelScoreChanged,
    required this.onOpenMouthfeelPopup,
    required this.onRemoveMouthfeel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAttributeCard(
          icon: CupertinoIcons.drop_triangle_fill,
          iconColor: const Color(0xFFD97706),
          title: 'Aftertaste (Sensasi Akhir)',
          description: 'Kualitas & panjang rasa tertinggal setelah ditelan.',
          score: aftertasteScore,
          onScoreChanged: onAftertasteScoreChanged,
          selectorLabel: 'Karakter Aftertaste',
          emptyHint: 'Pilih karakter aftertaste lewat pop-up...',
          selectedItems: selectedAftertaste,
          onOpenPopup: onOpenAftertastePopup,
          onRemoveItem: onRemoveAftertaste,
        ),
        const SizedBox(height: 12),
        _buildAttributeCard(
          icon: CupertinoIcons.circle_bottomthird_split,
          iconColor: const Color(0xFF0F766E),
          title: 'Mouthfeel / Body (Tekstur)',
          description: 'Sensasi bobot, kekentalan, dan kehalusan di lidah.',
          score: mouthfeelScore,
          onScoreChanged: onMouthfeelScoreChanged,
          selectorLabel: 'Tekstur Mouthfeel',
          emptyHint: 'Pilih tekstur body lewat pop-up...',
          selectedItems: selectedMouthfeel,
          onOpenPopup: onOpenMouthfeelPopup,
          onRemoveItem: onRemoveMouthfeel,
        ),
      ],
    );
  }

  Widget _buildAttributeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required double score,
    required ValueChanged<double> onScoreChanged,
    required String selectorLabel,
    required String emptyHint,
    required Set<String> selectedItems,
    required VoidCallback onOpenPopup,
    required ValueChanged<String> onRemoveItem,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  score.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryBrown,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: const TextStyle(fontSize: 11.2, color: AppTheme.textMuted),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryBrown,
              inactiveTrackColor: AppTheme.primaryBrown.withValues(alpha: 0.14),
              thumbColor: AppTheme.primaryBrown,
              overlayColor: AppTheme.primaryBrown.withValues(alpha: 0.18),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.5),
            ),
            child: Slider(
              value: score,
              min: 6.0,
              max: 10.0,
              divisions: 16,
              label: score.toStringAsFixed(2),
              onChanged: (v) =>
                  onScoreChanged(double.parse(v.toStringAsFixed(2))),
            ),
          ),

          // Tappable Compact Popup Selector
          InkWell(
            onTap: onOpenPopup,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedItems.isNotEmpty
                      ? iconColor.withValues(alpha: 0.35)
                      : AppTheme.borderWarm,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectorLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedItems.isEmpty
                                ? 'Pilih'
                                : 'Ubah (${selectedItems.length})',
                            style: TextStyle(
                              fontSize: 10.8,
                              fontWeight: FontWeight.w800,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 12,
                            color: iconColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (selectedItems.isEmpty)
                    Text(
                      emptyHint,
                      style: const TextStyle(
                        fontSize: 11.2,
                        color: AppTheme.textMuted,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: selectedItems.map((item) {
                        return InkWell(
                          onTap: () => onRemoveItem(item),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: iconColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    item,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10.8,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  CupertinoIcons.xmark,
                                  size: 10.5,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
