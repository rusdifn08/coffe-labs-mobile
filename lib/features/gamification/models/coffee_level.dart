import 'package:flutter/cupertino.dart';

/// 10 Prestigious Tiers of Specialty Coffee Mastery.
enum CoffeeLevelTier {
  noviceBrewer,
  aromaExplorer,
  extractionCraftsman,
  dialInAlchemist,
  sensorySommelier,
  masterOfTds,
  terroirVirtuoso,
  championshipBrewer,
  specialtyGrandmaster,
  legendaryQGrader,
}

class CoffeeLevel {
  final int level;
  final CoffeeLevelTier tier;
  final String title;
  final String indonesianTitle;
  final int minExp;
  final int nextLevelExp;
  final String quote;
  final IconData badgeIcon;
  final List<Color> borderGradient;
  final Color glowColor;
  final Color accentColor;
  final bool hasShinyAura;
  final bool hasCosmicParticles;

  const CoffeeLevel({
    required this.level,
    required this.tier,
    required this.title,
    required this.indonesianTitle,
    required this.minExp,
    required this.nextLevelExp,
    required this.quote,
    required this.badgeIcon,
    required this.borderGradient,
    required this.glowColor,
    required this.accentColor,
    this.hasShinyAura = false,
    this.hasCosmicParticles = false,
  });

  /// Daftar 10 Tingkatan Level Gamifikasi Barista
  static const List<CoffeeLevel> allLevels = [
    CoffeeLevel(
      level: 1,
      tier: CoffeeLevelTier.noviceBrewer,
      title: 'Novice Brewer',
      indonesianTitle: 'Pemula Seduh Presisi',
      minExp: 0,
      nextLevelExp: 200,
      quote: 'Langkah awal mengenali dunia seduhan kopi presisi.',
      badgeIcon: CupertinoIcons.drop,
      borderGradient: [Color(0xFF8D6E63), Color(0xFFA1887F)],
      glowColor: Color(0xFF6D4C41),
      accentColor: Color(0xFF8D6E63),
    ),
    CoffeeLevel(
      level: 2,
      tier: CoffeeLevelTier.aromaExplorer,
      title: 'Aroma Explorer',
      indonesianTitle: 'Penjelajah Aroma',
      minExp: 200,
      nextLevelExp: 500,
      quote: 'Mulai mengenali aroma floral, cokelat, dan buah segar.',
      badgeIcon: CupertinoIcons.wind,
      borderGradient: [Color(0xFF4CAF50), Color(0xFF81C784)],
      glowColor: Color(0xFF388E3C),
      accentColor: Color(0xFF43A047),
    ),
    CoffeeLevel(
      level: 3,
      tier: CoffeeLevelTier.extractionCraftsman,
      title: 'Extraction Craftsman',
      indonesianTitle: 'Artisan Ekstraksi',
      minExp: 500,
      nextLevelExp: 1000,
      quote: 'Menguasai kontrol rasio air, suhu, dan flow-rate stabil.',
      badgeIcon: CupertinoIcons.gear_alt_fill,
      borderGradient: [Color(0xFF78909C), Color(0xFFCFD8DC), Color(0xFF90A4AE)],
      glowColor: Color(0xFF546E7A),
      accentColor: Color(0xFF607D8B),
      hasShinyAura: true,
    ),
    CoffeeLevel(
      level: 4,
      tier: CoffeeLevelTier.dialInAlchemist,
      title: 'Dial-In Alchemist',
      indonesianTitle: 'Alkemis Dial-In',
      minExp: 1000,
      nextLevelExp: 1800,
      quote: 'Membedakan under-extracted sour dan over-bitter dalam sekejap.',
      badgeIcon: CupertinoIcons.sparkles,
      borderGradient: [Color(0xFF1E88E5), Color(0xFF64B5F6), Color(0xFF0D47A1)],
      glowColor: Color(0xFF1976D2),
      accentColor: Color(0xFF1565C0),
      hasShinyAura: true,
    ),
    CoffeeLevel(
      level: 5,
      tier: CoffeeLevelTier.sensorySommelier,
      title: 'Sensory Sommelier',
      indonesianTitle: 'Sommelier Sensorik',
      minExp: 1800,
      nextLevelExp: 3000,
      quote: 'Membaca spektrum rasa SCA Flavor Wheel dengan sensitivitas tinggi.',
      badgeIcon: CupertinoIcons.flame_fill,
      borderGradient: [Color(0xFFE91E63), Color(0xFFFF4081), Color(0xFFC2185B)],
      glowColor: Color(0xFFD81B60),
      accentColor: Color(0xFFC2185B),
      hasShinyAura: true,
    ),
    CoffeeLevel(
      level: 6,
      tier: CoffeeLevelTier.masterOfTds,
      title: 'Master of TDS & Solutes',
      indonesianTitle: 'Pakar Sains TDS',
      minExp: 3000,
      nextLevelExp: 4500,
      quote: 'Menavigasi grafik Golden Cup SCA dan kimia mineral air dengan presisi.',
      badgeIcon: CupertinoIcons.chart_bar_alt_fill,
      borderGradient: [Color(0xFFFFB300), Color(0xFFFFD54F), Color(0xFFFF8F00)],
      glowColor: Color(0xFFFFA000),
      accentColor: Color(0xFFFF8F00),
      hasShinyAura: true,
      hasCosmicParticles: true,
    ),
    CoffeeLevel(
      level: 7,
      tier: CoffeeLevelTier.terroirVirtuoso,
      title: 'Terroir & Origin Virtuoso',
      indonesianTitle: 'Virtuoso Terroir Dunia',
      minExp: 4500,
      nextLevelExp: 6500,
      quote: 'Memahami karakter micro-lot, elevasi mdpl, dan proses pasca panen.',
      badgeIcon: CupertinoIcons.globe,
      borderGradient: [Color(0xFF00897B), Color(0xFF4DB6AC), Color(0xFF004D40)],
      glowColor: Color(0xFF00796B),
      accentColor: Color(0xFF00897B),
      hasShinyAura: true,
      hasCosmicParticles: true,
    ),
    CoffeeLevel(
      level: 8,
      tier: CoffeeLevelTier.championshipBrewer,
      title: 'Championship Brewer',
      indonesianTitle: 'Brewer Kaliber Kejuaraan',
      minExp: 6500,
      nextLevelExp: 9000,
      quote: 'Standar kompetisi WBrC dunia dalam setiap tetes seduhan.',
      badgeIcon: CupertinoIcons.rosette,
      borderGradient: [Color(0xFFF4511E), Color(0xFFFF8A65), Color(0xFFBF360C), Color(0xFFFFAB91)],
      glowColor: Color(0xFFE64A19),
      accentColor: Color(0xFFD84315),
      hasShinyAura: true,
      hasCosmicParticles: true,
    ),
    CoffeeLevel(
      level: 9,
      tier: CoffeeLevelTier.specialtyGrandmaster,
      title: 'Grandmaster of Specialty Coffee',
      indonesianTitle: 'Grandmaster Seduh Kopi',
      minExp: 9000,
      nextLevelExp: 12500,
      quote: 'Penguasaan seduh tingkat maestro yang menginspirasi komunitas kopi.',
      badgeIcon: CupertinoIcons.star_fill,
      borderGradient: [Color(0xFF6A1B9A), Color(0xFFBA68C8), Color(0xFFFFD700), Color(0xFF8E24AA)],
      glowColor: Color(0xFF7B1FA2),
      accentColor: Color(0xFF8E24AA),
      hasShinyAura: true,
      hasCosmicParticles: true,
    ),
    CoffeeLevel(
      level: 10,
      tier: CoffeeLevelTier.legendaryQGrader,
      title: 'Legendary Q-Grader & Coffee Luminary',
      indonesianTitle: 'Legenda Kopi Specialty',
      minExp: 12500,
      nextLevelExp: 999999,
      quote: 'Puncak penguasaan kopi specialty tertinggi. Legenda abadi di balik bar.',
      badgeIcon: CupertinoIcons.shield_lefthalf_fill,
      borderGradient: [
        Color(0xFFFF1493),
        Color(0xFFFFD700),
        Color(0xFF00FFFF),
        Color(0xFF9D00FF),
        Color(0xFFFF4500),
      ],
      glowColor: Color(0xFFFFD700),
      accentColor: Color(0xFFFF8F00),
      hasShinyAura: true,
      hasCosmicParticles: true,
    ),
  ];

  /// Menghitung level saat ini berdasarkan total EXP
  static CoffeeLevel fromExp(int exp) {
    if (exp <= 0) return allLevels.first;
    for (int i = allLevels.length - 1; i >= 0; i--) {
      if (exp >= allLevels[i].minExp) {
        return allLevels[i];
      }
    }
    return allLevels.first;
  }

  /// Menghitung persentase progres menuju level berikutnya (0.0 s.d. 1.0)
  double getProgress(int currentExp) {
    if (level == 10) return 1.0;
    final range = nextLevelExp - minExp;
    if (range <= 0) return 1.0;
    final progress = (currentExp - minExp) / range;
    return progress.clamp(0.0, 1.0);
  }

  /// EXP yang dibutuhkan untuk naik ke level berikutnya
  int expNeededToNext(int currentExp) {
    if (level == 10) return 0;
    return (nextLevelExp - currentExp).clamp(0, nextLevelExp);
  }
}
