import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../domain/game_brew_studio_models.dart';

/// Official Coffee Labs Game Brew Studio 3D v2.0 Catalog:
/// - 10 Progressive Manual Brew 3D Adventure Levels (Dasar -> Master WBrC)
/// - 6 Direct Manual Brew Technique Drills (Circular, Reverse Circular, Zigzag, Center, Pulse 4:6, Ritual Lab)
/// - 10 Progressive Latte Art 3D Adventure Levels (Dasar -> Master WLAC)
/// - 7 Direct Latte Art Pattern Drills
/// - 3 Coming Soon Coffee Simulation Games
class GameBrewCurriculumCatalog {
  static const List<GameBrewLevelSpec> manualBrewAdventure = [
    GameBrewLevelSpec(
      code: 'MB-01',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 1,
      difficulty: GameBrewDifficulty.basic,
      title: 'Ritual Kertas & Air Bilasan',
      subtitle: 'Basahi ≥ 95% kertas filter, panaskan server, & buang air bilasan.',
      mentorTip:
          'Miringkan ketel kaca transparan memutar untuk membilas rasa kertas, lalu buang air bilasan dari server sebelum menuang bubuk kopi!',
      manualPattern: ManualPourPattern.circularCw,
      doseGrams: 15.0,
      targetWaterMl: 180.0,
      bloomMl: 45.0,
      idealFlowMlS: 4.0,
      waterTempC: 92.0,
      requirePreBrewRitual: true,
    ),
    GameBrewLevelSpec(
      code: 'MB-02',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 2,
      difficulty: GameBrewDifficulty.basic,
      title: 'Seni RDT & Center Divot',
      subtitle: 'Semprot 1–2× RDT, leveling, & buat lubang tengah (divot) 4–9 mm.',
      mentorTip:
          'Semprotan RDT 1–2 kali memangkas listrik statis fines hingga 22%, dan lubang tengah mempercepat pembasahan merata saat blooming.',
      manualPattern: ManualPourPattern.circularCw,
      doseGrams: 15.0,
      targetWaterMl: 210.0,
      bloomMl: 45.0,
      idealFlowMlS: 4.0,
      waterTempC: 92.0,
      requirePreBrewRitual: true,
    ),
    GameBrewLevelSpec(
      code: 'MB-03',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 3,
      difficulty: GameBrewDifficulty.basic,
      title: 'Napas Pertama: 100% Wet Blooming',
      subtitle: 'Jaga laju 4.0 ml/s hingga 100% bubuk basah tanpa dry spots.',
      mentorTip:
          'Aktifkan Dry-Spot Heatmap bila perlu dan gerakkan pancaran air perlahan memutar sampai seluruh titik kering terbasahi.',
      manualPattern: ManualPourPattern.circularCw,
      doseGrams: 15.0,
      targetWaterMl: 225.0,
      bloomMl: 45.0,
      idealFlowMlS: 4.0,
      waterTempC: 93.0,
      requirePreBrewRitual: true,
    ),
    GameBrewLevelSpec(
      code: 'MB-04',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 4,
      difficulty: GameBrewDifficulty.basic,
      title: 'Aliran Laminar (Re < 2300)',
      subtitle: 'Jaga tinggi ketel rendah agar pancaran kaca tidak pecah & nol bypass.',
      mentorTip:
          'Jika tinggi tuang melebihi 11 cm, hukum Rayleigh-Plateau memecah aliran menjadi tetesan turbulen yang menyumbat kertas filter!',
      manualPattern: ManualPourPattern.centerOsmotic,
      doseGrams: 15.0,
      targetWaterMl: 225.0,
      bloomMl: 45.0,
      idealFlowMlS: 3.8,
      waterTempC: 92.0,
      requirePreBrewRitual: true,
    ),
    GameBrewLevelSpec(
      code: 'MB-05',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 5,
      difficulty: GameBrewDifficulty.intermediate,
      title: 'Tarian Spiral & Gentle Rao Swirl',
      subtitle: 'Tuang spiral keluar-masuk lalu Rao Swirl hingga Flat Bed ≥ 90%.',
      mentorTip:
          'Lakukan goyangan melingkar lembut di akhir tuangan agar difusi Laplacian meratakan seluruh ampas di dinding cone V60.',
      manualPattern: ManualPourPattern.spiralSwirl,
      doseGrams: 15.0,
      targetWaterMl: 240.0,
      bloomMl: 45.0,
      idealFlowMlS: 4.5,
      waterTempC: 93.0,
      requirePreBrewRitual: true,
    ),
    GameBrewLevelSpec(
      code: 'MB-06',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 6,
      difficulty: GameBrewDifficulty.intermediate,
      title: 'Matematika 4:6 Tetsu Kasuya',
      subtitle: '5× pulse pour presisi (50→120→180→240→300 ml) fokus sweetness.',
      mentorTip:
          'Pantau garis skala ml pada ketel kaca transparan agar tiap pulse berhenti tepat tanpa meleset lebih dari 3 ml.',
      manualPattern: ManualPourPattern.pulse46,
      doseGrams: 20.0,
      targetWaterMl: 300.0,
      bloomMl: 50.0,
      idealFlowMlS: 4.6,
      waterTempC: 92.0,
      requirePreBrewRitual: true,
    ),
    GameBrewLevelSpec(
      code: 'MB-07',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 7,
      difficulty: GameBrewDifficulty.intermediate,
      title: 'Flash-Chill Japanese Iced V60',
      subtitle: 'Imbangi 40% es batu di server dengan tuangan lambat terkontrol.',
      mentorTip:
          'Gunakan laju alir rendah (~3.4 ml/s) dan pola zigzag/spiral lembut agar ekstraksi optimal sebelum menyentuh es batu.',
      manualPattern: ManualPourPattern.zigzag,
      doseGrams: 18.0,
      targetWaterMl: 180.0,
      bloomMl: 40.0,
      idealFlowMlS: 3.4,
      waterTempC: 93.0,
      requirePreBrewRitual: true,
    ),
    GameBrewLevelSpec(
      code: 'MB-08',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 8,
      difficulty: GameBrewDifficulty.advance,
      title: 'Dual-Temp Thermal Drop (93°→70°C)',
      subtitle: 'Turunkan suhu di tuangan akhir ala Sherry Hsu WBrC pangkas pahit.',
      mentorTip:
          'Awali ekstraksi manis di 93°C lalu selesaikan dengan suhu lebih rendah untuk menghindari astringency di fase akhir.',
      manualPattern: ManualPourPattern.reverseCircularCcw,
      doseGrams: 16.0,
      targetWaterMl: 240.0,
      bloomMl: 48.0,
      idealFlowMlS: 4.2,
      waterTempC: 93.0,
      dropTempC: 70.0,
      requirePreBrewRitual: true,
    ),
    GameBrewLevelSpec(
      code: 'MB-09',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 9,
      difficulty: GameBrewDifficulty.advance,
      title: 'Penyelamatan Ethiopian Fines',
      subtitle: 'Tinggi ketel ultra-rendah & agitasi minimal agar Darcy tak mampet.',
      mentorTip:
          'Biji Ethiopia padat menghasilkan banyak fines. RDT tepat + ketinggian ketel rendah adalah kunci mencegah clogging!',
      manualPattern: ManualPourPattern.centerOsmotic,
      doseGrams: 15.0,
      targetWaterMl: 240.0,
      bloomMl: 45.0,
      idealFlowMlS: 3.5,
      waterTempC: 93.0,
      highFinesMode: true,
      requirePreBrewRitual: true,
    ),
    GameBrewLevelSpec(
      code: 'MB-10',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 10,
      difficulty: GameBrewDifficulty.master,
      title: 'Panggung World Brewers Cup (Blind)',
      subtitle: 'Seduh sempurna tanpa angka timbangan — murni skala ketel kaca!',
      mentorTip:
          'Di panggung WBrC ini angka timbangan disembunyikan. Baca langsung ketinggian air di dinding kaca ketel dan jaga EY% 19.5–21%!',
      manualPattern: ManualPourPattern.spiralSwirl,
      doseGrams: 15.0,
      targetWaterMl: 240.0,
      bloomMl: 45.0,
      idealFlowMlS: 4.2,
      waterTempC: 93.0,
      blindScaleMode: true,
      requirePreBrewRitual: true,
      xpRewardBase: 300,
      xpThreeStarBonus: 200,
    ),
  ];

  /// Direct Technique Practice Drills (accessible anytime without unlocking Adventure!)
  static const List<GameBrewLevelSpec> manualBrewDrills = [
    GameBrewLevelSpec(
      code: 'DRILL-MB-CIRCULAR',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 1,
      difficulty: GameBrewDifficulty.basic,
      title: 'Latihan Circular Pour (↻)',
      subtitle: 'Langsung latih lintasan melingkar searah jarum jam yang halus.',
      mentorTip:
          'Ikuti lintasan lingkaran searah jarum jam pada panduan V60 sambil menjaga debit stabil 4.0 ml/s.',
      isDirectDrill: true,
      manualPattern: ManualPourPattern.circularCw,
      doseGrams: 15.0,
      targetWaterMl: 180.0,
      bloomMl: 45.0,
      idealFlowMlS: 4.0,
      requirePreBrewRitual: false,
    ),
    GameBrewLevelSpec(
      code: 'DRILL-MB-REV-CIRCULAR',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 2,
      difficulty: GameBrewDifficulty.intermediate,
      title: 'Latihan Reverse Circular Pour (↺)',
      subtitle: 'Latih gerakan melingkar berlawanan jarum jam anti-channeling.',
      mentorTip:
          'Membalik arah putaran melatih fleksibilitas pergelangan dan menyeimbangkan turbulensi dinding cone.',
      isDirectDrill: true,
      manualPattern: ManualPourPattern.reverseCircularCcw,
      doseGrams: 15.0,
      targetWaterMl: 180.0,
      bloomMl: 45.0,
      idealFlowMlS: 4.0,
      requirePreBrewRitual: false,
    ),
    GameBrewLevelSpec(
      code: 'DRILL-MB-ZIGZAG',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 3,
      difficulty: GameBrewDifficulty.intermediate,
      title: 'Latihan Zigzag Pour (↔)',
      subtitle: 'Sapuan zig-zag kiri-kanan merata untuk ekstraksi berkarakter.',
      mentorTip:
          'Sapukan pancaran air secara zig-zag menyilang di tengah bed tanpa menyentuh tepi kertas filter!',
      isDirectDrill: true,
      manualPattern: ManualPourPattern.zigzag,
      doseGrams: 15.0,
      targetWaterMl: 190.0,
      bloomMl: 45.0,
      idealFlowMlS: 4.2,
      requirePreBrewRitual: false,
    ),
    GameBrewLevelSpec(
      code: 'DRILL-MB-CENTER',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 4,
      difficulty: GameBrewDifficulty.basic,
      title: 'Latihan Center Osmotic Pour',
      subtitle: 'Fokus aliran laminar kaca tepat di pusat tanpa memecah stream.',
      mentorTip:
          'Jaga ketinggian ketel tetap rendah (< 9 cm) dan arahkan lurus ke pusat kawah untuk sweetness maksimal.',
      isDirectDrill: true,
      manualPattern: ManualPourPattern.centerOsmotic,
      doseGrams: 15.0,
      targetWaterMl: 180.0,
      bloomMl: 45.0,
      idealFlowMlS: 3.6,
      requirePreBrewRitual: false,
    ),
    GameBrewLevelSpec(
      code: 'DRILL-MB-PULSE46',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 5,
      difficulty: GameBrewDifficulty.intermediate,
      title: 'Latihan Pulse Pour 4:6',
      subtitle: 'Kontrol buka-tutup aliran tepat waktu di tiap target ml.',
      mentorTip:
          'Tegakkan ketel tepat sebelum target ml tercapai agar sisa air di leher angsa tidak melampaui target.',
      isDirectDrill: true,
      manualPattern: ManualPourPattern.pulse46,
      doseGrams: 20.0,
      targetWaterMl: 250.0,
      bloomMl: 50.0,
      idealFlowMlS: 4.5,
      requirePreBrewRitual: false,
    ),
    GameBrewLevelSpec(
      code: 'DRILL-MB-RITUAL',
      discipline: GameBrewDiscipline.manualBrew3d,
      levelNumber: 6,
      difficulty: GameBrewDifficulty.basic,
      title: 'Lab Pra-Seduh: Filter, RDT & Divot',
      subtitle: 'Latih seluruh 5 fase ritual barista lengkap dengan Rao Swirl.',
      mentorTip:
          'Cocok untuk pemanasan lengkap mulai dari bilas kertas filter, RDT 1–2×, finger divot, hingga Rao Swirl.',
      isDirectDrill: true,
      manualPattern: ManualPourPattern.spiralSwirl,
      doseGrams: 15.0,
      targetWaterMl: 200.0,
      bloomMl: 45.0,
      idealFlowMlS: 4.2,
      requirePreBrewRitual: true,
    ),
  ];

  static const List<GameBrewLevelSpec> latteArtAdventure = [
    GameBrewLevelSpec(
      code: 'LA-01',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 1,
      difficulty: GameBrewDifficulty.basic,
      title: 'Kanvas Emas (High Pour & Crema)',
      subtitle: 'Tahan pitcher tinggi (> 4 cm) isi 60% cangkir tanpa bercak putih.',
      mentorTip:
          'Hukum Dive vs Float: tuang tinggi membuat jet susu menyelam mulus di bawah crema, membangun kanvas emas rata!',
      lattePattern: LatteArtPattern.canvasBase,
    ),
    GameBrewLevelSpec(
      code: 'LA-02',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 2,
      difficulty: GameBrewDifficulty.basic,
      title: "Monk's Head (Turunkan Pitcher)",
      subtitle: 'Transisi High Pour → Low Pour (< 1.2 cm) untuk bola foam simetris.',
      mentorTip:
          'Begitu volume mencapai 55%, turunkan slider tinggi pitcher ke zona Float dan tahan stabil di pusat cangkir.',
      lattePattern: LatteArtPattern.monksHead,
    ),
    GameBrewLevelSpec(
      code: 'LA-03',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 3,
      difficulty: GameBrewDifficulty.basic,
      title: 'Classic Heart (Pull-Through Cut)',
      subtitle: 'Kembangkan bola foam lalu naikkan pitcher & sapu lurus ke depan.',
      mentorTip:
          'Saat bola foam sudah besar, angkat pitcher ke atas (Dive/Cut) lalu tarik lurus membelah puncak membentuk ujung Hati!',
      lattePattern: LatteArtPattern.heart,
    ),
    GameBrewLevelSpec(
      code: 'LA-04',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 4,
      difficulty: GameBrewDifficulty.intermediate,
      title: 'Stacked 2-Layer Tulip',
      subtitle: 'Teknik Stop-Move-Push 2 lapisan lalu akhiri Pull-Through Cut.',
      mentorTip:
          'Tuang layer pertama di tengah, jeda singkat, dorong layer kedua sedikit di belakangnya, lalu potong lurus.',
      lattePattern: LatteArtPattern.twoStackTulip,
    ),
    GameBrewLevelSpec(
      code: 'LA-05',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 5,
      difficulty: GameBrewDifficulty.intermediate,
      title: 'Classic 3-Stack Tulip',
      subtitle: 'Presisi ritme 3 dorongan terpisah dengan kontrol microfoam pitcher.',
      mentorTip:
          'Perhatikan lapisan microfoam putih di pitcher kaca transparan agar tak kehabisan foam di dorongan ketiga!',
      lattePattern: LatteArtPattern.threeStackTulip,
    ),
    GameBrewLevelSpec(
      code: 'LA-06',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 6,
      difficulty: GameBrewDifficulty.intermediate,
      title: 'Winged Base (Gyroscope Wiggle)',
      subtitle: 'Goyangkan kiri-kanan 2.5 Hz agar lapisan dasar membungkus cangkir.',
      mentorTip:
          'Fluida Navier-Stokes otomatis melengkung mengikuti dinding bundar cangkir saat Anda melakukan wiggle kiri-kanan.',
      lattePattern: LatteArtPattern.wingedBase,
    ),
    GameBrewLevelSpec(
      code: 'LA-07',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 7,
      difficulty: GameBrewDifficulty.advance,
      title: 'Classic Rosetta (Ripple & Pull)',
      subtitle: 'Wiggle berirama sambil perlahan mundur lalu potong lurus ke depan.',
      mentorTip:
          'Ikuti ketukan metronom 2.4 Hz sambil mundur ke tepi belakang cangkir, lalu angkat tinggi untuk menarik batang Rosetta!',
      lattePattern: LatteArtPattern.rosetta,
    ),
    GameBrewLevelSpec(
      code: 'LA-08',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 8,
      difficulty: GameBrewDifficulty.advance,
      title: 'Winged 5-Stack Tulip',
      subtitle: 'Gabungkan Winged Base lebar dengan 4 tumpukan push presisi tinggi.',
      mentorTip:
          'Mulai dari posisi agak ke depan cangkir agar ruang 5 lapisan tulip cukup sebelum cangkir penuh 200 ml.',
      lattePattern: LatteArtPattern.wingedFiveTulip,
    ),
    GameBrewLevelSpec(
      code: 'LA-09',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 9,
      difficulty: GameBrewDifficulty.advance,
      title: 'Slowsetta (Thick High-Contrast)',
      subtitle: 'Wiggle lambat (1.4 Hz) amplitudo lebar untuk daun tebal berkontras.',
      mentorTip:
          'Jangan terburu-buru! Ayunan lebar dan lambat menghasilkan helaian daun putih kontras tinggi seperti cat minyak.',
      lattePattern: LatteArtPattern.slowsetta,
    ),
    GameBrewLevelSpec(
      code: 'LA-10',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 10,
      difficulty: GameBrewDifficulty.master,
      title: 'The Graceful Swan (WLAC Master)',
      subtitle: 'Sayap Rosetta miring, tarik lengkung leher S, & tutup Mini Heart.',
      mentorTip:
          'Pola pamungkas WLAC: gambar sayap Rosetta di sisi kanan, tarik garis tipis leher melengkung ke atas, lalu bentuk kepala Hati kecil!',
      lattePattern: LatteArtPattern.swan,
      xpRewardBase: 300,
      xpThreeStarBonus: 200,
    ),
  ];

  static const List<GameBrewLevelSpec> latteArtDrills = [
    GameBrewLevelSpec(
      code: 'DRILL-LA-HEART',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 1,
      difficulty: GameBrewDifficulty.basic,
      title: 'Latihan Classic Heart',
      subtitle: 'Langsung latih transisi Dive → Float → Pull-Through Cut Hati.',
      mentorTip: 'Fokus pada simetri kiri-kanan dan tarikan Cut lurus di akhir.',
      isDirectDrill: true,
      lattePattern: LatteArtPattern.heart,
    ),
    GameBrewLevelSpec(
      code: 'DRILL-LA-TULIP',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 2,
      difficulty: GameBrewDifficulty.intermediate,
      title: 'Latihan 3-Stack Tulip',
      subtitle: 'Latih ritme Push-Stop-Push 3 lapis dengan kontras crema tajam.',
      mentorTip: 'Dorong lembut ke depan tiap lapisan agar tulip membungkus rapi.',
      isDirectDrill: true,
      lattePattern: LatteArtPattern.threeStackTulip,
    ),
    GameBrewLevelSpec(
      code: 'DRILL-LA-ROSETTA',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 3,
      difficulty: GameBrewDifficulty.advance,
      title: 'Latihan Classic Rosetta',
      subtitle: 'Latih osilasi Wiggle kiri-kanan & mundur berirama di CFD 60 FPS.',
      mentorTip: 'Jaga ritme wiggle konstan lalu tarik garis tipis di pusat.',
      isDirectDrill: true,
      lattePattern: LatteArtPattern.rosetta,
    ),
    GameBrewLevelSpec(
      code: 'DRILL-LA-SLOWSETTA',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 4,
      difficulty: GameBrewDifficulty.advance,
      title: 'Latihan Slowsetta',
      subtitle: 'Ayunan lambat lebar (1.4 Hz) untuk daun microfoam tebal.',
      mentorTip: 'Fokus kontras putih-cokelat dengan gerak lebar perlahan.',
      isDirectDrill: true,
      lattePattern: LatteArtPattern.slowsetta,
    ),
    GameBrewLevelSpec(
      code: 'DRILL-LA-SWAN',
      discipline: GameBrewDiscipline.latteArt3d,
      levelNumber: 5,
      difficulty: GameBrewDifficulty.master,
      title: 'Latihan Graceful Swan',
      subtitle: 'Uji langsung pola Angsa WLAC (Sayap + Leher S + Kepala Heart).',
      mentorTip: 'Gunakan Target Ghost Guide untuk membantu jalur leher angsa.',
      isDirectDrill: true,
      lattePattern: LatteArtPattern.swan,
    ),
  ];

  static const List<ComingSoonGameSpec> comingSoonGames = [
    ComingSoonGameSpec(
      id: 'espresso_dial_in_3d',
      title: 'Espresso Dial-In & 9-Bar 3D',
      subtitle:
          'WDT, tamping dinamometrik, kurva tekanan 9-bar, & deteksi channeling bottomless portafilter.',
      engineTag: 'PRESSURE CFD • COMING SOON',
      accentColor: Color(0xFFB45309),
      icon: CupertinoIcons.gauge,
    ),
    ComingSoonGameSpec(
      id: 'roasting_profile_3d',
      title: 'Roasting Profile Master 3D',
      subtitle:
          'Kontrol gas, airflow, Rate of Rise (RoR), Maillard & First Crack di drum roaster 3D.',
      engineTag: 'THERMAL SIM • COMING SOON',
      accentColor: Color(0xFFC2410C),
      icon: Icons.local_fire_department_rounded,
    ),
    ComingSoonGameSpec(
      id: 'cupping_triangulation_arena',
      title: 'Q-Grader Triangulation Arena',
      subtitle:
          'Tantangan cupping buta 3 mangkuk, kalibrasi defect, & duel skor sensori SCA.',
      engineTag: 'SENSORY LAB • COMING SOON',
      accentColor: Color(0xFF0F766E),
      icon: CupertinoIcons.compass,
    ),
  ];

  static List<GameBrewLevelSpec> adventureFor(GameBrewDiscipline discipline) {
    return discipline == GameBrewDiscipline.manualBrew3d
        ? manualBrewAdventure
        : latteArtAdventure;
  }

  static List<GameBrewLevelSpec> drillsFor(GameBrewDiscipline discipline) {
    return discipline == GameBrewDiscipline.manualBrew3d
        ? manualBrewDrills
        : latteArtDrills;
  }
}
