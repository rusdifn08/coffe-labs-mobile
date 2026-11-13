import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/social_thread_models.dart';
import '../controllers/social_profile_controllers.dart';
import 'thread_post_card.dart';

class KeepAliveProfileFeedTabView extends ConsumerStatefulWidget {
  final String targetUserOrUsername;
  final ProfileFeedTab tab;

  const KeepAliveProfileFeedTabView({
    super.key,
    required this.targetUserOrUsername,
    required this.tab,
  });

  @override
  ConsumerState<KeepAliveProfileFeedTabView> createState() =>
      _KeepAliveProfileFeedTabViewState();
}

class _KeepAliveProfileFeedTabViewState
    extends ConsumerState<KeepAliveProfileFeedTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final feedAsync = ref.watch(
      profileTabFeedControllerProvider(
        widget.targetUserOrUsername,
        widget.tab,
      ),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 320) {
          ref
              .read(
                profileTabFeedControllerProvider(
                  widget.targetUserOrUsername,
                  widget.tab,
                ).notifier,
              )
              .fetchNextPage();
        }
        return false;
      },
      child: RefreshIndicator(
        color: AppTheme.primaryBrown,
        onRefresh: () => ref
            .read(
              profileTabFeedControllerProvider(
                widget.targetUserOrUsername,
                widget.tab,
              ).notifier,
            )
            .refresh(),
        child: CustomScrollView(
          key: PageStorageKey<String>(
            'profile_tab_${widget.targetUserOrUsername}_${widget.tab.wireValue}',
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverOverlapInjector(
              handle:
                  NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            ...feedAsync.when(
              loading: () => const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ),
              ],
              error: (err, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _FeedErrorState(
                    message: 'Gagal memuat ${widget.tab.label}: $err',
                    onRetry: () => ref
                        .read(
                          profileTabFeedControllerProvider(
                            widget.targetUserOrUsername,
                            widget.tab,
                          ).notifier,
                        )
                        .refresh(),
                  ),
                ),
              ],
              data: (state) {
                if (state.items.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _FeedEmptyState(tab: widget.tab),
                    ),
                  ];
                }

                if (widget.tab == ProfileFeedTab.media) {
                  return _buildMediaSlivers(context, state);
                }
                return _buildThreadListSlivers(context, state);
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 88)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMediaSlivers(
    BuildContext context,
    CursorPaginatedThreadsState state,
  ) {
    final tiles = <({SocialThreadItem thread, MediaAttachmentItem media})>[];
    for (final thread in state.items) {
      for (final media in thread.mediaUrls) {
        tiles.add((thread: thread, media: media));
      }
    }

    if (tiles.isEmpty) {
      return _buildThreadListSlivers(context, state);
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, idx) {
            final entry = tiles[idx];
            return InkWell(
              onTap: () => context.push('/social/thread/${entry.thread.id}'),
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    entry.media.url.startsWith('assets/')
                        ? Image.asset(
                            entry.media.url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _mediaPlaceholder(),
                          )
                        : Image.network(
                            entry.media.url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _mediaPlaceholder(),
                          ),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.heart_fill,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${entry.thread.likesCount}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      if (state.isLoadingNextPage)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBrown),
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildThreadListSlivers(
    BuildContext context,
    CursorPaginatedThreadsState state,
  ) {
    final notifier = ref.read(
      profileTabFeedControllerProvider(
        widget.targetUserOrUsername,
        widget.tab,
      ).notifier,
    );

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        sliver: SliverList.separated(
          itemCount: state.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final thread = state.items[idx];
            return ThreadPostCard(
              thread: thread,
              onTapThread: () => context.push('/social/thread/${thread.id}'),
              onTapAuthor: () {
                if (thread.authorUsername != widget.targetUserOrUsername &&
                    thread.authorId != widget.targetUserOrUsername) {
                  context.push(
                    '/social/profile/${Uri.encodeComponent(thread.authorUsername)}',
                  );
                }
              },
              onTapQuotedThread: thread.quotedPreview != null
                  ? () => context
                      .push('/social/thread/${thread.quotedPreview!.id}')
                  : null,
              onToggleLike: () => notifier.toggleLikeOptimistic(thread.id),
              onToggleRepost: () => notifier.toggleRepostOptimistic(thread.id),
              onTryRecipe: (card) => notifier.onTryRecipeTapped(
                context: context,
                card: card,
                threadId: thread.id,
              ),
            );
          },
        ),
      ),
      if (state.isLoadingNextPage)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBrown),
            ),
          ),
        )
      else if (!state.hasMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: Center(
              child: Text(
                'Semua aktivitas pada tab ini sudah ditampilkan.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _mediaPlaceholder() {
    return Container(
      color: AppTheme.bgCream,
      alignment: Alignment.center,
      child: const Icon(CupertinoIcons.photo, color: AppTheme.textMuted),
    );
  }
}

class _FeedEmptyState extends StatelessWidget {
  final ProfileFeedTab tab;
  const _FeedEmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final desc = switch (tab) {
      ProfileFeedTab.allThreads => 'Belum ada thread atau diskusi yang diposting.',
      ProfileFeedTab.brewLogs => 'Belum ada catatan log seduhan atau kurva tuangan.',
      ProfileFeedTab.createdRecipes => 'Belum ada resep racikan yang dibagikan.',
      ProfileFeedTab.media => 'Belum ada foto seduhan atau kemasan kopi.',
    };

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.sparkles,
            size: 36,
            color: AppTheme.lightBrown.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FeedErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(CupertinoIcons.refresh),
            label: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }
}
