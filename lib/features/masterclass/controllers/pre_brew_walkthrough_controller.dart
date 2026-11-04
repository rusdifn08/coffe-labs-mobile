import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../brew/tts/brewing_tts_service.dart';
import '../models/recipe_walkthrough_step.dart';
import '../services/masterclass_data_service.dart';

part 'pre_brew_walkthrough_controller.g.dart';

/// Immutable state for the Pre-Brew Masterclass Walkthrough.
class PreBrewWalkthroughState {
  final RecipeMasterclass masterclass;
  final int currentIndex;
  final bool isPlaying;
  final bool isNarrating;
  final bool autoAdvance;
  final double riveStepIndex; // Directly maps to SMIInput<double> 'StepIndex'

  const PreBrewWalkthroughState({
    required this.masterclass,
    this.currentIndex = 0,
    this.isPlaying = true,
    this.isNarrating = false,
    this.autoAdvance = true,
    this.riveStepIndex = 0.0,
  });

  RecipeWalkthroughStep get currentStep => masterclass.steps[currentIndex];
  bool get isFirstStep => currentIndex == 0;
  bool get isLastStep => currentIndex == masterclass.steps.length - 1;
  double get progress => masterclass.steps.isEmpty ? 0.0 : (currentIndex + 1) / masterclass.steps.length;

  PreBrewWalkthroughState copyWith({
    RecipeMasterclass? masterclass,
    int? currentIndex,
    bool? isPlaying,
    bool? isNarrating,
    bool? autoAdvance,
    double? riveStepIndex,
  }) {
    return PreBrewWalkthroughState(
      masterclass: masterclass ?? this.masterclass,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isNarrating: isNarrating ?? this.isNarrating,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      riveStepIndex: riveStepIndex ?? this.riveStepIndex,
    );
  }
}

/// Orchestrator controller synchronizing Rive Animation SMIInputs with Barista TTS narration.
@riverpod
class PreBrewWalkthroughController extends _$PreBrewWalkthroughController {
  bool _isDisposed = false;

  @override
  PreBrewWalkthroughState build(Map<String, dynamic> recipe) {
    _isDisposed = false;
    final masterclass = MasterclassDataService.getMasterclassForRecipe(recipe);

    ref.onDispose(() {
      _isDisposed = true;
      BrewingTTSService.instance.stop();
    });

    // Start with Step 0
    final initialState = PreBrewWalkthroughState(
      masterclass: masterclass,
      currentIndex: 0,
      riveStepIndex: 0.0,
      isPlaying: true,
      autoAdvance: true,
    );

    // Trigger initial step narration asynchronously
    Future.microtask(() => _playCurrentStepNarration());

    return initialState;
  }

  /// Triggers voice narration for current step and automatically advances upon completion.
  Future<void> _playCurrentStepNarration() async {
    if (_isDisposed || !state.isPlaying) return;

    final step = state.currentStep;
    state = state.copyWith(
      isNarrating: true,
      riveStepIndex: state.currentIndex.toDouble(),
    );

    // Cancel any previous narration
    await BrewingTTSService.instance.stop();

    if (_isDisposed) return;

    // Speak step explanation via female barista TTS
    await BrewingTTSService.instance.speakRawText(step.ttsText);

    if (_isDisposed) return;
    state = state.copyWith(isNarrating: false);

    // Auto-advance logic: if autoAdvance is enabled and not at the last step
    if (state.autoAdvance && state.isPlaying && !state.isLastStep) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!_isDisposed && state.isPlaying) {
        nextStep();
      }
    }
  }

  /// Advance to next animation & narration step.
  void nextStep() {
    if (state.isLastStep) return;
    final nextIdx = state.currentIndex + 1;
    state = state.copyWith(
      currentIndex: nextIdx,
      riveStepIndex: nextIdx.toDouble(),
    );
    _playCurrentStepNarration();
  }

  /// Go back to previous step.
  void prevStep() {
    if (state.isFirstStep) return;
    final prevIdx = state.currentIndex - 1;
    state = state.copyWith(
      currentIndex: prevIdx,
      riveStepIndex: prevIdx.toDouble(),
    );
    _playCurrentStepNarration();
  }

  /// Jump directly to a specific step.
  void jumpToStep(int index) {
    if (index < 0 || index >= state.masterclass.steps.length) return;
    state = state.copyWith(
      currentIndex: index,
      riveStepIndex: index.toDouble(),
    );
    _playCurrentStepNarration();
  }

  /// Toggle play/pause of the pre-brew walkthrough.
  void togglePlayPause() {
    final nextPlaying = !state.isPlaying;
    state = state.copyWith(isPlaying: nextPlaying);
    if (nextPlaying) {
      _playCurrentStepNarration();
    } else {
      BrewingTTSService.instance.stop();
      state = state.copyWith(isNarrating: false);
    }
  }

  /// Toggle auto-advance to next step upon TTS completion.
  void toggleAutoAdvance() {
    state = state.copyWith(autoAdvance: !state.autoAdvance);
  }

  /// Replay voice narration for the current step.
  void replayNarration() {
    _playCurrentStepNarration();
  }
}
