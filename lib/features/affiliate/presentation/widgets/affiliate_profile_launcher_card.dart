import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/affiliate_hub_screen.dart';

/// Kartu kompak Program Afiliasi Coffee Labs 20% pada halaman Profil.
/// Aktif otomatis untuk akun Pro, Business & Admin; menampilkan badge Pro untuk Trial.
class AffiliateProfileLauncherCard extends StatelessWidget {
  final bool isProEligible;
  final VoidCallback? onReturned;

  const AffiliateProfileLauncherCard({
    super.key,
    required this.isProEligible,
    this.onReturned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProEligible
              ? const [Color(0xFF064E3B), Color(0xFF065F46)]
              : const [Color(0xFF2B1D12), Color(0xFF3E2717)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isProEligible
              ? const Color(0xFF34D399).withValues(alpha: 0.45)
              : const Color(0xFFD4A373).withValues(alpha: 0.45),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isProEligible
                    ? const Color(0xFF064E3B)
                    : const Color(0xFF2B1D12))
                .withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AffiliateHubScreen()),
            ).then((_) => onReturned?.call());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isProEligible
                        ? CupertinoIcons.money_dollar_circle_fill
                        : CupertinoIcons.gift_fill,
                    color: isProEligible
                        ? const Color(0xFF6EE7B7)
                        : const Color(0xFFD4A373),
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Program Afiliasi 20%',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isProEligible
                            ? 'Bagikan kode referral & tarik saldo ke Bank/E-Wallet'
                            : 'Aktifkan akun Pro untuk dapat kode & komisi 20%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.84),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: isProEligible
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFD4A373),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    isProEligible ? 'KOMISI 20%' : 'PRO',
                    style: TextStyle(
                      color: isProEligible
                          ? const Color(0xFF065F46)
                          : const Color(0xFF12100E),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: Colors.white.withValues(alpha: 0.72),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
