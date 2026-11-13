import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/chat_protocol.dart';
import '../../domain/chat_view_models.dart';
import 'interactive_bean_chat_bubble.dart';
import 'interactive_recipe_chat_bubble.dart';
import 'message_status_tick_icon.dart';

class ChatMessageBubble extends StatelessWidget {
  final LocalChatMessageView message;
  final bool isMine;
  final ValueChanged<int>? onVisibleSeq;
  final VoidCallback? onRetryFailed;
  final VoidCallback? onLongPressReply;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.onVisibleSeq,
    this.onRetryFailed,
    this.onLongPressReply,
  });

  InteractiveAttachment? _parseAttachment() {
    final raw = message.attachmentJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return InteractiveAttachment.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final status = DeliveryStatus.fromStorage(message.deliveryStatus);
    final attachment = _parseAttachment();
    final timeStr = DateFormat('HH:mm').format(message.createdAt.toLocal());

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPressReply,
              onTap: status == DeliveryStatus.failed && isMine
                  ? onRetryFailed
                  : null,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: isMine ? AppTheme.primaryBrown : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMine ? 18 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 18),
                  ),
                  border: isMine
                      ? null
                      : Border.all(color: AppTheme.borderWarm, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (attachment != null) ...[
                      _buildAttachmentCard(attachment),
                      if (message.bodyText != null &&
                          message.bodyText!.isNotEmpty)
                        const SizedBox(height: 8),
                    ],
                    if (message.bodyText != null &&
                        message.bodyText!.isNotEmpty)
                      Text(
                        message.bodyText!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.38,
                          color: isMine ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 10,
                            color: isMine
                                ? Colors.white.withValues(alpha: 0.72)
                                : AppTheme.textMuted,
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 5),
                          MessageStatusTickIcon(
                            status: status,
                            onDarkBubble: true,
                          ),
                        ],
                      ],
                    ),
                    if (status == DeliveryStatus.failed && isMine)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Gagal terkirim • Ketuk untuk kirim ulang',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFB4AB),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!isMine && message.seqId != null && onVisibleSeq != null) {
      content = VisibilityDetector(
        key: Key('chat_msg_${message.clientMsgId}'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.35 && message.seqId != null) {
            onVisibleSeq!(message.seqId!);
          }
        },
        child: content,
      );
    }

    return content;
  }

  Widget _buildAttachmentCard(InteractiveAttachment attachment) {
    return switch (attachment) {
      V60RecipeCardAttachment card => InteractiveRecipeChatBubble(
          card: card,
          isMine: isMine,
        ),
      CoffeeBeanCardAttachment bean => InteractiveBeanChatBubble(card: bean),
      BrewImageMediaAttachment img => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                color: AppTheme.bgCream,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.photo, color: AppTheme.primaryBrown),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        img.caption ?? img.imageUrl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      BrewSessionResultAttachment res => Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.bgCream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.rosette, color: AppTheme.accentAmber),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${res.method} • Akurasi ${res.accuracyScore}% (+${res.xpEarned} XP)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    };
  }
}
