import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/notifications/presentation/controllers/notification_center_controller.dart';
import '../../../theme/app_theme.dart';

/// Ikon garis 2 minimalis gaya Threads untuk membuka Sidebar kanan.
class ThreadsTwoLineMenuIcon extends StatelessWidget {
  final Color color;
  final bool showDot;

  const ThreadsTwoLineMenuIcon({
    super.key,
    this.color = AppTheme.textDark,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 22,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 20,
                  height: 2.2,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 5.5),
                Container(
                  width: 14,
                  height: 2.2,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          if (showDot)
            Positioned(
              right: -2,
              top: 1,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.bgCream, width: 1.2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ikon Messenger minimalis untuk akses cepat ke obrolan langsung barista.
class ThreadsMessengerIcon extends StatelessWidget {
  final Color color;
  final double size;

  const ThreadsMessengerIcon({
    super.key,
    this.color = AppTheme.textDark,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MessengerBubbleBoltPainter(color)),
    );
  }
}

class _MessengerBubbleBoltPainter extends CustomPainter {
  final Color color;
  const _MessengerBubbleBoltPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bubble = Path()
      ..moveTo(size.width * 0.50, size.height * 0.12)
      ..cubicTo(
        size.width * 0.77,
        size.height * 0.12,
        size.width * 0.90,
        size.height * 0.28,
        size.width * 0.90,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.90,
        size.height * 0.68,
        size.width * 0.74,
        size.height * 0.83,
        size.width * 0.50,
        size.height * 0.83,
      )
      ..lineTo(size.width * 0.36, size.height * 0.82)
      ..lineTo(size.width * 0.21, size.height * 0.90)
      ..lineTo(size.width * 0.24, size.height * 0.75)
      ..cubicTo(
        size.width * 0.13,
        size.height * 0.67,
        size.width * 0.10,
        size.height * 0.58,
        size.width * 0.10,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.10,
        size.height * 0.28,
        size.width * 0.23,
        size.height * 0.12,
        size.width * 0.50,
        size.height * 0.12,
      );
    canvas.drawPath(bubble, stroke);

    final bolt = Path()
      ..moveTo(size.width * 0.33, size.height * 0.52)
      ..lineTo(size.width * 0.47, size.height * 0.41)
      ..lineTo(size.width * 0.54, size.height * 0.52)
      ..lineTo(size.width * 0.67, size.height * 0.41);
    canvas.drawPath(bolt, stroke);
  }

  @override
  bool shouldRepaint(covariant _MessengerBubbleBoltPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Baris composer inline ala Threads ("Apa yang baru?") di bawah AppBar.
class SocialThreadsComposerHeader extends StatelessWidget {
  final String displayHandle;
  final String avatarPath;
  final VoidCallback onTapCompose;
  final VoidCallback? onTapAvatar;

  const SocialThreadsComposerHeader({
    super.key,
    required this.displayHandle,
    required this.avatarPath,
    required this.onTapCompose,
    this.onTapAvatar,
  });

  ImageProvider _resolveAvatar() {
    if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
      return NetworkImage(avatarPath);
    }
    if (avatarPath.startsWith('assets/')) {
      return AssetImage(avatarPath);
    }
    return const AssetImage('assets/images/coffee_labs_emblem.png');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapCompose,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onTapAvatar ?? onTapCompose,
              child: CircleAvatar(
                radius: 19,
                backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.1),
                backgroundImage: _resolveAvatar(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayHandle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Apa yang baru? Bagikan teknik seduh atau resep...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.square_pencil,
              size: 19,
              color: AppTheme.primaryBrown,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sidebar Kanan (`endDrawer`) Social Coffee tanpa card, bergaya datar & garis tipis.
class SocialThreadsEndDrawer extends StatelessWidget {
  final String displayName;
  final String avatarPath;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenExplore;
  final VoidCallback onOpenBasecamp;
  final VoidCallback onOpenBaristaDirectory;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenMyProfile;
  final VoidCallback onOpenNotifPreferences;
  final VoidCallback onRefreshFeed;
  final VoidCallback onBackToCoffeeLabs;

  const SocialThreadsEndDrawer({
    super.key,
    required this.displayName,
    required this.avatarPath,
    required this.onOpenChat,
    required this.onOpenExplore,
    required this.onOpenBasecamp,
    required this.onOpenBaristaDirectory,
    required this.onOpenNotifications,
    required this.onOpenMyProfile,
    required this.onOpenNotifPreferences,
    required this.onRefreshFeed,
    required this.onBackToCoffeeLabs,
  });

  ImageProvider _resolveAvatar() {
    if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
      return NetworkImage(avatarPath);
    }
    if (avatarPath.startsWith('assets/')) {
      return AssetImage(avatarPath);
    }
    return const AssetImage('assets/images/coffee_labs_emblem.png');
  }

  int _readUnreadCount(BuildContext context) {
    try {
      ProviderScope.containerOf(context, listen: false);
      return 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }

    return Drawer(
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.1),
                    backgroundImage: _resolveAvatar(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const Text(
                          'Social Coffee Hub',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/coffee_labs_emblem.png',
                    width: 28,
                    height: 28,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.dividerColor),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: [
                  _DrawerMenuRow(
                    icon: CupertinoIcons.paperplane,
                    title: 'Direct & Group Chat Barista',
                    subtitle: 'Kirim kartu resep & diskusi real-time',
                    onTap: () {
                      Navigator.pop(context);
                      onOpenChat();
                    },
                  ),
                  _DrawerMenuRow(
                    icon: CupertinoIcons.sparkles,
                    title: 'Explore For You & Trending',
                    subtitle: 'Rekomendasi selera & postingan seduh terhangat',
                    onTap: () {
                      Navigator.pop(context);
                      onOpenExplore();
                    },
                  ),
                  _DrawerMenuRow(
                    icon: CupertinoIcons.person_3_fill,
                    title: 'Coffee Club',
                    subtitle: 'Buat grup kopi, undang barista, & ruang seduh',
                    onTap: () {
                      Navigator.pop(context);
                      onOpenBasecamp();
                    },
                  ),
                  _DrawerMenuRow(
                    icon: CupertinoIcons.compass,
                    title: 'Directory & Stalking Barista',
                    subtitle: 'Intip log seduhan, rank, & thread terbaru',
                    onTap: () {
                      Navigator.pop(context);
                      onOpenBaristaDirectory();
                    },
                  ),
                  if (hasScope)
                    Consumer(
                      builder: (ctx, ref, _) {
                        final unread = ref.watch(unreadNotificationsCountProvider);
                        return _DrawerMenuRow(
                          icon: CupertinoIcons.bell,
                          title: 'Pusat Notifikasi',
                          subtitle: unread > 0
                              ? '$unread notifikasi belum dibaca'
                              : 'Semua kabar aktivitas sudah dibaca',
                          trailing: unread > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentAmber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    unread > 99 ? '99+' : '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            onOpenNotifications();
                          },
                        );
                      },
                    )
                  else
                    _DrawerMenuRow(
                      icon: CupertinoIcons.bell,
                      title: 'Pusat Notifikasi',
                      subtitle: 'Aktivitas sosial & balasan thread',
                      trailing: _readUnreadCount(context) > 0 ? const SizedBox.shrink() : null,
                      onTap: () {
                        Navigator.pop(context);
                        onOpenNotifications();
                      },
                    ),
                  _DrawerMenuRow(
                    icon: CupertinoIcons.person_crop_circle,
                    title: 'Profil Publik Saya',
                    subtitle: 'Kelola bio, equipment & koleksi thread',
                    onTap: () {
                      Navigator.pop(context);
                      onOpenMyProfile();
                    },
                  ),
                  const Divider(height: 16, indent: 18, endIndent: 18, color: AppTheme.dividerColor),
                  _DrawerMenuRow(
                    icon: CupertinoIcons.slider_horizontal_3,
                    title: 'Preferensi Notifikasi',
                    onTap: () {
                      Navigator.pop(context);
                      onOpenNotifPreferences();
                    },
                  ),
                  _DrawerMenuRow(
                    icon: CupertinoIcons.arrow_clockwise,
                    title: 'Segarkan Linimasa',
                    onTap: () {
                      Navigator.pop(context);
                      onRefreshFeed();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.dividerColor),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              leading: const Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.primaryBrown,
                size: 21,
              ),
              title: const Text(
                'Kembali ke Coffee Labs',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBrown,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onBackToCoffeeLabs();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _DrawerMenuRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      leading: Icon(icon, color: AppTheme.textDark, size: 21),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.textMuted,
              ),
            )
          : null,
      trailing: trailing ??
          const Icon(
            CupertinoIcons.chevron_forward,
            size: 14,
            color: AppTheme.textMuted,
          ),
      onTap: onTap,
    );
  }
}
