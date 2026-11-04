import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import '../../../../theme/app_theme.dart';
import '../models/recipe_walkthrough_step.dart';
import 'masterclass_method_painters.dart';

/// Animated visual canvas orchestrating Rive vector animation with recipe-specific
/// and method-specific Coffee Lab vector diagrams + live quantitative telemetry HUD.
class MasterclassAnimationCanvas extends StatefulWidget {
  final int stepIndex;
  final RecipeWalkthroughStep currentStep;
  final bool isPlaying;

  const MasterclassAnimationCanvas({
    super.key,
    required this.stepIndex,
    required this.currentStep,
    required this.isPlaying,
  });

  @override
  State<MasterclassAnimationCanvas> createState() => _MasterclassAnimationCanvasState();
}

class _MasterclassAnimationCanvasState extends State<MasterclassAnimationCanvas>
    with SingleTickerProviderStateMixin {
  rive.RiveWidgetController? _riveController;
  rive.NumberInput? _stepIndexInput;
  rive.File? _riveFile;
  bool _riveFailed = false;
  bool _riveLoaded = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _initRive();
  }

  Future<void> _initRive() async {
    try {
      final file = await rive.File.asset(
        'assets/rive/coffee_recipe_state_machine.riv',
        riveFactory: rive.Factory.flutter,
      );
      if (file != null && mounted) {
        _riveFile = file;
        final controller = rive.RiveWidgetController(
          file,
          stateMachineSelector: const rive.StateMachineNamed('RecipeStateMachine'),
        );
        _riveController = controller;
        // ignore: deprecated_member_use
        _stepIndexInput = controller.stateMachine.number('StepIndex');
        _stepIndexInput?.value = widget.stepIndex.toDouble();
        setState(() => _riveLoaded = true);
      } else {
        if (mounted) setState(() => _riveFailed = true);
      }
    } catch (_) {
      if (mounted) setState(() => _riveFailed = true);
    }
  }

  @override
  void didUpdateWidget(covariant MasterclassAnimationCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepIndex != widget.stepIndex) {
      _stepIndexInput?.value = widget.stepIndex.toDouble();
    }
    if (widget.isPlaying && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isPlaying && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _stepIndexInput = null;
    _riveController?.dispose();
    _riveFile?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.currentStep;

    return Container(
      height: 256,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C221E), Color(0xFF1F1714)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rive Animation if asset exists, otherwise dynamic recipe-specific vector diagram
            if (_riveLoaded && _riveController != null && !_riveFailed)
              rive.RiveWidget(
                controller: _riveController!,
                fit: rive.Fit.contain,
              )
            else
              _buildDynamicCoffeeCanvas(step),

            // Top-Left: Phase Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.45)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.sparkles, size: 12, color: AppTheme.accentGold),
                    const SizedBox(width: 5),
                    Text(
                      step.phaseName,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top-Right: Temperature & Coffee Dose Badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Text(
                  '${step.coffeeGrams.toStringAsFixed(step.coffeeGrams == step.coffeeGrams.roundToDouble() ? 0 : 1)}g · ${step.waterTempCelsius}°C',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFD54F),
                  ),
                ),
              ),
            ),

            // Bottom Live Telemetry HUD Bar (shows exact recipe step grams, scale target & timer)
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: _buildTelemetryHudBar(step),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicCoffeeCanvas(RecipeWalkthroughStep step) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(double.infinity, 256),
          painter: MasterclassEquipmentPainter(
            step: step,
            pulse: _pulseController.value,
          ),
        );
      },
    );
  }

  Widget _buildTelemetryHudBar(RecipeWalkthroughStep step) {
    final hasPour = step.stepWaterGrams > 0;
    final hasDuration = step.durationSeconds > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left metric: Pour weight or Grind setting
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasPour ? CupertinoIcons.drop_fill : CupertinoIcons.slider_horizontal_3,
                size: 12,
                color: hasPour ? Colors.lightBlueAccent : AppTheme.accentGold,
              ),
              const SizedBox(width: 5),
              Text(
                hasPour ? '+${step.stepWaterGrams}g Air' : step.grindLabel,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Center metric: Cumulative Scale Target
          Text(
            hasPour
                ? 'Timbangan: ${step.cumulativeWaterGrams}g / ${step.totalWaterGrams}g'
                : (step.iceGrams > 0
                    ? 'Es: ${step.iceGrams}g · Air: ${step.totalWaterGrams}g'
                    : 'Total Air: ${step.totalWaterGrams}g'),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEFEBE9),
            ),
          ),

          // Right metric: Step Duration if applicable
          if (hasDuration)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${step.durationSeconds} dtk',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD54F),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
