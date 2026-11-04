import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'brewing_tts_service.dart';

part 'brewing_tts_provider.g.dart';

/// State of the barista voice guidance system.
class BrewingTTSState {
  final bool isSpeaking;
  final bool isMuted;
  final String? activePrompt;

  const BrewingTTSState({
    this.isSpeaking = false,
    this.isMuted = false,
    this.activePrompt,
  });

  BrewingTTSState copyWith({
    bool? isSpeaking,
    bool? isMuted,
    String? activePrompt,
  }) {
    return BrewingTTSState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isMuted: isMuted ?? this.isMuted,
      activePrompt: activePrompt ?? this.activePrompt,
    );
  }
}

/// Riverpod controller providing access to the hands-free barista voice guidance.
@riverpod
class BrewingTTSNotifier extends _$BrewingTTSNotifier {
  @override
  BrewingTTSState build() {
    final service = BrewingTTSService.instance;
    service.initialize();
    return BrewingTTSState(isMuted: service.isMuted);
  }

  /// Speaks step title and instruction normalized into human-like Indonesian barista speech.
  Future<void> speakInstruction({
    required String title,
    required String instruction,
    required int stepIndex,
  }) async {
    state = state.copyWith(activePrompt: title, isSpeaking: true);
    await BrewingTTSService.instance.speakInstruction(
      title: title,
      instruction: instruction,
      stepIndex: stepIndex,
    );
    state = state.copyWith(isSpeaking: false);
  }

  /// Speaks countdown number (5, 4, 3, 2, 1) with time-critical priority.
  Future<void> speakCountdown(int number) async {
    state = state.copyWith(activePrompt: number.toString(), isSpeaking: true);
    await BrewingTTSService.instance.speakCountdown(number);
    state = state.copyWith(isSpeaking: false);
  }

  /// Speaks brew completion celebration.
  Future<void> speakCompletion() async {
    state = state.copyWith(activePrompt: 'Selesai', isSpeaking: true);
    await BrewingTTSService.instance.speakCompletion();
    state = state.copyWith(isSpeaking: false);
  }

  /// Toggles voice guidance mute state.
  void toggleMute() {
    final next = !state.isMuted;
    BrewingTTSService.instance.setMuted(next);
    state = state.copyWith(isMuted: next);
  }

  /// Immediately halts speech and clears audio queue.
  void stop() {
    BrewingTTSService.instance.stop();
    state = state.copyWith(isSpeaking: false);
  }
}
