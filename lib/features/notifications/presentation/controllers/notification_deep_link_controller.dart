import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../services/auth_service.dart';
import '../../../social_chat/domain/chat_protocol.dart';
import '../../../social_chat/presentation/controllers/chat_controllers.dart';
import '../../data/services/device_token_lifecycle_service.dart';
import '../../data/services/local_push_orchestrator.dart';
import '../../domain/models/notification_models.dart';
import 'notification_center_controller.dart';

final notificationDeepLinkControllerProvider =
    Provider<NotificationDeepLinkController>((ref) {
  final ctrl = NotificationDeepLinkController(ref);
  ref.onDispose(ctrl.dispose);
  return ctrl;
});

/// Mengoordinasikan 3 siklus hidup Push Notification (Terminated, Background, Foreground)
/// serta sinkronisasi WS real-time agar pengguna diarahkan ke rute Coffee Labs secara akurat.
class NotificationDeepLinkController {
  final Ref _ref;

  StreamSubscription<RemoteMessage>? _fcmOpenedSub;
  StreamSubscription<RemoteMessage>? _fcmForegroundSub;
  StreamSubscription<PushDeepLinkPayload>? _localTapSub;
  StreamSubscription<ServerPushNotificationEventFrame>? _wsNotifSub;
  bool _initialized = false;
  GoRouter? _router;

  NotificationDeepLinkController(this._ref);

  Future<void> initialize(GoRouter router) async {
    _router = router;
    if (_initialized) return;
    _initialized = true;

    final orchestrator = _ref.read(localPushOrchestratorProvider);
    await orchestrator.initialize();

    _localTapSub = orchestrator.deepLinkTapStream.listen((payload) {
      unawaited(_navigateFromPayload(payload));
    });

    final ws = _ref.read(chatWsServiceProvider);
    _wsNotifSub = ws.pushNotificationEvents.listen((evt) {
      if (evt.unreadCount >= 0) {
        _ref
            .read(unreadNotificationsCountProvider.notifier)
            .setCount(evt.unreadCount);
      }
      final payload = evt.toDeepLinkPayload();
      unawaited(orchestrator.showForegroundNotification(payload));
    });

    final tokenLifecycle = _ref.read(deviceTokenLifecycleServiceProvider);
    await tokenLifecycle.initializeAndSyncToken(requestPermission: false);
    final firebaseReady = await tokenLifecycle.ensureFirebaseInitialized();

    if (firebaseReady) {
      try {
        // 1. Terminated launch via Firebase notification tap
        final initialMsg =
            await FirebaseMessaging.instance.getInitialMessage();
        if (initialMsg != null) {
          final payload = _remoteMessageToPayload(initialMsg);
          unawaited(_navigateFromPayload(payload));
        }

        // 2. Background resume via notification tap
        _fcmOpenedSub =
            FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
          unawaited(_navigateFromPayload(_remoteMessageToPayload(msg)));
        });

        // 3. Foreground FCM message -> tampilkan banner lokal bila room belum terbuka
        _fcmForegroundSub =
            FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
          final payload = _remoteMessageToPayload(msg);
          unawaited(
            _ref.read(unreadNotificationsCountProvider.notifier).refresh(),
          );
          unawaited(orchestrator.showForegroundNotification(payload));
        });
      } catch (e) {
        debugPrint('Listener FirebaseMessaging dilewati: $e');
      }
    }

    // Fallback Terminated launch via flutter_local_notifications
    try {
      final initialLocalPayload = await orchestrator.getInitialLaunchPayload();
      if (initialLocalPayload != null) {
        unawaited(_navigateFromPayload(initialLocalPayload));
      }
    } catch (_) {}
  }

  PushDeepLinkPayload _remoteMessageToPayload(RemoteMessage msg) {
    return PushDeepLinkPayload.fromDataMap({
      ...msg.data,
      if (msg.notification?.title != null) 'title': msg.notification!.title!,
      if (msg.notification?.body != null) 'body': msg.notification!.body!,
    });
  }

  Future<void> _navigateFromPayload(PushDeepLinkPayload payload) async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) return;

    final notifId = payload.notificationId;
    if (notifId != null && notifId.isNotEmpty) {
      unawaited(
        _ref
            .read(notificationCenterControllerProvider.notifier)
            .markAsRead(notifId),
      );
    }

    final targetPath = payload.normalizedGoRouterPath;
    final router = _router;
    if (router != null) {
      router.push(targetPath);
    }
  }

  void dispose() {
    _fcmOpenedSub?.cancel();
    _fcmForegroundSub?.cancel();
    _localTapSub?.cancel();
    _wsNotifSub?.cancel();
  }
}
