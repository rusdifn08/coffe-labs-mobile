import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/audio_service.dart';
import '../../../../services/coffee_translator.dart';
import '../../tts/brewing_tts_service.dart';

class BaristaEspressoCockpit extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final List<Map<String, dynamic>> steps;
  final VoidCallback onFinishBrew;
  final VoidCallback onPrintReceipt;
  final VoidCallback onShowDoctor;
  final bool isEn;

  const BaristaEspressoCockpit({
    super.key,
    required this.recipe,
    required this.steps,
    required this.onFinishBrew,
    required this.onPrintReceipt,
    required this.onShowDoctor,
    required this.isEn,
  });

  @override
  State<BaristaEspressoCockpit> createState() => _BaristaEspressoCockpitState();
}

class _BaristaEspressoCockpitState extends State<BaristaEspressoCockpit> {
  int _activeStageIndex = 0;
  final Set<int> _completedStages = {};

  // Precision Shot Stopwatch
  Timer? _shotTimer;
  int _shotMilliseconds = 0;
  bool _isShotRunning = false;

  // Puck Prep Checklist
  final Set<int> _checkedPuckItems = {};

  // Milk Steaming State
  double _currentMilkTemp = 4.0;
  

  @override
  void initState() {
    super.initState();
    _announceCurrentStage();
  }

  @override
  void dispose() {
    _shotTimer?.cancel();
    super.dispose();
  }

  void _announceCurrentStage() {
    if (_activeStageIndex >= 0 && _activeStageIndex < widget.steps.length) {
      final step = widget.steps[_activeStageIndex];
      final title = step['title']?.toString() ?? 'Langkah ${_activeStageIndex + 1}';
      final instruction = step['instruction']?.toString() ?? '';
      final prompt = widget.isEn
          ? 'Step ${_activeStageIndex + 1}: $title. $instruction'
          : 'Tahap ${_activeStageIndex + 1}: $title. $instruction';
      BrewingTTSService.instance.speakRawText(prompt);
    }
  }

  void _toggleShotTimer() {
    AudioService.playClick();
    if (_isShotRunning) {
      _shotTimer?.cancel();
      setState(() => _isShotRunning = false);
    } else {
      setState(() => _isShotRunning = true);
      _shotTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted) return;
        setState(() {
          _shotMilliseconds += 100;
        });
      });
    }
  }

  void _resetShotTimer() {
    AudioService.playClick();
    _shotTimer?.cancel();
    setState(() {
      _shotMilliseconds = 0;
      _isShotRunning = false;
    });
  }

  void _advanceToStage(int index) {
    if (index < 0 || index >= widget.steps.length) return;
    AudioService.playTransition();
    setState(() {
      _completedStages.add(_activeStageIndex);
      _activeStageIndex = index;
    });
    _announceCurrentStage();
  }

  String _formatShotTimer(int ms) {
    final totalSec = ms ~/ 1000;
    final tenths = (ms % 1000) ~/ 100;
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s.$tenths';
  }

  @override
  Widget build(BuildContext context) {
    final isEn = widget.isEn;
    final steps = widget.steps;
    if (steps.isEmpty) {
      return Center(
        child: Text(isEn ? 'No steps defined for this recipe.' : 'Tidak ada tahapan untuk resep ini.'),
      );
    }

    final activeStep = steps[_activeStageIndex];
    final activeTitle = activeStep['title']?.toString() ?? 'Langkah ${_activeStageIndex + 1}';
    final activeInstruction = activeStep['instruction']?.toString() ?? '';
    final coffeeWeight = widget.recipe['coffeeWeightGrams'] ?? 18;
    final totalWater = widget.recipe['totalWaterWeightGrams'] ?? (coffeeWeight * 2);
    final beanName = widget.recipe['beanName'] ?? 'Espresso Blend';

    return Column(
      children: [
        // Top Recipe & Quick Info Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.surfaceWhite,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.bolt_fill, size: 18, color: Colors.amber),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Barista Espresso Station' : 'Barista Espresso Station',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentAmber),
                    ),
                    Text(
                      '$beanName · ${coffeeWeight}g Dose',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                ),
                child: Text(
                  'Target: ~${totalWater}g',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                ),
              ),
            ],
          ),
        ),

        // Horizontal Stage Stepper
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: steps.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final step = steps[idx];
              final rawTitle = step['title']?.toString() ?? 'Step ${idx + 1}';
              final translatedTitle = isEn ? CoffeeTranslator.translateStepTitle(rawTitle) : rawTitle;
              final isCurrent = idx == _activeStageIndex;
              final isDone = _completedStages.contains(idx);

              Color badgeBg;
              Color textColor;
              Border? border;

              if (isCurrent) {
                badgeBg = AppTheme.primaryBrown;
                textColor = Colors.white;
                border = Border.all(color: AppTheme.accentAmber, width: 1.5);
              } else if (isDone) {
                badgeBg = Colors.green.withValues(alpha: 0.15);
                textColor = Colors.green[800]!;
                border = Border.all(color: Colors.green.withValues(alpha: 0.3));
              } else {
                badgeBg = AppTheme.surfaceWhite;
                textColor = AppTheme.textMuted;
                border = Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1));
              }

              return InkWell(
                onTap: () {
                  AudioService.playClick();
                  setState(() => _activeStageIndex = idx);
                  _announceCurrentStage();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    border: border,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppTheme.accentAmber
                              : (isDone ? Colors.green : AppTheme.primaryBrown.withValues(alpha: 0.2)),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent ? AppTheme.primaryBrown : Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        translatedTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1, thickness: 1, color: AppTheme.dividerColor),

        // Main Stage Interactive Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Stage Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isEn
                                  ? 'Stage ${_activeStageIndex + 1} of ${steps.length}'
                                  : 'Tahap ${_activeStageIndex + 1} dari ${steps.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(CupertinoIcons.speaker_2_fill, size: 20, color: AppTheme.primaryBrown),
                            onPressed: _announceCurrentStage,
                            tooltip: isEn ? 'Vocal Instruction' : 'Ulangi Panduan Suara',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEn ? CoffeeTranslator.translateStepTitle(activeTitle) : activeTitle,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEn ? CoffeeTranslator.translateInstruction(activeInstruction) : activeInstruction,
                        style: const TextStyle(fontSize: 13.5, color: AppTheme.textDark, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Stage-Specific Interactive Controls
                _buildStageSpecificTool(
                  activeTitle: activeTitle,
                  coffeeWeight: coffeeWeight,
                  totalWater: totalWater,
                  isEn: isEn,
                ),
              ],
            ),
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_activeStageIndex > 0)
                OutlinedButton.icon(
                  onPressed: () => _advanceToStage(_activeStageIndex - 1),
                  icon: const Icon(CupertinoIcons.arrow_left, size: 16),
                  label: Text(isEn ? 'Previous' : 'Kembali'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (_activeStageIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_activeStageIndex < steps.length - 1) {
                      _advanceToStage(_activeStageIndex + 1);
                    } else {
                      widget.onFinishBrew();
                    }
                  },
                  icon: Icon(
                    _activeStageIndex < steps.length - 1
                        ? CupertinoIcons.arrow_right
                        : CupertinoIcons.checkmark_seal_fill,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    _activeStageIndex < steps.length - 1
                        ? (isEn ? 'Next Stage →' : 'Lanjut Tahap Berikutnya →')
                        : (isEn ? 'Finish & Enjoy Coffee ☕' : 'Selesai & Nikmati Kopi ☕'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activeStageIndex < steps.length - 1 ? AppTheme.primaryBrown : Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStageSpecificTool({
    required String activeTitle,
    required dynamic coffeeWeight,
    required dynamic totalWater,
    required bool isEn,
  }) {
    final t = activeTitle.toLowerCase();

    // 1. Puck Prep Stage Checklist
    if (t.contains('dose') ||
        t.contains('giling') ||
        t.contains('grind') ||
        t.contains('wdt') ||
        t.contains('distribus') ||
        t.contains('puck') ||
        t.contains('tamp') ||
        t.contains('basket') ||
        t.contains('level')) {
      final items = isEn
          ? [
              'Grind & dose ${coffeeWeight}g specialty coffee fine into basket',
              'WDT Needle Tool: circular deep stir to eliminate channeling clumps',
              'Distribute & Level Tamp horizontally with 15–20 kg firm pressure',
              'Clean basket rim and lock portafilter securely into grouphead',
            ]
          : [
              'Timbang & giling ${coffeeWeight}g biji kopi halus ke dalam basket',
              'Jarum WDT: aduk melingkar merata dari dasar untuk hilangkan clump',
              'Tamping rata presisi horizontal dengan tekanan stabil 15–20 kg',
              'Bersihkan bibir portafilter & kunci rapat ke grouphead mesin',
            ];

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist_rounded, color: AppTheme.primaryBrown, size: 20),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'Puck Prep Quality Checklist' : 'Checklist Kualitas Puck Prep',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBrown),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              final idx = entry.key;
              final text = entry.value;
              final isChecked = _checkedPuckItems.contains(idx);

              return InkWell(
                onTap: () {
                  AudioService.playClick();
                  setState(() {
                    if (isChecked) {
                      _checkedPuckItems.remove(idx);
                    } else {
                      _checkedPuckItems.add(idx);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        isChecked ? CupertinoIcons.checkmark_square_fill : CupertinoIcons.square,
                        color: isChecked ? Colors.green : AppTheme.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isChecked ? AppTheme.textDark : AppTheme.textMuted,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    // 2. Shot Extraction Stage Stopwatch
    if (t.contains('ekstraksi') ||
        t.contains('shot') ||
        t.contains('tarik') ||
        t.contains('pull') ||
        t.contains('yield') ||
        t.contains('9 bar') ||
        t.contains('normale') ||
        t.contains('ristretto') ||
        t.contains('lungo') ||
        t.contains('doppio')) {
      final shotSec = _shotMilliseconds / 1000.0;
      String diagText;
      Color diagColor;

      if (shotSec == 0) {
        diagText = isEn ? 'Ready for Extraction' : 'Siap Tarik Shot 9-Bar';
        diagColor = AppTheme.textMuted;
      } else if (shotSec < 20 && !_isShotRunning) {
        diagText = isEn
            ? 'Fast Flow (<20s) · Under-extracted (Grind Finer)'
            : 'Aliran Cepat (<20s) · Potensi Under-ekstraksi (Giling Lebih Halus)';
        diagColor = Colors.orange;
      } else if (shotSec >= 22 && shotSec <= 32) {
        diagText = isEn
            ? 'Optimal Sweet Spot (22–30s) · Rich Golden Crema ✨'
            : 'Sweet Spot Optimal (22–30s) · Crema Hazelnut Sempurna ✨';
        diagColor = Colors.green;
      } else if (shotSec > 32 && !_isShotRunning) {
        diagText = isEn
            ? 'Slow Flow (>32s) · Over-extracted (Grind Coarser)'
            : 'Aliran Lambat (>32s) · Potensi Pahit Kering (Giling Lebih Kasar)';
        diagColor = Colors.redAccent;
      } else {
        diagText = isEn ? 'Extracting 9-Bar Coffee...' : 'Ekstraksi Pompa 9-Bar Berjalan...';
        diagColor = Colors.amber[800]!;
      }

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.timer, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isEn ? 'Precision Shot Extraction Timer' : 'Shot Timer Ekstraksi Presisi',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Target: 25–28s',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber[900]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _formatShotTimer(_shotMilliseconds),
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: _isShotRunning ? Colors.amber[800] : AppTheme.primaryBrown,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: diagColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                diagText,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: diagColor),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _resetShotTimer,
                  icon: const Icon(CupertinoIcons.arrow_counterclockwise, size: 16),
                  label: Text(isEn ? 'Reset' : 'Reset'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  onPressed: _toggleShotTimer,
                  icon: Icon(_isShotRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill, size: 18),
                  label: Text(
                    _isShotRunning
                        ? (isEn ? 'Stop Pump' : 'Hentikan Pompa')
                        : (isEn ? 'Start 9-Bar Shot' : 'Mulai Tarik Shot'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isShotRunning ? Colors.redAccent : Colors.amber[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 3. Steaming Susu Stage Monitor
    if (t.contains('steam') || t.contains('susu') || t.contains('milk') || t.contains('busa') || t.contains('foam')) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepOrangeAccent.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_cafe_rounded, color: Colors.deepOrangeAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'Microfoam Steaming Temperature Guide' : 'Panduan Suhu Steaming Susu',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepOrangeAccent),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildTempStagePill(
                  tempLabel: '4°C',
                  title: isEn ? 'Chilled Milk' : 'Susu Dingin',
                  subtitle: isEn ? 'Pour in jug' : 'Tuang ke jug',
                  isActive: true,
                  color: Colors.cyan,
                ),
                const SizedBox(width: 8),
                _buildTempStagePill(
                  tempLabel: '37°C',
                  title: isEn ? 'Stretching' : 'Aerasi Busa',
                  subtitle: isEn ? 'Gentle hiss' : 'Desis halus',
                  isActive: _currentMilkTemp >= 37,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildTempStagePill(
                  tempLabel: '60–65°C',
                  title: isEn ? 'Glossy Vortex' : 'Pusaran Sutra',
                  subtitle: isEn ? 'Sweet spot!' : 'Rasa termanis!',
                  isActive: _currentMilkTemp >= 60,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: _currentMilkTemp,
              min: 4,
              max: 75,
              divisions: 71,
              activeColor: _currentMilkTemp > 68 ? Colors.red : Colors.deepOrangeAccent,
              label: '${_currentMilkTemp.round()}°C',
              onChanged: (val) {
                setState(() => _currentMilkTemp = val);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEn ? 'Current Milk Temp: ${_currentMilkTemp.round()}°C' : 'Suhu Susu: ${_currentMilkTemp.round()}°C',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                TextButton.icon(
                  onPressed: () {
                    AudioService.playTransition();
                    setState(() {
                      _currentMilkTemp = 65;
                      
                    });
                  },
                  icon: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  label: Text(
                    isEn ? 'Mark 65°C Ready ✓' : 'Tandai Siap 65°C ✓',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 4. Default Barista Presentation Advice
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CupertinoIcons.sparkles, color: AppTheme.accentAmber, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEn
                  ? 'Professional Presentation Tip: Maintain proper pouring angle and steady microfoam integration to elevate beverage aroma and aesthetics.'
                  : 'Tips Barista Profesional: Jaga kestabilan sudut pouring dan integrasi mikrobusa untuk memaksimalkan aroma dan estetika sajian minuman.',
              style: const TextStyle(fontSize: 12.5, color: AppTheme.textDark, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempStagePill({
    required String tempLabel,
    required String title,
    required String subtitle,
    required bool isActive,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color : AppTheme.primaryBrown.withValues(alpha: 0.1),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              tempLabel,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? color : AppTheme.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
