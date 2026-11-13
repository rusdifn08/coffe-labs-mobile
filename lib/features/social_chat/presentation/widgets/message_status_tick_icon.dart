import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/chat_protocol.dart';

class MessageStatusTickIcon extends StatelessWidget {
  final DeliveryStatus status;
  final bool onDarkBubble;
  final double size;

  const MessageStatusTickIcon({
    super.key,
    required this.status,
    this.onDarkBubble = true,
    this.size = 15,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = onDarkBubble
        ? Colors.white.withValues(alpha: 0.72)
        : AppTheme.textMuted;

    final Widget icon = switch (status) {
      DeliveryStatus.sending => Icon(
          CupertinoIcons.clock,
          key: const ValueKey('sending'),
          size: size - 2,
          color: mutedColor,
        ),
      DeliveryStatus.sent => Icon(
          Icons.check_rounded,
          key: const ValueKey('sent'),
          size: size,
          color: mutedColor,
        ),
      DeliveryStatus.delivered => Icon(
          Icons.done_all_rounded,
          key: const ValueKey('delivered'),
          size: size,
          color: mutedColor,
        ),
      DeliveryStatus.read => Icon(
          Icons.done_all_rounded,
          key: const ValueKey('read'),
          size: size,
          color: const Color(0xFFD4A373),
        ),
      DeliveryStatus.failed => Icon(
          CupertinoIcons.exclamationmark_circle_fill,
          key: const ValueKey('failed'),
          size: size - 1,
          color: const Color(0xFFFF6B6B),
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
      child: icon,
    );
  }
}
