import 'dart:math' as math;

enum ColdBrewMode {
  immersionFridge,
  immersionRoom,
  kyotoDrip,
}

class ConcentrateDilutionPlan {
  final double coffeeDoseG;
  final double brewWaterMl;
  final double absorbedWaterMl;
  final double concentrateYieldMl;
  final double suggestedDilutionMl;
  final double suggestedIceG;
  final String brewRatioLabel;

  const ConcentrateDilutionPlan({
    required this.coffeeDoseG,
    required this.brewWaterMl,
    required this.absorbedWaterMl,
    required this.concentrateYieldMl,
    required this.suggestedDilutionMl,
    required this.suggestedIceG,
    required this.brewRatioLabel,
  });
}

class ArrheniusColdBrewCalculator {
  const ArrheniusColdBrewCalculator._();

  static const double _baseImmersionHoursAt20C = 12.0;
  static const double _q10Factor = 1.48;
  static const double _mlPerDrop = 0.05;

  /// Menghitung durasi imersi Cold Brew berbasis kinetika Arrhenius Q10 = 1.48.
  /// Kulkas 4°C -> ~22.5 jam; Suhu ruang 22°C -> ~11 jam (dibatasi 8–24 jam).
  static Duration calculateImmersionDuration({required double tempCelsius}) {
    final safeTemp = tempCelsius.clamp(2.0, 28.0);
    final hours =
        _baseImmersionHoursAt20C * math.pow(_q10Factor, (20.0 - safeTemp) / 10.0);
    final clampedSecs = (hours * 3600).round().clamp(28800, 86400);
    return Duration(seconds: clampedSecs);
  }

  /// Menghitung durasi menara tetes Kyoto Drip berdasarkan laju tetesan (BPM) & volume air.
  static Duration calculateKyotoDripDuration({
    required double waterMl,
    required int dripRateBpm,
  }) {
    final safeBpm = dripRateBpm.clamp(15, 90);
    final safeWater = waterMl.clamp(80.0, 3000.0);
    final mlPerSec = (safeBpm * _mlPerDrop) / 60.0;
    final secs = (safeWater / mlPerSec).round().clamp(14400, 43200);
    return Duration(seconds: secs);
  }

  static int dripIntervalMs(int bpm) => (60000 / bpm.clamp(15, 90)).round();

  /// Menghitung estimasi konsentrat bersih & saran pengenceran (air/susu/es) menuju strength 1:15.
  static ConcentrateDilutionPlan calculateDilution({
    required double coffeeDoseG,
    required double waterMl,
    double targetReadyRatio = 15.0,
  }) {
    final dose = coffeeDoseG.clamp(5.0, 1000.0);
    final water = waterMl.clamp(50.0, 5000.0);
    final absorbed = dose * 2.0;
    final yieldMl = math.max(water - absorbed, water * 0.55);
    final idealDrinkTotal = dose * targetReadyRatio.clamp(10.0, 18.0);
    final dilutionNeeded = math.max(0.0, idealDrinkTotal - yieldMl);
    final ratio = water / dose;
    return ConcentrateDilutionPlan(
      coffeeDoseG: dose,
      brewWaterMl: water,
      absorbedWaterMl: absorbed,
      concentrateYieldMl: yieldMl.roundToDouble(),
      suggestedDilutionMl: dilutionNeeded.roundToDouble(),
      suggestedIceG: (dilutionNeeded * 0.55).roundToDouble(),
      brewRatioLabel: '1:${ratio.toStringAsFixed(1)}',
    );
  }

  static String formatHHMMSS(Duration d) {
    final safe = d.isNegative ? Duration.zero : d;
    final h = safe.inHours.toString().padLeft(2, '0');
    final m = (safe.inMinutes % 60).toString().padLeft(2, '0');
    final s = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
