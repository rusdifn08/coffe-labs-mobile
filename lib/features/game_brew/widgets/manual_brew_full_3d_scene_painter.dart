import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart'
    show Matrix4, Vector3, Vector4;
import '../domain/game_brew_studio_models.dart';
import '../engine/manual_brew_3d_physics_engine.dart';

enum ManualBrewCameraMode {
  baristaPov('POV 3D'),
  xrayCutaway('X-Ray'),
  topPattern('Atas Pola'),
  freeOrbit('360° Orbit');

  final String label;
  const ManualBrewCameraMode(this.label);
}

/// Photorealistic Full-Screen 3D Perspective Manual Brew Renderer (`Matrix4` 3D Projection):
/// - Full 360° Hario V60 Ceramic Dripper + Full 360° Pleated Japanese Paper Filter with
///   real capillary wetting diffusion & embossed spiral ribs (ZERO half-clipping!).
/// - Photorealistic granular coffee grounds bed (260+ roasted particles, central divot,
///   CO2 bloom dome foam + micro-bubbles, swirling translucent slurry, rising steam).
/// - First-Person Barista POV Foreground Matte-Black Gooseneck Kettle (bottom-right /
///   bottom-left hand pouring FORWARD into the V60) with live slosh window & physics-driven
///   gravity-parabolic water stream, Rayleigh-Plateau thinning, ripples & splashes!
class ManualBrewFull3DScenePainter extends CustomPainter {
  final ManualBrew3DPhysicsEngine engine;
  final ManualPourPattern pattern;
  final ManualBrewCameraMode cameraMode;
  final double orbitYawRad;
  final double orbitPitchRad;
  final double activePitchDeg;
  final double activeRollDeg;
  final bool showWetnessHeatmap;
  final bool showPatternGuide;
  final bool blindScaleMode;
  final double animTimeSec;
  final bool kettleOnRight;

  // Deterministic coffee ground particles (generated once, zero per-frame allocation)
  static final List<_CoffeeGroundGrain> _groundGrains = _buildCoffeeGrains();

  static List<_CoffeeGroundGrain> _buildCoffeeGrains() {
    final rng = math.Random(2026);
    final list = <_CoffeeGroundGrain>[];
    for (int i = 0; i < 270; i++) {
      final double r = math.sqrt(rng.nextDouble()) * 0.94;
      final double a = rng.nextDouble() * math.pi * 2.0;
      final double nx = math.cos(a) * r;
      final double nz = math.sin(a) * r;
      final double sizePx = 1.4 + rng.nextDouble() * 2.3;
      final double tone = rng.nextDouble();
      final bool isChaff = rng.nextDouble() < 0.08;
      list.add(_CoffeeGroundGrain(nx, nz, sizePx, tone, isChaff, a));
    }
    return list;
  }

  const ManualBrewFull3DScenePainter({
    required this.engine,
    required this.pattern,
    required this.cameraMode,
    required this.orbitYawRad,
    required this.orbitPitchRad,
    required this.activePitchDeg,
    required this.activeRollDeg,
    required this.showWetnessHeatmap,
    required this.showPatternGuide,
    required this.blindScaleMode,
    required this.animTimeSec,
    this.kettleOnRight = true,
  });

  Matrix4 _buildViewProjection(Size size) {
    final double aspect = size.width / math.max(1.0, size.height);
    double camDist = 5.1;
    double pitch = orbitPitchRad;
    double yaw = orbitYawRad;
    Vector3 target = Vector3(0.0, -0.18, 0.0);

    switch (cameraMode) {
      case ManualBrewCameraMode.baristaPov:
        // Framed cleanly so full Smart Scale, Server, 360° V60 & Foreground Kettle fit with zero clipping!
        camDist = aspect > 1.1 ? 4.35 : 5.45;
        pitch = aspect > 1.1 ? 0.64 : 0.72;
        yaw = 0.0;
        target = Vector3(0.0, aspect > 1.1 ? -0.16 : -0.10, 0.0);
        break;
      case ManualBrewCameraMode.xrayCutaway:
        camDist = aspect > 1.1 ? 4.20 : 5.15;
        pitch = 0.28;
        yaw = 0.06;
        target = Vector3(0.0, -0.26, 0.0);
        break;
      case ManualBrewCameraMode.topPattern:
        camDist = aspect > 1.1 ? 3.80 : 4.85;
        pitch = 1.32;
        yaw = 0.0;
        target = Vector3(0.0, 0.08, 0.0);
        break;
      case ManualBrewCameraMode.freeOrbit:
        camDist = aspect > 1.1 ? 4.45 : 5.35;
        break;
    }

    final double eyeY = camDist * math.sin(pitch) + target.y;
    final double horiz = camDist * math.cos(pitch);
    final Vector3 eye = Vector3(
      horiz * math.sin(yaw),
      eyeY,
      horiz * math.cos(yaw),
    );
    final Vector3 up = Vector3(0.0, 1.0, 0.0);

    final Matrix4 view = _lookAt(eye, target, up);
    final Matrix4 proj = _perspective(40.0 * math.pi / 180.0, aspect, 0.1, 30.0);
    return proj * view;
  }

  static Matrix4 _lookAt(Vector3 eye, Vector3 center, Vector3 up) {
    final Vector3 f = (center - eye)..normalize();
    final Vector3 s = f.cross(up)..normalize();
    final Vector3 u = s.cross(f);
    return Matrix4(
      s.x, u.x, -f.x, 0.0,
      s.y, u.y, -f.y, 0.0,
      s.z, u.z, -f.z, 0.0,
      -s.dot(eye), -u.dot(eye), f.dot(eye), 1.0,
    );
  }

  static Matrix4 _perspective(
    double fovY,
    double aspect,
    double zNear,
    double zFar,
  ) {
    final double f = 1.0 / math.tan(fovY * 0.5);
    final double nf = 1.0 / (zNear - zFar);
    return Matrix4(
      f / aspect, 0.0, 0.0, 0.0,
      0.0, f, 0.0, 0.0,
      0.0, 0.0, (zFar + zNear) * nf, -1.0,
      0.0, 0.0, (2.0 * zFar * zNear) * nf, 0.0,
    );
  }

  Offset _project(Vector3 world, Matrix4 vp, Size size) {
    final Vector4 clip = vp.transform(Vector4(world.x, world.y, world.z, 1.0));
    final double invW = clip.w.abs() < 1e-5 ? 1.0 : 1.0 / clip.w;
    final double ndcX = clip.x * invW;
    final double ndcY = clip.y * invW;
    return Offset(
      (ndcX + 1.0) * 0.5 * size.width,
      (1.0 - ndcY) * 0.5 * size.height,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 20 || size.height < 20) return;

    // 1. Warm Espresso Bar Studio Backdrop + Walnut Woodgrain Countertop
    _drawStudioBackdrop(canvas, size);

    final Matrix4 vp = _buildViewProjection(size);
    final bool isCutaway = cameraMode == ManualBrewCameraMode.xrayCutaway;

    // 2. 3D Wooden Countertop & Matte Black Barista Smart Scale
    _draw3DSmartScale(canvas, vp, size);

    // Phase 2 Special Prop: 3D Ceramic Bean Dosing Vessel + RDT Atomizer Mist
    if (engine.phase == ManualBrewPhase.rdtSpritz) {
      _draw3DRdtBeanBowl(canvas, vp, size);
      return;
    }

    // 3. 3D Borosilicate Glass Range Server + Brewed Coffee / Rinse Water + Darcy Drops
    _draw3DGlassServer(canvas, vp, size, isCutaway: isCutaway);

    // 4. 3D Hario V60 Outer Ceramic Cone (Lower Exterior) + FULL 360° Paper Filter Interior!
    _draw3DV60FullConeAndPaperFilter(canvas, vp, size, isCutaway: isCutaway);

    // 5. Photorealistic Granular Coffee Grounds Bed + Divot + CO2 Bloom Dome + Slurry
    final double bedY = _drawRealisticCoffeeBedAndSlurry(canvas, vp, size);

    // 6. Subtle Floating Pour Pattern Guide on Coffee Bed / Filter
    if (showPatternGuide &&
        (engine.phase == ManualBrewPhase.precisionPour ||
            engine.phase == ManualBrewPhase.wetFilter)) {
      _draw3DPatternGuideOnBed(canvas, vp, size, bedY);
    }

    // 7. 3D V60 Front Ceramic Lip, Front Wet Paper Collar & Rising Thermal Steam
    _draw3DV60FrontRimAndSteam(canvas, vp, size, bedY, isCutaway: isCutaway);

    // 8. First-Person Barista POV Foreground Gooseneck Kettle + Parabolic Water Stream!
    if (cameraMode != ManualBrewCameraMode.freeOrbit) {
      _drawForegroundBaristaKettleAndStream(canvas, vp, size, bedY);
    }
  }

  void _drawStudioBackdrop(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.34, 0.52, 1.0],
          colors: [
            Color(0xFF2B1A10),
            Color(0xFF42291A),
            Color(0xFF5D3A24),
            Color(0xFF3A2315),
          ],
        ).createShader(rect),
    );

    // Subtle café walnut planks on lower countertop background
    final plankPaint = Paint()
      ..color = const Color(0xFF28150B).withValues(alpha: 0.28)
      ..strokeWidth = 1.4;
    final grainPaint = Paint()
      ..color = const Color(0xFF8A5D3E).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double y = size.height * 0.42; y < size.height; y += 54.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), plankPaint);
      final gp = Path()..moveTo(0, y + 18);
      for (double x = 0; x <= size.width; x += 48) {
        gp.lineTo(x, y + 18 + math.sin(x * 0.025 + y * 0.05) * 2.0);
      }
      canvas.drawPath(gp, grainPaint);
    }

    // Soft warm café pendant spotlight above the V60 dripper
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.32),
      math.max(size.width, size.height) * 0.58,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF3C4).withValues(alpha: 0.16),
            const Color(0xFFF59E0B).withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ).createShader(rect),
    );
  }

  void _draw3DSmartScale(Canvas canvas, Matrix4 vp, Size size) {
    const double sx = 0.96;
    const double sz = 1.02;
    const double topY = -1.24;
    const double botY = -1.36;

    // Soft ambient occlusion shadow under smart scale on walnut counter
    final shadowQuad = [
      _project(Vector3(-sx * 1.12, botY - 0.01, -sz * 1.06), vp, size),
      _project(Vector3(sx * 1.12, botY - 0.01, -sz * 1.06), vp, size),
      _project(Vector3(sx * 1.16, botY - 0.01, sz * 1.16), vp, size),
      _project(Vector3(-sx * 1.16, botY - 0.01, sz * 1.16), vp, size),
    ];
    canvas.drawPath(
      Path()..addPolygon(shadowQuad, true),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.44)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    final topFace = [
      _project(Vector3(-sx, topY, -sz), vp, size),
      _project(Vector3(sx, topY, -sz), vp, size),
      _project(Vector3(sx, topY, sz), vp, size),
      _project(Vector3(-sx, topY, sz), vp, size),
    ];
    final frontFace = [
      _project(Vector3(-sx, topY, sz), vp, size),
      _project(Vector3(sx, topY, sz), vp, size),
      _project(Vector3(sx, botY, sz + 0.03), vp, size),
      _project(Vector3(-sx, botY, sz + 0.03), vp, size),
    ];

    // Anodized matte-black scale chassis
    canvas.drawPath(
      Path()..addPolygon(frontFace, true),
      Paint()..color = const Color(0xFF0E1116),
    );
    final topPath = Path()..addPolygon(topFace, true);
    canvas.drawPath(
      topPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFF282E38), Color(0xFF161A21)],
        ).createShader(topPath.getBounds()),
    );
    canvas.drawPath(
      topPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Textured circular silicone thermal pad on scale
    final padPts = <Offset>[];
    for (int i = 0; i <= 32; i++) {
      final double a = (i / 32) * math.pi * 2;
      padPts.add(
        _project(
          Vector3(math.cos(a) * 0.76, topY + 0.01, math.sin(a) * 0.76),
          vp,
          size,
        ),
      );
    }
    final padPath = Path()..addPolygon(padPts, true);
    canvas.drawPath(padPath, Paint()..color = const Color(0xFF111419));
    canvas.drawPath(
      padPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Subtle glowing OLED LED strip on front bevel of scale
    final Offset oledPos =
        _project(Vector3(0.0, topY + 0.008, sz * 0.85), vp, size);
    final String oledText = blindScaleMode
        ? '---- g  •  BLIND'
        : '${engine.pouredCoffeeWaterMl.toStringAsFixed(1)} g  •  ${engine.kettleSlosh.currentFlowMlS.toStringAsFixed(1)} ml/s';
    final tp = TextPainter(
      text: TextSpan(
        text: oledText,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF34D399),
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, oledPos - Offset(tp.width * 0.5, tp.height * 0.5));
  }

  void _draw3DRdtBeanBowl(Canvas canvas, Matrix4 vp, Size size) {
    const int segs = 36;
    final rimPts = <Offset>[];
    final basePts = <Offset>[];
    for (int i = 0; i <= segs; i++) {
      final double a = (i / segs) * math.pi * 2;
      rimPts.add(_project(
          Vector3(math.cos(a) * 0.90, 0.08, math.sin(a) * 0.90), vp, size));
      basePts.add(_project(
          Vector3(math.cos(a) * 0.56, -0.58, math.sin(a) * 0.56), vp, size));
    }

    // Glazed ceramic porcelain dosing tray
    for (int i = 0; i < segs; i++) {
      final double aMid = ((i + 0.5) / segs) * math.pi * 2;
      final double shade = 0.55 + 0.45 * math.cos(aMid - 0.8);
      final poly = [rimPts[i], rimPts[i + 1], basePts[i + 1], basePts[i]];
      canvas.drawPath(
        Path()..addPolygon(poly, true),
        Paint()
          ..color = Color.lerp(
              const Color(0xFFCBC1B4), const Color(0xFFFAF6F0), shade)!,
      );
    }
    final rimPath = Path()..addPolygon(rimPts, true);
    canvas.drawPath(
      rimPath,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFF3D2414), Color(0xFF1F1108)],
        ).createShader(rimPath.getBounds()),
    );

    // 3D Glossy Roasted Whole Coffee Beans with center cleft
    final rng = math.Random(7);
    for (int b = 0; b < 46; b++) {
      final double r = math.sqrt(rng.nextDouble()) * 0.72;
      final double a = rng.nextDouble() * math.pi * 2;
      final double rot = rng.nextDouble() * math.pi;
      final pt = _project(
        Vector3(
            math.cos(a) * r, -0.02 + rng.nextDouble() * 0.08, math.sin(a) * r),
        vp,
        size,
      );
      canvas.save();
      canvas.translate(pt.dx, pt.dy);
      canvas.rotate(rot);
      final beanRect = Rect.fromCenter(center: Offset.zero, width: 16, height: 11);
      canvas.drawOval(
        beanRect.shift(const Offset(1, 2)),
        Paint()..color = Colors.black.withValues(alpha: 0.35),
      );
      canvas.drawOval(
        beanRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C4826), Color(0xFF472510)],
          ).createShader(beanRect),
      );
      canvas.drawPath(
        Path()
          ..moveTo(-5, 0)
          ..quadraticBezierTo(0, 1.8, 5, 0),
        Paint()
          ..color = const Color(0xFF231106)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      canvas.restore();
    }

    // Shimmering RDT Micro-Mist Atomizer Plume
    if (engine.rdtSpritzCount > 0) {
      for (int m = 0; m < 32; m++) {
        final double phase = (animTimeSec * 1.9 + m * 0.17) % 1.0;
        final double mx = math.sin(m * 1.9 + animTimeSec * 0.8) * 0.62;
        final double mz = math.cos(m * 2.3) * 0.62;
        final double my = 0.60 - phase * 0.60;
        final mp = _project(Vector3(mx, my, mz), vp, size);
        canvas.drawCircle(
          mp,
          2.2 + (1.0 - phase) * 1.4,
          Paint()
            ..color =
                const Color(0xFFE0F2FE).withValues(alpha: (1.0 - phase) * 0.72),
        );
      }
    }
  }

  void _draw3DGlassServer(
    Canvas canvas,
    Matrix4 vp,
    Size size, {
    required bool isCutaway,
  }) {
    const double topY = -0.34;
    const double botY = -1.22;
    const double rTop = 0.54;
    const double rBot = 0.74;
    const int segs = 36;

    final bool isRinse = engine.phase == ManualBrewPhase.wetFilter;
    final double vol =
        isRinse ? engine.rinseWaterInServerMl : engine.serverCoffeeMl;
    final double maxV =
        isRinse ? 60.0 : math.max(1.0, engine.spec.targetWaterMl);
    final double fill = (vol / maxV).clamp(0.0, 0.90);

    final double startA = isCutaway ? math.pi * 0.16 : 0.0;
    final double endA = isCutaway ? math.pi * 1.44 : math.pi * 2.0;

    // 1. Subtle glass carafe interior tint
    final backBody = Path();
    final List<Offset> topRingPts = [];
    final List<Offset> botRingPts = [];
    for (int i = 0; i <= segs; i++) {
      final double a = startA + (endA - startA) * (i / segs);
      topRingPts.add(
          _project(Vector3(math.cos(a) * rTop, topY, math.sin(a) * rTop), vp, size));
      botRingPts.add(
          _project(Vector3(math.cos(a) * rBot, botY, math.sin(a) * rBot), vp, size));
    }
    backBody.moveTo(topRingPts.first.dx, topRingPts.first.dy);
    for (final pt in topRingPts) {
      backBody.lineTo(pt.dx, pt.dy);
    }
    for (int i = botRingPts.length - 1; i >= 0; i--) {
      backBody.lineTo(botRingPts[i].dx, botRingPts[i].dy);
    }
    backBody.close();
    canvas.drawPath(
      backBody,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            const Color(0xFFBAE6FD).withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.22),
          ],
        ).createShader(backBody.getBounds()),
    );

    // 2. Brewed Coffee or Clear Hot Rinse Water inside Glass Server
    if (fill > 0.015) {
      final double liqY = botY + (topY - botY - 0.09) * fill;
      final double liqR = rBot + (rTop - rBot) * fill;

      for (int i = 0; i < segs; i++) {
        final double a0 = startA + (endA - startA) * (i / segs);
        final double a1 = startA + (endA - startA) * ((i + 1) / segs);
        final poly = [
          _project(Vector3(math.cos(a0) * rBot, botY, math.sin(a0) * rBot), vp, size),
          _project(Vector3(math.cos(a1) * rBot, botY, math.sin(a1) * rBot), vp, size),
          _project(Vector3(math.cos(a1) * liqR, liqY, math.sin(a1) * liqR), vp, size),
          _project(Vector3(math.cos(a0) * liqR, liqY, math.sin(a0) * liqR), vp, size),
        ];
        final double shade = 0.5 + 0.45 * math.cos((a0 + a1) * 0.5 - 0.7);
        final Color c = isRinse
            ? Color.lerp(const Color(0xFF7DD3FC), const Color(0xFFE0F2FE), shade)!
                .withValues(alpha: 0.48)
            : Color.lerp(const Color(0xFF2B0F05), const Color(0xFF9A3E12), shade)!
                .withValues(alpha: 0.92);
        canvas.drawPath(Path()..addPolygon(poly, true), Paint()..color = c);
      }

      // Glossy top meniscus oval + subtle concentric drop ripple
      final menPts = <Offset>[];
      for (int i = 0; i <= segs; i++) {
        final double a = startA + (endA - startA) * (i / segs);
        menPts.add(_project(
            Vector3(math.cos(a) * liqR, liqY, math.sin(a) * liqR), vp, size));
      }
      final menPath = Path()..addPolygon(menPts, true);
      canvas.drawPath(
        menPath,
        Paint()
          ..shader = RadialGradient(
            colors: isRinse
                ? [
                    const Color(0xFFE0F2FE).withValues(alpha: 0.72),
                    const Color(0xFF7DD3FC).withValues(alpha: 0.45),
                  ]
                : [
                    const Color(0xFFD97706).withValues(alpha: 0.94),
                    const Color(0xFF5C2109).withValues(alpha: 0.95),
                  ],
          ).createShader(menPath.getBounds()),
      );
    }

    // 3. Falling Darcy Percolation Coffee Stream / Amber Droplets inside Server!
    if ((isRinse && engine.kettleSlosh.currentFlowMlS > 0.25) ||
        engine.slurryMl > 1.0) {
      final double liqSurfaceY = botY + (topY - botY - 0.09) * fill;
      for (int d = 0; d < 5; d++) {
        final double frac = (animTimeSec * 2.1 + d * 0.20) % 1.0;
        final double dy = topY - frac * (topY - liqSurfaceY);
        final dp = _project(Vector3(0, dy, 0), vp, size);
        canvas.drawOval(
          Rect.fromCenter(center: dp, width: 3.6, height: 6.2),
          Paint()
            ..color = isRinse
                ? const Color(0xFFBAE6FD).withValues(alpha: 0.88)
                : const Color(0xFFD97706).withValues(alpha: 0.95),
        );
      }
      final hitServer = _project(Vector3(0, liqSurfaceY, 0), vp, size);
      final double ripR = 4.0 + ((animTimeSec * 18.0) % 12.0);
      canvas.drawOval(
        Rect.fromCenter(center: hitServer, width: ripR * 2.2, height: ripR),
        Paint()
          ..color = (isRinse ? Colors.white : const Color(0xFFFCD34D))
              .withValues(alpha: (1.0 - (ripR - 4.0) / 12.0) * 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // 4. Crisp Borosilicate Glass Specular Highlights, Rings & Ergonomic Glass Handle
    final glassRimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(Path()..addPolygon(topRingPts, false), glassRimPaint);
    canvas.drawPath(Path()..addPolygon(botRingPts, false), glassRimPaint);

    // Specular vertical borosilicate reflection streaks on left & right walls
    for (final double aSpec in [math.pi * 0.78, math.pi * 0.22]) {
      final p1 = _project(
          Vector3(math.cos(aSpec) * (rTop * 0.96), topY - 0.04,
              math.sin(aSpec) * (rTop * 0.96)),
          vp,
          size);
      final p2 = _project(
          Vector3(math.cos(aSpec) * (rBot * 0.96), botY + 0.08,
              math.sin(aSpec) * (rBot * 0.96)),
          vp,
          size);
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.28)
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Glass Server Handle (Left side so it stays clear of foreground right-hand kettle!)
    final double hSign = kettleOnRight ? -1.0 : 1.0;
    final h1 = _project(Vector3(hSign * rTop, topY - 0.08, 0), vp, size);
    final h2 = _project(
        Vector3(hSign * (rBot + 0.32), (topY + botY) * 0.5, 0), vp, size);
    final h3 = _project(Vector3(hSign * rBot * 0.95, botY + 0.16, 0), vp, size);
    final handlePath = Path()
      ..moveTo(h1.dx, h1.dy)
      ..quadraticBezierTo(h2.dx, h2.dy, h3.dx, h3.dy);
    canvas.drawPath(
      handlePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.2
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Renders the COMPLETE 360° Hario V60 Ceramic Dripper Exterior + FULL 360° Pleated
  /// Japanese Paper Filter with natural capillary wetting darkening & 12 spiral ribs!
  void _draw3DV60FullConeAndPaperFilter(
    Canvas canvas,
    Matrix4 vp,
    Size size, {
    required bool isCutaway,
  }) {
    const int segs = 48;
    const double coneTopY = 0.48;
    const double paperTopY = 0.54; // Authentic paper filter rises slightly above ceramic lip!
    const double coneBotY = -0.34;
    const double rCeramicTop = 1.02;
    const double rPaperTop = 0.99;
    const double rBot = 0.25;

    // 1. Ceramic V60 Base Flange Resting on Server
    final flangePts = <Offset>[];
    for (int i = 0; i <= 36; i++) {
      final double a = (i / 36) * math.pi * 2;
      flangePts.add(_project(
          Vector3(math.cos(a) * 0.62, coneBotY, math.sin(a) * 0.62), vp, size));
    }
    final flangePath = Path()..addPolygon(flangePts, true);
    canvas.drawPath(
      flangePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [Color(0xFFEAE3D9), Color(0xFFFAF6F0), Color(0xFFD1C6B8)],
        ).createShader(flangePath.getBounds()),
    );

    // 2. Ceramic V60 Side Handle (Opposite side of kettle!)
    final double hSign = kettleOnRight ? -1.0 : 1.0;
    final ch1 = _project(Vector3(hSign * 0.90, 0.36, 0), vp, size);
    final ch2 = _project(Vector3(hSign * 1.38, 0.20, 0), vp, size);
    final ch3 = _project(Vector3(hSign * 0.56, -0.20, 0), vp, size);
    final ceramicHandle = Path()
      ..moveTo(ch1.dx, ch1.dy)
      ..quadraticBezierTo(ch2.dx, ch2.dy, ch3.dx, ch3.dy);
    canvas.drawPath(
      ceramicHandle.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      ceramicHandle,
      Paint()
        ..color = const Color(0xFFF3ECE2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.2
        ..strokeCap = StrokeCap.round,
    );

    // 3. Outer Glazed Ceramic V60 Body Silhouette (lower exterior visible under rim)
    if (!isCutaway && cameraMode != ManualBrewCameraMode.topPattern) {
      for (int i = 0; i < segs; i++) {
        final double a0 = (i / segs) * math.pi;
        final double a1 = ((i + 1) / segs) * math.pi;
        final double aMid = (a0 + a1) * 0.5;
        final double shade = 0.55 + 0.45 * math.cos(aMid - 0.9);
        final poly = [
          _project(
              Vector3(math.cos(a0) * rCeramicTop, coneTopY, math.sin(a0) * rCeramicTop),
              vp,
              size),
          _project(
              Vector3(math.cos(a1) * rCeramicTop, coneTopY, math.sin(a1) * rCeramicTop),
              vp,
              size),
          _project(
              Vector3(math.cos(a1) * (rBot + 0.03), coneBotY,
                  math.sin(a1) * (rBot + 0.03)),
              vp,
              size),
          _project(
              Vector3(math.cos(a0) * (rBot + 0.03), coneBotY,
                  math.sin(a0) * (rBot + 0.03)),
              vp,
              size),
        ];
        canvas.drawPath(
          Path()..addPolygon(poly, true),
          Paint()
            ..color = Color.lerp(
                const Color(0xFFD2C7B9), const Color(0xFFFAF6F0), shade)!,
        );
      }
    }

    // 4. FULL 360° INNER JAPANESE PAPER FILTER CONE (Back + Sides + Front Inner Lip!)
    // Draw from back (pi..2pi) AND lower funnel throat smoothly so there is NEVER a half-cut gap!
    final double startA = isCutaway ? math.pi * 0.25 : 0.0;
    final double endA = isCutaway ? math.pi * 1.45 : math.pi * 2.0;

    // Warm shaded inner cone apex (authentic conical paper tip, NOT a solid black circle!)
    final apexPts = <Offset>[];
    for (int i = 0; i <= 28; i++) {
      final double a = (i / 28) * math.pi * 2;
      apexPts.add(_project(
          Vector3(math.cos(a) * rBot, coneBotY + 0.02, math.sin(a) * rBot),
          vp,
          size));
    }
    final double avgWet = (engine.paperWetnessPct / 100.0).clamp(0.0, 1.0);
    final apexPath = Path()..addPolygon(apexPts, true);
    canvas.drawPath(
      apexPath,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(const Color(0xFF9C846B), const Color(0xFF6B533E), avgWet)!,
            Color.lerp(const Color(0xFFDCCBB7), const Color(0xFFB3987B), avgWet)!,
          ],
        ).createShader(apexPath.getBounds()),
    );

    // Draw full 360° paper filter wall segments (back-to-front sorted by sin(aMid))
    final List<int> order = List.generate(segs, (i) => i);
    order.sort((ia, ib) {
      final double aA = startA + (endA - startA) * ((ia + 0.5) / segs);
      final double aB = startA + (endA - startA) * ((ib + 0.5) / segs);
      return math.sin(aA).compareTo(math.sin(aB));
    });

    for (final int i in order) {
      final double a0 = startA + (endA - startA) * (i / segs);
      final double a1 = startA + (endA - startA) * ((i + 1) / segs);
      final double aMid = (a0 + a1) * 0.5;
      // Only draw interior visible faces (back half fully opaque, front inner paper slightly visible in top/POV)
      final bool isFrontWall = math.sin(aMid) > 0.05;
      if (isFrontWall && isCutaway) continue;

      final double normAngle =
          ((aMid % (math.pi * 2)) / (math.pi * 2)).clamp(0.0, 0.999);
      final int fIdx = (normAngle * ManualBrew3DPhysicsEngine.filterSegments)
          .floor()
          .clamp(0, ManualBrew3DPhysicsEngine.filterSegments - 1);
      final double w = engine.filterWetness[fIdx].clamp(0.0, 1.0);

      // Smooth conical shading (studio light from top-left)
      final double dirLight = (0.64 + 0.36 * math.cos(aMid + 0.95)).clamp(0.35, 1.0);
      // Dry matte cream paper (#FBF6EC) -> Damp warm translucent parchment (#C6AE91)
      final Color dryPaper = Color.lerp(
        const Color(0xFFE7DEC9),
        const Color(0xFFFFFCF6),
        dirLight,
      )!;
      final Color wetPaper = Color.lerp(
        const Color(0xFFAD9375),
        const Color(0xFFD5BE9E),
        dirLight,
      )!;
      final Color paperCol = Color.lerp(dryPaper, wetPaper, w)!;

      // For front wall in POV 3D, render from paper lip down to mid-interior so it wraps 360° seamlessly!
      final double segBotY =
          isFrontWall && cameraMode == ManualBrewCameraMode.baristaPov
              ? 0.06
              : coneBotY;
      final double segBotR =
          isFrontWall && cameraMode == ManualBrewCameraMode.baristaPov
              ? 0.64
              : rBot;

      final poly = [
        _project(
            Vector3(math.cos(a0) * rPaperTop, paperTopY, math.sin(a0) * rPaperTop),
            vp,
            size),
        _project(
            Vector3(math.cos(a1) * rPaperTop, paperTopY, math.sin(a1) * rPaperTop),
            vp,
            size),
        _project(
            Vector3(math.cos(a1) * segBotR, segBotY, math.sin(a1) * segBotR),
            vp,
            size),
        _project(
            Vector3(math.cos(a0) * segBotR, segBotY, math.sin(a0) * segBotR),
            vp,
            size),
      ];

      canvas.drawPath(
        Path()..addPolygon(poly, true),
        Paint()
          ..color = paperCol.withValues(
            alpha: isCutaway
                ? 0.62
                : (isFrontWall ? (0.42 + w * 0.14) : (0.98 - w * 0.08)),
          ),
      );

      // Subtle paper fiber crease / wet capillary gradient band inside cone
      if (w > 0.12 && !isFrontWall) {
        final double wetLineY = coneBotY + (paperTopY - coneBotY) * (0.28 + 0.66 * w);
        final double wetLineR = rBot + (rPaperTop - rBot) * (0.28 + 0.66 * w);
        final pW0 = _project(
            Vector3(math.cos(a0) * wetLineR, wetLineY, math.sin(a0) * wetLineR),
            vp,
            size);
        final pW1 = _project(
            Vector3(math.cos(a1) * wetLineR, wetLineY, math.sin(a1) * wetLineR),
            vp,
            size);
        canvas.drawLine(
          pW0,
          pW1,
          Paint()
            ..color = const Color(0xFF9C7E5E).withValues(alpha: 0.30 * w)
            ..strokeWidth = 1.6,
        );
      }
    }

    // 5. Authentic Folded Japanese V60 Paper Filter Crimped Seam (left-back diagonal)
    final double seamA = math.pi * 1.24;
    final pSeamTop = _project(
        Vector3(math.cos(seamA) * rPaperTop, paperTopY, math.sin(seamA) * rPaperTop),
        vp,
        size);
    final pSeamBot = _project(
        Vector3(math.cos(seamA) * rBot, coneBotY, math.sin(seamA) * rBot),
        vp,
        size);
    canvas.drawLine(
      pSeamTop,
      pSeamBot,
      Paint()
        ..color = const Color(0xFFB59D82).withValues(alpha: 0.65)
        ..strokeWidth = 2.6,
    );

    // 6. 12 Embossed Hario V60 Spiral Inner Ribs (visible subtly through damp paper!)
    final double swirlAngle =
        engine.swirlProgress * math.pi * 2.0 + engine.swirlPhaseRad * 0.12;
    for (int r = 0; r < 12; r++) {
      final double baseA = swirlAngle + (r * math.pi * 2 / 12);
      if (math.sin(baseA) > 0.15 && cameraMode != ManualBrewCameraMode.topPattern) {
        continue;
      }
      final p = Path();
      for (int s = 0; s <= 8; s++) {
        final double t = s / 8.0;
        final double rad = rBot + t * (rPaperTop - rBot);
        final double y = coneBotY + t * (coneTopY - coneBotY);
        final double a = baseA + t * 0.68;
        final pt = _project(Vector3(math.cos(a) * rad, y, math.sin(a) * rad), vp, size);
        if (s == 0) {
          p.moveTo(pt.dx, pt.dy);
        } else {
          p.lineTo(pt.dx, pt.dy);
        }
      }
      // Subtle relief shadow + highlight for each embossed ceramic spiral rib
      canvas.drawPath(
        p,
        Paint()
          ..color = const Color(0xFF8C735B).withValues(alpha: 0.18 + avgWet * 0.24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      canvas.drawPath(
        p.shift(const Offset(-0.8, -0.8)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.28 + avgWet * 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  /// Renders photorealistic granular roasted coffee grounds, sculpted center divot,
  /// CO2 bloom dome foam + micro-bubbles, and translucent swirling slurry pool!
  double _drawRealisticCoffeeBedAndSlurry(
    Canvas canvas,
    Matrix4 vp,
    Size size,
  ) {
    if (!engine.groundsDosed &&
        engine.phase != ManualBrewPhase.precisionPour &&
        engine.phase != ManualBrewPhase.swirlAndResult) {
      return 0.06;
    }

    const int n = ManualBrew3DPhysicsEngine.gridSize;
    final double slurryLift = (engine.slurryMl / 115.0).clamp(0.0, 0.28);
    final double bloomLift = engine.bloomDomeFactor * 0.065;
    final double baseY = -0.06 + slurryLift * 0.26 + bloomLift;
    const double bedR = 0.71;

    // 1. Smooth Continuous Shaded Coffee Bed Base Oval (NO blocky quads!)
    final List<Offset> bedPerimeter = [];
    for (int i = 0; i <= 40; i++) {
      final double a = (i / 40) * math.pi * 2;
      bedPerimeter.add(_project(
          Vector3(math.cos(a) * bedR, baseY + 0.14, math.sin(a) * bedR),
          vp,
          size));
    }
    final bedPath = Path()..addPolygon(bedPerimeter, true);
    final Rect bedBounds = bedPath.getBounds();

    // Average bed wetness for organic dry-to-wet base tone
    double avgBedWet = 0.0;
    int validCells = 0;
    for (int i = 0; i < engine.wetnessMap.length; i++) {
      if (engine.bedHeight[i] > 0.05) {
        avgBedWet += engine.wetnessMap[i];
        validCells++;
      }
    }
    avgBedWet = validCells > 0 ? (avgBedWet / validCells).clamp(0.0, 1.0) : 0.0;

    final Color centerTone = Color.lerp(
      const Color(0xFF754726), // Freshly ground medium-roast Arabica
      const Color(0xFF33180A), // Saturated dark espresso-brown slurry grounds
      avgBedWet,
    )!;
    final Color edgeTone = Color.lerp(
      const Color(0xFF5A3318),
      const Color(0xFF241006),
      avgBedWet,
    )!;

    canvas.drawPath(
      bedPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.12, -0.14),
          radius: 0.92,
          colors: [centerTone, edgeTone],
        ).createShader(bedBounds),
    );

    // 2. Sculpted Center Divot Shadow Depression (Phase 3 & 4)
    if (engine.centerDivotDepthMm > 0.5) {
      final double divotFrac = (engine.centerDivotDepthMm / 8.0).clamp(0.15, 1.0);
      final divotCenter = _project(Vector3(0.0, baseY + 0.08, 0.0), vp, size);
      final double divotRx = bedBounds.width * (0.14 + 0.10 * divotFrac);
      final double divotRy = bedBounds.height * (0.14 + 0.10 * divotFrac);
      canvas.drawOval(
        Rect.fromCenter(center: divotCenter, width: divotRx * 2, height: divotRy * 2),
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF1A0B04).withValues(alpha: 0.62 * divotFrac),
              const Color(0xFF2E1509).withValues(alpha: 0.22 * divotFrac),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCenter(
              center: divotCenter, width: divotRx * 2, height: divotRy * 2)),
      );
    }

    // 3. 270+ Realistic Roasted Coffee Grounds Granules (sampled directly from 32x32 physics heightfield!)
    final double swirlRot = engine.swirlPhaseRad * 0.45;
    final double cosS = math.cos(swirlRot);
    final double sinS = math.sin(swirlRot);

    for (final g in _groundGrains) {
      // Gently swirl floating grounds when slurry vortex is spinning
      final double gx = slurryLift > 0.04 ? (g.nx * cosS - g.nz * sinS) : g.nx;
      final double gz = slurryLift > 0.04 ? (g.nx * sinS + g.nz * cosS) : g.nz;

      final int ix = (((gx + 1.0) * 0.5) * (n - 1)).round().clamp(0, n - 1);
      final int iz = (((gz + 1.0) * 0.5) * (n - 1)).round().clamp(0, n - 1);
      final int idx = iz * n + ix;

      final double hVal = engine.bedHeight[idx];
      final double wet = engine.wetnessMap[idx];
      final double co2 = engine.co2Map[idx];
      final double wy = baseY + hVal * 0.30;

      final Offset pt = _project(Vector3(gx * bedR, wy, gz * bedR), vp, size);

      Color grainColor;
      if (g.isChaff && wet < 0.65) {
        // Authentic pale silver-skin coffee chaff flecks!
        grainColor = Color.lerp(
          const Color(0xFFD2AE82),
          const Color(0xFF7D5533),
          wet,
        )!;
      } else {
        final Color dryG = Color.lerp(
          const Color(0xFF5C3317),
          const Color(0xFF945E34),
          g.tone,
        )!;
        final Color wetG = Color.lerp(
          const Color(0xFF230F05),
          const Color(0xFF47230F),
          g.tone,
        )!;
        grainColor = Color.lerp(dryG, wetG, wet)!;
      }

      // Golden-tan CO2 Bloom Foam Crust over freshly wetted grounds!
      if (wet > 0.25 && co2 > 0.40) {
        final double foamAmt = ((co2 - 0.40) / 0.60).clamp(0.0, 1.0) * 0.72;
        grainColor = Color.lerp(grainColor, const Color(0xFFD9A66C), foamAmt)!;
      }

      // Optional subtle dry-zone amber guide tint if heatmap enabled
      if (showWetnessHeatmap &&
          engine.phase == ManualBrewPhase.precisionPour &&
          wet < 0.45 &&
          engine.pouredCoffeeWaterMl > 12.0) {
        grainColor = Color.lerp(grainColor, const Color(0xFFF59E0B), 0.26)!;
      }

      canvas.drawOval(
        Rect.fromCenter(
          center: pt,
          width: g.sizePx * 1.25,
          height: g.sizePx * 0.88,
        ),
        Paint()..color = grainColor,
      );
    }

    // 4. Translucent Swirling Slurry Water Pool + CO2 Bloom Micro-Bubbles
    if (slurryLift > 0.015) {
      final double waterY = baseY + 0.19 + slurryLift * 0.34;
      final double waterR = 0.69 + slurryLift * 0.20;
      final pts = <Offset>[];
      for (int i = 0; i <= 36; i++) {
        final double a = (i / 36) * math.pi * 2;
        pts.add(_project(
            Vector3(math.cos(a) * waterR, waterY, math.sin(a) * waterR),
            vp,
            size));
      }
      final poolPath = Path()..addPolygon(pts, true);
      final poolBounds = poolPath.getBounds();

      // Glossy amber-mahogany translucent coffee slurry
      canvas.drawPath(
        poolPath,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.22, -0.22),
            colors: engine.activeWaterTempC <= 75.0
                ? [
                    const Color(0xFF7DD3FC).withValues(alpha: 0.40),
                    const Color(0xFF0284C7).withValues(alpha: 0.28),
                  ]
                : [
                    const Color(0xFFC87D44).withValues(alpha: 0.56),
                    const Color(0xFF6B3112).withValues(alpha: 0.44),
                    const Color(0xFF3E1807).withValues(alpha: 0.50),
                  ],
          ).createShader(poolBounds),
      );

      // Swirling golden crema vortex streaks driven by real tangential momentum!
      final double vortexAlpha =
          (0.18 + engine.swirlAngularVel.abs() * 0.08 + engine.bloomDomeFactor * 0.25)
              .clamp(0.15, 0.58);
      for (int s = 0; s < 3; s++) {
        final double rArc = waterR * (0.34 + s * 0.20);
        final double a0 = engine.swirlPhaseRad + s * 2.1;
        final Path arc = Path();
        for (int k = 0; k <= 12; k++) {
          final double a = a0 + (k / 12.0) * 1.45;
          final pt = _project(
              Vector3(math.cos(a) * rArc, waterY + 0.005, math.sin(a) * rArc),
              vp,
              size);
          if (k == 0) {
            arc.moveTo(pt.dx, pt.dy);
          } else {
            arc.lineTo(pt.dx, pt.dy);
          }
        }
        canvas.drawPath(
          arc,
          Paint()
            ..color = const Color(0xFFF3C993).withValues(alpha: vortexAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round,
        );
      }

      // Live popping CO2 Bloom Micro-Bubbles!
      if (engine.bloomDomeFactor > 0.06 || engine.pouredCoffeeWaterMl < 75.0) {
        final int bubbleCount = (10 + engine.bloomDomeFactor * 18).round();
        for (int b = 0; b < bubbleCount; b++) {
          final double bPhase = (animTimeSec * 0.9 + b * 0.29) % 1.0;
          final double ba = b * 2.399 + engine.swirlPhaseRad * 0.4;
          final double br = (0.12 + (b % 7) * 0.09) * waterR;
          final bp = _project(
              Vector3(math.cos(ba) * br, waterY + 0.01, math.sin(ba) * br),
              vp,
              size);
          final double rad = 1.4 + math.sin(bPhase * math.pi) * 2.1;
          canvas.drawCircle(
            bp,
            rad,
            Paint()
              ..color = const Color(0xFFFDE6B8)
                  .withValues(alpha: math.sin(bPhase * math.pi) * 0.68),
          );
        }
      }

      return waterY;
    }

    return baseY + 0.16;
  }

  void _draw3DPatternGuideOnBed(
    Canvas canvas,
    Matrix4 vp,
    Size size,
    double bedY,
  ) {
    final guidePaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    if (engine.phase == ManualBrewPhase.wetFilter) {
      final ring = Path();
      for (int i = 0; i <= 36; i++) {
        final double a = (i / 36) * math.pi * 2;
        final pt = _project(
            Vector3(math.cos(a) * 0.80, 0.26, math.sin(a) * 0.80), vp, size);
        if (i == 0) {
          ring.moveTo(pt.dx, pt.dy);
        } else {
          ring.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(ring, guidePaint);
      return;
    }

    switch (pattern) {
      case ManualPourPattern.circularCw:
      case ManualPourPattern.reverseCircularCcw:
      case ManualPourPattern.spiralSwirl:
      case ManualPourPattern.pulse46:
        for (final double r in [0.28, 0.54]) {
          final p = Path();
          for (int i = 0; i <= 32; i++) {
            final double a = (i / 32) * math.pi * 2;
            final pt = _project(
                Vector3(math.cos(a) * r, bedY + 0.02, math.sin(a) * r), vp, size);
            if (i == 0) {
              p.moveTo(pt.dx, pt.dy);
            } else {
              p.lineTo(pt.dx, pt.dy);
            }
          }
          canvas.drawPath(p, guidePaint);
        }
        final double dir =
            pattern == ManualPourPattern.reverseCircularCcw ? -1.0 : 1.0;
        final double beadAngle = animTimeSec * 2.2 * dir;
        final Offset beadPt = _project(
          Vector3(
              math.cos(beadAngle) * 0.44, bedY + 0.03, math.sin(beadAngle) * 0.44),
          vp,
          size,
        );
        canvas.drawCircle(beadPt, 4.8, Paint()..color = const Color(0xFFFBBF24));
        break;
      case ManualPourPattern.zigzag:
        final zz = Path();
        const pts = [
          [-0.44, -0.38],
          [0.44, -0.19],
          [-0.44, 0.0],
          [0.44, 0.19],
          [-0.44, 0.38],
        ];
        for (int i = 0; i < pts.length; i++) {
          final p =
              _project(Vector3(pts[i][0], bedY + 0.02, pts[i][1]), vp, size);
          if (i == 0) {
            zz.moveTo(p.dx, p.dy);
          } else {
            zz.lineTo(p.dx, p.dy);
          }
        }
        canvas.drawPath(zz, guidePaint);
        break;
      case ManualPourPattern.centerOsmotic:
        final p = Path();
        for (int i = 0; i <= 24; i++) {
          final double a = (i / 24) * math.pi * 2;
          final pt = _project(
              Vector3(math.cos(a) * 0.18, bedY + 0.02, math.sin(a) * 0.18),
              vp,
              size);
          if (i == 0) {
            p.moveTo(pt.dx, pt.dy);
          } else {
            p.lineTo(pt.dx, pt.dy);
          }
        }
        canvas.drawPath(p, guidePaint);
        break;
    }
  }

  /// Draws the crisp glazed ceramic V60 top rim, subtle paper top collar & rising hot steam!
  void _draw3DV60FrontRimAndSteam(
    Canvas canvas,
    Matrix4 vp,
    Size size,
    double bedY, {
    required bool isCutaway,
  }) {
    const double coneTopY = 0.48;
    const double paperTopY = 0.54;
    const double rCeramicTop = 1.02;
    const double rPaperTop = 0.99;

    // Crisp Full 360° Paper Filter Upper Lip
    final paperLip = Path();
    for (int i = 0; i <= 48; i++) {
      final double a = (i / 48) * math.pi * 2;
      final pt = _project(
          Vector3(math.cos(a) * rPaperTop, paperTopY, math.sin(a) * rPaperTop),
          vp,
          size);
      if (i == 0) {
        paperLip.moveTo(pt.dx, pt.dy);
      } else {
        paperLip.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(
      paperLip,
      Paint()
        ..color = const Color(0xFFF5EDE0).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Crisp 3D Glazed Ceramic V60 Outer Lip Ring
    final ceramicLip = Path();
    for (int i = 0; i <= 48; i++) {
      final double a = (i / 48) * math.pi * 2;
      final pt = _project(
          Vector3(
              math.cos(a) * rCeramicTop, coneTopY, math.sin(a) * rCeramicTop),
          vp,
          size);
      if (i == 0) {
        ceramicLip.moveTo(pt.dx, pt.dy);
      } else {
        ceramicLip.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(
      ceramicLip,
      Paint()
        ..color = const Color(0xFFFBF7F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2,
    );

    // Rising Thermal Steam Wisps when hot water is active (> 78°C)
    if (engine.activeWaterTempC > 78.0 &&
        (engine.slurryMl > 1.5 || engine.rinseWaterInServerMl > 2.0)) {
      final double steamStrength =
          ((engine.activeWaterTempC - 75.0) / 22.0).clamp(0.15, 0.85);
      for (int w = 0; w < 5; w++) {
        final double ph = (animTimeSec * 0.48 + w * 0.21) % 1.0;
        final double sx = math.sin(w * 1.7 + animTimeSec * 1.1) * 0.28;
        final double sz = math.cos(w * 2.1) * 0.22;
        final double sy = bedY + 0.15 + ph * 0.85;
        final Offset sp = _project(Vector3(sx, sy, sz), vp, size);
        final double alpha = math.sin(ph * math.pi) * 0.18 * steamStrength;
        canvas.drawOval(
          Rect.fromCenter(
            center: sp,
            width: 18.0 + ph * 26.0,
            height: 28.0 + ph * 34.0,
          ),
          Paint()
            ..color = Colors.white.withValues(alpha: alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
        );
      }
    }
  }

  /// FIRST-PERSON BARISTA POV:
  /// Renders the sleek 3D Matte-Black Precision Gooseneck Kettle in the FOREGROUND
  /// (bottom-right or bottom-left, close to the user's hand!) reaching FORWARD over the V60,
  /// pouring a physics-driven parabolic laminar/Rayleigh-Plateau water stream forward!
  void _drawForegroundBaristaKettleAndStream(
    Canvas canvas,
    Matrix4 vp,
    Size size,
    double bedY,
  ) {
    final double impX = engine.aimPos.dx * 0.66;
    final double impZ = engine.aimPos.dy * 0.66;
    final Vector3 impactWorld = Vector3(
      impX,
      engine.phase == ManualBrewPhase.wetFilter ? 0.26 : (bedY + 0.02),
      impZ,
    );
    final Offset pHit = _project(impactWorld, vp, size);

    final double flow = engine.kettleSlosh.currentFlowMlS;
    final double heightNorm = ((engine.pourHeightCm - 3.5) / 10.5).clamp(0.0, 1.0);
    final double tiltRad = (activePitchDeg * math.pi / 180.0).clamp(0.0, 0.96);
    final double rollRad = (activeRollDeg * math.pi / 180.0).clamp(-0.48, 0.48);

    // Side multiplier: +1 = Right-handed foreground kettle, -1 = Left-handed foreground kettle
    final double side = kettleOnRight ? 1.0 : -1.0;

    // Spout tip hovers above `pHit` and slightly toward foreground barista (+Y on screen)
    final double spoutLiftPx = 46.0 + heightNorm * 78.0;
    final Offset pSpoutTip = Offset(
      pHit.dx + side * (16.0 + (1.0 - tiltRad) * 14.0),
      pHit.dy - spoutLiftPx,
    );

    // Kettle body sits in FOREGROUND (lower-right / lower-left), closest to the user!
    final double kScale = math.min(size.width, size.height).clamp(320.0, 620.0);
    final double bodyW = kScale * 0.24;
    final double bodyH = kScale * 0.27;
    final Offset kettleCenter = Offset(
      (pSpoutTip.dx + side * (bodyW * 1.12))
          .clamp(bodyW * 0.55, size.width - bodyW * 0.55),
      (pSpoutTip.dy + bodyH * 0.72 + (1.0 - tiltRad) * 18.0)
          .clamp(size.height * 0.42, size.height - bodyH * 0.52),
    );

    // 1. Physics-Driven 3D Parabolic Water Stream (Spout Tip -> Coffee Bed Impact!)
    if (flow > 0.20) {
      final Color waterTint = engine.isRayleighBreakup
          ? const Color(0xFF93C5FD)
          : (engine.activeWaterTempC <= 75.0
              ? const Color(0xFF7DD3FC)
              : const Color(0xFFE0F2FE));

      // Gravity parabola control point: stream launches slightly forward (-Y/inward) then drops vertically
      final Offset ctrlPt = Offset(
        pSpoutTip.dx + (pHit.dx - pSpoutTip.dx) * 0.72 + rollRad * 8.0,
        pSpoutTip.dy + (pHit.dy - pSpoutTip.dy) * 0.22,
      );

      if (engine.isRayleighBreakup) {
        // Authentic Rayleigh-Plateau breakup: upper intact neck + lower shimmering falling droplets!
        final Path upperNeck = Path()..moveTo(pSpoutTip.dx, pSpoutTip.dy);
        for (int i = 1; i <= 6; i++) {
          final double t = (i / 6.0) * 0.45;
          final pt = _quadBezier(pSpoutTip, ctrlPt, pHit, t);
          upperNeck.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(
          upperNeck,
          Paint()
            ..color = waterTint.withValues(alpha: 0.78)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.2
            ..strokeCap = StrokeCap.round,
        );
        for (int d = 0; d < 9; d++) {
          final double t = 0.44 + (((d / 9.0) + animTimeSec * 2.8) % 1.0) * 0.56;
          final pt = _quadBezier(pSpoutTip, ctrlPt, pHit, t);
          canvas.drawOval(
            Rect.fromCenter(center: pt, width: 4.0, height: 7.0),
            Paint()..color = waterTint.withValues(alpha: 0.90),
          );
          canvas.drawCircle(
            pt - const Offset(0.8, 1.2),
            1.2,
            Paint()..color = Colors.white.withValues(alpha: 0.92),
          );
        }
      } else {
        // Smooth Laminar Tapered Refractive Water Tube (thins gently as gravity accelerates!)
        final double topW = (2.8 + (flow / 10.5) * 3.8).clamp(2.8, 6.8);
        final double botW = topW * 0.68;
        final List<Offset> leftEdge = [];
        final List<Offset> rightEdge = [];
        const int steps = 16;
        for (int i = 0; i <= steps; i++) {
          final double t = i / steps;
          final Offset pt = _quadBezier(pSpoutTip, ctrlPt, pHit, t);
          final double w = (topW + (botW - topW) * t) * 0.5;
          leftEdge.add(Offset(pt.dx - w, pt.dy));
          rightEdge.add(Offset(pt.dx + w, pt.dy));
        }
        final Path tube = Path()..moveTo(leftEdge.first.dx, leftEdge.first.dy);
        for (final pt in leftEdge) {
          tube.lineTo(pt.dx, pt.dy);
        }
        for (int i = rightEdge.length - 1; i >= 0; i--) {
          tube.lineTo(rightEdge[i].dx, rightEdge[i].dy);
        }
        tube.close();

        // Outer translucent refractive water body
        canvas.drawPath(
          tube,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                waterTint.withValues(alpha: 0.55),
                Colors.white.withValues(alpha: 0.92),
                waterTint.withValues(alpha: 0.62),
              ],
            ).createShader(tube.getBounds()),
        );
      }

      // Animated Concentric Surface Impact Ripples + Tiny Micro-Splash Droplets!
      for (int r = 0; r < 2; r++) {
        final double rp = (animTimeSec * 2.6 + r * 0.5) % 1.0;
        final double rx = 5.0 + rp * (engine.isRayleighBreakup ? 22.0 : 14.0);
        canvas.drawOval(
          Rect.fromCenter(center: pHit, width: rx * 2.0, height: rx * 1.15),
          Paint()
            ..color = Colors.white.withValues(alpha: (1.0 - rp) * 0.62)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
      if (flow > 3.5 || engine.isRayleighBreakup) {
        for (int s = 0; s < 5; s++) {
          final double sp = (animTimeSec * 3.8 + s * 0.21) % 1.0;
          final double ang = s * 1.3 + animTimeSec;
          final double dist = sp * (engine.isRayleighBreakup ? 16.0 : 9.0);
          final double lift = math.sin(sp * math.pi) * 9.0;
          canvas.drawCircle(
            Offset(pHit.dx + math.cos(ang) * dist,
                pHit.dy + math.sin(ang) * dist * 0.5 - lift),
            1.6,
            Paint()..color = Colors.white.withValues(alpha: (1.0 - sp) * 0.8),
          );
        }
      }
    } else {
      // Subtle aim reticle when kettle is upright (idle)
      canvas.drawOval(
        Rect.fromCenter(center: pHit, width: 14, height: 9),
        Paint()
          ..color = const Color(0xFFFBBF24).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.7,
      );
    }

    // 2. Foreground Matte-Black S-Curve Gooseneck Spout (Kettle Lower Wall -> Forward Spout Tip!)
    final Offset spoutBase = Offset(
      kettleCenter.dx - side * bodyW * 0.36,
      kettleCenter.dy + bodyH * 0.24,
    );
    final Offset spoutCtrl1 = Offset(
      kettleCenter.dx - side * bodyW * 0.92,
      kettleCenter.dy + bodyH * 0.14,
    );
    final Offset spoutCtrl2 = Offset(
      pSpoutTip.dx + side * bodyW * 0.38,
      pSpoutTip.dy + 12.0,
    );
    final Path spoutPath = Path()
      ..moveTo(spoutBase.dx, spoutBase.dy)
      ..cubicTo(
        spoutCtrl1.dx,
        spoutCtrl1.dy,
        spoutCtrl2.dx,
        spoutCtrl2.dy,
        pSpoutTip.dx,
        pSpoutTip.dy,
      );

    // Spout drop shadow
    canvas.drawPath(
      spoutPath.shift(const Offset(0, 5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Matte-black steel gooseneck tube
    canvas.drawPath(
      spoutPath,
      Paint()
        ..color = const Color(0xFF1F242D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0
        ..strokeCap = StrokeCap.round,
    );
    // Metallic studio highlight along top edge of gooseneck
    canvas.drawPath(
      spoutPath.shift(const Offset(0, -1.5)),
      Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // 3. Foreground 3D Matte-Black Precision Barista Kettle Body (Tilting Forward with Gyro!)
    canvas.save();
    canvas.translate(kettleCenter.dx, kettleCenter.dy);
    // Forward pour tilt toward the V60 dripper
    canvas.rotate(-side * (0.14 + tiltRad * 0.56) + rollRad * 0.16);

    final Rect bodyRect = Rect.fromCenter(
      center: Offset.zero,
      width: bodyW,
      height: bodyH,
    );

    // Soft cast shadow on foreground space
    canvas.drawOval(
      bodyRect.shift(Offset(side * 6, 16)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.34)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Ergonomic Counterweight Handle (user-facing outer side!)
    final Path handle = Path()
      ..moveTo(side * bodyW * 0.44, -bodyH * 0.24)
      ..cubicTo(
        side * bodyW * 0.88,
        -bodyH * 0.26,
        side * bodyW * 0.90,
        bodyH * 0.34,
        side * bodyW * 0.44,
        bodyH * 0.28,
      );
    canvas.drawPath(
      handle,
      Paint()
        ..color = const Color(0xFF15181E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      handle,
      Paint()
        ..color = const Color(0xFF64748B).withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Tapered Cylindrical Fellow Stagg Matte-Black Steel Body
    final Path kettleBody = Path()
      ..moveTo(-bodyW * 0.44, -bodyH * 0.42)
      ..lineTo(bodyW * 0.44, -bodyH * 0.42)
      ..lineTo(bodyW * 0.50, bodyH * 0.44)
      ..quadraticBezierTo(0, bodyH * 0.54, -bodyW * 0.50, bodyH * 0.44)
      ..close();

    canvas.drawPath(
      kettleBody,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.24, 0.52, 0.82, 1.0],
          colors: const [
            Color(0xFF111419),
            Color(0xFF333B48),
            Color(0xFF1C212A),
            Color(0xFF0E1116),
            Color(0xFF252B36),
          ],
        ).createShader(bodyRect),
    );

    // Recessed Glass Sight-Gauge Window showing LIVE 2-Axis Sloshing Water Level!
    final RRect sightWindow = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-side * bodyW * 0.08, bodyH * 0.04),
        width: bodyW * 0.28,
        height: bodyH * 0.56,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(sightWindow, Paint()..color = const Color(0xFF0B1220));
    canvas.save();
    canvas.clipRRect(sightWindow);
    final double fillFrac = engine.kettleSlosh.fillFraction.clamp(0.0, 1.0);
    final double surfY =
        sightWindow.bottom - sightWindow.height * fillFrac;
    final double sloshDx = math
            .tan((engine.kettleSlosh.psiXRad - tiltRad * 0.35).clamp(-0.5, 0.5)) *
        (sightWindow.width * 0.5);
    final Path waterFill = Path()
      ..moveTo(sightWindow.left - 4, sightWindow.bottom + 4)
      ..lineTo(sightWindow.left - 4, surfY - sloshDx)
      ..lineTo(sightWindow.right + 4, surfY + sloshDx)
      ..lineTo(sightWindow.right + 4, sightWindow.bottom + 4)
      ..close();
    canvas.drawPath(
      waterFill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7DD3FC), Color(0xFF0284C7)],
        ).createShader(sightWindow.outerRect),
    );
    canvas.restore();
    canvas.drawRRect(
      sightWindow,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    // 3D Perspective Kettle Top Lid (with brass collar & warm walnut wood knob!)
    final Rect lidOval = Rect.fromCenter(
      center: Offset(0, -bodyH * 0.42),
      width: bodyW * 0.88,
      height: bodyH * 0.24,
    );
    canvas.drawOval(
      lidOval,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A4250), Color(0xFF151920)],
        ).createShader(lidOval),
    );
    canvas.drawOval(
      lidOval,
      Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    // Warm Walnut Lid Knob
    final Rect knobRect = Rect.fromCenter(
      center: Offset(0, -bodyH * 0.46),
      width: bodyW * 0.24,
      height: bodyH * 0.11,
    );
    canvas.drawOval(
      knobRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C6644), Color(0xFF4A2B18)],
        ).createShader(knobRect),
    );

    canvas.restore();
  }

  static Offset _quadBezier(Offset p0, Offset p1, Offset p2, double t) {
    final double u = 1.0 - t;
    return Offset(
      u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx,
      u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy,
    );
  }

  @override
  bool shouldRepaint(covariant ManualBrewFull3DScenePainter oldDelegate) => true;
}

class _CoffeeGroundGrain {
  final double nx;
  final double nz;
  final double sizePx;
  final double tone;
  final bool isChaff;
  final double angle;

  const _CoffeeGroundGrain(
    this.nx,
    this.nz,
    this.sizePx,
    this.tone,
    this.isChaff,
    this.angle,
  );
}
