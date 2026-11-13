// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BaristaBadgeItem _$BaristaBadgeItemFromJson(Map<String, dynamic> json) =>
    _BaristaBadgeItem(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String,
      title: json['title'] as String,
      rarity: json['rarity'] as String,
      riveArtboard: json['rive_artboard'] as String?,
    );

Map<String, dynamic> _$BaristaBadgeItemToJson(_BaristaBadgeItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'rarity': instance.rarity,
      'rive_artboard': instance.riveArtboard,
    };

_RecentBrewSnapshot _$RecentBrewSnapshotFromJson(Map<String, dynamic> json) =>
    _RecentBrewSnapshot(
      recipeId: json['recipe_id'] as String?,
      recipeTitle: json['recipe_title'] as String,
      beanName: json['bean_name'] as String,
      roastery: json['roastery'] as String,
      process: json['process'] as String,
      method: json['method'] as String,
      primaryTempC: (json['primary_temp_c'] as num?)?.toInt(),
      secondaryTempC: (json['secondary_temp_c'] as num?)?.toInt(),
      coffeeDoseG: (json['coffee_dose_g'] as num?)?.toDouble(),
      totalWaterMl: (json['total_water_ml'] as num?)?.toDouble(),
      targetDurationSec: (json['target_duration_sec'] as num?)?.toInt(),
      brewedAt: DateTime.parse(json['brewed_at'] as String),
      isLive: json['is_live'] as bool? ?? false,
      accuracyScore: (json['accuracy_score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RecentBrewSnapshotToJson(_RecentBrewSnapshot instance) =>
    <String, dynamic>{
      'recipe_id': instance.recipeId,
      'recipe_title': instance.recipeTitle,
      'bean_name': instance.beanName,
      'roastery': instance.roastery,
      'process': instance.process,
      'method': instance.method,
      'primary_temp_c': instance.primaryTempC,
      'secondary_temp_c': instance.secondaryTempC,
      'coffee_dose_g': instance.coffeeDoseG,
      'total_water_ml': instance.totalWaterMl,
      'target_duration_sec': instance.targetDurationSec,
      'brewed_at': instance.brewedAt.toIso8601String(),
      'is_live': instance.isLive,
      'accuracy_score': instance.accuracyScore,
    };

_MaterializedProfileView _$MaterializedProfileViewFromJson(
  Map<String, dynamic> json,
) => _MaterializedProfileView(
  userId: json['user_id'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String,
  bio: json['bio'] as String? ?? '',
  avatarUrl: json['avatar_url'] as String?,
  bannerUrl: json['banner_url'] as String?,
  accountTier: json['account_tier'] as String? ?? 'Trial',
  totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
  baristaLevel: (json['barista_level'] as num?)?.toInt() ?? 1,
  baristaRankTitle: json['barista_rank_title'] as String? ?? 'Home Brewer',
  levelProgressRatio: (json['level_progress_ratio'] as num?)?.toDouble() ?? 0.0,
  nextLevelXp: (json['next_level_xp'] as num?)?.toInt() ?? 313,
  currentStreakDays: (json['current_streak_days'] as num?)?.toInt() ?? 0,
  unlockedBadgeIds:
      (json['unlocked_badge_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  topFeaturedBadges:
      (json['top_featured_badges'] as List<dynamic>?)
          ?.map((e) => BaristaBadgeItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
  totalThreadsCount: (json['total_threads_count'] as num?)?.toInt() ?? 0,
  totalBrewsCount: (json['total_brews_count'] as num?)?.toInt() ?? 0,
  totalRecipesCreatedCount:
      (json['total_recipes_created_count'] as num?)?.toInt() ?? 0,
  totalRecipeTriesReceived:
      (json['total_recipe_tries_received'] as num?)?.toInt() ?? 0,
  recentBrewSnapshot: json['recent_brew_snapshot'] == null
      ? null
      : RecentBrewSnapshot.fromJson(
          json['recent_brew_snapshot'] as Map<String, dynamic>,
        ),
  isFollowedByViewer: json['is_followed_by_viewer'] as bool? ?? false,
  isFollowingViewer: json['is_following_viewer'] as bool? ?? false,
  isOwnProfile: json['is_own_profile'] as bool? ?? false,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MaterializedProfileViewToJson(
  _MaterializedProfileView instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'display_name': instance.displayName,
  'bio': instance.bio,
  'avatar_url': instance.avatarUrl,
  'banner_url': instance.bannerUrl,
  'account_tier': instance.accountTier,
  'total_xp': instance.totalXp,
  'barista_level': instance.baristaLevel,
  'barista_rank_title': instance.baristaRankTitle,
  'level_progress_ratio': instance.levelProgressRatio,
  'next_level_xp': instance.nextLevelXp,
  'current_streak_days': instance.currentStreakDays,
  'unlocked_badge_ids': instance.unlockedBadgeIds,
  'top_featured_badges': instance.topFeaturedBadges,
  'followers_count': instance.followersCount,
  'following_count': instance.followingCount,
  'total_threads_count': instance.totalThreadsCount,
  'total_brews_count': instance.totalBrewsCount,
  'total_recipes_created_count': instance.totalRecipesCreatedCount,
  'total_recipe_tries_received': instance.totalRecipeTriesReceived,
  'recent_brew_snapshot': instance.recentBrewSnapshot,
  'is_followed_by_viewer': instance.isFollowedByViewer,
  'is_following_viewer': instance.isFollowingViewer,
  'is_own_profile': instance.isOwnProfile,
  'updated_at': instance.updatedAt?.toIso8601String(),
};

_ProfileDirectoryEntry _$ProfileDirectoryEntryFromJson(
  Map<String, dynamic> json,
) => _ProfileDirectoryEntry(
  userId: json['user_id'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String,
  bio: json['bio'] as String? ?? '',
  avatarUrl: json['avatar_url'] as String?,
  accountTier: json['account_tier'] as String? ?? 'Trial',
  totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
  baristaLevel: (json['barista_level'] as num?)?.toInt() ?? 1,
  baristaRankTitle: json['barista_rank_title'] as String? ?? 'Home Brewer',
  followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
  totalThreadsCount: (json['total_threads_count'] as num?)?.toInt() ?? 0,
  recentBrewSnapshot: json['recent_brew_snapshot'] == null
      ? null
      : RecentBrewSnapshot.fromJson(
          json['recent_brew_snapshot'] as Map<String, dynamic>,
        ),
  isFollowedByViewer: json['is_followed_by_viewer'] as bool? ?? false,
);

Map<String, dynamic> _$ProfileDirectoryEntryToJson(
  _ProfileDirectoryEntry instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'display_name': instance.displayName,
  'bio': instance.bio,
  'avatar_url': instance.avatarUrl,
  'account_tier': instance.accountTier,
  'total_xp': instance.totalXp,
  'barista_level': instance.baristaLevel,
  'barista_rank_title': instance.baristaRankTitle,
  'followers_count': instance.followersCount,
  'total_threads_count': instance.totalThreadsCount,
  'recent_brew_snapshot': instance.recentBrewSnapshot,
  'is_followed_by_viewer': instance.isFollowedByViewer,
};

_FollowToggleResult _$FollowToggleResultFromJson(Map<String, dynamic> json) =>
    _FollowToggleResult(
      targetUserId: json['target_user_id'] as String,
      isFollowedByViewer: json['is_followed_by_viewer'] as bool,
      followersCount: (json['followers_count'] as num).toInt(),
    );

Map<String, dynamic> _$FollowToggleResultToJson(_FollowToggleResult instance) =>
    <String, dynamic>{
      'target_user_id': instance.targetUserId,
      'is_followed_by_viewer': instance.isFollowedByViewer,
      'followers_count': instance.followersCount,
    };
