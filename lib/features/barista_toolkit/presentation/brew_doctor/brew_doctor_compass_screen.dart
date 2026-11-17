import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../screens/brew_timer_screen.dart';
import '../../../../theme/app_theme.dart';
import '../../data/barista_toolkit_api_service.dart';
import '../../domain/barista_toolkit_models.dart';

class BrewDoctorCompassScreen extends ConsumerStatefulWidget {
  const BrewDoctorCompassScreen({super.key});

  @override
  ConsumerState<BrewDoctorCompassScreen> createState() =>
      _BrewDoctorCompassScreenState();
}

class _BrewDoctorCompassScreenState
    extends ConsumerState<BrewDoctorCompassScreen> {
  final Set<String> _selectedSymptoms = {'sour'};
  double _doseG = 15.0;
  double _waterMl = 225.0;
  double _tempC = 92.0;
  final int _targetSec = 145;
  int _actualSec = 125;

  BrewDoctorDiagnosisModel? _diagnosis;
  bool _loading = false;

  static const List<({String tag, String label})> _symptomOptions = [
    (tag: 'sour', label: 'Asam Tajam (Sour)'),
    (tag: 'salty', label: 'Asin / Gurih Tipis'),
    (tag: 'bitter', label: 'Pahit Tajam (Bitter)'),
    (tag: 'astringent', label: 'Sepat Kering (Dry)'),
    (tag: 'channeling', label: 'Asam + Pahit Bersamaan'),
    (tag: 'weak', label: 'Encer (Weak / Watery)'),
    (tag: 'heavy', label: 'Terlalu Pekat / Berat'),
    (tag: 'quick_finish', label: 'Drawdown Terlalu Cepat'),
  ];

  @override
  void initState() {
    super.initState();
    _diagnosis = BaristaToolkitApiService.diagnoseOfflineFallback(
      symptomTags: _selectedSymptoms.toList(),
      doseG: _doseG,
      waterMl: _waterMl,
      tempC: _tempC,
      targetSec: _targetSec,
      actualSec: _actualSec,
    );
  }

  Future<void> _runDiagnosis() async {
    setState(() => _loading = true);
    final res = await ref.read(baristaToolkitApiProvider).diagnoseBrew(
          symptomTags: _selectedSymptoms.toList(),
          doseG: _doseG,
          waterMl: _waterMl,
          tempC: _tempC,
          targetSec: _targetSec,
          actualSec: _actualSec,
        );
    if (!mounted) return;
    setState(() {
      _diagnosis = res;
      _loading = false;
    });
  }

  void _openCalibratedBrewTimer(BrewDoctorDiagnosisModel d) {
    final calibratedTemp = (_tempC + d.tempCDelta).clamp(80, 96).round();
    final ratioVal = double.tryParse(d.recommendedRatio.replaceFirst('1:', '')) ?? 15.0;
    final calibratedWater = (_doseG * ratioVal).round();
    final bloomWater = (_doseG * 2.5).round();
    final secondPour = ((calibratedWater - bloomWater) * 0.5).round();
    final finalPour = calibratedWater - bloomWater - secondPour;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrewTimerScreen(
          recipeData: {
            'title': 'V60 Kalibrasi Brew Doctor (${d.recommendedRatio})',
            'method': 'V60',
            'coffeeWeightGrams': _doseG.round(),
            'totalWaterWeightGrams': calibratedWater,
            'waterTempCelsius': calibratedTemp,
            'iceWeightGrams': 0,
            'steps': [
              {
                'title': 'Blooming CO2',
                'instruction':
                    'Tuang ${bloomWater}ml air $calibratedTemp°C secara merata lalu Rao Spin lembut.',
                'durationSeconds': 35,
                'waterAddedGrams': bloomWater,
              },
              {
                'title': 'Tuangan Kedua (Spiral)',
                'instruction':
                    'Tuang melingkar tenang di tengah hingga total ${bloomWater + secondPour}ml.',
                'durationSeconds': 45,
                'waterAddedGrams': secondPour,
              },
              {
                'title': 'Tuangan Akhir & Drawdown',
                'instruction':
                    'Selesaikan hingga ${calibratedWater}ml (${d.pourTechniqueAdvice}).',
                'durationSeconds': (_targetSec - 80).clamp(40, 90),
                'waterAddedGrams': finalPour,
              },
            ],
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diag = _diagnosis;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        title: const Text(
          'Brew Doctor & Kompas SCA',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          // 2D SCA Extraction vs Strength Compass
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE7DDD3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.explore_rounded, color: AppTheme.primaryBrown, size: 20),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Kompas Sensorik & Ekstraksi SCA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    if (diag != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        'EY ${diag.estimatedEyPct}% • TDS ${diag.estimatedTdsPct}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 1.42,
                  child: CustomPaint(
                    painter: _ScaCompassPainter(
                      xExtraction: diag?.xExtraction ?? 0.0,
                      yStrength: diag?.yStrength ?? 0.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Text(
            'Gejala Rasa Cangkir Saat Ini',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptomOptions.map((opt) {
              final active = _selectedSymptoms.contains(opt.tag);
              return FilterChip(
                label: Text(opt.label),
                selected: active,
                selectedColor: AppTheme.primaryBrown,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppTheme.textDark,
                ),
                onSelected: (sel) {
                  setState(() {
                    if (sel) {
                      _selectedSymptoms.add(opt.tag);
                    } else {
                      _selectedSymptoms.remove(opt.tag);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7DDD3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parameter Seduh Terakhir',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                _paramSlider(
                  label: 'Dosis Kopi',
                  valueLabel: '${_doseG.round()} g',
                  value: _doseG,
                  min: 10,
                  max: 30,
                  onChanged: (v) => setState(() => _doseG = v),
                ),
                _paramSlider(
                  label: 'Total Air',
                  valueLabel: '${_waterMl.round()} ml',
                  value: _waterMl,
                  min: 150,
                  max: 500,
                  onChanged: (v) => setState(() => _waterMl = v),
                ),
                _paramSlider(
                  label: 'Suhu Air',
                  valueLabel: '${_tempC.round()}°C',
                  value: _tempC,
                  min: 80,
                  max: 96,
                  onChanged: (v) => setState(() => _tempC = v),
                ),
                _paramSlider(
                  label: 'Waktu Drawdown Aktual',
                  valueLabel: '${_actualSec}s (Target ${_targetSec}s)',
                  value: _actualSec.toDouble(),
                  min: 60,
                  max: 240,
                  onChanged: (v) => setState(() => _actualSec = v.round()),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _loading ? null : _runDiagnosis,
              icon: const Icon(Icons.medical_services_rounded),
              label: Text(
                _loading ? 'Menganalisis...' : 'Analisa & Buat Resep Koreksi',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),

          if (diag != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EE),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_fix_high_rounded, color: AppTheme.primaryBrown),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          diag.diagnosisTitle,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _rxChip(
                        'Grinder',
                        diag.grindClicksDelta == 0
                            ? 'Tetap'
                            : (diag.grindClicksDelta > 0
                                ? '+${diag.grindClicksDelta} klik (Kasar)'
                                : '${diag.grindClicksDelta} klik (Halus)'),
                      ),
                      _rxChip(
                        'Suhu',
                        diag.tempCDelta == 0
                            ? 'Tetap'
                            : (diag.tempCDelta > 0
                                ? '+${diag.tempCDelta}°C'
                                : '${diag.tempCDelta}°C'),
                      ),
                      _rxChip('Rasio Saran', diag.recommendedRatio),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(diag.explanation, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    'Saran Teknik: ${diag.pourTechniqueAdvice}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBrown,
                        side: const BorderSide(color: AppTheme.primaryBrown),
                      ),
                      onPressed: () => _openCalibratedBrewTimer(diag),
                      icon: const Icon(Icons.timer_rounded),
                      label: const Text('Buka Brew Timer dengan Parameter Baru'),
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

  Widget _paramSlider({
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(valueLabel, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: AppTheme.primaryBrown,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _rxChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0D4C8)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ScaCompassPainter extends CustomPainter {
  final double xExtraction;
  final double yStrength;

  _ScaCompassPainter({required this.xExtraction, required this.yStrength});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Zona Ideal SCA Golden Cup di tengah
    final idealRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.34,
      height: size.height * 0.34,
    );
    canvas.drawRect(
      idealRect,
      Paint()..color = const Color(0xFF2E7D32).withValues(alpha: 0.14),
    );
    canvas.drawRect(
      idealRect,
      Paint()
        ..color = const Color(0xFF2E7D32).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Sumbu silang X (Extraction) & Y (Strength)
    final axisPaint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(10, center.dy), Offset(size.width - 10, center.dy), axisPaint);
    canvas.drawLine(Offset(center.dx, 10), Offset(center.dx, size.height - 10), axisPaint);

    // Label 4 kuadran & tengah
    _drawLabel(canvas, 'SOUR / UNDER', Offset(8, center.dy - 18), const Color(0xFFD97706));
    _drawLabel(canvas, 'BITTER / OVER', Offset(size.width - 96, center.dy - 18), const Color(0xFFDC2626));
    _drawLabel(canvas, 'STRONG', Offset(center.dx + 6, 8), const Color(0xFF5D4037));
    _drawLabel(canvas, 'WEAK / WATERY', Offset(center.dx + 6, size.height - 22), const Color(0xFF0284C7));
    _drawLabel(canvas, 'GOLDEN CUP', Offset(center.dx - 34, center.dy + 6), const Color(0xFF2E7D32));

    // Titik koordinat hasil cangkir saat ini
    final dotX = center.dx + xExtraction.clamp(-1.0, 1.0) * (size.width * 0.42);
    final dotY = center.dy - yStrength.clamp(-1.0, 1.0) * (size.height * 0.42);
    final dotPos = Offset(dotX, dotY);

    canvas.drawCircle(
      dotPos,
      12,
      Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.32),
    );
    canvas.drawCircle(
      dotPos,
      6.5,
      Paint()..color = const Color(0xFF5C3A21),
    );
    canvas.drawCircle(
      dotPos,
      6.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  void _drawLabel(Canvas canvas, String text, Offset offset, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ScaCompassPainter oldDelegate) =>
      oldDelegate.xExtraction != xExtraction || oldDelegate.yStrength != yStrength;
}
