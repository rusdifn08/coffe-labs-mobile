import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../screens/brew_timer_screen.dart';
import '../../../../theme/app_theme.dart';
import '../controllers/pre_brew_walkthrough_controller.dart';
import '../widgets/masterclass_animation_canvas.dart';

/// Interactive Pre-Brew Recipe Masterclass screen.
/// Synchronizes Rive vector animations with human-like Indonesian barista TTS narration.
class PreBrewMasterclassScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> recipeData;

  const PreBrewMasterclassScreen({
    super.key,
    required this.recipeData,
  });

  static Future<void> show({
    required BuildContext context,
    required Map<String, dynamic> recipeData,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreBrewMasterclassScreen(recipeData: recipeData),
      ),
    );
  }

  @override
  ConsumerState<PreBrewMasterclassScreen> createState() => _PreBrewMasterclassScreenState();
}

class _PreBrewMasterclassScreenState extends ConsumerState<PreBrewMasterclassScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preBrewWalkthroughControllerProvider(widget.recipeData));
    final controller = ref.read(preBrewWalkthroughControllerProvider(widget.recipeData).notifier);
    final currentStep = state.currentStep;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        title: Column(
          children: [
            Text(
              state.masterclass.techniqueName,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            Text(
              'Oleh ${state.masterclass.brewerName}',
              style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Ulangi Narasi Suara',
            icon: const Icon(CupertinoIcons.speaker_2_fill, color: AppTheme.primaryBrown, size: 20),
            onPressed: () => controller.replayNarration(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Timeline Step Progress Indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: List.generate(state.masterclass.totalSteps, (idx) {
                final isPassed = idx < state.currentIndex;
                final isCurrent = idx == state.currentIndex;
                return Expanded(
                  child: Container(
                    height: 4.5,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.accentAmber
                          : (isPassed ? AppTheme.primaryBrown : AppTheme.borderWarm),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Animated Visual Canvas (Rive Animation + Coffee Vector Fallback)
                  MasterclassAnimationCanvas(
                    stepIndex: state.currentIndex,
                    currentStep: currentStep,
                    isPlaying: state.isPlaying,
                  ),
                  const SizedBox(height: 16),

                  // Step Title & Phase Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentStep.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Langkah ${state.currentIndex + 1} / ${state.masterclass.totalSteps}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Barista Voice Narration Subtitle Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: state.isNarrating ? AppTheme.accentAmber : AppTheme.borderWarm,
                        width: state.isNarrating ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: state.isNarrating
                                    ? AppTheme.accentGold.withValues(alpha: 0.2)
                                    : AppTheme.bgCream,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                state.isNarrating ? CupertinoIcons.waveform : CupertinoIcons.speaker_2,
                                size: 14,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Panduan Suara Barista (Narasi Aktif)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                            const Spacer(),
                            if (state.isNarrating)
                              const Text(
                                'Bicara...',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.accentAmber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentStep.ttsText,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Visual Cues / Key Action Points
                  const Text(
                    'Poin Kunci Teknik:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 6),
                  ...currentStep.visualCues.map((cue) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4, right: 8),
                            child: Icon(CupertinoIcons.checkmark_circle_fill, size: 14, color: AppTheme.accentGold),
                          ),
                          Expanded(
                            child: Text(
                              cue,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Bottom Control Panel
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step Controls: Prev, Play/Pause, Next, Auto-advance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.backward_fill),
                      color: state.isFirstStep ? Colors.grey.shade300 : AppTheme.primaryBrown,
                      onPressed: state.isFirstStep ? null : () => controller.prevStep(),
                    ),
                    InkWell(
                      onTap: () => controller.togglePlayPause(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBrown.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          state.isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.forward_fill),
                      color: state.isLastStep ? Colors.grey.shade300 : AppTheme.primaryBrown,
                      onPressed: state.isLastStep ? null : () => controller.nextStep(),
                    ),
                    const SizedBox(width: 8),
                    // Auto-advance toggle pill
                    ChoiceChip(
                      label: const Text('Otomatis Lanjut', style: TextStyle(fontSize: 10.5)),
                      selected: state.autoAdvance,
                      selectedColor: AppTheme.accentGold.withValues(alpha: 0.2),
                      side: BorderSide(
                        color: state.autoAdvance ? AppTheme.accentGold : Colors.grey.shade300,
                      ),
                      onSelected: (_) => controller.toggleAutoAdvance(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Button: Mulai Seduh dengan Timer
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(CupertinoIcons.timer, size: 18),
                    label: const Text(
                      'Paham! Mulai Seduh Resep Ini Sekarang',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BrewTimerScreen(recipeData: widget.recipeData),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
