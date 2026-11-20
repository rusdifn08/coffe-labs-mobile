import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import '../live_brew_mirror_models.dart';

class NtpSample {
  final int rttMs;
  final int clockOffsetMs;

  const NtpSample({required this.rttMs, required this.clockOffsetMs});
}

/// Mesin Sinkronisasi Timer 1:1 Bebas Drift (< 25 ms cross-device) menggunakan:
/// 1. Cristian's Algorithm Clock Offset Calibration:
///    offset = ((t2 - t1) + (t3 - t4)) / 2  (mengambil sampel RTT terendah)
/// 2. Server-Anchored Monotonic Timer:
///    T_display = accumulated_ms + max(0, (local_now + offset) - anchor_server_ms)
/// 3. Strict Causal Ordering via `stateVersion` monotonik.
class NtpSyncedTimerEngine {
  final ValueNotifier<int> elapsedMsNotifier = ValueNotifier<int>(0);
  final List<NtpSample> _samples = [];

  Timer? _renderTicker;
  int _clockOffsetMs = 0;
  int _lastStateVersion = 0;
  LiveTimerStatus _timerStatus = LiveTimerStatus.idle;
  int _accumulatedMs = 0;
  int? _anchorServerMs;

  int get clockOffsetMs => _clockOffsetMs;
  int get lastStateVersion => _lastStateVersion;
  LiveTimerStatus get timerStatus => _timerStatus;

  /// Merekam balasan NTP (`t1`, `t2`, `t3`, `t4`) dan mengunci offset jam dari sampel RTT terkecil.
  void recordNtpPong({
    required int clientSendMs,
    required int serverRecvMs,
    required int serverSendMs,
    int? clientRecvMs,
  }) {
    final t4 = clientRecvMs ?? DateTime.now().millisecondsSinceEpoch;
    final rtt = math.max(0, (t4 - clientSendMs) - (serverSendMs - serverRecvMs));
    final offset = (((serverRecvMs - clientSendMs) + (serverSendMs - t4)) / 2).round();
    _samples.add(NtpSample(rttMs: rtt, clockOffsetMs: offset));
    if (_samples.length > 5) {
      _samples.removeAt(0);
    }
    _samples.sort((a, b) => a.rttMs.compareTo(b.rttMs));
    _clockOffsetMs = _samples.first.clockOffsetMs;
    _recomputeDisplayMs();
  }

  /// Menerapkan snapshot otoritatif dari server hanya jika `stateVersion` lebih baru (causal ordering).
  bool applyAuthoritativeSnapshot(LiveSessionMirrorSnapshot snap, {bool forceReset = false}) {
    if (!forceReset && snap.stateVersion <= _lastStateVersion) {
      return false;
    }
    _lastStateVersion = snap.stateVersion;
    _timerStatus = snap.timerStatus;
    _accumulatedMs = snap.timerAccumulatedMs;
    _anchorServerMs = snap.timerAnchorServerMs;

    _recomputeDisplayMs();
    if (_timerStatus == LiveTimerStatus.running) {
      _ensureRenderTicker();
    } else {
      _stopRenderTicker();
    }
    return true;
  }

  /// Menghitung milidetik seduh tepat pada `localNowMs` tertentu (deterministik & dapat diuji unit).
  int computeDisplayMsAt(int localNowMs) {
    if (_timerStatus == LiveTimerStatus.running && _anchorServerMs != null) {
      final estimatedServerNow = localNowMs + _clockOffsetMs;
      final delta = math.max(0, estimatedServerNow - _anchorServerMs!);
      return _accumulatedMs + delta;
    }
    return _accumulatedMs;
  }

  void _recomputeDisplayMs() {
    elapsedMsNotifier.value = computeDisplayMsAt(DateTime.now().millisecondsSinceEpoch);
  }

  void _ensureRenderTicker() {
    if (_renderTicker != null && _renderTicker!.isActive) return;
    _renderTicker = Timer.periodic(
      const Duration(milliseconds: 33),
      (_) => _recomputeDisplayMs(),
    );
  }

  void _stopRenderTicker() {
    _renderTicker?.cancel();
    _renderTicker = null;
  }

  void reset() {
    _stopRenderTicker();
    _lastStateVersion = 0;
    _timerStatus = LiveTimerStatus.idle;
    _accumulatedMs = 0;
    _anchorServerMs = null;
    elapsedMsNotifier.value = 0;
  }

  void dispose() {
    _stopRenderTicker();
    elapsedMsNotifier.dispose();
  }

  static String formatMmSs(int totalMs) {
    final secs = math.max(0, totalMs ~/ 1000);
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String formatTenths(int totalMs) {
    final tenths = (math.max(0, totalMs) % 1000) ~/ 100;
    return '.$tenths';
  }
}
