/// Model kelas kopi yang telah dilatih on-device (prototipe visual 512-D + sidik jari OCR).
class TrainedCoffeeClassModel {
  final String classSlug;
  final String displayTitle;
  final List<double> weightsVector;
  final List<List<double>> subCentroids;
  final double cosineThreshold;
  final int augmentedSampleCount;
  final double validationAccuracy;
  final Map<String, dynamic> coffeeMetadata;
  final List<String> ocrSignatureTokens;
  final DateTime createdAt;

  const TrainedCoffeeClassModel({
    required this.classSlug,
    required this.displayTitle,
    required this.weightsVector,
    required this.subCentroids,
    required this.cosineThreshold,
    required this.augmentedSampleCount,
    required this.validationAccuracy,
    required this.coffeeMetadata,
    this.ocrSignatureTokens = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'class_slug': classSlug,
        'display_title': displayTitle,
        'weights_vector': weightsVector,
        'sub_centroids': subCentroids,
        'cosine_threshold': cosineThreshold,
        'augmented_samples_count': augmentedSampleCount,
        'validation_accuracy': validationAccuracy,
        'coffee_metadata': coffeeMetadata,
        'ocr_signature_tokens': ocrSignatureTokens,
        'created_at': createdAt.toIso8601String(),
      };

  factory TrainedCoffeeClassModel.fromJson(Map<String, dynamic> json) {
    final rawWeights = (json['weights_vector'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [];

    final rawSub = (json['sub_centroids'] as List<dynamic>?)
            ?.map((sub) =>
                (sub as List<dynamic>).map((e) => (e as num).toDouble()).toList())
            .toList() ??
        const [];

    return TrainedCoffeeClassModel(
      classSlug: json['class_slug'] as String,
      displayTitle: json['display_title'] as String? ?? json['class_slug'] as String,
      weightsVector: rawWeights,
      subCentroids: rawSub,
      cosineThreshold: (json['cosine_threshold'] as num?)?.toDouble() ?? 0.72,
      augmentedSampleCount: json['augmented_samples_count'] as int? ?? 45,
      validationAccuracy: (json['validation_accuracy'] as num?)?.toDouble() ?? 0.98,
      coffeeMetadata: Map<String, dynamic>.from(json['coffee_metadata'] as Map? ?? {}),
      ocrSignatureTokens:
          (json['ocr_signature_tokens'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
