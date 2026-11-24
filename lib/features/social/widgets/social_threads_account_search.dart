import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/social_chat/domain/chat_protocol.dart';
import '../../../features/social_chat/presentation/controllers/chat_controllers.dart';
import '../../../features/social_graph/presentation/controllers/relationship_controller.dart';
import '../../../features/social_profile_feed/data/services/social_profile_api_service.dart';
import '../../../features/social_profile_feed/domain/models/social_profile_models.dart';
import '../../../features/social_profile_feed/presentation/controllers/social_profile_controllers.dart';
import '../../../models/social_coffee.dart';
import '../../../theme/app_theme.dart';
import '../../../core/assets/cloud_asset_manager.dart';

/// Daftar hasil pencarian akun Coffee Labs bergaya Threads (tanpa card)
/// dengan L1 Memory Prefix Cache + SWR + CancelToken + Zero Retry Hanging.
class SocialThreadsAccountSearchView extends StatelessWidget {
  final String liveQuery;
  final String networkQuery;
  final String currentUsername;
  final List<SocialPost> fallbackPosts;
  final bool hasProviderScope;

  const SocialThreadsAccountSearchView({
    super.key,
    required this.liveQuery,
    required this.networkQuery,
    required this.currentUsername,
    required this.fallbackPosts,
    required this.hasProviderScope,
  });

  @override
  Widget build(BuildContext context) {
    final peersFromPosts = extractUniquePeerAccounts(
      fallbackPosts,
      currentUsername: currentUsername,
      query: liveQuery,
    );

    if (!hasProviderScope) {
      return _OfflinePeerAccountSliverList(
        query: liveQuery,
        peers: peersFromPosts,
      );
    }

    return _FastDirectoryAccountSliverList(
      liveQuery: liveQuery,
      networkQuery: networkQuery,
      currentUsername: currentUsername,
      fallbackPeers: peersFromPosts,
    );
  }

  static List<FallbackPeerAccount> extractUniquePeerAccounts(
    List<SocialPost> posts, {
    required String currentUsername,
    required String query,
  }) {
    final selfLower = currentUsername.trim().toLowerCase();
    final cleanQuery = SocialProfileApiService.normalizeDirectoryQuery(query);
    final seen = <String>{};
    final peers = <FallbackPeerAccount>[];
    final selfMatches = <FallbackPeerAccount>[];

    for (final p in posts) {
      final name = p.authorName.trim();
      if (name.isEmpty) continue;
      final key = (p.userId != null && p.userId!.trim().isNotEmpty)
          ? p.userId!.trim().toLowerCase()
          : name.toLowerCase();
      if (!seen.add(key)) continue;

      final handle = name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      final isSelf = selfLower.isNotEmpty &&
          selfLower != 'coffeelabs.app' &&
          name.toLowerCase() == selfLower;
      if (isSelf && cleanQuery.isEmpty) continue;

      if (cleanQuery.isNotEmpty &&
          !name.toLowerCase().contains(cleanQuery) &&
          !handle.contains(cleanQuery) &&
          !p.authorRole.toLowerCase().contains(cleanQuery)) {
        continue;
      }

      final account = FallbackPeerAccount(
        targetId: (p.userId != null && p.userId!.trim().isNotEmpty)
            ? p.userId!.trim()
            : name,
        displayName: name,
        handle: handle,
        roleLabel:
            p.authorRole.trim().isNotEmpty ? p.authorRole.trim() : 'Barista',
        avatarPath: p.authorAvatar,
        isSelf: isSelf,
      );
      if (isSelf) {
        selfMatches.add(account);
      } else {
        peers.add(account);
      }
    }
    return [...peers, ...selfMatches];
  }
}

class _FastDirectoryAccountSliverList extends ConsumerStatefulWidget {
  final String liveQuery;
  final String networkQuery;
  final String currentUsername;
  final List<FallbackPeerAccount> fallbackPeers;

  const _FastDirectoryAccountSliverList({
    required this.liveQuery,
    required this.networkQuery,
    required this.currentUsername,
    required this.fallbackPeers,
  });

  @override
  ConsumerState<_FastDirectoryAccountSliverList> createState() =>
      _FastDirectoryAccountSliverListState();
}

class _FastDirectoryAccountSliverListState
    extends ConsumerState<_FastDirectoryAccountSliverList> {
  CancelToken? _cancelToken;
  int _requestSeq = 0;
  bool _isSyncing = false;
  bool _networkFailed = false;
  List<ProfileDirectoryEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _syncNetwork(forceNetwork: true);
  }

  @override
  void didUpdateWidget(covariant _FastDirectoryAccountSliverList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.liveQuery != widget.liveQuery) {
      _applyInstantLocalCache();
    }
    if (oldWidget.networkQuery != widget.networkQuery) {
      _syncNetwork(forceNetwork: false);
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel('disposed');
    super.dispose();
  }

  void _applyInstantLocalCache() {
    final api = ref.read(socialProfileApiServiceProvider);
    final query = widget.liveQuery;
    final freshQueryHit = api.getFreshQueryCache(query, limit: 30);
    final localMatches =
        freshQueryHit?.items ?? api.searchCachedProfiles(query);
    if (mounted) {
      setState(() {
        _entries = _rankForViewer(localMatches, query);
        _networkFailed = false;
      });
    }
  }

  List<ProfileDirectoryEntry> _rankForViewer(
    List<ProfileDirectoryEntry> raw,
    String query,
  ) {
    final selfLower = widget.currentUsername.trim().toLowerCase();
    final cleanQuery = SocialProfileApiService.normalizeDirectoryQuery(query);

    final peers = <ProfileDirectoryEntry>[];
    final selfHits = <ProfileDirectoryEntry>[];

    for (final entry in raw) {
      final isSelf = selfLower.isNotEmpty &&
          selfLower != 'coffeelabs.app' &&
          entry.username.toLowerCase() == selfLower;
      if (isSelf) {
        if (cleanQuery.isNotEmpty) selfHits.add(entry);
      } else {
        peers.add(entry);
      }
    }
    return [...peers, ...selfHits];
  }

  Future<void> _syncNetwork({required bool forceNetwork}) async {
    final api = ref.read(socialProfileApiServiceProvider);
    final query = widget.networkQuery;

    final freshQueryHit = api.getFreshQueryCache(query, limit: 30);
    final localMatches =
        freshQueryHit?.items ?? api.searchCachedProfiles(widget.liveQuery);
    if (localMatches.isNotEmpty && mounted) {
      setState(() {
        _entries = _rankForViewer(localMatches, widget.liveQuery);
        _networkFailed = false;
      });
    }

    if (!forceNetwork && freshQueryHit != null) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _networkFailed = false;
        });
      }
      return;
    }

    // Batalkan request lama, jalankan max 1 request cepat (tanpa retry backoff Riverpod!)
    _cancelToken?.cancel('superseded');
    final token = CancelToken();
    _cancelToken = token;
    final seq = ++_requestSeq;

    if (mounted) {
      setState(() {
        _isSyncing = _entries.isEmpty;
        _networkFailed = false;
      });
    }

    try {
      final chatApi = ref.read(chatApiServiceProvider);
      List<ProfileDirectoryEntry> directoryItems = const [];
      List<ProfileDirectoryEntry> peerItems = const [];
      var directoryOk = false;
      var peersOk = false;

      Future<void> loadDirectory() async {
        try {
          final res = await api.exploreProfiles(
            query: query,
            limit: 30,
            cancelToken: token,
          );
          directoryItems = res.items;
          directoryOk = true;
        } on DioException catch (e) {
          if (CancelToken.isCancel(e)) rethrow;
        } catch (_) {}
      }

      Future<void> loadChatPeers() async {
        try {
          final peers = await chatApi.searchPeers(
            query: SocialProfileApiService.normalizeDirectoryQuery(query),
            limit: 30,
          );
          peerItems = peers
              .map(
                (ChatPeerDto p) => ProfileDirectoryEntry(
                  userId: p.id.trim(),
                  username: p.username,
                  displayName:
                      p.fullName.trim().isNotEmpty ? p.fullName : p.username,
                  avatarUrl: p.avatarUrl,
                  baristaRankTitle:
                      p.role.isNotEmpty ? p.role : 'Barista Coffee Labs',
                ),
              )
              .where((e) => e.userId.isNotEmpty)
              .toList();
          peersOk = true;
        } catch (_) {}
      }

      await Future.wait([loadDirectory(), loadChatPeers()]);
      if (!mounted || seq != _requestSeq || token.isCancelled) return;

      if (!directoryOk && !peersOk) {
        setState(() {
          _isSyncing = false;
          _networkFailed = true;
        });
        return;
      }

      final mergedByKey = <String, ProfileDirectoryEntry>{};
      for (final item in directoryItems) {
        mergedByKey[item.userId.toLowerCase()] = item;
      }
      for (final peer in peerItems) {
        mergedByKey.putIfAbsent(peer.userId.toLowerCase(), () => peer);
      }
      final mergedList = mergedByKey.values.toList();
      api.rememberProfiles(mergedList);

      final refreshedLocal = api.searchCachedProfiles(widget.liveQuery);
      final toShow = SocialProfileApiService.normalizeDirectoryQuery(
                widget.liveQuery,
              ) ==
              SocialProfileApiService.normalizeDirectoryQuery(query)
          ? (mergedList.isNotEmpty ? mergedList : refreshedLocal)
          : refreshedLocal;
      setState(() {
        _entries = _rankForViewer(toShow, widget.liveQuery);
        _isSyncing = false;
        _networkFailed = false;
      });
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || !mounted || seq != _requestSeq) return;
      setState(() {
        _isSyncing = false;
        _networkFailed = true;
      });
    } catch (_) {
      if (!mounted || seq != _requestSeq) return;
      setState(() {
        _isSyncing = false;
        _networkFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selfLower = widget.currentUsername.trim().toLowerCase();

    if (_isSyncing && _entries.isEmpty && widget.fallbackPeers.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrown),
        ),
      );
    }

    if (_entries.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.only(bottom: 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (_networkFailed && index == 0) {
                return _OfflineNoticeStrip(
                  onRetry: () => _syncNetwork(forceNetwork: true),
                );
              }
              final itemIndex = _networkFailed ? index - 1 : index;
              final entry = _entries[itemIndex];
              final isSelf = selfLower.isNotEmpty &&
                  selfLower != 'coffeelabs.app' &&
                  entry.username.toLowerCase() == selfLower;
              return _LiveDirectoryAccountRow(
                entry: entry,
                isSelf: isSelf,
              );
            },
            childCount: _entries.length + (_networkFailed ? 1 : 0),
          ),
        ),
      );
    }

    if (widget.fallbackPeers.isNotEmpty) {
      return _OfflinePeerAccountSliverList(
        query: widget.liveQuery,
        peers: widget.fallbackPeers,
        showCacheBanner: _networkFailed,
        onRetryLive: () => _syncNetwork(forceNetwork: true),
      );
    }

    return SliverFillRemaining(
      hasScrollBody: false,
      child: _EmptyAccountSearchState(
        query: widget.liveQuery,
        networkFailed: _networkFailed,
        onRetry: () => _syncNetwork(forceNetwork: true),
      ),
    );
  }
}

class _OfflineNoticeStrip extends StatelessWidget {
  final VoidCallback onRetry;

  const _OfflineNoticeStrip({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.wifi_exclamationmark,
            size: 14,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Menampilkan data cache lokal',
              style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Muat Ulang',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDirectoryAccountRow extends StatelessWidget {
  final ProfileDirectoryEntry entry;
  final bool isSelf;

  const _LiveDirectoryAccountRow({
    required this.entry,
    required this.isSelf,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = entry.avatarUrl;
    final hasAsset = avatar != null && avatar.startsWith('assets/');
    final hasNet = avatar != null &&
        (avatar.startsWith('http://') || avatar.startsWith('https://'));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _openSafeRoute(
            context,
            isSelf
                ? '/social/profile/me'
                : '/social/profile/${Uri.encodeComponent(entry.userId)}',
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.12),
                  backgroundImage: hasAsset
                      ? CloudAssetManager.imageProvider(avatar)
                      : (hasNet ? NetworkImage(avatar) : null),
                  child: (!hasAsset && !hasNet)
                      ? Text(
                          entry.displayName.isNotEmpty
                              ? entry.displayName[0].toUpperCase()
                              : 'B',
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
                      Text(
                        entry.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${entry.username} • Lv.${entry.baristaLevel} ${entry.baristaRankTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      if (entry.bio.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          entry.bio.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        '${entry.followersCount} pengikut • ${entry.totalThreadsCount} thread',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isSelf)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Akun Anda',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  )
                else
                  _InlineAccountFollowPill(entry: entry),
              ],
            ),
          ),
        ),
        const Divider(height: 1, indent: 69, color: AppTheme.dividerColor),
      ],
    );
  }
}

/// Tombol Ikuti ringan berbasis `entry.isFollowedByViewer` tanpa N+1 HTTP storm.
class _InlineAccountFollowPill extends ConsumerStatefulWidget {
  final ProfileDirectoryEntry entry;

  const _InlineAccountFollowPill({required this.entry});

  @override
  ConsumerState<_InlineAccountFollowPill> createState() =>
      _InlineAccountFollowPillState();
}

class _InlineAccountFollowPillState
    extends ConsumerState<_InlineAccountFollowPill> {
  late bool _followed;
  bool _inFlight = false;

  @override
  void initState() {
    super.initState();
    _followed = widget.entry.isFollowedByViewer;
  }

  @override
  void didUpdateWidget(covariant _InlineAccountFollowPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.userId != widget.entry.userId ||
        oldWidget.entry.isFollowedByViewer != widget.entry.isFollowedByViewer) {
      _followed = widget.entry.isFollowedByViewer;
    }
  }

  Future<void> _toggle() async {
    if (_inFlight) return;
    HapticFeedback.lightImpact();
    final prev = _followed;
    setState(() {
      _followed = !prev;
      _inFlight = true;
    });
    try {
      final api = ref.read(socialProfileApiServiceProvider);
      final res = await api.toggleFollow(widget.entry.userId);
      api.updateCachedFollowState(
        widget.entry.userId,
        isFollowed: res.isFollowedByViewer,
        followersCount: res.followersCount,
      );
      ref.invalidate(userRelationshipControllerProvider(widget.entry.userId));
      if (mounted) {
        setState(() {
          _followed = res.isFollowedByViewer;
          _inFlight = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _followed = prev;
          _inFlight = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
        decoration: BoxDecoration(
          color: _followed ? AppTheme.bgCream : AppTheme.primaryBrown,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _followed ? AppTheme.borderWarm : AppTheme.primaryBrown,
          ),
        ),
        child: Text(
          _followed ? 'Mengikuti' : 'Ikuti',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _followed ? AppTheme.textDark : Colors.white,
          ),
        ),
      ),
    );
  }
}

class FallbackPeerAccount {
  final String targetId;
  final String displayName;
  final String handle;
  final String roleLabel;
  final String avatarPath;
  final bool isSelf;

  const FallbackPeerAccount({
    required this.targetId,
    required this.displayName,
    required this.handle,
    required this.roleLabel,
    required this.avatarPath,
    this.isSelf = false,
  });
}

class _OfflinePeerAccountSliverList extends StatelessWidget {
  final String query;
  final List<FallbackPeerAccount> peers;
  final bool showCacheBanner;
  final VoidCallback? onRetryLive;

  const _OfflinePeerAccountSliverList({
    required this.query,
    required this.peers,
    this.showCacheBanner = false,
    this.onRetryLive,
  });

  @override
  Widget build(BuildContext context) {
    if (peers.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyAccountSearchState(
          query: query,
          networkFailed: showCacheBanner,
          onRetry: onRetryLive,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (showCacheBanner && onRetryLive != null && index == 0) {
              return _OfflineNoticeStrip(onRetry: onRetryLive!);
            }
            final itemIndex =
                (showCacheBanner && onRetryLive != null) ? index - 1 : index;
            final account = peers[itemIndex];
            final img = account.avatarPath.startsWith('http://') ||
                    account.avatarPath.startsWith('https://')
                ? NetworkImage(account.avatarPath) as ImageProvider
                : CloudAssetManager.imageProvider(
                    account.avatarPath.startsWith('assets/')
                        ? account.avatarPath
                        : 'assets/images/characters/avatar_1.png',
                  );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _openSafeRoute(
                    context,
                    account.isSelf
                        ? '/social/profile/me'
                        : '/social/profile/${Uri.encodeComponent(account.targetId)}',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 21,
                          backgroundColor:
                              AppTheme.primaryBrown.withValues(alpha: 0.12),
                          backgroundImage: img,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${account.handle} • ${account.roleLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderWarm),
                          ),
                          child: Text(
                            account.isSelf ? 'Akun Anda' : 'Profil',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  indent: 69,
                  color: AppTheme.dividerColor,
                ),
              ],
            );
          },
          childCount:
              peers.length + (showCacheBanner && onRetryLive != null ? 1 : 0),
        ),
      ),
    );
  }
}

class _EmptyAccountSearchState extends StatelessWidget {
  final String query;
  final bool networkFailed;
  final VoidCallback? onRetry;

  const _EmptyAccountSearchState({
    required this.query,
    this.networkFailed = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = query.trim();
    final message = networkFailed
        ? 'Gagal memuat daftar akun dari server. Ketuk Muat Ulang untuk mencoba kembali.'
        : (trimmed.isEmpty
            ? 'Ketik nama atau @username untuk mencari akun Coffee Labs orang lain'
            : 'Akun "$trimmed" belum ditemukan.');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              networkFailed
                  ? CupertinoIcons.wifi_exclamationmark
                  : CupertinoIcons.person_2,
              size: 38,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: AppTheme.textMuted),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(CupertinoIcons.refresh, size: 15),
                    label: const Text('Muat Ulang'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBrown,
                      side: const BorderSide(color: AppTheme.borderWarm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void _openSafeRoute(BuildContext context, String route) {
  if (GoRouter.maybeOf(context) != null) {
    context.push(route);
  }
}
