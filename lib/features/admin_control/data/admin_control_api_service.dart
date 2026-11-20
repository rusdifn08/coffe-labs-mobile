import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_client.dart';
import '../../../services/auth_service.dart';
import '../models/admin_control_models.dart';

final adminControlApiProvider = Provider<AdminControlApiService>((ref) {
  return AdminControlApiService(ref.watch(dioClientProvider));
});

class AdminControlApiService {
  static const String _cacheKey = 'coffee_labs_system_control_snapshot_v1';
  final Dio _dio;

  AdminControlApiService(this._dio);

  Future<Options> _authOptions() async {
    final token = await AuthService.getToken();
    return Options(
      headers: token != null && token.isNotEmpty
          ? {'Authorization': 'Bearer $token'}
          : null,
    );
  }

  /// Resolves the WebSocket URL for real-time control snapshot broadcast.
  Uri resolveControlWsUri() {
    final base = _dio.options.baseUrl.trim();
    final parsed = Uri.tryParse(base);
    if (parsed == null || parsed.host.isEmpty) {
      return Uri.parse('wss://coffe-labs-backend.onrender.com/api/v1/system/control-ws');
    }
    final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
    return parsed.replace(
      scheme: wsScheme,
      path: '/api/v1/system/control-ws',
      query: null,
    );
  }

  /// Hydrates cached snapshot locally in 0ms for instant cold start.
  Future<SystemControlSnapshot?> loadCachedSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return SystemControlSnapshot.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveCachedSnapshot(SystemControlSnapshot snapshot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(snapshot.toJson()));
    } catch (_) {}
  }

  /// Fetches latest snapshot; returns `null` when server replies `304 Not Modified`.
  Future<SystemControlSnapshot?> fetchPublicSnapshot({int? sinceVersion}) async {
    final resp = await _dio.get<dynamic>(
      '/api/v1/system/control-snapshot',
      queryParameters: sinceVersion != null && sinceVersion > 0
          ? {'since_version': sinceVersion}
          : null,
      options: Options(
        validateStatus: (s) => s != null && (s == 200 || s == 304),
        extra: const {'silentLog': true},
      ),
    );
    if (resp.statusCode == 304 || resp.data == null) return null;
    final body = resp.data;
    final payload = (body is Map && body['data'] is Map)
        ? Map<String, dynamic>.from(body['data'] as Map)
        : (body is Map ? Map<String, dynamic>.from(body) : null);
    if (payload == null) return null;
    return SystemControlSnapshot.fromJson(payload);
  }

  Future<SystemControlSnapshot> fetchAdminSnapshot() async {
    final resp = await _dio.get<dynamic>(
      '/api/v1/admin/control/features',
      options: await _authOptions(),
    );
    final payload = Map<String, dynamic>.from(resp.data['data'] as Map);
    return SystemControlSnapshot.fromJson(payload);
  }

  Future<SystemControlSnapshot> updateFeatureLock({
    required String featureKey,
    required bool isLocked,
    required FeatureLockStatus lockStatus,
    String? customBadgeLabel,
    String lockTitle = '',
    String lockMessage = '',
    DateTime? estimatedUnlockAt,
    bool allowAdminBypass = true,
    String? reasonNote,
  }) async {
    final resp = await _dio.put<dynamic>(
      '/api/v1/admin/control/features/${featureKey.toUpperCase()}',
      options: await _authOptions(),
      data: {
        'is_locked': isLocked,
        'lock_status': isLocked ? lockStatus.apiValue : 'UNLOCKED',
        'custom_badge_label':
            (customBadgeLabel ?? '').trim().isEmpty ? null : customBadgeLabel!.trim(),
        'lock_title': lockTitle.trim(),
        'lock_message': lockMessage.trim(),
        'estimated_unlock_at': estimatedUnlockAt?.toUtc().toIso8601String(),
        'allow_admin_bypass': allowAdminBypass,
        'reason_note': reasonNote,
      },
    );
    final payload = Map<String, dynamic>.from(resp.data['data'] as Map);
    return SystemControlSnapshot.fromJson(payload);
  }

  Future<SystemControlSnapshot> bulkLockFeatures({
    List<String>? featureKeys,
    required bool isLocked,
    required FeatureLockStatus lockStatus,
    String lockTitle = '',
    String lockMessage = '',
    DateTime? estimatedUnlockAt,
    bool allowAdminBypass = true,
    String? reasonNote,
  }) async {
    final resp = await _dio.post<dynamic>(
      '/api/v1/admin/control/features/bulk-lock',
      options: await _authOptions(),
      data: {
        'feature_keys': featureKeys,
        'is_locked': isLocked,
        'lock_status': isLocked ? lockStatus.apiValue : 'UNLOCKED',
        'lock_title': lockTitle.trim(),
        'lock_message': lockMessage.trim(),
        'estimated_unlock_at': estimatedUnlockAt?.toUtc().toIso8601String(),
        'allow_admin_bypass': allowAdminBypass,
        'reason_note': reasonNote,
      },
    );
    final data = Map<String, dynamic>.from(resp.data['data'] as Map);
    final snapJson = Map<String, dynamic>.from(data['snapshot'] as Map);
    return SystemControlSnapshot.fromJson(snapJson);
  }

  Future<SystemControlSnapshot> updatePlanPricing({
    required String planCode,
    String? displayName,
    required int basePriceIdr,
    int? originalPriceIdr,
    String? promoBadgeText,
    required int durationDays,
    required bool isActive,
    bool? isHighlighted,
    String? reasonNote,
  }) async {
    final resp = await _dio.put<dynamic>(
      '/api/v1/admin/control/pricing/${planCode.toUpperCase()}',
      options: await _authOptions(),
      data: {
        'display_name': displayName,
        'base_price_idr': basePriceIdr,
        'original_price_idr':
            (originalPriceIdr != null && originalPriceIdr > 0) ? originalPriceIdr : null,
        'promo_badge_text':
            (promoBadgeText ?? '').trim().isEmpty ? null : promoBadgeText!.trim(),
        'duration_days': durationDays,
        'is_active': isActive,
        'is_highlighted': isHighlighted,
        'reason_note': reasonNote,
      },
    );
    final payload = Map<String, dynamic>.from(resp.data['data'] as Map);
    return SystemControlSnapshot.fromJson(payload);
  }

  Future<List<AdminControlAuditLogItem>> fetchAuditLogs({int limit = 50}) async {
    final resp = await _dio.get<dynamic>(
      '/api/v1/admin/control/audit-logs',
      queryParameters: {'limit': limit},
      options: await _authOptions(),
    );
    final list = resp.data['data'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => AdminControlAuditLogItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<SystemControlSnapshot> updateAffiliateConfig({
    required bool isProgramActive,
    required int affiliateCommissionPercent,
    required int buyerDiscountPercent,
    required bool allowFreeTierAffiliates,
    int? minWithdrawalIdr,
    String? reasonNote,
  }) async {
    final resp = await _dio.put<dynamic>(
      '/api/v1/admin/control/affiliate',
      options: await _authOptions(),
      data: {
        'is_program_active': isProgramActive,
        'affiliate_commission_percent': affiliateCommissionPercent.clamp(1, 50),
        'buyer_discount_percent': buyerDiscountPercent.clamp(0, 50),
        'allow_free_tier_affiliates': allowFreeTierAffiliates,
        'min_withdrawal_idr': minWithdrawalIdr,
        'reason_note': reasonNote,
      },
    );
    final payload = Map<String, dynamic>.from(resp.data['data'] as Map);
    return SystemControlSnapshot.fromJson(payload);
  }
}
