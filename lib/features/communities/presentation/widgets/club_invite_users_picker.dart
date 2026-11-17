import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/auth_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../social_chat/presentation/controllers/chat_controllers.dart';
import '../../../social_graph/domain/models/social_graph_models.dart';
import '../../../social_graph/presentation/controllers/relationship_controller.dart';
import '../../../social_profile_feed/data/services/social_profile_api_service.dart';
import '../../../social_profile_feed/domain/models/social_profile_models.dart';
import '../../../social_profile_feed/presentation/controllers/social_profile_controllers.dart';

class _InvitePeerCandidate {
  final ProfileDirectoryEntry profile;
  final bool isMutual;
  final bool isFollowing;

  const _InvitePeerCandidate({
    required this.profile,
    this.isMutual = false,
    this.isFollowing = false,
  });

  _InvitePeerCandidate mergeWith(_InvitePeerCandidate other) {
    final nextMutual = isMutual || other.isMutual;
    final nextFollowing = isFollowing || other.isFollowing || nextMutual;
    final richerProfile = profile.bio.isNotEmpty || profile.totalXp > other.profile.totalXp
        ? profile.copyWith(isFollowedByViewer: nextFollowing)
        : other.profile.copyWith(isFollowedByViewer: nextFollowing);
    return _InvitePeerCandidate(
      profile: richerProfile,
      isMutual: nextMutual,
      isFollowing: nextFollowing,
    );
  }
}

class ClubInviteUsersPicker extends ConsumerStatefulWidget {
  final List<ProfileDirectoryEntry> selectedUsers;
  final ValueChanged<ProfileDirectoryEntry> onToggleUser;
  final Set<String> excludeUserIds;
  final TextEditingController? messageController;
  final double maxListHeight;

  const ClubInviteUsersPicker({
    super.key,
    required this.selectedUsers,
    required this.onToggleUser,
    this.excludeUserIds = const {},
    this.messageController,
    this.maxListHeight = 200,
  });

  @override
  ConsumerState<ClubInviteUsersPicker> createState() =>
      _ClubInviteUsersPickerState();
}

class _ClubInviteUsersPickerState extends ConsumerState<ClubInviteUsersPicker> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Map<String, _InvitePeerCandidate> _candidatePool = {};
  Timer? _debounce;
  CancelToken? _cancelToken;

  List<_InvitePeerCandidate> _results = [];
  bool _loading = true;
  String? _error;
  String _selfId = '';

  @override
  void initState() {
    super.initState();
    _initAndSearch('');
  }

  Future<void> _initAndSearch(String query) async {
    if (_selfId.isEmpty) {
      final me = await AuthService.getCurrentUser();
      _selfId = (me?.id ?? '').trim().toLowerCase();
    }
    await _runSearch(query);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged(String val) {
    final trimmed = val.trim();
    final api = ref.read(socialProfileApiServiceProvider);
    final localCached = _buildRankedFromPoolAndCache(
      trimmed,
      api.searchCachedProfiles(trimmed),
    );
    if (localCached.isNotEmpty) {
      setState(() {
        _results = localCached;
        _error = null;
      });
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      _runSearch(trimmed);
    });
  }

  void _upsertCandidate(_InvitePeerCandidate incoming) {
    final uid = incoming.profile.userId.trim();
    if (uid.isEmpty) return;
    final key = uid.toLowerCase();
    final normalized = _InvitePeerCandidate(
      profile: incoming.profile.copyWith(userId: uid),
      isMutual: incoming.isMutual,
      isFollowing: incoming.isFollowing,
    );
    final existing = _candidatePool[key];
    _candidatePool[key] =
        existing == null ? normalized : existing.mergeWith(normalized);
  }

  List<_InvitePeerCandidate> _buildRankedFromPoolAndCache(
    String rawQuery,
    List<ProfileDirectoryEntry> directoryCache,
  ) {
    for (final entry in directoryCache) {
      _upsertCandidate(
        _InvitePeerCandidate(
          profile: entry,
          isFollowing: entry.isFollowedByViewer,
        ),
      );
    }

    final clean = SocialProfileApiService.normalizeDirectoryQuery(rawQuery);
    final excluded = widget.excludeUserIds.map((e) => e.trim().toLowerCase()).toSet();

    final list = _candidatePool.values.where((c) {
      final uid = c.profile.userId.trim().toLowerCase();
      if (_selfId.isNotEmpty && uid == _selfId) return false;
      if (excluded.contains(uid)) return false;
      if (clean.isEmpty) return true;
      return c.profile.username.toLowerCase().contains(clean) ||
          c.profile.displayName.toLowerCase().contains(clean) ||
          c.profile.baristaRankTitle.toLowerCase().contains(clean);
    }).toList();

    list.sort((a, b) {
      if (a.isMutual != b.isMutual) return a.isMutual ? -1 : 1;
      if (a.isFollowing != b.isFollowing) return a.isFollowing ? -1 : 1;
      if (clean.isNotEmpty) {
        final aExact = a.profile.username.toLowerCase() == clean ? 0 : 1;
        final bExact = b.profile.username.toLowerCase() == clean ? 0 : 1;
        if (aExact != bExact) return aExact.compareTo(bExact);
      }
      final xpCmp = b.profile.totalXp.compareTo(a.profile.totalXp);
      if (xpCmp != 0) return xpCmp;
      return a.profile.username
          .toLowerCase()
          .compareTo(b.profile.username.toLowerCase());
    });
    return list;
  }

  ProfileDirectoryEntry _fromGraphUser(
    SocialGraphUserItem u, {
    required bool isFollowed,
  }) {
    return ProfileDirectoryEntry(
      userId: u.userId.trim(),
      username: u.username,
      displayName: u.displayName,
      avatarUrl: u.avatarUrl,
      accountTier: u.accountTier,
      baristaLevel: u.baristaLevel,
      baristaRankTitle: u.baristaRankTitle,
      isFollowedByViewer: isFollowed,
    );
  }

  Future<void> _runSearch(String query) async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    final token = _cancelToken;

    final profileApi = ref.read(socialProfileApiServiceProvider);
    final graphApi = ref.read(socialGraphApiServiceProvider);
    final chatApi = ref.read(chatApiServiceProvider);

    final initialPool = _buildRankedFromPoolAndCache(
      query,
      profileApi.searchCachedProfiles(query),
    );
    if (mounted) {
      setState(() {
        if (initialPool.isNotEmpty) _results = initialPool;
        _loading = _results.isEmpty;
        _error = null;
      });
    }

    var anySourceSucceeded = false;

    Future<void> fetchMutuals() async {
      try {
        final target = _selfId.isNotEmpty ? _selfId : 'me';
        final page = await graphApi.listConnections(
          targetUserOrUsername: target,
          kind: 'mutual',
          limit: 40,
        );
        anySourceSucceeded = true;
        for (final item in page.items) {
          _upsertCandidate(
            _InvitePeerCandidate(
              profile: _fromGraphUser(item, isFollowed: true),
              isMutual: true,
              isFollowing: true,
            ),
          );
        }
      } catch (_) {}
    }

    Future<void> fetchFollowing() async {
      try {
        final target = _selfId.isNotEmpty ? _selfId : 'me';
        final page = await graphApi.listConnections(
          targetUserOrUsername: target,
          kind: 'following',
          limit: 40,
        );
        anySourceSucceeded = true;
        for (final item in page.items) {
          final isMutual = item.relationshipState == RelationshipState.mutual;
          _upsertCandidate(
            _InvitePeerCandidate(
              profile: _fromGraphUser(item, isFollowed: true),
              isMutual: isMutual,
              isFollowing: true,
            ),
          );
        }
      } catch (_) {}
    }

    Future<void> fetchDirectory() async {
      try {
        final res = await profileApi.exploreProfiles(
          query: query.isEmpty ? null : query,
          limit: 25,
          cancelToken: token,
        );
        anySourceSucceeded = true;
        for (final item in res.items) {
          _upsertCandidate(
            _InvitePeerCandidate(
              profile: item,
              isFollowing: item.isFollowedByViewer,
            ),
          );
        }
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) rethrow;
      } catch (_) {}
    }

    Future<void> fetchChatPeers() async {
      try {
        final peers = await chatApi.searchPeers(
          query: query.isEmpty ? null : query,
          limit: 25,
        );
        anySourceSucceeded = true;
        for (final p in peers) {
          _upsertCandidate(
            _InvitePeerCandidate(
              profile: ProfileDirectoryEntry(
                userId: p.id.trim(),
                username: p.username,
                displayName:
                    p.fullName.trim().isNotEmpty ? p.fullName : p.username,
                avatarUrl: p.avatarUrl,
                baristaRankTitle:
                    p.role.isNotEmpty ? p.role : 'Barista Coffee Labs',
              ),
            ),
          );
        }
      } catch (_) {}
    }

    try {
      await Future.wait([
        fetchMutuals(),
        fetchFollowing(),
        fetchDirectory(),
        fetchChatPeers(),
      ]);
      if (!mounted || (token?.isCancelled ?? false)) return;

      final merged = _buildRankedFromPoolAndCache(
        query,
        profileApi.searchCachedProfiles(query),
      );
      setState(() {
        _results = merged;
        _loading = false;
        _error = (!anySourceSucceeded && merged.isEmpty)
            ? 'Tidak dapat memuat daftar barista.'
            : null;
      });
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds =
        widget.selectedUsers.map((e) => e.userId.trim().toLowerCase()).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: _onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Cari teman saling follow atau @username...',
            hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            prefixIcon: const Icon(CupertinoIcons.search, size: 18),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(CupertinoIcons.clear_circled_solid, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      _onQueryChanged('');
                    },
                  )
                : null,
            filled: true,
            fillColor: AppTheme.surfaceWhite,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderWarm),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderWarm),
            ),
          ),
        ),
        if (widget.selectedUsers.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.selectedUsers.map((u) {
              return InputChip(
                avatar: CircleAvatar(
                  backgroundColor: AppTheme.primaryBrown,
                  child: Text(
                    u.displayName.isNotEmpty
                        ? u.displayName[0].toUpperCase()
                        : 'B',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                label: Text(
                  '@${u.username}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                deleteIcon:
                    const Icon(CupertinoIcons.xmark_circle_fill, size: 16),
                backgroundColor: AppTheme.accentAmber.withValues(alpha: 0.2),
                side:
                    BorderSide(color: AppTheme.accentGold.withValues(alpha: 0.5)),
                onDeleted: () => widget.onToggleUser(u),
              );
            }).toList(),
          ),
        ],
        if (widget.messageController != null &&
            widget.selectedUsers.isNotEmpty) ...[
          const SizedBox(height: 8),
          TextField(
            controller: widget.messageController,
            maxLength: 180,
            decoration: InputDecoration(
              counterText: '',
              labelText: 'Pesan ajakan opsional',
              hintText: 'Yuk gabung diskusi seduh & tukar resep V60 di Coffee Club!',
              filled: true,
              fillColor: AppTheme.surfaceWhite,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderWarm),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(maxHeight: widget.maxListHeight),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Material(
              color: AppTheme.surfaceWhite,
              child: _buildResultsBody(selectedIds),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsBody(Set<String> selectedIds) {
    if (_loading) {
      return const SizedBox(
        height: 92,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppTheme.primaryBrown,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.wifi_exclamationmark,
              size: 18,
              color: AppTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ),
            TextButton(
              onPressed: () => _runSearch(_searchCtrl.text.trim()),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Tidak ada barista yang cocok dengan pencarian.',
            style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _results.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 56, color: AppTheme.dividerColor),
      itemBuilder: (context, idx) {
        final candidate = _results[idx];
        final peer = candidate.profile;
        final isSelected =
            selectedIds.contains(peer.userId.trim().toLowerCase());
        return ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: CircleAvatar(
            radius: 17,
            backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.12),
            child: Text(
              peer.displayName.isNotEmpty
                  ? peer.displayName[0].toUpperCase()
                  : 'B',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.primaryBrown,
              ),
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  peer.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (candidate.isMutual || candidate.isFollowing) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: candidate.isMutual
                        ? AppTheme.accentAmber.withValues(alpha: 0.22)
                        : AppTheme.primaryBrown.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    candidate.isMutual ? 'Saling Follow' : 'Mengikuti',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            '@${peer.username} • Lv.${peer.baristaLevel}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
          ),
          trailing: isSelected
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.check_mark,
                          color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Diundang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              : OutlinedButton(
                  onPressed: () => widget.onToggleUser(peer),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                    side: const BorderSide(color: AppTheme.borderWarm),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    '+ Undang',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
          onTap: () => widget.onToggleUser(peer),
        );
      },
    );
  }
}
