import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../services/gamification_service.dart';
import 'level_roadmap_modal.dart';

/// Hero Card Gamifikasi untuk halaman Profil Pengguna.
class ProfileGamificationHero extends StatelessWidget {
  final GamificationStats stats;
  final String? avatarPath;

  const ProfileGamificationHero({
    super.key,
    required this.stats,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final lvl = stats.level;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lvl.accentColor.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: lvl.glowColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: lvl.borderGradient),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: lvl.glowColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(lvl.badgeIcon, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'LEVEL ${lvl.level}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lvl.title,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppTheme.textDark),
                      ),
                      Text(
                        lvl.indonesianTitle,
                        style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => LevelRoadmapModal.show(context, stats: stats, avatarPath: avatarPath),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: lvl.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Roadmap',
                        style: TextStyle(
                          color: lvl.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(CupertinoIcons.chevron_right, size: 10, color: lvl.accentColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // EXP Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stats.progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(lvl.accentColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.totalExp} EXP • ${(stats.progress * 100).toInt()}% Selesai',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              if (lvl.level < 10)
                Text(
                  '${stats.expToNext} EXP ke Lv.${lvl.level + 1}',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                )
              else
                const Text(
                  '⭐ Peringkat Maksimal',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00)),
                ),
            ],
          ),
          const Divider(height: 20),

          // 4 Metric Tiles
          Row(
            children: [
              _buildStatTile(
                icon: CupertinoIcons.timer,
                color: const Color(0xFFE65100),
                value: '${stats.brewsCount}',
                label: 'Seduhan',
              ),
              const SizedBox(width: 8),
              _buildStatTile(
                icon: CupertinoIcons.sparkles,
                color: const Color(0xFF1E88E5),
                value: '${stats.toolkitCount}',
                label: 'Sesi Toolkit',
              ),
              const SizedBox(width: 8),
              _buildStatTile(
                icon: CupertinoIcons.pencil_outline,
                color: const Color(0xFF2E7D32),
                value: '${stats.cuppingCount}',
                label: 'Evaluasi Rasa',
              ),
              const SizedBox(width: 8),
              _buildStatTile(
                icon: CupertinoIcons.flame_fill,
                color: const Color(0xFFD84315),
                value: '${stats.streakDays}d',
                label: 'Streak',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9.5, color: Colors.grey.shade700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
