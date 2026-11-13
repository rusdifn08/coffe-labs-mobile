import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_models.freezed.dart';
part 'notification_models.g.dart';

enum OmnichannelNotificationCategory {
  @JsonValue('ALL')
  all,
  @JsonValue('CHAT')
  chat,
  @JsonValue('SOCIAL_GRAPH')
  socialGraph,
  @JsonValue('THREAD_ACTIVITY')
  threadActivity,
  @JsonValue('GAMIFICATION')
  gamification,
  @JsonValue('BILLING')
  billing;

  String get apiFilterValue {
    switch (this) {
      case OmnichannelNotificationCategory.all:
        return '';
      case OmnichannelNotificationCategory.chat:
        return 'CHAT';
      case OmnichannelNotificationCategory.socialGraph:
        return 'SOCIAL_GRAPH';
      case OmnichannelNotificationCategory.threadActivity:
        return 'THREAD_ACTIVITY';
      case OmnichannelNotificationCategory.gamification:
        return 'GAMIFICATION';
      case OmnichannelNotificationCategory.billing:
        return 'BILLING';
    }
  }

  String get tabLabel {
    switch (this) {
      case OmnichannelNotificationCategory.all:
        return 'Semua';
      case OmnichannelNotificationCategory.socialGraph:
        return 'Follback & Teman';
      case OmnichannelNotificationCategory.threadActivity:
        return 'Resep & Thread';
      case OmnichannelNotificationCategory.chat:
        return 'Obrolan';
      case OmnichannelNotificationCategory.gamification:
        return 'Seduh & Streak';
      case OmnichannelNotificationCategory.billing:
        return 'Transaksi';
    }
  }
}

@freezed
abstract class NotificationActorPreview with _$NotificationActorPreview {
  const factory NotificationActorPreview({
    @JsonKey(name: 'user_id') required String userId,
    @Default('') String username,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _NotificationActorPreview;

  factory NotificationActorPreview.fromJson(Map<String, dynamic> json) =>
      _$NotificationActorPreviewFromJson(json);
}

@freezed
abstract class NotificationInboxItem with _$NotificationInboxItem {
  const NotificationInboxItem._();

  const factory NotificationInboxItem({
    required String id,
    @JsonKey(name: 'coalesce_group_key') String? coalesceGroupKey,
    @Default('SOCIAL_GRAPH') String category,
    @JsonKey(name: 'event_type') required String eventType,
    required String title,
    required String body,
    @JsonKey(name: 'deep_link_path') required String deepLinkPath,
    @JsonKey(name: 'action_payload')
    @Default(<String, dynamic>{})
    Map<String, dynamic> actionPayload,
    @JsonKey(name: 'actors_preview')
    @Default(<NotificationActorPreview>[])
    List<NotificationActorPreview> actorsPreview,
    @JsonKey(name: 'aggregated_count') @Default(1) int aggregatedCount,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _NotificationInboxItem;

  factory NotificationInboxItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationInboxItemFromJson(json);

  String? get actorId => actionPayload['actor_id']?.toString();
  bool get hasQuickFollbackAction =>
      eventType == 'SOCIAL_NEW_FOLLOWER' &&
      (actionPayload['is_follback_opportunity'] == true ||
          ((actionPayload['action_buttons'] as List?)?.contains(
                'QUICK_FOLLBACK',
              ) ??
              false));
}

@freezed
abstract class NotificationInboxPage with _$NotificationInboxPage {
  const factory NotificationInboxPage({
    @Default(<NotificationInboxItem>[]) List<NotificationInboxItem> items,
    @JsonKey(name: 'next_cursor') String? nextCursor,
    @JsonKey(name: 'has_more') @Default(false) bool hasMore,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
  }) = _NotificationInboxPage;

  factory NotificationInboxPage.fromJson(Map<String, dynamic> json) =>
      _$NotificationInboxPageFromJson(json);
}

@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    @JsonKey(name: 'enable_chat_messages')
    @Default(true)
    bool enableChatMessages,
    @JsonKey(name: 'enable_follow_follback')
    @Default(true)
    bool enableFollowFollback,
    @JsonKey(name: 'enable_thread_replies')
    @Default(true)
    bool enableThreadReplies,
    @JsonKey(name: 'enable_likes_and_recipe_tries')
    @Default(true)
    bool enableLikesAndRecipeTries,
    @JsonKey(name: 'enable_live_brew_and_streak')
    @Default(true)
    bool enableLiveBrewAndStreak,
    @JsonKey(name: 'enable_transactional_billing')
    @Default(true)
    bool enableTransactionalBilling,
    @JsonKey(name: 'quiet_hours_start_minute') int? quietHoursStartMinute,
    @JsonKey(name: 'quiet_hours_end_minute') int? quietHoursEndMinute,
    @Default('Asia/Jakarta') String timezone,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}

class PushDeepLinkPayload {
  final String eventType;
  final String deepLinkPath;
  final String? entityId;
  final String? actorId;
  final String? conversationId;
  final String? notificationId;
  final String? collapseKey;
  final String category;
  final String title;
  final String body;
  final List<String> actionButtons;

  const PushDeepLinkPayload({
    required this.eventType,
    required this.deepLinkPath,
    this.entityId,
    this.actorId,
    this.conversationId,
    this.notificationId,
    this.collapseKey,
    this.category = 'SOCIAL_GRAPH',
    this.title = '',
    this.body = '',
    this.actionButtons = const <String>[],
  });

  String get normalizedGoRouterPath => normalizeDeepLinkPath(deepLinkPath);

  String toJsonString() => json.encode(<String, dynamic>{
        'event_type': eventType,
        'deep_link_path': deepLinkPath,
        if (entityId != null) 'entity_id': entityId,
        if (actorId != null) 'actor_id': actorId,
        if (conversationId != null) 'conversation_id': conversationId,
        if (notificationId != null) 'notification_id': notificationId,
        if (collapseKey != null) 'collapse_key': collapseKey,
        'category': category,
        'title': title,
        'body': body,
        'action_buttons_json': json.encode(actionButtons),
      });

  factory PushDeepLinkPayload.fromDataMap(Map<String, dynamic> data) {
    final rawButtons = data['action_buttons_json'] ?? data['action_buttons'];
    final buttons = <String>[];
    if (rawButtons is List) {
      buttons.addAll(rawButtons.map((e) => e.toString()));
    } else if (rawButtons is String && rawButtons.trim().startsWith('[')) {
      try {
        final decoded = json.decode(rawButtons) as List;
        buttons.addAll(decoded.map((e) => e.toString()));
      } catch (_) {}
    }

    return PushDeepLinkPayload(
      eventType: data['event_type']?.toString() ?? 'GENERIC',
      deepLinkPath: data['deep_link_path']?.toString() ?? '/notifications',
      entityId: data['entity_id']?.toString(),
      actorId: data['actor_id']?.toString(),
      conversationId: data['conversation_id']?.toString(),
      notificationId: data['notification_id']?.toString(),
      collapseKey: data['collapse_key']?.toString(),
      category: data['category']?.toString() ?? 'SOCIAL_GRAPH',
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      actionButtons: buttons,
    );
  }

  static PushDeepLinkPayload? tryParsePayload(String? rawPayload) {
    if (rawPayload == null || rawPayload.trim().isEmpty) return null;
    final trimmed = rawPayload.trim();
    if (trimmed.startsWith('/')) {
      return PushDeepLinkPayload(
        eventType: 'DEEP_LINK',
        deepLinkPath: trimmed,
      );
    }
    try {
      final decoded = json.decode(trimmed);
      if (decoded is Map<String, dynamic>) {
        return PushDeepLinkPayload.fromDataMap(decoded);
      }
      if (decoded is Map) {
        return PushDeepLinkPayload.fromDataMap(
          decoded.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
    } catch (_) {}
    return null;
  }

  /// Normalisasi rute blueprint (/social/chat/room/..., /social/threads/...) agar
  /// konsisten 100% dengan definisi GoRouter di Coffee Labs.
  static String normalizeDeepLinkPath(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty) return '/notifications';
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return trimmed.startsWith('/') ? trimmed : '/$trimmed';

    var path = uri.path;
    if (path.startsWith('/social/chat/room/')) {
      path = path.replaceFirst('/social/chat/room/', '/social/chat/');
    } else if (path.startsWith('/social/threads/')) {
      path = path.replaceFirst('/social/threads/', '/social/thread/');
    } else if (path.startsWith('/settings/subscription')) {
      path = '/settings';
    } else if (path.startsWith('/brew/timer')) {
      path = '/brew-timer';
    }

    if (uri.hasQuery) {
      return '$path?${uri.query}';
    }
    return path;
  }
}
