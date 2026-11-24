import 'dart:math' as math;

/// 2-Axis Damped Harmonic Slosh Pendulum Solver for Transparent Borosilicate
/// Gooseneck Kettles & Transparent Milk Pitchers (Game Brew 3D v2.0).
///
/// Solves:
///   psi_dd + 2 * zeta * wn * psi_d + wn^2 * (psi - tilt) = -a_lat / R
///   wn = sqrt((1.841 * g / R) * tanh(1.841 * h_fill / R))
class TransparentVesselSloshSolver {
  final double radiusMeters;
  final double maxHeightMeters;
  final double capacityMl;
  final double dampingRatio; // zeta = 0.14 for hot water, 0.24 for steamed milk

  double volumeMl;
  double psiXRad = 0.0;
  double psiXVel = 0.0;
  double psiZRad = 0.0;
  double psiZVel = 0.0;
  double wavePhase = 0.0;
  double currentFlowMlS = 0.0;
  double critAngleDeg = 12.0;

  TransparentVesselSloshSolver({
    this.radiusMeters = 0.048,
    this.maxHeightMeters = 0.115,
    this.capacityMl = 350.0,
    double? initialVolumeMl,
    this.dampingRatio = 0.14,
  }) : volumeMl = initialVolumeMl ?? capacityMl;

  double get fillFraction =>
      capacityMl > 0 ? (volumeMl / capacityMl).clamp(0.0, 1.0) : 0.0;

  double get fillHeightMeters =>
      math.max(0.006, fillFraction * maxHeightMeters);

  /// Natural sloshing angular frequency omega_n (rad/s).
  double get naturalFreqRadS {
    const double g = 9.80665;
    final double ratio = (1.841 * fillHeightMeters) / radiusMeters;
    final double tanhVal = _tanh(ratio);
    return math.sqrt((1.841 * g / radiusMeters) * tanhVal);
  }

  void reset({double? newVolumeMl}) {
    volumeMl = (newVolumeMl ?? capacityMl).clamp(0.0, capacityMl);
    psiXRad = 0.0;
    psiXVel = 0.0;
    psiZRad = 0.0;
    psiZVel = 0.0;
    wavePhase = 0.0;
    currentFlowMlS = 0.0;
    critAngleDeg = _computeCriticalAngleDeg();
  }

  /// Advances liquid sloshing & non-linear Torricelli spout outflow by [dt] seconds.
  /// Returns the outflow rate in `ml/s`.
  double step({
    required double dt,
    required double pitchDeg,
    required double rollDeg,
    double lateralAccelX = 0.0,
    double lateralAccelZ = 0.0,
    double maxFlowMlS = 11.0,
  }) {
    final double safeDt = dt.clamp(0.001, 0.033);
    final double wn = naturalFreqRadS;
    final double pitchRad = pitchDeg * (math.pi / 180.0);
    final double rollRad = rollDeg * (math.pi / 180.0);

    // 2-Axis damped harmonic slosh integration (semi-implicit Euler for stability)
    final double accX = (-2.0 * dampingRatio * wn * psiXVel) -
        (wn * wn * (psiXRad - pitchRad)) -
        (lateralAccelX / radiusMeters).clamp(-18.0, 18.0);
    psiXVel = (psiXVel + accX * safeDt).clamp(-14.0, 14.0);
    psiXRad = (psiXRad + psiXVel * safeDt).clamp(-1.1, 1.1);

    final double accZ = (-2.0 * dampingRatio * wn * psiZVel) -
        (wn * wn * (psiZRad - rollRad)) -
        (lateralAccelZ / radiusMeters).clamp(-18.0, 18.0);
    psiZVel = (psiZVel + accZ * safeDt).clamp(-14.0, 14.0);
    psiZRad = (psiZRad + psiZVel * safeDt).clamp(-1.1, 1.1);

    wavePhase = (wavePhase + safeDt * (3.5 + psiXVel.abs() * 1.4)) %
        (math.pi * 2.0);

    critAngleDeg = _computeCriticalAngleDeg();

    // Effective internal liquid angle determines when liquid crests gooseneck spout
    final double effectiveTiltDeg =
        (pitchDeg * 0.72) + ((psiXRad * 180.0 / math.pi) * 0.28);

    if (volumeMl <= 0.1 || effectiveTiltDeg <= critAngleDeg) {
      currentFlowMlS = (currentFlowMlS * 0.72);
      if (currentFlowMlS < 0.05) currentFlowMlS = 0.0;
      return currentFlowMlS;
    }

    final double overAngle = (effectiveTiltDeg - critAngleDeg).clamp(0.0, 48.0);
    // Torricelli square-root head dependence * nonlinear spout opening
    final double headFactor = math.sqrt(math.max(0.18, fillFraction));
    final double targetFlow =
        (maxFlowMlS * math.pow(overAngle / 34.0, 1.18) * (0.45 + 0.55 * headFactor))
            .clamp(0.0, maxFlowMlS);

    currentFlowMlS = currentFlowMlS * 0.65 + targetFlow * 0.35;
    final double drained = math.min(volumeMl, currentFlowMlS * safeDt);
    volumeMl = math.max(0.0, volumeMl - drained);
    if (volumeMl <= 0.05) {
      currentFlowMlS = 0.0;
    }
    return currentFlowMlS;
  }

  /// Less remaining water requires a steeper tilt before water reaches the spout.
  double _computeCriticalAngleDeg() {
    return 7.0 + (1.0 - fillFraction) * 26.0;
  }

  static double _tanh(double x) {
    final double e2x = math.exp(2.0 * x.clamp(-10.0, 10.0));
    return (e2x - 1.0) / (e2x + 1.0);
  }
}
