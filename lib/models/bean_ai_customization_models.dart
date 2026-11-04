import 'package:flutter/material.dart';
import 'bean_recommendation_models.dart';

/// Umur sangrai biji kopi (resting period) yang memengaruhi konsentrasi gas CO2.
enum BeanRoastAge {
  fresh(
    label: 'Segar (< 7 Hari)',
    badge: '⚡ Degassing Tinggi',
    description: 'Biji baru disangrai. Kandungan gas CO2 masih padat, memerlukan blooming lebih lama dan rasio air mekar lebih banyak agar tidak asam tajam.',
    bloomSecondsDelta: 15,
    bloomWaterMultiplier: 3.5,
    grindMicronDelta: 15,
  ),
  peak(
    label: 'Optimal (8–21 Hari)',
    badge: '✨ Golden Window',
    description: 'Puncak kematangan rasa dan aroma. Porositas biji dan kelarutan senyawa rasa berada dalam keseimbangan sempurna.',
    bloomSecondsDelta: 0,
    bloomWaterMultiplier: 2.8,
    grindMicronDelta: 0,
  ),
  aged(
    label: 'Resting Lama (> 22 Hari)',
    badge: '⏳ Degassed Stabil',
    description: 'Gas CO2 sudah stabil terlepas. Aliran air lebih lancar tanpa gelembung berlebih, disarankan gilingan sedikit lebih rapat untuk menjaga ekstraksi.',
    bloomSecondsDelta: -10,
    bloomWaterMultiplier: 2.3,
    grindMicronDelta: -15,
  );

  final String label;
  final String badge;
  final String description;
  final int bloomSecondsDelta;
  final double bloomWaterMultiplier;
  final int grindMicronDelta;

  const BeanRoastAge({
    required this.label,
    required this.badge,
    required this.description,
    required this.bloomSecondsDelta,
    required this.bloomWaterMultiplier,
    required this.grindMicronDelta,
  });
}

/// Profil kandungan mineral air seduh (PPM) yang menentukan kelarutan senyawa rasa.
enum WaterProfile {
  scaStandard(
    label: 'SCA Standard (120–150 PPM)',
    subtitle: 'Keseimbangan Kalsium & Magnesium optimal',
    icon: Icons.water_drop_outlined,
    tempDelta: 0,
    clarityScore: 4.2,
  ),
  softWater(
    label: 'Air Lunak / Low PPM (40–75 PPM)',
    subtitle: 'Menonjolkan asam buah cerah & floral',
    icon: Icons.opacity,
    tempDelta: 1,
    clarityScore: 4.8,
  ),
  hardWater(
    label: 'Air Mineral Tinggi (180+ PPM)',
    subtitle: 'Body tebal, meredam keasaman buah',
    icon: Icons.grain,
    tempDelta: -2,
    clarityScore: 3.6,
  ),
  remineralized(
    label: 'Custom / Kejuaraan (Lotus / Aquacode)',
    subtitle: 'Ekstraksi presisi ionik kelas dunia',
    icon: Icons.science_outlined,
    tempDelta: 0,
    clarityScore: 4.9,
  );

  final String label;
  final String subtitle;
  final IconData icon;
  final int tempDelta;
  final double clarityScore;

  const WaterProfile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.tempDelta,
    required this.clarityScore,
  });
}

/// Paradigma dan gaya penuangan seduh manual.
enum PouringParadigm {
  specialtyStandard(
    label: 'Standard 3-Pulse',
    badge: 'Seimbang',
    desc: 'Metode 3 tuangan stabil melingkar untuk manis dan kejernihan seimbang.',
  ),
  tetsu46(
    label: 'Tetsu Kasuya 4:6',
    badge: 'Juara Dunia',
    desc: '40% awal mengatur manis & asam, 60% berikutnya mengatur body dan ketebalan.',
  ),
  lanceHedrick121(
    label: 'Lance Hedrick 1-2-1',
    badge: 'High Extraction',
    desc: 'Ekstraksi tinggi dengan agitasi terukur dan drawdown sangat bersih.',
  ),
  hoffmannUltimate(
    label: 'James Hoffmann V60',
    badge: 'Presisi Tinggi',
    desc: 'Suhu air konstan stabil dengan putaran swirl lembut di akhir.',
  ),
  osmoticFlow(
    label: 'Osmotic Center Flow',
    badge: 'Manis Legit',
    desc: 'Tuangan tengah lembut minim turbulensi, mengunci rasa manis dan anti-sepat.',
  );

  final String label;
  final String badge;
  final String desc;

  const PouringParadigm({
    required this.label,
    required this.badge,
    required this.desc,
  });
}

/// Aksi diagnosis cerdas (AI Dial-In Doctor) untuk koreksi rasa seduhan sebelumnya.
enum AiTweakAction {
  tooSour(
    label: 'Terlalu Asam / Kecut',
    icon: Icons.sentiment_dissatisfied_outlined,
    diagnosis: 'Under-Extraction (Asam organik terekstraksi lebih dulu sebelum gula melarut).',
    suggestion: 'AI menaikkan suhu air +2°C dan memperhalus gilingan 1 klik untuk memicu ekstraksi sukrosa.',
    tempAdjust: 2,
    micronAdjust: -25,
    ratioAdjust: 0.0,
  ),
  tooBitter(
    label: 'Terlalu Pahit / Sepat',
    icon: Icons.sentiment_very_dissatisfied_outlined,
    diagnosis: 'Over-Extraction / Channeling (Senyawa fenolik & tanin pahit ikut larut).',
    suggestion: 'AI memperkasar gilingan 1 klik dan menurunkan suhu -2°C untuk memotong rasa pahit.',
    tempAdjust: -2,
    micronAdjust: 30,
    ratioAdjust: 0.5,
  ),
  tooWatery(
    label: 'Terasa Encer / Hambar',
    icon: Icons.opacity,
    diagnosis: 'Konsentrasi Terlalu Rendah (TDS rendah akibat rasio air terlalu longgar).',
    suggestion: 'AI memperketat rasio seduh ke 1:14.5 dan memperpanjang kontak seduhan.',
    tempAdjust: 0,
    micronAdjust: -15,
    ratioAdjust: -0.8,
  ),
  boostSweetness(
    label: 'Ingin Sweetness Lebih Maksimal',
    icon: Icons.star_border_purple500_outlined,
    diagnosis: 'Potensi Gula Karamel Belum Terkunci Penuh.',
    suggestion: 'AI memperpanjang blooming dan mengaktifkan metode ekstraksi Tetsu Kasuya 4:6.',
    tempAdjust: 0,
    micronAdjust: 0,
    ratioAdjust: 0.0,
  );

  final String label;
  final IconData icon;
  final String diagnosis;
  final String suggestion;
  final int tempAdjust;
  final int micronAdjust;
  final double ratioAdjust;

  const AiTweakAction({
    required this.label,
    required this.icon,
    required this.diagnosis,
    required this.suggestion,
    required this.tempAdjust,
    required this.micronAdjust,
    required this.ratioAdjust,
  });
}

/// Metrik sains ekstraksi seduh kopi berbasis Golden Cup SCA.
class AiExtractionScience {
  final double estimatedTds;
  final double estimatedExtractionYield;
  final String goldenCupStatus;
  final double targetFlowRate;
  final String waterEfficiency;

  const AiExtractionScience({
    required this.estimatedTds,
    required this.estimatedExtractionYield,
    required this.goldenCupStatus,
    required this.targetFlowRate,
    required this.waterEfficiency,
  });

  factory AiExtractionScience.calculate({
    required double coffeeDose,
    required double totalWater,
    required int waterTemp,
    required int grindMicrons,
    required BeanRoastLevel roast,
    required BeanRoastAge roastAge,
    required WaterProfile water,
  }) {
    // Estimasi TDS matematis: TDS (%) ~ (Dose * SolubleRatio) / TotalWater * Efisiensi
    double baseSolubility = 0.20;
    if (roast == BeanRoastLevel.light) baseSolubility = 0.19;
    if (roast == BeanRoastLevel.dark) baseSolubility = 0.22;

    // Koreksi suhu & gilingan
    final double tempFactor = 1.0 + ((waterTemp - 90) * 0.012);
    final double grindFactor = 1.0 - ((grindMicrons - 600) * 0.0004);
    final double rawYield = baseSolubility * tempFactor * grindFactor;
    final double yieldClamped = (rawYield * 100).clamp(17.5, 23.0);

    final double beverageWeight = totalWater - (coffeeDose * 2.0); // Retensi ampas ~2x
    final double calculatedTds = (coffeeDose * (yieldClamped / 100)) / beverageWeight * 100;
    final double tdsClamped = calculatedTds.clamp(1.15, 1.55);

    String status = 'SCA Golden Cup Target (18–22%)';
    if (yieldClamped < 18.0) {
      status = 'Under-Extracted (Asam Dominan)';
    } else if (yieldClamped > 22.0) {
      status = 'Tinggi (Kaya Senyawa Kompleks)';
    }

    final double flowRate = (totalWater / 150.0).clamp(1.6, 2.8);

    return AiExtractionScience(
      estimatedTds: double.parse(tdsClamped.toStringAsFixed(2)),
      estimatedExtractionYield: double.parse(yieldClamped.toStringAsFixed(1)),
      goldenCupStatus: status,
      targetFlowRate: double.parse(flowRate.toStringAsFixed(1)),
      waterEfficiency: water == WaterProfile.softWater ? 'Tinggi (98.2%)' : 'Optimal (96.5%)',
    );
  }
}

/// Helper generator tahapan penuangan seduh cerdas berdasarkan paradigma barista juara.
class BeanStepGenerator {
  static void populateSteps({
    required List<Map<String, dynamic>> steps,
    required PouringParadigm paradigm,
    required FlavorGoal goal,
    required String leadNote,
    required int bloomWater,
    required int bloomSec,
    required double remainingWater,
    required double totalWater,
  }) {
    steps.add({
      'stepOrder': 1,
      'title': 'Fase 1: Blooming & Degassing Gas CO2',
      'durationSeconds': bloomSec,
      'waterAddedGrams': bloomWater,
      'instruction': 'Tuang memutar konsentris perlahan dari tengah. Basahi merata untuk melepaskan gas CO2 yang terperangkap.',
    });

    if (paradigm == PouringParadigm.tetsu46) {
      final int p2 = (totalWater * 0.20).round();
      final int remaining60 = (totalWater - bloomWater - p2).round();
      final int p3 = (remaining60 / 3).round();
      final int p4 = p3;
      final int p5 = remaining60 - (p3 * 2);

      steps.add({
        'stepOrder': 2,
        'title': 'Fase 2 (4:6): Kunci Manis & Asam ($leadNote)',
        'durationSeconds': 45,
        'waterAddedGrams': p2,
        'instruction': 'Tuangan kedua Tetsu Kasuya untuk mengunci keseimbangan rasa manis dan keasaman buah.',
      });
      steps.add({
        'stepOrder': 3,
        'title': 'Fase 3 (4:6): Pembentukan Kekuatan Seduhan',
        'durationSeconds': 40,
        'waterAddedGrams': p3,
        'instruction': 'Tuang rata melingkar untuk membentuk kepekatan ekstraksi larutan kopi.',
      });
      steps.add({
        'stepOrder': 4,
        'title': 'Fase 4 (4:6): Pembentukan Body & Mouthfeel',
        'durationSeconds': 40,
        'waterAddedGrams': p4,
        'instruction': 'Pertahankan level air untuk stabilitas suhu dan pelepasan senyawa lipid manis.',
      });
      steps.add({
        'stepOrder': 5,
        'title': 'Fase 5 (4:6): Penutupan & Drawdown Final',
        'durationSeconds': 45,
        'waterAddedGrams': p5,
        'instruction': 'Tuang lembut terpusat hingga target air tercapai dan tunggu drawdown tuntas.',
      });
    } else if (paradigm == PouringParadigm.lanceHedrick121) {
      steps.add({
        'stepOrder': 2,
        'title': 'Fase 2: Single Continuous Low Agitation',
        'durationSeconds': 80,
        'waterAddedGrams': remainingWater.round(),
        'instruction': 'Tuang lembut stabil dengan corong rendah dekat permukaan untuk memaksimalkan yield tanpa fines channeling.',
      });
    } else if (paradigm == PouringParadigm.osmoticFlow) {
      steps.add({
        'stepOrder': 2,
        'title': 'Fase 2: Osmotic Center Pour Flow',
        'durationSeconds': 85,
        'waterAddedGrams': remainingWater.round(),
        'instruction': 'Tuang aliran air tetes kontinu hanya di titik tengah (center drip) tanpa merusak kubah kopi (coffee dome).',
      });
    } else if (goal == FlavorGoal.highAcidity) {
      final int p1 = (remainingWater * 0.55).round();
      final int p2 = (remainingWater - p1).round();
      steps.add({
        'stepOrder': 2,
        'title': 'Fase 2: Ekstraksi Asam Buah & $leadNote',
        'durationSeconds': 45,
        'waterAddedGrams': p1,
        'instruction': 'Tuangan deras dengan agitasi sedang untuk mengangkat aroma buah dan asam organik ke permukaan.',
      });
      steps.add({
        'stepOrder': 3,
        'title': 'Fase 3: Finishing & Drawdown Bersih',
        'durationSeconds': 50,
        'waterAddedGrams': p2,
        'instruction': 'Tuang perlahan di tengah (center pour) untuk menjaga kejernihan dan menghindari kepahitan astringent.',
      });
    } else if (goal == FlavorGoal.heavyBody) {
      final int each = (remainingWater / 3).round();
      final int last = (remainingWater - (each * 2)).round();
      steps.add({
        'stepOrder': 2,
        'title': 'Fase 2: Pulse Body Ke-1 ($leadNote)',
        'durationSeconds': 35,
        'waterAddedGrams': each,
        'instruction': 'Tuangan spiral teratur untuk memicu ekstraksi karamelisasi gula kompleks.',
      });
      steps.add({
        'stepOrder': 3,
        'title': 'Fase 3: Pulse Body Ke-2',
        'durationSeconds': 35,
        'waterAddedGrams': each,
        'instruction': 'Pertahankan ketinggian air di dalam kerucut dripper untuk tekanan drawdown stabil.',
      });
      steps.add({
        'stepOrder': 4,
        'title': 'Fase 4: Pulse Penutup & Tekstur',
        'durationSeconds': 45,
        'waterAddedGrams': last,
        'instruction': 'Penuangan akhir lembut hingga selesai menetes.',
      });
    } else {
      final int p1 = (remainingWater * 0.50).round();
      final int p2 = (remainingWater - p1).round();
      steps.add({
        'stepOrder': 2,
        'title': 'Fase 2: Pembentukan Keseimbangan ($leadNote)',
        'durationSeconds': 45,
        'waterAddedGrams': p1,
        'instruction': 'Penuangan stabil melingkar. Air melarutkan sukrosa manis alami dan asam amino seimbang.',
      });
      steps.add({
        'stepOrder': 3,
        'title': 'Fase 3: Penyempurnaan Body & Aftertaste',
        'durationSeconds': 45,
        'waterAddedGrams': p2,
        'instruction': 'Tuang lembut melingkar hingga timbangan mencapai target total air.',
      });
    }
  }
}
