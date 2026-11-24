import 'dart:math' as math;

/// Status risiko mesin espresso (boiler scaling vs korosi).
enum BoilerSafetyStatus {
  optimal,
  scalingRisk,
  corrosionRisk,
  tooPure,
}

/// Sumber air dasar (termasuk preset air kemasan & keran populer di Indonesia).
class BaseWaterPreset {
  final String id;
  final String name;
  final String subtitle;
  final double ghPpm;
  final double khPpm;
  final double tdsPpm;
  final double naMgL;
  final double clMgL;
  final double mgShare; // Fraksi GH yang berasal dari Mg2+ (sisanya Ca2+)

  const BaseWaterPreset({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.ghPpm,
    required this.khPpm,
    required this.tdsPpm,
    this.naMgL = 0,
    this.clMgL = 0,
    this.mgShare = 0.35,
  });
}

/// Input dosis mineral tambahan (satuan mg garam food-grade per 1 Liter air).
class MineralAddition {
  /// Magnesium Sulfate Heptahydrate / Epsom Salt (MgSO4·7H2O, MM = 246.47 g/mol)
  final double epsomSaltMgPerL;

  /// Calcium Chloride Dihydrate (CaCl2·2H2O, MM = 147.01 g/mol)
  final double calciumChlorideMgPerL;

  /// Sodium Bicarbonate / Baking Soda (NaHCO3, MM = 84.007 g/mol)
  final double bakingSodaMgPerL;

  /// Potassium Bicarbonate (KHCO3, MM = 100.115 g/mol)
  final double potassiumBicarbMgPerL;

  /// Rasio pencampuran dengan air RO/Destilasi 0 ppm (0.0 = 100% air dasar, 0.5 = 50% RO).
  final double roDilutionRatio;

  const MineralAddition({
    this.epsomSaltMgPerL = 0,
    this.calciumChlorideMgPerL = 0,
    this.bakingSodaMgPerL = 0,
    this.potassiumBicarbMgPerL = 0,
    this.roDilutionRatio = 0,
  });

  MineralAddition copyWith({
    double? epsomSaltMgPerL,
    double? calciumChlorideMgPerL,
    double? bakingSodaMgPerL,
    double? potassiumBicarbMgPerL,
    double? roDilutionRatio,
  }) {
    return MineralAddition(
      epsomSaltMgPerL: epsomSaltMgPerL ?? this.epsomSaltMgPerL,
      calciumChlorideMgPerL: calciumChlorideMgPerL ?? this.calciumChlorideMgPerL,
      bakingSodaMgPerL: bakingSodaMgPerL ?? this.bakingSodaMgPerL,
      potassiumBicarbMgPerL: potassiumBicarbMgPerL ?? this.potassiumBicarbMgPerL,
      roDilutionRatio: roDilutionRatio ?? this.roDilutionRatio,
    );
  }
}

/// Skor 5 sumbu dampak sensori hasil simulasi kimia air (0–100).
class WaterSensoryScores {
  final double acidityClarity;
  final double sweetness;
  final double bodyMouthfeel;
  final double floralAroma;
  final double smoothnessBalance;

  const WaterSensoryScores({
    required this.acidityClarity,
    required this.sweetness,
    required this.bodyMouthfeel,
    required this.floralAroma,
    required this.smoothnessBalance,
  });
}

/// Hasil kalkulasi kimia air lengkap (stoikiometri aktual, EC/TDS, pH, boiler risk, sensori).
class WaterChemistryAnalysis {
  final double ghPpm;
  final double khPpm;
  final double mgGhPpm;
  final double caGhPpm;
  final double mgIonMgL;
  final double caIonMgL;
  final double naIonMgL;
  final double kIonMgL;
  final double so4IonMgL;
  final double clIonMgL;
  final double hco3IonMgL;
  final double estimatedTdsPpm;
  final double estimatedEcUsCm;
  final double estimatedPh;
  final double ghKhRatio;
  final double mgCaRatio;
  final BoilerSafetyStatus boilerStatus;
  final String boilerHeadline;
  final String boilerAdvice;
  final int readinessScore; // 0–100
  final WaterSensoryScores sensory;
  final String profileSummary;
  final List<String> whatIfInsights;

  const WaterChemistryAnalysis({
    required this.ghPpm,
    required this.khPpm,
    required this.mgGhPpm,
    required this.caGhPpm,
    required this.mgIonMgL,
    required this.caIonMgL,
    required this.naIonMgL,
    required this.kIonMgL,
    required this.so4IonMgL,
    required this.clIonMgL,
    required this.hco3IonMgL,
    required this.estimatedTdsPpm,
    required this.estimatedEcUsCm,
    required this.estimatedPh,
    required this.ghKhRatio,
    required this.mgCaRatio,
    required this.boilerStatus,
    required this.boilerHeadline,
    required this.boilerAdvice,
    required this.readinessScore,
    required this.sensory,
    required this.profileSummary,
    required this.whatIfInsights,
  });
}

/// Input pembacaan dari 3 kelas sensor air (TDS/EC, Ion Selektif ISE, & E-Tongue Multi-Sensor).
class WaterSensorReadings {
  /// Nilai konduktivitas listrik dalam µS/cm (atau hasil konversi dari TDS ppm).
  final double ecUsCm;

  /// Faktor konversi EC -> TDS pada meter (0.50 NaCl, 0.64 KCl/Kopi, 0.70 442).
  final double tdsFactor;

  /// Suhu air sampel (°C) untuk catatan kompensasi suhu ATC (25°C referensi).
  final double temperatureC;

  /// Pembacaan ISE / test kit ion spesifik:
  final double freeChlorineMgL; // Cl2 (wajib 0.0 mg/L)
  final double chlorideMgL; // Cl- (ideal < 35 mg/L, korosi > 50 mg/L)
  final double nitrateMgL; // NO3- (ideal < 10 mg/L, batas WHO 50 mg/L)
  final double ammoniumMgL; // NH4+ (ideal < 0.5 mg/L)
  final double sodiumSalinityMgL; // Na+ (ideal < 20 mg/L, asin > 30 mg/L)
  final double measuredPh;

  const WaterSensorReadings({
    this.ecUsCm = 156.0,
    this.tdsFactor = 0.64,
    this.temperatureC = 25.0,
    this.freeChlorineMgL = 0.0,
    this.chlorideMgL = 12.0,
    this.nitrateMgL = 2.0,
    this.ammoniumMgL = 0.0,
    this.sodiumSalinityMgL = 8.0,
    this.measuredPh = 7.1,
  });

  double get tdsPpm => ecUsCm * tdsFactor;
}

/// Output analisis diagnostik gabungan dari Sensor TDS/EC, ISE, dan E-Tongue.
class SensorDiagnosticReport {
  final double tdsPpm;
  final double ecUsCm;
  final String tdsCategory;
  final String tdsDiagnosis;
  final bool hasContaminantAlert;
  final List<String> iseAlerts;
  final Map<String, double> eTongueChannels; // 5 kanal virtual E-Tongue (0–100)
  final int overallScore;
  final String recommendedAction;
  final BaseWaterPreset estimatedBaseWater;

  const SensorDiagnosticReport({
    required this.tdsPpm,
    required this.ecUsCm,
    required this.tdsCategory,
    required this.tdsDiagnosis,
    required this.hasContaminantAlert,
    required this.iseAlerts,
    required this.eTongueChannels,
    required this.overallScore,
    required this.recommendedAction,
    required this.estimatedBaseWater,
  });
}

/// Mesin Sains Kimia Air Seduh Kopi (Stoikiometri Aktual, Simulasi What-If Mineral, & Multi-Sensor).
class WaterChemistryEngine {
  WaterChemistryEngine._();

  // Faktor stoikiometri eksak (per 1 mg/L garam murni):
  // 1. MgSO4·7H2O (MM = 246.47 g/mol) -> GH as CaCO3 (MM = 100.0869)
  static const double epsomGhFactor = 100.0869 / 246.47; // 0.40608 ppm CaCO3
  static const double epsomMgIonFactor = 24.305 / 246.47; // 0.09861 mg/L Mg2+
  static const double epsomSo4IonFactor = 96.06 / 246.47; // 0.38974 mg/L SO4^2-

  // 2. CaCl2·2H2O (MM = 147.01 g/mol) -> GH as CaCO3
  static const double cacl2GhFactor = 100.0869 / 147.01; // 0.68082 ppm CaCO3
  static const double cacl2CaIonFactor = 40.078 / 147.01; // 0.27262 mg/L Ca2+
  static const double cacl2ClIonFactor = 70.906 / 147.01; // 0.48232 mg/L Cl-

  // 3. NaHCO3 (MM = 84.007 g/mol) -> KH as CaCO3 (equiv weight = 50.0435)
  static const double nahco3KhFactor = 50.0435 / 84.007; // 0.59571 ppm CaCO3
  static const double nahco3NaIonFactor = 22.990 / 84.007; // 0.27367 mg/L Na+
  static const double nahco3Hco3Factor = 61.0168 / 84.007; // 0.72633 mg/L HCO3-

  // 4. KHCO3 (MM = 100.115 g/mol) -> KH as CaCO3
  static const double khco3KhFactor = 50.0435 / 100.115; // 0.49986 ppm CaCO3
  static const double khco3KIonFactor = 39.098 / 100.115; // 0.39053 mg/L K+
  static const double khco3Hco3Factor = 61.0168 / 100.115; // 0.60947 mg/L HCO3-

  static const double defaultEcFactor = 0.64; // TDS (ppm) = 0.64 * EC (µS/cm)

  static const List<BaseWaterPreset> baseWaters = [
    BaseWaterPreset(
      id: 'ro_amidis',
      name: 'RO / Amidis / Destilasi',
      subtitle: 'Air kosong (~0–5 ppm) · kanvas terbaik untuk racik mineral',
      ghPpm: 2,
      khPpm: 2,
      tdsPpm: 4,
      naMgL: 0.5,
      clMgL: 0.5,
    ),
    BaseWaterPreset(
      id: 'cleo',
      name: 'Cleo Demineral',
      subtitle: 'Sangat rendah mineral (~15 ppm) · aman untuk remineralisasi',
      ghPpm: 8,
      khPpm: 6,
      tdsPpm: 15,
      naMgL: 2,
      clMgL: 2,
    ),
    BaseWaterPreset(
      id: 'mineral_ringan',
      name: 'Air Mineral Ringan (Pristine / Nestle)',
      subtitle: 'Sedang-ringan (~75 ppm) · cocok langsung untuk pour-over',
      ghPpm: 45,
      khPpm: 32,
      tdsPpm: 75,
      naMgL: 8,
      clMgL: 8,
      mgShare: 0.40,
    ),
    BaseWaterPreset(
      id: 'aqua_mineral',
      name: 'Air Mineral Gunung (Aqua / Le Minerale)',
      subtitle: 'Mineral menengah (~125 ppm) · bisa diencerkan RO untuk filter',
      ghPpm: 82,
      khPpm: 58,
      tdsPpm: 125,
      naMgL: 12,
      clMgL: 14,
      mgShare: 0.42,
    ),
    BaseWaterPreset(
      id: 'pdam_tap',
      name: 'Air PDAM / Keran Kota',
      subtitle: 'TDS tinggi (~240 ppm) · butuh karbon aktif + dilusi RO',
      ghPpm: 145,
      khPpm: 110,
      tdsPpm: 240,
      naMgL: 24,
      clMgL: 38,
      mgShare: 0.28,
    ),
    BaseWaterPreset(
      id: 'well_hard',
      name: 'Air Sumur Sadah (Hard Water)',
      subtitle: 'Sangat keras (~420 ppm) · risiko tinggi kerak boiler & rasa flat',
      ghPpm: 260,
      khPpm: 185,
      tdsPpm: 420,
      naMgL: 35,
      clMgL: 52,
      mgShare: 0.25,
    ),
  ];

  /// Menganalisis komposisi air aktual dari air dasar + rasio RO + penambahan 4 garam mineral.
  static WaterChemistryAnalysis analyze({
    required BaseWaterPreset baseWater,
    required MineralAddition addition,
  }) {
    final dilution = addition.roDilutionRatio.clamp(0.0, 0.95);
    final retain = 1.0 - dilution;

    final baseGh = baseWater.ghPpm * retain;
    final baseKh = baseWater.khPpm * retain;
    final baseMgGh = baseGh * baseWater.mgShare;
    final baseCaGh = baseGh * (1.0 - baseWater.mgShare);
    final baseNa = baseWater.naMgL * retain;
    final baseCl = baseWater.clMgL * retain;

    // Tambahan stoikiometrik dari garam mineral (mg/L)
    final addedMgGh = addition.epsomSaltMgPerL * epsomGhFactor;
    final addedCaGh = addition.calciumChlorideMgPerL * cacl2GhFactor;
    final addedNaKh = addition.bakingSodaMgPerL * nahco3KhFactor;
    final addedKKh = addition.potassiumBicarbMgPerL * khco3KhFactor;

    final totalMgGh = baseMgGh + addedMgGh;
    final totalCaGh = baseCaGh + addedCaGh;
    final totalGh = totalMgGh + totalCaGh;
    final totalKh = baseKh + addedNaKh + addedKKh;

    final mgIon = (baseMgGh * 0.2428) + (addition.epsomSaltMgPerL * epsomMgIonFactor);
    final caIon = (baseCaGh * 0.4004) + (addition.calciumChlorideMgPerL * cacl2CaIonFactor);
    final naIon = baseNa + (addition.bakingSodaMgPerL * nahco3NaIonFactor);
    final kIon = addition.potassiumBicarbMgPerL * khco3KIonFactor;
    final so4Ion = addition.epsomSaltMgPerL * epsomSo4IonFactor;
    final clIon = baseCl + (addition.calciumChlorideMgPerL * cacl2ClIonFactor);
    final hco3Ion = (baseKh * 1.219) +
        (addition.bakingSodaMgPerL * nahco3Hco3Factor) +
        (addition.potassiumBicarbMgPerL * khco3Hco3Factor);

    // Estimasi TDS (mg/L ion terlarut) & Konduktivitas Listrik EC (µS/cm)
    final baseTdsRetained = baseWater.tdsPpm * retain;
    final addedAnhydrousTds = (addition.epsomSaltMgPerL * 0.4884) + // MgSO4 anhidrat
        (addition.calciumChlorideMgPerL * 0.7549) + // CaCl2 anhidrat
        (addition.bakingSodaMgPerL * 1.0) +
        (addition.potassiumBicarbMgPerL * 1.0);
    final totalTds = (baseTdsRetained + addedAnhydrousTds).clamp(0.0, 1500.0);
    final totalEc = totalTds / defaultEcFactor;

    // Estimasi pH kesetimbangan bikarbonat dengan CO2 atmosfer (25°C)
    final double estimatedPh;
    if (totalKh <= 1.5) {
      estimatedPh = 6.35;
    } else {
      // Aproksimasi Henderson-Hasselbalch pada pCO2 atmosfer ~415 ppm:
      // KH 20 -> ~7.1, KH 40 -> ~7.4, KH 100 -> ~7.8, KH 200 -> ~8.1
      estimatedPh = (6.3 + 0.68 * (math.log(totalKh) / math.ln10)).clamp(6.2, 8.4);
    }

    final ghKhRatio = totalKh > 0.5 ? (totalGh / totalKh) : totalGh;
    final mgCaRatio = totalCaGh > 0.5 ? (totalMgGh / totalCaGh) : (totalMgGh > 0 ? 5.0 : 1.0);

    // Evaluasi keamanan boiler espresso (LSI disederhanakan pada 93°C + risiko korosi Cl-)
    final BoilerSafetyStatus boilerStatus;
    final String boilerHeadline;
    final String boilerAdvice;
    if (totalTds < 35 || totalGh < 20) {
      boilerStatus = BoilerSafetyStatus.tooPure;
      boilerHeadline = 'Terlalu Murni (Kurang Mineral)';
      boilerAdvice =
          'Air terlalu kosong sehingga rasa kopi tipis/asam tajam dan sensor level air boiler bisa gagal mendeteksi konduktivitas.';
    } else if (clIon > 50 || (totalKh < 15 && clIon > 25)) {
      boilerStatus = BoilerSafetyStatus.corrosionRisk;
      boilerHeadline = 'Waspada Korosi Klorida (Cl⁻ ${clIon.round()} mg/L)';
      boilerAdvice =
          'Klorida > 50 mg/L atau buffer KH terlalu rendah berisiko memicu korosi pitting pada boiler stainless steel. Kurangi CaCl₂ atau naikkan KH.';
    } else if (totalCaGh > 75 && totalKh > 60) {
      boilerStatus = BoilerSafetyStatus.scalingRisk;
      boilerHeadline = 'Risiko Kerak Kapur Boiler (CaCO₃)';
      boilerAdvice =
          'Kombinasi Kalsium tinggi (Ca-GH ${totalCaGh.round()} ppm) + Alkalinitas tinggi (KH ${totalKh.round()} ppm) cepat membentuk kerak di boiler 93°C. Encerkan dengan RO atau ganti sebagian Ca²⁺ dengan Mg²⁺.';
    } else {
      boilerStatus = BoilerSafetyStatus.optimal;
      boilerHeadline = 'Aman Mesin Espresso & Ideal Seduh';
      boilerAdvice =
          'Keseimbangan Ca/Mg, buffer KH, dan klorida rendah berada di zona aman dari kerak maupun korosi.';
    }

    // 5-Axis Sensory Impact Simulation (0–100)
    final acidityClarity = (92.0 - (totalKh * 0.72) + (totalMgGh * 0.14)).clamp(15.0, 98.0);
    final sweetness = (52.0 +
            (40.0 * math.exp(-math.pow((totalGh - 75.0) / 55.0, 2))) +
            (totalMgGh > totalCaGh ? 6.0 : 2.0) +
            (naIon >= 3 && naIon <= 18 ? 5.0 : (naIon > 30 ? -12.0 : 0.0)))
        .clamp(20.0, 98.0);
    final bodyMouthfeel = (32.0 +
            (totalCaGh * 0.78) +
            (totalMgGh * 0.25) +
            (totalKh * 0.18))
        .clamp(18.0, 98.0);
    final floralAroma = (44.0 +
            (totalMgGh * 0.55) -
            (totalKh * 0.42) -
            (clIon > 35 ? 10.0 : 0.0) +
            (kIon > 0 ? 5.0 : 0.0))
        .clamp(15.0, 98.0);
    final smoothnessBalance = (95.0 -
            (totalGh - 75.0).abs() * 0.35 -
            (totalKh - 38.0).abs() * 0.55 -
            (naIon > 30 ? 15.0 : 0.0))
        .clamp(15.0, 98.0);

    // Readiness Score (0–100) berdasar rentang emas SCA (GH 50–100, KH 25–55, TDS 75–175)
    double score = 100.0;
    if (totalGh < 45) score -= (45 - totalGh) * 0.8;
    if (totalGh > 120) score -= (totalGh - 120) * 0.4;
    if (totalKh < 18) score -= (18 - totalKh) * 1.1;
    if (totalKh > 60) score -= (totalKh - 60) * 0.65;
    if (totalTds < 50) score -= (50 - totalTds) * 0.5;
    if (totalTds > 200) score -= (totalTds - 200) * 0.25;
    if (clIon > 50) score -= 18;
    if (naIon > 35) score -= 12;
    final readinessScore = score.round().clamp(10, 100);

    // Ringkasan Profil Rasa & What-If Insights
    final String summary;
    if (totalGh < 30 && totalKh < 20) {
      summary = 'Air Ultra-Soft: Ekstraksi sangat ringan; kopi terasa tipis, tajam, & kurang manis.';
    } else if (totalKh > 75) {
      summary = 'Over-Buffered (KH Tinggi): Keasaman buah teredam habis, kopi terasa datar/chalky & berat.';
    } else if (ghKhRatio > 2.8 && totalMgGh >= totalCaGh) {
      summary = 'Bright & Juicy Filter Profile: Dominasi Mg²⁺ + buffer rendah meledakkan aroma buah, floral, & keasaman cerah.';
    } else if (totalCaGh > totalMgGh * 1.3 && totalGh >= 60) {
      summary = 'Creamy Espresso & Body Profile: Dominasi Ca²⁺ + Cl⁻ menonjolkan tekstur kental, cokelat, & finish bulat.';
    } else {
      summary = 'Balanced Specialty Cup: Keseimbangan manis, kejernihan rasa, keasaman segar, & body harmonis.';
    }

    final insights = <String>[];
    if (addition.epsomSaltMgPerL > 0) {
      insights.add(
        'MgSO₄ (+${addition.epsomSaltMgPerL.round()} mg/L): menambah +${addedMgGh.toStringAsFixed(1)} ppm GH (Mg²⁺) & ${so4Ion.toStringAsFixed(1)} mg/L SO₄²⁻ → menarik senyawa buah/floral lebih kuat dengan finish crisp.',
      );
    }
    if (addition.calciumChlorideMgPerL > 0) {
      insights.add(
        'CaCl₂ (+${addition.calciumChlorideMgPerL.round()} mg/L): menambah +${addedCaGh.toStringAsFixed(1)} ppm GH (Ca²⁺) & ${(addition.calciumChlorideMgPerL * cacl2ClIonFactor).toStringAsFixed(1)} mg/L Cl⁻ → mempertebal body creamy & memperhalus asam.',
      );
    }
    if (addition.bakingSodaMgPerL > 0) {
      insights.add(
        'NaHCO₃ (+${addition.bakingSodaMgPerL.round()} mg/L): menambah +${addedNaKh.toStringAsFixed(1)} ppm KH buffer → menetralkan asam tajam; Na⁺ total ${naIon.toStringAsFixed(1)} mg/L${naIon > 30 ? ' (⚠️ mulai terasa asin!)' : ' (aman, membantu persepsi manis)'}.',
      );
    }
    if (addition.potassiumBicarbMgPerL > 0) {
      insights.add(
        'KHCO₃ (+${addition.potassiumBicarbMgPerL.round()} mg/L): menambah +${addedKKh.toStringAsFixed(1)} ppm KH buffer bersih tanpa Natrium → menjaga kejernihan rasa pour-over.',
      );
    }
    if (dilution > 0.01) {
      insights.add(
        'Dilusi ${(dilution * 100).round()}% Air RO: menurunkan kesadahan air dasar dari ${baseWater.ghPpm.round()} → ${baseGh.round()} ppm GH sebelum remineralisasi.',
      );
    }
    if (insights.isEmpty) {
      insights.add(
        'Geser slider mineral di atas untuk melihat simulasi reaksi kimia aktual (GH, KH, pH, EC, risiko boiler, & prediksi rasa cangkir).',
      );
    }

    return WaterChemistryAnalysis(
      ghPpm: totalGh,
      khPpm: totalKh,
      mgGhPpm: totalMgGh,
      caGhPpm: totalCaGh,
      mgIonMgL: mgIon,
      caIonMgL: caIon,
      naIonMgL: naIon,
      kIonMgL: kIon,
      so4IonMgL: so4Ion,
      clIonMgL: clIon,
      hco3IonMgL: hco3Ion,
      estimatedTdsPpm: totalTds,
      estimatedEcUsCm: totalEc,
      estimatedPh: estimatedPh,
      ghKhRatio: ghKhRatio,
      mgCaRatio: mgCaRatio,
      boilerStatus: boilerStatus,
      boilerHeadline: boilerHeadline,
      boilerAdvice: boilerAdvice,
      readinessScore: readinessScore,
      sensory: WaterSensoryScores(
        acidityClarity: acidityClarity,
        sweetness: sweetness,
        bodyMouthfeel: bodyMouthfeel,
        floralAroma: floralAroma,
        smoothnessBalance: smoothnessBalance,
      ),
      profileSummary: summary,
      whatIfInsights: insights,
    );
  }

  /// Menganalisis data dari 3 kelas sensor: TDS/EC, ISE Ion Selektif, dan E-Tongue Multi-Sensor.
  static SensorDiagnosticReport diagnoseSensors(WaterSensorReadings r) {
    final tds = r.tdsPpm;
    final ec = r.ecUsCm;

    String tdsCat;
    String tdsDiag;
    if (tds < 40) {
      tdsCat = 'Ultra-Soft / Demineral';
      tdsDiag =
          'Konduktivitas sangat rendah (${ec.round()} µS/cm). Sangat ideal sebagai air kanvas (base) untuk ditambah mineral Mg/Ca/KH.';
    } else if (tds <= 150) {
      tdsCat = 'Ideal Specialty (SCA Zone)';
      tdsDiag =
          'Total padatan terlarut ${tds.round()} ppm (${ec.round()} µS/cm) berada di rentang emas SCA (50–150 ppm) untuk ekstraksi seimbang.';
    } else if (tds <= 220) {
      tdsCat = 'Moderat-Tinggi (Batas Atas)';
      tdsDiag =
          'Mineral mulai padat (${tds.round()} ppm). Cocok untuk dark roast/espresso, namun untuk V60 light roast disarankan diencerkan 30–50% air RO.';
    } else {
      tdsCat = 'Air Sadah / Hard Water';
      tdsDiag =
          'Konduktivitas tinggi (${ec.round()} µS/cm / ${tds.round()} ppm). Berisiko meredam aroma kopi (flat) & memicu kerak kapur cepat pada ketel/mesin.';
    }

    final iseAlerts = <String>[];
    if (r.freeChlorineMgL > 0.05) {
      iseAlerts.add(
        '🚨 Klorin Bebas (${r.freeChlorineMgL.toStringAsFixed(2)} mg/L): Menyebabkan off-flavor kaporit/plastik/medisinal. Wajib gunakan filter Karbon Aktif (GAC/Carbon Block)!',
      );
    }
    if (r.chlorideMgL > 50) {
      iseAlerts.add(
        '⚠️ Klorida Tinggi (${r.chlorideMgL.round()} mg/L > 50 mg/L): Memicu korosi pitting pada boiler espresso stainless steel.',
      );
    }
    if (r.nitrateMgL > 45) {
      iseAlerts.add(
        '🚨 Nitrat Tinggi (${r.nitrateMgL.round()} mg/L): Mendekati/melewati batas aman WHO 50 mg/L (indikasi pencemaran limpasan organik). Gunakan membran RO.',
      );
    } else if (r.nitrateMgL > 15) {
      iseAlerts.add(
        'ℹ️ Nitrat Moderat (${r.nitrateMgL.round()} mg/L): Masih aman diminum, namun air RO + remineralisasi memberi kejernihan rasa lebih bersih.',
      );
    }
    if (r.ammoniumMgL > 0.5) {
      iseAlerts.add(
        '🚨 Amonium Terdeteksi (${r.ammoniumMgL.toStringAsFixed(2)} mg/L > 0,5 mg/L): Indikasi kontaminasi organik / bau tidak sedap — tidak layak untuk seduh specialty.',
      );
    }
    if (r.sodiumSalinityMgL > 30) {
      iseAlerts.add(
        '⚠️ Salinitas / Natrium Tinggi (${r.sodiumSalinityMgL.round()} mg/L): Memunculkan rasa asin/sabun (umami berlebih) pada cangkir kopi.',
      );
    }
    if (r.measuredPh < 6.5 || r.measuredPh > 8.0) {
      iseAlerts.add(
        '⚠️ pH Di Luar Ideal SCA (${r.measuredPh.toStringAsFixed(1)}): Target SCA berada pada pH 6.8–7.6 (7.0 netral ideal).',
      );
    }

    // E-Tongue Multi-Sensor Pattern Fingerprint (5 kanal virtual 0–100)
    final sourChannel = (75.0 - (r.measuredPh - 6.5) * 28.0 - (tds * 0.08)).clamp(10.0, 98.0);
    final sweetChannel = (45.0 +
            42.0 * math.exp(-math.pow((tds - 95.0) / 75.0, 2)) -
            (r.freeChlorineMgL > 0.05 ? 25.0 : 0.0))
        .clamp(10.0, 96.0);
    final saltyChannel = (12.0 + r.sodiumSalinityMgL * 1.45 + r.chlorideMgL * 0.35).clamp(5.0, 98.0);
    final bitterContamChannel = (10.0 +
            r.freeChlorineMgL * 75.0 +
            r.ammoniumMgL * 35.0 +
            (r.nitrateMgL > 20 ? (r.nitrateMgL - 20) * 0.7 : 0.0))
        .clamp(5.0, 98.0);
    final chalkyFlatChannel = (10.0 +
            (tds > 150 ? (tds - 150) * 0.32 : 0.0) +
            (r.measuredPh > 7.6 ? (r.measuredPh - 7.6) * 32.0 : 0.0))
        .clamp(5.0, 98.0);

    double score = 100.0;
    if (tds < 45) score -= (45 - tds) * 0.55;
    if (tds > 150) score -= (tds - 150) * 0.25;
    if (r.freeChlorineMgL > 0.05) score -= 35;
    if (r.ammoniumMgL > 0.5) score -= 30;
    if (r.nitrateMgL > 45) score -= 25;
    if (r.chlorideMgL > 50) score -= 18;
    if (r.sodiumSalinityMgL > 30) score -= 14;
    if (r.measuredPh < 6.5 || r.measuredPh > 8.0) score -= 12;
    final overallScore = score.round().clamp(5, 100);

    String action;
    if (r.freeChlorineMgL > 0.05 || r.ammoniumMgL > 0.5 || r.nitrateMgL > 45) {
      action = 'Wajib filtrasi Karbon Aktif + Reverse Osmosis (RO) sebelum dipakai menyeduh kopi.';
    } else if (tds < 40) {
      action = 'Tambahkan mineral (MgSO₄ + KHCO₃/NaHCO₃) di tab Lab Kustom untuk mencapai target 65–100 ppm.';
    } else if (tds > 180) {
      final idealDilution = ((1.0 - (95.0 / tds)) * 100).round().clamp(25, 80);
      action = 'Encerkan dengan ~$idealDilution% air RO/Amidis di tab Lab Kustom agar TDS turun ke ~95 ppm.';
    } else {
      action = 'Air siap seduh! Anda tetap bisa fine-tune +Mg²⁺ atau +Ca²⁺ di tab Lab Kustom sesuai karakter biji.';
    }

    // Estimasi base water preset untuk 1-tap transfer ke Lab Kustom
    final estimatedGh = (tds * 0.58).clamp(2.0, 350.0);
    final estimatedKh = (tds * 0.42).clamp(2.0, 260.0);
    final estimatedBase = BaseWaterPreset(
      id: 'sensor_detected',
      name: 'Hasil Deteksi Sensor (${tds.round()} ppm)',
      subtitle: 'EC ${ec.round()} µS/cm · pH ${r.measuredPh.toStringAsFixed(1)} · Cl⁻ ${r.chlorideMgL.round()} mg/L',
      ghPpm: estimatedGh,
      khPpm: estimatedKh,
      tdsPpm: tds,
      naMgL: r.sodiumSalinityMgL,
      clMgL: r.chlorideMgL,
      mgShare: 0.35,
    );

    return SensorDiagnosticReport(
      tdsPpm: tds,
      ecUsCm: ec,
      tdsCategory: tdsCat,
      tdsDiagnosis: tdsDiag,
      hasContaminantAlert: iseAlerts.isNotEmpty,
      iseAlerts: iseAlerts,
      eTongueChannels: {
        'Kecerahan Asam (Sour/Citric)': sourChannel,
        'Potensi Manis (Sweetness)': sweetChannel,
        'Salinitas / Mineral (Salty)': saltyChannel,
        'Risiko Off-Flavor / Kaporit': bitterContamChannel,
        'Flat / Chalky (Over-Buffer)': chalkyFlatChannel,
      },
      overallScore: overallScore,
      recommendedAction: action,
      estimatedBaseWater: estimatedBase,
    );
  }
}
