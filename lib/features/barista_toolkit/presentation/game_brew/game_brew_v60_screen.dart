import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../data/barista_toolkit_api_service.dart';
import '../../data/barista_toolkit_seed_data.dart';
import '../../domain/barista_toolkit_models.dart';
import '../game_brew_3d/ui/game_brew_3d_simulator_screen.dart';

class GameBrewV60Screen extends ConsumerStatefulWidget {
  const GameBrewV60Screen({super.key});

  @override
  ConsumerState<GameBrewV60Screen> createState() => _GameBrewV60ScreenState();
}

class _GameBrewV60ScreenState extends ConsumerState<GameBrewV60Screen> {
  List<GameBrewChapterModel> _chapters =
      BaristaToolkitFallbackSeed.offlineChapters();

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final chapters =
        await ref.read(baristaToolkitApiProvider).fetchGameChapters();
    if (!mounted) return;
    setState(() {
      _chapters = chapters;
    });
  }

  Future<void> _startChapter(GameBrewChapterModel chapter) async {
    final bool? refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => GameBrew3DSimulatorScreen(chapter: chapter),
      ),
    );
    if (refreshed == true && mounted) {
      _loadChapters();
    }
  }

  void _launchSandboxPreset({
    required String title,
    required double doseG,
    required double waterMl,
    required double bloomMl,
    required double tempC,
    required double idealFlow,
    double? dropTempC,
    double? dropAtMl,
  }) {
    final sandboxChapter = GameBrewChapterModel(
      chapterNumber: 99,
      slug: 'sandbox-3d',
      title: title,
      storyLocation: 'Lab Kalibrasi 3D Coffee Labs',
      npcMentorName: 'Master Kaito',
      targetRecipeSlug: 'sandbox-v60',
      physicsConfig: {
        'dose_g': doseG,
        'water_ml': waterMl,
        'bloom_ml': bloomMl,
        'bloom_sec': 35.0,
        'target_temp_c': tempC,
        'ideal_flow_ml_s': idealFlow,
        'target_time_sec': 145.0,
        'drop_temp_c': ?dropTempC,
        'drop_at_ml': ?dropAtMl,
      },
      storyDialogue: const [],
      xpReward3Stars: 150,
      isUnlocked: true,
    );

    Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => GameBrew3DSimulatorScreen(
          chapter: sandboxChapter,
          isSandboxMode: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        title: const Text(
          'Game Brew V60: Kedai Senja',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _buildHeroBanner(),
          const SizedBox(height: 12),
          _buildSandboxSection(),
          const SizedBox(height: 16),
          const Text(
            'Kampanye Cerita V60 (5 Chapter)',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          ..._chapters.map(_buildChapterCard),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3E2212), Color(0xFF7B4A2D)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0x33D4AF37),
            child: Icon(
              Icons.view_in_ar_rounded,
              color: AppTheme.accentGold,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '3D GYRO ENGINE',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentGold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'POV • X-Ray • 360°',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Seduh kopi V60 dengan ketel leher angsa Gyroscope 3D, fisika perkolasi ampas kopi, & bimbingan Master Kaito.',
                  style: TextStyle(fontSize: 12.2, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSandboxSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science_rounded,
                  size: 16, color: AppTheme.primaryBrown),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Mode Sandbox Bebas 3D (Latihan Instan)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _sandboxChip(
                label: 'Light Crisp\n15g/225ml',
                color: const Color(0xFF047857),
                onTap: () => _launchSandboxPreset(
                  title: 'Sandbox: Light Roast Crisp',
                  doseG: 15,
                  waterMl: 225,
                  bloomMl: 45,
                  tempC: 93,
                  idealFlow: 4.4,
                ),
              ),
              const SizedBox(width: 8),
              _sandboxChip(
                label: 'Kasuya 4:6\n18g/280ml',
                color: const Color(0xFFB45309),
                onTap: () => _launchSandboxPreset(
                  title: 'Sandbox: Kasuya 4:6 Sweet',
                  doseG: 18,
                  waterMl: 280,
                  bloomMl: 55,
                  tempC: 90,
                  idealFlow: 5.0,
                ),
              ),
              const SizedBox(width: 8),
              _sandboxChip(
                label: 'Dual-Temp\n93°→70°C',
                color: const Color(0xFF0369A1),
                onTap: () => _launchSandboxPreset(
                  title: 'Sandbox: WBrC Dual-Temp',
                  doseG: 15,
                  waterMl: 225,
                  bloomMl: 45,
                  tempC: 93,
                  idealFlow: 4.5,
                  dropTempC: 70,
                  dropAtMl: 135,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sandboxChip({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterCard(GameBrewChapterModel ch) {
    final dose = ch.physicsConfig['dose_g'] ?? 15;
    final water = ch.physicsConfig['water_ml'] ?? 225;
    final temp = ch.physicsConfig['target_temp_c'] ?? 92;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _startChapter(ch),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'CH ${ch.chapterNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ch.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ch.storyLocation} • ${dose}g / ${water}ml • $temp°C',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF795548),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...List.generate(
                          3,
                          (i) => Icon(
                            i < ch.starsEarned
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${ch.xpReward3Stars} XP',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E2212),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            '3D GYRO',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.play_circle_fill,
                color: AppTheme.primaryBrown,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
