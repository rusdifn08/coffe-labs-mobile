import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/dio_client.dart';
import '../../../services/auth_service.dart';
import '../models/affiliate_models.dart';

final affiliateApiServiceProvider = Provider<AffiliateApiService>((ref) {
  return AffiliateApiService(ref.watch(dioClientProvider));
});

class AffiliateApiService {
  final Dio _dio;
  static const String _localCustomCodeKey = 'coffeehub_aff_custom_code_v1';

  AffiliateApiService(this._dio);

  Future<AffiliateDashboardModel> fetchMyDashboard() async {
    try {
      final res = await _dio
          .get<Map<String, dynamic>>('/api/v1/affiliate/me')
          .timeout(const Duration(seconds: 8));
      final data =
          (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      return AffiliateDashboardModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) rethrow;
      return _buildResilientLocalDashboard();
    } catch (_) {
      return _buildResilientLocalDashboard();
    }
  }

  Future<AffiliateDashboardModel> _buildResilientLocalDashboard() async {
    final user = await AuthService.getCurrentUser();
    final isProEligible = user != null && (user.isPro || user.isBusiness || user.isAdmin);
    if (!isProEligible) {
      return AffiliateDashboardModel(
        isEligiblePro: false,
        currentTier: user?.tier ?? 'trial',
        isLocalPreview: true,
      );
    }
    final prefs = await SharedPreferences.getInstance();
    final customSaved = prefs.getString('${_localCustomCodeKey}_${user.id}');
    final prefix = user.username
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase()
        .padRight(4, 'X')
        .substring(0, 4);
    final suffix = user.id.replaceAll('-', '').toUpperCase().substring(0, 4);
    final code = customSaved ?? 'CL-$prefix$suffix';

    return AffiliateDashboardModel(
      isEligiblePro: true,
      currentTier: user.tier,
      isLocalPreview: true,
      wallet: AffiliateWalletModel(
        affiliateCode: code,
        shareLink: 'https://coffeelabs.id/join?ref=$code',
        isCustomCodeClaimed: customSaved != null,
        isAffiliateActive: true,
        availableBalanceIdr: 0,
        lockedWithdrawalIdr: 0,
        totalEarnedIdr: 0,
        totalWithdrawnIdr: 0,
        totalSuccessfulReferrals: 0,
      ),
    );
  }

  Future<AffiliateWalletModel> customizeAffiliateCode(String customCode) async {
    final clean = customCode.trim().toUpperCase();
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        '/api/v1/affiliate/code',
        data: {'custom_code': clean},
      );
      final data =
          (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      return AffiliateWalletModel.fromJson(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null && status != 404 && status < 500) {
        final msg = (e.response?.data is Map)
            ? (e.response?.data['message']?.toString() ?? 'Gagal memperbarui kode.')
            : 'Gagal memperbarui kode.';
        throw Exception(msg);
      }
      // Fallback lokal saat backend belum deploy
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('${_localCustomCodeKey}_${user.id}', clean);
      }
      return AffiliateWalletModel(
        affiliateCode: clean,
        shareLink: 'https://coffeelabs.id/join?ref=$clean',
        isCustomCodeClaimed: true,
        isAffiliateActive: true,
        availableBalanceIdr: 0,
        lockedWithdrawalIdr: 0,
        totalEarnedIdr: 0,
        totalWithdrawnIdr: 0,
        totalSuccessfulReferrals: 0,
      );
    }
  }

  Future<ValidatedReferralPreview> validateReferralCode({
    required String code,
    required String planCode,
  }) async {
    final clean = code.trim().toUpperCase();
    if (clean.length < 4 || clean.length > 24) {
      throw Exception('Kode referral minimal 4 karakter.');
    }
    try {
      final res = await _dio
          .post<Map<String, dynamic>>(
            '/api/v1/affiliate/validate-code',
            data: {'code': clean, 'plan_code': planCode},
          )
          .timeout(const Duration(seconds: 7));
      final data =
          (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      return ValidatedReferralPreview.fromJson(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null && status != 404 && status < 500) {
        final msg = (e.response?.data is Map)
            ? (e.response?.data['message']?.toString() ?? 'Kode referral tidak valid.')
            : 'Kode referral tidak valid.';
        throw Exception(msg);
      }
      // Fallback format saat backend belum deploy
      final isBiz = planCode.toUpperCase().contains('BUSINESS');
      final base = isBiz ? 249000 : 99000;
      final disc = (base * 1000) ~/ 10000;
      final comm = isBiz ? 50000 : 20000;
      return ValidatedReferralPreview(
        valid: true,
        normalizedCode: clean,
        referrerDisplayName: 'Partner Pro ($clean)',
        buyerDiscountBps: 1000,
        buyerDiscountIdr: disc,
        basePriceIdr: base,
        finalBasePriceIdr: base - disc,
        affiliateCommissionBps: 2000,
        affiliateCommissionIdr: comm,
      );
    }
  }

  Future<AffiliateWithdrawalItem> createWithdrawal({
    required int requestedAmountIdr,
    required String payoutChannel,
    required String bankOrWalletLabel,
    required String accountNumber,
    required String accountHolderName,
    String? userNotes,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/affiliate/withdrawals',
        data: {
          'requested_amount_idr': requestedAmountIdr,
          'payout_channel': payoutChannel,
          'bank_or_wallet_label': bankOrWalletLabel,
          'account_number': accountNumber.trim(),
          'account_holder_name': accountHolderName.trim(),
          if (userNotes != null && userNotes.trim().isNotEmpty)
            'user_notes': userNotes.trim(),
        },
      );
      final data =
          (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      return AffiliateWithdrawalItem.fromJson(data);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map)
          ? (e.response?.data['message']?.toString() ??
              'Gagal mengajukan penarikan saldo.')
          : 'Gagal mengajukan penarikan saldo.';
      throw Exception(msg);
    }
  }

  Future<AffiliateWithdrawalItem> cancelWithdrawal(String withdrawalId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/affiliate/withdrawals/$withdrawalId/cancel',
    );
    final data =
        (res.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AffiliateWithdrawalItem.fromJson(data);
  }

  // --- ADMIN ACC PAYOUT ENDPOINTS ---

  Future<List<AdminWithdrawalItem>> fetchAdminQueue({String? status}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/affiliate/admin/withdrawals',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final list = res.data?['data'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => AdminWithdrawalItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> adminMarkProcessing(String withdrawalId) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/v1/affiliate/admin/withdrawals/$withdrawalId/processing',
    );
  }

  Future<void> adminApproveWithProofBytes({
    required String withdrawalId,
    required Uint8List imageBytes,
    required String filename,
    String? transferRefCode,
    String? adminNotes,
  }) async {
    final sigRes = await _dio.post<Map<String, dynamic>>(
      '/api/v1/affiliate/admin/payout-proof-signature',
      data: {'withdrawal_id': withdrawalId},
    );
    final sig =
        (sigRes.data?['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final uploadUrl = sig['upload_url']?.toString() ?? '';
    if (uploadUrl.isEmpty) {
      throw Exception('Cloudinary belum aktif pada server.');
    }

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(imageBytes, filename: filename),
      'api_key': sig['api_key']?.toString() ?? '',
      'timestamp': sig['timestamp']?.toString() ?? '',
      'signature': sig['signature']?.toString() ?? '',
      'folder': sig['folder']?.toString() ?? 'coffeelabs/payout_proofs',
      if (sig['public_id'] != null) 'public_id': sig['public_id'].toString(),
    });

    final cloudRes =
        await Dio().post<Map<String, dynamic>>(uploadUrl, data: formData);
    final secureUrl = cloudRes.data?['secure_url']?.toString() ?? '';
    final publicId = cloudRes.data?['public_id']?.toString();
    if (secureUrl.isEmpty) {
      throw Exception('Gagal mengunggah bukti transfer ke Cloudinary.');
    }

    await _dio.post<Map<String, dynamic>>(
      '/api/v1/affiliate/admin/withdrawals/$withdrawalId/approve',
      data: {
        'transfer_proof_cloudinary_url': secureUrl,
        'transfer_proof_cloudinary_public_id': ?publicId,
        if (transferRefCode != null && transferRefCode.trim().isNotEmpty)
          'admin_transfer_ref_code': transferRefCode.trim(),
        if (adminNotes != null && adminNotes.trim().isNotEmpty)
          'admin_notes': adminNotes.trim(),
      },
    );
  }

  Future<void> adminRejectWithdrawal({
    required String withdrawalId,
    required String rejectionReason,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/v1/affiliate/admin/withdrawals/$withdrawalId/reject',
      data: {'rejection_reason': rejectionReason.trim()},
    );
  }
}
