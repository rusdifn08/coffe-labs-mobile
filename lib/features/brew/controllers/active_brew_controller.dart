import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/audio_service.dart';
import '../../brew/timer/utils/brew_method_helper.dart';
import '../tts/brewing_tts_service.dart';

part 'active_brew_controller.g.dart';

/// State immutable sesi seduh aktif.
class ActiveBrewState {
  final Map<String, dynamic> recipe;
  final int elapsedSeconds;
  final bool isRunning;
  final bool isPreparing;
  final int prepSeconds;
  final int activeStepIndex;
  final bool isCompleted;
  final bool isEndingSoon;

  const ActiveBrewState({
    required this.recipe,
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.isPreparing = true,
    this.prepSeconds = 5, // 5 seconds lead-time for T-5 vocal prep and countdown
    this.activeStepIndex = 0,
    this.isCompleted = false,
    this.isEndingSoon = false,
  });

  List<dynamic> get steps => (recipe['steps'] as List<dynamic>?) ?? [];

  int get totalDurationSeconds {
    final t = recipe['totalTimeSeconds'] ?? 0;
    if (t is int && t > 0) return t;
    int sum = 0;
    for (final s in steps) {
      if (s is Map) {
        sum += (s['durationSeconds'] ?? s['timeSeconds'] ?? 0) as int;
      }
    }
    return sum > 0 ? sum : 180;
  }

  BrewMethodFamily get methodFamily {
    return BrewMethodHelper.detectFamily(
      method: recipe['method']?.toString(),
      category: recipe['category']?.toString(),
    );
  }

  ActiveBrewState copyWith({
    Map<String, dynamic>? recipe,
    int? elapsedSeconds,
    bool? isRunning,
    bool? isPreparing,
    int? prepSecondsVal,
    int? activeStepIndex,
    bool? isCompleted,
    bool? isEndingSoon,
  }) {
    return ActiveBrewState(
      recipe: recipe ?? this.recipe,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPreparing: isPreparing ?? this.isPreparing,
      prepSeconds: prepSecondsVal ?? prepSeconds,
      activeStepIndex: activeStepIndex ?? this.activeStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isEndingSoon: isEndingSoon ?? this.isEndingSoon,
    );
  }
}

/// Notifier untuk mengontrol sesi seduh dan timer aktif dengan integrasi Barista TTS.
@riverpod
class ActiveBrewController extends _$ActiveBrewController {
  Timer? _timer;
  final Set<int> _announcedStepIndices = {};
  int _lastCountdownSec = -1;

  @override
  ActiveBrewState build(Map<String, dynamic> recipe) {
    unawaited(BrewingTTSService.instance.preloadRecipeSteps(recipe));

    ref.onDispose(() {
      _timer?.cancel();
      BrewingTTSService.instance.stop();
    });

    return ActiveBrewState(recipe: recipe);
  }

  /// Memulai hitung mundur persiapan (5 detik) dengan panduan Barista TTS.
  void start() {
    _timer?.cancel();
    state = state.copyWith(isRunning: true);

    // Trigger T-5 vocal announcement for Step 0 right as preparation starts
    if (state.isPreparing && state.prepSeconds >= 5) {
      _announceStep(0, isNextStep: false);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isPreparing) {
        final currentPrep = state.prepSeconds;
        if (currentPrep > 1) {
          final nextPrep = currentPrep - 1;

          // Vocal countdown for T-minus 5, 4, 3, 2, 1
          if (nextPrep <= 5 && nextPrep >= 1) {
            AudioService.playTick();
            BrewingTTSService.instance.speakCountdown(nextPrep);
          }

          state = state.copyWith(prepSecondsVal: nextPrep);
        } else {
          AudioService.playTransition();
          state = state.copyWith(
            isPreparing: false,
            prepSecondsVal: 0,
            elapsedSeconds: 0,
          );
          if (!_announcedStepIndices.contains(0)) {
            _announceStep(0);
          }
        }
      } else {
        final newElapsed = state.elapsedSeconds + 1;
        final total = state.totalDurationSeconds;
        final endingSoon = (total - newElapsed) <= 5 && (total - newElapsed) > 0;

        if (endingSoon) {
          AudioService.playTick();
        }

        // Tentukan indeks step aktif dan sisa waktu step saat ini
        int cumTime = 0;
        int currentStep = 0;
        int currentStepRemaining = 0;

        for (int i = 0; i < state.steps.length; i++) {
          final s = state.steps[i];
          final dur = (s is Map ? (s['durationSeconds'] ?? s['timeSeconds'] ?? 30) : 30) as int;
          cumTime += dur;
          if (newElapsed < cumTime) {
            currentStep = i;
            currentStepRemaining = cumTime - newElapsed;
            break;
          }
          currentStep = i;
          currentStepRemaining = 0;
        }

        // Audio Timing:
        // Pembacaan judul step dan deskripsi tepat di 5 detik sebelum masuk ke step selanjutnya
        if (currentStep + 1 < state.steps.length) {
          if (currentStepRemaining <= 5 && !_announcedStepIndices.contains(currentStep + 1)) {
            _announceStep(currentStep + 1, isNextStep: true);
          } else if (currentStepRemaining <= 5 && currentStepRemaining >= 1) {
            if (_lastCountdownSec != currentStepRemaining) {
              _lastCountdownSec = currentStepRemaining;
              BrewingTTSService.instance.speakCountdown(currentStepRemaining);
            }
          }
        }

        if (newElapsed >= total) {
          _timer?.cancel();
          AudioService.playEnjoy();
          BrewingTTSService.instance.speakCompletion();
          state = state.copyWith(
            elapsedSeconds: newElapsed,
            isRunning: false,
            isCompleted: true,
            activeStepIndex: state.steps.isNotEmpty ? state.steps.length - 1 : 0,
            isEndingSoon: false,
          );
        } else {
          state = state.copyWith(
            elapsedSeconds: newElapsed,
            activeStepIndex: currentStep,
            isEndingSoon: endingSoon,
          );
        }
      }
    });
  }

  void _announceStep(int stepIndex, {bool isNextStep = false}) {
    if (stepIndex < 0 || stepIndex >= state.steps.length) return;
    if (_announcedStepIndices.contains(stepIndex)) return;
    _announcedStepIndices.add(stepIndex);

    final stepData = state.steps[stepIndex];
    if (stepData is Map) {
      final title = (stepData['title'] ?? 'Tahap ${stepIndex + 1}').toString();
      final instruction = (stepData['instruction'] ?? '').toString();
      final stepWater = ((stepData['waterAddedGrams'] ?? stepData['waterGrams'] ?? 0) as num).toInt();
      final dur = ((stepData['durationSeconds'] ?? stepData['timeSeconds'] ?? 30) as num).toInt();
      final temp = (state.recipe['waterTempCelsius'] is num)
          ? (state.recipe['waterTempCelsius'] as num).toInt()
          : 91;

      int cumWater = 0;
      for (int i = 0; i <= stepIndex && i < state.steps.length; i++) {
        final s = state.steps[i];
        if (s is Map) {
          cumWater += ((s['waterAddedGrams'] ?? s['waterGrams'] ?? 0) as num).toInt();
        }
      }

      BrewingTTSService.instance.speakInstruction(
        title: title,
        instruction: instruction,
        stepIndex: stepIndex,
        stepWaterGrams: stepWater,
        cumulativeWaterGrams: cumWater,
        waterTempCelsius: temp,
        durationSeconds: dur,
        isNextStep: isNextStep,
      );
    }
  }

  /// Menjeda (pause) timer seduh dan menghentikan audio.
  void pause() {
    _timer?.cancel();
    BrewingTTSService.instance.stop();
    state = state.copyWith(isRunning: false);
  }

  /// Lewati hitung mundur persiapan dan langsung mulai seduh.
  void skipPreparation() {
    AudioService.playTransition();
    state = state.copyWith(
      isPreparing: false,
      prepSecondsVal: 0,
      elapsedSeconds: 0,
    );
    if (!_announcedStepIndices.contains(0)) {
      _announceStep(0);
    }
    if (!state.isRunning) {
      start();
    }
  }

  /// Reset timer ke posisi awal.
  void reset() {
    _timer?.cancel();
    BrewingTTSService.instance.stop();
    _announcedStepIndices.clear();
    _lastCountdownSec = -1;
    state = ActiveBrewState(recipe: state.recipe);
  }

  /// Navigasi manual ke langkah tertentu.
  void jumpToStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < state.steps.length) {
      BrewingTTSService.instance.stop();
      _announcedStepIndices.remove(stepIndex);
      int targetElapsed = 0;
      for (int i = 0; i < stepIndex; i++) {
        final s = state.steps[i];
        final dur = (s is Map ? (s['durationSeconds'] ?? s['timeSeconds'] ?? 30) : 30) as int;
        targetElapsed += dur;
      }
      state = state.copyWith(
        elapsedSeconds: targetElapsed,
        activeStepIndex: stepIndex,
      );
      if (state.isRunning) {
        _announceStep(stepIndex);
      }
    }
  }
}
