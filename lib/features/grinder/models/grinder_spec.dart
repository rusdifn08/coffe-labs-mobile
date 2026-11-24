/// Kategori penggerak grinder kopi.
enum GrinderCategory {
  manual,
  electric,
}

/// Tingkat kelengkapan data kalibrasi granulometri pada literatur terbuka.
enum CalibrationTier {
  /// Memiliki multi-jangkar terverifikasi lintas metode seduh (BrewMark / HCG / Manual Pabrikan).
  fullMultiAnchor,

  /// Memiliki jangkar V60/sebagian metode terverifikasi, segmen lain mengikuti langkah mekanis pabrikan.
  partialAnchor,

  /// Belum ada tabel granulometri/mikron independen — hanya spesifikasi mekanis (anti-halusinasi).
  specOnly,
}

/// Arsitektur dial fisik grinder untuk menerjemahkan nilai klik/skala ke posisi jarum sesungguhnya.
enum DialSystemType {
  /// Dial tanpa angka tercetak: hitung klik dari nol (Comandante C40, Timemore C2/C3, Hario, Porlex, dll).
  countFromZero,

  /// Dial bernomor Putaran.Angka.Klik (1Zpresso, KINGrinder K0-K3/K5, Timemore C3/C5 ESP, Blade R3, Normcore V2, dll).
  rotNumSubClick,

  /// Dial satu putaran saja (Angka.Klik tanpa putaran penuh), misal Timemore S3 (0-9.0), Mavo Phantox Pro (0-12.0), C5 Pro.
  singleRotNumSubClick,

  /// Dial cetak nomor langsung per putaran, misal KINGrinder K4/K6 (0-59 per putaran -> 1.40) & Race M1 (24 grid -> 1.11).
  rotDirectNumber,

  /// Dial Kinu M47 (50 divisi/putaran = 10 angka x 5 divisi, umum dibaca Putaran.Angka seperti 3.5 putaran = 175 klik).
  kinuRotNum,

  /// Flair Royal Crown (24 klik/putaran, 2 klik/angka, angka kontinyu No. 0 - 36 across 3 rotations).
  flairCrown,

  /// Timemore Chestnut X Dual Dial (Major 0-24 + Minor 0-5).
  dualMajorMinor,

  /// Grinder elektrik bertahap (Baratza Encore/ESP, De'Longhi, Breville SGP, Hario V60 Electric, Feima 600N, Fiorenzato AllGround).
  electricStepped,

  /// Fellow Ode Gen 2 (1-11 dengan 3 posisi per angka: .0, .1, .2) & Fellow Opus Gen 1 (4 sub-klik).
  fellowSubStep,

  /// Grinder elektrik/flat stepless skala desimal langsung (DF54, DF64 Gen 2, Niche Zero, EK43, Sculptor, Pietro, dll).
  electricStepless,

  /// Eureka Mignon Specialità stepless multi-putaran: Putaran+Angka (6 angka per putaran penuh, misal 1+1.5).
  eurekaMultiTurn,

  /// Model tanpa data kalibrasi klik/mikron terverifikasi.
  uncalibrated,
}

/// Titik jangkar metode seduh terverifikasi: pasangan ukuran partikel (µm) dan setelan dial grinder.
class BrewAnchor {
  final double microns;
  final double setting;
  final String methodLabel;

  const BrewAnchor({
    required this.microns,
    required this.setting,
    required this.methodLabel,
  });
}

/// Standar acuan titik tengah ukuran partikel (µm) lintas metode seduh (Honest Coffee Guide & BrewMark).
class BrewMicronAnchors {
  static const double turkish = 150.0;
  static const double espresso = 280.0;
  static const double mokaPot = 480.0;
  static const double aeroPress = 550.0;
  static const double v60 = 650.0;
  static const double pourOver = 720.0;
  static const double frenchPress = 975.0;
  static const double coldBrew = 1175.0;
}

/// Spesifikasi teknis lengkap satu model grinder (manual maupun elektrik).
class GrinderSpec {
  final String id;
  final String brand;
  final String model;
  final GrinderCategory category;
  final String burrSpec;
  final String dialPlacement; // 'Internal', 'Eksternal', 'Top Dial', 'Stepped', 'Stepless', dll.
  final DialSystemType dialType;
  final CalibrationTier calibrationTier;

  /// Jumlah klik per 1 putaran penuh (0 jika bukan mekanisme rotasi multi-putaran).
  final int clicksPerRotation;

  /// Jumlah klik per 1 angka dial (0 jika tanpa angka / langsung).
  final int clicksPerNumber;

  /// Jumlah angka per putaran (misal 10 untuk 0-9, 12 untuk 0-11, 6 untuk K6 0-50).
  final int numbersPerRotation;

  /// Resolusi aksial/step pabrikan dalam mikron per klik (null jika tidak dipublikasi pabrikan).
  final double? micronsPerClick;

  /// Apakah angka micronsPerClick merupakan pergerakan aksial ulir (bukan celah partikel langsung).
  final bool isAxialMicronSpec;

  /// Rentang nilai dial numerik minimum & maksimum (untuk slider & validasi).
  final double minSetting;
  final double maxSetting;

  /// Jumlah desimal saat menampilkan nilai numerik (0 untuk klik integer, 1 untuk stepless).
  final int valueDecimals;

  /// Titik jangkar terverifikasi (wajib terurut naik berdasarkan microns).
  final List<BrewAnchor> anchors;

  /// Jika true, grinder dirancang khusus filter/pour-over (tidak direkomendasikan untuk espresso).
  final bool filterOnly;

  /// Batas minimum mikron aman sebelum gesekan burr (burr rub) atau limit fisik.
  final double? minRecommendedMicrons;

  /// Catatan arah putar, zero-point, rentang alternatif, atau catatan pasar Indonesia.
  final String calibrationNote;

  /// Label singkat struktur dial untuk ditampilkan di UI.
  final String dialStructureSummary;

  const GrinderSpec({
    required this.id,
    required this.brand,
    required this.model,
    required this.category,
    required this.burrSpec,
    required this.dialPlacement,
    required this.dialType,
    required this.calibrationTier,
    this.clicksPerRotation = 0,
    this.clicksPerNumber = 0,
    this.numbersPerRotation = 0,
    this.micronsPerClick,
    this.isAxialMicronSpec = true,
    required this.minSetting,
    required this.maxSetting,
    this.valueDecimals = 0,
    required this.anchors,
    this.filterOnly = false,
    this.minRecommendedMicrons,
    required this.calibrationNote,
    required this.dialStructureSummary,
  });

  String get fullName => model.toLowerCase().startsWith(brand.toLowerCase())
      ? model
      : '$brand $model';

  bool get isCalibrated =>
      calibrationTier != CalibrationTier.specOnly && anchors.length >= 2;
}

/// Representasi pembacaan dial fisik yang siap dipraktikkan barista di grinder sungguhan.
class DialReading {
  /// Nilai mentah numerik (misal 86 klik, atau 64.4 untuk DF64 Gen 2).
  final double rawValue;

  /// Tampilan ringkas utama (misal "86 klik", "Dial 64.4", "Setting 25").
  final String primaryDisplay;

  /// Notasi posisi dial fisik (misal "2.1.2", "1.40", "0+4.0", "1 put + 8 klik").
  final String physicalNotation;

  /// Panduan langkah praktis dalam bahasa Indonesia untuk menyetel grinder fisik.
  final String humanInstruction;

  /// Peringatan bila berada di luar zona optimal (misal filter-only / burr rub / batas maks).
  final String? warning;

  const DialReading({
    required this.rawValue,
    required this.primaryDisplay,
    required this.physicalNotation,
    required this.humanInstruction,
    this.warning,
  });
}

/// Hasil lengkap konversi dari satu grinder asal ke satu grinder tujuan.
class GrinderConversionResult {
  final GrinderSpec source;
  final double sourceSetting;
  final DialReading sourceReading;
  final double estimatedMicrons;
  final String brewZoneLabel;
  final GrinderSpec target;
  final DialReading? targetReading;
  final String? notice;

  const GrinderConversionResult({
    required this.source,
    required this.sourceSetting,
    required this.sourceReading,
    required this.estimatedMicrons,
    required this.brewZoneLabel,
    required this.target,
    required this.targetReading,
    this.notice,
  });
}
