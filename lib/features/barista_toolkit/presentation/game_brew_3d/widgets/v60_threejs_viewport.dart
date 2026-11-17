import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flame/game.dart' hide Matrix4, Quaternion, Vector2, Vector3, Vector4;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:three_js_angle_renderer/three_js_angle_renderer.dart';
import 'package:three_js_core/three_js_core.dart' as three;
import 'package:three_js_math/three_js_math.dart' as tmath;

import '../engine/v60_3d_scene_renderer.dart';
import '../engine/v60_threejs_scene_builder.dart';

/// Viewport PBR 3D Nyata (`ThreeJS` OpenGL ES / ANGLE GPU Renderer)
/// yang menyinkronkan kamera perspektif (`Barista POV`, `3D X-Ray`, `360° Orbit`),
/// ketel leher angsa 3D, kertas filter basah, dripper terangkat, & pancaran air 3D.
/// Menyediakan fallback aman otomatis di lingkungan headless test / tanpa GPU.
class V60ThreeJsViewport extends StatefulWidget {
  final V603DFlameSimulatorGame game;
  final V603DCameraPerspective cameraMode;

  const V60ThreeJsViewport({
    super.key,
    required this.game,
    required this.cameraMode,
  });

  @override
  State<V60ThreeJsViewport> createState() => _V60ThreeJsViewportState();
}

class _V60ThreeJsViewportState extends State<V60ThreeJsViewport> {
  ThreeJS? _threeJs;
  Size? _initializedSize;
  bool _setupComplete = false;
  bool _useFallbackCanvas = false;
  final V60ThreeJsSceneBuilder _sceneBuilder = V60ThreeJsSceneBuilder();

  bool get _isHeadlessTestEnvironment =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    if (_isHeadlessTestEnvironment) {
      _useFallbackCanvas = true;
    }
  }

  void _ensureThreeJsForSize(Size size) {
    if (_useFallbackCanvas || _threeJs != null) return;
    if (size.width < 40 || size.height < 40) return;

    _initializedSize = size;
    _threeJs = ThreeJS(
      size: size,
      settings: Settings(
        enableShadowMap: true,
        antialias: true,
        alpha: false,
        clearColor: 0x160E09,
        shadowMapType: tmath.PCFShadowMap,
        toneMapping: tmath.ACESFilmicToneMapping,
        toneMappingExposure: 1.15,
      ),
      loadingWidget: const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      ),
      onSetupComplete: () {
        if (!mounted) return;
        setState(() {
          _setupComplete = true;
        });
      },
      setup: _setup3DScene,
    );
  }

  Future<void> _setup3DScene() async {
    final engine = _threeJs;
    if (engine == null) return;

    try {
      engine.scene = three.Scene();
      engine.scene.background = tmath.Color.fromHex32(0x160E09);

      final double w = math.max(1.0, _initializedSize?.width ?? 400.0);
      final double h = math.max(1.0, _initializedSize?.height ?? 500.0);
      engine.camera = three.PerspectiveCamera(42.0, w / h, 0.1, 45.0);

      _sceneBuilder.buildIntoScene(engine.scene);
      _syncCameraPose(engine.camera);
      _sceneBuilder.syncFromSimulation(
        snapshot: widget.game.snapshotNotifier.value,
        game: widget.game,
        cameraMode: widget.cameraMode,
      );

      engine.addAnimationEvent((double dt) {
        if (!mounted) return;
        widget.game.tickExternalPhysics(dt);
        _syncCameraPose(engine.camera);
        _sceneBuilder.syncFromSimulation(
          snapshot: widget.game.snapshotNotifier.value,
          game: widget.game,
          cameraMode: widget.cameraMode,
        );
      });
    } catch (e) {
      debugPrint('ThreeJS 3D OpenGL fallback triggered: $e');
      if (mounted) {
        setState(() => _useFallbackCanvas = true);
      }
    }
  }

  void _syncCameraPose(three.Camera camera) {
    final double camDist = widget.cameraMode == V603DCameraPerspective.xrayCutaway
        ? 3.85
        : (widget.cameraMode == V603DCameraPerspective.freeOrbit ? 4.35 : 4.25);
    final double pitch = widget.game.orbitPitchRad;
    final double yaw = widget.game.orbitYawRad;

    final double eyeY = camDist * math.sin(pitch) + 0.15;
    final double horiz = camDist * math.cos(pitch);
    final double eyeX = horiz * math.sin(yaw);
    final double eyeZ = horiz * math.cos(yaw);

    camera.position.setValues(eyeX, eyeY, eyeZ);
    camera.lookAt(tmath.Vector3(0.05, 0.12, 0.0));
  }

  @override
  void dispose() {
    if (_setupComplete && _threeJs != null) {
      try {
        _threeJs!.dispose();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_useFallbackCanvas) {
      return GameWidget(game: widget.game);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _ensureThreeJsForSize(size);
        final engine = _threeJs;
        if (engine == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          );
        }
        return SizedBox(
          width: size.width,
          height: size.height,
          child: engine.build(),
        );
      },
    );
  }
}
