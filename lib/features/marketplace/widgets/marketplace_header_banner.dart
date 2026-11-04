import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class MarketplaceHeaderBanner extends StatelessWidget {
  final bool isEn;

  const MarketplaceHeaderBanner({super.key, required this.isEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBrown, Color(0xFF2C1810)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isEn ? 'SPECIALTY ROASTERY DIRECT' : 'LANGSUNG DARI ROASTERY',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.accentGold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn ? 'Fresh Beans from 50+ Top Roasters' : 'Biji Segar dari 50+ Roastery Nasional',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEn
                      ? 'Roasted to order. Use voucher COFFEEFIRST for 15% discount.'
                      : 'Disangrai segar tiap batch. Gunakan voucher COFFEEFIRST untuk diskon 15%.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.flame_fill, color: AppTheme.accentGold, size: 26),
          ),
        ],
      ),
    );
  }
}
