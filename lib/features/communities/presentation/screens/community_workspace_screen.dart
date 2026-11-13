import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../explore_feed/presentation/controllers/explore_feed_controllers.dart';
import '../../../social_chat/presentation/screens/social_coffee_chat_room_screen.dart';
import '../../../social_graph/presentation/widgets/smart_follow_follback_button.dart';
import '../../../social_profile_feed/domain/models/social_thread_models.dart';
import '../../../social_profile_feed/presentation/controllers/social_profile_controllers.dart';
import '../../../social_profile_feed/presentation/widgets/thread_post_card.dart';
import '../../domain/community_models.dart';
import '../controllers/communities_controllers.dart';
import '../widgets/share_club_invite_modal.dart';

class CommunityWorkspaceScreen extends ConsumerStatefulWidget {
  final String communityId;

  const CommunityWorkspaceScreen({super.key, required this.communityId});

  @override
  ConsumerState<CommunityWorkspaceScreen> createState() =>
      _CommunityWorkspaceScreenState();
}

class _CommunityWorkspaceScreenState
    extends ConsumerState<CommunityWorkspaceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedConversationId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openCreatePostDialog() async {
    final ctrl = TextEditingController();
    var kind = 'STANDARD_POST';
    final posted = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppTheme.bgCream,
          title: const Text('Bagikan di Club (+25 Club XP)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: kind,
                items: const [
                  DropdownMenuItem(value: 'STANDARD_POST', child: Text('Diskusi / Thread')),
                  DropdownMenuItem(value: 'BREW_LOG', child: Text('Catatan Seduh (Brew Log)')),
                  DropdownMenuItem(value: 'CREATED_RECIPE', child: Text('Share Resep')),
                ],
                onChanged: (v) => setModalState(() => kind = v ?? 'STANDARD_POST'),
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ceritakan ekstraksi, rasio V60, atau catatan rasa...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
              ),
              child: const Text('Terbitkan'),
            ),
          ],
        ),
      ),
    );
    final text = ctrl.text.trim();
    ctrl.dispose();
    if (posted != true || text.isEmpty) return;

    try {
      await ref
          .read(communityWorkspaceControllerProvider(widget.communityId).notifier)
          .createPost(bodyText: text, kind: kind);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan club diterbitkan (+25 Club XP)!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncWs = ref.watch(
      communityWorkspaceControllerProvider(widget.communityId),
    );

    return asyncWs.when(
      loading: () => const Scaffold(
        backgroundColor: AppTheme.bgCream,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppTheme.bgCream,
        appBar: AppBar(title: const Text('Coffee Club')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.lock_fill,
                    size: 46, color: AppTheme.primaryBrown),
                const SizedBox(height: 12),
                Text(
                  '$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textDark),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(
                    communityWorkspaceControllerProvider(widget.communityId),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (ws) {
        final chatChannels = ws.channels
            .where((c) => c.kind == 'REALTIME_CHAT' && c.linkedConversationId != null)
            .toList();
        final activeConvId = (_selectedConversationId != null &&
                chatChannels.any((c) => c.linkedConversationId == _selectedConversationId))
            ? _selectedConversationId
            : (chatChannels.isNotEmpty ? chatChannels.first.linkedConversationId : null);

        return Scaffold(
          backgroundColor: AppTheme.bgCream,
          appBar: AppBar(
            backgroundColor: AppTheme.bgCream,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ws.community.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  '${ws.community.membersCount} anggota • ${ws.community.totalClubXp} Club XP',
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                ),
              ],
            ),
            actions: [
              if (ws.canManageInvites)
                IconButton(
                  tooltip: 'Undang via Secret ID / QR',
                  icon: const Icon(CupertinoIcons.qrcode_viewfinder,
                      color: AppTheme.primaryBrown),
                  onPressed: () => ShareClubInviteModal.show(
                    context,
                    communityId: widget.communityId,
                    clubName: ws.community.name,
                  ),
                ),
              if (!ws.isMember && ws.community.privacyLevel == 'PUBLIC')
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: TextButton(
                    onPressed: () => ref
                        .read(communityWorkspaceControllerProvider(widget.communityId)
                            .notifier)
                        .joinPublic(),
                    child: const Text('Gabung'),
                  ),
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppTheme.primaryBrown,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.accentAmber,
              tabs: const [
                Tab(icon: Icon(CupertinoIcons.chat_bubble_2), text: 'Live Chat'),
                Tab(icon: Icon(CupertinoIcons.flame), text: 'Brew Feed'),
                Tab(icon: Icon(CupertinoIcons.book), text: 'Recipe Vault'),
                Tab(icon: Icon(CupertinoIcons.person_3), text: 'Leaderboard'),
              ],
            ),
          ),
          floatingActionButton: ws.canPost
              ? FloatingActionButton.extended(
                  onPressed: _openCreatePostDialog,
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  icon: const Icon(CupertinoIcons.add),
                  label: const Text('Post di Club'),
                )
              : null,
          body: TabBarView(
            controller: _tabController,
            children: [
              _ChatChannelsTab(
                workspace: ws,
                chatChannels: chatChannels,
                selectedConvId: activeConvId,
                onSelectChannel: (id) =>
                    setState(() => _selectedConversationId = id),
                onJoinPublic: () => ref
                    .read(communityWorkspaceControllerProvider(widget.communityId)
                        .notifier)
                    .joinPublic(),
              ),
              _ClubFeedTab(communityId: widget.communityId),
              _RecipeVaultTab(communityId: widget.communityId),
              _LeaderboardTab(communityId: widget.communityId),
            ],
          ),
        );
      },
    );
  }
}

class _ChatChannelsTab extends StatefulWidget {
  final CommunityWorkspace workspace;
  final List<CommunityChannel> chatChannels;
  final String? selectedConvId;
  final ValueChanged<String> onSelectChannel;
  final VoidCallback onJoinPublic;

  const _ChatChannelsTab({
    required this.workspace,
    required this.chatChannels,
    required this.selectedConvId,
    required this.onSelectChannel,
    required this.onJoinPublic,
  });

  @override
  State<_ChatChannelsTab> createState() => _ChatChannelsTabState();
}

class _ChatChannelsTabState extends State<_ChatChannelsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!widget.workspace.isMember) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.chat_bubble_2_fill,
                  size: 44, color: AppTheme.primaryBrown),
              const SizedBox(height: 12),
              const Text(
                'Bergabunglah dengan club ini untuk masuk ke channel Live Chat.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (widget.workspace.community.privacyLevel == 'PUBLIC')
                ElevatedButton(
                  onPressed: widget.onJoinPublic,
                  child: const Text('Gabung Club Sekarang'),
                ),
            ],
          ),
        ),
      );
    }

    if (widget.selectedConvId == null) {
      return const Center(child: Text('Belum ada channel chat di club ini.'));
    }

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: widget.chatChannels.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, idx) {
              final ch = widget.chatChannels[idx];
              final selected = ch.linkedConversationId == widget.selectedConvId;
              return ChoiceChip(
                label: Text(ch.name),
                selected: selected,
                selectedColor: AppTheme.primaryBrown,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) {
                  if (ch.linkedConversationId != null) {
                    widget.onSelectChannel(ch.linkedConversationId!);
                  }
                },
              );
            },
          ),
        ),
        Expanded(
          child: SocialCoffeeChatRoomScreen(
            key: ValueKey(widget.selectedConvId),
            conversationId: widget.selectedConvId!,
          ),
        ),
      ],
    );
  }
}

class _ClubFeedTab extends ConsumerStatefulWidget {
  final String communityId;
  const _ClubFeedTab({required this.communityId});

  @override
  ConsumerState<_ClubFeedTab> createState() => _ClubFeedTabState();
}

class _ClubFeedTabState extends ConsumerState<_ClubFeedTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final asyncFeed = ref.watch(clubFeedItemsProvider(widget.communityId));
    return asyncFeed.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Gagal memuat feed club: $err')),
      data: (items) => RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(clubFeedItemsProvider(widget.communityId)),
        child: items.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('Belum ada postingan. Mulailah diskusi pertama!')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, idx) =>
                    _ClubThreadTile(thread: items[idx], communityId: widget.communityId),
              ),
      ),
    );
  }
}

class _RecipeVaultTab extends ConsumerStatefulWidget {
  final String communityId;
  const _RecipeVaultTab({required this.communityId});

  @override
  ConsumerState<_RecipeVaultTab> createState() => _RecipeVaultTabState();
}

class _RecipeVaultTabState extends ConsumerState<_RecipeVaultTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final asyncVault = ref.watch(clubRecipeVaultItemsProvider(widget.communityId));
    return asyncVault.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Recipe Vault terkunci: $err')),
      data: (items) => items.isEmpty
          ? const Center(
              child: Text('Belum ada resep V60 / Kalibrasi tersimpan di Recipe Vault.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, idx) =>
                  _ClubThreadTile(thread: items[idx], communityId: widget.communityId),
            ),
    );
  }
}

class _ClubThreadTile extends ConsumerWidget {
  final SocialThreadItem thread;
  final String communityId;

  const _ClubThreadTile({required this.thread, required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ThreadPostCard(
      thread: thread,
      onTapThread: () => context.push('/social/threads/${thread.id}'),
      onTapAuthor: () => context.push(
        '/social/profile/${Uri.encodeComponent(thread.authorUsername)}',
      ),
      onTapReply: () => context.push('/social/threads/${thread.id}'),
      onToggleLike: () async {
        await ref.read(socialProfileApiServiceProvider).toggleLike(thread.id);
        ref.invalidate(clubFeedItemsProvider(communityId));
      },
      onToggleRepost: () async {
        await ref.read(socialProfileApiServiceProvider).toggleRepost(thread.id);
        ref.invalidate(clubFeedItemsProvider(communityId));
      },
      onTryRecipe: (card) => ref
          .read(forYouFeedControllerProvider().notifier)
          .onTryRecipeTapped(context: context, card: card, threadId: thread.id),
    );
  }
}

class _LeaderboardTab extends ConsumerStatefulWidget {
  final String communityId;
  const _LeaderboardTab({required this.communityId});

  @override
  ConsumerState<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends ConsumerState<_LeaderboardTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final asyncBoard = ref.watch(clubLeaderboardItemsProvider(widget.communityId));
    return asyncBoard.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Leaderboard belum tersedia: $err')),
      data: (entries) => ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, idx) {
          final e = entries[idx];
          return ListTile(
            tileColor: AppTheme.surfaceWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppTheme.borderWarm),
            ),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.14),
              child: Text(
                '#${idx + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBrown,
                ),
              ),
            ),
            title: Text(
              e.displayName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${e.baristaRankTitle} • ${e.clubXpContributed} Club XP • ${e.role}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: SmartFollowFollbackButton(
              targetUserOrUsername: e.username,
              compact: true,
            ),
            onTap: () => context.push(
              '/social/profile/${Uri.encodeComponent(e.username)}',
            ),
          );
        },
      ),
    );
  }
}
