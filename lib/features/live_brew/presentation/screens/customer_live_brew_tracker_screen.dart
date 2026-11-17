import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../theme/app_theme.dart';
import '../../data/live_brew_api_service.dart';
import '../../domain/live_brew_models.dart';

class CustomerLiveBrewTrackerScreen extends ConsumerStatefulWidget {
  final String? addressCode;

  const CustomerLiveBrewTrackerScreen({super.key, this.addressCode});

  @override
  ConsumerState<CustomerLiveBrewTrackerScreen> createState() =>
      _CustomerLiveBrewTrackerScreenState();
}

class _CustomerLiveBrewTrackerScreenState
    extends ConsumerState<CustomerLiveBrewTrackerScreen> {
  final TextEditingController _codeCtrl = TextEditingController();
  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  Timer? _demoTimer;

  LiveBrewSnapshotModel? _snapshot;
  final List<LiveBrewCurvePoint> _curvePoints = [];
  LiveBrewStage _stage = LiveBrewStage.queuedAssigned;
  String? _waitingTableMessage;
  bool _loading = false;
  bool _showCameraTab = false;
  Uint8List? _latestCameraFrame;
  double _currentWeightG = 0.0;
  double _currentFlowMlS = 0.0;
  double _currentTempC = 91.0;
  int _elapsedSec = 0;
  int _cheersCount = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.addressCode?.trim() ?? '';
    if (initial.isNotEmpty) {
      _codeCtrl.text = initial;
      _connectAddress(initial);
    }
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _wsSub?.cancel();
    _ws?.sink.close();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _connectAddress(String rawCode) async {
    _demoTimer?.cancel();
    final code = LiveBrewApiService.extractAddressCode(rawCode);
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
      _waitingTableMessage = null;
    });

    try {
      final api = ref.read(liveBrewApiProvider);
      final res = await api.resolveAddress(code);
      if (!mounted) return;
      if (res['resolution_kind'] == 'TABLE_WAITING') {
        final waiting = res['waiting'] as Map<String, dynamic>? ?? {};
        setState(() {
          _snapshot = null;
          _waitingTableMessage =
              waiting['message']?.toString() ?? 'Menunggu Barista memulai seduhan Anda...';
          _loading = false;
        });
      } else if (res['session'] is Map) {
        _applySnapshot(
          LiveBrewSnapshotModel.fromJson(Map<String, dynamic>.from(res['session'] as Map)),
        );
      } else {
        setState(() => _loading = false);
      }
      _openViewerWs(code);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openViewerWs(String code) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    await _wsSub?.cancel();
    await _ws?.sink.close();
    try {
      final (wsBase, _) = await ref.read(liveBrewApiProvider).resolveWsBaseAndToken();
      _ws = WebSocketChannel.connect(Uri.parse('$wsBase/api/v1/livebrew/stream/$code/ws'));
      _wsSub = _ws!.stream.listen((raw) {
        try {
          final ev = jsonDecode(raw.toString()) as Map<String, dynamic>;
          final kind = ev['event']?.toString();
          if (kind == 'initial_session_snapshot') {
            _applySnapshot(LiveBrewSnapshotModel.fromJson(ev));
          } else if (kind == 'table_session_bound' && ev['snapshot'] is Map) {
            _applySnapshot(
              LiveBrewSnapshotModel.fromJson(Map<String, dynamic>.from(ev['snapshot'] as Map)),
            );
          } else if (kind == 'stage_changed') {
            setState(() => _stage = LiveBrewStage.fromApi(ev['stage']?.toString()));
          } else if (kind == 'telemetry_tick') {
            final pt = LiveBrewCurvePoint.fromJson(ev);
            setState(() {
              _curvePoints.add(pt);
              _currentWeightG = pt.wG;
              _currentFlowMlS = pt.flow;
              _currentTempC = pt.tempC;
              _elapsedSec = pt.tMs ~/ 1000;
            });
          } else if (kind == 'customer_cheer') {
            setState(() => _cheersCount = (ev['total_cheers'] as num?)?.toInt() ?? _cheersCount + 1);
          } else if (kind == 'video_keyframe_relayed' && ev['jpeg_b64'] != null) {
            setState(() => _latestCameraFrame = base64Decode(ev['jpeg_b64'].toString()));
          }
        } catch (_) {}
      }, onError: (_) {});
    } catch (_) {}
  }

  void _applySnapshot(LiveBrewSnapshotModel snap) {
    setState(() {
      _snapshot = snap;
      _waitingTableMessage = null;
      _loading = false;
      _stage = snap.currentStage;
      _currentWeightG = snap.currentWeightG;
      _currentFlowMlS = snap.currentFlowRateMlS;
      _currentTempC = snap.currentTempC;
      _elapsedSec = snap.elapsedSec;
      _cheersCount = snap.cheersReactionsCount;
      _curvePoints
        ..clear()
        ..addAll(snap.catchupCurvePoints);
    });
  }

  void _startOfflineDemoPreview() {
    _demoTimer?.cancel();
    _applySnapshot(
      const LiveBrewSnapshotModel(
        sessionId: 'demo',
        dynamicAddressCode: '3201923849204',
        livebrewUrl: 'https://coffeelabs.app/livebrew/3201923849204',
        deepLinkUrl: 'coffeelabs://livebrew/3201923849204',
        tableNumber: 'Meja 04 (Simulasi)',
        storeName: 'Coffee Labs Flagship Bar',
        baristaDisplayName: 'Master Kaito',
        customerDisplayName: 'Pelanggan Spesial',
        recipeTitle: 'Malabar Wine Dual-Temp V60',
        brewMethod: 'V60',
        beanName: 'Malabar Wine 1700 MDPL',
        roasteryName: 'Coffee Labs Roastery',
        beanOrigin: 'Jawa Barat',
        beanProcess: 'Wine Natural',
        tastingNotes: ['Winey Grape', 'Dark Cocoa', 'Sweet Berry'],
        targetDoseG: 15,
        targetWaterMl: 225,
        targetTempC: 93,
        secondaryTempC: 70,
        targetDurationSec: 145,
        currentStage: LiveBrewStage.bloomingDegassing,
        currentStepIndex: 3,
        elapsedSec: 0,
        currentWeightG: 0,
        currentFlowRateMlS: 0,
        currentTempC: 93,
      ),
    );
    int sec = 0;
    _demoTimer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      sec += 2;
      final stage = sec < 35
          ? LiveBrewStage.bloomingDegassing
          : (sec < 105
              ? LiveBrewStage.activePouring
              : (sec < 145 ? LiveBrewStage.drawdownSwirl : LiveBrewStage.readyToServe));
      final weight = sec < 35 ? (sec * 1.3).clamp(0.0, 45.0) : (45.0 + (sec - 35) * 2.57).clamp(45.0, 225.0);
      final flow = sec < 105 ? 4.8 : 0.0;
      final temp = sec > 70 ? 70.0 : 93.0;
      setState(() {
        _stage = stage;
        _elapsedSec = sec.clamp(0, 145);
        _currentWeightG = double.parse(weight.toStringAsFixed(1));
        _currentFlowMlS = flow;
        _currentTempC = temp;
        _curvePoints.add(LiveBrewCurvePoint(tMs: _elapsedSec * 1000, wG: _currentWeightG, flow: flow, tempC: temp));
      });
      if (sec >= 145) t.cancel();
    });
  }

  Future<void> _sendCheer(String kind) async {
    setState(() => _cheersCount++);
    final code = _snapshot?.dynamicAddressCode ?? _codeCtrl.text.trim();
    if (code.isEmpty || _demoTimer != null) return;
    try {
      final total = await ref.read(liveBrewApiProvider).sendCheer(code, kind);
      if (mounted && total > 0) setState(() => _cheersCount = total);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final snap = _snapshot;

    return Scaffold(
      backgroundColor: const Color(0xFF12100E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1512),
        foregroundColor: Colors.white,
        title: const Text(
          'Live Brew Tracker',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          if (snap != null)
            IconButton(
              tooltip: 'Buka di Landing Page Web',
              onPressed: () {
                final uri = Uri.tryParse(snap.livebrewUrl);
                if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.open_in_browser_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan 13-digit kode QR / meja...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 12.5),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: const Color(0xFF12100E),
                ),
                onPressed: () => _connectAddress(_codeCtrl.text),
                child: const Text('Lacak', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator(color: AppTheme.accentGold)),
            ),

          if (_waitingTableMessage != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1713),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppTheme.accentGold),
                  const SizedBox(height: 14),
                  Text(
                    _waitingTableMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],

          if (snap == null && !_loading && _waitingTableMessage == null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1612),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.35)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.accentGold, size: 42),
                  const SizedBox(height: 10),
                  const Text(
                    'Lacak Seduhan Barista Live (10Hz)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15.5),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pindai QR meja atau struk dari kasir Coffee Labs, atau coba simulasi langsung.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: const Color(0xFF12100E),
                    ),
                    onPressed: _startOfflineDemoPreview,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Jalankan Simulasi Live Brew'),
                  ),
                ],
              ),
            ),
          ],

          if (snap != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1712),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'LIVE BREW',
                          style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (snap.tableNumber != null)
                        Text(
                          snap.tableNumber!,
                          style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      const Spacer(),
                      Text('#${snap.dynamicAddressCode}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snap.recipeTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${snap.beanName} • Barista ${snap.baristaDisplayName}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _stage.labelId,
                    style: const TextStyle(color: AppTheme.accentAmber, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ((_stage.stepIndex + 1) / 7.0).clamp(0.1, 1.0),
                      backgroundColor: Colors.white12,
                      color: AppTheme.accentGold,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Kurva Hermite 60fps')),
                    selected: !_showCameraTab,
                    onSelected: (_) => setState(() => _showCameraTab = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Kamera Barista')),
                    selected: _showCameraTab,
                    onSelected: (_) => setState(() => _showCameraTab = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              height: 195,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1410),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: _showCameraTab
                  ? (_latestCameraFrame != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_latestCameraFrame!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : const Center(
                          child: Text(
                            'Kamera overhead belum diaktifkan oleh Barista.',
                            style: TextStyle(color: Colors.white54, fontSize: 12.5),
                          ),
                        ))
                  : CustomPaint(
                      painter: _HermitePourChartPainter(
                        points: _curvePoints,
                        targetWaterMl: snap.targetWaterMl,
                        targetDurationSec: snap.targetDurationSec,
                      ),
                      size: Size.infinite,
                    ),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metricTile('Waktu', '${(_elapsedSec ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSec % 60).toString().padLeft(2, '0')}'),
                _metricTile('Berat', '${_currentWeightG.toStringAsFixed(1)}g'),
                _metricTile('Flow', '${_currentFlowMlS.toStringAsFixed(1)} ml/s'),
                _metricTile('Suhu', '${_currentTempC.toStringAsFixed(0)}°C'),
              ],
            ),

            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF211813),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Semangat Barista ($_cheersCount)',
                      style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                  IconButton(onPressed: () => _sendCheer('clap'), icon: const Text('👏', style: TextStyle(fontSize: 20))),
                  IconButton(onPressed: () => _sendCheer('fire'), icon: const Text('🔥', style: TextStyle(fontSize: 20))),
                  IconButton(onPressed: () => _sendCheer('coffee'), icon: const Text('☕', style: TextStyle(fontSize: 20))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricTile(String label, String val) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1612),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
            const SizedBox(height: 3),
            Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _HermitePourChartPainter extends CustomPainter {
  final List<LiveBrewCurvePoint> points;
  final double targetWaterMl;
  final int targetDurationSec;

  _HermitePourChartPainter({
    required this.points,
    required this.targetWaterMl,
    required this.targetDurationSec,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 10 || size.height <= 10) return;
    final maxSec = targetDurationSec <= 0 ? 145.0 : targetDurationSec.toDouble();
    final maxW = targetWaterMl <= 0 ? 225.0 : targetWaterMl * 1.08;
    double toX(double sec) => (sec / maxSec).clamp(0.0, 1.0) * size.width;
    double toY(double w) => size.height - (w / maxW).clamp(0.0, 1.0) * size.height;

    final targetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final targetPath = Path()
      ..moveTo(toX(0), toY(0))
      ..lineTo(toX(maxSec * 0.25), toY(targetWaterMl * 0.2))
      ..lineTo(toX(maxSec * 0.55), toY(targetWaterMl * 0.6))
      ..lineTo(toX(maxSec), toY(targetWaterMl));
    canvas.drawPath(targetPath, targetPaint);

    if (points.length < 2) return;
    final actualPath = Path()..moveTo(toX(points.first.tMs / 1000), toY(points.first.wG));
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      for (int s = 1; s <= 5; s++) {
        final u = s / 5.0;
        final w = interpolateCubicHermiteWeight(p0, p1, u);
        final t = (p0.tMs + (p1.tMs - p0.tMs) * u) / 1000.0;
        actualPath.lineTo(toX(t), toY(w));
      }
    }
    canvas.drawPath(
      actualPath,
      Paint()
        ..color = AppTheme.accentGold
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _HermitePourChartPainter oldDelegate) => true;
}
