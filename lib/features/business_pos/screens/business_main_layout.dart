import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/business_pos_models.dart';
import '../../../providers/workspace_mode_provider.dart';
import '../../../services/audio_service.dart';
import '../../../theme/business_theme.dart';
import '../../../widgets/notched_nav_bar_painter.dart';
import 'business_cashier_screen.dart';
import 'business_dashboard_home_screen.dart';
import 'business_display_hub_screen.dart';
import 'business_settings_screen.dart';
import 'business_stock_opname_screen.dart';

class BusinessMainLayout extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const BusinessMainLayout({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<BusinessMainLayout> createState() => _BusinessMainLayoutState();
}

class _BusinessMainLayoutState extends ConsumerState<BusinessMainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex.clamp(0, 4);
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    AudioService.playClick();
    setState(() => _currentIndex = index);
  }

  void _switchToPersonal() {
    ref.read(workspaceModeProvider.notifier).forceSetMode(WorkspaceMode.personalBrewer);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isWide = mediaQuery.size.width >= 750;
    final useSideNav = isLandscape || isWide;

    final pages = [
      BusinessDashboardHomeScreen(
        onNavigateToTab: _onTabSelected,
        onSwitchToPersonal: _switchToPersonal,
      ),
      const BusinessCashierScreen(isEmbeddedInTab: true),
      const BusinessDisplayHubScreen(),
      const BusinessStockOpnameScreen(),
      BusinessSettingsScreen(
        onSwitchToPersonal: _switchToPersonal,
      ),
    ];

    if (useSideNav) {
      return Scaffold(
        backgroundColor: BusinessTheme.bgDark,
        body: Row(
          children: [
            _buildLandscapeSideNav(),
            const VerticalDivider(width: 1, thickness: 1, color: BusinessTheme.borderSubtle),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: BusinessTheme.bgDark,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildCustomElevatedNavBar(),
    );
  }

  Widget _buildLandscapeSideNav() {
    return Container(
      width: 82,
      color: BusinessTheme.navBarBg,
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Coffee Labs Business Gold Emblem
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFF8A6C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: BusinessTheme.goldAccent.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(CupertinoIcons.flame_fill, size: 22, color: Colors.black),
            ),
            const SizedBox(height: 16),

            // Side Nav Items: Home & Kasir
            _buildLandscapeRailItem(0, CupertinoIcons.home, CupertinoIcons.house_fill, 'Home'),
            const SizedBox(height: 8),
            _buildLandscapeRailItem(1, CupertinoIcons.cart, CupertinoIcons.cart_fill, 'Kasir'),
            const SizedBox(height: 12),

            // Center Elevated Display Button
            _buildElevatedDisplayButtonLandscape(),
            const SizedBox(height: 12),

            // Side Nav Items: Stock & Settings
            _buildLandscapeRailItem(3, CupertinoIcons.archivebox, CupertinoIcons.archivebox_fill, 'Stock'),
            const SizedBox(height: 8),
            _buildLandscapeRailItem(4, CupertinoIcons.gear_alt, CupertinoIcons.gear_alt_fill, 'Setting'),

            const Spacer(),
            // Quick Button back to Personal Mode
            Tooltip(
              message: 'Beralih ke Mode Personal',
              child: InkWell(
                onTap: _switchToPersonal,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BusinessTheme.cardElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: BusinessTheme.borderHighlighted),
                  ),
                  child: const Icon(CupertinoIcons.person_crop_circle, size: 18, color: BusinessTheme.goldAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedDisplayButtonLandscape() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => _onTabSelected(2),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? const [Color(0xFFE5A93C), Color(0xFFF3C654)]
                    : const [Color(0xFF9E7728), Color(0xFFD4AF37)],
              ),
              boxShadow: [
                BoxShadow(
                  color: BusinessTheme.goldAccent.withValues(alpha: isSelected ? 0.45 : 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(CupertinoIcons.tv_fill, size: 22, color: Colors.black),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Display',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeRailItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 66,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? BusinessTheme.goldAccent.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: BusinessTheme.goldAccent.withValues(alpha: 0.4), width: 0.8)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomElevatedNavBar() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 68,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Custom Notched/Scoop NavBar Background (Mode Business Dark Espresso & Border)
            Positioned.fill(
              child: CustomPaint(
                painter: const NotchedNavBarPainter(
                  backgroundColor: BusinessTheme.navBarBg,
                  borderColor: BusinessTheme.navBarBorder,
                  buttonCenterY: 3.0,
                  buttonRadius: 27.0,
                  gap: 5.0,
                  filletRadius: 14.0,
                  cornerRadius: 20.0,
                ),
              ),
            ),

            // 4 Side Navigation Items (Home, Kasir | Stock, Setting)
            Positioned.fill(
              child: Row(
                children: [
                  _buildSideNavItem(
                    index: 0,
                    icon: CupertinoIcons.home,
                    activeIcon: CupertinoIcons.house_fill,
                    label: 'Home',
                  ),
                  _buildSideNavItem(
                    index: 1,
                    icon: CupertinoIcons.cart,
                    activeIcon: CupertinoIcons.cart_fill,
                    label: 'Kasir',
                  ),
                  // Spacer center untuk Scoop Notch dan Tombol Display
                  const SizedBox(width: 88),
                  _buildSideNavItem(
                    index: 3,
                    icon: CupertinoIcons.archivebox,
                    activeIcon: CupertinoIcons.archivebox_fill,
                    label: 'Stock',
                  ),
                  _buildSideNavItem(
                    index: 4,
                    icon: CupertinoIcons.gear_alt,
                    activeIcon: CupertinoIcons.gear_alt_fill,
                    label: 'Setting',
                  ),
                ],
              ),
            ),

            // Elevated Center "Display" Button dengan Notch Scoop
            Positioned(
              top: -24,
              child: _buildElevatedDisplayButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedDisplayButton() {
    final isSelected = _currentIndex == 2;

    return GestureDetector(
      onTap: () => _onTabSelected(2),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? const [Color(0xFFE5A93C), Color(0xFFF3C654)]
                    : const [Color(0xFF9E7728), Color(0xFFD4AF37)],
              ),
              boxShadow: [
                BoxShadow(
                  color: BusinessTheme.goldAccent.withValues(alpha: isSelected ? 0.45 : 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.tv_fill,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Display',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        splashColor: BusinessTheme.goldAccent.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 6),
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
