import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import '../services/trial_service.dart';
import 'brew_journal_screen.dart';

class BrewTimerScreen extends StatefulWidget {
  final dynamic recipeData;

  const BrewTimerScreen({super.key, required this.recipeData});

  @override
  State<BrewTimerScreen> createState() => _BrewTimerScreenState();
}

class _BrewTimerScreenState extends State<BrewTimerScreen> {
  Timer? _timer;
  Timer? _prepTimer;

  int _elapsedSeconds = 0;
  int _prepSeconds = 5;

  bool _isRunning = false;
  bool _isPreparing = false;

  final ScrollController _stepScrollController = ScrollController();
  int _lastScrolledStepIndex = -1;

  late Map<String, dynamic> _recipe;
  late String title;
  late int totalSeconds;
  late int iceWeightGrams;
  late int totalWaterGrams;
  late int waterTempCelsius;
  late List<Map<String, dynamic>> steps;

  static int _stepDuration(Map<String, dynamic> step) {
    final val = step['durationSeconds'] ?? step['timeSeconds'] ?? 30;
    return val is int ? val : (val as num).toInt();
  }

  static int _stepWater(Map<String, dynamic> step) {
    final val = step['waterAddedGrams'] ?? step['waterGrams'] ?? 0;
    return val is int ? val : (val as num).toInt();
  }

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipeData is Map
        ? ApiService.sanitizeRecipe(widget.recipeData as Map)
        : ApiService.sanitizeRecipe({});
    title = _recipe['title'] as String;
    iceWeightGrams = _recipe['iceWeightGrams'] as int;
    totalWaterGrams = _recipe['totalWaterWeightGrams'] as int;
    waterTempCelsius = _recipe['waterTempCelsius'] as int;
    steps = (_recipe['steps'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    _recomputeTotalSeconds();
    ApiService.recordBrew(_recipe);
    TrialService.recordTrialBrew();
  }

  void _recomputeTotalSeconds() {
    int computedTotal = 0;
    for (final s in steps) {
      computedTotal += _stepDuration(s);
    }
    totalSeconds = computedTotal > 0 ? computedTotal : (_recipe['totalTimeSeconds'] as int);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _prepTimer?.cancel();
    AudioService.stopBgm();
    _stepScrollController.dispose();
    super.dispose();
  }

  void _checkAutoScroll() {
    if (steps.isEmpty) return;
    final activeIndex = _getActiveStepIndex();
    if (activeIndex != _lastScrolledStepIndex) {
      _lastScrolledStepIndex = activeIndex;
      _scrollToStep(activeIndex);
    }
  }

  void _scrollToStep(int index) {
    if (!_stepScrollController.hasClients) return;
    final double targetOffset = (index * 115.0).clamp(0.0, _stepScrollController.position.maxScrollExtent);
    _stepScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _startMainTimer() {
    _prepTimer?.cancel();
    setState(() {
      _isPreparing = false;
      _isRunning = true;
    });

    AudioService.startBgm();
    _checkAutoScroll();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_elapsedSeconds < totalSeconds) {
        setState(() => _elapsedSeconds++);
        _checkAutoScroll();

        // Pastikan background music tetap berputar lancar tanpa terhenti oleh OS
        if (_elapsedSeconds % 2 == 0) {
          AudioService.ensureBgmPlaying();
        }

        int accumulated = 0;
        for (final step in steps) {
          accumulated += _stepDuration(step);
          if (accumulated > _elapsedSeconds) {
            final int left = accumulated - _elapsedSeconds;
            if (left <= 5 && left > 0) {
              AudioService.playTick();
            }
            break;
          } else if (accumulated == _elapsedSeconds && _elapsedSeconds != totalSeconds) {
            AudioService.playTransition();
          }
        }
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        AudioService.stopBgm();
        AudioService.playEnjoy();
        _promptJournal();
      }
    });
  }

  bool _isEndingSoon() {
    if (_isPreparing) return false;
    int accumulated = 0;
    for (final step in steps) {
      accumulated += _stepDuration(step);
      if (accumulated > _elapsedSeconds) {
        final int left = accumulated - _elapsedSeconds;
        return left <= 5 && left > 0;
      }
    }
    return false;
  }

  void _toggleTimer() {
    if (_isRunning || _isPreparing) {
      _timer?.cancel();
      _prepTimer?.cancel();
      AudioService.stopBgm();
      setState(() {
        _isRunning = false;
        _isPreparing = false;
      });
    } else {
      if (_elapsedSeconds >= totalSeconds) {
        _resetTimer();
      }
      if (_elapsedSeconds == 0 && _prepSeconds > 0) {
        setState(() => _isPreparing = true);
        _prepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_prepSeconds > 1) {
            AudioService.playTick();
            setState(() => _prepSeconds--);
          } else {
            _prepTimer?.cancel();
            AudioService.playTransition();
            _startMainTimer();
          }
        });
      } else {
        _startMainTimer();
      }
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _prepTimer?.cancel();
    AudioService.stopBgm();
    setState(() {
      _elapsedSeconds = 0;
      _prepSeconds = 5;
      _isRunning = false;
      _isPreparing = false;
    });
    _lastScrolledStepIndex = 0;
    _scrollToStep(0);
  }

  void _jumpToStep(int targetIndex) {
    if (steps.isEmpty) return;
    final clamped = targetIndex.clamp(0, steps.length - 1);
    int startSec = 0;
    for (int i = 0; i < clamped; i++) {
      startSec += _stepDuration(steps[i]);
    }
    setState(() {
      if (_isPreparing) {
        _prepTimer?.cancel();
        _isPreparing = false;
      }
      _elapsedSeconds = startSec;
    });
    _lastScrolledStepIndex = clamped;
    _scrollToStep(clamped);
  }

  void _add10SecondsToActiveStep() {
    if (steps.isEmpty) return;
    final idx = _getActiveStepIndex();
    final curDur = _stepDuration(steps[idx]);
    setState(() {
      steps[idx]['durationSeconds'] = curDur + 10;
      steps[idx]['timeSeconds'] = curDur + 10;
      _recomputeTotalSeconds();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ditambahkan +10 detik pada Tahap ${idx + 1}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showDialInDoctorSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Brew Doctor (Panduan Koreksi Rasa)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _doctorTipCard(
              icon: CupertinoIcons.bolt_fill,
              color: Colors.orange,
              title: 'Terlalu Asam / Kecut / Tipis (Under-Extracted)',
              fix: '• Haluskan gilingan 1–2 klik\n• Naikkan suhu air +2°C\n• Tuang sedikit lebih lambat atau tambah waktu bloom.',
            ),
            _doctorTipCard(
              icon: CupertinoIcons.flame_fill,
              color: Colors.redAccent,
              title: 'Terlalu Pahit / Sepat / Kering (Over-Extracted)',
              fix: '• Kasarkan gilingan 1–2 klik\n• Turunkan suhu air -2°C\n• Kurangi goyangan (swirl) dan tuang lebih lembut di tengah.',
            ),
            _doctorTipCard(
              icon: CupertinoIcons.drop,
              color: Colors.blueAccent,
              title: 'Kurang Body / Terlalu Encer (Weak)',
              fix: '• Gunakan rasio lebih pendek (misal 1:14 atau 1:15)\n• Tambahkan dosis kopi +1g hingga +2g.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _doctorTipCard({
    required IconData icon,
    required Color color,
    required String title,
    required String fix,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(fix, style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCompactSensorySlider({
    required String label,
    required double value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: activeColor,
                inactiveTrackColor: activeColor.withValues(alpha: 0.18),
                thumbColor: activeColor,
                overlayColor: activeColor.withValues(alpha: 0.15),
              ),
              child: Slider(
                value: value,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 26,
            child: Text(
              value.toStringAsFixed(1),
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: activeColor),
            ),
          ),
        ],
      ),
    );
  }

  void _promptJournal() {
    if (!mounted) return;
    double acidity = 3.0;
    double sweetness = 3.5;
    double bitterness = 2.0;
    double body = 3.0;
    double overallScore = 4.5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // Dynamic Live Diagnosis & Advice
          String status = 'Harmonis & Nikmat 👍';
          String badge = 'SWEET SPOT';
          IconData icon = CupertinoIcons.checkmark_circle_fill;
          Color color = Colors.green.shade700;
          Color bgColor = Colors.green.withValues(alpha: 0.08);
          String advice = '✨ Keseimbangan rasa manis dan keasaman sangat ideal!';

          if (bitterness >= 4.0 || (bitterness - sweetness >= 1.5)) {
            status = 'Over-Extracted (Terlalu Pahit & Sepat)';
            badge = 'OVER-EXTRACTED';
            icon = CupertinoIcons.exclamationmark_triangle_fill;
            color = Colors.redAccent;
            bgColor = Colors.red.withValues(alpha: 0.08);
            advice = '💡 Kasarkan gilingan 1-2 klik atau turunkan suhu air -2°C.';
          } else if (acidity >= 4.0 && sweetness <= 2.5) {
            status = 'Under-Extracted (Asam Tajam / Tipis)';
            badge = 'UNDER-EXTRACTED';
            icon = CupertinoIcons.bolt_fill;
            color = Colors.orange.shade800;
            bgColor = Colors.orange.withValues(alpha: 0.08);
            advice = '💡 Haluskan gilingan 1-2 klik atau naikkan suhu air +2°C.';
          } else if (body <= 1.5) {
            status = 'Under-Body (Seduhan Terlalu Encer)';
            badge = 'LOW BODY';
            icon = CupertinoIcons.drop;
            color = Colors.blueGrey;
            bgColor = Colors.blueGrey.withValues(alpha: 0.08);
            advice = '💡 Perpanjang waktu blooming 10-15s atau percepat tuang pour.';
          } else if (sweetness >= 3.5 && bitterness <= 2.5 && acidity >= 2.5 && acidity <= 3.5) {
            status = 'Sweet Spot! Ekstraksi Seimbang 🎯';
            badge = 'SWEET SPOT';
            icon = CupertinoIcons.checkmark_circle_fill;
            color = Colors.green.shade700;
            bgColor = Colors.green.withValues(alpha: 0.08);
            advice = '✨ Keseimbangan rasa manis dan keasaman sangat ideal!';
          }

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(CupertinoIcons.flame_fill, color: AppTheme.primaryBrown, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Evaluasi Hasil Seduh',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                            ),
                            Text(
                              _recipe['title']?.toString() ?? 'Seduhan Kopi',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.star_fill, size: 12, color: AppTheme.accentAmber),
                            const SizedBox(width: 4),
                            Text(
                              overallScore.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Compact Sensory Sliders
                  _buildCompactSensorySlider(
                    label: 'Keasaman (Acidity)',
                    value: acidity,
                    activeColor: Colors.amber.shade700,
                    onChanged: (v) => setDialogState(() => acidity = v),
                  ),
                  _buildCompactSensorySlider(
                    label: 'Kemanisan (Sweetness)',
                    value: sweetness,
                    activeColor: Colors.deepOrangeAccent,
                    onChanged: (v) => setDialogState(() => sweetness = v),
                  ),
                  _buildCompactSensorySlider(
                    label: 'Kepahitan (Bitterness)',
                    value: bitterness,
                    activeColor: Colors.brown.shade700,
                    onChanged: (v) => setDialogState(() => bitterness = v),
                  ),
                  _buildCompactSensorySlider(
                    label: 'Ketebalan (Body)',
                    value: body,
                    activeColor: Colors.teal.shade700,
                    onChanged: (v) => setDialogState(() => body = v),
                  ),
                  _buildCompactSensorySlider(
                    label: 'Skor Keseluruhan',
                    value: overallScore,
                    activeColor: AppTheme.primaryBrown,
                    onChanged: (v) => setDialogState(() => overallScore = v),
                  ),

                  const SizedBox(height: 8),

                  // Smart Diagnosis Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(icon, size: 13, color: color),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          advice,
                          style: const TextStyle(fontSize: 10.5, color: AppTheme.textDark, height: 1.25),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.25)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Lewati', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 1,
                          ),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await ApiService.addJournalEntry({
                              'recipeId': _recipe['id'],
                              'recipeTitle': _recipe['title'],
                              'author': _recipe['author'],
                              'authorAvatarUrl': _recipe['authorAvatarUrl'],
                              'authorImageUrl': _recipe['coverImageUrl'],
                              'grindNote': '${_recipe['grindSize'] ?? ''} • $badge',
                              'rating': overallScore,
                              'notes': '$status | Asam: ${acidity.toStringAsFixed(1)}, Manis: ${sweetness.toStringAsFixed(1)}, Pahit: ${bitterness.toStringAsFixed(1)}, Body: ${body.toStringAsFixed(1)}. $advice',
                            });
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Tersimpan di Jurnal Brew.'),
                                action: SnackBarAction(
                                  label: 'Buka',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(CupertinoIcons.bookmark_fill, size: 13),
                          label: const Text('Simpan ke Jurnal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int _getActiveStepIndex() {
    int accumulated = 0;
    for (int i = 0; i < steps.length; i++) {
      accumulated += _stepDuration(steps[i]);
      if (_elapsedSeconds < accumulated || (_elapsedSeconds == accumulated && _elapsedSeconds == totalSeconds)) {
        return i;
      }
    }
    return steps.length - 1;
  }

  int _getStepRemainingSeconds(int activeIdx) {
    if (activeIdx < 0 || activeIdx >= steps.length) return 0;
    int accumulated = 0;
    for (int i = 0; i <= activeIdx; i++) {
      accumulated += _stepDuration(steps[i]);
    }
    return (accumulated - _elapsedSeconds).clamp(0, 3600);
  }

  int _getCumulativeWaterUpTo(int stepIdx) {
    int sum = 0;
    for (int i = 0; i <= stepIdx && i < steps.length; i++) {
      sum += _stepWater(steps[i]);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    int activeIndex = (_elapsedSeconds > 0 || _isRunning) ? _getActiveStepIndex() : 0;
    if (_elapsedSeconds >= totalSeconds && steps.isNotEmpty) activeIndex = steps.length - 1;

    final activeStep = steps.isNotEmpty ? steps[activeIndex] : null;
    final activeTargetWater = activeStep != null ? _getCumulativeWaterUpTo(activeIndex) : 0;
    final activeStepRemaining = _getStepRemainingSeconds(activeIndex);

    int runningWater = 0;
    int runningTime = 0;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Brew Doctor (Saran Koreksi Rasa)',
            icon: const Icon(CupertinoIcons.lightbulb, size: 20),
            onPressed: _showDialInDoctorSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Japanese Iced: Siapkan es di server sebelum mulai seduh (hilang setelah hitung mundur 5 detik selesai)
          if (iceWeightGrams > 0 && (_isPreparing || _elapsedSeconds == 0))
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.lightBlue.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.snow, size: 16, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Japanese Iced: Siapkan ${iceWeightGrams}g Es di Server + ${totalWaterGrams}g Air Panas ($waterTempCelsius°C)',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 6),
          // CIRCULAR TIMER DISPLAY (Diperbesar sedikit, info timbangan flow rate dihilangkan)
          Center(
            child: SizedBox(
              width: 245,
              height: 245,
              child: CustomPaint(
                painter: SegmentedTimerPainter(
                  steps: steps,
                  totalSeconds: totalSeconds,
                  elapsedSeconds: _elapsedSeconds,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isPreparing) ...[
                        const Text(
                          'SIAP SEDUH',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$_prepSeconds',
                          style: const TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentAmber,
                          ),
                        ),
                        TextButton(
                          onPressed: _startMainTimer,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          ),
                          child: const Text(
                            'Lewati Hitung Mundur →',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                          ),
                        ),
                      ] else if (_elapsedSeconds > 0 && _elapsedSeconds >= totalSeconds) ...[
                        const Text(
                          'Enjoy your',
                          style: TextStyle(color: AppTheme.primaryBrown, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'coffee!',
                          style: TextStyle(color: AppTheme.primaryBrown, fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ] else ...[
                        Text(
                          _formatTime(_elapsedSeconds),
                          style: TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.bold,
                            color: _isEndingSoon() ? Colors.red : AppTheme.primaryBrown,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Target ${_formatTime(totalSeconds)} · ${activeTargetWater}g',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // SCROLLABLE STEPS LIST (Auto Scroll & Auto Switch, Active step di-highlight coklat elegan)
          Expanded(
            child: ListView.builder(
              controller: _stepScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final int stepWater = _stepWater(step);
                final int stepDur = _stepDuration(step);
                final int startSec = runningTime;
                runningTime += stepDur;
                final int endSec = runningTime;
                runningWater += stepWater;
                final int cumulativeTarget = runningWater;

                final bool isActive = index == activeIndex && !_isPreparing && (_isRunning || _elapsedSeconds > 0);
                final bool isDone = _elapsedSeconds > 0 && (index < activeIndex || _elapsedSeconds >= totalSeconds);
                final Color stepColor = _getColorForStep(index);
                final String instruction = step['instruction']?.toString() ?? '';

                return GestureDetector(
                  onTap: () => _jumpToStep(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive ? AppTheme.accentAmber : AppTheme.primaryBrown.withValues(alpha: 0.1),
                        width: isActive ? 1.8 : 1.0,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBrown.withValues(alpha: 0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? Colors.green.shade600
                                    : (isActive
                                        ? AppTheme.accentAmber
                                        : stepColor.withValues(alpha: 0.2)),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isDone
                                    ? const Icon(CupertinoIcons.check_mark, color: Colors.white, size: 18)
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: isActive ? Colors.white : stepColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          step['title']?.toString() ?? 'Step ${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isActive ? 15 : 13.5,
                                            color: isActive ? Colors.white : AppTheme.textDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isActive) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentAmber,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${activeStepRemaining}s',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(
                                        stepWater > 0 ? CupertinoIcons.drop_fill : CupertinoIcons.timer,
                                        size: 12,
                                        color: isActive
                                            ? AppTheme.accentAmber
                                            : (stepWater > 0 ? Colors.blueAccent : AppTheme.accentAmber),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          stepWater > 0
                                              ? '+${stepWater}g Air (Target: ${cumulativeTarget}g)'
                                              : 'Imersi / Drawdown (Total: ${cumulativeTarget}g)',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: isActive ? Colors.white.withValues(alpha: 0.9) : AppTheme.textMuted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatTime(stepDur),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isActive ? Colors.white : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  '${_formatTime(startSec)}-${_formatTime(endSec)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isActive ? Colors.white70 : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (instruction.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: isActive
                                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                                : EdgeInsets.zero,
                            decoration: isActive
                                ? BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                : null,
                            child: Text(
                              instruction,
                              style: TextStyle(
                                fontSize: 12,
                                color: isActive ? Colors.white.withValues(alpha: 0.95) : AppTheme.textMuted,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // BOTTOM CONTROL PANEL WITH QUICK STEP CONTROLS
          Container(
            padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10)),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: 'Tahap Sebelumnya',
                  onPressed: activeIndex > 0 ? () => _jumpToStep(activeIndex - 1) : null,
                  icon: const Icon(CupertinoIcons.backward_end_fill, color: AppTheme.primaryBrown),
                ),
                FloatingActionButton.small(
                  heroTag: 'reset',
                  tooltip: 'Reset Timer',
                  backgroundColor: AppTheme.bgCream,
                  elevation: 0,
                  onPressed: _resetTimer,
                  child: const Icon(CupertinoIcons.refresh, color: AppTheme.primaryBrown, size: 18),
                ),
                SizedBox(
                  width: 68,
                  height: 68,
                  child: FloatingActionButton(
                    heroTag: 'playpause',
                    backgroundColor: AppTheme.primaryBrown,
                    elevation: 4,
                    onPressed: _toggleTimer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    child: Icon(
                      _isRunning || _isPreparing ? CupertinoIcons.pause_solid : CupertinoIcons.play_arrow_solid,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _add10SecondsToActiveStep,
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.bgCream,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    '+10d',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBrown),
                  ),
                ),
                IconButton(
                  tooltip: 'Tahap Berikutnya',
                  onPressed: activeIndex < steps.length - 1 ? () => _jumpToStep(activeIndex + 1) : null,
                  icon: const Icon(CupertinoIcons.forward_end_fill, color: AppTheme.primaryBrown),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _getColorForStep(int index) {
  const List<Color> colors = [
    Colors.blueAccent,
    Colors.green,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.amber,
    Colors.redAccent,
  ];
  return colors[index % colors.length];
}

class SegmentedTimerPainter extends CustomPainter {
  final List<dynamic> steps;
  final num totalSeconds;
  final num elapsedSeconds;

  SegmentedTimerPainter({required this.steps, required this.totalSeconds, required this.elapsedSeconds});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 18.0;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - strokeWidth / 2,
    );

    final Paint trackPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - strokeWidth / 2, trackPaint);

    if (totalSeconds <= 0) return;

    double startAngle = -pi / 2;
    double currentElapsed = elapsedSeconds.toDouble();

    for (int i = 0; i < steps.length; i++) {
      final double stepSecs = (steps[i]['durationSeconds'] ?? steps[i]['timeSeconds'] ?? 0).toDouble();
      final double sweepAngle = (stepSecs / totalSeconds) * 2 * pi;

      final Color stepColor = _getColorForStep(i);

      final Paint segmentPaint = Paint()
        ..color = stepColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = strokeWidth;

      canvas.drawArc(rect, startAngle, max(0.01, sweepAngle - 0.05), false, segmentPaint);

      if (currentElapsed > 0) {
        final double filledSecs = min(currentElapsed, stepSecs);
        final double filledSweepAngle = (filledSecs / totalSeconds) * 2 * pi;

        final Paint filledPaint = Paint()
          ..color = stepColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth + 2;

        canvas.drawArc(rect, startAngle, filledSweepAngle, false, filledPaint);
        currentElapsed -= filledSecs;
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant SegmentedTimerPainter oldDelegate) {
    return oldDelegate.elapsedSeconds != elapsedSeconds || oldDelegate.totalSeconds != totalSeconds;
  }
}
