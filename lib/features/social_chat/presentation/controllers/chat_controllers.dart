import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../data/local/chat_drift_database.dart';
import '../../data/services/chat_api_service.dart';
import '../../data/services/chat_ws_service.dart';
import '../../domain/chat_protocol.dart';
import '../../domain/chat_view_models.dart';

part 'chat_controllers.g.dart';

const _uuid = Uuid();

@Riverpod(keepAlive: true)
ChatDriftDatabase chatDriftDatabase(Ref ref) {
  final db = ChatDriftDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
ChatApiService chatApiService(Ref ref) {
  return ChatApiService(ref.watch(dioClientProvider));
}

@Riverpod(keepAlive: true)
ChatWsService chatWsService(Ref ref) {
  final service = ChatWsService(
    ref.watch(chatDriftDatabaseProvider),
    ref.watch(chatApiServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
Stream<WsConnectionState> chatConnectionState(Ref ref) async* {
  final ws = ref.watch(chatWsServiceProvider);
  yield ws.currentState;
  yield* ws.connectionStateStream;
}

class ChatRoomListItemView {
  final ChatConversationView conversation;
  final String? typingUserName;

  const ChatRoomListItemView({
    required this.conversation,
    this.typingUserName,
  });
}

@riverpod
class ChatRoomListController extends _$ChatRoomListController {
  final Map<String, String> _typingByRoom = {};
  final Map<String, Timer> _typingTimers = {};

  @override
  Stream<List<ChatRoomListItemView>> build() {
    final db = ref.watch(chatDriftDatabaseProvider);
    final ws = ref.watch(chatWsServiceProvider);

    unawaited(ws.connectIfAuthenticated());
    unawaited(refreshFromServer());

    final controller = StreamController<List<ChatRoomListItemView>>();
    List<ChatConversationView> latestRooms = const [];
    bool hasRooms = false;

    void emitMerged() {
      if (controller.isClosed || !hasRooms) return;
      controller.add(
        latestRooms
            .map(
              (r) => ChatRoomListItemView(
                conversation: r,
                typingUserName: _typingByRoom[r.id],
              ),
            )
            .toList(),
      );
    }

    final roomsSub = db.watchConversationViews().listen(
      (rooms) {
        latestRooms = rooms;
        hasRooms = true;
        emitMerged();
      },
      onError: (Object err, StackTrace st) {
        if (!controller.isClosed) controller.addError(err, st);
      },
    );

    final typingSub = ws.typingStream.listen((evt) {
      _typingTimers[evt.conversationId]?.cancel();
      if (evt.isTyping) {
        _typingByRoom[evt.conversationId] = evt.displayName;
        _typingTimers[evt.conversationId] = Timer(
          const Duration(milliseconds: 3500),
          () {
            _typingByRoom.remove(evt.conversationId);
            emitMerged();
          },
        );
      } else {
        _typingByRoom.remove(evt.conversationId);
      }
      emitMerged();
    });

    ref.onDispose(() {
      typingSub.cancel();
      roomsSub.cancel();
      for (final t in _typingTimers.values) {
        t.cancel();
      }
      _typingTimers.clear();
      controller.close();
    });

    return controller.stream;
  }

  Future<void> refreshFromServer() async {
    try {
      final api = ref.read(chatApiServiceProvider);
      final db = ref.read(chatDriftDatabaseProvider);
      final rooms = await api.fetchConversations();
      if (rooms.isNotEmpty) {
        await db.upsertConversationsFromServer(rooms);
      }
      final ws = ref.read(chatWsServiceProvider);
      if (ws.currentState == WsConnectionState.disconnected) {
        unawaited(ws.connectIfAuthenticated());
      }
    } catch (_) {}
  }

  Future<String> startDirectChat(String targetUserId) async {
    final api = ref.read(chatApiServiceProvider);
    final convId = await api.createDirectRoom(targetUserId);
    await refreshFromServer();
    return convId;
  }

  Future<String> createGroupChat({
    required String title,
    required List<String> memberIds,
  }) async {
    final api = ref.read(chatApiServiceProvider);
    final convId = await api.createGroupRoom(title: title, memberIds: memberIds);
    await refreshFromServer();
    return convId;
  }
}

@riverpod
class ActiveChatRoomController extends _$ActiveChatRoomController {
  DateTime? _lastTypingSentAt;
  int _lastSentReadSeq = 0;

  @override
  Stream<List<LocalChatMessageView>> build(String conversationId) {
    final db = ref.watch(chatDriftDatabaseProvider);
    final ws = ref.watch(chatWsServiceProvider);
    unawaited(ws.connectIfAuthenticated());
    unawaited(_syncRoomHistory(conversationId));

    return db.watchMessageViews(conversationId);
  }

  Future<void> _syncRoomHistory(String conversationId) async {
    try {
      final api = ref.read(chatApiServiceProvider);
      final db = ref.read(chatDriftDatabaseProvider);
      final user = await ref.read(authControllerProvider.future);
      final uid = user?.id ?? '';

      final history = await api.fetchHistory(conversationId, limit: 60);
      final deliveredMap = <String, int>{};
      final readMap = <String, int>{};
      for (final wm in history.watermarks) {
        if (wm.userId != uid) {
          deliveredMap[wm.conversationId] = wm.lastDeliveredSeqId;
          readMap[wm.conversationId] = wm.lastReadSeqId;
        }
      }
      await db.upsertIncomingMessages(
        messages: history.messages,
        currentUserId: uid,
        peerDeliveredWatermarks: deliveredMap,
        peerReadWatermarks: readMap,
      );
    } catch (_) {}
  }

  Future<void> sendTextMessage(String text, {String? replyToMsgId}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await _dispatchOutgoing(
      messageType: ChatMessageType.text,
      bodyText: trimmed,
      previewText: trimmed,
      replyToMsgId: replyToMsgId,
    );
  }

  Future<void> sendV60RecipeCard(
    V60RecipeCardAttachment card, {
    String? caption,
  }) async {
    await _dispatchOutgoing(
      messageType: ChatMessageType.recipeCard,
      bodyText: caption?.trim().isNotEmpty == true ? caption!.trim() : null,
      attachment: card,
      previewText: '☕ Resep: ${card.title}',
    );
  }

  Future<void> sendBeanProfileCard(
    CoffeeBeanCardAttachment card, {
    String? caption,
  }) async {
    await _dispatchOutgoing(
      messageType: ChatMessageType.beanCard,
      bodyText: caption?.trim().isNotEmpty == true ? caption!.trim() : null,
      attachment: card,
      previewText: '🫘 Biji: ${card.beanName} (${card.roastery})',
    );
  }

  Future<void> sendBrewSessionResult(BrewSessionResultAttachment result) async {
    await _dispatchOutgoing(
      messageType: ChatMessageType.brewLog,
      attachment: result,
      previewText: '🏆 Seduh ${result.title}: ${result.accuracyScore}%',
    );
  }

  Future<void> _dispatchOutgoing({
    required ChatMessageType messageType,
    String? bodyText,
    InteractiveAttachment? attachment,
    String? replyToMsgId,
    required String previewText,
  }) async {
    final db = ref.read(chatDriftDatabaseProvider);
    final ws = ref.read(chatWsServiceProvider);
    final authUser = await ref.read(authControllerProvider.future);
    final senderId = authUser?.id ?? 'local_barista';

    final clientMsgId = _uuid.v4();
    final frame = ClientFrame.sendMessage(
      clientMsgId: clientMsgId,
      conversationId: conversationId,
      replyToMsgId: replyToMsgId,
      messageType: messageType,
      bodyText: bodyText,
      attachment: attachment,
    );

    await db.insertOptimisticAndEnqueue(
      clientMsgId: clientMsgId,
      conversationId: conversationId,
      senderId: senderId,
      messageType: messageType,
      bodyText: bodyText,
      attachment: attachment,
      replyToMsgId: replyToMsgId,
      previewText: previewText,
      wireFrameJson: frame.toWireJson(),
    );

    await ws.sendFrame(frame);
  }

  Future<void> retryFailedMessage(LocalChatMessageView failedMsg) async {
    final db = ref.read(chatDriftDatabaseProvider);
    final ws = ref.read(chatWsServiceProvider);
    await db.retryOutboxEntry(failedMsg.clientMsgId);

    InteractiveAttachment? parsedAttachment;
    if (failedMsg.attachmentJson != null) {
      try {
        final decoded = json.decode(failedMsg.attachmentJson!);
        if (decoded is Map<String, dynamic>) {
          parsedAttachment = InteractiveAttachment.fromJson(decoded);
        }
      } catch (_) {}
    }

    final frame = ClientFrame.sendMessage(
      clientMsgId: failedMsg.clientMsgId,
      conversationId: failedMsg.conversationId,
      replyToMsgId: failedMsg.replyToMsgId,
      messageType: ChatMessageType.fromWire(failedMsg.messageType),
      bodyText: failedMsg.bodyText,
      attachment: parsedAttachment,
    );
    await ws.sendFrame(frame);
  }

  void notifyTyping() {
    final now = DateTime.now();
    if (_lastTypingSentAt != null &&
        now.difference(_lastTypingSentAt!) < const Duration(milliseconds: 2500)) {
      return;
    }
    _lastTypingSentAt = now;
    final ws = ref.read(chatWsServiceProvider);
    unawaited(
      ws.sendFrame(
        ClientFrame.typing(conversationId: conversationId, isTyping: true),
      ),
    );
  }

  Future<void> markViewportSeqAsRead(int seqId) async {
    if (seqId <= _lastSentReadSeq) return;
    _lastSentReadSeq = seqId;

    final db = ref.read(chatDriftDatabaseProvider);
    final ws = ref.read(chatWsServiceProvider);
    await db.markLocalRoomReadUpTo(conversationId, seqId);
    await ws.sendFrame(
      ClientFrame.ackRead(conversationId: conversationId, upToSeqId: seqId),
    );
  }
}
