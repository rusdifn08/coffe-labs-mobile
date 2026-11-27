import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/moderation/content_moderation_guard.dart';
import '../../../../models/social_coffee.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/user_avatar_circle.dart';
import '../utils/social_time_formatter.dart';
import 'social_embedded_recipe_card.dart';

/// Postingan Social Coffee bergaya datar edge-to-edge ala Threads.
/// Mendukung Like, Komentar, Repost, Save/Bookmark, Share, Edit, Hapus, dan Laporkan.
class SocialPostCard extends StatelessWidget {
  final SocialPost post;
  final bool isOwnPost;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onRepost;
  final VoidCallback? onSave;
  final VoidCallback? onBrewRecipe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onReport;

  const SocialPostCard({
    super.key,
    required this.post,
    this.isOwnPost = false,
    required this.onLike,
    required this.onComment,
    this.onRepost,
    this.onSave,
    this.onBrewRecipe,
    this.onEdit,
    this.onDelete,
    this.onReport,
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
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Teks postingan disalin ke clipboard!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Postingan?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        content: const Text(
          'Postingan ini akan dihapus secara permanen dari Social Coffee dan tidak dapat dikembalikan.',
          style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onDelete?.call();
    }
  }

  void _showReportReasonSheet(BuildContext context) {
    const reasons = [
      'Kata kasar, pelecehan, atau SARA',
      'Spam, iklan judi online, atau tautan mencurigakan',
      'Penipuan atau informasi palsu',
      'Konten tidak pantas di komunitas kopi',
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 6),
              child: Text(
                'Laporkan Postingan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Text(
                'Pilih alasan pelaporan agar tim moderasi menindaklanjuti dan menyembunyikan postingan ini.',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              ),
            ),
            const Divider(height: 1, color: AppTheme.dividerColor),
            ...reasons.map(
              (reason) => ListTile(
                leading: const Icon(
                  CupertinoIcons.flag_fill,
                  size: 18,
                  color: Color(0xFFDC2626),
                ),
                title: Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onReport?.call(reason);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
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
            if (isOwnPost && onEdit != null)
              ListTile(
                leading: const Icon(
                  CupertinoIcons.pencil,
                  color: AppTheme.primaryBrown,
                ),
                title: const Text(
                  'Edit Postingan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onEdit?.call();
                },
              ),
            if (isOwnPost && onDelete != null)
              ListTile(
                leading: const Icon(
                  CupertinoIcons.trash,
                  color: Color(0xFFDC2626),
                ),
                title: const Text(
                  'Hapus Postingan',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context);
                },
              ),
            if (onSave != null)
              ListTile(
                leading: Icon(
                  post.isSavedByMe
                      ? CupertinoIcons.bookmark_fill
                      : CupertinoIcons.bookmark,
                  color: AppTheme.primaryBrown,
                ),
                title: Text(
                  post.isSavedByMe
                      ? 'Hapus dari Tersimpan'
                      : 'Simpan Postingan',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onSave?.call();
                },
              ),
            if (!isOwnPost)
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
            if (!isOwnPost && onReport != null)
              ListTile(
                leading: const Icon(
                  CupertinoIcons.flag,
                  color: Color(0xFFDC2626),
                ),
                title: const Text(
                  'Laporkan Postingan',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportReasonSheet(context);
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (post.isRepostedByMe)
          const Padding(
            padding: EdgeInsets.fromLTRB(54, 10, 16, 0),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.arrow_2_squarepath,
                  size: 13.5,
                  color: Color(0xFF15803D),
                ),
                SizedBox(width: 6),
                Text(
                  'Anda memposting ulang',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            post.isRepostedByMe ? 6 : 14,
            16,
            12,
          ),
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
                            UserAvatarCircle(
                              avatarUrl: post.authorAvatar,
                              displayName: post.authorName,
                              radius: 19,
                            ),
                            if (!isOwnPost)
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

                // Kolom Kanan Threads: Header Nama, Role, Teks, Tags, Quoted Resep, Baris Aksi Bawah
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
                                if (post.isEdited) ...[
                                  const SizedBox(width: 4),
                                  const Text(
                                    '• Diedit',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
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

                      // Isi Diskusi (dengan lapisan proteksi tampilan defensif)
                      Text(
                        ContentModerationGuard.sanitizeForDisplay(post.content),
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

                      // Kutipan Resep Inline Gaya Threads Quote Box (tanpa tombol Salin)
                      if (post.recipeSnapshot != null) ...[
                        const SizedBox(height: 10),
                        SocialEmbeddedRecipeCard(
                          post: post,
                          onBrewRecipe: onBrewRecipe ?? () {},
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Baris Ikon Interaksi Bawah: Like · Komentar · Repost · Simpan · Bagikan
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
                            tooltip: 'Suka',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onLike();
                            },
                          ),
                          const SizedBox(width: 18),
                          _ThreadsActionButton(
                            icon: CupertinoIcons.chat_bubble,
                            color: AppTheme.textDark,
                            label: post.commentsCount > 0
                                ? _formatCompactCount(post.commentsCount)
                                : null,
                            tooltip: 'Komentar',
                            onTap: onComment,
                          ),
                          const SizedBox(width: 18),
                          _ThreadsActionButton(
                            icon: CupertinoIcons.arrow_2_squarepath,
                            color: post.isRepostedByMe
                                ? const Color(0xFF15803D)
                                : AppTheme.textDark,
                            label: post.repostsCount > 0
                                ? _formatCompactCount(post.repostsCount)
                                : null,
                            tooltip: post.isRepostedByMe
                                ? 'Batalkan Repost'
                                : 'Repost',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onRepost?.call();
                            },
                          ),
                          const SizedBox(width: 18),
                          _ThreadsActionButton(
                            icon: post.isSavedByMe
                                ? CupertinoIcons.bookmark_fill
                                : CupertinoIcons.bookmark,
                            color: post.isSavedByMe
                                ? AppTheme.primaryBrown
                                : AppTheme.textDark,
                            tooltip: post.isSavedByMe
                                ? 'Hapus dari Tersimpan'
                                : 'Simpan Postingan',
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onSave?.call();
                            },
                          ),
                          const Spacer(),
                          _ThreadsActionButton(
                            icon: CupertinoIcons.paperplane,
                            color: AppTheme.textMuted,
                            tooltip: 'Bagikan',
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
  final String? tooltip;
  final VoidCallback onTap;

  const _ThreadsActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.label,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
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
                  color: color == AppTheme.textDark
                      ? AppTheme.textDark.withValues(alpha: 0.78)
                      : color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: child);
    }
    return child;
  }
}
