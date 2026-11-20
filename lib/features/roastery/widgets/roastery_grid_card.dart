import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/optimized_coffee_image.dart';
import '../../../models/roastery.dart';
import '../../../theme/app_theme.dart';

class RoasteryGridCard extends StatelessWidget {
  final Roastery roastery;
  final VoidCallback onTap;

  const RoasteryGridCard({
    super.key,
    required this.roastery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: roastery.isVerifiedBusiness
                    ? const Color(0xFFE7D49E)
                    : const Color(0xFFEFECE6),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3ECE2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${roastery.effectiveLineupCount} Varian',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (roastery.isVerifiedBusiness) ...[
                          const Icon(
                            Icons.verified_rounded,
                            size: 13,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 2),
                        ],
                        const Icon(Icons.star_rounded,
                            size: 13.5, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          roastery.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEDE4D7)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: OptimizedCoffeeImage(
                      imageUrlOrAsset: roastery.imageUrl,
                      width: 38,
                      height: 38,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  roastery.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.location_solid,
                      size: 11,
                      color: AppTheme.accentAmber,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        roastery.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roastery.isVerifiedBusiness
                        ? const Color(0xFFFDF6E2)
                        : const Color(0xFFF7F4EF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    roastery.salesHighlight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C3A21),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Lihat Lineup',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(CupertinoIcons.chevron_right,
                          size: 11.5, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
