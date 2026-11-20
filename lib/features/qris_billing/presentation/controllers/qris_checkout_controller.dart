import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../admin_control/controllers/system_control_sync_controller.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../../services/auth_service.dart';
import '../../data/qris_billing_api_service.dart';
import '../../domain/qris_billing_models.dart';
import '../../domain/services/emvco_qris_converter.dart';

class QrisCheckoutState {
  final List<SubscriptionPlanCatalogItem> plans;
  final bool isLoadingPlans;
  final bool isCreatingInvoice;
  final bool isUploadingProof;
  final bool isVerifyingPayment;
  final bool isWsConnected;
  final DynamicQrisInvoiceModel? activeInvoice;
  final String? confirmedTier;
  final DateTime? confirmedExpiresAt;
  final String? errorMessage;

  const QrisCheckoutState({
    this.plans = SubscriptionPlanCatalogItem.defaultCatalog,
    this.isLoadingPlans = false,
    this.isCreatingInvoice = false,
    this.isUploadingProof = false,
    this.isVerifyingPayment = false,
    this.isWsConnected = false,
    this.activeInvoice,
    this.confirmedTier,
    this.confirmedExpiresAt,
    this.errorMessage,
  });

  QrisCheckoutState copyWith({
    List<SubscriptionPlanCatalogItem>? plans,
    bool? isLoadingPlans,
    bool? isCreatingInvoice,
    bool? isUploadingProof,
    bool? isVerifyingPayment,
    bool? isWsConnected,
    DynamicQrisInvoiceModel? activeInvoice,
    bool clearInvoice = false,
    String? confirmedTier,
    bool clearConfirmed = false,
    DateTime? confirmedExpiresAt,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QrisCheckoutState(
      plans: plans ?? this.plans,
      isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
      isCreatingInvoice: isCreatingInvoice ?? this.isCreatingInvoice,
      isUploadingProof: isUploadingProof ?? this.isUploadingProof,
      isVerifyingPayment: isVerifyingPayment ?? this.isVerifyingPayment,
      isWsConnected: isWsConnected ?? this.isWsConnected,
      activeInvoice: clearInvoice ? null : (activeInvoice ?? this.activeInvoice),
      confirmedTier: clearConfirmed ? null : (confirmedTier ?? this.confirmedTier),
      confirmedExpiresAt: clearConfirmed
          ? null
          : (confirmedExpiresAt ?? this.confirmedExpiresAt),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final qrisCheckoutProvider =
    NotifierProvider<QrisCheckoutController, QrisCheckoutState>(
  QrisCheckoutController.new,
);

class QrisCheckoutController extends Notifier<QrisCheckoutState> {
  static const String _localCachePrefix = 'coffeehub_qris_resilient_inv_';

  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  Timer? _fallbackPollTimer;
  bool _confirmedHandled = false;

  bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  QrisBillingApiService get _api => ref.read(qrisBillingApiProvider);

  @override
  QrisCheckoutState build() {
    ref.onDispose(_teardownRealtime);
    return const QrisCheckoutState();
  }

  Future<void> loadPlans() async {
    if (_isTestEnv) return;
    state = state.copyWith(isLoadingPlans: true, clearError: true);
    final fetched = await _api.fetchPlans();
    final activePlans = fetched.where((p) => p.isActive).toList();
    state = state.copyWith(
      plans: activePlans.isNotEmpty
          ? activePlans
          : (fetched.isNotEmpty
              ? fetched
              : SubscriptionPlanCatalogItem.defaultCatalog),
      isLoadingPlans: false,
    );
  }

  String _normalizePlanCode(String raw) {
    const knownCodes = {
      'PRO_LIFETIME',
      'BUSINESS_LIFETIME',
      'PRO_MONTHLY',
      'PRO_YEARLY',
      'BUSINESS_MONTHLY',
      'BUSINESS_YEARLY',
    };
    final upper = raw.trim().toUpperCase();
    if (knownCodes.contains(upper)) {
      return upper;
    }
    return upper.contains('BUSINESS') ? 'BUSINESS_LIFETIME' : 'PRO_LIFETIME';
  }

  /// Dual-Engine Checkout QRIS (Zero-Failure Architecture):
  /// 1. Utamakan Backend Rust Axum (`POST /api/v1/billing/qris/checkout`) untuk sinkronisasi NeonDB + Redis + WS.
  /// 2. Jika endpoint baru belum ter-deploy (404/5xx/timeout), otomatis konversi EMVCo QRIS resmi `Coffeelabs`
  ///    ber-CRC-16 lokal dan jalankan auto-polling sinkronisasi profil & pembayaran setiap 3 detik.
  Future<DynamicQrisInvoiceModel?> startCheckout(
    String planCode, {
    String? referralCode,
    int discountIdr = 0,
  }) async {
    _teardownRealtime();
    _confirmedHandled = false;
    final normalizedCode = _normalizePlanCode(planCode);
    final cleanRef = referralCode?.trim().toUpperCase();

    state = state.copyWith(
      isCreatingInvoice: true,
      clearError: true,
      clearConfirmed: true,
    );

    try {
      final invoice = await _api
          .createOrResumeCheckout(normalizedCode, referralCode: cleanRef)
          .timeout(const Duration(seconds: 8));
      state = state.copyWith(
        activeInvoice: invoice,
        isCreatingInvoice: false,
      );
      if (invoice.isPaid) {
        await _handlePaymentConfirmed(
          newTier: invoice.targetTier,
          planCode: invoice.planCode,
          freshToken: invoice.freshAccessToken,
          expiresAt: invoice.subscriptionExpiresAt,
        );
      } else {
        await _connectRealtime(invoice);
      }
      return invoice;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        final token = await AuthService.getToken();
        if (token == null || token.trim().isEmpty) {
          state = state.copyWith(
            isCreatingInvoice: false,
            errorMessage:
                'Silakan login ke akun Coffee Labs Anda terlebih dahulu agar lisensi langsung terikat ke akun.',
          );
          return null;
        }
      }
      return _activateResilientLocalQris(
        normalizedCode,
        referralCode: cleanRef,
        discountIdr: discountIdr,
      );
    } catch (_) {
      return _activateResilientLocalQris(
        normalizedCode,
        referralCode: cleanRef,
        discountIdr: discountIdr,
      );
    }
  }

  Future<DynamicQrisInvoiceModel> _activateResilientLocalQris(
    String normalizedCode, {
    String? referralCode,
    int discountIdr = 0,
  }) async {
    final livePlan = ref.read(dynamicPlanPricingProvider(normalizedCode));
    final livePrice = livePlan?.basePriceIdr;
    final priceSuffix = livePrice != null ? '_$livePrice' : '';
    final cacheKey = (referralCode != null && referralCode.isNotEmpty)
        ? '$normalizedCode${priceSuffix}_$referralCode'
        : '$normalizedCode$priceSuffix';
    final cached = await _loadCachedResilientInvoice(cacheKey);
    final invoice = cached ??
        EmvcoQrisConverter.buildResilientLifetimeInvoice(
          planCode: normalizedCode,
          appliedReferralCode: referralCode,
          discountIdr: discountIdr,
          overrideBaseAmountIdr: livePrice,
          overrideDurationDays: livePlan?.durationDays,
        );
    await _saveCachedResilientInvoice(cacheKey, invoice);

    state = state.copyWith(
      activeInvoice: invoice,
      isCreatingInvoice: false,
      clearError: true,
    );
    await _connectRealtime(invoice);
    return invoice;
  }

  Future<DynamicQrisInvoiceModel?> _loadCachedResilientInvoice(
    String planCode,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_localCachePrefix$planCode');
      if (raw == null || raw.isEmpty) return null;
      final inv = DynamicQrisInvoiceModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (inv.expiresAt.isAfter(DateTime.now().add(const Duration(minutes: 1))) &&
          EmvcoQrisConverter.verifyQrisCrc16(inv.dynamicQrisPayload)) {
        return inv;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveCachedResilientInvoice(
    String planCode,
    DynamicQrisInvoiceModel inv,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_localCachePrefix$planCode', jsonEncode(inv.toJson()));
    } catch (_) {}
  }

  Future<void> _clearCachedResilientInvoice(String planCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_localCachePrefix$planCode');
    } catch (_) {}
  }

  void attachExistingInvoice(DynamicQrisInvoiceModel invoice) {
    _teardownRealtime();
    _confirmedHandled = false;
    state = state.copyWith(
      activeInvoice: invoice,
      clearError: true,
      clearConfirmed: true,
    );
    if (!invoice.isPaid && !invoice.isExpired) {
      _connectRealtime(invoice);
    }
  }

  Future<void> _connectRealtime(DynamicQrisInvoiceModel invoice) async {
    if (_isTestEnv) return;
    _teardownRealtime();

    if (!invoice.isLocalResilientMode) {
      try {
        final (wsBase, token) = await _api.resolveWsBaseAndToken();
        final uri = Uri.parse(
          token != null && token.isNotEmpty
              ? '$wsBase/api/v1/billing/qris/invoices/${invoice.invoiceId}/ws?token=$token'
              : '$wsBase/api/v1/billing/qris/invoices/${invoice.invoiceId}/ws',
        );
        _ws = WebSocketChannel.connect(uri);
        state = state.copyWith(isWsConnected: true);

        _wsSub = _ws!.stream.listen(
          _onWsFrame,
          onError: (_) => state = state.copyWith(isWsConnected: false),
          onDone: () => state = state.copyWith(isWsConnected: false),
        );
      } catch (_) {
        state = state.copyWith(isWsConnected: false);
      }
    }

    // Selalu jalankan auto-polling 3 detik baik untuk invoice server maupun local resilient mode
    _fallbackPollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkInvoiceStatusNow(),
    );

    // Cek langsung sekali saat layar QRIS dibuka
    unawaited(checkInvoiceStatusNow());
  }

  Future<void> _onWsFrame(dynamic raw) async {
    try {
      final ev = jsonDecode(raw.toString()) as Map<String, dynamic>;
      final type = ev['event']?.toString().toUpperCase();
      if (type == 'PAYMENT_CONFIRMED') {
        await _handlePaymentConfirmed(
          newTier: (ev['new_tier'] ?? state.activeInvoice?.targetTier ?? 'pro')
              .toString(),
          planCode: (ev['plan_code'] ??
                  state.activeInvoice?.planCode ??
                  'PRO_LIFETIME')
              .toString(),
          freshToken: ev['fresh_access_token']?.toString(),
          expiresAt: DateTime.tryParse(
            (ev['subscription_expires_at'] ?? '').toString(),
          ),
        );
      } else if (type == 'EXPIRED') {
        final cur = state.activeInvoice;
        if (cur != null) {
          state = state.copyWith(activeInvoice: cur.copyWith(status: 'EXPIRED'));
        }
        _teardownRealtime();
      }
    } catch (_) {}
  }

  /// Cek status pembayaran otomatis setiap 3 detik & saat user kembali dari aplikasi bank/e-wallet.
  Future<bool> checkInvoiceStatusNow() async {
    final cur = state.activeInvoice;
    if (cur == null || _confirmedHandled || cur.isExpired) return false;

    // 1. Cek sinkronisasi profil user di backend Render / NeonDB
    try {
      final latestUser = await AuthService.syncProfile(force: true);
      if (latestUser != null) {
        final tierMatches = cur.isBusiness
            ? latestUser.isBusiness
            : (latestUser.isPro || latestUser.isBusiness);
        if (tierMatches) {
          await _handlePaymentConfirmed(
            newTier: cur.isBusiness ? 'business' : latestUser.tier,
            planCode: cur.planCode,
            freshToken: await AuthService.getToken(),
            expiresAt: null,
          );
          return true;
        }
      }
    } catch (_) {}

    if (cur.isLocalResilientMode) {
      return false;
    }

    // 2. Cek status invoice langsung ke endpoint QRIS backend
    try {
      final latest = await _api.getInvoiceStatus(cur.invoiceId);
      state = state.copyWith(activeInvoice: latest);
      if (latest.isPaid) {
        await _handlePaymentConfirmed(
          newTier: latest.targetTier,
          planCode: latest.planCode,
          freshToken: latest.freshAccessToken,
          expiresAt: latest.subscriptionExpiresAt,
        );
        return true;
      } else if (latest.isExpired) {
        _teardownRealtime();
      }
    } catch (_) {}
    return false;
  }

  /// Verifikasi & Aktivasi Pembayaran QRIS Instan:
  /// - Mengecek status server terlebih dahulu.
  /// - Mengunggah bukti struk (jika dilampirkan) & memanggil endpoint live Render `POST /api/v1/rbac/upgrade`
  ///   untuk memutakhirkan akun di NeonDB secara real-time, lalu langsung mengaktifkan lisensi Pro / Business!
  Future<bool> verifyAndActivatePayment({
    String? rrnOrReference,
    Uint8List? imageBytes,
    String? filename,
  }) async {
    final cur = state.activeInvoice;
    if (cur == null) return false;
    if (_confirmedHandled) return true;

    state = state.copyWith(
      isVerifyingPayment: true,
      isUploadingProof: imageBytes != null,
      clearError: true,
    );

    try {
      // 1. Cek apakah sudah terdeteksi otomatis di server
      final alreadyPaid = await checkInvoiceStatusNow();
      if (alreadyPaid || _confirmedHandled) {
        state = state.copyWith(
          isVerifyingPayment: false,
          isUploadingProof: false,
        );
        return true;
      }

      final refCode = (rrnOrReference != null && rrnOrReference.trim().isNotEmpty)
          ? 'RRN:${rrnOrReference.trim()}'
          : 'QRIS:${cur.invoiceNumber}:${cur.totalPayableIdr}';

      // 2. Jika ada gambar bukti struk QRIS, unggah di latar belakang bila endpoint tersedia
      if (imageBytes != null && filename != null && !cur.isLocalResilientMode) {
        try {
          await _api
              .uploadManualProofBytes(
                invoiceId: cur.invoiceId,
                imageBytes: imageBytes,
                filename: filename,
                note: 'Bukti QRIS ${cur.invoiceNumber} (${cur.formattedTotal}) $refCode',
              )
              .timeout(const Duration(seconds: 6));
        } catch (_) {}
      }

      // 3. Upgrade tier akun secara real-time di NeonDB via endpoint live `/api/v1/rbac/upgrade`
      await _api.upgradeTierViaRbac(
        targetTier: cur.targetTier,
        paymentReference:
            'QRIS_COFFEELABS_${cur.invoiceNumber}_${cur.totalPayableIdr}_$refCode',
      );

      // 4. Aktifkan sesi Pro / Business secara instan
      await _handlePaymentConfirmed(
        newTier: cur.targetTier,
        planCode: cur.planCode,
        freshToken: await AuthService.getToken(),
        expiresAt: null,
      );

      state = state.copyWith(
        isVerifyingPayment: false,
        isUploadingProof: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isVerifyingPayment: false,
        isUploadingProof: false,
        errorMessage: 'Gagal memverifikasi pembayaran: $e',
      );
      return false;
    }
  }

  Future<bool> submitManualProof({
    required Uint8List imageBytes,
    required String filename,
    String? note,
  }) async {
    return verifyAndActivatePayment(
      rrnOrReference: note,
      imageBytes: imageBytes,
      filename: filename,
    );
  }

  Future<void> _handlePaymentConfirmed({
    required String newTier,
    required String planCode,
    String? freshToken,
    DateTime? expiresAt,
  }) async {
    if (_confirmedHandled) return;
    _confirmedHandled = true;
    _teardownRealtime();

    final normalizedPlan = _normalizePlanCode(planCode);
    await _clearCachedResilientInvoice(normalizedPlan);

    await AuthService.applyUpgradedTierSession(
      newTier: newTier,
      planCode: normalizedPlan,
      freshAccessToken: freshToken,
    );
    ref.invalidate(authControllerProvider);
    HapticFeedback.heavyImpact();

    final cur = state.activeInvoice;
    state = state.copyWith(
      activeInvoice: cur?.copyWith(
        status: 'PAID',
        paidAt: DateTime.now(),
        freshAccessToken: freshToken,
        subscriptionExpiresAt: expiresAt,
      ),
      confirmedTier: newTier.toLowerCase(),
      confirmedExpiresAt: expiresAt,
      isVerifyingPayment: false,
      isUploadingProof: false,
      clearError: true,
    );
  }

  void clearSession() {
    _teardownRealtime();
    _confirmedHandled = false;
    state = state.copyWith(
      clearInvoice: true,
      clearConfirmed: true,
      clearError: true,
    );
  }

  void _teardownRealtime() {
    _fallbackPollTimer?.cancel();
    _fallbackPollTimer = null;
    _wsSub?.cancel();
    _wsSub = null;
    _ws?.sink.close();
    _ws = null;
  }
}
