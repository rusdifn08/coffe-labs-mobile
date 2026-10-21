import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/social_coffee.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/social_service.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _buildCommunityBanner(),
              ),
            ),

            // Search Bar & Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 10),
                    _buildFilterTabs(),
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
                      return _buildPostCard(post);
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

  // --- HEADER COMMUNITY BANNER ---
  Widget _buildCommunityBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBrown,
            AppTheme.primaryBrown.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.person_3_fill, color: AppTheme.accentGold, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'KOMUNITAS SEDUH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(CupertinoIcons.circle_fill, size: 6, color: Colors.greenAccent),
                    SizedBox(width: 3),
                    Text(
                      'Live Feed',
                      style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Diskusi & Tukar Resep Kopi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Eksplorasi teknik seduh para barista, salin resep favorit ke tab Seduh, dan tinggalkan masukan!',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BasecampScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.person_3_fill, size: 13, color: AppTheme.accentGold),
                        SizedBox(width: 6),
                        Text(
                          'Buka Basecamp Barista',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(CupertinoIcons.chevron_right, size: 11, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SEARCH BAR ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(CupertinoIcons.search, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Cari diskusi, resep, atau nama barista...',
                hintStyle: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
              child: const Icon(CupertinoIcons.clear_circled_solid, size: 16, color: AppTheme.textMuted),
            ),
        ],
      ),
    );
  }

  // --- FILTER TABS ---
  Widget _buildFilterTabs() {
    final tabs = [
      {'id': 'all', 'label': 'Semua Feed', 'icon': CupertinoIcons.layers_fill},
      {'id': 'popular', 'label': '🔥 Terpopuler', 'icon': CupertinoIcons.flame_fill},
      {'id': 'recipes', 'label': '📖 Resep Kopi', 'icon': CupertinoIcons.book_fill},
    ];

    return Row(
      children: tabs.map((t) {
        final active = _activeTab == t['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (_activeTab != t['id']) {
                setState(() => _activeTab = t['id'] as String);
                _loadFeed();
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.15),
                ),
              ),
              child: Center(
                child: Text(
                  t['label'] as String,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: active ? FontWeight.bold : FontWeight.w600,
                    color: active ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- POST CARD ---
  Widget _buildPostCard(SocialPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.bgCream,
                backgroundImage: post.authorAvatar.startsWith('assets/')
                    ? AssetImage(post.authorAvatar) as ImageProvider
                    : NetworkImage(post.authorAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            post.authorRole,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRelativeTime(post.createdAt),
                      style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content Text
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppTheme.textDark,
            ),
          ),

          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: post.tags.map((tag) {
                final displayTag = tag.startsWith('#') ? tag : '#$tag';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    displayTag,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Embedded Recipe Card Preview (if recipe attached)
          if (post.recipeSnapshot != null) ...[
            const SizedBox(height: 14),
            _buildEmbeddedRecipeCard(post),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 8),

          // Actions Bar: Like, Komen, Copy, Share
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Like Button
              InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await SocialService.toggleLike(post);
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        post.isLikedByMe ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        size: 18,
                        color: post.isLikedByMe ? Colors.redAccent : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${post.likesCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: post.isLikedByMe ? Colors.redAccent : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Comment Button
              InkWell(
                onTap: () => _showCommentsSheet(post),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.chat_bubble_text, size: 18, color: AppTheme.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        '${post.commentsCount}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),

              // Copies Count Indicator (jika ada resep)
              if (post.recipeSnapshot != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.doc_on_clipboard, size: 17, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${post.copiesCount} disalin',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              // Share Button
              InkWell(
                onTap: () {
                  final textToCopy = 'Resep dari ${post.authorName} di Coffee Labs:\n${post.content}';
                  Clipboard.setData(ClipboardData(text: textToCopy));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teks diskusi disalin ke clipboard!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Icon(CupertinoIcons.share, size: 17, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- EMBEDDED RECIPE CARD ---
  Widget _buildEmbeddedRecipeCard(SocialPost post) {
    final snap = post.recipeSnapshot!;
    final title = snap['title']?.toString() ?? 'Resep Seduh';
    final method = snap['method']?.toString() ?? 'Hario V60 02';
    final coffee = snap['coffeeWeightGrams'] ?? 15;
    final water = snap['totalWaterWeightGrams'] ?? 225;
    final temp = snap['waterTempCelsius'] ?? 92;
    final notes = snap['tastingNotes']?.toString() ?? '';

    final ratio = (water is num && coffee is num && coffee > 0)
        ? (water / coffee).toStringAsFixed(1)
        : '15.0';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCream.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4), width: 1.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(CupertinoIcons.drop_fill, color: AppTheme.primaryBrown, size: 13),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          method,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    if (snap['isCustom'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '✍️ Resep Kustom',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '🏆 World Recipe',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF9E6500)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // COPY RESEP BUTTON - CUKUP ICON COPY SAJA SESUAI INSTRUKSI USER
              Material(
                color: Colors.transparent,
                child: Tooltip(
                  message: 'Copy Resep',
                  child: InkWell(
                    onTap: () => _handleCopyRecipe(post),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.doc_on_clipboard_fill,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Judul Resep: Bisa turun ke baris baru jika card tidak cukup
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              height: 1.3,
            ),
            softWrap: true,
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          // Metric row: Wrap agar tidak overflow pada layar kecil
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _metricPill(CupertinoIcons.circle_grid_hex, '${coffee}g Kopi'),
              _metricPill(CupertinoIcons.drop, '${water}ml Air'),
              _metricPill(CupertinoIcons.gauge, '1:$ratio'),
              _metricPill(CupertinoIcons.thermometer, '$temp°C'),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: $notes',
              style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppTheme.primaryBrown),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  // --- HANDLE COPY RESEP ---
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

  // --- COMMENTS BOTTOM SHEET ---
  void _showCommentsSheet(SocialPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CommentsSheetWidget(post: post),
    );
  }

  // --- CREATE POST DIALOG ---
  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreatePostSheetWidget(onPostCreated: () => _loadFeed(force: true)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.chat_bubble_2, color: AppTheme.primaryBrown, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Diskusi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Jadilah yang pertama memulai diskusi kopi atau membagikan resep andalan Anda ke komunitas!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _showCreatePostDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              icon: const Icon(CupertinoIcons.add, size: 16, color: Colors.white),
              label: const Text('Buat Postingan Pertama', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${time.day}/${time.month}/${time.year}';
  }
}

// ================= COMMENTS SHEET WIDGET =================
class _CommentsSheetWidget extends StatefulWidget {
  final SocialPost post;
  const _CommentsSheetWidget({required this.post});

  @override
  State<_CommentsSheetWidget> createState() => _CommentsSheetWidgetState();
}

class _CommentsSheetWidgetState extends State<_CommentsSheetWidget> {
  List<SocialComment> _comments = [];
  bool _isLoading = true;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final list = await SocialService.getComments(widget.post.id);
    if (!mounted) return;
    setState(() {
      _comments = list;
      _isLoading = false;
    });
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final comment = await SocialService.addComment(widget.post.id, text);
    if (!mounted) return;

    if (comment != null) {
      widget.post.commentsCount++;
      setState(() {
        _comments.add(comment);
        _commentCtrl.clear();
        _isSending = false;
      });
    } else {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Komentar (${widget.post.commentsCount})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),

          // Comments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.chat_bubble, size: 36, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada komentar. Berikan tanggapan pertama!',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (ctx, idx) {
                          final c = _comments[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.bgCream,
                                  backgroundImage: c.authorAvatar.startsWith('assets/')
                                      ? AssetImage(c.authorAvatar) as ImageProvider
                                      : NetworkImage(c.authorAvatar),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgCream.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.authorName,
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c.content,
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Input Bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCream,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Tulis tanggapan atau saran seduh...',
                        hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSending ? null : _submitComment,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBrown),
                        )
                      : const Icon(CupertinoIcons.paperplane_fill, color: AppTheme.primaryBrown),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CREATE POST SHEET WIDGET =================
class _CreatePostSheetWidget extends StatefulWidget {
  final VoidCallback onPostCreated;
  const _CreatePostSheetWidget({required this.onPostCreated});

  @override
  State<_CreatePostSheetWidget> createState() => _CreatePostSheetWidgetState();
}

class _CreatePostSheetWidgetState extends State<_CreatePostSheetWidget> {
  final TextEditingController _contentCtrl = TextEditingController();
  List<dynamic> _availableRecipes = [];
  Map<String, dynamic>? _selectedRecipe;
  AuthUser? _currentUser;
  bool _isSubmitting = false;

  final List<String> _suggestedTags = [
    'V60',
    'Aeropress',
    'Origami',
    'JapaneseIced',
    'GayoWine',
    'Kintamani',
    'Sweetness',
    'ManualBrew',
    'Espresso',
  ];
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final list = await ApiService.getRecipes();
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _availableRecipes = list;
      _currentUser = user;
    });
  }

  Future<void> _openRecipePicker() async {
    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RecipePickerSheet(
        allRecipes: _availableRecipes,
        selectedRecipeId: _selectedRecipe?['id'] as int?,
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedRecipe = picked;
      });
    }
  }

  Future<void> _submitPost() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis isi postingan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Map<String, dynamic>? snap;
    if (_selectedRecipe != null) {
      snap = {
        'id': _selectedRecipe!['id'],
        'title': _selectedRecipe!['title'],
        'author': _selectedRecipe!['author'],
        'method': _selectedRecipe!['method'],
        'category': _selectedRecipe!['category'],
        'beanName': _selectedRecipe!['beanName'],
        'variety': _selectedRecipe!['variety'],
        'process': _selectedRecipe!['process'],
        'waterTempCelsius': _selectedRecipe!['waterTempCelsius'],
        'grindSize': _selectedRecipe!['grindSize'],
        'coffeeWeightGrams': _selectedRecipe!['coffeeWeightGrams'],
        'totalWaterWeightGrams': _selectedRecipe!['totalWaterWeightGrams'],
        'tastingNotes': _selectedRecipe!['tastingNotes'],
        'steps': _selectedRecipe!['steps'],
        'description': _selectedRecipe!['description'],
        'isCustom': _selectedRecipe!['isCustom'] == true,
      };
    }

    final post = await SocialService.createPost(
      content: content,
      recipeSnapshot: snap,
      tags: _selectedTags.toList(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (post != null) {
      Navigator.pop(context);
      widget.onPostCreated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Postingan berhasil dibagikan ke Social Coffee!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Buat Postingan Baru',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),

          // User info header
          _buildUserHeader(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                // Post text input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Bagikan pengalaman seduh, tips ekstraksi, racikan beans, atau diskusikan resep kopi Anda...',
                      hintStyle: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    maxLines: 5,
                    minLines: 3,
                    style: const TextStyle(fontSize: 13.5, height: 1.35),
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive Recipe Attachment Section
                _buildRecipeAttachmentSection(),
                const SizedBox(height: 20),

                // Topic Tags
                const Text('Pilih Tag Topik:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _suggestedTags.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    return ChoiceChip(
                      label: Text('#$tag', style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? Colors.white : AppTheme.textDark)),
                      selected: selected,
                      selectedColor: AppTheme.primaryBrown,
                      backgroundColor: AppTheme.bgCream,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(CupertinoIcons.paperplane_fill, size: 18),
                label: const Text('Publikasikan ke Social Coffee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    final username = _currentUser?.username ?? 'Barista';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'B';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryBrown,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Membagikan ke Social Coffee',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeAttachmentSection() {
    if (_selectedRecipe == null) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCream.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryBrown.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _openRecipePicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.book_fill, color: AppTheme.primaryBrown, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lampirkan Resep Seduh',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pilih dari 140+ World Recipe atau Resep Kustom Anda',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.plus, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Pilih Resep',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final snap = _selectedRecipe!;
    final title = snap['title']?.toString() ?? 'Resep Seduh';
    final author = snap['author']?.toString() ?? 'Barista';
    final cleanAuthor = BaristaUtils.cleanName(author);
    final method = snap['method']?.toString() ?? snap['category']?.toString() ?? 'V60';
    final coffee = snap['coffeeWeightGrams'] ?? 15;
    final water = snap['totalWaterWeightGrams'] ?? 225;
    final temp = snap['waterTempCelsius'] ?? 92;
    final ratio = (water is num && coffee is num && coffee > 0)
        ? (water / coffee).toStringAsFixed(1)
        : '15.0';
    final isCustom = snap['isCustom'] == true || (snap['id'] is int && (snap['id'] as int) >= 500);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCustom
              ? const Color(0xFF2E7D32).withValues(alpha: 0.35)
              : AppTheme.accentGold.withValues(alpha: 0.5),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (isCustom)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.person_crop_circle_badge_checkmark, size: 12, color: Color(0xFF2E7D32)),
                              SizedBox(width: 4),
                              Text(
                                'Resep Kustom Anda',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.rosette, size: 12, color: Color(0xFF9E6500)),
                              SizedBox(width: 4),
                              Text(
                                '🏆 World Recipe',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF9E6500)),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          method,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: _openRecipePicker,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 12, color: AppTheme.primaryBrown),
                      label: const Text(
                        'Ganti',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 18, color: AppTheme.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _selectedRecipe = null),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                height: 1.3,
              ),
              softWrap: true,
              maxLines: 4,
            ),
            if (cleanAuthor.isNotEmpty && cleanAuthor != 'Barista') ...[
              const SizedBox(height: 2),
              Text(
                cleanAuthor,
                style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _metricMini(CupertinoIcons.circle_grid_hex, '${coffee}g', 'Kopi'),
                  _metricMini(CupertinoIcons.drop, '${water}ml', 'Air'),
                  _metricMini(CupertinoIcons.gauge, '1:$ratio', 'Rasio'),
                  _metricMini(CupertinoIcons.thermometer, '$temp°C', 'Suhu'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricMini(IconData icon, String val, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppTheme.primaryBrown),
            const SizedBox(width: 3),
            Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ],
    );
  }
}

// ================= RECIPE PICKER SHEET =================
class _RecipePickerSheet extends StatefulWidget {
  final List<dynamic> allRecipes;
  final int? selectedRecipeId;

  const _RecipePickerSheet({
    required this.allRecipes,
    this.selectedRecipeId,
  });

  @override
  State<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<_RecipePickerSheet> {
  int _selectedTab = 0; // 0: World Recipe, 1: Resep Saya
  String _searchQuery = '';
  String _selectedMethod = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _worldRecipes = [];
  final List<Map<String, dynamic>> _myRecipes = [];

  final List<String> _methods = [
    'Semua',
    'V60',
    'Aeropress',
    'Origami',
    'Kalita',
    'French Press',
    'Syphon',
    'Cold Brew',
    'Espresso',
  ];

  @override
  void initState() {
    super.initState();
    for (final r in widget.allRecipes) {
      if (r is Map) {
        final map = Map<String, dynamic>.from(r);
        final isCustom = map['isCustom'] == true || (map['id'] is int && (map['id'] as int) >= 500);
        if (isCustom) {
          _myRecipes.add(map);
        } else {
          _worldRecipes.add(map);
        }
      }
    }
    if (widget.selectedRecipeId != null) {
      final isSelCustom = _myRecipes.any((r) => r['id'] == widget.selectedRecipeId);
      if (isSelCustom) {
        _selectedTab = 1;
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredList {
    final pool = _selectedTab == 0 ? _worldRecipes : _myRecipes;
    return pool.where((recipe) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final title = (recipe['title'] ?? '').toString().toLowerCase();
        final author = (recipe['author'] ?? '').toString().toLowerCase();
        final bean = (recipe['beanName'] ?? '').toString().toLowerCase();
        final variety = (recipe['variety'] ?? '').toString().toLowerCase();
        final method = (recipe['method'] ?? recipe['category'] ?? '').toString().toLowerCase();
        if (!title.contains(q) && !author.contains(q) && !bean.contains(q) && !variety.contains(q) && !method.contains(q)) {
          return false;
        }
      }
      if (_selectedMethod != 'Semua') {
        final m = (recipe['method'] ?? recipe['category'] ?? '').toString().toLowerCase();
        if (!m.contains(_selectedMethod.toLowerCase())) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredList;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Top title bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Resep Kopi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'World Recipe Juara atau Resep Kustom Anda',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),

          // Segmented Tab Selector (World Recipe vs Resep Saya)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTab = 0);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? AppTheme.surfaceWhite : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedTab == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            Text(
                              'World Recipe (${_worldRecipes.length})',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.w500,
                                color: _selectedTab == 0 ? AppTheme.primaryBrown : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTab = 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? AppTheme.surfaceWhite : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedTab == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('✍️', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            Text(
                              'Resep Saya (${_myRecipes.length})',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.w500,
                                color: _selectedTab == 1 ? AppTheme.primaryBrown : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.bgCream.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.search, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Cari resep, barista, varietas, beans...',
                        hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 9),
                      ),
                      style: const TextStyle(fontSize: 12.5),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(CupertinoIcons.clear_circled_solid, size: 16, color: AppTheme.textMuted),
                    ),
                ],
              ),
            ),
          ),

          // Brewer Method Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _methods.map((m) {
                final isSel = _selectedMethod == m;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(m, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : AppTheme.textDark)),
                    selected: isSel,
                    selectedColor: AppTheme.primaryBrown,
                    backgroundColor: AppTheme.bgCream,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    onSelected: (val) {
                      if (val) setState(() => _selectedMethod = m);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 4),

          // Recipe Cards List
          Expanded(
            child: list.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _buildRecipeItemCard(list[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_selectedTab == 1 && _myRecipes.isEmpty) {
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
                child: const Icon(CupertinoIcons.book, size: 36, color: AppTheme.primaryBrown),
              ),
              const SizedBox(height: 14),
              const Text(
                'Belum Ada Resep Kustom',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Anda belum memiliki resep buatan sendiri. Anda bisa membuat resep baru di menu Toolkit > Jurnal Brew atau menyalin resep dari World Recipe!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.search, size: 36, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            const Text(
              'Tidak Ditemukan Resep',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Tidak ada resep yang sesuai dengan filter pencarian.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeItemCard(Map<String, dynamic> recipe) {
    final id = recipe['id'] as int?;
    final isSelected = id != null && id == widget.selectedRecipeId;
    final title = recipe['title']?.toString() ?? 'Resep Kopi';
    final author = recipe['author']?.toString() ?? 'Barista';
    final cleanAuthor = BaristaUtils.cleanName(author);
    final method = recipe['method']?.toString() ?? recipe['category']?.toString() ?? 'V60';
    final bean = recipe['beanName']?.toString() ?? '';
    final coffee = recipe['coffeeWeightGrams'] ?? 15;
    final water = recipe['totalWaterWeightGrams'] ?? 225;
    final temp = recipe['waterTempCelsius'] ?? 92;
    final ratio = (water is num && coffee is num && coffee > 0)
        ? (water / coffee).toStringAsFixed(1)
        : '15.0';
    final isCustom = recipe['isCustom'] == true || (id != null && id >= 500);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.accentGold.withValues(alpha: 0.08) : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.accentGold : AppTheme.primaryBrown.withValues(alpha: 0.12),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context, recipe);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar / Method Icon
                if (!isCustom)
                  BaristaAvatar(
                    imageUrl: BaristaUtils.imageUrlFromRecipe(recipe),
                    radius: 22,
                  )
                else
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      color: Color(0xFF2E7D32),
                      size: 22,
                    ),
                  ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              method,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (isCustom)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '✍️ Resep Kustom',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '🏆 World Recipe',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9E6500),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (cleanAuthor.isNotEmpty && cleanAuthor != 'Barista') ...[
                        const SizedBox(height: 2),
                        Text(
                          cleanAuthor,
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (bean.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          bean,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Parameter Row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _smallParamPill('⚖️ ${coffee}g'),
                          _smallParamPill('💧 ${water}ml'),
                          _smallParamPill('📐 1:$ratio'),
                          _smallParamPill('🌡️ $temp°C'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Check / Select indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppTheme.primaryBrown : AppTheme.bgCream,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    isSelected ? CupertinoIcons.checkmark : CupertinoIcons.add,
                    size: 14,
                    color: isSelected ? Colors.white : AppTheme.primaryBrown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallParamPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textDark),
      ),
    );
  }
}
