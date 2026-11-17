import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

/// Bottom navigation bar ala Threads (5 slot, tombol "+" tengah dalam pill bulat)
/// dengan skema warna Warm Cream & Espresso Coffee Labs.
class SocialThreadsBottomNavBar extends StatelessWidget {
  final int currentTabIndex; // 0: Home, 1: Search, 2: Activity, 3: Profile
  final int unreadNotifications;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onTapCreatePost;

  const SocialThreadsBottomNavBar({
    super.key,
    required this.currentTabIndex,
    required this.onSelectTab,
    required this.onTapCreatePost,
    this.unreadNotifications = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(
          top: BorderSide(color: AppTheme.dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              _NavIconItem(
                tooltip: 'Linimasa Social Coffee',
                icon: currentTabIndex == 0
                    ? CupertinoIcons.house_fill
                    : CupertinoIcons.house,
                selected: currentTabIndex == 0,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectTab(0);
                },
              ),
              _NavIconItem(
                tooltip: 'Cari & Explore',
                icon: CupertinoIcons.search,
                selected: currentTabIndex == 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectTab(1);
                },
              ),
              Expanded(
                child: Center(
                  child: Tooltip(
                    message: 'Buat Postingan Baru',
                    child: Material(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(13),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(13),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onTapCreatePost();
                        },
                        child: const SizedBox(
                          width: 54,
                          height: 38,
                          child: Icon(
                            CupertinoIcons.add,
                            size: 24,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _NavIconItem(
                tooltip: 'Aktivitas & Obrolan',
                icon: currentTabIndex == 2
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                selected: currentTabIndex == 2,
                badgeCount: unreadNotifications,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectTab(2);
                },
              ),
              _NavIconItem(
                tooltip: 'Profil Barista Saya',
                icon: currentTabIndex == 3
                    ? CupertinoIcons.person_fill
                    : CupertinoIcons.person,
                selected: currentTabIndex == 3,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectTab(3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIconItem extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavIconItem({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? AppTheme.primaryBrown : AppTheme.textMuted;

    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: double.infinity,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 24, color: iconColor),
                  if (badgeCount > 0)
                    Positioned(
                      right: -3,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.surfaceWhite,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
