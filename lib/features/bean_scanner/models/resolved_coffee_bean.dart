class RecommendedRecipeSummary {
  final String slug;
  final String name;
  final String targetNotes;
  final int suggestedTempC;
  final String ratio;

  const RecommendedRecipeSummary({
    required this.slug,
    required this.name,
    required this.targetNotes,
    required this.suggestedTempC,
    required this.ratio,
  });

  factory RecommendedRecipeSummary.fromJson(Map<String, dynamic> json) {
    return RecommendedRecipeSummary(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      targetNotes: json['target_notes']?.toString() ?? '',
      suggestedTempC: (json['suggested_temp_c'] as num?)?.toInt() ?? 92,
      ratio: json['ratio']?.toString() ?? '1:15',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'target_notes': targetNotes,
      'suggested_temp_c': suggestedTempC,
      'ratio': ratio,
    };
  }
}

class ResolvedCoffeeBean {
  final String? beanId;
  final bool isCatalogVerified;
  final double confidenceScore;
  final String roasteryName;
  final String beanName;
  final String origin;
  final String variety;
  final String process;
  final String roastLevel;
  final String? altitudeMasl;
  final List<String> tastingNotes;
  final int recommendedWaterTempC;
  final List<RecommendedRecipeSummary> recommendedRecipes;
  final String? localCroppedImagePath;

  const ResolvedCoffeeBean({
    this.beanId,
    required this.isCatalogVerified,
    required this.confidenceScore,
    required this.roasteryName,
    required this.beanName,
    required this.origin,
    required this.variety,
    required this.process,
    required this.roastLevel,
    this.altitudeMasl,
    required this.tastingNotes,
    required this.recommendedWaterTempC,
    required this.recommendedRecipes,
    this.localCroppedImagePath,
  });

  ResolvedCoffeeBean copyWith({
    String? beanId,
    bool? isCatalogVerified,
    double? confidenceScore,
    String? roasteryName,
    String? beanName,
    String? origin,
    String? variety,
    String? process,
    String? roastLevel,
    String? altitudeMasl,
    List<String>? tastingNotes,
    int? recommendedWaterTempC,
    List<RecommendedRecipeSummary>? recommendedRecipes,
    String? localCroppedImagePath,
  }) {
    return ResolvedCoffeeBean(
      beanId: beanId ?? this.beanId,
      isCatalogVerified: isCatalogVerified ?? this.isCatalogVerified,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      roasteryName: roasteryName ?? this.roasteryName,
      beanName: beanName ?? this.beanName,
      origin: origin ?? this.origin,
      variety: variety ?? this.variety,
      process: process ?? this.process,
      roastLevel: roastLevel ?? this.roastLevel,
      altitudeMasl: altitudeMasl ?? this.altitudeMasl,
      tastingNotes: tastingNotes ?? this.tastingNotes,
      recommendedWaterTempC: recommendedWaterTempC ?? this.recommendedWaterTempC,
      recommendedRecipes: recommendedRecipes ?? this.recommendedRecipes,
      localCroppedImagePath: localCroppedImagePath ?? this.localCroppedImagePath,
    );
  }

  factory ResolvedCoffeeBean.fromJson(Map<String, dynamic> json, {String? localImagePath}) {
    final recipesRaw = json['recommended_recipes'] as List? ?? [];
    final recipes = recipesRaw.map((r) => RecommendedRecipeSummary.fromJson(r as Map<String, dynamic>)).toList();

    return ResolvedCoffeeBean(
      beanId: json['bean_id']?.toString(),
      isCatalogVerified: json['is_catalog_verified'] == true,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 85.0,
      roasteryName: json['roastery_name']?.toString() ?? 'Specialty Roastery',
      beanName: json['bean_name']?.toString() ?? 'Specialty Coffee',
      origin: json['origin']?.toString() ?? 'Single Origin',
      variety: json['variety']?.toString() ?? 'Arabica',
      process: json['process']?.toString() ?? 'Washed',
      roastLevel: json['roast_level']?.toString() ?? 'Light to Medium',
      altitudeMasl: json['altitude_masl']?.toString(),
      tastingNotes: (json['tasting_notes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      recommendedWaterTempC: (json['recommended_water_temp_c'] as num?)?.toInt() ?? 92,
      recommendedRecipes: recipes,
      localCroppedImagePath: localImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bean_id': beanId,
      'is_catalog_verified': isCatalogVerified,
      'confidence_score': confidenceScore,
      'roastery_name': roasteryName,
      'bean_name': beanName,
      'origin': origin,
      'variety': variety,
      'process': process,
      'roast_level': roastLevel,
      'altitude_masl': altitudeMasl,
      'tasting_notes': tastingNotes,
      'recommended_water_temp_c': recommendedWaterTempC,
      'recommended_recipes': recommendedRecipes.map((r) => r.toJson()).toList(),
      'local_cropped_image_path': localCroppedImagePath,
    };
  }
}
