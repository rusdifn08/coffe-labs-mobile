import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/optimized_coffee_image.dart';
import '../../../../theme/app_theme.dart';
import '../../models/beans_radar_models.dart';

class CoffeeRadarPlaceCard extends StatelessWidget {
  final RadarPlaceCard place;
  final bool isSelected;
  final VoidCallback onTapCard;
  final VoidCallback onTapRoute;
  final VoidCallback? onTapLineup;

  const CoffeeRadarPlaceCard({
    super.key,
    required this.place,
    required this.isSelected,
    required this.onTapCard,
    required this.onTapRoute,
    this.onTapLineup,
  });

  @override
  Widget build(BuildContext context) {
    final openStatus = place.openStatus;
    final statusColor = !openStatus.isOpenNow
        ? const Color(0xFFDC2626)
        : (openStatus.isClosingSoon
            ? const Color(0xFFD97706)
            : const Color(0xFF16A34A));

    return RepaintBoundary(
      child: Material(
        color: isSelected ? const Color(0xFFFFFBF4) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTapCard,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryBrown
                    : AppTheme.primaryBrown.withValues(alpha: 0.14),
                width: isSelected ? 1.6 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 86,
                        height: 86,
                        color: AppTheme.bgCream,
                        child: OptimizedCoffeeImage(
                          imageUrlOrAsset: place.thumbnailUrl ?? '',
                          width: 86,
                          height: 86,
                          fit: BoxFit.cover,
                          errorWidget: Center(
                            child: Icon(
                              place.category.iconData,
                              size: 32,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  place.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              if (place.isVerifiedPartner) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 15,
                                  color: AppTheme.primaryBrown,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (place.rating > 0)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.star_fill,
                                      size: 12,
                                      color: Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${place.rating.toStringAsFixed(1)} ${place.formattedReviewsCount}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  place.etaDisplayLabel,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryBrown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  '${openStatus.statusLabelId} • ${place.category.fullLabel}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            place.fullAddress.isNotEmpty
                                ? place.fullAddress
                                : '${place.districtKecamatan}, ${place.cityKabupaten}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (place.radarKind == 'ROASTERY_AND_CAFE')
                      const _MiniTagChip(label: 'Cafe & Penjual Beans'),
                    if (place.hasManualBrewV60)
                      const _MiniTagChip(label: 'Manual Brew V60'),
                    if (place.sellsRoastBeans && place.radarKind != 'ROASTERY_AND_CAFE')
                      const _MiniTagChip(label: 'Jual Biji Kopi'),
                    if (place.featuredBeanSummary != null &&
                        place.featuredBeanSummary!.trim().isNotEmpty)
                      _MiniTagChip(label: place.featuredBeanSummary!),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTapRoute,
                        icon: const Icon(Icons.alt_route_rounded, size: 14),
                        label: const Text(
                          'Lihat Rute',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBrown,
                          side: BorderSide(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.35),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onTapLineup ?? onTapCard,
                        icon: Icon(
                          onTapLineup != null
                              ? CupertinoIcons.bag_fill
                              : CupertinoIcons.info_circle,
                          size: 14,
                        ),
                        label: Text(
                          onTapLineup != null ? 'Lihat Lineup' : 'Detail Toko',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBrown,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniTagChip extends StatelessWidget {
  final String label;

  const _MiniTagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryBrown,
        ),
      ),
    );
  }
}
