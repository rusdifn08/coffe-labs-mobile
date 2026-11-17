import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_client.dart';
import '../domain/live_brew_models.dart';

final liveBrewApiProvider = Provider<LiveBrewApiService>((ref) {
  return LiveBrewApiService(ref.watch(dioClientProvider));
});

class LiveBrewApiService {
  final Dio _dio;
  LiveBrewApiService(this._dio);

  static const String landingBaseUrl = 'https://coffeelabs.app';

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

  Future<LiveBrewSnapshotModel> createSession({
    required Map<String, dynamic> recipe,
    String? tableId,
    String? posOrderId,
    String? customerName,
  }) async {
    final dose = (recipe['coffeeWeightGrams'] as num?)?.toDouble() ?? 15.0;
    final water = (recipe['totalWaterWeightGrams'] as num?)?.toDouble() ?? 225.0;
    final temp = (recipe['waterTempCelsius'] as num?)?.toDouble() ?? 91.0;
    final steps = recipe['steps'] as List? ?? [];
    int durationSec = 0;
    for (final s in steps) {
      if (s is Map) {
        durationSec += ((s['durationSeconds'] ?? s['timeSeconds'] ?? 30) as num).toInt();
      }
    }
    if (durationSec <= 0) durationSec = 145;

    final notesRaw = recipe['tastingNotes'] ?? recipe['flavorNotes'];
    final notes = notesRaw is List
        ? notesRaw.map((e) => e.toString()).toList()
        : const ['Floral', 'Sweet Caramel', 'Clean Finish'];

    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/livebrew/sessions',
      data: {
        'table_id': tableId,
        'pos_order_id': posOrderId,
        'customer_display_name': customerName ?? 'Pelanggan Coffee Labs',
        'recipe_title': recipe['title']?.toString() ?? 'V60 Live Brew',
        'brew_method': recipe['method']?.toString() ?? 'V60',
        'bean_name': recipe['beanName']?.toString() ?? 'Malabar Wine Reserve',
        'roastery_name': recipe['roastery']?.toString() ?? 'Coffee Labs Slow Bar',
        'bean_origin': recipe['origin']?.toString() ?? 'Jawa Barat, 1500 MDPL',
        'bean_process': recipe['process']?.toString() ?? 'Wine Natural',
        'tasting_notes': notes,
        'target_dose_g': dose,
        'target_water_ml': water,
        'target_temp_c': temp,
        'target_duration_sec': durationSec,
        'recipe_steps': steps,
      },
    );
    final data = (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return LiveBrewSnapshotModel.fromJson(data);
  }

  Future<List<LiveBrewTableModel>> listTables() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/livebrew/tables');
      final list = res.data?['data'] as List? ?? [];
      return list
          .map((e) => LiveBrewTableModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<LiveBrewTableModel> createTable(String tableNumber) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/livebrew/tables',
      data: {'table_number': tableNumber},
    );
    final data = (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return LiveBrewTableModel.fromJson(data);
  }

  Future<void> bindTableSession({required String tableId, required String sessionId}) async {
    await _dio.post<dynamic>(
      '/api/v1/livebrew/tables/$tableId/bind',
      data: {'session_id': sessionId},
    );
  }

  Future<Map<String, dynamic>> resolveAddress(String addressCode) async {
    final clean = extractAddressCode(addressCode);
    final res = await _dio.get<Map<String, dynamic>>('/api/v1/livebrew/resolve/$clean');
    return (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  }

  Future<int> sendCheer(String addressCode, String cheerKind) async {
    final clean = extractAddressCode(addressCode);
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/livebrew/$clean/cheer',
      data: {'cheer_kind': cheerKind},
    );
    return (res.data?['data'] as num?)?.toInt() ?? 0;
  }

  Future<void> publishWhipStatus(String sessionId, String dummySdp) async {
    try {
      await _dio.post<dynamic>(
        '/api/v1/livebrew/rtc/$sessionId/whip',
        data: dummySdp,
        options: Options(contentType: 'application/sdp'),
      );
    } catch (_) {}
  }

  Future<void> teardownWhip(String sessionId) async {
    try {
      await _dio.delete<dynamic>('/api/v1/livebrew/rtc/$sessionId/whip');
    } catch (_) {}
  }

  static String extractAddressCode(String rawInput) {
    final match = RegExp(r'\d{13}').firstMatch(rawInput.trim());
    return match?.group(0) ?? rawInput.trim();
  }
}
