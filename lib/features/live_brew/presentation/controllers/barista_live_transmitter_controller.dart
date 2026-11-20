import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../data/ble_coffee_scale_service.dart';
import '../../data/live_brew_api_service.dart';
import '../../domain/live_brew_models.dart';

class IncomingCheerParticle {
  final int id;
  final String cheerKind;
  IncomingCheerParticle({required this.id, required this.cheerKind});
}

class BaristaLiveBroadcastState {
  final LiveBrewSnapshotModel? activeSession;
  final List<LiveBrewTableModel> tables;
  final String? selectedTableId;
  final bool isBroadcasting;
  final bool isCameraActive;
  final int cheersCount;
  final List<IncomingCheerParticle> recentCheers;
  final String? statusMessage;

  const BaristaLiveBroadcastState({
    this.activeSession,
    this.tables = const [],
    this.selectedTableId,
    this.isBroadcasting = false,
    this.isCameraActive = false,
    this.cheersCount = 0,
    this.recentCheers = const [],
    this.statusMessage,
  });

  BaristaLiveBroadcastState copyWith({
    LiveBrewSnapshotModel? activeSession,
    List<LiveBrewTableModel>? tables,
    String? selectedTableId,
    bool? isBroadcasting,
    bool? isCameraActive,
    int? cheersCount,
    List<IncomingCheerParticle>? recentCheers,
    String? statusMessage,
    bool clearSession = false,
  }) {
    return BaristaLiveBroadcastState(
      activeSession: clearSession ? null : (activeSession ?? this.activeSession),
      tables: tables ?? this.tables,
      selectedTableId: selectedTableId ?? this.selectedTableId,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      isCameraActive: isCameraActive ?? this.isCameraActive,
      cheersCount: cheersCount ?? this.cheersCount,
      recentCheers: recentCheers ?? this.recentCheers,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

final baristaLiveTransmitterProvider =
    NotifierProvider<BaristaLiveTransmitterController, BaristaLiveBroadcastState>(
  BaristaLiveTransmitterController.new,
);

class BaristaLiveTransmitterController extends Notifier<BaristaLiveBroadcastState> {
  final BleCoffeeScaleBridge _scaleBridge = BleCoffeeScaleBridge();
  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  CameraController? _cameraController;
  Timer? _cameraFrameTimer;
  int _cheerSeq = 0;

  @override
  BaristaLiveBroadcastState build() {
    ref.onDispose(() {
      _cleanupSocketsAndScale();
    });
    return const BaristaLiveBroadcastState();
  }

  Future<void> refreshTables() async {
    final tables = await ref.read(liveBrewApiProvider).listTables();
    state = state.copyWith(tables: tables);
  }

  Future<LiveBrewTableModel?> createStaticTable(String tableNumber) async {
    try {
      final tbl = await ref.read(liveBrewApiProvider).createTable(tableNumber);
      await refreshTables();
      state = state.copyWith(selectedTableId: tbl.id);
      return tbl;
    } catch (_) {
      return null;
    }
  }

  void selectTable(String? tableId) {
    state = state.copyWith(selectedTableId: tableId);
  }

  Future<LiveBrewSnapshotModel?> startLiveSession({
    required Map<String, dynamic> recipe,
    required double Function() weightSampler,
    double tempC = 91.0,
    String? tableId,
    String? customerName,
  }) async {
    final api = ref.read(liveBrewApiProvider);
    final chosenTable = tableId ?? state.selectedTableId;
    LiveBrewSnapshotModel snap;
    try {
      snap = await api.createSession(
        recipe: recipe,
        tableId: chosenTable,
        customerName: customerName,
      );
    } catch (_) {
      state = state.copyWith(
        isBroadcasting: false,
        statusMessage: 'Gagal terhubung ke server Live Brew. Pastikan login & koneksi aktif.',
      );
      return null;
    }

    state = state.copyWith(
      activeSession: snap,
      isBroadcasting: true,
      cheersCount: 0,
      statusMessage: 'Siaran Live Brew aktif!',
    );

    await _connectBaristaWs(snap.sessionId);
    _scaleBridge.start10HzStream(
      targetWaterMl: snap.targetWaterMl,
      totalDurationSec: snap.targetDurationSec,
      currentTempC: tempC,
      activeWeightFallback: weightSampler,
      onTick: (frame) {
        _sendWsFrame({
          'type': 'scale_telemetry_tick',
          'elapsed_ms': frame.elapsedMs,
          'weight_g': frame.weightG,
          'flow_rate_ml_s': frame.flowRateMlS,
          'temp_c': frame.tempC,
        });
      },
    );
    return snap;
  }

  Future<void> _connectBaristaWs(String sessionId) async {
    if (sessionId.startsWith('local-') || Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    try {
      final (wsBase, token) = await ref.read(liveBrewApiProvider).resolveWsBaseAndToken();
      if (token == null || token.isEmpty) return;
      final uri = Uri.parse('$wsBase/api/v1/livebrew/barista/ws/$sessionId?token=$token');
      _ws = WebSocketChannel.connect(uri);
      _wsSub = _ws!.stream.listen(
        (raw) {
          try {
            final data = jsonDecode(raw.toString()) as Map<String, dynamic>;
            if (data['event'] == 'customer_cheer') {
              final kind = data['cheer_kind']?.toString() ?? 'coffee';
              final total = (data['total_cheers'] as num?)?.toInt() ?? state.cheersCount + 1;
              HapticFeedback.selectionClick();
              final next = [
                ...state.recentCheers.take(8),
                IncomingCheerParticle(id: ++_cheerSeq, cheerKind: kind),
              ];
              state = state.copyWith(cheersCount: total, recentCheers: next);
            }
          } catch (_) {}
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  void pushStageTransition(LiveBrewStage stage, int stepIndex, double tempC) {
    if (!state.isBroadcasting) return;
    _sendWsFrame({
      'type': 'stage_transition',
      'stage': stage.apiValue,
      'step_index': stepIndex,
      'message': stage.labelId,
      'temp_c': tempC,
    });
  }

  Future<void> finishAndServe({
    required double finalWeightG,
    required int totalDurationSec,
    double accuracyScorePct = 98.4,
  }) async {
    if (!state.isBroadcasting) return;
    _sendWsFrame({
      'type': 'finish_and_serve',
      'final_weight_g': finalWeightG,
      'total_duration_sec': totalDurationSec,
      'accuracy_score_pct': accuracyScorePct,
    });
    await stopBroadcast();
  }

  Future<void> toggleOverheadCamera(bool enabled) async {
    final session = state.activeSession;
    if (session == null) return;
    if (!enabled) {
      _cameraFrameTimer?.cancel();
      _cameraFrameTimer = null;
      await _cameraController?.dispose();
      _cameraController = null;
      await ref.read(liveBrewApiProvider).teardownWhip(session.sessionId);
      _sendWsFrame({'type': 'video_stream_status', 'is_active': false, 'whep_url': null});
      state = state.copyWith(isCameraActive: false);
      return;
    }

    if (!kIsWeb && !Platform.environment.containsKey('FLUTTER_TEST')) {
      try {
        final cams = await availableCameras();
        if (cams.isNotEmpty) {
          final cam = CameraController(cams.first, ResolutionPreset.low, enableAudio: false);
          await cam.initialize();
          _cameraController = cam;
          _cameraFrameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
            if (_cameraController == null || !(_cameraController!.value.isInitialized)) return;
            if (_cameraController!.value.isTakingPicture) return;
            try {
              final xfile = await _cameraController!.takePicture();
              final bytes = await xfile.readAsBytes();
              if (bytes.length <= 120000) {
                _sendWsFrame({
                  'type': 'video_keyframe',
                  'jpeg_b64': base64Encode(bytes),
                  'ts_ms': DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
                });
              }
            } catch (_) {}
          });
        }
      } catch (_) {}
    }

    await ref.read(liveBrewApiProvider).publishWhipStatus(
          session.sessionId,
          'v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\ns=CoffeeLabsLive\r\n',
        );
    _sendWsFrame({
      'type': 'video_stream_status',
      'is_active': true,
      'whep_url': '/api/v1/livebrew/rtc/${session.sessionId}/whep',
    });
    state = state.copyWith(isCameraActive: true);
  }

  void _sendWsFrame(Map<String, dynamic> payload) {
    try {
      _ws?.sink.add(jsonEncode(payload));
    } catch (_) {}
  }

  Future<void> stopBroadcast() async {
    await toggleOverheadCamera(false);
    _cleanupSocketsAndScale();
    state = state.copyWith(isBroadcasting: false, statusMessage: 'Sesi siaran selesai.');
  }

  void _cleanupSocketsAndScale() {
    _scaleBridge.stop();
    _cameraFrameTimer?.cancel();
    _cameraController?.dispose();
    _wsSub?.cancel();
    _ws?.sink.close();
    _ws = null;
  }
}
