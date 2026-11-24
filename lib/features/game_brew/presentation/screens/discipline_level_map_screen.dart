import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../data/game_brew_curriculum_catalog.dart';
import '../../data/game_brew_progress_service.dart';
import '../../domain/game_brew_studio_models.dart';
import 'latte_art_3d_stage_screen.dart';
import 'manual_brew_3d_stage_screen.dart';

/// 2-Tab Progressive Roadmap & Direct Technique Drills Screen for either
/// Manual Brew 3D Simulator or Latte Art 3D Simulator.
class DisciplineLevelMapScreen extends StatefulWidget {
  final GameBrewDiscipline discipline;
  final int initialTabIndex;

  const DisciplineLevelMapScreen({
    super.key,
    required this.discipline,
    this.initialTabIndex = 0,
  });

  @override
  State<DisciplineLevelMapScreen> createState() =>
      _DisciplineLevelMapScreenState();
}

class _DisciplineLevelMapScreenState extends State<DisciplineLevelMapScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool get _isManual => widget.discipline == GameBrewDiscipline.manualBrew3d;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    GameBrewProgressService.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchLevel(GameBrewLevelSpec spec) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _isManual
            ? ManualBrew3DStageScreen(spec: spec)
            : LatteArt3DStageScreen(spec: spec),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adventure = GameBrewCurriculumCatalog.adventureFor(widget.discipline);
    final drills = GameBrewCurriculumCatalog.drillsFor(widget.discipline);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          _isManual ? 'Manual Brew 3D' : 'Latte Art 3D',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          ValueListenableBuilder<Map<String, LevelProgressRecord>>(
            valueListenable: GameBrewProgressService.progressNotifier,
            builder: (_, _, _) {
              final stars =
                  GameBrewProgressService.totalStarsFor(widget.discipline);
              return Container(
                margin: const EdgeInsets.only(right: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.star_fill,
                      size: 13,
                      color: AppTheme.accentAmber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$stars / 30',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryBrown,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textMuted,
                labelStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  const Tab(text: 'Adventure (Lv 1–10)'),
                  Tab(text: _isManual ? 'Latihan Teknik' : 'Latihan Pola'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<Map<String, LevelProgressRecord>>(
        valueListenable: GameBrewProgressService.progressNotifier,
        builder: (context, progressMap, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: Adventure Roadmap (Dasar -> Menengah -> Advance -> Master)
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                children: [
                  _buildTierSection(
                    'Tier 1 • Dasar (Lv. 1–3)',
                    adventure
                        .where((e) => e.difficulty == GameBrewDifficulty.basic)
                        .toList(),
                    progressMap,
                  ),
                  _buildTierSection(
                    'Tier 2 • Menengah (Lv. 4–6)',
                    adventure
                        .where((e) =>
                            e.difficulty == GameBrewDifficulty.intermediate)
                        .toList(),
                    progressMap,
                  ),
                  _buildTierSection(
                    'Tier 3 • Advance (Lv. 7–9)',
                    adventure
                        .where(
                            (e) => e.difficulty == GameBrewDifficulty.advance)
                        .toList(),
                    progressMap,
                  ),
                  _buildTierSection(
                    _isManual
                        ? 'Tier 4 • Master WBrC (Lv. 10)'
                        : 'Tier 4 • Master WLAC (Lv. 10)',
                    adventure
                        .where((e) => e.difficulty == GameBrewDifficulty.master)
                        .toList(),
                    progressMap,
                  ),
                ],
              ),

              // TAB 2: Direct Technique / Pattern Drills (All Unlocked!)
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppTheme.borderWarm),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: AppTheme.accentAmber.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            CupertinoIcons.bolt_fill,
                            size: 18,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isManual
                                ? 'Langsung coba teknik spesifik (Circular, Reverse Circular, Zigzag, Center, Pulse 4:6) kapan saja tanpa menunggu level!'
                                : 'Langsung latih pola Latte Art favorit Anda (Heart, 3-Stack Tulip, Rosetta, Slowsetta, Swan) dengan CFD Navier-Stokes!',
                            style: const TextStyle(
                              fontSize: 11.2,
                              color: AppTheme.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...drills.map((spec) => _buildLevelCard(
                        spec: spec,
                        record: progressMap[spec.code],
                        unlocked: true,
                      )),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTierSection(
    String heading,
    List<GameBrewLevelSpec> levels,
    Map<String, LevelProgressRecord> progressMap,
  ) {
    if (levels.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 8),
          child: Text(
            heading,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 0.3,
            ),
          ),
        ),
        ...levels.map((spec) {
          final unlocked = GameBrewProgressService.isLevelUnlocked(spec);
          return _buildLevelCard(
            spec: spec,
            record: progressMap[spec.code],
            unlocked: unlocked,
          );
        }),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildLevelCard({
    required GameBrewLevelSpec spec,
    required LevelProgressRecord? record,
    required bool unlocked,
  }) {
    final int stars = record?.stars ?? 0;
    final Color tierColor = spec.difficulty.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stars >= 1
              ? const Color(0xFF0F766E).withValues(alpha: 0.35)
              : AppTheme.borderWarm,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  spec.isDirectDrill
                      ? 'DRILL • ${spec.difficulty.label.toUpperCase()}'
                      : 'LV.${spec.levelNumber} • ${spec.difficulty.label.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: tierColor,
                  ),
                ),
              ),
              const Spacer(),
              if (!unlocked)
                const Icon(
                  CupertinoIcons.lock_fill,
                  size: 15,
                  color: AppTheme.textMuted,
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Icon(
                      i < stars
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star,
                      size: 14,
                      color:
                          i < stars ? AppTheme.accentAmber : AppTheme.borderWarm,
                    );
                  }),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            spec.title,
            style: TextStyle(
              fontSize: 13.8,
              fontWeight: FontWeight.w800,
              color: unlocked ? AppTheme.textDark : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            spec.subtitle,
            style: const TextStyle(
              fontSize: 11.2,
              color: AppTheme.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  record != null
                      ? 'Skor Terbaik: ${record.bestScorePct.toStringAsFixed(0)}%'
                      : '+${spec.xpRewardBase} EXP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: unlocked ? () => _launchLevel(spec) : null,
                icon: Icon(
                  unlocked ? CupertinoIcons.play_fill : CupertinoIcons.lock_fill,
                  size: 13,
                ),
                label: Text(
                  unlocked ? 'Main' : 'Terkunci',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      unlocked ? AppTheme.primaryBrown : AppTheme.borderWarm,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
