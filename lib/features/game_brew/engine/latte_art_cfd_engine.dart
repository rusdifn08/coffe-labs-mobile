import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../domain/game_brew_studio_models.dart';
import 'transparent_vessel_slosh_solver.dart';

class LatteArtWlacGrade {
  final double contrastPct;
  final double symmetryPct;
  final double patternFidelityPct;
  final double fillAccuracyPct;
  final double overallScorePct;
  final int stars;
  final bool spilled;

  const LatteArtWlacGrade({
    required this.contrastPct,
    required this.symmetryPct,
    required this.patternFidelityPct,
    required this.fillAccuracyPct,
    required this.overallScorePct,
    required this.stars,
    required this.spilled,
  });

  Map<String, double> toMetricsMap() => {
        'contrastPct': contrastPct,
        'symmetryPct': symmetryPct,
        'fidelityPct': patternFidelityPct,
        'fillPct': fillAccuracyPct,
        'overall': overallScorePct,
      };
}

/// Real 2D Incompressible Navier-Stokes CFD Engine (Jos Stam's Stable Fluids)
/// for Coffee Labs Latte Art 3D Simulator v2.0.
///
/// Pre-allocated `Float32List` velocity, pressure, foam density & `Uint8List`
/// RGBA pixel buffer => ZERO GC allocation per frame, 100% numerically stable,
/// circular cup no-slip boundary conditions, Dive-vs-Float buoyancy law,
/// Gyroscope Wiggle Vorticity, and automated WLAC Pattern Grader!
class LatteArtCfdEngine {
  static const int n = 64;
  static const int _cellCount = n * n;

  // Fluid fields (pre-allocated)
  final Float32List u = Float32List(_cellCount);
  final Float32List v = Float32List(_cellCount);
  final Float32List uPrev = Float32List(_cellCount);
  final Float32List vPrev = Float32List(_cellCount);
  final Float32List foam = Float32List(_cellCount);
  final Float32List foamPrev = Float32List(_cellCount);
  final Float32List cremaTone = Float32List(_cellCount);
  final Float32List p = Float32List(_cellCount);
  final Float32List div = Float32List(_cellCount);
  final Uint8List rgbaBuffer = Uint8List(_cellCount * 4);

  // Transparent Milk Pitcher Slosh Solver (dual-layer milk + microfoam)
  late final TransparentVesselSloshSolver pitcherSlosh;

  // Cup state
  final double cupCapacityMl;
  final double espressoBaseMl;
  double cupVolumeMl = 36.0;
  double pourHeightCm = 5.0; // 0.5 cm (Float) .. 8.0 cm (Dive)
  Offset pourPos = const Offset(0.0, 0.05); // normalized cup coords [-0.8..0.8]
  Offset _prevPourPos = const Offset(0.0, 0.05);
  double milkFoamRemainingFraction = 1.0;
  bool spilled = false;
  double highPourCanvasMl = 0.0;
  double accidentalEarlyFoamPenalty = 0.0;
  double elapsedSec = 0.0;

  LatteArtCfdEngine({
    this.cupCapacityMl = 200.0,
    this.espressoBaseMl = 36.0,
  }) {
    pitcherSlosh = TransparentVesselSloshSolver(
      radiusMeters: 0.042,
      maxHeightMeters: 0.105,
      capacityMl: 300.0,
      initialVolumeMl: 240.0,
      dampingRatio: 0.24, // Creamier microfoam damping
    );
    reset();
  }

  double get cupFillPct =>
      ((cupVolumeMl / cupCapacityMl) * 100.0).clamp(0.0, 120.0);

  /// Dive-vs-Float buoyancy coefficient alpha_float in [0, 1].
  /// High pour (H > 3.5 cm) => dives cleanly under crema (~0.0).
  /// Low pour (H <= 1.3 cm) => floats velvety white microfoam on surface (~1.0).
  double computeFloatFactor(double heightCm, double flowMlS) {
    const double hCrit = 2.2;
    final double sigmoid = 1.0 / (1.0 + math.exp((heightCm - hCrit) / 0.45));
    final double flowBoost = 1.0 - 0.35 * math.exp(-flowMlS / 4.0);
    return (sigmoid * flowBoost).clamp(0.0, 1.0);
  }

  void reset() {
    u.fillRange(0, _cellCount, 0.0);
    v.fillRange(0, _cellCount, 0.0);
    uPrev.fillRange(0, _cellCount, 0.0);
    vPrev.fillRange(0, _cellCount, 0.0);
    foam.fillRange(0, _cellCount, 0.0);
    foamPrev.fillRange(0, _cellCount, 0.0);
    p.fillRange(0, _cellCount, 0.0);
    div.fillRange(0, _cellCount, 0.0);

    // Rich tiger-striped espresso crema canvas
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) {
        final double nx = (i / (n - 1)) * 2.0 - 1.0;
        final double ny = (j / (n - 1)) * 2.0 - 1.0;
        final double r = math.sqrt(nx * nx + ny * ny);
        final double swirlNoise =
            0.5 + 0.5 * math.sin(nx * 5.0 + ny * 3.0 + r * 4.0);
        cremaTone[j * n + i] = (0.18 + 0.14 * swirlNoise).clamp(0.0, 1.0);
      }
    }

    pitcherSlosh.reset(newVolumeMl: 240.0);
    cupVolumeMl = espressoBaseMl;
    pourHeightCm = 5.0;
    pourPos = const Offset(0.0, 0.04);
    _prevPourPos = pourPos;
    milkFoamRemainingFraction = 1.0;
    spilled = false;
    highPourCanvasMl = 0.0;
    accidentalEarlyFoamPenalty = 0.0;
    elapsedSec = 0.0;
    renderToRgbaBuffer();
  }

  /// Advances the 2D Incompressible Navier-Stokes fluid simulation by [dt].
  void step({
    required double dt,
    required double pitchDeg,
    required double rollDeg,
    double wiggleAngularVel = 0.0,
  }) {
    final double safeDt = dt.clamp(0.004, 0.025);
    elapsedSec += safeDt;

    final double flowMlS = pitcherSlosh.step(
      dt: safeDt,
      pitchDeg: pitchDeg,
      rollDeg: rollDeg,
      lateralAccelZ: wiggleAngularVel * 0.45,
      maxFlowMlS: 16.5,
    );

    if (flowMlS > 0.25) {
      final double addedMl = flowMlS * safeDt;
      cupVolumeMl += addedMl;
      if (cupVolumeMl > cupCapacityMl + 6.0) {
        spilled = true;
      }

      final double alphaFloat = computeFloatFactor(pourHeightCm, flowMlS);
      final bool isEarlyCanvasPhase = cupVolumeMl < cupCapacityMl * 0.52;
      if (isEarlyCanvasPhase && alphaFloat < 0.22) {
        highPourCanvasMl += addedMl;
      } else if (isEarlyCanvasPhase && alphaFloat > 0.55) {
        accidentalEarlyFoamPenalty += addedMl * 0.25;
      }

      // Microfoam ratio depletes gradually when floating white foam
      if (alphaFloat > 0.35) {
        milkFoamRemainingFraction =
            (milkFoamRemainingFraction - addedMl * 0.0042).clamp(0.15, 1.0);
      }

      _injectPourSource(
        dt: safeDt,
        flowMlS: flowMlS,
        alphaFloat: alphaFloat,
        wiggleVel: wiggleAngularVel,
      );
    }

    // 1. Velocity Viscosity Diffusion & Incompressible Pressure Projection
    _diffuse(1, uPrev, u, 0.00018, safeDt, 4);
    _diffuse(2, vPrev, v, 0.00018, safeDt, 4);
    _project(uPrev, vPrev, p, div, 10);

    // 2. Semi-Lagrangian Velocity Self-Advection + Second Projection
    _advect(1, u, uPrev, uPrev, vPrev, safeDt);
    _advect(2, v, vPrev, uPrev, vPrev, safeDt);
    _project(u, v, p, div, 10);

    // Gentle viscous damping so foam settles smoothly like real velvety milk
    for (int i = 0; i < _cellCount; i++) {
      u[i] *= 0.968;
      v[i] *= 0.968;
    }

    // 3. Microfoam Scalar Diffusion & Semi-Lagrangian Advection
    _diffuse(0, foamPrev, foam, 0.00004, safeDt, 2);
    _advect(0, foam, foamPrev, u, v, safeDt);

    _prevPourPos = pourPos;
    renderToRgbaBuffer();
  }

  void _injectPourSource({
    required double dt,
    required double flowMlS,
    required double alphaFloat,
    required double wiggleVel,
  }) {
    final double cx = ((pourPos.dx + 1.0) * 0.5) * (n - 1);
    final double cy = ((pourPos.dy + 1.0) * 0.5) * (n - 1);

    final Offset moveDelta = pourPos - _prevPourPos;
    final double pushDirX = (moveDelta.dx * 22.0 + wiggleVel * 0.9).clamp(-6.0, 6.0);
    // Forward pull-through drag or gentle forward push into the cup
    final double pushDirY =
        (moveDelta.dy * 24.0 - 1.35 * (flowMlS / 12.0)).clamp(-6.5, 6.5);

    // Radius narrower when pouring high (sharp Pull-Through Cut!), wider when low
    final double radiusCells = alphaFloat > 0.45 ? 4.4 : 2.6;
    final int rInt = radiusCells.ceil() + 1;
    final int iMin = math.max(1, cx.floor() - rInt);
    final int iMax = math.min(n - 2, cx.ceil() + rInt);
    final int jMin = math.max(1, cy.floor() - rInt);
    final int jMax = math.min(n - 2, cy.ceil() + rInt);

    final double jetStrength = (flowMlS / 11.0).clamp(0.2, 1.5);
    final double foamStrength =
        alphaFloat * milkFoamRemainingFraction * jetStrength;

    for (int j = jMin; j <= jMax; j++) {
      for (int i = iMin; i <= iMax; i++) {
        final double dx = i - cx;
        final double dy = j - cy;
        final double d2 = dx * dx + dy * dy;
        final double weight =
            math.exp(-d2 / (radiusCells * radiusCells * 0.55));
        if (weight < 0.02) continue;

        final int idx = j * n + i;

        // Radial expansion force (low pour pushes crema outward symmetrically)
        final double invDist = 1.0 / math.sqrt(d2 + 0.5);
        final double radial = alphaFloat * 2.2 * jetStrength;

        u[idx] += (pushDirX + dx * invDist * radial) * weight * dt * 26.0;
        v[idx] += (pushDirY + dy * invDist * radial) * weight * dt * 26.0;

        if (alphaFloat > 0.25) {
          foam[idx] =
              (foam[idx] + foamStrength * weight * dt * 7.2).clamp(0.0, 1.0);
        } else {
          // High pour integrates golden crema smoothly without bright white blobs
          cremaTone[idx] =
              (cremaTone[idx] + 0.25 * weight * dt).clamp(0.0, 0.72);
          // Slight foam wash-under if high pour cuts across existing foam
          foam[idx] = (foam[idx] * (1.0 - 0.14 * weight * dt)).clamp(0.0, 1.0);
        }
      }
    }
  }

  void _diffuse(
    int b,
    Float32List x,
    Float32List x0,
    double diff,
    double dt,
    int iters,
  ) {
    final double a = dt * diff * (n - 2) * (n - 2);
    final double invDiv = 1.0 / (1.0 + 4.0 * a);
    for (int i = 0; i < _cellCount; i++) {
      x[i] = x0[i];
    }
    for (int k = 0; k < iters; k++) {
      for (int j = 1; j < n - 1; j++) {
        final int row = j * n;
        for (int i = 1; i < n - 1; i++) {
          final int idx = row + i;
          x[idx] = (x0[idx] +
                  a * (x[idx - 1] + x[idx + 1] + x[idx - n] + x[idx + n])) *
              invDiv;
        }
      }
      _setCircularBoundary(b, x);
    }
  }

  void _project(
    Float32List velU,
    Float32List velV,
    Float32List press,
    Float32List divergence,
    int iters,
  ) {
    const double h = 1.0 / n;
    for (int j = 1; j < n - 1; j++) {
      final int row = j * n;
      for (int i = 1; i < n - 1; i++) {
        final int idx = row + i;
        divergence[idx] = -0.5 *
            h *
            (velU[idx + 1] - velU[idx - 1] + velV[idx + n] - velV[idx - n]);
        press[idx] = 0.0;
      }
    }
    _setCircularBoundary(0, divergence);
    _setCircularBoundary(0, press);

    for (int k = 0; k < iters; k++) {
      for (int j = 1; j < n - 1; j++) {
        final int row = j * n;
        for (int i = 1; i < n - 1; i++) {
          final int idx = row + i;
          press[idx] = (divergence[idx] +
                  press[idx - 1] +
                  press[idx + 1] +
                  press[idx - n] +
                  press[idx + n]) *
              0.25;
        }
      }
      _setCircularBoundary(0, press);
    }

    const double inv2h = 0.5 * n;
    for (int j = 1; j < n - 1; j++) {
      final int row = j * n;
      for (int i = 1; i < n - 1; i++) {
        final int idx = row + i;
        velU[idx] -= inv2h * (press[idx + 1] - press[idx - 1]);
        velV[idx] -= inv2h * (press[idx + n] - press[idx - n]);
      }
    }
    _setCircularBoundary(1, velU);
    _setCircularBoundary(2, velV);
  }

  void _advect(
    int b,
    Float32List d,
    Float32List d0,
    Float32List velU,
    Float32List velV,
    double dt,
  ) {
    final double dt0 = dt * (n - 2);
    const double maxCoord = n - 1.5;

    for (int j = 1; j < n - 1; j++) {
      final int row = j * n;
      for (int i = 1; i < n - 1; i++) {
        final int idx = row + i;
        double x = (i - dt0 * velU[idx]).clamp(0.5, maxCoord);
        double y = (j - dt0 * velV[idx]).clamp(0.5, maxCoord);

        final int i0 = x.floor();
        final int i1 = i0 + 1;
        final int j0 = y.floor();
        final int j1 = j0 + 1;

        final double s1 = x - i0;
        final double s0 = 1.0 - s1;
        final double t1 = y - j0;
        final double t0 = 1.0 - t1;

        d[idx] = s0 * (t0 * d0[j0 * n + i0] + t1 * d0[j1 * n + i0]) +
            s1 * (t0 * d0[j0 * n + i1] + t1 * d0[j1 * n + i1]);
      }
    }
    _setCircularBoundary(b, d);
  }

  /// No-slip circular cup wall boundary so fluid organically curls along the rim!
  void _setCircularBoundary(int b, Float32List field) {
    const double half = (n - 1) * 0.5;
    const double maxR = half - 1.5;
    const double maxR2 = maxR * maxR;

    for (int j = 0; j < n; j++) {
      final double dy = j - half;
      final int row = j * n;
      for (int i = 0; i < n; i++) {
        final double dx = i - half;
        if (dx * dx + dy * dy >= maxR2) {
          if (b == 1 || b == 2) {
            field[row + i] = 0.0;
          } else {
            field[row + i] *= 0.85;
          }
        }
      }
    }
  }

  /// Writes warm golden crema + velvety white microfoam into `rgbaBuffer` (0 GC).
  void renderToRgbaBuffer() {
    const double half = (n - 1) * 0.5;
    final double cupR = half - 0.5;

    for (int j = 0; j < n; j++) {
      final double ny = (j - half) / cupR;
      final int row = j * n;
      for (int i = 0; i < n; i++) {
        final double nx = (i - half) / cupR;
        final double r = math.sqrt(nx * nx + ny * ny);
        final int idx = row + i;
        final int pIdx = idx * 4;

        if (r > 1.0) {
          rgbaBuffer[pIdx] = 0;
          rgbaBuffer[pIdx + 1] = 0;
          rgbaBuffer[pIdx + 2] = 0;
          rgbaBuffer[pIdx + 3] = 0;
          continue;
        }

        final double f = foam[idx].clamp(0.0, 1.0);
        // Smooth S-curve contrast like silky milk foam on hazelnut crema
        final double fSmooth = f * f * (3.0 - 2.0 * f);
        final double tone = cremaTone[idx];

        // Espresso Crema base (#7C431C -> warm latte gold #A86B3A as milk mixes)
        final double baseR = 124.0 + tone * 58.0;
        final double baseG = 67.0 + tone * 46.0;
        final double baseB = 28.0 + tone * 32.0;

        // Velvety Microfoam white (#FAF6EE)
        double rCol = baseR + (250.0 - baseR) * fSmooth;
        double gCol = baseG + (246.0 - baseG) * fSmooth;
        double bCol = baseB + (238.0 - baseB) * fSmooth;

        // Soft ceramic inner rim shading for 3D depth
        final double rimShade = r > 0.84 ? (1.0 - (r - 0.84) * 1.65) : 1.0;
        // Subtle top-left studio specular sheen
        final double spec =
            math.exp(-((nx + 0.35) * (nx + 0.35) + (ny + 0.35) * (ny + 0.35)) * 4.5) *
                18.0;

        rgbaBuffer[pIdx] = (rCol * rimShade + spec).clamp(0.0, 255.0).toInt();
        rgbaBuffer[pIdx + 1] =
            (gCol * rimShade + spec).clamp(0.0, 255.0).toInt();
        rgbaBuffer[pIdx + 2] =
            (bCol * rimShade + spec).clamp(0.0, 255.0).toInt();
        rgbaBuffer[pIdx + 3] = 255;
      }
    }
  }

  /// Automated WLAC Pattern Grader (Contrast 25% + Symmetry 25% + Fidelity 35% + Fill 15%).
  LatteArtWlacGrade evaluateCup(LatteArtPattern target) {
    // 1. Bilateral Symmetry & Gradient Contrast
    double symDiff = 0.0;
    double symSum = 0.0;
    double gradSum = 0.0;
    double foamTotal = 0.0;
    int innerCount = 0;

    double dotProd = 0.0;
    double normActual = 0.0;
    double normTemplate = 0.0;

    const double half = (n - 1) * 0.5;
    final double cupR = half - 1.5;

    for (int j = 2; j < n - 2; j++) {
      final double ny = (j - half) / cupR;
      for (int i = 2; i < n - 2; i++) {
        final double nx = (i - half) / cupR;
        if (nx * nx + ny * ny > 0.92) continue;

        final int idx = j * n + i;
        final double c = foam[idx];
        final int mirrorI = (n - 1 - i).clamp(0, n - 1);
        final double cMirror = foam[j * n + mirrorI];

        symDiff += (c - cMirror).abs();
        symSum += c + cMirror;
        foamTotal += c;
        innerCount++;

        final double gx = foam[idx + 1] - foam[idx - 1];
        final double gy = foam[idx + n] - foam[idx - n];
        gradSum += math.sqrt(gx * gx + gy * gy);

        final double tmpl = _samplePatternTemplate(target, nx, ny);
        dotProd += c * tmpl;
        normActual += c * c;
        normTemplate += tmpl * tmpl;
      }
    }

    // Special case: Level 1 Canvas Base wants clean uniform golden crema (minimal white foam!)
    if (target == LatteArtPattern.canvasBase) {
      final double avgFoam = innerCount > 0 ? foamTotal / innerCount : 0.0;
      final double cleanScore = (100.0 - avgFoam * 320.0).clamp(20.0, 100.0);
      final double fillScore = _computeFillScore(targetFillPct: 65.0);
      final double overall =
          (cleanScore * 0.65 + fillScore * 0.35 - (spilled ? 25.0 : 0.0))
              .clamp(0.0, 100.0);
      return LatteArtWlacGrade(
        contrastPct: cleanScore,
        symmetryPct: 95.0,
        patternFidelityPct: cleanScore,
        fillAccuracyPct: fillScore,
        overallScorePct: overall,
        stars: _starsFor(overall),
        spilled: spilled,
      );
    }

    final double symmetryPct = symSum > 1.0
        ? ((1.0 - (symDiff / (symSum + 0.0001))) * 100.0).clamp(0.0, 100.0)
        : 20.0;

    final double avgGrad = innerCount > 0 ? gradSum / innerCount : 0.0;
    final double contrastPct = ((avgGrad * 420.0) - accidentalEarlyFoamPenalty)
        .clamp(15.0, 100.0);

    final double fidelityPct = (normActual > 0.5 && normTemplate > 0.5)
        ? ((dotProd / math.sqrt(normActual * normTemplate)) * 112.0)
            .clamp(0.0, 100.0)
        : 10.0;

    final double fillPct = _computeFillScore(targetFillPct: 95.0);

    final double overall = (contrastPct * 0.25 +
            symmetryPct * 0.25 +
            fidelityPct * 0.35 +
            fillPct * 0.15 -
            (spilled ? 22.0 : 0.0))
        .clamp(0.0, 100.0);

    return LatteArtWlacGrade(
      contrastPct: contrastPct,
      symmetryPct: symmetryPct,
      patternFidelityPct: fidelityPct,
      fillAccuracyPct: fillPct,
      overallScorePct: overall,
      stars: _starsFor(overall),
      spilled: spilled,
    );
  }

  double _computeFillScore({required double targetFillPct}) {
    if (spilled) return 35.0;
    final double err = (cupFillPct - targetFillPct).abs();
    return (100.0 - err * 1.8).clamp(15.0, 100.0);
  }

  int _starsFor(double score) {
    if (score >= 82.0) return 3;
    if (score >= 66.0) return 2;
    if (score >= 50.0) return 1;
    return 0;
  }

  /// Analytical normalized reference silhouette for WLAC Pattern Fidelity grading.
  static double _samplePatternTemplate(
    LatteArtPattern target,
    double nx,
    double ny,
  ) {
    switch (target) {
      case LatteArtPattern.canvasBase:
        return 0.0;
      case LatteArtPattern.monksHead:
        final double r2 = nx * nx + ny * ny;
        return r2 <= 0.26 ? 1.0 : 0.0;
      case LatteArtPattern.heart:
        // Implicit heart curve (inverted y so point faces bottom/front)
        final double x = nx * 1.45;
        final double y = -ny * 1.45 + 0.1;
        final double a = x * x + y * y - 0.55;
        return (a * a * a - x * x * y * y * y) <= 0.0 ? 1.0 : 0.0;
      case LatteArtPattern.twoStackTulip:
      case LatteArtPattern.threeStackTulip:
      case LatteArtPattern.wingedFiveTulip:
        final double baseArc =
            (ny > -0.15 && ny < 0.55 && (nx * nx * 1.2 + (ny - 0.15) * (ny - 0.15) * 2.2) < 0.45)
                ? 1.0
                : 0.0;
        final double topHeart =
            (nx * nx * 2.6 + (ny + 0.28) * (ny + 0.28) * 2.6) < 0.22 ? 1.0 : 0.0;
        return math.max(baseArc, topHeart);
      case LatteArtPattern.wingedBase:
        final double r2 = nx * nx * 0.9 + (ny - 0.12) * (ny - 0.12) * 1.9;
        return r2 < 0.46 ? 1.0 : 0.0;
      case LatteArtPattern.rosetta:
      case LatteArtPattern.slowsetta:
        final double widthAtY = (0.48 - (ny + 0.55).abs() * 0.35).clamp(0.08, 0.52);
        final double leafWave =
            0.5 + 0.5 * math.sin(ny * (target == LatteArtPattern.slowsetta ? 12.0 : 20.0));
        return (nx.abs() < widthAtY * (0.65 + 0.35 * leafWave) && ny > -0.65 && ny < 0.65)
            ? 1.0
            : 0.0;
      case LatteArtPattern.swan:
        // Right wing + curved neck + upper left head
        final bool wing = nx > -0.15 &&
            nx < 0.68 &&
            ny > -0.15 &&
            ny < 0.58 &&
            ((nx - 0.25) * (nx - 0.25) + (ny - 0.2) * (ny - 0.2) < 0.26);
        final bool neck = (nx + 0.18 + 0.12 * math.sin(ny * 4.5)).abs() < 0.09 &&
            ny > -0.58 &&
            ny < 0.35;
        final bool head =
            (nx + 0.14) * (nx + 0.14) + (ny + 0.54) * (ny + 0.54) < 0.032;
        return (wing || neck || head) ? 1.0 : 0.0;
    }
  }
}
