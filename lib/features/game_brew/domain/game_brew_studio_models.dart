import 'package:flutter/material.dart';

enum GameBrewDiscipline {
  manualBrew3d,
  latteArt3d,
}

enum GameBrewDifficulty {
  basic,
  intermediate,
  advance,
  master,
}

extension GameBrewDifficultyX on GameBrewDifficulty {
  String get label {
    switch (this) {
      case GameBrewDifficulty.basic:
        return 'Dasar';
      case GameBrewDifficulty.intermediate:
        return 'Menengah';
      case GameBrewDifficulty.advance:
        return 'Advance';
      case GameBrewDifficulty.master:
        return 'Master';
    }
  }

  Color get color {
    switch (this) {
      case GameBrewDifficulty.basic:
        return const Color(0xFF0F766E);
      case GameBrewDifficulty.intermediate:
        return const Color(0xFF0369A1);
      case GameBrewDifficulty.advance:
        return const Color(0xFFC2410C);
      case GameBrewDifficulty.master:
        return const Color(0xFFB45309);
    }
  }
}

/// Pouring trajectory disciplines for Manual Brew Adventure & Direct Technique Drills.
enum ManualPourPattern {
  circularCw,
  reverseCircularCcw,
  zigzag,
  centerOsmotic,
  pulse46,
  spiralSwirl,
}

extension ManualPourPatternX on ManualPourPattern {
  String get label {
    switch (this) {
      case ManualPourPattern.circularCw:
        return 'Circular Pour (Searah Jarum Jam)';
      case ManualPourPattern.reverseCircularCcw:
        return 'Reverse Circular Pour (Berlawanan)';
      case ManualPourPattern.zigzag:
        return 'Zigzag / Cross-Hatch Pour';
      case ManualPourPattern.centerOsmotic:
        return 'Center Osmotic Pour';
      case ManualPourPattern.pulse46:
        return 'Pulse Pour 4:6 Tetsu Kasuya';
      case ManualPourPattern.spiralSwirl:
        return 'Spiral + Gentle Rao Swirl';
    }
  }

  String get shortLabel {
    switch (this) {
      case ManualPourPattern.circularCw:
        return 'Circular Pour';
      case ManualPourPattern.reverseCircularCcw:
        return 'Reverse Circular';
      case ManualPourPattern.zigzag:
        return 'Zigzag Pour';
      case ManualPourPattern.centerOsmotic:
        return 'Center Pour';
      case ManualPourPattern.pulse46:
        return 'Pulse 4:6';
      case ManualPourPattern.spiralSwirl:
        return 'Spiral + Swirl';
    }
  }

  String get guideHint {
    switch (this) {
      case ManualPourPattern.circularCw:
        return 'Gerakkan pancaran air melingkar halus searah jarum jam (↻) dari pusat keluar tanpa menyentuh dinding kertas.';
      case ManualPourPattern.reverseCircularCcw:
        return 'Latih kontrol pergelangan berlawanan jarum jam (↺) secara konsisten untuk pemerataan agitasi.';
      case ManualPourPattern.zigzag:
        return 'Sapukan pancaran air secara bolak-balik zig-zag (↔) merata melintasi hamparan bubuk kopi.';
      case ManualPourPattern.centerOsmotic:
        return 'Pertahankan pancaran laminar tipis tepat di titik pusat (< 20% radius) dengan tinggi ketel rendah.';
      case ManualPourPattern.pulse46:
        return 'Lakukan 5 fase tuang terukur (50→120→180→240→300 ml) sambil memantau skala ml di ketel kaca.';
      case ManualPourPattern.spiralSwirl:
        return 'Tuang spiral stabil lalu tutup dengan Gentle Rao Swirl agar dinding ampas rata 100% Flat Bed.';
    }
  }
}

/// Target patterns evaluated by the Latte Art CFD + WLAC Pattern Grader.
enum LatteArtPattern {
  canvasBase,
  monksHead,
  heart,
  twoStackTulip,
  threeStackTulip,
  wingedBase,
  rosetta,
  wingedFiveTulip,
  slowsetta,
  swan,
}

extension LatteArtPatternX on LatteArtPattern {
  String get label {
    switch (this) {
      case LatteArtPattern.canvasBase:
        return 'Kanvas Emas (High Pour)';
      case LatteArtPattern.monksHead:
        return "Monk's Head";
      case LatteArtPattern.heart:
        return 'Classic Heart';
      case LatteArtPattern.twoStackTulip:
        return '2-Stack Tulip';
      case LatteArtPattern.threeStackTulip:
        return '3-Stack Tulip';
      case LatteArtPattern.wingedBase:
        return 'Winged Base (Wiggle)';
      case LatteArtPattern.rosetta:
        return 'Classic Rosetta';
      case LatteArtPattern.wingedFiveTulip:
        return 'Winged 5-Stack Tulip';
      case LatteArtPattern.slowsetta:
        return 'Slowsetta';
      case LatteArtPattern.swan:
        return 'The Graceful Swan';
    }
  }

  String get techniqueGuide {
    switch (this) {
      case LatteArtPattern.canvasBase:
        return 'Tahan pitcher TINGGI (> 4 cm) agar susu menyelam bersih di bawah crema hingga 60% cangkir tanpa bercak putih.';
      case LatteArtPattern.monksHead:
        return 'Mulai tinggi (Dive) hingga 55%, lalu turunkan pitcher RENDAH (< 1.2 cm) tepat di tengah untuk bola foam simetris.';
      case LatteArtPattern.heart:
        return 'Bangun bola foam di tengah (Low Pour), lalu naikkan pitcher & sapu lurus ke depan (Pull-Through Cut) membelah puncak.';
      case LatteArtPattern.twoStackTulip:
        return 'Tuang lapisan 1 → hentikan aliran sejenak → dorong lapisan 2 → naikkan pitcher dan potong lurus ke depan.';
      case LatteArtPattern.threeStackTulip:
        return 'Lakukan 3 dorongan terpisah (Push 1, Push 2, Push 3) dengan kontrol sisa microfoam di pitcher transparan lalu Cut.';
      case LatteArtPattern.wingedBase:
        return 'Rendahkan pitcher di tengah dan goyangkan kiri-kanan (Wiggle 2.5 Hz) agar foam melengkung memeluk dinding cangkir.';
      case LatteArtPattern.rosetta:
        return 'Wiggle berirama stabil sambil perlahan mundur ke tepi belakang cangkir, lalu naikkan pitcher dan potong lurus ke depan!';
      case LatteArtPattern.wingedFiveTulip:
        return 'Buka dengan Winged Wiggle Base lebar, lanjutkan 4 dorongan bertumpuk sebelum cangkir mencapai 200 ml lalu Cut.';
      case LatteArtPattern.slowsetta:
        return 'Gunakan wiggle frekuensi lambat (1.4 Hz) dengan ayunan lebar agar helaian daun tebal & berkontras tinggi.';
      case LatteArtPattern.swan:
        return 'Bentuk sayap Rosetta sedikit miring di kanan, tarik garis leher melengkung S ke atas, akhiri Mini Heart di ujung kepala!';
    }
  }

  double get recommendedWiggleHz {
    switch (this) {
      case LatteArtPattern.wingedBase:
      case LatteArtPattern.rosetta:
      case LatteArtPattern.wingedFiveTulip:
      case LatteArtPattern.swan:
        return 2.4;
      case LatteArtPattern.slowsetta:
        return 1.4;
      default:
        return 0.0;
    }
  }
}

/// Unified level or direct technique drill specification for both disciplines.
class GameBrewLevelSpec {
  final String code; // e.g., MB-01..MB-10, DRILL-MB-ZIGZAG, LA-01..LA-10
  final GameBrewDiscipline discipline;
  final int levelNumber;
  final GameBrewDifficulty difficulty;
  final String title;
  final String subtitle;
  final String mentorTip;
  final bool isDirectDrill;
  final int xpRewardBase;
  final int xpThreeStarBonus;

  // Manual Brew specific parameters
  final ManualPourPattern? manualPattern;
  final double doseGrams;
  final double targetWaterMl;
  final double bloomMl;
  final double idealFlowMlS;
  final double waterTempC;
  final double? dropTempC;
  final bool requirePreBrewRitual; // Wet Filter + Rinse + RDT + Divot
  final bool blindScaleMode;
  final bool highFinesMode;

  // Latte Art specific parameters
  final LatteArtPattern? lattePattern;
  final double cupCapacityMl;
  final double espressoBaseMl;

  const GameBrewLevelSpec({
    required this.code,
    required this.discipline,
    required this.levelNumber,
    required this.difficulty,
    required this.title,
    required this.subtitle,
    required this.mentorTip,
    this.isDirectDrill = false,
    this.xpRewardBase = 150,
    this.xpThreeStarBonus = 100,
    this.manualPattern,
    this.doseGrams = 15.0,
    this.targetWaterMl = 225.0,
    this.bloomMl = 45.0,
    this.idealFlowMlS = 4.2,
    this.waterTempC = 92.0,
    this.dropTempC,
    this.requirePreBrewRitual = true,
    this.blindScaleMode = false,
    this.highFinesMode = false,
    this.lattePattern,
    this.cupCapacityMl = 200.0,
    this.espressoBaseMl = 36.0,
  });
}

class ComingSoonGameSpec {
  final String id;
  final String title;
  final String subtitle;
  final String engineTag;
  final Color accentColor;
  final IconData icon;

  const ComingSoonGameSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.engineTag,
    required this.accentColor,
    required this.icon,
  });
}

class LevelProgressRecord {
  final String code;
  final int stars;
  final double bestScorePct;
  final Map<String, double> bestMetrics;
  final int attempts;
  final DateTime updatedAt;

  const LevelProgressRecord({
    required this.code,
    required this.stars,
    required this.bestScorePct,
    this.bestMetrics = const {},
    this.attempts = 1,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'stars': stars,
        'bestScorePct': double.parse(bestScorePct.toStringAsFixed(1)),
        'bestMetrics': bestMetrics,
        'attempts': attempts,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory LevelProgressRecord.fromJson(Map<String, dynamic> json) {
    final rawMetrics = json['bestMetrics'];
    final parsedMetrics = <String, double>{};
    if (rawMetrics is Map) {
      rawMetrics.forEach((k, v) {
        if (v is num) parsedMetrics[k.toString()] = v.toDouble();
      });
    }
    return LevelProgressRecord(
      code: (json['code'] ?? '').toString(),
      stars: (json['stars'] as num?)?.toInt().clamp(0, 3) ?? 0,
      bestScorePct: (json['bestScorePct'] as num?)?.toDouble() ?? 0.0,
      bestMetrics: parsedMetrics,
      attempts: (json['attempts'] as num?)?.toInt() ?? 1,
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
