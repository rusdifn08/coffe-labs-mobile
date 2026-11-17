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
  final String method;
  final String grindSize;
  final int coffeeGrams;
  final int totalWaterGrams;
  final int totalTimeSeconds;
  final String description;
  final List<Map<String, dynamic>> steps;

  const RecommendedRecipeSummary({
    required this.slug,
    required this.name,
    required this.targetNotes,
    required this.suggestedTempC,
    required this.ratio,
    this.method = 'Hario V60',
    this.grindSize = '645 µm (Medium • 22 Klik)',
    this.coffeeGrams = 15,
    this.totalWaterGrams = 225,
    this.totalTimeSeconds = 150,
    this.description = '',
    this.steps = const [],
  });

  factory RecommendedRecipeSummary.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] as List? ?? [];
    final parsedSteps = rawSteps
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();

    return RecommendedRecipeSummary(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      targetNotes: json['target_notes']?.toString() ?? '',
      suggestedTempC: (json['suggested_temp_c'] as num?)?.toInt() ?? 92,
      ratio: json['ratio']?.toString() ?? '1:15',
      method: json['method']?.toString() ?? 'Hario V60',
      grindSize: json['grind_size']?.toString() ?? '645 µm (Medium • 22 Klik)',
      coffeeGrams: (json['coffee_grams'] as num?)?.toInt() ?? 15,
      totalWaterGrams: (json['total_water_grams'] as num?)?.toInt() ?? 225,
      totalTimeSeconds: (json['total_time_seconds'] as num?)?.toInt() ?? 150,
      description: json['description']?.toString() ?? '',
      steps: parsedSteps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'target_notes': targetNotes,
      'suggested_temp_c': suggestedTempC,
      'ratio': ratio,
      'method': method,
      'grind_size': grindSize,
      'coffee_grams': coffeeGrams,
      'total_water_grams': totalWaterGrams,
      'total_time_seconds': totalTimeSeconds,
      if (description.isNotEmpty) 'description': description,
      if (steps.isNotEmpty) 'steps': steps,
    };
  }

  /// Konversi ringkasan resep hasil deteksi Smart OCR menjadi payload lengkap
  /// untuk `BrewTimerScreen` dengan identitas `Roastery + Nama Kopi`.
  Map<String, dynamic> toBrewTimerRecipeMap(ResolvedCoffeeBean bean) {
    final displayBean = bean.fullDisplayName;
    final lowerMethod = method.toLowerCase();
    String category = 'V60';
    if (lowerMethod.contains('origami')) {
      category = 'Origami';
    } else if (lowerMethod.contains('kalita')) {
      category = 'Kalita';
    } else if (lowerMethod.contains('aeropress')) {
      category = 'AeroPress';
    } else if (lowerMethod.contains('chemex')) {
      category = 'Chemex';
    }

    final List<Map<String, dynamic>> resolvedSteps = steps.isNotEmpty
        ? steps.map((s) => Map<String, dynamic>.from(s)).toList()
        : _buildDefaultSteps(
            coffeeGrams: coffeeGrams,
            totalWaterGrams: totalWaterGrams,
            totalTimeSeconds: totalTimeSeconds,
            suggestedTempC: suggestedTempC,
            leadNote: bean.tastingNotes.isNotEmpty ? bean.tastingNotes.first : 'manis alami',
          );

    return {
      'id': 98000 + (slug.hashCode.abs() % 900),
      'title': name,
      'author': bean.roasteryName != 'Specialty Roastery'
          ? '${bean.roasteryName} • Smart AI'
          : 'Coffee Labs Smart AI',
      'category': category,
      'method': method,
      'beanName': displayBean,
      'scannedBeanName': displayBean,
      'scannedRoastery': bean.roasteryName,
      'roastery': bean.roasteryName,
      'origin': bean.origin,
      'variety': bean.variety,
      'process': bean.process,
      'roastLevel': bean.roastLevel,
      'waterTempCelsius': suggestedTempC,
      'grindSize': grindSize,
      'coffeeWeightGrams': coffeeGrams,
      'totalWaterWeightGrams': totalWaterGrams,
      'iceWeightGrams': 0,
      'totalTimeSeconds': totalTimeSeconds,
      'tastingNotes': bean.tastingNotes.join(', '),
      'description': description.isNotEmpty ? description : targetNotes,
      'steps': resolvedSteps,
    };
  }

  static List<Map<String, dynamic>> _buildDefaultSteps({
    required int coffeeGrams,
    required int totalWaterGrams,
    required int totalTimeSeconds,
    required int suggestedTempC,
    required String leadNote,
  }) {
    final bloom = (coffeeGrams * 3).clamp(30, 75);
    final rem = (totalWaterGrams - bloom).clamp(60, 450);
    final p2 = (rem * 0.45).round();
    final p3 = rem - p2;
    final bloomSec = 40;
    final dur2 = ((totalTimeSeconds - bloomSec) * 0.45).round().clamp(25, 90);
    final dur3 = (totalTimeSeconds - bloomSec - dur2).clamp(30, 120);
    return [
      {
        'stepOrder': 1,
        'title': '1. Blooming & Degassing',
        'waterAddedGrams': bloom,
        'waterGrams': bloom,
        'cumulativeWaterGrams': bloom,
        'durationSeconds': bloomSec,
        'timeSeconds': bloomSec,
        'instruction':
            'Tuang ${bloom}g air ($suggestedTempC°C) merata membasahi seluruh bubuk kopi, goyangkan dripper lembut untuk degassing.',
      },
      {
        'stepOrder': 2,
        'title': '2. Sweet Flavor Pour',
        'waterAddedGrams': p2,
        'waterGrams': p2,
        'cumulativeWaterGrams': bloom + p2,
        'durationSeconds': dur2,
        'timeSeconds': dur2,
        'instruction':
            'Tuang spiral stabil hingga ${bloom + p2}g untuk mengekstrak karakter $leadNote.',
      },
      {
        'stepOrder': 3,
        'title': '3. Clean Clarity Finish',
        'waterAddedGrams': p3,
        'waterGrams': p3,
        'cumulativeWaterGrams': totalWaterGrams,
        'durationSeconds': dur3,
        'timeSeconds': dur3,
        'instruction':
            'Tuang lembut di titik tengah hingga ${totalWaterGrams}g dan biarkan tuntas mengalir bersih.',
      },
    ];
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

  /// Nama pendek roastery (mis. "Fugol Coffee Roasters" -> "Fugol").
  String get shortRoasteryLabel {
    final raw = roasteryName.trim();
    if (raw.isEmpty) return '';
    final lower = raw.toLowerCase();
    if (lower == 'specialty roastery' || lower == 'roastery' || lower == 'coffee roastery') {
      return '';
    }
    var short = raw;
    for (final suffix in const [
      'official store',
      'coffee roasters',
      'coffee roastery',
      'coffee supply',
      'coffee house',
      'coffee beans',
      'coffee bean',
      'coffee lab',
      'roasters',
      'roastery',
      'roaster',
      'roast',
      'supply',
      'coffee',
      'beans',
      'bean',
    ]) {
      final candidate = short
          .replaceAll(RegExp('\\s+${RegExp.escape(suffix)}\$', caseSensitive: false), '')
          .trim();
      if (candidate.length >= 3) {
        short = candidate;
      }
    }
    return short;
  }

  /// Format resmi tampilan kopi terdeteksi: `Roastery + Nama Kopi`
  /// (mis. "Fugol Watermelon Smash").
  String get fullDisplayName {
    final cleanBean = beanName.trim();
    final shortBrand = shortRoasteryLabel;
    if (shortBrand.isEmpty) return cleanBean;
    if (cleanBean.isEmpty || cleanBean.toLowerCase() == 'specialty coffee') {
      return shortBrand;
    }
    final beanLow = cleanBean.toLowerCase();
    final brandLow = shortBrand.toLowerCase();
    if (beanLow.startsWith(brandLow) || beanLow.contains('$brandLow ')) {
      return cleanBean;
    }
    return '$shortBrand $cleanBean';
  }

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
