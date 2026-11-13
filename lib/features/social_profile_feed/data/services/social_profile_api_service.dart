import 'package:dio/dio.dart';

import '../../domain/models/social_profile_models.dart';
import '../../domain/models/social_thread_models.dart';

class SocialProfileApiService {
  final Dio _dio;

  SocialProfileApiService(this._dio);

  Future<CursorPaginatedResult<ProfileDirectoryEntry>> exploreProfiles({
    String? query,
    String? cursor,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/profiles',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
      },
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    final items = (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ProfileDirectoryEntry.fromJson)
        .toList();
    return CursorPaginatedResult(
      items: items,
      nextCursor: data['next_cursor'] as String?,
      hasMore: data['has_more'] == true,
    );
  }

  Future<MaterializedProfileView> getProfile(String targetUserOrUsername) async {
    final safeTarget = Uri.encodeComponent(targetUserOrUsername.trim());
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/profiles/$safeTarget',
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    return MaterializedProfileView.fromJson(data);
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
