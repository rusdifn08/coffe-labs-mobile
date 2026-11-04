import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../services/gamification_service.dart';
import 'level_roadmap_modal.dart';

/// Kartu progres gamifikasi ringkas & elegan di halaman Home.
class GamificationHomeCard extends StatelessWidget {
  final GamificationStats stats;
  final String? avatarPath;

  const GamificationHomeCard({
    super.key,
    required this.stats,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final lvl = stats.level;

    return GestureDetector(
      onTap: () => LevelRoadmapModal.show(context, stats: stats, avatarPath: avatarPath),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: lvl.accentColor.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: lvl.glowColor.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: lvl.borderGradient),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(lvl.badgeIcon, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Lv.${lvl.level}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lvl.title,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.textDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        lvl.indonesianTitle,
                        style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Roadmap',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: lvl.accentColor,
                      ),
                    ),
                    Icon(CupertinoIcons.chevron_right, size: 12, color: lvl.accentColor),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: stats.progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(lvl.accentColor),
              ),
            ),
            const SizedBox(height: 6),

            // Stat pills
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stats.totalExp} EXP • ${(stats.progress * 100).toInt()}%',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                ),
                Row(
                  children: [
                    _buildMiniBadge(CupertinoIcons.timer, '${stats.brewsCount} Seduh'),
                    const SizedBox(width: 6),
                    _buildMiniBadge(CupertinoIcons.flame_fill, '${stats.streakDays}d Streak'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 11, color: AppTheme.primaryBrown),
        const SizedBox(width: 2),
        Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }
}
