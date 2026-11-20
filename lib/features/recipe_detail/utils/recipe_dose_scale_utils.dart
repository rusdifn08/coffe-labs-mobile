import 'dart:math' as math;

/// Utility untuk menskalakan resep secara dinamis ketika pengguna mengubah dosis kopi,
/// termasuk berat air per tahap, total air, es batu, bahan, deskripsi filosofi,
/// serta teks instruksi setiap step (yang juga dibacakan secara sinkron oleh Voice Over TTS).
class RecipeDoseScaleUtils {
  /// Mencocokkan takaran massa/volume dalam gram atau mililiter (single atau rentang),
  /// tanpa menyentuh suhu (°C), waktu (s/detik), rasio (1:15), tekanan (bar/kg),
  /// mikron (µm), ppm, persentase (%), atau panjang (cm).
  static final RegExp _weightTokenRegex = RegExp(
    r'(~|\+)?(\d+(?:[.,]\d+)?)(?:\s*([–-])\s*(\d+(?:[.,]\d+)?))?(\s*)(mililiter|gram|gr|ml|g)\b',
    caseSensitive: false,
  );

  static final RegExp _cumulativeCueRegex = RegExp(
    r'(?:total|hingga|sampai|mencapai|target|ke|up\s+to|reach(?:ing)?|scale\s+reads?|timbangan|kumulatif|cumulative|akhir|berat\s+akhir|yield|output)\s*[:~(]*\s*$',
    caseSensitive: false,
  );

  static final RegExp _coffeePrefixCueRegex = RegExp(
    r'(?:kopi|coffee|biji|beans?|bubuk|grounds?|dosis|dose|giling|grind|timbang|weigh)\s*[:~(]*\s*$',
    caseSensitive: false,
  );

  static final RegExp _coffeeSuffixCueRegex = RegExp(
    r'^\s*(?:kopi|coffee|biji|beans?|bubuk|grounds?|medium|fine|coarse|halus|kasar|espresso)',
    caseSensitive: false,
  );

  static final RegExp _waterSuffixCueRegex = RegExp(
    r'^\s*(?:air|water|panas|hot|dingin|cold|suhu)',
    caseSensitive: false,
  );

  static final RegExp _iceCueRegex = RegExp(
    r'(?:es\s*batu|ice\s*cubes?|es\b|ice\b)',
    caseSensitive: false,
  );

  /// Menghasilkan salinan resep yang seluruh angka berat, tahapan, instruksi,
  /// deskripsi, dan daftar bahannya sudah diskalakan terhadap [scaledCoffeeGrams].
  static Map<String, dynamic> scaleRecipe(
    Map<String, dynamic> baseRecipe, {
    required int baseCoffeeGrams,
    required int scaledCoffeeGrams,
  }) {
    if (baseCoffeeGrams <= 0 || scaledCoffeeGrams == baseCoffeeGrams) {
      return Map<String, dynamic>.from(baseRecipe);
    }

    final double factor = scaledCoffeeGrams / baseCoffeeGrams;
    final int baseTotalWater = (baseRecipe['totalWaterWeightGrams'] as num?)?.round() ?? 0;
    final int baseIceGrams = (baseRecipe['iceWeightGrams'] as num?)?.round() ?? 0;
    final List<dynamic> rawSteps = (baseRecipe['steps'] as List<dynamic>?) ?? const [];

    // Pass 1: hitung total air asli & terkalibrasi per langkah serta kumulatifnya
    final List<int> origStepWaters = [];
    final List<int> origStepCumulatives = [];
    final List<int> scaledStepWaters = [];
    final List<int> scaledStepCumulatives = [];

    int runningOrigWater = 0;
    int runningScaledWater = 0;
    for (final rawStep in rawSteps) {
      final map = rawStep is Map ? rawStep : const <String, dynamic>{};
      final origW = ((map['waterAddedGrams'] ?? map['waterGrams'] ?? 0) as num).round();
      final scaledW = origW > 0 ? math.max(1, (origW * factor).round()) : 0;
      runningOrigWater += origW;
      runningScaledWater += scaledW;

      origStepWaters.add(origW);
      origStepCumulatives.add(runningOrigWater);
      scaledStepWaters.add(scaledW);
      scaledStepCumulatives.add(runningScaledWater);
    }

    final int effectiveBaseTotalWater =
        runningOrigWater > 0 ? runningOrigWater : baseTotalWater;
    final int scaledTotalWater = runningScaledWater > 0
        ? runningScaledWater
        : (baseTotalWater > 0 ? math.max(1, (baseTotalWater * factor).round()) : 0);
    final int scaledIceGrams =
        baseIceGrams > 0 ? math.max(1, (baseIceGrams * factor).round()) : 0;

    // Pass 2: skalakan setiap langkah termasuk instruction & title
    final List<Map<String, dynamic>> scaledSteps = [];
    for (int i = 0; i < rawSteps.length; i++) {
      final map = Map<String, dynamic>.from(rawSteps[i] as Map);
      final int origW = origStepWaters[i];
      final int scaledW = scaledStepWaters[i];
      final int origCum = origStepCumulatives[i];
      final int scaledCum = scaledStepCumulatives[i];
      final int origPrevCum = i > 0 ? origStepCumulatives[i - 1] : 0;
      final int scaledPrevCum = i > 0 ? scaledStepCumulatives[i - 1] : 0;

      map['waterAddedGrams'] = scaledW;
      map['waterGrams'] = scaledW;
      map['cumulativeWaterGrams'] = scaledCum;

      final rawInstruction = map['instruction']?.toString() ?? '';
      if (rawInstruction.isNotEmpty) {
        map['instruction'] = scaleStepInstruction(
          rawInstruction,
          scaleFactor: factor,
          baseCoffeeGrams: baseCoffeeGrams,
          scaledCoffeeGrams: scaledCoffeeGrams,
          baseTotalWater: effectiveBaseTotalWater,
          scaledTotalWater: scaledTotalWater,
          baseIceGrams: baseIceGrams,
          scaledIceGrams: scaledIceGrams,
          origStepWater: origW,
          scaledStepWater: scaledW,
          origCumulativeWater: origCum,
          scaledCumulativeWater: scaledCum,
          origPrevCumulativeWater: origPrevCum,
          scaledPrevCumulativeWater: scaledPrevCum,
        );
      }

      final rawTitle = map['title']?.toString() ?? '';
      if (rawTitle.isNotEmpty) {
        map['title'] = scaleStepInstruction(
          rawTitle,
          scaleFactor: factor,
          baseCoffeeGrams: baseCoffeeGrams,
          scaledCoffeeGrams: scaledCoffeeGrams,
          baseTotalWater: effectiveBaseTotalWater,
          scaledTotalWater: scaledTotalWater,
          baseIceGrams: baseIceGrams,
          scaledIceGrams: scaledIceGrams,
          origStepWater: origW,
          scaledStepWater: scaledW,
          origCumulativeWater: origCum,
          scaledCumulativeWater: scaledCum,
          origPrevCumulativeWater: origPrevCum,
          scaledPrevCumulativeWater: scaledPrevCum,
        );
      }

      scaledSteps.add(map);
    }

    final copy = Map<String, dynamic>.from(baseRecipe);
    copy['coffeeWeightGrams'] = scaledCoffeeGrams;
    copy['totalWaterWeightGrams'] = scaledTotalWater;
    copy['iceWeightGrams'] = scaledIceGrams;
    copy['steps'] = scaledSteps;

    // Skalakan deskripsi filosofi resep apabila menyebutkan gramasi/ml kopi/air/es
    final rawDesc = copy['description']?.toString() ?? '';
    if (rawDesc.isNotEmpty) {
      copy['description'] = scaleStepInstruction(
        rawDesc,
        scaleFactor: factor,
        baseCoffeeGrams: baseCoffeeGrams,
        scaledCoffeeGrams: scaledCoffeeGrams,
        baseTotalWater: effectiveBaseTotalWater,
        scaledTotalWater: scaledTotalWater,
        baseIceGrams: baseIceGrams,
        scaledIceGrams: scaledIceGrams,
      );
    }

    // Skalakan daftar bahan (ingredients) jika tersedia
    final rawIngredients = copy['ingredients'];
    if (rawIngredients is List && rawIngredients.isNotEmpty) {
      copy['ingredients'] = rawIngredients.map((item) {
        if (item is Map) {
          final ing = Map<String, dynamic>.from(item);
          final amount = ing['amount']?.toString() ?? '';
          if (amount.isNotEmpty) {
            ing['amount'] = scaleStepInstruction(
              amount,
              scaleFactor: factor,
              baseCoffeeGrams: baseCoffeeGrams,
              scaledCoffeeGrams: scaledCoffeeGrams,
              baseTotalWater: effectiveBaseTotalWater,
              scaledTotalWater: scaledTotalWater,
              baseIceGrams: baseIceGrams,
              scaledIceGrams: scaledIceGrams,
            );
          }
          return ing;
        }
        return item;
      }).toList();
    }

    return copy;
  }

  /// Menskalakan teks instruksi step atau deskripsi agar semua angka gram/ml
  /// menyesuaikan persis dengan dosis kopi, volume tuangan step, dan target kumulatif.
  static String scaleStepInstruction(
    String text, {
    required double scaleFactor,
    required int baseCoffeeGrams,
    required int scaledCoffeeGrams,
    required int baseTotalWater,
    required int scaledTotalWater,
    int baseIceGrams = 0,
    int scaledIceGrams = 0,
    int origStepWater = 0,
    int scaledStepWater = 0,
    int origCumulativeWater = 0,
    int scaledCumulativeWater = 0,
    int origPrevCumulativeWater = 0,
    int scaledPrevCumulativeWater = 0,
  }) {
    if (text.isEmpty || (scaleFactor - 1.0).abs() < 0.0001) {
      return text;
    }

    final int origTotalLiquid = baseTotalWater + baseIceGrams;
    final int scaledTotalLiquid = scaledTotalWater + scaledIceGrams;

    return text.replaceAllMapped(_weightTokenRegex, (match) {
      final String leadingSign = match.group(1) ?? '';
      final String firstRaw = match.group(2) ?? '';
      final String? rangeSep = match.group(3);
      final String? secondRaw = match.group(4);
      final String spaceBeforeUnit = match.group(5) ?? '';
      final String unit = match.group(6) ?? 'g';

      final double? firstVal = _parseNumber(firstRaw);
      if (firstVal == null || firstVal <= 0) {
        return match.group(0)!;
      }

      // Rentang berat seperti "45–50g" atau "30-35 ml"
      if (rangeSep != null && secondRaw != null) {
        final double? secondVal = _parseNumber(secondRaw);
        if (secondVal == null || secondVal <= 0) {
          return match.group(0)!;
        }
        final scaledFirst = _formatScaledNumber(
          firstVal * scaleFactor,
          hadDecimal: firstRaw.contains('.') || firstRaw.contains(','),
          decimalChar: firstRaw.contains(',') ? ',' : '.',
        );
        final scaledSecond = _formatScaledNumber(
          secondVal * scaleFactor,
          hadDecimal: secondRaw.contains('.') || secondRaw.contains(','),
          decimalChar: secondRaw.contains(',') ? ',' : '.',
        );
        return '$leadingSign$scaledFirst$rangeSep$scaledSecond$spaceBeforeUnit$unit';
      }

      final int prefixStart = math.max(0, match.start - 36);
      final int suffixEnd = math.min(text.length, match.end + 28);
      final String prefix = text.substring(prefixStart, match.start);
      final String suffix = text.substring(match.end, suffixEnd);

      final bool isCumulativeCtx = _cumulativeCueRegex.hasMatch(prefix);
      final bool isWaterSuffix = _waterSuffixCueRegex.hasMatch(suffix);
      final bool isCoffeeCtx = !isWaterSuffix &&
          (_coffeeSuffixCueRegex.hasMatch(suffix) ||
              _coffeePrefixCueRegex.hasMatch(prefix));
      final bool isIceCtx =
          _iceCueRegex.hasMatch(suffix) || _iceCueRegex.hasMatch(prefix);

      num? exactMapped;

      // 1. Konteks target kumulatif ("hingga mencapai total 60g", "up to 90g", "target 60g")
      if (isCumulativeCtx) {
        if (origCumulativeWater > 0 && (firstVal - origCumulativeWater).abs() <= 1.0) {
          exactMapped = scaledCumulativeWater;
        } else if (baseTotalWater > 0 && (firstVal - baseTotalWater).abs() <= 1.0) {
          exactMapped = scaledTotalWater;
        } else if (origTotalLiquid > 0 && (firstVal - origTotalLiquid).abs() <= 1.0) {
          exactMapped = scaledTotalLiquid;
        }
      }

      // 2. Konteks es batu ("100g es batu")
      if (exactMapped == null && isIceCtx && baseIceGrams > 0) {
        if ((firstVal - baseIceGrams).abs() <= 1.0) {
          exactMapped = scaledIceGrams;
        }
      }

      // 3. Konteks dosis kopi ("Giling 20g kopi", "dosis 20g")
      if (exactMapped == null && isCoffeeCtx) {
        if ((firstVal - baseCoffeeGrams).abs() <= 0.5) {
          exactMapped = scaledCoffeeGrams;
        }
      }

      // 4. Volume tuangan air pada tahap ini ("Tuang 30g air...")
      if (exactMapped == null && origStepWater > 0) {
        if ((firstVal - origStepWater).abs() <= 1.0) {
          exactMapped = scaledStepWater;
        }
      }

      // 5. Fallback pencocokan eksak kumulatif / tahap sebelumnya / total air / es / kopi
      if (exactMapped == null) {
        if (origCumulativeWater > 0 && (firstVal - origCumulativeWater).abs() <= 1.0) {
          exactMapped = scaledCumulativeWater;
        } else if (origPrevCumulativeWater > 0 &&
            (firstVal - origPrevCumulativeWater).abs() <= 1.0) {
          exactMapped = scaledPrevCumulativeWater;
        } else if (baseTotalWater > 0 && (firstVal - baseTotalWater).abs() <= 1.0) {
          exactMapped = scaledTotalWater;
        } else if (origTotalLiquid > 0 &&
            baseIceGrams > 0 &&
            (firstVal - origTotalLiquid).abs() <= 1.0) {
          exactMapped = scaledTotalLiquid;
        } else if (baseIceGrams > 0 && (firstVal - baseIceGrams).abs() <= 1.0) {
          exactMapped = scaledIceGrams;
        } else if ((firstVal - baseCoffeeGrams).abs() <= 0.5) {
          exactMapped = scaledCoffeeGrams;
        }
      }

      final String formatted = exactMapped != null
          ? exactMapped.round().toString()
          : _formatScaledNumber(
              firstVal * scaleFactor,
              hadDecimal: firstRaw.contains('.') || firstRaw.contains(','),
              decimalChar: firstRaw.contains(',') ? ',' : '.',
            );

      return '$leadingSign$formatted$spaceBeforeUnit$unit';
    });
  }

  static double? _parseNumber(String raw) {
    return double.tryParse(raw.replaceAll(',', '.'));
  }

  static String _formatScaledNumber(
    double value, {
    required bool hadDecimal,
    required String decimalChar,
  }) {
    if (value <= 0) return '0';
    if (hadDecimal) {
      final roundedTenths = (value * 10).round() / 10.0;
      if ((roundedTenths - roundedTenths.round()).abs() < 0.01) {
        return math.max(1, roundedTenths.round()).toString();
      }
      return roundedTenths.toStringAsFixed(1).replaceAll('.', decimalChar);
    }
    return math.max(1, value.round()).toString();
  }
}
