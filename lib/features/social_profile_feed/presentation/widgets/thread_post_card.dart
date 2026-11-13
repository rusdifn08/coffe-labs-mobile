import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../social/utils/social_time_formatter.dart';
import '../../domain/models/social_thread_models.dart';
import 'thread_pouring_curve_card.dart';
import 'thread_recipe_attachment_card.dart';
import 'thread_scanned_bean_badge.dart';

class ThreadPostCard extends StatelessWidget {
  final SocialThreadItem thread;
  final VoidCallback onTapThread;
  final VoidCallback onTapAuthor;
  final VoidCallback? onTapQuotedThread;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleRepost;
  final VoidCallback? onTapReply;
  final ValueChanged<InteractiveRecipeCardAttachment>? onTryRecipe;
  final bool compact;

  const ThreadPostCard({
    super.key,
    required this.thread,
    required this.onTapThread,
    required this.onTapAuthor,
    this.onTapQuotedThread,
    required this.onToggleLike,
    required this.onToggleRepost,
    this.onTapReply,
    this.onTryRecipe,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final attachment = thread.parsedAttachment;

    return Material(
      color: AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTapThread,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: thread.isPinnedOnProfile
                  ? AppTheme.accentGold.withValues(alpha: 0.45)
                  : AppTheme.borderWarm,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thread.isPinnedOnProfile) ...[
                const Row(
                  children: [
                    Icon(
                      CupertinoIcons.pin_fill,
                      size: 12,
                      color: AppTheme.primaryBrown,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Disematkan di Profil',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              _buildAuthorHeader(),
              if (thread.bodyText.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  thread.bodyText,
                  style: TextStyle(
                    fontSize: compact ? 13.5 : 14,
                    height: 1.45,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
              if (thread.mediaUrls.isNotEmpty) ...[
                const SizedBox(height: 10),
                _MediaStrip(items: thread.mediaUrls),
              ],
              if (attachment != null) ...[
                const SizedBox(height: 11),
                attachment.map(
                  interactiveRecipeCard: (card) => ThreadRecipeAttachmentCard(
                    card: card,
                    tryCount: thread.tryRecipeCount,
                    onTryRecipe: () => onTryRecipe?.call(card),
                  ),
                  pouringTelemetryCurve: (telemetry) =>
                      ThreadPouringCurveCard(telemetry: telemetry),
                  scannedCoffeeBagTag: (bean) =>
                      ThreadScannedBeanBadge(bean: bean),
                ),
              ],
              if (thread.quotedPreview != null) ...[
                const SizedBox(height: 10),
                _QuotedThreadBox(
                  quoted: thread.quotedPreview!,
                  onTap: onTapQuotedThread,
                ),
              ],
              const SizedBox(height: 12),
              _EngagementFooter(
                thread: thread,
                onTapReply: onTapReply ?? onTapThread,
                onToggleRepost: onToggleRepost,
                onToggleLike: onToggleLike,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorHeader() {
    final avatar = thread.authorAvatarUrl;
    final hasAsset = avatar != null && avatar.startsWith('assets/');
    final hasNet = avatar != null &&
        (avatar.startsWith('http://') || avatar.startsWith('https://'));

    return InkWell(
      onTap: onTapAuthor,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: compact ? 18 : 20,
            backgroundColor: AppTheme.primaryBrown.withValues(alpha: 0.14),
            backgroundImage: hasAsset
                ? AssetImage(avatar) as ImageProvider
                : (hasNet ? NetworkImage(avatar) : null),
            child: (!hasAsset && !hasNet)
                ? Text(
                    thread.authorDisplayName.isNotEmpty
                        ? thread.authorDisplayName[0].toUpperCase()
                        : 'B',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBrown,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        thread.authorDisplayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCream,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        'Lv.${thread.authorBaristaLevel}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      SocialTimeFormatter.formatRelative(thread.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Text(
                      '@${thread.authorUsername}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    if (thread.kind != 'STANDARD_POST') ...[
                      const SizedBox(width: 8),
                      _ThreadKindPill(kind: thread.kind),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadKindPill extends StatelessWidget {
  final String kind;
  const _ThreadKindPill({required this.kind});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (kind) {
      'BREW_LOG' => ('BREW LOG', const Color(0xFFD97706)),
      'CREATED_RECIPE' => ('RESEP', const Color(0xFF059669)),
      'BEAN_REVIEW' => ('BEAN REVIEW', const Color(0xFF7C3AED)),
      'REPOST' => ('REPOST', const Color(0xFF0284C7)),
      _ => (kind, AppTheme.primaryBrown),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _MediaStrip extends StatelessWidget {
  final List<MediaAttachmentItem> items;
  const _MediaStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: _MediaImage(url: items.first.url),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, idx) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 190,
            child: _MediaImage(url: items[idx].url),
          ),
        ),
      ),
    );
  }
}

class _MediaImage extends StatelessWidget {
  final String url;
  const _MediaImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackBox(),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallbackBox(),
    );
  }

  Widget _fallbackBox() {
    return Container(
      color: AppTheme.bgCream,
      alignment: Alignment.center,
      child: const Icon(
        CupertinoIcons.photo,
        color: AppTheme.textMuted,
      ),
    );
  }
}

class _QuotedThreadBox extends StatelessWidget {
  final QuotedThreadPreview quoted;
  final VoidCallback? onTap;

  const _QuotedThreadBox({required this.quoted, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderWarm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  quoted.authorDisplayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '@${quoted.authorUsername}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              quoted.bodyText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngagementFooter extends StatelessWidget {
  final SocialThreadItem thread;
  final VoidCallback onTapReply;
  final VoidCallback onToggleRepost;
  final VoidCallback onToggleLike;

  const _EngagementFooter({
    required this.thread,
    required this.onTapReply,
    required this.onToggleRepost,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionCounter(
          icon: CupertinoIcons.chat_bubble,
          count: thread.repliesCount,
          active: false,
          activeColor: AppTheme.primaryBrown,
          onTap: onTapReply,
        ),
        const SizedBox(width: 22),
        _ActionCounter(
          icon: CupertinoIcons.arrow_2_squarepath,
          count: thread.repostsCount,
          active: thread.isRepostedByMe,
          activeColor: const Color(0xFF059669),
          onTap: onToggleRepost,
        ),
        const SizedBox(width: 22),
        _ActionCounter(
          icon: thread.isLikedByMe
              ? CupertinoIcons.heart_fill
              : CupertinoIcons.heart,
          count: thread.likesCount,
          active: thread.isLikedByMe,
          activeColor: const Color(0xFFE11D48),
          onTap: onToggleLike,
        ),
        const Spacer(),
        if (thread.tryRecipeCount > 0)
          Row(
            children: [
              const Icon(
                CupertinoIcons.flame,
                size: 14,
                color: AppTheme.lightBrown,
              ),
              const SizedBox(width: 4),
              Text(
                '${thread.tryRecipeCount} diseduh',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ActionCounter extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _ActionCounter({
    required this.icon,
    required this.count,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : AppTheme.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            AnimatedScale(
              scale: active ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 160),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
