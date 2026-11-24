import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Step 1 of SCA Cupping Flow: Clean, compact Sample Identity card.
/// - NO horizontal scrolling for varieties or processes
/// - Multi-select popup pickers for Varieties (supports 1 or more!) & Post-Harvest Process
/// - Zero-overflow Roast Level dropdown (`isExpanded: true`)
class CuppingCoffeeInfoSection extends StatelessWidget {
  final TextEditingController beanNameController;
  final TextEditingController originController;
  final TextEditingController cupperController;
  final Set<String> selectedVarieties;
  final Set<String> selectedProcesses;
  final String selectedRoast;
  final List<String> roastPresets;
  final VoidCallback onOpenBeanCatalog;
  final VoidCallback onOpenVarietyPopup;
  final ValueChanged<String> onRemoveVariety;
  final VoidCallback onOpenProcessPopup;
  final ValueChanged<String> onRemoveProcess;
  final ValueChanged<String> onRoastChanged;

  const CuppingCoffeeInfoSection({
    super.key,
    required this.beanNameController,
    required this.originController,
    required this.cupperController,
    required this.selectedVarieties,
    required this.selectedProcesses,
    required this.selectedRoast,
    required this.roastPresets,
    required this.onOpenBeanCatalog,
    required this.onOpenVarietyPopup,
    required this.onRemoveVariety,
    required this.onOpenProcessPopup,
    required this.onRemoveProcess,
    required this.onRoastChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header Row (Zero Overflow)
          Row(
            children: [
              const Icon(
                Icons.coffee_rounded,
                color: AppTheme.primaryBrown,
                size: 18,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Identitas Sampel Kopi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: onOpenBeanCatalog,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.search,
                        size: 12,
                        color: AppTheme.primaryBrown,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Katalog',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nama Kopi
          TextField(
            controller: beanNameController,
            style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
            decoration: InputDecoration(
              labelText: 'Nama Kopi / Lot / Single Origin',
              labelStyle:
                  const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              prefixIcon: const Icon(
                Icons.coffee_rounded,
                size: 17,
                color: AppTheme.primaryBrown,
              ),
              filled: true,
              fillColor: AppTheme.bgCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),

          // Asal Daerah
          TextField(
            controller: originController,
            style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
            decoration: InputDecoration(
              labelText: 'Asal Daerah / Negara',
              labelStyle:
                  const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              prefixIcon: const Icon(
                CupertinoIcons.globe,
                size: 17,
                color: AppTheme.primaryBrown,
              ),
              filled: true,
              fillColor: AppTheme.bgCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),

          // Varietas Kopi (Popup Multi-Select — NO horizontal scroll!)
          _buildPopupSelectorField(
            label: 'Varietas Kopi (Multi-Pilih)',
            emptyPlaceholder: 'Ketuk untuk pilih 1 atau lebih varietas...',
            icon: Icons.eco_rounded,
            accentColor: const Color(0xFF2E7D32),
            selectedItems: selectedVarieties,
            onTapPopup: onOpenVarietyPopup,
            onRemoveItem: onRemoveVariety,
          ),
          const SizedBox(height: 10),

          // Proses Pasca-Panen (Popup Multi-Select — NO horizontal scroll!)
          _buildPopupSelectorField(
            label: 'Proses Pasca-Panen',
            emptyPlaceholder: 'Ketuk untuk pilih proses (Washed, Natural, dll)...',
            icon: Icons.science_rounded,
            accentColor: const Color(0xFFC2410C),
            selectedItems: selectedProcesses,
            onTapPopup: onOpenProcessPopup,
            onRemoveItem: onRemoveProcess,
          ),
          const SizedBox(height: 12),

          // Tingkat Sangrai & Nama Cupper (Zero Overflow with isExpanded: true)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('roast_dropdown_$selectedRoast'),
                  isExpanded: true,
                  initialValue: roastPresets.contains(selectedRoast)
                      ? selectedRoast
                      : 'Light-Medium',
                  decoration: InputDecoration(
                    labelText: 'Roast Level',
                    labelStyle:
                        const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: roastPresets.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(
                        r,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.textDark,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) onRoastChanged(v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: cupperController,
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.textDark),
                  decoration: InputDecoration(
                    labelText: 'Nama Cupper',
                    labelStyle:
                        const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.bgCream,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopupSelectorField({
    required String label,
    required String emptyPlaceholder,
    required IconData icon,
    required Color accentColor,
    required Set<String> selectedItems,
    required VoidCallback onTapPopup,
    required ValueChanged<String> onRemoveItem,
  }) {
    return InkWell(
      onTap: onTapPopup,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selectedItems.isNotEmpty
                ? accentColor.withValues(alpha: 0.35)
                : AppTheme.borderWarm,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: accentColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderWarm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedItems.isEmpty
                            ? 'Pilih'
                            : 'Ubah (${selectedItems.length})',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 11,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (selectedItems.isEmpty)
              Text(
                emptyPlaceholder,
                style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
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
                        color: accentColor,
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
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            CupertinoIcons.xmark,
                            size: 11,
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
    );
  }
}
