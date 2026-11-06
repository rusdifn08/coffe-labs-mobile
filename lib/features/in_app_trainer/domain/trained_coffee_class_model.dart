/// Model kelas kopi yang telah dilatih secara on-device dengan MobileNetV3 Transfer Learning Head.
class TrainedCoffeeClassModel {
  final String classSlug;
  final String displayTitle;
  final List<double> weightsVector960;
  final List<List<double>> subCentroids;
  final double cosineThreshold;
  final int augmentedSampleCount;
  final double validationAccuracy;
  final Map<String, dynamic> coffeeMetadata;
  final DateTime createdAt;

  const TrainedCoffeeClassModel({
    required this.classSlug,
    required this.displayTitle,
    required this.weightsVector960,
    required this.subCentroids,
    required this.cosineThreshold,
    required this.augmentedSampleCount,
    required this.validationAccuracy,
    required this.coffeeMetadata,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'class_slug': classSlug,
        'display_title': displayTitle,
        'weights_vector': weightsVector960,
        'sub_centroids': subCentroids,
        'cosine_threshold': cosineThreshold,
        'augmented_samples_count': augmentedSampleCount,
        'validation_accuracy': validationAccuracy,
        'coffee_metadata': coffeeMetadata,
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
      weightsVector960: rawWeights,
      subCentroids: rawSub,
      cosineThreshold: (json['cosine_threshold'] as num?)?.toDouble() ?? 0.72,
      augmentedSampleCount: json['augmented_samples_count'] as int? ?? 45,
      validationAccuracy: (json['validation_accuracy'] as num?)?.toDouble() ?? 0.98,
      coffeeMetadata: Map<String, dynamic>.from(json['coffee_metadata'] as Map? ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
