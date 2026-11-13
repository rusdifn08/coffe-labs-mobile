import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/social_thread_models.dart';
import '../controllers/social_profile_controllers.dart';
import '../widgets/thread_post_card.dart';

class ThreadDetailScreen extends ConsumerStatefulWidget {
  final String threadId;

  const ThreadDetailScreen({super.key, required this.threadId});

  @override
  ConsumerState<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends ConsumerState<ThreadDetailScreen> {
  final _replyController = TextEditingController();
  SocialThreadItem? _replyTarget;
  bool _sending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);

    final ok = await ref
        .read(threadDetailControllerProvider(widget.threadId).notifier)
        .submitReply(
          bodyText: text,
          parentThreadId: _replyTarget?.id ?? widget.threadId,
        );

    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      _replyController.clear();
      setState(() => _replyTarget = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim balasan. Pastikan sudah login.'),
        ),
      );
    }
  }

  Future<void> _toggleLike(String id) async {
    try {
      await ref.read(socialProfileApiServiceProvider).toggleLike(id);
      await ref
          .read(threadDetailControllerProvider(widget.threadId).notifier)
          .refresh();
    } catch (_) {}
  }

  Future<void> _toggleRepost(String id) async {
    try {
      await ref.read(socialProfileApiServiceProvider).toggleRepost(id);
      await ref
          .read(threadDetailControllerProvider(widget.threadId).notifier)
          .refresh();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(threadDetailControllerProvider(widget.threadId));

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Detail Thread'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh),
            onPressed: () => ref
                .read(threadDetailControllerProvider(widget.threadId).notifier)
                .refresh(),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrown),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat thread: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ),
        ),
        data: (detail) => Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primaryBrown,
                onRefresh: () => ref
                    .read(
                      threadDetailControllerProvider(widget.threadId).notifier,
                    )
                    .refresh(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    ThreadPostCard(
                      thread: detail.root,
                      onTapThread: () {},
                      onTapAuthor: () => context.push(
                        '/social/profile/${Uri.encodeComponent(detail.root.authorUsername)}',
                      ),
                      onTapReply: () => setState(() => _replyTarget = null),
                      onToggleLike: () => _toggleLike(detail.root.id),
                      onToggleRepost: () => _toggleRepost(detail.root.id),
                      onTryRecipe: (card) => ref
                          .read(
                            profileTabFeedControllerProvider(
                              detail.root.authorUsername,
                              ProfileFeedTab.allThreads,
                            ).notifier,
                          )
                          .onTryRecipeTapped(
                            context: context,
                            card: card,
                            threadId: detail.root.id,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Balasan Diskusi (${detail.replies.length})',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (detail.replies.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderWarm),
                        ),
                        child: const Text(
                          'Belum ada balasan. Jadilah barista pertama yang menanggapi!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      )
                    else
                      ...detail.replies.map(
                        (node) => _ReplyTreeBranch(
                          node: node,
                          depth: 0,
                          onReplyTo: (target) =>
                              setState(() => _replyTarget = target),
                          onToggleLike: _toggleLike,
                          onToggleRepost: _toggleRepost,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _buildReplyComposer(detail.root),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyComposer(SocialThreadItem root) {
    final targetHandle = _replyTarget?.authorUsername ?? root.authorUsername;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceWhite,
          border: Border(top: BorderSide(color: AppTheme.dividerColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Membalas @$targetHandle',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBrown,
                  ),
                ),
                if (_replyTarget != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _replyTarget = null),
                    child: const Text(
                      '(Reset ke root)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar atau feedback seduhan...',
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.bgCream,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            const BorderSide(color: AppTheme.borderWarm),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _sending ? null : _submitReply,
                  icon: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(CupertinoIcons.paperplane_fill, size: 17),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyTreeBranch extends StatelessWidget {
  final ThreadReplyNode node;
  final int depth;
  final ValueChanged<SocialThreadItem> onReplyTo;
  final Future<void> Function(String id) onToggleLike;
  final Future<void> Function(String id) onToggleRepost;

  const _ReplyTreeBranch({
    required this.node,
    required this.depth,
    required this.onReplyTo,
    required this.onToggleLike,
    required this.onToggleRepost,
  });

  @override
  Widget build(BuildContext context) {
    final indent = (depth.clamp(0, 3) * 16).toDouble();

    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: 10),
      child: CustomPaint(
        painter: depth > 0 ? _ThreadConnectorPainter() : null,
        child: Padding(
          padding: EdgeInsets.only(left: depth > 0 ? 12 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThreadPostCard(
                compact: true,
                thread: node.thread,
                onTapThread: () =>
                    context.push('/social/thread/${node.thread.id}'),
                onTapAuthor: () => context.push(
                  '/social/profile/${Uri.encodeComponent(node.thread.authorUsername)}',
                ),
                onTapReply: () => onReplyTo(node.thread),
                onToggleLike: () => onToggleLike(node.thread.id),
                onToggleRepost: () => onToggleRepost(node.thread.id),
              ),
              if (node.children.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...node.children.map(
                  (child) => _ReplyTreeBranch(
                    node: child,
                    depth: depth + 1,
                    onReplyTo: onReplyTo,
                    onToggleLike: onToggleLike,
                    onToggleRepost: onToggleRepost,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreadConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderWarm
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      const Offset(2, 0),
      Offset(2, size.height - 16),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
