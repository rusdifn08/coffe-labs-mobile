import 'package:flutter/cupertino.dart';

enum StorageMethod {
  valveBag(
    'One-Way Valve Bag (25°C)',
    'Kemasan standar kedap udara dengan katup satu arah pada suhu ruang.',
    1.0,
    CupertinoIcons.bag_fill,
  ),
  freezerVacuum(
    'Deep Freeze Vacuum (-18°C)',
    'Metode WBrC Champion: Pembekuan vakum menghentikan penuaan kimiawi biji hingga 90%.',
    0.15,
    CupertinoIcons.snow,
  ),
  openHopper(
    'Hopper Terbuka / Toples Kaca',
    'Terpapar udara & cahaya: Oksidasi dan staling terjadi 2.5x lebih cepat.',
    2.5,
    CupertinoIcons.sun_max_fill,
  );

  final String label;
  final String description;
  final double agingMultiplier;
  final IconData icon;

  const StorageMethod(this.label, this.description, this.agingMultiplier, this.icon);
}

enum FreshnessStage {
  resting(
    '⚡ Masih Degassing (Disarankan Istirahat)',
    'Kopi masih aktif melepaskan gas karbon dioksida (CO2) dalam jumlah besar. Gas akan menolak penetrasi air.',
    Color(0xFFE65100),
    CupertinoIcons.hourglass,
  ),
  peak(
    '🔥 Puncak Kenikmatan (Peak Flavor Window)',
    'Biji kopi berada pada fase rasa terbaiknya! Senyawa volatil aromatik dan rasa manis berada di intensitas tertinggi.',
    Color(0xFF2E7D32),
    CupertinoIcons.flame_fill,
  ),
  mature(
    '⏳ Stabil & Bulat (Mature Body)',
    'Gas CO2 tenang sempurna, menghasilkan ekstraksi stabil dengan mouthfeel dan body yang membulat manis.',
    Color(0xFF1565C0),
    CupertinoIcons.checkmark_shield_fill,
  ),
  pastPeak(
    '🍂 Melewati Puncak (Past Peak)',
    'Senyawa aromatik bunga dan buah mulai menurun. Sangat cocok untuk cold brew, es kopi susu, atau metode imersi.',
    Color(0xFF5D4037),
    CupertinoIcons.wind,
  );

  final String label;
  final String desc;
  final Color color;
  final IconData icon;

  const FreshnessStage(this.label, this.desc, this.color, this.icon);
}

class BrewAdjustment {
  final int bloomTimeSeconds;
  final double bloomWaterRatio;
  final int recommendedTempC;
  final String grindAdvice;
  final String agitationAdvice;

  const BrewAdjustment({
    required this.bloomTimeSeconds,
    required this.bloomWaterRatio,
    required this.recommendedTempC,
    required this.grindAdvice,
    required this.agitationAdvice,
  });

  factory BrewAdjustment.calculate({
    required FreshnessStage stage,
    required String roastLevel,
    required bool isEspresso,
  }) {
    if (isEspresso) {
      switch (stage) {
        case FreshnessStage.resting:
          return const BrewAdjustment(
            bloomTimeSeconds: 8, // pre-infusion
            bloomWaterRatio: 2.0,
            recommendedTempC: 93,
            grindAdvice: 'Giling 1/2 step lebih kasar (biji banyak gas menciptakan hambatan ekstra)',
            agitationAdvice: 'Pre-infusion 8-10 detik wajib diaktifkan untuk melepaskan CO2 di puck.',
          );
        case FreshnessStage.peak:
          return const BrewAdjustment(
            bloomTimeSeconds: 4,
            bloomWaterRatio: 2.0,
            recommendedTempC: 93,
            grindAdvice: 'Dial-in standar (Target ekstraksi 25-30 detik)',
            agitationAdvice: 'Pre-infusion standar 3-5 detik untuk ekstraksi manis merata.',
          );
        case FreshnessStage.mature:
          return const BrewAdjustment(
            bloomTimeSeconds: 3,
            bloomWaterRatio: 2.0,
            recommendedTempC: 92,
            grindAdvice: 'Giling 1/2 step lebih halus untuk menjaga tekanan 9 bar stabil',
            agitationAdvice: 'Puck stabil, tidak memerlukan pre-infusion panjang.',
          );
        case FreshnessStage.pastPeak:
          return const BrewAdjustment(
            bloomTimeSeconds: 2,
            bloomWaterRatio: 2.0,
            recommendedTempC: 90,
            grindAdvice: 'Giling 1 step lebih halus agar puck tidak under-extract',
            agitationAdvice: 'Tamp lebih padat atau gunakan puck screen untuk membatasi channeling.',
          );
      }
    }

    // Manual Filter (V60/Aeropress)
    final baseTemp = roastLevel == 'Light' ? 93 : (roastLevel == 'Dark' ? 88 : 91);
    switch (stage) {
      case FreshnessStage.resting:
        return BrewAdjustment(
          bloomTimeSeconds: 50,
          bloomWaterRatio: 3.5,
          recommendedTempC: baseTemp,
          grindAdvice: '+1 klik lebih kasar (gas CO2 menahan aliran air di dasar dripper)',
          agitationAdvice: 'Goyang dripper (swirl) atau sendok lembut di fase bloom untuk memecah gelembung gas.',
        );
      case FreshnessStage.peak:
        return BrewAdjustment(
          bloomTimeSeconds: 40,
          bloomWaterRatio: 3.0,
          recommendedTempC: baseTemp,
          grindAdvice: 'Rekomendasi grind size ideal standar V60',
          agitationAdvice: 'Cukup swirl ringan satu kali saat blooming untuk membasahi seluruh bubuk.',
        );
      case FreshnessStage.mature:
        return BrewAdjustment(
          bloomTimeSeconds: 35,
          bloomWaterRatio: 2.5,
          recommendedTempC: baseTemp - 1,
          grindAdvice: '-1 klik lebih halus agar drawdown tidak terlalu cepat',
          agitationAdvice: 'Hindari adukan keras agar serbuk halus (fines) tidak menyumbat pori filter.',
        );
      case FreshnessStage.pastPeak:
        return BrewAdjustment(
          bloomTimeSeconds: 30,
          bloomWaterRatio: 2.5,
          recommendedTempC: baseTemp - 2,
          grindAdvice: '-2 klik lebih halus dan pertimbangkan metode imersi (Clever / Aeropress)',
          agitationAdvice: 'Tuang lembut dari ketinggian rendah untuk meminimalkan agitasi berlebih.',
        );
    }
  }
}
