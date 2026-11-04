import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'recipe_feed_screen.dart';
import 'brew_selection_screen.dart';
import 'toolkit_screen.dart';
import 'profile_screen.dart';
import '../features/gamification/services/gamification_service.dart';
import '../services/audio_service.dart';
import '../services/app_update_service.dart';
import '../services/main_navigation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brew_dripper_glass_icon.dart';
import '../widgets/notched_nav_bar_painter.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    GamificationService.instance.checkDailyStreak();
    MainNavigationService.currentTabNotifier.addListener(_onTabNavChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdate(context: context, isManual: false);
    });
  }

  @override
  void dispose() {
    MainNavigationService.currentTabNotifier.removeListener(_onTabNavChange);
    super.dispose();
  }

  void _onTabNavChange() {
    if (mounted && _currentIndex != MainNavigationService.currentTabNotifier.value) {
      setState(() => _currentIndex = MainNavigationService.currentTabNotifier.value);
    }
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    AudioService.playClick();
    MainNavigationService.switchTab(index);
  }

  final List<Widget> _pages = const [
    HomeScreen(),
    RecipeFeedScreen(),
    BrewSelectionScreen(),
    ToolkitScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isWide = mediaQuery.size.width >= 750;
    final useSideNav = isLandscape || isWide;

    if (useSideNav) {
      return Scaffold(
        body: Row(
          children: [
            _buildLandscapeSideNav(),
            const VerticalDivider(width: 1, thickness: 1, color: AppTheme.dividerColor),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildCustomElevatedNavBar(),
    );
  }

  Widget _buildLandscapeSideNav() {
    return Container(
      width: 76,
      color: Colors.white,
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Coffe Labs Emblem Header
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const BrewDripperGlassIcon(size: 22, color: AppTheme.primaryBrown),
            ),
            const SizedBox(height: 18),

            // Side Nav Items
            _buildLandscapeRailItem(0, CupertinoIcons.home, CupertinoIcons.house_fill, 'Home'),
            const SizedBox(height: 8),
            _buildLandscapeRailItem(1, CupertinoIcons.book, CupertinoIcons.book_fill, 'Recipes'),
            const SizedBox(height: 12),

            // Elevated Brew Center Button
            _buildElevatedBrewButtonLandscape(),
            const SizedBox(height: 12),

            _buildLandscapeRailItem(3, CupertinoIcons.wrench, CupertinoIcons.wrench_fill, 'Toolkit'),
            const SizedBox(height: 8),
            _buildLandscapeRailItem(4, CupertinoIcons.person, CupertinoIcons.person_solid, 'Profile'),

            const Spacer(),
            // Indikator Mode Landscape Aktif
            Tooltip(
              message: 'Mode Landscape Aktif',
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.device_phone_landscape, size: 16, color: AppTheme.primaryBrown),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedBrewButtonLandscape() {
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? const [Color(0xFFC67C4E), Color(0xFFE5A65D)]
                    : const [Color(0xFF6B3A19), Color(0xFF8D4925)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? const Color(0xFFC67C4E) : const Color(0xFF6B3A19))
                      .withValues(alpha: isSelected ? 0.38 : 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: BrewDripperGlassIcon(size: 21, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Brew',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? const Color(0xFFC67C4E) : AppTheme.textMuted,
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
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBrown.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? AppTheme.primaryBrown : AppTheme.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryBrown : AppTheme.textMuted,
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
            // Custom Notched/Scoop NavBar Background (desain referensi melengkung halus)
            Positioned.fill(
              child: CustomPaint(
                painter: const NotchedNavBarPainter(
                  backgroundColor: Colors.white,
                  borderColor: Color(0xFFEDE5DE),
                  buttonCenterY: 3.0,
                  buttonRadius: 27.0,
                  gap: 5.0,
                  filletRadius: 14.0,
                  cornerRadius: 20.0,
                ),
              ),
            ),

            // 4 Side Navigation Items (Home, Recipes | Toolkit, Profile)
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
                    icon: CupertinoIcons.book,
                    activeIcon: CupertinoIcons.book_fill,
                    label: 'Recipes',
                  ),
                  // Spacer center untuk Notch Scoop dan Tombol Brew
                  const SizedBox(width: 88),
                  _buildSideNavItem(
                    index: 3,
                    icon: CupertinoIcons.wrench,
                    activeIcon: CupertinoIcons.wrench_fill,
                    label: 'Toolkit',
                  ),
                  _buildSideNavItem(
                    index: 4,
                    icon: CupertinoIcons.person,
                    activeIcon: CupertinoIcons.person_solid,
                    label: 'Profile',
                  ),
                ],
              ),
            ),

            // Elevated Center "Brew" Button dengan Notch Scoop
            Positioned(
              top: -24,
              child: _buildElevatedBrewButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedBrewButton() {
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
                    ? const [Color(0xFFC67C4E), Color(0xFFE5A65D)]
                    : const [Color(0xFF6B3A19), Color(0xFF8D4925)],
              ),
              border: Border.all(
                color: Colors.white,
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? const Color(0xFFC67C4E) : const Color(0xFF6B3A19))
                      .withValues(alpha: isSelected ? 0.38 : 0.28),
                  blurRadius: isSelected ? 14 : 10,
                  spreadRadius: isSelected ? 0.5 : 0.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: BrewDripperGlassIcon(
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 11),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? const Color(0xFFC67C4E) : AppTheme.textMuted,
              fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
            ),
            child: const Text('Brew'),
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
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryBrown.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 20,
                color: isSelected ? AppTheme.primaryBrown : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryBrown : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
