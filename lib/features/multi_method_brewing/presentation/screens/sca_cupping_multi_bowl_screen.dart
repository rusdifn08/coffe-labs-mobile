import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';

/// Studio Khusus SCA Coffee Cupping 15 Menit dengan Formulir Penilaian Sensorik Langsung.
class ScaCuppingMultiBowlScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const ScaCuppingMultiBowlScreen({super.key, required this.recipe});

  @override
  State<ScaCuppingMultiBowlScreen> createState() =>
      _ScaCuppingMultiBowlScreenState();
}

class _ScaCuppingMultiBowlScreenState extends State<ScaCuppingMultiBowlScreen> {
  static const int _totalSec = 900; // 15 Menit Protokol Resmi SCA
  int _elapsedSec = 0;
  bool _running = false;
  Timer? _timer;

  final Map<String, double> _scores = {
    'Fragrance/Aroma': 8.0,
    'Flavor': 8.25,
    'Aftertaste': 8.0,
    'Acidity': 8.25,
    'Body': 8.0,
    'Balance': 8.0,
  };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_elapsedSec < _totalSec) {
          setState(() => _elapsedSec++);
        } else {
          _timer?.cancel();
          setState(() => _running = false);
        }
      });
    }
  }

  String get _currentMilestone {
    if (_elapsedSec < 30) return '00:00–00:30 · Tuang Air Panas 93°C ke Mangkuk';
    if (_elapsedSec < 240) return '00:30–04:00 · Diamkan Kerak (Wet Crust Steep)';
    if (_elapsedSec < 480) return '04:00–08:00 · Break Crust 3x & Skim Busa!';
    if (_elapsedSec < 600) return '08:00–10:00 · Pendinginan Stabil ke ~70°C';
    return '10:00–15:00 · Slurp Evaluasi Panas -> Hangat -> Dingin!';
  }

  double get _computedScaTotal {
    final sixAttrs = _scores.values.fold(0.0, (a, b) => a + b);
    // Standar Uniformity + Clean Cup + Sweetness = 30.0 + Overall 8.0 = 38 baseline
    return sixAttrs + 38.0;
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_elapsedSec ~/ 60).toString().padLeft(2, '0');
    final ss = (_elapsedSec % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text(
          'SCA 15-Min Cupping Session',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.recipe['title']?.toString() ?? 'SCA Cupping',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$mm:$ss / 15:00',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBrown,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentMilestone,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0E7490),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleTimer,
                          icon: Icon(
                            _running
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(_running ? 'Jeda Sesi' : 'Mulai 15:00 Timer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _timer?.cancel();
                            setState(() {
                              _running = false;
                              _elapsedSec = 0;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Skor Sensorik SCA',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Final: ${_computedScaTotal.toStringAsFixed(2)} pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._scores.entries.map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderWarm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            e.value.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: e.value,
                        min: 6.0,
                        max: 10.0,
                        divisions: 16,
                        activeColor: AppTheme.primaryBrown,
                        onChanged: (v) => setState(() => _scores[e.key] = v),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
