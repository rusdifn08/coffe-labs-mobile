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

  String get rankBadge {
    if (overallScorePct >= 90) return 'SSR';
    if (overallScorePct >= 80) return 'SR';
    if (overallScorePct >= 68) return 'S';
    if (overallScorePct >= 52) return 'A';
    return 'B';
  }

  Map<String, double> toMetricsMap() => {
        'contrastPct': contrastPct,
        'symmetryPct': symmetryPct,
        'fidelityPct': patternFidelityPct,
        'fillPct': fillAccuracyPct,
        'overall': overallScorePct,
      };
}

/// High-Definition 112x112 2D Incompressible Navier-Stokes CFD Engine
/// (Jos Stam's Stable Fluids) with crisp razor-sharp crema-foam boundary,
/// concentric Tulip/Rosetta advection, stream impact dimple shading,
/// and 3D rim overflow drip tracking!
class LatteArtCfdEngine {
  static const int n = 112;
  static const int _cellCount = n * n;

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

  /// Normalized angles around front rim where excess milk/crema spilled over.
  final Float32List rimSpillDrops = Float32List(7);

  late final TransparentVesselSloshSolver pitcherSlosh;

  final double cupCapacityMl;
  final double espressoBaseMl;
  double cupVolumeMl = 36.0;
  double pourHeightCm = 4.6; // > 3.2 cm = Dive/Cut, <= 1.6 cm = Float/Pattern
  Offset pourPos = const Offset(0.0, 0.05);
  Offset _prevPourPos = const Offset(0.0, 0.05);
  double milkFoamRemainingFraction = 1.0;
  bool spilled = false;
  double spillAmountMl = 0.0;
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
      initialVolumeMl: 250.0,
      dampingRatio: 0.24,
    );
    reset();
  }

  double get cupFillPct =>
      ((cupVolumeMl / cupCapacityMl) * 100.0).clamp(0.0, 125.0);

  double computeFloatFactor(double heightCm, double flowMlS) {
    const double hCrit = 2.25;
    final double sigmoid = 1.0 / (1.0 + math.exp((heightCm - hCrit) / 0.42));
    final double flowBoost = 1.0 - 0.30 * math.exp(-flowMlS / 3.8);
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
    rimSpillDrops.fillRange(0, rimSpillDrops.length, 0.0);

    // Rich velvety roasted espresso crema marbled texture
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) {
        final double nx = (i / (n - 1)) * 2.0 - 1.0;
        final double ny = (j / (n - 1)) * 2.0 - 1.0;
        final double r = math.sqrt(nx * nx + ny * ny);
        final double tiger = 0.5 +
            0.3 * math.sin(nx * 4.5 + ny * 3.2) +
            0.2 * math.cos(r * 6.5 - nx * 2.0);
        cremaTone[j * n + i] = (0.14 + 0.16 * tiger).clamp(0.0, 1.0);
      }
    }

    pitcherSlosh.reset(newVolumeMl: 250.0);
    cupVolumeMl = espressoBaseMl;
    pourHeightCm = 4.6;
    pourPos = const Offset(0.0, 0.04);
    _prevPourPos = pourPos;
    milkFoamRemainingFraction = 1.0;
    spilled = false;
    spillAmountMl = 0.0;
    highPourCanvasMl = 0.0;
    accidentalEarlyFoamPenalty = 0.0;
    elapsedSec = 0.0;
    renderToRgbaBuffer();
  }

  void step({
    required double dt,
    required double pitchDeg,
    required double rollDeg,
    double wiggleAngularVel = 0.0,
    double lateralAccelX = 0.0,
  }) {
    final double safeDt = dt.clamp(0.004, 0.025);
    elapsedSec += safeDt;

    final double flowMlS = pitcherSlosh.step(
      dt: safeDt,
      pitchDeg: pitchDeg,
      rollDeg: rollDeg,
      lateralAccelX: lateralAccelX,
      lateralAccelZ: wiggleAngularVel * 0.45,
      maxFlowMlS: 17.0,
    );

    if (flowMlS > 0.22) {
      final double addedMl = flowMlS * safeDt;
      cupVolumeMl += addedMl;

      // Realistic Rim Overflow Spill Physics (matching 69s-70s of reference video!)
      if (cupVolumeMl > cupCapacityMl + 3.0) {
        spilled = true;
        spillAmountMl += addedMl;
        for (int k = 0; k < rimSpillDrops.length; k++) {
          final double rate = 0.28 + (k % 3) * 0.14;
          rimSpillDrops[k] = (rimSpillDrops[k] + safeDt * rate).clamp(0.0, 1.0);
        }
      }

      final double alphaFloat = computeFloatFactor(pourHeightCm, flowMlS);
      final bool isEarlyCanvasPhase = cupVolumeMl < cupCapacityMl * 0.50;
      if (isEarlyCanvasPhase && alphaFloat < 0.22) {
        highPourCanvasMl += addedMl;
      } else if (isEarlyCanvasPhase && alphaFloat > 0.55) {
        accidentalEarlyFoamPenalty += addedMl * 0.22;
      }

      if (alphaFloat > 0.35) {
        milkFoamRemainingFraction =
            (milkFoamRemainingFraction - addedMl * 0.0038).clamp(0.18, 1.0);
      }

      _injectPourSource(
        dt: safeDt,
        flowMlS: flowMlS,
        alphaFloat: alphaFloat,
        wiggleVel: wiggleAngularVel,
      );
    }

    // High-stability Jos Stam solver on 112x112 grid
    _diffuse(1, uPrev, u, 0.00014, safeDt, 3);
    _diffuse(2, vPrev, v, 0.00014, safeDt, 3);
    _project(uPrev, vPrev, p, div, 8);

    _advect(1, u, uPrev, uPrev, vPrev, safeDt);
    _advect(2, v, vPrev, uPrev, vPrev, safeDt);
    _project(u, v, p, div, 8);

    // Silky microfoam viscous settling so tulip stacks stay razor-crisp!
    for (int i = 0; i < _cellCount; i++) {
      u[i] *= 0.962;
      v[i] *= 0.962;
    }

    _diffuse(0, foamPrev, foam, 0.000018, safeDt, 2);
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
    final double pushDirX =
        (moveDelta.dx * 26.0 + wiggleVel * 1.05).clamp(-7.5, 7.5);
    // Forward push toward front of cup (+Y in screen cup space) or pull-through drag
    final double pushDirY = (moveDelta.dy * 28.0 +
            (alphaFloat > 0.45 ? 1.55 * (flowMlS / 12.0) : 0.0))
        .clamp(-8.0, 8.0);

    final double radiusCells = alphaFloat > 0.45 ? 6.8 : 3.2;
    final int rInt = radiusCells.ceil() + 1;
    final int iMin = math.max(1, cx.floor() - rInt);
    final int iMax = math.min(n - 2, cx.ceil() + rInt);
    final int jMin = math.max(1, cy.floor() - rInt);
    final int jMax = math.min(n - 2, cy.ceil() + rInt);

    final double jetStrength = (flowMlS / 10.5).clamp(0.22, 1.55);
    final double foamStrength =
        alphaFloat * milkFoamRemainingFraction * jetStrength;

    for (int j = jMin; j <= jMax; j++) {
      for (int i = iMin; i <= iMax; i++) {
        final double dx = i - cx;
        final double dy = j - cy;
        final double d2 = dx * dx + dy * dy;
        final double weight =
            math.exp(-d2 / (radiusCells * radiusCells * 0.52));
        if (weight < 0.015) continue;

        final int idx = j * n + i;
        final double invDist = 1.0 / math.sqrt(d2 + 0.65);
        final double radial = alphaFloat * 2.55 * jetStrength;

        u[idx] += (pushDirX + dx * invDist * radial) * weight * dt * 24.0;
        v[idx] += (pushDirY + dy * invDist * radial) * weight * dt * 24.0;

        if (alphaFloat > 0.25) {
          // Concentric ring contrast: center deposits pure foam while outer rim gently clears dark ring!
          foam[idx] =
              (foam[idx] + foamStrength * weight * dt * 8.4).clamp(0.0, 1.0);
        } else {
          cremaTone[idx] =
              (cremaTone[idx] + 0.22 * weight * dt).clamp(0.0, 0.68);
          // Thin Pull-Through Cut slices & pulls crema line cleanly
          foam[idx] = (foam[idx] * (1.0 - 0.28 * weight * dt)).clamp(0.0, 1.0);
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
        final double x = (i - dt0 * velU[idx]).clamp(0.5, maxCoord);
        final double y = (j - dt0 * velV[idx]).clamp(0.5, maxCoord);

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
            field[row + i] *= 0.82;
          }
        }
      }
    }
  }

  /// Renders smooth anti-aliased 112x112 espresso crema + crisp silky microfoam
  /// + pouring stream indentation dimple into `rgbaBuffer`.
  void renderToRgbaBuffer() {
    const double half = (n - 1) * 0.5;
    final double cupR = half - 0.5;
    final bool pouring = pitcherSlosh.currentFlowMlS > 0.25;

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

        // Sharp oil-paint-like meniscus edge between espresso crema & white microfoam!
        final double rawF = foam[idx].clamp(0.0, 1.0);
        final double sharpF =
            (1.0 / (1.0 + math.exp(-(rawF - 0.34) * 13.5))).clamp(0.0, 1.0);
        final double tone = cremaTone[idx];

        // Rich velvety hazelnut espresso crema (#783E18 -> #9E5C2E)
        final double baseR = 120.0 + tone * 46.0;
        final double baseG = 62.0 + tone * 38.0;
        final double baseB = 24.0 + tone * 24.0;

        // Silky steamed milk microfoam (#FCF9F2)
        double rCol = baseR + (252.0 - baseR) * sharpF;
        double gCol = baseG + (249.0 - baseG) * sharpF;
        double bCol = baseB + (242.0 - baseB) * sharpF;

        // Realistic stream impact indentation shadow (visible in reference video!)
        if (pouring) {
          final double dxP = nx - pourPos.dx;
          final double dyP = ny - pourPos.dy;
          final double d2P = dxP * dxP + dyP * dyP;
          final double dimple = 1.0 - 0.16 * math.exp(-d2P / 0.012);
          rCol *= dimple;
          gCol *= dimple;
          bCol *= dimple;
        }

        // Inner ceramic meniscus contact shadow + soft studio sheen
        final double rimShade =
            r > 0.88 ? (1.0 - (r - 0.88) * 1.85).clamp(0.65, 1.0) : 1.0;
        final double spec = math.exp(
              -((nx + 0.30) * (nx + 0.30) + (ny + 0.34) * (ny + 0.34)) * 5.2,
            ) *
            14.0;

        // Smooth sub-pixel alpha anti-aliasing along circular rim!
        final int alpha = r > 0.975
            ? (((1.0 - r) / 0.025) * 255.0).clamp(0.0, 255.0).toInt()
            : 255;

        rgbaBuffer[pIdx] = (rCol * rimShade + spec).clamp(0.0, 255.0).toInt();
        rgbaBuffer[pIdx + 1] =
            (gCol * rimShade + spec).clamp(0.0, 255.0).toInt();
        rgbaBuffer[pIdx + 2] =
            (bCol * rimShade + spec).clamp(0.0, 255.0).toInt();
        rgbaBuffer[pIdx + 3] = alpha;
      }
    }
  }

  LatteArtWlacGrade evaluateCup(LatteArtPattern target) {
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
    final double contrastPct =
        ((avgGrad * 520.0) - accidentalEarlyFoamPenalty).clamp(15.0, 100.0);
    final double fidelityPct = (normActual > 0.5 && normTemplate > 0.5)
        ? ((dotProd / math.sqrt(normActual * normTemplate)) * 114.0)
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

  static double _samplePatternTemplate(
    LatteArtPattern target,
    double nx,
    double ny,
  ) {
    switch (target) {
      case LatteArtPattern.canvasBase:
        return 0.0;
      case LatteArtPattern.monksHead:
        return (nx * nx + ny * ny) <= 0.26 ? 1.0 : 0.0;
      case LatteArtPattern.heart:
        final double x = nx * 1.45;
        final double y = -ny * 1.45 + 0.1;
        final double a = x * x + y * y - 0.55;
        return (a * a * a - x * x * y * y * y) <= 0.0 ? 1.0 : 0.0;
      case LatteArtPattern.twoStackTulip:
      case LatteArtPattern.threeStackTulip:
      case LatteArtPattern.wingedFiveTulip:
        final double baseArc = (ny > -0.15 &&
                ny < 0.55 &&
                (nx * nx * 1.2 + (ny - 0.15) * (ny - 0.15) * 2.2) < 0.45)
            ? 1.0
            : 0.0;
        final double topHeart =
            (nx * nx * 2.6 + (ny + 0.28) * (ny + 0.28) * 2.6) < 0.22 ? 1.0 : 0.0;
        return math.max(baseArc, topHeart);
      case LatteArtPattern.wingedBase:
        return (nx * nx * 0.9 + (ny - 0.12) * (ny - 0.12) * 1.9) < 0.46
            ? 1.0
            : 0.0;
      case LatteArtPattern.rosetta:
      case LatteArtPattern.slowsetta:
        final double widthAtY =
            (0.48 - (ny + 0.55).abs() * 0.35).clamp(0.08, 0.52);
        final double leafWave = 0.5 +
            0.5 *
                math.sin(
                  ny * (target == LatteArtPattern.slowsetta ? 12.0 : 20.0),
                );
        return (nx.abs() < widthAtY * (0.65 + 0.35 * leafWave) &&
                ny > -0.65 &&
                ny < 0.65)
            ? 1.0
            : 0.0;
      case LatteArtPattern.swan:
        final bool wing = nx > -0.15 &&
            nx < 0.68 &&
            ny > -0.15 &&
            ny < 0.58 &&
            ((nx - 0.25) * (nx - 0.25) + (ny - 0.2) * (ny - 0.2) < 0.26);
        final bool neck =
            (nx + 0.18 + 0.12 * math.sin(ny * 4.5)).abs() < 0.09 &&
                ny > -0.58 &&
                ny < 0.35;
        final bool head =
            (nx + 0.14) * (nx + 0.14) + (ny + 0.54) * (ny + 0.54) < 0.032;
        return (wing || neck || head) ? 1.0 : 0.0;
    }
  }
}
