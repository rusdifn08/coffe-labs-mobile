import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../screens/brew_journal_screen.dart';
import '../../../screens/favorites_screen.dart';
import '../../../screens/feedback_screen.dart';
import '../../../screens/settings_screen.dart';
import '../../../services/app_update_service.dart';
import '../../../theme/app_theme.dart';

class ProfileMenuSection extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const ProfileMenuSection({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Tombol Pengaturan
          _buildMenuTile(
            icon: CupertinoIcons.gear_alt_fill,
            iconColor: AppTheme.primaryBrown,
            title: 'Pengaturan',
            subtitle: 'Ubah nama barista, avatar, dan preferensi aplikasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) => onOpenSettings());
            },
          ),
          const Divider(height: 1, indent: 58, color: AppTheme.dividerColor),

          // Jurnal Seduh
          _buildMenuTile(
            icon: CupertinoIcons.book_fill,
            iconColor: Colors.deepOrange,
            title: 'Catatan Seduh',
            subtitle: 'Lihat riwayat seduhan dan rating kopi Anda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 58, color: AppTheme.dividerColor),

          // Resep Favorit
          _buildMenuTile(
            icon: CupertinoIcons.heart_fill,
            iconColor: Colors.pinkAccent,
            title: 'Resep Favorit Saya',
            subtitle: 'Daftar resep yang telah Anda tandai',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 58, color: AppTheme.dividerColor),

          // Beri Masukan & Feedback
          _buildMenuTile(
            icon: CupertinoIcons.chat_bubble_2_fill,
            iconColor: Colors.teal,
            title: 'Beri Masukan & Feedback',
            subtitle: 'Laporkan masalah atau usulkan fitur baru',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 58, color: AppTheme.dividerColor),

          // Periksa Pembaruan Sistem
          _buildMenuTile(
            icon: CupertinoIcons.arrow_clockwise_circle_fill,
            iconColor: Colors.purple,
            title: 'Periksa Pembaruan Sistem',
            subtitle: 'Cek rilis versi terbaru & Shorebird OTA Patch',
            onTap: () {
              AppUpdateService.checkForUpdate(context: context, isManual: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: 19),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
          letterSpacing: -0.2,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(CupertinoIcons.chevron_forward, color: AppTheme.textMuted, size: 15),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }
}
