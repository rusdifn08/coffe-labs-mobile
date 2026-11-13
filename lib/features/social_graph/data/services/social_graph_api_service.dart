import 'package:dio/dio.dart';

import '../../domain/models/social_graph_models.dart';

class SocialGraphApiService {
  final Dio _dio;

  SocialGraphApiService(this._dio);

  Map<String, dynamic> _unwrapMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final inner = raw['data'];
      if (inner is Map<String, dynamic>) return inner;
      return raw;
    }
    return const {};
  }

  Future<RelationshipSnapshot> getRelationshipSnapshot(
    String targetUserOrUsername,
  ) async {
    final encoded = Uri.encodeComponent(targetUserOrUsername.trim());
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/graph/relationship/$encoded',
    );
    return RelationshipSnapshot.fromJson(_unwrapMap(res.data));
  }

  Future<FollowMutationResult> followUser(String targetUserOrUsername) async {
    final encoded = Uri.encodeComponent(targetUserOrUsername.trim());
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/social/graph/users/$encoded/follow',
    );
    return FollowMutationResult.fromJson(_unwrapMap(res.data));
  }

  Future<FollowMutationResult> unfollowUser(String targetUserOrUsername) async {
    final encoded = Uri.encodeComponent(targetUserOrUsername.trim());
    final res = await _dio.delete<Map<String, dynamic>>(
      '/api/v1/social/graph/users/$encoded/follow',
    );
    return FollowMutationResult.fromJson(_unwrapMap(res.data));
  }

  Future<List<BatchRelationshipItem>> batchCheckRelationships(
    List<String> targetIds,
  ) async {
    if (targetIds.isEmpty) return const [];
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/social/graph/relationships/batch',
      data: {'target_ids': targetIds.take(50).toList()},
    );
    final data = _unwrapMap(res.data);
    return (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BatchRelationshipItem.fromJson)
        .toList();
  }

  Future<SocialGraphCursorPage<SocialGraphUserItem>> listConnections({
    required String targetUserOrUsername,
    required String kind,
    String? cursor,
    int limit = 20,
  }) async {
    final encoded = Uri.encodeComponent(targetUserOrUsername.trim());
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/graph/users/$encoded/$kind',
      queryParameters: {
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
      },
    );
    final data = _unwrapMap(res.data);
    final items = (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SocialGraphUserItem.fromJson)
        .toList();
    return SocialGraphCursorPage(
      items: items,
      nextCursor: data['next_cursor'] as String?,
      hasMore: data['has_more'] == true,
    );
  }

  Future<SocialGraphCursorPage<FollowRequestItem>> listPendingRequests({
    String? cursor,
    int limit = 20,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/graph/requests/pending',
      queryParameters: {
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
      },
    );
    final data = _unwrapMap(res.data);
    final items = (data['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(FollowRequestItem.fromJson)
        .toList();
    return SocialGraphCursorPage(
      items: items,
      nextCursor: data['next_cursor'] as String?,
      hasMore: data['has_more'] == true,
    );
  }

  Future<PendingRequestActionResult> handleFollowRequest({
    required String requesterId,
    required bool accept,
  }) async {
    final verb = accept ? 'accept' : 'reject';
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/social/graph/requests/$requesterId/$verb',
    );
    return PendingRequestActionResult.fromJson(_unwrapMap(res.data));
  }

  Future<void> removeFollower(String followerId) async {
    await _dio.delete<Map<String, dynamic>>(
      '/api/v1/social/graph/followers/$followerId',
    );
  }

  Future<PrivacySettingSnapshot> getPrivacySetting() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/social/graph/privacy',
    );
    return PrivacySettingSnapshot.fromJson(_unwrapMap(res.data));
  }

  Future<PrivacySettingSnapshot> updatePrivacySetting(bool isPrivate) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/social/graph/privacy',
      data: {'is_private_account': isPrivate},
    );
    return PrivacySettingSnapshot.fromJson(_unwrapMap(res.data));
  }
}
