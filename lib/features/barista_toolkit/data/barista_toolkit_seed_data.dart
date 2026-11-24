import 'dart:convert';

import '../../../core/assets/cloud_dataset_service.dart';
import '../domain/barista_toolkit_models.dart';

class BaristaToolkitFallbackSeed {
  static List<LmsCourseModel>? _cachedCourses;
  static List<EbookCatalogItem>? _cachedEbooks;
  static List<CoffeeDictionaryEntryModel>? _cachedDict;

  /// Mengembalikan ringkasan 9 Bab Kurikulum Manual Brew secara sinkron untuk render instan,
  /// sementara materi penuh 30 Sub-bab dimuat oleh [loadOfflineCoursesAsync].
  static List<LmsCourseModel> offlineCourses() {
    if (_cachedCourses != null && _cachedCourses!.isNotEmpty) {
      return _cachedCourses!;
    }
    return const [
      LmsCourseModel(
        id: 'c1010001-0000-4000-8000-000000000001',
        slug: 'bab-1-sains-ekstraksi-kimia-air-termodinamika',
        title: 'Bab 1: Sains Fundamental Ekstraksi, Kimia Air & Termodinamika',
        subtitle: 'TDS, Extraction Yield, Control Chart 1950 vs UC Davis 2023, kation Ca²⁺/Mg²⁺/KH, degassing CO₂ & Extract Chilling (Paragon).',
        instructorName: 'Dr. Nadia Aris & Tim Riset Coffee Labs',
        difficulty: 'NOVICE',
        requiredTier: 'Trial',
        isUnlocked: true,
        competencyLevel: 'Dasar – Menengah',
        totalDurationSec: 1400,
        xpRewardOnComplete: 350,
        lessons: [],
      ),
      LmsCourseModel(
        id: 'c1010001-0000-4000-8000-000000000002',
        slug: 'bab-2-fisika-perkolasi-hidrodinamika-ketel',
        title: 'Bab 2: Fisika Perkolasi, Hidrodinamika Ketel & Mekanika Fluida',
        subtitle: 'Hukum Darcy, channeling & bypass, Efek Kacang Brasil Terbalik, aliran ketel & Melodrip.',
        instructorName: 'Dr. Jonathan & Master Kaito',
        difficulty: 'ARTISAN',
        requiredTier: 'Trial',
        isUnlocked: true,
        competencyLevel: 'Menengah',
        totalDurationSec: 1030,
        xpRewardOnComplete: 360,
        lessons: [],
      ),
      LmsCourseModel(
        id: 'c1010001-0000-4000-8000-000000000003',
        slug: 'bab-3-rekayasa-geometri-dripper-filter-grinder',
        title: 'Bab 3: Rekayasa Geometri Dripper, Kertas Filter & Grinder',
        subtitle: 'V60, Origami, Solo, UFO, Orea, April; kertas CAFEC & Sibarist; Dual-Grind 3:1.',
        instructorName: 'Raka Pratama (WBrC Coach)',
        difficulty: 'ARTISAN',
        requiredTier: 'Pro',
        isUnlocked: false,
        competencyLevel: 'Menengah – Lanjut',
        totalDurationSec: 1090,
        xpRewardOnComplete: 400,
        lessons: [],
      ),
      LmsCourseModel(
        id: 'c1010001-0000-4000-8000-000000000004',
        slug: 'bab-4-penguasaan-hario-v60-teknik-pakar-dunia',
        title: 'Bab 4: Penguasaan Hario V60 & Teknik Ikonik Pakar Dunia',
        subtitle: 'James Hoffmann 1-Cup, The Rao Spin, Lance Hedrick 1-2-1/Samo Bloom & Osmotic Flow.',
        instructorName: 'Master Kaito & Tim Edukasi',
        difficulty: 'ARTISAN',
        requiredTier: 'Pro',
        isUnlocked: false,
        competencyLevel: 'Menengah – Lanjut',
        totalDurationSec: 1370,
        xpRewardOnComplete: 420,
        lessons: [],
      ),
      LmsCourseModel(
        id: 'c1010001-0000-4000-8000-000000000005',
        slug: 'bab-5-evolusi-tiga-era-tetsu-kasuya',
        title: 'Bab 5: Evolusi Tiga Era Teknik Tetsu Kasuya (2016–2026)',
        subtitle: '4:6 Method, Hybrid Devil Hario Switch & 10-Pour Super-Coarse V60 NEO.',
        instructorName: 'Raka Pratama (Kyoto Archive)',
        difficulty: 'ALCHEMIST',
        requiredTier: 'Pro',
        isUnlocked: false,
        competencyLevel: 'Lanjut',
        totalDurationSec: 1020,
        xpRewardOnComplete: 450,
        lessons: [],
      ),
      LmsCourseModel(
        id: 'c1010001-0000-4000-8000-000000000006',
        slug: 'bab-6-flat-bottom-dripper-hybrid-immersion',
        title: 'Bab 6: Spesialisasi Flat-Bottom & Hybrid Immersion-Percolation',
        subtitle: 'April System Patrik Rolf, Orea Negotiator, No Difference Recipe & Emi Fukahori Switch.',
        instructorName: 'Master Kaito & Elena Roaster',
        difficulty: 'ALCHEMIST',
        requiredTier: 'Pro',
        isUnlocked: false,
        competencyLevel: 'Lanjut',
        totalDurationSec: 1010,
        xpRewardOnComplete: 460,
        lessons: [],
      ),
      LmsCourseModel(
        id: 'c1010001-0000-4000-8000-000000000007',
        slug: 'bab-7-sains-japanese-iced-coffee-flash-brew',
        title: 'Bab 7: Sains & Teknik Japanese Iced Coffee (Flash Brew)',
        subtitle: 'Rasio 60:40 vs 80:20, Iced V60 Hoffmann, Flash Brew Hedrick & 15s Kasuya.',
        instructorName: 'Dr. Nadia Aris',
        difficulty: 'ARTISAN',
        requiredTier: 'Pro',
        isUnlocked: false,
        competencyLevel: 'Menengah – Lanjut',
        totalDurationSec: 940,
        xpRewardOnComplete: 400,
        lessons: [],
      ),
      LmsCourseModel(
        id: 'c1010001-0000-4000-8000-000000000008',
        slug: 'bab-8-dekonstruksi-resep-juara-dunia-wbrc',
        title: 'Bab 8: Dekonstruksi Resep Juara Dunia WBrC (2018–2026)',
        subtitle: 'Fukahori, Matt Winton, Sherry Hsu, Carlos Medina, Martin Wölfl, George Peng & Nas Jaafar.',
        instructorName: 'Coffee Labs Championship Faculty',
        difficulty: 'WBRC_MASTER',
        requiredTier: 'Business',
        isUnlocked: false,
        competencyLevel: 'Masterclass / Advance',
        totalDurationSec: 1510,
        xpRewardOnComplete: 550,
        lessons: [],
      ),
      LmsCourseModel(
        id: 'c1010001-0000-4000-8000-000000000009',
        slug: 'bab-9-diagnostik-sensorik-cooling-curve-ujian-akhir',
        title: 'Bab 9: Diagnostik Sensorik, Cooling Curve & Lab Ujian Akhir',
        subtitle: 'Sensory Cooling Curve 65°C ke 50°C, Troubleshooting Matrix & Virtual WBrC Sandbox.',
        instructorName: 'Board of Sensory Judges Coffee Labs',
        difficulty: 'WBRC_MASTER',
        requiredTier: 'Business',
        isUnlocked: false,
        competencyLevel: 'Masterclass / Advance',
        totalDurationSec: 1070,
        xpRewardOnComplete: 650,
        lessons: [],
      ),
    ];
  }

  /// Memuat kurikulum lengkap 9 Bab / 30 Sub-Bab beserta pembahasan detail, tabel, rumus & kuis.
  static Future<List<LmsCourseModel>> loadOfflineCoursesAsync() async {
    if (_cachedCourses != null && _cachedCourses!.isNotEmpty) {
      return _cachedCourses!;
    }
    try {
      final raw = await CloudDatasetService.loadDatasetString('lms_manual_brew_seed');
      if (raw == null || raw.isEmpty) return offlineCourses();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final list = decoded['courses'] as List? ?? [];
      final parsed = list
          .map((e) => LmsCourseModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (parsed.isNotEmpty) {
        _cachedCourses = parsed;
        return parsed;
      }
    } catch (_) {}
    return offlineCourses();
  }

  static List<EbookCatalogItem> cachedEbooksSync() => _cachedEbooks ?? const [];

  static Future<List<EbookCatalogItem>> offlineEbooks() async {
    if (_cachedEbooks != null && _cachedEbooks!.isNotEmpty) {
      return _cachedEbooks!;
    }
    try {
      final raw = await CloudDatasetService.loadDatasetString('ebooks_catalog_seed');
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      final parsed = decoded
          .map((e) => EbookCatalogItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      _cachedEbooks = parsed;
      return parsed;
    } catch (_) {
      return const [];
    }
  }

  static Future<List<CoffeeDictionaryEntryModel>> offlineDictionary() async {
    if (_cachedDict != null && _cachedDict!.isNotEmpty) {
      return _cachedDict!;
    }
    try {
      final raw = await CloudDatasetService.loadDatasetString('coffee_dictionary_seed');
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      final parsed = decoded
          .map((e) => CoffeeDictionaryEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      _cachedDict = parsed;
      return parsed;
    } catch (_) {
      return const [];
    }
  }

  static List<GameBrewChapterModel> offlineChapters() {
    return const [
      GameBrewChapterModel(
        chapterNumber: 1,
        slug: 'chapter-1-first-drip-blooming',
        title: 'Tetes Pertama di Kedai Senja',
        storyLocation: 'Kedai Senja Malabar',
        npcMentorName: 'Master Kaito',
        targetRecipeSlug: 'v60-fundamental-bloom',
        physicsConfig: {
          'dose_g': 15,
          'water_ml': 225,
          'bloom_ml': 30,
          'bloom_sec': 35,
          'target_temp_c': 92,
          'target_time_sec': 135,
          'ideal_flow_ml_s': 5.0,
        },
        storyDialogue: [
          {
            'speaker': 'Master Kaito',
            'line': 'Hari pertama di Kedai Senja! Tuang 30ml untuk blooming CO2, lalu lanjut spiral stabil hingga 225ml.',
          },
        ],
        xpReward3Stars: 200,
        isUnlocked: true,
      ),
      GameBrewChapterModel(
        chapterNumber: 2,
        slug: 'chapter-2-pusaran-air-flat-bed',
        title: 'Pusaran Air & Flat Coffee Bed',
        storyLocation: 'Slow Bar Bandung',
        npcMentorName: 'Master Kaito',
        targetRecipeSlug: 'smoking-barrels-v60',
        physicsConfig: {
          'dose_g': 15,
          'water_ml': 225,
          'bloom_ml': 45,
          'bloom_sec': 35,
          'target_temp_c': 89,
          'target_time_sec': 145,
          'ideal_flow_ml_s': 5.5,
        },
        storyDialogue: [
          {
            'speaker': 'Master Kaito',
            'line': 'Kritikus kopi sedang menonton! Pertahankan gerakan spiral tenang untuk Smoking Barrels V60.',
          },
        ],
        xpReward3Stars: 250,
      ),
      GameBrewChapterModel(
        chapterNumber: 3,
        slug: 'chapter-3-teka-teki-kasuya-4-6',
        title: 'Teka-Teki Matematika 4:6 Juara Dunia',
        storyLocation: 'Kyoto Heritage Corner',
        npcMentorName: 'Master Kaito',
        targetRecipeSlug: 'tetsu-kasuya-4-6',
        physicsConfig: {
          'dose_g': 20,
          'water_ml': 300,
          'bloom_ml': 50,
          'bloom_sec': 45,
          'target_temp_c': 90,
          'target_time_sec': 210,
          'ideal_flow_ml_s': 6.0,
        },
        storyDialogue: [
          {
            'speaker': 'Master Kaito',
            'line': 'Atur fase 40% pertama (50ml + 70ml) untuk keseimbangan manis dan cerah metode Tetsu Kasuya 4:6!',
          },
        ],
        xpReward3Stars: 300,
      ),
      GameBrewChapterModel(
        chapterNumber: 4,
        slug: 'chapter-4-rahasia-dua-suhu-air',
        title: 'Rahasia Dua Suhu Air (Thermal Drop)',
        storyLocation: 'Malabar Reserve Lab',
        npcMentorName: 'Master Kaito',
        targetRecipeSlug: 'sherry-hsu-dual-temp',
        physicsConfig: {
          'dose_g': 15,
          'water_ml': 300,
          'bloom_ml': 45,
          'bloom_sec': 35,
          'target_temp_c': 93,
          'drop_temp_c': 70,
          'drop_at_ml': 180,
          'target_time_sec': 165,
          'ideal_flow_ml_s': 5.2,
        },
        storyDialogue: [
          {
            'speaker': 'Master Kaito',
            'line': 'Ekstrak aroma Malabar Wine di 93°C hingga 180ml, lalu tekan "Campur Air 70°C" untuk mengunci manisnya!',
          },
        ],
        xpReward3Stars: 350,
      ),
      GameBrewChapterModel(
        chapterNumber: 5,
        slug: 'chapter-5-final-wbrc-sandwich',
        title: 'Panggung Final World Brewers Cup',
        storyLocation: 'WBrC Main Stage',
        npcMentorName: 'Master Kaito',
        targetRecipeSlug: 'wbrc-sandwich-champion',
        physicsConfig: {
          'dose_g': 16,
          'water_ml': 250,
          'bloom_ml': 50,
          'bloom_sec': 35,
          'target_temp_c': 91,
          'target_time_sec': 155,
          'ideal_flow_ml_s': 5.0,
        },
        storyDialogue: [
          {
            'speaker': 'Master Kaito',
            'line': 'Babak final! Jaga presisi tuangan gooseneck dan raih 20.5% Extraction Yield tanpa channeling!',
          },
        ],
        xpReward3Stars: 500,
      ),
    ];
  }
}
