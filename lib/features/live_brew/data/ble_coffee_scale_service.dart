import 'dart:async';

import '../../../services/smart_scale_service.dart';
import '../domain/live_brew_models.dart';

class ScaleSampleFrame {
  final int elapsedMs;
  final double weightG;
  final double flowRateMlS;
  final double tempC;
  final bool fromBleHardware;

  const ScaleSampleFrame({
    required this.elapsedMs,
    required this.weightG,
    required this.flowRateMlS,
    required this.tempC,
    required this.fromBleHardware,
  });
}

/// Jembatan Smart Scale Bluetooth (`flutter_blue_plus` via `SmartScaleService`) +
/// Filter EWMA Laju Tuang (alpha = 0.28) pada frekuensi 10Hz (setiap 100ms).
class BleCoffeeScaleBridge {
  final EwmaFlowFilter _ewmaFilter = EwmaFlowFilter();
  Timer? _ticker10Hz;
  int _elapsedMs = 0;

  void start10HzStream({
    required double targetWaterMl,
    required int totalDurationSec,
    required double currentTempC,
    required double Function() activeWeightFallback,
    required void Function(ScaleSampleFrame frame) onTick,
  }) {
    stop();
    _ewmaFilter.reset();
    _elapsedMs = 0;

    _ticker10Hz = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _elapsedMs += 100;
      final ble = SmartScaleService.instance;
      final hasBle = ble.isConnected && !ble.isSimulationMode;
      final weight = hasBle
          ? ble.currentWeight
          : (ble.isSimulationMode ? ble.currentWeight : activeWeightFallback());

      final smoothedFlow = _ewmaFilter.update(weight, _elapsedMs);
      onTick(
        ScaleSampleFrame(
          elapsedMs: _elapsedMs,
          weightG: double.parse(weight.toStringAsFixed(1)),
          flowRateMlS: smoothedFlow,
          tempC: currentTempC,
          fromBleHardware: hasBle,
        ),
      );
    });
  }

  void stop() {
    _ticker10Hz?.cancel();
    _ticker10Hz = null;
  }
}
