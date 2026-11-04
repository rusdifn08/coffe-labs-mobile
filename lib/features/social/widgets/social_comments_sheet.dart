import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../models/social_coffee.dart';
import '../../../../services/social_service.dart';
import '../../../../theme/app_theme.dart';

class SocialCommentsSheet extends StatefulWidget {
  final SocialPost post;

  const SocialCommentsSheet({super.key, required this.post});

  static Future<void> show(BuildContext context, SocialPost post) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SocialCommentsSheet(post: post),
    );
  }

  @override
  State<SocialCommentsSheet> createState() => _SocialCommentsSheetState();
}

class _SocialCommentsSheetState extends State<SocialCommentsSheet> {
  List<SocialComment> _comments = [];
  bool _isLoading = true;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final list = await SocialService.getComments(widget.post.id);
    if (!mounted) return;
    setState(() {
      _comments = list;
      _isLoading = false;
    });
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final comment = await SocialService.addComment(widget.post.id, text);
    if (!mounted) return;

    if (comment != null) {
      widget.post.commentsCount++;
      setState(() {
        _comments.add(comment);
        _commentCtrl.clear();
        _isSending = false;
      });
    } else {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Komentar (${widget.post.commentsCount})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.dividerColor),

          // Comments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.chat_bubble, size: 36, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada komentar. Berikan tanggapan pertama!',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (ctx, idx) {
                          final c = _comments[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.bgCream,
                                  backgroundImage: c.authorAvatar.startsWith('assets/')
                                      ? AssetImage(c.authorAvatar) as ImageProvider
                                      : NetworkImage(c.authorAvatar),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgCream.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.authorName,
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c.content,
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Input Bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCream,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Tulis tanggapan atau saran seduh...',
                        hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSending ? null : _submitComment,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBrown),
                        )
                      : const Icon(CupertinoIcons.paperplane_fill, color: AppTheme.primaryBrown),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
