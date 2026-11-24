import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../services/social_service.dart';
import '../../../../theme/app_theme.dart';
import '../../data/game_brew_progress_service.dart';
import '../../domain/game_brew_studio_models.dart';
import '../../engine/latte_art_cfd_engine.dart';
import '../../widgets/transparent_glass_vessel_painter.dart';

/// Real-Time 2D Incompressible Navier-Stokes Latte Art 3D Studio Screen:
/// - Smooth GPU bicubic fluid texture decoded from `LatteArtCfdEngine`
/// - Transparent Borosilicate Glass Milk Pitcher (liquid milk + floating microfoam!)
/// - Ergonomic Left-Thumb Pour Height Control (Dive > 3.5cm vs Float <= 1.3cm)
/// - Gyroscope Wiggle + Touch Drag + Optional Target Ghost Guide + Wiggle Metronome
/// - Automated WLAC Pattern Grader + Share to Social Coffee!
class LatteArt3DStageScreen extends StatefulWidget {
  final GameBrewLevelSpec spec;

  const LatteArt3DStageScreen({super.key, required this.spec});

  @override
  State<LatteArt3DStageScreen> createState() => _LatteArt3DStageScreenState();
}

class _LatteArt3DStageScreenState extends State<LatteArt3DStageScreen> {
  late final LatteArtCfdEngine _cfd;
  final ValueNotifier<int> _frameTick = ValueNotifier<int>(0);
  Timer? _simTimer;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  ui.Image? _fluidImage;
  bool _decodingImage = false;
  bool _showGhostGuide = true;
  bool _useHardwareGyro = true;
  bool _gyroAvailable = false;
  double _deskPourTilt = 0.0; // 0..48 deg
  double _gyroWiggleVel = 0.0;
  double _liveRollDeg = 0.0;
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
    _initGyro();

    _simTimer = Timer.periodic(const Duration(milliseconds: 22), (_) {
      final double pitch = _deskPourTilt;
      final double roll = (_useHardwareGyro && _gyroAvailable) ? _liveRollDeg : 0.0;
      _cfd.step(
        dt: 0.022,
        pitchDeg: pitch,
        rollDeg: roll,
        wiggleAngularVel: _gyroWiggleVel,
      );
      _gyroWiggleVel *= 0.85;
      _decodeFluidFrame();
      _frameTick.value++;
    });
  }

  void _initGyro() {
    if (kIsWeb ||
        (!Platform.isAndroid && !Platform.isIOS) ||
        Platform.environment.containsKey('FLUTTER_TEST')) {
      _gyroAvailable = false;
      _useHardwareGyro = false;
      return;
    }
    try {
      _gyroSub = gyroscopeEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (e) {
          _gyroAvailable = true;
          _gyroWiggleVel = e.z.clamp(-6.0, 6.0);
          _liveRollDeg = (_liveRollDeg * 0.82 + e.z * 8.0).clamp(-35.0, 35.0);
        },
        onError: (_) => _gyroAvailable = false,
      );
    } catch (_) {
      _gyroAvailable = false;
      _useHardwareGyro = false;
    }
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
    _gyroSub?.cancel();
    _fluidImage?.dispose();
    _frameTick.dispose();
    super.dispose();
  }

  void _resetCup() {
    setState(() {
      _deskPourTilt = 0.0;
      _cfd.reset();
    });
    _decodeFluidFrame();
  }

  Future<void> _gradeAndShowResult() async {
    setState(() => _deskPourTilt = 0.0);
    final grade = _cfd.evaluateCup(_targetPattern);
    await GameBrewProgressService.recordRun(
      levelCode: widget.spec.code,
      stars: grade.stars,
      scorePct: grade.overallScorePct,
      metrics: grade.toMetricsMap(),
    );
    if (!mounted) return;
    _showWlacGradeDialog(grade);
  }

  Future<void> _shareWorkToSocialCoffee(LatteArtWlacGrade grade) async {
    setState(() => _isSharing = true);
    try {
      await SocialService.createPost(
        content:
            '🎨 Baru saja melukis ${_targetPattern.label} di Coffee Labs Latte Art 3D Simulator!\n'
            '• Skor WLAC: ${grade.overallScorePct.toStringAsFixed(1)}% (${'★' * grade.stars})\n'
            '• Symmetry: ${grade.symmetryPct.toStringAsFixed(0)}% | Contrast: ${grade.contrastPct.toStringAsFixed(0)}% | Fidelity: ${grade.patternFidelityPct.toStringAsFixed(0)}%\n'
            '#CoffeeLabs #LatteArt3D #GameBrew',
        tags: const ['LatteArt3D', 'GameBrew', 'WLAC'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF0F766E),
            content: Text('Karya Latte Art berhasil dibagikan ke Social Coffee!'),
          ),
        );
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showWlacGradeDialog(LatteArtWlacGrade grade) {
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
                  i < grade.stars
                      ? CupertinoIcons.star_fill
                      : CupertinoIcons.star,
                  color: i < grade.stars
                      ? AppTheme.accentAmber
                      : AppTheme.borderWarm,
                  size: 28,
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              'Skor WLAC: ${grade.overallScorePct.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              _targetPattern.label,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _gradeRow('Contrast & Definition (25%)', '${grade.contrastPct.toStringAsFixed(0)}%'),
            _gradeRow('Bilateral Symmetry (25%)', '${grade.symmetryPct.toStringAsFixed(0)}%'),
            _gradeRow('Pattern Fidelity (35%)', '${grade.patternFidelityPct.toStringAsFixed(0)}%'),
            _gradeRow(
              'Cup Fill & Zero-Spill (15%)',
              grade.spilled
                  ? 'Tumpah!'
                  : '${grade.fillAccuracyPct.toStringAsFixed(0)}%',
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSharing
                ? null
                : () {
                    Navigator.pop(ctx);
                    _shareWorkToSocialCoffee(grade);
                  },
            icon: const Icon(CupertinoIcons.paperplane_fill, size: 14),
            label: const Text('Bagikan'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetCup();
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

  Widget _gradeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.8, color: AppTheme.textMuted),
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
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.spec.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              'Navier-Stokes CFD • ${_targetPattern.label}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBrown,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Panduan Ghost Siluet',
            icon: Icon(
              CupertinoIcons.sparkles,
              color: _showGhostGuide ? AppTheme.primaryBrown : AppTheme.textMuted,
              size: 20,
            ),
            onPressed: () => setState(() => _showGhostGuide = !_showGhostGuide),
          ),
          IconButton(
            tooltip: 'Reset Cangkir',
            icon: const Icon(
              CupertinoIcons.arrow_clockwise,
              color: AppTheme.textDark,
              size: 19,
            ),
            onPressed: _resetCup,
          ),
        ],
      ),
      body: RepaintBoundary(
        child: ValueListenableBuilder<int>(
          valueListenable: _frameTick,
          builder: (context, _, _) {
            final double alphaFloat = _cfd.computeFloatFactor(
              _cfd.pourHeightCm,
              _cfd.pitcherSlosh.currentFlowMlS,
            );
            final bool isFloatingFoam = alphaFloat >= 0.45;
            final double wiggleHz = _targetPattern.recommendedWiggleHz;
            final double metroPulse = wiggleHz > 0
                ? (0.5 + 0.5 * math.sin(_cfd.elapsedSec * wiggleHz * math.pi * 2))
                : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Live Dive vs Float Status & Cup Fill Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderWarm),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isFloatingFoam
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isFloatingFoam
                                ? 'FLOAT (POLA FOAM)'
                                : 'DIVE (KANVAS CREMA)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isFloatingFoam
                                  ? const Color(0xFF0F766E)
                                  : const Color(0xFFC2410C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_cfd.cupVolumeMl.toStringAsFixed(0)} / ${_cfd.cupCapacityMl.toInt()} ml (${_cfd.cupFillPct.round()}%)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: _cfd.spilled
                                      ? const Color(0xFFB91C1C)
                                      : AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (_cfd.cupFillPct / 100.0).clamp(0.0, 1.0),
                                  minHeight: 5,
                                  backgroundColor: AppTheme.bgCream,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _cfd.spilled
                                        ? const Color(0xFFB91C1C)
                                        : AppTheme.primaryBrown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Main 3D Latte Cup CFD Stage + Transparent Glass Milk Pitcher
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderWarm),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 235,
                          child: Row(
                            children: [
                              // Interactive Ceramic Latte Cup (60 FPS Navier-Stokes!)
                              Expanded(
                                flex: 7,
                                child: LayoutBuilder(
                                  builder: (ctx, box) {
                                    void updatePourPoint(Offset local, {Offset? delta}) {
                                      final double cx = box.maxWidth * 0.5;
                                      final double cy = box.maxHeight * 0.5;
                                      final double r =
                                          math.min(box.maxWidth, box.maxHeight) * 0.43;
                                      _cfd.pourPos = Offset(
                                        ((local.dx - cx) / r).clamp(-0.78, 0.78),
                                        ((local.dy - cy) / r).clamp(-0.78, 0.78),
                                      );
                                      if (delta != null) {
                                        _gyroWiggleVel =
                                            (delta.dx * 0.35).clamp(-5.0, 5.0);
                                      }
                                    }

                                    return GestureDetector(
                                      onTapDown: (d) =>
                                          updatePourPoint(d.localPosition),
                                      onPanStart: (d) =>
                                          updatePourPoint(d.localPosition),
                                      onPanUpdate: (d) => updatePourPoint(
                                        d.localPosition,
                                        delta: d.delta,
                                      ),
                                      child: CustomPaint(
                                        size: Size(box.maxWidth, box.maxHeight),
                                        painter: _LatteCupCfdPainter(
                                          fluidImage: _fluidImage,
                                          pourPos: _cfd.pourPos,
                                          isPouring:
                                              _cfd.pitcherSlosh.currentFlowMlS > 0.25,
                                          isFloatingFoam: isFloatingFoam,
                                          showGhostGuide: _showGhostGuide,
                                          targetPattern: _targetPattern,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Transparent Glass Milk Pitcher (Milk + Floating Microfoam!)
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: CustomPaint(
                                        size: const Size(
                                          double.infinity,
                                          double.infinity,
                                        ),
                                        painter: TransparentGlassVesselPainter(
                                          isMilkPitcher: true,
                                          fillFraction:
                                              _cfd.pitcherSlosh.fillFraction,
                                          capacityMl: _cfd.pitcherSlosh.capacityMl,
                                          remainingMl: _cfd.pitcherSlosh.volumeMl,
                                          tiltAngleRad:
                                              _deskPourTilt * (math.pi / 180.0),
                                          sloshAngleRad: _cfd.pitcherSlosh.psiXRad,
                                          wavePhase: _cfd.pitcherSlosh.wavePhase,
                                          flowRateMlS:
                                              _cfd.pitcherSlosh.currentFlowMlS,
                                          foamLayerFraction:
                                              0.28 * _cfd.milkFoamRemainingFraction,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Susu ${_cfd.pitcherSlosh.volumeMl.round()}ml',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (wiggleHz > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.lerp(
                                    AppTheme.borderWarm,
                                    const Color(0xFF0F766E),
                                    metroPulse,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Metronom Wiggle: ${wiggleHz.toStringAsFixed(1)} Hz — goyang kiri-kanan berirama',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Ergonomic Controls: Pour Height (Dive <-> Float) & Pour Flow + Wiggle Trigger
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.borderWarm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _targetPattern.techniqueGuide,
                          style: const TextStyle(
                            fontSize: 11.2,
                            color: AppTheme.textMuted,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Pour Height Control (Dive > 3.5 cm <-> Float <= 1.3 cm)
                        Row(
                          children: [
                            const Text(
                              'Tinggi Pitcher',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: _cfd.pourHeightCm,
                                min: 0.6,
                                max: 7.5,
                                activeColor: isFloatingFoam
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFFC2410C),
                                onChanged: (v) =>
                                    setState(() => _cfd.pourHeightCm = v),
                              ),
                            ),
                            Text(
                              '${_cfd.pourHeightCm.toStringAsFixed(1)} cm',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isFloatingFoam
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFFC2410C),
                              ),
                            ),
                          ],
                        ),

                        // Pour Tilt / Flow Slider
                        Row(
                          children: [
                            const Text(
                              'Tuang Susu',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: _deskPourTilt,
                                min: 0.0,
                                max: 48.0,
                                activeColor: AppTheme.primaryBrown,
                                onChanged: (v) =>
                                    setState(() => _deskPourTilt = v),
                              ),
                            ),
                            Text(
                              '${_cfd.pitcherSlosh.currentFlowMlS.toStringAsFixed(1)} ml/s',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  // Quick Pull-Through Cut preset (raises pitcher + forward sweep)
                                  setState(() {
                                    _cfd.pourHeightCm = 5.2;
                                    _cfd.pourPos = Offset(
                                      _cfd.pourPos.dx * 0.3,
                                      (_cfd.pourPos.dy - 0.35).clamp(-0.75, 0.75),
                                    );
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryBrown,
                                  side: const BorderSide(
                                    color: AppTheme.primaryBrown,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Pull-Through Cut',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _gradeAndShowResult,
                                icon: const Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 15,
                                ),
                                label: const Text(
                                  'Nilai WLAC',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.8,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBrown,
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
          },
        ),
      ),
    );
  }
}

class _LatteCupCfdPainter extends CustomPainter {
  final ui.Image? fluidImage;
  final Offset pourPos;
  final bool isPouring;
  final bool isFloatingFoam;
  final bool showGhostGuide;
  final LatteArtPattern targetPattern;

  const _LatteCupCfdPainter({
    required this.fluidImage,
    required this.pourPos,
    required this.isPouring,
    required this.isFloatingFoam,
    required this.showGhostGuide,
    required this.targetPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final double cupOuterR = math.min(size.width, size.height) * 0.45;
    final double liquidR = cupOuterR * 0.87;

    // 1. Ceramic Cup Handle (Right Side)
    final handleRect = Rect.fromCenter(
      center: Offset(center.dx + cupOuterR + 4, center.dy),
      width: 24,
      height: 30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(10)),
      Paint()
        ..color = const Color(0xFFE7DFD6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0,
    );

    // 2. Soft Ceramic Cup Shadow + Matte White Rim
    canvas.drawCircle(
      center + const Offset(0, 6),
      cupOuterR,
      Paint()..color = AppTheme.primaryBrown.withValues(alpha: 0.14),
    );
    canvas.drawCircle(
      center,
      cupOuterR,
      Paint()..color = const Color(0xFFFAF8F5),
    );
    canvas.drawCircle(
      center,
      cupOuterR,
      Paint()
        ..color = AppTheme.borderWarm
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // 3. Live 2D Navier-Stokes Crema + Microfoam Texture!
    final liquidRect = Rect.fromCircle(center: center, radius: liquidR);
    canvas.save();
    canvas.clipPath(Path()..addOval(liquidRect));

    if (fluidImage != null) {
      canvas.drawImageRect(
        fluidImage!,
        Rect.fromLTWH(
          0,
          0,
          fluidImage!.width.toDouble(),
          fluidImage!.height.toDouble(),
        ),
        liquidRect,
        Paint()..filterQuality = FilterQuality.high,
      );
    } else {
      canvas.drawCircle(center, liquidR, Paint()..color = const Color(0xFF7C431C));
    }

    // 4. Optional Translucent Target Ghost Guide
    if (showGhostGuide) {
      _drawGhostSilhouette(canvas, center, liquidR);
    }

    // 5. Active Milk Stream Touch Point & Ripple
    final streamPt = Offset(
      center.dx + pourPos.dx * liquidR,
      center.dy + pourPos.dy * liquidR,
    );
    if (isPouring) {
      canvas.drawCircle(
        streamPt,
        isFloatingFoam ? 13.0 : 8.0,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
    canvas.drawCircle(
      streamPt,
      isPouring ? 5.5 : 4.5,
      Paint()..color = isFloatingFoam ? Colors.white : const Color(0xFFFDE68A),
    );
    canvas.drawCircle(
      streamPt,
      isPouring ? 5.5 : 4.5,
      Paint()
        ..color = AppTheme.primaryBrown.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    canvas.restore();
  }

  void _drawGhostSilhouette(Canvas canvas, Offset c, double r) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    switch (targetPattern) {
      case LatteArtPattern.canvasBase:
        canvas.drawCircle(c, r * 0.28, p);
        break;
      case LatteArtPattern.monksHead:
        canvas.drawCircle(c, r * 0.42, p);
        break;
      case LatteArtPattern.heart:
        final path = Path()
          ..moveTo(c.dx, c.dy + r * 0.48)
          ..cubicTo(
            c.dx - r * 0.62,
            c.dy + r * 0.08,
            c.dx - r * 0.45,
            c.dy - r * 0.48,
            c.dx,
            c.dy - r * 0.16,
          )
          ..cubicTo(
            c.dx + r * 0.45,
            c.dy - r * 0.48,
            c.dx + r * 0.62,
            c.dy + r * 0.08,
            c.dx,
            c.dy + r * 0.48,
          );
        canvas.drawPath(path, p);
        break;
      case LatteArtPattern.twoStackTulip:
      case LatteArtPattern.threeStackTulip:
      case LatteArtPattern.wingedFiveTulip:
      case LatteArtPattern.wingedBase:
        canvas.drawArc(
          Rect.fromCenter(center: c + Offset(0, r * 0.08), width: r * 1.1, height: r * 0.72),
          0.1,
          math.pi - 0.2,
          false,
          p,
        );
        canvas.drawCircle(c - Offset(0, r * 0.18), r * 0.22, p);
        break;
      case LatteArtPattern.rosetta:
      case LatteArtPattern.slowsetta:
        canvas.drawLine(c + Offset(0, r * 0.55), c - Offset(0, r * 0.52), p);
        for (int i = -2; i <= 2; i++) {
          final double y = c.dy + i * (r * 0.18);
          final double w = r * (0.42 - (i.abs() * 0.06));
          canvas.drawOval(
            Rect.fromCenter(center: Offset(c.dx, y), width: w * 2, height: r * 0.14),
            p,
          );
        }
        break;
      case LatteArtPattern.swan:
        // Wing + S-neck + Head
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(r * 0.18, r * 0.16),
            width: r * 0.78,
            height: r * 0.45,
          ),
          p,
        );
        final neck = Path()
          ..moveTo(c.dx - r * 0.18, c.dy + r * 0.25)
          ..cubicTo(
            c.dx - r * 0.35,
            c.dy - r * 0.05,
            c.dx + r * 0.05,
            c.dy - r * 0.25,
            c.dx - r * 0.12,
            c.dy - r * 0.48,
          );
        canvas.drawPath(neck, p);
        canvas.drawCircle(c + Offset(-r * 0.14, -r * 0.52), r * 0.11, p);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _LatteCupCfdPainter oldDelegate) => true;
}
