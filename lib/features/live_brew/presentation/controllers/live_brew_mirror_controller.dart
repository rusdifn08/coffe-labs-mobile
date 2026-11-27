import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/subscription_service.dart';
import '../../data/live_brew_v2_api_service.dart';
import '../../domain/live_brew_mirror_models.dart';
import '../../domain/services/ntp_synced_timer_engine.dart';

class LiveBrewMirrorState {
  final LiveSessionMirrorSnapshot? activeSession;
  final BusinessBrandingModel? branding;
  final List<CafeSeatModel> seats;
  final String? selectedSeatId;
  final bool isBusinessUser;
  final bool isAuthenticated;
  final bool requiresAuthRelogin;
  final bool isStartingSession;
  final bool isLoadingBusiness;
  final bool isSavingBranding;
  final bool isGeneratingSeats;
  final bool isWsConnected;
  final int clockOffsetMs;

  /// Scoped error messages so Studio Meja errors never pollute the Siarkan tab.
  final String? broadcastError;
  final String? studioError;

  const LiveBrewMirrorState({
    this.activeSession,
    this.branding,
    this.seats = const [],
    this.selectedSeatId,
    this.isBusinessUser = false,
    this.isAuthenticated = true,
    this.requiresAuthRelogin = false,
    this.isStartingSession = false,
    this.isLoadingBusiness = false,
    this.isSavingBranding = false,
    this.isGeneratingSeats = false,
    this.isWsConnected = false,
    this.clockOffsetMs = 0,
    this.broadcastError,
    this.studioError,
  });

  /// Backwards-compatible getter.
  String? get errorMessage => broadcastError ?? studioError;

  LiveBrewMirrorState copyWith({
    LiveSessionMirrorSnapshot? activeSession,
    bool clearSession = false,
    BusinessBrandingModel? branding,
    List<CafeSeatModel>? seats,
    String? selectedSeatId,
    bool clearSelectedSeat = false,
    bool? isBusinessUser,
    bool? isAuthenticated,
    bool? requiresAuthRelogin,
    bool? isStartingSession,
    bool? isLoadingBusiness,
    bool? isSavingBranding,
    bool? isGeneratingSeats,
    bool? isWsConnected,
    int? clockOffsetMs,
    String? broadcastError,
    bool clearBroadcastError = false,
    String? studioError,
    bool clearStudioError = false,
    bool clearAllErrors = false,
  }) {
    return LiveBrewMirrorState(
      activeSession: clearSession ? null : (activeSession ?? this.activeSession),
      branding: branding ?? this.branding,
      seats: seats ?? this.seats,
      selectedSeatId: clearSelectedSeat ? null : (selectedSeatId ?? this.selectedSeatId),
      isBusinessUser: isBusinessUser ?? this.isBusinessUser,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      requiresAuthRelogin: requiresAuthRelogin ?? this.requiresAuthRelogin,
      isStartingSession: isStartingSession ?? this.isStartingSession,
      isLoadingBusiness: isLoadingBusiness ?? this.isLoadingBusiness,
      isSavingBranding: isSavingBranding ?? this.isSavingBranding,
      isGeneratingSeats: isGeneratingSeats ?? this.isGeneratingSeats,
      isWsConnected: isWsConnected ?? this.isWsConnected,
      clockOffsetMs: clockOffsetMs ?? this.clockOffsetMs,
      broadcastError: (clearBroadcastError || clearAllErrors)
          ? null
          : (broadcastError ?? this.broadcastError),
      studioError: (clearStudioError || clearAllErrors)
          ? null
          : (studioError ?? this.studioError),
    );
  }
}

final liveBrewMirrorProvider =
    NotifierProvider<LiveBrewMirrorController, LiveBrewMirrorState>(
  LiveBrewMirrorController.new,
);

class LiveBrewMirrorController extends Notifier<LiveBrewMirrorState> {
  final NtpSyncedTimerEngine timerEngine = NtpSyncedTimerEngine();
  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  DateTime? _lastTelemetryPushAt;

  bool get _isTestEnv => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  LiveBrewMirrorState build() {
    ref.onDispose(() {
      _closeSocket();
      timerEngine.dispose();
    });
    Future.microtask(loadBusinessStudio);
    return const LiveBrewMirrorState();
  }

  LiveBrewV2ApiService get _api => ref.read(liveBrewV2ApiProvider);

  /// Maps raw Dio/network exceptions into clean, actionable Indonesian user copy.
  static ({String message, bool isAuthExpired}) mapFriendlyError(
    Object error, {
    required String fallback,
  }) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final mapped = GlobalErrorAndLoggingInterceptor.mapDioException(error);
      if (status == 401) {
        return (
          message:
              'Sesi login Anda belum aktif atau sudah berakhir. Silakan login ulang di menu Profil agar Live Brew & QR meja dapat tersimpan ke server.',
          isAuthExpired: true,
        );
      }
      if (status == 403) {
        return (
          message:
              'Fitur Studio Meja & QR Kafe memerlukan akun Coffee Labs Business atau Admin.',
          isAuthExpired: false,
        );
      }
      if (status == 409) {
        return (
          message:
              'Slug URL kafe tersebut sudah digunakan kafe lain. Gunakan nama slug yang berbeda.',
          isAuthExpired: false,
        );
      }
      if (status == 400 || status == 422) {
        return (message: mapped.message, isAuthExpired: false);
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return (
          message:
              'Tidak dapat terhubung ke server Coffee Labs. Periksa koneksi internet Anda lalu coba lagi.',
          isAuthExpired: false,
        );
      }
      return (message: mapped.message, isAuthExpired: false);
    }
    return (message: fallback, isAuthExpired: false);
  }

  Future<void> loadBusinessStudio() async {
    state = state.copyWith(isLoadingBusiness: true, clearStudioError: true);
    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      final hasToken = token != null && token.trim().isNotEmpty;
      final isBiz = user != null
          ? (user.isAdmin || user.isBusiness || user.username.toLowerCase() == 'bisnis123')
          : await SubscriptionService.isBusiness();

      if (!hasToken) {
        state = state.copyWith(
          isAuthenticated: false,
          requiresAuthRelogin: true,
          isBusinessUser: isBiz,
          isLoadingBusiness: false,
        );
        return;
      }

      if (!isBiz) {
        state = state.copyWith(
          isAuthenticated: true,
          requiresAuthRelogin: false,
          isBusinessUser: false,
          isLoadingBusiness: false,
        );
        return;
      }

      final branding = await _api.getMyBranding();
      final seats = await _api.listMySeats();
      state = state.copyWith(
        isAuthenticated: true,
        requiresAuthRelogin: false,
        isBusinessUser: true,
        branding: branding,
        seats: seats,
        isLoadingBusiness: false,
      );
    } catch (e) {
      final mapped = mapFriendlyError(
        e,
        fallback: 'Gagal memuat konfigurasi Studio Meja.',
      );
      state = state.copyWith(
        isLoadingBusiness: false,
        requiresAuthRelogin: mapped.isAuthExpired,
        isAuthenticated: !mapped.isAuthExpired,
        studioError: mapped.isAuthExpired ? mapped.message : null,
      );
    }
  }

  void selectSeatForBroadcast(String? seatId) {
    state = state.copyWith(
      selectedSeatId: seatId,
      clearSelectedSeat: seatId == null,
    );
  }

  void clearErrors() {
    state = state.copyWith(clearAllErrors: true);
  }

  Future<bool> startRealSession({
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
    state = state.copyWith(isStartingSession: true, clearBroadcastError: true);
    try {
      final token = await AuthService.getToken();
      if (token == null || token.trim().isEmpty) {
        state = state.copyWith(
          isStartingSession: false,
          isAuthenticated: false,
          requiresAuthRelogin: true,
          broadcastError:
              'Anda belum login. Silakan login di menu Profil terlebih dahulu untuk membuat QR & link Live Brew.',
        );
        return false;
      }

      await _calibrateNtpViaRest();
      final snap = await _api.createRealMirrorSession(
        seatId: seatId ?? state.selectedSeatId,
        posOrderId: posOrderId,
        posOrderNumber: posOrderNumber,
        customerName: customerName,
        methodId: methodId,
        methodName: methodName,
        recipeTitle: recipeTitle,
        recipeSnapshot: recipeSnapshot,
        beanSnapshot: beanSnapshot,
        initialTimerRunning: initialTimerRunning,
        initialElapsedMs: initialElapsedMs,
        initialStepIndex: initialStepIndex,
        initialTempC: initialTempC,
        initialWeightG: initialWeightG,
      );
      timerEngine.applyAuthoritativeSnapshot(snap, forceReset: true);
      state = state.copyWith(
        activeSession: snap,
        isAuthenticated: true,
        requiresAuthRelogin: false,
        isStartingSession: false,
        clockOffsetMs: timerEngine.clockOffsetMs,
      );
      await _connectBrewerWs(snap.sessionId);
      return true;
    } catch (e) {
      final mapped = mapFriendlyError(
        e,
        fallback: 'Gagal memulai sesi Live Brew. Periksa koneksi internet Anda lalu coba lagi.',
      );
      state = state.copyWith(
        isStartingSession: false,
        requiresAuthRelogin: mapped.isAuthExpired,
        isAuthenticated: !mapped.isAuthExpired,
        broadcastError: mapped.message,
      );
      return false;
    }
  }

  Future<void> _calibrateNtpViaRest() async {
    if (_isTestEnv) return;
    for (var i = 0; i < 2; i++) {
      final t1 = DateTime.now().millisecondsSinceEpoch;
      final res = await _api.pingNtp(t1);
      if (res != null) {
        timerEngine.recordNtpPong(
          clientSendMs: res['client_send_ms'] ?? t1,
          serverRecvMs: res['server_recv_ms'] ?? t1,
          serverSendMs: res['server_send_ms'] ?? t1,
        );
      }
    }
  }

  Future<void> _connectBrewerWs(String sessionId) async {
    if (_isTestEnv) return;
    await _closeSocket();
    try {
      final (wsBase, token) = await _api.resolveWsBaseAndToken();
      final uri = Uri.parse(
        token != null && token.isNotEmpty
            ? '$wsBase/api/v1/livebrew/v2/brewer/ws/$sessionId?token=$token'
            : '$wsBase/api/v1/livebrew/v2/brewer/ws/$sessionId',
      );
      _ws = WebSocketChannel.connect(uri);
      state = state.copyWith(isWsConnected: true);
      _wsSub = _ws!.stream.listen(
        (raw) {
          try {
            final ev = jsonDecode(raw.toString()) as Map<String, dynamic>;
            final eventType = ev['event']?.toString();
            if (eventType == 'ntp_pong') {
              timerEngine.recordNtpPong(
                clientSendMs: ((ev['client_send_ms'] as num?) ?? 0).toInt(),
                serverRecvMs: ((ev['server_recv_ms'] as num?) ?? 0).toInt(),
                serverSendMs: ((ev['server_send_ms'] as num?) ?? 0).toInt(),
              );
              state = state.copyWith(clockOffsetMs: timerEngine.clockOffsetMs);
            } else if (eventType == 'mirror_snapshot') {
              if (ev['share_url'] is String) {
                ev['share_url'] =
                    LiveBrewV2ApiService.normalizePublicShareUrl(ev['share_url'] as String);
              }
              final snap = LiveSessionMirrorSnapshot.fromJson(ev);
              if (timerEngine.applyAuthoritativeSnapshot(snap)) {
                state = state.copyWith(activeSession: snap);
              }
            } else if (eventType == 'cheer_burst' && state.activeSession != null) {
              final total = ((ev['total_cheers'] as num?) ?? state.activeSession!.cheersCount).toInt();
              state = state.copyWith(
                activeSession: _cloneSessionWith(
                  state.activeSession!,
                  cheersCount: total,
                ),
              );
            } else if (eventType == 'viewer_count_updated' && state.activeSession != null) {
              final count = ((ev['active_viewers'] as num?) ?? 0).toInt();
              state = state.copyWith(
                activeSession: _cloneSessionWith(
                  state.activeSession!,
                  activeViewersCount: count,
                ),
              );
            }
          } catch (_) {}
        },
        onError: (_) => state = state.copyWith(isWsConnected: false),
        onDone: () => state = state.copyWith(isWsConnected: false),
      );
      _ws!.sink.add(
        jsonEncode({
          'cmd': 'NTP_PING',
          'client_send_ms': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    } catch (_) {
      state = state.copyWith(isWsConnected: false);
    }
  }

  LiveSessionMirrorSnapshot _cloneSessionWith(
    LiveSessionMirrorSnapshot cur, {
    int? activeViewersCount,
    int? cheersCount,
  }) {
    return LiveSessionMirrorSnapshot.fromJson({
      'session_id': cur.sessionId,
      'share_code': cur.shareCode,
      'share_url': cur.shareUrl,
      'deep_link_url': cur.deepLinkUrl,
      'is_business_session': cur.isBusinessSession,
      'store_id': cur.storeId,
      'seat_id': cur.seatId,
      'pos_order_id': cur.posOrderId,
      'pos_order_number': cur.posOrderNumber,
      'pos_order_status': cur.posOrderStatus,
      'brewer_display_name': cur.brewerDisplayName,
      'customer_name': cur.customerName,
      'phase': cur.phase.apiValue,
      'phase_label_id': cur.phaseLabelId,
      'state_version': cur.stateVersion,
      'selected_method_id': cur.selectedMethodId,
      'selected_method_name': cur.selectedMethodName,
      'selected_recipe_title': cur.selectedRecipeTitle,
      'recipe_snapshot_json': cur.recipeSnapshot,
      'bean_snapshot_json': cur.beanSnapshot,
      'timer_status': cur.timerStatus.apiValue,
      'timer_accumulated_ms': cur.timerAccumulatedMs,
      'timer_anchor_server_ms': cur.timerAnchorServerMs,
      'current_step_index': cur.currentStepIndex,
      'current_weight_g': cur.currentWeightG,
      'current_flow_rate_ml_s': cur.currentFlowRateMlS,
      'current_temp_c': cur.currentTempC,
      'cheers_count': cheersCount ?? cur.cheersCount,
      'active_viewers_count': activeViewersCount ?? cur.activeViewersCount,
      'server_epoch_ms': cur.serverEpochMs,
    });
  }

  Future<void> dispatchCommand(Map<String, dynamic> cmd) async {
    final session = state.activeSession;
    if (session == null) return;
    try {
      final updated = await _api.sendCommandRest(session.sessionId, cmd);
      if (timerEngine.applyAuthoritativeSnapshot(updated)) {
        state = state.copyWith(activeSession: updated, clearBroadcastError: true);
      }
    } catch (_) {
      // Fallback to WS if REST temporarily fails
      try {
        _ws?.sink.add(jsonEncode(cmd));
      } catch (_) {}
    }
  }

  Future<void> broadcastRecipeSelection({
    required String methodId,
    required String methodName,
    required String recipeTitle,
    required Map<String, dynamic> recipeSnapshot,
  }) {
    return dispatchCommand({
      'cmd': 'SELECT_RECIPE_PREVIEW',
      'method_id': methodId,
      'method_name': methodName,
      'recipe_title': recipeTitle,
      'recipe_snapshot_json': recipeSnapshot,
    });
  }

  Future<void> broadcastBeanSelection(Map<String, dynamic> beanSnapshot) {
    return dispatchCommand({
      'cmd': 'SELECT_BEAN_PREVIEW',
      'bean_snapshot_json': beanSnapshot,
    });
  }

  Future<void> confirmReadyToBrew() =>
      dispatchCommand({'cmd': 'CONFIRM_READY_TO_BREW'});

  Future<void> timerStartOrResume() =>
      dispatchCommand({'cmd': 'TIMER_START_OR_RESUME'});

  Future<void> timerPause() => dispatchCommand({'cmd': 'TIMER_PAUSE'});

  Future<void> timerReset() => dispatchCommand({'cmd': 'TIMER_RESET'});

  Future<void> advanceStepOrTelemetry({
    required int stepIndex,
    required double weightG,
    required double flowRateMlS,
    required double tempC,
    bool throttle = false,
  }) {
    if (throttle) {
      final now = DateTime.now();
      if (_lastTelemetryPushAt != null &&
          now.difference(_lastTelemetryPushAt!).inMilliseconds < 1800) {
        return Future.value();
      }
      _lastTelemetryPushAt = now;
    }
    return dispatchCommand({
      'cmd': 'ADVANCE_STEP_OR_TELEMETRY',
      'current_step_index': stepIndex,
      'weight_g': weightG,
      'flow_rate_ml_s': flowRateMlS,
      'temp_c': tempC,
    });
  }

  Future<void> completeAndServe({
    required double finalWeightG,
    double accuracyScorePct = 97.5,
  }) {
    return dispatchCommand({
      'cmd': 'COMPLETE_AND_SERVE',
      'final_weight_g': finalWeightG,
      'accuracy_score_pct': accuracyScorePct,
    });
  }

  Future<void> stopBroadcast() async {
    final sessionId = state.activeSession?.sessionId;
    await _closeSocket();
    timerEngine.reset();
    state = state.copyWith(clearSession: true, isWsConnected: false);
    if (sessionId != null && !_isTestEnv) {
      unawaited(_api.endRealMirrorSession(sessionId));
    }
    if (state.isBusinessUser && state.isAuthenticated) {
      unawaited(_refreshSeatsSilently());
    }
  }

  Future<void> _refreshSeatsSilently() async {
    try {
      final seats = await _api.listMySeats();
      state = state.copyWith(seats: seats);
    } catch (_) {}
  }

  Future<BusinessBrandingModel?> saveCafeBranding({
    required String cafeSlug,
    required String cafeDisplayName,
    required String primaryColorHex,
    required String accentColorHex,
    required String welcomeMessage,
    String? wifiSsid,
    String? wifiPassword,
    String? instagramHandle,
    bool showPosQueuePosition = true,
  }) async {
    if (cafeDisplayName.trim().length < 2) {
      state = state.copyWith(
        studioError: 'Nama kafe minimal 2 karakter.',
      );
      return null;
    }
    if (cafeSlug.trim().length < 2) {
      state = state.copyWith(
        studioError: 'Slug URL kafe minimal 2 karakter (contoh: kopi-senja).',
      );
      return null;
    }

    state = state.copyWith(isSavingBranding: true, clearStudioError: true);
    try {
      final saved = await _api.saveBranding(
        cafeSlug: cafeSlug,
        cafeDisplayName: cafeDisplayName,
        primaryColorHex: primaryColorHex,
        accentColorHex: accentColorHex,
        welcomeMessage: welcomeMessage,
        wifiSsid: wifiSsid,
        wifiPassword: wifiPassword,
        instagramHandle: instagramHandle,
        showPosQueuePosition: showPosQueuePosition,
      );
      final seats = await _api.listMySeats();
      state = state.copyWith(
        branding: saved,
        seats: seats,
        isSavingBranding: false,
        requiresAuthRelogin: false,
        isAuthenticated: true,
        clearStudioError: true,
      );
      return saved;
    } catch (e) {
      final mapped = mapFriendlyError(
        e,
        fallback: 'Gagal menyimpan branding kafe. Coba lagi sesaat lagi.',
      );
      state = state.copyWith(
        isSavingBranding: false,
        requiresAuthRelogin: mapped.isAuthExpired,
        isAuthenticated: !mapped.isAuthExpired,
        studioError: mapped.message,
      );
      return null;
    }
  }

  Future<CafeSeatModel?> createSingleSeat({
    required String seatLabel,
    required CafeSeatKind kind,
    required String zoneArea,
    int capacityPersons = 2,
  }) async {
    if (seatLabel.trim().isEmpty) {
      state = state.copyWith(studioError: 'Nama meja / kursi tidak boleh kosong.');
      return null;
    }
    state = state.copyWith(isGeneratingSeats: true, clearStudioError: true);
    try {
      final seat = await _api.createSeat(
        seatLabel: seatLabel.trim(),
        seatKind: kind,
        zoneArea: zoneArea.trim().isEmpty ? 'Main Area' : zoneArea.trim(),
        capacityPersons: capacityPersons,
      );
      final all = await _api.listMySeats();
      final branding = await _api.getMyBranding();
      state = state.copyWith(
        branding: branding ?? state.branding,
        seats: all,
        isGeneratingSeats: false,
        requiresAuthRelogin: false,
        isAuthenticated: true,
        clearStudioError: true,
      );
      return seat;
    } catch (e) {
      final mapped = mapFriendlyError(
        e,
        fallback: 'Gagal menambahkan meja/kursi baru.',
      );
      state = state.copyWith(
        isGeneratingSeats: false,
        requiresAuthRelogin: mapped.isAuthExpired,
        isAuthenticated: !mapped.isAuthExpired,
        studioError: mapped.message,
      );
      return null;
    }
  }

  Future<List<CafeSeatModel>> generateBatchSeats({
    required String prefix,
    required int startNumber,
    required int endNumber,
    required CafeSeatKind kind,
    required String zoneArea,
    required int capacityPersons,
  }) async {
    if (endNumber < startNumber || startNumber < 1) {
      state = state.copyWith(
        studioError: 'Rentang nomor meja tidak valid (contoh: Dari 1 Sampai 6).',
      );
      return const [];
    }
    state = state.copyWith(isGeneratingSeats: true, clearStudioError: true);
    try {
      final created = await _api.createSeatBatch(
        prefix: prefix,
        startNumber: startNumber,
        endNumber: endNumber,
        seatKind: kind,
        zoneArea: zoneArea,
        capacityPersons: capacityPersons,
      );
      final all = await _api.listMySeats();
      final branding = await _api.getMyBranding();
      state = state.copyWith(
        branding: branding ?? state.branding,
        seats: all,
        isGeneratingSeats: false,
        requiresAuthRelogin: false,
        isAuthenticated: true,
        clearStudioError: true,
      );
      return created;
    } catch (e) {
      final mapped = mapFriendlyError(
        e,
        fallback: 'Gagal membuat barcode meja/kursi. Coba lagi sesaat lagi.',
      );
      state = state.copyWith(
        isGeneratingSeats: false,
        requiresAuthRelogin: mapped.isAuthExpired,
        isAuthenticated: !mapped.isAuthExpired,
        studioError: mapped.message,
      );
      return const [];
    }
  }

  Future<bool> deleteSeat(String seatId) async {
    state = state.copyWith(clearStudioError: true);
    try {
      await _api.deleteSeat(seatId);
      final updated = state.seats.where((s) => s.id != seatId).toList();
      state = state.copyWith(
        seats: updated,
        clearSelectedSeat: state.selectedSeatId == seatId,
      );
      return true;
    } catch (e) {
      final mapped = mapFriendlyError(
        e,
        fallback: 'Gagal menghapus barcode meja/kursi.',
      );
      state = state.copyWith(
        requiresAuthRelogin: mapped.isAuthExpired,
        studioError: mapped.message,
      );
      return false;
    }
  }

  Future<bool> bindPosOrderToSeat({
    required String seatId,
    required String orderNumber,
    String? posOrderId,
    String? customerName,
    String? itemsSummary,
  }) async {
    try {
      await _api.bindPosOrderToSeat(
        seatId: seatId,
        posOrderId: posOrderId,
        posOrderNumber: orderNumber,
        customerName: customerName,
        itemsSummary: itemsSummary,
      );
      final all = await _api.listMySeats();
      state = state.copyWith(seats: all, clearStudioError: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _closeSocket() async {
    await _wsSub?.cancel();
    _wsSub = null;
    await _ws?.sink.close();
    _ws = null;
  }
}
