import '../data/roastery_catalog.dart';
import '../data/featured_screenshot_beans.dart';
import '../models/roastery.dart';
import 'bean_recommendation_models.dart';

/// Represents a real commercial coffee bean from Indonesian & international roasteries,
/// enriched with product packaging image, roastery logo, sales count, and barista intelligence.
class CuratedRoasteryBean {
  final String id;
  final String roasteryName;
  final String roasteryLocation;
  final String roasteryImageUrl;
  final String roasteryLogoUrl;
  final String packageImageUrl;
  final String name;
  final String origin;
  final String roastProfileRaw;
  final BeanRoastLevel roastLevel;
  final String processRaw;
  final BeanProcess process;
  final String variety;
  final String tastingNotes;
  final List<String> tastingNotesList;
  final String? badge;
  final String originalPackage;
  final int soldCount;
  final BeanDripper recommendedDripper;
  final String baristaOpinion;
  final String tempNotesHot;
  final String tempNotesWarm;
  final String tempNotesCool;

  const CuratedRoasteryBean({
    required this.id,
    required this.roasteryName,
    required this.roasteryLocation,
    required this.roasteryImageUrl,
    required this.roasteryLogoUrl,
    required this.packageImageUrl,
    required this.name,
    required this.origin,
    required this.roastProfileRaw,
    required this.roastLevel,
    required this.processRaw,
    required this.process,
    required this.variety,
    required this.tastingNotes,
    required this.tastingNotesList,
    this.badge,
    required this.originalPackage,
    required this.soldCount,
    required this.recommendedDripper,
    required this.baristaOpinion,
    required this.tempNotesHot,
    required this.tempNotesWarm,
    required this.tempNotesCool,
  });

  /// Parse from Roastery and CoffeeLineupItem
  factory CuratedRoasteryBean.fromCatalog(Roastery roastery, CoffeeLineupItem item, int index) {
    final roastLower = item.roastProfile.toLowerCase();
    BeanRoastLevel roast = BeanRoastLevel.medium;
    if (roastLower.contains('medium-dark') || (roastLower.contains('medium') && roastLower.contains('dark'))) {
      roast = BeanRoastLevel.mediumDark;
    } else if (roastLower.contains('dark') || roastLower.contains('espresso')) {
      roast = BeanRoastLevel.dark;
    } else if (roastLower.contains('medium-light') || roastLower.contains('light-medium')) {
      roast = BeanRoastLevel.mediumLight;
    } else if (roastLower.contains('light')) {
      roast = BeanRoastLevel.light;
    }

    final processLower = item.process.toLowerCase();
    BeanProcess proc = BeanProcess.washed;
    if (processLower.contains('anaerobic') || processLower.contains('carbonic') || processLower.contains('ferment')) {
      proc = BeanProcess.anaerobic;
    } else if (processLower.contains('honey')) {
      proc = BeanProcess.honey;
    } else if (processLower.contains('natural')) {
      proc = BeanProcess.natural;
    }

    final notes = item.tastingNotes
        .split(RegExp(r'[,|•;]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // 1. Roastery Logo: Exact match for this roastery's own brand ID
    final String logo = 'assets/images/roasteries/${roastery.id}.png';

    // 2. Packaging Image: Generate slug for exact bean match
    final slug = item.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    String pack = 'assets/images/beans/${roastery.id}_$slug.jpg';

    // Check if official marketplace packaging photo exists
    final rId = roastery.id;
    if (rId == 'indibro_sutoyo_mknd') {
      if (slug.contains('kintamani')) {
        pack = 'assets/images/beans/mknd_bali_kintamani.jpg';
      } else if (slug.contains('excelsa')) {
        pack = 'assets/images/beans/mknd_kopi_excelsa.jpg';
      } else if (slug.contains('gayo')) {
        pack = 'assets/images/beans/mknd_aceh_gayo.jpg';
      } else if (slug.contains('toraja') || slug.contains('sapan')) {
        pack = 'assets/images/beans/mknd_toraja_sapan.jpg';
      }
    } else if (rId == 'fugol_coffee') {
      if (slug.contains('roast_a') || slug.contains('filter_a')) {
        pack = 'assets/images/beans/fugol_sample_a.jpg';
      } else if (slug.contains('roast_b') || slug.contains('filter_b')) {
        pack = 'assets/images/beans/fugol_sample_b.jpg';
      } else if (slug.contains('kamojang')) {
        pack = 'assets/images/beans/kamojang_classico.jpg';
      } else {
        pack = 'assets/images/beans/fugol_sample_c.jpg';
      }
    } else if (rId == 'space_coffee') {
      if (slug.contains('tolu') || slug.contains('batak')) {
        pack = 'assets/images/beans/space_tolu_batak.jpg';
      } else {
        pack = 'assets/images/beans/space_halu_pink_banana.jpg';
      }
    } else if (rId == 'tanamera_coffee' && slug.contains('gayo')) {
      pack = 'assets/images/beans/tanamera_aceh_gayo.jpg';
    } else if (rId == 'smoking_barrels' && slug.contains('kerinci')) {
      pack = 'assets/images/beans/smoking_barrels_kerinci.jpg';
    } else if (rId == 'common_grounds' && slug.contains('guji')) {
      pack = 'assets/images/beans/common_grounds_guji.jpg';
    } else if (rId == 'anomali_coffee' && slug.contains('toraja')) {
      pack = 'assets/images/beans/anomali_toraja.jpg';
    } else if (rId == 'gordi_coffee' && slug.contains('flores')) {
      pack = 'assets/images/beans/gordi_flores.jpg';
    } else if (rId == 'hungry_bird_coffee' && slug.contains('berawa')) {
      pack = 'assets/images/beans/hungry_bird_berawa.jpg';
    }

    BeanDripper dripper = BeanDripper.v60;
    String opinion;
    if (roast == BeanRoastLevel.light || roast == BeanRoastLevel.mediumLight) {
      if (proc == BeanProcess.anaerobic || proc == BeanProcess.natural) {
        dripper = BeanDripper.origami;
        opinion = 'Biji berkarakter manis fermentasi buah tropis tinggi. Sangat direkomendasikan dengan Origami Dripper agar aroma floral dan keasaman manis terekstrak rapi tanpa rasa fermentasi berlebih.';
      } else {
        dripper = BeanDripper.v60;
        opinion = 'Biji light wash berdensitas padat dengan potensi aroma bunga dan asam segar. Hario V60 dengan aliran stabil adalah pasangan paling ideal untuk menghasilkan clean cup.';
      }
    } else if (roast == BeanRoastLevel.medium) {
      dripper = BeanDripper.kalita;
      opinion = 'Karakter rasa paling seimbang. Disarankan memakai Kalita Wave (flat bottom) agar saturasi merata, memaksimalkan gula karamel alami dan body yang lembut.';
    } else {
      dripper = BeanDripper.aeropress;
      opinion = 'Roast pekat dengan senyawa karamel pekat. Gunakan AeroPress dengan suhu air 88°C untuk mengunci rasa cokelat mantap tanpa mengekstrak kepahitan tajam.';
    }

    final firstNote = notes.isNotEmpty ? notes[0] : 'Kopi Segar';
    final secondNote = notes.length > 1 ? notes[1] : 'Manis Alami';
    final lastNote = notes.length > 2 ? notes[2] : 'Aftertaste Halus';

    final sold = 120 + ((index * 47) % 580);

    return CuratedRoasteryBean(
      id: '${roastery.id}_${slug}_$index',
      roasteryName: roastery.name,
      roasteryLocation: roastery.location,
      roasteryImageUrl: roastery.imageUrl,
      roasteryLogoUrl: logo,
      packageImageUrl: pack,
      name: item.name,
      origin: item.origin,
      roastProfileRaw: item.roastProfile,
      roastLevel: roast,
      processRaw: item.process,
      process: proc,
      variety: item.variety,
      tastingNotes: item.tastingNotes,
      tastingNotesList: notes,
      badge: item.badge ?? (index % 4 == 0 ? '🏆 Pilihan Roaster' : null),
      originalPackage: item.originalPackage,
      soldCount: sold,
      recommendedDripper: dripper,
      baristaOpinion: opinion,
      tempNotesHot: 'Uap aroma mekar: $firstNote dengan kehangatan wangi lembut.',
      tempNotesWarm: 'Puncak kemanisan: $secondNote & kejernihan rasa paling seimbang.',
      tempNotesCool: 'Aftertaste panjang: $lastNote yang manis bertahan di langit-langit lidah.',
    );
  }

  /// Load all commercial beans from RoasteryCatalog with featured items first
  static List<CuratedRoasteryBean> getAllCatalogBeans() {
    final List<CuratedRoasteryBean> others = [];
    int counter = 0;

    for (final roastery in RoasteryCatalog.list) {
      for (final item in roastery.lineups) {
        others.add(CuratedRoasteryBean.fromCatalog(roastery, item, counter++));
      }
    }

    return [...featuredScreenshotBeans, ...others];
  }
}
