import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/notification_models.dart';
import '../controllers/notification_center_controller.dart';
import '../widgets/notification_preferences_sheet.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 220) {
      ref.read(notificationCenterControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String _formatRelativeTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt.toLocal());
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return DateFormat('dd MMM', 'id_ID').format(createdAt.toLocal());
  }

  IconData _categoryIcon(String category, String eventType) {
    if (eventType == 'SOCIAL_MUTUAL_FOLLBACK_ACCEPTED') {
      return CupertinoIcons.person_2_fill;
    }
    switch (category.toUpperCase()) {
      case 'CHAT':
        return CupertinoIcons.chat_bubble_2_fill;
      case 'SOCIAL_GRAPH':
        return CupertinoIcons.person_badge_plus_fill;
      case 'THREAD_ACTIVITY':
        return CupertinoIcons.heart_circle_fill;
      case 'GAMIFICATION':
        return CupertinoIcons.flame_fill;
      case 'BILLING':
        return CupertinoIcons.sparkles;
      default:
        return CupertinoIcons.bell_fill;
    }
  }

  void _openItem(NotificationInboxItem item) {
    if (!item.isRead) {
      ref
          .read(notificationCenterControllerProvider.notifier)
          .markAsRead(item.id);
    }
    final target = PushDeepLinkPayload.normalizeDeepLinkPath(item.deepLinkPath);
    if (target.isNotEmpty && target != '/notifications') {
      context.push(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationCenterControllerProvider);
    final ctrl = ref.read(notificationCenterControllerProvider.notifier);

    const tabs = <OmnichannelNotificationCategory>[
      OmnichannelNotificationCategory.all,
      OmnichannelNotificationCategory.socialGraph,
      OmnichannelNotificationCategory.threadActivity,
      OmnichannelNotificationCategory.chat,
      OmnichannelNotificationCategory.gamification,
      OmnichannelNotificationCategory.billing,
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pusat Notifikasi',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              state.unreadCount > 0
                  ? '${state.unreadCount} notifikasi belum dibaca'
                  : 'Semua kabar seduh sudah terbaca',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: ctrl.markAllAsRead,
              icon: const Icon(
                CupertinoIcons.checkmark_seal_fill,
                size: 16,
                color: AppTheme.primaryBrown,
              ),
              label: const Text(
                'Tandai Semua',
                style: TextStyle(
                  color: AppTheme.primaryBrown,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Preferensi Notifikasi',
            onPressed: () => NotificationPreferencesSheet.show(context),
            icon: const Icon(
              CupertinoIcons.slider_horizontal_3,
              color: AppTheme.primaryBrown,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = tabs[index];
                final selected = state.selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat.tabLabel),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppTheme.primaryBrown,
                  backgroundColor: AppTheme.surfaceWhite,
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.textDark,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppTheme.primaryBrown
                        : AppTheme.borderWarm,
                  ),
                  onSelected: (_) => ctrl.selectCategory(cat),
                );
              },
            ),
          ),
          if (state.errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentAmber),
              ),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primaryBrown,
              onRefresh: () => ctrl.refresh(),
              child: _buildListBody(state, ctrl),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListBody(
    NotificationCenterState state,
    NotificationCenterController ctrl,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrown),
      );
    }

    if (state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 88),
          Icon(
            CupertinoIcons.bell_circle,
            size: 64,
            color: AppTheme.lightBrown.withValues(alpha: 0.65),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Belum ada notifikasi di kategori ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Interaksi chat, follback barista, likes resep, dan promo Pro akan tampil di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBrown),
            ),
          );
        }

        final item = state.items[index];
        final actorId = item.actorId ?? '';
        final inFlight = state.follbackInFlightIds.contains(item.id);
        final followedBack =
            actorId.isNotEmpty && state.followedBackActorIds.contains(actorId);

        return _NotificationCard(
          item: item,
          icon: _categoryIcon(item.category, item.eventType),
          relativeTime: _formatRelativeTime(item.createdAt),
          follbackInFlight: inFlight,
          followedBack: followedBack,
          onTap: () => _openItem(item),
          onFollback: () => ctrl.quickFollback(item),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationInboxItem item;
  final IconData icon;
  final String relativeTime;
  final bool follbackInFlight;
  final bool followedBack;
  final VoidCallback onTap;
  final VoidCallback onFollback;

  const _NotificationCard({
    required this.item,
    required this.icon,
    required this.relativeTime,
    required this.follbackInFlight,
    required this.followedBack,
    required this.onTap,
    required this.onFollback,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;
    return Material(
      color: unread ? const Color(0xFFFFFBF2) : AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unread
                  ? AppTheme.accentAmber.withValues(alpha: 0.65)
                  : AppTheme.borderWarm,
              width: unread ? 1.3 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActorAvatarStack(actors: item.actorsPreview, fallbackIcon: icon),
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          relativeTime,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentAmber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    if (item.aggregatedCount > 1) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCream,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderWarm),
                        ),
                        child: Text(
                          '${item.aggregatedCount} interaksi digabungkan',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ),
                    ],
                    if (item.hasQuickFollbackAction) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (followedBack)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Mutual Barista ✓',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: follbackInFlight ? null : onFollback,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBrown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              icon: Icon(
                                follbackInFlight
                                    ? CupertinoIcons.hourglass
                                    : CupertinoIcons.person_add_solid,
                                size: 15,
                              ),
                              label: Text(
                                follbackInFlight ? 'Memproses...' : 'Follback',
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActorAvatarStack extends StatelessWidget {
  final List<NotificationActorPreview> actors;
  final IconData fallbackIcon;

  const _ActorAvatarStack({
    required this.actors,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (actors.isEmpty) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderWarm),
        ),
        child: Icon(fallbackIcon, color: AppTheme.primaryBrown, size: 22),
      );
    }

    final visible = actors.take(3).toList();
    if (visible.length == 1) {
      return _SingleAvatar(actor: visible.first, size: 44);
    }

    return SizedBox(
      width: 46,
      height: 44,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * 10.0,
              top: i.isOdd ? 10.0 : 0.0,
              child: _SingleAvatar(actor: visible[i], size: 28),
            ),
        ],
      ),
    );
  }
}

class _SingleAvatar extends StatelessWidget {
  final NotificationActorPreview actor;
  final double size;

  const _SingleAvatar({required this.actor, required this.size});

  @override
  Widget build(BuildContext context) {
    final label = actor.displayName.isNotEmpty
        ? actor.displayName
        : (actor.username.isNotEmpty ? actor.username : 'B');
    final initial = label.substring(0, 1).toUpperCase();
    final url = actor.avatarUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.accentGold.withValues(alpha: 0.25),
        border: Border.all(color: AppTheme.surfaceWhite, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: size * 0.42,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.42,
                  color: AppTheme.primaryBrown,
                ),
              ),
            ),
    );
  }
}
