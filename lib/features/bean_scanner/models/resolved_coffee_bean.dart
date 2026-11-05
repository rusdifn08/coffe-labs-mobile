import 'package:flutter/material.dart';

enum BlockRole {
  roastery,
  originOrTitle,
  process,
  tastingNote,
  variety,
  altitude,
  ignoredNoise,
}

extension BlockRoleX on BlockRole {
  String get badgeLabel {
    switch (this) {
      case BlockRole.roastery:
        return '🏪 Roastery';
      case BlockRole.originOrTitle:
        return '⛰️ Origin / Kopi';
      case BlockRole.process:
        return '🍷 Proses';
      case BlockRole.tastingNote:
        return '✨ Tasting Note';
      case BlockRole.variety:
        return '🌱 Varietas';
      case BlockRole.altitude:
        return '📐 Altitude';
      case BlockRole.ignoredNoise:
        return 'Noise Diabaikan';
    }
  }

  Color get color {
    switch (this) {
      case BlockRole.roastery:
        return const Color(0xFFD4AF37); // Gold
      case BlockRole.originOrTitle:
        return const Color(0xFF4E8752); // Emerald Sage
      case BlockRole.process:
        return const Color(0xFF9E2A3B); // Wine Burgundy
      case BlockRole.tastingNote:
        return const Color(0xFF3B82A6); // Sky Blue
      case BlockRole.variety:
        return const Color(0xFF2E7D32); // Forest Green
      case BlockRole.altitude:
        return const Color(0xFF5C6BC0); // Indigo
      case BlockRole.ignoredNoise:
        return const Color(0xFF757575); // Grey
    }
  }
}

class ClassifiedOcrBlock {
  final String text;
  final BlockRole role;
  final double topY;
  final double leftX;
  final double normalizedWidth;
  final double normalizedHeight;
  final double confidence;

  const ClassifiedOcrBlock({
    required this.text,
    required this.role,
    this.topY = 0.0,
    this.leftX = 0.0,
    this.normalizedWidth = 0.0,
    this.normalizedHeight = 0.0,
    this.confidence = 0.95,
  });

  factory ClassifiedOcrBlock.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role']?.toString().toLowerCase() ?? '';
    final role = BlockRole.values.firstWhere(
      (r) => r.name.toLowerCase() == roleStr || roleStr.contains(r.name.toLowerCase()),
      orElse: () => BlockRole.tastingNote,
    );

    return ClassifiedOcrBlock(
      text: json['text']?.toString() ?? '',
      role: role,
      topY: (json['top_y'] as num?)?.toDouble() ?? 0.0,
      leftX: (json['left_x'] as num?)?.toDouble() ?? 0.0,
      normalizedWidth: (json['normalized_width'] as num?)?.toDouble() ?? 0.0,
      normalizedHeight: (json['normalized_height'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.95,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'role': role.name,
      'top_y': topY,
      'left_x': leftX,
      'normalized_width': normalizedWidth,
      'normalized_height': normalizedHeight,
      'confidence': confidence,
    };
  }
}

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
  final String notesSource; // 'OCR_EXPLICIT' vs 'AI_SOMMELIER_INFERRED'
  final bool isAiInferredAltitude;
  final bool isAiInferredVariety;
  final List<ClassifiedOcrBlock> classifiedBlocks;

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
    this.notesSource = 'AI_SOMMELIER_INFERRED',
    this.isAiInferredAltitude = false,
    this.isAiInferredVariety = false,
    this.classifiedBlocks = const [],
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
    String? notesSource,
    bool? isAiInferredAltitude,
    bool? isAiInferredVariety,
    List<ClassifiedOcrBlock>? classifiedBlocks,
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
      notesSource: notesSource ?? this.notesSource,
      isAiInferredAltitude: isAiInferredAltitude ?? this.isAiInferredAltitude,
      isAiInferredVariety: isAiInferredVariety ?? this.isAiInferredVariety,
      classifiedBlocks: classifiedBlocks ?? this.classifiedBlocks,
    );
  }

  factory ResolvedCoffeeBean.fromJson(Map<String, dynamic> json, {String? localImagePath}) {
    final recipesRaw = json['recommended_recipes'] as List? ?? [];
    final recipes = recipesRaw.map((r) => RecommendedRecipeSummary.fromJson(r as Map<String, dynamic>)).toList();

    final blocksRaw = json['classified_blocks'] as List? ?? [];
    final blocks = blocksRaw.map((b) => ClassifiedOcrBlock.fromJson(b as Map<String, dynamic>)).toList();

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
      notesSource: json['notes_source']?.toString() ?? 'AI_SOMMELIER_INFERRED',
      isAiInferredAltitude: json['is_ai_inferred_altitude'] == true,
      isAiInferredVariety: json['is_ai_inferred_variety'] == true,
      classifiedBlocks: blocks,
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
      'notes_source': notesSource,
      'is_ai_inferred_altitude': isAiInferredAltitude,
      'is_ai_inferred_variety': isAiInferredVariety,
      'classified_blocks': classifiedBlocks.map((b) => b.toJson()).toList(),
    };
  }
}
