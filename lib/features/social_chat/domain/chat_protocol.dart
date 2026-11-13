import 'package:freezed_annotation/freezed_annotation.dart';

import '../../notifications/domain/models/notification_models.dart';

part 'chat_protocol.freezed.dart';
part 'chat_protocol.g.dart';

enum ChatMessageType {
  @JsonValue('TEXT')
  text,
  @JsonValue('IMAGE')
  image,
  @JsonValue('RECIPE_CARD')
  recipeCard,
  @JsonValue('BEAN_CARD')
  beanCard,
  @JsonValue('BREW_LOG')
  brewLog;

  String get wireValue {
    switch (this) {
      case ChatMessageType.text:
        return 'TEXT';
      case ChatMessageType.image:
        return 'IMAGE';
      case ChatMessageType.recipeCard:
        return 'RECIPE_CARD';
      case ChatMessageType.beanCard:
        return 'BEAN_CARD';
      case ChatMessageType.brewLog:
        return 'BREW_LOG';
    }
  }

  static ChatMessageType fromWire(String raw) {
    switch (raw.toUpperCase()) {
      case 'IMAGE':
        return ChatMessageType.image;
      case 'RECIPE_CARD':
        return ChatMessageType.recipeCard;
      case 'BEAN_CARD':
        return ChatMessageType.beanCard;
      case 'BREW_LOG':
        return ChatMessageType.brewLog;
      default:
        return ChatMessageType.text;
    }
  }
}

enum DeliveryStatus {
  sending,
  sent,
  delivered,
  read,
  failed;

  static DeliveryStatus fromStorage(String raw) {
    return DeliveryStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => DeliveryStatus.sent,
    );
  }
}

enum ReceiptStatus {
  @JsonValue('SENT')
  sent,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('READ')
  read,
}

@Freezed(unionKey: 'kind', unionValueCase: FreezedUnionCase.snake)
sealed class InteractiveAttachment with _$InteractiveAttachment {
  @FreezedUnionValue('v60_recipe_card')
  const factory InteractiveAttachment.v60RecipeCard({
    @JsonKey(name: 'recipe_id') required String recipeId,
    required String title,
    @JsonKey(name: 'brewer_name') required String brewerName,
    @JsonKey(name: 'dose_grams') required double doseGrams,
    @JsonKey(name: 'water_ml') required double waterMl,
    @JsonKey(name: 'temp_c') required int tempC,
    @JsonKey(name: 'target_duration_sec') required int targetDurationSec,
    @JsonKey(name: 'steps_preview') @Default(<String>[]) List<String> stepsPreview,
  }) = V60RecipeCardAttachment;

  @FreezedUnionValue('coffee_bean_card')
  const factory InteractiveAttachment.coffeeBeanCard({
    @JsonKey(name: 'bean_id') String? beanId,
    required String roastery,
    @JsonKey(name: 'bean_name') required String beanName,
    required String origin,
    required String process,
    @JsonKey(name: 'tasting_notes') @Default(<String>[]) List<String> tastingNotes,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = CoffeeBeanCardAttachment;

  @FreezedUnionValue('brew_image_media')
  const factory InteractiveAttachment.brewImageMedia({
    @JsonKey(name: 'image_url') required String imageUrl,
    required int width,
    required int height,
    String? blurhash,
    String? caption,
  }) = BrewImageMediaAttachment;

  @FreezedUnionValue('brew_session_result')
  const factory InteractiveAttachment.brewSessionResult({
    required String title,
    required String method,
    @JsonKey(name: 'accuracy_score') required int accuracyScore,
    @JsonKey(name: 'xp_earned') required int xpEarned,
    @JsonKey(name: 'brew_duration_sec') int? brewDurationSec,
    String? notes,
  }) = BrewSessionResultAttachment;

  factory InteractiveAttachment.fromJson(Map<String, dynamic> json) =>
      _$InteractiveAttachmentFromJson(json);
}

@freezed
abstract class ConversationCursorDto with _$ConversationCursorDto {
  const factory ConversationCursorDto({
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'local_max_seq_id') required int localMaxSeqId,
  }) = _ConversationCursorDto;

  factory ConversationCursorDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationCursorDtoFromJson(json);
}

@freezed
abstract class ChatMessageDto with _$ChatMessageDto {
  const factory ChatMessageDto({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'seq_id') required int seqId,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'client_msg_id') required String clientMsgId,
    @JsonKey(name: 'reply_to_msg_id') String? replyToMsgId,
    @JsonKey(name: 'message_type') required ChatMessageType messageType,
    @JsonKey(name: 'body_text') String? bodyText,
    InteractiveAttachment? attachment,
    @JsonKey(name: 'is_edited') @Default(false) bool isEdited,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ChatMessageDto;

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDtoFromJson(json);
}

@freezed
abstract class ParticipantWatermarkDto with _$ParticipantWatermarkDto {
  const factory ParticipantWatermarkDto({
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'last_delivered_seq_id') required int lastDeliveredSeqId,
    @JsonKey(name: 'last_read_seq_id') required int lastReadSeqId,
  }) = _ParticipantWatermarkDto;

  factory ParticipantWatermarkDto.fromJson(Map<String, dynamic> json) =>
      _$ParticipantWatermarkDtoFromJson(json);
}

@freezed
abstract class ChatConversationDto with _$ChatConversationDto {
  const factory ChatConversationDto({
    required String id,
    required String kind,
    required String title,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'last_seq_id') @Default(0) int lastSeqId,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'my_read_seq_id') @Default(0) int myReadSeqId,
    @JsonKey(name: 'my_delivered_seq_id') @Default(0) int myDeliveredSeqId,
    @JsonKey(name: 'last_message_preview') String? lastMessagePreview,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'peer_user_id') String? peerUserId,
    @JsonKey(name: 'peer_username') String? peerUsername,
    @JsonKey(name: 'peer_online') @Default(false) bool peerOnline,
    @JsonKey(name: 'peer_last_seen_at') DateTime? peerLastSeenAt,
    @JsonKey(name: 'peer_delivered_seq_id') @Default(0) int peerDeliveredSeqId,
    @JsonKey(name: 'peer_read_seq_id') @Default(0) int peerReadSeqId,
  }) = _ChatConversationDto;

  factory ChatConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationDtoFromJson(json);
}

@freezed
abstract class ChatPeerDto with _$ChatPeerDto {
  const factory ChatPeerDto({
    required String id,
    required String username,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    required String role,
    @JsonKey(name: 'is_online') @Default(false) bool isOnline,
    @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
  }) = _ChatPeerDto;

  factory ChatPeerDto.fromJson(Map<String, dynamic> json) =>
      _$ChatPeerDtoFromJson(json);
}

@freezed
sealed class ClientFrame with _$ClientFrame {
  const ClientFrame._();

  const factory ClientFrame.sendMessage({
    required String clientMsgId,
    required String conversationId,
    String? replyToMsgId,
    required ChatMessageType messageType,
    String? bodyText,
    InteractiveAttachment? attachment,
  }) = ClientSendMessageFrame;

  const factory ClientFrame.ackDelivered({
    required String conversationId,
    required int upToSeqId,
  }) = ClientAckDeliveredFrame;

  const factory ClientFrame.ackRead({
    required String conversationId,
    required int upToSeqId,
  }) = ClientAckReadFrame;

  const factory ClientFrame.typing({
    required String conversationId,
    required bool isTyping,
  }) = ClientTypingFrame;

  const factory ClientFrame.syncDelta({
    required List<ConversationCursorDto> cursors,
  }) = ClientSyncDeltaFrame;

  const factory ClientFrame.ping({
    required int timestampMs,
  }) = ClientPingFrame;

  const factory ClientFrame.setActiveRoom({
    String? conversationId,
  }) = ClientSetActiveRoomFrame;

  /// Encodes to exact Rust `#[serde(tag = "type", content = "payload")]` JSON contract.
  Map<String, dynamic> toWireJson() {
    return switch (this) {
      ClientSendMessageFrame f => {
        'type': 'send_message',
        'payload': {
          'client_msg_id': f.clientMsgId,
          'conversation_id': f.conversationId,
          'reply_to_msg_id': f.replyToMsgId,
          'message_type': f.messageType.wireValue,
          'body_text': f.bodyText,
          'attachment': f.attachment?.toJson(),
        },
      },
      ClientAckDeliveredFrame f => {
        'type': 'ack_delivered',
        'payload': {
          'conversation_id': f.conversationId,
          'up_to_seq_id': f.upToSeqId,
        },
      },
      ClientAckReadFrame f => {
        'type': 'ack_read',
        'payload': {
          'conversation_id': f.conversationId,
          'up_to_seq_id': f.upToSeqId,
        },
      },
      ClientTypingFrame f => {
        'type': 'typing',
        'payload': {
          'conversation_id': f.conversationId,
          'is_typing': f.isTyping,
        },
      },
      ClientSyncDeltaFrame f => {
        'type': 'sync_delta',
        'payload': {
          'cursors': f.cursors.map((c) => c.toJson()).toList(),
        },
      },
      ClientPingFrame f => {
        'type': 'ping',
        'payload': {'timestamp_ms': f.timestampMs},
      },
      ClientSetActiveRoomFrame f => {
        'type': 'set_active_room',
        'payload': {'conversation_id': f.conversationId},
      },
    };
  }
}

@freezed
sealed class ServerFrame with _$ServerFrame {
  const ServerFrame._();

  const factory ServerFrame.messageSentAck({
    required String clientMsgId,
    required String serverMsgId,
    required String conversationId,
    required int seqId,
    required DateTime createdAt,
  }) = ServerMessageSentAckFrame;

  const factory ServerFrame.newMessage(ChatMessageDto message) =
      ServerNewMessageFrame;

  const factory ServerFrame.receiptWatermarkUpdate({
    required String conversationId,
    required String userId,
    required ReceiptStatus status,
    required int upToSeqId,
    required DateTime updatedAt,
  }) = ServerReceiptWatermarkUpdateFrame;

  const factory ServerFrame.typingIndicator({
    required String conversationId,
    required String userId,
    required String displayName,
    required bool isTyping,
  }) = ServerTypingIndicatorFrame;

  const factory ServerFrame.presenceUpdate({
    required String userId,
    required bool isOnline,
    DateTime? lastSeenAt,
  }) = ServerPresenceUpdateFrame;

  const factory ServerFrame.deltaSyncBatch({
    required List<ChatMessageDto> messages,
    required List<ParticipantWatermarkDto> watermarks,
  }) = ServerDeltaSyncBatchFrame;

  const factory ServerFrame.frameError({
    String? clientMsgId,
    required String code,
    required String message,
  }) = ServerFrameErrorFrame;

  const factory ServerFrame.pong({
    required int timestampMs,
  }) = ServerPongFrame;

  const factory ServerFrame.socialGraphEvent({
    required String actorId,
    required String actorUsername,
    required String actorDisplayName,
    String? actorAvatarUrl,
    required String state,
    required String action,
    required String message,
    required DateTime createdAt,
  }) = ServerSocialGraphEventFrame;

  const factory ServerFrame.pushNotificationEvent({
    required String notificationId,
    required String category,
    required String eventType,
    required String title,
    required String body,
    required String deepLinkPath,
    String? collapseKey,
    String? entityId,
    String? actorId,
    String? conversationId,
    @Default(<String>[]) List<String> actionButtons,
    required int unreadCount,
    required DateTime createdAt,
  }) = ServerPushNotificationEventFrame;

  static ServerFrame? tryFromWireJson(Map<String, dynamic> raw) {
    final type = raw['type']?.toString();
    final payload = raw['payload'];
    if (type == null || payload is! Map<String, dynamic>) return null;

    switch (type) {
      case 'message_sent_ack':
        return ServerFrame.messageSentAck(
          clientMsgId: payload['client_msg_id'].toString(),
          serverMsgId: payload['server_msg_id'].toString(),
          conversationId: payload['conversation_id'].toString(),
          seqId: (payload['seq_id'] as num).toInt(),
          createdAt: DateTime.parse(payload['created_at'].toString()),
        );
      case 'new_message':
        return ServerFrame.newMessage(ChatMessageDto.fromJson(payload));
      case 'receipt_watermark_update':
        final rawStatus = payload['status']?.toString().toUpperCase();
        final status = rawStatus == 'READ'
            ? ReceiptStatus.read
            : (rawStatus == 'DELIVERED'
                ? ReceiptStatus.delivered
                : ReceiptStatus.sent);
        return ServerFrame.receiptWatermarkUpdate(
          conversationId: payload['conversation_id'].toString(),
          userId: payload['user_id'].toString(),
          status: status,
          upToSeqId: (payload['up_to_seq_id'] as num).toInt(),
          updatedAt: DateTime.parse(payload['updated_at'].toString()),
        );
      case 'typing_indicator':
        return ServerFrame.typingIndicator(
          conversationId: payload['conversation_id'].toString(),
          userId: payload['user_id'].toString(),
          displayName: payload['display_name']?.toString() ?? 'Barista',
          isTyping: payload['is_typing'] == true,
        );
      case 'presence_update':
        final rawLastSeen = payload['last_seen_at']?.toString();
        return ServerFrame.presenceUpdate(
          userId: payload['user_id'].toString(),
          isOnline: payload['is_online'] == true,
          lastSeenAt: rawLastSeen != null ? DateTime.tryParse(rawLastSeen) : null,
        );
      case 'delta_sync_batch':
        final rawMsgs = payload['messages'] as List<dynamic>? ?? const [];
        final rawWms = payload['watermarks'] as List<dynamic>? ?? const [];
        return ServerFrame.deltaSyncBatch(
          messages: rawMsgs
              .whereType<Map<String, dynamic>>()
              .map(ChatMessageDto.fromJson)
              .toList(),
          watermarks: rawWms
              .whereType<Map<String, dynamic>>()
              .map(ParticipantWatermarkDto.fromJson)
              .toList(),
        );
      case 'frame_error':
        return ServerFrame.frameError(
          clientMsgId: payload['client_msg_id']?.toString(),
          code: payload['code']?.toString() ?? 'ERROR',
          message: payload['message']?.toString() ?? 'Kesalahan komunikasi chat',
        );
      case 'pong':
        return ServerFrame.pong(
          timestampMs: (payload['timestamp_ms'] as num?)?.toInt() ?? 0,
        );
      case 'social_graph_event':
        return ServerFrame.socialGraphEvent(
          actorId: payload['actor_id']?.toString() ?? '',
          actorUsername: payload['actor_username']?.toString() ?? '',
          actorDisplayName:
              payload['actor_display_name']?.toString() ?? 'Barista',
          actorAvatarUrl: payload['actor_avatar_url'] as String?,
          state: payload['state']?.toString() ?? 'none',
          action: payload['action']?.toString() ?? 'follow',
          message: payload['message']?.toString() ?? '',
          createdAt:
              DateTime.tryParse(payload['created_at']?.toString() ?? '') ??
              DateTime.now().toUtc(),
        );
      case 'push_notification_event':
        final rawActions = payload['action_buttons'] as List<dynamic>? ?? const [];
        return ServerFrame.pushNotificationEvent(
          notificationId: payload['notification_id']?.toString() ?? '',
          category: payload['category']?.toString() ?? 'SOCIAL_GRAPH',
          eventType: payload['event_type']?.toString() ?? 'GENERIC',
          title: payload['title']?.toString() ?? 'Coffee Labs',
          body: payload['body']?.toString() ?? '',
          deepLinkPath:
              payload['deep_link_path']?.toString() ?? '/notifications',
          collapseKey: payload['collapse_key']?.toString(),
          entityId: payload['entity_id']?.toString(),
          actorId: payload['actor_id']?.toString(),
          conversationId: payload['conversation_id']?.toString(),
          actionButtons: rawActions.map((e) => e.toString()).toList(),
          unreadCount: (payload['unread_count'] as num?)?.toInt() ?? 0,
          createdAt:
              DateTime.tryParse(payload['created_at']?.toString() ?? '') ??
              DateTime.now().toUtc(),
        );
      default:
        return null;
    }
  }
}

extension ServerPushNotificationEventPayloadExt
    on ServerPushNotificationEventFrame {
  PushDeepLinkPayload toDeepLinkPayload() => PushDeepLinkPayload(
    eventType: eventType,
    deepLinkPath: deepLinkPath,
    entityId: entityId,
    actorId: actorId,
    conversationId: conversationId,
    notificationId: notificationId.isEmpty ? null : notificationId,
    collapseKey: collapseKey,
    category: category,
    title: title,
    body: body,
    actionButtons: actionButtons,
  );
}
