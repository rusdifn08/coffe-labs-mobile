import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../utils/barista_utils.dart';
import '../../domain/models/social_profile_models.dart';

class BaristaRankShowcaseHeader extends StatelessWidget {
  final MaterializedProfileView profile;
  final VoidCallback onToggleFollow;
  final VoidCallback onMessagePeer;
  final VoidCallback onEditProfile;
  final VoidCallback onTapFollowers;
  final VoidCallback onTapFollowing;
  final Widget? customFollowSection;
  final Widget? relationshipAccessory;

  const BaristaRankShowcaseHeader({
    super.key,
    required this.profile,
    required this.onToggleFollow,
    required this.onMessagePeer,
    required this.onEditProfile,
    required this.onTapFollowers,
    required this.onTapFollowing,
    this.customFollowSection,
    this.relationshipAccessory,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = profile.tierRingGradient;
    final xpPct = (profile.levelProgressRatio * 100).round().clamp(0, 100);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: profile.rankAccentColor.withValues(alpha: 0.25),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Glowing Tier Avatar + Follow/Chat Action CTA
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GlowingTierAvatar(
                avatarUrl: profile.avatarUrl,
                displayName: profile.displayName,
                gradient: gradient,
                tier: profile.accountTier,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _TierPill(tier: profile.accountTier),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '@${profile.username}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        if (profile.isFollowingViewer &&
                            !profile.isOwnProfile) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBrown.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Mengikuti Anda',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),

          if (profile.bio.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              profile.bio,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: AppTheme.textDark,
              ),
            ),
          ],

          ?relationshipAccessory,

          const SizedBox(height: 14),

          // Gamification Barista Rank & XP Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: profile.rankAccentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lv.${profile.baristaLevel}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile.baristaRankTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.flame_fill,
                            size: 12,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${profile.currentStreakDays}h Streak',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: profile.levelProgressRatio.clamp(0.0, 1.0),
                    ),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 7,
                        backgroundColor: Colors.black.withValues(alpha: 0.08),
                        valueColor:
                            AlwaysStoppedAnimation(profile.rankAccentColor),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${profile.totalXp} XP ($xpPct% ke Lv.${profile.baristaLevel + 1})',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Text(
                      '${profile.unlockedBadgeIds.length} Lencana',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: profile.rankAccentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (profile.topFeaturedBadges.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: profile.topFeaturedBadges.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, idx) {
                  final badge = profile.topFeaturedBadges[idx];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: profile.rankAccentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: profile.rankAccentColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.rosette,
                          size: 13,
                          color: profile.rankAccentColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          badge.title,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 10),

          // Social Stats Grid (Followers, Following, Brews, Recipe Tries)
          Row(
            children: [
              Expanded(
                child: _StatTapTile(
                  value: '${profile.followersCount}',
                  label: 'Pengikut',
                  onTap: onTapFollowers,
                ),
              ),
              Expanded(
                child: _StatTapTile(
                  value: '${profile.followingCount}',
                  label: 'Mengikuti',
                  onTap: onTapFollowing,
                ),
              ),
              Expanded(
                child: _StatTapTile(
                  value: '${profile.totalBrewsCount}',
                  label: 'Seduhan',
                ),
              ),
              Expanded(
                child: _StatTapTile(
                  value: '${profile.totalRecipeTriesReceived}x',
                  label: 'Resep Dicoba',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (customFollowSection != null && !profile.isOwnProfile) {
      return customFollowSection!;
    }
    if (profile.isOwnProfile) {
      return SizedBox(
        width: double.infinity,
        height: 36,
        child: OutlinedButton.icon(
          onPressed: onEditProfile,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryBrown,
            side: const BorderSide(color: AppTheme.primaryBrown),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(CupertinoIcons.pencil, size: 15),
          label: const Text(
            'Edit Profil & Bio',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: profile.isFollowedByViewer
                ? OutlinedButton.icon(
                    onPressed: onToggleFollow,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBrown,
                      side: BorderSide(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.45),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.checkmark_alt, size: 15),
                    label: const Text(
                      'Mengikuti',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: onToggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.person_add_solid, size: 14),
                    label: const Text(
                      'Ikuti',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 36,
          child: OutlinedButton.icon(
            onPressed: onMessagePeer,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryBrown,
              side: const BorderSide(color: AppTheme.borderWarm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon: const Icon(CupertinoIcons.paperplane_fill, size: 14),
            label: const Text(
              'Chat',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowingTierAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final List<Color> gradient;
  final String tier;

  const _GlowingTierAvatar({
    required this.avatarUrl,
    required this.displayName,
    required this.gradient,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = avatarUrl?.trim() ?? '';
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 34,
        backgroundColor: AppTheme.bgCream,
        child: trimmed.isNotEmpty
            ? ClipOval(
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: BaristaUtils.buildOfflineImage(
                    trimmed,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'B',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryBrown,
                ),
              ),
      ),
    );
  }
}

class _TierPill extends StatelessWidget {
  final String tier;

  const _TierPill({required this.tier});

  @override
  Widget build(BuildContext context) {
    final lower = tier.toLowerCase();
    final Color bg;
    final Color fg;
    if (lower == 'business') {
      bg = const Color(0xFFEDE9FE);
      fg = const Color(0xFF6D28D9);
    } else if (lower == 'pro') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    } else {
      bg = AppTheme.bgCream;
      fg = AppTheme.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tier.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _StatTapTile extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatTapTile({
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
