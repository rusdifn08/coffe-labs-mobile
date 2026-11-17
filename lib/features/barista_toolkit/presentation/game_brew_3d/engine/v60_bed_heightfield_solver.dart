import 'dart:math' as math;
import 'dart:typed_data';

import 'package:vector_math/vector_math_64.dart';

/// Solver Heightfield 3D 32x32 permukaan ampas kopi V60, degassing CO2,
/// deteksi erosi kawah (cratering), perkolasi Hukum Darcy, bypass tepi filter,
/// serta pemerataan difusi Laplacian saat pemain melakukan Gentle Rao Swirl.
class V60BedPercolationSolver {
  static const int gridSize = 32;

  final Float32List bedHeightGrid = Float32List(gridSize * gridSize);
  final Float32List co2BubbleGrid = Float32List(gridSize * gridSize);
  final Float32List localExtractionGrid = Float32List(gridSize * gridSize);

  double slurryWaterVolumeMl = 0.0;
  double beverageServerVolumeMl = 0.0;
  double finesChokeFactor = 0.0;

  double acidExtracted = 0.0;
  double sweetExtracted = 0.0;
  double bitterExtracted = 0.0;

  int bypassEventsCount = 0;
  double _bypassCooldown = 0.0;
  double _laminarTime = 0.0;
  double _totalPourTime = 0.0;
  double _spiralAccum = 0.0;
  double _spiralSamples = 0.0;
  Vector2 _prevImpactPos = Vector2.zero();

  V60BedPercolationSolver() {
    resetCoffeeBed();
  }

  void resetCoffeeBed() {
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final double nx = (x / (gridSize - 1)) * 2.0 - 1.0;
        final double ny = (y / (gridSize - 1)) * 2.0 - 1.0;
        final double r = math.sqrt(nx * nx + ny * ny);
        final int idx = y * gridSize + x;

        if (r <= 1.0) {
          // Gundukan bubuk kopi segar awal dengan lekukan tengah (well) untuk blooming
          bedHeightGrid[idx] = 0.50 - 0.08 * math.exp(-r * r * 6.0);
          co2BubbleGrid[idx] = 1.0;
          localExtractionGrid[idx] = 0.0;
        } else {
          bedHeightGrid[idx] = 0.0;
          co2BubbleGrid[idx] = 0.0;
          localExtractionGrid[idx] = 0.0;
        }
      }
    }

    slurryWaterVolumeMl = 0.0;
    beverageServerVolumeMl = 0.0;
    finesChokeFactor = 0.0;
    acidExtracted = 0.0;
    sweetExtracted = 0.0;
    bitterExtracted = 0.0;
    bypassEventsCount = 0;
    _bypassCooldown = 0.0;
    _laminarTime = 0.0;
    _totalPourTime = 0.0;
    _spiralAccum = 0.0;
    _spiralSamples = 0.0;
    _prevImpactPos = Vector2.zero();
  }

  void stepPercolation({
    required double dt,
    required double inflowRateMlSec,
    required Vector2 impactPos,
    required double swirlIntensity,
    required double waterTempC,
    required double targetWaterMl,
    required double totalPouredMl,
    bool thermalDropActive = false,
  }) {
    final clampedDt = dt.clamp(0.001, 0.05);
    if (_bypassCooldown > 0.0) {
      _bypassCooldown = (_bypassCooldown - clampedDt).clamp(0.0, 2.0);
    }

    slurryWaterVolumeMl += inflowRateMlSec * clampedDt;

    if (inflowRateMlSec > 0.25) {
      _totalPourTime += clampedDt;
      final bool isTurbulent = inflowRateMlSec > 6.8;
      if (!isTurbulent) {
        _laminarTime += clampedDt;
      } else {
        finesChokeFactor = (finesChokeFactor + 0.045 * clampedDt).clamp(0.0, 0.55);
      }

      final double rHit = impactPos.length;
      final double moved = impactPos.distanceTo(_prevImpactPos);

      if (rHit > 0.88) {
        _spiralAccum += 0.30 * clampedDt;
        if (_bypassCooldown <= 0.0) {
          bypassEventsCount++;
          _bypassCooldown = 1.25;
        }
      } else if (isTurbulent) {
        _spiralAccum += 0.55 * clampedDt;
      } else if (rHit >= 0.14 && rHit <= 0.74 && moved > 0.002) {
        _spiralAccum += 1.0 * clampedDt;
      } else {
        _spiralAccum += 0.78 * clampedDt;
      }
      _spiralSamples += clampedDt;

      // Erosi kawah (Laplacian of Gaussian) & degassing CO2 lokal
      const double sigmaSq = 0.048;
      final double tempFactor = ((waterTempC - 65.0) / 30.0).clamp(0.25, 1.2);
      for (int y = 0; y < gridSize; y++) {
        for (int x = 0; x < gridSize; x++) {
          final double nx = (x / (gridSize - 1)) * 2.0 - 1.0;
          final double ny = (y / (gridSize - 1)) * 2.0 - 1.0;
          if (nx * nx + ny * ny > 1.0) continue;

          final double dx = nx - impactPos.x;
          final double dy = ny - impactPos.y;
          final double distSq = dx * dx + dy * dy;
          final int idx = y * gridSize + x;

          final double wave = (1.0 - distSq / sigmaSq) * math.exp(-distSq / (2.0 * sigmaSq));
          bedHeightGrid[idx] = (bedHeightGrid[idx] - 0.022 * inflowRateMlSec * clampedDt * wave).clamp(0.08, 0.92);

          final double hitGaussian = math.exp(-distSq / 0.14);
          co2BubbleGrid[idx] = (co2BubbleGrid[idx] - 0.45 * clampedDt * hitGaussian).clamp(0.0, 1.0);
          localExtractionGrid[idx] =
              (localExtractionGrid[idx] + 0.095 * clampedDt * hitGaussian * tempFactor).clamp(0.0, 1.5);
        }
      }
    }

    _prevImpactPos = impactPos.clone();

    // Difusi Laplacian dengan kondisi batas Neumann (zero-flux terhadap dinding cone V60)
    if (swirlIntensity > 0.05 && slurryWaterVolumeMl > 8.0) {
      final Float32List copyGrid = Float32List.fromList(bedHeightGrid);
      final double diffusionRate = 2.4 * swirlIntensity * clampedDt;

      for (int y = 1; y < gridSize - 1; y++) {
        for (int x = 1; x < gridSize - 1; x++) {
          final int idx = y * gridSize + x;
          final double h = copyGrid[idx];
          if (h <= 0.02) continue;

          double diffSum = 0.0;
          int activeNbrs = 0;
          final neighbors = [idx - 1, idx + 1, idx - gridSize, idx + gridSize];
          for (final nIdx in neighbors) {
            final double nh = copyGrid[nIdx];
            if (nh > 0.02) {
              diffSum += (nh - h);
              activeNbrs++;
            }
          }
          if (activeNbrs > 0) {
            final double avgNbr = h + (diffSum / activeNbrs);
            final double alpha = (diffusionRate * 1.8).clamp(0.0, 0.45);
            bedHeightGrid[idx] = (h + alpha * (avgNbr - h)).clamp(0.15, 0.85);
          }
        }
      }
    }

    // Hukum Darcy: drawdown keluar dari cone ke glass server + ekstraksi bertahap
    if (slurryWaterVolumeMl > 0.01) {
      final double darcyConductivity = 0.40 * (1.0 - finesChokeFactor);
      final double outflowRateMlSec = darcyConductivity * math.sqrt(slurryWaterVolumeMl);
      final double drainedMl = math.min(slurryWaterVolumeMl, outflowRateMlSec * clampedDt);
      slurryWaterVolumeMl -= drainedMl;
      beverageServerVolumeMl += drainedMl;

      final double tempFactor = ((waterTempC - 65.0) / 30.0).clamp(0.30, 1.20);
      final double progress = (totalPouredMl / math.max(1.0, targetWaterMl)).clamp(0.0, 1.0);
      if (progress < 0.32) {
        acidExtracted += drainedMl * 0.52 * tempFactor;
      } else if (progress < 0.76) {
        sweetExtracted += drainedMl * 0.64 * tempFactor;
        acidExtracted += drainedMl * 0.12 * tempFactor;
      } else {
        final double bitterShield = thermalDropActive && waterTempC <= 75.0 ? 0.25 : 1.0;
        bitterExtracted += drainedMl * 0.44 * tempFactor * bitterShield;
        sweetExtracted += drainedMl * 0.34 * tempFactor;
      }
    }
  }

  /// Rata-rata gelembung gas CO2 blooming tersisa [0..1]
  double averageCo2Level() {
    double sum = 0.0;
    int count = 0;
    for (int i = 0; i < co2BubbleGrid.length; i++) {
      if (bedHeightGrid[i] > 0.02) {
        sum += co2BubbleGrid[i];
        count++;
      }
    }
    return count > 0 ? (sum / count).clamp(0.0, 1.0) : 0.0;
  }

  double get laminarFlowRatio =>
      _totalPourTime > 0.05 ? (_laminarTime / _totalPourTime).clamp(0.0, 1.0) : 1.0;

  double get spiralEvennessPct {
    final base = _spiralSamples > 0.05 ? (_spiralAccum / _spiralSamples) * 100.0 : 100.0;
    return (base - bypassEventsCount * 3.5).clamp(25.0, 100.0);
  }

  /// Skor kerataan ampas kopi 3D (Flat Coffee Bed Uniformity Score 0..100%).
  double computeFlatBedUniformityScore() {
    double sum = 0.0;
    int count = 0;
    for (int i = 0; i < bedHeightGrid.length; i++) {
      if (bedHeightGrid[i] > 0.05) {
        sum += bedHeightGrid[i];
        count++;
      }
    }
    if (count == 0) return 100.0;
    final double mean = sum / count;
    double varianceSum = 0.0;
    for (int i = 0; i < bedHeightGrid.length; i++) {
      if (bedHeightGrid[i] > 0.05) {
        final double diff = bedHeightGrid[i] - mean;
        varianceSum += diff * diff;
      }
    }
    final double stdDev = math.sqrt(varianceSum / count);
    return (100.0 * (1.0 - (stdDev / 0.22))).clamp(0.0, 100.0);
  }

  double estimateExtractionYieldPct() {
    final total = acidExtracted + sweetExtracted + bitterExtracted;
    if (beverageServerVolumeMl < 5.0 || total <= 0.0) return 0.0;
    final sweetShare = (sweetExtracted / total) * 100.0;
    final flatScore = computeFlatBedUniformityScore();
    final ey = 17.8 +
        (sweetShare - 35.0) * 0.075 +
        (flatScore - 75.0) * 0.045 -
        bypassEventsCount * 0.35;
    return double.parse(ey.clamp(15.2, 23.8).toStringAsFixed(1));
  }
}
