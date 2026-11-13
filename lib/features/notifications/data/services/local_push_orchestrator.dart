import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/notification_models.dart';
import 'notification_api_service.dart';

final localPushOrchestratorProvider = Provider<LocalPushOrchestrator>((ref) {
  final orchestrator = LocalPushOrchestrator();
  ref.onDispose(orchestrator.dispose);
  return orchestrator;
});

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}

  final payload = PushDeepLinkPayload.fromDataMap({
    ...message.data,
    if (message.notification?.title != null)
      'title': message.notification!.title!,
    if (message.notification?.body != null) 'body': message.notification!.body!,
  });

  if (message.notification == null &&
      payload.title.trim().isNotEmpty &&
      payload.body.trim().isNotEmpty) {
    await LocalPushOrchestrator.showIsolatedLocalNotification(payload);
  }
}

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {
  final actionId = response.actionId;
  final payload = PushDeepLinkPayload.tryParsePayload(response.payload);
  if (payload == null || actionId == null || actionId.isEmpty) return;
  if (actionId == 'QUICK_FOLLBACK' ||
      actionId == 'INLINE_REPLY' ||
      actionId == 'MARK_AS_READ') {
    unawaited(
      NotificationApiService.executeBackgroundAction(
        actionId: actionId,
        payload: payload,
        replyText: response.input,
      ),
    );
  }
}

class LocalPushOrchestrator {
  static const String chatChannelId = 'social_coffee_chat';
  static const String graphChannelId = 'social_coffee_graph';
  static const String threadsChannelId = 'social_coffee_threads';
  static const String billingChannelId = 'social_coffee_billing';

  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
    chatChannelId,
    'Obrolan Social Coffee',
    description: 'Pesan langsung dan balasan cepat obrolan barista.',
    importance: Importance.max,
  );

  static const AndroidNotificationChannel _graphChannel =
      AndroidNotificationChannel(
    graphChannelId,
    'Follback & Mutual',
    description: 'Pengikut baru, mutual follback, dan jaringan pertemanan.',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _threadsChannel =
      AndroidNotificationChannel(
    threadsChannelId,
    'Aktivitas Resep & Thread',
    description: 'Komentar, likes gabungan, dan seduhan komunitas.',
    importance: Importance.defaultImportance,
  );

  static const AndroidNotificationChannel _billingChannel =
      AndroidNotificationChannel(
    billingChannelId,
    'Transaksi & Live Seduh',
    description: 'Status upgrade Pro, langganan, dan pengingat streak seduh.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _activeChatRoomId;

  final StreamController<PushDeepLinkPayload> _deepLinkTapCtrl =
      StreamController<PushDeepLinkPayload>.broadcast();
  final StreamController<String> _actionExecutedCtrl =
      StreamController<String>.broadcast();

  Stream<PushDeepLinkPayload> get deepLinkTapStream => _deepLinkTapCtrl.stream;
  Stream<String> get actionExecutedStream => _actionExecutedCtrl.stream;

  void setActiveChatRoomId(String? conversationId) {
    _activeChatRoomId = conversationId;
  }

  bool get _isTestEnvironment =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  bool get _supportsLocalNotifications {
    if (kIsWeb || _isTestEnvironment) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  static InitializationSettings _buildInitializationSettings() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    final iosCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        'SOCIAL_CHAT',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'INLINE_REPLY',
            'Balas Cepat',
            buttonTitle: 'Kirim',
            placeholder: 'Tulis balasan...',
            options: const <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
          DarwinNotificationAction.plain(
            'MARK_AS_READ',
            'Tandai Dibaca',
          ),
        ],
      ),
      DarwinNotificationCategory(
        'SOCIAL_GRAPH',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            'QUICK_FOLLBACK',
            'Follback',
            options: const <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
          DarwinNotificationAction.plain(
            'MARK_AS_READ',
            'Tandai Dibaca',
          ),
        ],
      ),
    ];

    final darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: iosCategories,
    );

    const windows = WindowsInitializationSettings(
      appName: 'Coffee Labs',
      appUserModelId: 'com.supernovalabs.coffeelabs',
      guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991b8',
    );

    return InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
      windows: windows,
    );
  }

  Future<void> initialize() async {
    if (_initialized || !_supportsLocalNotifications) return;

    await _plugin.initialize(
      settings: _buildInitializationSettings(),
      onDidReceiveNotificationResponse: _handleForegroundNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackgroundHandler,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_chatChannel);
        await androidPlugin.createNotificationChannel(_graphChannel);
        await androidPlugin.createNotificationChannel(_threadsChannel);
        await androidPlugin.createNotificationChannel(_billingChannel);
      }
    }
    _initialized = true;
  }

  Future<void> requestOsNotificationPermissions() async {
    if (!_supportsLocalNotifications) return;
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<PushDeepLinkPayload?> getInitialLaunchPayload() async {
    if (!_supportsLocalNotifications) return null;
    await initialize();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return PushDeepLinkPayload.tryParsePayload(
      details.notificationResponse?.payload,
    );
  }

  void _handleForegroundNotificationResponse(NotificationResponse response) {
    final payload = PushDeepLinkPayload.tryParsePayload(response.payload);
    if (payload == null) return;

    final actionId = response.actionId;
    if (actionId == 'QUICK_FOLLBACK' ||
        actionId == 'INLINE_REPLY' ||
        actionId == 'MARK_AS_READ') {
      unawaited(
        NotificationApiService.executeBackgroundAction(
          actionId: actionId!,
          payload: payload,
          replyText: response.input,
        ).then((ok) {
          if (ok && !_actionExecutedCtrl.isClosed) {
            _actionExecutedCtrl.add(actionId);
          }
        }),
      );
      return;
    }

    if (!_deepLinkTapCtrl.isClosed) {
      _deepLinkTapCtrl.add(payload);
    }
  }

  bool shouldSuppressForActiveRoom(PushDeepLinkPayload payload) {
    if (_activeChatRoomId == null || _activeChatRoomId!.isEmpty) return false;
    return payload.category == 'CHAT' &&
        payload.conversationId != null &&
        payload.conversationId == _activeChatRoomId;
  }

  Future<void> showForegroundNotification(PushDeepLinkPayload payload) async {
    if (!_supportsLocalNotifications) return;
    if (shouldSuppressForActiveRoom(payload)) return;
    await initialize();
    await _showWithPlugin(_plugin, payload);
  }

  static Future<void> showIsolatedLocalNotification(
    PushDeepLinkPayload payload,
  ) async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(settings: _buildInitializationSettings());
    await _showWithPlugin(plugin, payload);
  }

  static Future<void> _showWithPlugin(
    FlutterLocalNotificationsPlugin plugin,
    PushDeepLinkPayload payload,
  ) async {
    final channel = _channelForCategory(payload.category);
    final groupKey = payload.collapseKey ?? payload.category;
    final notifId = (payload.collapseKey ??
            payload.notificationId ??
            payload.deepLinkPath)
        .hashCode &
        0x7fffffff;

    final actions = <AndroidNotificationAction>[];
    if (payload.actionButtons.contains('QUICK_FOLLBACK')) {
      actions.add(
        const AndroidNotificationAction(
          'QUICK_FOLLBACK',
          'Follback',
          showsUserInterface: false,
        ),
      );
    }
    if (payload.actionButtons.contains('INLINE_REPLY')) {
      actions.add(
        const AndroidNotificationAction(
          'INLINE_REPLY',
          'Balas Cepat',
          showsUserInterface: false,
          inputs: <AndroidNotificationActionInput>[
            AndroidNotificationActionInput(label: 'Tulis balasan...'),
          ],
        ),
      );
    }
    if (payload.notificationId != null && payload.notificationId!.isNotEmpty) {
      actions.add(
        const AndroidNotificationAction(
          'MARK_AS_READ',
          'Tandai Dibaca',
          showsUserInterface: false,
        ),
      );
    }

    final iosCategory = payload.category == 'CHAT'
        ? 'SOCIAL_CHAT'
        : (payload.category == 'SOCIAL_GRAPH' ? 'SOCIAL_GRAPH' : null);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: payload.category == 'CHAT' || payload.category == 'BILLING'
            ? Priority.high
            : Priority.defaultPriority,
        groupKey: groupKey,
        tag: payload.collapseKey,
        actions: actions,
        styleInformation: BigTextStyleInformation(payload.body),
      ),
      iOS: DarwinNotificationDetails(
        threadIdentifier: groupKey,
        categoryIdentifier: iosCategory,
      ),
      macOS: DarwinNotificationDetails(
        threadIdentifier: groupKey,
        categoryIdentifier: iosCategory,
      ),
    );

    await plugin.show(
      id: notifId,
      title: payload.title.isEmpty ? 'Coffee Labs' : payload.title,
      body: payload.body,
      notificationDetails: details,
      payload: payload.toJsonString(),
    );
  }

  static AndroidNotificationChannel _channelForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'CHAT':
        return _chatChannel;
      case 'SOCIAL_GRAPH':
        return _graphChannel;
      case 'THREAD_ACTIVITY':
        return _threadsChannel;
      case 'BILLING':
      case 'GAMIFICATION':
        return _billingChannel;
      default:
        return _graphChannel;
    }
  }

  void dispose() {
    _deepLinkTapCtrl.close();
    _actionExecutedCtrl.close();
  }
}
