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
  static const String publicWebBaseUrl = 'https://brewingcoffee.vercel.app';

  final Dio _dio;
  LiveBrewV2ApiService(this._dio);

  /// Normalizes any legacy/unhosted domain (`coffeelabs.com`, `coffeelabs.app`)
  /// returned by cached sessions to the live public web viewer URL.
  static String normalizePublicShareUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return '$publicWebBaseUrl/livebrew';
    return trimmed
        .replaceFirst('https://coffeelabs.com', publicWebBaseUrl)
        .replaceFirst('http://coffeelabs.com', publicWebBaseUrl)
        .replaceFirst('https://coffeelabs.app', publicWebBaseUrl)
        .replaceFirst('http://coffeelabs.app', publicWebBaseUrl);
  }

  static ParsedLiveBrewTarget parseUserInputOrUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const ParsedLiveBrewTarget();

    // Support HTTPS URLs (brewingcoffee.vercel.app, coffeelabs.app, coffeelabs.com) and coffeelabs:// deep links
    final uri = Uri.tryParse(trimmed);
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https' || uri.scheme == 'coffeelabs')) {
      final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (uri.scheme == 'coffeelabs' && uri.host == 'livebrew') {
        if (segs.length >= 2) {
          return ParsedLiveBrewTarget(
            cafeSlug: segs[0].toLowerCase(),
            seatSlug: segs[1].toLowerCase(),
          );
        }
        if (segs.length == 1) {
          return ParsedLiveBrewTarget(shareCode: segs.first);
        }
      }
      final idx = segs.indexOf('livebrew');
      if (idx != -1) {
        final rest = segs.sublist(idx + 1);
        if (rest.length >= 2) {
          return ParsedLiveBrewTarget(
            cafeSlug: rest[0].toLowerCase(),
            seatSlug: rest[1].toLowerCase(),
          );
        }
        if (rest.length == 1) {
          return ParsedLiveBrewTarget(shareCode: rest.first);
        }
      }
      final qCode = uri.queryParameters['code']?.trim();
      if (qCode != null && qCode.isNotEmpty) {
        return parseUserInputOrUrl(qCode);
      }
    }

    // Short slug input "kopi-senja/meja-04"
    if (trimmed.contains('/')) {
      final parts = trimmed
          .split('/')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
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
    final base = await AuthAndRefreshInterceptor.resolveActiveBaseUrl();
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
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

  Map<String, dynamic> _normalizeSnapshotJson(Map<String, dynamic> raw) {
    final copy = Map<String, dynamic>.from(raw);
    if (copy['share_url'] is String) {
      copy['share_url'] = normalizePublicShareUrl(copy['share_url'] as String);
    }
    return copy;
  }

  Map<String, dynamic> _normalizeSeatJson(Map<String, dynamic> raw) {
    final copy = Map<String, dynamic>.from(raw);
    if (copy['branded_url'] is String) {
      copy['branded_url'] = normalizePublicShareUrl(copy['branded_url'] as String);
    }
    return copy;
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
    bool? initialTimerRunning,
    int? initialElapsedMs,
    int? initialStepIndex,
    double? initialTempC,
    double? initialWeightG,
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
        'initial_timer_running': ?initialTimerRunning,
        'initial_elapsed_ms': ?initialElapsedMs,
        'initial_step_index': ?initialStepIndex,
        'initial_temp_c': ?initialTempC,
        'initial_weight_g': ?initialWeightG,
      },
    );
    final data = (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return LiveSessionMirrorSnapshot.fromJson(_normalizeSnapshotJson(data));
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
    return LiveSessionMirrorSnapshot.fromJson(_normalizeSnapshotJson(data));
  }

  Future<void> endRealMirrorSession(String sessionId) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/v1/livebrew/v2/sessions/$sessionId/end',
      );
    } catch (_) {}
  }

  Future<BrandedSeatResolution> resolveTarget(ParsedLiveBrewTarget target) async {
    final endpoint = target.isBrandedSeat
        ? '/api/v1/livebrew/resolve/cafe/${target.cafeSlug}/${target.seatSlug}'
        : '/api/v1/livebrew/resolve/code/${target.shareCode}';
    final res = await _dio.get<Map<String, dynamic>>(endpoint);
    final data = Map<String, dynamic>.from(
      (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
    if (data['seat'] is Map) {
      data['seat'] = _normalizeSeatJson((data['seat'] as Map).cast<String, dynamic>());
    }
    if (data['active_brew_session'] is Map) {
      data['active_brew_session'] = _normalizeSnapshotJson(
        (data['active_brew_session'] as Map).cast<String, dynamic>(),
      );
    }
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
    final res = await _dio.get<Map<String, dynamic>>('/api/v1/livebrew/business/branding');
    final raw = res.data?['data'];
    if (raw is Map) {
      return BusinessBrandingModel.fromJson(raw.cast<String, dynamic>());
    }
    return null;
  }

  Future<BusinessBrandingModel> saveBranding({
    required String cafeSlug,
    required String cafeDisplayName,
    String? logoCloudinaryUrl,
    String primaryColorHex = '#5D3A1A',
    String accentColorHex = '#B45309',
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
    final res = await _dio.get<Map<String, dynamic>>('/api/v1/livebrew/business/seats');
    final list = res.data?['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => CafeSeatModel.fromJson(_normalizeSeatJson(e.cast<String, dynamic>())))
        .toList();
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
    return CafeSeatModel.fromJson(_normalizeSeatJson(data));
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
        .map((e) => CafeSeatModel.fromJson(_normalizeSeatJson(e.cast<String, dynamic>())))
        .toList();
  }

  Future<bool> deleteSeat(String seatId) async {
    await _dio.delete<Map<String, dynamic>>(
      '/api/v1/livebrew/business/seats/$seatId',
    );
    return true;
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
