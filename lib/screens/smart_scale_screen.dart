import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/smart_scale_model.dart';
import '../services/language_service.dart';
import '../services/smart_scale_service.dart';
import '../theme/app_theme.dart';
import 'brew_selection_screen.dart';

class SmartScaleScreen extends StatefulWidget {
  const SmartScaleScreen({super.key});

  @override
  State<SmartScaleScreen> createState() => _SmartScaleScreenState();
}

class _SmartScaleScreenState extends State<SmartScaleScreen> {
  final SmartScaleService _scaleService = SmartScaleService.instance;

  // Local Timer & Chart
  Timer? _ticker;
  int _brewSeconds = 0;
  bool _isTimerRunning = false;
  final List<WeightDataPoint> _dataPoints = [];

  // Coffee Ratio Calculator
  double _coffeeDoseGrams = 15.0;
  double _selectedRatio = 15.0; // 1:15

  // Display Unit
  bool _isOunces = false;

  @override
  void initState() {
    super.initState();
    _scaleService.addListener(_onScaleUpdate);
    _scaleService.onAutoStartBrewTimer = _startTimerAutomatically;

    // Start ticker for live graph & stopwatch
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_isTimerRunning) {
        setState(() {
          _brewSeconds++;
          _dataPoints.add(
            WeightDataPoint(
              elapsedSeconds: _brewSeconds * 0.2,
              weight: _scaleService.currentWeight,
              flowRate: _scaleService.flowRate,
            ),
          );
          // Keep up to 300 data points (60 seconds)
          if (_dataPoints.length > 300) {
            _dataPoints.removeAt(0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scaleService.removeListener(_onScaleUpdate);
    _scaleService.onAutoStartBrewTimer = null;
    super.dispose();
  }

  void _onScaleUpdate() {
    if (mounted) setState(() {});
  }

  void _startTimerAutomatically() {
    if (!_isTimerRunning) {
      setState(() {
        _isTimerRunning = true;
      });
    }
  }

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
  }

  void _resetTimer() {
    setState(() {
      _isTimerRunning = false;
      _brewSeconds = 0;
      _dataPoints.clear();
      _scaleService.resetAutoStartTrigger();
    });
  }

  double get _targetWater => _coffeeDoseGrams * _selectedRatio;

  String _formatTimer(int fifthSeconds) {
    final totalSec = (fifthSeconds * 0.2).floor();
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _displayWeight(double grams) {
    if (_isOunces) {
      final oz = grams * 0.035274;
      return oz.toStringAsFixed(2);
    }
    return grams.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final isConnected = _scaleService.isConnected;
    final currentDevice = _scaleService.activeDevice;
    final weight = _scaleService.currentWeight;
    final flowRate = _scaleService.flowRate;
    final isStable = _scaleService.isStable;
    final targetWater = _targetWater;
    final progress = targetWater > 0 ? (weight / targetWater).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF141312), // Deep dark matte barista aesthetic
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1A18),
        elevation: 0,
        title: Row(
          children: [
            const Icon(CupertinoIcons.gauge, color: AppTheme.accentGold, size: 20),
            const SizedBox(width: 8),
            Text(
              isEn ? 'Smart Scale Brew' : 'Smart Scale Timbangan',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white),
            ),
          ],
        ),
        actions: [
          // Unit Switcher (g / oz)
          TextButton(
            onPressed: () {
              setState(() {
                _isOunces = !_isOunces;
              });
            },
            child: Text(
              _isOunces ? 'OZ' : 'GRAM',
              style: const TextStyle(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          // Bluetooth Connection Modal Button
          IconButton(
            icon: Icon(
              isConnected ? CupertinoIcons.bluetooth : CupertinoIcons.bolt_slash_fill,
              color: isConnected ? Colors.blueAccent : Colors.white70,
            ),
            tooltip: isEn ? 'Bluetooth Devices' : 'Perangkat Bluetooth',
            onPressed: () => _showDeviceSheet(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          children: [
          // 1. Device Connection Status Banner
          _buildDeviceStatusBanner(context, isEn, isConnected, currentDevice),
          const SizedBox(height: 14),

          // 2. Giant LED Digital Readout & Flow Rate
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF221F1C), Color(0xFF171513)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Indicator Row: Stable flag + Scale Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isStable ? Colors.greenAccent : Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isStable ? (isEn ? 'STABLE' : 'STABIL') : (isEn ? 'POURING' : 'MENUANG'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isStable ? Colors.greenAccent : Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                    // Auto-start indicator
                    Row(
                      children: [
                        const Icon(CupertinoIcons.bolt_fill, size: 12, color: AppTheme.accentGold),
                        const SizedBox(width: 4),
                        Text(
                          isEn ? 'AUTO-TIMER ON' : 'AUTO-TIMER AKTIF',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Main Weight Display (Huge 7-Segment style)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _displayWeight(weight),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOunces ? 'oz' : 'g',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Flow Rate Readout & Speed Gauge
                _buildFlowRateGauge(flowRate, isEn),
                const SizedBox(height: 20),

                // Action Controls: Tare, Timer, Reset
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tare Button
                    ElevatedButton.icon(
                      onPressed: () {
                        _scaleService.tare();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF332F2A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 16, color: AppTheme.accentGold),
                      label: Text(
                        isEn ? 'TARE' : 'NOL-KAN (TARE)',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Stopwatch Timer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2824),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isTimerRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: _toggleTimer,
                          ),
                          Text(
                            _formatTimer(_brewSeconds),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.stop_fill, color: Colors.white54, size: 16),
                            onPressed: _resetTimer,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Real-Time Flow & Weight Graph
          Container(
            height: 130,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1B18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEn ? 'Extraction Curve (Real-Time)' : 'Kurva Ekstraksi Real-Time',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    Row(
                      children: [
                        _buildLegend(Colors.cyanAccent, isEn ? 'Weight (g)' : 'Berat (g)'),
                        const SizedBox(width: 12),
                        _buildLegend(AppTheme.accentGold, isEn ? 'Flow (g/s)' : 'Laju Air (g/s)'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ClipRect(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _ExtractionChartPainter(dataPoints: _dataPoints),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Barista Ratio Calculator & Progress Target Ring
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1B18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEn ? 'Target Ratio Calculator' : 'Kalkulator Target Rasio',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '1:${_selectedRatio.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.accentGold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Dose selector
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'Coffee Dose' : 'Dosis Kopi',
                            style: const TextStyle(fontSize: 10.5, color: Colors.white54),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildDoseChip(12.0),
                              const SizedBox(width: 4),
                              _buildDoseChip(15.0),
                              const SizedBox(width: 4),
                              _buildDoseChip(18.0),
                              const SizedBox(width: 4),
                              _buildDoseChip(20.0),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Ratio selectors
                Row(
                  children: [
                    _buildRatioChip(14.0),
                    const SizedBox(width: 6),
                    _buildRatioChip(15.0),
                    const SizedBox(width: 6),
                    _buildRatioChip(16.0),
                    const SizedBox(width: 6),
                    _buildRatioChip(16.6),
                    const SizedBox(width: 6),
                    _buildRatioChip(17.0),
                  ],
                ),
                const Divider(height: 20, color: Colors.white12),
                // Target vs Current Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${weight.toStringAsFixed(1)}g / ${targetWater.toStringAsFixed(1)}g',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: progress >= 1.0 ? Colors.greenAccent : AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? Colors.greenAccent : AppTheme.accentGold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. Virtual Scale Interactive Simulation (if active)
          if (_scaleService.isSimulationMode) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF26211C),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.play_circle_fill, color: AppTheme.accentGold, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        isEn ? 'Interactive Scale Simulator (Testing Mode)' : 'Simulator Timbangan Interaktif',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEn
                        ? 'Simulate coffee pouring physics without physical hardware scale.'
                        : 'Simulasikan penuangan air tanpa perlu hardware timbangan fisik.',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        backgroundColor: const Color(0xFF332D26),
                        label: Text(
                          isEn ? '+15g Coffee' : '+15g Kopi',
                          style: const TextStyle(fontSize: 11, color: Colors.white),
                        ),
                        onPressed: () => _scaleService.simulateAddCoffee(15.0),
                      ),
                      ActionChip(
                        backgroundColor: const Color(0xFF332D26),
                        label: Text(
                          isEn ? 'Bloom Pour (3.0 g/s)' : 'Tuang Bloom (3.0 g/s)',
                          style: const TextStyle(fontSize: 11, color: Colors.cyanAccent),
                        ),
                        onPressed: () => _scaleService.setSimulatedFlowRate(3.0),
                      ),
                      ActionChip(
                        backgroundColor: const Color(0xFF332D26),
                        label: Text(
                          isEn ? 'Main Spiral (4.5 g/s)' : 'Tuang Utama (4.5 g/s)',
                          style: const TextStyle(fontSize: 11, color: AppTheme.accentGold),
                        ),
                        onPressed: () => _scaleService.setSimulatedFlowRate(4.5),
                      ),
                      ActionChip(
                        backgroundColor: const Color(0xFF332D26),
                        label: Text(
                          isEn ? 'Stop Pour (0 g/s)' : 'Hentikan Tuang (0 g/s)',
                          style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                        ),
                        onPressed: () => _scaleService.setSimulatedFlowRate(0.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // 6. Launch Guided Brew with this Scale
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrewSelectionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(CupertinoIcons.timer, size: 18),
            label: Text(
              isEn ? 'Start Guided Recipe Brew →' : 'Mulai Seduh Resep dengan Timbangan Ini →',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildDeviceStatusBanner(
    BuildContext context,
    bool isEn,
    bool isConnected,
    SmartScaleDevice? currentDevice,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1B18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isConnected ? Colors.blueAccent.withValues(alpha: 0.3) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
            color: isConnected ? Colors.blueAccent : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected
                      ? currentDevice?.name ?? 'Connected Scale'
                      : (isEn ? 'No Scale Connected' : 'Timbangan Belum Terhubung'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  isConnected
                      ? currentDevice?.brandLabel ?? 'Bluetooth BLE Scale'
                      : (isEn ? 'Tap to scan Timemore, Acaia, or BLE scale' : 'Ketuk untuk scan Timemore, Acaia, atau BLE'),
                  style: const TextStyle(fontSize: 10, color: Colors.white54),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showDeviceSheet(context),
            child: Text(
              isConnected ? (isEn ? 'Change' : 'Ubah') : (isEn ? 'Connect' : 'Hubungkan'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowRateGauge(double flowRate, bool isEn) {
    Color gaugeColor = Colors.grey;
    String status = isEn ? 'Drip / Pause' : 'Tetesan Lambat';

    if (flowRate >= 2.8 && flowRate <= 5.2) {
      gaugeColor = Colors.greenAccent;
      status = isEn ? 'Sweet Spot (Ideal Pour)' : 'Sweet Spot (Laju Ideal)';
    } else if (flowRate > 5.2) {
      gaugeColor = Colors.orangeAccent;
      status = isEn ? 'Heavy Agitation' : 'Agitasi Cepat';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.drop_fill, size: 14, color: AppTheme.accentGold),
            const SizedBox(width: 4),
            Text(
              '${flowRate.toStringAsFixed(1)} g/s',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gaugeColor),
            ),
            const SizedBox(width: 8),
            Text(
              '• $status',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: gaugeColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoseChip(double dose) {
    final isSel = _coffeeDoseGrams == dose;
    return InkWell(
      onTap: () {
        setState(() {
          _coffeeDoseGrams = dose;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.accentGold : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${dose.toInt()}g',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRatioChip(double ratio) {
    final isSel = _selectedRatio == ratio;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRatio = ratio;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.primaryBrown : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSel ? AppTheme.accentGold : Colors.transparent,
          ),
        ),
        child: Text(
          '1:${ratio.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }

  void _showDeviceSheet(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    _scaleService.startScan();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1C19),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEn ? 'Bluetooth Coffee Scales' : 'Pindai Timbangan Bluetooth',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.arrow_clockwise, color: AppTheme.accentGold, size: 18),
                        onPressed: () {
                          _scaleService.startScan();
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  Text(
                    isEn
                        ? 'Compatible with Timemore (Dot / Black Mirror), Acaia, Felicita, and standard BLE scales.'
                        : 'Kompatibel dengan Timemore Dot Scale, Black Mirror, Acaia, Felicita, & BLE standar.',
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                  const Divider(height: 20, color: Colors.white12),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _scaleService,
                      builder: (context, _) {
                        final devices = _scaleService.discoveredDevices;
                        return ListView.separated(
                          itemCount: devices.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final d = devices[idx];
                            final isCur = _scaleService.activeDevice?.id == d.id;
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF282521),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCur ? Colors.blueAccent : Colors.white10,
                                ),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  d.brand == ScaleBrand.simulated ? CupertinoIcons.sparkles : CupertinoIcons.bluetooth,
                                  color: isCur ? Colors.blueAccent : AppTheme.accentGold,
                                ),
                                title: Text(
                                  d.name,
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                subtitle: Text(
                                  d.brandLabel,
                                  style: const TextStyle(fontSize: 10.5, color: Colors.white54),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () async {
                                    if (isCur) {
                                      await _scaleService.disconnect();
                                    } else {
                                      await _scaleService.connect(d);
                                    }
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCur ? Colors.redAccent : AppTheme.primaryBrown,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    isCur ? (isEn ? 'Disconnect' : 'Putus') : (isEn ? 'Connect' : 'Hubungkan'),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                        },
                      ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ExtractionChartPainter extends CustomPainter {
  final List<WeightDataPoint> dataPoints;

  _ExtractionChartPainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double maxWeight = math.max(50.0, dataPoints.map((d) => d.weight).reduce(math.max));
    const double maxFlow = 8.0;

    final weightPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final flowPaint = Paint()
      ..color = AppTheme.accentGold
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path weightPath = Path();
    final Path flowPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length > 1 ? dataPoints.length - 1 : 1)) * size.width;
      final yWeight = size.height - ((dataPoints[i].weight / maxWeight) * size.height).clamp(0.0, size.height);
      final yFlow = size.height - ((dataPoints[i].flowRate / maxFlow) * size.height).clamp(0.0, size.height);

      if (i == 0) {
        weightPath.moveTo(x, yWeight);
        flowPath.moveTo(x, yFlow);
      } else {
        weightPath.lineTo(x, yWeight);
        flowPath.lineTo(x, yFlow);
      }
    }

    canvas.drawPath(weightPath, weightPaint);
    canvas.drawPath(flowPath, flowPaint);
  }

  @override
  bool shouldRepaint(covariant _ExtractionChartPainter oldDelegate) {
    return true;
  }
}
