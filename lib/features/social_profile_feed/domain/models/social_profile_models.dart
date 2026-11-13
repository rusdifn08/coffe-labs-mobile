import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_profile_models.freezed.dart';
part 'social_profile_models.g.dart';

@freezed
abstract class BaristaBadgeItem with _$BaristaBadgeItem {
  const factory BaristaBadgeItem({
    required int id,
    required String slug,
    required String title,
    required String rarity,
    @JsonKey(name: 'rive_artboard') String? riveArtboard,
  }) = _BaristaBadgeItem;

  factory BaristaBadgeItem.fromJson(Map<String, dynamic> json) =>
      _$BaristaBadgeItemFromJson(json);
}

@freezed
abstract class RecentBrewSnapshot with _$RecentBrewSnapshot {
  const factory RecentBrewSnapshot({
    @JsonKey(name: 'recipe_id') String? recipeId,
    @JsonKey(name: 'recipe_title') required String recipeTitle,
    @JsonKey(name: 'bean_name') required String beanName,
    required String roastery,
    required String process,
    required String method,
    @JsonKey(name: 'primary_temp_c') int? primaryTempC,
    @JsonKey(name: 'secondary_temp_c') int? secondaryTempC,
    @JsonKey(name: 'coffee_dose_g') double? coffeeDoseG,
    @JsonKey(name: 'total_water_ml') double? totalWaterMl,
    @JsonKey(name: 'target_duration_sec') int? targetDurationSec,
    @JsonKey(name: 'brewed_at') required DateTime brewedAt,
    @JsonKey(name: 'is_live') @Default(false) bool isLive,
    @JsonKey(name: 'accuracy_score') double? accuracyScore,
  }) = _RecentBrewSnapshot;

  factory RecentBrewSnapshot.fromJson(Map<String, dynamic> json) =>
      _$RecentBrewSnapshotFromJson(json);
}

@freezed
abstract class MaterializedProfileView with _$MaterializedProfileView {
  const MaterializedProfileView._();

  const factory MaterializedProfileView({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @Default('') String bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'banner_url') String? bannerUrl,
    @JsonKey(name: 'account_tier') @Default('Trial') String accountTier,
    @JsonKey(name: 'total_xp') @Default(0) int totalXp,
    @JsonKey(name: 'barista_level') @Default(1) int baristaLevel,
    @JsonKey(name: 'barista_rank_title')
    @Default('Home Brewer')
    String baristaRankTitle,
    @JsonKey(name: 'level_progress_ratio')
    @Default(0.0)
    double levelProgressRatio,
    @JsonKey(name: 'next_level_xp') @Default(313) int nextLevelXp,
    @JsonKey(name: 'current_streak_days') @Default(0) int currentStreakDays,
    @JsonKey(name: 'unlocked_badge_ids')
    @Default([])
    List<int> unlockedBadgeIds,
    @JsonKey(name: 'top_featured_badges')
    @Default([])
    List<BaristaBadgeItem> topFeaturedBadges,
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    @JsonKey(name: 'total_threads_count') @Default(0) int totalThreadsCount,
    @JsonKey(name: 'total_brews_count') @Default(0) int totalBrewsCount,
    @JsonKey(name: 'total_recipes_created_count')
    @Default(0)
    int totalRecipesCreatedCount,
    @JsonKey(name: 'total_recipe_tries_received')
    @Default(0)
    int totalRecipeTriesReceived,
    @JsonKey(name: 'recent_brew_snapshot')
    RecentBrewSnapshot? recentBrewSnapshot,
    @JsonKey(name: 'is_followed_by_viewer')
    @Default(false)
    bool isFollowedByViewer,
    @JsonKey(name: 'is_following_viewer')
    @Default(false)
    bool isFollowingViewer,
    @JsonKey(name: 'is_own_profile') @Default(false) bool isOwnProfile,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _MaterializedProfileView;

  factory MaterializedProfileView.fromJson(Map<String, dynamic> json) =>
      _$MaterializedProfileViewFromJson(json);

  Color get rankAccentColor {
    if (baristaLevel >= 80) return const Color(0xFFA78BFA);
    if (baristaLevel >= 50) return const Color(0xFF10B981);
    if (baristaLevel >= 25) return const Color(0xFFD4AF37);
    if (baristaLevel >= 10) return const Color(0xFF94A3B8);
    return const Color(0xFFCD7F32);
  }

  List<Color> get tierRingGradient {
    switch (accountTier.toLowerCase()) {
      case 'business':
        return const [Color(0xFFA78BFA), Color(0xFF312E81), Color(0xFF38BDF8)];
      case 'pro':
        return const [Color(0xFFFDE68A), Color(0xFFD4AF37), Color(0xFFB45309)];
      default:
        return [rankAccentColor, const Color(0xFF8D5B4C)];
    }
  }
}

@freezed
abstract class ProfileDirectoryEntry with _$ProfileDirectoryEntry {
  const factory ProfileDirectoryEntry({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @Default('') String bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'account_tier') @Default('Trial') String accountTier,
    @JsonKey(name: 'total_xp') @Default(0) int totalXp,
    @JsonKey(name: 'barista_level') @Default(1) int baristaLevel,
    @JsonKey(name: 'barista_rank_title')
    @Default('Home Brewer')
    String baristaRankTitle,
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'total_threads_count') @Default(0) int totalThreadsCount,
    @JsonKey(name: 'recent_brew_snapshot')
    RecentBrewSnapshot? recentBrewSnapshot,
    @JsonKey(name: 'is_followed_by_viewer')
    @Default(false)
    bool isFollowedByViewer,
  }) = _ProfileDirectoryEntry;

  factory ProfileDirectoryEntry.fromJson(Map<String, dynamic> json) =>
      _$ProfileDirectoryEntryFromJson(json);
}

@freezed
abstract class FollowToggleResult with _$FollowToggleResult {
  const factory FollowToggleResult({
    @JsonKey(name: 'target_user_id') required String targetUserId,
    @JsonKey(name: 'is_followed_by_viewer') required bool isFollowedByViewer,
    @JsonKey(name: 'followers_count') required int followersCount,
  }) = _FollowToggleResult;

  factory FollowToggleResult.fromJson(Map<String, dynamic> json) =>
      _$FollowToggleResultFromJson(json);
}
