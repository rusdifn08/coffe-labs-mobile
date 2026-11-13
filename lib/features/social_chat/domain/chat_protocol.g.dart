// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_protocol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

V60RecipeCardAttachment _$V60RecipeCardAttachmentFromJson(
  Map<String, dynamic> json,
) => V60RecipeCardAttachment(
  recipeId: json['recipe_id'] as String,
  title: json['title'] as String,
  brewerName: json['brewer_name'] as String,
  doseGrams: (json['dose_grams'] as num).toDouble(),
  waterMl: (json['water_ml'] as num).toDouble(),
  tempC: (json['temp_c'] as num).toInt(),
  targetDurationSec: (json['target_duration_sec'] as num).toInt(),
  stepsPreview:
      (json['steps_preview'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$V60RecipeCardAttachmentToJson(
  V60RecipeCardAttachment instance,
) => <String, dynamic>{
  'recipe_id': instance.recipeId,
  'title': instance.title,
  'brewer_name': instance.brewerName,
  'dose_grams': instance.doseGrams,
  'water_ml': instance.waterMl,
  'temp_c': instance.tempC,
  'target_duration_sec': instance.targetDurationSec,
  'steps_preview': instance.stepsPreview,
  'kind': instance.$type,
};

CoffeeBeanCardAttachment _$CoffeeBeanCardAttachmentFromJson(
  Map<String, dynamic> json,
) => CoffeeBeanCardAttachment(
  beanId: json['bean_id'] as String?,
  roastery: json['roastery'] as String,
  beanName: json['bean_name'] as String,
  origin: json['origin'] as String,
  process: json['process'] as String,
  tastingNotes:
      (json['tasting_notes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  imageUrl: json['image_url'] as String?,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$CoffeeBeanCardAttachmentToJson(
  CoffeeBeanCardAttachment instance,
) => <String, dynamic>{
  'bean_id': instance.beanId,
  'roastery': instance.roastery,
  'bean_name': instance.beanName,
  'origin': instance.origin,
  'process': instance.process,
  'tasting_notes': instance.tastingNotes,
  'image_url': instance.imageUrl,
  'kind': instance.$type,
};

BrewImageMediaAttachment _$BrewImageMediaAttachmentFromJson(
  Map<String, dynamic> json,
) => BrewImageMediaAttachment(
  imageUrl: json['image_url'] as String,
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  blurhash: json['blurhash'] as String?,
  caption: json['caption'] as String?,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$BrewImageMediaAttachmentToJson(
  BrewImageMediaAttachment instance,
) => <String, dynamic>{
  'image_url': instance.imageUrl,
  'width': instance.width,
  'height': instance.height,
  'blurhash': instance.blurhash,
  'caption': instance.caption,
  'kind': instance.$type,
};

BrewSessionResultAttachment _$BrewSessionResultAttachmentFromJson(
  Map<String, dynamic> json,
) => BrewSessionResultAttachment(
  title: json['title'] as String,
  method: json['method'] as String,
  accuracyScore: (json['accuracy_score'] as num).toInt(),
  xpEarned: (json['xp_earned'] as num).toInt(),
  brewDurationSec: (json['brew_duration_sec'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$BrewSessionResultAttachmentToJson(
  BrewSessionResultAttachment instance,
) => <String, dynamic>{
  'title': instance.title,
  'method': instance.method,
  'accuracy_score': instance.accuracyScore,
  'xp_earned': instance.xpEarned,
  'brew_duration_sec': instance.brewDurationSec,
  'notes': instance.notes,
  'kind': instance.$type,
};

_ConversationCursorDto _$ConversationCursorDtoFromJson(
  Map<String, dynamic> json,
) => _ConversationCursorDto(
  conversationId: json['conversation_id'] as String,
  localMaxSeqId: (json['local_max_seq_id'] as num).toInt(),
);

Map<String, dynamic> _$ConversationCursorDtoToJson(
  _ConversationCursorDto instance,
) => <String, dynamic>{
  'conversation_id': instance.conversationId,
  'local_max_seq_id': instance.localMaxSeqId,
};

_ChatMessageDto _$ChatMessageDtoFromJson(Map<String, dynamic> json) =>
    _ChatMessageDto(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      seqId: (json['seq_id'] as num).toInt(),
      senderId: json['sender_id'] as String,
      clientMsgId: json['client_msg_id'] as String,
      replyToMsgId: json['reply_to_msg_id'] as String?,
      messageType: $enumDecode(_$ChatMessageTypeEnumMap, json['message_type']),
      bodyText: json['body_text'] as String?,
      attachment: json['attachment'] == null
          ? null
          : InteractiveAttachment.fromJson(
              json['attachment'] as Map<String, dynamic>,
            ),
      isEdited: json['is_edited'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ChatMessageDtoToJson(_ChatMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'seq_id': instance.seqId,
      'sender_id': instance.senderId,
      'client_msg_id': instance.clientMsgId,
      'reply_to_msg_id': instance.replyToMsgId,
      'message_type': _$ChatMessageTypeEnumMap[instance.messageType]!,
      'body_text': instance.bodyText,
      'attachment': instance.attachment,
      'is_edited': instance.isEdited,
      'is_deleted': instance.isDeleted,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$ChatMessageTypeEnumMap = {
  ChatMessageType.text: 'TEXT',
  ChatMessageType.image: 'IMAGE',
  ChatMessageType.recipeCard: 'RECIPE_CARD',
  ChatMessageType.beanCard: 'BEAN_CARD',
  ChatMessageType.brewLog: 'BREW_LOG',
};

_ParticipantWatermarkDto _$ParticipantWatermarkDtoFromJson(
  Map<String, dynamic> json,
) => _ParticipantWatermarkDto(
  conversationId: json['conversation_id'] as String,
  userId: json['user_id'] as String,
  lastDeliveredSeqId: (json['last_delivered_seq_id'] as num).toInt(),
  lastReadSeqId: (json['last_read_seq_id'] as num).toInt(),
);

Map<String, dynamic> _$ParticipantWatermarkDtoToJson(
  _ParticipantWatermarkDto instance,
) => <String, dynamic>{
  'conversation_id': instance.conversationId,
  'user_id': instance.userId,
  'last_delivered_seq_id': instance.lastDeliveredSeqId,
  'last_read_seq_id': instance.lastReadSeqId,
};

_ChatConversationDto _$ChatConversationDtoFromJson(Map<String, dynamic> json) =>
    _ChatConversationDto(
      id: json['id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      avatarUrl: json['avatar_url'] as String?,
      lastSeqId: (json['last_seq_id'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      myReadSeqId: (json['my_read_seq_id'] as num?)?.toInt() ?? 0,
      myDeliveredSeqId: (json['my_delivered_seq_id'] as num?)?.toInt() ?? 0,
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      peerUserId: json['peer_user_id'] as String?,
      peerUsername: json['peer_username'] as String?,
      peerOnline: json['peer_online'] as bool? ?? false,
      peerLastSeenAt: json['peer_last_seen_at'] == null
          ? null
          : DateTime.parse(json['peer_last_seen_at'] as String),
      peerDeliveredSeqId: (json['peer_delivered_seq_id'] as num?)?.toInt() ?? 0,
      peerReadSeqId: (json['peer_read_seq_id'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ChatConversationDtoToJson(
  _ChatConversationDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'kind': instance.kind,
  'title': instance.title,
  'avatar_url': instance.avatarUrl,
  'last_seq_id': instance.lastSeqId,
  'unread_count': instance.unreadCount,
  'my_read_seq_id': instance.myReadSeqId,
  'my_delivered_seq_id': instance.myDeliveredSeqId,
  'last_message_preview': instance.lastMessagePreview,
  'last_message_at': instance.lastMessageAt?.toIso8601String(),
  'peer_user_id': instance.peerUserId,
  'peer_username': instance.peerUsername,
  'peer_online': instance.peerOnline,
  'peer_last_seen_at': instance.peerLastSeenAt?.toIso8601String(),
  'peer_delivered_seq_id': instance.peerDeliveredSeqId,
  'peer_read_seq_id': instance.peerReadSeqId,
};

_ChatPeerDto _$ChatPeerDtoFromJson(Map<String, dynamic> json) => _ChatPeerDto(
  id: json['id'] as String,
  username: json['username'] as String,
  fullName: json['full_name'] as String,
  avatarUrl: json['avatar_url'] as String?,
  role: json['role'] as String,
  isOnline: json['is_online'] as bool? ?? false,
  lastSeenAt: json['last_seen_at'] == null
      ? null
      : DateTime.parse(json['last_seen_at'] as String),
);

Map<String, dynamic> _$ChatPeerDtoToJson(_ChatPeerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'full_name': instance.fullName,
      'avatar_url': instance.avatarUrl,
      'role': instance.role,
      'is_online': instance.isOnline,
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
    };
