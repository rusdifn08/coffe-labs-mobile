import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/models/notification_models.dart';

class NotificationApiService {
  final Dio _dio;

  NotificationApiService(this._dio);

  Map<String, dynamic> _extractDataMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw['data'] is Map<String, dynamic>) {
        return raw['data'] as Map<String, dynamic>;
      }
      if (raw['data'] is Map) {
        return (raw['data'] as Map).map((k, v) => MapEntry(k.toString(), v));
      }
      return raw;
    }
    return const <String, dynamic>{};
  }

  Future<void> registerDeviceToken({
    required String deviceInstallationId,
    required String platform,
    required String fcmToken,
    String? apnsToken,
    String appVersion = '2.2.0',
    String? deviceModel,
    bool isKioskAodActive = false,
  }) async {
    await _dio.put<dynamic>(
      '/api/v1/notifications/devices/token',
      data: {
        'device_installation_id': deviceInstallationId,
        'platform': platform,
        'fcm_token': fcmToken,
        'apns_voip_or_live_activity_token': apnsToken,
        'app_version': appVersion,
        'device_model': deviceModel,
        'is_kiosk_aod_active': isKioskAodActive,
      },
    );
  }

  Future<void> updateKioskMode({
    required String deviceInstallationId,
    required bool isKioskAodActive,
  }) async {
    await _dio.patch<dynamic>(
      '/api/v1/notifications/devices/kiosk-mode',
      data: {
        'device_installation_id': deviceInstallationId,
        'is_kiosk_aod_active': isKioskAodActive,
      },
    );
  }

  Future<void> unregisterDeviceToken({
    required String deviceInstallationId,
  }) async {
    await _dio.delete<dynamic>(
      '/api/v1/notifications/devices/token',
      data: {'device_installation_id': deviceInstallationId},
    );
  }

  Future<void> setActiveChatRoom(String? conversationId) async {
    await _dio.post<dynamic>(
      '/api/v1/notifications/presence/active-room',
      data: {'conversation_id': conversationId},
    );
  }

  Future<NotificationInboxPage> getInbox({
    String category = '',
    String? cursor,
    int limit = 25,
  }) async {
    final res = await _dio.get<dynamic>(
      '/api/v1/notifications/inbox',
      queryParameters: {
        if (category.isNotEmpty) 'category': category,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit,
      },
    );
    return NotificationInboxPage.fromJson(_extractDataMap(res.data));
  }

  Future<int> getUnreadCount() async {
    final res = await _dio.get<dynamic>('/api/v1/notifications/unread-count');
    final map = _extractDataMap(res.data);
    return (map['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<int> markAsRead(String notificationId) async {
    final res = await _dio.post<dynamic>(
      '/api/v1/notifications/inbox/$notificationId/read',
    );
    final map = _extractDataMap(res.data);
    return (map['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<int> markAllAsRead() async {
    final res = await _dio.post<dynamic>(
      '/api/v1/notifications/inbox/read-all',
    );
    final map = _extractDataMap(res.data);
    return (map['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<NotificationPreferences> getPreferences() async {
    final res = await _dio.get<dynamic>('/api/v1/notifications/preferences');
    return NotificationPreferences.fromJson(_extractDataMap(res.data));
  }

  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences prefs,
  ) async {
    final res = await _dio.put<dynamic>(
      '/api/v1/notifications/preferences',
      data: prefs.toJson(),
    );
    return NotificationPreferences.fromJson(_extractDataMap(res.data));
  }

  Future<String> quickFollback(String targetUserId) async {
    final res = await _dio.post<dynamic>(
      '/api/v1/social/graph/users/$targetUserId/follow',
    );
    final map = _extractDataMap(res.data);
    return map['state']?.toString() ?? 'following';
  }

  /// Eksekutor mandiri untuk Background Isolate saat pengguna menekan tombol aksi cepat
  /// (`QUICK_FOLLBACK`, `INLINE_REPLY`, `MARK_AS_READ`) langsung dari layar kunci.
  static Future<bool> executeBackgroundAction({
    required String actionId,
    required PushDeepLinkPayload payload,
    String? replyText,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('coffeehub_auth_token_v1')?.trim() ??
          prefs.getString('coffeehub_auth_jwt_token')?.trim();
      if (token == null || token.isEmpty) return false;

      final savedUrl = prefs.getString('coffeehub_backend_server_url')?.trim();
      final baseUrl = (savedUrl != null &&
              savedUrl.isNotEmpty &&
              !savedUrl.contains('localhost') &&
              !savedUrl.contains('10.0.2.2'))
          ? (savedUrl.endsWith('/')
              ? savedUrl.substring(0, savedUrl.length - 1)
              : savedUrl)
          : AuthAndRefreshInterceptor.defaultBaseUrl;

      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (actionId == 'QUICK_FOLLBACK') {
        final actorId = payload.actorId?.trim();
        if (actorId == null || actorId.isEmpty) return false;
        await dio.post<dynamic>('/api/v1/social/graph/users/$actorId/follow');
        if (payload.notificationId != null &&
            payload.notificationId!.isNotEmpty) {
          await dio.post<dynamic>(
            '/api/v1/notifications/inbox/${payload.notificationId}/read',
          );
        }
        return true;
      }

      if (actionId == 'INLINE_REPLY') {
        final roomId = payload.conversationId?.trim();
        final text = replyText?.trim();
        if (roomId == null || roomId.isEmpty || text == null || text.isEmpty) {
          return false;
        }
        await dio.post<dynamic>(
          '/api/v1/chat/conversations/$roomId/messages',
          data: {'body_text': text, 'message_type': 'TEXT'},
        );
        return true;
      }

      if (actionId == 'MARK_AS_READ' &&
          payload.notificationId != null &&
          payload.notificationId!.isNotEmpty) {
        await dio.post<dynamic>(
          '/api/v1/notifications/inbox/${payload.notificationId}/read',
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
