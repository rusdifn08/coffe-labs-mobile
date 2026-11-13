import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../screens/brew_timer_screen.dart';
import '../../../../services/api_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../social_chat/presentation/controllers/chat_controllers.dart';
import '../../../social_graph/domain/models/social_graph_models.dart';
import '../../../social_graph/presentation/controllers/relationship_controller.dart';
import '../../../social_graph/presentation/widgets/follow_requests_inbox_banner.dart';
import '../../../social_graph/presentation/widgets/mutual_followers_banner_pill.dart';
import '../../../social_graph/presentation/widgets/smart_follow_follback_button.dart';
import '../../domain/models/social_profile_models.dart';
import '../../domain/models/social_thread_models.dart';
import '../controllers/social_profile_controllers.dart';
import '../widgets/barista_rank_showcase_header.dart';
import '../widgets/create_thread_sheet.dart';
import '../widgets/keep_alive_profile_tab_view.dart';
import '../widgets/live_or_recent_brew_spotlight_card.dart';

class SocialUserProfileScreen extends ConsumerStatefulWidget {
  final String targetUserOrUsername;

  const SocialUserProfileScreen({
    super.key,
    required this.targetUserOrUsername,
  });

  @override
  ConsumerState<SocialUserProfileScreen> createState() =>
      _SocialUserProfileScreenState();
}

class _SocialUserProfileScreenState
    extends ConsumerState<SocialUserProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _openingChat = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ProfileFeedTab.values.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openDirectChat(MaterializedProfileView profile) async {
    if (_openingChat) return;
    setState(() => _openingChat = true);
    try {
      final convId = await ref
          .read(chatRoomListControllerProvider.notifier)
          .startDirectChat(profile.userId);
      if (!mounted) return;
      context.push('/social/chat/$convId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka chat: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  Future<void> _launchSpotlightBrew(RecentBrewSnapshot snap) async {
    try {
      Map<String, dynamic>? found;
      if (snap.recipeId != null) {
        final recipes = await ApiService.getRecipes();
        final match = recipes.whereType<Map<String, dynamic>>().firstWhere(
              (r) => r['id']?.toString() == snap.recipeId,
              orElse: () => const {},
            );
        if (match.isNotEmpty) {
          found = ApiService.sanitizeRecipe(match);
        }
      }

      final payload = found ??
          ApiService.sanitizeRecipe({
            'id': int.tryParse(snap.recipeId ?? '') ?? 9101,
            'title': snap.recipeTitle,
            'brewer': snap.roastery,
            'method': snap.method,
            'coffeeWeightGrams': (snap.coffeeDoseG ?? 15).round(),
            'waterWeightGrams': (snap.totalWaterMl ?? 240).round(),
            'waterTempCelsius': snap.primaryTempC ?? 92,
            'totalTimeSeconds': snap.targetDurationSec ?? 150,
            'steps': [
              {
                'stepOrder': 1,
                'title': 'Pour ${snap.method}',
                'durationSeconds': snap.targetDurationSec ?? 150,
                'waterAddedGrams': (snap.totalWaterMl ?? 240).round(),
                'instruction':
                    'Seduh ${snap.beanName} (${snap.roastery}) mengikuti resep ${snap.recipeTitle}.',
              },
            ],
          });

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BrewTimerScreen(recipeData: payload),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka brew timer: $e')),
        );
      }
    }
  }

  Future<void> _showEditProfileDialog(MaterializedProfileView profile) async {
    final nameCtrl = TextEditingController(text: profile.displayName);
    final bioCtrl = TextEditingController(text: profile.bio);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil Publik Barista'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Tampilan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio & Setup Alat Seduh',
                hintText: 'Contoh: V60 • Comandante C40 • Suka Natural Process',
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
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      final ok = await ref
          .read(
            publicProfileControllerProvider(widget.targetUserOrUsername)
                .notifier,
          )
          .updateMyProfile(
            displayName: nameCtrl.text.trim(),
            bio: bioCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok ? 'Profil publik diperbarui.' : 'Gagal menyimpan profil.',
            ),
          ),
        );
      }
    }

    nameCtrl.dispose();
    bioCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(
      publicProfileControllerProvider(widget.targetUserOrUsername),
    );

    ref.listen<String?>(relationshipFeedbackBannerProvider, (_, msg) {
      if (msg == null || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      ref.read(relationshipFeedbackBannerProvider.notifier).clear();
    });

    ref.listen(socialGraphRealtimeEventsProvider, (_, nextAsync) {
      final evt = nextAsync.value;
      if (evt == null || !mounted) return;
      ref.invalidate(
        userRelationshipControllerProvider(widget.targetUserOrUsername),
      );
      ref.invalidate(pendingFollowRequestsControllerProvider);
      ref.invalidate(myPrivacySettingControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primaryBrown,
          content: Text(evt.message),
        ),
      );
    });

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      floatingActionButton: profileAsync.value?.isOwnProfile == true
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryBrown,
              foregroundColor: Colors.white,
              onPressed: () async {
                final created = await CreateThreadSheet.show(context);
                if (created != null && mounted) {
                  ref
                      .read(
                        profileTabFeedControllerProvider(
                          widget.targetUserOrUsername,
                          ProfileFeedTab.allThreads,
                        ).notifier,
                      )
                      .prependThread(created);
                  ref.invalidate(
                    profileTabFeedControllerProvider(
                      widget.targetUserOrUsername,
                      ProfileFeedTab.brewLogs,
                    ),
                  );
                  ref.invalidate(
                    profileTabFeedControllerProvider(
                      widget.targetUserOrUsername,
                      ProfileFeedTab.createdRecipes,
                    ),
                  );
                  ref
                      .read(
                        publicProfileControllerProvider(
                          widget.targetUserOrUsername,
                        ).notifier,
                      )
                      .refresh();
                }
              },
              icon: const Icon(CupertinoIcons.add),
              label: const Text('Post Thread'),
            )
          : null,
      body: profileAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Memuat Profil...')),
          body: const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBrown),
          ),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: const Text('Profil Barista')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.person_crop_circle_badge_exclam,
                    size: 48,
                    color: AppTheme.lightBrown,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Profil tidak ditemukan atau gagal dimuat.\n$err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => ref
                        .read(
                          publicProfileControllerProvider(
                            widget.targetUserOrUsername,
                          ).notifier,
                        )
                        .refresh(),
                    icon: const Icon(CupertinoIcons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (profile) => _buildProfileBody(context, profile),
      ),
    );
  }

  Widget _buildProfileBody(
    BuildContext context,
    MaterializedProfileView profile,
  ) {
    final notifier = ref.read(
      publicProfileControllerProvider(widget.targetUserOrUsername).notifier,
    );
    final relSnap = ref
        .watch(userRelationshipControllerProvider(widget.targetUserOrUsername))
        .value;
    final effectiveProfile = relSnap != null && !profile.isOwnProfile
        ? profile.copyWith(
            followersCount: relSnap.followersCount,
            followingCount: relSnap.followingCount,
          )
        : profile;

    void openConnections(String tab) {
      final encodedTarget = Uri.encodeComponent(widget.targetUserOrUsername);
      final encodedName = Uri.encodeQueryComponent(profile.displayName);
      final own = profile.isOwnProfile ? '1' : '0';
      context.push(
        '/social/profile/$encodedTarget/connections?tab=$tab&name=$encodedName&own=$own',
      );
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.bgCream,
                foregroundColor: AppTheme.textDark,
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        '@${profile.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: profile.rankAccentColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lv.${profile.baristaLevel}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: profile.rankAccentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'Jelajah Barista Lain',
                    icon: const Icon(CupertinoIcons.compass),
                    onPressed: () => context.push(AppRoutes.socialProfiles),
                  ),
                  IconButton(
                    tooltip: 'Muat Ulang Profil',
                    icon: const Icon(CupertinoIcons.refresh),
                    onPressed: () => notifier.refresh(),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    BaristaRankShowcaseHeader(
                      profile: effectiveProfile,
                      onToggleFollow: () => ref
                          .read(
                            userRelationshipControllerProvider(
                              widget.targetUserOrUsername,
                            ).notifier,
                          )
                          .toggleFollow(),
                      onMessagePeer: () => _openDirectChat(profile),
                      onEditProfile: () => _showEditProfileDialog(profile),
                      onTapFollowers: () => openConnections('followers'),
                      onTapFollowing: () => openConnections('following'),
                      customFollowSection: !profile.isOwnProfile
                          ? SmartFollowFollbackButton(
                              targetUserOrUsername:
                                  widget.targetUserOrUsername,
                              onEditProfile: () =>
                                  _showEditProfileDialog(profile),
                              onOpenDirectChat: () => _openDirectChat(profile),
                            )
                          : null,
                      relationshipAccessory:
                          !profile.isOwnProfile && relSnap != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (relSnap.mutualFollowersCount > 0)
                                  MutualFollowersBannerPill(
                                    mutualCount: relSnap.mutualFollowersCount,
                                    avatars: relSnap.mutualAvatars,
                                    onTap: () => openConnections('mutual'),
                                  ),
                                if (relSnap.targetIsPrivate &&
                                    relSnap.state !=
                                        RelationshipState.following &&
                                    relSnap.state != RelationshipState.mutual)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.bgCream,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppTheme.borderWarm,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            CupertinoIcons.lock_fill,
                                            size: 13,
                                            color: AppTheme.primaryBrown,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Akun Privat • Daftar pengikut dibatasi',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : null,
                    ),
                    if (profile.isOwnProfile) const FollowRequestsInboxBanner(),
                    if (profile.recentBrewSnapshot != null)
                      LiveOrRecentBrewSpotlightCard(
                        snapshot: profile.recentBrewSnapshot!,
                        onTryExactBrew: () =>
                            _launchSpotlightBrew(profile.recentBrewSnapshot!),
                      ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: AppTheme.primaryBrown,
                    indicatorWeight: 2.5,
                    labelColor: AppTheme.primaryBrown,
                    unselectedLabelColor: AppTheme.textMuted,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    tabs: [
                      Tab(text: 'Threads (${profile.totalThreadsCount})'),
                      Tab(text: 'Brew Logs (${profile.totalBrewsCount})'),
                      Tab(
                        text:
                            'Resep (${profile.totalRecipesCreatedCount})',
                      ),
                      const Tab(text: 'Media'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: ProfileFeedTab.values
            .map(
              (tab) => KeepAliveProfileFeedTabView(
                targetUserOrUsername: widget.targetUserOrUsername,
                tab: tab,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.dividerColor),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}
