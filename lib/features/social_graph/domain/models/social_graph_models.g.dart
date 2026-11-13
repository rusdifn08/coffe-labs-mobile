// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_graph_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MiniUserAvatar _$MiniUserAvatarFromJson(Map<String, dynamic> json) =>
    _MiniUserAvatar(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      baristaRankTitle: json['barista_rank_title'] as String? ?? 'Home Brewer',
    );

Map<String, dynamic> _$MiniUserAvatarToJson(_MiniUserAvatar instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'barista_rank_title': instance.baristaRankTitle,
    };

_RelationshipSnapshot _$RelationshipSnapshotFromJson(
  Map<String, dynamic> json,
) => _RelationshipSnapshot(
  targetUserId: json['target_user_id'] as String,
  state:
      $enumDecodeNullable(_$RelationshipStateEnumMap, json['state']) ??
      RelationshipState.none,
  isMutual: json['is_mutual'] as bool? ?? false,
  isFollowedByTarget: json['is_followed_by_target'] as bool? ?? false,
  hasPendingIncomingRequest:
      json['has_pending_incoming_request'] as bool? ?? false,
  targetIsPrivate: json['target_is_private'] as bool? ?? false,
  mutualFollowersCount: (json['mutual_followers_count'] as num?)?.toInt() ?? 0,
  mutualAvatars:
      (json['mutual_avatars'] as List<dynamic>?)
          ?.map((e) => MiniUserAvatar.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RelationshipSnapshotToJson(
  _RelationshipSnapshot instance,
) => <String, dynamic>{
  'target_user_id': instance.targetUserId,
  'state': _$RelationshipStateEnumMap[instance.state]!,
  'is_mutual': instance.isMutual,
  'is_followed_by_target': instance.isFollowedByTarget,
  'has_pending_incoming_request': instance.hasPendingIncomingRequest,
  'target_is_private': instance.targetIsPrivate,
  'mutual_followers_count': instance.mutualFollowersCount,
  'mutual_avatars': instance.mutualAvatars,
  'followers_count': instance.followersCount,
  'following_count': instance.followingCount,
};

const _$RelationshipStateEnumMap = {
  RelationshipState.selfProfile: 'self_profile',
  RelationshipState.none: 'none',
  RelationshipState.followedByTarget: 'followed_by_target',
  RelationshipState.requested: 'requested',
  RelationshipState.following: 'following',
  RelationshipState.mutual: 'mutual',
};

_FollowMutationResult _$FollowMutationResultFromJson(
  Map<String, dynamic> json,
) => _FollowMutationResult(
  targetUserId: json['target_user_id'] as String,
  state: $enumDecode(_$RelationshipStateEnumMap, json['state']),
  status: json['status'] as String,
  isIdempotentReplay: json['is_idempotent_replay'] as bool? ?? false,
  targetFollowersCount: (json['target_followers_count'] as num?)?.toInt() ?? 0,
  targetFollowingCount: (json['target_following_count'] as num?)?.toInt() ?? 0,
  actorFollowingCount: (json['actor_following_count'] as num?)?.toInt() ?? 0,
  mutualFollowersCount: (json['mutual_followers_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$FollowMutationResultToJson(
  _FollowMutationResult instance,
) => <String, dynamic>{
  'target_user_id': instance.targetUserId,
  'state': _$RelationshipStateEnumMap[instance.state]!,
  'status': instance.status,
  'is_idempotent_replay': instance.isIdempotentReplay,
  'target_followers_count': instance.targetFollowersCount,
  'target_following_count': instance.targetFollowingCount,
  'actor_following_count': instance.actorFollowingCount,
  'mutual_followers_count': instance.mutualFollowersCount,
};

_BatchRelationshipItem _$BatchRelationshipItemFromJson(
  Map<String, dynamic> json,
) => _BatchRelationshipItem(
  targetUserId: json['target_user_id'] as String,
  state: $enumDecode(_$RelationshipStateEnumMap, json['state']),
  isMutual: json['is_mutual'] as bool? ?? false,
  isFollowedByTarget: json['is_followed_by_target'] as bool? ?? false,
);

Map<String, dynamic> _$BatchRelationshipItemToJson(
  _BatchRelationshipItem instance,
) => <String, dynamic>{
  'target_user_id': instance.targetUserId,
  'state': _$RelationshipStateEnumMap[instance.state]!,
  'is_mutual': instance.isMutual,
  'is_followed_by_target': instance.isFollowedByTarget,
};

_SocialGraphUserItem _$SocialGraphUserItemFromJson(Map<String, dynamic> json) =>
    _SocialGraphUserItem(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      baristaLevel: (json['barista_level'] as num?)?.toInt() ?? 1,
      baristaRankTitle: json['barista_rank_title'] as String? ?? 'Home Brewer',
      accountTier: json['account_tier'] as String? ?? 'Trial',
      isPrivateAccount: json['is_private_account'] as bool? ?? false,
      relationshipState:
          $enumDecodeNullable(
            _$RelationshipStateEnumMap,
            json['relationship_state'],
          ) ??
          RelationshipState.none,
      followedAt: DateTime.parse(json['followed_at'] as String),
    );

Map<String, dynamic> _$SocialGraphUserItemToJson(
  _SocialGraphUserItem instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'display_name': instance.displayName,
  'avatar_url': instance.avatarUrl,
  'barista_level': instance.baristaLevel,
  'barista_rank_title': instance.baristaRankTitle,
  'account_tier': instance.accountTier,
  'is_private_account': instance.isPrivateAccount,
  'relationship_state': _$RelationshipStateEnumMap[instance.relationshipState]!,
  'followed_at': instance.followedAt.toIso8601String(),
};

_FollowRequestItem _$FollowRequestItemFromJson(Map<String, dynamic> json) =>
    _FollowRequestItem(
      requesterId: json['requester_id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      baristaLevel: (json['barista_level'] as num?)?.toInt() ?? 1,
      baristaRankTitle: json['barista_rank_title'] as String? ?? 'Home Brewer',
      accountTier: json['account_tier'] as String? ?? 'Trial',
      requestedAt: DateTime.parse(json['requested_at'] as String),
    );

Map<String, dynamic> _$FollowRequestItemToJson(_FollowRequestItem instance) =>
    <String, dynamic>{
      'requester_id': instance.requesterId,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'barista_level': instance.baristaLevel,
      'barista_rank_title': instance.baristaRankTitle,
      'account_tier': instance.accountTier,
      'requested_at': instance.requestedAt.toIso8601String(),
    };

_PrivacySettingSnapshot _$PrivacySettingSnapshotFromJson(
  Map<String, dynamic> json,
) => _PrivacySettingSnapshot(
  isPrivateAccount: json['is_private_account'] as bool? ?? false,
  pendingFollowRequestsCount:
      (json['pending_follow_requests_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PrivacySettingSnapshotToJson(
  _PrivacySettingSnapshot instance,
) => <String, dynamic>{
  'is_private_account': instance.isPrivateAccount,
  'pending_follow_requests_count': instance.pendingFollowRequestsCount,
};

_PendingRequestActionResult _$PendingRequestActionResultFromJson(
  Map<String, dynamic> json,
) => _PendingRequestActionResult(
  requesterId: json['requester_id'] as String,
  action: json['action'] as String,
  state:
      $enumDecodeNullable(_$RelationshipStateEnumMap, json['state']) ??
      RelationshipState.none,
  pendingFollowRequestsCount:
      (json['pending_follow_requests_count'] as num?)?.toInt() ?? 0,
  followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PendingRequestActionResultToJson(
  _PendingRequestActionResult instance,
) => <String, dynamic>{
  'requester_id': instance.requesterId,
  'action': instance.action,
  'state': _$RelationshipStateEnumMap[instance.state]!,
  'pending_follow_requests_count': instance.pendingFollowRequestsCount,
  'followers_count': instance.followersCount,
};
