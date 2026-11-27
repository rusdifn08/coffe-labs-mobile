import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Precision speed tier exposed by [BaristaJoystickState].
enum JoystickSpeedTier {
  idle('Diam'),
  micro('Halus'),
  medium('Sedang'),
  fast('Cepat');

  final String label;
  const JoystickSpeedTier(this.label);
}

/// Immutable kinematic snapshot of the analog barista joystick.
class BaristaJoystickState {
  /// Raw normalized stick deflection inside unit disk (`|raw| <= 1.0`).
  final Offset rawVector;

  /// Deadzone-compensated & non-linearly curved velocity command (`[-1..1]` per axis).
  final Offset curvedVector;

  /// Effective normalized magnitude after radial deadzone (`0..1`).
  final double magnitude;

  /// Smoothed nozzle translation velocity in normalized workspace units per second.
  final Offset velocityNormPerSec;

  /// Current speed tier (Diam / Halus / Sedang / Cepat).
  final JoystickSpeedTier tier;

  /// True while user's thumb is actively holding the joystick.
  final bool isEngaged;

  const BaristaJoystickState({
    this.rawVector = Offset.zero,
    this.curvedVector = Offset.zero,
    this.magnitude = 0.0,
    this.velocityNormPerSec = Offset.zero,
    this.tier = JoystickSpeedTier.idle,
    this.isEngaged = false,
  });

  double get speedNormPerSec => velocityNormPerSec.distance;

  /// Approximate physical nozzle translation speed in cm/s (for 9.5 cm V60/Cup diameter).
  double get speedCmPerSec => speedNormPerSec * 4.75;
}

/// Aerospace / AAA-Game Grade Analog Joystick Kinematic Controller:
/// - Scaled Radial Deadzone (zero drift near center, smooth non-snapping exit)
/// - Non-linear Exponential Precision Curve (`mag^gamma`, gamma = 1.85) so small
///   deflections yield surgical micro-control while larger deflections smoothly accelerate
/// - Exponentially damped velocity integrator (spring-damper inertia) for silky motion
/// - Circular workspace soft-clamping with tangential boundary sliding
class BaristaJoystickController {
  final double deadzone;
  final double responseGamma;
  final double maxSpeedNormPerSec;
  final double velocitySmoothingTauSec;
  final double workspaceMaxRadius;

  Offset _rawInput = Offset.zero;
  Offset _smoothedVelocity = Offset.zero;
  bool _engaged = false;
  JoystickSpeedTier _lastTier = JoystickSpeedTier.idle;

  BaristaJoystickController({
    this.deadzone = 0.08,
    this.responseGamma = 1.85,
    this.maxSpeedNormPerSec = 1.55,
    this.velocitySmoothingTauSec = 0.042,
    this.workspaceMaxRadius = 0.88,
  });

  BaristaJoystickState _state = const BaristaJoystickState();
  BaristaJoystickState get state => _state;

  /// Updates raw joystick vector from touch drag (normalized unit disk).
  /// Returns true if the speed tier changed (used for tactile haptic detent).
  bool updateInput(Offset normalizedUnitVector, {required bool engaged}) {
    _engaged = engaged;
    if (!engaged) {
      _rawInput = Offset.zero;
    } else {
      final double len = normalizedUnitVector.distance;
      _rawInput = len > 1.0 ? (normalizedUnitVector / len) : normalizedUnitVector;
    }

    final JoystickSpeedTier nextTier = _tierForMagnitude(_effectiveMagnitude(_rawInput));
    final bool crossedTier = engaged && nextTier != _lastTier && nextTier != JoystickSpeedTier.idle;
    _lastTier = nextTier;
    return crossedTier;
  }

  void reset() {
    _rawInput = Offset.zero;
    _smoothedVelocity = Offset.zero;
    _engaged = false;
    _lastTier = JoystickSpeedTier.idle;
    _state = const BaristaJoystickState();
  }

  double _effectiveMagnitude(Offset raw) {
    final double mag = raw.distance.clamp(0.0, 1.0);
    if (mag <= deadzone) return 0.0;
    return ((mag - deadzone) / (1.0 - deadzone)).clamp(0.0, 1.0);
  }

  static JoystickSpeedTier _tierForMagnitude(double effMag) {
    if (effMag <= 0.001) return JoystickSpeedTier.idle;
    if (effMag < 0.38) return JoystickSpeedTier.micro;
    if (effMag < 0.72) return JoystickSpeedTier.medium;
    return JoystickSpeedTier.fast;
  }

  /// Advances kinematics by [dt] seconds and integrates [currentPos] within the circular workspace.
  Offset stepPosition(Offset currentPos, double dt) {
    final double safeDt = dt.clamp(0.001, 0.05);
    final double rawMag = _rawInput.distance;
    final double effMag = _effectiveMagnitude(_rawInput);

    Offset curved = Offset.zero;
    if (effMag > 0.0 && rawMag > 1e-6) {
      final Offset dir = _rawInput / rawMag;
      // Non-linear exponential speed curve: tiny push = slow precision, full push = fast!
      final double curvedMag = math.pow(effMag, responseGamma).toDouble();
      curved = dir * curvedMag;
    }

    final Offset targetVel = curved * maxSpeedNormPerSec;
    // Critically smooth exponential damping toward target velocity (fast stop on release)
    final double tau = _engaged ? velocitySmoothingTauSec : 0.028;
    final double alpha = (1.0 - math.exp(-safeDt / tau)).clamp(0.0, 1.0);
    _smoothedVelocity = Offset(
      _smoothedVelocity.dx + (targetVel.dx - _smoothedVelocity.dx) * alpha,
      _smoothedVelocity.dy + (targetVel.dy - _smoothedVelocity.dy) * alpha,
    );
    if (!_engaged && _smoothedVelocity.distance < 0.004) {
      _smoothedVelocity = Offset.zero;
    }

    final JoystickSpeedTier tier = _tierForMagnitude(effMag);
    _state = BaristaJoystickState(
      rawVector: _rawInput,
      curvedVector: curved,
      magnitude: effMag,
      velocityNormPerSec: _smoothedVelocity,
      tier: tier,
      isEngaged: _engaged,
    );

    if (_smoothedVelocity == Offset.zero) {
      return currentPos;
    }

    Offset nextPos = currentPos + _smoothedVelocity * safeDt;
    // Circular boundary soft-clamp so pushing diagonally glides smoothly along the rim!
    final double r = nextPos.distance;
    if (r > workspaceMaxRadius) {
      nextPos = (nextPos / r) * workspaceMaxRadius;
    }
    return nextPos;
  }
}

/// High-Precision Analog Virtual Joystick Widget for Manual Brew 3D & Latte Art 3D:
/// - Concentric precision rings (Halus / Sedang / Cepat)
/// - Live directional vector glow & outer speed arc
/// - Smooth tactile metallic knob with haptic zone detents
/// - Double-tap to instantly re-center the kettle/pitcher to the middle of the dripper/cup
class BaristaPrecisionJoystick extends StatefulWidget {
  final BaristaJoystickController controller;
  final double size;
  final Color accentColor;
  final VoidCallback? onRecenter;
  final String label;

  const BaristaPrecisionJoystick({
    super.key,
    required this.controller,
    this.size = 114.0,
    this.accentColor = const Color(0xFFFBBF24),
    this.onRecenter,
    this.label = 'ARAH TUANG',
  });

  @override
  State<BaristaPrecisionJoystick> createState() =>
      _BaristaPrecisionJoystickState();
}

class _BaristaPrecisionJoystickState extends State<BaristaPrecisionJoystick> {
  Offset _knobNorm = Offset.zero;
  bool _active = false;

  void _handleTouch(Offset localPosition) {
    final double half = widget.size * 0.5;
    final double maxTravel = half - 22.0;
    final Offset delta = localPosition - Offset(half, half);
    final double dist = delta.distance;
    final Offset unit = dist > maxTravel && dist > 0.0
        ? delta / dist
        : Offset(
            (delta.dx / maxTravel).clamp(-1.0, 1.0),
            (delta.dy / maxTravel).clamp(-1.0, 1.0),
          );

    final bool crossed = widget.controller.updateInput(unit, engaged: true);
    if (crossed) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _active = true;
      _knobNorm = unit;
    });
  }

  void _handleRelease() {
    widget.controller.updateInput(Offset.zero, engaged: false);
    setState(() {
      _active = false;
      _knobNorm = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.controller.state;
    final Color tierColor = switch (st.tier) {
      JoystickSpeedTier.idle => Colors.white60,
      JoystickSpeedTier.micro => const Color(0xFF34D399),
      JoystickSpeedTier.medium => widget.accentColor,
      JoystickSpeedTier.fast => const Color(0xFFFB923C),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () {
            HapticFeedback.lightImpact();
            widget.onRecenter?.call();
          },
          onPanStart: (d) {
            HapticFeedback.lightImpact();
            _handleTouch(d.localPosition);
          },
          onPanUpdate: (d) => _handleTouch(d.localPosition),
          onPanEnd: (_) => _handleRelease(),
          onPanCancel: _handleRelease,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _BaristaJoystickPainter(
                knobNorm: _knobNorm,
                magnitude: st.magnitude,
                engaged: _active,
                accentColor: widget.accentColor,
                tierColor: tierColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _active
                  ? tierColor.withValues(alpha: 0.75)
                  : Colors.white24,
            ),
          ),
          child: Text(
            _active
                ? '${st.tier.label} • ${st.speedCmPerSec.toStringAsFixed(1)} cm/s'
                : widget.label,
            style: TextStyle(
              fontSize: 8.8,
              fontWeight: FontWeight.w800,
              color: _active ? tierColor : Colors.white70,
              letterSpacing: 0.3,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _BaristaJoystickPainter extends CustomPainter {
  final Offset knobNorm;
  final double magnitude;
  final bool engaged;
  final Color accentColor;
  final Color tierColor;

  const _BaristaJoystickPainter({
    required this.knobNorm,
    required this.magnitude,
    required this.engaged,
    required this.accentColor,
    required this.tierColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width * 0.5, size.height * 0.5);
    final double outerR = size.width * 0.5 - 3.0;
    final double maxTravel = outerR - 19.0;

    // 1. Frosted Dark Tactical Radar Base
    canvas.drawCircle(
      c,
      outerR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1F1610).withValues(alpha: 0.76),
            const Color(0xFF0E0A07).withValues(alpha: 0.88),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: outerR)),
    );

    // 2. Concentric Precision Zone Rings (Deadzone / Halus / Sedang / Cepat)
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(c, maxTravel * 0.38, ringPaint);
    canvas.drawCircle(c, maxTravel * 0.72, ringPaint);

    // Subtle orthogonal crosshair axes + cardinal micro-arrows
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(c.dx - outerR + 8, c.dy),
        Offset(c.dx + outerR - 8, c.dy), axisPaint);
    canvas.drawLine(Offset(c.dx, c.dy - outerR + 8),
        Offset(c.dx, c.dy + outerR - 8), axisPaint);

    // Outer bezel border
    canvas.drawCircle(
      c,
      outerR,
      Paint()
        ..color = engaged
            ? tierColor.withValues(alpha: 0.72)
            : Colors.white.withValues(alpha: 0.26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = engaged ? 2.0 : 1.4,
    );

    // 3. Speed Magnitude Glow Arc on Outer Bezel
    if (engaged && magnitude > 0.02) {
      final double angle = math.atan2(knobNorm.dy, knobNorm.dx);
      final double sweep = (0.35 + magnitude * 1.45).clamp(0.35, 1.85);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: outerR - 1.5),
        angle - sweep * 0.5,
        sweep,
        false,
        Paint()
          ..color = tierColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round,
      );
    }

    // 4. Directional Vector Beam from Center -> Knob
    final Offset knobCenter = c + knobNorm * maxTravel;
    if (engaged && knobNorm.distance > 0.04) {
      canvas.drawLine(
        c,
        knobCenter,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.center,
            end: Alignment(knobNorm.dx, knobNorm.dy),
            colors: [
              tierColor.withValues(alpha: 0.18),
              tierColor.withValues(alpha: 0.85),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: outerR))
          ..strokeWidth = 3.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // 5. Tactile Metallic Thumbstick Cap with Soft Shadow
    const double knobR = 19.0;
    canvas.drawCircle(
      knobCenter + const Offset(0, 3),
      knobR,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      knobCenter,
      knobR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: engaged
              ? [const Color(0xFFFFFBEB), tierColor, const Color(0xFF78350F)]
              : [
                  const Color(0xFF6B4F3B),
                  const Color(0xFF3E2718),
                  const Color(0xFF1F120A),
                ],
        ).createShader(Rect.fromCircle(center: knobCenter, radius: knobR)),
    );
    canvas.drawCircle(
      knobCenter,
      knobR - 1.0,
      Paint()
        ..color = Colors.white.withValues(alpha: engaged ? 0.88 : 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // Inner tactile dimple ring
    canvas.drawCircle(
      knobCenter,
      knobR * 0.44,
      Paint()
        ..color = Colors.white.withValues(alpha: engaged ? 0.45 : 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _BaristaJoystickPainter oldDelegate) =>
      oldDelegate.knobNorm != knobNorm ||
      oldDelegate.magnitude != magnitude ||
      oldDelegate.engaged != engaged ||
      oldDelegate.tierColor != tierColor;
}
