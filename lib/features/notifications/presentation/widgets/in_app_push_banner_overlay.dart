import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../data/services/local_push_orchestrator.dart';
import '../../domain/models/notification_models.dart';
import '../controllers/notification_deep_link_controller.dart';

/// Overlay Pop-Up Heads-Up Banner bergaya WhatsApp/iMessage yang meluncur halus dari atas layar
/// setiap kali pesan chat atau notifikasi penting masuk saat aplikasi sedang terbuka.
class InAppPushBannerOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const InAppPushBannerOverlay({super.key, required this.child});

  @override
  ConsumerState<InAppPushBannerOverlay> createState() =>
      _InAppPushBannerOverlayState();
}

class _InAppPushBannerOverlayState
    extends ConsumerState<InAppPushBannerOverlay> {
  StreamSubscription<PushDeepLinkPayload>? _bannerSub;
  Timer? _autoDismissTimer;
  PushDeepLinkPayload? _currentBanner;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final orchestrator = ref.read(localPushOrchestratorProvider);
    _bannerSub = orchestrator.inAppBannerStream.listen(_showBanner);
  }

  void _showBanner(PushDeepLinkPayload payload) {
    if (!mounted) return;
    _autoDismissTimer?.cancel();
    setState(() {
      _currentBanner = payload;
      _visible = true;
    });
    _autoDismissTimer = Timer(const Duration(milliseconds: 4600), _dismiss);
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    if (!mounted) return;
    setState(() => _visible = false);
  }

  void _onTapBanner() {
    final payload = _currentBanner;
    _dismiss();
    if (payload != null) {
      unawaited(
        ref.read(notificationDeepLinkControllerProvider).openFromBanner(payload),
      );
    }
  }

  @override
  void dispose() {
    _bannerSub?.cancel();
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _currentBanner;
    final isChat = banner?.category.toUpperCase() == 'CHAT';

    return Stack(
      children: [
        widget.child,
        if (banner != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                offset: _visible ? Offset.zero : const Offset(0, -1.35),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _visible ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !_visible,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Dismissible(
                        key: ValueKey(
                          '${banner.notificationId ?? banner.conversationId}_${banner.body.hashCode}',
                        ),
                        direction: DismissDirection.up,
                        onDismissed: (_) => _dismiss(),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: _onTapBanner,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F1611),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isChat
                                      ? AppTheme.accentGold.withValues(alpha: 0.65)
                                      : Colors.white24,
                                  width: 1.1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.32),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isChat
                                            ? const [
                                                Color(0xFF25D366),
                                                Color(0xFF128C7E),
                                              ]
                                            : const [
                                                AppTheme.primaryBrown,
                                                Color(0xFFC67C4E),
                                              ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      isChat
                                          ? CupertinoIcons.chat_bubble_text_fill
                                          : CupertinoIcons.bell_fill,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                banner.title.trim().isEmpty
                                                    ? 'Coffee Labs'
                                                    : banner.title.trim(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13.5,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              isChat ? 'Baru saja' : 'Info',
                                              style: const TextStyle(
                                                color: AppTheme.accentGold,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          banner.body.trim(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12.2,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    onPressed: _dismiss,
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white54,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
