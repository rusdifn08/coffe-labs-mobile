/// Domain model representing a single animated step in the Pre-Brew Masterclass walkthrough.
class RecipeWalkthroughStep {
  /// Numeric index mapped to Rive State Machine `SMIInput<double>` 'StepIndex'.
  final int stepIndex;
  final String title;
  final String phaseName;

  /// Detailed Indonesian explanation spoken by the female barista TTS.
  final String ttsText;
  final List<String> visualCues;

  /// Specific visual state identifier driving the recipe-aware animation canvas.
  final String animationState;
  final int durationSeconds;
  final bool autoAdvance;

  /// Recipe-specific quantitative parameters for live visual rendering on the canvas.
  final int stepWaterGrams;
  final int cumulativeWaterGrams;
  final int totalWaterGrams;
  final int waterTempCelsius;
  final num coffeeGrams;
  final int iceGrams;
  final String grindLabel;

  const RecipeWalkthroughStep({
    required this.stepIndex,
    required this.title,
    required this.phaseName,
    required this.ttsText,
    required this.visualCues,
    required this.animationState,
    this.durationSeconds = 12,
    this.autoAdvance = true,
    this.stepWaterGrams = 0,
    this.cumulativeWaterGrams = 0,
    this.totalWaterGrams = 225,
    this.waterTempCelsius = 91,
    this.coffeeGrams = 15,
    this.iceGrams = 0,
    this.grindLabel = 'Medium',
  });

  RecipeWalkthroughStep copyWith({
    int? stepIndex,
    String? title,
    String? phaseName,
    String? ttsText,
    List<String>? visualCues,
    String? animationState,
    int? durationSeconds,
    bool? autoAdvance,
    int? stepWaterGrams,
    int? cumulativeWaterGrams,
    int? totalWaterGrams,
    int? waterTempCelsius,
    num? coffeeGrams,
    int? iceGrams,
    String? grindLabel,
  }) {
    return RecipeWalkthroughStep(
      stepIndex: stepIndex ?? this.stepIndex,
      title: title ?? this.title,
      phaseName: phaseName ?? this.phaseName,
      ttsText: ttsText ?? this.ttsText,
      visualCues: visualCues ?? this.visualCues,
      animationState: animationState ?? this.animationState,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      stepWaterGrams: stepWaterGrams ?? this.stepWaterGrams,
      cumulativeWaterGrams: cumulativeWaterGrams ?? this.cumulativeWaterGrams,
      totalWaterGrams: totalWaterGrams ?? this.totalWaterGrams,
      waterTempCelsius: waterTempCelsius ?? this.waterTempCelsius,
      coffeeGrams: coffeeGrams ?? this.coffeeGrams,
      iceGrams: iceGrams ?? this.iceGrams,
      grindLabel: grindLabel ?? this.grindLabel,
    );
  }
}

/// Domain model representing the full Pre-Brew Masterclass for a recipe.
class RecipeMasterclass {
  final dynamic recipeId;
  final String title;
  final String techniqueName;
  final String brewerName;
  final String overview;
  final String recommendedDripper;
  final String methodFamilyName;
  final num coffeeGrams;
  final int totalWaterGrams;
  final int waterTempCelsius;
  final String grindSize;
  final List<RecipeWalkthroughStep> steps;

  const RecipeMasterclass({
    required this.recipeId,
    required this.title,
    required this.techniqueName,
    required this.brewerName,
    required this.overview,
    required this.recommendedDripper,
    required this.steps,
    this.methodFamilyName = 'pourOver',
    this.coffeeGrams = 15,
    this.totalWaterGrams = 225,
    this.waterTempCelsius = 91,
    this.grindSize = 'Medium 900 µm',
  });

  int get totalSteps => steps.length;
}
