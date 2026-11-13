import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/social_graph_models.dart';

class MutualFollowersBannerPill extends StatelessWidget {
  final int mutualCount;
  final List<MiniUserAvatar> avatars;
  final VoidCallback onTap;

  const MutualFollowersBannerPill({
    super.key,
    required this.mutualCount,
    required this.avatars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mutualCount <= 0 || avatars.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayAvatars = avatars.take(3).toList();
    final stackWidth = 24.0 + (displayAvatars.length - 1) * 14.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderWarm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: stackWidth,
              height: 24,
              child: Stack(
                children: [
                  for (var i = 0; i < displayAvatars.length; i++)
                    Positioned(
                      left: i * 14.0,
                      child: _MiniCircleAvatar(user: displayAvatars[i]),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _buildCopy(displayAvatars, mutualCount),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  String _buildCopy(List<MiniUserAvatar> sample, int total) {
    final first = sample[0].displayName;
    if (total == 1 || sample.length == 1) {
      return 'Diikuti oleh $first yang Anda ikuti';
    }
    final second = sample[1].displayName;
    if (total == 2) {
      return 'Diikuti oleh $first & $second yang Anda ikuti';
    }
    final rest = total - 2;
    return 'Diikuti oleh $first, $second, dan $rest lainnya';
  }
}

class _MiniCircleAvatar extends StatelessWidget {
  final MiniUserAvatar user;

  const _MiniCircleAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final initial = user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : 'B';
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.accentGold.withValues(alpha: 0.25),
        border: Border.all(color: AppTheme.surfaceWhite, width: 1.8),
        image: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(user.avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
          ? Text(
              initial,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBrown,
              ),
            )
          : null,
    );
  }
}
