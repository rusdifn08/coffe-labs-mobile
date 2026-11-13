import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../domain/explore_feed_models.dart';

class ExploreFeedApiService {
  final Dio _dio;

  ExploreFeedApiService(this._dio);

  dynamic _unwrapData(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  Future<ForYouFeedResponse> getForYouFeed({
    int cursorOffset = 0,
    int limit = 20,
    String? methodFilter,
    bool refresh = false,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/feed/for-you',
        queryParameters: {
          'cursor_offset': cursorOffset,
          'limit': limit,
          if (methodFilter != null && methodFilter != 'ALL')
            'method_filter': methodFilter,
          if (refresh) 'refresh': true,
        },
      );
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return ForYouFeedResponse.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<TrendingFeedResponse> getTrendingFeed({int limit = 25}) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/feed/trending',
        queryParameters: {'limit': limit},
      );
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return TrendingFeedResponse.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<RecommendedClubsResponse> getRecommendedClubs() async {
    try {
      final res = await _dio.get<dynamic>('/api/v1/clubs/recommended');
      final data = Map<String, dynamic>.from(_unwrapData(res) as Map);
      return RecommendedClubsResponse.fromJson(data);
    } on DioException catch (e) {
      throw GlobalErrorAndLoggingInterceptor.mapDioException(e);
    }
  }

  Future<void> markSeenAndEngaged({
    List<String> threadIds = const [],
    List<String> engagedThreadIds = const [],
  }) async {
    if (threadIds.isEmpty && engagedThreadIds.isEmpty) return;
    try {
      await _dio.post<dynamic>(
        '/api/v1/feed/seen',
        data: {
          'thread_ids': threadIds,
          'engaged_thread_ids': engagedThreadIds,
        },
      );
    } catch (_) {
      // Best-effort telemetry; fail silently.
    }
  }
}
