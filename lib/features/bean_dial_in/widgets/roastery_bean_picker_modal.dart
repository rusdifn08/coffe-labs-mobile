import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/curated_roastery_bean.dart';
import '../../../theme/app_theme.dart';
import 'roastery_bean_catalog_card.dart';

/// Curated Roastery Coffee Beans Catalog Modal for Smart Brew AI Dial-In.
/// Styled according to Coffee Labs warm specialty coffee palette (cream, espresso brown, amber).
class RoasteryBeanPickerModal extends StatefulWidget {
  final List<CuratedRoasteryBean> allBeans;
  final CuratedRoasteryBean? selectedBean;
  final ValueChanged<CuratedRoasteryBean> onBeanSelected;

  const RoasteryBeanPickerModal({
    super.key,
    required this.allBeans,
    required this.selectedBean,
    required this.onBeanSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required List<CuratedRoasteryBean> allBeans,
    required CuratedRoasteryBean? selectedBean,
    required ValueChanged<CuratedRoasteryBean> onBeanSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RoasteryBeanPickerModal(
        allBeans: allBeans,
        selectedBean: selectedBean,
        onBeanSelected: onBeanSelected,
      ),
    );
  }

  @override
  State<RoasteryBeanPickerModal> createState() => _RoasteryBeanPickerModalState();
}

class _RoasteryBeanPickerModalState extends State<RoasteryBeanPickerModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeCategory = 'Semua Biji';

  final List<String> _categories = [
    'Semua Biji',
    'Light Roast',
    'Medium Roast',
    'Washed',
    'Natural',
    'Anaerobic',
    '🏆 Pilihan Roaster',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CuratedRoasteryBean> _getFilteredBeans() {
    final query = _searchCtrl.text.toLowerCase().trim();
    return widget.allBeans.where((bean) {
      // Category filter
      if (_activeCategory == 'Light Roast' && !bean.roastProfileRaw.toLowerCase().contains('light')) {
        return false;
      }
      if (_activeCategory == 'Medium Roast' && !bean.roastProfileRaw.toLowerCase().contains('medium')) {
        return false;
      }
      if (_activeCategory == 'Washed' && !bean.processRaw.toLowerCase().contains('wash')) {
        return false;
      }
      if (_activeCategory == 'Natural' && !bean.processRaw.toLowerCase().contains('natural')) {
        return false;
      }
      if (_activeCategory == 'Anaerobic' &&
          !bean.processRaw.toLowerCase().contains('anaerob') &&
          !bean.processRaw.toLowerCase().contains('carbonic')) {
        return false;
      }
      if (_activeCategory == '🏆 Pilihan Roaster' && bean.badge == null) {
        return false;
      }

      // Query filter
      if (query.isNotEmpty) {
        final matchesName = bean.name.toLowerCase().contains(query);
        final matchesRoaster = bean.roasteryName.toLowerCase().contains(query);
        final matchesOrigin = bean.origin.toLowerCase().contains(query);
        final matchesNotes = bean.tastingNotes.toLowerCase().contains(query);
        if (!matchesName && !matchesRoaster && !matchesOrigin && !matchesNotes) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredBeans();

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppTheme.borderWarm,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.circle_grid_hex_fill,
                    size: 18,
                    color: AppTheme.primaryBrown,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Katalog Biji Kopi Roastery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Pilih biji roastery untuk dial-in seduh otomatis',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
              decoration: InputDecoration(
                hintText: 'Cari biji, roastery (MKND, Fugol, Mahugi), rasa...',
                hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: AppTheme.primaryBrown),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16, color: AppTheme.textMuted),
                        onPressed: () => setState(() => _searchCtrl.clear()),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                fillColor: AppTheme.surfaceWhite,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderWarm),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderWarm),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.accentAmber, width: 1.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Category Pill Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              itemCount: _categories.length,
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSel = _activeCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                        color: isSel ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: AppTheme.primaryBrown,
                    backgroundColor: AppTheme.surfaceWhite,
                    side: BorderSide(
                      color: isSel ? AppTheme.primaryBrown : AppTheme.borderWarm,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    showCheckmark: false,
                    onSelected: (val) {
                      if (val) setState(() => _activeCategory = cat);
                    },
                  ),
                );
              },
            ),
          ),

          // Options Count indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} biji kopi siap dial-in',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.sparkles, size: 12, color: AppTheme.accentAmber),
                    SizedBox(width: 4),
                    Text(
                      'Resep Presisi AI',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2-Column Product Grid
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.search, size: 42, color: AppTheme.textMuted),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada biji kopi untuk "${_searchCtrl.text}"',
                          style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final bean = filtered[index];
                      final isSelected = widget.selectedBean?.id == bean.id;
                      return RoasteryBeanCatalogCard(
                        bean: bean,
                        isSelected: isSelected,
                        onSelect: (selected) {
                          widget.onBeanSelected(selected);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
