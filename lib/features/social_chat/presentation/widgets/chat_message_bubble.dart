import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/moderation/content_moderation_guard.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/user_avatar_circle.dart';
import '../../domain/chat_protocol.dart';
import '../../domain/chat_view_models.dart';
import 'interactive_bean_chat_bubble.dart';
import 'interactive_recipe_chat_bubble.dart';
import 'message_status_tick_icon.dart';

class ChatMessageBubble extends StatelessWidget {
  final LocalChatMessageView message;
  final bool isMine;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool showPeerAvatar;
  final String? peerAvatarInitial;
  final String? peerAvatarUrl;
  final String? senderLabel;
  final LocalChatMessageView? quotedMessage;
  final String? quotedAuthorLabel;
  final ValueChanged<int>? onVisibleSeq;
  final VoidCallback? onRetryFailed;
  final VoidCallback? onLongPressReply;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.showPeerAvatar = false,
    this.peerAvatarInitial,
    this.peerAvatarUrl,
    this.senderLabel,
    this.quotedMessage,
    this.quotedAuthorLabel,
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

  BorderRadius _bubbleRadius() {
    if (isMine) {
      return BorderRadius.only(
        topLeft: const Radius.circular(18),
        topRight: Radius.circular(isFirstInGroup ? 18 : 6),
        bottomLeft: const Radius.circular(18),
        bottomRight: Radius.circular(isLastInGroup ? 4 : 6),
      );
    }
    return BorderRadius.only(
      topLeft: Radius.circular(isFirstInGroup ? 18 : 6),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isLastInGroup ? 4 : 6),
      bottomRight: const Radius.circular(18),
    );
  }

  Widget _buildQuotedPreview(LocalChatMessageView quoted) {
    final quotedText = quoted.bodyText?.trim().isNotEmpty == true
        ? quoted.bodyText!.trim()
        : 'Lampiran (${quoted.messageType})';
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isMine
            ? Colors.white.withValues(alpha: 0.13)
            : AppTheme.bgCream,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: isMine ? AppTheme.accentGold : AppTheme.primaryBrown,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (quotedAuthorLabel != null && quotedAuthorLabel!.isNotEmpty)
            Text(
              quotedAuthorLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isMine ? AppTheme.accentGold : AppTheme.primaryBrown,
              ),
            ),
          Text(
            quotedText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              color: isMine
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = DeliveryStatus.fromStorage(message.deliveryStatus);
    final attachment = _parseAttachment();
    final timeStr = DateFormat('HH:mm').format(message.createdAt.toLocal());

    final bubbleContainer = GestureDetector(
      onLongPress: onLongPressReply,
      onTap: (status == DeliveryStatus.failed || status == DeliveryStatus.sending) &&
              isMine &&
              onRetryFailed != null &&
              status == DeliveryStatus.failed
          ? onRetryFailed
          : null,
      child: Container(
        key: ValueKey('bubble_box_${message.clientMsgId}'),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
          minWidth: 74,
        ),
        padding: const EdgeInsets.fromLTRB(13, 9, 12, 7),
        decoration: BoxDecoration(
          gradient: isMine
              ? const LinearGradient(
                  colors: [Color(0xFF5D4037), Color(0xFF432924)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMine ? null : Colors.white,
          borderRadius: _bubbleRadius(),
          border: isMine
              ? null
              : Border.all(color: AppTheme.borderWarm, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withValues(alpha: isMine ? 0.14 : 0.05),
              blurRadius: isMine ? 10 : 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMine && isFirstInGroup && senderLabel != null && senderLabel!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  senderLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
            if (quotedMessage != null) _buildQuotedPreview(quotedMessage!),
            if (attachment != null) ...[
              _buildAttachmentCard(attachment),
              if (message.bodyText != null && message.bodyText!.isNotEmpty)
                const SizedBox(height: 8),
            ],
            if (message.bodyText != null && message.bodyText!.isNotEmpty)
              Text(
                ContentModerationGuard.sanitizeForDisplay(message.bodyText!),
                style: TextStyle(
                  fontSize: 14.2,
                  height: 1.38,
                  color: isMine ? const Color(0xFFFFFDFB) : AppTheme.textDark,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isMine
                        ? Colors.white.withValues(alpha: 0.74)
                        : AppTheme.textMuted,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 5),
                  MessageStatusTickIcon(
                    status: status,
                    onDarkBubble: true,
                    showPendingLabel: true,
                    size: 14.5,
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
    );

    Widget content = Padding(
      padding: EdgeInsets.only(
        left: isMine ? 40 : 12,
        right: isMine ? 12 : 40,
        top: isFirstInGroup ? 5 : 1.5,
        bottom: isLastInGroup ? 5 : 1.5,
      ),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine && showPeerAvatar) ...[
            if (isLastInGroup)
              UserAvatarCircle(
                avatarUrl: peerAvatarUrl,
                displayName: (peerAvatarInitial != null && peerAvatarInitial!.isNotEmpty)
                    ? peerAvatarInitial!
                    : 'B',
                radius: 13,
              )
            else
              const SizedBox(width: 26),
            const SizedBox(width: 7),
          ],
          Flexible(child: bubbleContainer),
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
