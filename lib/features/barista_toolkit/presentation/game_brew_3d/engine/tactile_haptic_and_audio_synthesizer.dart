import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'gyro_kettle_physics_engine.dart';

/// Synthesizer umpan balik haptik taktil berfrekuensi variabel mengikuti laju
/// air ketel (`ml/s`), gelembung blooming CO2, goyangan Rao Swirl, serta getaran
/// peringatan Bypass / Turbulensi.
class TactileHapticAndAudioSynthesizer {
  double _tickCooldownSec = 0.0;
  double _warningCooldownSec = 0.0;

  bool get _canFireHaptics {
    if (kIsWeb) return false;
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  void stepFeedback({
    required double dt,
    required KettleTelemetryState telemetry,
    required double averageCo2Remaining,
  }) {
    final clampedDt = dt.clamp(0.0, 0.05);
    _tickCooldownSec = (_tickCooldownSec - clampedDt).clamp(0.0, 1.0);
    _warningCooldownSec = (_warningCooldownSec - clampedDt).clamp(0.0, 2.0);

    if (!_canFireHaptics) return;

    // 1. Peringatan keras pada Filter Bypass atau Aliran Turbulen (> 6.8 ml/s)
    if ((telemetry.isBypassWarning || telemetry.flowRegime == KettleFlowRegime.turbulent) &&
        _warningCooldownSec <= 0.0) {
      _warningCooldownSec = 0.35;
      HapticFeedback.heavyImpact();
      return;
    }

    // 2. Pulsa sentrifugal saat goyangan Gentle Rao Swirl terdeteksi
    if (telemetry.swirlIntensity > 0.35 && _tickCooldownSec <= 0.0) {
      _tickCooldownSec = 0.14;
      HapticFeedback.mediumImpact();
      return;
    }

    // 3. Getaran mikro proporsional terhadap laju aliran Q(t) di zona Laminar
    if (telemetry.flowRateMlPerSec > 0.35 && _tickCooldownSec <= 0.0) {
      final ratio = (telemetry.flowRateMlPerSec / 6.8).clamp(0.1, 1.0);
      final isBlooming = averageCo2Remaining > 0.45 && telemetry.pouredTotalMl < 70.0;
      _tickCooldownSec = isBlooming ? 0.09 : (0.22 - 0.14 * ratio);

      if (isBlooming || telemetry.flowRateMlPerSec >= 4.5) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
  }
}
