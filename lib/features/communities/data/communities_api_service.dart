import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../social_profile_feed/domain/models/social_thread_models.dart';
import '../domain/community_models.dart';

class CommunitiesApiService {
  final Dio _dio;

  CommunitiesApiService(this._dio);

  dynamic _unwrapData(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  Future<DiscoverCommunitiesResponse> discoverCommunities({
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/communities/discover',
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          'limit': limit,
          'offset': offset,
        },
      );
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return DiscoverCommunitiesResponse.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<CommunityWorkspace> createCommunity({
    required String name,
    String? handleSlug,
    required String description,
    required String privacyLevel,
    List<String> focusTags = const [],
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/communities',
        data: {
          'name': name.trim(),
          if (handleSlug != null && handleSlug.trim().isNotEmpty)
            'handle_slug': handleSlug.trim(),
          'description': description.trim(),
          'privacy_level': privacyLevel,
          'focus_tags': focusTags,
        },
      );
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return CommunityWorkspace.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<CommunityWorkspace> getWorkspace(String communityId) async {
    try {
      final res = await _dio.get<dynamic>('/api/v1/communities/$communityId');
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return CommunityWorkspace.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<JoinClubResponse> joinPublicClub(String communityId) async {
    try {
      final res =
          await _dio.post<dynamic>('/api/v1/communities/$communityId/join');
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return JoinClubResponse.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<JoinClubResponse> joinBySecretCode(String secretCode) async {
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/communities/join-by-secret',
        data: {'secret_code': secretCode},
      );
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return JoinClubResponse.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<JoinClubResponse> joinByInviteToken(String token) async {
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/communities/join-by-link/$token',
      );
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return JoinClubResponse.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<List<CommunityInviteSecret>> listInvites(String communityId) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/communities/$communityId/invites',
      );
      final list = _unwrapData(res) as List<dynamic>? ?? const [];
      return list
          .map((e) => CommunityInviteSecret.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<CommunityInviteSecret> createInvite({
    required String communityId,
    int? maxUses,
    int? expiresInHours,
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/communities/$communityId/invites',
        data: {
          'role_granted': 'BARISTA_MEMBER',
          'max_uses': ?maxUses,
          'expires_in_hours': ?expiresInHours,
        },
      );
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return CommunityInviteSecret.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<void> revokeInvite(String communityId, String inviteId) async {
    try {
      await _dio.delete<dynamic>(
        '/api/v1/communities/$communityId/invites/$inviteId',
      );
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<List<SocialThreadItem>> getClubFeed(
    String communityId, {
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/communities/$communityId/feed',
        queryParameters: {
          'cursor': ?cursor,
          'limit': limit,
        },
      );
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      final items = data['items'] as List<dynamic>? ?? const [];
      return items
          .map((e) => SocialThreadItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<List<SocialThreadItem>> getClubRecipeVault(String communityId) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/communities/$communityId/recipe-vault',
      );
      final items = _unwrapData(res) as List<dynamic>? ?? const [];
      return items
          .map((e) => SocialThreadItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<SocialThreadItem> createClubPost({
    required String communityId,
    required String bodyText,
    String kind = 'STANDARD_POST',
    ThreadAttachment? attachment,
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/communities/$communityId/feed',
        data: {
          'kind': kind,
          'body_text': bodyText.trim(),
          if (attachment != null) 'attachment': attachment.toWireJson(),
        },
      );
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return SocialThreadItem.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<List<CommunityLeaderboardEntry>> getLeaderboard(
    String communityId,
  ) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/communities/$communityId/leaderboard',
      );
      final items = _unwrapData(res) as List<dynamic>? ?? const [];
      return items
          .map((e) => CommunityLeaderboardEntry.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }
}
