import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../services/auth_service.dart';
import '../../domain/chat_protocol.dart';
import '../local/chat_drift_database.dart';
import 'chat_api_service.dart';

enum WsConnectionState { disconnected, connecting, connected, reconnecting }

class ChatWsService {
  final ChatDriftDatabase _db;
  final ChatApiService _api;
  final math.Random _rng = math.Random();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _socketSub;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  WsConnectionState _state = WsConnectionState.disconnected;
  int _reconnectAttempt = 0;
  DateTime _lastActivityAt = DateTime.now();
  bool _manualDisconnect = false;
  bool _isFlushingOutbox = false;
  String? _currentUserId;
  String? _activeRoomId;

  final StreamController<WsConnectionState> _stateCtrl =
      StreamController<WsConnectionState>.broadcast();
  final StreamController<ServerTypingIndicatorFrame> _typingCtrl =
      StreamController<ServerTypingIndicatorFrame>.broadcast();
  final StreamController<ServerFrameErrorFrame> _errorCtrl =
      StreamController<ServerFrameErrorFrame>.broadcast();
  final StreamController<ServerSocialGraphEventFrame> _graphEventsCtrl =
      StreamController<ServerSocialGraphEventFrame>.broadcast();
  final StreamController<ServerPushNotificationEventFrame> _notifEventsCtrl =
      StreamController<ServerPushNotificationEventFrame>.broadcast();

  ChatWsService(this._db, this._api);

  WsConnectionState get currentState => _state;
  Stream<WsConnectionState> get connectionStateStream => _stateCtrl.stream;
  Stream<ServerTypingIndicatorFrame> get typingStream => _typingCtrl.stream;
  Stream<ServerFrameErrorFrame> get errorStream => _errorCtrl.stream;
  Stream<ServerSocialGraphEventFrame> get socialGraphEvents =>
      _graphEventsCtrl.stream;
  Stream<ServerPushNotificationEventFrame> get pushNotificationEvents =>
      _notifEventsCtrl.stream;

  void _setState(WsConnectionState next) {
    if (_state == next) return;
    _state = next;
    if (!_stateCtrl.isClosed) {
      _stateCtrl.add(next);
    }
  }

  Future<String?> _resolveJwtToken() async {
    final direct = await AuthService.getToken();
    if (direct != null && direct.trim().isNotEmpty) return direct.trim();
    final prefs = await SharedPreferences.getInstance();
    final v1 = prefs.getString('coffeehub_auth_token_v1')?.trim();
    return (v1 != null && v1.isNotEmpty) ? v1 : null;
  }

  Future<String> _resolveUserId() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && user.id.isNotEmpty) {
      _currentUserId = user.id;
      return user.id;
    }
    return _currentUserId ?? '';
  }

  Future<void> connectIfAuthenticated() async {
    if (_state == WsConnectionState.connected ||
        _state == WsConnectionState.connecting) {
      return;
    }
    _manualDisconnect = false;
    _reconnectTimer?.cancel();

    final token = await _resolveJwtToken();
    if (token == null || token.isEmpty) {
      _setState(WsConnectionState.disconnected);
      return;
    }
    await _resolveUserId();

    _setState(
      _reconnectAttempt > 0
          ? WsConnectionState.reconnecting
          : WsConnectionState.connecting,
    );

    try {
      final baseHttp = await AuthService.getBaseUrl();
      final httpUri = Uri.parse(baseHttp);
      final wsScheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
      final basePath = httpUri.path.endsWith('/')
          ? httpUri.path.substring(0, httpUri.path.length - 1)
          : httpUri.path;

      final wsUri = httpUri.replace(
        scheme: wsScheme,
        path: '$basePath/api/v1/chat/ws',
        queryParameters: kIsWeb ? {'token': token} : null,
      );

      final WebSocketChannel channel;
      if (kIsWeb) {
        channel = WebSocketChannel.connect(wsUri);
      } else {
        channel = IOWebSocketChannel.connect(
          wsUri,
          headers: {'Authorization': 'Bearer $token'},
          connectTimeout: const Duration(seconds: 12),
        );
      }

      await channel.ready;
      _channel = channel;
      _reconnectAttempt = 0;
      _lastActivityAt = DateTime.now();
      _setState(WsConnectionState.connected);

      _socketSub = channel.stream.listen(
        _onRawSocketData,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );

      _startHeartbeatWatchdog();
      await _onConnectedSyncPipeline();
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _startHeartbeatWatchdog() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_state != WsConnectionState.connected || _channel == null) return;
      final staleSeconds =
          DateTime.now().difference(_lastActivityAt).inSeconds;
      if (staleSeconds >= 45) {
        _scheduleReconnect();
        return;
      }
      sendFrame(
        ClientFrame.ping(timestampMs: DateTime.now().millisecondsSinceEpoch),
      );
    });
  }

  Future<void> _onConnectedSyncPipeline() async {
    try {
      final conversations = await _api.fetchConversations();
      if (conversations.isNotEmpty) {
        await _db.upsertConversationsFromServer(conversations);
      }
    } catch (_) {}

    final cursors = await _db.getSyncCursors();
    if (cursors.isNotEmpty) {
      await sendFrame(ClientFrame.syncDelta(cursors: cursors));
    }

    if (_activeRoomId != null) {
      await sendFrame(ClientFrame.setActiveRoom(conversationId: _activeRoomId));
    }

    await flushOutboxQueue();
  }

  Future<bool> setActiveRoom(String? conversationId) async {
    _activeRoomId = conversationId;
    return sendFrame(ClientFrame.setActiveRoom(conversationId: conversationId));
  }

  Future<bool> sendFrame(ClientFrame frame) async {
    final ch = _channel;
    if (ch == null || _state != WsConnectionState.connected) {
      return false;
    }
    try {
      ch.sink.add(json.encode(frame.toWireJson()));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> flushOutboxQueue() async {
    if (_isFlushingOutbox || _state != WsConnectionState.connected) return;
    _isFlushingOutbox = true;
    try {
      final queue = await _db.getOutboxFifo();
      for (final item in queue) {
        if (_state != WsConnectionState.connected || _channel == null) break;
        try {
          _channel!.sink.add(item.framePayloadJson);
        } catch (_) {
          await _db.markOutboxFailed(item.clientMsgId);
          break;
        }
      }
    } finally {
      _isFlushingOutbox = false;
    }
  }

  void _onRawSocketData(dynamic data) {
    _lastActivityAt = DateTime.now();
    if (data is! String) return;
    try {
      final decoded = json.decode(data);
      if (decoded is! Map<String, dynamic>) return;
      final frame = ServerFrame.tryFromWireJson(decoded);
      if (frame == null) return;
      _handleServerFrame(frame);
    } catch (_) {}
  }

  Future<void> _handleServerFrame(ServerFrame frame) async {
    final uid = await _resolveUserId();
    switch (frame) {
      case ServerMessageSentAckFrame ack:
        await _db.applySentAck(
          clientMsgId: ack.clientMsgId,
          serverMsgId: ack.serverMsgId,
          conversationId: ack.conversationId,
          seqId: ack.seqId,
          createdAt: ack.createdAt,
        );
      case ServerNewMessageFrame m:
        final dto = m.message;
        await _db.upsertIncomingMessages(
          messages: [dto],
          currentUserId: uid,
          peerDeliveredWatermarks: const {},
          peerReadWatermarks: const {},
        );
        if (dto.senderId != uid && uid.isNotEmpty) {
          await sendFrame(
            ClientFrame.ackDelivered(
              conversationId: dto.conversationId,
              upToSeqId: dto.seqId,
            ),
          );
        }
      case ServerReceiptWatermarkUpdateFrame wm:
        await _db.applyReceiptWatermark(
          conversationId: wm.conversationId,
          currentUserId: uid,
          actorUserId: wm.userId,
          status: wm.status,
          upToSeqId: wm.upToSeqId,
        );
      case ServerTypingIndicatorFrame t:
        if (!_typingCtrl.isClosed) {
          _typingCtrl.add(t);
        }
      case ServerPresenceUpdateFrame p:
        await _db.updatePeerPresence(p.userId, p.isOnline, p.lastSeenAt);
      case ServerDeltaSyncBatchFrame batch:
        final deliveredMap = <String, int>{};
        final readMap = <String, int>{};
        for (final wm in batch.watermarks) {
          if (wm.userId != uid) {
            final prevDel = deliveredMap[wm.conversationId] ?? 0;
            final prevRead = readMap[wm.conversationId] ?? 0;
            if (wm.lastDeliveredSeqId > prevDel) {
              deliveredMap[wm.conversationId] = wm.lastDeliveredSeqId;
            }
            if (wm.lastReadSeqId > prevRead) {
              readMap[wm.conversationId] = wm.lastReadSeqId;
            }
          }
        }
        await _db.upsertIncomingMessages(
          messages: batch.messages,
          currentUserId: uid,
          peerDeliveredWatermarks: deliveredMap,
          peerReadWatermarks: readMap,
        );
      case ServerFrameErrorFrame err:
        if (err.clientMsgId != null) {
          await _db.markOutboxFailed(err.clientMsgId!);
        }
        if (!_errorCtrl.isClosed) {
          _errorCtrl.add(err);
        }
      case ServerPongFrame _:
        break;
      case ServerSocialGraphEventFrame g:
        if (!_graphEventsCtrl.isClosed) {
          _graphEventsCtrl.add(g);
        }
      case ServerPushNotificationEventFrame n:
        if (!_notifEventsCtrl.isClosed) {
          _notifEventsCtrl.add(n);
        }
    }
  }

  void _scheduleReconnect() {
    _cleanupSocketOnly();
    if (_manualDisconnect) {
      _setState(WsConnectionState.disconnected);
      return;
    }
    _setState(WsConnectionState.reconnecting);
    final exp = math.min(_reconnectAttempt, 5);
    final capMs = math.min(30000, 1000 * (1 << exp));
    final jitterMs = math.max(450, _rng.nextInt(capMs + 1));
    _reconnectAttempt++;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: jitterMs), () {
      connectIfAuthenticated();
    });
  }

  void _cleanupSocketOnly() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _socketSub?.cancel();
    _socketSub = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _cleanupSocketOnly();
    _setState(WsConnectionState.disconnected);
  }

  Future<void> dispose() async {
    await disconnect();
    await _stateCtrl.close();
    await _typingCtrl.close();
    await _errorCtrl.close();
    await _graphEventsCtrl.close();
    await _notifEventsCtrl.close();
  }
}
