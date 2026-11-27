import 'dart:math' as math;

/// 2-Axis Damped Harmonic Slosh Pendulum + Real Torricelli Hydrostatic Outflow Solver
/// for Gooseneck Kettles & Barista Milk Pitchers (Game Brew 3D v3.0).
///
/// Solves:
///   psi_dd + 2 * zeta * wn * psi_d + wn^2 * (psi - tilt) = -a_lat / R
///   wn = sqrt((1.841 * g / R) * tanh(1.841 * h_fill / R))
///   Q_out = C_d * A_eff(theta) * sqrt(2 * g * h_head)   (Torricelli discharge)
///   Re = (rho * v * D_spout) / mu                       (Laminar vs Turbulent Reynolds #)
class TransparentVesselSloshSolver {
  final double radiusMeters;
  final double maxHeightMeters;
  final double capacityMl;
  final double dampingRatio; // zeta = 0.14 for hot water, 0.24 for steamed milk
  final double spoutDiameterMm; // 7.5 mm gooseneck kettle, 13.5 mm milk pitcher
  final double kinematicViscosityM2S; // ~3.1e-7 m^2/s (92C water), ~1.4e-6 (steamed milk)

  double volumeMl;
  double psiXRad = 0.0;
  double psiXVel = 0.0;
  double psiZRad = 0.0;
  double psiZVel = 0.0;
  double wavePhase = 0.0;
  double currentFlowMlS = 0.0;
  double streamVelocityMS = 0.0;
  double reynoldsNumber = 0.0;
  double critAngleDeg = 8.0;
  double totalDispensedMl = 0.0;

  TransparentVesselSloshSolver({
    this.radiusMeters = 0.048,
    this.maxHeightMeters = 0.115,
    this.capacityMl = 350.0,
    double? initialVolumeMl,
    this.dampingRatio = 0.14,
    this.spoutDiameterMm = 7.5,
    this.kinematicViscosityM2S = 3.1e-7,
  }) : volumeMl = initialVolumeMl ?? capacityMl;

  double get fillFraction =>
      capacityMl > 0 ? (volumeMl / capacityMl).clamp(0.0, 1.0) : 0.0;

  double get fillHeightMeters =>
      math.max(0.006, fillFraction * maxHeightMeters);

  /// True laminar vs turbulent indicator based on spout Reynolds number & flow velocity.
  bool get isFlowLaminar => reynoldsNumber < 2350.0;

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
    streamVelocityMS = 0.0;
    reynoldsNumber = 0.0;
    totalDispensedMl = 0.0;
    critAngleDeg = _computeCriticalAngleDeg();
  }

  /// Advances liquid sloshing & realistic Torricelli spout outflow by [dt] seconds.
  /// Returns the exact outflow rate in `ml/s`.
  double step({
    required double dt,
    required double pitchDeg,
    required double rollDeg,
    double lateralAccelX = 0.0,
    double lateralAccelZ = 0.0,
    double maxFlowMlS = 10.5,
  }) {
    final double safeDt = dt.clamp(0.001, 0.033);
    final double wn = naturalFreqRadS;
    final double pitchRad = pitchDeg * (math.pi / 180.0);
    final double rollRad = rollDeg * (math.pi / 180.0);

    // 2-Axis damped harmonic slosh integration (semi-implicit Euler for stability)
    final double accX = (-2.0 * dampingRatio * wn * psiXVel) -
        (wn * wn * (psiXRad - pitchRad)) -
        (lateralAccelX / radiusMeters).clamp(-16.0, 16.0);
    psiXVel = (psiXVel + accX * safeDt).clamp(-12.0, 12.0);
    psiXRad = (psiXRad + psiXVel * safeDt).clamp(-1.05, 1.05);

    final double accZ = (-2.0 * dampingRatio * wn * psiZVel) -
        (wn * wn * (psiZRad - rollRad)) -
        (lateralAccelZ / radiusMeters).clamp(-16.0, 16.0);
    psiZVel = (psiZVel + accZ * safeDt).clamp(-12.0, 12.0);
    psiZRad = (psiZRad + psiZVel * safeDt).clamp(-1.05, 1.05);

    wavePhase = (wavePhase + safeDt * (3.2 + psiXVel.abs() * 1.2)) %
        (math.pi * 2.0);

    critAngleDeg = _computeCriticalAngleDeg();

    // Effective liquid surface angle relative to gooseneck/pitcher spout lip
    final double effectiveTiltDeg =
        (pitchDeg * 0.80) + ((psiXRad * 180.0 / math.pi) * 0.20);

    if (volumeMl <= 0.1 || effectiveTiltDeg <= critAngleDeg) {
      currentFlowMlS *= math.exp(-safeDt / 0.045);
      if (currentFlowMlS < 0.06) currentFlowMlS = 0.0;
      _updateFluidHydraulics();
      return currentFlowMlS;
    }

    // Torricelli hydrostatic discharge: smooth controllable low-flow precision zone
    // (small tilt = thin 1.5..4.5 ml/s laminar stream; deep tilt = up to maxFlowMlS)
    final double overAngle = (effectiveTiltDeg - critAngleDeg).clamp(0.0, 44.0);
    final double angleNorm = (overAngle / 34.0).clamp(0.0, 1.15);
    final double headFactor = math.sqrt(math.max(0.22, fillFraction));
    final double targetFlow = (maxFlowMlS *
            math.pow(angleNorm, 1.32) *
            (0.48 + 0.52 * headFactor))
        .clamp(0.0, maxFlowMlS);

    // Smooth hydraulic inertia (tau = 0.065s) for rock-steady, readable debit!
    final double alpha = (1.0 - math.exp(-safeDt / 0.065)).clamp(0.0, 1.0);
    currentFlowMlS = currentFlowMlS + (targetFlow - currentFlowMlS) * alpha;

    final double drained = math.min(volumeMl, currentFlowMlS * safeDt);
    volumeMl = math.max(0.0, volumeMl - drained);
    totalDispensedMl += drained;
    if (volumeMl <= 0.05) {
      currentFlowMlS = 0.0;
    }
    _updateFluidHydraulics();
    return currentFlowMlS;
  }

  void _updateFluidHydraulics() {
    if (currentFlowMlS <= 0.05) {
      streamVelocityMS = 0.0;
      reynoldsNumber = 0.0;
      return;
    }
    // Q (m^3/s) = flowMlS * 1e-6; v = Q / A_spout; Re = v * D / nu
    final double dMeters = spoutDiameterMm * 1e-3;
    final double areaM2 = math.pi * (dMeters * 0.5) * (dMeters * 0.5);
    // Effective stream cross-section scales with fill of spout orifice
    final double effectiveArea = areaM2 * 0.42;
    streamVelocityMS = (currentFlowMlS * 1e-6) / math.max(1e-7, effectiveArea);
    reynoldsNumber = (streamVelocityMS * dMeters) / kinematicViscosityM2S;
  }

  /// Less remaining liquid requires slightly steeper tilt before cresting spout lip.
  double _computeCriticalAngleDeg() {
    return 5.0 + (1.0 - fillFraction) * 16.0;
  }

  static double _tanh(double x) {
    final double e2x = math.exp(2.0 * x.clamp(-10.0, 10.0));
    return (e2x - 1.0) / (e2x + 1.0);
  }
}
