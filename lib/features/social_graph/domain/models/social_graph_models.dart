import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_graph_models.freezed.dart';
part 'social_graph_models.g.dart';

enum RelationshipState {
  @JsonValue('self_profile')
  selfProfile,
  @JsonValue('none')
  none,
  @JsonValue('followed_by_target')
  followedByTarget,
  @JsonValue('requested')
  requested,
  @JsonValue('following')
  following,
  @JsonValue('mutual')
  mutual,
}

extension RelationshipStateX on RelationshipState {
  bool get isOutgoingDesired =>
      this == RelationshipState.following ||
      this == RelationshipState.mutual ||
      this == RelationshipState.requested;

  String get ctaLabel {
    switch (this) {
      case RelationshipState.selfProfile:
        return 'Edit Profil';
      case RelationshipState.none:
        return 'Follow';
      case RelationshipState.followedByTarget:
        return 'Follback';
      case RelationshipState.requested:
        return 'Diminta';
      case RelationshipState.following:
        return 'Mengikuti';
      case RelationshipState.mutual:
        return 'Teman Mutual';
    }
  }

  RelationshipState nextOptimisticState({
    required bool isTargetPrivate,
    required bool isFollowedByTarget,
  }) {
    switch (this) {
      case RelationshipState.selfProfile:
        return RelationshipState.selfProfile;
      case RelationshipState.none:
        return isTargetPrivate
            ? RelationshipState.requested
            : RelationshipState.following;
      case RelationshipState.followedByTarget:
        return isTargetPrivate
            ? RelationshipState.requested
            : RelationshipState.mutual;
      case RelationshipState.requested:
      case RelationshipState.following:
      case RelationshipState.mutual:
        return isFollowedByTarget
            ? RelationshipState.followedByTarget
            : RelationshipState.none;
    }
  }

  static RelationshipState fromWire(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'self_profile':
        return RelationshipState.selfProfile;
      case 'followed_by_target':
        return RelationshipState.followedByTarget;
      case 'requested':
        return RelationshipState.requested;
      case 'following':
        return RelationshipState.following;
      case 'mutual':
        return RelationshipState.mutual;
      default:
        return RelationshipState.none;
    }
  }
}

@freezed
abstract class MiniUserAvatar with _$MiniUserAvatar {
  const factory MiniUserAvatar({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'barista_rank_title')
    @Default('Home Brewer')
    String baristaRankTitle,
  }) = _MiniUserAvatar;

  factory MiniUserAvatar.fromJson(Map<String, dynamic> json) =>
      _$MiniUserAvatarFromJson(json);
}

@freezed
abstract class RelationshipSnapshot with _$RelationshipSnapshot {
  const RelationshipSnapshot._();

  const factory RelationshipSnapshot({
    @JsonKey(name: 'target_user_id') required String targetUserId,
    @Default(RelationshipState.none) RelationshipState state,
    @JsonKey(name: 'is_mutual') @Default(false) bool isMutual,
    @JsonKey(name: 'is_followed_by_target')
    @Default(false)
    bool isFollowedByTarget,
    @JsonKey(name: 'has_pending_incoming_request')
    @Default(false)
    bool hasPendingIncomingRequest,
    @JsonKey(name: 'target_is_private') @Default(false) bool targetIsPrivate,
    @JsonKey(name: 'mutual_followers_count')
    @Default(0)
    int mutualFollowersCount,
    @JsonKey(name: 'mutual_avatars')
    @Default([])
    List<MiniUserAvatar> mutualAvatars,
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
  }) = _RelationshipSnapshot;

  factory RelationshipSnapshot.fromJson(Map<String, dynamic> json) =>
      _$RelationshipSnapshotFromJson(json);
}

@freezed
abstract class FollowMutationResult with _$FollowMutationResult {
  const factory FollowMutationResult({
    @JsonKey(name: 'target_user_id') required String targetUserId,
    required RelationshipState state,
    required String status,
    @JsonKey(name: 'is_idempotent_replay')
    @Default(false)
    bool isIdempotentReplay,
    @JsonKey(name: 'target_followers_count')
    @Default(0)
    int targetFollowersCount,
    @JsonKey(name: 'target_following_count')
    @Default(0)
    int targetFollowingCount,
    @JsonKey(name: 'actor_following_count')
    @Default(0)
    int actorFollowingCount,
    @JsonKey(name: 'mutual_followers_count')
    @Default(0)
    int mutualFollowersCount,
  }) = _FollowMutationResult;

  factory FollowMutationResult.fromJson(Map<String, dynamic> json) =>
      _$FollowMutationResultFromJson(json);
}

@freezed
abstract class BatchRelationshipItem with _$BatchRelationshipItem {
  const factory BatchRelationshipItem({
    @JsonKey(name: 'target_user_id') required String targetUserId,
    required RelationshipState state,
    @JsonKey(name: 'is_mutual') @Default(false) bool isMutual,
    @JsonKey(name: 'is_followed_by_target')
    @Default(false)
    bool isFollowedByTarget,
  }) = _BatchRelationshipItem;

  factory BatchRelationshipItem.fromJson(Map<String, dynamic> json) =>
      _$BatchRelationshipItemFromJson(json);
}

@freezed
abstract class SocialGraphUserItem with _$SocialGraphUserItem {
  const factory SocialGraphUserItem({
    @JsonKey(name: 'user_id') required String userId,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'barista_level') @Default(1) int baristaLevel,
    @JsonKey(name: 'barista_rank_title')
    @Default('Home Brewer')
    String baristaRankTitle,
    @JsonKey(name: 'account_tier') @Default('Trial') String accountTier,
    @JsonKey(name: 'is_private_account') @Default(false) bool isPrivateAccount,
    @JsonKey(name: 'relationship_state')
    @Default(RelationshipState.none)
    RelationshipState relationshipState,
    @JsonKey(name: 'followed_at') required DateTime followedAt,
  }) = _SocialGraphUserItem;

  factory SocialGraphUserItem.fromJson(Map<String, dynamic> json) =>
      _$SocialGraphUserItemFromJson(json);
}

@freezed
abstract class FollowRequestItem with _$FollowRequestItem {
  const factory FollowRequestItem({
    @JsonKey(name: 'requester_id') required String requesterId,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'barista_level') @Default(1) int baristaLevel,
    @JsonKey(name: 'barista_rank_title')
    @Default('Home Brewer')
    String baristaRankTitle,
    @JsonKey(name: 'account_tier') @Default('Trial') String accountTier,
    @JsonKey(name: 'requested_at') required DateTime requestedAt,
  }) = _FollowRequestItem;

  factory FollowRequestItem.fromJson(Map<String, dynamic> json) =>
      _$FollowRequestItemFromJson(json);
}

@freezed
abstract class PrivacySettingSnapshot with _$PrivacySettingSnapshot {
  const factory PrivacySettingSnapshot({
    @JsonKey(name: 'is_private_account') @Default(false) bool isPrivateAccount,
    @JsonKey(name: 'pending_follow_requests_count')
    @Default(0)
    int pendingFollowRequestsCount,
  }) = _PrivacySettingSnapshot;

  factory PrivacySettingSnapshot.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingSnapshotFromJson(json);
}

@freezed
abstract class PendingRequestActionResult with _$PendingRequestActionResult {
  const factory PendingRequestActionResult({
    @JsonKey(name: 'requester_id') required String requesterId,
    required String action,
    @Default(RelationshipState.none) RelationshipState state,
    @JsonKey(name: 'pending_follow_requests_count')
    @Default(0)
    int pendingFollowRequestsCount,
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
  }) = _PendingRequestActionResult;

  factory PendingRequestActionResult.fromJson(Map<String, dynamic> json) =>
      _$PendingRequestActionResultFromJson(json);
}

class SocialGraphCursorPage<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  const SocialGraphCursorPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}

class SocialGraphRealtimeEvent {
  final String actorId;
  final String actorUsername;
  final String actorDisplayName;
  final String? actorAvatarUrl;
  final RelationshipState state;
  final String action;
  final String message;
  final DateTime createdAt;

  const SocialGraphRealtimeEvent({
    required this.actorId,
    required this.actorUsername,
    required this.actorDisplayName,
    this.actorAvatarUrl,
    required this.state,
    required this.action,
    required this.message,
    required this.createdAt,
  });

  factory SocialGraphRealtimeEvent.fromPayload(Map<String, dynamic> map) {
    return SocialGraphRealtimeEvent(
      actorId: map['actor_id']?.toString() ?? '',
      actorUsername: map['actor_username']?.toString() ?? '',
      actorDisplayName: map['actor_display_name']?.toString() ?? 'Barista',
      actorAvatarUrl: map['actor_avatar_url'] as String?,
      state: RelationshipStateX.fromWire(map['state']?.toString() ?? 'none'),
      action: map['action']?.toString() ?? 'follow',
      message: map['message']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now().toUtc(),
    );
  }
}
