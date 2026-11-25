import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  /// Channel v2 memaksa Android 8+ menerapkan Importance.max + suara + getar + Heads-Up Banner.
  static const String chatChannelId = 'social_coffee_chat_v2';
  static const String legacyChatChannelId = 'social_coffee_chat';
  static const String graphChannelId = 'social_coffee_graph';
  static const String threadsChannelId = 'social_coffee_threads';
  static const String billingChannelId = 'social_coffee_billing';

  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
    chatChannelId,
    'Obrolan Social Coffee (Prioritas Tinggi)',
    description: 'Pop-up pesan langsung & balasan cepat ala WhatsApp.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    showBadge: true,
  );

  static const AndroidNotificationChannel _graphChannel =
      AndroidNotificationChannel(
    graphChannelId,
    'Follback & Mutual',
    description: 'Pengikut baru, mutual follback, dan jaringan pertemanan.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
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
    playSound: true,
    enableVibration: true,
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _activeChatRoomId;
  final Map<String, DateTime> _recentDeliveredKeys = {};
  final Map<String, List<Message>> _chatMessageStacks = {};

  final StreamController<PushDeepLinkPayload> _deepLinkTapCtrl =
      StreamController<PushDeepLinkPayload>.broadcast();
  final StreamController<String> _actionExecutedCtrl =
      StreamController<String>.broadcast();
  final StreamController<PushDeepLinkPayload> _inAppBannerCtrl =
      StreamController<PushDeepLinkPayload>.broadcast();

  Stream<PushDeepLinkPayload> get deepLinkTapStream => _deepLinkTapCtrl.stream;
  Stream<String> get actionExecutedStream => _actionExecutedCtrl.stream;
  Stream<PushDeepLinkPayload> get inAppBannerStream => _inAppBannerCtrl.stream;

  void setActiveChatRoomId(String? conversationId) {
    _activeChatRoomId = conversationId;
    if (conversationId != null && conversationId.trim().isNotEmpty) {
      clearRoomConversationStack(conversationId);
    }
  }

  /// Menghapus tumpukan pesan unread lokal dan notifikasi OS saat pengguna membuka room chat.
  void clearRoomConversationStack(String conversationId) {
    final key = 'CHAT_ROOM:${conversationId.trim()}';
    _chatMessageStacks.remove(key);
    if (_initialized && _supportsLocalNotifications) {
      final notifId = key.hashCode & 0x7fffffff;
      unawaited(_plugin.cancel(id: notifId, tag: key).catchError((_) {}));
    }
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

  /// Meminta izin runtime OS (`POST_NOTIFICATIONS` Android 13+ & iOS alert/sound/badge).
  Future<bool> requestOsNotificationPermissions() async {
    if (!_supportsLocalNotifications) return false;
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? (await androidPlugin?.areNotificationsEnabled() ?? false);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  /// Memeriksa apakah izin notifikasi tingkat OS saat ini aktif.
  Future<bool> areOsNotificationsEnabled() async {
    if (!_supportsLocalNotifications) return false;
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    return true;
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
    return payload.category.toUpperCase() == 'CHAT' &&
        payload.conversationId != null &&
        payload.conversationId == _activeChatRoomId;
  }

  /// Deduplikasi lintas-kanal (WS `NewMessage` + WS `PushNotificationEvent` + Foreground FCM)
  /// dengan jendela 8 detik agar 1 pesan masuk tidak pernah memicu 2 pop-up ganda.
  @visibleForTesting
  bool isDuplicateNotification(PushDeepLinkPayload payload, {DateTime? now}) {
    final ts = now ?? DateTime.now();
    _recentDeliveredKeys.removeWhere(
      (_, seenAt) => ts.difference(seenAt) > const Duration(seconds: 8),
    );
    final dedupKey = _buildDedupKey(payload);
    if (_recentDeliveredKeys.containsKey(dedupKey)) {
      return true;
    }
    _recentDeliveredKeys[dedupKey] = ts;
    return false;
  }

  static String _buildDedupKey(PushDeepLinkPayload payload) {
    final cat = payload.category.trim().toUpperCase();
    final roomOrEntity =
        (payload.conversationId ?? payload.entityId ?? payload.deepLinkPath)
            .trim();
    final body = payload.body.trim();
    return '$cat|$roomOrEntity|$body';
  }

  /// Menampilkan pop-up notifikasi ganda:
  /// 1) In-App Floating Heads-Up Banner ala WhatsApp (instan di semua OEM Android/iOS),
  /// 2) OS Heads-Up System Notification (`Importance.max` + `MessagingStyleInformation`).
  Future<bool> showForegroundNotification(
    PushDeepLinkPayload payload, {
    bool emitInAppBanner = true,
  }) async {
    if (shouldSuppressForActiveRoom(payload)) return false;
    if (isDuplicateNotification(payload)) return false;

    if (emitInAppBanner && !_inAppBannerCtrl.isClosed) {
      _inAppBannerCtrl.add(payload);
    }

    if (!_supportsLocalNotifications) return true;
    await initialize();
    unawaited(HapticFeedback.lightImpact().catchError((_) {}));
    await _showWithPlugin(_plugin, payload, chatStacks: _chatMessageStacks);
    return true;
  }

  static Future<void> showIsolatedLocalNotification(
    PushDeepLinkPayload payload,
  ) async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(settings: _buildInitializationSettings());
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_chatChannel);
        await androidPlugin.createNotificationChannel(_graphChannel);
        await androidPlugin.createNotificationChannel(_threadsChannel);
        await androidPlugin.createNotificationChannel(_billingChannel);
      }
    }
    await _showWithPlugin(plugin, payload);
  }

  static Future<void> _showWithPlugin(
    FlutterLocalNotificationsPlugin plugin,
    PushDeepLinkPayload payload, {
    Map<String, List<Message>>? chatStacks,
  }) async {
    final isChat = payload.category.toUpperCase() == 'CHAT';
    final channel = _channelForCategory(payload.category);
    final groupKey = payload.collapseKey ??
        (isChat && payload.conversationId != null
            ? 'CHAT_ROOM:${payload.conversationId}'
            : payload.category);
    final notifId = (payload.collapseKey ??
            (isChat && payload.conversationId != null
                ? 'CHAT_ROOM:${payload.conversationId}'
                : null) ??
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
    if (isChat || payload.actionButtons.contains('INLINE_REPLY')) {
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

    final StyleInformation styleInfo;
    if (isChat) {
      final senderName =
          payload.title.trim().isEmpty ? 'Barista Coffee Labs' : payload.title.trim();
      final sender = Person(
        name: senderName,
        key: payload.actorId ?? senderName,
      );
      final incomingMsg = Message(
        payload.body.trim().isEmpty ? 'Pesan baru' : payload.body.trim(),
        DateTime.now(),
        sender,
      );
      final stack = chatStacks?.putIfAbsent(groupKey, () => <Message>[]) ?? <Message>[];
      stack.add(incomingMsg);
      if (stack.length > 5) {
        stack.removeRange(0, stack.length - 5);
      }
      styleInfo = MessagingStyleInformation(
        const Person(name: 'Anda', key: 'me'),
        conversationTitle: senderName,
        messages: List<Message>.from(stack),
      );
    } else {
      styleInfo = BigTextStyleInformation(payload.body);
    }

    final iosCategory = isChat
        ? 'SOCIAL_CHAT'
        : (payload.category == 'SOCIAL_GRAPH' ? 'SOCIAL_GRAPH' : null);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: isChat
            ? Priority.max
            : (payload.category == 'BILLING' || payload.category == 'SOCIAL_GRAPH'
                ? Priority.high
                : Priority.defaultPriority),
        category: isChat
            ? AndroidNotificationCategory.message
            : AndroidNotificationCategory.social,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
        ticker: '${payload.title}: ${payload.body}',
        groupKey: groupKey,
        tag: groupKey,
        actions: actions,
        styleInformation: styleInfo,
        autoCancel: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
        presentBadge: true,
        interruptionLevel:
            isChat ? InterruptionLevel.timeSensitive : InterruptionLevel.active,
        threadIdentifier: groupKey,
        categoryIdentifier: iosCategory,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
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
    _inAppBannerCtrl.close();
  }
}
