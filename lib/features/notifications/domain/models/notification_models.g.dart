// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationActorPreview _$NotificationActorPreviewFromJson(
  Map<String, dynamic> json,
) => _NotificationActorPreview(
  userId: json['user_id'] as String,
  username: json['username'] as String? ?? '',
  displayName: json['display_name'] as String? ?? '',
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$NotificationActorPreviewToJson(
  _NotificationActorPreview instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'display_name': instance.displayName,
  'avatar_url': instance.avatarUrl,
};

_NotificationInboxItem _$NotificationInboxItemFromJson(
  Map<String, dynamic> json,
) => _NotificationInboxItem(
  id: json['id'] as String,
  coalesceGroupKey: json['coalesce_group_key'] as String?,
  category: json['category'] as String? ?? 'SOCIAL_GRAPH',
  eventType: json['event_type'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  deepLinkPath: json['deep_link_path'] as String,
  actionPayload:
      json['action_payload'] as Map<String, dynamic>? ??
      const <String, dynamic>{},
  actorsPreview:
      (json['actors_preview'] as List<dynamic>?)
          ?.map(
            (e) => NotificationActorPreview.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <NotificationActorPreview>[],
  aggregatedCount: (json['aggregated_count'] as num?)?.toInt() ?? 1,
  isRead: json['is_read'] as bool? ?? false,
  readAt: json['read_at'] == null
      ? null
      : DateTime.parse(json['read_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$NotificationInboxItemToJson(
  _NotificationInboxItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'coalesce_group_key': instance.coalesceGroupKey,
  'category': instance.category,
  'event_type': instance.eventType,
  'title': instance.title,
  'body': instance.body,
  'deep_link_path': instance.deepLinkPath,
  'action_payload': instance.actionPayload,
  'actors_preview': instance.actorsPreview,
  'aggregated_count': instance.aggregatedCount,
  'is_read': instance.isRead,
  'read_at': instance.readAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

_NotificationInboxPage _$NotificationInboxPageFromJson(
  Map<String, dynamic> json,
) => _NotificationInboxPage(
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) => NotificationInboxItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <NotificationInboxItem>[],
  nextCursor: json['next_cursor'] as String?,
  hasMore: json['has_more'] as bool? ?? false,
  unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$NotificationInboxPageToJson(
  _NotificationInboxPage instance,
) => <String, dynamic>{
  'items': instance.items,
  'next_cursor': instance.nextCursor,
  'has_more': instance.hasMore,
  'unread_count': instance.unreadCount,
};

_NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferences(
  enableChatMessages: json['enable_chat_messages'] as bool? ?? true,
  enableFollowFollback: json['enable_follow_follback'] as bool? ?? true,
  enableThreadReplies: json['enable_thread_replies'] as bool? ?? true,
  enableLikesAndRecipeTries:
      json['enable_likes_and_recipe_tries'] as bool? ?? true,
  enableLiveBrewAndStreak: json['enable_live_brew_and_streak'] as bool? ?? true,
  enableTransactionalBilling:
      json['enable_transactional_billing'] as bool? ?? true,
  quietHoursStartMinute: (json['quiet_hours_start_minute'] as num?)?.toInt(),
  quietHoursEndMinute: (json['quiet_hours_end_minute'] as num?)?.toInt(),
  timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'enable_chat_messages': instance.enableChatMessages,
  'enable_follow_follback': instance.enableFollowFollback,
  'enable_thread_replies': instance.enableThreadReplies,
  'enable_likes_and_recipe_tries': instance.enableLikesAndRecipeTries,
  'enable_live_brew_and_streak': instance.enableLiveBrewAndStreak,
  'enable_transactional_billing': instance.enableTransactionalBilling,
  'quiet_hours_start_minute': instance.quietHoursStartMinute,
  'quiet_hours_end_minute': instance.quietHoursEndMinute,
  'timezone': instance.timezone,
};
