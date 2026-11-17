import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_router.dart';
import '../features/notifications/presentation/controllers/notification_center_controller.dart';
import '../features/notifications/presentation/widgets/notification_preferences_sheet.dart';
import '../features/social/widgets/social_comments_sheet.dart';
import '../features/social/widgets/social_create_post_sheet.dart';
import '../features/social/widgets/social_filter_tabs.dart';
import '../features/social/widgets/social_post_card.dart';
import '../features/social/widgets/social_threads_bottom_nav_bar.dart';
import '../features/social/widgets/social_threads_header_widgets.dart';
import '../features/social/widgets/social_threads_tab_views.dart';
import '../features/social_chat/presentation/screens/social_coffee_chat_list_screen.dart';
import '../models/social_coffee.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/social_service.dart';
import '../theme/app_theme.dart';
import 'brew_timer_screen.dart';

class SocialCoffeeScreen extends StatefulWidget {
  @visibleForTesting
  final List<SocialPost>? initialPosts;

  const SocialCoffeeScreen({super.key, this.initialPosts});

  @override
  State<SocialCoffeeScreen> createState() => _SocialCoffeeScreenState();
}

class _SocialCoffeeScreenState extends State<SocialCoffeeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _feedScrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  List<SocialPost> _posts = [];
  bool _isLoading = true;
  String _activeFilterTab = 'all'; // 'all' | 'popular' | 'recipes'
  int _bottomNavIndex = 0; // 0: Home, 1: Search, 2: Activity, 3: Profile
  String _searchQuery = '';
  String _displayHandle = 'coffeelabs.app';
  String _avatarPath = 'assets/images/coffee_labs_emblem.png';

  @override
  void initState() {
    super.initState();
    _loadIdentity();
    if (widget.initialPosts != null) {
      _posts = List<SocialPost>.from(widget.initialPosts!);
      _isLoading = false;
    } else {
      _loadFeed();
    }
    SocialService.changeNotifier.addListener(_onFeedChanged);
  }

  @override
  void dispose() {
    SocialService.changeNotifier.removeListener(_onFeedChanged);
    _feedScrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadIdentity() async {
    try {
      final user = await AuthService.getCurrentUser();
      final localName = await ProfileService.getUserName();
      final localAvatar = await ProfileService.getUserImagePath();
      if (!mounted) return;
      final resolvedName = (user?.username.trim().isNotEmpty ?? false)
          ? user!.username.trim()
          : (localName.trim().isNotEmpty ? localName.trim() : 'coffeelabs.app');
      final resolvedAvatar = (user?.avatarUrl.trim().isNotEmpty ?? false)
          ? user!.avatarUrl.trim()
          : localAvatar;
      setState(() {
        _displayHandle = resolvedName;
        _avatarPath = resolvedAvatar;
      });
    } catch (_) {}
  }

  void _onFeedChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadFeed({bool force = false}) async {
    setState(() => _isLoading = true);
    final list = await SocialService.getFeed(
      sort: _activeFilterTab,
      forceRefresh: force,
    );
    if (!mounted) return;
    setState(() {
      _posts = list;
      _isLoading = false;
    });
  }

  List<SocialPost> get _filteredPosts {
    Iterable<SocialPost> base = _posts;
    if (_activeFilterTab == 'popular') {
      final sorted = base.toList()
        ..sort((a, b) =>
            (b.likesCount * 2 + b.commentsCount * 3 + b.copiesCount * 4).compareTo(
                a.likesCount * 2 + a.commentsCount * 3 + a.copiesCount * 4));
      base = sorted;
    } else if (_activeFilterTab == 'recipes') {
      base = base.where((p) => p.recipeSnapshot != null);
    }

    if (_searchQuery.trim().isEmpty) return base.toList();
    final q = _searchQuery.toLowerCase();
    return base.where((p) {
      final inContent = p.content.toLowerCase().contains(q);
      final inAuthor = p.authorName.toLowerCase().contains(q);
      final inTags = p.tags.any((t) => t.toLowerCase().contains(q));
      final inRecipe =
          p.recipeSnapshot?['title']?.toString().toLowerCase().contains(q) ??
              false;
      return inContent || inAuthor || inTags || inRecipe;
    }).toList();
  }

  void _handleBackToCoffeeLabs() {
    HapticFeedback.selectionClick();
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }
    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.home);
    }
  }

  void _pushRouteSafe(String route, {WidgetBuilder? fallback}) {
    if (GoRouter.maybeOf(context) != null) {
      context.push(route);
    } else if (fallback != null) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: fallback));
    }
  }

  void _scrollToTop() {
    if (_bottomNavIndex == 0 && _feedScrollCtrl.hasClients) {
      _feedScrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showCommentsSheet(SocialPost post) {
    SocialCommentsSheet.show(context, post);
  }

  void _showCreatePostDialog() {
    SocialCreatePostSheet.show(
      context,
      onPostCreated: () => _loadFeed(force: true),
    );
  }

  Future<void> _handleCopyRecipe(SocialPost post) async {
    HapticFeedback.mediumImpact();
    final saved = await SocialService.copyRecipeToMyRecipes(post);
    if (!mounted) return;

    if (saved != null) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: Colors.green,
                size: 24,
              ),
              SizedBox(width: 8),
              Text('Resep Berhasil Disalin!'),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Resep "${saved['title']}" telah tersimpan di daftar resep pribadi Anda.\n\nAnda dapat langsung menyeduhnya atau mengubah parameter sesuka hati.',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Nanti Saja'),
              onPressed: () => Navigator.pop(ctx),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Mulai Brew Sekarang'),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BrewTimerScreen(recipeData: saved),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyalin resep'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _hasRiverpodScope() {
    try {
      ProviderScope.containerOf(context, listen: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _headerTitleForTab() {
    switch (_bottomNavIndex) {
      case 1:
        return 'Cari Akun';
      case 2:
        return 'Aktivitas';
      case 3:
        return 'Profil';
      default:
        return 'Social Coffee';
    }
  }

  Widget _buildAppBarMessengerAction() {
    return IconButton(
      tooltip: 'Pesan Barista',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 38, height: 40),
      onPressed: () {
        HapticFeedback.selectionClick();
        _pushRouteSafe(
          AppRoutes.socialChat,
          fallback: (_) => const SocialCoffeeChatListScreen(),
        );
      },
      icon: const ThreadsMessengerIcon(color: AppTheme.textDark, size: 21),
    );
  }

  Widget _buildAppBarMenuAction(bool hasScope) {
    const compactConstraints = BoxConstraints.tightFor(width: 38, height: 40);
    if (!hasScope) {
      return IconButton(
        tooltip: 'Menu Sidebar',
        padding: EdgeInsets.zero,
        constraints: compactConstraints,
        onPressed: () {
          HapticFeedback.selectionClick();
          _scaffoldKey.currentState?.openEndDrawer();
        },
        icon: const ThreadsTwoLineMenuIcon(color: AppTheme.textDark),
      );
    }
    return Consumer(
      builder: (ctx, ref, _) {
        final unread = ref.watch(unreadNotificationsCountProvider);
        return IconButton(
          tooltip: 'Menu Sidebar',
          padding: EdgeInsets.zero,
          constraints: compactConstraints,
          onPressed: () {
            HapticFeedback.selectionClick();
            _scaffoldKey.currentState?.openEndDrawer();
          },
          icon: ThreadsTwoLineMenuIcon(
            color: AppTheme.textDark,
            showDot: unread > 0,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasScope = _hasRiverpodScope();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        actions: const [SizedBox.shrink()],
        title: SizedBox(
          width: double.infinity,
          height: kToolbarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _scrollToTop,
                  behavior: HitTestBehavior.translucent,
                  child: _CenteredTextWithLeftEmblem(
                    leftReserved: 44,
                    rightReserved: 84,
                    gap: 6,
                    emblem: Image.asset(
                      'assets/images/coffee_labs_emblem.png',
                      width: 24,
                      height: 24,
                    ),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        _headerTitleForTab(),
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    tooltip: 'Kembali ke Coffee Labs',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints.tightFor(width: 40, height: 40),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: AppTheme.textDark,
                    ),
                    onPressed: _handleBackToCoffeeLabs,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAppBarMessengerAction(),
                    _buildAppBarMenuAction(hasScope),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: SocialThreadsEndDrawer(
        displayName: _displayHandle,
        avatarPath: _avatarPath,
        onOpenChat: () => _pushRouteSafe(AppRoutes.socialChat),
        onOpenExplore: () => _pushRouteSafe(AppRoutes.socialExplore),
        onOpenBasecamp: () => _pushRouteSafe(AppRoutes.socialClubs),
        onOpenBaristaDirectory: () => _pushRouteSafe(AppRoutes.socialProfiles),
        onOpenNotifications: () => _pushRouteSafe(AppRoutes.notifications),
        onOpenMyProfile: () => _pushRouteSafe('/social/profile/me'),
        onOpenNotifPreferences: () => NotificationPreferencesSheet.show(context),
        onRefreshFeed: () => _loadFeed(force: true),
        onBackToCoffeeLabs: _handleBackToCoffeeLabs,
      ),
      body: _buildBodyForCurrentTab(),
      bottomNavigationBar: hasScope
          ? Consumer(
              builder: (ctx, ref, _) {
                final unread = ref.watch(unreadNotificationsCountProvider);
                return SocialThreadsBottomNavBar(
                  currentTabIndex: _bottomNavIndex,
                  unreadNotifications: unread,
                  onSelectTab: _onSelectBottomTab,
                  onTapCreatePost: _showCreatePostDialog,
                );
              },
            )
          : SocialThreadsBottomNavBar(
              currentTabIndex: _bottomNavIndex,
              onSelectTab: _onSelectBottomTab,
              onTapCreatePost: _showCreatePostDialog,
            ),
    );
  }

  void _onSelectBottomTab(int index) {
    if (index == 0 && _bottomNavIndex == 0) {
      _scrollToTop();
      return;
    }
    setState(() => _bottomNavIndex = index);
  }

  Widget _buildBodyForCurrentTab() {
    switch (_bottomNavIndex) {
      case 1:
        return SocialThreadsSearchTab(
          searchController: _searchCtrl,
          searchQuery: _searchQuery,
          currentUsername: _displayHandle,
          allPosts: _posts,
          filteredPosts: _filteredPosts,
          onSearchChanged: (val) => setState(() => _searchQuery = val),
          onClearSearch: () {
            _searchCtrl.clear();
            setState(() => _searchQuery = '');
          },
          onOpenBasecamp: () => _pushRouteSafe(AppRoutes.socialClubs),
          onToggleLike: (post) async => await SocialService.toggleLike(post),
          onOpenComments: _showCommentsSheet,
          onCopyRecipe: _handleCopyRecipe,
        );
      case 2:
        return const SocialThreadsActivityTab();
      case 3:
        return SocialThreadsProfileTab(
          displayName: _displayHandle,
          avatarPath: _avatarPath,
          allPosts: _posts,
          onToggleLike: (post) async => await SocialService.toggleLike(post),
          onOpenComments: _showCommentsSheet,
          onCopyRecipe: _handleCopyRecipe,
        );
      default:
        return _buildHomeFeedTab();
    }
  }

  Widget _buildHomeFeedTab() {
    final posts = _filteredPosts;

    return RefreshIndicator(
      color: AppTheme.primaryBrown,
      onRefresh: () => _loadFeed(force: true),
      child: CustomScrollView(
        controller: _feedScrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SocialThreadsComposerHeader(
              displayHandle: _displayHandle,
              avatarPath: _avatarPath,
              onTapCompose: _showCreatePostDialog,
              onTapAvatar: () => setState(() => _bottomNavIndex = 3),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1, thickness: 1, color: AppTheme.dividerColor),
          ),
          SliverToBoxAdapter(
            child: SocialFilterTabs(
              activeTab: _activeFilterTab,
              onTabChanged: (tabId) {
                setState(() => _activeFilterTab = tabId);
                if (widget.initialPosts == null) {
                  _loadFeed();
                }
              },
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBrown),
              ),
            )
          else if (posts.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return SocialPostCard(
                      post: post,
                      onLike: () async => await SocialService.toggleLike(post),
                      onComment: () => _showCommentsSheet(post),
                      onCopyRecipe: () => _handleCopyRecipe(post),
                    );
                  },
                  childCount: posts.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.chat_bubble_2,
              size: 42,
              color: AppTheme.primaryBrown,
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum Ada Postingan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Jadilah yang pertama membagikan resep seduh favorit Anda atau menyapa sesama barista!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showCreatePostDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBrown,
                side: const BorderSide(color: AppTheme.borderWarm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(CupertinoIcons.pencil, size: 16),
              label: const Text('Tulis Postingan Pertama'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CenteredHeaderSlot { emblem, label }

/// Memosisikan teks judul tepat di tengah layar dan menggeser ikon emblem tepat di sebelah kiri teks.
class _CenteredTextWithLeftEmblem extends StatelessWidget {
  final Widget emblem;
  final Widget label;
  final double leftReserved;
  final double rightReserved;
  final double gap;

  const _CenteredTextWithLeftEmblem({
    required this.emblem,
    required this.label,
    required this.leftReserved,
    required this.rightReserved,
    this.gap = 6,
  });

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _CenteredTextWithLeftEmblemDelegate(
        leftReserved: leftReserved,
        rightReserved: rightReserved,
        gap: gap,
      ),
      children: [
        LayoutId(id: _CenteredHeaderSlot.emblem, child: emblem),
        LayoutId(id: _CenteredHeaderSlot.label, child: label),
      ],
    );
  }
}

class _CenteredTextWithLeftEmblemDelegate extends MultiChildLayoutDelegate {
  final double leftReserved;
  final double rightReserved;
  final double gap;

  _CenteredTextWithLeftEmblemDelegate({
    required this.leftReserved,
    required this.rightReserved,
    required this.gap,
  });

  @override
  void performLayout(Size size) {
    final emblemSize = layoutChild(
      _CenteredHeaderSlot.emblem,
      BoxConstraints.loose(size),
    );
    final maxLabelWidth =
        (size.width - leftReserved - rightReserved - emblemSize.width - gap)
            .clamp(0.0, size.width);
    final labelSize = layoutChild(
      _CenteredHeaderSlot.label,
      BoxConstraints(
        minWidth: 0,
        maxWidth: maxLabelWidth,
        minHeight: 0,
        maxHeight: size.height,
      ),
    );

    final idealLabelX = (size.width - labelSize.width) / 2.0;
    final minLabelX = leftReserved + emblemSize.width + gap;
    final maxLabelX = size.width - rightReserved - labelSize.width;
    final double finalLabelX;
    if (minLabelX <= maxLabelX) {
      finalLabelX = idealLabelX.clamp(minLabelX, maxLabelX);
    } else {
      finalLabelX = minLabelX;
    }

    final emblemX =
        (finalLabelX - gap - emblemSize.width).clamp(0.0, size.width);
    positionChild(
      _CenteredHeaderSlot.emblem,
      Offset(emblemX, (size.height - emblemSize.height) / 2.0),
    );
    positionChild(
      _CenteredHeaderSlot.label,
      Offset(finalLabelX, (size.height - labelSize.height) / 2.0),
    );
  }

  @override
  bool shouldRelayout(
    covariant _CenteredTextWithLeftEmblemDelegate oldDelegate,
  ) =>
      oldDelegate.leftReserved != leftReserved ||
      oldDelegate.rightReserved != rightReserved ||
      oldDelegate.gap != gap;
}
