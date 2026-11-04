import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/curated_roastery_bean.dart';
import '../../../theme/app_theme.dart';

/// Card component for an individual roastery bean within the Smart Brew catalog grid.
class RoasteryBeanCatalogCard extends StatelessWidget {
  final CuratedRoasteryBean bean;
  final bool isSelected;
  final ValueChanged<CuratedRoasteryBean> onSelect;

  const RoasteryBeanCatalogCard({
    super.key,
    required this.bean,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppTheme.accentAmber : AppTheme.borderWarm,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Package Image
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                  child: Image.asset(
                    bean.packageImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.bgCream,
                      child: const Icon(CupertinoIcons.drop_fill, color: AppTheme.primaryBrown, size: 36),
                    ),
                  ),
                ),
                // Badge Pill (Roaster Pick / Quality Tag)
                if (bean.badge != null && !bean.badge!.toLowerCase().contains('terjual'))
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppTheme.textDark.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        bean.badge!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                // Roastery Logo in Corner
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.borderWarm, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      bean.roasteryLogoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        CupertinoIcons.circle_fill,
                        size: 14,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Box
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Roastery / Brand Name
                Text(
                  bean.roasteryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightBrown,
                  ),
                ),
                const SizedBox(height: 2),

                // Product Title
                Text(
                  bean.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),

                // Tasting Notes / Flavors preview
                Text(
                  bean.tastingNotesList.take(2).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 6),

                // Roast & Process Badges (Coffee Attributes)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCream,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppTheme.borderWarm, width: 0.8),
                      ),
                      child: Text(
                        bean.roastProfileRaw,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.3), width: 0.8),
                        ),
                        child: Text(
                          bean.processRaw,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9E6B00),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Action Button: "Pilih Biji" / "Terpilih"
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? AppTheme.accentAmber : AppTheme.primaryBrown,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () => onSelect(bean),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? CupertinoIcons.checkmark_alt : CupertinoIcons.sparkles,
                          size: 13,
                          color: isSelected ? Colors.white : AppTheme.accentGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSelected ? 'Terpilih' : 'Pilih Biji',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}
