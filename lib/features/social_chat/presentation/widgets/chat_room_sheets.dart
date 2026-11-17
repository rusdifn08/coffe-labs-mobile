import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/chat_protocol.dart';
import '../../domain/chat_view_models.dart';
import 'message_status_tick_icon.dart';

class ChatDatePill extends StatelessWidget {
  final DateTime date;

  const ChatDatePill({super.key, required this.date});

  String _formatDateLabel(DateTime localDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(localDate.year, localDate.month, localDate.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Kemarin';
    if (localDate.year == now.year) {
      return DateFormat('dd MMM yyyy').format(localDate);
    }
    return DateFormat('dd MMM yyyy').format(localDate);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.borderWarm),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _formatDateLabel(date.toLocal()),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 0.15,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatReplyComposerBanner extends StatelessWidget {
  final LocalChatMessageView replyingTo;
  final bool isMine;
  final String peerTitle;
  final VoidCallback onCancel;

  const ChatReplyComposerBanner({
    super.key,
    required this.replyingTo,
    required this.isMine,
    required this.peerTitle,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final preview = replyingTo.bodyText?.trim().isNotEmpty == true
        ? replyingTo.bodyText!.trim()
        : 'Lampiran (${replyingTo.messageType})';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 8, 10, 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderWarm)),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 6, 7),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderWarm),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isMine ? 'Membalas Anda' : 'Membalas $peerTitle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onCancel,
              icon: const Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 18,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomSheets {
  ChatRoomSheets._();

  static Future<void> showStatusLegend(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderWarm,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Indikator Status Pesan',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pesan Anda tampil di kanan, sedangkan balasan lawan bicara tampil di kiri.',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 14),
              _LegendTile(
                status: DeliveryStatus.sending,
                title: 'Pending',
                subtitle: 'Pesan berada di antrean / menunggu koneksi server.',
              ),
              const SizedBox(height: 8),
              _LegendTile(
                status: DeliveryStatus.sent,
                title: 'Ceklis 1 • Terkirim',
                subtitle: 'Pesan sudah tersimpan di server dan dikirim ke penerima.',
              ),
              const SizedBox(height: 8),
              _LegendTile(
                status: DeliveryStatus.read,
                title: 'Ceklis 2 • Sudah Dibaca',
                subtitle: 'Pesan sudah dibuka dan dibaca langsung oleh penerima.',
              ),
              const SizedBox(height: 8),
              _LegendTile(
                status: DeliveryStatus.failed,
                title: 'Gagal Terkirim',
                subtitle: 'Ketuk bubble pesan merah untuk mengirim ulang.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showMessageActions(
    BuildContext context, {
    required LocalChatMessageView message,
    required bool isMine,
    required VoidCallback onReply,
    VoidCallback? onRetry,
  }) {
    final status = DeliveryStatus.fromStorage(message.deliveryStatus);
    final timeStr = DateFormat('dd MMM yyyy, HH:mm').format(message.createdAt.toLocal());

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderWarm,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isMine
                              ? MessageStatusTickIcon.labelForStatus(status)
                              : 'Pesan Masuk',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 6),
                          MessageStatusTickIcon(
                            status: status,
                            onDarkBubble: false,
                          ),
                        ],
                        const Spacer(),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (isMine) ...[
                      const SizedBox(height: 4),
                      Text(
                        MessageStatusTickIcon.descriptionForStatus(status),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(CupertinoIcons.reply, color: AppTheme.primaryBrown),
                title: const Text('Balas Pesan'),
                onTap: () {
                  Navigator.pop(ctx);
                  onReply();
                },
              ),
              if (message.bodyText != null && message.bodyText!.trim().isNotEmpty)
                ListTile(
                  leading: const Icon(CupertinoIcons.doc_on_doc, color: AppTheme.primaryBrown),
                  title: const Text('Salin Teks'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message.bodyText!));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Teks pesan disalin.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              if (isMine &&
                  onRetry != null &&
                  (status == DeliveryStatus.failed || status == DeliveryStatus.sending))
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_clockwise, color: AppTheme.primaryBrown),
                  title: const Text('Kirim Ulang Sekarang'),
                  onTap: () {
                    Navigator.pop(ctx);
                    onRetry();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendTile extends StatelessWidget {
  final DeliveryStatus status;
  final String title;
  final String subtitle;

  const _LegendTile({
    required this.status,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primaryBrown,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: MessageStatusTickIcon(status: status, onDarkBubble: true, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
