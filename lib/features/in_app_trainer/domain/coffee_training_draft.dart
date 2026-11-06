import 'annotated_training_sample.dart';

/// Draft metadata kopi yang diisi barista untuk pelatihan model transfer learning.
class CoffeeTrainingDraft {
  final String roasteryBrand;
  final String beanName;
  final String varietal;
  final String process;
  final String altitudeMasl;
  final List<String> tastingNotes;
  final String? recommendedRecipeId;
  final List<AnnotatedTrainingSample> samples;

  const CoffeeTrainingDraft({
    required this.roasteryBrand,
    required this.beanName,
    this.varietal = 'Mixed Varieties',
    this.process = 'Natural',
    this.altitudeMasl = '1400 - 1650 MASL',
    this.tastingNotes = const [],
    this.recommendedRecipeId,
    this.samples = const [],
  });

  bool get isValid =>
      roasteryBrand.trim().isNotEmpty &&
      beanName.trim().isNotEmpty &&
      samples.length >= 3;

  CoffeeTrainingDraft copyWith({
    String? roasteryBrand,
    String? beanName,
    String? varietal,
    String? process,
    String? altitudeMasl,
    List<String>? tastingNotes,
    String? recommendedRecipeId,
    List<AnnotatedTrainingSample>? samples,
  }) {
    return CoffeeTrainingDraft(
      roasteryBrand: roasteryBrand ?? this.roasteryBrand,
      beanName: beanName ?? this.beanName,
      varietal: varietal ?? this.varietal,
      process: process ?? this.process,
      altitudeMasl: altitudeMasl ?? this.altitudeMasl,
      tastingNotes: tastingNotes ?? this.tastingNotes,
      recommendedRecipeId: recommendedRecipeId ?? this.recommendedRecipeId,
      samples: samples ?? this.samples,
    );
  }
}
