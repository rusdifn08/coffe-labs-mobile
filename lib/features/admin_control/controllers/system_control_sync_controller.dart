import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../data/admin_control_api_service.dart';
import '../models/admin_control_models.dart';

class SystemControlState {
  final SystemControlSnapshot snapshot;
  final bool isWsConnected;
  final bool isSyncing;
  final bool isMutating;
  final String? activePushedFeatureKey;
  final String? errorMessage;

  const SystemControlState({
    required this.snapshot,
    this.isWsConnected = false,
    this.isSyncing = false,
    this.isMutating = false,
    this.activePushedFeatureKey,
    this.errorMessage,
  });

  SystemControlState copyWith({
    SystemControlSnapshot? snapshot,
    bool? isWsConnected,
    bool? isSyncing,
    bool? isMutating,
    String? activePushedFeatureKey,
    bool clearActiveFeatureKey = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SystemControlState(
      snapshot: snapshot ?? this.snapshot,
      isWsConnected: isWsConnected ?? this.isWsConnected,
      isSyncing: isSyncing ?? this.isSyncing,
      isMutating: isMutating ?? this.isMutating,
      activePushedFeatureKey: clearActiveFeatureKey
          ? null
          : (activePushedFeatureKey ?? this.activePushedFeatureKey),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final systemControlProvider =
    NotifierProvider<SystemControlSyncController, SystemControlState>(
  SystemControlSyncController.new,
);

/// Granular per-card selector: hanya membangun ulang 1 kartu Toolkit saat statusnya berubah (60–120fps).
final featureLockProvider =
    Provider.family<FeatureControlItem?, String>((ref, featureKey) {
  return ref.watch(
    systemControlProvider.select((s) => s.snapshot.featureForKey(featureKey)),
  );
});

/// Selector daftar harga paket Pro & Business yang selalu sinkron real-time.
final dynamicPlansProvider = Provider<List<DynamicPlanPricingItem>>((ref) {
  return ref.watch(systemControlProvider.select((s) => s.snapshot.plans));
});

/// Selector konfigurasi komisi afiliasi (10%/20%) & akses Pro/Free real-time.
final affiliateControlProvider = Provider<AffiliateControlConfig>((ref) {
  return ref.watch(
    systemControlProvider.select((s) => s.snapshot.affiliateConfig),
  );
});

final dynamicPlanPricingProvider =
    Provider.family<DynamicPlanPricingItem?, String>((ref, planCode) {
  final target = planCode.toUpperCase();
  return ref.watch(
    systemControlProvider.select((s) {
      for (final p in s.snapshot.plans) {
        if (p.planCode.toUpperCase() == target) return p;
      }
      return null;
    }),
  );
});

class SystemControlSyncController extends Notifier<SystemControlState> {
  WebSocketChannel? _ws;
  StreamSubscription<dynamic>? _wsSub;
  Timer? _reconnectTimer;
  Timer? _fallbackPollTimer;
  bool _initialized = false;
  bool _disposed = false;
  int _reconnectAttempt = 0;

  bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  AdminControlApiService get _api => ref.read(adminControlApiProvider);

  @override
  SystemControlState build() {
    ref.onDispose(() {
      _disposed = true;
      _teardownWs();
      _fallbackPollTimer?.cancel();
    });
    return SystemControlState(snapshot: SystemControlSnapshot.empty());
  }

  /// Menginisialisasi hidrasi cache lokal (0ms), REST snapshot, dan aliran WebSocket real-time.
  Future<void> initialize() async {
    if (_initialized || _isTestEnv) return;
    _initialized = true;

    final cached = await _api.loadCachedSnapshot();
    if (cached != null && !_disposed) {
      applyIncomingSnapshot(cached, persist: false);
    }

    unawaited(syncFromRest());
    _connectWs();
    _fallbackPollTimer?.cancel();
    _fallbackPollTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) => syncFromRest(),
    );
  }

  /// Menandai layar fitur yang sedang dibuka oleh pengguna (untuk real-time Active-Session Kickout).
  void setActiveFeatureScreen(String? featureKey) {
    final normalized = featureKey?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      state = state.copyWith(clearActiveFeatureKey: true);
    } else {
      state = state.copyWith(activePushedFeatureKey: normalized);
    }
  }

  /// Monotonic Version Gate (`incoming.configVersion > local` atau force refresh).
  void applyIncomingSnapshot(
    SystemControlSnapshot incoming, {
    bool force = false,
    bool persist = true,
  }) {
    final localVer = state.snapshot.configVersion;
    final hasFeatures = state.snapshot.features.isNotEmpty;
    if (!force && hasFeatures && incoming.configVersion < localVer) {
      return;
    }
    if (!force && hasFeatures && incoming.configVersion == localVer && localVer > 0) {
      // Hanya perbarui counter perangkat bila versinya identik
      if (incoming.connectedClients != state.snapshot.connectedClients) {
        state = state.copyWith(snapshot: incoming);
      }
      return;
    }
    state = state.copyWith(snapshot: incoming, clearError: true);
    if (persist && !_isTestEnv) {
      unawaited(_api.saveCachedSnapshot(incoming));
    }
  }

  Future<void> syncFromRest({bool force = false}) async {
    if (_disposed || _isTestEnv) return;
    state = state.copyWith(isSyncing: true);
    try {
      final since = force ? null : state.snapshot.configVersion;
      final fresh = await _api.fetchPublicSnapshot(sinceVersion: since);
      if (fresh != null && !_disposed) {
        applyIncomingSnapshot(fresh, force: force);
      }
    } catch (_) {
      // Silent resilient fallback: tetap gunakan snapshot cache lokal
    } finally {
      if (!_disposed) {
        state = state.copyWith(isSyncing: false);
      }
    }
  }

  Future<void> refreshAsAdmin() async {
    if (_disposed) return;
    state = state.copyWith(isSyncing: true, clearError: true);
    try {
      final fresh = await _api.fetchAdminSnapshot();
      if (!_disposed) {
        applyIncomingSnapshot(fresh, force: true);
      }
    } catch (e) {
      if (!_disposed) {
        state = state.copyWith(
          errorMessage: 'Gagal menyinkronkan panel admin: $e',
        );
      }
    } finally {
      if (!_disposed) {
        state = state.copyWith(isSyncing: false);
      }
    }
  }

  Future<bool> updateFeatureLock({
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
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final snap = await _api.updateFeatureLock(
        featureKey: featureKey,
        isLocked: isLocked,
        lockStatus: lockStatus,
        customBadgeLabel: customBadgeLabel,
        lockTitle: lockTitle,
        lockMessage: lockMessage,
        estimatedUnlockAt: estimatedUnlockAt,
        allowAdminBypass: allowAdminBypass,
        reasonNote: reasonNote,
      );
      applyIncomingSnapshot(snap, force: true);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    } finally {
      if (!_disposed) {
        state = state.copyWith(isMutating: false);
      }
    }
  }

  Future<bool> bulkLockAll({
    required bool isLocked,
    required FeatureLockStatus lockStatus,
    String lockTitle = '',
    String lockMessage = '',
    DateTime? estimatedUnlockAt,
  }) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final snap = await _api.bulkLockFeatures(
        isLocked: isLocked,
        lockStatus: lockStatus,
        lockTitle: lockTitle,
        lockMessage: lockMessage,
        estimatedUnlockAt: estimatedUnlockAt,
        allowAdminBypass: true,
      );
      applyIncomingSnapshot(snap, force: true);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    } finally {
      if (!_disposed) {
        state = state.copyWith(isMutating: false);
      }
    }
  }

  Future<bool> updatePlanPricing({
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
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final snap = await _api.updatePlanPricing(
        planCode: planCode,
        displayName: displayName,
        basePriceIdr: basePriceIdr,
        originalPriceIdr: originalPriceIdr,
        promoBadgeText: promoBadgeText,
        durationDays: durationDays,
        isActive: isActive,
        isHighlighted: isHighlighted,
        reasonNote: reasonNote,
      );
      applyIncomingSnapshot(snap, force: true);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    } finally {
      if (!_disposed) {
        state = state.copyWith(isMutating: false);
      }
    }
  }

  Future<bool> updateAffiliateConfig({
    required bool isProgramActive,
    required int affiliateCommissionPercent,
    required int buyerDiscountPercent,
    required bool allowFreeTierAffiliates,
    int? minWithdrawalIdr,
    String? reasonNote,
  }) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final snap = await _api.updateAffiliateConfig(
        isProgramActive: isProgramActive,
        affiliateCommissionPercent: affiliateCommissionPercent,
        buyerDiscountPercent: buyerDiscountPercent,
        allowFreeTierAffiliates: allowFreeTierAffiliates,
        minWithdrawalIdr: minWithdrawalIdr,
        reasonNote: reasonNote,
      );
      applyIncomingSnapshot(snap, force: true);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    } finally {
      if (!_disposed) {
        state = state.copyWith(isMutating: false);
      }
    }
  }

  void _connectWs() {
    if (_disposed || _isTestEnv) return;
    _teardownWs();
    try {
      final uri = _api.resolveControlWsUri();
      final channel = WebSocketChannel.connect(uri);
      _ws = channel;
      unawaited(
        channel.ready.catchError((_) {
          if (_ws == channel && !_disposed) {
            _scheduleReconnect();
          }
        }),
      );
      _wsSub = channel.stream.listen(
        _onWsMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
      );
      _reconnectAttempt = 0;
      state = state.copyWith(isWsConnected: true);
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onWsMessage(dynamic raw) {
    if (_disposed) return;
    try {
      final frame = jsonDecode(raw.toString()) as Map<String, dynamic>;
      final event = (frame['event'] ?? '').toString().toUpperCase();
      if (event == 'SNAPSHOT_SYNCED' && frame['snapshot'] is Map) {
        final snap = SystemControlSnapshot.fromJson(
          Map<String, dynamic>.from(frame['snapshot'] as Map),
        );
        applyIncomingSnapshot(snap);
      } else if (event == 'HEARTBEAT') {
        final ver = ((frame['config_version'] as num?) ?? 0).toInt();
        final clients = ((frame['connected_clients'] as num?) ?? 0).toInt();
        if (ver > state.snapshot.configVersion) {
          unawaited(syncFromRest(force: true));
        } else if (clients != state.snapshot.connectedClients) {
          state = state.copyWith(
            snapshot: SystemControlSnapshot(
              configVersion: state.snapshot.configVersion,
              globalMaintenanceMode: state.snapshot.globalMaintenanceMode,
              globalMaintenanceMessage: state.snapshot.globalMaintenanceMessage,
              connectedClients: clients,
              features: state.snapshot.features,
              plans: state.snapshot.plans,
              updatedAt: state.snapshot.updatedAt,
            ),
          );
        }
      }
    } catch (_) {}
  }

  void _scheduleReconnect() {
    if (_disposed || _isTestEnv) return;
    _teardownWs();
    state = state.copyWith(isWsConnected: false);
    _reconnectAttempt = (_reconnectAttempt + 1).clamp(1, 6);
    final delaySecs = (2 * _reconnectAttempt).clamp(2, 20);
    _reconnectTimer = Timer(Duration(seconds: delaySecs), _connectWs);
  }

  void _teardownWs() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _wsSub?.cancel();
    _wsSub = null;
    try {
      _ws?.sink.close();
    } catch (_) {}
    _ws = null;
  }
}
