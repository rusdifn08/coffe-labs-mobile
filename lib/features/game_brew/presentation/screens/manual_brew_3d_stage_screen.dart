import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme/app_theme.dart';
import '../../data/game_brew_progress_service.dart';
import '../../domain/game_brew_studio_models.dart';
import '../../engine/manual_brew_3d_physics_engine.dart';
import '../../engine/natural_gyro_sensor_fusion.dart';
import '../../widgets/barista_precision_joystick.dart';
import '../../widgets/manual_brew_full_3d_scene_painter.dart';

/// Full-Screen (Portrait & Landscape) 3D Manual Brew Simulator v2.5:
/// - 100% Edge-to-Edge True 3D Perspective Stage (`ManualBrewFull3DScenePainter`)
///   with 3D Walnut Countertop, OLED Smart Scale, Glass Range Server, Hario V60
///   (12 Spiral Ribs + 36-Segment Wet Filter), RDT Dosing Bowl, Deformable 32x32
///   Coffee Bed, and 3D Transparent Borosilicate Gooseneck Kettle!
/// - Powered by 9-Axis `NaturalGyroSensorFusionEngine` (200Hz Gyro SO(3) +
///   Linear Accel Gravity Separation + Rao Swirl Detector + 1-Euro Tremor Filter).
class ManualBrew3DStageScreen extends StatefulWidget {
  final GameBrewLevelSpec spec;

  const ManualBrew3DStageScreen({super.key, required this.spec});

  @override
  State<ManualBrew3DStageScreen> createState() =>
      _ManualBrew3DStageScreenState();
}

class _ManualBrew3DStageScreenState extends State<ManualBrew3DStageScreen> {
  late final ManualBrew3DPhysicsEngine _engine;
  final NaturalGyroSensorFusionEngine _sensors =
      NaturalGyroSensorFusionEngine();
  final BaristaJoystickController _joystick = BaristaJoystickController(
    deadzone: 0.08,
    responseGamma: 1.85,
    maxSpeedNormPerSec: 1.55,
    workspaceMaxRadius: 0.86,
  );
  final ValueNotifier<int> _frameTick = ValueNotifier<int>(0);
  Timer? _loopTimer;

  ManualBrewCameraMode _cameraMode = ManualBrewCameraMode.baristaPov;
  double _orbitYawRad = 0.45;
  double _orbitPitchRad = 0.72;
  double _animTimeSec = 0.0;

  final bool _useGyroControl = true;
  bool _controlsOnLeft = true;
  bool _showWetnessHeatmap = true;
  bool _showPatternGuide = true;

  // Ergonomic manual pour lever fallback (0..1 -> 0..50 deg)
  double _pourLever = 0.0;
  NaturalSensorSnapshot _sensorSnap = const NaturalSensorSnapshot();

  @override
  void initState() {
    super.initState();
    _engine = ManualBrew3DPhysicsEngine(spec: widget.spec);
    _sensors.start();

    _loopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _animTimeSec += 0.016;
      _sensorSnap = _sensors.sample(0.016);

      // SEPARATED PRO ARCHITECTURE:
      // 1) Gyroscope ONLY controls Pour Flow Rate (sedikit / banyaknya air tergantung kemiringan HP!)
      final bool gyroActive = _useGyroControl && _sensorSnap.hardwareActive;
      final double leverPitch = _pourLever * 48.0;
      final double effectivePitch = gyroActive
          ? math.max(_sensorSnap.pitchDeg, leverPitch)
          : leverPitch;

      // 2) Precision Analog Joystick ONLY controls XY Pour Position & Variable Speed!
      if (_engine.phase == ManualBrewPhase.wetFilter ||
          _engine.phase == ManualBrewPhase.precisionPour) {
        _engine.aimPos = _joystick.stepPosition(_engine.aimPos, 0.016);
      }

      // Automatic physical Gentle Rao Swirl via circular hand motion when NOT pouring
      if (gyroActive &&
          _sensorSnap.swirlIntensity > 0.55 &&
          _engine.phase == ManualBrewPhase.precisionPour &&
          _engine.kettleSlosh.currentFlowMlS < 0.6) {
        _engine.applyGentleRaoSwirl(intensity: 0.12);
      }

      _engine.step(
        dt: 0.016,
        pitchDeg: effectivePitch,
        rollDeg: 0.0, // Keep kettle upright & steady — zero sideways tilt distortion!
        lateralAccelX: _joystick.state.velocityNormPerSec.dx * 1.4,
        lateralAccelZ: _joystick.state.velocityNormPerSec.dy * 1.4,
      );
      _frameTick.value++;
    });
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _sensors.stop();
    _frameTick.dispose();
    super.dispose();
  }

  void _calibrateGyroZero() {
    _sensors.calibrateZeroTare();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gyroscope 9-Axis dikalibrasi 0°! Miringkan HP halus untuk menuang.'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryBrown,
      ),
    );
  }

  void _resetSession() {
    HapticFeedback.selectionClick();
    _joystick.reset();
    setState(() {
      _pourLever = 0.0;
      _engine.reset();
    });
  }

  Future<void> _finishBrewAndSave() async {
    HapticFeedback.mediumImpact();
    final res = _engine.finishAndEvaluate();
    setState(() => _pourLever = 0.0);
    await GameBrewProgressService.recordRun(
      levelCode: widget.spec.code,
      stars: (res['stars'] ?? 0).round(),
      scorePct: res['overall'] ?? 0.0,
      metrics: res,
    );
    if (!mounted) return;
    _showResultDialog(res);
  }

  void _showResultDialog(Map<String, double> res) {
    final int stars = (res['stars'] ?? 0).round();
    final double overall = res['overall'] ?? 0.0;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Icon(
                  i < stars ? CupertinoIcons.star_fill : CupertinoIcons.star,
                  color: i < stars ? AppTheme.accentAmber : AppTheme.borderWarm,
                  size: 28,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor Manual Brew 3D: ${overall.toStringAsFixed(1)}%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _scoreRow('Akurasi Pola Tuang', '${(res['patternPct'] ?? 0).toStringAsFixed(0)}%'),
            _scoreRow('Wetting Coverage', '${(res['wettingPct'] ?? 0).toStringAsFixed(0)}%'),
            _scoreRow('Stabilitas Laju Alir', '${(res['stabilityPct'] ?? 0).toStringAsFixed(0)}%'),
            _scoreRow('Flat Coffee Bed', '${(res['flatBedPct'] ?? 0).toStringAsFixed(0)}%'),
            _scoreRow('Extraction Yield (EY%)', '${(res['eyPct'] ?? 0).toStringAsFixed(1)}%'),
            _scoreRow('TDS%', '${(res['tdsPct'] ?? 0).toStringAsFixed(2)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _cameraMode = ManualBrewCameraMode.freeOrbit);
            },
            child: const Text('Inspeksi 360°'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetSession();
            },
            child: const Text('Ulangi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  Widget _scoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.2,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pattern = widget.spec.manualPattern ?? ManualPourPattern.circularCw;

    return Scaffold(
      backgroundColor: const Color(0xFF3E2618),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final bool isLandscape = size.width > size.height;
          _sensors.setOrientation(isLandscape: isLandscape);

          return Stack(
            children: [
              // 1. FULL-BLEED 100% 3D SCENE (Portrait & Landscape!)
              Positioned.fill(
                child: RepaintBoundary(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _frameTick,
                    builder: (_, _, _) {
                      final bool gyroOn =
                          _useGyroControl && _sensorSnap.hardwareActive;
                      final double activePitch = gyroOn
                          ? math.max(_sensorSnap.pitchDeg, _pourLever * 50.0)
                          : _pourLever * 50.0;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (d) => _handleSceneTouch(d.localPosition, size),
                        onPanUpdate: (d) {
                          if (_cameraMode == ManualBrewCameraMode.freeOrbit) {
                            _orbitYawRad = (_orbitYawRad + d.delta.dx * 0.012) %
                                (math.pi * 2);
                            _orbitPitchRad =
                                (_orbitPitchRad + d.delta.dy * 0.009)
                                    .clamp(0.15, 1.42);
                          } else {
                            _handleSceneTouch(d.localPosition, size);
                          }
                        },
                        child: CustomPaint(
                          size: size,
                          painter: ManualBrewFull3DScenePainter(
                            engine: _engine,
                            pattern: pattern,
                            cameraMode: _cameraMode,
                            orbitYawRad: _orbitYawRad,
                            orbitPitchRad: _orbitPitchRad,
                            activePitchDeg: activePitch,
                            activeRollDeg: 0.0,
                            showWetnessHeatmap: _showWetnessHeatmap,
                            showPatternGuide: _showPatternGuide,
                            blindScaleMode: widget.spec.blindScaleMode,
                            animTimeSec: _animTimeSec,
                            kettleOnRight: _controlsOnLeft,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 2. FLOATING TOP GLASS HUD + CAMERA SWITCHER
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _frameTick,
                      builder: (_, _, _) =>
                          _buildFloatingTopHud(pattern, isLandscape),
                    ),
                  ),
                ),
              ),

              // 3. ERGONOMIC VERTICAL POUR CAPSULE (Active in Filter & Pour Phases)
              SafeArea(
                child: Align(
                  alignment: _controlsOnLeft
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: _controlsOnLeft ? 10 : 0,
                      right: _controlsOnLeft ? 0 : 10,
                      top: isLandscape ? 50 : 88,
                      bottom: isLandscape ? 128 : 196,
                    ),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _frameTick,
                      builder: (_, _, _) {
                        if (_engine.phase != ManualBrewPhase.wetFilter &&
                            _engine.phase != ManualBrewPhase.precisionPour) {
                          return const SizedBox.shrink();
                        }
                        return _buildVerticalKettleCapsule(isLandscape);
                      },
                    ),
                  ),
                ),
              ),

              // 4. FLOATING BOTTOM CEREMONY & TELEMETRY DOCK
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _frameTick,
                      builder: (_, _, _) => _buildBottomFloatingDock(pattern),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleSceneTouch(Offset localPos, Size size) {
    final double cx = size.width * 0.5;
    final double cy = size.height * 0.44;
    final double span = math.min(size.width, size.height) * 0.28;
    final Offset norm = Offset(
      ((localPos.dx - cx) / span).clamp(-0.94, 0.94),
      ((localPos.dy - cy) / span).clamp(-0.94, 0.94),
    );
    if (_engine.phase == ManualBrewPhase.doseAndDivot) {
      _engine.sculptDivotAt(norm);
      HapticFeedback.selectionClick();
    } else {
      _engine.aimPos = norm;
    }
  }

  Widget _buildFloatingTopHud(ManualPourPattern pattern, bool isLandscape) {
    final bool gyroLive = _useGyroControl && _sensorSnap.hardwareActive;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(true),
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.spec.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      gyroLive
                          ? 'GYRO TUANG • ${_sensorSnap.pitchDeg.toStringAsFixed(0)}° • ${_engine.flowRegimeLabel}'
                          : 'JOYSTICK + TUAS • ${pattern.shortLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFDE68A),
                      ),
                    ),
                  ],
                ),
              ),
              _topIconBtn(
                icon: CupertinoIcons.sparkles,
                active: _showPatternGuide,
                tooltip: 'Panduan Pola 3D',
                onTap: () =>
                    setState(() => _showPatternGuide = !_showPatternGuide),
              ),
              _topIconBtn(
                icon: CupertinoIcons.drop_fill,
                active: _showWetnessHeatmap,
                tooltip: 'Dry-Spot Heatmap',
                onTap: () =>
                    setState(() => _showWetnessHeatmap = !_showWetnessHeatmap),
              ),
              _topIconBtn(
                icon: CupertinoIcons.compass,
                active: gyroLive,
                tooltip: 'Kalibrasi Gyroscope 0°',
                onTap: _calibrateGyroZero,
              ),
              _topIconBtn(
                icon: CupertinoIcons.arrow_clockwise,
                active: false,
                tooltip: 'Reset Seduhan',
                onTap: _resetSession,
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),

        // 4 Camera Perspective Pills fitting 100% width cleanly
        Row(
          children: ManualBrewCameraMode.values.map((cam) {
            final active = _cameraMode == cam;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => setState(() => _cameraMode = cam),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.accentAmber
                          : Colors.black.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active ? Colors.white : Colors.white24,
                      ),
                    ),
                    child: Text(
                      cam.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.8,
                        fontWeight: FontWeight.w800,
                        color: active ? AppTheme.textDark : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _topIconBtn({
    required IconData icon,
    required bool active,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(6.5),
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.accentAmber.withValues(alpha: 0.28)
                  : Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: active ? const Color(0xFFFDE68A) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalKettleCapsule(bool isLandscape) {
    return SizedBox(
      width: 54,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sidePill(
            label: 'Tuang',
            onTap: () => setState(() => _pourLever = 0.62),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: isLandscape ? 140 : 210,
                minHeight: 95,
              ),
              child: LayoutBuilder(
                builder: (ctx, box) {
                  void updateY(double dy) {
                    final double norm =
                        (1.0 - (dy / box.maxHeight)).clamp(0.0, 1.0);
                    setState(() => _pourLever = norm);
                  }

                  final double knobTop =
                      (1.0 - _pourLever) * (box.maxHeight - 40.0);

                  return GestureDetector(
                    onVerticalDragStart: (d) => updateY(d.localPosition.dy),
                    onVerticalDragUpdate: (d) => updateY(d.localPosition.dy),
                    onTapDown: (d) => updateY(d.localPosition.dy),
                    child: Container(
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 1.3),
                      ),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: knobTop.clamp(2.0, box.maxHeight - 40.0),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryBrown,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.drop_fill,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          _sidePill(
            label: 'Stop',
            onTap: () => setState(() => _pourLever = 0.0),
          ),
          const SizedBox(height: 4),
          _sidePill(
            label: _engine.pourHeightCm > 11.0 ? 'Tinggi!' : 'Rendah',
            onTap: () => setState(() {
              _engine.pourHeightCm = _engine.pourHeightCm > 9.5 ? 6.5 : 12.2;
            }),
          ),
          const SizedBox(height: 4),
          _sidePill(
            label: _controlsOnLeft ? '⇄ Kanan' : '⇄ Kiri',
            onTap: () => setState(() => _controlsOnLeft = !_controlsOnLeft),
          ),
        ],
      ),
    );
  }

  Widget _sidePill({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 8.8,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFloatingDock(ManualPourPattern pattern) {
    final bool blind = widget.spec.blindScaleMode;
    final bool isWetPhase = _engine.phase == ManualBrewPhase.wetFilter;
    final bool showJoystick =
        isWetPhase || _engine.phase == ManualBrewPhase.precisionPour;
    final double flow = _engine.kettleSlosh.currentFlowMlS;
    final Color flowColor = flow <= 0.15
        ? Colors.white70
        : (_engine.isRayleighBreakup || flow > 6.8
            ? const Color(0xFFF87171)
            : ((flow - widget.spec.idealFlowMlS).abs() <= 1.5
                ? const Color(0xFF34D399)
                : const Color(0xFFFBBF24)));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Compact Guided Direction Coaching Pill (Super helpful for non-baristas!)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.42),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.compass_fill,
                size: 14,
                color: Color(0xFFFBBF24),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _engine.coachingHint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.6,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFEF3C7),
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Main Bottom Telemetry + Precision Analog Joystick Deck
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showJoystick && _controlsOnLeft) ...[
                BaristaPrecisionJoystick(
                  controller: _joystick,
                  size: 104,
                  label: 'ARAH KETEL',
                  onRecenter: () => setState(() {
                    _engine.aimPos = isWetPhase
                        ? const Offset(0.0, -0.68)
                        : Offset.zero;
                  }),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _hudMetric(
                          isWetPhase ? 'Bilas' : 'Air',
                          blind
                              ? 'BLIND'
                              : (isWetPhase
                                  ? '${_engine.rinseWaterInServerMl.toStringAsFixed(0)}ml'
                                  : '${_engine.pouredCoffeeWaterMl.toStringAsFixed(0)}/${widget.spec.targetWaterMl.toInt()}'),
                          const Color(0xFFFDE68A),
                        ),
                        _hudMetric(
                          'Debit',
                          '${flow.toStringAsFixed(1)}/s',
                          flowColor,
                        ),
                        _hudMetric(
                          isWetPhase ? 'Filter' : 'Basah',
                          '${_engine.activeWetnessPct.toStringAsFixed(0)}%',
                          const Color(0xFF7DD3FC),
                        ),
                        _hudMetric(
                          'Ketel',
                          '${_engine.kettleSlosh.volumeMl.toStringAsFixed(0)}ml',
                          const Color(0xFFE2E8F0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildPhaseActionRow(),
                  ],
                ),
              ),
              if (showJoystick && !_controlsOnLeft) ...[
                const SizedBox(width: 10),
                BaristaPrecisionJoystick(
                  controller: _joystick,
                  size: 104,
                  label: 'ARAH KETEL',
                  onRecenter: () => setState(() {
                    _engine.aimPos = isWetPhase
                        ? const Offset(0.0, -0.68)
                        : Offset.zero;
                  }),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _hudMetric(String label, String val, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, color: Colors.white70),
          ),
          Text(
            val,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseActionRow() {
    switch (_engine.phase) {
      case ManualBrewPhase.wetFilter:
        return Row(
          children: [
            Expanded(
              child: Text(
                'Bilas ${_engine.paperWetnessPct.toStringAsFixed(0)}%/95% • ${_engine.serverTempC.toStringAsFixed(0)}°C',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.6,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: _engine.isFilterReadyToDiscard
                  ? () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _pourLever = 0.0;
                        _engine.discardRinseWater();
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                minimumSize: const Size(0, 32),
              ),
              child: const Text(
                'Buang →',
                style: TextStyle(fontSize: 10.6, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );

      case ManualBrewPhase.rdtSpritz:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _engine.spritzRdt());
                },
                icon: const Icon(CupertinoIcons.drop_fill, size: 14),
                label: Text(
                  'Semprot RDT (${_engine.rdtSpritzCount}×)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFBAE6FD),
                  side: const BorderSide(color: Color(0xFFBAE6FD)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    setState(() => _engine.completeRdtAndMoveToDosing()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentAmber,
                  foregroundColor: AppTheme.textDark,
                ),
                child: const Text(
                  'Giling & Lanjut →',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        );

      case ManualBrewPhase.doseAndDivot:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _engine.sculptDivotAt(Offset.zero));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFDE68A),
                  side: const BorderSide(color: Color(0xFFFDE68A)),
                ),
                child: Text(
                  'Divot (${_engine.centerDivotDepthMm.toStringAsFixed(1)}mm)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    setState(() => _engine.finishDosingAndStartPouring()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentAmber,
                  foregroundColor: AppTheme.textDark,
                ),
                child: const Text(
                  'Mulai Tuang 3D →',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        );

      case ManualBrewPhase.precisionPour:
      case ManualBrewPhase.swirlAndResult:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _engine.applyGentleRaoSwirl());
                },
                icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 14),
                label: Text(
                  'Rao Swirl (${_engine.flatBedScorePct.round()}%)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF34D399),
                  side: const BorderSide(color: Color(0xFF34D399)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _finishBrewAndSave,
                icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 14),
                label: const Text(
                  'Selesai & Nilai',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentAmber,
                  foregroundColor: AppTheme.textDark,
                ),
              ),
            ),
          ],
        );
    }
  }
}
