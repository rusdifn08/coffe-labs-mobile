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
  sweetBalanced('Sweet & Balanced', 'Keseimbangan ideal rasa manis gula alami dan keasaman segar'),
  highAcidity('High Acidity & Clarity', 'Keasaman buah yang cerah, clean finish dan aroma bunga mekar'),
  heavyBody('Heavy Body & Sweet', 'Tekstur kental di lidah, aftertaste manis panjang dan cokelat');

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

  const RecommendedBrewRecipe({
    required this.beanName,
    required this.roastLevel,
    required this.process,
    required this.goal,
    required this.dripper,
    required this.coffeeDose,
    required this.brewRatio,
    required this.totalWater,
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
  });

  Map<String, dynamic> toRecipeMap() {
    return {
      'id': 99000 + (coffeeDose.round() * 10) + roastLevel.index,
      'title': '$beanName • ${roastLevel.label}',
      'author': 'Smart Brew AI Recommendation ☕',
      'category': 'Smart Dial-In',
      'method': dripper.label,
      'beanName': beanName,
      'variety': 'Specialty Single Origin',
      'process': process.label,
      'waterTempCelsius': waterTemp,
      'grindSize': '$grindMicrons µm ($grindClickLabel)',
      'coffeeWeightGrams': coffeeDose.round(),
      'totalWaterWeightGrams': totalWater.round(),
      'iceWeightGrams': 0,
      'totalTimeSeconds': totalTimeSeconds,
      'description': scientificReason,
      'tastingNotes': predictedTastingNotes.join(', '),
      'steps': steps,
    };
  }
}

class BeanRecommenderEngine {
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
    final String cleanDescriptors = '$beanName $origin $variety ${tastingNotes.join(" ")}'.toLowerCase();

    // 1. Hitung Rasio Seduh Adaptif
    double ratio = 15.0;
    if (goal == FlavorGoal.highAcidity) {
      ratio = (roast == BeanRoastLevel.light) ? 16.0 : 15.5;
    } else if (goal == FlavorGoal.heavyBody) {
      ratio = (roast == BeanRoastLevel.dark || roast == BeanRoastLevel.mediumDark) ? 13.5 : 14.5;
    } else {
      if (cleanDescriptors.contains('excelsa') || cleanDescriptors.contains('liberica')) {
        ratio = 14.5;
      } else if (roast == BeanRoastLevel.light) {
        ratio = 15.5;
      } else {
        ratio = 15.0;
      }
    }
    if (customRatioAdjust != null) ratio += customRatioAdjust;
    final double totalWater = (dose * ratio).roundToDouble();

    // 2. Hitung Suhu Air Panas Ilmiah
    int temp = switch (roast) {
      BeanRoastLevel.light => 94,
      BeanRoastLevel.mediumLight => 92,
      BeanRoastLevel.medium => 90,
      BeanRoastLevel.mediumDark => 88,
      BeanRoastLevel.dark => 86,
    };

    // Koreksi Suhu Berdasarkan Karakter Biji
    if (cleanDescriptors.contains('excelsa') || cleanDescriptors.contains('liberica')) {
      temp = 89;
    } else if (process == BeanProcess.anaerobic && temp > 90) {
      temp -= 2;
    } else if (process == BeanProcess.natural && temp > 92) {
      temp -= 1;
    } else if (process == BeanProcess.washed && roast == BeanRoastLevel.light) {
      temp = 94;
    }

    if (dripper == BeanDripper.chemex) temp += 1;
    if (dripper == BeanDripper.aeropress) temp -= 2;
    temp += waterProfile.tempDelta + (customTempAdjust ?? 0);

    // 3. Hitung Grind Size Mikron & Klik Grinder
    int microns = switch (roast) {
      BeanRoastLevel.light => (goal == FlavorGoal.highAcidity) ? 570 : 600,
      BeanRoastLevel.mediumLight => 620,
      BeanRoastLevel.medium => 640,
      BeanRoastLevel.mediumDark => 690,
      BeanRoastLevel.dark => 750,
    };

    if (process == BeanProcess.natural || process == BeanProcess.anaerobic) {
      microns += 25; // Kompensasi fines pada biji natural/fermentasi
    }
    if (cleanDescriptors.contains('excelsa')) microns += 30;
    if (dripper == BeanDripper.chemex) microns += 75;
    if (dripper == BeanDripper.kalita) microns -= 25;
    if (dripper == BeanDripper.aeropress) microns -= 40;
    microns += roastAge.grindMicronDelta + (customMicronAdjust ?? 0);

    final String clickLabel = _formatClicks(microns);

    // 4. Tahap Penuangan Berfase (Pour Schedule)
    final double bloomMult = (process == BeanProcess.natural ? 3.0 : 2.7) * (roastAge.bloomWaterMultiplier / 2.8);
    final int bloomWater = (dose * bloomMult).round();
    final int baseBloomSec = (process == BeanProcess.natural || process == BeanProcess.anaerobic) ? 45 : 35;
    final int bloomSec = (baseBloomSec + roastAge.bloomSecondsDelta).clamp(25, 60);
    final double remainingWater = totalWater - bloomWater;

    final List<Map<String, dynamic>> steps = [];
    final String leadNote = tastingNotes.isNotEmpty ? tastingNotes.first : 'senyawa rasa';

    BeanStepGenerator.populateSteps(
      steps: steps,
      paradigm: pouringParadigm,
      goal: goal,
      leadNote: leadNote,
      bloomWater: bloomWater,
      bloomSec: bloomSec,
      remainingWater: remainingWater,
      totalWater: totalWater,
    );

    final int totalTime = steps.fold<int>(0, (acc, s) => acc + (s['durationSeconds'] as int));

    // 5. Prediksi Profil Cita Rasa 5-Dimensi Robust (Sensory Radar)
    double acidity = 3.2;
    double sweetness = 3.6;
    double body = 3.3;
    double bitterness = 1.6;
    double clarity = 4.0;

    // A. Pengaruh Tingkat Sangrai
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

    // B. Pengaruh Proses Pasca-Panen
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

    // C. Analisis Sensorik Biji Riil (Deskriptor Rasa, Varietas & Asal Biji)
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

    // D. Target Profil Rasa
    if (goal == FlavorGoal.highAcidity) {
      acidity += 0.3;
      clarity += 0.2;
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

    // 6. Tasting Notes Riil Biji Kopi
    final List<String> notes = _generateBeanNotes(tastingNotes, cleanDescriptors, roast, process);

    // 7. Alasan Ilmiah Kimia Ekstraksi
    final String reason = _generateScientificReason(beanName, origin, variety, roast, process, goal, temp, ratio, microns);

    return RecommendedBrewRecipe(
      beanName: beanName.trim().isEmpty ? 'Single Origin Specialty' : beanName.trim(),
      roastLevel: roast,
      process: process,
      goal: goal,
      dripper: dripper,
      coffeeDose: dose,
      brewRatio: ratio,
      totalWater: totalWater,
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
    );
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  static String _formatClicks(int microns) {
    final c40 = (microns / 30).round();
    final c2 = (microns / 38).round();
    final kUltra = (microns / 20).round();
    return 'C40 MK4: ~$c40 klik • Timemore C2: ~$c2 klik • K-Ultra: ~$kUltra klik';
  }

  static List<String> _generateBeanNotes(List<String> officialNotes, String descriptors, BeanRoastLevel roast, BeanProcess process) {
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
    int microns,
  ) {
    final vInfo = variety.isNotEmpty ? ' varietas $variety' : '';
    final oInfo = origin.isNotEmpty ? ' asal $origin' : '';
    return 'Berdasarkan densitas selular biji $name$oInfo$vInfo (${roast.label}) dengan proses ${process.label}, '
        'kandungan asam organik dan gula alami membutuhkan suhu $temp°C dan gilingan $microns µm. '
        'Rasio 1:${ratio.toStringAsFixed(1)} mengunci target ${goal.label} tanpa memicu over-ekstraksi fenolik pahit.';
  }
}
