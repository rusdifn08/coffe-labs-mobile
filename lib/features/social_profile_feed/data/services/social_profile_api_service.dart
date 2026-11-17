import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/models/social_profile_models.dart';
import '../../domain/models/social_thread_models.dart';

class _DirectoryCacheBucket {
  final List<ProfileDirectoryEntry> items;
  final String? nextCursor;
  final bool hasMore;
  final DateTime cachedAt;

  const _DirectoryCacheBucket({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    required this.cachedAt,
  });
}

class SocialProfileApiService {
  static const Duration _directoryCacheTtl = Duration(seconds: 45);
  static const Duration _profileCacheTtl = Duration(seconds: 30);
  final Dio _dio;
  final Map<String, ProfileDirectoryEntry> _knownProfilesById = {};
  final Map<String, _DirectoryCacheBucket> _queryCache = {};
  final Map<String, ({MaterializedProfileView profile, DateTime cachedAt})>
      _profileCache = {};

  SocialProfileApiService(this._dio);

  static String normalizeDirectoryQuery(String? raw) {
    return (raw ?? '').trim().replaceFirst(RegExp(r'^@+'), '').toLowerCase();
  }

  void rememberProfiles(Iterable<ProfileDirectoryEntry> entries) {
    for (final entry in entries) {
      if (entry.userId.isEmpty) continue;
      _knownProfilesById.putIfAbsent(entry.userId, () => entry);
    }
  }

  /// Pencarian instan di RAM L1 terhadap seluruh akun Coffee Labs yang sudah pernah dimuat.
  List<ProfileDirectoryEntry> searchCachedProfiles(String? rawQuery) {
    if (_knownProfilesById.isEmpty) return const [];
    final clean = normalizeDirectoryQuery(rawQuery);
    final entries = _knownProfilesById.values.where((entry) {
      if (clean.isEmpty) return true;
      return entry.username.toLowerCase().contains(clean) ||
          entry.displayName.toLowerCase().contains(clean) ||
          entry.baristaRankTitle.toLowerCase().contains(clean);
    }).toList();

    entries.sort((a, b) {
      if (clean.isNotEmpty) {
        final aRank = _matchScore(a, clean);
        final bRank = _matchScore(b, clean);
        if (aRank != bRank) return aRank.compareTo(bRank);
      }
      final xpCmp = b.totalXp.compareTo(a.totalXp);
      if (xpCmp != 0) return xpCmp;
      return a.username.toLowerCase().compareTo(b.username.toLowerCase());
    });
    return entries;
  }

  int _matchScore(ProfileDirectoryEntry e, String clean) {
    final u = e.username.toLowerCase();
    final d = e.displayName.toLowerCase();
    if (u == clean) return 0;
    if (u.startsWith(clean)) return 1;
    if (d.startsWith(clean)) return 2;
    return 3;
  }

  CursorPaginatedResult<ProfileDirectoryEntry>? getFreshQueryCache(
    String? query, {
    int limit = 30,
  }) {
    final key = '${normalizeDirectoryQuery(query)}:$limit';
    final hit = _queryCache[key];
    if (hit == null) return null;
    if (DateTime.now().difference(hit.cachedAt) > _directoryCacheTtl) {
      _queryCache.remove(key);
      return null;
    }
    return CursorPaginatedResult(
      items: hit.items,
      nextCursor: hit.nextCursor,
      hasMore: hit.hasMore,
    );
  }

  void updateCachedFollowState(
    String userId, {
    required bool isFollowed,
    required int followersCount,
  }) {
    final existing = _knownProfilesById[userId];
    if (existing == null) return;
    final updated = existing.copyWith(
      isFollowedByViewer: isFollowed,
      followersCount: followersCount,
    );
    _knownProfilesById[userId] = updated;
    for (final key in _queryCache.keys.toList()) {
      final bucket = _queryCache[key]!;
      _queryCache[key] = _DirectoryCacheBucket(
        items: bucket.items
            .map((e) => e.userId == userId ? updated : e)
            .toList(),
        nextCursor: bucket.nextCursor,
        hasMore: bucket.hasMore,
        cachedAt: bucket.cachedAt,
      );
    }
  }

  Future<CursorPaginatedResult<ProfileDirectoryEntry>> exploreProfiles({
    String? query,
    String? cursor,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    final clean = normalizeDirectoryQuery(query);
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/profiles',
      queryParameters: {
        if (clean.isNotEmpty) 'q': clean,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
      },
      cancelToken: cancelToken,
      options: Options(
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
      ),
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    final items = (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ProfileDirectoryEntry.fromJson)
        .toList();

    for (final entry in items) {
      _knownProfilesById[entry.userId] = entry;
    }

    final result = CursorPaginatedResult(
      items: items,
      nextCursor: data['next_cursor'] as String?,
      hasMore: data['has_more'] == true,
    );
    if (cursor == null || cursor.isEmpty) {
      if (_queryCache.length >= 40) {
        _queryCache.clear();
      }
      _queryCache['$clean:$limit'] = _DirectoryCacheBucket(
        items: result.items,
        nextCursor: result.nextCursor,
        hasMore: result.hasMore,
        cachedAt: DateTime.now(),
      );
    }
    return result;
  }

  MaterializedProfileView? getFreshProfileCache(String targetUserOrUsername) {
    final clean = normalizeDirectoryQuery(targetUserOrUsername);
    final hit = _profileCache[clean];
    if (hit == null) return null;
    if (DateTime.now().difference(hit.cachedAt) > _profileCacheTtl) {
      _profileCache.remove(clean);
      return null;
    }
    return hit.profile;
  }

  Future<MaterializedProfileView> getProfile(
    String targetUserOrUsername, {
    bool forceRefresh = false,
  }) async {
    final trimmed = targetUserOrUsername.trim();
    final clean = normalizeDirectoryQuery(trimmed);
    if (clean.isEmpty) {
      throw const ApiException(
        message: 'Username atau ID akun tidak valid.',
        statusCode: 400,
      );
    }

    if (!forceRefresh) {
      final hit = getFreshProfileCache(trimmed);
      if (hit != null) return hit;
    }

    final safeTarget = Uri.encodeComponent(trimmed);
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/social/profiles/$safeTarget',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
      final profile = MaterializedProfileView.fromJson(data);
      final entry = (profile: profile, cachedAt: DateTime.now());
      _profileCache[clean] = entry;
      _profileCache[profile.userId.toLowerCase()] = entry;
      if (profile.username.isNotEmpty) {
        _profileCache[profile.username.toLowerCase()] = entry;
      }
      _knownProfilesById[profile.userId] = ProfileDirectoryEntry(
        userId: profile.userId,
        username: profile.username,
        displayName: profile.displayName,
        bio: profile.bio,
        avatarUrl: profile.avatarUrl,
        accountTier: profile.accountTier,
        totalXp: profile.totalXp,
        baristaLevel: profile.baristaLevel,
        baristaRankTitle: profile.baristaRankTitle,
        followersCount: profile.followersCount,
        totalThreadsCount: profile.totalThreadsCount,
        recentBrewSnapshot: profile.recentBrewSnapshot,
        isFollowedByViewer: profile.isFollowedByViewer,
      );
      return profile;
    } on DioException catch (e) {
      final stale = _profileCache[clean];
      if (stale != null && (e.response?.statusCode ?? 500) >= 500) {
        return stale.profile;
      }
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<MaterializedProfileView> updateMyProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? bannerUrl,
    RecentBrewSnapshot? recentBrewSnapshot,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/social/profiles/me',
      data: {
        'display_name': ?displayName,
        'bio': ?bio,
        'avatar_url': ?avatarUrl,
        'banner_url': ?bannerUrl,
        if (recentBrewSnapshot != null)
          'recent_brew_snapshot': recentBrewSnapshot.toJson(),
      },
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    return MaterializedProfileView.fromJson(data);
  }

  Future<FollowToggleResult> toggleFollow(String targetUserOrUsername) async {
    final safeTarget = Uri.encodeComponent(targetUserOrUsername.trim());
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/social/profiles/$safeTarget/follow',
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    return FollowToggleResult.fromJson(data);
  }

  Future<List<ProfileDirectoryEntry>> getFollowers(
    String targetUserOrUsername,
  ) async {
    final safeTarget = Uri.encodeComponent(targetUserOrUsername.trim());
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/profiles/$safeTarget/followers',
    );
    final list = res.data?['data'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ProfileDirectoryEntry.fromJson)
        .toList();
  }

  Future<List<ProfileDirectoryEntry>> getFollowing(
    String targetUserOrUsername,
  ) async {
    final safeTarget = Uri.encodeComponent(targetUserOrUsername.trim());
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/profiles/$safeTarget/following',
    );
    final list = res.data?['data'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ProfileDirectoryEntry.fromJson)
        .toList();
  }

  Future<CursorPaginatedResult<SocialThreadItem>> getProfileTabThreads({
    required String targetUserOrUsername,
    required ProfileFeedTab tab,
    String? cursor,
    int limit = 20,
  }) async {
    final safeTarget = Uri.encodeComponent(targetUserOrUsername.trim());
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/profiles/$safeTarget/threads',
      queryParameters: {
        'tab': tab.wireValue,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
      },
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    final items = (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SocialThreadItem.fromJson)
        .toList();
    return CursorPaginatedResult(
      items: items,
      nextCursor: data['next_cursor'] as String?,
      hasMore: data['has_more'] == true,
    );
  }

  Future<CursorPaginatedResult<SocialThreadItem>> getGlobalTimeline({
    String scope = 'for_you',
    String? cursor,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/threads/timeline',
      queryParameters: {
        'scope': scope,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
      },
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    final items = (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SocialThreadItem.fromJson)
        .toList();
    return CursorPaginatedResult(
      items: items,
      nextCursor: data['next_cursor'] as String?,
      hasMore: data['has_more'] == true,
    );
  }

  Future<ThreadDetailResponse> getThreadDetail(String threadId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/threads/$threadId',
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    return ThreadDetailResponse.fromJson(data);
  }

  Future<SocialThreadItem> createThread({
    required String kind,
    required String bodyText,
    String? parentThreadId,
    String? quotedThreadId,
    List<MediaAttachmentItem> mediaUrls = const [],
    ThreadAttachment? attachment,
    RecentBrewSnapshot? recentBrewSnapshot,
    bool pinOnProfile = false,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/social/threads',
      data: {
        'kind': kind,
        'body_text': bodyText,
        'parent_thread_id': ?parentThreadId,
        'quoted_thread_id': ?quotedThreadId,
        'media_urls': mediaUrls.map((m) => m.toJson()).toList(),
        if (attachment != null) 'attachment': attachment.toWireJson(),
        if (recentBrewSnapshot != null)
          'recent_brew_snapshot': recentBrewSnapshot.toJson(),
        'pin_on_profile': pinOnProfile,
      },
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    return SocialThreadItem.fromJson(data);
  }

  Future<Map<String, dynamic>> toggleLike(String threadId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/social/threads/$threadId/like',
    );
    return res.data?['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<Map<String, dynamic>> toggleRepost(String threadId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/social/threads/$threadId/repost',
    );
    return res.data?['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<Map<String, dynamic>> recordTryRecipe(String threadId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/social/threads/$threadId/try-recipe',
    );
    return res.data?['data'] as Map<String, dynamic>? ?? const {};
  }

  Future<void> deleteThread(String threadId) async {
    await _dio.delete<Map<String, dynamic>>(
      '/api/v1/social/threads/$threadId/delete',
    );
  }
}

class CursorPaginatedResult<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  const CursorPaginatedResult({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}
