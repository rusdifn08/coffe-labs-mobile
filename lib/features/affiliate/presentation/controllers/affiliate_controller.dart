import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/affiliate_api_service.dart';
import '../../models/affiliate_models.dart';

class AffiliateDashboardState {
  final bool isLoading;
  final bool isSubmitting;
  final AffiliateDashboardModel? dashboard;
  final String? errorMessage;

  const AffiliateDashboardState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.dashboard,
    this.errorMessage,
  });

  AffiliateDashboardState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    AffiliateDashboardModel? dashboard,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AffiliateDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final affiliateDashboardProvider =
    NotifierProvider<AffiliateDashboardController, AffiliateDashboardState>(
  AffiliateDashboardController.new,
);

class AffiliateDashboardController extends Notifier<AffiliateDashboardState> {
  AffiliateApiService get _api => ref.read(affiliateApiServiceProvider);

  @override
  AffiliateDashboardState build() => const AffiliateDashboardState();

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final d = await _api.fetchMyDashboard();
      state = state.copyWith(isLoading: false, dashboard: d);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> customizeCode(String customCode) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _api.customizeAffiliateCode(customCode);
      await loadDashboard();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<AffiliateWithdrawalItem?> submitWithdrawal({
    required int requestedAmountIdr,
    required String payoutChannel,
    required String bankOrWalletLabel,
    required String accountNumber,
    required String accountHolderName,
    String? userNotes,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final ticket = await _api.createWithdrawal(
        requestedAmountIdr: requestedAmountIdr,
        payoutChannel: payoutChannel,
        bankOrWalletLabel: bankOrWalletLabel,
        accountNumber: accountNumber,
        accountHolderName: accountHolderName,
        userNotes: userNotes,
      );
      await loadDashboard();
      state = state.copyWith(isSubmitting: false);
      return ticket;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<bool> cancelWithdrawal(String withdrawalId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _api.cancelWithdrawal(withdrawalId);
      await loadDashboard();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

class AdminPayoutQueueState {
  final bool isLoading;
  final bool isMutating;
  final String selectedStatus;
  final List<AdminWithdrawalItem> items;
  final String? errorMessage;

  const AdminPayoutQueueState({
    this.isLoading = true,
    this.isMutating = false,
    this.selectedStatus = 'PENDING_ADMIN_REVIEW',
    this.items = const [],
    this.errorMessage,
  });

  AdminPayoutQueueState copyWith({
    bool? isLoading,
    bool? isMutating,
    String? selectedStatus,
    List<AdminWithdrawalItem>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminPayoutQueueState(
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final adminPayoutQueueProvider =
    NotifierProvider<AdminPayoutQueueController, AdminPayoutQueueState>(
  AdminPayoutQueueController.new,
);

class AdminPayoutQueueController extends Notifier<AdminPayoutQueueState> {
  AffiliateApiService get _api => ref.read(affiliateApiServiceProvider);

  @override
  AdminPayoutQueueState build() => const AdminPayoutQueueState();

  Future<void> loadQueue({String? status}) async {
    final target = status ?? state.selectedStatus;
    state = state.copyWith(
      isLoading: true,
      selectedStatus: target,
      clearError: true,
    );
    try {
      final list = await _api.fetchAdminQueue(status: target);
      state = state.copyWith(isLoading: false, items: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> markProcessing(String withdrawalId) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      await _api.adminMarkProcessing(withdrawalId);
      await loadQueue();
      state = state.copyWith(isMutating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> approveWithProof({
    required String withdrawalId,
    required Uint8List imageBytes,
    required String filename,
    String? transferRefCode,
    String? adminNotes,
  }) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      await _api.adminApproveWithProofBytes(
        withdrawalId: withdrawalId,
        imageBytes: imageBytes,
        filename: filename,
        transferRefCode: transferRefCode,
        adminNotes: adminNotes,
      );
      await loadQueue();
      state = state.copyWith(isMutating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> rejectWithdrawal({
    required String withdrawalId,
    required String reason,
  }) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      await _api.adminRejectWithdrawal(
        withdrawalId: withdrawalId,
        rejectionReason: reason,
      );
      await loadQueue();
      state = state.copyWith(isMutating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}
