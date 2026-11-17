import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart';

enum KettleFlowRegime { idle, laminar, turbulent }

class TelemetryCurvePoint {
  final double tSec;
  final double flowMlS;
  final double tempC;
  final double pitchDeg;

  const TelemetryCurvePoint({
    required this.tSec,
    required this.flowMlS,
    required this.tempC,
    required this.pitchDeg,
  });

  Map<String, dynamic> toJson() => {
        't_sec': double.parse(tSec.toStringAsFixed(2)),
        'flow_ml_s': double.parse(flowMlS.toStringAsFixed(2)),
        'temp_c': double.parse(tempC.toStringAsFixed(1)),
        'pitch_deg': double.parse(pitchDeg.toStringAsFixed(1)),
      };
}

class KettleTelemetryState {
  final double pitchDeg;
  final double rollDeg;
  final double critSpoutAngleDeg;
  final double flowRateMlPerSec;
  final double remainingKettleMl;
  final double initialKettleMl;
  final double pouredTotalMl;
  final double waterTempCelsius;
  final double swirlIntensity;
  final bool isLaminarFlow;
  final bool isBypassWarning;
  final bool isGyroHardwareActive;
  final KettleFlowRegime flowRegime;
  final Vector2 streamImpactNormalized;
  final Quaternion relativeOrientation;

  const KettleTelemetryState({
    required this.pitchDeg,
    required this.rollDeg,
    required this.critSpoutAngleDeg,
    required this.flowRateMlPerSec,
    required this.remainingKettleMl,
    required this.initialKettleMl,
    required this.pouredTotalMl,
    required this.waterTempCelsius,
    required this.swirlIntensity,
    required this.isLaminarFlow,
    required this.isBypassWarning,
    required this.isGyroHardwareActive,
    required this.flowRegime,
    required this.streamImpactNormalized,
    required this.relativeOrientation,
  });
}

/// Mesin fusi sensor 6-DoF Quaternion (200 Hz Gyroscope + Accelerometer)
/// dengan Adaptive Motion Rejection, Ergonomic Zero-Tare, Non-Linear
/// Volume-Dependent Torricelli Gooseneck Outflow, dan Deteksi Gentle Rao Swirl.
class GyroKettlePhysicsEngine {
  Quaternion _qCurrent = Quaternion.identity();
  Quaternion _qTareInverse = Quaternion.identity();
  bool _hasCalibratedTare = false;

  Vector3 _lastAccel = Vector3(0.0, 9.80665, 0.0);
  Vector3 _prevLinearAccel = Vector3.zero();
  DateTime? _lastGyroTimestamp;

  double _initialKettleWaterMl = 350.0;
  double _remainingKettleMl = 350.0;
  double _pouredTotalMl = 0.0;
  double _currentFlowRateMlSec = 0.0;
  double _waterTempC = 92.0;
  double _swirlMomentum = 0.0;
  double _elapsedSec = 0.0;

  bool _useHardwareGyro = true;
  bool _gyroHardwareAvailable = false;
  double _virtualTiltNormalized = 0.0; // 0.0 .. 1.0 -> 0° .. 58°
  Vector2 _touchSpiralOffset = Vector2.zero();

  double _lastRecordedCurveTime = -1.0;
  final List<TelemetryCurvePoint> telemetryCurve2Hz = [];

  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  bool get isHardwareGyroActive => _useHardwareGyro && _gyroHardwareAvailable;
  bool get useHardwareGyro => _useHardwareGyro;

  void startSensorFusion({
    required double initialKettleWaterMl,
    required double initialTempCelsius,
    bool preferHardwareGyro = true,
  }) {
    _initialKettleWaterMl = initialKettleWaterMl;
    _remainingKettleMl = initialKettleWaterMl;
    _pouredTotalMl = 0.0;
    _currentFlowRateMlSec = 0.0;
    _waterTempC = initialTempCelsius;
    _swirlMomentum = 0.0;
    _elapsedSec = 0.0;
    _virtualTiltNormalized = 0.0;
    _touchSpiralOffset = Vector2.zero();
    _hasCalibratedTare = false;
    _lastGyroTimestamp = null;
    _lastRecordedCurveTime = -1.0;
    telemetryCurve2Hz.clear();

    _useHardwareGyro = preferHardwareGyro;
    _disposeStreams();

    final bool canListenHardware = !kIsWeb &&
        (Platform.isAndroid || Platform.isIOS) &&
        !Platform.environment.containsKey('FLUTTER_TEST');

    if (!canListenHardware || !preferHardwareGyro) {
      _gyroHardwareAvailable = false;
      return;
    }

    try {
      _accelSub = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        _onAccelerometerTick,
        onError: (_) => _gyroHardwareAvailable = false,
      );

      _gyroSub = gyroscopeEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (event) {
          _gyroHardwareAvailable = true;
          _onGyroscopeTick(event);
        },
        onError: (_) => _gyroHardwareAvailable = false,
      );
      _gyroHardwareAvailable = true;
    } catch (e) {
      debugPrint('Gyroscope hardware fallback to Desk Mode: $e');
      _gyroHardwareAvailable = false;
    }
  }

  void setControlMode({required bool useHardwareGyro}) {
    _useHardwareGyro = useHardwareGyro;
  }

  void setVirtualPourTilt(double normalizedTilt) {
    _virtualTiltNormalized = normalizedTilt.clamp(0.0, 1.0);
  }

  /// Kalibrasi posisi pegangan tangan ergonomis (25°–35°) menjadi 0° netral.
  void calibrateZeroTare() {
    _qTareInverse = _qCurrent.conjugated();
    _hasCalibratedTare = true;
  }

  void injectCoolingWater({required double addedCoolWaterMl, required double targetTempC}) {
    _remainingKettleMl = (_remainingKettleMl + addedCoolWaterMl).clamp(0.0, 650.0);
    _waterTempC = targetTempC.clamp(55.0, 98.0);
  }

  void triggerManualSwirl() {
    _swirlMomentum = 1.0;
  }

  void setTouchSpiralPosition(Vector2 normalizedPos) {
    _touchSpiralOffset = Vector2(
      normalizedPos.x.clamp(-0.96, 0.96),
      normalizedPos.y.clamp(-0.96, 0.96),
    );
  }

  void updateTouchSpiralGuide(Vector2 normalizedDelta) {
    _touchSpiralOffset = Vector2(
      (_touchSpiralOffset.x + normalizedDelta.x).clamp(-0.96, 0.96),
      (_touchSpiralOffset.y + normalizedDelta.y).clamp(-0.96, 0.96),
    );
  }

  void _onAccelerometerTick(AccelerometerEvent event) {
    ingestAccelerometer(event.x, event.y, event.z);
  }

  void _onGyroscopeTick(GyroscopeEvent event) {
    final now = event.timestamp;
    if (_lastGyroTimestamp == null) {
      _lastGyroTimestamp = now;
      return;
    }
    final double dt = (now.difference(_lastGyroTimestamp!).inMicroseconds / 1e6).clamp(0.0005, 0.05);
    _lastGyroTimestamp = now;
    ingestGyroscope(event.x, event.y, event.z, dt);
  }

  /// Umpan data akselerometer langsung (dipakai oleh 200Hz hardware & uji deterministik).
  void ingestAccelerometer(double ax, double ay, double az) {
    final rawA = Vector3(ax, ay, az);
    _lastAccel = rawA;

    // Deteksi goyangan memutar "Gentle Rao Swirl" menggunakan cross-product planar
    final crossImpulse = (ax * _prevLinearAccel.y - ay * _prevLinearAccel.x).abs();
    _prevLinearAccel = rawA;

    if (crossImpulse > 3.8 && _currentFlowRateMlSec < 0.8) {
      _swirlMomentum = (_swirlMomentum + 0.14).clamp(0.0, 1.0);
    }
  }

  /// Integrasi SO(3) Quaternion Gyroscope + Adaptive Motion Rejection Complementary Filter.
  void ingestGyroscope(double wx, double wy, double wz, double dt) {
    final clampedDt = dt.clamp(0.0005, 0.05);
    final Quaternion omegaQ = Quaternion(wx, wy, wz, 0.0);
    final Quaternion qDot = (_qCurrent * omegaQ).scaled(0.5);

    _qCurrent = Quaternion(
      _qCurrent.x + qDot.x * clampedDt,
      _qCurrent.y + qDot.y * clampedDt,
      _qCurrent.z + qDot.z * clampedDt,
      _qCurrent.w + qDot.w * clampedDt,
    )..normalize();

    final double accelNorm = _lastAccel.length;
    if (accelNorm > 0.1) {
      final double motionError = (accelNorm - 9.80665).abs();
      final double adaptiveBeta = 0.025 * math.exp(-(motionError * motionError) / (2.0 * 1.44));

      final Vector3 accelUnit = _lastAccel.normalized();
      final Vector3 estGravity = _qCurrent.rotated(Vector3(0.0, 1.0, 0.0));
      final Vector3 errorCross = accelUnit.cross(estGravity);

      _qCurrent = Quaternion(
        _qCurrent.x + errorCross.x * adaptiveBeta,
        _qCurrent.y + errorCross.y * adaptiveBeta,
        _qCurrent.z + errorCross.z * adaptiveBeta,
        _qCurrent.w,
      )..normalize();
    }

    if (!_hasCalibratedTare) {
      calibrateZeroTare();
    }
  }

  /// Sudut kemiringan kritis ketel leher angsa bergantung sisa volume air: 8° -> 28°.
  double computeCriticalSpoutAngleDeg() {
    final double fillRatio = (_remainingKettleMl / math.max(1.0, _initialKettleWaterMl)).clamp(0.0, 1.0);
    return 8.0 + 20.0 * math.pow(1.0 - fillRatio, 1.2).toDouble();
  }

  KettleTelemetryState stepHydrodynamics(double dt, {bool forceUseGyroOrientationForTest = false}) {
    final double clampedDt = dt.clamp(0.001, 0.05);
    _elapsedSec += clampedDt;
    _swirlMomentum = (_swirlMomentum * math.pow(0.88, clampedDt * 25.0)).clamp(0.0, 1.0);

    final Quaternion qRel = _qTareInverse * _qCurrent;

    final double sinPitch = (2.0 * (qRel.w * qRel.x - qRel.z * qRel.y)).clamp(-1.0, 1.0);
    final double pitchFromGyroDeg = (math.asin(sinPitch).abs() * 180.0 / math.pi).clamp(0.0, 65.0);
    final double rollFromGyroDeg = (math.atan2(
              2.0 * (qRel.w * qRel.y + qRel.x * qRel.z),
              1.0 - 2.0 * (qRel.x * qRel.x + qRel.y * qRel.y),
            ) *
            180.0 /
            math.pi)
        .clamp(-45.0, 45.0);

    final bool useGyroValues = isHardwareGyroActive || forceUseGyroOrientationForTest;
    final double virtualPitchDeg = (_virtualTiltNormalized * 58.0).clamp(0.0, 65.0);
    final double pitchDeg = useGyroValues ? math.max(pitchFromGyroDeg, virtualPitchDeg) : virtualPitchDeg;
    final double rollDeg = useGyroValues ? rollFromGyroDeg : 0.0;

    // 1. Sudut ambang kritis Torricelli terhadap sisa volume air ketel
    final double critAngleDeg = computeCriticalSpoutAngleDeg();

    // 2. Non-Linear Gooseneck Outflow Q_raw(t): kalibrasi 3-6.5 ml/s laminar (12-36°) -> >7 ml/s turbulen (>42°)
    double targetFlowMlSec = 0.0;
    if (pitchDeg > critAngleDeg && _remainingKettleMl > 0.05) {
      final double pitchRadEff = pitchDeg * math.pi / 180.0;
      final double critRadEff = critAngleDeg * math.pi / 180.0;
      final double headHeightMeters = 0.14 * math.max(0.0, math.sin(pitchRadEff) - math.sin(critRadEff));
      targetFlowMlSec = (6.8 * math.sqrt(2.0 * 9.80665 * headHeightMeters)).clamp(0.0, 12.0);
    }

    // 3. Inersia fluida leher pipa (tau = 0.08 s)
    final double alphaPipe = (clampedDt / (0.08 + clampedDt)).clamp(0.0, 1.0);
    _currentFlowRateMlSec = _currentFlowRateMlSec + alphaPipe * (targetFlowMlSec - _currentFlowRateMlSec);
    if (_currentFlowRateMlSec < 0.06 && targetFlowMlSec == 0.0) {
      _currentFlowRateMlSec = 0.0;
    }

    // 4. Kurangi air ketel & catat akumulasi tuangan
    final double deltaMl = math.min(_remainingKettleMl, _currentFlowRateMlSec * clampedDt);
    _remainingKettleMl -= deltaMl;
    _pouredTotalMl += deltaMl;

    // 5. Peluruhan termal alami
    _waterTempC = (_waterTempC - 0.03 * clampedDt).clamp(60.0, 100.0);

    // 6. Koordinat jatuh aliran air 3D di atas bed V60
    final double gyroSteerX = (rollDeg / 38.0).clamp(-0.6, 0.6);
    final Vector2 impactPos = Vector2(
      (_touchSpiralOffset.x + gyroSteerX * 0.35).clamp(-1.0, 1.0),
      _touchSpiralOffset.y.clamp(-1.0, 1.0),
    );

    final double radialDist = impactPos.length;
    final bool isBypass = _currentFlowRateMlSec > 0.5 && radialDist > 0.88;
    final bool isLaminar = _currentFlowRateMlSec <= 6.8;
    final KettleFlowRegime regime = _currentFlowRateMlSec <= 0.15
        ? KettleFlowRegime.idle
        : (isLaminar ? KettleFlowRegime.laminar : KettleFlowRegime.turbulent);

    // Rekam kurva telemetri 2Hz untuk validasi server
    if (_elapsedSec - _lastRecordedCurveTime >= 0.5 && telemetryCurve2Hz.length < 360) {
      _lastRecordedCurveTime = _elapsedSec;
      telemetryCurve2Hz.add(
        TelemetryCurvePoint(
          tSec: _elapsedSec,
          flowMlS: _currentFlowRateMlSec,
          tempC: _waterTempC,
          pitchDeg: pitchDeg,
        ),
      );
    }

    final Quaternion displayRel = useGyroValues
        ? qRel
        : Quaternion.axisAngle(Vector3(1.0, 0.0, 0.0), pitchDeg * math.pi / 180.0);

    return KettleTelemetryState(
      pitchDeg: pitchDeg,
      rollDeg: rollDeg,
      critSpoutAngleDeg: critAngleDeg,
      flowRateMlPerSec: _currentFlowRateMlSec,
      remainingKettleMl: _remainingKettleMl,
      initialKettleMl: _initialKettleWaterMl,
      pouredTotalMl: _pouredTotalMl,
      waterTempCelsius: _waterTempC,
      swirlIntensity: _swirlMomentum,
      isLaminarFlow: isLaminar,
      isBypassWarning: isBypass,
      isGyroHardwareActive: isHardwareGyroActive,
      flowRegime: regime,
      streamImpactNormalized: impactPos,
      relativeOrientation: displayRel,
    );
  }

  void _disposeStreams() {
    _gyroSub?.cancel();
    _accelSub?.cancel();
    _gyroSub = null;
    _accelSub = null;
  }

  void dispose() {
    _disposeStreams();
  }
}
