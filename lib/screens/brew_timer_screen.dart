import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import '../services/trial_service.dart';
import '../services/language_service.dart';
import '../services/coffee_translator.dart';
import '../services/smart_scale_service.dart';
import '../widgets/thermal_receipt_sheet.dart';
import '../features/brew/timer/widgets/brew_doctor_sheet.dart';
import '../features/brew/timer/widgets/brew_sensory_evaluation_sheet.dart';
import '../features/brew/timer/widgets/circular_brew_timer.dart';
import '../features/brew/timer/widgets/brew_step_tile.dart';
import '../features/brew/timer/widgets/brew_timer_controls.dart';
import '../features/brew/timer/widgets/segmented_timer_painter.dart';
import '../features/brew/timer/utils/brew_method_helper.dart';
import '../features/brew/timer/widgets/brew_spec_header_bar.dart';
import '../features/brew/timer/widgets/brew_iced_banner.dart';
import '../features/brew/timer/widgets/brew_scale_live_badge.dart';
import '../features/brew/tts/brewing_tts_service.dart';
import '../features/gamification/services/gamification_service.dart';
import '../features/brew/timer/widgets/barista_espresso_cockpit.dart';

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
  int _prepSeconds = 5; // 5s lead time for T-5 vocal announcement and countdown
  bool _isRunning = false;
  bool _isPreparing = false;
  bool _useBaristaCockpit = true;
  final ScrollController _stepScrollController = ScrollController();
  int _lastScrolledStepIndex = -1;

  // TTS Tracking sets to prevent duplicate vocal prompts
  final Set<int> _announcedStepIndices = {};
  int _lastCountdownStepIndex = -1;
  int _lastCountdownSec = -1;

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

    unawaited(BrewingTTSService.instance.preloadRecipeSteps(_recipe));

    SmartScaleService.instance.addListener(_onScaleChanged);
    SmartScaleService.instance.onAutoStartBrewTimer = () {
      if (_isPreparing) {
        _startMainTimer();
      } else if (!_isRunning && _elapsedSeconds == 0) {
        _toggleTimer();
      }
    };
  }

  void _announceStep(int stepIdx, {bool isNextStep = false}) {
    if (stepIdx < 0 || stepIdx >= steps.length) return;
    if (_announcedStepIndices.contains(stepIdx)) return;
    _announcedStepIndices.add(stepIdx);

    final s = steps[stepIdx];
    BrewingTTSService.instance.speakInstruction(
      title: (s['title'] ?? 'Tahap ${stepIdx + 1}').toString(),
      instruction: (s['instruction'] ?? '').toString(),
      stepIndex: stepIdx,
      stepWaterGrams: _stepWater(s),
      cumulativeWaterGrams: _getCumulativeWaterUpTo(stepIdx),
      waterTempCelsius: waterTempCelsius,
      durationSeconds: _stepDuration(s),
      isNextStep: isNextStep,
    );
  }

  void _onScaleChanged() {
    if (mounted) setState(() {});
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
    SmartScaleService.instance.removeListener(_onScaleChanged);
    SmartScaleService.instance.onAutoStartBrewTimer = null;
    _timer?.cancel();
    _prepTimer?.cancel();
    AudioService.stopBgm();
    BrewingTTSService.instance.stop();
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

    if (steps.isNotEmpty && !_announcedStepIndices.contains(0)) {
      _announceStep(0);
    }

    AudioService.startBgm();
    _checkAutoScroll();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_elapsedSeconds < totalSeconds) {
        setState(() => _elapsedSeconds++);
        _checkAutoScroll();

        if (_elapsedSeconds % 2 == 0) {
          AudioService.ensureBgmPlaying();
        }

        int accumulated = 0;
        for (int i = 0; i < steps.length; i++) {
          final step = steps[i];
          final stepDur = _stepDuration(step);
          accumulated += stepDur;
          if (accumulated > _elapsedSeconds) {
            final int left = accumulated - _elapsedSeconds;

            // Audio Timing:
            // Pembacaan judul step dan deskripsi tepat di 5 detik sebelum masuk ke step selanjutnya
            if (i + 1 < steps.length) {
              if (left <= 5 && !_announcedStepIndices.contains(i + 1)) {
                _announceStep(i + 1, isNextStep: true);
              } else if (left <= 5 && left >= 1) {
                if (_lastCountdownStepIndex != i || _lastCountdownSec != left) {
                  _lastCountdownStepIndex = i;
                  _lastCountdownSec = left;
                  AudioService.playTick();
                  BrewingTTSService.instance.speakCountdown(left);
                }
              }
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
        BrewingTTSService.instance.speakCompletion();
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
      BrewingTTSService.instance.stop();
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

        // Vocal Step 0 announcement at T-minus 5s
        if (steps.isNotEmpty) {
          _announceStep(0, isNextStep: false);
        }

        _prepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_prepSeconds > 1) {
            final nextPrep = _prepSeconds - 1;
            if (nextPrep <= 5 && nextPrep >= 1) {
              AudioService.playTick();
              BrewingTTSService.instance.speakCountdown(nextPrep);
            }
            setState(() => _prepSeconds = nextPrep);
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
    BrewingTTSService.instance.stop();
    _announcedStepIndices.clear();
    _lastCountdownSec = -1;
    _lastCountdownStepIndex = -1;
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
    BrewingTTSService.instance.stop();
    final clamped = targetIndex.clamp(0, steps.length - 1);
    _announcedStepIndices.remove(clamped);
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
    if (_isRunning) {
      _announceStep(clamped);
    }
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
    final isEn = LanguageService.isEnglish;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEn ? 'Added +10s to Step ${idx + 1}' : 'Ditambahkan +10 detik pada Tahap ${idx + 1}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showDialInDoctorSheet() => BrewDoctorSheet.show(context);

  void _promptJournal() {
    GamificationService.instance.recordBrewCompleted();
    if (mounted) BrewSensoryEvaluationSheet.show(context, _recipe);
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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

  int _getCumulativeWaterUpTo(int stepIdx) {
    int sum = 0;
    for (int i = 0; i <= stepIdx && i < steps.length; i++) {
      sum += _stepWater(steps[i]);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final displayTitle = isEn ? CoffeeTranslator.translateTitle(title) : title;
    int activeIndex = (_elapsedSeconds > 0 || _isRunning) ? _getActiveStepIndex() : 0;
    if (_elapsedSeconds >= totalSeconds && steps.isNotEmpty) activeIndex = steps.length - 1;
    final activeStep = steps.isNotEmpty ? steps[activeIndex] : null;
    final activeTargetWater = activeStep != null ? _getCumulativeWaterUpTo(activeIndex) : 0;
    final family = BrewMethodHelper.detectFamily(
      method: _recipe['method']?.toString(),
      category: _recipe['category']?.toString(),
      title: _recipe['title']?.toString(),
    );
    int runningWater = 0;
    int runningTime = 0;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(displayTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (family == BrewMethodFamily.espresso)
            IconButton(
              tooltip: _useBaristaCockpit
                  ? (isEn ? 'Switch to Continuous Stopwatch' : 'Beralih ke Stopwatch Standar')
                  : (isEn ? 'Switch to Barista Workflow' : 'Beralih ke Alur Barista'),
              icon: Icon(_useBaristaCockpit ? CupertinoIcons.stopwatch : CupertinoIcons.square_list),
              onPressed: () => setState(() => _useBaristaCockpit = !_useBaristaCockpit),
            ),
          IconButton(
            tooltip: isEn ? 'Print Bluetooth Receipt' : 'Print Struk Resep Bluetooth',
            icon: const Icon(CupertinoIcons.printer_fill, size: 20),
            onPressed: () => ThermalReceiptSheet.show(context, _recipe),
          ),
          IconButton(
            tooltip: isEn ? 'Brew Doctor (Flavor Correction)' : 'Brew Doctor (Saran Koreksi Rasa)',
            icon: const Icon(CupertinoIcons.lightbulb, size: 20),
            onPressed: _showDialInDoctorSheet,
          ),
        ],
      ),
      body: (family == BrewMethodFamily.espresso && _useBaristaCockpit)
          ? BaristaEspressoCockpit(
              recipe: _recipe,
              steps: steps,
              onFinishBrew: _promptJournal,
              onPrintReceipt: () => ThermalReceiptSheet.show(context, _recipe),
              onShowDoctor: _showDialInDoctorSheet,
              isEn: isEn,
            )
          : LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

          if (isLandscape) {
            // Mode Cockpit Seduh Landscape: Timer di Kiri, Alur Tuangan di Kanan
            int lRunningWater = 0;
            int lRunningTime = 0;

            return Row(
              children: [
                // Panel Kiri: Timer & Kontrol Eksekusi
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      BrewSpecHeaderBar(recipe: _recipe),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularBrewTimer(
                                steps: steps,
                                totalSeconds: totalSeconds,
                                elapsedSeconds: _elapsedSeconds,
                                isPreparing: _isPreparing,
                                prepSeconds: _prepSeconds,
                                activeTargetWater: activeTargetWater,
                                isEndingSoon: _isEndingSoon(),
                                onSkipCountdown: _startMainTimer,
                                formatTime: _formatTime,
                                methodFamily: family,
                              ),
                            ],
                          ),
                        ),
                      ),
                      BrewTimerControls(
                        activeIndex: activeIndex,
                        stepsCount: steps.length,
                        isRunning: _isRunning,
                        isPreparing: _isPreparing,
                        onPrevStep: activeIndex > 0 ? () => _jumpToStep(activeIndex - 1) : null,
                        onNextStep: activeIndex < steps.length - 1 ? () => _jumpToStep(activeIndex + 1) : null,
                        onReset: _resetTimer,
                        onToggle: _toggleTimer,
                        onAdd10Sec: _add10SecondsToActiveStep,
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1, color: AppTheme.dividerColor),
                // Panel Kanan: Smart Scale & Daftar Langkah Tuangan Auto-Scroll
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      BrewScaleLiveBadge(isEn: isEn),
                      Expanded(
                        child: ListView.builder(
                          controller: _stepScrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          itemCount: steps.length,
                          itemBuilder: (context, index) {
                            final step = steps[index];
                            final int stepWater = _stepWater(step);
                            final int stepDur = _stepDuration(step);
                            final int startSec = lRunningTime;
                            lRunningTime += stepDur;
                            final int endSec = lRunningTime;
                            lRunningWater += stepWater;
                            final int cumulativeTarget = lRunningWater;

                            final bool isActive = index == activeIndex && !_isPreparing && (_isRunning || _elapsedSeconds > 0);
                            final bool isDone = _elapsedSeconds > 0 && (index < activeIndex || _elapsedSeconds >= totalSeconds);
                            final Color stepColor = getColorForStep(index);

                            return BrewStepTile(
                              index: index,
                              step: step,
                              isActive: isActive,
                              isDone: isDone,
                              stepWater: stepWater,
                              stepDur: stepDur,
                              startSec: startSec,
                              endSec: endSec,
                              cumulativeTarget: cumulativeTarget,
                              stepColor: stepColor,
                              onTap: () => _jumpToStep(index),
                              formatTime: _formatTime,
                              methodFamily: family,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Mode Portrait Standar (100% Utuh Seperti Semula)
          return Column(
            children: [
              // Brew Specification Bar (Bean, Ratio, Temp, Grind, Speaker Mute)
              BrewSpecHeaderBar(recipe: _recipe),

              // Japanese Iced Preparation Guide
              BrewIcedBanner(
                iceWeightGrams: iceWeightGrams,
                totalWaterGrams: totalWaterGrams,
                waterTempCelsius: waterTempCelsius,
                isPreparing: _isPreparing,
                elapsedSeconds: _elapsedSeconds,
                isEn: isEn,
              ),

              const SizedBox(height: 6),

              // Circular Timer Display
              CircularBrewTimer(
                steps: steps,
                totalSeconds: totalSeconds,
                elapsedSeconds: _elapsedSeconds,
                isPreparing: _isPreparing,
                prepSeconds: _prepSeconds,
                activeTargetWater: activeTargetWater,
                isEndingSoon: _isEndingSoon(),
                onSkipCountdown: _startMainTimer,
                formatTime: _formatTime,
                methodFamily: family,
              ),

              const SizedBox(height: 10),

              // Live Smart Scale Badge
              BrewScaleLiveBadge(isEn: isEn),

              const SizedBox(height: 6),

              // Scrollable Steps List
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
                    final Color stepColor = getColorForStep(index);

                    return BrewStepTile(
                      index: index,
                      step: step,
                      isActive: isActive,
                      isDone: isDone,
                      stepWater: stepWater,
                      stepDur: stepDur,
                      startSec: startSec,
                      endSec: endSec,
                      cumulativeTarget: cumulativeTarget,
                      stepColor: stepColor,
                      onTap: () => _jumpToStep(index),
                      formatTime: _formatTime,
                      methodFamily: family,
                    );
                  },
                ),
              ),

              // Bottom Control Panel
              BrewTimerControls(
                activeIndex: activeIndex,
                stepsCount: steps.length,
                isRunning: _isRunning,
                isPreparing: _isPreparing,
                onPrevStep: activeIndex > 0 ? () => _jumpToStep(activeIndex - 1) : null,
                onNextStep: activeIndex < steps.length - 1 ? () => _jumpToStep(activeIndex + 1) : null,
                onReset: _resetTimer,
                onToggle: _toggleTimer,
                onAdd10Sec: _add10SecondsToActiveStep,
              ),
            ],
          );
        },
      ),
    );
  }
}
