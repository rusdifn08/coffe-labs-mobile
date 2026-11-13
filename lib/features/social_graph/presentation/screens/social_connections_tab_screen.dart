import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/social_graph_models.dart';
import '../controllers/relationship_controller.dart';
import '../widgets/smart_follow_follback_button.dart';

class SocialConnectionsTabScreen extends ConsumerStatefulWidget {
  final String targetUserOrUsername;
  final String displayName;
  final int initialTabIndex;
  final bool isOwnProfile;

  const SocialConnectionsTabScreen({
    super.key,
    required this.targetUserOrUsername,
    this.displayName = '',
    this.initialTabIndex = 1,
    this.isOwnProfile = false,
  });

  @override
  ConsumerState<SocialConnectionsTabScreen> createState() =>
      _SocialConnectionsTabScreenState();
}

class _SocialConnectionsTabScreenState
    extends ConsumerState<SocialConnectionsTabScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    ('mutual', 'Mutual'),
    ('followers', 'Pengikut'),
    ('following', 'Mengikuti'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      initialIndex: widget.initialTabIndex.clamp(0, _tabs.length - 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleName = widget.displayName.isNotEmpty
        ? widget.displayName
        : '@${widget.targetUserOrUsername}';

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        title: Text(
          titleName,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBrown,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryBrown,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
          tabs: [
            for (final t in _tabs) Tab(text: t.$2),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (final t in _tabs)
            _ConnectionsTabPage(
              targetUserOrUsername: widget.targetUserOrUsername,
              kind: t.$1,
              isOwnFollowersTab: widget.isOwnProfile && t.$1 == 'followers',
            ),
        ],
      ),
    );
  }
}

class _ConnectionsTabPage extends ConsumerWidget {
  final String targetUserOrUsername;
  final String kind;
  final bool isOwnFollowersTab;

  const _ConnectionsTabPage({
    required this.targetUserOrUsername,
    required this.kind,
    required this.isOwnFollowersTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = socialConnectionsTabControllerProvider(
      targetUserOrUsername,
      kind,
    );
    final pageAsync = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return pageAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrown),
      ),
      error: (err, _) {
        final isForbidden =
            err is DioException && err.response?.statusCode == 403;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isForbidden
                        ? CupertinoIcons.lock_shield_fill
                        : CupertinoIcons.wifi_exclamationmark,
                    size: 36,
                    color: AppTheme.primaryBrown,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isForbidden
                        ? 'Akun Ini Bersifat Privat'
                        : 'Gagal memuat daftar koneksi',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isForbidden
                        ? 'Ikuti dan tunggu persetujuan akun ini untuk melihat daftar pengikut serta mengikuti.'
                        : 'Periksa koneksi Anda lalu coba muat ulang.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      data: (page) {
        if (page.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                kind == 'mutual'
                    ? 'Belum ada teman mutual di sini.'
                    : (kind == 'followers'
                        ? 'Belum ada pengikut.'
                        : 'Belum mengikuti siapa pun.'),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryBrown,
          onRefresh: () => ref.refresh(provider.future),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 220 &&
                  page.hasMore &&
                  !page.isLoadingNext) {
                notifier.fetchNextPage();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: page.items.length + (page.isLoadingNext ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index >= page.items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  );
                }
                final user = page.items[index];
                return _ConnectionUserCard(
                  user: user,
                  onTapProfile: () => context.push(
                    '/social/profile/${Uri.encodeComponent(user.username)}',
                  ),
                  onToggleFollow: () => notifier.toggleRowFollow(user),
                  onRemoveFollower: isOwnFollowersTab
                      ? () => notifier.removeFollower(user.userId)
                      : null,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ConnectionUserCard extends StatelessWidget {
  final SocialGraphUserItem user;
  final VoidCallback onTapProfile;
  final VoidCallback onToggleFollow;
  final VoidCallback? onRemoveFollower;

  const _ConnectionUserCard({
    required this.user,
    required this.onTapProfile,
    required this.onToggleFollow,
    this.onRemoveFollower,
  });

  @override
  Widget build(BuildContext context) {
    final initial = user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : 'B';
    return InkWell(
      onTap: onTapProfile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderWarm),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.accentGold.withValues(alpha: 0.24),
              backgroundImage:
                  user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? Text(
                      initial,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBrown,
                      ),
                    )
                  : null,
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
                          user.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      if (user.isPrivateAccount) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          CupertinoIcons.lock_fill,
                          size: 12,
                          color: AppTheme.textMuted,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username} • Lv.${user.baristaLevel} ${user.baristaRankTitle}',
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
            const SizedBox(width: 8),
            if (user.relationshipState != RelationshipState.selfProfile)
              RelationshipCtaButton(
                state: user.relationshipState,
                compact: true,
                onTap: onToggleFollow,
              ),
            if (onRemoveFollower != null) ...[
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Hapus Pengikut',
                icon: const Icon(
                  CupertinoIcons.xmark_circle,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                onPressed: onRemoveFollower,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
