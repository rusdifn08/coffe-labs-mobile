import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_hub_mobile/features/notifications/data/services/local_push_orchestrator.dart';
import 'package:coffee_hub_mobile/features/notifications/domain/models/notification_models.dart';

void main() {
  test('deduplicates rapid duplicate chat notifications across WS & FCM within 8s window', () {
    final orchestrator = LocalPushOrchestrator();
    addTearDown(orchestrator.dispose);

    const payload = PushDeepLinkPayload(
      category: 'CHAT',
      eventType: 'DIRECT_CHAT_MESSAGE_RECEIVED',
      title: 'Risa Hanipah',
      body: 'Halo, resep V60 hari ini enak banget!',
      deepLinkPath: '/social/chat/room/room-1',
      conversationId: 'room-1',
      collapseKey: 'CHAT_ROOM:room-1',
    );

    final t0 = DateTime(2026, 11, 25, 14, 30, 0);
    expect(orchestrator.isDuplicateNotification(payload, now: t0), isFalse);
    expect(
      orchestrator.isDuplicateNotification(
        payload,
        now: t0.add(const Duration(seconds: 2)),
      ),
      isTrue,
    );
    expect(
      orchestrator.isDuplicateNotification(
        payload,
        now: t0.add(const Duration(seconds: 10)),
      ),
      isFalse,
    );
  });

  test('suppresses chat popup only when user is actively viewing that exact room', () async {
    final orchestrator = LocalPushOrchestrator();
    addTearDown(orchestrator.dispose);

    final received = <PushDeepLinkPayload>[];
    final sub = orchestrator.inAppBannerStream.listen(received.add);
    addTearDown(sub.cancel);

    orchestrator.setActiveChatRoomId('room-active');

    final activeRoomPayload = const PushDeepLinkPayload(
      category: 'CHAT',
      eventType: 'DIRECT_CHAT_MESSAGE_RECEIVED',
      title: 'Risa Hanipah',
      body: 'Pesan di room aktif',
      deepLinkPath: '/social/chat/room/room-active',
      conversationId: 'room-active',
    );
    final otherRoomPayload = const PushDeepLinkPayload(
      category: 'CHAT',
      eventType: 'DIRECT_CHAT_MESSAGE_RECEIVED',
      title: 'Rusdi',
      body: 'Pesan dari room lain',
      deepLinkPath: '/social/chat/room/room-other',
      conversationId: 'room-other',
    );

    expect(await orchestrator.showForegroundNotification(activeRoomPayload), isFalse);
    expect(await orchestrator.showForegroundNotification(otherRoomPayload), isTrue);

    await Future<void>.delayed(Duration.zero);
    expect(received.length, 1);
    expect(received.first.conversationId, 'room-other');
  });

  test('uses upgraded v2 max-importance Android chat channel id', () {
    expect(LocalPushOrchestrator.chatChannelId, 'social_coffee_chat_v2');
  });
}
