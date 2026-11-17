import 'dart:math' as math;

import 'package:flame/game.dart' hide Matrix4, Quaternion, Vector2, Vector3, Vector4;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Quaternion, Vector2, Vector3, Vector4;

import 'gyro_kettle_physics_engine.dart';
import 'tactile_haptic_and_audio_synthesizer.dart';
import 'v60_bed_heightfield_solver.dart';

enum V603DCameraPerspective {
  baristaPov,
  xrayCutaway,
  freeOrbit,
}

enum BrewInteractiveStage {
  wettingPaper,
  liftAndDiscard,
  blooming,
  mainPour,
  drawdownAndInspect,
}

class V603DSimulationSnapshot {
  final double elapsedSec;
  final double pouredMl;
  final double targetWaterMl;
  final double serverMl;
  final double slurryMl;
  final double rinseWaterMl;
  final double remainingKettleMl;
  final double initialKettleMl;
  final double flowRateMlS;
  final double pitchDeg;
  final double rollDeg;
  final double critSpoutAngleDeg;
  final double tempC;
  final double estimatedEyPct;
  final double acidPct;
  final double sweetPct;
  final double bitterPct;
  final double laminarRatioPct;
  final double spiralEvennessPct;
  final double flatBedScorePct;
  final double thermalMasteryPct;
  final double swirlIntensity;
  final double averageCo2;
  final double paperWetnessPct;
  final double dripperLiftProgress;
  final double serverTiltRad;
  final int bypassEventsCount;
  final KettleFlowRegime flowRegime;
  final BrewInteractiveStage interactiveStage;
  final bool isBypassWarning;
  final bool isGyroHardwareActive;
  final bool swirlPerformed;
  final bool isDripperLifted;
  final bool rinseDiscarded;
  final bool coffeeGroundsAdded;
  final bool isCompleted;
  final Offset streamImpactNormalized;
  final String activePhaseLabel;
  final String liveCoachTip;

  const V603DSimulationSnapshot({
    this.elapsedSec = 0.0,
    this.pouredMl = 0.0,
    this.targetWaterMl = 225.0,
    this.serverMl = 0.0,
    this.slurryMl = 0.0,
    this.rinseWaterMl = 0.0,
    this.remainingKettleMl = 350.0,
    this.initialKettleMl = 350.0,
    this.flowRateMlS = 0.0,
    this.pitchDeg = 0.0,
    this.rollDeg = 0.0,
    this.critSpoutAngleDeg = 8.0,
    this.tempC = 92.0,
    this.estimatedEyPct = 0.0,
    this.acidPct = 32.0,
    this.sweetPct = 44.0,
    this.bitterPct = 24.0,
    this.laminarRatioPct = 100.0,
    this.spiralEvennessPct = 100.0,
    this.flatBedScorePct = 92.0,
    this.thermalMasteryPct = 100.0,
    this.swirlIntensity = 0.0,
    this.averageCo2 = 1.0,
    this.paperWetnessPct = 0.0,
    this.dripperLiftProgress = 0.0,
    this.serverTiltRad = 0.0,
    this.bypassEventsCount = 0,
    this.flowRegime = KettleFlowRegime.idle,
    this.interactiveStage = BrewInteractiveStage.wettingPaper,
    this.isBypassWarning = false,
    this.isGyroHardwareActive = false,
    this.swirlPerformed = false,
    this.isDripperLifted = false,
    this.rinseDiscarded = false,
    this.coffeeGroundsAdded = false,
    this.isCompleted = false,
    this.streamImpactNormalized = Offset.zero,
    this.activePhaseLabel = 'Tahap 1 • Basahi Kertas Filter',
    this.liveCoachTip = 'Miringkan teko ketel memutar (~35ml) untuk membasahi kertas filter & memanaskan teko server.',
  });
}

class _SteamParticle3D {
  Vector3 pos;
  double life;
  double radius;
  _SteamParticle3D(this.pos, this.life, this.radius);
}

class _PercolationDroplet3D {
  double yNorm;
  double speed;
  _PercolationDroplet3D(this.yNorm, this.speed);
}

/// Master Flame Engine 120Hz Physics + Multi-Perspective 3D V60 Renderer.
/// Mengorkestrasi:
/// 1) 6-DoF Gyroscope Quaternion Fusion (`GyroKettlePhysicsEngine`)
/// 2) 32x32 3D Coffee Bed Heightfield & Darcy Solver (`V60BedPercolationSolver`)
/// 3) Tactile Haptics (`TactileHapticAndAudioSynthesizer`)
/// 4) Real-Time 3D Perspective Mesh, Parabolic Kettle Stream, & Cutaway Shader Rendering.
class V603DFlameSimulatorGame extends FlameGame {
  final double doseG;
  final double targetWaterMl;
  final double bloomMl;
  final double bloomSec;
  final double initialTempC;
  final double? dropTempC;
  final double? dropAtMl;
  final double targetTimeSec;
  final double idealFlowMlS;

  late final GyroKettlePhysicsEngine kettleEngine = GyroKettlePhysicsEngine();
  late final V60BedPercolationSolver bedSolver = V60BedPercolationSolver();
  late final TactileHapticAndAudioSynthesizer hapticSynth = TactileHapticAndAudioSynthesizer();

  late final ValueNotifier<V603DSimulationSnapshot> snapshotNotifier = ValueNotifier(
    V603DSimulationSnapshot(
      targetWaterMl: targetWaterMl,
      initialKettleMl: targetWaterMl + 95.0,
      remainingKettleMl: targetWaterMl + 95.0,
      tempC: initialTempC,
    ),
  );

  V603DFlameSimulatorGame({
    required this.doseG,
    required this.targetWaterMl,
    required this.bloomMl,
    required this.bloomSec,
    required this.initialTempC,
    this.dropTempC,
    this.dropAtMl,
    required this.targetTimeSec,
    required this.idealFlowMlS,
  }) {
    _startPhysicsSession();
  }

  V603DCameraPerspective _cameraMode = V603DCameraPerspective.baristaPov;
  double _orbitYawRad = 0.45;
  double _orbitPitchRad = 0.72; // ~41° elevation

  double _elapsedSec = 0.0;
  bool _hasStartedPour = false;
  bool _thermalDropTriggered = false;
  bool _swirlPerformed = false;
  bool _isCompleted = false;
  double _thermalScore = 100.0;
  double _physicsAccum = 0.0;
  double _uiEmitTimer = 0.0;
  double _ghostSpiralPhase = 0.0;
  double _vortexPhase = 0.0;

  // Siklus interaktif persiapan V60 (membasahi kertas -> angkat dripper -> buang air -> tuang kopi -> seduh)
  BrewInteractiveStage _stage = BrewInteractiveStage.wettingPaper;
  double _paperWetness = 0.0; // 0..1
  double _rinseWaterMl = 0.0;
  bool _isDripperLifted = false;
  double _dripperLiftProgress = 0.0;
  double _serverTiltRad = 0.0;
  bool _discardingRinse = false;
  bool _rinseDiscarded = false;
  bool _coffeeGroundsAdded = false;

  late KettleTelemetryState _lastTelemetry;
  final math.Random _rng = math.Random(42);
  final List<_SteamParticle3D> _steamParticles = [];
  final List<_PercolationDroplet3D> _droplets = [];

  V603DCameraPerspective get cameraMode => _cameraMode;
  double get orbitYawRad => _orbitYawRad;
  double get orbitPitchRad => _orbitPitchRad;
  double get vortexPhase => _vortexPhase;
  double get ghostSpiralPhase => _ghostSpiralPhase;
  bool get isThermalDropTriggered => _thermalDropTriggered;
  KettleTelemetryState get lastTelemetry => _lastTelemetry;

  void _startPhysicsSession() {
    final kettleCapacity = targetWaterMl + 145.0; // Termasuk air panas untuk rinsing kertas filter
    kettleEngine.startSensorFusion(
      initialKettleWaterMl: kettleCapacity,
      initialTempCelsius: initialTempC,
      preferHardwareGyro: true,
    );
    bedSolver.resetCoffeeBed();
    _elapsedSec = 0.0;
    _hasStartedPour = false;
    _thermalDropTriggered = false;
    _swirlPerformed = false;
    _isCompleted = false;
    _thermalScore = 100.0;
    _stage = BrewInteractiveStage.wettingPaper;
    _paperWetness = 0.0;
    _rinseWaterMl = 0.0;
    _isDripperLifted = false;
    _dripperLiftProgress = 0.0;
    _serverTiltRad = 0.0;
    _discardingRinse = false;
    _rinseDiscarded = false;
    _coffeeGroundsAdded = false;
    _steamParticles.clear();
    _droplets.clear();
    _lastTelemetry = kettleEngine.stepHydrodynamics(1.0 / 120.0);
  }

  void resetSimulation() {
    _startPhysicsSession();
    _emitSnapshot();
  }

  void setCameraPerspective(V603DCameraPerspective mode) {
    _cameraMode = mode;
    if (mode == V603DCameraPerspective.baristaPov) {
      _orbitYawRad = 0.35;
      _orbitPitchRad = 0.92; // 53° POV Barista melihat ke dalam V60
    } else if (mode == V603DCameraPerspective.xrayCutaway) {
      _orbitYawRad = 0.08;
      _orbitPitchRad = 0.24; // Potongan melintang sejajar sisi cone & server
    } else {
      _orbitYawRad = 0.65;
      _orbitPitchRad = 0.85;
    }
  }

  void adjustOrbitCamera(double deltaX, double deltaY) {
    _orbitYawRad = (_orbitYawRad + deltaX * 0.011) % (math.pi * 2);
    _orbitPitchRad = (_orbitPitchRad + deltaY * 0.008).clamp(0.12, 1.38);
  }

  void setControlMode({required bool useHardwareGyro}) {
    kettleEngine.setControlMode(useHardwareGyro: useHardwareGyro);
    _emitSnapshot();
  }

  void calibrateZeroTare() {
    kettleEngine.calibrateZeroTare();
  }

  void setVirtualPourTilt(double normalizedTilt) {
    kettleEngine.setVirtualPourTilt(normalizedTilt);
  }

  void setTouchSpiralPosition(Offset normalizedPos) {
    kettleEngine.setTouchSpiralPosition(Vector2(normalizedPos.dx, normalizedPos.dy));
  }

  void triggerGentleRaoSwirl() {
    if (_isCompleted) return;
    kettleEngine.triggerManualSwirl();
    _swirlPerformed = true;
    // Saat Rinsing kertas, swirl membantu meratakan pembasahan; saat liftAndDiscard tanpa buang, kocok teko
    if (_stage == BrewInteractiveStage.liftAndDiscard && _isDripperLifted && _rinseWaterMl > 0.5) {
      discardRinseWater();
    }
  }

  /// Angkat atau turunkan dripper Hario V60 di atas Glass Server.
  void toggleLiftDripper() {
    if (_isCompleted) return;
    _isDripperLifted = !_isDripperLifted;
    if (_isDripperLifted && _stage == BrewInteractiveStage.wettingPaper && _paperWetness >= 0.4) {
      _stage = BrewInteractiveStage.liftAndDiscard;
    }
    _emitSnapshot();
  }

  /// Miringkan teko Glass Server untuk membuang air bilasan kertas filter.
  void discardRinseWater() {
    if (_isCompleted) return;
    if (!_isDripperLifted) {
      _isDripperLifted = true;
    }
    if (_stage == BrewInteractiveStage.wettingPaper) {
      _stage = BrewInteractiveStage.liftAndDiscard;
    }
    _discardingRinse = true;
    _emitSnapshot();
  }

  /// Tuangkan bubuk kopi segar (doseG) ke dalam cone V60 yang sudah dibilas lalu turunkan dripper.
  void dropCoffeeGrounds() {
    if (_isCompleted) return;
    _rinseWaterMl = 0.0;
    _rinseDiscarded = true;
    _discardingRinse = false;
    _serverTiltRad = 0.0;
    _isDripperLifted = false;
    _paperWetness = math.max(_paperWetness, 1.0);
    _coffeeGroundsAdded = true;
    bedSolver.resetCoffeeBed();
    _stage = BrewInteractiveStage.blooming;
    _emitSnapshot();
  }

  /// Pintasan cepat langsung menuju fase seduh kopi dengan kertas filter sudah terbilas rapi.
  void skipPreBrewToCoffee() {
    dropCoffeeGrounds();
  }

  void activateThermalDrop(double coolTempC) {
    if (_isCompleted || _thermalDropTriggered) return;
    _thermalDropTriggered = true;
    final atMl = dropAtMl ?? targetWaterMl * 0.60;
    final err = (_lastTelemetry.pouredTotalMl - atMl).abs();
    _thermalScore = err <= 35.0 ? 100.0 : (100.0 - (err - 35.0) * 0.45).clamp(48.0, 96.0);
    kettleEngine.injectCoolingWater(addedCoolWaterMl: 85.0, targetTempC: coolTempC);
    _emitSnapshot();
  }

  void finishBrewEarlyForInspection() {
    if (_elapsedSec >= 8.0 && _lastTelemetry.pouredTotalMl >= targetWaterMl * 0.75) {
      _isCompleted = true;
      _emitSnapshot();
    }
  }

  @override
  void onRemove() {
    kettleEngine.dispose();
    super.onRemove();
  }

  /// Panggil dari StatefulWidget.dispose() setelah super.dispose() agar semua
  /// ValueListenableBuilder selesai melepaskan listener tanpa debug error.
  void disposeNotifier() {
    snapshotNotifier.dispose();
  }

  @override
  Color backgroundColor() => const Color(0xFF140D09);

  /// Dijalankan oleh render loop Three.js / OpenGL saat rendering PBR 3D aktif
  /// agar fisika 120Hz tetap melaju presisi tanpa double GameWidget.
  void tickExternalPhysics(double dt) {
    if (_isCompleted) return;
    const double fixedDt = 1.0 / 120.0;
    _physicsAccum = (_physicsAccum + dt.clamp(0.0, 0.05)).clamp(0.0, 0.12);

    while (_physicsAccum >= fixedDt) {
      _physicsAccum -= fixedDt;
      _stepPhysics(fixedDt);
    }

    _uiEmitTimer += dt.clamp(0.0, 0.05);
    if (_uiEmitTimer >= 0.05) {
      _uiEmitTimer = 0.0;
      _emitSnapshot();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    tickExternalPhysics(dt);
  }

  void _stepPhysics(double dt) {
    final telemetry = kettleEngine.stepHydrodynamics(dt);
    _lastTelemetry = telemetry;

    // Interpolasi halus animasi Angkat Dripper V60 & Miringkan Glass Server buang bilasan
    final double targetLift = _isDripperLifted ? 1.0 : 0.0;
    _dripperLiftProgress += (targetLift - _dripperLiftProgress) * math.min(1.0, dt * 5.2);

    if (_discardingRinse) {
      _serverTiltRad += (1.06 - _serverTiltRad) * math.min(1.0, dt * 4.5);
      if (_serverTiltRad > 0.72) {
        _rinseWaterMl = math.max(0.0, _rinseWaterMl - 48.0 * dt);
        if (_rinseWaterMl <= 0.1) {
          _rinseWaterMl = 0.0;
          _rinseDiscarded = true;
          _discardingRinse = false;
        }
      }
    } else {
      _serverTiltRad += (0.0 - _serverTiltRad) * math.min(1.0, dt * 5.0);
    }

    if (telemetry.swirlIntensity > 0.25) {
      _swirlPerformed = true;
      _vortexPhase += dt * (4.0 + telemetry.swirlIntensity * 6.0);
    }

    _ghostSpiralPhase += dt * 1.45;

    final bool isPreBrewStage =
        _stage == BrewInteractiveStage.wettingPaper ||
        _stage == BrewInteractiveStage.liftAndDiscard;

    if (isPreBrewStage) {
      if (_stage == BrewInteractiveStage.wettingPaper && telemetry.flowRateMlPerSec > 0.2) {
        final double rinseDelta = telemetry.flowRateMlPerSec * dt;
        _rinseWaterMl = (_rinseWaterMl + rinseDelta).clamp(0.0, 80.0);
        _paperWetness = (_paperWetness + rinseDelta / 30.0).clamp(0.0, 1.0);
        if (_droplets.length < 8 && _rng.nextDouble() < 0.28) {
          _droplets.add(_PercolationDroplet3D(0.0, 1.6 + _rng.nextDouble() * 0.7));
        }
        if (_paperWetness >= 0.99) {
          _stage = BrewInteractiveStage.liftAndDiscard;
          _isDripperLifted = true;
        }
      }
    } else {
      if (telemetry.flowRateMlPerSec > 0.2) {
        _hasStartedPour = true;
      }
      if (_hasStartedPour) {
        _elapsedSec += dt;
      }

      final double allowedInflow = math.min(
        telemetry.flowRateMlPerSec,
        math.max(0.0, (targetWaterMl - (bedSolver.slurryWaterVolumeMl + bedSolver.beverageServerVolumeMl)) / dt),
      );

      bedSolver.stepPercolation(
        dt: dt,
        inflowRateMlSec: allowedInflow,
        impactPos: telemetry.streamImpactNormalized,
        swirlIntensity: telemetry.swirlIntensity,
        waterTempC: telemetry.waterTempCelsius,
        targetWaterMl: targetWaterMl,
        totalPouredMl: bedSolver.slurryWaterVolumeMl + bedSolver.beverageServerVolumeMl,
        thermalDropActive: _thermalDropTriggered,
      );

      final totalEntered = bedSolver.slurryWaterVolumeMl + bedSolver.beverageServerVolumeMl;
      if (_stage == BrewInteractiveStage.blooming && (totalEntered >= bloomMl || _elapsedSec >= bloomSec)) {
        _stage = BrewInteractiveStage.mainPour;
      } else if (_stage == BrewInteractiveStage.mainPour && totalEntered >= targetWaterMl - 2.0) {
        _stage = BrewInteractiveStage.drawdownAndInspect;
      }
    }

    hapticSynth.stepFeedback(
      dt: dt,
      telemetry: telemetry,
      averageCo2Remaining: bedSolver.averageCo2Level(),
    );

    // Partikel uap panas dari air > 82°C
    if ((telemetry.flowRateMlPerSec > 0.2 || _hasStartedPour) &&
        telemetry.waterTempCelsius > 80.0 &&
        _steamParticles.length < 20 &&
        _rng.nextDouble() < 0.18) {
      _steamParticles.add(
        _SteamParticle3D(
          Vector3((_rng.nextDouble() - 0.5) * 0.9, 0.55, (_rng.nextDouble() - 0.5) * 0.9),
          1.0,
          4.0 + _rng.nextDouble() * 6.0,
        ),
      );
    }
    for (int i = _steamParticles.length - 1; i >= 0; i--) {
      _steamParticles[i].pos.y += dt * 0.65;
      _steamParticles[i].pos.x += math.sin(_elapsedSec * 2.0 + i) * dt * 0.15;
      _steamParticles[i].life -= dt * 0.72;
      if (_steamParticles[i].life <= 0.0) _steamParticles.removeAt(i);
    }

    // Tetesan Darcy ke Server
    if (bedSolver.slurryWaterVolumeMl > 1.0 && _droplets.length < 10 && _rng.nextDouble() < 0.24) {
      _droplets.add(_PercolationDroplet3D(0.0, 1.4 + _rng.nextDouble() * 0.8));
    }
    for (int i = _droplets.length - 1; i >= 0; i--) {
      _droplets[i].yNorm += _droplets[i].speed * dt;
      if (_droplets[i].yNorm >= 1.0) _droplets.removeAt(i);
    }

    final totalWaterEntered = bedSolver.slurryWaterVolumeMl + bedSolver.beverageServerVolumeMl;
    if (_hasStartedPour &&
        totalWaterEntered >= targetWaterMl - 1.0 &&
        bedSolver.slurryWaterVolumeMl < 1.8 &&
        bedSolver.beverageServerVolumeMl >= targetWaterMl - 5.0) {
      _isCompleted = true;
      _stage = BrewInteractiveStage.drawdownAndInspect;
      if (dropTempC != null && !_thermalDropTriggered) {
        _thermalScore = (_thermalScore - 28.0).clamp(45.0, 100.0);
      }
      _emitSnapshot();
    }
  }

  void _emitSnapshot() {
    final totalPoured = bedSolver.slurryWaterVolumeMl + bedSolver.beverageServerVolumeMl;
    final rawTotal = bedSolver.acidExtracted + bedSolver.sweetExtracted + bedSolver.bitterExtracted;
    final acidPct = rawTotal > 0 ? (bedSolver.acidExtracted / rawTotal * 100.0).clamp(0.0, 100.0) : 32.0;
    final sweetPct = rawTotal > 0 ? (bedSolver.sweetExtracted / rawTotal * 100.0).clamp(0.0, 100.0) : 44.0;
    final bitterPct = rawTotal > 0 ? (bedSolver.bitterExtracted / rawTotal * 100.0).clamp(0.0, 100.0) : 24.0;

    final String phase;
    final String tip;
    if (_stage == BrewInteractiveStage.wettingPaper) {
      phase = 'Tahap 1 • Basahi Kertas (${(_paperWetness * 100).toInt()}%)';
      tip = 'Miringkan teko ketel (> ${_lastTelemetry.critSpoutAngleDeg.toStringAsFixed(0)}°) mengelilingi dinding kertas filter untuk membilas & memanaskan teko server.';
    } else if (_stage == BrewInteractiveStage.liftAndDiscard) {
      if (!_rinseDiscarded && _rinseWaterMl > 0.5) {
        phase = 'Tahap 2 • Angkat Dripper & Buang Air';
        tip = _isDripperLifted
            ? 'Teko V60 terangkat! Tekan "Buang Air Bilasan" untuk memiringkan Glass Server.'
            : 'Tekan "Angkat Dripper" lalu buang air bilasan hangat dari teko server.';
      } else {
        phase = 'Tahap 2 • Masukkan ${doseG.toInt()}g Bubuk Kopi';
        tip = 'Server sudah bersih! Tekan "Tuang Bubuk Kopi (${doseG.toInt()}g)" untuk mulai menyeduh.';
      }
    } else if (!_hasStartedPour) {
      phase = 'Tahap 3 • Siap Blooming (${bloomMl.toInt()}ml)';
      tip = 'Miringkan HP (> ${_lastTelemetry.critSpoutAngleDeg.toStringAsFixed(0)}°) atau geser tuas untuk membasahi bubuk kopi.';
    } else if (_isCompleted) {
      phase = 'Selesai • Inspeksi 3D Flat Bed';
      tip = 'Seduhan tuntas! Putar kamera 360° untuk memeriksa kerataan ampas kopi 3D.';
    } else if (_lastTelemetry.isBypassWarning) {
      phase = 'Peringatan • Filter Bypass!';
      tip = 'Aliran mengenai kertas filter! Arahkan pancuran kembali ke spiral dalam V60.';
    } else if (_lastTelemetry.flowRegime == KettleFlowRegime.turbulent) {
      phase = 'Peringatan • Aliran Turbulen!';
      tip = 'Terlalu deras (> 6.8 ml/s)! Tegakkan sedikit HP agar kembali ke zona Laminar hijau.';
    } else if (totalPoured <= bloomMl + 10.0 && _elapsedSec < bloomSec) {
      phase = 'Tahap 3 • Degassing CO2 & Swirl';
      tip = 'Goyangkan HP melingkar (Gentle Rao Swirl) atau tekan Rao Swirl untuk melepaskan gas CO2!';
    } else if (dropTempC != null && !_thermalDropTriggered && totalPoured >= (dropAtMl ?? targetWaterMl * 0.60) - 12.0) {
      phase = 'Momen Kritis • Thermal Drop!';
      tip = 'Tekan "Campur Air ${dropTempC!.toInt()}°C" sekarang untuk mengunci manis & cegah sepat!';
    } else if (totalPoured >= targetWaterMl - 2.0) {
      phase = 'Tahap 5 • Drawdown Darcy';
      tip = 'Lakukan Rao Swirl lembut terakhir selagi air turun agar membentuk 100% Flat Coffee Bed!';
    } else {
      phase = 'Tahap 4 • Laminar Spiral Pour';
      tip = 'Bagus! Ikuti cincin target emas memutar dengan aliran stabil ${idealFlowMlS.toStringAsFixed(1)} ml/s.';
    }

    snapshotNotifier.value = V603DSimulationSnapshot(
      elapsedSec: _elapsedSec,
      pouredMl: totalPoured,
      targetWaterMl: targetWaterMl,
      serverMl: bedSolver.beverageServerVolumeMl,
      slurryMl: bedSolver.slurryWaterVolumeMl,
      rinseWaterMl: _rinseWaterMl,
      remainingKettleMl: _lastTelemetry.remainingKettleMl,
      initialKettleMl: _lastTelemetry.initialKettleMl,
      flowRateMlS: _lastTelemetry.flowRateMlPerSec,
      pitchDeg: _lastTelemetry.pitchDeg,
      rollDeg: _lastTelemetry.rollDeg,
      critSpoutAngleDeg: _lastTelemetry.critSpoutAngleDeg,
      tempC: _lastTelemetry.waterTempCelsius,
      estimatedEyPct: bedSolver.estimateExtractionYieldPct(),
      acidPct: acidPct,
      sweetPct: sweetPct,
      bitterPct: bitterPct,
      laminarRatioPct: double.parse((bedSolver.laminarFlowRatio * 100.0).toStringAsFixed(1)),
      spiralEvennessPct: double.parse(bedSolver.spiralEvennessPct.toStringAsFixed(1)),
      flatBedScorePct: double.parse(bedSolver.computeFlatBedUniformityScore().toStringAsFixed(1)),
      thermalMasteryPct: double.parse(_thermalScore.toStringAsFixed(1)),
      swirlIntensity: _lastTelemetry.swirlIntensity,
      averageCo2: bedSolver.averageCo2Level(),
      paperWetnessPct: (_paperWetness * 100.0).clamp(0.0, 100.0),
      dripperLiftProgress: _dripperLiftProgress,
      serverTiltRad: _serverTiltRad,
      bypassEventsCount: bedSolver.bypassEventsCount,
      flowRegime: _lastTelemetry.flowRegime,
      interactiveStage: _stage,
      isBypassWarning: _lastTelemetry.isBypassWarning,
      isGyroHardwareActive: _lastTelemetry.isGyroHardwareActive,
      swirlPerformed: _swirlPerformed,
      isDripperLifted: _isDripperLifted,
      rinseDiscarded: _rinseDiscarded,
      coffeeGroundsAdded: _coffeeGroundsAdded,
      isCompleted: _isCompleted,
      streamImpactNormalized: Offset(
        _lastTelemetry.streamImpactNormalized.x,
        _lastTelemetry.streamImpactNormalized.y,
      ),
      activePhaseLabel: phase,
      liveCoachTip: tip,
    );
  }

  // ── Pipeline Proyeksi Perspektif 3D Real-Time ──

  Matrix4 _buildViewProjection(double w, double h) {
    final double camDist = _cameraMode == V603DCameraPerspective.xrayCutaway ? 5.6 : 5.9;
    final double eyeY = camDist * math.sin(_orbitPitchRad);
    final double horizDist = camDist * math.cos(_orbitPitchRad);
    final double eyeX = horizDist * math.sin(_orbitYawRad);
    final double eyeZ = horizDist * math.cos(_orbitYawRad);

    final view = Matrix4.identity();
    _setLookAt(view, Vector3(eyeX, eyeY + 0.1, eyeZ), Vector3(0.0, -0.05, 0.0), Vector3(0.0, 1.0, 0.0));

    final aspect = math.max(0.4, w / math.max(1.0, h));
    final proj = Matrix4.identity();
    _setPerspective(proj, 40.0 * math.pi / 180.0, aspect, 0.1, 40.0);
    return proj * view;
  }

  static void _setLookAt(Matrix4 out, Vector3 eye, Vector3 target, Vector3 up) {
    final z = (eye - target)..normalize();
    final x = up.cross(z)..normalize();
    final y = z.cross(x);
    out.setValues(
      x.x, y.x, z.x, 0.0,
      x.y, y.y, z.y, 0.0,
      x.z, y.z, z.z, 0.0,
      -x.dot(eye), -y.dot(eye), -z.dot(eye), 1.0,
    );
  }

  static void _setPerspective(Matrix4 out, double fovYRad, double aspect, double zNear, double zFar) {
    final f = 1.0 / math.tan(fovYRad / 2.0);
    out.setZero();
    out.setEntry(0, 0, f / aspect);
    out.setEntry(1, 1, f);
    out.setEntry(2, 2, (zFar + zNear) / (zNear - zFar));
    out.setEntry(2, 3, -1.0);
    out.setEntry(3, 2, (2.0 * zFar * zNear) / (zNear - zFar));
  }

  Offset _project(Vector3 world, Matrix4 vp, double w, double h) {
    final v = Vector4(world.x, world.y, world.z, 1.0);
    final clip = vp * v;
    final invW = clip.w.abs() > 1e-4 ? 1.0 / clip.w : 1.0;
    final ndcX = clip.x * invW;
    final ndcY = clip.y * invW;
    return Offset((ndcX + 1.0) * 0.5 * w, (1.0 - ndcY) * 0.5 * h);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x < 20 || size.y < 20) return;

    final w = size.x;
    final h = size.y;

    // 1. Latar Belakang Studio Café Kedai Senja Hangat
    final bgShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF281911), Color(0xFF140D09)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = bgShader);

    final vp = _buildViewProjection(w, h);
    final isCutaway = _cameraMode == V603DCameraPerspective.xrayCutaway;

    // 2. Meja Bar Kayu + Timbangan Digital Minimalis di bawah Server
    _renderBarTableAndScale(canvas, vp, w, h);

    // 3. Glass Server 3D + Kopi Cair Amber yang naik perlahan + Tetesan Darcy
    _renderGlassServer3D(canvas, vp, w, h, isCutaway: isCutaway);

    // 4. Hario V60 Ceramic / Glass Cone + Spiral Ribs
    _renderV60DripperConeBack(canvas, vp, w, h, isCutaway: isCutaway);

    // 5. Dynamic 3D 32x32 Coffee Bed Heightfield Mesh + CO2 Bloom Foam + Slurry Surface
    final double bedSurfaceY = _render3DCoffeeBedHeightfield(canvas, vp, w, h);

    // 6. Target Spiral Emas di atas Coffee Bed
    if (!_isCompleted) {
      _renderSpiralGhostTarget(canvas, vp, w, h, bedSurfaceY);
    }

    // 7. V60 Cone Front Rim (di depan bed kecuali pada potongan X-Ray)
    _renderV60DripperConeFront(canvas, vp, w, h, isCutaway: isCutaway);

    // 8. 3D Gooseneck Kettle (Fellow Stagg EKG) & 3D Parabolic Water Stream
    if (_cameraMode != V603DCameraPerspective.freeOrbit) {
      _renderKettleAndBallisticStream(canvas, vp, w, h, bedSurfaceY);
    }

    // 9. Partikel Uap Panas 3D
    for (final p in _steamParticles) {
      final pt = _project(p.pos, vp, w, h);
      canvas.drawCircle(
        pt,
        p.radius,
        Paint()..color = Colors.white.withValues(alpha: (p.life * 0.16).clamp(0.0, 0.25)),
      );
    }
  }

  void _renderBarTableAndScale(Canvas canvas, Matrix4 vp, double w, double h) {
    final padPts = <Offset>[];
    for (int i = 0; i <= 24; i++) {
      final a = (i / 24) * math.pi * 2;
      padPts.add(_project(Vector3(math.cos(a) * 1.12, -1.35, math.sin(a) * 1.12), vp, w, h));
    }
    final padPath = Path()..addPolygon(padPts, true);
    canvas.drawPath(padPath, Paint()..color = const Color(0xFF0B0705));
    canvas.drawPath(
      padPath,
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  void _renderGlassServer3D(Canvas canvas, Matrix4 vp, double w, double h, {required bool isCutaway}) {
    const double serverTopY = -0.35;
    const double serverBottomY = -1.32;
    const double rTop = 0.56;
    const double rBot = 0.78;
    const int segs = 28;

    final startAng = isCutaway ? math.pi * 0.15 : 0.0;
    final endAng = isCutaway ? math.pi * 1.35 : math.pi * 2.0;

    // Cairan air bilasan atau kopi di dalam server
    final bool showRinse = !_coffeeGroundsAdded && _rinseWaterMl > 0.5;
    final fillRatio = showRinse
        ? (_rinseWaterMl / 70.0).clamp(0.0, 0.7)
        : (bedSolver.beverageServerVolumeMl / math.max(1.0, targetWaterMl)).clamp(0.0, 1.0);
    if (fillRatio > 0.01) {
      final double liqY = serverBottomY + (serverTopY - serverBottomY - 0.12) * fillRatio;
      final double liqR = rBot + (rTop - rBot) * fillRatio;

      for (int i = 0; i < segs; i++) {
        final a0 = startAng + (endAng - startAng) * (i / segs);
        final a1 = startAng + (endAng - startAng) * ((i + 1) / segs);
        final poly = [
          _project(Vector3(math.cos(a0) * rBot, serverBottomY, math.sin(a0) * rBot), vp, w, h),
          _project(Vector3(math.cos(a1) * rBot, serverBottomY, math.sin(a1) * rBot), vp, w, h),
          _project(Vector3(math.cos(a1) * liqR, liqY, math.sin(a1) * liqR), vp, w, h),
          _project(Vector3(math.cos(a0) * liqR, liqY, math.sin(a0) * liqR), vp, w, h),
        ];
        final shade = 0.55 + 0.35 * math.sin((a0 + a1) * 0.5);
        final Color c0 = showRinse ? const Color(0xFF93C5FD) : const Color(0xFF3E180A);
        final Color c1 = showRinse ? const Color(0xFFBAE6FD) : const Color(0xFF8C3F19);
        canvas.drawPath(
          Path()..addPolygon(poly, true),
          Paint()..color = Color.lerp(c0, c1, shade.clamp(0.0, 1.0))!,
        );
      }

      final topDisk = <Offset>[];
      for (int i = 0; i <= segs; i++) {
        final a = startAng + (endAng - startAng) * (i / segs);
        topDisk.add(_project(Vector3(math.cos(a) * liqR, liqY, math.sin(a) * liqR), vp, w, h));
      }
      if (isCutaway) {
        topDisk.add(_project(Vector3(0, liqY, 0), vp, w, h));
      }
      canvas.drawPath(
        Path()..addPolygon(topDisk, true),
        Paint()
          ..color = (showRinse ? const Color(0xFF93C5FD) : const Color(0xFFA95724))
              .withValues(alpha: showRinse ? 0.55 : 0.90),
      );
    }

    // Wireframe & Glass Refraction Edges
    final glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final topRing = Path();
    final botRing = Path();
    for (int i = 0; i <= segs; i++) {
      final a = startAng + (endAng - startAng) * (i / segs);
      final pTop = _project(Vector3(math.cos(a) * rTop, serverTopY, math.sin(a) * rTop), vp, w, h);
      final pBot = _project(Vector3(math.cos(a) * rBot, serverBottomY, math.sin(a) * rBot), vp, w, h);
      if (i == 0) {
        topRing.moveTo(pTop.dx, pTop.dy);
        botRing.moveTo(pBot.dx, pBot.dy);
      } else {
        topRing.lineTo(pTop.dx, pTop.dy);
        botRing.lineTo(pBot.dx, pBot.dy);
      }
      if (i % 7 == 0) {
        canvas.drawLine(pTop, pBot, glassPaint);
      }
    }
    canvas.drawPath(topRing, glassPaint);
    canvas.drawPath(botRing, glassPaint);

    // Tetesan air perkolasi Darcy turun dari ujung cone ke permukaan server
    for (final d in _droplets) {
      final dropY = serverTopY + 0.02 - d.yNorm * (serverTopY - (serverBottomY + fillRatio * 0.78));
      final pt = _project(Vector3(0, dropY, 0), vp, w, h);
      canvas.drawCircle(pt, 3.0, Paint()..color = const Color(0xFFD98A42));
    }
  }

  void _renderV60DripperConeBack(Canvas canvas, Matrix4 vp, double w, double h, {required bool isCutaway}) {
    const int segs = 28;
    final startAng = isCutaway ? math.pi * 0.22 : math.pi;
    final endAng = isCutaway ? math.pi * 1.45 : math.pi * 2.0;
    final double liftY = _dripperLiftProgress * 0.55;

    for (int i = 0; i < segs; i++) {
      final a0 = startAng + (endAng - startAng) * (i / segs);
      final a1 = startAng + (endAng - startAng) * ((i + 1) / segs);
      final poly = [
        _project(Vector3(math.cos(a0) * 1.05, 0.45 + liftY, math.sin(a0) * 1.05), vp, w, h),
        _project(Vector3(math.cos(a1) * 1.05, 0.45 + liftY, math.sin(a1) * 1.05), vp, w, h),
        _project(Vector3(math.cos(a1) * 0.24, -0.35 + liftY, math.sin(a1) * 0.24), vp, w, h),
        _project(Vector3(math.cos(a0) * 0.24, -0.35 + liftY, math.sin(a0) * 0.24), vp, w, h),
      ];
      final Color coneBaseCol = Color.lerp(
        const Color(0xFFFAF2E8),
        const Color(0xFFD1BFA7),
        _paperWetness * 0.65,
      )!;
      canvas.drawPath(
        Path()..addPolygon(poly, true),
        Paint()..color = coneBaseCol.withValues(alpha: isCutaway ? 0.42 : 0.72),
      );
    }

    // 12 Spiral Ribs bagian dalam V60 (berputar saat Rao Swirl!)
    final ribPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 12; i++) {
      final baseA = _vortexPhase * 0.4 + (i * math.pi * 2 / 12);
      if (isCutaway && (math.sin(baseA) > 0.35)) continue;
      final path = Path();
      for (int s = 0; s <= 6; s++) {
        final t = s / 6.0;
        final r = 0.24 + t * 0.79;
        final y = -0.34 + t * 0.78;
        final a = baseA + t * 0.65;
        final p = _project(Vector3(math.cos(a) * r, y, math.sin(a) * r), vp, w, h);
        if (s == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, ribPaint);
    }
  }

  /// Merender Mesh 3D Deformable Coffee Bed Heightfield (disampel dari 32x32 Grid)
  double _render3DCoffeeBedHeightfield(Canvas canvas, Matrix4 vp, double w, double h) {
    final double liftY = _dripperLiftProgress * 0.55;
    if (!_coffeeGroundsAdded) {
      return 0.14 + liftY;
    }
    const int renderStep = 2; // 16x16 quads dari 32x32 grid
    const int n = V60BedPercolationSolver.gridSize;
    final slurryLift = (bedSolver.slurryWaterVolumeMl / 120.0).clamp(0.0, 0.28);
    final double baseBedY = -0.02 + liftY + slurryLift * 0.38;
    final double ampY = 0.32;
    final lightDir = Vector3(0.45, 0.85, 0.35)..normalize();

    double avgSurfaceY = baseBedY + 0.14;

    for (int y = 0; y < n - renderStep; y += renderStep) {
      for (int x = 0; x < n - renderStep; x += renderStep) {
        final double nx0 = (x / (n - 1)) * 2.0 - 1.0;
        final double nz0 = (y / (n - 1)) * 2.0 - 1.0;
        final double nx1 = ((x + renderStep) / (n - 1)) * 2.0 - 1.0;
        final double nz1 = ((y + renderStep) / (n - 1)) * 2.0 - 1.0;

        final double cx = (nx0 + nx1) * 0.5;
        final double cz = (nz0 + nz1) * 0.5;
        if (cx * cx + cz * cz > 0.96) continue;

        final int i00 = y * n + x;
        final int i10 = y * n + (x + renderStep);
        final int i11 = (y + renderStep) * n + (x + renderStep);
        final int i01 = (y + renderStep) * n + x;

        final double h00 = bedSolver.bedHeightGrid[i00];
        final double h10 = bedSolver.bedHeightGrid[i10];
        final double h11 = bedSolver.bedHeightGrid[i11];
        final double h01 = bedSolver.bedHeightGrid[i01];

        const double bedRadiusWorld = 0.72;
        final v00 = Vector3(nx0 * bedRadiusWorld, baseBedY + h00 * ampY, nz0 * bedRadiusWorld);
        final v10 = Vector3(nx1 * bedRadiusWorld, baseBedY + h10 * ampY, nz0 * bedRadiusWorld);
        final v11 = Vector3(nx1 * bedRadiusWorld, baseBedY + h11 * ampY, nz1 * bedRadiusWorld);
        final v01 = Vector3(nx0 * bedRadiusWorld, baseBedY + h01 * ampY, nz1 * bedRadiusWorld);

        final e1 = v10 - v00;
        final e2 = v01 - v00;
        final normal = e2.cross(e1)..normalize();
        final double lit = (normal.dot(lightDir) * 0.5 + 0.5).clamp(0.18, 1.0);

        final double co2 = bedSolver.co2BubbleGrid[i00];
        final double wet = bedSolver.localExtractionGrid[i00].clamp(0.0, 1.0);

        // Blend warna dari bubuk kering hangat -> crema blooming berbusa -> slurry espresso basah
        final Color dryColor = const Color(0xFF7B4828);
        final Color wetColor = const Color(0xFF3E1F0F);
        final Color foamColor = const Color(0xFFD6A874);
        Color baseColor = Color.lerp(dryColor, wetColor, wet)!;
        if (_hasStartedPour && co2 > 0.45 && _lastTelemetry.pouredTotalMl < bloomMl * 2.0) {
          baseColor = Color.lerp(baseColor, foamColor, (co2 - 0.45) * 0.65)!;
        }
        final Color shaded = Color.lerp(const Color(0xFF1D0E06), baseColor, lit)!;

        final poly = [
          _project(v00, vp, w, h),
          _project(v10, vp, w, h),
          _project(v11, vp, w, h),
          _project(v01, vp, w, h),
        ];
        canvas.drawPath(Path()..addPolygon(poly, true), Paint()..color = shaded);
      }
    }

    // Lapisan air slurry jernih di atas coffee bed bila menggenang
    if (slurryLift > 0.02) {
      final waterY = baseBedY + 0.19 + slurryLift * 0.42;
      avgSurfaceY = waterY;
      final waterR = 0.66 + slurryLift * 0.25;
      final ring = <Offset>[];
      for (int i = 0; i <= 24; i++) {
        final a = (i / 24) * math.pi * 2;
        ring.add(_project(Vector3(math.cos(a) * waterR, waterY, math.sin(a) * waterR), vp, w, h));
      }
      final waterCol = _thermalDropTriggered && _lastTelemetry.waterTempCelsius <= 75
          ? const Color(0xFF38BDF8).withValues(alpha: 0.28)
          : const Color(0xFFB4692E).withValues(alpha: 0.34);
      canvas.drawPath(Path()..addPolygon(ring, true), Paint()..color = waterCol);
    }

    return avgSurfaceY;
  }

  void _renderSpiralGhostTarget(Canvas canvas, Matrix4 vp, double w, double h, double bedY) {
    final targetR = 0.36 + 0.22 * math.sin(_ghostSpiralPhase * 0.5);
    final gx = math.cos(_ghostSpiralPhase) * targetR * 0.68;
    final gz = math.sin(_ghostSpiralPhase) * targetR * 0.68;
    final ghostWorld = Vector3(gx, bedY + 0.04, gz);
    final pt = _project(ghostWorld, vp, w, h);

    canvas.drawCircle(
      pt,
      14.0 + 3.0 * math.sin(_ghostSpiralPhase * 2.0),
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    canvas.drawCircle(pt, 4.0, Paint()..color = const Color(0xFFD4AF37));
  }

  void _renderV60DripperConeFront(Canvas canvas, Matrix4 vp, double w, double h, {required bool isCutaway}) {
    const int segs = 28;
    final rimPath = Path();
    final baseRimPath = Path();
    final startAng = isCutaway ? math.pi * 0.22 : 0.0;
    final endAng = isCutaway ? math.pi * 1.45 : math.pi * 2.0;

    for (int i = 0; i <= segs; i++) {
      final a = startAng + (endAng - startAng) * (i / segs);
      final pTop = _project(Vector3(math.cos(a) * 1.05, 0.45, math.sin(a) * 1.05), vp, w, h);
      final pBot = _project(Vector3(math.cos(a) * 0.24, -0.35, math.sin(a) * 0.24), vp, w, h);
      if (i == 0) {
        rimPath.moveTo(pTop.dx, pTop.dy);
        baseRimPath.moveTo(pBot.dx, pBot.dy);
      } else {
        rimPath.lineTo(pTop.dx, pTop.dy);
        baseRimPath.lineTo(pBot.dx, pBot.dy);
      }
    }

    canvas.drawPath(
      rimPath,
      Paint()
        ..color = const Color(0xFFFAF2E8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      baseRimPath,
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _renderKettleAndBallisticStream(
    Canvas canvas,
    Matrix4 vp,
    double w,
    double h,
    double bedSurfaceY,
  ) {
    final impactNorm = _lastTelemetry.streamImpactNormalized;
    final double impactWorldX = impactNorm.x * 0.66;
    final double impactWorldZ = impactNorm.y * 0.66;

    // Posisi dasar ketel melayang di kanan-atas cone + ikut orientasi 3D Gyroscope!
    final double tiltRad = (_lastTelemetry.pitchDeg * math.pi / 180.0).clamp(0.0, 1.05);
    final double rollRad = (_lastTelemetry.rollDeg * math.pi / 180.0).clamp(-0.6, 0.6);

    final kettlePos = Vector3(impactWorldX + 0.92, 1.38 - tiltRad * 0.16, impactWorldZ - 0.18);

    // Transformasi lokal ujung moncong leher angsa menggunakan rotasi pitch & roll nyata!
    final qKettle = Quaternion.euler(rollRad, 0.0, tiltRad * 0.85);
    final spoutTipLocal = Vector3(-0.76, -0.18, 0.0);
    final spoutTipWorld = kettlePos + qKettle.rotated(spoutTipLocal);

    // Gambar Badan Ketel 3D (Fellow Stagg Matte Charcoal + Brass Accent)
    final bodyBaseWorld = kettlePos + qKettle.rotated(Vector3(0.18, -0.25, 0.0));
    final bodyTopWorld = kettlePos + qKettle.rotated(Vector3(0.18, 0.25, 0.0));
    final pBase = _project(bodyBaseWorld, vp, w, h);
    final pTop = _project(bodyTopWorld, vp, w, h);
    final pSpoutBase = _project(kettlePos + qKettle.rotated(Vector3(-0.22, -0.10, 0.0)), vp, w, h);
    final pSpoutMid = _project(kettlePos + qKettle.rotated(Vector3(-0.52, -0.02, 0.0)), vp, w, h);
    final pSpoutTip = _project(spoutTipWorld, vp, w, h);
    final pHandleOut = _project(kettlePos + qKettle.rotated(Vector3(0.55, 0.05, 0.0)), vp, w, h);

    // Handle Ketel
    canvas.drawLine(
      pTop,
      pHandleOut,
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      pHandleOut,
      pBase,
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round,
    );

    // Leher Angsa (Gooseneck Spout S-curve)
    final spoutPath = Path()
      ..moveTo(pSpoutBase.dx, pSpoutBase.dy)
      ..quadraticBezierTo(pSpoutMid.dx, pSpoutMid.dy, pSpoutTip.dx, pSpoutTip.dy);
    canvas.drawPath(
      spoutPath,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.5
        ..strokeCap = StrokeCap.round,
    );

    // Badan Silinder Ketel Matte Charcoal dengan garis emas
    canvas.drawLine(
      pBase,
      pTop,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..strokeWidth = 42.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(pTop, 19.0, Paint()..color = const Color(0xFF334155));
    canvas.drawCircle(
      pTop,
      7.0,
      Paint()..color = const Color(0xFFD4AF37),
    );

    // Pancaran Air Balistik 3D Parabolik P(s) dari Spout Tip ke Coffee Bed!
    final impactWorld = Vector3(impactWorldX, bedSurfaceY + 0.02, impactWorldZ);
    final pHit = _project(impactWorld, vp, w, h);

    if (_lastTelemetry.flowRateMlPerSec > 0.2) {
      final isTurbulent = _lastTelemetry.flowRegime == KettleFlowRegime.turbulent;
      final isCold = _thermalDropTriggered && _lastTelemetry.waterTempCelsius <= 75.0;
      final Color streamColor = _lastTelemetry.isBypassWarning
          ? const Color(0xFFEF4444)
          : (isCold ? const Color(0xFF38BDF8) : const Color(0xFFE0F2FE));

      final streamPath = Path()..moveTo(pSpoutTip.dx, pSpoutTip.dy);
      for (int i = 1; i <= 14; i++) {
        final s = i / 14.0;
        final px = spoutTipWorld.x + (impactWorld.x - spoutTipWorld.x) * s;
        final pz = spoutTipWorld.z + (impactWorld.z - spoutTipWorld.z) * s;
        // Kurva jatuh gravitasi parabolik (-0.5 * g * s^2)
        final py = spoutTipWorld.y + (impactWorld.y - spoutTipWorld.y) * (s * s);
        final pt = _project(Vector3(px, py, pz), vp, w, h);
        streamPath.lineTo(pt.dx, pt.dy);
      }

      canvas.drawPath(
        streamPath,
        Paint()
          ..color = streamColor.withValues(alpha: 0.88)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (2.2 + (_lastTelemetry.flowRateMlPerSec / 12.0) * 4.5).clamp(2.2, 7.5)
          ..strokeCap = StrokeCap.round,
      );

      // Efek tumbukan air di permukaan ampas kopi
      canvas.drawCircle(
        pHit,
        isTurbulent ? 14.0 : 8.0,
        Paint()
          ..color = streamColor.withValues(alpha: isTurbulent ? 0.55 : 0.35)
          ..style = isTurbulent ? PaintingStyle.stroke : PaintingStyle.fill
          ..strokeWidth = 2.0,
      );
    } else {
      // Crosshair posisi siap tuang sebelum ketel dimiringkan melewati theta_crit
      canvas.drawCircle(
        pHit,
        6.5,
        Paint()
          ..color = Colors.white54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }
}
