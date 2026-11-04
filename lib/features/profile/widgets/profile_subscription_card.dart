import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/subscription_plan.dart';
import '../../../theme/app_theme.dart';
import 'subscription_checkout_sheet.dart';

class ProfileSubscriptionCard extends StatelessWidget {
  final SubscriptionPlan currentPlan;
  final bool isTrial;
  final VoidCallback onRefresh;

  const ProfileSubscriptionCard({
    super.key,
    required this.currentPlan,
    required this.isTrial,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTrial && currentPlan.tier != SubscriptionTier.trial) {
      return _buildActivePlanCard(context);
    }
    return _buildUpgradeCard(context);
  }

  Widget _buildUpgradeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2C1810),
            Color(0xFF452618),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4A373).withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C1810).withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A373).withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(CupertinoIcons.sparkles, color: Color(0xFFE5A65D), size: 17),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upgrade Lisensi Pro',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Akses penuh 96+ resep, Lab AI & bebas iklan',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5A65D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LIFETIME',
                      style: TextStyle(
                        color: Color(0xFF2C1810),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Compact Pricing Tiers
              Row(
                children: [
                  Expanded(
                    child: _buildCompactTierPill(
                      title: 'Pro',
                      price: 'Rp 99K',
                      sub: 'Home Barista',
                      isPopular: true,
                      onTap: () => _openCheckout(context, SubscriptionPlan.pro),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactTierPill(
                      title: 'Business',
                      price: 'Rp 249K',
                      sub: 'Kafe & Roastery',
                      isPopular: false,
                      onTap: () => _openCheckout(context, SubscriptionPlan.business),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Action button (Professional & Ringkas)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openCheckout(context, SubscriptionPlan.pro),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5A65D),
                    foregroundColor: const Color(0xFF2C1810),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    padding: const EdgeInsets.symmetric(vertical: 9.5),
                  ),
                  icon: const Icon(CupertinoIcons.sparkles, size: 15),
                  label: const Text(
                    'Upgrade Sekarang',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivePlanCard(BuildContext context) {
    final isBusiness = currentPlan.tier == SubscriptionTier.business;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBusiness ? Colors.amber.shade50 : AppTheme.bgCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isBusiness ? Colors.amber.shade700 : AppTheme.primaryBrown,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: (isBusiness ? Colors.amber : AppTheme.primaryBrown).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBusiness ? CupertinoIcons.briefcase_fill : CupertinoIcons.checkmark_seal_fill,
                  color: isBusiness ? Colors.amber.shade900 : AppTheme.primaryBrown,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPlan.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                    ),
                    Text(
                      'Lisensi Aktif • Bebas Iklan & Seduh Unlimited',
                      style: TextStyle(fontSize: 11, color: isBusiness ? Colors.brown.shade800 : AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isBusiness ? Colors.amber.shade800 : Colors.green.shade700,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'AKTIF',
                  style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isBusiness
                ? 'Akun bisnis kafe aktif: Akses 5 barista, katalog roastery, dan struk bluetooth tanpa batas.'
                : 'Akun Pro aktif: Bebas iklan, 96+ resep juara dunia & modul laboratorium dial-in terbuka penuh.',
            style: const TextStyle(fontSize: 11.5, color: AppTheme.textDark, height: 1.3),
          ),
          if (!isBusiness) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openCheckout(context, SubscriptionPlan.business),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryBrown),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(CupertinoIcons.arrow_up_right_circle, size: 14, color: AppTheme.primaryBrown),
                label: const Text(
                  'Upgrade ke Business (Rp 249K)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactTierPill({
    required String title,
    required String price,
    required String sub,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 9),
        decoration: BoxDecoration(
          color: isPopular
              ? const Color(0xFFE5A65D).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPopular
                ? const Color(0xFFE5A65D).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.18),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isPopular ? const Color(0xFFE5A65D) : Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isPopular) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5A65D),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BEST',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2C1810),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              price,
              style: TextStyle(
                color: isPopular ? const Color(0xFFE5A65D) : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCheckout(BuildContext context, SubscriptionPlan plan) {
    SubscriptionCheckoutSheet.show(context, plan: plan).then((_) => onRefresh());
  }
}
