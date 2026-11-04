import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/social_coffee.dart';
import '../../../../theme/app_theme.dart';
import '../utils/social_time_formatter.dart';
import 'social_embedded_recipe_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.bgCream,
                backgroundImage: post.authorAvatar.startsWith('assets/')
                    ? AssetImage(post.authorAvatar) as ImageProvider
                    : NetworkImage(post.authorAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            post.authorRole,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      SocialTimeFormatter.formatRelative(post.createdAt),
                      style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content Text
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppTheme.textDark,
            ),
          ),

          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: post.tags.map((tag) {
                final displayTag = tag.startsWith('#') ? tag : '#$tag';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    displayTag,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Embedded Recipe Card Preview (if recipe attached)
          if (post.recipeSnapshot != null) ...[
            const SizedBox(height: 14),
            SocialEmbeddedRecipeCard(
              post: post,
              onCopyRecipe: onCopyRecipe,
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: 8),

          // Actions Bar: Like, Komen, Copy, Share
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Like Button
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onLike();
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        post.isLikedByMe ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        size: 18,
                        color: post.isLikedByMe ? Colors.redAccent : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${post.likesCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: post.isLikedByMe ? Colors.redAccent : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Comment Button
              InkWell(
                onTap: onComment,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.chat_bubble_text, size: 18, color: AppTheme.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        '${post.commentsCount}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),

              // Copies Count Indicator (jika ada resep)
              if (post.recipeSnapshot != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.doc_on_clipboard, size: 17, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${post.copiesCount} disalin',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              // Share Button
              InkWell(
                onTap: () {
                  final textToCopy = 'Resep dari ${post.authorName} di Coffee Labs:\n${post.content}';
                  Clipboard.setData(ClipboardData(text: textToCopy));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teks diskusi disalin ke clipboard!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Icon(CupertinoIcons.share, size: 17, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
