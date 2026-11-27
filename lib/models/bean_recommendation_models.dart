import 'bean_ai_customization_models.dart';

enum BeanRoastLevel {
  light('Light Roast', 'Sangat padat, asam organik tinggi, aroma bunga & buah segar'),
  mediumLight('Medium-Light', 'Keseimbangan asam buah cerah dan manis karamel awal'),
  medium('Medium Roast', 'Manis maksimal, seimbang, body medium dan aftertaste cokelat'),
  mediumDark('Medium-Dark', 'Body tebal, keasaman rendah, aroma nutty dan dark cocoa'),
  dark('Dark Roast', 'Sangat mudah larut, keasaman minim, body pekat dan smoky');

  final String label;
  final String desc;
  const BeanRoastLevel(this.label, this.desc);
}

enum BeanProcess {
  washed('Washed / Basah', 'Karakter rasa bersih (clean cup), keasaman cerah & elegan'),
  natural('Natural / Kering', 'Rasa manis buah matang yang pekat, body tebal & aroma fruity'),
  honey('Honey Process', 'Kemanisan madu lengket, keasaman lembut dan aftertaste creamy'),
  anaerobic('Anaerobic / Fermentasi', 'Aroma kompleks, winey, asam laktat/malat intens & eksotis'),
  wetHulled('Wet-Hulled / Giling Basah', 'Body kental pekat, keasaman rendah, notes herbal & cokelat');

  final String label;
  final String desc;
  const BeanProcess(this.label, this.desc);
}

enum FlavorGoal {
  sweetBalanced('Manis & Seimbang', 'Standar SCA Golden Cup: keseimbangan ideal gula alami & keasaman halus'),
  highAcidity('Cerah & Floral', 'Menonjolkan keasaman buah cerah, aroma bunga mekar & clean finish'),
  heavyBody('Tebal & Bold', 'Tekstur kental di lidah, aftertaste cokelat & karamel panjang'),
  japaneseIced('Japanese Iced', 'Filter es segar: 60% air panas + 40% es batu mengunci aroma tropis');

  final String label;
  final String desc;
  const FlavorGoal(this.label, this.desc);
}

enum BeanDripper {
  v60('Hario V60 (Conical)', 'Aliran air cepat, ekstraksi asam & kejernihan tinggi'),
  kalita('Kalita Wave (Flat Bottom)', 'Ekstraksi rata seimbang, manis tebal dan minim channeling'),
  aeropress('AeroPress (Immersion)', 'Fleksibel, body pekat dan ekstraksi manis intens'),
  origami('Origami Dripper', 'Kombinasi conical & flat, menonjolkan aroma floral'),
  chemex('Chemex', 'Kertas filter tebal, seduhan sangat jernih dan manis halus'),
  clever('Clever Dripper', 'Kombinasi seduh rendam & saring, body bulat manis');

  final String label;
  final String desc;
  const BeanDripper(this.label, this.desc);
}

class RecommendedBrewRecipe {
  final String beanName;
  final BeanRoastLevel roastLevel;
  final BeanProcess process;
  final FlavorGoal goal;
  final BeanDripper dripper;
  final double coffeeDose;
  final double brewRatio;
  final double totalWater;
  final int iceWeightGrams;
  final int waterTemp;
  final int grindMicrons;
  final String grindClickLabel;
  final int bloomWater;
  final int bloomSeconds;
  final int totalTimeSeconds;
  final List<Map<String, dynamic>> steps;

  // Expected Cup Sensory Profile (1.0 - 5.0)
  final double expectedAcidity;
  final double expectedSweetness;
  final double expectedBody;
  final double expectedBitterness;
  final double expectedClarity;
  final List<String> predictedTastingNotes;
  final String scientificReason;

  // International SCA / WBC Specialty Dial-In Intelligence
  final String roastGuidanceSummary;
  final String agitationGuidance;
  final String recommendedWaterChemistry;
  final String recommendedRestWindow;
  final String estimatedDrawdownRange;
  final PouringParadigm recommendedParadigm;
  final List<String> internationalBrewTips;

  const RecommendedBrewRecipe({
    required this.beanName,
    required this.roastLevel,
    required this.process,
    required this.goal,
    required this.dripper,
    required this.coffeeDose,
    required this.brewRatio,
    required this.totalWater,
    this.iceWeightGrams = 0,
    required this.waterTemp,
    required this.grindMicrons,
    required this.grindClickLabel,
    required this.bloomWater,
    required this.bloomSeconds,
    required this.totalTimeSeconds,
    required this.steps,
    required this.expectedAcidity,
    required this.expectedSweetness,
    required this.expectedBody,
    required this.expectedBitterness,
    required this.expectedClarity,
    required this.predictedTastingNotes,
    required this.scientificReason,
    this.roastGuidanceSummary = '',
    this.agitationGuidance = 'Agitasi Sedang (Spiral Halus)',
    this.recommendedWaterChemistry = '70–95 ppm (GH 50 • KH 25 • pH 7.0)',
    this.recommendedRestWindow = '7–14 hari pasca-roast',
    this.estimatedDrawdownRange = '2:20 – 2:45',
    this.recommendedParadigm = PouringParadigm.specialtyStandard,
    this.internationalBrewTips = const [],
  });

  /// Hot water poured from kettle (for Japanese Iced, totalWater = hotWater + iceWeightGrams).
  int get hotWaterGrams => (totalWater.round() - iceWeightGrams).clamp(40, 2000);

  Map<String, dynamic> toRecipeMap() {
    return {
      'id': 99000 + (coffeeDose.round() * 10) + roastLevel.index,
      'title': '$beanName • ${roastLevel.label}',
      'author': 'Smart Brew AI Recommendation ☕',
      'category': goal == FlavorGoal.japaneseIced ? 'Japanese Iced' : 'Smart Dial-In',
      'method': dripper.label,
      'beanName': beanName,
      'variety': 'Specialty Single Origin',
      'process': process.label,
      'waterTempCelsius': waterTemp,
      'grindSize': '$grindMicrons µm ($grindClickLabel)',
      'coffeeWeightGrams': coffeeDose.round(),
      'totalWaterWeightGrams': hotWaterGrams,
      'iceWeightGrams': iceWeightGrams,
      'totalTimeSeconds': totalTimeSeconds,
      'description': scientificReason,
      'tastingNotes': predictedTastingNotes.join(', '),
      'steps': steps,
    };
  }
}

class BeanRecommenderEngine {
  /// Recommends the best world-champion pouring paradigm for a given roast + process + varietal.
  static PouringParadigm recommendParadigm({
    required BeanRoastLevel roast,
    required BeanProcess process,
    String descriptors = '',
  }) {
    final lower = descriptors.toLowerCase();
    if (roast == BeanRoastLevel.dark ||
        roast == BeanRoastLevel.mediumDark ||
        process == BeanProcess.wetHulled) {
      return PouringParadigm.osmoticFlow;
    }
    if (process == BeanProcess.anaerobic ||
        lower.contains('anaerob') ||
        lower.contains('carbonic') ||
        lower.contains('thermal') ||
        lower.contains('wine')) {
      return PouringParadigm.tetsu46;
    }
    if (roast == BeanRoastLevel.light && process == BeanProcess.washed) {
      return PouringParadigm.hoffmannUltimate;
    }
    if (roast == BeanRoastLevel.light && process == BeanProcess.natural) {
      return PouringParadigm.lanceHedrick121;
    }
    return PouringParadigm.specialtyStandard;
  }

  /// Recommends optimal WaterProfile matching the bean's roast & acidity potential.
  static WaterProfile recommendWaterProfile({
    required BeanRoastLevel roast,
    required BeanProcess process,
  }) {
    if (roast == BeanRoastLevel.light && process == BeanProcess.washed) {
      return WaterProfile.softWater;
    }
    if (process == BeanProcess.anaerobic) {
      return WaterProfile.remineralized;
    }
    return WaterProfile.scaStandard;
  }

  static RecommendedBrewRecipe calculate({
    required String beanName,
    String origin = '',
    String variety = '',
    List<String> tastingNotes = const [],
    required BeanRoastLevel roast,
    required BeanProcess process,
    required FlavorGoal goal,
    required BeanDripper dripper,
    required double dose,
    BeanRoastAge roastAge = BeanRoastAge.peak,
    WaterProfile waterProfile = WaterProfile.scaStandard,
    PouringParadigm pouringParadigm = PouringParadigm.specialtyStandard,
    int? customTempAdjust,
    int? customMicronAdjust,
    double? customRatioAdjust,
  }) {
    final String cleanDescriptors =
        '$beanName $origin $variety ${tastingNotes.join(" ")}'.toLowerCase();

    final bool isHighDensitySpecialty = _containsAny(cleanDescriptors, [
      'geisha', 'gesha', 'sl28', 'sl34', 'kenya', 'ethiopia', 'yirgacheffe',
      'guji', 'panama', 'pink bourbon', 'pacamara', 'abyssinia', 'kerinci',
      'puntang', 'wamena', 'papua', 'sidamo', 'chiriqui', 'tarrazu',
    ]);
    final bool isHyperSolubleFerment = process == BeanProcess.anaerobic ||
        _containsAny(cleanDescriptors, [
          'anaerob', 'carbonic', 'thermal shock', 'koji', 'infused', 'wine',
          'mossto', 'yeast', 'experimental',
        ]);
    final bool isExcelsaOrLiberica = _containsAny(
      cleanDescriptors,
      ['excelsa', 'liberica', 'liberika', 'robusta'],
    );

    // 1. Hitung Rasio Seduh Adaptif (Standar SCA / WBC)
    double ratio;
    if (goal == FlavorGoal.japaneseIced) {
      ratio = (roast == BeanRoastLevel.light) ? 15.5 : 15.0;
    } else if (goal == FlavorGoal.highAcidity) {
      ratio = (roast == BeanRoastLevel.light) ? 16.5 : 15.8;
    } else if (goal == FlavorGoal.heavyBody) {
      ratio = (roast == BeanRoastLevel.dark || roast == BeanRoastLevel.mediumDark)
          ? 13.5
          : 14.5;
    } else {
      if (isExcelsaOrLiberica) {
        ratio = 14.2;
      } else if (roast == BeanRoastLevel.light) {
        ratio = isHighDensitySpecialty ? 16.2 : 15.8;
      } else if (roast == BeanRoastLevel.mediumLight) {
        ratio = 15.5;
      } else if (roast == BeanRoastLevel.medium) {
        ratio = 15.0;
      } else if (roast == BeanRoastLevel.mediumDark) {
        ratio = 14.2;
      } else {
        ratio = 13.5;
      }
    }
    if (customRatioAdjust != null) ratio += customRatioAdjust;
    ratio = ratio.clamp(12.0, 18.5);
    final double totalWater = (dose * ratio).roundToDouble();
    final int iceGrams = goal == FlavorGoal.japaneseIced
        ? (totalWater * 0.40).round()
        : 0;
    final double hotWater = totalWater - iceGrams;

    // 2. Hitung Suhu Air Panas Ilmiah (Roast x Process x Density x Dripper x Water)
    int temp = switch (roast) {
      BeanRoastLevel.light => 94,
      BeanRoastLevel.mediumLight => 92,
      BeanRoastLevel.medium => 90,
      BeanRoastLevel.mediumDark => 87,
      BeanRoastLevel.dark => 85,
    };

    if (isExcelsaOrLiberica) {
      temp = temp.clamp(84, 88);
    } else if (isHyperSolubleFerment) {
      // Fermentasi intens & anaerobic jauh lebih mudah larut -> turunkan suhu agar bersih!
      temp -= 3;
    } else if (process == BeanProcess.natural) {
      temp -= 1;
    } else if (process == BeanProcess.wetHulled) {
      temp -= 2;
    } else if (process == BeanProcess.washed &&
        roast == BeanRoastLevel.light &&
        isHighDensitySpecialty) {
      temp += 1; // 95°C untuk Light Washed high-altitude (Geisha/Ethiopia/Kenya)
    }

    if (goal == FlavorGoal.japaneseIced) temp += 1;
    if (dripper == BeanDripper.chemex) temp += 1;
    if (dripper == BeanDripper.aeropress) temp -= 2;
    temp += waterProfile.tempDelta + (customTempAdjust ?? 0);
    temp = temp.clamp(82, 97);

    // 3. Hitung Grind Size Mikron & Multi-Grinder Clicks
    int microns = switch (roast) {
      BeanRoastLevel.light => (goal == FlavorGoal.highAcidity) ? 550 : 580,
      BeanRoastLevel.mediumLight => 610,
      BeanRoastLevel.medium => 650,
      BeanRoastLevel.mediumDark => 720,
      BeanRoastLevel.dark => 790,
    };

    if (isHighDensitySpecialty && roast == BeanRoastLevel.light) {
      microns -= 20; // Biji keras high-altitude butuh luas permukaan lebih besar
    }
    if (isHyperSolubleFerment) {
      microns += 55; // Cegah choking fines & rasa fermentasi sepat
    } else if (process == BeanProcess.natural) {
      microns += 30;
    } else if (process == BeanProcess.wetHulled) {
      microns += 45;
    }
    if (isExcelsaOrLiberica) microns += 35;
    if (goal == FlavorGoal.japaneseIced) microns -= 55;
    if (dripper == BeanDripper.chemex) microns += 75;
    if (dripper == BeanDripper.kalita) microns -= 25;
    if (dripper == BeanDripper.aeropress) microns -= 45;
    if (dripper == BeanDripper.clever) microns += 30;
    microns += roastAge.grindMicronDelta + (customMicronAdjust ?? 0);
    microns = microns.clamp(420, 1050);

    final String clickLabel = _formatClicks(microns);

    // 4. Tahap Penuangan Berfase (Pour Schedule)
    final double bloomMult =
        ((roast == BeanRoastLevel.light || process == BeanProcess.natural)
                ? 3.0
                : (roast == BeanRoastLevel.dark ? 2.2 : 2.6)) *
            (roastAge.bloomWaterMultiplier / 2.8);
    final int bloomWater = (dose * bloomMult)
        .round()
        .clamp((dose * 1.8).round(), (hotWater * 0.45).round());
    final int baseBloomSec = (roast == BeanRoastLevel.light || isHyperSolubleFerment)
        ? 45
        : (roast == BeanRoastLevel.dark ? 30 : 35);
    final int bloomSec =
        (baseBloomSec + (isHighDensitySpecialty ? 5 : 0) + roastAge.bloomSecondsDelta)
            .clamp(25, 60);
    final double remainingHotWater = (hotWater - bloomWater).clamp(20.0, 2000.0);

    final List<Map<String, dynamic>> steps = [];
    final String leadNote =
        tastingNotes.isNotEmpty ? tastingNotes.first : 'senyawa rasa utama';

    BeanStepGenerator.populateSteps(
      steps: steps,
      paradigm: pouringParadigm,
      goal: goal,
      leadNote: leadNote,
      bloomWater: bloomWater,
      bloomSec: bloomSec,
      remainingWater: remainingHotWater,
      totalWater: hotWater,
      iceWeightGrams: iceGrams,
    );

    final int totalTime =
        steps.fold<int>(0, (acc, s) => acc + (s['durationSeconds'] as int));

    // 5. Prediksi Profil Cita Rasa 5-Dimensi Robust (Sensory Radar)
    double acidity = 3.2;
    double sweetness = 3.6;
    double body = 3.3;
    double bitterness = 1.6;
    double clarity = 4.0;

    switch (roast) {
      case BeanRoastLevel.light:
        acidity += 1.1; clarity += 0.6; body -= 0.5; bitterness -= 0.3;
      case BeanRoastLevel.mediumLight:
        acidity += 0.7; sweetness += 0.5; clarity += 0.3; body -= 0.1;
      case BeanRoastLevel.medium:
        sweetness += 0.7; body += 0.4;
      case BeanRoastLevel.mediumDark:
        acidity -= 0.9; sweetness += 0.2; body += 0.8; bitterness += 0.8; clarity -= 0.6;
      case BeanRoastLevel.dark:
        acidity -= 1.6; sweetness -= 0.3; body += 1.2; bitterness += 1.5; clarity -= 1.1;
    }

    switch (process) {
      case BeanProcess.washed:
        clarity += 0.5; acidity += 0.3; body -= 0.2;
      case BeanProcess.natural:
        sweetness += 0.6; body += 0.4; clarity -= 0.3;
      case BeanProcess.honey:
        sweetness += 0.7; body += 0.3;
      case BeanProcess.anaerobic:
        acidity += 0.5; sweetness += 0.5; body += 0.3;
      case BeanProcess.wetHulled:
        body += 0.7; acidity -= 0.4; bitterness += 0.2;
    }

    if (_containsAny(cleanDescriptors, ['citrus', 'lemon', 'lime', 'orange', 'bergamot', 'apple', 'grape', 'zest', 'passion', 'sour', 'acid', 'floral', 'jasmine', 'yirgacheffe', 'geisha'])) {
      acidity += 0.5;
      clarity += 0.4;
    }
    if (_containsAny(cleanDescriptors, ['honey', 'sugar', 'caramel', 'toffee', 'sweet', 'mango', 'banana', 'peach', 'lychee', 'papaya', 'jackfruit', 'salak', 'maple'])) {
      sweetness += 0.6;
    }
    if (_containsAny(cleanDescriptors, ['chocolate', 'cocoa', 'cacao', 'creamy', 'syrupy', 'heavy', 'full', 'butter', 'peanut', 'nut', 'excelsa', 'liberica', 'toraja', 'lahat', 'mandheling'])) {
      body += 0.6;
      sweetness += 0.2;
    }
    if (_containsAny(cleanDescriptors, ['dark chocolate', 'tobacco', 'smoky', 'bold', 'pepper', 'roasted', 'spicy'])) {
      bitterness += 0.4;
      body += 0.3;
    }
    if (_containsAny(cleanDescriptors, ['clean finish', 'black tea', 'earl grey', 'jasmine', 'white peach'])) {
      clarity += 0.5;
    }

    if (goal == FlavorGoal.highAcidity || goal == FlavorGoal.japaneseIced) {
      acidity += 0.35;
      clarity += 0.35;
      body -= 0.3;
    } else if (goal == FlavorGoal.heavyBody) {
      body += 0.5;
      sweetness += 0.2;
      acidity -= 0.3;
    } else {
      sweetness += 0.4;
      acidity += 0.1;
      body += 0.1;
    }

    // 6. International Guidance Intelligence (Roast, Water Chemistry, Agitation, Rest Window)
    final recommendedParadigm = recommendParadigm(
      roast: roast,
      process: process,
      descriptors: cleanDescriptors,
    );
    final String waterChem = _recommendedWaterChemistry(roast, process);
    final String restWindow = _recommendedRestWindow(roast, process, isHyperSolubleFerment);
    final String agitation = _recommendedAgitation(roast, process, isHyperSolubleFerment);
    final String roastSummary = _roastGuidanceSummary(roast, process, temp, ratio);
    final String drawdownRange = _formatDrawdownRange(totalTime);
    final List<String> tips = _buildInternationalTips(
      roast: roast,
      process: process,
      goal: goal,
      isHighDensity: isHighDensitySpecialty,
      isHyperSoluble: isHyperSolubleFerment,
      temp: temp,
      iceGrams: iceGrams,
      restWindow: restWindow,
      agitation: agitation,
    );

    final List<String> notes =
        _generateBeanNotes(tastingNotes, cleanDescriptors, roast, process);
    final String reason = _generateScientificReason(
      beanName,
      origin,
      variety,
      roast,
      process,
      goal,
      temp,
      ratio,
      microns,
      iceGrams: iceGrams,
    );

    return RecommendedBrewRecipe(
      beanName: beanName.trim().isEmpty ? 'Single Origin Specialty' : beanName.trim(),
      roastLevel: roast,
      process: process,
      goal: goal,
      dripper: dripper,
      coffeeDose: dose,
      brewRatio: ratio,
      totalWater: totalWater,
      iceWeightGrams: iceGrams,
      waterTemp: temp,
      grindMicrons: microns,
      grindClickLabel: clickLabel,
      bloomWater: bloomWater,
      bloomSeconds: bloomSec,
      totalTimeSeconds: totalTime,
      steps: steps,
      expectedAcidity: double.parse(acidity.clamp(1.0, 5.0).toStringAsFixed(1)),
      expectedSweetness: double.parse(sweetness.clamp(1.0, 5.0).toStringAsFixed(1)),
      expectedBody: double.parse(body.clamp(1.0, 5.0).toStringAsFixed(1)),
      expectedBitterness: double.parse(bitterness.clamp(1.0, 5.0).toStringAsFixed(1)),
      expectedClarity: double.parse(clarity.clamp(1.0, 5.0).toStringAsFixed(1)),
      predictedTastingNotes: notes,
      scientificReason: reason,
      roastGuidanceSummary: roastSummary,
      agitationGuidance: agitation,
      recommendedWaterChemistry: waterChem,
      recommendedRestWindow: restWindow,
      estimatedDrawdownRange: drawdownRange,
      recommendedParadigm: recommendedParadigm,
      internationalBrewTips: tips,
    );
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  static String _formatClicks(int microns) {
    final c40 = (microns / 30).round();
    final c2 = (microns / 38).round();
    final kUltra = (microns / 20).round();
    final ode2 = ((microns - 250) / 85).clamp(1.5, 9.0).toStringAsFixed(1);
    return 'C40: ~$c40 klik • Timemore C2/C3: ~$c2 • K-Ultra: ~$kUltra • Ode 2: #$ode2';
  }

  static String _recommendedWaterChemistry(BeanRoastLevel roast, BeanProcess process) {
    if (roast == BeanRoastLevel.light && process == BeanProcess.washed) {
      return '45–65 ppm • GH 35 • KH 15 • pH 7.0 (Soft Clarity)';
    }
    if (process == BeanProcess.anaerobic || process == BeanProcess.natural) {
      return '65–85 ppm • GH 50 • KH 22 • pH 7.0 (Sweet Fruit Balance)';
    }
    if (roast == BeanRoastLevel.medium || roast == BeanRoastLevel.mediumLight) {
      return '80–110 ppm • GH 60 • KH 30 • pH 7.1 (SCA Golden Cup)';
    }
    return '105–135 ppm • GH 75 • KH 40 • pH 7.2 (Buffer Anti-Pahit)';
  }

  static String _recommendedRestWindow(
    BeanRoastLevel roast,
    BeanProcess process,
    bool isHyperSoluble,
  ) {
    if (isHyperSoluble) return '14–24 hari pasca-roast (degassing fermentasi)';
    return switch (roast) {
      BeanRoastLevel.light => '10–18 hari pasca-roast (puncak floral & manis)',
      BeanRoastLevel.mediumLight => '8–16 hari pasca-roast (SCA peak window)',
      BeanRoastLevel.medium => '6–14 hari pasca-roast',
      BeanRoastLevel.mediumDark => '4–10 hari pasca-roast',
      BeanRoastLevel.dark => '3–7 hari pasca-roast (CO2 cepat lepas)',
    };
  }

  static String _recommendedAgitation(
    BeanRoastLevel roast,
    BeanProcess process,
    bool isHyperSoluble,
  ) {
    if (roast == BeanRoastLevel.dark ||
        roast == BeanRoastLevel.mediumDark ||
        isHyperSoluble) {
      return 'Agitasi Rendah (Tuang lembut tengah, minim swirl)';
    }
    if (roast == BeanRoastLevel.light && process == BeanProcess.washed) {
      return 'Agitasi Terukur (Spiral stabil + gentle swirl akhir)';
    }
    return 'Agitasi Sedang (Spiral konsentris 4–5 ml/s)';
  }

  static String _roastGuidanceSummary(
    BeanRoastLevel roast,
    BeanProcess process,
    int temp,
    double ratio,
  ) {
    return switch (roast) {
      BeanRoastLevel.light =>
        'Light Roast (${process.label.split('/').first.trim()}): butuh energi panas tinggi ($temp°C) & rasio longgar 1:${ratio.toStringAsFixed(1)} agar gula alami & aroma bunga terbuka penuh tanpa kecut mentah.',
      BeanRoastLevel.mediumLight =>
        'Medium-Light: titik manis filter specialty modern — suhu $temp°C menyeimbangkan keasaman buah cerah dengan manis karamel.',
      BeanRoastLevel.medium =>
        'Medium Roast: paling fleksibel & seimbang di $temp°C (1:${ratio.toStringAsFixed(1)}), menonjolkan sweetness cokelat susu & body bulat.',
      BeanRoastLevel.mediumDark =>
        'Medium-Dark: gunakan suhu lebih rendah ($temp°C), gilingan lebih kasar & aliran lembut agar manis dark cocoa keluar tanpa pahit gosong.',
      BeanRoastLevel.dark =>
        'Dark Roast: struktur biji sangat berpori — seduh rendah suhu ($temp°C), rasio ketat 1:${ratio.toStringAsFixed(1)} & teknik center/osmotic agar bersih dan manis.',
    };
  }

  static String _formatDrawdownRange(int totalSec) {
    final int low = (totalSec - 10).clamp(90, 360);
    final int high = (totalSec + 15).clamp(110, 400);
    String fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
    return '${fmt(low)} – ${fmt(high)}';
  }

  static List<String> _buildInternationalTips({
    required BeanRoastLevel roast,
    required BeanProcess process,
    required FlavorGoal goal,
    required bool isHighDensity,
    required bool isHyperSoluble,
    required int temp,
    required int iceGrams,
    required String restWindow,
    required String agitation,
  }) {
    final tips = <String>[];
    if (goal == FlavorGoal.japaneseIced && iceGrams > 0) {
      tips.add(
        'Siapkan ${iceGrams}g es batu bening di server sebelum mulai seduh agar senyawa aromatik langsung terkunci dingin.',
      );
    }
    if (isHyperSoluble) {
      tips.add(
        'Proses ${process.label.split('/').first.trim()} sangat mudah larut: jaga suhu tetap $temp°C dan hindari swirl keras agar rasa buah bersih (tidak over-fermented).',
      );
    } else if (roast == BeanRoastLevel.light) {
      tips.add(
        isHighDensity
            ? 'Biji dataran tinggi padat: bilas kertas filter dengan air panas agar suhu dripper stabil di $temp°C sejak detik pertama.'
            : 'Light Roast: pastikan blooming penuh 45 detik agar pelepasan CO2 tuntas sebelum tuangan utama.',
      );
    } else if (roast == BeanRoastLevel.dark || roast == BeanRoastLevel.mediumDark) {
      tips.add(
        'Gunakan tinggi tuangan rendah dekat permukaan bubuk kopi ($agitation) untuk mencegah ekstraksi tanin pahit.',
      );
    } else {
      tips.add('$agitation dengan debit laminar stabil 4–5 ml/s untuk ekstraksi SCA Golden Cup.');
    }

    tips.add('Jendela resting ideal pasca-sangrai: $restWindow.');
    if (tips.length < 3) {
      tips.add(
        'Targetkan flat coffee bed saat drawdown akhir ($agitation) agar Extraction Yield berada di zona SCA Golden Cup 19–21%.',
      );
    }
    return tips.take(3).toList();
  }

  static List<String> _generateBeanNotes(
    List<String> officialNotes,
    String descriptors,
    BeanRoastLevel roast,
    BeanProcess process,
  ) {
    if (officialNotes.isNotEmpty) {
      final List<String> result = List<String>.from(officialNotes);
      return result.take(4).toList();
    }

    if (descriptors.contains('excelsa')) {
      return ['Buah Nangka Matang', 'Salak Manis Legit', 'Sweet Herbal', 'Caramel Aftertaste'];
    }
    if (descriptors.contains('gayo')) {
      return ['Gula Aren / Brown Sugar', 'Sweet Cane Sugar', 'Dark Cocoa', 'Clean Finish'];
    }
    if (descriptors.contains('kintamani') || descriptors.contains('bali')) {
      return ['Jeruk Keprok Manis', 'Milk Chocolate', 'Caramel Syrup', 'Citrus Blossom'];
    }
    if (descriptors.contains('toraja')) {
      return ['Rempah Manis Herbal', 'Dark Chocolate 70%', 'Citrus Zest', 'Heavy Creamy Body'];
    }
    if (descriptors.contains('kamojang') || descriptors.contains('patuha') || descriptors.contains('ciwidey')) {
      return ['Peach Kuning Matang', 'Madu Hutan', 'Bunga Melati', 'Teh Hitam Manis'];
    }

    if (roast == BeanRoastLevel.light) {
      return process == BeanProcess.washed
          ? ['Jasmine / Melati', 'Lemon Bergamot', 'Green Apple', 'Earl Grey Tea']
          : ['Strawberry Jam', 'Blueberry', 'Peach', 'Honey Nectar'];
    } else if (roast == BeanRoastLevel.mediumLight) {
      return process == BeanProcess.natural
          ? ['Ripe Mango', 'Papaya', 'Brown Sugar', 'Milk Chocolate']
          : ['Orange Zest', 'Caramelized Peach', 'Black Tea', 'Cane Sugar'];
    } else if (roast == BeanRoastLevel.medium) {
      return ['Toffee Butter', 'Milk Chocolate', 'Roasted Almond', 'Red Apple'];
    } else {
      return ['Dark Chocolate 85%', 'Roasted Walnut', 'Molasses', 'Spiced Oak'];
    }
  }

  static String _generateScientificReason(
    String name,
    String origin,
    String variety,
    BeanRoastLevel roast,
    BeanProcess process,
    FlavorGoal goal,
    int temp,
    double ratio,
    int microns, {
    int iceGrams = 0,
  }) {
    final vInfo = variety.isNotEmpty ? ' varietas $variety' : '';
    final oInfo = origin.isNotEmpty ? ' asal $origin' : '';
    final iceInfo = iceGrams > 0
        ? ' Dengan metode Japanese Iced (${iceGrams}g es batu), gilingan diperhalus ke $microns µm agar ekstraksi tetap kaya sebelum dilusi es.'
        : ' Suhu $temp°C dan gilingan $microns µm dengan rasio 1:${ratio.toStringAsFixed(1)} mengunci target ${goal.label} sesuai rentang SCA Golden Cup (18–22% EY) tanpa over-ekstraksi pahit.';
    return 'Berdasarkan densitas selular biji $name$oInfo$vInfo (${roast.label}) dengan proses ${process.label}.$iceInfo';
  }
}
