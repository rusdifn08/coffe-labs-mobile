import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../communities/domain/community_models.dart';
import '../../../communities/presentation/controllers/communities_controllers.dart';
import '../../../communities/presentation/widgets/create_club_sheet.dart';
import '../../../communities/presentation/widgets/join_club_by_secret_id_sheet.dart';
import '../../../social_profile_feed/domain/models/social_thread_models.dart';
import '../../../social_profile_feed/presentation/widgets/thread_post_card.dart';
import '../../domain/explore_feed_models.dart';
import '../controllers/explore_feed_controllers.dart';

class SocialExploreAndFeedScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const SocialExploreAndFeedScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<SocialExploreAndFeedScreen> createState() =>
      _SocialExploreAndFeedScreenState();
}

class _SocialExploreAndFeedScreenState
    extends ConsumerState<SocialExploreAndFeedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _methodFilter = 'ALL';
  String _clubQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        title: const Text(
          'Social Coffee Explore',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        actions: [
          IconButton(
            tooltip: 'Gabung Club dengan Secret ID',
            icon: const Icon(CupertinoIcons.lock_shield_fill,
                color: AppTheme.primaryBrown),
            onPressed: () => JoinClubBySecretIdSheet.show(context),
          ),
          IconButton(
            tooltip: 'Dirikan Club Baru',
            icon: const Icon(CupertinoIcons.plus_circle_fill,
                color: AppTheme.accentAmber),
            onPressed: () => CreateClubSheet.show(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBrown,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.accentAmber,
          tabs: const [
            Tab(text: '✨ For You'),
            Tab(text: '🔥 Trending'),
            Tab(text: '☕ Coffee Clubs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ForYouTab(
            selectedMethod: _methodFilter,
            onSelectMethod: (m) => setState(() => _methodFilter = m),
          ),
          const _TrendingTab(),
          _ClubsDirectoryTab(
            searchQuery: _clubQuery,
            onSearchChanged: (q) => setState(() => _clubQuery = q),
          ),
        ],
      ),
    );
  }
}

class _ForYouTab extends ConsumerWidget {
  final String selectedMethod;
  final ValueChanged<String> onSelectMethod;

  const _ForYouTab({
    required this.selectedMethod,
    required this.onSelectMethod,
  });

  static const _filters = ['ALL', 'V60', 'Espresso', 'Natural', 'Ethiopia', 'Gayo'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFeed =
        ref.watch(forYouFeedControllerProvider(methodFilter: selectedMethod));
    final asyncClubs = ref.watch(recommendedClubsProvider);

    return asyncFeed.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat For You: $err'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => ref
                    .read(forYouFeedControllerProvider(methodFilter: selectedMethod)
                        .notifier)
                    .refresh(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      data: (feed) => RefreshIndicator(
        onRefresh: () => ref
            .read(forYouFeedControllerProvider(methodFilter: selectedMethod)
                .notifier)
            .refresh(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (feed.userTopTastes.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profil Selera Kopimu',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: feed.userTopTastes
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentAmber.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBrown,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, idx) {
                  final f = _filters[idx];
                  final selected = selectedMethod == f;
                  return ChoiceChip(
                    label: Text(f == 'ALL' ? 'Semua' : f),
                    selected: selected,
                    selectedColor: AppTheme.primaryBrown,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => onSelectMethod(f),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            asyncClubs.maybeWhen(
              data: (clubsRes) => clubsRes.items.isEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: clubsRes.items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, idx) => _RecommendedClubMiniCard(
                          club: clubsRes.items[idx],
                        ),
                      ),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            if (feed.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('Belum ada postingan sesuai filter ini.'),
                ),
              )
            else
              ...feed.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RecommendedThreadCard(
                    item: item,
                    onLike: () => ref
                        .read(forYouFeedControllerProvider(
                                methodFilter: selectedMethod)
                            .notifier)
                        .toggleLike(item.thread.id),
                    onRepost: () => ref
                        .read(forYouFeedControllerProvider(
                                methodFilter: selectedMethod)
                            .notifier)
                        .toggleRepost(item.thread.id),
                    onTryRecipe: (card) => ref
                        .read(forYouFeedControllerProvider(
                                methodFilter: selectedMethod)
                            .notifier)
                        .onTryRecipeTapped(
                          context: context,
                          card: card,
                          threadId: item.thread.id,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrendingTab extends ConsumerWidget {
  const _TrendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTrending = ref.watch(trendingFeedProvider);
    return asyncTrending.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Gagal memuat Trending: $err')),
      data: (res) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(trendingFeedProvider),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: res.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, idx) {
            final item = res.items[idx];
            return _RecommendedThreadCard(
              item: item,
              onLike: () => ref
                  .read(forYouFeedControllerProvider().notifier)
                  .toggleLike(item.thread.id),
              onRepost: () => ref
                  .read(forYouFeedControllerProvider().notifier)
                  .toggleRepost(item.thread.id),
              onTryRecipe: (card) => ref
                  .read(forYouFeedControllerProvider().notifier)
                  .onTryRecipeTapped(
                    context: context,
                    card: card,
                    threadId: item.thread.id,
                  ),
            );
          },
        ),
      ),
    );
  }
}

class _ClubsDirectoryTab extends ConsumerWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _ClubsDirectoryTab({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncClubs = ref.watch(
      exploreCommunitiesControllerProvider(query: searchQuery),
    );
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Cari club kopi V60, Roastery, atau Origin...',
            prefixIcon: const Icon(CupertinoIcons.search),
            filled: true,
            fillColor: AppTheme.surfaceWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderWarm),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => JoinClubBySecretIdSheet.show(context),
                icon: const Icon(CupertinoIcons.ticket_fill, size: 16),
                label: const Text('Pakai Secret ID'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBrown,
                  side: const BorderSide(color: AppTheme.borderWarm),
                  backgroundColor: AppTheme.surfaceWhite,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => CreateClubSheet.show(context),
                icon: const Icon(CupertinoIcons.add, size: 16),
                label: const Text('Buat Club'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        asyncClubs.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Center(child: Text('Gagal memuat daftar club: $err')),
          data: (res) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (res.myClubs.isNotEmpty) ...[
                const Text(
                  'Club Saya',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...res.myClubs.map((c) => _ClubDirectoryCard(club: c)),
                const SizedBox(height: 14),
              ],
              const Text(
                'Jelajahi Coffee Clubs',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              ...res.discoverClubs.map((c) => _ClubDirectoryCard(club: c)),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecommendedClubMiniCard extends StatelessWidget {
  final CommunitySummary club;
  const _RecommendedClubMiniCard({required this.club});

  @override
  Widget build(BuildContext context) {
    final pct = (club.matchScorePct ?? 75).round();
    return GestureDetector(
      onTap: () => context.push('/social/clubs/${club.id}'),
      child: Container(
        width: 215,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderWarm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$pct% match',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              club.description.isEmpty ? '@${club.handleSlug}' : club.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
            ),
            Text(
              '${club.membersCount} anggota • ${club.privacyLevel}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubDirectoryCard extends StatelessWidget {
  final CommunitySummary club;
  const _ClubDirectoryCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppTheme.surfaceWhite,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.14),
          child: const Icon(CupertinoIcons.person_3_fill,
              color: AppTheme.primaryBrown),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                club.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (club.privacyLevel != 'PUBLIC')
              const Icon(CupertinoIcons.lock_fill,
                  size: 14, color: AppTheme.primaryBrown),
          ],
        ),
        subtitle: Text(
          '${club.membersCount} anggota • ${club.sharedRecipesCount} resep • ${club.totalClubXp} Club XP\n${club.description}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
        onTap: () => context.push('/social/clubs/${club.id}'),
      ),
    );
  }
}

class _RecommendedThreadCard extends StatelessWidget {
  final RecommendedThreadItem item;
  final VoidCallback onLike;
  final VoidCallback onRepost;
  final ValueChanged<InteractiveRecipeCardAttachment> onTryRecipe;

  const _RecommendedThreadCard({
    required this.item,
    required this.onLike,
    required this.onRepost,
    required this.onTryRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Wrap(
            spacing: 6,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.reasonBadge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
              if (item.communityName != null)
                ActionChip(
                  label: Text(item.communityName!),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: item.communityId == null
                      ? null
                      : () => context.push('/social/clubs/${item.communityId}'),
                ),
            ],
          ),
        ),
        ThreadPostCard(
          thread: item.thread,
          onTapThread: () => context.push('/social/threads/${item.thread.id}'),
          onTapAuthor: () => context.push(
            '/social/profile/${Uri.encodeComponent(item.thread.authorUsername)}',
          ),
          onTapReply: () => context.push('/social/threads/${item.thread.id}'),
          onToggleLike: onLike,
          onToggleRepost: onRepost,
          onTryRecipe: (card) => onTryRecipe(card),
        ),
      ],
    );
  }
}
