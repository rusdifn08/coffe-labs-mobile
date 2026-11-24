import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../theme/app_theme.dart';
import '../../data/game_brew_progress_service.dart';
import '../../domain/game_brew_studio_models.dart';
import '../../engine/manual_brew_3d_physics_engine.dart';
import '../../widgets/transparent_glass_vessel_painter.dart';

/// Interactive 5-Phase Manual Brew 3D Studio Screen:
/// 1. Wet Paper Filter (>=95%) & Rinse Discard
/// 2. RDT Micro-Mist Spritz (1-2x optimal)
/// 3. Dosing & Finger Center Divot Sculpting (4-9 mm)
/// 4. Precision Gyroscope / Desk Pouring with Transparent Borosilicate Kettle,
///    Pattern Trajectory Guides (Circular CW, Reverse CCW, Zigzag, Center, Pulse 4:6),
///    Rayleigh-Plateau Height Monitor & Dry-Spot Wetness Heatmap!
/// 5. Gentle Rao Swirl & Scientific EY% / TDS% Scorecard!
class ManualBrew3DStageScreen extends StatefulWidget {
  final GameBrewLevelSpec spec;

  const ManualBrew3DStageScreen({super.key, required this.spec});

  @override
  State<ManualBrew3DStageScreen> createState() =>
      _ManualBrew3DStageScreenState();
}

class _ManualBrew3DStageScreenState extends State<ManualBrew3DStageScreen> {
  late final ManualBrew3DPhysicsEngine _engine;
  final ValueNotifier<int> _frameTick = ValueNotifier<int>(0);
  Timer? _loopTimer;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  bool _useHardwareGyro = true;
  bool _gyroAvailable = false;
  double _tarePitchDeg = 0.0;
  double _livePitchDeg = 0.0;
  double _liveRollDeg = 0.0;
  double _deskTiltSlider = 0.0; // 0..52 deg
  bool _showWetnessHeatmap = true;
  bool _showPatternGuide = true;

  @override
  void initState() {
    super.initState();
    _engine = ManualBrew3DPhysicsEngine(spec: widget.spec);
    _initSensors();
    _loopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final double pitch =
          (_useHardwareGyro && _gyroAvailable) ? _livePitchDeg : _deskTiltSlider;
      final double roll = (_useHardwareGyro && _gyroAvailable) ? _liveRollDeg : 0.0;
      _engine.step(dt: 0.016, pitchDeg: pitch, rollDeg: roll);
      _frameTick.value++;
    });
  }

  void _initSensors() {
    if (kIsWeb ||
        (!Platform.isAndroid && !Platform.isIOS) ||
        Platform.environment.containsKey('FLUTTER_TEST')) {
      _gyroAvailable = false;
      _useHardwareGyro = false;
      return;
    }
    try {
      _accelSub = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        (e) {
          _gyroAvailable = true;
          final double rawPitch =
              math.atan2(e.z, math.sqrt(e.x * e.x + e.y * e.y)) *
                  (180.0 / math.pi);
          final double rawRoll =
              math.atan2(e.x, e.y.abs() + 0.1) * (180.0 / math.pi);
          _livePitchDeg = (rawPitch - _tarePitchDeg).clamp(0.0, 56.0);
          _liveRollDeg = rawRoll.clamp(-45.0, 45.0);
        },
        onError: (_) => _gyroAvailable = false,
      );
    } catch (_) {
      _gyroAvailable = false;
      _useHardwareGyro = false;
    }
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _accelSub?.cancel();
    _frameTick.dispose();
    super.dispose();
  }

  void _calibrateGyroZero() {
    setState(() {
      _tarePitchDeg += _livePitchDeg;
      _livePitchDeg = 0.0;
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Posisi HP dikalibrasi 0°! Miringkan perlahan untuk menuang.'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryBrown,
      ),
    );
  }

  void _resetSession() {
    setState(() {
      _deskTiltSlider = 0.0;
      _engine.reset();
    });
  }

  Future<void> _finishBrewAndSave() async {
    final res = _engine.finishAndEvaluate();
    setState(() {
      _deskTiltSlider = 0.0;
    });
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
              'Skor Seduh: ${overall.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 18,
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
            _scoreRow(
              'Extraction Yield (EY%)',
              '${(res['eyPct'] ?? 0).toStringAsFixed(1)}% (Ideal 18–22%)',
            ),
            _scoreRow('TDS%', '${(res['tdsPct'] ?? 0).toStringAsFixed(2)}%'),
          ],
        ),
        actions: [
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
      padding: const EdgeInsets.symmetric(vertical: 3.5),
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
              pattern.label,
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
            tooltip: 'Kalibrasi Posisi HP (0°)',
            icon: const Icon(CupertinoIcons.compass, color: AppTheme.primaryBrown, size: 20),
            onPressed: _calibrateGyroZero,
          ),
          IconButton(
            tooltip: 'Reset Sesi',
            icon: const Icon(CupertinoIcons.arrow_clockwise, color: AppTheme.textDark, size: 19),
            onPressed: _resetSession,
          ),
        ],
      ),
      body: RepaintBoundary(
        child: ValueListenableBuilder<int>(
          valueListenable: _frameTick,
          builder: (context, _, _) {
            final double activePitch = (_useHardwareGyro && _gyroAvailable)
                ? _livePitchDeg
                : _deskTiltSlider;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. 5-Phase Barista Ritual Progress Strip
                  _buildPhaseStepper(),
                  const SizedBox(height: 10),

                  // 2. Live 3D Stage: V60 Cone + Transparent Glass Borosilicate Kettle
                  _buildStageArena(activePitch: activePitch, pattern: pattern),
                  const SizedBox(height: 10),

                  // 3. Telemetry Strip (Hidden ml numbers in Blind WBrC Lv.10!)
                  _buildTelemetryStrip(),
                  const SizedBox(height: 10),

                  // 4. Phase-Specific Interactive Controls
                  _buildPhaseControls(pattern),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhaseStepper() {
    const phases = [
      (ManualBrewPhase.wetFilter, '1. Filter'),
      (ManualBrewPhase.rdtSpritz, '2. RDT'),
      (ManualBrewPhase.doseAndDivot, '3. Divot'),
      (ManualBrewPhase.precisionPour, '4. Tuang'),
      (ManualBrewPhase.swirlAndResult, '5. Swirl'),
    ];
    final currentIdx = ManualBrewPhase.values.indexOf(_engine.phase);

    return Row(
      children: phases.asMap().entries.map((entry) {
        final idx = entry.key;
        final label = entry.value.$2;
        final isActive = idx == currentIdx;
        final isDone = idx < currentIdx;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: idx == phases.length - 1 ? 0 : 4),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryBrown
                  : (isDone ? const Color(0xFFECFDF5) : Colors.white),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isActive
                    ? AppTheme.primaryBrown
                    : (isDone
                        ? const Color(0xFF0F766E).withValues(alpha: 0.4)
                        : AppTheme.borderWarm),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: isActive
                    ? Colors.white
                    : (isDone ? const Color(0xFF0F766E) : AppTheme.textMuted),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStageArena({
    required double activePitch,
    required ManualPourPattern pattern,
  }) {
    return Container(
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
          // Top Mode Toggles (Heatmap / Pattern Guide / Gyro vs Desk)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _miniToggle(
                label: 'Heatmap Basah',
                active: _showWetnessHeatmap,
                onTap: () =>
                    setState(() => _showWetnessHeatmap = !_showWetnessHeatmap),
              ),
              _miniToggle(
                label: 'Panduan Pola',
                active: _showPatternGuide,
                onTap: () =>
                    setState(() => _showPatternGuide = !_showPatternGuide),
              ),
              _miniToggle(
                label: (_useHardwareGyro && _gyroAvailable)
                    ? 'Gyro 200Hz'
                    : 'Mode Meja',
                active: _useHardwareGyro && _gyroAvailable,
                onTap: () =>
                    setState(() => _useHardwareGyro = !_useHardwareGyro),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Interactive Canvas: Left = V60 Top-Down 3D Bed, Right = Transparent Glass Kettle
          SizedBox(
            height: 225,
            child: Row(
              children: [
                // Interactive V60 Cone & Coffee Bed
                Expanded(
                  flex: 6,
                  child: LayoutBuilder(
                    builder: (ctx, box) {
                      void handleTouch(Offset localPos) {
                        final double cx = box.maxWidth * 0.5;
                        final double cy = box.maxHeight * 0.5;
                        final double radius =
                            math.min(box.maxWidth, box.maxHeight) * 0.44;
                        final double nx =
                            ((localPos.dx - cx) / radius).clamp(-0.95, 0.95);
                        final double ny =
                            ((localPos.dy - cy) / radius).clamp(-0.95, 0.95);
                        final norm = Offset(nx, ny);
                        if (_engine.phase == ManualBrewPhase.doseAndDivot) {
                          _engine.sculptDivotAt(norm);
                          HapticFeedback.selectionClick();
                        } else {
                          _engine.aimPos = norm;
                        }
                      }

                      return GestureDetector(
                        onTapDown: (d) => handleTouch(d.localPosition),
                        onPanStart: (d) => handleTouch(d.localPosition),
                        onPanUpdate: (d) => handleTouch(d.localPosition),
                        child: CustomPaint(
                          size: Size(box.maxWidth, box.maxHeight),
                          painter: _V60TopDownBedPainter(
                            engine: _engine,
                            pattern: pattern,
                            showHeatmap: _showWetnessHeatmap,
                            showPatternGuide: _showPatternGuide,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 6),

                // Transparent Borosilicate Gooseneck Kettle (Real 2-Axis Sloshing!)
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          size: const Size(double.infinity, double.infinity),
                          painter: TransparentGlassVesselPainter(
                            isMilkPitcher: false,
                            fillFraction: _engine.kettleSlosh.fillFraction,
                            capacityMl: _engine.kettleSlosh.capacityMl,
                            remainingMl: _engine.kettleSlosh.volumeMl,
                            tiltAngleRad: activePitch * (math.pi / 180.0),
                            sloshAngleRad: _engine.kettleSlosh.psiXRad,
                            wavePhase: _engine.kettleSlosh.wavePhase,
                            flowRateMlS: _engine.kettleSlosh.currentFlowMlS,
                          ),
                        ),
                      ),
                      Text(
                        'Ketel Kaca ${_engine.kettleSlosh.volumeMl.round()} ml',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.8,
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

          if (_engine.isRayleighBreakup) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFB91C1C).withValues(alpha: 0.35),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle_fill,
                    size: 14,
                    color: Color(0xFFB91C1C),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rayleigh-Plateau Breakup! Turunkan tinggi tuang (< 11 cm) agar aliran laminar.',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniToggle({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBrown : AppTheme.bgCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppTheme.primaryBrown : AppTheme.borderWarm,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryStrip() {
    final bool blind = widget.spec.blindScaleMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Row(
        children: [
          _metricCell(
            'Air Tuang',
            blind
                ? 'BLIND'
                : '${_engine.pouredCoffeeWaterMl.toStringAsFixed(0)}/${widget.spec.targetWaterMl.toInt()} ml',
            AppTheme.primaryBrown,
          ),
          _metricCell(
            'Debit',
            '${_engine.kettleSlosh.currentFlowMlS.toStringAsFixed(1)} ml/s',
            const Color(0xFF0F766E),
          ),
          _metricCell(
            'Basah',
            '${_engine.wettingCoveragePct.toStringAsFixed(0)}%',
            const Color(0xFF0369A1),
          ),
          _metricCell(
            'Pola',
            '${_engine.patternAccuracyPct.toStringAsFixed(0)}%',
            const Color(0xFFB45309),
          ),
        ],
      ),
    );
  }

  Widget _metricCell(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
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

  Widget _buildPhaseControls(ManualPourPattern pattern) {
    switch (_engine.phase) {
      case ManualBrewPhase.wetFilter:
        return _controlCard(
          title: 'Fase 1: Basahi Kertas Filter & Buang Air Bilasan',
          hint:
              'Geser slider tuang & putar jari di V60 sampai kertas basah ≥ 95% (${_engine.paperWetnessPct.toStringAsFixed(0)}%, Server ${_engine.serverTempC.toStringAsFixed(0)}°C).',
          child: Column(
            children: [
              _tiltSliderWidget(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _engine.isFilterReadyToDiscard
                      ? () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _deskTiltSlider = 0.0;
                            _engine.discardRinseWater();
                          });
                        }
                      : null,
                  icon: const Icon(CupertinoIcons.checkmark_circle_fill, size: 16),
                  label: Text(
                    _engine.isFilterReadyToDiscard
                        ? 'Buang Air Bilasan & Lanjut ke RDT'
                        : 'Basahi Kertas Filter (${_engine.paperWetnessPct.toStringAsFixed(0)}% / 95%)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
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
        );

      case ManualBrewPhase.rdtSpritz:
        return _controlCard(
          title: 'Fase 2: RDT (Ross Droplet Technique)',
          hint:
              'Semprot 1–2× micro-mist ke biji kopi sebelum giling untuk memangkas fines statis 22%. Status: ${_engine.rdtStatusLabel}',
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _engine.spritzRdt());
                  },
                  icon: const Icon(CupertinoIcons.drop_fill, size: 15),
                  label: Text('Semprot RDT (${_engine.rdtSpritzCount}×)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0369A1),
                    side: const BorderSide(color: Color(0xFF0369A1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      setState(() => _engine.completeRdtAndMoveToDosing()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Giling & Lanjut'),
                ),
              ),
            ],
          ),
        );

      case ManualBrewPhase.doseAndDivot:
        return _controlCard(
          title: 'Fase 3: Tuang Bubuk & Center Divot',
          hint:
              'Tekan jari beberapa kali di pusat V60 di atas untuk membentuk lubang tengah 4–9 mm (Saat ini: ${_engine.centerDivotDepthMm.toStringAsFixed(1)} mm).',
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _engine.sculptDivotAt(Offset.zero));
                  },
                  icon: const Icon(CupertinoIcons.circle, size: 15),
                  label: Text('Tekan Divot (${_engine.centerDivotDepthMm.toStringAsFixed(1)}mm)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                    side: const BorderSide(color: AppTheme.primaryBrown),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      setState(() => _engine.finishDosingAndStartPouring()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Mulai Tuang 3D'),
                ),
              ),
            ],
          ),
        );

      case ManualBrewPhase.precisionPour:
      case ManualBrewPhase.swirlAndResult:
        return _controlCard(
          title: 'Fase 4–5: ${pattern.shortLabel} & Rao Swirl',
          hint: pattern.guideHint,
          child: Column(
            children: [
              _tiltSliderWidget(),
              const SizedBox(height: 6),
              // Pour Height Slider (Rayleigh-Plateau control)
              Row(
                children: [
                  const Text(
                    'Tinggi Ketel',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _engine.pourHeightCm,
                      min: 4.0,
                      max: 14.0,
                      activeColor: _engine.pourHeightCm > 11.0
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF0F766E),
                      onChanged: (v) =>
                          setState(() => _engine.pourHeightCm = v),
                    ),
                  ),
                  Text(
                    '${_engine.pourHeightCm.toStringAsFixed(1)} cm',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _engine.pourHeightCm > 11.0
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _engine.applyGentleRaoSwirl());
                      },
                      icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 15),
                      label: Text(
                        'Rao Swirl (${_engine.flatBedScorePct.round()}%)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F766E),
                        side: const BorderSide(color: Color(0xFF0F766E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _finishBrewAndSave,
                      icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 15),
                      label: const Text(
                        'Selesai & Nilai',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
        );
    }
  }

  Widget _tiltSliderWidget() {
    return Row(
      children: [
        const Text(
          'Tuang Ketel',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        Expanded(
          child: Slider(
            value: _deskTiltSlider,
            min: 0.0,
            max: 52.0,
            activeColor: AppTheme.primaryBrown,
            onChanged: (v) {
              setState(() {
                _useHardwareGyro = false;
                _deskTiltSlider = v;
              });
            },
          ),
        ),
        Text(
          '${_deskTiltSlider.round()}°',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryBrown,
          ),
        ),
      ],
    );
  }

  Widget _controlCard({
    required String title,
    required String hint,
    required Widget child,
  }) {
    return Container(
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
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 11.2,
              color: AppTheme.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Top-down 3D V60 cone painter showing wet paper segments, 32x32 coffee bed
/// heightfield & center divot, wetness heatmap, and live pattern guide paths
/// (Circular CW, Reverse Circular CCW, Zigzag, Center Osmotic, Pulse 4:6).
class _V60TopDownBedPainter extends CustomPainter {
  final ManualBrew3DPhysicsEngine engine;
  final ManualPourPattern pattern;
  final bool showHeatmap;
  final bool showPatternGuide;

  const _V60TopDownBedPainter({
    required this.engine,
    required this.pattern,
    required this.showHeatmap,
    required this.showPatternGuide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final double outerR = math.min(size.width, size.height) * 0.45;
    final double bedR = outerR * 0.78;

    // 1. Ceramic V60 Cone Rim & Spiral Ribs
    canvas.drawCircle(
      center,
      outerR,
      Paint()..color = const Color(0xFFF3ECE4),
    );
    canvas.drawCircle(
      center,
      outerR,
      Paint()
        ..color = AppTheme.borderWarm
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    // 2. 36-Segment Paper Filter Saturation Ring (Dry White -> Translucent Wet Cream)
    final double sweep = (math.pi * 2.0) / ManualBrew3DPhysicsEngine.filterSegments;
    for (int i = 0; i < ManualBrew3DPhysicsEngine.filterSegments; i++) {
      final double w = engine.filterWetness[i].clamp(0.0, 1.0);
      final color = Color.lerp(
        const Color(0xFFFFFFFF),
        const Color(0xFFD6C3AD),
        w,
      )!;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerR - 6),
        i * sweep - math.pi,
        sweep + 0.02,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10.0,
      );
    }

    // 3. Coffee Grounds 32x32 Bed + Center Divot + Wetness Heatmap
    if (engine.groundsDosed ||
        engine.phase == ManualBrewPhase.precisionPour ||
        engine.phase == ManualBrewPhase.swirlAndResult) {
      final int g = ManualBrew3DPhysicsEngine.gridSize;
      final double cell = (bedR * 2.0) / g;

      for (int y = 0; y < g; y += 2) {
        for (int x = 0; x < g; x += 2) {
          final double nx = (x / (g - 1)) * 2.0 - 1.0;
          final double ny = (y / (g - 1)) * 2.0 - 1.0;
          if (nx * nx + ny * ny > 0.98) continue;

          final int idx = y * g + x;
          final double h = engine.bedHeight[idx];
          final double wet = engine.wetnessMap[idx];
          final double co2 = engine.co2Map[idx];

          // Dry coffee (#8B5A2B) -> Wet dark roast (#3D2212) + Golden CO2 Bloom Sheen
          Color c = Color.lerp(
            const Color(0xFF966336),
            const Color(0xFF3E2212),
            wet,
          )!;
          if (wet > 0.3 && co2 > 0.4) {
            c = Color.lerp(c, const Color(0xFFC58B4B), co2 * 0.42)!;
          }
          if (showHeatmap && engine.phase == ManualBrewPhase.precisionPour && wet < 0.7) {
            c = Color.lerp(c, const Color(0xFFF59E0B), 0.35)!;
          }
          // Height shading (Center Divot looks visibly recessed!)
          final double shade = (0.72 + h * 0.48).clamp(0.55, 1.15);
          c = Color.fromARGB(
            255,
            (c.r * 255 * shade).clamp(0, 255).toInt(),
            (c.g * 255 * shade).clamp(0, 255).toInt(),
            (c.b * 255 * shade).clamp(0, 255).toInt(),
          );

          final double px = center.dx + nx * bedR;
          final double py = center.dy + ny * bedR;
          canvas.drawRect(
            Rect.fromCenter(center: Offset(px, py), width: cell * 2.2, height: cell * 2.2),
            Paint()..color = c,
          );
        }
      }
    }

    // 4. Pattern Guide Overlay (Circular CW, Reverse CCW, Zigzag, Center, Pulse)
    if (showPatternGuide && engine.phase == ManualBrewPhase.precisionPour) {
      _drawPatternGuide(canvas, center, bedR);
    }

    // 5. Recent Pour Trail
    if (engine.recentPourTrail.length >= 2) {
      final trailPath = Path();
      for (int i = 0; i < engine.recentPourTrail.length; i++) {
        final pt = Offset(
          center.dx + engine.recentPourTrail[i].dx * bedR,
          center.dy + engine.recentPourTrail[i].dy * bedR,
        );
        if (i == 0) {
          trailPath.moveTo(pt.dx, pt.dy);
        } else {
          trailPath.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(
        trailPath,
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // 6. Active Stream Impact Marker
    final impact = Offset(
      center.dx + engine.aimPos.dx * bedR,
      center.dy + engine.aimPos.dy * bedR,
    );
    final bool pouring = engine.kettleSlosh.currentFlowMlS > 0.25;
    canvas.drawCircle(
      impact,
      pouring ? (engine.isRayleighBreakup ? 10.0 : 7.0) : 5.5,
      Paint()
        ..color = pouring
            ? (engine.isRayleighBreakup
                ? const Color(0xFFEF4444)
                : const Color(0xFF38BDF8))
            : AppTheme.accentAmber,
    );
    canvas.drawCircle(
      impact,
      2.5,
      Paint()..color = Colors.white,
    );
  }

  void _drawPatternGuide(Canvas canvas, Offset center, double r) {
    final guidePaint = Paint()
      ..color = AppTheme.accentGold.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    switch (pattern) {
      case ManualPourPattern.circularCw:
      case ManualPourPattern.reverseCircularCcw:
      case ManualPourPattern.spiralSwirl:
      case ManualPourPattern.pulse46:
        canvas.drawCircle(center, r * 0.42, guidePaint);
        canvas.drawCircle(center, r * 0.72, guidePaint);
        // Direction arrow on outer circle
        final bool ccw = pattern == ManualPourPattern.reverseCircularCcw;
        final arrowBase = Offset(center.dx, center.dy - r * 0.72);
        final dir = ccw ? -1.0 : 1.0;
        canvas.drawLine(
          arrowBase,
          arrowBase + Offset(-6 * dir, -5),
          guidePaint,
        );
        canvas.drawLine(
          arrowBase,
          arrowBase + Offset(-6 * dir, 5),
          guidePaint,
        );
        break;
      case ManualPourPattern.zigzag:
        final p = Path()
          ..moveTo(center.dx - r * 0.55, center.dy - r * 0.45)
          ..lineTo(center.dx + r * 0.55, center.dy - r * 0.22)
          ..lineTo(center.dx - r * 0.55, center.dy + r * 0.02)
          ..lineTo(center.dx + r * 0.55, center.dy + r * 0.25)
          ..lineTo(center.dx - r * 0.55, center.dy + r * 0.48);
        canvas.drawPath(p, guidePaint);
        break;
      case ManualPourPattern.centerOsmotic:
        canvas.drawCircle(center, r * 0.22, guidePaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _V60TopDownBedPainter oldDelegate) => true;
}
