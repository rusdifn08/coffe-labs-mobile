import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../notifications/presentation/widgets/notification_bell_button.dart';
import '../../data/services/social_profile_api_service.dart';
import '../../domain/models/social_profile_models.dart';
import '../../domain/models/social_thread_models.dart';
import '../controllers/social_profile_controllers.dart';
import '../widgets/create_thread_sheet.dart';
import '../widgets/thread_post_card.dart';

class BaristaDirectoryScreen extends ConsumerStatefulWidget {
  const BaristaDirectoryScreen({super.key});

  @override
  ConsumerState<BaristaDirectoryScreen> createState() =>
      _BaristaDirectoryScreenState();
}

class _BaristaDirectoryScreenState
    extends ConsumerState<BaristaDirectoryScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  int _modeIndex = 0; // 0 = Barista Directory, 1 = Global Threads
  String _timelineScope = 'for_you';
  Future<CursorPaginatedResult<SocialThreadItem>>? _timelineFuture;

  @override
  void initState() {
    super.initState();
    _reloadTimeline();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (mounted) setState(() => _query = val.trim());
    });
  }

  void _reloadTimeline() {
    _timelineFuture = ref
        .read(socialProfileApiServiceProvider)
        .getGlobalTimeline(scope: _timelineScope, limit: 25);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Jelajah & Stalking Barista'),
        actions: [
          IconButton(
            tooltip: 'Explore For You & Coffee Clubs',
            icon: const Icon(CupertinoIcons.sparkles),
            onPressed: () => context.push('/social/explore'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: NotificationBellButton(compact: true),
          ),
          IconButton(
            tooltip: 'Profil Publik Saya',
            icon: const Icon(CupertinoIcons.person_crop_circle_fill),
            onPressed: () => context.push('/social/profile/me'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBrown,
        foregroundColor: Colors.white,
        onPressed: () async {
          final created = await CreateThreadSheet.show(context);
          if (created != null && mounted) {
            setState(_reloadTimeline);
          }
        },
        icon: const Icon(CupertinoIcons.add),
        label: const Text('Buat Thread'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  icon: Icon(CupertinoIcons.person_2_fill, size: 16),
                  label: Text('Cari Barista'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: Icon(CupertinoIcons.flame_fill, size: 16),
                  label: Text('Linimasa Thread'),
                ),
              ],
              selected: {_modeIndex},
              onSelectionChanged: (next) {
                setState(() => _modeIndex = next.first);
              },
            ),
          ),
          Expanded(
            child: _modeIndex == 0
                ? _buildDirectoryTab(context)
                : _buildGlobalTimelineTab(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryTab(BuildContext context) {
    final directoryAsync = ref.watch(baristaDirectorySearchProvider(_query));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari barista, @username, atau rank...',
              prefixIcon: const Icon(CupertinoIcons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(CupertinoIcons.clear_circled_solid),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surfaceWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.borderWarm),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: InkWell(
            onTap: () => context.push('/social/profile/me'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A2E1B), Color(0xFF7D5132)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    color: Color(0xFFFDE68A),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buka Showcase Profil Publik Saya',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          'Lihat level XP, badge langka, & log seduhan terbarumu',
                          style: TextStyle(
                            color: Color(0xFFE7DDD3),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: directoryAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBrown),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Gagal memuat direktori barista: $err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(baristaDirectorySearchProvider(_query)),
                      child: const Text('Muat Ulang'),
                    ),
                  ],
                ),
              ),
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada barista yang cocok dengan pencarianmu.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                );
              }
              return RefreshIndicator(
                color: AppTheme.primaryBrown,
                onRefresh: () async =>
                    ref.invalidate(baristaDirectorySearchProvider(_query)),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) =>
                      _DirectoryBaristaCard(entry: entries[idx]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalTimelineTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('For You'),
                selected: _timelineScope == 'for_you',
                onSelected: (_) => setState(() {
                  _timelineScope = 'for_you';
                  _reloadTimeline();
                }),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Following'),
                selected: _timelineScope == 'following',
                onSelected: (_) => setState(() {
                  _timelineScope = 'following';
                  _reloadTimeline();
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<CursorPaginatedResult<SocialThreadItem>>(
            future: _timelineFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryBrown,
                  ),
                );
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    'Gagal memuat linimasa: ${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                );
              }
              final items = snap.data?.items ?? const [];
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    _timelineScope == 'following'
                        ? 'Belum ada postingan dari akun yang kamu ikuti.'
                        : 'Linimasa masih sepi. Yuk bagikan seduhanmu!',
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppTheme.primaryBrown,
                onRefresh: () async => setState(_reloadTimeline),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 92),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final thread = items[idx];
                    return ThreadPostCard(
                      thread: thread,
                      onTapThread: () =>
                          context.push('/social/thread/${thread.id}'),
                      onTapAuthor: () => context.push(
                        '/social/profile/${Uri.encodeComponent(thread.authorUsername)}',
                      ),
                      onToggleLike: () async {
                        await ref
                            .read(socialProfileApiServiceProvider)
                            .toggleLike(thread.id);
                        if (mounted) setState(_reloadTimeline);
                      },
                      onToggleRepost: () async {
                        await ref
                            .read(socialProfileApiServiceProvider)
                            .toggleRepost(thread.id);
                        if (mounted) setState(_reloadTimeline);
                      },
                      onTryRecipe: (card) => ref
                          .read(
                            profileTabFeedControllerProvider(
                              thread.authorUsername,
                              ProfileFeedTab.allThreads,
                            ).notifier,
                          )
                          .onTryRecipeTapped(
                            context: context,
                            card: card,
                            threadId: thread.id,
                          ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DirectoryBaristaCard extends StatelessWidget {
  final ProfileDirectoryEntry entry;

  const _DirectoryBaristaCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final brew = entry.recentBrewSnapshot;

    return Material(
      color: AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push(
          '/social/profile/${Uri.encodeComponent(entry.username)}',
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        AppTheme.primaryBrown.withValues(alpha: 0.14),
                    child: Text(
                      entry.displayName.isNotEmpty
                          ? entry.displayName[0].toUpperCase()
                          : 'B',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
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
                                entry.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.bgCream,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: AppTheme.primaryBrown
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                'Lv.${entry.baristaLevel} • ${entry.baristaRankTitle}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${entry.username} • ${entry.followersCount} followers • ${entry.totalThreadsCount} thread',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
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
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
              if (entry.bio.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
              if (brew != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.flame_fill,
                        size: 13,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Terakhir menyeduh ${brew.beanName} (${brew.method})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
