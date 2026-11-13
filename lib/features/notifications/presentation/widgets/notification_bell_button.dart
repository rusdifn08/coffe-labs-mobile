import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../controllers/notification_center_controller.dart';

class NotificationBellButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool compact;

  const NotificationBellButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsCountProvider);
    final badgeText = unread > 99 ? '99+' : '$unread';
    final iconSize = compact ? 16.0 : 20.0;
    final padding = compact ? const EdgeInsets.all(6.5) : const EdgeInsets.all(8);

    return Tooltip(
      message: 'Pusat Notifikasi',
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 99 : 14),
        onTap: onPressed ?? () => context.push('/notifications'),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ??
                AppTheme.surfaceWhite.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(compact ? 99 : 14),
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                unread > 0
                    ? CupertinoIcons.bell_fill
                    : CupertinoIcons.bell,
                size: iconSize,
                color: iconColor ?? AppTheme.primaryBrown,
              ),
              if (unread > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.surfaceWhite,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      badgeText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
