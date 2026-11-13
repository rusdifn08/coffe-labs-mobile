import 'package:dio/dio.dart';

import '../../domain/chat_protocol.dart';

class ChatDeltaSyncResult {
  final List<ChatMessageDto> messages;
  final List<ParticipantWatermarkDto> watermarks;

  const ChatDeltaSyncResult({
    required this.messages,
    required this.watermarks,
  });
}

class ChatApiService {
  final Dio _dio;

  ChatApiService(this._dio);

  Future<List<ChatConversationDto>> fetchConversations() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/v1/chat/conversations');
    final rawList = res.data?['data'] as List<dynamic>? ?? const [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ChatConversationDto.fromJson)
        .toList();
  }

  Future<String> createDirectRoom(String targetUserId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/chat/conversations/direct',
      data: {'target_user_id': targetUserId},
    );
    final data = res.data?['data'] as Map<String, dynamic>?;
    final id = data?['conversation_id']?.toString() ?? '';
    if (id.isEmpty) {
      throw Exception('Gagal mendapatkan ID ruang obrolan dari server.');
    }
    return id;
  }

  Future<String> createGroupRoom({
    required String title,
    String? avatarUrl,
    required List<String> memberIds,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/chat/conversations/group',
      data: {
        'title': title.trim(),
        if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
        'member_ids': memberIds,
      },
    );
    final data = res.data?['data'] as Map<String, dynamic>?;
    final id = data?['conversation_id']?.toString() ?? '';
    if (id.isEmpty) {
      throw Exception('Gagal mendapatkan ID grup dari server.');
    }
    return id;
  }

  Future<ChatDeltaSyncResult> fetchHistory(
    String conversationId, {
    int? beforeSeq,
    int limit = 50,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/chat/conversations/$conversationId/messages',
      queryParameters: {
        'before_seq': ?beforeSeq,
        'limit': limit,
      },
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    final msgs = (data['messages'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ChatMessageDto.fromJson)
        .toList();
    final wms = (data['watermarks'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ParticipantWatermarkDto.fromJson)
        .toList();
    return ChatDeltaSyncResult(messages: msgs, watermarks: wms);
  }

  Future<ChatDeltaSyncResult> syncDelta(List<ConversationCursorDto> cursors) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/chat/sync-delta',
      data: {'cursors': cursors.map((c) => c.toJson()).toList()},
    );
    final data = res.data?['data'] as Map<String, dynamic>? ?? const {};
    final msgs = (data['messages'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ChatMessageDto.fromJson)
        .toList();
    final wms = (data['watermarks'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ParticipantWatermarkDto.fromJson)
        .toList();
    return ChatDeltaSyncResult(messages: msgs, watermarks: wms);
  }

  Future<List<ChatPeerDto>> searchPeers({String? query, int limit = 25}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/chat/peers',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'limit': limit,
      },
    );
    final rawList = res.data?['data'] as List<dynamic>? ?? const [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ChatPeerDto.fromJson)
        .toList();
  }
}
