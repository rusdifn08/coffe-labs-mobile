import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_client.dart';
import '../../../services/auth_service.dart';
import '../domain/qris_billing_models.dart';

final qrisBillingApiProvider = Provider<QrisBillingApiService>((ref) {
  return QrisBillingApiService(ref.watch(dioClientProvider));
});

class QrisBillingApiService {
  final Dio _dio;
  QrisBillingApiService(this._dio);

  Future<List<SubscriptionPlanCatalogItem>> fetchPlans() async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>('/api/v1/billing/qris/plans');
      final list = res.data?['data'] as List? ?? const [];
      final parsed = list
          .whereType<Map>()
          .map(
            (e) => SubscriptionPlanCatalogItem.fromJson(
              e.cast<String, dynamic>(),
            ),
          )
          .toList();
      return parsed.isNotEmpty
          ? parsed
          : SubscriptionPlanCatalogItem.defaultCatalog;
    } catch (_) {
      return SubscriptionPlanCatalogItem.defaultCatalog;
    }
  }

  Future<DynamicQrisInvoiceModel> createOrResumeCheckout(
    String planCode, {
    String? referralCode,
  }) async {
    final cleanRef = referralCode?.trim().toUpperCase();
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/billing/qris/checkout',
      data: {
        'plan_code': planCode,
        if (cleanRef != null && cleanRef.isNotEmpty) 'referral_code': cleanRef,
      },
    );
    final data =
        (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return DynamicQrisInvoiceModel.fromJson(data);
  }

  Future<DynamicQrisInvoiceModel> getInvoiceStatus(String invoiceId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/billing/qris/invoices/$invoiceId/status',
    );
    final data =
        (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return DynamicQrisInvoiceModel.fromJson(data);
  }

  /// Sinkronisasi langsung upgrade tier ke endpoint RBAC produksi (`/api/v1/rbac/upgrade`)
  /// ketika pembayaran QRIS telah terverifikasi lewat bukti struk / RRN / mutasi.
  Future<bool> upgradeTierViaRbac({
    required String targetTier,
    required String paymentReference,
  }) async {
    final isBiz = targetTier.toLowerCase() == 'business';
    final planId = isBiz ? 'plan_coffe_labs_business' : 'plan_coffe_labs_pro';
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/rbac/upgrade',
        data: {
          'plan_id': planId,
          'payment_method': paymentReference,
        },
      );
      if (res.statusCode == 200) {
        final freshToken = res.data?['fresh_access_token']?.toString().trim();
        if (freshToken != null && freshToken.isNotEmpty) {
          await AuthService.applyUpgradedTierSession(
            newTier: isBiz ? 'business' : 'pro',
            planCode: isBiz ? 'BUSINESS_LIFETIME' : 'PRO_LIFETIME',
            freshAccessToken: freshToken,
          );
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Upload bukti bayar langsung ke Cloudinary via Signed Upload lalu tautkan ke invoice (Layer 3).
  Future<DynamicQrisInvoiceModel> uploadManualProofBytes({
    required String invoiceId,
    required Uint8List imageBytes,
    required String filename,
    String? note,
  }) async {
    final sigRes = await _dio.post<Map<String, dynamic>>(
      '/api/v1/media/upload-signature',
      data: {
        'folder': 'qris_manual_proofs',
        'public_id': 'proof_$invoiceId',
      },
    );
    final sig =
        (sigRes.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final uploadUrl = sig['upload_url']?.toString() ?? '';
    if (uploadUrl.isEmpty) {
      throw Exception('Layanan Cloudinary upload belum aktif di server.');
    }

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(imageBytes, filename: filename),
      'api_key': sig['api_key']?.toString() ?? '',
      'timestamp': sig['timestamp']?.toString() ?? '',
      'signature': sig['signature']?.toString() ?? '',
      'folder': sig['folder']?.toString() ?? 'qris_manual_proofs',
      if (sig['public_id'] != null) 'public_id': sig['public_id'].toString(),
    });

    final cloudDio = Dio();
    final cloudRes =
        await cloudDio.post<Map<String, dynamic>>(uploadUrl, data: formData);
    final secureUrl = cloudRes.data?['secure_url']?.toString() ?? '';
    if (secureUrl.isEmpty) {
      throw Exception('Upload gambar ke Cloudinary gagal mengembalikan URL.');
    }

    final attachRes = await _dio.post<Map<String, dynamic>>(
      '/api/v1/billing/qris/invoices/$invoiceId/manual-proof',
      data: {
        'proof_cloudinary_url': secureUrl,
        'note': ?note,
      },
    );
    final data =
        (attachRes.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return DynamicQrisInvoiceModel.fromJson(data);
  }

  Future<(String wsBaseUrl, String? jwtToken)> resolveWsBaseAndToken() async {
    final base = await AuthAndRefreshInterceptor.resolveActiveBaseUrl();
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('coffeehub_auth_jwt_token') ??
          prefs.getString('coffeehub_auth_token_v1');
    } catch (_) {}
    final wsBase = base.startsWith('https://')
        ? base.replaceFirst('https://', 'wss://')
        : base.replaceFirst('http://', 'ws://');
    return (wsBase, token);
  }

  // --- ADMIN RECONCILIATION & BRIDGE ENDPOINTS ---

  Future<AdminBridgeInfoModel> fetchAdminBridgeInfo() async {
    final res = await _dio
        .get<Map<String, dynamic>>('/api/v1/billing/qris/admin/bridge-info');
    final data =
        (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AdminBridgeInfoModel.fromJson(data);
  }

  Future<List<UnmatchedMutationModel>> fetchRecentMutations() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/billing/qris/admin/unmatched-mutations',
    );
    final list = res.data?['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => UnmatchedMutationModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<List<DynamicQrisInvoiceModel>> fetchPendingInvoices() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/billing/qris/admin/pending-invoices',
    );
    final list = res.data?['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => DynamicQrisInvoiceModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<DynamicQrisInvoiceModel> adminApproveInvoice(String invoiceId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/billing/qris/admin/manual-approve/$invoiceId',
    );
    final data =
        (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return DynamicQrisInvoiceModel.fromJson(data);
  }

  Future<Map<String, dynamic>> adminTestDynamicQris(int amountIdr) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/billing/qris/admin/test-dynamic-qris',
      data: {'amount_idr': amountIdr},
    );
    return (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  }
}

/// Bridge MethodChannel Android Native untuk mengontrol `LivinMerchantNotificationListener`.
class QrisBridgePlatformChannel {
  static const MethodChannel _channel =
      MethodChannel('com.coffeelabs.app/qris_bridge');

  static Future<MerchantBridgeStatusModel> getStatus() async {
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('getBridgeStatus');
      if (raw == null) return const MerchantBridgeStatusModel();
      List<Map<String, dynamic>> logs = const [];
      final logsJson = raw['recentLogsJson']?.toString();
      if (logsJson != null && logsJson.isNotEmpty) {
        final decoded = jsonDecode(logsJson);
        if (decoded is List) {
          logs = decoded
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList();
        }
      }
      return MerchantBridgeStatusModel(
        enabled: raw['enabled'] == true,
        hasNotificationAccess: raw['hasNotificationAccess'] == true,
        apiBaseUrl: AuthAndRefreshInterceptor.normalizeBaseUrl(
          raw['apiBaseUrl']?.toString(),
        ),
        hasSecret: raw['hasSecret'] == true,
        recentLogs: logs,
      );
    } catch (_) {
      return const MerchantBridgeStatusModel();
    }
  }

  static Future<bool> configure({
    required bool enabled,
    String? bridgeSecret,
    String? apiBaseUrl,
  }) async {
    try {
      final ok = await _channel.invokeMethod<bool>('configureBridge', {
        'enabled': enabled,
        'bridgeSecret': ?bridgeSecret,
        'apiBaseUrl': ?apiBaseUrl,
      });
      return ok == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openNotificationAccessSettings() async {
    try {
      final ok = await _channel.invokeMethod<bool>('openNotificationAccessSettings');
      return ok == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> clearLogs() async {
    try {
      final ok = await _channel.invokeMethod<bool>('clearLogs');
      return ok == true;
    } catch (_) {
      return false;
    }
  }
}
