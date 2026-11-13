import 'package:coffee_hub_mobile/features/notifications/data/services/device_token_lifecycle_service.dart';
import 'package:coffee_hub_mobile/features/notifications/data/services/notification_api_service.dart';
import 'package:coffee_hub_mobile/features/notifications/domain/models/notification_models.dart';
import 'package:coffee_hub_mobile/features/notifications/presentation/controllers/notification_center_controller.dart';
import 'package:coffee_hub_mobile/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:coffee_hub_mobile/features/notifications/presentation/widgets/notification_bell_button.dart';
import 'package:coffee_hub_mobile/features/social_chat/data/local/chat_drift_database.dart';
import 'package:coffee_hub_mobile/features/social_chat/data/services/chat_api_service.dart';
import 'package:coffee_hub_mobile/features/social_chat/data/services/chat_ws_service.dart';
import 'package:coffee_hub_mobile/features/social_chat/domain/chat_protocol.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/controllers/chat_controllers.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationApiService extends NotificationApiService {
  NotificationInboxPage nextPage;
  bool failNextMarkRead = false;
  bool failNextMarkAllRead = false;
  int markReadReturnUnread = 0;
  int markAllReturnUnread = 0;
  final List<String> requestedCategories = <String>[];
  final List<String> follbackCalls = <String>[];

  _FakeNotificationApiService(this.nextPage) : super(Dio());

  @override
  Future<NotificationInboxPage> getInbox({
    String category = '',
    String? cursor,
    int limit = 25,
  }) async {
    requestedCategories.add(category);
    return nextPage;
  }

  @override
  Future<int> getUnreadCount() async => nextPage.unreadCount;

  @override
  Future<int> markAsRead(String notificationId) async {
    if (failNextMarkRead) {
      failNextMarkRead = false;
      throw Exception('Network error simulated');
    }
    return markReadReturnUnread;
  }

  @override
  Future<int> markAllAsRead() async {
    if (failNextMarkAllRead) {
      failNextMarkAllRead = false;
      throw Exception('Server timeout simulated');
    }
    return markAllReturnUnread;
  }

  @override
  Future<String> quickFollback(String targetUserId) async {
    follbackCalls.add(targetUserId);
    return 'mutual';
  }
}

class _FakeChatWsService extends ChatWsService {
  final ChatDriftDatabase _db;

  _FakeChatWsService._(this._db)
      : super(
          _db,
          ChatApiService(Dio()),
        );

  factory _FakeChatWsService() {
    return _FakeChatWsService._(ChatDriftDatabase(NativeDatabase.memory()));
  }

  @override
  Future<void> connectIfAuthenticated() async {}

  @override
  Stream<ServerPushNotificationEventFrame> get pushNotificationEvents =>
      const Stream<ServerPushNotificationEventFrame>.empty();

  @override
  Future<void> dispose() async {
    await super.dispose();
    await _db.close();
  }
}

NotificationInboxPage _samplePage() {
  return NotificationInboxPage(
    unreadCount: 2,
    hasMore: false,
    items: [
      NotificationInboxItem(
        id: 'notif-follow-1',
        category: 'SOCIAL_GRAPH',
        eventType: 'SOCIAL_NEW_FOLLOWER',
        title: 'Barista Raka mulai mengikuti Anda',
        body: 'Follback untuk langsung membuka jalur obrolan.',
        deepLinkPath: '/social/profile/@raka_v60',
        actionPayload: const <String, dynamic>{
          'actor_id': 'user-raka',
          'is_follback_opportunity': true,
          'action_buttons': ['QUICK_FOLLBACK'],
        },
        actorsPreview: const [
          NotificationActorPreview(
            userId: 'user-raka',
            username: 'raka_v60',
            displayName: 'Barista Raka',
          ),
        ],
        aggregatedCount: 1,
        isRead: false,
        createdAt: DateTime.utc(2026, 11, 13, 8, 0),
      ),
      NotificationInboxItem(
        id: 'notif-likes-1',
        coalesceGroupKey: 'LIKE:thread:abc',
        category: 'THREAD_ACTIVITY',
        eventType: 'THREAD_LIKE_COALESCED',
        title: 'Andi, Citra, dan 12 lainnya menyukai resep Anda',
        body: 'Catatan seduh V60 Geisha Anda sedang ramai diseduh.',
        deepLinkPath: '/social/threads/thread-abc',
        actorsPreview: const [
          NotificationActorPreview(
            userId: 'u1',
            username: 'andi',
            displayName: 'Andi',
          ),
          NotificationActorPreview(
            userId: 'u2',
            username: 'citra',
            displayName: 'Citra',
          ),
        ],
        aggregatedCount: 14,
        isRead: false,
        createdAt: DateTime.utc(2026, 11, 13, 7, 45),
      ),
    ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('PushDeepLinkPayload & Notification Models', () {
    test('normalizes blueprint deep link paths to GoRouter routes', () {
      expect(
        PushDeepLinkPayload.normalizeDeepLinkPath(
          '/social/chat/room/conv-123?open=1',
        ),
        '/social/chat/conv-123?open=1',
      );
      expect(
        PushDeepLinkPayload.normalizeDeepLinkPath('/social/threads/t-999'),
        '/social/thread/t-999',
      );
      expect(
        PushDeepLinkPayload.normalizeDeepLinkPath('/settings/subscription'),
        '/settings',
      );
      expect(
        PushDeepLinkPayload.normalizeDeepLinkPath('/brew/timer?dose=15'),
        '/brew-timer?dose=15',
      );
      expect(
        PushDeepLinkPayload.normalizeDeepLinkPath('/social/profile/@andi'),
        '/social/profile/@andi',
      );
    });

    test('parses action_buttons_json and serializes roundtrip', () {
      final parsed = PushDeepLinkPayload.fromDataMap(<String, dynamic>{
        'event_type': 'DIRECT_CHAT_MESSAGE_RECEIVED',
        'category': 'CHAT',
        'deep_link_path': '/social/chat/room/c-42',
        'conversation_id': 'c-42',
        'actor_id': 'u-9',
        'notification_id': 'n-77',
        'collapse_key': 'CHAT_ROOM:c-42',
        'title': 'Pesan baru dari Sinta',
        'body': 'Ratio 1:15 suhunya 92C ya',
        'action_buttons_json': '["INLINE_REPLY","MARK_AS_READ"]',
      });

      expect(parsed.normalizedGoRouterPath, '/social/chat/c-42');
      expect(parsed.actionButtons, ['INLINE_REPLY', 'MARK_AS_READ']);

      final reparsed = PushDeepLinkPayload.tryParsePayload(
        parsed.toJsonString(),
      );
      expect(reparsed, isNotNull);
      expect(reparsed!.conversationId, 'c-42');
      expect(reparsed.collapseKey, 'CHAT_ROOM:c-42');
    });

    test('NotificationInboxItem exposes quick follback & defaults cleanly', () {
      final sample = _samplePage();
      expect(sample.items.first.hasQuickFollbackAction, isTrue);
      expect(sample.items.last.hasQuickFollbackAction, isFalse);
      expect(sample.items.last.aggregatedCount, 14);
    });
  });

  group('NotificationCenterController state transitions', () {
    test('optimistic markAsRead reconciles & rolls back cleanly on failure', () async {
      final fakeApi = _FakeNotificationApiService(_samplePage())
        ..markReadReturnUnread = 1;
      final fakeWs = _FakeChatWsService();
      addTearDown(fakeWs.dispose);

      final container = ProviderContainer(
        overrides: [
          notificationApiServiceProvider.overrideWithValue(fakeApi),
          chatWsServiceProvider.overrideWithValue(fakeWs),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationCenterControllerProvider.notifier).refresh();
      var state = container.read(notificationCenterControllerProvider);
      expect(state.items.length, 2);
      expect(state.unreadCount, 2);

      await container
          .read(notificationCenterControllerProvider.notifier)
          .markAsRead('notif-follow-1');
      state = container.read(notificationCenterControllerProvider);
      expect(state.items.first.isRead, isTrue);
      expect(state.unreadCount, 1);

      // Simulasikan kegagalan server untuk item ke-2 -> rollback harus terjadi
      fakeApi.failNextMarkRead = true;
      await container
          .read(notificationCenterControllerProvider.notifier)
          .markAsRead('notif-likes-1');
      state = container.read(notificationCenterControllerProvider);
      expect(state.items.last.isRead, isFalse);
      expect(state.unreadCount, 1);
      expect(state.errorMessage, isNotNull);
    });

    test('category selection & quickFollback trigger API calls correctly', () async {
      final fakeApi = _FakeNotificationApiService(_samplePage())
        ..markReadReturnUnread = 1;
      final fakeWs = _FakeChatWsService();
      addTearDown(fakeWs.dispose);

      final container = ProviderContainer(
        overrides: [
          notificationApiServiceProvider.overrideWithValue(fakeApi),
          chatWsServiceProvider.overrideWithValue(fakeWs),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(notificationCenterControllerProvider.notifier);
      await notifier.refresh();
      await notifier.selectCategory(
        OmnichannelNotificationCategory.socialGraph,
      );
      expect(fakeApi.requestedCategories, contains('SOCIAL_GRAPH'));

      final followItem =
          container.read(notificationCenterControllerProvider).items.first;
      await notifier.quickFollback(followItem);
      expect(fakeApi.follbackCalls, ['user-raka']);
      expect(
        container
            .read(notificationCenterControllerProvider)
            .followedBackActorIds,
        contains('user-raka'),
      );
    });
  });

  group('Notification Widgets', () {
    testWidgets('NotificationBellButton renders unread count and 99+ cap', (
      tester,
    ) async {
      final fakeWs = _FakeChatWsService();
      final fakeApi = _FakeNotificationApiService(_samplePage());
      addTearDown(fakeWs.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationApiServiceProvider.overrideWithValue(fakeApi),
            chatWsServiceProvider.overrideWithValue(fakeWs),
          ],
          child: const MaterialApp(
            home: Scaffold(body: Center(child: NotificationBellButton())),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(NotificationBellButton));
      final container = ProviderScope.containerOf(element);
      container.read(unreadNotificationsCountProvider.notifier).setCount(12);
      await tester.pump();
      expect(find.text('12'), findsOneWidget);

      container.read(unreadNotificationsCountProvider.notifier).setCount(145);
      await tester.pump();
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('NotificationCenterScreen displays coalesced count & Follback CTA', (
      tester,
    ) async {
      final fakeApi = _FakeNotificationApiService(_samplePage());
      final fakeWs = _FakeChatWsService();
      addTearDown(fakeWs.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationApiServiceProvider.overrideWithValue(fakeApi),
            chatWsServiceProvider.overrideWithValue(fakeWs),
          ],
          child: const MaterialApp(home: NotificationCenterScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pusat Notifikasi'), findsOneWidget);
      expect(find.text('Tandai Semua'), findsOneWidget);
      expect(find.text('Follback & Teman'), findsOneWidget);
      expect(find.text('Follback'), findsOneWidget);
      expect(find.text('14 interaksi digabungkan'), findsOneWidget);
    });
  });
}
