import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../domain/game_brew_studio_models.dart';
import 'transparent_vessel_slosh_solver.dart';

enum ManualBrewPhase {
  wetFilter,
  rdtSpritz,
  doseAndDivot,
  precisionPour,
  swirlAndResult,
}

/// Complete 5-Phase Manual Brew 3D Physics Engine (Game Brew Studio v2.0).
/// Zero per-frame heap allocation inside the step loop.
class ManualBrew3DPhysicsEngine {
  static const int gridSize = 32;
  static const int filterSegments = 36;

  final GameBrewLevelSpec spec;
  late final TransparentVesselSloshSolver kettleSlosh;

  // Phase 1: Paper Filter Saturation & Rinse Discard
  final Float32List filterWetness = Float32List(filterSegments);
  double rinseWaterInServerMl = 0.0;
  double serverTempC = 25.0;
  bool rinseDiscarded = false;

  // Phase 2: RDT Electrostatic Fines Retention
  int rdtSpritzCount = 0;
  bool rdtCompleted = false;

  // Phase 3: Granular 32x32 Bed Heightfield & Center Divot
  final Float32List bedHeight = Float32List(gridSize * gridSize);
  final Float32List wetnessMap = Float32List(gridSize * gridSize);
  final Float32List co2Map = Float32List(gridSize * gridSize);
  bool groundsDosed = false;
  double centerDivotDepthMm = 0.0; // Ideal: 4.0 - 9.0 mm

  // Phase 4: Precision Pouring, Rayleigh-Plateau & Pattern Accuracy
  ManualBrewPhase phase = ManualBrewPhase.wetFilter;
  double elapsedPourSec = 0.0;
  double pouredCoffeeWaterMl = 0.0;
  double slurryMl = 0.0;
  double serverCoffeeMl = 0.0;
  double pourHeightCm = 7.0; // > 11 cm triggers Rayleigh-Plateau breakup!
  double activeWaterTempC = 92.0;
  Offset aimPos = Offset.zero; // normalized [-0.95..0.95]
  Offset _prevAimPos = Offset.zero;

  double finesCloggingFactor = 0.0;
  int bypassCount = 0;
  double _bypassCooldown = 0.0;
  double _laminarTimeSec = 0.0;
  double _totalPourTimeSec = 0.0;
  double _flowErrSqSum = 0.0;
  int _flowSampleCount = 0;

  // Pattern Trajectory Tracking (Circular CW, Reverse CCW, Zigzag, Center, Pulse 4:6)
  double _patternScoreAccum = 0.0;
  double _patternSampleSec = 0.0;
  int _zigzagDir = 0;
  int _zigzagReversals = 0;
  int _pulseCount = 0;
  bool _wasPouringLastFrame = false;

  // Phase 5: Rao Swirl & Extraction
  bool raoSwirlDone = false;
  double swirlProgress = 0.0;
  double swirlAngularVel = 0.0; // rad/s slurry vortex rotation
  double swirlPhaseRad = 0.0;
  double bloomDomeFactor = 0.0; // 0..1 CO2 bloom expansion dome
  final Float32List _wetScratch = Float32List(gridSize * gridSize);
  final Float32List _filterScratch = Float32List(filterSegments);
  final List<Offset> recentPourTrail = [];

  ManualBrew3DPhysicsEngine({required this.spec}) {
    kettleSlosh = TransparentVesselSloshSolver(
      capacityMl: math.max(350.0, spec.targetWaterMl + 110.0),
      initialVolumeMl: math.max(350.0, spec.targetWaterMl + 110.0),
      dampingRatio: 0.14,
    );
    reset();
  }

  void reset() {
    kettleSlosh.reset(
      newVolumeMl: math.max(350.0, spec.targetWaterMl + 110.0),
    );
    filterWetness.fillRange(0, filterSegments, 0.0);
    rinseWaterInServerMl = 0.0;
    serverTempC = 25.0;
    rinseDiscarded = false;

    rdtSpritzCount = 0;
    rdtCompleted = false;

    groundsDosed = false;
    centerDivotDepthMm = 0.0;
    _initBedHeightfield(withDivot: false);

    elapsedPourSec = 0.0;
    pouredCoffeeWaterMl = 0.0;
    slurryMl = 0.0;
    serverCoffeeMl = 0.0;
    pourHeightCm = 6.5;
    activeWaterTempC = spec.waterTempC;
    aimPos = Offset.zero;
    _prevAimPos = Offset.zero;

    finesCloggingFactor = spec.highFinesMode ? 0.16 : 0.0;
    bypassCount = 0;
    _bypassCooldown = 0.0;
    _laminarTimeSec = 0.0;
    _totalPourTimeSec = 0.0;
    _flowErrSqSum = 0.0;
    _flowSampleCount = 0;
    _patternScoreAccum = 0.0;
    _patternSampleSec = 0.0;
    _zigzagDir = 0;
    _zigzagReversals = 0;
    _pulseCount = 0;
    _wasPouringLastFrame = false;

    raoSwirlDone = false;
    swirlProgress = 0.0;
    swirlAngularVel = 0.0;
    swirlPhaseRad = 0.0;
    bloomDomeFactor = 0.0;
    recentPourTrail.clear();

    // Direct technique drills skip straight to precision pouring unless ritual drill!
    if (spec.requirePreBrewRitual) {
      phase = ManualBrewPhase.wetFilter;
    } else {
      filterWetness.fillRange(0, filterSegments, 1.0);
      serverTempC = 64.0;
      rinseDiscarded = true;
      rdtSpritzCount = 2;
      rdtCompleted = true;
      groundsDosed = true;
      centerDivotDepthMm = 6.5;
      _initBedHeightfield(withDivot: true);
      phase = ManualBrewPhase.precisionPour;
    }
  }

  void _initBedHeightfield({required bool withDivot}) {
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final double nx = (x / (gridSize - 1)) * 2.0 - 1.0;
        final double ny = (y / (gridSize - 1)) * 2.0 - 1.0;
        final double r = math.sqrt(nx * nx + ny * ny);
        final int idx = y * gridSize + x;
        if (r <= 1.0) {
          // Angle of repose mound ~34 deg + optional sculpted center divot
          double h = 0.56 - 0.10 * r;
          if (withDivot) {
            h -= 0.18 * math.exp(-r * r * 7.5);
          }
          bedHeight[idx] = h.clamp(0.15, 0.85);
          wetnessMap[idx] = 0.0;
          co2Map[idx] = 1.0;
        } else {
          bedHeight[idx] = 0.0;
          wetnessMap[idx] = 0.0;
          co2Map[idx] = 0.0;
        }
      }
    }
  }

  // ---- PHASE 1 ACTIONS ----
  double get paperWetnessPct {
    double sum = 0.0;
    for (int i = 0; i < filterSegments; i++) {
      sum += filterWetness[i];
    }
    return (sum / filterSegments) * 100.0;
  }

  bool get isFilterReadyToDiscard => paperWetnessPct >= 95.0;

  void discardRinseWater() {
    rinseWaterInServerMl = 0.0;
    rinseDiscarded = true;
    phase = ManualBrewPhase.rdtSpritz;
  }

  // ---- PHASE 2 ACTIONS (RDT) ----
  void spritzRdt() {
    rdtSpritzCount++;
    if (rdtSpritzCount >= 1 && rdtSpritzCount <= 2) {
      finesCloggingFactor = math.max(0.0, finesCloggingFactor - 0.06);
    } else if (rdtSpritzCount >= 5) {
      finesCloggingFactor = math.min(0.45, finesCloggingFactor + 0.08);
    }
  }

  String get rdtStatusLabel {
    if (rdtSpritzCount == 0) return 'Belum disemprot (risiko statis fines)';
    if (rdtSpritzCount <= 2) return 'RDT Optimal (-22% fines retention!)';
    if (rdtSpritzCount <= 4) return 'Sedikit lembap (masih aman)';
    return 'Terlalu basah! Peringatan burr lengket';
  }

  void completeRdtAndMoveToDosing() {
    rdtCompleted = true;
    if (rdtSpritzCount == 0) {
      finesCloggingFactor = math.min(0.45, finesCloggingFactor + 0.12);
    }
    phase = ManualBrewPhase.doseAndDivot;
  }

  // ---- PHASE 3 ACTIONS (DOSING & FINGER CENTER DIVOT) ----
  void doseGroundsIntoV60() {
    groundsDosed = true;
    _initBedHeightfield(withDivot: false);
  }

  /// Called when user presses near the center of the V60 cone to sculpt a Center Divot.
  void sculptDivotAt(Offset normalizedPos) {
    if (!groundsDosed) doseGroundsIntoV60();
    final double distFromCenter = normalizedPos.distance;
    if (distFromCenter > 0.55) return;

    centerDivotDepthMm = (centerDivotDepthMm + 1.6).clamp(0.0, 10.5);
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final double nx = (x / (gridSize - 1)) * 2.0 - 1.0;
        final double ny = (y / (gridSize - 1)) * 2.0 - 1.0;
        final double r = math.sqrt(nx * nx + ny * ny);
        if (r > 1.0) continue;
        final double dx = nx - normalizedPos.dx;
        final double dy = ny - normalizedPos.dy;
        final double d2 = dx * dx + dy * dy;
        final int idx = y * gridSize + x;
        bedHeight[idx] =
            (bedHeight[idx] - 0.055 * math.exp(-d2 * 9.0)).clamp(0.14, 0.85);
      }
    }
  }

  bool get isDivotOptimal =>
      centerDivotDepthMm >= 4.0 && centerDivotDepthMm <= 9.0;

  void finishDosingAndStartPouring() {
    if (!groundsDosed) doseGroundsIntoV60();
    kettleSlosh.reset(
      newVolumeMl: math.max(350.0, spec.targetWaterMl + 90.0),
    );
    phase = ManualBrewPhase.precisionPour;
  }

  // ---- PHASE 4 & 1 REAL-TIME TICK ----
  bool get isRayleighBreakup =>
      kettleSlosh.currentFlowMlS > 0.3 && pourHeightCm > 11.0;

  void step({
    required double dt,
    required double pitchDeg,
    required double rollDeg,
    double lateralAccelX = 0.0,
    double lateralAccelZ = 0.0,
  }) {
    final double safeDt = dt.clamp(0.001, 0.04);
    if (_bypassCooldown > 0.0) {
      _bypassCooldown = math.max(0.0, _bypassCooldown - safeDt);
    }

    final double flow = kettleSlosh.step(
      dt: safeDt,
      pitchDeg: pitchDeg,
      rollDeg: rollDeg,
      lateralAccelX: lateralAccelX,
      lateralAccelZ: lateralAccelZ,
      maxFlowMlS: 10.5,
    );

    // Phase 1: Wet Paper Filter circumference + Capillary Wicking Diffusion
    if (phase == ManualBrewPhase.wetFilter) {
      if (flow > 0.25) {
        rinseWaterInServerMl += flow * safeDt;
        serverTempC = (serverTempC + flow * safeDt * 0.95).clamp(25.0, 68.0);
        final double angle = math.atan2(aimPos.dy, aimPos.dx);
        final double normA = (angle + math.pi) / (2.0 * math.pi);
        final int centerSeg =
            (normA * filterSegments).floor().clamp(0, filterSegments - 1);
        for (int offset = -5; offset <= 5; offset++) {
          final int s = (centerSeg + offset) % filterSegments;
          final int wrapped = s < 0 ? s + filterSegments : s;
          final double falloff = math.exp(-(offset * offset) / 10.5);
          filterWetness[wrapped] =
              (filterWetness[wrapped] + flow * safeDt * 0.19 * falloff)
                  .clamp(0.0, 1.0);
        }
      }
      // Natural capillary wicking across adjacent Japanese paper fibers!
      const double wickRate = 0.85;
      for (int i = 0; i < filterSegments; i++) {
        final int prev = (i - 1 + filterSegments) % filterSegments;
        final int next = (i + 1) % filterSegments;
        final double avg = (filterWetness[prev] + filterWetness[next]) * 0.5;
        final double w = filterWetness[i];
        _filterScratch[i] = avg > w
            ? (w + (avg - w) * wickRate * safeDt).clamp(0.0, 1.0)
            : w;
      }
      filterWetness.setAll(0, _filterScratch);
      return;
    }

    if (phase != ManualBrewPhase.precisionPour) return;

    // Dual-temp drop (Lv. 8 Sherry Hsu)
    if (spec.dropTempC != null &&
        pouredCoffeeWaterMl >= spec.targetWaterMl * 0.65) {
      activeWaterTempC = spec.dropTempC!;
    }

    if (flow > 0.25 || pouredCoffeeWaterMl > 0.5) {
      elapsedPourSec += safeDt;
    }

    final bool isPouringNow = flow > 0.35;
    if (isPouringNow && !_wasPouringLastFrame) {
      _pulseCount++;
    }
    _wasPouringLastFrame = isPouringNow;

    if (isPouringNow) {
      final double added = flow * safeDt;
      pouredCoffeeWaterMl += added;
      slurryMl += added;
      _totalPourTimeSec += safeDt;

      final bool breakup = pourHeightCm > 11.0;
      final bool turbulent = flow > 6.8 || breakup;
      if (!turbulent) {
        _laminarTimeSec += safeDt;
      } else {
        finesCloggingFactor =
            (finesCloggingFactor + 0.035 * safeDt).clamp(0.0, 0.55);
      }

      // Track flow variance vs ideal
      final double diff = flow - spec.idealFlowMlS;
      _flowErrSqSum += diff * diff;
      _flowSampleCount++;

      // Record visual pour trail
      recentPourTrail.add(aimPos);
      if (recentPourTrail.length > 48) {
        recentPourTrail.removeAt(0);
      }

      // Bypass check
      final double rHit = aimPos.distance;
      if (rHit > 0.86 && _bypassCooldown <= 0.0) {
        bypassCount++;
        _bypassCooldown = 1.1;
      }

      // Pattern accuracy scoring
      _scorePourPatternStep(safeDt, aimPos, _prevAimPos);

      // Update 32x32 Wetness Map, CO2 Bloom Dome, Vortex Torque & Cratering
      final double divotBoost = isDivotOptimal ? 1.18 : 1.0;
      final Offset aimDelta = aimPos - _prevAimPos;
      final double tangTorque =
          (aimPos.dx * aimDelta.dy - aimPos.dy * aimDelta.dx) * 32.0;
      swirlAngularVel =
          (swirlAngularVel + tangTorque * (flow / 6.0)).clamp(-6.5, 6.5);

      double bloomRelease = 0.0;
      for (int y = 0; y < gridSize; y++) {
        for (int x = 0; x < gridSize; x++) {
          final double nx = (x / (gridSize - 1)) * 2.0 - 1.0;
          final double ny = (y / (gridSize - 1)) * 2.0 - 1.0;
          if (nx * nx + ny * ny > 1.0) continue;
          final double dx = nx - aimPos.dx;
          final double dy = ny - aimPos.dy;
          final double d2 = dx * dx + dy * dy;
          final int idx = y * gridSize + x;

          final double hit = math.exp(-d2 / 0.17);
          final double prevCo2 = co2Map[idx];
          wetnessMap[idx] =
              (wetnessMap[idx] + flow * safeDt * 0.25 * hit * divotBoost)
                  .clamp(0.0, 1.0);
          co2Map[idx] = (prevCo2 - 0.34 * safeDt * hit).clamp(0.0, 1.0);
          bloomRelease += (prevCo2 - co2Map[idx]) * wetnessMap[idx];

          // Gentle bloom puffing on fresh grounds vs turbulent cratering on high pour
          if (turbulent) {
            bedHeight[idx] =
                (bedHeight[idx] - 0.032 * safeDt * hit).clamp(0.12, 0.9);
          } else if (prevCo2 > 0.55) {
            bedHeight[idx] =
                (bedHeight[idx] + 0.018 * safeDt * hit).clamp(0.14, 0.88);
          }
        }
      }
      bloomDomeFactor =
          (bloomDomeFactor + bloomRelease * 0.045).clamp(0.0, 1.0);
    }

    // Smooth capillary wetting diffusion across coffee bed + swirl damping
    if (slurryMl > 0.4 || pouredCoffeeWaterMl > 1.0) {
      for (int y = 1; y < gridSize - 1; y++) {
        final int row = y * gridSize;
        for (int x = 1; x < gridSize - 1; x++) {
          final int idx = row + x;
          final double avg = (wetnessMap[idx - 1] +
                  wetnessMap[idx + 1] +
                  wetnessMap[idx - gridSize] +
                  wetnessMap[idx + gridSize]) *
              0.25;
          final double cur = wetnessMap[idx];
          _wetScratch[idx] = avg > cur
              ? (cur + (avg - cur) * 0.55 * safeDt).clamp(0.0, 1.0)
              : cur;
        }
      }
      for (int y = 1; y < gridSize - 1; y++) {
        final int row = y * gridSize;
        for (int x = 1; x < gridSize - 1; x++) {
          wetnessMap[row + x] = _wetScratch[row + x];
        }
      }
    }

    bloomDomeFactor = (bloomDomeFactor * (1.0 - 0.14 * safeDt)).clamp(0.0, 1.0);
    swirlPhaseRad += swirlAngularVel * safeDt;
    swirlAngularVel *= (1.0 - 1.35 * safeDt).clamp(0.0, 1.0);

    _prevAimPos = aimPos;

    // Darcy percolation drawdown from slurry into server
    if (slurryMl > 0.2) {
      final double permeability = (1.0 - finesCloggingFactor).clamp(0.35, 1.0);
      final double drainRate =
          (1.6 + 0.042 * slurryMl) * permeability; // ml/s
      final double drained = math.min(slurryMl, drainRate * safeDt);
      slurryMl -= drained;
      serverCoffeeMl += drained;
    }
  }

  void _scorePourPatternStep(double dt, Offset cur, Offset prev) {
    final ManualPourPattern pattern =
        spec.manualPattern ?? ManualPourPattern.circularCw;
    final Offset delta = cur - prev;
    final double speed = delta.distance;
    final double r = cur.distance;
    double stepQuality = 0.72;

    if (r > 0.86) {
      stepQuality = 0.22; // Bypass penalty
    } else {
      switch (pattern) {
        case ManualPourPattern.circularCw:
          // Screen coords (y downward): cross = x*dy - y*dx > 0 is clockwise!
          final double crossCw = (cur.dx * delta.dy) - (cur.dy * delta.dx);
          if (r >= 0.15 && r <= 0.78 && crossCw > 0.0005) {
            stepQuality = 1.0;
          } else if (speed > 0.002) {
            stepQuality = 0.65;
          }
          break;
        case ManualPourPattern.reverseCircularCcw:
          // Cross < 0 is counter-clockwise!
          final double crossCcw = (cur.dx * delta.dy) - (cur.dy * delta.dx);
          if (r >= 0.15 && r <= 0.78 && crossCcw < -0.0005) {
            stepQuality = 1.0;
          } else if (speed > 0.002) {
            stepQuality = 0.65;
          }
          break;
        case ManualPourPattern.zigzag:
          if (delta.dx.abs() > 0.004) {
            final int dir = delta.dx > 0 ? 1 : -1;
            if (_zigzagDir != 0 && dir != _zigzagDir) {
              _zigzagReversals++;
            }
            _zigzagDir = dir;
            stepQuality = 0.96;
          } else {
            stepQuality = 0.68;
          }
          break;
        case ManualPourPattern.centerOsmotic:
          stepQuality = r <= 0.25 ? 1.0 : (r <= 0.45 ? 0.78 : 0.45);
          break;
        case ManualPourPattern.pulse46:
        case ManualPourPattern.spiralSwirl:
          stepQuality = (r <= 0.78 && speed > 0.001) ? 0.96 : 0.78;
          break;
      }
    }

    _patternScoreAccum += stepQuality * dt;
    _patternSampleSec += dt;
  }

  /// Performs Gentle Rao Swirl using Laplacian bed height diffusion.
  void applyGentleRaoSwirl({double intensity = 1.0}) {
    raoSwirlDone = true;
    swirlProgress = (swirlProgress + 0.34 * intensity).clamp(0.0, 1.0);

    final Float32List copy = Float32List.fromList(bedHeight);
    const double diffusion = 0.32;
    for (int y = 1; y < gridSize - 1; y++) {
      for (int x = 1; x < gridSize - 1; x++) {
        final int idx = y * gridSize + x;
        final double h = copy[idx];
        if (h <= 0.02) continue;
        double sum = 0.0;
        int n = 0;
        for (final int nIdx in [idx - 1, idx + 1, idx - gridSize, idx + gridSize]) {
          if (copy[nIdx] > 0.02) {
            sum += (copy[nIdx] - h);
            n++;
          }
        }
        if (n > 0) {
          bedHeight[idx] = (h + diffusion * (sum / n)).clamp(0.12, 0.9);
        }
      }
    }
  }

  // ---- SCIENTIFIC METRICS & EVALUATION ----
  double get wettingCoveragePct {
    int wet = 0;
    int total = 0;
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final double nx = (x / (gridSize - 1)) * 2.0 - 1.0;
        final double ny = (y / (gridSize - 1)) * 2.0 - 1.0;
        if (nx * nx + ny * ny > 1.0) continue;
        total++;
        if (wetnessMap[y * gridSize + x] >= 0.85) wet++;
      }
    }
    return total > 0 ? (wet / total) * 100.0 : 0.0;
  }

  double get flatBedScorePct {
    double sum = 0.0;
    int count = 0;
    for (int i = 0; i < bedHeight.length; i++) {
      if (bedHeight[i] > 0.02) {
        sum += bedHeight[i];
        count++;
      }
    }
    if (count == 0) return 85.0;
    final double mean = sum / count;
    double varSum = 0.0;
    for (int i = 0; i < bedHeight.length; i++) {
      if (bedHeight[i] > 0.02) {
        final double d = bedHeight[i] - mean;
        varSum += d * d;
      }
    }
    final double stdDev = math.sqrt(varSum / count);
    return (100.0 - stdDev * 260.0).clamp(45.0, 100.0);
  }

  double get flowStabilityPct {
    if (_flowSampleCount == 0) return 100.0;
    final double variance = _flowErrSqSum / _flowSampleCount;
    const double sigmaTol = 2.2;
    return (100.0 * math.exp(-variance / (2.0 * sigmaTol * sigmaTol)))
        .clamp(35.0, 100.0);
  }

  double get laminarRatioPct => _totalPourTimeSec > 0
      ? ((_laminarTimeSec / _totalPourTimeSec) * 100.0).clamp(0.0, 100.0)
      : 100.0;

  double get patternAccuracyPct {
    if (_patternSampleSec <= 0.1) return 0.0;
    double base = (_patternScoreAccum / _patternSampleSec) * 100.0;
    if (spec.manualPattern == ManualPourPattern.zigzag && _zigzagReversals >= 4) {
      base = math.min(100.0, base + 6.0);
    }
    if (spec.manualPattern == ManualPourPattern.pulse46 && _pulseCount >= 3) {
      base = math.min(100.0, base + 6.0);
    }
    return base.clamp(0.0, 100.0);
  }

  double get estimatedEyPct {
    final double waterRatio =
        (pouredCoffeeWaterMl / math.max(1.0, spec.targetWaterMl))
            .clamp(0.0, 1.35);
    final double tempBonus = (activeWaterTempC - 86.0) * 0.18;
    final double baseEy = 15.5 +
        (waterRatio * 3.8) +
        ((wettingCoveragePct / 100.0) * 1.4) +
        tempBonus -
        (finesCloggingFactor * 2.5);
    return baseEy.clamp(12.0, 25.0);
  }

  double get estimatedTdsPct {
    if (pouredCoffeeWaterMl <= 5.0) return 0.0;
    return ((spec.doseGrams * (estimatedEyPct / 100.0)) /
            math.max(40.0, pouredCoffeeWaterMl) *
            100.0)
        .clamp(0.5, 2.2);
  }

  Map<String, double> finishAndEvaluate() {
    phase = ManualBrewPhase.swirlAndResult;
    final double waterAccuracy = (100.0 -
            ((pouredCoffeeWaterMl - spec.targetWaterMl).abs() /
                    math.max(1.0, spec.targetWaterMl)) *
                120.0)
        .clamp(0.0, 100.0);
    final double ritualScore = spec.requirePreBrewRitual
        ? (((rinseDiscarded ? 35.0 : 10.0) +
                ((rdtSpritzCount >= 1 && rdtSpritzCount <= 2) ? 35.0 : 18.0) +
                (isDivotOptimal ? 30.0 : 15.0))
            .clamp(0.0, 100.0))
        : 100.0;
    final double eyScore =
        (estimatedEyPct >= 18.0 && estimatedEyPct <= 22.0) ? 100.0 : 72.0;

    final double overall = (waterAccuracy * 0.22 +
            wettingCoveragePct * 0.20 +
            patternAccuracyPct * 0.22 +
            flowStabilityPct * 0.14 +
            flatBedScorePct * 0.12 +
            ritualScore * 0.05 +
            eyScore * 0.05 -
            bypassCount * 3.0)
        .clamp(0.0, 100.0);

    final int stars = overall >= 86.0
        ? 3
        : (overall >= 72.0 ? 2 : (overall >= 55.0 ? 1 : 0));

    return {
      'overall': overall,
      'stars': stars.toDouble(),
      'wettingPct': wettingCoveragePct,
      'patternPct': patternAccuracyPct,
      'stabilityPct': flowStabilityPct,
      'flatBedPct': flatBedScorePct,
      'laminarPct': laminarRatioPct,
      'eyPct': estimatedEyPct,
      'tdsPct': estimatedTdsPct,
      'waterAccPct': waterAccuracy,
    };
  }
}
