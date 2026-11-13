import '../../communities/domain/community_models.dart';
import '../../social_profile_feed/domain/models/social_thread_models.dart';

class RecommendedThreadItem {
  final SocialThreadItem thread;
  final double relevanceScore;
  final int tasteMatchPct;
  final String reasonBadge;
  final bool isTrending;
  final String? communityId;
  final String? communityName;

  const RecommendedThreadItem({
    required this.thread,
    required this.relevanceScore,
    required this.tasteMatchPct,
    required this.reasonBadge,
    required this.isTrending,
    this.communityId,
    this.communityName,
  });

  factory RecommendedThreadItem.fromJson(Map<String, dynamic> json) {
    return RecommendedThreadItem(
      thread: SocialThreadItem.fromJson(json),
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
      tasteMatchPct: (json['taste_match_pct'] as num?)?.toInt() ?? 0,
      reasonBadge: (json['reason_badge'] ?? 'Rekomendasi Seduh').toString(),
      isTrending: json['is_trending'] == true,
      communityId: json['community_id']?.toString(),
      communityName: json['community_name']?.toString(),
    );
  }

  RecommendedThreadItem copyWith({SocialThreadItem? thread}) {
    return RecommendedThreadItem(
      thread: thread ?? this.thread,
      relevanceScore: relevanceScore,
      tasteMatchPct: tasteMatchPct,
      reasonBadge: reasonBadge,
      isTrending: isTrending,
      communityId: communityId,
      communityName: communityName,
    );
  }
}

class ForYouFeedResponse {
  final List<RecommendedThreadItem> items;
  final List<String> userTopTastes;
  final int? nextOffset;
  final bool hasMore;

  const ForYouFeedResponse({
    required this.items,
    required this.userTopTastes,
    this.nextOffset,
    required this.hasMore,
  });

  factory ForYouFeedResponse.fromJson(Map<String, dynamic> json) {
    return ForYouFeedResponse(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map(
            (e) => RecommendedThreadItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      userTopTastes: (json['user_top_tastes'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      nextOffset: (json['next_offset'] as num?)?.toInt(),
      hasMore: json['has_more'] == true,
    );
  }
}

class TrendingFeedResponse {
  final List<RecommendedThreadItem> items;
  final DateTime updatedAt;

  const TrendingFeedResponse({
    required this.items,
    required this.updatedAt,
  });

  factory TrendingFeedResponse.fromJson(Map<String, dynamic> json) {
    return TrendingFeedResponse(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map(
            (e) => RecommendedThreadItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class RecommendedClubsResponse {
  final List<CommunitySummary> items;
  final List<String> userTopTastes;

  const RecommendedClubsResponse({
    required this.items,
    required this.userTopTastes,
  });

  factory RecommendedClubsResponse.fromJson(Map<String, dynamic> json) {
    return RecommendedClubsResponse(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map(
            (e) => CommunitySummary.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      userTopTastes: (json['user_top_tastes'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
