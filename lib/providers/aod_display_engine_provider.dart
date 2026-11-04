import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AodDisplayState {
  final Offset pixelShiftOffset;
  final double currentBrightness;
  final bool isIdle;
  final bool isActive;

  const AodDisplayState({
    this.pixelShiftOffset = Offset.zero,
    this.currentBrightness = 0.90,
    this.isIdle = false,
    this.isActive = false,
  });

  AodDisplayState copyWith({
    Offset? pixelShiftOffset,
    double? currentBrightness,
    bool? isIdle,
    bool? isActive,
  }) {
    return AodDisplayState(
      pixelShiftOffset: pixelShiftOffset ?? this.pixelShiftOffset,
      currentBrightness: currentBrightness ?? this.currentBrightness,
      isIdle: isIdle ?? this.isIdle,
      isActive: isActive ?? this.isActive,
    );
  }
}

class AodDisplayEngineController extends Notifier<AodDisplayState> {
  Timer? _burnInTimer;
  Timer? _idleDimTimer;
  int _shiftStep = 0;

  static const List<Offset> _shiftOffsets = [
    Offset(0.0, 0.0),
    Offset(1.5, 0.5),
    Offset(-1.0, 1.5),
    Offset(2.0, -1.0),
    Offset(-1.5, -1.5),
    Offset(0.5, 2.0),
    Offset(-2.0, 0.0),
  ];

  @override
  AodDisplayState build() {
    ref.onDispose(() {
      _stopTimers();
      _restoreHardware();
    });
    return const AodDisplayState();
  }

  /// Aktifkan mode Kiosk Always-On Display hemat daya
  Future<void> activateEngine({
    double activeBrightness = 0.90,
    double idleBrightness = 0.35,
    bool enablePixelShift = true,
  }) async {
    state = state.copyWith(isActive: true, currentBrightness: activeBrightness);

    // 1. Kunci layar agar tidak sleep / lock otomatis
    try {
      await WakelockPlus.enable();
    } catch (_) {}

    // 2. Sembunyikan seluruh UI bar Android/iOS (Immersive Sticky)
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}

    // 3. Set kecerahan layar awal
    try {
      await ScreenBrightness().setApplicationScreenBrightness(activeBrightness);
    } catch (_) {}

    // 4. Jalankan Timer Anti Burn-in (setiap 180 detik / 3 menit)
    if (enablePixelShift) {
      _burnInTimer?.cancel();
      _burnInTimer = Timer.periodic(const Duration(seconds: 180), (_) {
        _shiftStep = (_shiftStep + 1) % _shiftOffsets.length;
        state = state.copyWith(pixelShiftOffset: _shiftOffsets[_shiftStep]);
      });
    }

    // 5. Jalankan Idle Timer untuk auto-dimming hemat daya
    _resetIdleTimer(idleBrightness);
  }

  /// Reset timer saat layar disentuh oleh pelanggan atau barista
  void onUserInteraction({
    double activeBrightness = 0.90,
    double idleBrightness = 0.35,
  }) {
    if (!state.isActive) return;

    if (state.isIdle) {
      // Pulihkan kecerahan layar ke level aktif
      try {
        ScreenBrightness().setApplicationScreenBrightness(activeBrightness);
      } catch (_) {}
      state = state.copyWith(isIdle: false, currentBrightness: activeBrightness);
    }

    _resetIdleTimer(idleBrightness);
  }

  void _resetIdleTimer(double idleBrightness) {
    _idleDimTimer?.cancel();
    // 45 detik tanpa interaksi -> turunkan kecerahan ke level idle hemat daya
    _idleDimTimer = Timer(const Duration(seconds: 45), () {
      if (!state.isActive) return;
      try {
        ScreenBrightness().setApplicationScreenBrightness(idleBrightness);
      } catch (_) {}
      state = state.copyWith(isIdle: true, currentBrightness: idleBrightness);
    });
  }

  /// Matikan AOD dan kembalikan hardware tablet ke kondisi normal
  Future<void> deactivateEngine() async {
    _stopTimers();
    await _restoreHardware();
    state = const AodDisplayState(isActive: false);
  }

  void _stopTimers() {
    _burnInTimer?.cancel();
    _idleDimTimer?.cancel();
  }

  Future<void> _restoreHardware() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (_) {}
    try {
      await ScreenBrightness().resetApplicationScreenBrightness();
    } catch (_) {}
  }
}

final aodDisplayEngineProvider = NotifierProvider<AodDisplayEngineController, AodDisplayState>(
  AodDisplayEngineController.new,
);
