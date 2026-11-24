import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/roastery_catalog.dart';
import '../../../models/roastery.dart';
import '../../../theme/app_theme.dart';

/// Strip jaminan mutu specialty coffee + rail horizontal Roastery Resmi Pilihan
/// bergaya Tokopedia Official Store / Shopee Mall (tanpa voucher & tanpa flash deals).
class MarketplaceOfficialRoasteryRail extends StatelessWidget {
  final String? selectedRoasteryId;
  final ValueChanged<Roastery> onRoasterySelected;
  final VoidCallback onSeeAllRoasteries;

  const MarketplaceOfficialRoasteryRail({
    super.key,
    required this.selectedRoasteryId,
    required this.onRoasterySelected,
    required this.onSeeAllRoasteries,
  });

  @override
  Widget build(BuildContext context) {
    final featured = RoasteryCatalog.list.take(10).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Trust & Quality Guarantee Strip (Profesional & Transparan)
        Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF5EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE7D9C6)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TrustPill(
                icon: CupertinoIcons.checkmark_seal_fill,
                label: 'Roastery Resmi',
              ),
              _TrustPill(
                icon: CupertinoIcons.flame_fill,
                label: 'Fresh < 48 Jam',
              ),
              _TrustPill(
                icon: CupertinoIcons.qrcode,
                label: 'QRIS 0% Admin',
              ),
            ],
          ),
        ),

        // 2. Official Roastery Rail Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                size: 16,
                color: AppTheme.primaryBrown,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Roastery Official Pilihan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSeeAllRoasteries,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 13,
                      color: AppTheme.primaryBrown,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3. Horizontal Sleek Official Roastery Cards
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final r = featured[index];
              final isSelected = r.id == selectedRoasteryId;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onRoasterySelected(r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 172,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryBrown.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBrown
                          : const Color(0xFFEDE4D7),
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.bgCream,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: const Color(0xFFE7D9C6)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          r.name.isNotEmpty ? r.name[0].toUpperCase() : 'R',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? AppTheme.primaryBrown
                                    : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 12,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  r.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '· ${r.lineups.length} kopi',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ),
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
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TrustPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: AppTheme.primaryBrown),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
