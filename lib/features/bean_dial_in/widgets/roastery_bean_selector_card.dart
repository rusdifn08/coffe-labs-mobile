import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/curated_roastery_bean.dart';
import '../../../theme/app_theme.dart';
import 'roastery_bean_picker_modal.dart';

/// Card for selecting real commercial coffee beans from top Indonesian & Global roasteries,
/// featuring authentic product packaging imagery and roastery logos.
class RoasteryBeanSelectorCard extends StatelessWidget {
  final List<CuratedRoasteryBean> allBeans;
  final CuratedRoasteryBean selectedBean;
  final ValueChanged<CuratedRoasteryBean> onBeanSelected;
  final VoidCallback onSwitchToCustom;

  const RoasteryBeanSelectorCard({
    super.key,
    required this.allBeans,
    required this.selectedBean,
    required this.onBeanSelected,
    required this.onSwitchToCustom,
  });

  @override
  Widget build(BuildContext context) {
    final featuredBeans = allBeans.take(14).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.checkmark_seal_fill, size: 16, color: AppTheme.accentGold),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Pilih Biji Kopi Komersil',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                    ),
                    Text(
                      'Foto kemasan & logo resmi dari 50 micro-roastery',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  RoasteryBeanPickerModal.show(
                    context: context,
                    allBeans: allBeans,
                    selectedBean: selectedBean,
                    onBeanSelected: onBeanSelected,
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor: AppTheme.bgCream,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Katalog', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown)),
                    Icon(CupertinoIcons.chevron_right, size: 12, color: AppTheme.primaryBrown),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active Selected Bean Highlight with Packaging Image & Logo
          _buildActiveBeanCard(context),

          const SizedBox(height: 14),
          const Text(
            'Koleksi Populer Roastery (Tap untuk Pilih)',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF6B5F54)),
          ),
          const SizedBox(height: 8),

          // Horizontal Carousel of Featured Beans with Real Packaging Photos
          SizedBox(
            height: 136,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: featuredBeans.length,
              itemBuilder: (context, idx) {
                final bean = featuredBeans[idx];
                final isSel = selectedBean.id == bean.id;
                return GestureDetector(
                  onTap: () => onBeanSelected(bean),
                  child: Container(
                    width: 115,
                    margin: const EdgeInsets.only(right: 9),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFAF3EC) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSel ? AppTheme.accentGold : Colors.grey.shade200,
                        width: isSel ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Pouch thumbnail
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: SizedBox(
                            height: 64,
                            child: Image.asset(
                              bean.packageImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppTheme.bgCream,
                                alignment: Alignment.center,
                                child: const Icon(CupertinoIcons.drop_fill, size: 20, color: AppTheme.primaryBrown),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bean.roasteryName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.brown.shade700),
                              ),
                              Text(
                                bean.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    bean.roastProfileRaw,
                                    style: TextStyle(fontSize: 8.5, color: Colors.grey.shade600),
                                  ),
                                  const Spacer(),
                                  if (isSel)
                                    const Icon(CupertinoIcons.checkmark_circle_fill, size: 12, color: AppTheme.accentGold),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Bottom Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  RoasteryBeanPickerModal.show(
                    context: context,
                    allBeans: allBeans,
                    selectedBean: selectedBean,
                    onBeanSelected: onBeanSelected,
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.square_grid_2x2, size: 13, color: AppTheme.primaryBrown),
                      SizedBox(width: 4),
                      Text('Buka Katalog 230+ Biji Kopi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryBrown)),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: onSwitchToCustom,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.pencil, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Biji Kustom', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBeanCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real Product Package Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 58,
              height: 68,
              child: Image.asset(
                selectedBean.packageImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.primaryBrown,
                  alignment: Alignment.center,
                  child: const Icon(CupertinoIcons.drop_fill, color: AppTheme.accentGold, size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Roastery Mini Logo
                    ClipOval(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: Image.asset(
                          selectedBean.roasteryLogoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(CupertinoIcons.circle_fill, size: 10, color: AppTheme.primaryBrown),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        selectedBean.roasteryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (selectedBean.badge != null && !selectedBean.badge!.toLowerCase().contains('terjual'))
                            ? selectedBean.badge!
                            : (selectedBean.originalPackage.isNotEmpty ? selectedBean.originalPackage.toUpperCase() : '100 G'),
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  selectedBean.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${selectedBean.origin} • ${selectedBean.roastProfileRaw} • ${selectedBean.processRaw}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF5D534A)),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: selectedBean.tastingNotesList.take(3).map((note) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.brown.shade100),
                      ),
                      child: Text(
                        note,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
