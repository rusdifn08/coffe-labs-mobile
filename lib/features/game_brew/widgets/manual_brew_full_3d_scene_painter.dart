import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Quaternion, Vector3, Vector4;
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

/// Full-Screen True 3D Perspective Manual Brew Renderer (`Matrix4` 3D Projection):
/// Renders every barista element with rich 3D geometry & lighting across 100%
/// of Portrait & Landscape screens:
/// 1. 3D Roasted Walnut Countertop + Matte Black Barista Smart Scale (OLED readout)
/// 2. 3D Borosilicate Glass Range Server (handle, ml ticks, amber coffee / rinse water, tilt discard)
/// 3. 3D Hario V60 Ceramic Cone (12 spiral inner ribs, handle, 36-segment wet/dry paper filter)
/// 4. 3D RDT Whole-Bean Dosing Vessel & Shimmering Micro-Mist Spray (Phase 2)
/// 5. 3D Deformable 32x32 Lit Coffee Bed Heightfield (sculpted Center Divot, CO2 bloom dome, heatmap)
/// 6. 3D Pattern Trajectory Overlay floating directly on the 3D coffee bed
/// 7. 3D Crystal-Clear Transparent Borosilicate Gooseneck Kettle with live 2-axis sloshing water,
///    ml scale markings, brass collar, S-curve spout & 3D Parabolic Water Stream!
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
  });

  Matrix4 _buildViewProjection(Size size) {
    final double aspect = size.width / math.max(1.0, size.height);
    double camDist = 4.15;
    double pitch = orbitPitchRad;
    double yaw = orbitYawRad;

    switch (cameraMode) {
      case ManualBrewCameraMode.baristaPov:
        camDist = aspect > 1.1 ? 3.85 : 4.25;
        pitch = 0.78;
        yaw = 0.28;
        break;
      case ManualBrewCameraMode.xrayCutaway:
        camDist = 3.75;
        pitch = 0.24;
        yaw = 0.08;
        break;
      case ManualBrewCameraMode.topPattern:
        camDist = 3.95;
        pitch = 1.34;
        yaw = 0.0;
        break;
      case ManualBrewCameraMode.freeOrbit:
        camDist = 4.15;
        break;
    }

    final double eyeY = camDist * math.sin(pitch) + 0.05;
    final double horiz = camDist * math.cos(pitch);
    final Vector3 eye = Vector3(
      horiz * math.sin(yaw),
      eyeY,
      horiz * math.cos(yaw),
    );
    final Vector3 target = Vector3(0.0, -0.08, 0.0);
    final Vector3 up = Vector3(0.0, 1.0, 0.0);

    final Matrix4 view = _lookAt(eye, target, up);
    final Matrix4 proj = _perspective(42.0 * math.pi / 180.0, aspect, 0.1, 30.0);
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

    // 1. Warm Espresso Bar Studio Background + Wooden Bar Counter
    _drawStudioBackdrop(canvas, size);

    final Matrix4 vp = _buildViewProjection(size);
    final bool isCutaway = cameraMode == ManualBrewCameraMode.xrayCutaway;

    // 2. 3D Wooden Countertop Surface & Matte Black Barista Smart Scale
    _draw3DSmartScale(canvas, vp, size);

    // Phase 2 Special Prop: 3D Ceramic Bean Dosing Cup + RDT Atomizer Mist!
    if (engine.phase == ManualBrewPhase.rdtSpritz) {
      _draw3DRdtBeanBowl(canvas, vp, size);
      return;
    }

    // 3. 3D Borosilicate Glass Range Server + Brewed Coffee / Rinse Water + Darcy Drops
    _draw3DGlassServer(canvas, vp, size, isCutaway: isCutaway);

    // 4. 3D Hario V60 Ceramic Cone (Back Half + 12 Spiral Ribs + 36-Segment Paper Filter)
    _draw3DV60ConeBackAndFilter(canvas, vp, size, isCutaway: isCutaway);

    // 5. 3D Deformable 32x32 Coffee Grounds Heightfield Mesh + Center Divot + Slurry
    final double bedY = _draw3DCoffeeBedMesh(canvas, vp, size);

    // 6. 3D Pour Pattern Guide Path on Coffee Bed
    if (showPatternGuide &&
        (engine.phase == ManualBrewPhase.precisionPour ||
            engine.phase == ManualBrewPhase.wetFilter)) {
      _draw3DPatternGuideOnBed(canvas, vp, size, bedY);
    }

    // 7. 3D Hario V60 Front Lip & Ceramic Side Handle
    _draw3DV60ConeFrontAndHandle(canvas, vp, size, isCutaway: isCutaway);

    // 8. 3D Crystal-Clear Transparent Borosilicate Gooseneck Kettle + Parabolic Stream!
    if (cameraMode != ManualBrewCameraMode.freeOrbit) {
      _draw3DTransparentGooseneckKettleAndStream(canvas, vp, size, bedY);
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
          stops: [0.0, 0.52, 1.0],
          colors: [
            Color(0xFF3A2418),
            Color(0xFF5A3925),
            Color(0xFF3E2618),
          ],
        ).createShader(rect),
    );

    // Warm overhead barista spotlight glow
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.28),
      math.max(size.width, size.height) * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFDE68A).withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ).createShader(rect),
    );
  }

  void _draw3DSmartScale(Canvas canvas, Matrix4 vp, Size size) {
    // 3D Wood Bar Surface Plank Grid
    final tableQuad = [
      _project(Vector3(-2.6, -1.36, -1.8), vp, size),
      _project(Vector3(2.6, -1.36, -1.8), vp, size),
      _project(Vector3(2.8, -1.36, 2.2), vp, size),
      _project(Vector3(-2.8, -1.36, 2.2), vp, size),
    ];
    canvas.drawPath(
      Path()..addPolygon(tableQuad, true),
      Paint()..color = const Color(0xFF4E311F),
    );

    // 3D Matte Black Scale Top & Front OLED Bevel (Acaia / TIMEMORE Dot style)
    const double sx = 0.92;
    const double sz = 0.98;
    const double topY = -1.24;
    const double botY = -1.35;

    final topFace = [
      _project(Vector3(-sx, topY, -sz), vp, size),
      _project(Vector3(sx, topY, -sz), vp, size),
      _project(Vector3(sx, topY, sz), vp, size),
      _project(Vector3(-sx, topY, sz), vp, size),
    ];
    final frontFace = [
      _project(Vector3(-sx, topY, sz), vp, size),
      _project(Vector3(sx, topY, sz), vp, size),
      _project(Vector3(sx, botY, sz + 0.04), vp, size),
      _project(Vector3(-sx, botY, sz + 0.04), vp, size),
    ];

    canvas.drawPath(
      Path()..addPolygon(frontFace, true),
      Paint()..color = const Color(0xFF0F1318),
    );
    canvas.drawPath(
      Path()..addPolygon(topFace, true),
      Paint()..color = const Color(0xFF1C2128),
    );
    canvas.drawPath(
      Path()..addPolygon(topFace, true),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Circular Silicone Heat Pad on Scale
    final padPts = <Offset>[];
    for (int i = 0; i <= 24; i++) {
      final double a = (i / 24) * math.pi * 2;
      padPts.add(
        _project(Vector3(math.cos(a) * 0.72, topY + 0.01, math.sin(a) * 0.72), vp, size),
      );
    }
    canvas.drawPath(
      Path()..addPolygon(padPts, true),
      Paint()..color = const Color(0xFF13161B),
    );

    // Glowing OLED Digital Readout on Front Edge of 3D Scale!
    final Offset oledPos = _project(Vector3(0.0, topY + 0.005, sz * 0.84), vp, size);
    final String oledText = blindScaleMode
        ? '---- g  |  BLIND'
        : '${engine.pouredCoffeeWaterMl.toStringAsFixed(1)} g  •  ${engine.kettleSlosh.currentFlowMlS.toStringAsFixed(1)} ml/s';
    final tp = TextPainter(
      text: TextSpan(
        text: oledText,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0xFF34D399),
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, oledPos - Offset(tp.width * 0.5, tp.height * 0.5));
  }

  void _draw3DRdtBeanBowl(Canvas canvas, Matrix4 vp, Size size) {
    const int segs = 28;
    final rimPts = <Offset>[];
    final basePts = <Offset>[];
    for (int i = 0; i <= segs; i++) {
      final double a = (i / segs) * math.pi * 2;
      rimPts.add(_project(Vector3(math.cos(a) * 0.88, 0.05, math.sin(a) * 0.88), vp, size));
      basePts.add(_project(Vector3(math.cos(a) * 0.56, -0.58, math.sin(a) * 0.56), vp, size));
    }

    // Outer ceramic dosing tray wall
    for (int i = 0; i < segs; i++) {
      final poly = [rimPts[i], rimPts[i + 1], basePts[i + 1], basePts[i]];
      canvas.drawPath(
        Path()..addPolygon(poly, true),
        Paint()..color = const Color(0xFFEAE2D6),
      );
    }
    canvas.drawPath(
      Path()..addPolygon(rimPts, true),
      Paint()..color = const Color(0xFF2B1A10),
    );

    // 3D Roasted Whole Coffee Beans inside dosing vessel
    final rng = math.Random(7);
    for (int b = 0; b < 38; b++) {
      final double r = math.sqrt(rng.nextDouble()) * 0.68;
      final double a = rng.nextDouble() * math.pi * 2;
      final pt = _project(
        Vector3(math.cos(a) * r, -0.05 + rng.nextDouble() * 0.08, math.sin(a) * r),
        vp,
        size,
      );
      canvas.drawOval(
        Rect.fromCenter(center: pt, width: 15, height: 10),
        Paint()..color = const Color(0xFF5C3419),
      );
      canvas.drawLine(
        pt - const Offset(4, 0),
        pt + const Offset(4, 0),
        Paint()
          ..color = const Color(0xFF2A1508)
          ..strokeWidth = 1.3,
      );
    }

    // Shimmering RDT Micro-Mist Droplets above beans!
    if (engine.rdtSpritzCount > 0) {
      for (int m = 0; m < 26; m++) {
        final double phase = (animTimeSec * 2.0 + m * 0.21) % 1.0;
        final double mx = math.sin(m * 1.9 + animTimeSec) * 0.58;
        final double mz = math.cos(m * 2.3) * 0.58;
        final double my = 0.55 - phase * 0.55;
        final mp = _project(Vector3(mx, my, mz), vp, size);
        canvas.drawCircle(
          mp,
          2.6,
          Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 1.0 - phase * 0.7),
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
    const int segs = 28;

    final bool isRinse = engine.phase == ManualBrewPhase.wetFilter;
    final double vol = isRinse ? engine.rinseWaterInServerMl : engine.serverCoffeeMl;
    final double maxV = isRinse ? 60.0 : math.max(1.0, engine.spec.targetWaterMl);
    final double fill = (vol / maxV).clamp(0.0, 0.92);

    final double startA = isCutaway ? math.pi * 0.18 : 0.0;
    final double endA = isCutaway ? math.pi * 1.40 : math.pi * 2.0;

    // 1. Liquid Inside Glass Range Server
    if (fill > 0.015) {
      final double liqY = botY + (topY - botY - 0.10) * fill;
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
        final double shade = 0.5 + 0.4 * math.sin((a0 + a1) * 0.5);
        final Color c = isRinse
            ? Color.lerp(const Color(0xFF7DD3FC), const Color(0xFFBAE6FD), shade)!
                .withValues(alpha: 0.55)
            : Color.lerp(const Color(0xFF3E180A), const Color(0xFF9A4419), shade)!
                .withValues(alpha: 0.90);
        canvas.drawPath(Path()..addPolygon(poly, true), Paint()..color = c);
      }

      // Top meniscus oval
      final menPts = <Offset>[];
      for (int i = 0; i <= segs; i++) {
        final double a = startA + (endA - startA) * (i / segs);
        menPts.add(_project(Vector3(math.cos(a) * liqR, liqY, math.sin(a) * liqR), vp, size));
      }
      canvas.drawPath(
        Path()..addPolygon(menPts, true),
        Paint()
          ..color = isRinse
              ? const Color(0xFFBAE6FD).withValues(alpha: 0.65)
              : const Color(0xFFB45309).withValues(alpha: 0.92),
      );
    }

    // 2. Borosilicate Carafe Glass Silhouette, Rim & Handle
    final glassStroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final topRing = Path();
    final botRing = Path();
    for (int i = 0; i <= segs; i++) {
      final double a = startA + (endA - startA) * (i / segs);
      final pT = _project(Vector3(math.cos(a) * rTop, topY, math.sin(a) * rTop), vp, size);
      final pB = _project(Vector3(math.cos(a) * rBot, botY, math.sin(a) * rBot), vp, size);
      if (i == 0) {
        topRing.moveTo(pT.dx, pT.dy);
        botRing.moveTo(pB.dx, pB.dy);
      } else {
        topRing.lineTo(pT.dx, pT.dy);
        botRing.lineTo(pB.dx, pB.dy);
      }
      if (i == 0 || i == segs ~/ 2) {
        canvas.drawLine(pT, pB, glassStroke);
      }
    }
    canvas.drawPath(topRing, glassStroke);
    canvas.drawPath(botRing, glassStroke);

    // 3D Glass Handle on Right Side of Carafe
    final h1 = _project(Vector3(rTop, topY - 0.08, 0), vp, size);
    final h2 = _project(Vector3(rBot + 0.30, (topY + botY) * 0.5, 0), vp, size);
    final h3 = _project(Vector3(rBot * 0.95, botY + 0.16, 0), vp, size);
    final handlePath = Path()
      ..moveTo(h1.dx, h1.dy)
      ..quadraticBezierTo(h2.dx, h2.dy, h3.dx, h3.dy);
    canvas.drawPath(
      handlePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round,
    );

    // Falling Darcy Percolation Droplets inside Server!
    if ((isRinse && engine.kettleSlosh.currentFlowMlS > 0.25) ||
        engine.slurryMl > 1.2) {
      for (int d = 0; d < 4; d++) {
        final double frac = (animTimeSec * 1.8 + d * 0.25) % 1.0;
        final double dy = topY - frac * (topY - (botY + 0.15 + fill * 0.55));
        final dp = _project(Vector3(0, dy, 0), vp, size);
        canvas.drawCircle(
          dp,
          3.2,
          Paint()
            ..color = isRinse ? const Color(0xFF93C5FD) : const Color(0xFFD97706),
        );
      }
    }
  }

  void _draw3DV60ConeBackAndFilter(
    Canvas canvas,
    Matrix4 vp,
    Size size, {
    required bool isCutaway,
  }) {
    const int segs = 36;
    final double startA = isCutaway ? math.pi * 0.22 : math.pi;
    final double endA = isCutaway ? math.pi * 1.45 : math.pi * 2.0;

    for (int i = 0; i < segs; i++) {
      final double a0 = startA + (endA - startA) * (i / segs);
      final double a1 = startA + (endA - startA) * ((i + 1) / segs);
      final int fIdx = i % ManualBrew3DPhysicsEngine.filterSegments;
      final double w = engine.filterWetness[fIdx].clamp(0.0, 1.0);

      final poly = [
        _project(Vector3(math.cos(a0) * 1.02, 0.46, math.sin(a0) * 1.02), vp, size),
        _project(Vector3(math.cos(a1) * 1.02, 0.46, math.sin(a1) * 1.02), vp, size),
        _project(Vector3(math.cos(a1) * 0.24, -0.34, math.sin(a1) * 0.24), vp, size),
        _project(Vector3(math.cos(a0) * 0.24, -0.34, math.sin(a0) * 0.24), vp, size),
      ];
      final Color paperCol = Color.lerp(
        const Color(0xFFFFFCF7),
        const Color(0xFFD4C1AA),
        w,
      )!;
      canvas.drawPath(
        Path()..addPolygon(poly, true),
        Paint()..color = paperCol.withValues(alpha: isCutaway ? 0.45 : 0.88),
      );
    }

    // 12 Iconic Hario V60 3D Spiral Inner Ribs
    final ribPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final double swirlAngle = engine.swirlProgress * math.pi * 2.0;
    for (int r = 0; r < 12; r++) {
      final double baseA = swirlAngle + (r * math.pi * 2 / 12);
      if (isCutaway && math.sin(baseA) > 0.35) continue;
      final p = Path();
      for (int s = 0; s <= 6; s++) {
        final double t = s / 6.0;
        final double rad = 0.24 + t * 0.76;
        final double y = -0.33 + t * 0.78;
        final double a = baseA + t * 0.68;
        final pt = _project(Vector3(math.cos(a) * rad, y, math.sin(a) * rad), vp, size);
        if (s == 0) {
          p.moveTo(pt.dx, pt.dy);
        } else {
          p.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(p, ribPaint);
    }
  }

  double _draw3DCoffeeBedMesh(Canvas canvas, Matrix4 vp, Size size) {
    if (!engine.groundsDosed &&
        engine.phase != ManualBrewPhase.precisionPour &&
        engine.phase != ManualBrewPhase.swirlAndResult) {
      return 0.08;
    }

    const int n = ManualBrew3DPhysicsEngine.gridSize;
    const int step = 2;
    final double slurryLift = (engine.slurryMl / 110.0).clamp(0.0, 0.26);
    final double baseY = -0.05 + slurryLift * 0.32;
    const double ampY = 0.34;
    const double bedR = 0.72;
    final Vector3 lightDir = Vector3(0.45, 0.86, 0.32)..normalize();

    for (int y = 0; y < n - step; y += step) {
      for (int x = 0; x < n - step; x += step) {
        final double nx0 = (x / (n - 1)) * 2.0 - 1.0;
        final double nz0 = (y / (n - 1)) * 2.0 - 1.0;
        final double nx1 = ((x + step) / (n - 1)) * 2.0 - 1.0;
        final double nz1 = ((y + step) / (n - 1)) * 2.0 - 1.0;
        final double cx = (nx0 + nx1) * 0.5;
        final double cz = (nz0 + nz1) * 0.5;
        if (cx * cx + cz * cz > 0.96) continue;

        final int i00 = y * n + x;
        final int i10 = y * n + (x + step);
        final int i11 = (y + step) * n + (x + step);
        final int i01 = (y + step) * n + x;

        final v00 = Vector3(nx0 * bedR, baseY + engine.bedHeight[i00] * ampY, nz0 * bedR);
        final v10 = Vector3(nx1 * bedR, baseY + engine.bedHeight[i10] * ampY, nz0 * bedR);
        final v11 = Vector3(nx1 * bedR, baseY + engine.bedHeight[i11] * ampY, nz1 * bedR);
        final v01 = Vector3(nx0 * bedR, baseY + engine.bedHeight[i01] * ampY, nz1 * bedR);

        final normal = (v01 - v00).cross(v10 - v00)..normalize();
        final double lit = (normal.dot(lightDir) * 0.5 + 0.5).clamp(0.22, 1.0);

        final double wet = engine.wetnessMap[i00];
        final double co2 = engine.co2Map[i00];

        Color col = Color.lerp(
          const Color(0xFF8C5830),
          const Color(0xFF3B1E0E),
          wet,
        )!;
        if (wet > 0.25 && co2 > 0.45) {
          col = Color.lerp(col, const Color(0xFFD8A468), (co2 - 0.45) * 0.65)!;
        }
        if (showWetnessHeatmap &&
            engine.phase == ManualBrewPhase.precisionPour &&
            wet < 0.72) {
          col = Color.lerp(col, const Color(0xFFF59E0B), 0.36)!;
        }
        final Color shaded = Color.lerp(const Color(0xFF1A0C05), col, lit)!;

        final quad = [
          _project(v00, vp, size),
          _project(v10, vp, size),
          _project(v11, vp, size),
          _project(v01, vp, size),
        ];
        canvas.drawPath(Path()..addPolygon(quad, true), Paint()..color = shaded);
      }
    }

    // Translucent Slurry Water Pool on top of Coffee Bed
    if (slurryLift > 0.02) {
      final double waterY = baseY + 0.20 + slurryLift * 0.35;
      final double waterR = 0.68 + slurryLift * 0.22;
      final pts = <Offset>[];
      for (int i = 0; i <= 28; i++) {
        final double a = (i / 28) * math.pi * 2;
        pts.add(_project(Vector3(math.cos(a) * waterR, waterY, math.sin(a) * waterR), vp, size));
      }
      canvas.drawPath(
        Path()..addPolygon(pts, true),
        Paint()
          ..color = (engine.activeWaterTempC <= 75.0
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFFA85824))
              .withValues(alpha: 0.34),
      );
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
      ..color = const Color(0xFFFBBF24).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (engine.phase == ManualBrewPhase.wetFilter) {
      final ring = Path();
      for (int i = 0; i <= 32; i++) {
        final double a = (i / 32) * math.pi * 2;
        final pt = _project(Vector3(math.cos(a) * 0.82, 0.25, math.sin(a) * 0.82), vp, size);
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
            final pt = _project(Vector3(math.cos(a) * r, bedY + 0.03, math.sin(a) * r), vp, size);
            if (i == 0) {
              p.moveTo(pt.dx, pt.dy);
            } else {
              p.lineTo(pt.dx, pt.dy);
            }
          }
          canvas.drawPath(p, guidePaint);
        }
        // Animated orbiting gold guide bead showing exact CW vs CCW direction!
        final double dir =
            pattern == ManualPourPattern.reverseCircularCcw ? -1.0 : 1.0;
        final double beadAngle = animTimeSec * 2.2 * dir;
        final Offset beadPt = _project(
          Vector3(math.cos(beadAngle) * 0.44, bedY + 0.04, math.sin(beadAngle) * 0.44),
          vp,
          size,
        );
        canvas.drawCircle(beadPt, 5.5, Paint()..color = const Color(0xFFFBBF24));
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
          final p = _project(Vector3(pts[i][0], bedY + 0.03, pts[i][1]), vp, size);
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
          final pt = _project(Vector3(math.cos(a) * 0.18, bedY + 0.03, math.sin(a) * 0.18), vp, size);
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

  void _draw3DV60ConeFrontAndHandle(
    Canvas canvas,
    Matrix4 vp,
    Size size, {
    required bool isCutaway,
  }) {
    const int segs = 32;
    final double startA = isCutaway ? math.pi * 0.22 : 0.0;
    final double endA = isCutaway ? math.pi * 1.45 : math.pi;

    // Front translucent ceramic/glass cone wall
    if (!isCutaway && cameraMode != ManualBrewCameraMode.topPattern) {
      for (int i = 0; i < segs; i++) {
        final double a0 = startA + (endA - startA) * (i / segs);
        final double a1 = startA + (endA - startA) * ((i + 1) / segs);
        final poly = [
          _project(Vector3(math.cos(a0) * 1.02, 0.46, math.sin(a0) * 1.02), vp, size),
          _project(Vector3(math.cos(a1) * 1.02, 0.46, math.sin(a1) * 1.02), vp, size),
          _project(Vector3(math.cos(a1) * 0.24, -0.34, math.sin(a1) * 0.24), vp, size),
          _project(Vector3(math.cos(a0) * 0.24, -0.34, math.sin(a0) * 0.24), vp, size),
        ];
        canvas.drawPath(
          Path()..addPolygon(poly, true),
          Paint()..color = const Color(0xFFFAF2E8).withValues(alpha: 0.24),
        );
      }
    }

    // Crisp V60 Top Ceramic Lip Ring & Base Flange
    final rimPath = Path();
    for (int i = 0; i <= 36; i++) {
      final double a = (i / 36) * math.pi * 2;
      final pt = _project(Vector3(math.cos(a) * 1.02, 0.46, math.sin(a) * 1.02), vp, size);
      if (i == 0) {
        rimPath.moveTo(pt.dx, pt.dy);
      } else {
        rimPath.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(
      rimPath,
      Paint()
        ..color = const Color(0xFFFAF5EE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.8,
    );

    // Left Ceramic V60 Handle
    final ch1 = _project(Vector3(-0.88, 0.36, 0), vp, size);
    final ch2 = _project(Vector3(-1.32, 0.22, 0), vp, size);
    final ch3 = _project(Vector3(-0.56, -0.18, 0), vp, size);
    canvas.drawPath(
      Path()
        ..moveTo(ch1.dx, ch1.dy)
        ..quadraticBezierTo(ch2.dx, ch2.dy, ch3.dx, ch3.dy),
      Paint()
        ..color = const Color(0xFFF3ECE2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Renders the 3D Crystal-Clear Transparent Borosilicate Gooseneck Kettle
  /// hovering in 3D space above the V60 with live sloshing internal water,
  /// `ml` markings, S-curve gooseneck spout, and 3D Parabolic Water Stream!
  void _draw3DTransparentGooseneckKettleAndStream(
    Canvas canvas,
    Matrix4 vp,
    Size size,
    double bedY,
  ) {
    final double impX = engine.aimPos.dx * 0.68;
    final double impZ = engine.aimPos.dy * 0.68;
    final double heightWorldLift = ((engine.pourHeightCm - 4.0) / 10.0) * 0.55;
    final double tiltRad = (activePitchDeg * math.pi / 180.0).clamp(0.0, 1.02);
    final double rollRad = (activeRollDeg * math.pi / 180.0).clamp(-0.55, 0.55);

    final Vector3 kettleCenter = Vector3(
      impX + 0.96,
      1.18 + heightWorldLift - tiltRad * 0.12,
      impZ - 0.12,
    );
    final Quaternion qKettle = Quaternion.euler(rollRad * 0.5, 0.0, tiltRad * 0.85);
    final Vector3 spoutTipWorld =
        kettleCenter + qKettle.rotated(Vector3(-0.82, -0.14, 0.0));
    final Vector3 impactWorld = Vector3(
      impX,
      engine.phase == ManualBrewPhase.wetFilter ? 0.22 : (bedY + 0.02),
      impZ,
    );

    // 1. 3D Parabolic Water Stream (Laminar Glass Stream vs Rayleigh-Plateau Droplets!)
    final double flow = engine.kettleSlosh.currentFlowMlS;
    final Offset pHit = _project(impactWorld, vp, size);

    if (flow > 0.22) {
      final Color streamCol = engine.isRayleighBreakup
          ? const Color(0xFFEF4444)
          : (engine.activeWaterTempC <= 75.0
              ? const Color(0xFF38BDF8)
              : const Color(0xFFBAE6FD));

      if (engine.isRayleighBreakup) {
        // Broken turbulent droplets due to excessive pour height (> 11 cm)!
        for (int i = 1; i <= 12; i++) {
          final double s = ((i / 12.0) + animTimeSec * 2.5) % 1.0;
          final double px = spoutTipWorld.x + (impactWorld.x - spoutTipWorld.x) * s;
          final double pz = spoutTipWorld.z + (impactWorld.z - spoutTipWorld.z) * s;
          final double py =
              spoutTipWorld.y + (impactWorld.y - spoutTipWorld.y) * (s * s);
          final dp = _project(Vector3(px, py, pz), vp, size);
          canvas.drawCircle(dp, 3.6, Paint()..color = streamCol);
        }
      } else {
        // Crystal-clear continuous laminar parabolic tube!
        final streamPath = Path();
        for (int i = 0; i <= 16; i++) {
          final double s = i / 16.0;
          final double px = spoutTipWorld.x + (impactWorld.x - spoutTipWorld.x) * s;
          final double pz = spoutTipWorld.z + (impactWorld.z - spoutTipWorld.z) * s;
          final double py =
              spoutTipWorld.y + (impactWorld.y - spoutTipWorld.y) * (s * s);
          final pt = _project(Vector3(px, py, pz), vp, size);
          if (i == 0) {
            streamPath.moveTo(pt.dx, pt.dy);
          } else {
            streamPath.lineTo(pt.dx, pt.dy);
          }
        }
        canvas.drawPath(
          streamPath,
          Paint()
            ..color = streamCol.withValues(alpha: 0.90)
            ..style = PaintingStyle.stroke
            ..strokeWidth = (2.4 + (flow / 10.5) * 4.2).clamp(2.4, 6.8)
            ..strokeCap = StrokeCap.round,
        );
      }

      // Impact splash ripple on coffee bed
      canvas.drawCircle(
        pHit,
        engine.isRayleighBreakup ? 14.0 : 8.5,
        Paint()
          ..color = streamCol.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    } else {
      canvas.drawCircle(
        pHit,
        6.0,
        Paint()
          ..color = const Color(0xFFFBBF24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }

    // 2. 3D Transparent Borosilicate Gooseneck Kettle Body + Sloshing Water!
    final Offset kCenterScreen = _project(kettleCenter, vp, size);
    final Offset kTopScreen =
        _project(kettleCenter + qKettle.rotated(Vector3(0.0, 0.34, 0.0)), vp, size);
    final double kHeightPx = (kCenterScreen - kTopScreen).distance * 2.05;
    final double kWidthPx = kHeightPx * 0.76;

    // 3D S-Curve Gooseneck Spout from kettle lower-left to `spoutTipWorld`
    final Offset pSpoutBase = _project(
      kettleCenter + qKettle.rotated(Vector3(-0.26, -0.22, 0.0)),
      vp,
      size,
    );
    final Offset pSpoutMid = _project(
      kettleCenter + qKettle.rotated(Vector3(-0.56, -0.02, 0.0)),
      vp,
      size,
    );
    final Offset pSpoutTip = _project(spoutTipWorld, vp, size);
    final spoutPath = Path()
      ..moveTo(pSpoutBase.dx, pSpoutBase.dy)
      ..quadraticBezierTo(pSpoutMid.dx, pSpoutMid.dy, pSpoutTip.dx, pSpoutTip.dy);
    canvas.drawPath(
      spoutPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0
        ..strokeCap = StrokeCap.round,
    );
    if (flow > 0.2) {
      canvas.drawPath(
        spoutPath,
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // Draw Tilted Transparent Borosilicate Glass Kettle Cylinder in Screen-Projected 3D!
    canvas.save();
    canvas.translate(kCenterScreen.dx, kCenterScreen.dy);
    canvas.rotate(-tiltRad * 0.82);

    final Rect bodyRect = Rect.fromCenter(
      center: Offset.zero,
      width: kWidthPx.clamp(46.0, 120.0),
      height: kHeightPx.clamp(58.0, 150.0),
    );
    final RRect glassBody = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(10),
    );

    // Counterweight Handle (Right)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          bodyRect.right - 2,
          bodyRect.top + bodyRect.height * 0.16,
          14,
          bodyRect.height * 0.62,
        ),
        const Radius.circular(7),
      ),
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5,
    );

    // Glass wall tint
    canvas.drawRRect(
      glassBody,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.55),
            const Color(0xFFBAE6FD).withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.50),
          ],
        ).createShader(bodyRect),
    );

    // Live 2-Axis Sloshing Hot Water Inside Glass Kettle!
    canvas.save();
    canvas.clipRRect(glassBody);
    final double fillFrac = engine.kettleSlosh.fillFraction.clamp(0.0, 1.0);
    final double liqH = bodyRect.height * fillFrac;
    final double surfY = bodyRect.bottom - liqH;
    final double slope =
        math.tan((engine.kettleSlosh.psiXRad - tiltRad * 0.45).clamp(-0.6, 0.6)) *
            (bodyRect.width * 0.48);

    final Path waterPoly = Path()
      ..moveTo(bodyRect.left - 10, bodyRect.bottom + 10)
      ..lineTo(bodyRect.left - 6, surfY - slope)
      ..lineTo(bodyRect.right + 6, surfY + slope)
      ..lineTo(bodyRect.right + 10, bodyRect.bottom + 10)
      ..close();
    canvas.drawPath(
      waterPoly,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF7DD3FC).withValues(alpha: 0.74),
            const Color(0xFF0284C7).withValues(alpha: 0.86),
          ],
        ).createShader(bodyRect),
    );

    // Graduated ml measurement lines printed on glass kettle!
    for (int step = 1; step <= 4; step++) {
      final double fy = bodyRect.bottom - bodyRect.height * (step / 5.0);
      canvas.drawLine(
        Offset(bodyRect.right - 12, fy),
        Offset(bodyRect.right - 3, fy),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.78)
          ..strokeWidth = 1.2,
      );
      if (step.isEven) {
        final int mlMark = (engine.kettleSlosh.capacityMl * (step / 5.0)).round();
        final tp = TextPainter(
          text: TextSpan(
            text: '$mlMark',
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(bodyRect.right - 14 - tp.width, fy - 4));
      }
    }
    canvas.restore();

    // Brass Lid Collar & Knob + Glass Outline
    canvas.drawRRect(
      glassBody,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawLine(
      Offset(bodyRect.left + 4, bodyRect.top),
      Offset(bodyRect.right - 4, bodyRect.top),
      Paint()
        ..color = const Color(0xFFD4AF37)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(0, bodyRect.top - 5),
      5.0,
      Paint()..color = const Color(0xFFD4AF37),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ManualBrewFull3DScenePainter oldDelegate) => true;
}
