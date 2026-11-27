import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math_64.dart';

/// Adaptive 1-Euro Filter (Casiez et al.) used in surgical robotics & VR:
/// Eliminates 8-12 Hz physiological hand tremor when holding steady while
/// preserving zero-latency responsiveness during fast pours & Pull-Through Cuts.
class OneEuroFilter {
  final double minCutoffHz;
  final double betaSlope;
  final double derivCutoffHz;

  double? _prevValue;
  double _prevDeriv = 0.0;

  OneEuroFilter({
    this.minCutoffHz = 1.35,
    this.betaSlope = 0.045,
    this.derivCutoffHz = 1.0,
  });

  void reset([double? initial]) {
    _prevValue = initial;
    _prevDeriv = 0.0;
  }

  double filter(double raw, double dt) {
    final double safeDt = dt.clamp(0.0005, 0.1);
    if (_prevValue == null) {
      _prevValue = raw;
      return raw;
    }

    final double rawDeriv = (raw - _prevValue!) / safeDt;
    final double alphaD = _smoothingFactor(safeDt, derivCutoffHz);
    final double hatDeriv = _prevDeriv + alphaD * (rawDeriv - _prevDeriv);
    _prevDeriv = hatDeriv;

    final double cutoff = minCutoffHz + betaSlope * hatDeriv.abs();
    final double alpha = _smoothingFactor(safeDt, cutoff);
    final double filtered = _prevValue! + alpha * (raw - _prevValue!);
    _prevValue = filtered;
    return filtered;
  }

  static double _smoothingFactor(double dt, double cutoffHz) {
    final double r = 2.0 * math.pi * cutoffHz * dt;
    return (r / (r + 1.0)).clamp(0.0, 1.0);
  }
}

/// Snapshot of fused 9-axis orientation & natural hand kinematics.
class NaturalSensorSnapshot {
  final double pitchDeg; // Pour tilt angle (0..65 deg)
  final double rollDeg; // Left-right bank angle (-48..48 deg)
  final double yawDeg; // Stabilized compass/heading angle (-90..90 deg)
  final double pitchRateDegS;
  final double rollRateDegS;
  final double yawRateDegS;
  final double linearAccelX; // m/s^2 (gravity removed!)
  final double linearAccelY;
  final double linearAccelZ;
  final double swirlIntensity; // 0..1 planar circular momentum
  final double wiggleFrequencyHz; // Live measured oscillation Hz
  final double handSteadinessPct; // 0..100% physiological steadiness
  final bool hardwareActive;
  final bool magnetometerActive;

  const NaturalSensorSnapshot({
    this.pitchDeg = 0.0,
    this.rollDeg = 0.0,
    this.yawDeg = 0.0,
    this.pitchRateDegS = 0.0,
    this.rollRateDegS = 0.0,
    this.yawRateDegS = 0.0,
    this.linearAccelX = 0.0,
    this.linearAccelY = 0.0,
    this.linearAccelZ = 0.0,
    this.swirlIntensity = 0.0,
    this.wiggleFrequencyHz = 0.0,
    this.handSteadinessPct = 100.0,
    this.hardwareActive = false,
    this.magnetometerActive = false,
  });
}

/// Aerospace/Barista-grade 9-Axis Sensor Fusion Engine:
/// Combines 200Hz Gyroscope (SO(3) exponential map + stationary bias removal),
/// Accelerometer + UserAccelerometer (true gravity separation from hand motion),
/// Magnetometer (yaw drift stabilization with magnetic anomaly rejection),
/// Portrait/Landscape axis remapping, and 1-Euro physiological tremor filtering.
class NaturalGyroSensorFusionEngine {
  Quaternion _qAttitude = Quaternion.identity();
  Quaternion _qTareInv = Quaternion.identity();
  bool _hasTare = false;

  // Sensor biases & raw vectors
  final Vector3 _gyroBias = Vector3.zero();
  final Vector3 _rawGyro = Vector3.zero();
  final Vector3 _rawAccel = Vector3(0.0, 9.80665, 0.0);
  final Vector3 _linearAccel = Vector3.zero();
  final Vector3 _prevLinearAccel = Vector3.zero();
  final Vector3 _magField = Vector3.zero();
  bool _hasUserAccelStream = false;
  bool _hasGravityInit = false;
  bool _magValid = false;
  bool _hardwareActive = false;
  bool _isLandscape = false;
  double _baseGravityPitchRad = 0.0;
  double _currentGravityPitchRad = 0.0;

  DateTime? _lastGyroTime;

  // 1-Euro filters for butter-smooth zero-lag output
  final OneEuroFilter _pitchFilter =
      OneEuroFilter(minCutoffHz: 1.4, betaSlope: 0.055);
  final OneEuroFilter _rollFilter =
      OneEuroFilter(minCutoffHz: 1.6, betaSlope: 0.065);
  final OneEuroFilter _yawFilter =
      OneEuroFilter(minCutoffHz: 1.1, betaSlope: 0.035);

  // Kinematic detectors (Rao Swirl, Wiggle Hz, Hand Steadiness)
  double _swirlMomentum = 0.0;
  double _tremorRms = 0.0;
  int _lastRollSign = 0;
  final List<double> _wiggleCrossTimes = [];
  double _elapsedSec = 0.0;

  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<UserAccelerometerEvent>? _userAccelSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  bool get isHardwareActive => _hardwareActive;

  void setOrientation({required bool isLandscape}) {
    _isLandscape = isLandscape;
  }

  void start() {
    stop();
    final bool canUseHardware = !kIsWeb &&
        (Platform.isAndroid || Platform.isIOS) &&
        !Platform.environment.containsKey('FLUTTER_TEST');
    if (!canUseHardware) {
      _hardwareActive = false;
      return;
    }

    try {
      _accelSub = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (e) {
          _hardwareActive = true;
          ingestAccelerometer(e.x, e.y, e.z);
        },
        onError: (_) {},
      );

      _userAccelSub = userAccelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (e) {
          _hasUserAccelStream = true;
          ingestUserLinearAccelerometer(e.x, e.y, e.z);
        },
        onError: (_) => _hasUserAccelStream = false,
      );

      _gyroSub = gyroscopeEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (e) {
          _hardwareActive = true;
          final now = e.timestamp;
          final double dt = _lastGyroTime == null
              ? 0.005
              : (now.difference(_lastGyroTime!).inMicroseconds / 1e6)
                  .clamp(0.001, 0.04);
          _lastGyroTime = now;
          ingestGyroscope(e.x, e.y, e.z, dt);
        },
        onError: (_) {},
      );

      _magSub = magnetometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (e) => ingestMagnetometer(e.x, e.y, e.z),
        onError: (_) => _magValid = false,
      );
    } catch (_) {
      _hardwareActive = false;
    }
  }

  void stop() {
    _gyroSub?.cancel();
    _accelSub?.cancel();
    _userAccelSub?.cancel();
    _magSub?.cancel();
    _gyroSub = null;
    _accelSub = null;
    _userAccelSub = null;
    _magSub = null;
  }

  /// Sets current comfortable hand grip as neutral 0° pour baseline (signed forward tilt = pour!).
  void calibrateZeroTare() {
    _qTareInv = _qAttitude.conjugated();
    _baseGravityPitchRad = _currentGravityPitchRad;
    _hasTare = true;
    _pitchFilter.reset(0.0);
    _rollFilter.reset(0.0);
    _yawFilter.reset(0.0);
  }

  Vector3 _remapAxes(double x, double y, double z) {
    // In landscape-left, device +Y becomes horizontal right and -X becomes up.
    if (_isLandscape) {
      return Vector3(y, -x, z);
    }
    return Vector3(x, y, z);
  }

  /// Deterministic entry point for hardware stream & unit tests.
  void ingestAccelerometer(double x, double y, double z) {
    final v = _remapAxes(x, y, z);
    _rawAccel.setFrom(v);

    // Compute rock-solid gravity-aligned forward pitch angle (rad) around device +X axis:
    // Vertical (0, 9.8, 0) -> 0 rad; 45 deg grip (0, 6.9, 6.9) -> +45 deg;
    // Tilting top forward/down to pour -> monotonically increases toward +90..+135 deg!
    final double gNorm = v.length;
    if (gNorm > 2.0) {
      final double gravPitch = math.atan2(v.z, v.y);
      if (!_hasGravityInit) {
        _hasGravityInit = true;
        _currentGravityPitchRad = gravPitch;
        _baseGravityPitchRad = gravPitch;
        // vector_math_64's `Quaternion.rotated` applies inverse (world -> body),
        // so initializing body -> world via fromTwoVectors(gMeasBody, +Y) gives exact 0.0° at rest!
        _qAttitude = Quaternion.fromTwoVectors(
          v / gNorm,
          Vector3(0.0, 1.0, 0.0),
        )..normalize();
        _qTareInv = _qAttitude.conjugated();
        _hasTare = true;
      } else {
        // Shortest angular delta prevents wraparound glitches
        double delta = gravPitch - _currentGravityPitchRad;
        if (delta > math.pi) delta -= 2.0 * math.pi;
        if (delta < -math.pi) delta += 2.0 * math.pi;
        _currentGravityPitchRad += delta * 0.22;
      }
    }

    if (!_hasUserAccelStream) {
      // High-pass fallback if device lacks hardware linear-accel sensor
      final Vector3 gravEst = _qAttitude.rotated(Vector3(0.0, 9.80665, 0.0));
      _prevLinearAccel.setFrom(_linearAccel);
      _linearAccel.setFrom(v - gravEst);
      _detectCircularSwirl();
    }
  }

  void ingestUserLinearAccelerometer(double x, double y, double z) {
    final v = _remapAxes(x, y, z);
    _prevLinearAccel.setFrom(_linearAccel);
    _linearAccel.setValues(
      _linearAccel.x * 0.6 + v.x * 0.4,
      _linearAccel.y * 0.6 + v.y * 0.4,
      _linearAccel.z * 0.6 + v.z * 0.4,
    );
    _detectCircularSwirl();
  }

  void _detectCircularSwirl() {
    final double cross = (_linearAccel.x * _prevLinearAccel.z -
            _linearAccel.z * _prevLinearAccel.x)
        .abs();
    final double planarMag = math.sqrt(
      _linearAccel.x * _linearAccel.x + _linearAccel.z * _linearAccel.z,
    );
    if (cross > 0.45 || planarMag > 2.2) {
      _swirlMomentum = (_swirlMomentum + 0.085).clamp(0.0, 1.0);
    }
  }

  void ingestMagnetometer(double mx, double my, double mz) {
    final v = _remapAxes(mx, my, mz);
    final double norm = v.length;
    // Earth magnetic field is ~25-65 uT; reject desk magnets / speaker anomalies
    if (norm >= 18.0 && norm <= 88.0) {
      _magField.setFrom(v);
      _magValid = true;
    } else {
      _magValid = false;
    }
  }

  /// Exact SO(3) Exponential Map Quaternion integration + Mahony Gravity/Mag Fusion.
  void ingestGyroscope(double wx, double wy, double wz, double dt) {
    final double safeDt = dt.clamp(0.0005, 0.05);
    _elapsedSec += safeDt;

    final Vector3 rawW = _remapAxes(wx, wy, wz);
    _rawGyro.setFrom(rawW);

    // 1. Online stationary MEMS bias estimation (thermal drift killer)
    final double accelErr = (_rawAccel.length - 9.80665).abs();
    if (rawW.length < 0.045 && accelErr < 0.35) {
      _gyroBias.scale(0.995);
      _gyroBias.addScaled(rawW, 0.005);
    }

    final Vector3 w = rawW - _gyroBias;
    _tremorRms = _tremorRms * 0.94 + w.length * 0.06;

    // Track Wiggle Zero-Crossings on Roll/Yaw rate for Latte Art Rosetta rhythm
    final double wiggleRate = w.z.abs() > w.y.abs() ? w.z : w.y;
    if (wiggleRate.abs() > 0.35) {
      final int sign = wiggleRate > 0 ? 1 : -1;
      if (_lastRollSign != 0 && sign != _lastRollSign) {
        _wiggleCrossTimes.add(_elapsedSec);
        while (_wiggleCrossTimes.isNotEmpty &&
            _elapsedSec - _wiggleCrossTimes.first > 2.2) {
          _wiggleCrossTimes.removeAt(0);
        }
      }
      _lastRollSign = sign;
    }

    // 2. Mahony Complementary Gravity Correction (using TRUE gravity = rawAccel - linearAccel!)
    final Vector3 trueGrav = _hasUserAccelStream
        ? (_rawAccel - _linearAccel)
        : _rawAccel;
    final double gNorm = trueGrav.length;
    Vector3 corr = Vector3.zero();

    if (gNorm > 2.0) {
      final double trust = math.exp(-(accelErr * accelErr) / 3.2);
      final Vector3 gMeasBody = trueGrav / gNorm;
      // Note: vector_math_64's `Quaternion.rotated` transforms world -> body directly!
      final Vector3 gEstBody = _qAttitude.rotated(Vector3(0.0, 1.0, 0.0));
      corr = gMeasBody.cross(gEstBody) * (1.85 * trust);

      // Optional Magnetometer Yaw Drift Correction (subtle weight)
      if (_magValid && _magField.length > 1.0) {
        final Vector3 mUnit = _magField.normalized();
        // Project magnetic field onto horizontal plane perpendicular to gravity
        final Vector3 hHoriz =
            (mUnit - gMeasBody * mUnit.dot(gMeasBody)).normalized();
        final Vector3 mEstBody = _qAttitude.rotated(Vector3(0.0, 0.0, 1.0));
        final Vector3 mEstHoriz =
            (mEstBody - gEstBody * mEstBody.dot(gEstBody));
        if (mEstHoriz.length2 > 0.05) {
          mEstHoriz.normalize();
          corr += hHoriz.cross(mEstHoriz) * 0.25;
        }
      }
    }

    // 3. Exact SO(3) Exponential Map step (zero numerical norm drift!)
    final Vector3 wEff = w + corr;
    final double omegaMag = wEff.length;
    Quaternion dq;
    if (omegaMag > 1e-6) {
      final double halfTheta = 0.5 * omegaMag * safeDt;
      final double sinHalf = math.sin(halfTheta) / omegaMag;
      dq = Quaternion(
        wEff.x * sinHalf,
        wEff.y * sinHalf,
        wEff.z * sinHalf,
        math.cos(halfTheta),
      );
    } else {
      dq = Quaternion(
        0.5 * wEff.x * safeDt,
        0.5 * wEff.y * safeDt,
        0.5 * wEff.z * safeDt,
        1.0,
      );
    }

    _qAttitude = (_qAttitude * dq)..normalize();

    if (!_hasTare && gNorm > 5.0) {
      calibrateZeroTare();
    }
  }

  NaturalSensorSnapshot sample(double dt) {
    final double safeDt = dt.clamp(0.001, 0.05);
    _swirlMomentum =
        (_swirlMomentum * math.pow(0.86, safeDt * 30.0)).clamp(0.0, 1.0);

    final Quaternion qRel = _qTareInv * _qAttitude;

    // Signed ergonomic pour tilt (ONLY forward/downward tilt pours; upright or backward = 0° STOP!).
    // Blends instantaneous SO(3) quaternion pitch with drift-free gravity inclination baseline so
    // the kettle NEVER starts stuck at 61° on launch!
    final double sinP =
        (2.0 * (qRel.w * qRel.x - qRel.z * qRel.y)).clamp(-1.0, 1.0);
    // Body->world quaternion rotates -X on forward pour tilt, so -asin(sinP) is positive!
    final double quatPitchDeg = -(math.asin(sinP) * 180.0 / math.pi);
    final double gravDeltaDeg =
        ((_currentGravityPitchRad - _baseGravityPitchRad) * 180.0 / math.pi);
    // Complementary blend: gravity prevents startup offset/drift, gyro gives instant 200Hz feel!
    final double signedPourDeg = _hasGravityInit
        ? (gravDeltaDeg * 0.72 + quatPitchDeg * 0.28)
        : quatPitchDeg;
    // Apply 3.5° ergonomic neutral deadband so holding the phone naturally stays at exact 0.0 ml/s!
    final double rawPitchDeg = signedPourDeg <= 3.5
        ? 0.0
        : (signedPourDeg - 3.5).clamp(0.0, 58.0);

    final double rawRollDeg = (math.atan2(
              2.0 * (qRel.w * qRel.z + qRel.x * qRel.y),
              1.0 - 2.0 * (qRel.y * qRel.y + qRel.z * qRel.z),
            ) *
            180.0 /
            math.pi)
        .clamp(-48.0, 48.0);

    final double rawYawDeg = (math.atan2(
              2.0 * (qRel.w * qRel.y + qRel.x * qRel.z),
              1.0 - 2.0 * (qRel.x * qRel.x + qRel.y * qRel.y),
            ) *
            180.0 /
            math.pi)
        .clamp(-90.0, 90.0);

    final double smoothPitch = _pitchFilter.filter(rawPitchDeg, safeDt);
    final double smoothRoll = _rollFilter.filter(rawRollDeg, safeDt);
    final double smoothYaw = _yawFilter.filter(rawYawDeg, safeDt);

    // Compute live Wiggle frequency (2 zero-crossings = 1 full cycle)
    double wiggleHz = 0.0;
    if (_wiggleCrossTimes.length >= 3) {
      final double span =
          _wiggleCrossTimes.last - _wiggleCrossTimes.first;
      if (span > 0.15) {
        final double cycles = (_wiggleCrossTimes.length - 1) / 2.0;
        wiggleHz = (cycles / span).clamp(0.0, 8.0);
      }
    }

    final double steadiness =
        (100.0 * math.exp(-(_tremorRms * _tremorRms) / 1.8)).clamp(25.0, 100.0);

    const double rad2Deg = 180.0 / math.pi;
    final Vector3 netRate = _rawGyro - _gyroBias;

    return NaturalSensorSnapshot(
      pitchDeg: smoothPitch,
      rollDeg: smoothRoll,
      yawDeg: smoothYaw,
      pitchRateDegS: netRate.x * rad2Deg,
      rollRateDegS: netRate.z * rad2Deg,
      yawRateDegS: netRate.y * rad2Deg,
      linearAccelX: _linearAccel.x,
      linearAccelY: _linearAccel.y,
      linearAccelZ: _linearAccel.z,
      swirlIntensity: _swirlMomentum,
      wiggleFrequencyHz: wiggleHz,
      handSteadinessPct: steadiness,
      hardwareActive: _hardwareActive,
      magnetometerActive: _magValid,
    );
  }
}
