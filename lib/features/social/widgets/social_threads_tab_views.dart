import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../features/notifications/domain/models/notification_models.dart';
import '../../../features/notifications/presentation/controllers/notification_center_controller.dart';
import '../../../features/notifications/presentation/widgets/notification_preferences_sheet.dart';
import '../../../features/social_chat/presentation/controllers/chat_controllers.dart';
import '../../../features/social_profile_feed/presentation/controllers/social_profile_controllers.dart';
import '../../../models/social_coffee.dart';
import '../../../theme/app_theme.dart';
import '../utils/social_time_formatter.dart';
import 'social_post_card.dart';
import 'social_search_bar.dart';
import 'social_threads_account_search.dart';

bool _hasProviderScope(BuildContext context) {
  try {
    ProviderScope.containerOf(context, listen: false);
    return true;
  } catch (_) {
    return false;
  }
}

void _pushSafe(
  BuildContext context,
  String route, {
  WidgetBuilder? fallback,
}) {
  if (GoRouter.maybeOf(context) != null) {
    context.push(route);
  } else if (fallback != null) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: fallback));
  }
}

/// Tab Pencarian Akun Coffee Labs & Jelajah ala Threads (tanpa card boxes).
class SocialThreadsSearchTab extends StatefulWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String currentUsername;
  final List<SocialPost> allPosts;
  final List<SocialPost> filteredPosts;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenBasecamp;
  final ValueChanged<SocialPost> onToggleLike;
  final ValueChanged<SocialPost> onOpenComments;
  final ValueChanged<SocialPost> onCopyRecipe;

  const SocialThreadsSearchTab({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.currentUsername,
    required this.allPosts,
    required this.filteredPosts,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onOpenBasecamp,
    required this.onToggleLike,
    required this.onOpenComments,
    required this.onCopyRecipe,
  });

  @override
  State<SocialThreadsSearchTab> createState() => _SocialThreadsSearchTabState();
}

class _SocialThreadsSearchTabState extends State<SocialThreadsSearchTab> {
  int _searchSubTab = 0; // 0: Akun Coffee Labs, 1: Postingan & Jelajah
  Timer? _debounce;
  String _debouncedAccountQuery = '';

  @override
  void initState() {
    super.initState();
    _debouncedAccountQuery = widget.searchQuery.trim();
  }

  @override
  void didUpdateWidget(covariant SocialThreadsSearchTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _scheduleDebounce(widget.searchQuery);
    }
  }

  void _scheduleDebounce(String val) {
    _debounce?.cancel();
    final trimmed = val.trim();
    if (trimmed.isEmpty) {
      if (_debouncedAccountQuery.isNotEmpty) {
        setState(() => _debouncedAccountQuery = '');
      }
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _debouncedAccountQuery = trimmed);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasScope = _hasProviderScope(context);
    final isSearching = widget.searchQuery.trim().isNotEmpty;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: SocialSearchBar(
              controller: widget.searchController,
              searchQuery: widget.searchQuery,
              hintText: _searchSubTab == 0
                  ? 'Cari akun Coffee Labs, @username, atau barista...'
                  : 'Cari diskusi, resep, atau topik seduh...',
              onChanged: (val) {
                widget.onSearchChanged(val);
                _scheduleDebounce(val);
              },
              onClear: () {
                _debounce?.cancel();
                setState(() => _debouncedAccountQuery = '');
                widget.onClearSearch();
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Row(
                children: [
                  _UnderlineSubTab(
                    label: 'Akun Coffee Labs',
                    selected: _searchSubTab == 0,
                    onTap: () => setState(() => _searchSubTab = 0),
                  ),
                  _UnderlineSubTab(
                    label: 'Postingan & Jelajah',
                    selected: _searchSubTab == 1,
                    onTap: () => setState(() => _searchSubTab = 1),
                  ),
                ],
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppTheme.dividerColor,
              ),
            ],
          ),
        ),
        if (_searchSubTab == 0)
          SocialThreadsAccountSearchView(
            liveQuery: widget.searchQuery,
            networkQuery: _debouncedAccountQuery,
            currentUsername: widget.currentUsername,
            fallbackPosts: widget.allPosts,
            hasProviderScope: hasScope,
          )
        else ...[
          if (!isSearching)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FlatExploreLinkRow(
                    icon: CupertinoIcons.sparkles,
                    title: 'For You, Trending & Coffee Club',
                    subtitle: 'Temukan resep sesuai selera & gabung club Secret ID',
                    onTap: () => _pushSafe(context, AppRoutes.socialExplore),
                  ),
                  const Divider(
                    height: 1,
                    indent: 60,
                    color: AppTheme.dividerColor,
                  ),
                  _FlatExploreLinkRow(
                    icon: CupertinoIcons.compass,
                    title: 'Jelajah & Directory Barista',
                    subtitle: 'Intip log seduhan, rank barista, & thread terbaru',
                    onTap: () => _pushSafe(context, AppRoutes.socialProfiles),
                  ),
                  const Divider(
                    height: 1,
                    indent: 60,
                    color: AppTheme.dividerColor,
                  ),
                  _FlatExploreLinkRow(
                    icon: CupertinoIcons.paperplane,
                    title: 'Direct & Group Chat Barista',
                    subtitle: 'Kirim kartu resep & diskusi seduh real-time',
                    onTap: () => _pushSafe(context, AppRoutes.socialChat),
                  ),
                  const Divider(
                    height: 1,
                    indent: 60,
                    color: AppTheme.dividerColor,
                  ),
                  _FlatExploreLinkRow(
                    icon: CupertinoIcons.person_3_fill,
                    title: 'Coffee Club',
                    subtitle: 'Buat grup seduh sendiri, undang teman & workspace',
                    onTap: widget.onOpenBasecamp,
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.dividerColor,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text(
                      'Diskusi Terbaru Komunitas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.filteredPosts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.search,
                        size: 36,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isSearching
                            ? 'Tidak ada thread yang cocok dengan "${widget.searchQuery}"'
                            : 'Belum ada postingan komunitas',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = widget.filteredPosts[index];
                    return SocialPostCard(
                      post: post,
                      onLike: () => widget.onToggleLike(post),
                      onComment: () => widget.onOpenComments(post),
                      onCopyRecipe: () => widget.onCopyRecipe(post),
                    );
                  },
                  childCount: widget.filteredPosts.length,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _FlatExploreLinkRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FlatExploreLinkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: AppTheme.primaryBrown),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
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
              size: 15,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab Aktivitas & Direct Chat bergaya datar ala Threads (tanpa card).
class SocialThreadsActivityTab extends StatefulWidget {
  const SocialThreadsActivityTab({super.key});

  @override
  State<SocialThreadsActivityTab> createState() =>
      _SocialThreadsActivityTabState();
}

class _SocialThreadsActivityTabState extends State<SocialThreadsActivityTab> {
  int _subTab = 0; // 0: Aktivitas Notifikasi, 1: Obrolan Chat

  @override
  Widget build(BuildContext context) {
    final hasScope = _hasProviderScope(context);

    return Column(
      children: [
        Row(
          children: [
            _UnderlineSubTab(
              label: 'Aktivitas',
              selected: _subTab == 0,
              onTap: () => setState(() => _subTab = 0),
            ),
            _UnderlineSubTab(
              label: 'Obrolan Barista',
              selected: _subTab == 1,
              onTap: () => setState(() => _subTab = 1),
            ),
          ],
        ),
        const Divider(height: 1, thickness: 1, color: AppTheme.dividerColor),
        Expanded(
          child: !hasScope
              ? _ActivityFallbackEmpty(isChatTab: _subTab == 1)
              : (_subTab == 0
                  ? const _LiveNotificationsFlatFeed()
                  : const _LiveChatRoomsFlatFeed()),
        ),
      ],
    );
  }
}

class _LiveNotificationsFlatFeed extends ConsumerWidget {
  const _LiveNotificationsFlatFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationCenterControllerProvider);
    final ctrl = ref.read(notificationCenterControllerProvider.notifier);

    return RefreshIndicator(
      color: AppTheme.primaryBrown,
      onRefresh: () => ctrl.refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
            child: Row(
              children: [
                Text(
                  state.unreadCount > 0
                      ? '${state.unreadCount} belum dibaca'
                      : 'Aktivitas terbaru',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const Spacer(),
                if (state.unreadCount > 0)
                  TextButton(
                    onPressed: ctrl.markAllAsRead,
                    child: const Text(
                      'Tandai Semua',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: 'Preferensi Notifikasi',
                  icon: const Icon(
                    CupertinoIcons.slider_horizontal_3,
                    size: 18,
                    color: AppTheme.primaryBrown,
                  ),
                  onPressed: () => NotificationPreferencesSheet.show(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          if (state.isLoading && state.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBrown),
              ),
            )
          else if (state.items.isEmpty)
            const _ActivityFallbackEmpty(isChatTab: false)
          else
            ...state.items.map(
              (item) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FlatNotificationRow(
                    item: item,
                    onTap: () {
                      if (!item.isRead) {
                        ctrl.markAsRead(item.id);
                      }
                      final path = PushDeepLinkPayload.normalizeDeepLinkPath(
                        item.deepLinkPath,
                      );
                      if (path.isNotEmpty && path != '/notifications') {
                        _pushSafe(context, path);
                      } else {
                        _pushSafe(context, AppRoutes.notifications);
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 68, color: AppTheme.dividerColor),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FlatNotificationRow extends StatelessWidget {
  final NotificationInboxItem item;
  final VoidCallback onTap;

  const _FlatNotificationRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isRead
            ? Colors.transparent
            : AppTheme.accentAmber.withValues(alpha: 0.06),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.1),
              child: Icon(
                item.category.toUpperCase() == 'CHAT'
                    ? CupertinoIcons.chat_bubble_2_fill
                    : CupertinoIcons.heart_fill,
                size: 16,
                color: AppTheme.primaryBrown,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        SocialTimeFormatter.formatRelative(item.createdAt),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveChatRoomsFlatFeed extends ConsumerWidget {
  const _LiveChatRoomsFlatFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(chatRoomListControllerProvider);

    return RefreshIndicator(
      color: AppTheme.primaryBrown,
      onRefresh: () =>
          ref.read(chatRoomListControllerProvider.notifier).refreshFromServer(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _FlatExploreLinkRow(
            icon: CupertinoIcons.paperplane,
            title: 'Buka Daftar Lengkap Obrolan & FTS',
            subtitle: 'Mulai obrolan baru atau cari riwayat chat barista',
            onTap: () => _pushSafe(context, AppRoutes.socialChat),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),
          roomsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(36),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBrown),
              ),
            ),
            error: (_, _) => const _ActivityFallbackEmpty(isChatTab: true),
            data: (rooms) {
              if (rooms.isEmpty) {
                return const _ActivityFallbackEmpty(isChatTab: true);
              }
              return Column(
                children: rooms.map((item) {
                  final conv = item.conversation;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              AppTheme.primaryBrown.withValues(alpha: 0.1),
                          child: const Icon(
                            CupertinoIcons.person_fill,
                            size: 18,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                        title: Text(
                          conv.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        subtitle: Text(
                          item.typingUserName != null
                              ? '${item.typingUserName} sedang mengetik...'
                              : (conv.lastMessagePreview ?? 'Mulai obrolan seduh'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        trailing: conv.unreadCount > 0
                            ? CircleAvatar(
                                radius: 10,
                                backgroundColor: AppTheme.accentAmber,
                                child: Text(
                                  '${conv.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () => _pushSafe(
                          context,
                          AppRoutes.socialChatRoom
                              .replaceFirst(':conversationId', conv.id),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 68,
                        color: AppTheme.dividerColor,
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActivityFallbackEmpty extends StatelessWidget {
  final bool isChatTab;

  const _ActivityFallbackEmpty({required this.isChatTab});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isChatTab ? CupertinoIcons.paperplane : CupertinoIcons.heart,
            size: 38,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            isChatTab
                ? 'Belum ada obrolan aktif'
                : 'Belum ada aktivitas terbaru',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isChatTab
                ? 'Mulai obrolan Direct & Group Chat untuk berbagi resep seduh real-time.'
                : 'Notifikasi balasan thread, suka, dan follback barista akan tampil di sini.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
          ),
          if (isChatTab) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => _pushSafe(context, AppRoutes.socialChat),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBrown,
                side: const BorderSide(color: AppTheme.borderWarm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Buka Direct Chat'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tab Profil Barista Saya bergaya datar ala Threads (tanpa card).
class SocialThreadsProfileTab extends StatefulWidget {
  final String displayName;
  final String avatarPath;
  final List<SocialPost> allPosts;
  final ValueChanged<SocialPost> onToggleLike;
  final ValueChanged<SocialPost> onOpenComments;
  final ValueChanged<SocialPost> onCopyRecipe;

  const SocialThreadsProfileTab({
    super.key,
    required this.displayName,
    required this.avatarPath,
    required this.allPosts,
    required this.onToggleLike,
    required this.onOpenComments,
    required this.onCopyRecipe,
  });

  @override
  State<SocialThreadsProfileTab> createState() =>
      _SocialThreadsProfileTabState();
}

class _SocialThreadsProfileTabState extends State<SocialThreadsProfileTab> {
  int _profileSubTab = 0; // 0: Thread Saya, 1: Disukai

  ImageProvider _resolveAvatar() {
    if (widget.avatarPath.startsWith('http://') ||
        widget.avatarPath.startsWith('https://')) {
      return NetworkImage(widget.avatarPath);
    }
    if (widget.avatarPath.startsWith('assets/')) {
      return AssetImage(widget.avatarPath);
    }
    return const AssetImage('assets/images/coffee_labs_emblem.png');
  }

  @override
  Widget build(BuildContext context) {
    final handle = widget.displayName.toLowerCase().replaceAll(' ', '');
    final myPosts = widget.allPosts
        .where((p) =>
            p.authorName.toLowerCase() == widget.displayName.toLowerCase())
        .toList();
    final likedPosts =
        widget.allPosts.where((p) => p.isLikedByMe).toList();
    final visiblePosts = _profileSubTab == 0 ? myPosts : likedPosts;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@$handle • Coffee Labs Barista',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          AppTheme.primaryBrown.withValues(alpha: 0.1),
                      backgroundImage: _resolveAvatar(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_hasProviderScope(context))
                  Consumer(
                    builder: (ctx, ref, _) {
                      final profAsync = ref.watch(
                        publicProfileControllerProvider('me'),
                      );
                      return profAsync.maybeWhen(
                        data: (profile) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (profile.bio.trim().isNotEmpty) ...[
                              Text(
                                profile.bio,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppTheme.textDark,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            GestureDetector(
                              onTap: () => _pushSafe(
                                context,
                                '/social/profile/me/connections?tab=followers&name=${Uri.encodeQueryComponent(profile.displayName)}&own=1',
                              ),
                              child: Text(
                                '${profile.followersCount} Pengikut • ${profile.followingCount} Mengikuti • Lv.${profile.baristaLevel}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        orElse: () => const Text(
                          'Bagikan racikan manual brew & diskusikan kopi bersama barista.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Text(
                    'Bagikan racikan manual brew & diskusikan kopi bersama barista.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _pushSafe(context, '/social/profile/me'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textDark,
                          side: const BorderSide(color: AppTheme.borderWarm),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Profil Lengkap & Rank',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pushSafe(
                          context,
                          '/social/profile/me/connections?tab=followers&own=1',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textDark,
                          side: const BorderSide(color: AppTheme.borderWarm),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Pengikut & Mutual',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Row(
                children: [
                  _UnderlineSubTab(
                    label: 'Thread (${myPosts.length})',
                    selected: _profileSubTab == 0,
                    onTap: () => setState(() => _profileSubTab = 0),
                  ),
                  _UnderlineSubTab(
                    label: 'Disukai (${likedPosts.length})',
                    selected: _profileSubTab == 1,
                    onTap: () => setState(() => _profileSubTab = 1),
                  ),
                ],
              ),
              const Divider(height: 1, thickness: 1, color: AppTheme.dividerColor),
            ],
          ),
        ),
        if (visiblePosts.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _profileSubTab == 0
                      ? 'Anda belum menerbitkan thread diskusi kopi.'
                      : 'Belum ada postingan yang Anda sukai.',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = visiblePosts[index];
                  return SocialPostCard(
                    post: post,
                    onLike: () => widget.onToggleLike(post),
                    onComment: () => widget.onOpenComments(post),
                    onCopyRecipe: () => widget.onCopyRecipe(post),
                  );
                },
                childCount: visiblePosts.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _UnderlineSubTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UnderlineSubTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppTheme.primaryBrown : AppTheme.textMuted,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2.2,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryBrown : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
