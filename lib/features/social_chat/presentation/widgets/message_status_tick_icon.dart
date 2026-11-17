import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/chat_protocol.dart';

class MessageStatusTickIcon extends StatelessWidget {
  final DeliveryStatus status;
  final bool onDarkBubble;
  final double size;
  final bool showPendingLabel;

  const MessageStatusTickIcon({
    super.key,
    required this.status,
    this.onDarkBubble = true,
    this.size = 15,
    this.showPendingLabel = false,
  });

  static String labelForStatus(DeliveryStatus status) {
    return switch (status) {
      DeliveryStatus.sending => 'Pending',
      DeliveryStatus.sent => 'Terkirim',
      DeliveryStatus.delivered => 'Terkirim',
      DeliveryStatus.read => 'Sudah dibaca',
      DeliveryStatus.failed => 'Gagal terkirim',
    };
  }

  static String descriptionForStatus(DeliveryStatus status) {
    return switch (status) {
      DeliveryStatus.sending => 'Menunggu antrean pengiriman ke server.',
      DeliveryStatus.sent => 'Ceklis 1: Pesan berhasil terkirim ke server.',
      DeliveryStatus.delivered => 'Ceklis 1: Pesan sudah diteruskan ke perangkat penerima.',
      DeliveryStatus.read => 'Ceklis 2: Pesan sudah dibaca oleh penerima.',
      DeliveryStatus.failed => 'Pesan gagal dikirim. Ketuk untuk kirim ulang.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final mutedColor = onDarkBubble
        ? Colors.white.withValues(alpha: 0.78)
        : AppTheme.textMuted;
    final deliveredColor =
        onDarkBubble ? Colors.white.withValues(alpha: 0.94) : AppTheme.primaryBrown;
    final readColor =
        onDarkBubble ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7);

    final Widget icon = switch (status) {
      DeliveryStatus.sending => Row(
          key: const ValueKey('sending_wrap'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.clock,
              key: const ValueKey('sending'),
              size: size - 2,
              color: mutedColor,
            ),
            if (showPendingLabel) ...[
              const SizedBox(width: 3),
              Text(
                'Pending',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                ),
              ),
            ],
          ],
        ),
      // Ceklis 1 = Terkirim ke server (atau perangkat penerima sebelum dibaca)
      DeliveryStatus.sent => Icon(
          Icons.check_rounded,
          key: const ValueKey('sent'),
          size: size,
          color: mutedColor,
        ),
      DeliveryStatus.delivered => Icon(
          Icons.check_rounded,
          key: const ValueKey('delivered'),
          size: size,
          color: deliveredColor,
        ),
      // Ceklis 2 = Sudah dibaca oleh penerima
      DeliveryStatus.read => Icon(
          Icons.done_all_rounded,
          key: const ValueKey('read'),
          size: size,
          color: readColor,
        ),
      DeliveryStatus.failed => Icon(
          CupertinoIcons.exclamationmark_circle_fill,
          key: const ValueKey('failed'),
          size: size - 1,
          color: const Color(0xFFFF6B6B),
        ),
    };

    return Tooltip(
      message: descriptionForStatus(status),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: icon,
      ),
    );
  }
}
