import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_client.dart';
import '../domain/live_brew_mirror_models.dart';

final liveBrewV2ApiProvider = Provider<LiveBrewV2ApiService>((ref) {
  return LiveBrewV2ApiService(ref.watch(dioClientProvider));
});

class ParsedLiveBrewTarget {
  final String? shareCode;
  final String? cafeSlug;
  final String? seatSlug;

  const ParsedLiveBrewTarget({this.shareCode, this.cafeSlug, this.seatSlug});

  bool get isBrandedSeat =>
      cafeSlug != null &&
      cafeSlug!.isNotEmpty &&
      seatSlug != null &&
      seatSlug!.isNotEmpty;

  bool get isValid => isBrandedSeat || (shareCode != null && shareCode!.isNotEmpty);

  String get streamTargetKey =>
      isBrandedSeat ? '${cafeSlug}__$seatSlug' : (shareCode ?? '');
}

class LiveBrewV2ApiService {
  final Dio _dio;
  LiveBrewV2ApiService(this._dio);

  static ParsedLiveBrewTarget parseUserInputOrUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const ParsedLiveBrewTarget();

    // URL lengkap https://coffeelabs.com/livebrew/{cafe}/{seat} atau /livebrew/{code}
    final uri = Uri.tryParse(trimmed);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'coffeelabs')) {
      final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (uri.scheme == 'coffeelabs' && uri.host == 'livebrew') {
        if (segs.length >= 2) {
          return ParsedLiveBrewTarget(cafeSlug: segs[0].toLowerCase(), seatSlug: segs[1].toLowerCase());
        }
        if (segs.length == 1) {
          return ParsedLiveBrewTarget(shareCode: segs.first);
        }
      }
      final idx = segs.indexOf('livebrew');
      if (idx != -1) {
        final rest = segs.sublist(idx + 1);
        if (rest.length >= 2) {
          return ParsedLiveBrewTarget(cafeSlug: rest[0].toLowerCase(), seatSlug: rest[1].toLowerCase());
        }
        if (rest.length == 1) {
          return ParsedLiveBrewTarget(shareCode: rest.first);
        }
      }
    }

    // Input singkat "kopi-senja/meja-04"
    if (trimmed.contains('/')) {
      final parts = trimmed.split('/').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (parts.length >= 2) {
        return ParsedLiveBrewTarget(
          cafeSlug: parts[parts.length - 2].toLowerCase(),
          seatSlug: parts.last.toLowerCase(),
        );
      }
    }

    return ParsedLiveBrewTarget(shareCode: trimmed);
  }

  Future<(String wsBaseUrl, String? jwtToken)> resolveWsBaseAndToken() async {
    String base = AuthAndRefreshInterceptor.defaultBaseUrl;
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('coffeehub_backend_server_url')?.trim();
      if (saved != null && saved.isNotEmpty) {
        base = saved.endsWith('/') ? saved.substring(0, saved.length - 1) : saved;
      }
      token = prefs.getString('coffeehub_auth_token_v1') ??
          prefs.getString('coffeehub_auth_jwt_token');
    } catch (_) {}
    final wsBase = base.startsWith('https://')
        ? base.replaceFirst('https://', 'wss://')
        : base.replaceFirst('http://', 'ws://');
    return (wsBase, token);
  }

  Future<Map<String, int>?> pingNtp(int clientSendMs) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/livebrew/ntp',
        queryParameters: {'client_send_ms': clientSendMs},
      );
      final data = (res.data?['data'] as Map?)?.cast<String, dynamic>();
      if (data == null) return null;
      return {
        'client_send_ms': ((data['client_send_ms'] as num?) ?? clientSendMs).toInt(),
        'server_recv_ms': ((data['server_recv_ms'] as num?) ?? clientSendMs).toInt(),
        'server_send_ms': ((data['server_send_ms'] as num?) ?? clientSendMs).toInt(),
      };
    } catch (_) {
      return null;
    }
  }

  Future<LiveSessionMirrorSnapshot> createRealMirrorSession({
    String? seatId,
    String? posOrderId,
    String? posOrderNumber,
    String? customerName,
    String? methodId,
    String? methodName,
    String? recipeTitle,
    Map<String, dynamic>? recipeSnapshot,
    Map<String, dynamic>? beanSnapshot,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/livebrew/v2/sessions',
      data: {
        'seat_id': ?seatId,
        'pos_order_id': ?posOrderId,
        'pos_order_number': ?posOrderNumber,
        'customer_name': ?customerName,
        'selected_method_id': ?methodId,
        'selected_method_name': ?methodName,
        'selected_recipe_title': ?recipeTitle,
        'recipe_snapshot_json': ?recipeSnapshot,
        'bean_snapshot_json': ?beanSnapshot,
      },
    );
    final data = (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return LiveSessionMirrorSnapshot.fromJson(data);
  }

  Future<LiveSessionMirrorSnapshot> sendCommandRest(
    String sessionId,
    Map<String, dynamic> cmdPayload,
  ) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/livebrew/v2/sessions/$sessionId/command',
      data: cmdPayload,
    );
    final data = (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return LiveSessionMirrorSnapshot.fromJson(data);
  }

  Future<BrandedSeatResolution> resolveTarget(ParsedLiveBrewTarget target) async {
    final endpoint = target.isBrandedSeat
        ? '/api/v1/livebrew/resolve/cafe/${target.cafeSlug}/${target.seatSlug}'
        : '/api/v1/livebrew/resolve/code/${target.shareCode}';
    final res = await _dio.get<Map<String, dynamic>>(endpoint);
    final data = (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return BrandedSeatResolution.fromJson(data);
  }

  Future<int> sendCheer(String targetKey, String cheerKind) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/livebrew/v2/$targetKey/cheer',
      data: {'cheer_kind': cheerKind},
    );
    return ((res.data?['data'] as num?) ?? 0).toInt();
  }

  Future<BusinessBrandingModel?> getMyBranding() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/livebrew/business/branding');
      final raw = res.data?['data'];
      if (raw is Map) {
        return BusinessBrandingModel.fromJson(raw.cast<String, dynamic>());
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<BusinessBrandingModel> saveBranding({
    required String cafeSlug,
    required String cafeDisplayName,
    String? logoCloudinaryUrl,
    String primaryColorHex = '#12100E',
    String accentColorHex = '#D4A373',
    String? welcomeMessage,
    String? wifiSsid,
    String? wifiPassword,
    String? instagramHandle,
    bool showPosQueuePosition = true,
    bool showLiveBeanDetails = true,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/api/v1/livebrew/business/branding',
      data: {
        'cafe_slug': cafeSlug,
        'cafe_display_name': cafeDisplayName,
        'logo_cloudinary_url': ?logoCloudinaryUrl,
        'primary_color_hex': primaryColorHex,
        'accent_color_hex': accentColorHex,
        'welcome_message': ?welcomeMessage,
        'wifi_ssid': ?wifiSsid,
        'wifi_password': ?wifiPassword,
        'instagram_handle': ?instagramHandle,
        'show_pos_queue_position': showPosQueuePosition,
        'show_live_bean_details': showLiveBeanDetails,
      },
    );
    final data = (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return BusinessBrandingModel.fromJson(data);
  }

  Future<List<CafeSeatModel>> listMySeats() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/livebrew/business/seats');
      final list = res.data?['data'] as List? ?? const [];
      return list
          .whereType<Map>()
          .map((e) => CafeSeatModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<CafeSeatModel> createSeat({
    required String seatLabel,
    CafeSeatKind seatKind = CafeSeatKind.meja,
    String zoneArea = 'Main Area',
    int capacityPersons = 2,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/livebrew/business/seats',
      data: {
        'seat_kind': seatKind.apiValue,
        'seat_label': seatLabel,
        'zone_area': zoneArea,
        'capacity_persons': capacityPersons,
      },
    );
    final data = (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return CafeSeatModel.fromJson(data);
  }

  Future<List<CafeSeatModel>> createSeatBatch({
    required String prefix,
    required int startNumber,
    required int endNumber,
    CafeSeatKind seatKind = CafeSeatKind.meja,
    String zoneArea = 'Main Area',
    int capacityPersons = 2,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/livebrew/business/seats/batch',
      data: {
        'seat_kind': seatKind.apiValue,
        'prefix': prefix,
        'start_number': startNumber,
        'end_number': endNumber,
        'zone_area': zoneArea,
        'capacity_persons': capacityPersons,
      },
    );
    final list = res.data?['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => CafeSeatModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<BrandedSeatResolution> bindPosOrderToSeat({
    required String seatId,
    String? posOrderId,
    required String posOrderNumber,
    String posOrderStatus = 'QUEUED',
    String? customerName,
    String? itemsSummary,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/livebrew/business/pos-bind',
      data: {
        'seat_id': seatId,
        'pos_order_id': ?posOrderId,
        'pos_order_number': posOrderNumber,
        'pos_order_status': posOrderStatus,
        'customer_name': ?customerName,
        'items_summary': ?itemsSummary,
      },
    );
    final data = (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return BrandedSeatResolution.fromJson(data);
  }
}
