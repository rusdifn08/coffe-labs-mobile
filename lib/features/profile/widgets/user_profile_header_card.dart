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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (_hasInlineTierBadge) ...[
                          const SizedBox(width: 7),
                          _buildInlineTierBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      currentUser != null ? '@${currentUser!.username}' : '@tamu_trial',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (!_hasInlineTierBadge) _buildSecondaryRoleBadge(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          constraints: const BoxConstraints(maxWidth: 165),
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

  bool get _hasInlineTierBadge =>
      isAdmin ||
      currentTier == SubscriptionTier.business ||
      currentTier == SubscriptionTier.pro;

  Widget _buildInlineTierBadge() {
    if (isAdmin) {
      return Container(
        key: const Key('profile_tier_badge_admin'),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7F1D1D), Color(0xFF450A0A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF991B1B).withValues(alpha: 0.28),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.shield_lefthalf_fill,
              size: 10.5,
              color: Color(0xFFFDE68A),
            ),
            SizedBox(width: 3.5),
            Text(
              'ADMIN',
              style: TextStyle(
                color: Color(0xFFFEF3C7),
                fontSize: 9.2,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.85,
                height: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    if (currentTier == SubscriptionTier.business) {
      return Container(
        key: const Key('profile_tier_badge_business'),
        padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 3.5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF14110F),
              Color(0xFF2E2318),
              Color(0xFF17130F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFF2C96B), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.34),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 11.5,
              color: Color(0xFFF6CE69),
            ),
            SizedBox(width: 3.5),
            Text(
              'BUSINESS',
              style: TextStyle(
                color: Color(0xFFFFE7A3),
                fontSize: 9.2,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.85,
                height: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    // Coffee Labs PRO — Premium Espresso-Bronze & Champagne Gold Pill
    return Container(
      key: const Key('profile_tier_badge_pro'),
      padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 3.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2B1810),
            Color(0xFF5C3317),
            Color(0xFF8C5324),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF0C36D), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC88A32).withValues(alpha: 0.32),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 11,
            color: Color(0xFFFFDE8A),
          ),
          SizedBox(width: 3.5),
          Text(
            'PRO',
            style: TextStyle(
              color: Color(0xFFFFF5D6),
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryRoleBadge() {
    if (isTrial) {
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
    }
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
