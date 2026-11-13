class ChatConversationView {
  final String id;
  final String kind;
  final String title;
  final String? avatarUrl;
  final int lastSeqId;
  final int localSyncedSeqId;
  final int unreadCount;
  final int myReadSeqId;
  final String? peerUserId;
  final String? peerUsername;
  final bool peerOnline;
  final DateTime? peerLastSeenAt;
  final int peerDeliveredSeqId;
  final int peerReadSeqId;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;

  const ChatConversationView({
    required this.id,
    required this.kind,
    required this.title,
    this.avatarUrl,
    required this.lastSeqId,
    required this.localSyncedSeqId,
    required this.unreadCount,
    required this.myReadSeqId,
    this.peerUserId,
    this.peerUsername,
    required this.peerOnline,
    this.peerLastSeenAt,
    required this.peerDeliveredSeqId,
    required this.peerReadSeqId,
    this.lastMessagePreview,
    this.lastMessageAt,
  });
}

class LocalChatMessageView {
  final String clientMsgId;
  final String? serverMsgId;
  final String conversationId;
  final int? seqId;
  final String senderId;
  final String? replyToMsgId;
  final String messageType;
  final String? bodyText;
  final String? attachmentJson;
  final String deliveryStatus;
  final DateTime createdAt;

  const LocalChatMessageView({
    required this.clientMsgId,
    this.serverMsgId,
    required this.conversationId,
    this.seqId,
    required this.senderId,
    this.replyToMsgId,
    required this.messageType,
    this.bodyText,
    this.attachmentJson,
    required this.deliveryStatus,
    required this.createdAt,
  });
}
