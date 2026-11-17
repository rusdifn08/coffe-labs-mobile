import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../theme/app_theme.dart';
import '../../../data/barista_toolkit_api_service.dart';
import '../../../domain/barista_toolkit_models.dart';
import '../engine/v60_3d_scene_renderer.dart';
import '../widgets/kettle_tactical_hud.dart';
import '../widgets/v60_threejs_viewport.dart';

/// Layar Simulator Game Brew V60 3D Multi-Engine:
/// menggabungkan 6-DoF Gyroscope Kettle, Heightfield Bed 32x32 Darcy,
/// 3 sudut pandang kamera 3D (POV / X-Ray / 360° Orbit), dan pembinaan interaktif.
class GameBrew3DSimulatorScreen extends StatefulWidget {
  final GameBrewChapterModel chapter;
  final bool isSandboxMode;

  const GameBrew3DSimulatorScreen({
    super.key,
    required this.chapter,
    this.isSandboxMode = false,
  });

  @override
  State<GameBrew3DSimulatorScreen> createState() =>
      _GameBrew3DSimulatorScreenState();
}

class _GameBrew3DSimulatorScreenState extends State<GameBrew3DSimulatorScreen> {
  late V603DFlameSimulatorGame _game;
  final GlobalKey _viewportKey = GlobalKey();

  V603DCameraPerspective _cameraMode = V603DCameraPerspective.baristaPov;
  bool _useHardwareGyro = true;
  double _virtualTilt = 0.0;
  bool _showScienceNotes = false;
  bool _resultShown = false;
  bool _isInspecting3D = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _lastEvalResult;

  @override
  void initState() {
    super.initState();
    _game = _buildGameFromChapter(widget.chapter);
    _game.snapshotNotifier.addListener(_handleSnapshotUpdate);
  }

  V603DFlameSimulatorGame _buildGameFromChapter(GameBrewChapterModel ch) {
    final cfg = ch.physicsConfig;
    return V603DFlameSimulatorGame(
      doseG: (cfg['dose_g'] as num?)?.toDouble() ?? 15.0,
      targetWaterMl: (cfg['water_ml'] as num?)?.toDouble() ?? 225.0,
      bloomMl: (cfg['bloom_ml'] as num?)?.toDouble() ?? 45.0,
      bloomSec: (cfg['bloom_sec'] as num?)?.toDouble() ?? 35.0,
      initialTempC: (cfg['target_temp_c'] as num?)?.toDouble() ?? 92.0,
      dropTempC: (cfg['drop_temp_c'] as num?)?.toDouble(),
      dropAtMl: (cfg['drop_at_ml'] as num?)?.toDouble(),
      targetTimeSec: (cfg['target_time_sec'] as num?)?.toDouble() ?? 145.0,
      idealFlowMlS: (cfg['ideal_flow_ml_s'] as num?)?.toDouble() ?? 4.5,
    );
  }

  void _handleSnapshotUpdate() {
    final snap = _game.snapshotNotifier.value;
    if (snap.isCompleted && !_resultShown && mounted) {
      _resultShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _evaluateAndShowResult(snap);
      });
    }
  }

  @override
  void dispose() {
    _game.snapshotNotifier.removeListener(_handleSnapshotUpdate);
    super.dispose();
    _game.disposeNotifier();
  }

  void _switchCamera(V603DCameraPerspective mode) {
    setState(() => _cameraMode = mode);
    _game.setCameraPerspective(mode);
  }

  void _toggleGyroMode() {
    setState(() => _useHardwareGyro = !_useHardwareGyro);
    _game.setControlMode(useHardwareGyro: _useHardwareGyro);
    _showQuickToast(
      _useHardwareGyro
          ? 'Mode Gyroscope 3D aktif (miringkan HP atau pakai slider).'
          : 'Mode Desk Slider aktif — nyaman di meja tanpa gerak HP.',
    );
  }

  void _calibrateTare() {
    _game.calibrateZeroTare();
    _showQuickToast('Pegangan tangan dikalibrasi 0°! Miringkan perlahan untuk menuang.');
  }

  void _resetBrew() {
    setState(() {
      _virtualTilt = 0.0;
      _resultShown = false;
      _isInspecting3D = false;
      _lastEvalResult = null;
    });
    _game.setVirtualPourTilt(0.0);
    _game.resetSimulation();
  }

  void _showQuickToast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontSize: 12)),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF3E2723),
        ),
      );
  }

  void _handleViewportDragStart(DragStartDetails details) {
    if (_cameraMode != V603DCameraPerspective.freeOrbit) {
      _updateSpiralAimFromGlobal(details.globalPosition);
    }
  }

  void _handleViewportDragUpdate(DragUpdateDetails details) {
    if (_cameraMode == V603DCameraPerspective.freeOrbit || _isInspecting3D) {
      _game.adjustOrbitCamera(details.delta.dx, details.delta.dy);
    } else {
      _updateSpiralAimFromGlobal(details.globalPosition);
    }
  }

  void _updateSpiralAimFromGlobal(Offset globalPosition) {
    final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || box.size.isEmpty) return;
    final local = box.globalToLocal(globalPosition);
    final double nx = ((local.dx / box.size.width) * 2.2 - 1.1).clamp(-0.95, 0.95);
    final double ny = ((local.dy / box.size.height) * 2.2 - 1.1).clamp(-0.95, 0.95);
    _game.setTouchSpiralPosition(Offset(nx, ny));
  }

  Future<void> _evaluateAndShowResult(V603DSimulationSnapshot snap) async {
    setState(() => _isSubmitting = true);
    Map<String, dynamic> evalResult;

    if (widget.isSandboxMode) {
      evalResult = _computeLocalEvaluation(snap, isSandbox: true);
    } else {
      try {
        final container = ProviderScope.containerOf(context, listen: false);
        final api = container.read(baristaToolkitApiProvider);
        evalResult = await api.submitGame3DScore(
          chapterNumber: widget.chapter.chapterNumber,
          durationSec: snap.elapsedSec.clamp(10.0, 900.0),
          pouredTotalMl: snap.pouredMl.clamp(20.0, 1200.0),
          laminarFlowRatio: (snap.laminarRatioPct / 100.0).clamp(0.0, 1.0),
          flatBedScorePct: snap.flatBedScorePct,
          spiralEvennessPct: snap.spiralEvennessPct,
          swirlPerformed: snap.swirlPerformed,
          bypassEventsCount: snap.bypassEventsCount,
          extractionYieldEst: snap.estimatedEyPct.clamp(10.0, 30.0),
          thermalStabilityScore: snap.thermalMasteryPct,
          sampleCurve2Hz: _game.kettleEngine.telemetryCurve2Hz
              .map((p) => p.toJson())
              .toList(),
        );
      } catch (_) {
        evalResult = _computeLocalEvaluation(snap, isSandbox: false);
      }
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _lastEvalResult = evalResult;
    });
    await _openResultDialog(snap, evalResult);
  }

  Map<String, dynamic> _computeLocalEvaluation(
    V603DSimulationSnapshot snap, {
    required bool isSandbox,
  }) {
    final bypassPenalty = (snap.bypassEventsCount * 4.0).clamp(0.0, 25.0);
    final swirlBonus = snap.swirlPerformed ? 4.0 : 0.0;
    final eyScore =
        (100.0 - ((snap.estimatedEyPct - 20.2).abs() * 14.0)).clamp(0.0, 100.0);

    final composite = ((snap.laminarRatioPct * 0.25) +
            (snap.spiralEvennessPct * 0.28) +
            (snap.flatBedScorePct * 0.25) +
            (snap.thermalMasteryPct * 0.12) +
            (eyScore * 0.10) +
            swirlBonus -
            bypassPenalty)
        .clamp(0.0, 100.0);

    final stars = composite >= 86.0
        ? 3
        : (composite >= 70.0 ? 2 : (composite >= 54.0 ? 1 : 0));

    final String rank;
    if (composite >= 94.0) {
      rank = 'S+ WBrC Grandmaster';
    } else if (composite >= 86.0) {
      rank = 'S Head Barista';
    } else if (composite >= 76.0) {
      rank = 'A Senior Brewer';
    } else if (composite >= 62.0) {
      rank = 'B Pour-Over Enthusiast';
    } else {
      rank = 'C Apprentice';
    }

    final int xp = isSandbox
        ? (stars * 45)
        : (stars == 3
            ? widget.chapter.xpReward3Stars
            : (stars > 0 ? (widget.chapter.xpReward3Stars * stars ~/ 3) : 15));

    final String feedback;
    if (stars == 3) {
      feedback =
          'Luar biasa! Flat Coffee Bed rata & aliran laminar gooseneck menghasilkan cangkir kelas juara dunia!';
    } else if (snap.bypassEventsCount > 2) {
      feedback =
          'Air sempat mengenai kertas filter (Bypass ${snap.bypassEventsCount}x). Jaga lintasan spiral di radius dalam.';
    } else if (!snap.swirlPerformed) {
      feedback =
          'Coba tekan Rao Swirl saat blooming atau akhir seduh untuk meratakan bed kopi 100%!';
    } else {
      feedback =
          'Bagus! Jaga aliran konstan di zona Laminar hijau agar Extraction Yield makin optimal.';
    }

    return {
      'stars_earned': stars,
      'final_accuracy_pct': double.parse(composite.toStringAsFixed(1)),
      'rank_title': rank,
      'xp_awarded': xp,
      'mentor_feedback': feedback,
      'physics_verified': true,
    };
  }

  Future<void> _openResultDialog(
    V603DSimulationSnapshot snap,
    Map<String, dynamic> eval,
  ) async {
    final int stars = (eval['stars_earned'] as num?)?.toInt() ?? 2;
    final double scorePct =
        (eval['final_accuracy_pct'] as num?)?.toDouble() ?? 82.0;
    final String rank =
        eval['rank_title']?.toString() ?? 'A Senior Brewer';
    final int xp = (eval['xp_awarded'] as num?)?.toInt() ?? 100;
    final String feedback = eval['mentor_feedback']?.toString() ??
        'Seduhan selesai dengan presisi V60!';

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _Brew3DResultDialog(
        chapterTitle: widget.isSandboxMode
            ? 'Free Brew 3D Sandbox'
            : 'Chapter ${widget.chapter.chapterNumber}: ${widget.chapter.title}',
        rankTitle: rank,
        starsEarned: stars,
        finalScorePct: scorePct,
        xpAwarded: xp,
        mentorName: widget.chapter.npcMentorName,
        mentorFeedback: feedback,
        snapshot: snap,
        onShareCard: () {
          final summary = 'Coffee Labs 3D Game Brew\n'
              'Rank: $rank (${scorePct.toStringAsFixed(1)}%) | '
              'EY: ${snap.estimatedEyPct.toStringAsFixed(1)}%\n'
              'Flat Bed: ${snap.flatBedScorePct.toStringAsFixed(0)}% | '
              'Laminar: ${snap.laminarRatioPct.toStringAsFixed(0)}% | '
              'Swirl: ${snap.swirlPerformed ? "Ya" : "Tidak"}';
          Clipboard.setData(ClipboardData(text: summary));
          _showQuickToast('Kartu telemetri seduh disalin ke clipboard!');
        },
      ),
    );

    if (!mounted) return;
    if (action == 'inspect') {
      setState(() {
        _isInspecting3D = true;
        _cameraMode = V603DCameraPerspective.freeOrbit;
      });
      _game.setCameraPerspective(V603DCameraPerspective.freeOrbit);
    } else if (action == 'retry') {
      _resetBrew();
    } else if (action == 'map') {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasThermalDrop = _game.dropTempC != null;
    final doseLabel = '${_game.doseG.toInt()}g';
    final waterLabel = '${_game.targetWaterMl.toInt()}ml';
    final tempLabel = '${_game.initialTempC.toInt()}°C';

    return Scaffold(
      backgroundColor: const Color(0xFF140D09),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(doseLabel, waterLabel, tempLabel),
            _buildCameraSwitcherBar(),
            ValueListenableBuilder<V603DSimulationSnapshot>(
              valueListenable: _game.snapshotNotifier,
              builder: (_, snap, _) => _buildCeremonyStepperBar(snap),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ValueListenableBuilder<V603DSimulationSnapshot>(
                      valueListenable: _game.snapshotNotifier,
                      builder: (_, snap, _) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: GestureDetector(
                                key: _viewportKey,
                                behavior: HitTestBehavior.opaque,
                                onPanStart: _handleViewportDragStart,
                                onPanUpdate: _handleViewportDragUpdate,
                                child: V60ThreeJsViewport(
                                  game: _game,
                                  cameraMode: _cameraMode,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 10,
                              right: 10,
                              child: _buildLiveHudOverlay(snap),
                            ),
                            if (_isInspecting3D)
                              Positioned(
                                bottom: 12,
                                left: 16,
                                right: 16,
                                child: _buildInspectionBanner(snap),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (_isSubmitting)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ValueListenableBuilder<V603DSimulationSnapshot>(
              valueListenable: _game.snapshotNotifier,
              builder: (_, snap, _) => _buildBottomDeck(
                snap: snap,
                hasThermalDrop: hasThermalDrop,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String doseLabel, String waterLabel, String tempLabel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 19),
            tooltip: 'Kembali',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isSandboxMode
                      ? 'Free Brew 3D Sandbox'
                      : widget.chapter.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${widget.chapter.storyLocation} • $doseLabel / $waterLabel • $tempLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _calibrateTare,
            icon: const Icon(Icons.balance_rounded,
                color: AppTheme.accentGold, size: 19),
            tooltip: 'Kalibrasi Zero-Tare',
          ),
          InkWell(
            onTap: _toggleGyroMode,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _useHardwareGyro
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.35)
                    : Colors.white12,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _useHardwareGyro
                      ? const Color(0xFF4CAF50)
                      : Colors.white24,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _useHardwareGyro
                        ? Icons.screen_rotation_alt_rounded
                        : Icons.tune_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _useHardwareGyro ? 'Gyro' : 'Desk',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                setState(() => _showScienceNotes = !_showScienceNotes),
            icon: Icon(
              Icons.info_outline_rounded,
              color: _showScienceNotes ? AppTheme.accentGold : Colors.white70,
              size: 19,
            ),
            tooltip: 'Penjelasan Sains Ekstraksi',
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSwitcherBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Row(
        children: [
          _buildCameraChip(
            mode: V603DCameraPerspective.baristaPov,
            icon: Icons.videocam_rounded,
            label: 'Barista POV',
          ),
          const SizedBox(width: 6),
          _buildCameraChip(
            mode: V603DCameraPerspective.xrayCutaway,
            icon: Icons.layers_rounded,
            label: '3D X-Ray',
          ),
          const SizedBox(width: 6),
          _buildCameraChip(
            mode: V603DCameraPerspective.freeOrbit,
            icon: Icons.threesixty_rounded,
            label: '360° Orbit',
          ),
        ],
      ),
    );
  }

  Widget _buildCameraChip({
    required V603DCameraPerspective mode,
    required IconData icon,
    required String label,
  }) {
    final selected = _cameraMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => _switchCamera(mode),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accentGold.withValues(alpha: 0.22)
                : const Color(0xFF231710),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.accentGold : Colors.white12,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13.5,
                color: selected ? AppTheme.accentGold : Colors.white70,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppTheme.accentGold : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Indikator 5 langkah upacara seduh V60 interaktif (bilas -> angkat -> bloom -> spiral -> selesai).
  Widget _buildCeremonyStepperBar(V603DSimulationSnapshot snap) {
    const steps = <(BrewInteractiveStage, String)>[
      (BrewInteractiveStage.wettingPaper, 'Bilas'),
      (BrewInteractiveStage.liftAndDiscard, 'Angkat'),
      (BrewInteractiveStage.blooming, 'Bloom'),
      (BrewInteractiveStage.mainPour, 'Spiral'),
      (BrewInteractiveStage.drawdownAndInspect, 'Selesai'),
    ];
    final activeIdx = snap.interactiveStage.index;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1D120C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  for (var i = 0; i < steps.length; i++) ...[
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < activeIdx
                                    ? const Color(0xFF22C55E)
                                    : (i == activeIdx
                                        ? AppTheme.accentGold
                                        : Colors.white12),
                              ),
                              child: i < activeIdx
                                  ? const Icon(Icons.check,
                                      size: 9.5, color: Color(0xFF0B1F12))
                                  : Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: i == activeIdx
                                            ? const Color(0xFF1F140E)
                                            : Colors.white60,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              steps[i].$2,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: i == activeIdx
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: i <= activeIdx
                                    ? Colors.white
                                    : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!snap.coffeeGroundsAdded) ...[
              const SizedBox(width: 6),
              InkWell(
                key: const Key('skip_prebrew_btn'),
                onTap: _game.skipPreBrewToCoffee,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Text(
                    'Kertas ${snap.paperWetnessPct.toInt()}% • Lewati',
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLiveHudOverlay(V603DSimulationSnapshot snap) {
    final secs = snap.elapsedSec.toInt();
    final timeStr =
        '${(secs ~/ 60).toString().padLeft(2, '0')}:${(secs % 60).toString().padLeft(2, '0')}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: KettleTiltArcGauge(snapshot: snap)),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F140E).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${snap.pouredMl.toInt()}/${snap.targetWaterMl.toInt()}ml',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${snap.tempC.toStringAsFixed(0)}°C • Bed ${snap.flatBedScorePct.toInt()}%',
                              style: TextStyle(
                                color: snap.tempC <= 75.0
                                    ? const Color(0xFF67E8F9)
                                    : Colors.white70,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'EY ${snap.estimatedEyPct.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Color(0xFF86EFAC),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildCoachAndFlavorCard(snap),
        if (_showScienceNotes) ...[
          const SizedBox(height: 6),
          _buildScienceNotesBanner(),
        ],
      ],
    );
  }

  Widget _buildCoachAndFlavorCard(V603DSimulationSnapshot snap) {
    final total = snap.acidPct + snap.sweetPct + snap.bitterPct;
    final aFlex = ((snap.acidPct / (total > 0 ? total : 1)) * 100).round().clamp(5, 90);
    final sFlex = ((snap.sweetPct / (total > 0 ? total : 1)) * 100).round().clamp(5, 90);
    final bFlex = ((snap.bitterPct / (total > 0 ? total : 1)) * 100).round().clamp(5, 90);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF221610).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: snap.isBypassWarning
              ? const Color(0xFFEF4444)
              : AppTheme.accentGold.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 13, color: AppTheme.accentGold),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  snap.activePhaseLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _cameraMode == V603DCameraPerspective.freeOrbit
                      ? 'Putar 360°'
                      : 'Geser spiral',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9.5, color: Colors.white54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            snap.liveCoachTip,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: Colors.white),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: Row(
                children: [
                  Expanded(
                    flex: aFlex,
                    child: Container(color: const Color(0xFFFBBF24)),
                  ),
                  Expanded(
                    flex: sFlex,
                    child: Container(color: const Color(0xFF22C55E)),
                  ),
                  Expanded(
                    flex: bFlex,
                    child: Container(color: const Color(0xFF92400E)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Acid ${snap.acidPct.toInt()}% • Sweet ${snap.sweetPct.toInt()}% • Bitter ${snap.bitterPct.toInt()}%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: Colors.white60),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'CO2 ${(snap.averageCo2 * 100).toInt()}%',
                style: const TextStyle(fontSize: 9, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScienceNotesBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A110B).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LABORATORIUM FISIKA V60',
            style: TextStyle(
              color: AppTheme.accentGold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '• Sudut Kritis Ketel: Saat air di ketel berkurang, Anda perlu mencondongkan ketel lebih dalam agar air keluar.\n'
            '• Aliran Laminar (≤ 6.8 ml/s): Mencegah partikel halus (fines) menyumbat kertas filter.\n'
            '• Gentle Rao Swirl: Meratakan puncak-lembah ampas kopi secara difusi sehingga terbentuk Flat Coffee Bed.',
            style: TextStyle(fontSize: 10.5, color: Colors.white70, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionBanner(V603DSimulationSnapshot snap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF281910),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentGold),
      ),
      child: Row(
        children: [
          const Icon(Icons.threesixty_rounded, color: AppTheme.accentGold, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode Inspeksi Flat Bed (${snap.flatBedScorePct.toInt()}%). Putar 360° untuk cek kerataan.',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: () {
              final res = _lastEvalResult ?? _computeLocalEvaluation(snap, isSandbox: widget.isSandboxMode);
              _openResultDialog(snap, res);
            },
            child: const Text('Nilai', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDeck({
    required V603DSimulationSnapshot snap,
    required bool hasThermalDrop,
  }) {
    final canManualFinish =
        !_isInspecting3D && snap.pouredMl >= _game.targetWaterMl * 0.72;
    final bool coolPrompt = hasThermalDrop &&
        snap.pouredMl >= (_game.dropAtMl ?? _game.targetWaterMl * 0.60) - 15.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1D120C),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_outlined,
                  size: 15, color: AppTheme.accentGold),
              const SizedBox(width: 6),
              Text(
                'Tuang Ketel: ${(_virtualTilt * 100).round()}%',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                    activeTrackColor: AppTheme.accentGold,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppTheme.accentGold,
                  ),
                  child: Slider(
                    key: const Key('virtual_tilt_slider'),
                    value: _virtualTilt,
                    onChanged: (v) {
                      setState(() => _virtualTilt = v);
                      _game.setVirtualPourTilt(v);
                    },
                  ),
                ),
              ),
            ],
          ),
          if (!snap.coffeeGroundsAdded) ...[
            _buildPreBrewActionRow(snap),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _game.triggerGentleRaoSwirl,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: snap.swirlIntensity > 0.2
                        ? AppTheme.accentGold
                        : Colors.white,
                    side: BorderSide(
                      color: snap.swirlIntensity > 0.2
                          ? AppTheme.accentGold
                          : Colors.white30,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)),
                  ),
                  icon: const Icon(Icons.cyclone_rounded, size: 15),
                  label: const Text('Rao Swirl',
                      style:
                          TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                ),
              ),
              if (hasThermalDrop) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _game.activateThermalDrop(_game.dropTempC ?? 70.0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coolPrompt
                          ? const Color(0xFF0891B2)
                          : const Color(0xFF1E3A4C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11)),
                    ),
                    icon: const Icon(Icons.ac_unit_rounded, size: 14),
                    label: Text(
                      'Air ${_game.dropTempC!.toInt()}°C',
                      style: const TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
              if (canManualFinish) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _game.finishBrewEarlyForInspection();
                      if (!_resultShown) {
                        _resultShown = true;
                        _evaluateAndShowResult(_game.snapshotNotifier.value);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: const Color(0xFF1F140E),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11)),
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 15),
                    label: const Text('Nilai',
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              IconButton(
                onPressed: _resetBrew,
                style: IconButton.styleFrom(backgroundColor: Colors.white10),
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white70, size: 18),
                tooltip: 'Ulangi Seduhan',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Kontrol interaktif pra-seduh V60: angkat dripper, miringkan teko buang bilasan, lalu tuang bubuk kopi.
  Widget _buildPreBrewActionRow(V603DSimulationSnapshot snap) {
    final bool readyToDiscard =
        snap.rinseWaterMl > 1.0 || snap.isDripperLifted;
    final bool readyToDropCoffee =
        snap.paperWetnessPct >= 40.0 || snap.rinseDiscarded;

    return Row(
      children: [
        Expanded(
          child: _buildCeremonyButton(
            key: const Key('lift_dripper_btn'),
            icon: snap.isDripperLifted
                ? Icons.vertical_align_bottom_rounded
                : Icons.vertical_align_top_rounded,
            label: snap.isDripperLifted ? 'Turun Dripper' : 'Angkat Dripper',
            highlighted: snap.isDripperLifted ||
                (snap.paperWetnessPct >= 50.0 && !snap.rinseDiscarded),
            filledGold: false,
            onTap: _game.toggleLiftDripper,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildCeremonyButton(
            key: const Key('discard_rinse_btn'),
            icon: snap.rinseDiscarded
                ? Icons.check_circle_rounded
                : Icons.water_damage_rounded,
            label: snap.rinseDiscarded ? 'Air Dibuang' : 'Buang Air',
            highlighted: readyToDiscard && !snap.rinseDiscarded,
            filledGold: false,
            onTap: _game.discardRinseWater,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildCeremonyButton(
            key: const Key('drop_coffee_btn'),
            icon: Icons.grain_rounded,
            label: 'Tuang ${_game.doseG.toInt()}g Kopi',
            highlighted: readyToDropCoffee,
            filledGold: snap.rinseDiscarded || snap.paperWetnessPct >= 80.0,
            onTap: _game.dropCoffeeGrounds,
          ),
        ),
      ],
    );
  }

  Widget _buildCeremonyButton({
    required Key key,
    required IconData icon,
    required String label,
    required bool highlighted,
    required bool filledGold,
    required VoidCallback onTap,
  }) {
    final bgColor = filledGold
        ? AppTheme.accentGold
        : (highlighted
            ? AppTheme.accentGold.withValues(alpha: 0.16)
            : const Color(0xFF281A12));
    final fgColor = filledGold
        ? const Color(0xFF1F140E)
        : (highlighted ? AppTheme.accentGold : Colors.white70);

    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filledGold || highlighted
                ? AppTheme.accentGold
                : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13.5, color: fgColor),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: fgColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brew3DResultDialog extends StatelessWidget {
  final String chapterTitle;
  final String rankTitle;
  final int starsEarned;
  final double finalScorePct;
  final int xpAwarded;
  final String mentorName;
  final String mentorFeedback;
  final V603DSimulationSnapshot snapshot;
  final VoidCallback onShareCard;

  const _Brew3DResultDialog({
    required this.chapterTitle,
    required this.rankTitle,
    required this.starsEarned,
    required this.finalScorePct,
    required this.xpAwarded,
    required this.mentorName,
    required this.mentorFeedback,
    required this.snapshot,
    required this.onShareCard,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFFBF7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4A2B18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              rankTitle,
              style: const TextStyle(
                color: AppTheme.accentGold,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            chapterTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Icon(
                i < starsEarned ? Icons.star_rounded : Icons.star_border_rounded,
                size: 32,
                color: i < starsEarned ? AppTheme.accentGold : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metricChip('Skor Total', '${finalScorePct.toStringAsFixed(1)}%'),
                _metricChip('Est. EY', '${snapshot.estimatedEyPct.toStringAsFixed(1)}%'),
                _metricChip('XP Bonus', '+$xpAwarded XP'),
              ],
            ),
            const SizedBox(height: 12),
            _pillarBar('Aliran Laminar', snapshot.laminarRatioPct),
            _pillarBar('Lintasan Spiral', snapshot.spiralEvennessPct),
            _pillarBar('Kerataan Flat Bed 3D', snapshot.flatBedScorePct),
            _pillarBar('Stabilitas Termal', snapshot.thermalMasteryPct),
            if (snapshot.bypassEventsCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Filter Bypass tercatat: ${snapshot.bypassEventsCount}x',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$mentorName: "$mentorFeedback"',
                style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      actions: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.end,
          children: [
            TextButton.icon(
              onPressed: onShareCard,
              icon: const Icon(Icons.share_rounded, size: 16),
              label: const Text('Bagikan Kartu', style: TextStyle(fontSize: 12)),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop('inspect'),
              icon: const Icon(Icons.threesixty_rounded, size: 16),
              label: const Text('Inspeksi Flat Bed 360°',
                  style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('retry'),
              child: const Text('Ulangi'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: const Text('Kembali ke Peta'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricChip(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted)),
          Text(val,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBrown)),
        ],
      ),
    );
  }

  Widget _pillarBar(String label, double pct) {
    final norm = (pct / 100.0).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              Text('${pct.toInt()}%',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBrown)),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: norm,
              minHeight: 5,
              backgroundColor: const Color(0xFFEFE5DC),
              color: pct >= 85
                  ? const Color(0xFF16A34A)
                  : (pct >= 65 ? AppTheme.accentGold : const Color(0xFFEA580C)),
            ),
          ),
        ],
      ),
    );
  }
}
