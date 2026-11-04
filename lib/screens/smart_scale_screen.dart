import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/smart_scale/controllers/smart_scale_controller.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/smart_scale/widgets/extraction_chart_painter.dart';
import '../features/smart_scale/widgets/scale_device_sheet.dart';
import '../features/smart_scale/widgets/scale_device_status_banner.dart';
import '../features/smart_scale/widgets/scale_flow_rate_gauge.dart';
import '../features/smart_scale/widgets/scale_ratio_calculator_card.dart';
import '../features/smart_scale/widgets/scale_simulation_card.dart';
import '../models/smart_scale_model.dart';
import '../services/language_service.dart';
import '../services/smart_scale_service.dart';
import '../theme/app_theme.dart';
import 'brew_selection_screen.dart';

class SmartScaleScreen extends ConsumerStatefulWidget {
  const SmartScaleScreen({super.key});

  @override
  ConsumerState<SmartScaleScreen> createState() => _SmartScaleScreenState();
}

class _SmartScaleScreenState extends ConsumerState<SmartScaleScreen> {
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
    final scaleState = ref.watch(smartScaleControllerProvider);
    final isConnected = scaleState.isConnected;
    final currentDevice = scaleState.activeDevice;
    final weight = scaleState.currentWeight;
    final flowRate = scaleState.flowRate;
    final isStable = _scaleService.isStable;

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
            onPressed: () => ScaleDeviceSheet.show(context, _scaleService),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          children: [
            // 1. Device Connection Status Banner
            ScaleDeviceStatusBanner(
              isEn: isEn,
              isConnected: isConnected,
              currentDevice: currentDevice,
              onOpenSheet: () => ScaleDeviceSheet.show(context, _scaleService),
            ),
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
                  ScaleFlowRateGauge(flowRate: flowRate, isEn: isEn),
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
                        painter: ExtractionChartPainter(dataPoints: _dataPoints),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Barista Ratio Calculator & Progress Target Ring
            ScaleRatioCalculatorCard(
              isEn: isEn,
              coffeeDoseGrams: _coffeeDoseGrams,
              selectedRatio: _selectedRatio,
              currentWeight: weight,
              onDoseChanged: (d) => setState(() => _coffeeDoseGrams = d),
              onRatioChanged: (r) => setState(() => _selectedRatio = r),
            ),

            // 5. Virtual Scale Interactive Simulation (if active)
            if (_scaleService.isSimulationMode) ...[
              const SizedBox(height: 16),
              ScaleSimulationCard(
                isEn: isEn,
                scaleService: _scaleService,
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

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }
}
