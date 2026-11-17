import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../communities/domain/community_models.dart';
import '../../../communities/presentation/controllers/communities_controllers.dart';
import '../../../communities/presentation/widgets/create_club_sheet.dart';
import '../../../communities/presentation/widgets/join_club_by_secret_id_sheet.dart';
import '../../../communities/presentation/widgets/pending_club_invitations_section.dart';
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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Coffee Club',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBrown,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.accentAmber,
          tabs: [
            const Tab(text: 'Coffee Club'),
            Tab(
              icon: Tooltip(
                message: 'Trending',
                child: Semantics(
                  label: 'Trending',
                  button: true,
                  child: const _UniqueCoffeeTrendingIcon(),
                ),
              ),
            ),
            Tab(
              icon: Tooltip(
                message: 'For You',
                child: Semantics(
                  label: 'For You',
                  button: true,
                  child: const _UniqueCoffeeForYouIcon(),
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ClubsDirectoryTab(
            searchQuery: _clubQuery,
            onSearchChanged: (q) => setState(() => _clubQuery = q),
          ),
          const _TrendingTab(),
          _ForYouTab(
            selectedMethod: _methodFilter,
            onSelectMethod: (m) => setState(() => _methodFilter = m),
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

class _ClubsDirectoryTab extends ConsumerStatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _ClubsDirectoryTab({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  ConsumerState<_ClubsDirectoryTab> createState() => _ClubsDirectoryTabState();
}

class _ClubsDirectoryTabState extends ConsumerState<_ClubsDirectoryTab> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _ClubsDirectoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.value = TextEditingValue(
        text: widget.searchQuery,
        selection: TextSelection.collapsed(offset: widget.searchQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncClubs = ref.watch(
      exploreCommunitiesControllerProvider(query: widget.searchQuery),
    );
    return RefreshIndicator(
      color: AppTheme.primaryBrown,
      onRefresh: () async {
        ref.invalidate(pendingClubInvitationsProvider);
        await ref
            .read(
              exploreCommunitiesControllerProvider(query: widget.searchQuery)
                  .notifier,
            )
            .refresh();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBrown,
                  Color.lerp(AppTheme.primaryBrown, Colors.black, 0.14) ??
                      AppTheme.primaryBrown,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const _UniqueCoffeeClubGuildIcon(),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'COFFEE CLUB',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppTheme.accentGold,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Komunitas & Basecamp Barista',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.sparkles,
                        size: 11,
                        color: AppTheme.accentGold,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Hub',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const PendingClubInvitationsSection(),
          TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari Coffee Club V60, Roastery, atau Origin...',
              hintStyle: const TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
              prefixIcon: const Icon(CupertinoIcons.search, size: 19),
              suffixIcon: widget.searchQuery.isNotEmpty
                  ? IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(
                        CupertinoIcons.clear_circled_solid,
                        size: 18,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surfaceWhite,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.borderWarm),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.borderWarm),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppTheme.primaryBrown, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => JoinClubBySecretIdSheet.show(context),
                  icon: const _JoinClubKeyPassIcon(),
                  label: const Text(
                    'Join Club',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                    side: const BorderSide(color: AppTheme.borderWarm),
                    backgroundColor: AppTheme.surfaceWhite,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => CreateClubSheet.show(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'New Club',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          asyncClubs.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBrown),
              ),
            ),
            error: (err, _) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: Column(
                children: [
                  Text(
                    err.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(
                      exploreCommunitiesControllerProvider(query: widget.searchQuery),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Muat Ulang'),
                  ),
                ],
              ),
            ),
            data: (res) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (res.myClubs.isNotEmpty) ...[
                  const Text(
                    'Coffee Club Saya',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...res.myClubs.map((c) => _ClubDirectoryCard(club: c)),
                  const SizedBox(height: 14),
                ],
                const Text(
                  'Jelajahi Coffee Club',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                if (res.discoverClubs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderWarm),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const _UniqueCoffeeClubGuildIcon(
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.searchQuery.trim().isNotEmpty
                              ? 'Tidak ada Coffee Club yang cocok dengan "${widget.searchQuery}".'
                              : 'Belum ada Coffee Club tersedia.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.searchQuery.trim().isNotEmpty
                              ? 'Coba kata kunci lain atau buat grup seduh baru.'
                              : 'Mulai grup seduh pertamamu atau masukkan kode undangan club.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        if (widget.searchQuery.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged('');
                            },
                            child: const Text('Reset Pencarian'),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  ...res.discoverClubs.map((c) => _ClubDirectoryCard(club: c)),
              ],
            ),
          ),
        ],
      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppTheme.primaryBrown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const _UniqueCoffeeClubGuildIcon(color: AppTheme.primaryBrown),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                club.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            if (club.privacyLevel != 'PUBLIC') ...[
              const SizedBox(width: 4),
              const Icon(
                CupertinoIcons.lock_fill,
                size: 13,
                color: AppTheme.primaryBrown,
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${club.membersCount} anggota • ${club.sharedRecipesCount} resep',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
        ),
        trailing: club.isMember
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              )
            : const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: AppTheme.textMuted,
              ),
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

/// Ikon unik eksklusif Tab Trending: Gelombang Roast-Heat & Denyut Espresso.
class _UniqueCoffeeTrendingIcon extends StatelessWidget {
  const _UniqueCoffeeTrendingIcon();

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? AppTheme.primaryBrown;
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _TrendingWaveCupPainter(color)),
    );
  }
}

class _TrendingWaveCupPainter extends CustomPainter {
  final Color color;
  const _TrendingWaveCupPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Api / gelombang kenaikan trending di atas cangkir seduh
    final pulse = Path()
      ..moveTo(size.width * 0.22, size.height * 0.56)
      ..lineTo(size.width * 0.40, size.height * 0.36)
      ..lineTo(size.width * 0.54, size.height * 0.46)
      ..lineTo(size.width * 0.78, size.height * 0.18);
    canvas.drawPath(pulse, stroke);

    // Ujung panah naik
    final arrow = Path()
      ..moveTo(size.width * 0.63, size.height * 0.18)
      ..lineTo(size.width * 0.78, size.height * 0.18)
      ..lineTo(size.width * 0.78, size.height * 0.33);
    canvas.drawPath(arrow, stroke);

    // Wadah roast-saucer minimalis di bawah gelombang
    final cup = Path()
      ..moveTo(size.width * 0.20, size.height * 0.70)
      ..lineTo(size.width * 0.80, size.height * 0.70)
      ..quadraticBezierTo(
        size.width * 0.74,
        size.height * 0.88,
        size.width * 0.50,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.26,
        size.height * 0.88,
        size.width * 0.20,
        size.height * 0.70,
      );
    canvas.drawPath(cup, stroke);
  }

  @override
  bool shouldRepaint(covariant _TrendingWaveCupPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Ikon unik eksklusif Tab For You: Kerucut V60 Personal & Bintang Aroma Selera.
class _UniqueCoffeeForYouIcon extends StatelessWidget {
  const _UniqueCoffeeForYouIcon();

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? AppTheme.primaryBrown;
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _ForYouPourStarPainter(color)),
    );
  }
}

class _ForYouPourStarPainter extends CustomPainter {
  final Color color;
  const _ForYouPourStarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Bintang aroma 4-sisi (personal taste match)
    final star = Path()
      ..moveTo(size.width * 0.50, size.height * 0.10)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.25,
        size.width * 0.67,
        size.height * 0.27,
      )
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.29,
        size.width * 0.50,
        size.height * 0.44,
      )
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.29,
        size.width * 0.33,
        size.height * 0.27,
      )
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.25,
        size.width * 0.50,
        size.height * 0.10,
      );
    canvas.drawPath(star, fill);

    // Corong dripper V60 simetris & tatakan personal
    final cone = Path()
      ..moveTo(size.width * 0.21, size.height * 0.50)
      ..lineTo(size.width * 0.79, size.height * 0.50)
      ..lineTo(size.width * 0.56, size.height * 0.80)
      ..lineTo(size.width * 0.44, size.height * 0.80)
      ..close();
    canvas.drawPath(cone, stroke);

    canvas.drawLine(
      Offset(size.width * 0.30, size.height * 0.88),
      Offset(size.width * 0.70, size.height * 0.88),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ForYouPourStarPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Ikon kustom unik khusus kartu Coffee Club: Perisai Biji Kopi & Lingkaran Persaudaraan.
class _UniqueCoffeeClubGuildIcon extends StatelessWidget {
  final Color color;
  const _UniqueCoffeeClubGuildIcon({this.color = AppTheme.accentGold});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _CoffeeClubGuildPainter(color)),
    );
  }
}

class _CoffeeClubGuildPainter extends CustomPainter {
  final Color color;
  const _CoffeeClubGuildPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Bingkai heksagon/crest club kopi simetris
    final crest = Path()
      ..moveTo(size.width * 0.50, size.height * 0.08)
      ..lineTo(size.width * 0.86, size.height * 0.25)
      ..lineTo(size.width * 0.86, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.86,
        size.height * 0.83,
        size.width * 0.50,
        size.height * 0.93,
      )
      ..quadraticBezierTo(
        size.width * 0.14,
        size.height * 0.83,
        size.width * 0.14,
        size.height * 0.62,
      )
      ..lineTo(size.width * 0.14, size.height * 0.25)
      ..close();
    canvas.drawPath(crest, stroke);

    // Biji kopi sentral + belahan S khas sangrai
    final beanRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.51),
      width: size.width * 0.34,
      height: size.height * 0.44,
    );
    canvas.drawOval(beanRect, stroke);

    final seam = Path()
      ..moveTo(size.width * 0.51, size.height * 0.31)
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.43,
        size.width * 0.58,
        size.height * 0.58,
        size.width * 0.49,
        size.height * 0.71,
      );
    canvas.drawPath(seam, stroke);
  }

  @override
  bool shouldRepaint(covariant _CoffeeClubGuildPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Ikon profesional tombol Join Club: Lencana Kunci Akses & Undangan.
class _JoinClubKeyPassIcon extends StatelessWidget {
  const _JoinClubKeyPassIcon();

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? AppTheme.primaryBrown;
    return SizedBox(
      width: 17,
      height: 17,
      child: CustomPaint(painter: _JoinClubKeyPassPainter(color)),
    );
  }
}

class _JoinClubKeyPassPainter extends CustomPainter {
  final Color color;
  const _JoinClubKeyPassPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Kepala kunci lingkaran presisi
    canvas.drawCircle(
      Offset(size.width * 0.32, size.height * 0.50),
      size.width * 0.20,
      stroke,
    );

    // Batang kunci akses & gerigi elegan
    final shaft = Path()
      ..moveTo(size.width * 0.52, size.height * 0.50)
      ..lineTo(size.width * 0.90, size.height * 0.50)
      ..lineTo(size.width * 0.90, size.height * 0.68)
      ..moveTo(size.width * 0.72, size.height * 0.50)
      ..lineTo(size.width * 0.72, size.height * 0.64);
    canvas.drawPath(shaft, stroke);
  }

  @override
  bool shouldRepaint(covariant _JoinClubKeyPassPainter oldDelegate) =>
      oldDelegate.color != color;
}
