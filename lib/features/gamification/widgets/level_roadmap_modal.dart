import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/coffee_level.dart';
import '../services/gamification_service.dart';
import 'gamified_avatar.dart';

/// Modal interaktif menampilkan Roadmap 10 Pangkat Barista, EXP Breakdown, dan Cara Naik Level.
class LevelRoadmapModal extends StatelessWidget {
  final GamificationStats stats;
  final String? avatarPath;

  const LevelRoadmapModal({
    super.key,
    required this.stats,
    this.avatarPath,
  });

  static void show(BuildContext context, {required GamificationStats stats, String? avatarPath}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LevelRoadmapModal(stats: stats, avatarPath: avatarPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lvl = stats.level;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Roadmap Pangkat Barista',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                // Hero Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        lvl.accentColor,
                        lvl.glowColor.withValues(alpha: 0.88),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: lvl.glowColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      GamifiedAvatar(
                        radius: 36,
                        level: lvl,
                        imagePath: avatarPath,
                        showLevelBadge: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        lvl.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        lvl.indonesianTitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '"${lvl.quote}"',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // EXP Progress bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${stats.totalExp} EXP',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            lvl.level == 10 ? 'MAX LEVEL' : '${lvl.nextLevelExp} EXP Target',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: stats.progress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      if (lvl.level < 10) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Kurang ${stats.expToNext} EXP lagi untuk naik ke Lv.${lvl.level + 1} (${CoffeeLevel.allLevels[lvl.level].title})',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quests to Earn EXP
                const Text(
                  'Cara Memperoleh EXP Pengalaman:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                ),
                const SizedBox(height: 10),
                _buildQuestRow(
                  icon: CupertinoIcons.timer_fill,
                  color: const Color(0xFFE65100),
                  title: 'Menyeduh Kopi Mandiri / Resep',
                  expReward: '+50 EXP',
                  desc: 'Selesaikan seduhan di Brew Timer',
                ),
                _buildQuestRow(
                  icon: CupertinoIcons.pencil_ellipsis_rectangle,
                  color: const Color(0xFF2E7D32),
                  title: 'Catat Hasil Seduh di Jurnal',
                  expReward: '+40 EXP',
                  desc: 'Beri rating bintang dan ulasan tasting notes',
                ),
                _buildQuestRow(
                  icon: CupertinoIcons.sparkles,
                  color: const Color(0xFF1E88E5),
                  title: 'Gunakan Barista Precision Toolkit',
                  expReward: '+20 EXP',
                  desc: 'Matriks Grinder, TDS, Kimia Air, Kasuya 4:6, Dial-In',
                ),
                _buildQuestRow(
                  icon: CupertinoIcons.flame_fill,
                  color: const Color(0xFFD84315),
                  title: 'Streak Seduh Harian Berturut-turut',
                  expReward: '+25 EXP',
                  desc: 'Buka dan seduh setiap hari tanpa putus',
                ),
                const SizedBox(height: 20),

                // 10 Level Progression Roadmap List
                const Text(
                  '10 Tingkatan Pangkat Barista:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                ),
                const SizedBox(height: 10),
                ...CoffeeLevel.allLevels.map((item) {
                  final isUnlocked = stats.totalExp >= item.minExp;
                  final isCurrent = item.level == lvl.level;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? item.accentColor.withValues(alpha: 0.1)
                          : (isUnlocked ? Colors.white : const Color(0xFFF0EAE1)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent ? item.accentColor : (isUnlocked ? Colors.grey.shade300 : Colors.grey.shade200),
                        width: isCurrent ? 2 : 1,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: item.glowColor.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isUnlocked ? item.borderGradient : [Colors.grey.shade400, Colors.grey.shade500],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: isUnlocked
                                ? [
                                    BoxShadow(
                                      color: item.glowColor.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Icon(
                              isUnlocked ? item.badgeIcon : CupertinoIcons.lock_fill,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Lv.${item.level} • ${item.title}',
                                    style: TextStyle(
                                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.bold,
                                      fontSize: 13,
                                      color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: item.accentColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'AKTIF',
                                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.indonesianTitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isUnlocked ? Colors.grey.shade700 : Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.minExp} EXP',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? item.accentColor : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUnlocked)
                          Icon(
                            isCurrent ? CupertinoIcons.star_circle_fill : CupertinoIcons.checkmark_circle_fill,
                            color: item.accentColor,
                            size: 20,
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestRow({
    required IconData icon,
    required Color color,
    required String title,
    required String expReward,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                Text(desc, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              expReward,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.primaryBrown),
            ),
          ),
        ],
      ),
    );
  }
}
