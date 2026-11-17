import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/social_coffee.dart';
import '../../../../theme/app_theme.dart';
import '../utils/social_time_formatter.dart';
import 'social_embedded_recipe_card.dart';

/// Postingan Social Coffee bergaya datar edge-to-edge ala Threads (tanpa card).
class SocialPostCard extends StatelessWidget {
  final SocialPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onCopyRecipe;

  const SocialPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onCopyRecipe,
  });

  void _openAuthorProfile(BuildContext context) {
    final target = (post.userId != null && post.userId!.isNotEmpty)
        ? post.userId!
        : post.authorName.trim();
    if (target.isEmpty) return;
    if (GoRouter.maybeOf(context) != null) {
      context.push('/social/profile/${Uri.encodeComponent(target)}');
    }
  }

  void _copyDiscussionText(BuildContext context) {
    final textToCopy =
        'Postingan dari ${post.authorName} di Coffee Labs:\n${post.content}';
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teks diskusi disalin ke clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.person_crop_circle,
                color: AppTheme.textDark,
              ),
              title: Text('Lihat profil ${post.authorName}'),
              onTap: () {
                Navigator.pop(ctx);
                _openAuthorProfile(context);
              },
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.doc_on_doc,
                color: AppTheme.textDark,
              ),
              title: const Text('Salin teks diskusi'),
              onTap: () {
                Navigator.pop(ctx);
                _copyDiscussionText(context);
              },
            ),
            if (post.recipeSnapshot != null)
              ListTile(
                leading: const Icon(
                  CupertinoIcons.arrow_down_doc,
                  color: AppTheme.primaryBrown,
                ),
                title: const Text('Salin resep seduh ke koleksiku'),
                onTap: () {
                  Navigator.pop(ctx);
                  onCopyRecipe();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatCompactCount(int value) {
    if (value >= 1000) {
      final rb = value / 1000.0;
      return '${rb.toStringAsFixed(rb >= 10 ? 0 : 1).replaceAll('.', ',')}RB';
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final hasReplies = post.commentsCount > 0;
    final hasCustomRole = post.authorRole.trim().isNotEmpty &&
        post.authorRole.toLowerCase() != 'barista';
    final avatarImage = post.authorAvatar.startsWith('assets/')
        ? AssetImage(post.authorAvatar) as ImageProvider
        : NetworkImage(post.authorAvatar);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kolom Kiri Threads: Avatar + Lencana '+' + Garis Vertikal Thread
                SizedBox(
                  width: 42,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _openAuthorProfile(context),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 19,
                              backgroundColor:
                                  AppTheme.primaryBrown.withValues(alpha: 0.1),
                              backgroundImage: avatarImage,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 17,
                                height: 17,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBrown,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.bgCream,
                                    width: 1.8,
                                  ),
                                ),
                                child: const Icon(
                                  CupertinoIcons.plus,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasReplies)
                        Expanded(
                          child: Container(
                            width: 1.8,
                            margin: const EdgeInsets.only(top: 8, bottom: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.dividerColor,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Kolom Kanan Threads: Header Nama, Role di bawah nama, Teks, Tags, Quoted Resep, Aksi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () => _openAuthorProfile(context),
                                    child: Text(
                                      post.authorName,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 13.5,
                                  color: AppTheme.primaryBrown,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  SocialTimeFormatter.formatRelative(
                                    post.createdAt,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showMoreOptionsSheet(context),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                CupertinoIcons.ellipsis,
                                size: 17,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (hasCustomRole) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            post.authorRole,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 5),

                      // Isi Diskusi
                      Text(
                        post.content,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.42,
                          color: AppTheme.textDark,
                        ),
                      ),

                      // Tagar Inline Tanpa Kotak Card
                      if (post.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          children: post.tags.map((tag) {
                            final displayTag =
                                tag.startsWith('#') ? tag : '#$tag';
                            return Text(
                              displayTag,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBrown,
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // Kutipan Resep Inline Gaya Threads Quote Box
                      if (post.recipeSnapshot != null) ...[
                        const SizedBox(height: 10),
                        SocialEmbeddedRecipeCard(
                          post: post,
                          onCopyRecipe: onCopyRecipe,
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Baris Ikon Interaksi Ala Threads
                      Row(
                        children: [
                          _ThreadsActionButton(
                            icon: post.isLikedByMe
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: post.isLikedByMe
                                ? Colors.redAccent
                                : AppTheme.textDark,
                            label: post.likesCount > 0
                                ? _formatCompactCount(post.likesCount)
                                : null,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onLike();
                            },
                          ),
                          const SizedBox(width: 20),
                          _ThreadsActionButton(
                            icon: CupertinoIcons.chat_bubble,
                            color: AppTheme.textDark,
                            label: post.commentsCount > 0
                                ? _formatCompactCount(post.commentsCount)
                                : null,
                            onTap: onComment,
                          ),
                          const SizedBox(width: 20),
                          _ThreadsActionButton(
                            icon: CupertinoIcons.arrow_2_squarepath,
                            color: post.recipeSnapshot != null
                                ? AppTheme.primaryBrown
                                : AppTheme.textDark,
                            label: post.copiesCount > 0
                                ? _formatCompactCount(post.copiesCount)
                                : null,
                            onTap: post.recipeSnapshot != null
                                ? onCopyRecipe
                                : () => _copyDiscussionText(context),
                          ),
                          const SizedBox(width: 20),
                          _ThreadsActionButton(
                            icon: CupertinoIcons.paperplane,
                            color: AppTheme.textDark,
                            onTap: () => _copyDiscussionText(context),
                          ),
                        ],
                      ),

                      if (hasReplies) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onComment,
                          child: Text(
                            'Lihat ${post.commentsCount} balasan',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppTheme.dividerColor),
      ],
    );
  }
}

class _ThreadsActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback onTap;

  const _ThreadsActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color),
            if (label != null) ...[
              const SizedBox(width: 5),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: color == Colors.redAccent
                      ? Colors.redAccent
                      : AppTheme.textDark.withValues(alpha: 0.78),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
