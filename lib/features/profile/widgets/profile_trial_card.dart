import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../../auth/utils/auth_navigation_helper.dart';

/// Kartu status Mode Pengunjung / Akun Terdaftar (Trial) di halaman Profil.
/// Membedakan dengan tegas akun resmi yang sudah login vs pengunjung anonim.
class ProfileTrialCard extends StatelessWidget {
  final int? trialBrews;
  final bool? isBrewLocked;
  final Duration? remainingLock;
  final AuthUser? currentUser;
  final bool isFullTrialActive;
  final Duration? remainingPolicyDuration;

  const ProfileTrialCard({
    super.key,
    this.trialBrews,
    this.isBrewLocked,
    this.remainingLock,
    this.currentUser,
    this.isFullTrialActive = false,
    this.remainingPolicyDuration,
  });

  String _formatRemaining() {
    final d = remainingPolicyDuration;
    if (d == null) return 'Aktif';
    if (d == Duration.zero) return 'Masa Berlaku Habis';
    final days = d.inDays;
    final hours = d.inHours % 24;
    if (days > 0) return 'Sisa ${days}h ${hours}j';
    return 'Sisa ${hours}j';
  }

  @override
  Widget build(BuildContext context) {
    final isRegistered = currentUser != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isFullTrialActive
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFFBF6F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFullTrialActive
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFE2D1BE),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (isFullTrialActive
                      ? const Color(0xFF15803D)
                      : AppTheme.accentGold)
                  .withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isFullTrialActive
                  ? CupertinoIcons.sparkles
                  : (isRegistered
                      ? CupertinoIcons.checkmark_seal_fill
                      : CupertinoIcons.person_crop_circle_fill),
              color: isFullTrialActive
                  ? const Color(0xFF15803D)
                  : AppTheme.primaryBrown,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRegistered
                      ? (isFullTrialActive
                          ? 'Trial 7 Hari Full Non-Bisnis'
                          : 'Akun @${currentUser!.username} • Trial')
                      : (isFullTrialActive
                          ? 'Pengunjung • Trial 7H Full'
                          : 'Mode Pengunjung • Bebas Seduh'),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isFullTrialActive
                      ? 'Seluruh fitur Brewer & Resep terbuka (${_formatRemaining()}) • Bisnis terkunci'
                      : (isRegistered
                          ? 'Sudah login sebagai ${currentUser!.fullName} • Upgrade ke Pro untuk Lab lengkap'
                          : 'Ekosistem aktif • Login untuk Lab Pro'),
                  style: TextStyle(
                    fontSize: 10,
                    color: isFullTrialActive
                        ? const Color(0xFF166534)
                        : AppTheme.textMuted,
                    fontWeight: isFullTrialActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isRegistered)
            InkWell(
              onTap: () => AuthNavigationHelper.openLoginScreen(context),
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
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: isFullTrialActive
                    ? const Color(0xFF15803D)
                    : AppTheme.primaryBrown.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isFullTrialActive ? _formatRemaining() : 'LOGIN AKTIF',
                style: TextStyle(
                  color: isFullTrialActive ? Colors.white : AppTheme.primaryBrown,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
