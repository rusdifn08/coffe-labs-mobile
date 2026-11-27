import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../data/barista_toolkit_api_service.dart';
import '../../data/barista_toolkit_seed_data.dart';
import '../../domain/barista_toolkit_models.dart';
import '../ebook_reader/ebook_library_screen.dart';
import 'lms_program_syllabus_screen.dart';

/// Metadata kartu program/track kurikulum di halaman utama Akademi Barista LMS.
class LmsProgramTrack {
  final String id;
  final String title;
  final String categoryTag;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
  final bool isComingSoon;
  final String levelRange;
  final String modulesMeta;
  final List<String> featurePills;
  final List<String> previewTopics;

  const LmsProgramTrack({
    required this.id,
    required this.title,
    required this.categoryTag,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
    required this.isComingSoon,
    required this.levelRange,
    required this.modulesMeta,
    required this.featurePills,
    required this.previewTopics,
  });

  static const List<LmsProgramTrack> catalog = [
    LmsProgramTrack(
      id: 'manual_brew_science',
      title: 'Sains & Teknik Manual Brew',
      categoryTag: 'BREWING & EXTRACTION',
      description:
          'Fisika ekstraksi TDS & EY%, kimia air seduh (GH/KH), termodinamika degassing CO₂, hingga penguasaan V60, Switch, dan strategi kompetisi WBrC.',
      icon: Icons.science_rounded,
      accentColor: AppTheme.primaryBrown,
      gradientColors: [Color(0xFF3E2723), Color(0xFF6D4C41)],
      isComingSoon: false,
      levelRange: 'Novice → Master',
      modulesMeta: '9 Bab • 30 Sub-Bab',
      featurePills: ['Video Animasi HD', 'Lab Interaktif', 'Kuis & Evaluasi'],
      previewTopics: [
        'Sains Fundamental Ekstraksi, Kimia Air & Termodinamika',
        'Fisika Perkolasi V60, Hukum Darcy & Dinamika Flow Rate',
        'Arsitektur Multi-Pour, Immersion Hybrid & Flash Chill',
        'Strategi Dial-In & Kalibrasi Kompetisi WBrC',
      ],
    ),
    LmsProgramTrack(
      id: 'espresso_milk_science',
      title: 'Espresso Engineering & Milk Science',
      categoryTag: 'ESPRESSO & LATTE ART',
      description:
          'Dinamika tekanan 9-bar vs turbo shot, flow & pressure profiling, presisi puck prep bebas channeling, serta fisika microfoam susu standar kompetisi.',
      icon: Icons.coffee_maker_rounded,
      accentColor: Color(0xFF9A3412),
      gradientColors: [Color(0xFF431407), Color(0xFF9A3412)],
      isComingSoon: true,
      levelRange: 'Artisan → Master',
      modulesMeta: '8 Bab • 26 Sub-Bab',
      featurePills: ['Pressure Lab', 'Puck Physics', 'Microfoam Science'],
      previewTopics: [
        'Hidraulika Mesin Espresso, Pre-Infusion & Flow Profiling',
        'Distribusi Partikel Burr (Flat vs Conical) & Puck Prep WDT',
        'Dial-In Ristretto, Normale, Lungo hingga Modern Turbo Shot',
        'Kimia Protein-Lemak Susu & Termodinamika Steaming Latte Art',
      ],
    ),
    LmsProgramTrack(
      id: 'sensory_cupping_qgrader',
      title: 'Sensory Cupping & Q-Grader Calibration',
      categoryTag: 'SENSORY & QUALITY',
      description:
          'Kalibrasi protokol SCA & CVA, pemetaan asam organik (sitrat, malat, fosfat), identifikasi defect sangrai & green bean, serta penilaian cupping profesional.',
      icon: Icons.donut_large_rounded,
      accentColor: Color(0xFF831843),
      gradientColors: [Color(0xFF4C0519), Color(0xFF9D174D)],
      isComingSoon: true,
      levelRange: 'Novice → Q-Calibrated',
      modulesMeta: '7 Bab • 24 Sub-Bab',
      featurePills: ['SCA & CVA Form', 'Flavor Matrix', 'Triangulation Drill'],
      previewTopics: [
        'Fisiologi Olfaktori, Retronasal & Kalibrasi Roda Rasa SCA',
        'Identifikasi Asam Organik Buah, Sweetness & Tactile Mouthfeel',
        'Protokol Cupping Blind, Triangulation & Defect Diagnosis',
        'Coffee Value Assessment (CVA) Deskriptif & Afektif Modern',
      ],
    ),
    LmsProgramTrack(
      id: 'roasting_physics_profile',
      title: 'Coffee Roasting Physics & Profile Design',
      categoryTag: 'ROASTING & THERMODYNAMICS',
      description:
          'Perpindahan panas konduksi-konveksi-radiasi, reaksi Maillard & karamelisasi, kontrol kurva RoR (Rate of Rise), DTR, serta mitigasi roast defect.',
      icon: Icons.local_fire_department_rounded,
      accentColor: Color(0xFFB45309),
      gradientColors: [Color(0xFF451A03), Color(0xFFB45309)],
      isComingSoon: true,
      levelRange: 'Artisan → Master Roaster',
      modulesMeta: '8 Bab • 28 Sub-Bab',
      featurePills: ['Kurva RoR Lab', 'Maillard & DTR', 'Defect Audit'],
      previewTopics: [
        'Termodinamika Drum, Fluid Bed & Energi Panas Penyangraian',
        'Fase Drying, Reaksi Maillard, First Crack & Development Ratio',
        'Membaca Kurva Bean Temp vs RoR (Flick, Crash & Baking)',
        'Desain Profil Filter Light Roast vs Espresso Omni & Blending',
      ],
    ),
    LmsProgramTrack(
      id: 'post_harvest_cafe_business',
      title: 'Green Coffee Processing & Cafe Business',
      categoryTag: 'ORIGIN & CAFE MANAGEMENT',
      description:
          'Biokimia fermentasi pascapanen (Washed, Natural, Anaerobic, Koji), analisis kadar air & densitas green bean, HPP menu, hingga workflow bar kafe modern.',
      icon: Icons.eco_rounded,
      accentColor: Color(0xFF0F766E),
      gradientColors: [Color(0xFF042F2E), Color(0xFF0F766E)],
      isComingSoon: true,
      levelRange: 'Entrepreneur → Architect',
      modulesMeta: '7 Bab • 22 Sub-Bab',
      featurePills: ['Post-Harvest Bio', 'Kalkulasi HPP', 'Bar Workflow'],
      previewTopics: [
        'Anatomi Ceri Kopi, Varietas Unggul & Mikrobiologi Fermentasi',
        'Grading Green Bean, Moisture Meter, Water Activity & Storage',
        'Rekayasa Menu, Struktur HPP Minuman & Profitabilitas Kedai',
        'Desain Ergonomi Coffee Bar, SOP QC Harian & Skala Roastery',
      ],
    ),
  ];
}

/// Halaman katalog utama Akademi Barista LMS: menampilkan 5 kartu program kopi
/// (1 program aktif "Sains & Teknik Manual Brew" + 4 program profesional "Coming Soon")
/// sebelum masuk ke halaman silabus bab/sub-bab.
class BaristaLmsCoursesScreen extends ConsumerStatefulWidget {
  const BaristaLmsCoursesScreen({super.key});

  @override
  ConsumerState<BaristaLmsCoursesScreen> createState() =>
      _BaristaLmsCoursesScreenState();
}

class _BaristaLmsCoursesScreenState
    extends ConsumerState<BaristaLmsCoursesScreen> {
  late List<LmsCourseModel> _manualBrewCourses;

  @override
  void initState() {
    super.initState();
    _manualBrewCourses = BaristaToolkitFallbackSeed.offlineCourses();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final api = ref.read(baristaToolkitApiProvider);
    final offlineRaw = await BaristaToolkitFallbackSeed.loadOfflineCoursesAsync();
    var courses = await api.reconcileCoursesAccess(offlineRaw);
    try {
      final remote = await api.fetchLmsCourses();
      if (remote.isNotEmpty) {
        courses = remote;
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _manualBrewCourses = courses;
    });
  }

  void _openManualBrewSyllabus() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => LmsProgramSyllabusScreen(
              programTitle: 'Sains & Teknik Manual Brew',
              initialCourses: _manualBrewCourses,
            ),
          ),
        )
        .then((_) => _loadProgress());
  }

  void _showComingSoonPreview(LmsProgramTrack track) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: track.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(track.icon, color: AppTheme.accentGold, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD97706).withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Text(
                              'COMING SOON',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            track.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  track.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF5D4D44),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderWarm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pratinjau Modul yang Sedang Disusun',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...track.previewTopics.asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: track.accentColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${e.key + 1}',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: track.accentColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textDark,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Mengerti',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allLessons = _manualBrewCourses.expand((c) => c.lessons).toList();
    final completedLessons = allLessons.where((l) => l.isCompleted).length;
    final totalXp = allLessons
        .where((l) => l.isCompleted)
        .fold<int>(0, (sum, l) => sum + l.xpReward);
    final totalPrograms = LmsProgramTrack.catalog.length;
    final activePrograms =
        LmsProgramTrack.catalog.where((p) => !p.isComingSoon).length;
    final upcomingPrograms = totalPrograms - activePrograms;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Akademi Barista LMS',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
            ),
            Text(
              '$totalPrograms Program Kurikulum Kopi Specialty',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pustaka E-Book Terkait',
            icon: const Icon(
              Icons.auto_stories_rounded,
              color: AppTheme.primaryBrown,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EbookLibraryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _buildAcademyHeroBanner(
              activePrograms: activePrograms,
              upcomingPrograms: upcomingPrograms,
              completedLessons: completedLessons,
              totalLessons: allLessons.length,
              totalXp: totalXp,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome_mosaic_rounded,
                  size: 17,
                  color: AppTheme.primaryBrown,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Pilih Program Materi Kopi',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...LmsProgramTrack.catalog.map(
              (track) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildProgramCard(
                  track: track,
                  totalChapters: _manualBrewCourses.length,
                  totalLessons: allLessons.length,
                  completedLessons: completedLessons,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademyHeroBanner({
    required int activePrograms,
    required int upcomingPrograms,
    required int completedLessons,
    required int totalLessons,
    required int totalXp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B1810), Color(0xFF4E342E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1810).withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppTheme.accentGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coffee Labs Specialty Academy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$activePrograms Program Aktif • $upcomingPrograms Program Segera Hadir',
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _heroStatPill(
                Icons.check_circle_outline_rounded,
                'Progres: $completedLessons/$totalLessons Sub-Bab',
              ),
              _heroStatPill(
                Icons.bolt_rounded,
                '$totalXp XP Terkumpul',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStatPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.accentGold),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard({
    required LmsProgramTrack track,
    required int totalChapters,
    required int totalLessons,
    required int completedLessons,
  }) {
    final isComingSoon = track.isComingSoon;
    final progressValue = (!isComingSoon && totalLessons > 0)
        ? (completedLessons / totalLessons).clamp(0.0, 1.0)
        : 0.0;
    final modulesLabel = isComingSoon
        ? track.modulesMeta
        : '$totalChapters Bab • $totalLessons Sub-Bab';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: Key('lms_program_card_${track.id}'),
        borderRadius: BorderRadius.circular(20),
        onTap: isComingSoon
            ? () => _showComingSoonPreview(track)
            : _openManualBrewSyllabus,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isComingSoon
                  ? AppTheme.borderWarm
                  : AppTheme.primaryBrown.withValues(alpha: 0.38),
              width: isComingSoon ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isComingSoon ? 0.025 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Strip berwarna khas tiap track kopi
              Container(
                padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isComingSoon
                        ? [
                            track.gradientColors.first.withValues(alpha: 0.9),
                            track.gradientColors.last.withValues(alpha: 0.85),
                          ]
                        : track.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        track.icon,
                        color: AppTheme.accentGold,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  track.categoryTag,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.78),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isComingSoon
                                      ? const Color(0xFFFFF3CD)
                                      : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isComingSoon ? 'COMING SOON' : 'TERSEDIA',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                    color: isComingSoon
                                        ? const Color(0xFF92400E)
                                        : const Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            track.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Body Deskripsi, Pills, Progress / CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.description,
                      style: const TextStyle(
                        fontSize: 12.2,
                        color: Color(0xFF5D4D44),
                        height: 1.42,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _metaBadge(
                          Icons.menu_book_rounded,
                          modulesLabel,
                          track.accentColor,
                        ),
                        _metaBadge(
                          Icons.trending_up_rounded,
                          track.levelRange,
                          AppTheme.textMuted,
                        ),
                        ...track.featurePills.map(
                          (pill) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF6F0),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.borderWarm),
                            ),
                            child: Text(
                              pill,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isComingSoon) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFEFE6DC),
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(progressValue * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isComingSoon
                                ? 'Ketuk untuk lihat pratinjau modul'
                                : 'Masuk ke silabus lengkap & lab interaktif',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isComingSoon
                                  ? AppTheme.textMuted
                                  : AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isComingSoon
                                ? const Color(0xFFF5EFE6)
                                : AppTheme.primaryBrown,
                            borderRadius: BorderRadius.circular(11),
                            border: isComingSoon
                                ? Border.all(color: AppTheme.borderWarm)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isComingSoon ? 'Pratinjau' : 'Buka Silabus',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: isComingSoon
                                      ? AppTheme.primaryBrown
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isComingSoon
                                    ? Icons.schedule_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 14,
                                color: isComingSoon
                                    ? AppTheme.primaryBrown
                                    : Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
