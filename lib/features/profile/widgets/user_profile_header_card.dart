import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/subscription_plan.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../../gamification/models/coffee_level.dart';
import '../../gamification/services/gamification_service.dart';
import '../../gamification/widgets/gamified_avatar.dart';
import '../../gamification/widgets/level_roadmap_modal.dart';
import '../../../widgets/professional_running_text.dart';

class UserProfileHeaderCard extends StatelessWidget {
  final AuthUser? currentUser;
  final String displayName;
  final String? avatarPath;
  final bool isTrial;
  final bool isAdmin;
  final SubscriptionTier currentTier;
  final CoffeeLevel? level;
  final GamificationStats? gamificationStats;
  final VoidCallback onTapAvatar;

  const UserProfileHeaderCard({
    super.key,
    required this.currentUser,
    required this.displayName,
    required this.avatarPath,
    required this.isTrial,
    required this.isAdmin,
    this.currentTier = SubscriptionTier.trial,
    this.level,
    this.gamificationStats,
    required this.onTapAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final lvl = level ?? gamificationStats?.level ?? CoffeeLevel.allLevels.first;
    final stats = gamificationStats;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row Utama: Avatar & Info Pengguna
          Row(
            children: [
              GamifiedAvatar(
                radius: 32,
                imagePath: avatarPath,
                level: lvl,
                showLevelBadge: true,
                onTap: () {
                  if (stats != null) {
                    LevelRoadmapModal.show(context, stats: stats, avatarPath: avatarPath);
                  } else {
                    onTapAvatar();
                  }
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                      child: ProfessionalRunningText(
                        text: displayName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      currentUser != null ? '@${currentUser!.username}' : '@tamu_trial',
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildRoleBadge(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          constraints: const BoxConstraints(maxWidth: 160),
                          decoration: BoxDecoration(
                            color: lvl.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ProfessionalRunningText(
                            text: lvl.title,
                            style: TextStyle(
                              color: lvl.accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Gamifikasi Terintegrasi Langsung di Header (Tanpa Card Baru Terpisah)
          if (stats != null) ...[
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: lvl.borderGradient),
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: lvl.glowColor.withValues(alpha: 0.25),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(lvl.badgeIcon, size: 10.5, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'LEVEL ${lvl.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lvl.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.textDark),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => LevelRoadmapModal.show(context, stats: stats, avatarPath: avatarPath),
                  child: Row(
                    children: [
                      Text(
                        'Roadmap',
                        style: TextStyle(
                          color: lvl.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(CupertinoIcons.chevron_right, size: 11, color: lvl.accentColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar EXP
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: stats.progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(lvl.accentColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stats.totalExp} EXP • ${(stats.progress * 100).toInt()}% Selesai',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                if (lvl.level < 10)
                  Text(
                    '${stats.expToNext} EXP ke Lv.${lvl.level + 1}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  )
                else
                  const Text(
                    '⭐ Peringkat Maksimal',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF8F00)),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 4 Mini Metric Chips
            Row(
              children: [
                _buildMiniMetric(CupertinoIcons.timer, '${stats.brewsCount}', 'Seduhan', const Color(0xFFE65100)),
                const SizedBox(width: 6),
                _buildMiniMetric(CupertinoIcons.sparkles, '${stats.toolkitCount}', 'Toolkit', const Color(0xFF1E88E5)),
                const SizedBox(width: 6),
                _buildMiniMetric(CupertinoIcons.pencil_outline, '${stats.cuppingCount}', 'Evaluasi', const Color(0xFF2E7D32)),
                const SizedBox(width: 6),
                _buildMiniMetric(CupertinoIcons.flame_fill, '${stats.streakDays}d', 'Streak', const Color(0xFFD84315)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMetric(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 8.5, color: Colors.grey.shade700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge() {
    if (isAdmin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade700),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.shield_lefthalf_fill, size: 12, color: Colors.amber.shade900),
            const SizedBox(width: 4),
            Text(
              'ADMINISTRATOR',
              style: TextStyle(color: Colors.amber.shade900, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (currentTier == SubscriptionTier.business) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.briefcase_fill, size: 12, color: Colors.amber.shade900),
            const SizedBox(width: 4),
            Text(
              'BUSINESS CAFE',
              style: TextStyle(color: Colors.amber.shade900, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (currentTier == SubscriptionTier.pro) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.brown.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryBrown),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.sparkles, size: 12, color: AppTheme.primaryBrown),
            SizedBox(width: 4),
            Text(
              'COFFEE LABS PRO',
              style: TextStyle(color: AppTheme.primaryBrown, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (isTrial) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.brown.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.person_fill, size: 12, color: AppTheme.primaryBrown),
            const SizedBox(width: 4),
            Text(
              currentUser != null ? 'BARISTA' : 'PENGUNJUNG',
              style: const TextStyle(color: AppTheme.primaryBrown, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.checkmark_seal_fill, size: 12, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'VERIFIED BARISTA',
              style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }
}
