import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../domain/game_brew_studio_models.dart';
import '../engine/latte_art_cfd_engine.dart';

/// Ceramic cup color palette matching the Coffee Labs Barista Studio.
enum LatteCupColorTheme {
  cobaltBlue(
    label: 'Cobalt Blue',
    outerLight: Color(0xFF4F7AD6),
    outerDark: Color(0xFF2B4C9B),
    saucerLight: Color(0xFF5A84DF),
    saucerDark: Color(0xFF3659AB),
  ),
  matchaSage(
    label: 'Matcha Sage',
    outerLight: Color(0xFFA7C49B),
    outerDark: Color(0xFF6E8E63),
    saucerLight: Color(0xFFB6D0AB),
    saucerDark: Color(0xFF7D9D72),
  ),
  matteCharcoal(
    label: 'Matte Noir',
    outerLight: Color(0xFF3D3D42),
    outerDark: Color(0xFF1E1E22),
    saucerLight: Color(0xFF48484E),
    saucerDark: Color(0xFF252529),
  ),
  sakuraPink(
    label: 'Sakura Rose',
    outerLight: Color(0xFFE095A8),
    outerDark: Color(0xFFB36579),
    saucerLight: Color(0xFFE9A5B6),
    saucerDark: Color(0xFFC07387),
  ),
  ivoryCream(
    label: 'Alabaster',
    outerLight: Color(0xFFF3EFE8),
    outerDark: Color(0xFFC9BFB2),
    saucerLight: Color(0xFFF7F4EE),
    saucerDark: Color(0xFFD6CEC2),
  );

  final String label;
  final Color outerLight;
  final Color outerDark;
  final Color saucerLight;
  final Color saucerDark;

  const LatteCupColorTheme({
    required this.label,
    required this.outerLight,
    required this.outerDark,
    required this.saucerLight,
    required this.saucerDark,
  });
}

/// Photorealistic First-Person Barista POV 3D Latte Art Studio Painter:
/// - Warm walnut barista countertop with woodgrain & overhead café pendant spotlight
/// - Glazed 3D porcelain cup & saucer positioned cleanly in upper-middle with realistic
///   counter-tilt shading, inner meniscus shadow & ZERO-pixelation anti-aliased CFD crema!
/// - FIRST-PERSON BARISTA POV: Brushed Stainless-Steel (or Borosilicate Glass) Milk Pitcher
///   positioned in the FOREGROUND (bottom-right / bottom-left, close to the barista's hand!),
///   tilting FORWARD to pour a gleaming 3D tapered microfoam stream forward into the cup!
class LatteArtFull3DScenePainter extends CustomPainter {
  final LatteArtCfdEngine cfd;
  final ui.Image? fluidImage;
  final LatteCupColorTheme cupTheme;
  final bool transparentGlassPitcher;
  final bool topDownInspectionMode;
  final bool showGhostGuide;
  final LatteArtPattern targetPattern;
  final double activePitchDeg;
  final double activeRollDeg;
  final bool pitcherOnRight;

  const LatteArtFull3DScenePainter({
    required this.cfd,
    required this.fluidImage,
    required this.cupTheme,
    this.transparentGlassPitcher = false,
    this.topDownInspectionMode = false,
    required this.showGhostGuide,
    required this.targetPattern,
    required this.activePitchDeg,
    required this.activeRollDeg,
    this.pitcherOnRight = true,
  });

  /// Converts a screen touch inside [size] into normalized cup coordinates `[-0.78..0.78]`.
  static Offset screenToCupNormalized(
    Offset localPos,
    Size size, {
    required bool isLandscape,
    required bool topDown,
  }) {
    final center = cupCenterForSize(size, isLandscape: isLandscape, topDown: topDown);
    final double cupR = cupRadiusForSize(size, isLandscape: isLandscape);
    final double tiltYScale = topDown ? 1.0 : 0.86;
    final double nx = ((localPos.dx - center.dx) / (cupR * 0.88)).clamp(-0.78, 0.78);
    final double ny =
        ((localPos.dy - center.dy) / (cupR * 0.88 * tiltYScale)).clamp(-0.78, 0.78);
    return Offset(nx, ny);
  }

  static Offset cupCenterForSize(
    Size size, {
    required bool isLandscape,
    required bool topDown,
  }) {
    if (topDown) {
      return Offset(
        size.width * (isLandscape ? 0.36 : 0.50),
        size.height * (isLandscape ? 0.50 : 0.34),
      );
    }
    // Cup sits cleanly in the mid-upper workspace so the foreground pitcher has natural barista room below!
    return Offset(
      size.width * (isLandscape ? 0.48 : 0.52),
      size.height * (isLandscape ? 0.44 : 0.41),
    );
  }

  static double cupRadiusForSize(Size size, {required bool isLandscape}) {
    final double shortest = math.min(size.width, size.height);
    return isLandscape ? shortest * 0.34 : shortest * 0.35;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bool isLandscape = size.width > size.height;

    // 1. Full-Bleed Walnut Barista Wood Countertop + Studio Pendant Spotlight
    _drawWoodCountertop(canvas, size);

    final Offset cupCenter = cupCenterForSize(
      size,
      isLandscape: isLandscape,
      topDown: topDownInspectionMode,
    );
    final double cupR = cupRadiusForSize(size, isLandscape: isLandscape);

    // Subtle real-world Barista Cup Counter-Tilt: cup angles slightly toward pouring hand early on,
    // and levels smoothly as it reaches 100% fill!
    final double fillNorm = (cfd.cupFillPct / 100.0).clamp(0.18, 1.0);
    final double ySquash =
        topDownInspectionMode ? 1.0 : (0.83 + 0.05 * fillNorm);

    // 2. 3D Glazed Ceramic Saucer + Spill Puddle
    _draw3DSaucer(canvas, cupCenter, cupR, ySquash);

    // 3. 3D Curved Ceramic Cup Handle (opposite side of foreground pouring pitcher!)
    _draw3DCupHandle(canvas, cupCenter, cupR, ySquash);

    // 4. 3D Glazed Ceramic Cup Bowl + Smooth Anti-Aliased CFD Crema/Microfoam Surface
    final Offset streamImpactScreen = _draw3DCupAndFluidSurface(
      canvas,
      cupCenter,
      cupR,
      ySquash,
    );

    // 5. Realistic Rim Spill Drips when overfilled (> 100%)
    if (cfd.spilled) {
      _draw3DRimSpillDrips(canvas, cupCenter, cupR, ySquash);
    }

    // 6. FIRST-PERSON BARISTA POV: Foreground Brushed-Steel / Glass Pitcher Pouring FORWARD!
    if (!topDownInspectionMode) {
      _drawForegroundBaristaPitcherAndStream(
        canvas,
        size: size,
        cupCenter: cupCenter,
        cupR: cupR,
        streamImpactScreen: streamImpactScreen,
      );
    }
  }

  void _drawWoodCountertop(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6B462E),
            Color(0xFF5A3924),
            Color(0xFF472B1A),
          ],
        ).createShader(rect),
    );

    // Natural walnut planks + smooth curved woodgrain lines
    final plankLinePaint = Paint()
      ..color = const Color(0xFF2D190E).withValues(alpha: 0.34)
      ..strokeWidth = 1.6;
    final grainPaint = Paint()
      ..color = const Color(0xFF8C6143).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    const double plankH = 66.0;
    for (double y = 24.0; y < size.height; y += plankH) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), plankLinePaint);
      for (int g = 1; g <= 3; g++) {
        final double gy = y + g * (plankH / 4.0);
        final path = Path()..moveTo(0, gy);
        for (double x = 0; x <= size.width; x += 52) {
          path.lineTo(x, gy + math.sin(x * 0.022 + y * 0.04) * 1.9);
        }
        canvas.drawPath(path, grainPaint);
      }
    }

    // Soft warm café pendant spotlight centered over the latte cup
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.38),
      math.max(size.width, size.height) * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF4D2).withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ).createShader(rect),
    );
  }

  void _draw3DSaucer(
    Canvas canvas,
    Offset cupCenter,
    double cupR,
    double ySquash,
  ) {
    final Offset saucerCenter =
        cupCenter + Offset(0, topDownInspectionMode ? 0 : cupR * 0.16);
    final double saucerRx = cupR * 1.44;
    final double saucerRy = saucerRx * (topDownInspectionMode ? 1.0 : 0.82);

    // Soft multi-layer ambient occlusion drop shadow under saucer
    canvas.drawOval(
      Rect.fromCenter(
        center: saucerCenter + const Offset(5, 14),
        width: saucerRx * 2.04,
        height: saucerRy * 2.04,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // Overflow coffee puddle on saucer when heavily spilled
    if (cfd.spillAmountMl > 8.0) {
      final double puddleGrow = (cfd.spillAmountMl / 35.0).clamp(0.15, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: saucerCenter + Offset(-cupR * 0.15, cupR * 0.12),
          width: saucerRx * (1.78 + puddleGrow * 0.65),
          height: saucerRy * (1.58 + puddleGrow * 0.55),
        ),
        Paint()..color = const Color(0xFFC89B73).withValues(alpha: 0.72),
      );
    }

    final saucerRect = Rect.fromCenter(
      center: saucerCenter,
      width: saucerRx * 2,
      height: saucerRy * 2,
    );
    canvas.drawOval(
      saucerRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cupTheme.saucerLight, cupTheme.saucerDark],
        ).createShader(saucerRect),
    );

    // Saucer inner concave well shadow
    final wellRect = Rect.fromCenter(
      center: saucerCenter + Offset(0, topDownInspectionMode ? 0 : 4),
      width: cupR * 1.44,
      height: cupR * 1.44 * ySquash,
    );
    canvas.drawOval(
      wellRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.28),
            Colors.black.withValues(alpha: 0.08),
          ],
        ).createShader(wellRect),
    );

    // Glazed specular saucer rim highlight
    canvas.drawOval(
      saucerRect.deflate(1.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  void _draw3DCupHandle(
    Canvas canvas,
    Offset cupCenter,
    double cupR,
    double ySquash,
  ) {
    // Place handle opposite the pouring hand so barista holds cup with off-hand naturally!
    final double hSign = pitcherOnRight ? -1.0 : 1.0;
    final Offset attachTop =
        cupCenter + Offset(hSign * cupR * 0.90, -cupR * 0.08 * ySquash);
    final Offset attachBot =
        cupCenter + Offset(hSign * cupR * 0.78, cupR * 0.30 * ySquash);
    final Path handlePath = Path()
      ..moveTo(attachTop.dx, attachTop.dy)
      ..cubicTo(
        cupCenter.dx + hSign * cupR * 1.38,
        cupCenter.dy - cupR * 0.14 * ySquash,
        cupCenter.dx + hSign * cupR * 1.36,
        cupCenter.dy + cupR * 0.36 * ySquash,
        attachBot.dx,
        attachBot.dy,
      );

    canvas.drawPath(
      handlePath.shift(const Offset(2, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cupR * 0.16
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      handlePath,
      Paint()
        ..color = cupTheme.outerDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = cupR * 0.16
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      handlePath.shift(Offset(-hSign * 1.0, -2.0)),
      Paint()
        ..color = cupTheme.outerLight.withValues(alpha: 0.88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cupR * 0.06
        ..strokeCap = StrokeCap.round,
    );
  }

  Offset _draw3DCupAndFluidSurface(
    Canvas canvas,
    Offset cupCenter,
    double cupR,
    double ySquash,
  ) {
    // 1. 3D Outer Curved Porcelain Bowl Wall
    if (!topDownInspectionMode) {
      final double bowlDepth = cupR * 0.56;
      final Path bowlBody = Path()
        ..moveTo(cupCenter.dx - cupR, cupCenter.dy)
        ..cubicTo(
          cupCenter.dx - cupR * 0.96,
          cupCenter.dy + bowlDepth * 1.24,
          cupCenter.dx + cupR * 0.96,
          cupCenter.dy + bowlDepth * 1.24,
          cupCenter.dx + cupR,
          cupCenter.dy,
        )
        ..close();

      final bowlBounds = bowlBody.getBounds();
      canvas.drawPath(
        bowlBody,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cupTheme.outerLight,
              cupTheme.outerDark,
              Color.lerp(cupTheme.outerDark, Colors.black, 0.38)!,
            ],
          ).createShader(bowlBounds),
      );
    }

    // 2. Outer Ceramic Rim + Thick Glazed White Porcelain Inner Wall
    final outerRimRect = Rect.fromCenter(
      center: cupCenter,
      width: cupR * 2.0,
      height: cupR * 2.0 * ySquash,
    );
    canvas.drawOval(outerRimRect, Paint()..color = cupTheme.outerLight);

    final innerWallRect = Rect.fromCenter(
      center: cupCenter,
      width: cupR * 1.88,
      height: cupR * 1.88 * ySquash,
    );
    canvas.drawOval(
      innerWallRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD5CFC7),
            Color(0xFFF6F3EE),
            Color(0xFFFFFFFF),
          ],
        ).createShader(innerWallRect),
    );

    // 3. Rising Liquid Level Inside the 3D Cup (ZERO Pixelation Anti-Aliased Clip!)
    final double fillNorm = (cfd.cupFillPct / 100.0).clamp(0.18, 1.0);
    final double dropDown =
        topDownInspectionMode ? 0.0 : (1.0 - fillNorm) * (cupR * 0.22);
    final double radiusScale = 0.80 + 0.14 * fillNorm;
    final Offset liquidCenter = cupCenter + Offset(0, dropDown);
    final Rect liquidOval = Rect.fromCenter(
      center: liquidCenter,
      width: cupR * 2.0 * radiusScale,
      height: cupR * 2.0 * radiusScale * ySquash,
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(innerWallRect), doAntiAlias: true);
    canvas.save();
    canvas.clipPath(Path()..addOval(liquidOval), doAntiAlias: true);

    if (fluidImage != null) {
      // Sample inner 96% of 112x112 buffer so edge crema fills the anti-aliased oval 100% smoothly!
      final double inset = fluidImage!.width * 0.025;
      canvas.drawImageRect(
        fluidImage!,
        Rect.fromLTWH(
          inset,
          inset,
          fluidImage!.width.toDouble() - inset * 2,
          fluidImage!.height.toDouble() - inset * 2,
        ),
        liquidOval,
        Paint()
          ..filterQuality = FilterQuality.high
          ..isAntiAlias = true,
      );
    } else {
      canvas.drawOval(
        liquidOval,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFF9E5A2B), Color(0xFF6B3312)],
          ).createShader(liquidOval),
      );
    }

    // Subtle porcelain-to-crema contact meniscus shadow ring
    canvas.drawOval(
      liquidOval.deflate(0.5),
      Paint()
        ..color = const Color(0xFF2B1105).withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // Subtle glossy overhead café window reflection arc across microfoam surface
    canvas.drawArc(
      liquidOval.deflate(liquidOval.width * 0.10),
      -math.pi * 0.82,
      math.pi * 0.36,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );

    if (showGhostGuide) {
      _drawGhostGuide(canvas, liquidCenter, liquidOval.width * 0.48, ySquash);
    }

    canvas.restore();
    canvas.restore();

    // Crisp glazed porcelain lip rim highlight
    canvas.drawOval(
      innerWallRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.94)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );

    final Offset streamImpact = Offset(
      liquidCenter.dx + cfd.pourPos.dx * (liquidOval.width * 0.46),
      liquidCenter.dy + cfd.pourPos.dy * (liquidOval.height * 0.46),
    );

    // Subtle delicate steam wisps rising from hot espresso/milk
    if (!topDownInspectionMode) {
      for (int s = 0; s < 3; s++) {
        final double ph = (cfd.elapsedSec * 0.42 + s * 0.33) % 1.0;
        final Offset sp = Offset(
          liquidCenter.dx + math.sin(cfd.elapsedSec + s * 2.1) * cupR * 0.24,
          liquidCenter.dy - ph * cupR * 0.95,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: sp,
            width: 18 + ph * 22,
            height: 24 + ph * 28,
          ),
          Paint()
            ..color =
                Colors.white.withValues(alpha: math.sin(ph * math.pi) * 0.10)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );
      }
    }

    // Subtle target reticle when idle
    if (cfd.pitcherSlosh.currentFlowMlS <= 0.22 && !topDownInspectionMode) {
      canvas.drawOval(
        Rect.fromCenter(center: streamImpact, width: 14, height: 11),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    return streamImpact;
  }

  void _draw3DRimSpillDrips(
    Canvas canvas,
    Offset cupCenter,
    double cupR,
    double ySquash,
  ) {
    if (topDownInspectionMode) return;
    const angles = [0.22, 0.48, 0.72, 1.05, 1.38, 1.85, 2.35];
    for (int i = 0; i < cfd.rimSpillDrops.length; i++) {
      final double len = cfd.rimSpillDrops[i];
      if (len <= 0.02) continue;
      final double a = angles[i % angles.length];
      final double rimX = cupCenter.dx + math.cos(a) * cupR * 0.96;
      final double rimY =
          cupCenter.dy + math.sin(a).abs() * cupR * ySquash * 0.95;
      final double dripH = 8.0 + len * (cupR * 0.36);
      final bool whiteDrip = i.isEven;
      final Color col =
          whiteDrip ? const Color(0xFFFAF6EE) : const Color(0xFFC68B59);

      final dripRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(rimX - 4.5, rimY - 2, 9.0, dripH),
        const Radius.circular(5),
      );
      canvas.drawRRect(dripRect, Paint()..color = col);
      canvas.drawCircle(
        Offset(rimX, rimY + dripH),
        5.5,
        Paint()..color = col,
      );
    }
  }

  /// FIRST-PERSON BARISTA POV:
  /// Renders the photorealistic 3D Brushed Stainless-Steel (or Glass) Barista Milk Pitcher
  /// in the FOREGROUND (lower-right / lower-left, closest to the user's pouring hand!)
  /// tilted FORWARD over the cup lip, pouring a silky 3D tapered milk stream FORWARD!
  void _drawForegroundBaristaPitcherAndStream(
    Canvas canvas, {
    required Size size,
    required Offset cupCenter,
    required double cupR,
    required Offset streamImpactScreen,
  }) {
    final double flow = cfd.pitcherSlosh.currentFlowMlS;
    final double alphaFloat = cfd.computeFloatFactor(cfd.pourHeightCm, flow);
    final double heightNorm =
        ((cfd.pourHeightCm - 0.6) / 6.0).clamp(0.0, 1.0); // 0 = close, 1 = high
    final double side = pitcherOnRight ? 1.0 : -1.0;

    // FOREGROUND POV Geometry:
    // Spout tip sits slightly toward the barista's foreground (+Y) & elevated by `pourHeightCm`!
    // When low pour (close to crema), spout hugs the cup surface right in front of `streamImpactScreen`.
    // When high pour (dive), pitcher lifts cleanly higher & slightly back toward the barista.
    final Offset spoutTip = Offset(
      streamImpactScreen.dx + side * cupR * (0.14 + heightNorm * 0.10),
      streamImpactScreen.dy + cupR * (0.18 + heightNorm * 0.14) -
          cupR * (0.14 + heightNorm * 0.34),
    );

    // 1. 3D Tapered Parabolic Milk Stream arching FORWARD from Foreground Spout Tip -> Crema!
    if (flow > 0.20) {
      final double topW =
          (alphaFloat > 0.45 ? 8.2 : 3.6) * (0.65 + (flow / 17.0) * 0.60);
      final double botW = alphaFloat > 0.45 ? topW * 0.84 : 2.3;
      final double curveSway = (activeRollDeg / 45.0) * 7.5;

      // Parabolic control point bends forward from spout tip into crema surface
      final Offset midCtrl = Offset(
        (spoutTip.dx + streamImpactScreen.dx) * 0.5 + curveSway,
        math.min(spoutTip.dy, streamImpactScreen.dy) - 6.0 + heightNorm * 14.0,
      );

      final List<Offset> leftPts = [];
      final List<Offset> rightPts = [];
      const int segs = 14;
      for (int i = 0; i <= segs; i++) {
        final double t = i / segs;
        final double u = 1.0 - t;
        final Offset pt = Offset(
          u * u * spoutTip.dx +
              2 * u * t * midCtrl.dx +
              t * t * streamImpactScreen.dx,
          u * u * spoutTip.dy +
              2 * u * t * midCtrl.dy +
              t * t * streamImpactScreen.dy,
        );
        final double hw = (topW + (botW - topW) * t) * 0.5;
        leftPts.add(Offset(pt.dx - hw, pt.dy));
        rightPts.add(Offset(pt.dx + hw, pt.dy));
      }

      final Path streamPath = Path()..moveTo(leftPts.first.dx, leftPts.first.dy);
      for (final p in leftPts) {
        streamPath.lineTo(p.dx, p.dy);
      }
      for (int i = rightPts.length - 1; i >= 0; i--) {
        streamPath.lineTo(rightPts[i].dx, rightPts[i].dy);
      }
      streamPath.close();

      // Subtle milk stream shadow onto crema
      canvas.drawPath(
        streamPath.shift(const Offset(2, 4)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Silky gleaming steamed milk ribbon
      canvas.drawPath(
        streamPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0xFFEDE4D7),
              Color(0xFFFFFFFF),
              Color(0xFFF6F0E6),
            ],
          ).createShader(streamPath.getBounds()),
      );

      // Animated Microfoam Crown & Concentric Surface Ripple at Impact Point!
      canvas.drawOval(
        Rect.fromCenter(
          center: streamImpactScreen,
          width: botW * 3.4,
          height: botW * 2.5,
        ),
        Paint()
          ..color = Colors.white
              .withValues(alpha: alphaFloat > 0.4 ? 0.88 : 0.36),
      );
      final double rp = (cfd.elapsedSec * 2.8) % 1.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: streamImpactScreen,
          width: botW * (2.6 + rp * 5.0),
          height: botW * (1.8 + rp * 3.4),
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: (1.0 - rp) * 0.42)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    // 2. FOREGROUND 3D Brushed Stainless-Steel / Glass Barista Pitcher!
    // Anchored at `spoutTip` (0, 0), body extends DOWN-RIGHT (or DOWN-LEFT) into the foreground!
    canvas.save();
    canvas.translate(spoutTip.dx, spoutTip.dy);

    final double pourTilt =
        ((activePitchDeg / 48.0).clamp(0.0, 1.0)) * 0.36;
    final double wiggleTilt = (activeRollDeg / 90.0).clamp(-0.32, 0.32);
    // Natural barista wrist angle: pitcher angled forward toward cup center!
    canvas.rotate(side * (-0.30 - pourTilt) + wiggleTilt);

    final double pW = cupR * 0.94;
    final double pH = cupR * 1.12;
    // In local pitcher space: V-spout tip is at (0, 0); body extends DOWN (+Y) & slightly outward (`side * X`)!
    final Rect bodyRect = Rect.fromLTWH(
      side > 0 ? -pW * 0.16 : -pW * 0.84,
      pH * 0.06,
      pW,
      pH,
    );

    // Soft cast shadow projected onto lower cup rim & walnut bar
    canvas.drawOval(
      bodyRect.shift(Offset(side * 8, 16)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // Ergonomic Welded Stainless-Steel Handle (on user-facing lower/outer side!)
    final double handleX = side > 0 ? bodyRect.right : bodyRect.left;
    final Path pHandle = Path()
      ..moveTo(handleX - side * pW * 0.08, bodyRect.top + pH * 0.24)
      ..cubicTo(
        handleX + side * pW * 0.40,
        bodyRect.top + pH * 0.20,
        handleX + side * pW * 0.38,
        bodyRect.bottom - pH * 0.14,
        handleX - side * pW * 0.06,
        bodyRect.bottom - pH * 0.18,
      );
    canvas.drawPath(
      pHandle,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = pW * 0.11
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      pHandle.shift(Offset(-side * 1.5, -1.5)),
      Paint()
        ..color = const Color(0xFFF1F5F9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = pW * 0.04
        ..strokeCap = StrokeCap.round,
    );

    // Sculpted Conical Barista Pitcher Silhouette tapering forward to sharp V-spout at (0, 0)
    final Path pitcherBody = Path()
      ..moveTo(0, 0) // Sharp precision V-spout tip pointing FORWARD!
      ..quadraticBezierTo(
        bodyRect.left - pW * 0.04,
        bodyRect.top + pH * 0.16,
        bodyRect.left + pW * 0.02,
        bodyRect.bottom - pH * 0.10,
      )
      ..cubicTo(
        bodyRect.left + pW * 0.10,
        bodyRect.bottom + pH * 0.10,
        bodyRect.right - pW * 0.10,
        bodyRect.bottom + pH * 0.10,
        bodyRect.right - pW * 0.02,
        bodyRect.bottom - pH * 0.10,
      )
      ..quadraticBezierTo(
        bodyRect.right + pW * 0.04,
        bodyRect.top + pH * 0.16,
        0,
        0,
      )
      ..close();

    if (transparentGlassPitcher) {
      // Crystal Borosilicate Glass Pitcher + Live Sloshing Steamed Milk & Microfoam!
      canvas.drawPath(
        pitcherBody,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withValues(alpha: 0.56),
              const Color(0xFFE2E8F0).withValues(alpha: 0.24),
              Colors.white.withValues(alpha: 0.52),
            ],
          ).createShader(bodyRect),
      );
      canvas.save();
      canvas.clipPath(pitcherBody);
      final double fill = cfd.pitcherSlosh.fillFraction.clamp(0.08, 1.0);
      final double liqTop = bodyRect.bottom - bodyRect.height * (0.28 + 0.58 * fill);
      final double slosh =
          math.tan((cfd.pitcherSlosh.psiXRad).clamp(-0.5, 0.5)) * (pW * 0.42);
      final Path milkPoly = Path()
        ..moveTo(bodyRect.left - 18, bodyRect.bottom + 24)
        ..lineTo(bodyRect.left - 12, liqTop - slosh)
        ..lineTo(bodyRect.right + 18, liqTop + slosh)
        ..lineTo(bodyRect.right + 18, bodyRect.bottom + 24)
        ..close();
      canvas.drawPath(
        milkPoly,
        Paint()..color = const Color(0xFFF6EFE4).withValues(alpha: 0.90),
      );
      canvas.restore();
      canvas.drawPath(
        pitcherBody,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    } else {
      // Photorealistic Brushed Stainless-Steel Chrome Barista Pitcher (Motta / WPM style!)
      canvas.drawPath(
        pitcherBody,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.22, 0.46, 0.72, 0.88, 1.0],
            colors: const [
              Color(0xFF64748B),
              Color(0xFFE2E8F0),
              Color(0xFFFFFFFF),
              Color(0xFF94A3B8),
              Color(0xFF475569),
              Color(0xFFCBD5E1),
            ],
          ).createShader(bodyRect),
      );
      // Crisp specular metallic rim outline
      canvas.drawPath(
        pitcherBody,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    // 3D Open Top Mouth of Foreground Pitcher (Looking slightly DOWN into gleaming white milk!)
    final Rect openMouth = Rect.fromCenter(
      center: Offset(bodyRect.center.dx * 0.72, bodyRect.top + pH * 0.24),
      width: pW * 0.78,
      height: pH * 0.34,
    );
    // Polished steel inner wall rim
    canvas.drawOval(
      openMouth,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF475569), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
        ).createShader(openMouth),
    );

    // Glossy Swirling Steamed Milk Pool inside Pitcher Mouth (shifts forward as you tilt!)
    canvas.save();
    canvas.clipPath(Path()..addOval(openMouth.deflate(3.0)));
    final double milkShiftY = -pourTilt * pH * 0.16 + cfd.pitcherSlosh.psiXRad * 10.0;
    final Rect milkPool = openMouth.deflate(3.5).shift(Offset(0, milkShiftY));
    canvas.drawOval(
      milkPool,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.2),
          colors: [Color(0xFFFFFFFF), Color(0xFFF3ECE0)],
        ).createShader(milkPool),
    );
    // Subtle milk vortex sheen inside pitcher
    canvas.drawArc(
      milkPool.deflate(6),
      0.4,
      2.2,
      false,
      Paint()
        ..color = const Color(0xFFE6DCCB).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    canvas.restore();

    // Gleaming V-Spout Inner Channel Highlight leading right to (0, 0)
    canvas.drawLine(
      Offset(openMouth.center.dx * 0.45, openMouth.top + 4),
      const Offset(0, 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.92)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  void _drawLatteArrow(
    Canvas canvas,
    Offset tip,
    Offset dir, {
    double arrowSize = 9.5,
    Color color = const Color(0xFFFBBF24),
  }) {
    final double len = dir.distance;
    if (len < 1e-4) return;
    final Offset u = dir / len;
    final Offset perp = Offset(-u.dy, u.dx);
    final Offset back = tip - u * arrowSize;
    final Offset leftWing = back + perp * (arrowSize * 0.58);
    final Offset rightWing = back - perp * (arrowSize * 0.58);

    final Path arrowPath = Path()
      ..moveTo(leftWing.dx, leftWing.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(rightWing.dx, rightWing.dy);

    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawGhostGuide(
    Canvas canvas,
    Offset c,
    double r,
    double ySquash,
  ) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final double ry = r * ySquash;
    final double t = cfd.elapsedSec;
    final int stage = cfd.currentLatteStage;

    // 1. Pattern Silhouette Ghost
    switch (targetPattern) {
      case LatteArtPattern.canvasBase:
        canvas.drawOval(
            Rect.fromCenter(center: c, width: r * 0.5, height: ry * 0.5), p);
        break;
      case LatteArtPattern.monksHead:
        canvas.drawOval(
            Rect.fromCenter(center: c, width: r * 0.85, height: ry * 0.85), p);
        break;
      case LatteArtPattern.heart:
        final path = Path()
          ..moveTo(c.dx, c.dy + ry * 0.52)
          ..cubicTo(
            c.dx - r * 0.65,
            c.dy + ry * 0.08,
            c.dx - r * 0.46,
            c.dy - ry * 0.48,
            c.dx,
            c.dy - ry * 0.16,
          )
          ..cubicTo(
            c.dx + r * 0.46,
            c.dy - ry * 0.48,
            c.dx + r * 0.65,
            c.dy + ry * 0.08,
            c.dx,
            c.dy + ry * 0.52,
          );
        canvas.drawPath(path, p);
        break;
      case LatteArtPattern.twoStackTulip:
      case LatteArtPattern.threeStackTulip:
      case LatteArtPattern.wingedFiveTulip:
      case LatteArtPattern.wingedBase:
        for (int s = 0; s < 3; s++) {
          final double offY = (1 - s) * ry * 0.22;
          final double w = r * (1.05 - s * 0.20);
          canvas.drawArc(
            Rect.fromCenter(
                center: c + Offset(0, offY), width: w, height: ry * 0.55),
            0.1,
            math.pi - 0.2,
            false,
            p,
          );
        }
        break;
      case LatteArtPattern.rosetta:
      case LatteArtPattern.slowsetta:
        canvas.drawLine(c + Offset(0, ry * 0.55), c - Offset(0, ry * 0.52), p);
        for (int i = -2; i <= 2; i++) {
          final double y = c.dy + i * (ry * 0.18);
          final double w = r * (0.44 - (i.abs() * 0.06));
          canvas.drawOval(
            Rect.fromCenter(
                center: Offset(c.dx, y), width: w * 2, height: ry * 0.14),
            p,
          );
        }
        break;
      case LatteArtPattern.swan:
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(r * 0.18, ry * 0.16),
            width: r * 0.78,
            height: ry * 0.45,
          ),
          p,
        );
        final neck = Path()
          ..moveTo(c.dx - r * 0.18, c.dy + ry * 0.25)
          ..cubicTo(
            c.dx - r * 0.35,
            c.dy - ry * 0.05,
            c.dx + r * 0.05,
            c.dy - ry * 0.25,
            c.dx - r * 0.12,
            c.dy - ry * 0.48,
          );
        canvas.drawPath(neck, p);
        canvas.drawCircle(c + Offset(-r * 0.14, -ry * 0.52), r * 0.10, p);
        break;
    }

    // 2. Animated Phase-Aware Directional Movement Arrows (super clear for beginners!)
    final double pulse = 0.5 + 0.5 * math.sin(t * 4.5);
    if (stage == 0 || targetPattern == LatteArtPattern.canvasBase) {
      // Stage 0 (Dive / Canvas): Gentle circular orbit arrows around center
      final double orbitR = r * 0.34;
      for (int k = 0; k < 3; k++) {
        final double a = (k / 3.0) * math.pi * 2.0 + t * 1.4;
        final double a2 = a + 0.22;
        final Offset p0 = c + Offset(math.cos(a) * orbitR, math.sin(a) * orbitR * ySquash);
        final Offset p1 = c + Offset(math.cos(a2) * orbitR, math.sin(a2) * orbitR * ySquash);
        _drawLatteArrow(canvas, p1, p1 - p0, arrowSize: 8.5, color: const Color(0xFFFDE68A));
      }
      return;
    }

    if (stage == 2 && targetPattern != LatteArtPattern.monksHead) {
      // Stage 2 (Pull-Through Cut): Bold animated upward arrow straight through the center!
      final double cutFrac = (t * 1.1) % 1.0;
      final Offset bot = c + Offset(0, ry * 0.45);
      final Offset top = c - Offset(0, ry * 0.56);
      canvas.drawLine(
        bot,
        top,
        Paint()
          ..color = const Color(0xFF34D399).withValues(alpha: 0.72)
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
      final Offset movingTip = Offset.lerp(bot, top, cutFrac)!;
      _drawLatteArrow(
        canvas,
        movingTip,
        top - bot,
        arrowSize: 11.5,
        color: const Color(0xFF34D399),
      );
      return;
    }

    // Stage 1 (Float / Draw Pattern)
    switch (targetPattern) {
      case LatteArtPattern.heart:
      case LatteArtPattern.monksHead:
        canvas.drawOval(
          Rect.fromCenter(
            center: c,
            width: r * (0.28 + pulse * 0.14),
            height: ry * (0.28 + pulse * 0.14),
          ),
          Paint()
            ..color = const Color(0xFFFBBF24).withValues(alpha: 0.75)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
        break;
      case LatteArtPattern.twoStackTulip:
      case LatteArtPattern.threeStackTulip:
      case LatteArtPattern.wingedFiveTulip:
        // Animated forward push arrows (↑)
        final double pushT = (t * 1.3) % 1.0;
        final Offset start = c + Offset(0, ry * 0.28);
        final Offset end = c - Offset(0, ry * 0.34);
        canvas.drawLine(
          start,
          end,
          Paint()
            ..color = const Color(0xFFFBBF24).withValues(alpha: 0.65)
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round,
        );
        _drawLatteArrow(
          canvas,
          Offset.lerp(start, end, pushT)!,
          end - start,
          arrowSize: 10.5,
          color: const Color(0xFFFBBF24),
        );
        break;
      case LatteArtPattern.wingedBase:
      case LatteArtPattern.rosetta:
      case LatteArtPattern.slowsetta:
      case LatteArtPattern.swan:
        // Animated left-right wiggle arrows (⇄) + gentle pull-back arrow (↓)
        final double wig = math.sin(t * 7.5) * r * 0.24;
        final Offset leftPt = c + Offset(-r * 0.34, 0);
        final Offset rightPt = c + Offset(r * 0.34, 0);
        canvas.drawLine(
          leftPt,
          rightPt,
          Paint()
            ..color = const Color(0xFFFBBF24).withValues(alpha: 0.65)
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round,
        );
        _drawLatteArrow(canvas, leftPt, const Offset(-1, 0), arrowSize: 9.0);
        _drawLatteArrow(canvas, rightPt, const Offset(1, 0), arrowSize: 9.0);
        canvas.drawCircle(
          c + Offset(wig, 0),
          5.0,
          Paint()..color = const Color(0xFFFBBF24),
        );
        break;
      case LatteArtPattern.canvasBase:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant LatteArtFull3DScenePainter oldDelegate) => true;
}
