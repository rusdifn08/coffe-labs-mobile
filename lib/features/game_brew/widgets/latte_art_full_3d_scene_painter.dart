import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../domain/game_brew_studio_models.dart';
import '../engine/latte_art_cfd_engine.dart';

/// Ceramic cup color palette matching the reference Latte Art 3D studio.
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

/// Full-Screen 3D Perspective Latte Art Studio Painter:
/// - Full-bleed warm walnut barista wood table with grain & studio lighting
/// - 3D Saucer + 3D Curved Ceramic Latte Bowl + Sculpted 3D Handle + Rising Inner Liquid Level
/// - 3D Rim Overflow Spill Drips & Saucer Puddle when overfilled (> 100%)
/// - 3D Hovering & Tilting Milk Pitcher (Transparent Borosilicate Glass OR Ceramic Matte)
///   with visible sloshing internal milk/microfoam, V-spout & 3D Tapered Milk Stream!
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

  const LatteArtFull3DScenePainter({
    required this.cfd,
    required this.fluidImage,
    required this.cupTheme,
    this.transparentGlassPitcher = true,
    this.topDownInspectionMode = false,
    required this.showGhostGuide,
    required this.targetPattern,
    required this.activePitchDeg,
    required this.activeRollDeg,
  });

  /// Helper to convert a local screen touch inside [size] into normalized cup coords `[-0.8..0.8]`.
  static Offset screenToCupNormalized(
    Offset localPos,
    Size size, {
    required bool isLandscape,
    required bool topDown,
  }) {
    final center = cupCenterForSize(size, isLandscape: isLandscape, topDown: topDown);
    final double cupR = cupRadiusForSize(size, isLandscape: isLandscape);
    final double tiltYScale = topDown ? 1.0 : 0.84;
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
    return Offset(
      size.width * (isLandscape ? 0.52 : 0.54),
      size.height * (isLandscape ? 0.58 : 0.56),
    );
  }

  static double cupRadiusForSize(Size size, {required bool isLandscape}) {
    final double shortest = math.min(size.width, size.height);
    return isLandscape ? shortest * 0.34 : shortest * 0.36;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bool isLandscape = size.width > size.height;

    // 1. Full-Bleed Walnut Barista Wood Countertop
    _drawWoodCountertop(canvas, size);

    final Offset cupCenter = cupCenterForSize(
      size,
      isLandscape: isLandscape,
      topDown: topDownInspectionMode,
    );
    final double cupR = cupRadiusForSize(size, isLandscape: isLandscape);
    final double ySquash = topDownInspectionMode ? 1.0 : 0.84;

    // 2. 3D Wide Ceramic Saucer + Spill Puddle
    _draw3DSaucer(canvas, cupCenter, cupR, ySquash);

    // 3. 3D Curved Ceramic Cup Handle (Right Side)
    _draw3DCupHandle(canvas, cupCenter, cupR, ySquash);

    // 4. 3D Outer Ceramic Bowl Body + Rim Lip + Inner Rising Crema Surface
    final Offset streamImpactScreen = _draw3DCupAndFluidSurface(
      canvas,
      cupCenter,
      cupR,
      ySquash,
    );

    // 5. 3D Rim Spill Drips (when overfilled > 100%, just like 69s-70s of reference video!)
    if (cfd.spilled) {
      _draw3DRimSpillDrips(canvas, cupCenter, cupR, ySquash);
    }

    // 6. 3D Sculpted Milk Pitcher Hovering & Tilting Above the Cup!
    if (!topDownInspectionMode) {
      _draw3DPitcherAndMilkStream(
        canvas,
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
            Color(0xFF7A5238),
            Color(0xFF66422B),
            Color(0xFF533421),
          ],
        ).createShader(rect),
    );

    // Horizontal wood planks & subtle natural grain lines
    final plankLinePaint = Paint()
      ..color = const Color(0xFF3B2214).withValues(alpha: 0.34)
      ..strokeWidth = 1.6;
    final grainPaint = Paint()
      ..color = const Color(0xFF8E6346).withValues(alpha: 0.16)
      ..strokeWidth = 1.1;

    const double plankH = 68.0;
    for (double y = 24.0; y < size.height; y += plankH) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), plankLinePaint);
      for (int g = 1; g <= 3; g++) {
        final double gy = y + g * (plankH / 4.0);
        final path = Path()..moveTo(0, gy);
        for (double x = 0; x <= size.width; x += 60) {
          path.lineTo(x, gy + math.sin(x * 0.02 + y) * 1.8);
        }
        canvas.drawPath(
          path,
          grainPaint..style = PaintingStyle.stroke,
        );
      }
    }
  }

  void _draw3DSaucer(
    Canvas canvas,
    Offset cupCenter,
    double cupR,
    double ySquash,
  ) {
    final Offset saucerCenter =
        cupCenter + Offset(0, topDownInspectionMode ? 0 : cupR * 0.18);
    final double saucerRx = cupR * 1.46;
    final double saucerRy = saucerRx * (topDownInspectionMode ? 1.0 : 0.80);

    // Table drop shadow under saucer
    canvas.drawOval(
      Rect.fromCenter(
        center: saucerCenter + const Offset(4, 14),
        width: saucerRx * 2.04,
        height: saucerRy * 2.04,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.36)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Table overflow coffee puddle if heavily spilled (70s of video)
    if (cfd.spillAmountMl > 8.0) {
      final double puddleGrow = (cfd.spillAmountMl / 35.0).clamp(0.15, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: saucerCenter + Offset(-cupR * 0.15, cupR * 0.12),
          width: saucerRx * (1.8 + puddleGrow * 0.7),
          height: saucerRy * (1.6 + puddleGrow * 0.6),
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
      width: cupR * 1.45,
      height: cupR * 1.45 * ySquash,
    );
    canvas.drawOval(
      wellRect,
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    // Specular saucer rim highlight
    canvas.drawOval(
      saucerRect.deflate(1.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
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
    final Offset attachTop =
        cupCenter + Offset(cupR * 0.92, -cupR * 0.08 * ySquash);
    final Offset attachBot =
        cupCenter + Offset(cupR * 0.80, cupR * 0.30 * ySquash);
    final Path handlePath = Path()
      ..moveTo(attachTop.dx, attachTop.dy)
      ..cubicTo(
        cupCenter.dx + cupR * 1.38,
        cupCenter.dy - cupR * 0.14 * ySquash,
        cupCenter.dx + cupR * 1.36,
        cupCenter.dy + cupR * 0.36 * ySquash,
        attachBot.dx,
        attachBot.dy,
      );

    // Handle shadow
    canvas.drawPath(
      handlePath.shift(const Offset(2, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cupR * 0.16
        ..strokeCap = StrokeCap.round,
    );
    // Handle ceramic body
    canvas.drawPath(
      handlePath,
      Paint()
        ..color = cupTheme.outerDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = cupR * 0.16
        ..strokeCap = StrokeCap.round,
    );
    // Handle specular highlight
    canvas.drawPath(
      handlePath.shift(const Offset(-1, -2)),
      Paint()
        ..color = cupTheme.outerLight.withValues(alpha: 0.85)
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
    // 1. 3D Outer Curved Bowl Wall (visible below the rim in 3/4 barista view!)
    if (!topDownInspectionMode) {
      final double bowlDepth = cupR * 0.56;
      final Path bowlBody = Path()
        ..moveTo(cupCenter.dx - cupR, cupCenter.dy)
        ..cubicTo(
          cupCenter.dx - cupR * 0.96,
          cupCenter.dy + bowlDepth * 1.25,
          cupCenter.dx + cupR * 0.96,
          cupCenter.dy + bowlDepth * 1.25,
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
              Color.lerp(cupTheme.outerDark, Colors.black, 0.35)!,
            ],
          ).createShader(bowlBounds),
      );
    }

    // 2. Outer Rim & Thick Glazed White Inner Porcelain Lip
    final outerRimRect = Rect.fromCenter(
      center: cupCenter,
      width: cupR * 2.0,
      height: cupR * 2.0 * ySquash,
    );
    canvas.drawOval(outerRimRect, Paint()..color = cupTheme.outerLight);

    final innerWallRect = Rect.fromCenter(
      center: cupCenter,
      width: cupR * 1.89,
      height: cupR * 1.89 * ySquash,
    );
    // Glazed inner porcelain wall (shaded top-to-bottom so rising liquid looks 3D!)
    canvas.drawOval(
      innerWallRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFFDCD6CE),
            Color(0xFFFAF8F5),
            Color(0xFFFFFFFF),
          ],
        ).createShader(innerWallRect),
    );

    // 3. Rising Liquid Level Inside the 3D Cup!
    // At 18% fill, liquid sits deeper inside the cup; at 100%, it reaches the very lip!
    final double fillNorm = (cfd.cupFillPct / 100.0).clamp(0.18, 1.0);
    final double dropDown = topDownInspectionMode
        ? 0.0
        : (1.0 - fillNorm) * (cupR * 0.24);
    final double radiusScale = 0.80 + 0.14 * fillNorm;
    final Offset liquidCenter = cupCenter + Offset(0, dropDown);
    final Rect liquidOval = Rect.fromCenter(
      center: liquidCenter,
      width: cupR * 2.0 * radiusScale,
      height: cupR * 2.0 * radiusScale * ySquash,
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(innerWallRect));
    canvas.save();
    canvas.clipPath(Path()..addOval(liquidOval));

    if (fluidImage != null) {
      canvas.drawImageRect(
        fluidImage!,
        Rect.fromLTWH(
          0,
          0,
          fluidImage!.width.toDouble(),
          fluidImage!.height.toDouble(),
        ),
        liquidOval,
        Paint()..filterQuality = FilterQuality.high,
      );
    } else {
      canvas.drawOval(liquidOval, Paint()..color = const Color(0xFF783E18));
    }

    if (showGhostGuide) {
      _drawGhostGuide(canvas, liquidCenter, liquidOval.width * 0.48, ySquash);
    }

    canvas.restore();
    canvas.restore();

    // Crisp porcelain top lip ring highlight
    canvas.drawOval(
      innerWallRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );

    final Offset streamImpact = Offset(
      liquidCenter.dx + cfd.pourPos.dx * (liquidOval.width * 0.48),
      liquidCenter.dy + cfd.pourPos.dy * (liquidOval.height * 0.48),
    );

    // Subtle target reticle when idle
    if (cfd.pitcherSlosh.currentFlowMlS <= 0.22 && !topDownInspectionMode) {
      canvas.drawCircle(
        streamImpact,
        5.5,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
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
      final double rimY = cupCenter.dy + math.sin(a).abs() * cupR * ySquash * 0.95;
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

  /// Renders the 3D Milk Pitcher hovering above the cup, tilting with Gyroscope/Slider,
  /// showing real sloshing internal milk/microfoam, and pouring a 3D milk stream!
  void _draw3DPitcherAndMilkStream(
    Canvas canvas, {
    required Offset cupCenter,
    required double cupR,
    required Offset streamImpactScreen,
  }) {
    final double flow = cfd.pitcherSlosh.currentFlowMlS;
    final double alphaFloat = cfd.computeFloatFactor(cfd.pourHeightCm, flow);
    final double heightNorm =
        ((cfd.pourHeightCm - 0.6) / 6.9).clamp(0.0, 1.0); // 0 = close, 1 = high

    // Spout tip hovers above `streamImpactScreen`: closer when Low Pour, higher when High Pour!
    final double verticalGap = cupR * (0.14 + heightNorm * 0.68);
    final Offset spoutTip =
        streamImpactScreen - Offset(cupR * 0.08, verticalGap);

    // 1. 3D Tapered Milk Stream from Pitcher Spout Tip -> Crema Dimple!
    if (flow > 0.22) {
      final double topW =
          (alphaFloat > 0.45 ? 7.5 : 3.4) * (0.65 + (flow / 17.0) * 0.65);
      final double botW = alphaFloat > 0.45 ? topW * 0.82 : 2.2;
      final double curveSway = (activeRollDeg / 45.0) * 8.0;

      final Path streamPath = Path()
        ..moveTo(spoutTip.dx - topW * 0.5, spoutTip.dy)
        ..quadraticBezierTo(
          (spoutTip.dx + streamImpactScreen.dx) * 0.5 + curveSway - botW,
          (spoutTip.dy + streamImpactScreen.dy) * 0.5,
          streamImpactScreen.dx - botW * 0.5,
          streamImpactScreen.dy,
        )
        ..lineTo(streamImpactScreen.dx + botW * 0.5, streamImpactScreen.dy)
        ..quadraticBezierTo(
          (spoutTip.dx + streamImpactScreen.dx) * 0.5 + curveSway + botW,
          (spoutTip.dy + streamImpactScreen.dy) * 0.5,
          spoutTip.dx + topW * 0.5,
          spoutTip.dy,
        )
        ..close();

      canvas.drawPath(
        streamPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Color(0xFFFFFFFF),
              Color(0xFFF5EFE6),
            ],
          ).createShader(streamPath.getBounds()),
      );

      // Soft impact foam crown ripple
      canvas.drawOval(
        Rect.fromCenter(
          center: streamImpactScreen,
          width: botW * 3.2,
          height: botW * 2.4,
        ),
        Paint()..color = Colors.white.withValues(alpha: alphaFloat > 0.4 ? 0.85 : 0.35),
      );
    }

    // 2. 3D Sculpted Milk Pitcher Body (anchored so its sharp V-spout sits at `spoutTip`)
    canvas.save();
    canvas.translate(spoutTip.dx, spoutTip.dy);

    final double tiltRad =
        (0.42 + (activePitchDeg / 55.0) * 0.58 + (activeRollDeg / 140.0))
            .clamp(0.28, 1.18);
    canvas.rotate(tiltRad);

    final double pW = cupR * 0.86;
    final double pH = cupR * 0.98;
    // Spout tip is at (0, 0); pitcher body extends up-left in local rotated frame
    final Rect bodyRect = Rect.fromLTWH(-pW * 0.95, -pH * 0.92, pW, pH);

    // Pitcher Drop Shadow onto Cup
    canvas.drawOval(
      bodyRect.shift(const Offset(8, 18)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // 3D Ergonomic Pitcher Handle (top-back)
    final Path pHandle = Path()
      ..moveTo(bodyRect.left + pW * 0.12, bodyRect.top + pH * 0.14)
      ..cubicTo(
        bodyRect.left - pW * 0.34,
        bodyRect.top - pH * 0.10,
        bodyRect.left - pW * 0.36,
        bodyRect.bottom - pH * 0.25,
        bodyRect.left + pW * 0.06,
        bodyRect.bottom - pH * 0.18,
      );
    canvas.drawPath(
      pHandle,
      Paint()
        ..color = transparentGlassPitcher
            ? Colors.white.withValues(alpha: 0.72)
            : const Color(0xFFD6D2CC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = pW * 0.10
        ..strokeCap = StrokeCap.round,
    );

    // Sculpted 3D Pitcher Silhouette with tapered V-Spout at (0, 0)
    final Path pitcherBody = Path()
      ..moveTo(0, 0) // Sharp V-spout tip!
      ..quadraticBezierTo(
        bodyRect.right + pW * 0.08,
        bodyRect.top + pH * 0.22,
        bodyRect.right - pW * 0.04,
        bodyRect.bottom - pH * 0.10,
      )
      ..cubicTo(
        bodyRect.right - pW * 0.10,
        bodyRect.bottom + pH * 0.06,
        bodyRect.left + pW * 0.12,
        bodyRect.bottom + pH * 0.06,
        bodyRect.left + pW * 0.02,
        bodyRect.bottom - pH * 0.14,
      )
      ..lineTo(bodyRect.left + pW * 0.08, bodyRect.top + pH * 0.08)
      ..quadraticBezierTo(
        bodyRect.center.dx,
        bodyRect.top - pH * 0.05,
        0,
        0,
      )
      ..close();

    if (transparentGlassPitcher) {
      // Crystal Borosilicate Glass Pitcher + Live Sloshing Dual-Layer Milk & Microfoam!
      canvas.drawPath(
        pitcherBody,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.58),
              const Color(0xFFE2E8F0).withValues(alpha: 0.26),
              Colors.white.withValues(alpha: 0.52),
            ],
          ).createShader(bodyRect),
      );

      canvas.save();
      canvas.clipPath(pitcherBody);
      final double fill = cfd.pitcherSlosh.fillFraction.clamp(0.05, 1.0);
      final double liqTop = bodyRect.bottom - bodyRect.height * (0.25 + 0.65 * fill);
      final double slosh =
          math.tan((cfd.pitcherSlosh.psiXRad - tiltRad * 0.45).clamp(-0.6, 0.6)) *
              (pW * 0.45);

      final Path milkPoly = Path()
        ..moveTo(bodyRect.left - 20, bodyRect.bottom + 20)
        ..lineTo(bodyRect.left - 10, liqTop - slosh)
        ..lineTo(bodyRect.right + 20, liqTop + slosh)
        ..lineTo(bodyRect.right + 20, bodyRect.bottom + 20)
        ..close();
      canvas.drawPath(
        milkPoly,
        Paint()..color = const Color(0xFFF4EAD8).withValues(alpha: 0.88),
      );

      // Velvety White Microfoam Top Layer
      final Path foamBand = Path()
        ..moveTo(bodyRect.left - 10, liqTop - slosh)
        ..lineTo(bodyRect.right + 20, liqTop + slosh)
        ..lineTo(bodyRect.right + 20, liqTop + slosh + 14)
        ..lineTo(bodyRect.left - 10, liqTop - slosh + 14)
        ..close();
      canvas.drawPath(foamBand, Paint()..color = Colors.white);

      // Printed ml scale lines on glass wall
      for (int m = 1; m <= 3; m++) {
        final double my = bodyRect.bottom - bodyRect.height * (m * 0.22);
        canvas.drawLine(
          Offset(bodyRect.center.dx - 8, my),
          Offset(bodyRect.center.dx + 8, my),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.35)
            ..strokeWidth = 1.1,
        );
      }
      canvas.restore();

      canvas.drawPath(
        pitcherBody,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.82)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    } else {
      // Matte Barista Ceramic / Brushed Steel Pitcher (matching reference video!)
      canvas.drawPath(
        pitcherBody,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [
              Color(0xFFF2EFEA),
              Color(0xFFD5CFC7),
              Color(0xFFA9A299),
            ],
          ).createShader(bodyRect),
      );
    }

    // 3D Open Top Mouth of Pitcher showing bright white milk pool inside!
    final Rect openMouth = Rect.fromCenter(
      center: Offset(bodyRect.center.dx + pW * 0.08, bodyRect.top + pH * 0.24),
      width: pW * 0.72,
      height: pH * 0.44,
    );
    canvas.drawOval(
      openMouth,
      Paint()..color = const Color(0xFFBDB6AE),
    );
    canvas.drawOval(
      openMouth.deflate(pW * 0.05),
      Paint()..color = const Color(0xFFFCFBF9),
    );

    canvas.restore();
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
      ..strokeWidth = 1.7;
    final double ry = r * ySquash;

    switch (targetPattern) {
      case LatteArtPattern.canvasBase:
        canvas.drawOval(Rect.fromCenter(center: c, width: r * 0.5, height: ry * 0.5), p);
        break;
      case LatteArtPattern.monksHead:
        canvas.drawOval(Rect.fromCenter(center: c, width: r * 0.85, height: ry * 0.85), p);
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
            Rect.fromCenter(center: c + Offset(0, offY), width: w, height: ry * 0.55),
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
            Rect.fromCenter(center: Offset(c.dx, y), width: w * 2, height: ry * 0.14),
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
  }

  @override
  bool shouldRepaint(covariant LatteArtFull3DScenePainter oldDelegate) => true;
}
