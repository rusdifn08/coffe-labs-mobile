import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Bottom Navigation Bar bergaya Shopee / Tokopedia khusus di dalam Marketplace:
/// Beranda · Roastery · Favorit · Keranjang (live badge) · Pesanan (live badge).
class MarketplaceBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final int favoriteCount;
  final int cartCount;
  final int orderCount;
  final ValueChanged<int> onTap;

  const MarketplaceBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.favoriteCount,
    required this.cartCount,
    required this.orderCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFEDE4D7), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                label: 'Beranda',
                icon: CupertinoIcons.house,
                activeIcon: CupertinoIcons.house_fill,
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                label: 'Roastery',
                icon: Icons.storefront_rounded,
                activeIcon: Icons.storefront_rounded,
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                label: 'Favorit',
                icon: CupertinoIcons.heart,
                activeIcon: CupertinoIcons.heart_fill,
                selected: currentIndex == 2,
                badgeCount: favoriteCount,
                badgeColor: const Color(0xFFDC2626),
                onTap: () => onTap(2),
              ),
              _NavItem(
                label: 'Keranjang',
                icon: CupertinoIcons.cart,
                activeIcon: CupertinoIcons.cart_fill,
                selected: currentIndex == 3,
                badgeCount: cartCount,
                badgeColor: const Color(0xFFEA580C),
                onTap: () => onTap(3),
              ),
              _NavItem(
                label: 'Pesanan',
                icon: CupertinoIcons.doc_text,
                activeIcon: CupertinoIcons.doc_text_fill,
                selected: currentIndex == 4,
                badgeCount: orderCount,
                badgeColor: AppTheme.primaryBrown,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final int badgeCount;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    this.badgeCount = 0,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.primaryBrown;
    final inactiveColor = const Color(0xFF8C7E72);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: selected ? 26 : 0,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  size: 21,
                  color: selected ? activeColor : inactiveColor,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -9,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 15),
                      decoration: BoxDecoration(
                        color: badgeColor ?? const Color(0xFFEA580C),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
