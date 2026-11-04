import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../screens/onboarding_screen.dart';
import '../../../theme/app_theme.dart';

/// Kartu status Mode Tamu / Pengunjung di halaman Profil.
/// Didesain compact & minimalis tanpa teks panjang.
class ProfileTrialCard extends StatelessWidget {
  final int? trialBrews;
  final bool? isBrewLocked;
  final Duration? remainingLock;

  const ProfileTrialCard({
    super.key,
    this.trialBrews,
    this.isBrewLocked,
    this.remainingLock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2D1BE), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.person_crop_circle_fill,
              color: AppTheme.primaryBrown,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  overflow: TextOverflow.ellipsis,
                  text: const TextSpan(
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                    children: [
                      TextSpan(
                        text: 'Mode Pengunjung ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: AppTheme.textDark,
                        ),
                      ),
                      TextSpan(
                        text: '• Bebas Seduh',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Ekosistem aktif • Login untuk Lab Pro',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Masuk',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
