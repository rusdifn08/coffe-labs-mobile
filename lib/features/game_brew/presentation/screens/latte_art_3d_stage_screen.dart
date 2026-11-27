import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/social_service.dart';
import '../../../../theme/app_theme.dart';
import '../../data/game_brew_progress_service.dart';
import '../../domain/game_brew_studio_models.dart';
import '../../engine/latte_art_cfd_engine.dart';
import '../../engine/natural_gyro_sensor_fusion.dart';
import '../../widgets/barista_precision_joystick.dart';
import '../../widgets/latte_art_full_3d_scene_painter.dart';

/// Full-Screen (Portrait & Landscape) 3D Latte Art Simulator v2.5:
/// - Edge-to-edge 3D Barista Walnut Table, Saucer, Curved Porcelain Cup,
///   3D Hovering & Tilting Milk Pitcher (Glass or Ceramic) & Tapered Milk Stream
/// - Powered by 9-Axis `NaturalGyroSensorFusionEngine` (200Hz Gyro SO(3) +
///   Linear Accel Gravity Separation + Magnetometer + 1-Euro Tremor Filter)
/// - Ergonomic Left/Right Handed Vertical Pour Capsule + Post-Pour Collector Card
///   with 5 selectable Ceramic Cup Colors!
class LatteArt3DStageScreen extends StatefulWidget {
  final GameBrewLevelSpec spec;

  const LatteArt3DStageScreen({super.key, required this.spec});

  @override
  State<LatteArt3DStageScreen> createState() => _LatteArt3DStageScreenState();
}

class _LatteArt3DStageScreenState extends State<LatteArt3DStageScreen> {
  late final LatteArtCfdEngine _cfd;
  final NaturalGyroSensorFusionEngine _sensors =
      NaturalGyroSensorFusionEngine();
  final BaristaJoystickController _joystick = BaristaJoystickController(
    deadzone: 0.08,
    responseGamma: 1.85,
    maxSpeedNormPerSec: 1.48,
    workspaceMaxRadius: 0.76,
  );
  final ValueNotifier<int> _frameTick = ValueNotifier<int>(0);
  Timer? _simTimer;

  ui.Image? _fluidImage;
  bool _decodingImage = false;

  final bool _useGyroControl = true;
  bool _controlsOnLeft = true; // Ergonomic Left/Right swap
  bool _transparentGlassPitcher = false; // Default to photorealistic Brushed Stainless-Steel Pitcher
  bool _showGhostGuide = true;
  bool _isLowFloatHeight = false; // Deliberate Dive (4.8cm) vs Float (1.1cm) toggle!
  LatteCupColorTheme _cupTheme = LatteCupColorTheme.cobaltBlue;

  // Manual / Hybrid Pour Lever fallback (0..1 -> 0..46 deg)
  double _pourLever = 0.0;
  double _touchWiggleVel = 0.0;
  NaturalSensorSnapshot _sensorSnap = const NaturalSensorSnapshot();

  // Post-pour top-down collector inspection state
  bool _isInspectingResult = false;
  LatteArtWlacGrade? _finalGrade;
  bool _isSharing = false;

  LatteArtPattern get _targetPattern =>
      widget.spec.lattePattern ?? LatteArtPattern.heart;

  @override
  void initState() {
    super.initState();
    _cfd = LatteArtCfdEngine(
      cupCapacityMl: widget.spec.cupCapacityMl,
      espressoBaseMl: widget.spec.espressoBaseMl,
    );
    _decodeFluidFrame();
    _sensors.start();

    _simTimer = Timer.periodic(const Duration(milliseconds: 20), (_) {
      if (_isInspectingResult) return;

      _sensorSnap = _sensors.sample(0.020);
      final bool gyroActive = _useGyroControl && _sensorSnap.hardwareActive;

      // SEPARATED PRO ARCHITECTURE:
      // 1) Gyroscope ONLY controls Milk Pour Flow Rate (sedikit / banyaknya susu tergantung kemiringan HP!)
      final double leverPitch = _pourLever * 46.0;
      final double effectivePitch = gyroActive
          ? (_sensorSnap.pitchDeg > leverPitch
              ? _sensorSnap.pitchDeg
              : leverPitch)
          : leverPitch;

      // 2) Deliberate Pour Height (Dive 4.85 cm vs Float 1.15 cm) — NEVER hijacked by tilt!
      _cfd.pourHeightCm = _isLowFloatHeight ? 1.15 : 4.85;

      // 3) Precision Analog Joystick ONLY controls XY Pitcher Position + Wiggle Velocity!
      _cfd.pourPos = _joystick.stepPosition(_cfd.pourPos, 0.020);
      final double joyWiggle =
          (_joystick.state.velocityNormPerSec.dx * 3.8).clamp(-6.5, 6.5);
      final double wiggleVel = (joyWiggle + _touchWiggleVel).clamp(-6.8, 6.8);

      _cfd.step(
        dt: 0.020,
        pitchDeg: effectivePitch,
        rollDeg: 0.0,
        wiggleAngularVel: wiggleVel,
        lateralAccelX: _joystick.state.velocityNormPerSec.dx * 1.2,
      );
      _touchWiggleVel *= 0.82;
      _decodeFluidFrame();
      _frameTick.value++;
    });
  }

  void _decodeFluidFrame() {
    if (_decodingImage || !mounted) return;
    _decodingImage = true;
    ui.decodeImageFromPixels(
      _cfd.rgbaBuffer,
      LatteArtCfdEngine.n,
      LatteArtCfdEngine.n,
      ui.PixelFormat.rgba8888,
      (ui.Image img) {
        _decodingImage = false;
        if (!mounted) {
          img.dispose();
          return;
        }
        _fluidImage?.dispose();
        _fluidImage = img;
      },
    );
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _sensors.stop();
    _fluidImage?.dispose();
    _frameTick.dispose();
    super.dispose();
  }

  void _calibrateGyro() {
    _sensors.calibrateZeroTare();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gyroscope 9-Axis dikalibrasi 0° pada posisi tangan saat ini!'),
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
      _isLowFloatHeight = false;
      _isInspectingResult = false;
      _finalGrade = null;
      _cfd.reset();
    });
    _decodeFluidFrame();
  }

  Future<void> _finishAndGrade() async {
    HapticFeedback.mediumImpact();
    final grade = _cfd.evaluateCup(_targetPattern);
    setState(() {
      _pourLever = 0.0;
      _finalGrade = grade;
      _isInspectingResult = true;
    });
    await GameBrewProgressService.recordRun(
      levelCode: widget.spec.code,
      stars: grade.stars,
      scorePct: grade.overallScorePct,
      metrics: grade.toMetricsMap(),
    );
  }

  Future<void> _shareToSocial(LatteArtWlacGrade grade) async {
    setState(() => _isSharing = true);
    try {
      await SocialService.createPost(
        content:
            '🎨 Melukis ${_targetPattern.label} [${grade.rankBadge}] di Latte Art 3D Simulator Coffee Labs!\n'
            '• Skor WLAC: ${grade.overallScorePct.toStringAsFixed(0)}/100 (${'★' * grade.stars})\n'
            '• Presisi: ${grade.patternFidelityPct.toStringAsFixed(0)}% | Simetri: ${grade.symmetryPct.toStringAsFixed(0)}% | Kontras: ${grade.contrastPct.toStringAsFixed(0)}%\n'
            '#CoffeeLabs #LatteArt3D #GyroBarista',
        tags: const ['LatteArt3D', 'GameBrew', 'WLAC'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF0F766E),
            content: Text('Karya Latte Art 3D dibagikan ke Social Coffee!'),
          ),
        );
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF533421),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final bool isLandscape = size.width > size.height;
          _sensors.setOrientation(isLandscape: isLandscape);

          return Stack(
            children: [
              // 1. FULL-SCREEN 100% 3D SCENE (Portrait & Landscape!)
              Positioned.fill(
                child: RepaintBoundary(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _frameTick,
                    builder: (_, _, _) {
                      final bool gyroOn =
                          _useGyroControl && _sensorSnap.hardwareActive;
                      final double activePitch = gyroOn
                          ? (_sensorSnap.pitchDeg > _pourLever * 44.0
                              ? _sensorSnap.pitchDeg
                              : _pourLever * 44.0)
                          : _pourLever * 44.0;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (d) {
                          if (_isInspectingResult) return;
                          _cfd.pourPos =
                              LatteArtFull3DScenePainter.screenToCupNormalized(
                            d.localPosition,
                            size,
                            isLandscape: isLandscape,
                            topDown: false,
                          );
                        },
                        onPanUpdate: (d) {
                          if (_isInspectingResult) return;
                          _cfd.pourPos =
                              LatteArtFull3DScenePainter.screenToCupNormalized(
                            d.localPosition,
                            size,
                            isLandscape: isLandscape,
                            topDown: false,
                          );
                          _touchWiggleVel =
                              (d.delta.dx * 0.36).clamp(-6.0, 6.0);
                        },
                        child: CustomPaint(
                          size: size,
                          painter: LatteArtFull3DScenePainter(
                            cfd: _cfd,
                            fluidImage: _fluidImage,
                            cupTheme: _cupTheme,
                            transparentGlassPitcher: _transparentGlassPitcher,
                            topDownInspectionMode: _isInspectingResult,
                            showGhostGuide:
                                _showGhostGuide && !_isInspectingResult,
                            targetPattern: _targetPattern,
                            activePitchDeg: activePitch,
                            activeRollDeg:
                                _joystick.state.velocityNormPerSec.dx * 10.0,
                            pitcherOnRight: _controlsOnLeft,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 2. FLOATING TOP GLASS HUD BAR
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _frameTick,
                      builder: (_, _, _) => _buildFloatingTopHud(isLandscape),
                    ),
                  ),
                ),
              ),

              // 3. OVERFLOW CALLOUT BANNER (like 69s of reference video!)
              if (!_isInspectingResult)
                Positioned(
                  top: isLandscape ? 58 : 96,
                  left: 16,
                  right: 16,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _frameTick,
                    builder: (_, _, _) {
                      if (!_cfd.spilled) return const SizedBox.shrink();
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB91C1C).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Text(
                            'Cangkir Meluap! Kurangi Sudut Tuang!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 4. ERGONOMIC VERTICAL POUR CAPSULE + ACTION DOCK (Active Pouring)
              if (!_isInspectingResult) ...[
                SafeArea(
                  child: Align(
                    alignment: _controlsOnLeft
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: _controlsOnLeft ? 12 : 0,
                        right: _controlsOnLeft ? 0 : 12,
                        top: isLandscape ? 42 : 76,
                        bottom: isLandscape ? 124 : 196,
                      ),
                      child: _buildVerticalPourCapsule(isLandscape),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: ValueListenableBuilder<int>(
                        valueListenable: _frameTick,
                        builder: (_, _, _) => _buildBottomFloatingBar(),
                      ),
                    ),
                  ),
                ),
              ],

              // 5. POST-POUR TOP-DOWN COLLECTOR CARD & CUP COLOR PICKER (16s & 90s of video!)
              if (_isInspectingResult && _finalGrade != null)
                SafeArea(
                  child: Align(
                    alignment: isLandscape
                        ? Alignment.centerRight
                        : Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        12,
                        isLandscape ? 52 : 12,
                        12,
                        12,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isLandscape ? size.width * 0.46 : 460,
                        ),
                        child: _buildCollectorResultCard(_finalGrade!),
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

  Widget _buildFloatingTopHud(bool isLandscape) {
    final double alphaFloat = _cfd.computeFloatFactor(
      _cfd.pourHeightCm,
      _cfd.pitcherSlosh.currentFlowMlS,
    );
    final bool isFloat = alphaFloat >= 0.45;
    final bool gyroLive = _useGyroControl && _sensorSnap.hardwareActive;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.46),
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
                          ? 'GYRO TUANG • ${_sensorSnap.pitchDeg.toStringAsFixed(0)}° • ${_cfd.pitcherSlosh.currentFlowMlS.toStringAsFixed(1)} ml/s'
                          : '${_targetPattern.label} • ${_cfd.cupVolumeMl.toStringAsFixed(0)}/${_cfd.cupCapacityMl.toInt()} ml',
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
              _hudIconBtn(
                icon: CupertinoIcons.drop_fill,
                active: _transparentGlassPitcher,
                tooltip: 'Pitcher Kaca Transparan / Keramik',
                onTap: () => setState(
                  () => _transparentGlassPitcher = !_transparentGlassPitcher,
                ),
              ),
              _hudIconBtn(
                icon: CupertinoIcons.sparkles,
                active: _showGhostGuide,
                tooltip: 'Panduan Siluet Pola',
                onTap: () => setState(() => _showGhostGuide = !_showGhostGuide),
              ),
              _hudIconBtn(
                icon: CupertinoIcons.compass,
                active: gyroLive,
                tooltip: 'Kalibrasi Gyroscope 0°',
                onTap: _calibrateGyro,
              ),
              _hudIconBtn(
                icon: CupertinoIcons.arrow_clockwise,
                active: false,
                tooltip: 'Ulangi Cangkir',
                onTap: _resetSession,
              ),
            ],
          ),
        ),
        if (!isLandscape && !_isInspectingResult) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isFloat
                            ? const Color(0xFF0F766E)
                            : const Color(0xFFC2410C))
                        .withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isFloat
                        ? 'FLOAT • ${_cfd.pourHeightCm.toStringAsFixed(1)}cm'
                        : 'DIVE • ${_cfd.pourHeightCm.toStringAsFixed(1)}cm',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_cfd.cupFillPct / 100.0).clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: Colors.black38,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _cfd.spilled
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFFBBF24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${_cfd.cupFillPct.round()}%',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _hudIconBtn({
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

  /// Ergonomic Vertical Frosted Capsule Slider (matching reference video `1s-89s`!).
  Widget _buildVerticalPourCapsule(bool isLandscape) {
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top "Tuang" pill
          _capsulePill(
            label: 'Tuang',
            onTap: () => setState(() => _pourLever = 0.72),
          ),
          const SizedBox(height: 5),

          // Main Vertical Drag Track
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: isLandscape ? 170 : 250,
                minHeight: 110,
              ),
              child: LayoutBuilder(
                builder: (ctx, box) {
                  void updateFromLocalY(double dy) {
                    // Top = 1.0 (Low Float Full Pour), Bottom = 0.0 (Stop)
                    final double norm =
                        (1.0 - (dy / box.maxHeight)).clamp(0.0, 1.0);
                    setState(() => _pourLever = norm);
                  }

                  final double knobTop =
                      (1.0 - _pourLever) * (box.maxHeight - 44.0);

                  return GestureDetector(
                    onVerticalDragStart: (d) =>
                        updateFromLocalY(d.localPosition.dy),
                    onVerticalDragUpdate: (d) =>
                        updateFromLocalY(d.localPosition.dy),
                    onTapDown: (d) => updateFromLocalY(d.localPosition.dy),
                    child: Container(
                      width: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFFFFFFF).withValues(alpha: 0.85),
                            const Color(0xFFD6C7B8).withValues(alpha: 0.65),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.65),
                          width: 1.4,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            top: knobTop.clamp(2.0, box.maxHeight - 44.0),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E3A8A),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.coffee_rounded,
                                color: Colors.white,
                                size: 19,
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
          const SizedBox(height: 5),

          // Stop pill
          _capsulePill(
            label: 'Stop',
            onTap: () => setState(() => _pourLever = 0.0),
          ),
          const SizedBox(height: 4),

          // Left / Right Hand Swap pill (`⇄ Kiri/Kanan` just like reference video!)
          _capsulePill(
            label: _controlsOnLeft ? '⇄ Kanan' : '⇄ Kiri',
            onTap: () => setState(() => _controlsOnLeft = !_controlsOnLeft),
          ),
        ],
      ),
    );
  }

  Widget _capsulePill({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 4.5, horizontal: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFE8).withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9.2,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFloatingBar() {
    final double flow = _cfd.pitcherSlosh.currentFlowMlS;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Live Step-by-Step Barista Movement Coaching Banner
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
                  _cfd.coachingHintFor(_targetPattern),
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

        // 2. Precision Analog Joystick + Milk Physics Telemetry + Dive/Float/Cut Controls
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
              if (_controlsOnLeft) ...[
                BaristaPrecisionJoystick(
                  controller: _joystick,
                  size: 104,
                  label: 'ARAH PITCHER',
                  onRecenter: () => setState(() {
                    _cfd.pourPos = const Offset(0.0, 0.04);
                  }),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Live Milk Debit, Cup Fill & Pitcher Volume Telemetry
                    Row(
                      children: [
                        _latteHudMetric(
                          'Debit',
                          '${flow.toStringAsFixed(1)}/s',
                          const Color(0xFF34D399),
                        ),
                        _latteHudMetric(
                          'Cangkir',
                          '${_cfd.cupVolumeMl.toStringAsFixed(0)}/${_cfd.cupCapacityMl.toInt()}',
                          const Color(0xFFFDE68A),
                        ),
                        _latteHudMetric(
                          'Pitcher',
                          '${_cfd.pitcherSlosh.volumeMl.toStringAsFixed(0)}ml',
                          const Color(0xFF7DD3FC),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),

                    // Deliberate Height Toggle (Dive vs Float) + Cut
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _isLowFloatHeight = !_isLowFloatHeight);
                            },
                            borderRadius: BorderRadius.circular(11),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: _isLowFloatHeight
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFFC2410C),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Text(
                                _isLowFloatHeight
                                    ? '↓ Rendah (Float)'
                                    : '↑ Tinggi (Dive)',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10.4,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _isLowFloatHeight = false;
                              _cfd.pourHeightCm = 5.4;
                              _cfd.pourPos = Offset(
                                _cfd.pourPos.dx * 0.25,
                                (_cfd.pourPos.dy - 0.36).clamp(-0.75, 0.75),
                              );
                            });
                          },
                          borderRadius: BorderRadius.circular(11),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Text(
                              'Cut ↑',
                              style: TextStyle(
                                fontSize: 10.4,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Cup Color Swatches + Nilai WLAC CTA
                    Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: LatteCupColorTheme.values.map((theme) {
                            final sel = _cupTheme == theme;
                            return GestureDetector(
                              onTap: () => setState(() => _cupTheme = theme),
                              child: Container(
                                width: 15,
                                height: 15,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: theme.outerLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: sel ? Colors.white : Colors.white38,
                                    width: sel ? 2.0 : 1.0,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: InkWell(
                            onTap: _finishAndGrade,
                            borderRadius: BorderRadius.circular(11),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentAmber,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.checkmark_seal_fill,
                                    size: 13,
                                    color: AppTheme.textDark,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Nilai WLAC',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!_controlsOnLeft) ...[
                const SizedBox(width: 10),
                BaristaPrecisionJoystick(
                  controller: _joystick,
                  size: 104,
                  label: 'ARAH PITCHER',
                  onRecenter: () => setState(() {
                    _cfd.pourPos = const Offset(0.0, 0.04);
                  }),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _latteHudMetric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8.8, color: Colors.white70),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  /// Collector Score Card inspired by 16s-17s & 90s of reference video!
  Widget _buildCollectorResultCard(LatteArtWlacGrade grade) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 5 Ceramic Cup Color Swatches (change cup color live on finished art!)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: LatteCupColorTheme.values.map((theme) {
              final sel = _cupTheme == theme;
              return GestureDetector(
                onTap: () => setState(() => _cupTheme = theme),
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: theme.outerLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: sel ? 3.0 : 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            grade.overallScorePct.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '/ 100',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D4ED8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  grade.rankBadge,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ...List.generate(3, (i) {
                                return Icon(
                                  i < grade.stars
                                      ? CupertinoIcons.star_fill
                                      : CupertinoIcons.star,
                                  size: 15,
                                  color: i < grade.stars
                                      ? AppTheme.accentAmber
                                      : AppTheme.borderWarm,
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '「${_targetPattern.label}」',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18, color: AppTheme.dividerColor),

                // 4 WLAC Sub-Criteria Bars
                Row(
                  children: [
                    _subMetricBar('Presisi', grade.patternFidelityPct),
                    const SizedBox(width: 8),
                    _subMetricBar('Simetri', grade.symmetryPct),
                    const SizedBox(width: 8),
                    _subMetricBar('Kontras', grade.contrastPct),
                    const SizedBox(width: 8),
                    _subMetricBar(
                      'Volume',
                      grade.spilled ? 30 : grade.fillAccuracyPct,
                      overrideText: grade.spilled
                          ? 'Meluap'
                          : '${grade.fillAccuracyPct.round()}',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _isSharing ? null : () => _shareToSocial(grade),
                        icon: const Icon(
                          CupertinoIcons.paperplane_fill,
                          size: 14,
                        ),
                        label: const Text(
                          'Bagikan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBrown,
                          side: const BorderSide(color: AppTheme.borderWarm),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _resetSession,
                        icon: const Icon(
                          CupertinoIcons.arrow_clockwise,
                          size: 14,
                        ),
                        label: const Text(
                          'Tuang Lagi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _subMetricBar(
    String label,
    double pct, {
    String? overrideText,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9.8, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            overrideText ?? '${pct.round()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100.0).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppTheme.borderWarm,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
            ),
          ),
        ],
      ),
    );
  }
}
