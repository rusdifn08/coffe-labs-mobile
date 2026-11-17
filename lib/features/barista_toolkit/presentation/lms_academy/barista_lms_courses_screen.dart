import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../data/barista_toolkit_api_service.dart';
import '../../data/barista_toolkit_seed_data.dart';
import '../../domain/barista_toolkit_models.dart';
import '../ebook_reader/ebook_library_screen.dart';
import 'lms_course_player_screen.dart';

class BaristaLmsCoursesScreen extends ConsumerStatefulWidget {
  const BaristaLmsCoursesScreen({super.key});

  @override
  ConsumerState<BaristaLmsCoursesScreen> createState() =>
      _BaristaLmsCoursesScreenState();
}

class _BaristaLmsCoursesScreenState
    extends ConsumerState<BaristaLmsCoursesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<LmsCourseModel> _courses;
  final Set<String> _expandedCourseIds = {
    'c1010001-0000-4000-8000-000000000001',
    'c1010001-0000-4000-8000-000000000002',
  };
  String _selectedDifficulty = 'ALL';

  @override
  void initState() {
    super.initState();
    _courses = BaristaToolkitFallbackSeed.offlineCourses();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Pastikan minimal 30 Sub-bab lengkap langsung tersedia dari seed offline bila API belum merespons
    var courses = await BaristaToolkitFallbackSeed.loadOfflineCoursesAsync();
    try {
      final remote = await ref.read(baristaToolkitApiProvider).fetchLmsCourses();
      if (remote.isNotEmpty) {
        courses = remote;
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _courses = courses;
      if (_expandedCourseIds.length <= 2 && courses.isNotEmpty) {
        _expandedCourseIds.add(courses.first.id);
      }
    });
  }

  List<LmsCourseModel> get _filteredCourses {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _courses.where((c) {
      final okDiff = _selectedDifficulty == 'ALL' ||
          c.difficulty.toUpperCase() == _selectedDifficulty;
      if (!okDiff) return false;
      if (q.isEmpty) return true;
      final hitCourse = c.title.toLowerCase().contains(q) ||
          c.subtitle.toLowerCase().contains(q) ||
          c.focusSummary.toLowerCase().contains(q);
      final hitLesson = c.lessons.any(
        (l) =>
            l.title.toLowerCase().contains(q) ||
            l.description.toLowerCase().contains(q) ||
            l.subchapterCode.toLowerCase().contains(q),
      );
      return hitCourse || hitLesson;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allLessons = _courses.expand((c) => c.lessons).toList();
    final completedLessons = allLessons.where((l) => l.isCompleted).length;
    final totalXp = allLessons
        .where((l) => l.isCompleted)
        .fold<int>(0, (sum, l) => sum + l.xpReward);
    final filtered = _filteredCourses;
    final hasSearch = _searchCtrl.text.trim().isNotEmpty;

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
              'LMS Kurikulum Manual Brew',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
            ),
            Text(
              '${_courses.length} Bab • ${allLessons.length} Sub-Bab Interaktif',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pustaka E-Book Terkait',
            icon: const Icon(Icons.auto_stories_rounded,
                color: AppTheme.primaryBrown),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EbookLibraryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _buildCurriculumHeroCard(
              totalCourses: _courses.length,
              totalLessons: allLessons.length,
              completedLessons: completedLessons,
              totalXp: totalXp,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText:
                    'Cari Bab/Sub-bab (mis: Darcy, Kasuya 4:6, Switch, WBrC)...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderWarm),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _diffChip('ALL', 'Semua (${_courses.length} Bab)'),
                  const SizedBox(width: 6),
                  _diffChip('NOVICE', 'Novice'),
                  const SizedBox(width: 6),
                  _diffChip('ARTISAN', 'Artisan'),
                  const SizedBox(width: 6),
                  _diffChip('ALCHEMIST', 'Alchemist'),
                  const SizedBox(width: 6),
                  _diffChip('ARCHITECT', 'Architect'),
                  const SizedBox(width: 6),
                  _diffChip('MASTER', 'Master'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...filtered.map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBabAccordionCard(
                  course: course,
                  forceExpanded: hasSearch,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculumHeroCard({
    required int totalCourses,
    required int totalLessons,
    required int completedLessons,
    required int totalXp,
  }) {
    final pct = totalLessons == 0
        ? 0.0
        : (completedLessons / totalLessons).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B1810), Color(0xFF4E342E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppTheme.accentGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Silabus Sains & Teknik Manual Brew',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '$totalCourses Bab • $totalLessons Sub-Bab + Lab Simulasi & Kuis',
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: Colors.white12,
              color: AppTheme.accentGold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                'Selesai: $completedLessons/$totalLessons Sub-Bab (${(pct * 100).round()}%)',
                style: const TextStyle(color: Colors.white70, fontSize: 11.5),
              ),
              Text(
                '$totalXp XP Terkumpul • 100-Bit Anti-Skip',
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBabAccordionCard({
    required LmsCourseModel course,
    required bool forceExpanded,
  }) {
    final isExpanded = forceExpanded || _expandedCourseIds.contains(course.id);
    final completedInBab = course.lessons.where((l) => l.isCompleted).length;
    final q = _searchCtrl.text.trim().toLowerCase();
    final visibleLessons = q.isEmpty
        ? course.lessons
        : course.lessons
            .where(
              (l) =>
                  l.title.toLowerCase().contains(q) ||
                  l.description.toLowerCase().contains(q) ||
                  l.subchapterCode.toLowerCase().contains(q) ||
                  course.title.toLowerCase().contains(q),
            )
            .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? AppTheme.primaryBrown.withValues(alpha: 0.45)
              : AppTheme.borderWarm,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                if (_expandedCourseIds.contains(course.id)) {
                  _expandedCourseIds.remove(course.id);
                } else {
                  _expandedCourseIds.add(course.id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _pill(
                                  course.difficulty,
                                  const Color(0xFFEFE6DC),
                                  AppTheme.primaryBrown,
                                ),
                                _pill(
                                  course.requiredTier,
                                  course.isUnlocked
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFFFEBEE),
                                  course.isUnlocked
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                ),
                                if (course.competencyLevel.isNotEmpty)
                                  _pill(
                                    course.competencyLevel,
                                    const Color(0xFFFFF8E1),
                                    const Color(0xFF8C5D00),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course.title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course.subtitle,
                              maxLines: isExpanded ? 5 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6D5D54),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.primaryBrown,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      Text(
                        '${course.lessons.length} Sub-Bab • $completedInBab selesai',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                      Text(
                        '${(course.totalDurationSec / 60).ceil()} mnt • +${course.xpRewardOnComplete} XP',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && visibleLessons.isNotEmpty) ...[
            const Divider(height: 1, color: AppTheme.dividerColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                children: visibleLessons.map((lesson) {
                  return Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6F0),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: lesson.isCompleted
                            ? const Color(0xFF66BB6A).withValues(alpha: 0.5)
                            : AppTheme.borderWarm,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: () {
                        if (!course.isUnlocked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Bab ini memerlukan Tier ${course.requiredTier}.',
                              ),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute<void>(
                                builder: (_) => LmsCoursePlayerScreen(
                                  course: course,
                                  lesson: lesson,
                                ),
                              ),
                            )
                            .then((_) => _load());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: lesson.isCompleted
                                    ? const Color(0xFF2E7D32)
                                    : AppTheme.primaryBrown,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                lesson.subchapterCode.isNotEmpty
                                    ? lesson.subchapterCode
                                    : '${lesson.lessonNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      Text(
                                        '${(lesson.durationSec / 60).ceil()} mnt • +${lesson.xpReward} XP',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                      if (lesson.simulationConfig['lab_kind'] !=
                                          null)
                                        const Text(
                                          'Lab + Kuis',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryBrown,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              !course.isUnlocked
                                  ? Icons.lock_outline_rounded
                                  : (lesson.isCompleted
                                      ? Icons.verified_rounded
                                      : Icons.play_circle_fill_rounded),
                              color: !course.isUnlocked
                                  ? AppTheme.textMuted
                                  : (lesson.isCompleted
                                      ? const Color(0xFF2E7D32)
                                      : AppTheme.primaryBrown),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _diffChip(String value, String label) {
    final sel = _selectedDifficulty == value;
    return ChoiceChip(
      label: Text(label),
      selected: sel,
      onSelected: (_) => setState(() => _selectedDifficulty = value),
      selectedColor: AppTheme.primaryBrown,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: sel ? Colors.white : AppTheme.textDark,
        fontWeight: FontWeight.w700,
        fontSize: 11.5,
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
