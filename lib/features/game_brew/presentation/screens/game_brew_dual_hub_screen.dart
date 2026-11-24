import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../data/game_brew_curriculum_catalog.dart';
import '../../data/game_brew_progress_service.dart';
import '../../domain/game_brew_studio_models.dart';
import '../../widgets/transparent_glass_vessel_painter.dart';
import 'discipline_level_map_screen.dart';
import 'latte_art_3d_stage_screen.dart';
import 'manual_brew_3d_stage_screen.dart';

/// Main Entry Hub for Coffee Labs Game Brew Studio 3D v2.0:
/// - 2 Flagship Interactive 3D Discipline Cards:
///     1. Manual Brew 3D Simulator (10-Level Adventure Dasar -> Master WBrC + Technique Drills)
///     2. Latte Art 3D Simulator (10-Level Adventure Dasar -> Master WLAC + Pattern Drills)
/// - Quick Direct Technique Jump Bar (Circular, Reverse Circular, Zigzag, Center, Heart, Tulip, Rosetta, Swan)
/// - Coming Soon Arena Cards (Espresso Dial-In 3D, Roasting Profile 3D, Q-Grader Triangulation)
class GameBrewDualHubScreen extends StatefulWidget {
  const GameBrewDualHubScreen({super.key});

  @override
  State<GameBrewDualHubScreen> createState() => _GameBrewDualHubScreenState();
}

class _GameBrewDualHubScreenState extends State<GameBrewDualHubScreen> {
  @override
  void initState() {
    super.initState();
    GameBrewProgressService.load();
  }

  void _openDiscipline(
    GameBrewDiscipline discipline, {
    int initialTab = 0,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DisciplineLevelMapScreen(
          discipline: discipline,
          initialTabIndex: initialTab,
        ),
      ),
    );
  }

  void _openDirectDrill(GameBrewLevelSpec spec) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => spec.discipline == GameBrewDiscipline.manualBrew3d
            ? ManualBrew3DStageScreen(spec: spec)
            : LatteArt3DStageScreen(spec: spec),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: const Row(
          children: [
            Icon(
              Icons.videogame_asset_rounded,
              color: AppTheme.primaryBrown,
              size: 20,
            ),
            SizedBox(width: 7),
            Flexible(
              child: Text(
                'Game Brew Studio 3D',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<Map<String, LevelProgressRecord>>(
            valueListenable: GameBrewProgressService.progressNotifier,
            builder: (_, _, _) {
              final stars = GameBrewProgressService.totalCombinedStars;
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
                      '$stars ★',
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
      ),
      body: ValueListenableBuilder<Map<String, LevelProgressRecord>>(
        valueListenable: GameBrewProgressService.progressNotifier,
        builder: (context, _, _) {
          final mbStars = GameBrewProgressService.totalStarsFor(
            GameBrewDiscipline.manualBrew3d,
          );
          final mbDone = GameBrewProgressService.completedLevelsFor(
            GameBrewDiscipline.manualBrew3d,
          );
          final laStars = GameBrewProgressService.totalStarsFor(
            GameBrewDiscipline.latteArt3d,
          );
          final laDone = GameBrewProgressService.completedLevelsFor(
            GameBrewDiscipline.latteArt3d,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
            children: [
              // Intro Header
              const Text(
                'Pilih Disiplin Latihan Sensor Gyroscope 3D',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Latih insting barista dari dasar hingga advance dengan fisika fluida nyata, ketel kaca transparan, & pitcher microfoam.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.textMuted,
                  height: 1.38,
                ),
              ),
              const SizedBox(height: 14),

              // FLAGSHIP CARD 1: MANUAL BREW 3D SIMULATOR
              _buildFlagshipDisciplineCard(
                discipline: GameBrewDiscipline.manualBrew3d,
                badge: '3D GYRO • DARCY & SLOSH',
                badgeColor: const Color(0xFF0F766E),
                title: 'Manual Brew 3D Simulator',
                description:
                    'Kuasai Rinsing Filter, RDT, Center Divot, Circular/Reverse/Zigzag Pour, hingga World Brewers Cup (10 Level Adventure + Latihan Teknik).',
                completedLevels: mbDone,
                totalStars: mbStars,
                isMilkPitcher: false,
                drillButtonLabel: 'Latihan Teknik',
              ),
              const SizedBox(height: 14),

              // FLAGSHIP CARD 2: LATTE ART 3D SIMULATOR
              _buildFlagshipDisciplineCard(
                discipline: GameBrewDiscipline.latteArt3d,
                badge: 'CFD NAVIER-STOKES • WLAC',
                badgeColor: const Color(0xFFB45309),
                title: 'Latte Art 3D Simulator',
                description:
                    'Kendalikan ketinggian tuang (Dive vs Float) & ritme wiggle Gyroscope untuk melukis Heart, Tulip, Rosetta hingga Swan (10 Level + Latihan Pola).',
                completedLevels: laDone,
                totalStars: laStars,
                isMilkPitcher: true,
                drillButtonLabel: 'Latihan Pola',
              ),
              const SizedBox(height: 18),

              // DIRECT TECHNIQUE JUMP BAR (Zigzag, Circular, Reverse Circular, Heart, Rosetta, Swan!)
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.bolt_fill,
                    size: 16,
                    color: AppTheme.primaryBrown,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Langsung Latihan Teknik (Tanpa Tunggu Level)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  ...GameBrewCurriculumCatalog.manualBrewDrills.take(4).map(
                        (d) => _buildQuickDrillChip(
                          label: d.manualPattern?.shortLabel ?? d.title,
                          accent: const Color(0xFF0F766E),
                          onTap: () => _openDirectDrill(d),
                        ),
                      ),
                  ...GameBrewCurriculumCatalog.latteArtDrills.take(4).map(
                        (d) => _buildQuickDrillChip(
                          label: d.lattePattern?.label ?? d.title,
                          accent: AppTheme.primaryBrown,
                          onTap: () => _openDirectDrill(d),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 20),

              // COMING SOON GAMES SECTION
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    size: 16,
                    color: AppTheme.accentAmber,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Segera Hadir di Game Brew Studio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...GameBrewCurriculumCatalog.comingSoonGames.map(
                _buildComingSoonCard,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFlagshipDisciplineCard({
    required GameBrewDiscipline discipline,
    required String badge,
    required Color badgeColor,
    required String title,
    required String description,
    required int completedLevels,
    required int totalStars,
    required bool isMilkPitcher,
    required String drillButtonLabel,
  }) {
    final double progress = (completedLevels / 10.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderWarm),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Preview Strip with Transparent Glass Vessel Miniature + Engine Badge
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: CustomPaint(
                  painter: TransparentGlassVesselPainter(
                    isMilkPitcher: isMilkPitcher,
                    fillFraction: isMilkPitcher ? 0.72 : 0.68,
                    capacityMl: isMilkPitcher ? 300 : 350,
                    remainingMl: isMilkPitcher ? 215 : 240,
                    tiltAngleRad: 0.16,
                    sloshAngleRad: 0.08,
                    wavePhase: 0.6,
                    flowRateMlS: 3.5,
                  ),
                ),
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
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        badge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.2,
                          fontWeight: FontWeight.w900,
                          color: badgeColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 11),

          // Progress Bar (Level X / 10 • Y/30 ★)
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: AppTheme.bgCream,
                    valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Lv $completedLevels/10 • $totalStars/30 ★',
                style: const TextStyle(
                  fontSize: 10.8,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dual CTA Buttons: Adventure (Dasar -> Advance) & Direct Drills
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () => _openDiscipline(discipline, initialTab: 0),
                  icon: const Icon(CupertinoIcons.play_fill, size: 14),
                  label: const Text(
                    'Adventure Lv 1–10',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => _openDiscipline(discipline, initialTab: 1),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                    side: const BorderSide(color: AppTheme.primaryBrown),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    drillButtonLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDrillChip({
    required String label,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.play_fill, size: 11, color: accent),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonCard(ComingSoonGameSpec game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: game.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(game.icon, color: game.accentColor, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        game.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.accentAmber.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        'COMING SOON',
                        style: TextStyle(
                          fontSize: 8.8,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC2410C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  game.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
