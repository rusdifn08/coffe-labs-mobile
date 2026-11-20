import '../../qris_billing/domain/qris_billing_models.dart';

class PayoutChannelOption {
  final String code;
  final String label;
  final bool isEwallet;

  const PayoutChannelOption({
    required this.code,
    required this.label,
    this.isEwallet = false,
  });

  static const List<PayoutChannelOption> all = [
    PayoutChannelOption(code: 'BANK_BCA', label: 'BCA'),
    PayoutChannelOption(code: 'BANK_MANDIRI', label: 'Mandiri'),
    PayoutChannelOption(code: 'BANK_BRI', label: 'BRI'),
    PayoutChannelOption(code: 'BANK_BNI', label: 'BNI'),
    PayoutChannelOption(code: 'BANK_BSI', label: 'BSI'),
    PayoutChannelOption(code: 'BANK_SEABANK', label: 'SeaBank'),
    PayoutChannelOption(code: 'BANK_JAGO', label: 'Jago'),
    PayoutChannelOption(code: 'EWALLET_GOPAY', label: 'GoPay', isEwallet: true),
    PayoutChannelOption(code: 'EWALLET_DANA', label: 'DANA', isEwallet: true),
    PayoutChannelOption(code: 'EWALLET_OVO', label: 'OVO', isEwallet: true),
    PayoutChannelOption(
      code: 'EWALLET_SHOPEEPAY',
      label: 'ShopeePay',
      isEwallet: true,
    ),
  ];
}

class AffiliateProgramTerms {
  final int buyerDiscountBps;
  final int affiliateCommissionBps;
  final int minWithdrawalIdr;
  final int withdrawalAdminFeeIdr;
  final int proExampleCommissionIdr;
  final int businessExampleCommissionIdr;

  const AffiliateProgramTerms({
    this.buyerDiscountBps = 1000,
    this.affiliateCommissionBps = 2000,
    this.minWithdrawalIdr = 100000,
    this.withdrawalAdminFeeIdr = 0,
    this.proExampleCommissionIdr = 20000,
    this.businessExampleCommissionIdr = 50000,
  });

  int get buyerDiscountPercent => buyerDiscountBps ~/ 100;
  int get commissionPercent => affiliateCommissionBps ~/ 100;

  factory AffiliateProgramTerms.fromJson(Map<String, dynamic> j) {
    return AffiliateProgramTerms(
      buyerDiscountBps: ((j['buyer_discount_bps'] as num?) ?? 1000).toInt(),
      affiliateCommissionBps:
          ((j['affiliate_commission_bps'] as num?) ?? 2000).toInt(),
      minWithdrawalIdr: ((j['min_withdrawal_idr'] as num?) ?? 100000).toInt(),
      withdrawalAdminFeeIdr:
          ((j['withdrawal_admin_fee_idr'] as num?) ?? 0).toInt(),
      proExampleCommissionIdr:
          ((j['pro_example_commission_idr'] as num?) ?? 20000).toInt(),
      businessExampleCommissionIdr:
          ((j['business_example_commission_idr'] as num?) ?? 50000).toInt(),
    );
  }
}

class AffiliateWalletModel {
  final String affiliateCode;
  final String shareLink;
  final bool isCustomCodeClaimed;
  final bool isAffiliateActive;
  final int availableBalanceIdr;
  final int lockedWithdrawalIdr;
  final int totalEarnedIdr;
  final int totalWithdrawnIdr;
  final int totalSuccessfulReferrals;
  final String? savedPayoutChannel;
  final String? savedAccountNumber;
  final String? savedAccountHolderName;

  const AffiliateWalletModel({
    required this.affiliateCode,
    required this.shareLink,
    required this.isCustomCodeClaimed,
    required this.isAffiliateActive,
    required this.availableBalanceIdr,
    required this.lockedWithdrawalIdr,
    required this.totalEarnedIdr,
    required this.totalWithdrawnIdr,
    required this.totalSuccessfulReferrals,
    this.savedPayoutChannel,
    this.savedAccountNumber,
    this.savedAccountHolderName,
  });

  String get formattedAvailable => formatRupiahIdr(availableBalanceIdr);
  String get formattedLocked => formatRupiahIdr(lockedWithdrawalIdr);
  String get formattedTotalEarned => formatRupiahIdr(totalEarnedIdr);

  factory AffiliateWalletModel.fromJson(Map<String, dynamic> j) {
    final code = (j['affiliate_code'] ?? '').toString();
    return AffiliateWalletModel(
      affiliateCode: code,
      shareLink:
          (j['share_link'] ?? 'https://coffeelabs.id/join?ref=$code').toString(),
      isCustomCodeClaimed: j['is_custom_code_claimed'] == true,
      isAffiliateActive: j['is_affiliate_active'] != false,
      availableBalanceIdr: ((j['available_balance_idr'] as num?) ?? 0).toInt(),
      lockedWithdrawalIdr: ((j['locked_withdrawal_idr'] as num?) ?? 0).toInt(),
      totalEarnedIdr: ((j['total_earned_idr'] as num?) ?? 0).toInt(),
      totalWithdrawnIdr: ((j['total_withdrawn_idr'] as num?) ?? 0).toInt(),
      totalSuccessfulReferrals:
          ((j['total_successful_referrals'] as num?) ?? 0).toInt(),
      savedPayoutChannel: j['saved_payout_channel']?.toString(),
      savedAccountNumber: j['saved_account_number']?.toString(),
      savedAccountHolderName: j['saved_account_holder_name']?.toString(),
    );
  }
}

class AffiliateConversionItem {
  final String id;
  final String buyerUsername;
  final String buyerFullName;
  final String planCode;
  final int commissionEarnedIdr;
  final int buyerDiscountIdr;
  final DateTime createdAt;

  const AffiliateConversionItem({
    required this.id,
    required this.buyerUsername,
    required this.buyerFullName,
    required this.planCode,
    required this.commissionEarnedIdr,
    required this.buyerDiscountIdr,
    required this.createdAt,
  });

  String get planDisplayLabel => planCode.toUpperCase().contains('BUSINESS')
      ? 'Coffee Labs Business'
      : 'Coffee Labs Pro';

  factory AffiliateConversionItem.fromJson(Map<String, dynamic> j) {
    return AffiliateConversionItem(
      id: (j['id'] ?? '').toString(),
      buyerUsername: (j['buyer_username'] ?? 'barista').toString(),
      buyerFullName: (j['buyer_full_name'] ?? 'Barista').toString(),
      planCode: (j['plan_code'] ?? 'PRO_LIFETIME').toString(),
      commissionEarnedIdr:
          ((j['commission_earned_idr'] as num?) ?? 0).toInt(),
      buyerDiscountIdr: ((j['buyer_discount_idr'] as num?) ?? 0).toInt(),
      createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class AffiliateWithdrawalItem {
  final String id;
  final String ticketNumber;
  final int requestedAmountIdr;
  final int adminFeeIdr;
  final int netTransferAmountIdr;
  final String payoutChannel;
  final String bankOrWalletLabel;
  final String accountNumber;
  final String accountHolderName;
  final String status;
  final DateTime slaDeadlineAt;
  final String? adminTransferRefCode;
  final String? transferProofCloudinaryUrl;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? completedOrRejectedAt;

  const AffiliateWithdrawalItem({
    required this.id,
    required this.ticketNumber,
    required this.requestedAmountIdr,
    required this.adminFeeIdr,
    required this.netTransferAmountIdr,
    required this.payoutChannel,
    required this.bankOrWalletLabel,
    required this.accountNumber,
    required this.accountHolderName,
    required this.status,
    required this.slaDeadlineAt,
    this.adminTransferRefCode,
    this.transferProofCloudinaryUrl,
    this.rejectionReason,
    required this.createdAt,
    this.completedOrRejectedAt,
  });

  bool get isPending => status == 'PENDING_ADMIN_REVIEW';
  bool get isProcessing => status == 'PROCESSING_BY_ADMIN';
  bool get isCompleted => status == 'COMPLETED_TRANSFERRED';
  bool get isRejected => status == 'REJECTED_REFUNDED';
  bool get isCancelled => status == 'CANCELLED_BY_USER';

  String get statusLabelId {
    switch (status) {
      case 'PENDING_ADMIN_REVIEW':
        return 'Menunggu ACC (1×24 Jam Kerja)';
      case 'PROCESSING_BY_ADMIN':
        return 'Sedang Diproses Admin';
      case 'COMPLETED_TRANSFERRED':
        return 'Berhasil Ditransfer';
      case 'REJECTED_REFUNDED':
        return 'Ditolak & Saldo Dikembalikan';
      case 'CANCELLED_BY_USER':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  factory AffiliateWithdrawalItem.fromJson(Map<String, dynamic> j) {
    return AffiliateWithdrawalItem(
      id: (j['id'] ?? '').toString(),
      ticketNumber: (j['ticket_number'] ?? '').toString(),
      requestedAmountIdr: ((j['requested_amount_idr'] as num?) ?? 0).toInt(),
      adminFeeIdr: ((j['admin_fee_idr'] as num?) ?? 0).toInt(),
      netTransferAmountIdr:
          ((j['net_transfer_amount_idr'] as num?) ?? 0).toInt(),
      payoutChannel: (j['payout_channel'] ?? 'BANK_BCA').toString(),
      bankOrWalletLabel: (j['bank_or_wallet_label'] ?? 'Bank').toString(),
      accountNumber: (j['account_number'] ?? '').toString(),
      accountHolderName: (j['account_holder_name'] ?? '').toString(),
      status: (j['status'] ?? 'PENDING_ADMIN_REVIEW').toString(),
      slaDeadlineAt: DateTime.tryParse((j['sla_deadline_at'] ?? '').toString()) ??
          DateTime.now().add(const Duration(hours: 24)),
      adminTransferRefCode: j['admin_transfer_ref_code']?.toString(),
      transferProofCloudinaryUrl: j['transfer_proof_cloudinary_url']?.toString(),
      rejectionReason: j['rejection_reason']?.toString(),
      createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()) ??
          DateTime.now(),
      completedOrRejectedAt: j['completed_or_rejected_at'] != null
          ? DateTime.tryParse(j['completed_or_rejected_at'].toString())
          : null,
    );
  }
}

class AdminWithdrawalItem {
  final String id;
  final String ticketNumber;
  final String userId;
  final String affiliateUsername;
  final String affiliateFullName;
  final String affiliateCode;
  final int requestedAmountIdr;
  final int netTransferAmountIdr;
  final String payoutChannel;
  final String bankOrWalletLabel;
  final String accountNumber;
  final String accountHolderName;
  final String? userNotes;
  final String status;
  final DateTime slaDeadlineAt;
  final String? adminTransferRefCode;
  final String? transferProofCloudinaryUrl;
  final String? rejectionReason;
  final DateTime createdAt;

  const AdminWithdrawalItem({
    required this.id,
    required this.ticketNumber,
    required this.userId,
    required this.affiliateUsername,
    required this.affiliateFullName,
    required this.affiliateCode,
    required this.requestedAmountIdr,
    required this.netTransferAmountIdr,
    required this.payoutChannel,
    required this.bankOrWalletLabel,
    required this.accountNumber,
    required this.accountHolderName,
    this.userNotes,
    required this.status,
    required this.slaDeadlineAt,
    this.adminTransferRefCode,
    this.transferProofCloudinaryUrl,
    this.rejectionReason,
    required this.createdAt,
  });

  factory AdminWithdrawalItem.fromJson(Map<String, dynamic> j) {
    return AdminWithdrawalItem(
      id: (j['id'] ?? '').toString(),
      ticketNumber: (j['ticket_number'] ?? '').toString(),
      userId: (j['user_id'] ?? '').toString(),
      affiliateUsername: (j['affiliate_username'] ?? '').toString(),
      affiliateFullName: (j['affiliate_full_name'] ?? '').toString(),
      affiliateCode: (j['affiliate_code'] ?? '').toString(),
      requestedAmountIdr: ((j['requested_amount_idr'] as num?) ?? 0).toInt(),
      netTransferAmountIdr:
          ((j['net_transfer_amount_idr'] as num?) ?? 0).toInt(),
      payoutChannel: (j['payout_channel'] ?? 'BANK_BCA').toString(),
      bankOrWalletLabel: (j['bank_or_wallet_label'] ?? 'Bank').toString(),
      accountNumber: (j['account_number'] ?? '').toString(),
      accountHolderName: (j['account_holder_name'] ?? '').toString(),
      userNotes: j['user_notes']?.toString(),
      status: (j['status'] ?? 'PENDING_ADMIN_REVIEW').toString(),
      slaDeadlineAt: DateTime.tryParse((j['sla_deadline_at'] ?? '').toString()) ??
          DateTime.now().add(const Duration(hours: 24)),
      adminTransferRefCode: j['admin_transfer_ref_code']?.toString(),
      transferProofCloudinaryUrl: j['transfer_proof_cloudinary_url']?.toString(),
      rejectionReason: j['rejection_reason']?.toString(),
      createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class ValidatedReferralPreview {
  final bool valid;
  final String normalizedCode;
  final String referrerDisplayName;
  final int buyerDiscountBps;
  final int buyerDiscountIdr;
  final int basePriceIdr;
  final int finalBasePriceIdr;
  final int affiliateCommissionBps;
  final int affiliateCommissionIdr;

  const ValidatedReferralPreview({
    required this.valid,
    required this.normalizedCode,
    required this.referrerDisplayName,
    required this.buyerDiscountBps,
    required this.buyerDiscountIdr,
    required this.basePriceIdr,
    required this.finalBasePriceIdr,
    required this.affiliateCommissionBps,
    required this.affiliateCommissionIdr,
  });

  int get discountPercent => buyerDiscountBps ~/ 100;

  factory ValidatedReferralPreview.fromJson(Map<String, dynamic> j) {
    return ValidatedReferralPreview(
      valid: j['valid'] != false,
      normalizedCode: (j['normalized_code'] ?? '').toString(),
      referrerDisplayName: (j['referrer_display_name'] ?? 'Partner Pro').toString(),
      buyerDiscountBps: ((j['buyer_discount_bps'] as num?) ?? 1000).toInt(),
      buyerDiscountIdr: ((j['buyer_discount_idr'] as num?) ?? 0).toInt(),
      basePriceIdr: ((j['base_price_idr'] as num?) ?? 99000).toInt(),
      finalBasePriceIdr: ((j['final_base_price_idr'] as num?) ?? 89100).toInt(),
      affiliateCommissionBps:
          ((j['affiliate_commission_bps'] as num?) ?? 2000).toInt(),
      affiliateCommissionIdr:
          ((j['affiliate_commission_idr'] as num?) ?? 20000).toInt(),
    );
  }
}

class AffiliateDashboardModel {
  final bool isEligiblePro;
  final String currentTier;
  final AffiliateWalletModel? wallet;
  final AffiliateProgramTerms terms;
  final List<AffiliateConversionItem> recentConversions;
  final List<AffiliateWithdrawalItem> recentWithdrawals;
  final bool isLocalPreview;

  const AffiliateDashboardModel({
    required this.isEligiblePro,
    required this.currentTier,
    this.wallet,
    this.terms = const AffiliateProgramTerms(),
    this.recentConversions = const [],
    this.recentWithdrawals = const [],
    this.isLocalPreview = false,
  });

  factory AffiliateDashboardModel.fromJson(Map<String, dynamic> j) {
    return AffiliateDashboardModel(
      isEligiblePro: j['is_eligible_pro'] == true,
      currentTier: (j['current_tier'] ?? 'trial').toString().toLowerCase(),
      wallet: j['wallet'] is Map
          ? AffiliateWalletModel.fromJson(
              (j['wallet'] as Map).cast<String, dynamic>(),
            )
          : null,
      terms: j['terms'] is Map
          ? AffiliateProgramTerms.fromJson(
              (j['terms'] as Map).cast<String, dynamic>(),
            )
          : const AffiliateProgramTerms(),
      recentConversions: (j['recent_conversions'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => AffiliateConversionItem.fromJson(e.cast<String, dynamic>()))
          .toList(),
      recentWithdrawals: (j['recent_withdrawals'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => AffiliateWithdrawalItem.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}
