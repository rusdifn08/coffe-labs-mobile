import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/gamification/models/coffee_level.dart';
import '../features/gamification/services/gamification_service.dart';
import '../features/gamification/widgets/gamified_avatar.dart';
import '../features/notifications/presentation/widgets/notification_bell_button.dart';
import '../theme/app_theme.dart';
import 'professional_running_text.dart';

/// Header profil di bagian atas Home Screen:
/// - Avatar gamifikasi squircle dengan border sesuai tingkatan level 1-10.
/// - Baris 1: Sapaan (Selamat pagi/siang/sore) + Badge Title Rank + Tombol Favorit di pojok kanan atas.
/// - Baris 2: Nama Rank Pengguna / Judul lengkap membentang panjang sampai ke area paling kanan,
///   dan otomatis bergulir sebagai running text profesional jika melebihi lebar layar.
/// - Baris 3: Indikator progress EXP dan level roadmap.
class HomeHeaderProfileRow extends StatelessWidget {
  final String? userImagePath;
  final String userName;
  final GamificationStats? gamificationStats;
  final CoffeeLevel currentLevel;
  final String greeting;
  final VoidCallback onTapProfile;
  final VoidCallback onTapFavorites;

  const HomeHeaderProfileRow({
    super.key,
    required this.userImagePath,
    required this.userName,
    required this.gamificationStats,
    required this.currentLevel,
    required this.greeting,
    required this.onTapProfile,
    required this.onTapFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Avatar Profil Kotak Squircle dengan Border Gamifikasi
        GamifiedAvatar(
          radius: 26,
          imagePath: userImagePath,
          level: currentLevel,
          showLevelBadge: true,
          onTap: onTapProfile,
        ),
        const SizedBox(width: 12),

        // 2. Area Informasi Profil & Rank (Membentang maksimal ke kanan)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris 1: Greeting + Badge Rank Level + Tombol Favorit di Ujung Kanan
              Row(
                children: [
                  GestureDetector(
                    onTap: onTapProfile,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      greeting,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: GestureDetector(
                      onTap: onTapProfile,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: currentLevel.borderGradient),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: currentLevel.glowColor.withValues(alpha: 0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(currentLevel.badgeIcon, size: 9.5, color: Colors.white),
                            const SizedBox(width: 4),
                            Flexible(
                              child: ProfessionalRunningText(
                                text: currentLevel.title,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const NotificationBellButton(compact: true),
                  const SizedBox(width: 6),
                  // Tombol Love Favorit di Pojok Kanan Atas (Memberi ruang bebas di Baris 2)
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(CupertinoIcons.heart_fill, size: 16),
                      color: AppTheme.primaryBrown,
                      onPressed: onTapFavorites,
                      tooltip: 'Favorit',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),

              // Baris 2: Nama Rank Pengguna (Panjang bebas hambatan ke kanan + Running Text)
              GestureDetector(
                onTap: onTapProfile,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 25,
                  child: ProfessionalRunningText(
                    text: userName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 17.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                    velocity: 30.0,
                  ),
                ),
              ),

              // Baris 3: Progress EXP Bar
              if (gamificationStats != null) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onTapProfile,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: gamificationStats!.progress,
                            minHeight: 4,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(currentLevel.accentColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${gamificationStats!.totalExp} EXP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: currentLevel.accentColor,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(CupertinoIcons.chevron_right, size: 9, color: currentLevel.accentColor),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
