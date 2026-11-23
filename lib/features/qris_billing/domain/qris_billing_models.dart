import 'package:intl/intl.dart';

String formatRupiahIdr(int amount) {
  final fmt = NumberFormat('#,###', 'id_ID');
  return 'Rp ${fmt.format(amount).replaceAll(',', '.')}';
}

class SubscriptionPlanCatalogItem {
  final String planCode;
  final String targetTier;
  final String displayName;
  final int durationDays;
  final int basePriceIdr;
  final int normalPriceIdr;
  final String? promoBadgeText;
  final bool isHighlighted;
  final List<String> features;
  final bool isActive;

  const SubscriptionPlanCatalogItem({
    required this.planCode,
    required this.targetTier,
    required this.displayName,
    required this.durationDays,
    required this.basePriceIdr,
    required this.normalPriceIdr,
    this.promoBadgeText,
    this.isHighlighted = false,
    required this.features,
    this.isActive = true,
  });

  bool get isBusiness => targetTier.toLowerCase() == 'business';
  bool get isLifetime => durationDays >= 3650 || planCode.endsWith('_LIFETIME');

  String get priceLabel => formatRupiahIdr(basePriceIdr);
  String get normalPriceLabel => formatRupiahIdr(normalPriceIdr);
  String get cycleLabel => isLifetime
      ? ' • Sekali Bayar'
      : (durationDays >= 360 ? ' / Tahun' : ' / Bulan');

  factory SubscriptionPlanCatalogItem.fromJson(Map<String, dynamic> j) {
    final rawFeatures = j['features'] ?? j['features_json'];
    final features = rawFeatures is List
        ? rawFeatures.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : const <String>[];
    final tier = (j['target_tier'] ?? 'pro').toString().toLowerCase();
    final isBiz = tier == 'business';
    final basePrice =
        ((j['base_price_idr'] as num?) ?? (isBiz ? 249000 : 99000)).toInt();
    final origFromApi = (j['original_price_idr'] as num?)?.toInt();
    final normalPrice = (origFromApi != null && origFromApi > basePrice)
        ? origFromApi
        : (isBiz ? 1490000 : 490000);
    return SubscriptionPlanCatalogItem(
      planCode:
          (j['plan_code'] ?? (isBiz ? 'BUSINESS_LIFETIME' : 'PRO_LIFETIME'))
              .toString(),
      targetTier: tier,
      displayName: (j['display_name'] ??
              (isBiz ? 'Coffee Labs Business' : 'Coffee Labs Pro'))
          .toString(),
      durationDays: ((j['duration_days'] as num?) ?? 36500).toInt(),
      basePriceIdr: basePrice,
      normalPriceIdr: normalPrice,
      promoBadgeText: j['promo_badge_text']?.toString(),
      isHighlighted: j['is_highlighted'] == true,
      features: features,
      isActive: j['is_active'] != false,
    );
  }

  /// Katalog resmi Coffee Labs Pro & Business (Promo Akhir 2026 • Sekali Bayar).
  static const List<SubscriptionPlanCatalogItem> defaultCatalog = [
    SubscriptionPlanCatalogItem(
      planCode: 'PRO_LIFETIME',
      targetTier: 'pro',
      displayName: 'Coffee Labs Pro',
      durationDays: 36500,
      basePriceIdr: 99000,
      normalPriceIdr: 490000,
      features: [
        'Sekali Bayar • Akses Penuh Selamanya (Promo s/d 31 Des 2026)',
        'Buka Seluruh 500+ Resep Juara Dunia & Nusantara (18 Metode)',
        'Seduh Tanpa Batas & Alarm Latar Belakang Cold Brew',
        'Toolkit Barista 21 Fitur (Smart Brew AI, Grinder Matrix, TDS)',
        '10 World Coffee E-Books, Akademi LMS & AI Bean Scanner',
        'Otomatis Jadi Partner Afiliasi Coffee Labs (Komisi 20%)',
        'Live Brew QR 2.0 & Bebas Iklan 100% Selamanya',
      ],
    ),
    SubscriptionPlanCatalogItem(
      planCode: 'BUSINESS_LIFETIME',
      targetTier: 'business',
      displayName: 'Coffee Labs Business',
      durationDays: 36500,
      basePriceIdr: 249000,
      normalPriceIdr: 1490000,
      features: [
        'Sekali Bayar • Lisensi Komersial Bisnis (Promo s/d 31 Des 2026)',
        'Seluruh Fitur Coffee Labs Pro (500+ Resep & Toolkit 21 Fitur)',
        'Business Roastery Studio: 1 Profil Roastery & Lineup Kopi Publik',
        'POS Kasir Lengkap, Smart Bean Vault & Cetak Struk Bluetooth',
        'Strict AMOLED AOD Kiosk Mode Anti Burn-In & Kunci PIN',
        'Custom Branded Live Brew 2.0 & Cetak QR Meja/Kursi Kafe',
      ],
    ),
  ];
}

class DynamicQrisInvoiceModel {
  final String invoiceId;
  final String invoiceNumber;
  final String planCode;
  final String targetTier;
  final int durationDays;
  final int baseAmountIdr;
  final int uniqueCodeIdr;
  final int totalPayableIdr;
  final String dynamicQrisPayload;
  final String merchantName;
  final String acquirerCode;
  final String nmid;
  final String status;
  final DateTime expiresAt;
  final DateTime? paidAt;
  final String? manualProofCloudinaryUrl;
  final String? freshAccessToken;
  final DateTime? subscriptionExpiresAt;
  final bool isLocalResilientMode;
  final String? appliedReferralCode;
  final int buyerDiscountIdr;

  const DynamicQrisInvoiceModel({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.planCode,
    required this.targetTier,
    required this.durationDays,
    required this.baseAmountIdr,
    required this.uniqueCodeIdr,
    required this.totalPayableIdr,
    required this.dynamicQrisPayload,
    required this.merchantName,
    required this.acquirerCode,
    required this.nmid,
    required this.status,
    required this.expiresAt,
    this.paidAt,
    this.manualProofCloudinaryUrl,
    this.freshAccessToken,
    this.subscriptionExpiresAt,
    this.isLocalResilientMode = false,
    this.appliedReferralCode,
    this.buyerDiscountIdr = 0,
  });

  bool get isPaid => status.toUpperCase() == 'PAID';
  bool get isExpired => status.toUpperCase() == 'EXPIRED';
  bool get isManualReview => status.toUpperCase() == 'MANUAL_REVIEW';
  bool get isBusiness => targetTier.toLowerCase() == 'business';
  bool get isLifetime => durationDays >= 3650 || planCode.endsWith('_LIFETIME');

  String get formattedTotal => formatRupiahIdr(totalPayableIdr);
  String get formattedBase => formatRupiahIdr(baseAmountIdr);

  DynamicQrisInvoiceModel copyWith({
    String? status,
    DateTime? paidAt,
    String? manualProofCloudinaryUrl,
    String? freshAccessToken,
    DateTime? subscriptionExpiresAt,
    bool? isLocalResilientMode,
    String? appliedReferralCode,
    int? buyerDiscountIdr,
  }) {
    return DynamicQrisInvoiceModel(
      invoiceId: invoiceId,
      invoiceNumber: invoiceNumber,
      planCode: planCode,
      targetTier: targetTier,
      durationDays: durationDays,
      baseAmountIdr: baseAmountIdr,
      uniqueCodeIdr: uniqueCodeIdr,
      totalPayableIdr: totalPayableIdr,
      dynamicQrisPayload: dynamicQrisPayload,
      merchantName: merchantName,
      acquirerCode: acquirerCode,
      nmid: nmid,
      status: status ?? this.status,
      expiresAt: expiresAt,
      paidAt: paidAt ?? this.paidAt,
      manualProofCloudinaryUrl:
          manualProofCloudinaryUrl ?? this.manualProofCloudinaryUrl,
      freshAccessToken: freshAccessToken ?? this.freshAccessToken,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      isLocalResilientMode: isLocalResilientMode ?? this.isLocalResilientMode,
      appliedReferralCode: appliedReferralCode ?? this.appliedReferralCode,
      buyerDiscountIdr: buyerDiscountIdr ?? this.buyerDiscountIdr,
    );
  }

  Map<String, dynamic> toJson() => {
        'invoice_id': invoiceId,
        'invoice_number': invoiceNumber,
        'plan_code': planCode,
        'target_tier': targetTier,
        'duration_days': durationDays,
        'base_amount_idr': baseAmountIdr,
        'unique_code_idr': uniqueCodeIdr,
        'total_payable_idr': totalPayableIdr,
        'dynamic_qris_payload': dynamicQrisPayload,
        'merchant_name': merchantName,
        'acquirer_code': acquirerCode,
        'nmid': nmid,
        'status': status,
        'expires_at': expiresAt.toIso8601String(),
        'paid_at': paidAt?.toIso8601String(),
        'manual_proof_cloudinary_url': manualProofCloudinaryUrl,
        'is_local_resilient_mode': isLocalResilientMode,
        'applied_referral_code': appliedReferralCode,
        'buyer_discount_idr': buyerDiscountIdr,
      };

  factory DynamicQrisInvoiceModel.fromJson(Map<String, dynamic> j) {
    final targetTier = (j['target_tier'] ?? 'pro').toString().toLowerCase();
    final isBiz = targetTier == 'business';
    return DynamicQrisInvoiceModel(
      invoiceId: (j['invoice_id'] ?? j['id'] ?? '').toString(),
      invoiceNumber: (j['invoice_number'] ?? '').toString(),
      planCode: (j['plan_code'] ??
              (isBiz ? 'BUSINESS_LIFETIME' : 'PRO_LIFETIME'))
          .toString(),
      targetTier: targetTier,
      durationDays: ((j['duration_days'] as num?) ?? 36500).toInt(),
      baseAmountIdr:
          ((j['base_amount_idr'] as num?) ?? (isBiz ? 249000 : 99000)).toInt(),
      uniqueCodeIdr: ((j['unique_code_idr'] as num?) ?? 1).toInt(),
      totalPayableIdr:
          ((j['total_payable_idr'] as num?) ?? (isBiz ? 249001 : 99001))
              .toInt(),
      dynamicQrisPayload: (j['dynamic_qris_payload'] ?? '').toString(),
      merchantName: (j['merchant_name'] ?? 'Coffeelabs').toString(),
      acquirerCode: (j['acquirer_code'] ?? '93600008').toString(),
      nmid: (j['nmid'] ?? 'ID1023277752888').toString(),
      status: (j['status'] ?? 'PENDING').toString().toUpperCase(),
      expiresAt: DateTime.tryParse((j['expires_at'] ?? '').toString()) ??
          DateTime.now().add(const Duration(minutes: 15)),
      paidAt: j['paid_at'] != null
          ? DateTime.tryParse(j['paid_at'].toString())
          : null,
      manualProofCloudinaryUrl: j['manual_proof_cloudinary_url']?.toString(),
      freshAccessToken: j['fresh_access_token']?.toString(),
      subscriptionExpiresAt: j['subscription_expires_at'] != null
          ? DateTime.tryParse(j['subscription_expires_at'].toString())
          : null,
      isLocalResilientMode: j['is_local_resilient_mode'] == true,
      appliedReferralCode: j['applied_referral_code']?.toString(),
      buyerDiscountIdr: ((j['buyer_discount_idr'] as num?) ?? 0).toInt(),
    );
  }
}

class UnmatchedMutationModel {
  final String id;
  final String sourceChannel;
  final int amountIdr;
  final String? payerName;
  final String? bankRrnRef;
  final String rawNotificationText;
  final DateTime receivedAt;
  final String reconciliationStatus;
  final String? matchedInvoiceId;

  const UnmatchedMutationModel({
    required this.id,
    required this.sourceChannel,
    required this.amountIdr,
    this.payerName,
    this.bankRrnRef,
    required this.rawNotificationText,
    required this.receivedAt,
    required this.reconciliationStatus,
    this.matchedInvoiceId,
  });

  factory UnmatchedMutationModel.fromJson(Map<String, dynamic> j) {
    return UnmatchedMutationModel(
      id: (j['id'] ?? '').toString(),
      sourceChannel: (j['source_channel'] ?? 'LIVIN_ANDROID_BRIDGE').toString(),
      amountIdr: ((j['amount_idr'] as num?) ?? 0).toInt(),
      payerName: j['payer_name']?.toString(),
      bankRrnRef: j['bank_rrn_ref']?.toString(),
      rawNotificationText: (j['raw_notification_text'] ?? '').toString(),
      receivedAt: DateTime.tryParse((j['received_at'] ?? '').toString()) ??
          DateTime.now(),
      reconciliationStatus:
          (j['reconciliation_status'] ?? 'UNMATCHED').toString(),
      matchedInvoiceId: j['matched_invoice_id']?.toString(),
    );
  }
}

class MerchantBridgeStatusModel {
  final bool enabled;
  final bool hasNotificationAccess;
  final String apiBaseUrl;
  final bool hasSecret;
  final List<Map<String, dynamic>> recentLogs;

  const MerchantBridgeStatusModel({
    this.enabled = false,
    this.hasNotificationAccess = false,
    this.apiBaseUrl = 'https://coffe-labs-backend-production.up.railway.app',
    this.hasSecret = false,
    this.recentLogs = const [],
  });
}

class AdminBridgeInfoModel {
  final String merchantName;
  final String merchantCity;
  final String acquirerCode;
  final String nmid;
  final bool staticQrisCrcValid;
  final String bridgeHmacSecret;
  final bool imapWatcherConfigured;

  const AdminBridgeInfoModel({
    required this.merchantName,
    required this.merchantCity,
    required this.acquirerCode,
    required this.nmid,
    required this.staticQrisCrcValid,
    required this.bridgeHmacSecret,
    required this.imapWatcherConfigured,
  });

  factory AdminBridgeInfoModel.fromJson(Map<String, dynamic> j) {
    return AdminBridgeInfoModel(
      merchantName: (j['merchant_name'] ?? 'Coffeelabs').toString(),
      merchantCity: (j['merchant_city'] ?? 'Bandung (Kab)').toString(),
      acquirerCode: (j['acquirer_code'] ?? '93600008').toString(),
      nmid: (j['nmid'] ?? 'ID1023277752888').toString(),
      staticQrisCrcValid: j['static_qris_crc_valid'] == true,
      bridgeHmacSecret: (j['bridge_hmac_secret'] ?? '').toString(),
      imapWatcherConfigured: j['imap_watcher_configured'] == true,
    );
  }
}
