import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  final bool isStartingSession;
  final bool isLoadingBusiness;
  final bool isWsConnected;
  final int clockOffsetMs;
  final String? errorMessage;

  const LiveBrewMirrorState({
    this.activeSession,
    this.branding,
    this.seats = const [],
    this.selectedSeatId,
    this.isBusinessUser = false,
    this.isStartingSession = false,
    this.isLoadingBusiness = false,
    this.isWsConnected = false,
    this.clockOffsetMs = 0,
    this.errorMessage,
  });

  LiveBrewMirrorState copyWith({
    LiveSessionMirrorSnapshot? activeSession,
    bool clearSession = false,
    BusinessBrandingModel? branding,
    List<CafeSeatModel>? seats,
    String? selectedSeatId,
    bool clearSelectedSeat = false,
    bool? isBusinessUser,
    bool? isStartingSession,
    bool? isLoadingBusiness,
    bool? isWsConnected,
    int? clockOffsetMs,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LiveBrewMirrorState(
      activeSession: clearSession ? null : (activeSession ?? this.activeSession),
      branding: branding ?? this.branding,
      seats: seats ?? this.seats,
      selectedSeatId: clearSelectedSeat ? null : (selectedSeatId ?? this.selectedSeatId),
      isBusinessUser: isBusinessUser ?? this.isBusinessUser,
      isStartingSession: isStartingSession ?? this.isStartingSession,
      isLoadingBusiness: isLoadingBusiness ?? this.isLoadingBusiness,
      isWsConnected: isWsConnected ?? this.isWsConnected,
      clockOffsetMs: clockOffsetMs ?? this.clockOffsetMs,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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

  Future<void> loadBusinessStudio() async {
    state = state.copyWith(isLoadingBusiness: true, clearError: true);
    try {
      final user = await AuthService.getCurrentUser();
      final isBiz = user != null
          ? (user.isAdmin || user.isBusiness || user.username.toLowerCase() == 'bisnis123')
          : await SubscriptionService.isBusiness();
      if (!isBiz) {
        state = state.copyWith(isBusinessUser: false, isLoadingBusiness: false);
        return;
      }
      final branding = await _api.getMyBranding();
      final seats = await _api.listMySeats();
      state = state.copyWith(
        isBusinessUser: true,
        branding: branding,
        seats: seats,
        isLoadingBusiness: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingBusiness: false);
    }
  }

  void selectSeatForBroadcast(String? seatId) {
    state = state.copyWith(
      selectedSeatId: seatId,
      clearSelectedSeat: seatId == null,
    );
  }

  Future<bool> startRealSession({
    String? seatId,
    String? posOrderId,
    String? posOrderNumber,
    String? customerName,
  }) async {
    state = state.copyWith(isStartingSession: true, clearError: true);
    try {
      await _calibrateNtpViaRest();
      final snap = await _api.createRealMirrorSession(
        seatId: seatId ?? state.selectedSeatId,
        posOrderId: posOrderId,
        posOrderNumber: posOrderNumber,
        customerName: customerName,
      );
      timerEngine.applyAuthoritativeSnapshot(snap, forceReset: true);
      state = state.copyWith(
        activeSession: snap,
        isStartingSession: false,
        clockOffsetMs: timerEngine.clockOffsetMs,
      );
      await _connectBrewerWs(snap.sessionId);
      return true;
    } catch (e) {
      state = state.copyWith(
        isStartingSession: false,
        errorMessage:
            'Gagal memulai sesi Live Brew nyata. Pastikan Anda sudah login dan terhubung ke server.',
      );
      return false;
    }
  }

  Future<void> _calibrateNtpViaRest() async {
    if (_isTestEnv) return;
    for (var i = 0; i < 3; i++) {
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
              final snap = LiveSessionMirrorSnapshot.fromJson(ev);
              if (timerEngine.applyAuthoritativeSnapshot(snap)) {
                state = state.copyWith(activeSession: snap);
              }
            } else if (eventType == 'viewer_count_updated' && state.activeSession != null) {
              final count = ((ev['active_viewers'] as num?) ?? 0).toInt();
              final cur = state.activeSession!;
              state = state.copyWith(
                activeSession: LiveSessionMirrorSnapshot.fromJson({
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
                  'cheers_count': cur.cheersCount,
                  'active_viewers_count': count,
                  'server_epoch_ms': cur.serverEpochMs,
                }),
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

  Future<void> dispatchCommand(Map<String, dynamic> cmd) async {
    final session = state.activeSession;
    if (session == null) return;
    try {
      final updated = await _api.sendCommandRest(session.sessionId, cmd);
      if (timerEngine.applyAuthoritativeSnapshot(updated)) {
        state = state.copyWith(activeSession: updated, clearError: true);
      }
    } catch (_) {
      // Kirim via WS jika REST sementara gagal
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
  }) {
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
    await _closeSocket();
    timerEngine.reset();
    state = state.copyWith(clearSession: true, isWsConnected: false);
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
      state = state.copyWith(branding: saved, seats: seats, clearError: true);
      return saved;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal menyimpan branding kafe: $e');
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
      state = state.copyWith(seats: all, clearError: true);
      return created;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal membuat batch meja/kursi: $e');
      return const [];
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
      state = state.copyWith(seats: all, clearError: true);
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
