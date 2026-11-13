import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/router/app_router.dart';
import '../features/notifications/presentation/widgets/notification_bell_button.dart';
import '../features/social/widgets/social_comments_sheet.dart';
import '../features/social/widgets/social_community_banner.dart';
import '../features/social/widgets/social_create_post_sheet.dart';
import '../features/social/widgets/social_filter_tabs.dart';
import '../features/social/widgets/social_post_card.dart';
import '../features/social/widgets/social_search_bar.dart';
import '../models/social_coffee.dart';
import '../services/social_service.dart';
import '../theme/app_theme.dart';
import 'basecamp_screen.dart';
import 'brew_timer_screen.dart';

class SocialCoffeeScreen extends StatefulWidget {
  const SocialCoffeeScreen({super.key});

  @override
  State<SocialCoffeeScreen> createState() => _SocialCoffeeScreenState();
}

class _SocialCoffeeScreenState extends State<SocialCoffeeScreen> {
  List<SocialPost> _posts = [];
  bool _isLoading = true;
  String _activeTab = 'all'; // 'all' | 'popular' | 'recipes'
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFeed();
    SocialService.changeNotifier.addListener(_onFeedChanged);
  }

  @override
  void dispose() {
    SocialService.changeNotifier.removeListener(_onFeedChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onFeedChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadFeed({bool force = false}) async {
    setState(() => _isLoading = true);
    final list = await SocialService.getFeed(sort: _activeTab, forceRefresh: force);
    if (!mounted) return;
    setState(() {
      _posts = list;
      _isLoading = false;
    });
  }

  List<SocialPost> get _filteredPosts {
    if (_searchQuery.trim().isEmpty) return _posts;
    final q = _searchQuery.toLowerCase();
    return _posts.where((p) {
      final inContent = p.content.toLowerCase().contains(q);
      final inAuthor = p.authorName.toLowerCase().contains(q);
      final inTags = p.tags.any((t) => t.toLowerCase().contains(q));
      final inRecipe = p.recipeSnapshot?['title']?.toString().toLowerCase().contains(q) ?? false;
      return inContent || inAuthor || inTags || inRecipe;
    }).toList();
  }

  void _showCommentsSheet(SocialPost post) {
    SocialCommentsSheet.show(context, post);
  }

  void _showCreatePostDialog() {
    SocialCreatePostSheet.show(context, onPostCreated: () => _loadFeed(force: true));
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
              Icon(CupertinoIcons.check_mark_circled_solid, color: Colors.green, size: 24),
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
                  MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: saved)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.chat_bubble_2_fill, color: AppTheme.primaryBrown, size: 20),
            SizedBox(width: 8),
            Text('Social Coffee'),
          ],
        ),
        centerTitle: true,
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: NotificationBellButton(compact: true),
          ),
          IconButton(
            tooltip: 'Profil Publik Saya',
            icon: const Icon(
              CupertinoIcons.person_crop_circle_fill,
              color: AppTheme.primaryBrown,
            ),
            onPressed: () => context.push('/social/profile/me'),
          ),
          IconButton(
            tooltip: 'Jelajah & Stalking Barista',
            icon: const Icon(
              CupertinoIcons.compass,
              color: AppTheme.primaryBrown,
            ),
            onPressed: () => context.push(AppRoutes.socialProfiles),
          ),
          IconButton(
            tooltip: 'Direct & Group Chat',
            icon: const Icon(
              CupertinoIcons.paperplane_fill,
              color: AppTheme.primaryBrown,
            ),
            onPressed: () => context.push(AppRoutes.socialChat),
          ),
          IconButton(
            tooltip: 'Basecamp Komunitas',
            icon: const Icon(CupertinoIcons.person_3_fill, color: AppTheme.primaryBrown),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BasecampScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Segarkan Feed',
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            onPressed: () => _loadFeed(force: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'social_coffee_fab',
        backgroundColor: AppTheme.primaryBrown,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(CupertinoIcons.pencil_ellipsis_rectangle, size: 20),
        label: const Text('Buat Postingan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        onPressed: _showCreatePostDialog,
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBrown,
        onRefresh: () => _loadFeed(force: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Banner Komunitas
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SocialCommunityBanner(),
              ),
            ),

            // Quick Entry Coffee Clubs, For You & Trending (Modul 3.5)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push(AppRoutes.socialExplore),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: AppTheme.accentAmber.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              CupertinoIcons.sparkles,
                              color: AppTheme.primaryBrown,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explore For You, Trending & Clubs',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  'Temukan resep cocok selera & gabung club via Secret ID',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_forward,
                            size: 16,
                            color: AppTheme.primaryBrown,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Quick Entry Direct & Group Messaging (Real-Time)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push(AppRoutes.socialChat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              CupertinoIcons.bubble_left_bubble_right_fill,
                              color: AppTheme.primaryBrown,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Direct & Group Chat Barista',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  'Kirim kartu resep V60 & profil biji real-time',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_forward,
                            size: 16,
                            color: AppTheme.primaryBrown,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Quick Entry Jelajah & Stalking Profil Barista (Modul 3.2)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push(AppRoutes.socialProfiles),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              CupertinoIcons.person_crop_circle_badge_checkmark,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jelajah & Stalking Profil Barista',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  'Intip log seduhan, rank barista, badge, & thread terbaru',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_forward,
                            size: 16,
                            color: AppTheme.primaryBrown,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search Bar & Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SocialSearchBar(
                      controller: _searchCtrl,
                      searchQuery: _searchQuery,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onClear: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                    const SizedBox(height: 10),
                    SocialFilterTabs(
                      activeTab: _activeTab,
                      onTabChanged: (tabId) {
                        setState(() => _activeTab = tabId);
                        _loadFeed();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // List Postingan
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown)),
              )
            else if (_filteredPosts.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = _filteredPosts[index];
                      return SocialPostCard(
                        post: post,
                        onLike: () async => await SocialService.toggleLike(post),
                        onComment: () => _showCommentsSheet(post),
                        onCopyRecipe: () => _handleCopyRecipe(post),
                      );
                    },
                    childCount: _filteredPosts.length,
                  ),
                ),
              ),
          ],
        ),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.bgCream,
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.chat_bubble_2, size: 36, color: AppTheme.primaryBrown),
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum Ada Postingan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Jadilah yang pertama membagikan resep seduh favorit Anda atau menyapa sesama barista!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreatePostDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
