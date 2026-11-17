import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:coffee_hub_mobile/core/network/rust_api_client.dart';
import 'package:coffee_hub_mobile/features/notifications/data/services/device_token_lifecycle_service.dart';
import 'package:coffee_hub_mobile/features/notifications/data/services/local_push_orchestrator.dart';
import 'package:coffee_hub_mobile/features/social_chat/data/local/chat_drift_database.dart';
import 'package:coffee_hub_mobile/features/social_chat/data/services/chat_ws_service.dart';
import 'package:coffee_hub_mobile/features/social_chat/domain/chat_protocol.dart';
import 'package:coffee_hub_mobile/features/social_chat/domain/chat_view_models.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/controllers/chat_controllers.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/screens/social_coffee_chat_room_screen.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/widgets/chat_message_bubble.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/widgets/interactive_bean_chat_bubble.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/widgets/interactive_recipe_chat_bubble.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/widgets/message_status_tick_icon.dart';
import 'package:coffee_hub_mobile/repositories/auth_repository.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';

void main() {
  group('ChatProtocol serialization', () {
    test('ClientFrame.sendMessage encodes to Rust serde wire format', () {
      const card = InteractiveAttachment.v60RecipeCard(
        recipeId: '42',
        title: 'Dual-Temp V60 - Sherry Hsu',
        brewerName: 'Hario V60',
        doseGrams: 15.0,
        waterMl: 240.0,
        tempC: 92,
        targetDurationSec: 150,
        stepsPreview: ['Bloom 45ml'],
      );

      final frame = ClientFrame.sendMessage(
        clientMsgId: 'client-123',
        conversationId: 'conv-456',
        messageType: ChatMessageType.recipeCard,
        bodyText: 'Coba resep ini!',
        attachment: card,
      );

      final wire = frame.toWireJson();
      expect(wire['type'], 'send_message');
      final payload = wire['payload'] as Map<String, dynamic>;
      expect(payload['client_msg_id'], 'client-123');
      expect(payload['message_type'], 'RECIPE_CARD');
      expect(payload['attachment']['kind'], 'v60_recipe_card');
      expect(payload['attachment']['dose_grams'], 15.0);
    });

    test('ServerFrame.tryFromWireJson parses DeltaSyncBatch cleanly', () {
      final raw = {
        'type': 'delta_sync_batch',
        'payload': {
          'messages': [
            {
              'id': 'srv-1',
              'conversation_id': 'conv-1',
              'seq_id': 7,
              'sender_id': 'user-b',
              'client_msg_id': 'cli-7',
              'message_type': 'BEAN_CARD',
              'body_text': 'Biji enak nih',
              'attachment': {
                'kind': 'coffee_bean_card',
                'roastery': 'Fugol Coffee Roasters',
                'bean_name': 'Halu Banana Wine',
                'origin': 'Gunung Halu',
                'process': 'Wine',
                'tasting_notes': ['Banana', 'Caramel'],
              },
              'created_at': '2026-11-13T05:00:00Z',
            }
          ],
          'watermarks': [
            {
              'conversation_id': 'conv-1',
              'user_id': 'user-b',
              'last_delivered_seq_id': 7,
              'last_read_seq_id': 6,
            }
          ],
        },
      };

      final parsed = ServerFrame.tryFromWireJson(raw);
      expect(parsed, isA<ServerDeltaSyncBatchFrame>());
      final batch = parsed! as ServerDeltaSyncBatchFrame;
      expect(batch.messages.length, 1);
      expect(batch.messages.first.seqId, 7);
      expect(batch.messages.first.attachment, isA<CoffeeBeanCardAttachment>());
      expect(batch.watermarks.first.lastReadSeqId, 6);
    });
  });

  group('ChatDriftDatabase Offline-First & FTS5', () {
    late ChatDriftDatabase db;

    setUp(() {
      db = ChatDriftDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('optimistic send -> outbox -> sent ack -> read watermark & FTS5 search',
        () async {
      await db.upsertConversationsFromServer([
        const ChatConversationDto(
          id: 'conv-1',
          kind: 'DIRECT',
          title: 'Bayu Prawiro',
        ),
      ]);

      final frame = ClientFrame.sendMessage(
        clientMsgId: 'cmsg-1',
        conversationId: 'conv-1',
        messageType: ChatMessageType.recipeCard,
        bodyText: 'Resep V60 Sherry Hsu Mantap',
        attachment: const InteractiveAttachment.v60RecipeCard(
          recipeId: '99',
          title: 'Dual-Temp V60 Sherry Hsu',
          brewerName: 'Hario V60',
          doseGrams: 15,
          waterMl: 225,
          tempC: 93,
          targetDurationSec: 140,
        ),
      );

      await db.insertOptimisticAndEnqueue(
        clientMsgId: 'cmsg-1',
        conversationId: 'conv-1',
        senderId: 'me',
        messageType: ChatMessageType.recipeCard,
        bodyText: 'Resep V60 Sherry Hsu Mantap',
        attachment: const InteractiveAttachment.v60RecipeCard(
          recipeId: '99',
          title: 'Dual-Temp V60 Sherry Hsu',
          brewerName: 'Hario V60',
          doseGrams: 15,
          waterMl: 225,
          tempC: 93,
          targetDurationSec: 140,
        ),
        previewText: '☕ Resep: Dual-Temp V60 Sherry Hsu',
        wireFrameJson: frame.toWireJson(),
      );

      final outboxBeforeAck = await db.getOutboxFifo();
      expect(outboxBeforeAck.length, 1);

      final ftsHits = await db.searchMessagesFts('Sherry');
      expect(ftsHits.length, 1);
      expect(ftsHits.first.clientMsgId, 'cmsg-1');

      await db.applySentAck(
        clientMsgId: 'cmsg-1',
        serverMsgId: 'srv-msg-1',
        conversationId: 'conv-1',
        seqId: 12,
        createdAt: DateTime.utc(2026, 11, 13, 6, 0),
      );

      final outboxAfterAck = await db.getOutboxFifo();
      expect(outboxAfterAck, isEmpty);

      await db.applyReceiptWatermark(
        conversationId: 'conv-1',
        currentUserId: 'me',
        actorUserId: 'peer-1',
        status: ReceiptStatus.read,
        upToSeqId: 12,
      );

      final msgs = await db.watchMessagesForConversation('conv-1').first;
      expect(msgs.first.seqId, 12);
      expect(msgs.first.deliveryStatus, 'read');
    });
  });

  group('Social Chat UI Widgets', () {
    testWidgets('renders RecipeCard, BeanCard, and StatusTicks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MessageStatusTickIcon(status: DeliveryStatus.read),
                InteractiveRecipeChatBubble(
                  isMine: true,
                  card: V60RecipeCardAttachment(
                    recipeId: '1',
                    title: 'Bayu Prawiro Segitiga',
                    brewerName: 'Hario Switch',
                    doseGrams: 15,
                    waterMl: 220,
                    tempC: 93,
                    targetDurationSec: 140,
                  ),
                ),
                InteractiveBeanChatBubble(
                  card: CoffeeBeanCardAttachment(
                    roastery: 'Fugol Coffee',
                    beanName: 'Halu Banana',
                    origin: 'Jawa Barat',
                    process: 'Natural',
                    tastingNotes: ['Banana', 'Caramel'],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Bayu Prawiro Segitiga'), findsOneWidget);
      expect(find.text('Buka di Brewing Timer'), findsOneWidget);
      expect(find.text('Halu Banana'), findsOneWidget);
      expect(find.text('Natural'), findsOneWidget);
    });

    testWidgets(
        'aligns mine right with Pending/Ceklis1/Ceklis2 and peer replies left',
        (tester) async {
      final now = DateTime.utc(2026, 11, 16, 8, 47);
      final peerMsg = LocalChatMessageView(
        clientMsgId: 'peer-1',
        conversationId: 'conv-1',
        seqId: 1,
        senderId: 'peer-risa',
        messageType: 'TEXT',
        bodyText: 'Halo Rusdi!',
        deliveryStatus: 'delivered',
        createdAt: now,
      );
      final pendingMsg = LocalChatMessageView(
        clientMsgId: 'mine-pending',
        conversationId: 'conv-1',
        senderId: 'user-rusdi',
        messageType: 'TEXT',
        bodyText: 'Lagi dikirim nih',
        deliveryStatus: 'sending',
        createdAt: now.add(const Duration(minutes: 1)),
      );
      final sentMsg = LocalChatMessageView(
        clientMsgId: 'mine-sent',
        conversationId: 'conv-1',
        seqId: 2,
        senderId: 'user-rusdi',
        messageType: 'TEXT',
        bodyText: 'Sudah terkirim ke server',
        deliveryStatus: 'sent',
        createdAt: now.add(const Duration(minutes: 2)),
      );
      final readMsg = LocalChatMessageView(
        clientMsgId: 'mine-read',
        conversationId: 'conv-1',
        seqId: 3,
        senderId: 'user-rusdi',
        messageType: 'TEXT',
        bodyText: 'Sudah dibaca Risa',
        deliveryStatus: 'read',
        createdAt: now.add(const Duration(minutes: 3)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: Column(
                children: [
                  ChatMessageBubble(
                    message: peerMsg,
                    isMine: false,
                    showPeerAvatar: true,
                    peerAvatarInitial: 'Risa Hanipah',
                  ),
                  ChatMessageBubble(message: pendingMsg, isMine: true),
                  ChatMessageBubble(message: sentMsg, isMine: true),
                  ChatMessageBubble(message: readMsg, isMine: true),
                ],
              ),
            ),
          ),
        ),
      );

      final peerCenter =
          tester.getCenter(find.byKey(const ValueKey('bubble_box_peer-1')));
      final mineCenter =
          tester.getCenter(find.byKey(const ValueKey('bubble_box_mine-read')));
      expect(mineCenter.dx, greaterThan(peerCenter.dx));

      expect(find.byKey(const ValueKey('sending')), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.byKey(const ValueKey('sent')), findsOneWidget);
      expect(find.byKey(const ValueKey('read')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('bubble_box_peer-1')),
          matching: find.byType(MessageStatusTickIcon),
        ),
        findsNothing,
      );
    });
  });

  group('Auth Session Resolution & Room Screen Integration', () {
    test('AuthService & AuthRepositoryImpl resolve ID across legacy keys + JWT sub',
        () async {
      final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
      final payload = base64Url.encode(
        utf8.encode('{"sub":"11111111-2222-3333-4444-555555555555","username":"rusdi"}'),
      );
      final fakeJwt = '$header.$payload.sig';

      SharedPreferences.setMockInitialValues({
        'coffeehub_auth_jwt_token': fakeJwt,
        'coffeehub_auth_user_json': json.encode({
          'id': '',
          'username': 'rusdifn08',
          'full_name': 'Rusdi Barista',
          'role': 'user',
          'status': 'approved',
        }),
      });

      final fromService = await AuthService.getCurrentUser();
      expect(fromService?.id, '11111111-2222-3333-4444-555555555555');

      final repo = AuthRepositoryImpl(apiClient: _NoopRustApiClient());
      final fromRepo = await repo.getCurrentUser();
      expect(fromRepo?.id, '11111111-2222-3333-4444-555555555555');
    });

    test('reconcileLocalSenderId and monotonic watermarks never downgrade read status',
        () async {
      final db = ChatDriftDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await db.upsertConversationsFromServer([
        const ChatConversationDto(
          id: 'conv-r1',
          kind: 'DIRECT',
          title: 'Risa Hanipah',
        ),
      ]);

      final frame = ClientFrame.sendMessage(
        clientMsgId: 'loc-1',
        conversationId: 'conv-r1',
        messageType: ChatMessageType.text,
        bodyText: 'hi',
      );
      await db.insertOptimisticAndEnqueue(
        clientMsgId: 'loc-1',
        conversationId: 'conv-r1',
        senderId: 'local_barista',
        messageType: ChatMessageType.text,
        bodyText: 'hi',
        previewText: 'hi',
        wireFrameJson: frame.toWireJson(),
      );

      const realUuid = 'aaaa1111-2222-3333-4444-555555555555';
      await db.reconcileLocalSenderId(realUuid);
      final afterReconcile = await db.watchMessageViews('conv-r1').first;
      expect(afterReconcile.first.senderId, realUuid);

      await db.applySentAck(
        clientMsgId: 'loc-1',
        serverMsgId: 'srv-1',
        conversationId: 'conv-r1',
        seqId: 5,
        createdAt: DateTime.utc(2026, 11, 16, 8, 48),
      );
      await db.applyReceiptWatermark(
        conversationId: 'conv-r1',
        currentUserId: realUuid,
        actorUserId: 'peer-risa',
        status: ReceiptStatus.read,
        upToSeqId: 5,
      );

      // Simulate out-of-order replay with empty watermarks: must remain 'read'
      await db.upsertIncomingMessages(
        messages: [
          ChatMessageDto(
            id: 'srv-1',
            conversationId: 'conv-r1',
            seqId: 5,
            senderId: realUuid.toUpperCase(),
            clientMsgId: 'loc-1',
            messageType: ChatMessageType.text,
            bodyText: 'hi',
            createdAt: DateTime.utc(2026, 11, 16, 8, 48),
          ),
        ],
        currentUserId: realUuid,
        peerDeliveredWatermarks: const {},
        peerReadWatermarks: const {},
      );

      final rows = await db.watchMessageViews('conv-r1').first;
      expect(rows.length, 1);
      expect(ChatDriftDatabase.isSameSender(rows.first.senderId, realUuid), isTrue);
      expect(rows.first.deliveryStatus, 'read');
    });

    testWidgets('SocialCoffeeChatRoomScreen renders my messages on right & peer on left',
        (tester) async {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
      addTearDown(
        () => VisibilityDetectorController.instance.updateInterval =
            const Duration(milliseconds: 500),
      );

      const myUuid = 'aaaa1111-2222-3333-4444-555555555555';
      const peerUuid = 'bbbb1111-2222-3333-4444-555555555555';

      SharedPreferences.setMockInitialValues({
        'coffeehub_auth_user_json': json.encode({
          'id': myUuid,
          'username': 'rusdifn08',
          'full_name': 'Rusdi Barista',
          'role': 'user',
          'status': 'approved',
        }),
      });

      final db = ChatDriftDatabase(NativeDatabase.memory());

      await db.upsertConversationsFromServer([
        const ChatConversationDto(
          id: 'conv-room-1',
          kind: 'DIRECT',
          title: 'Risa Hanipah',
          peerUserId: peerUuid,
          peerOnline: true,
        ),
      ]);

      await db.upsertIncomingMessages(
        messages: [
          ChatMessageDto(
            id: 's1',
            conversationId: 'conv-room-1',
            seqId: 1,
            senderId: peerUuid,
            clientMsgId: 'c-peer',
            messageType: ChatMessageType.text,
            bodyText: 'hi juga',
            createdAt: DateTime.utc(2026, 11, 16, 8, 47),
          ),
          ChatMessageDto(
            id: 's2',
            conversationId: 'conv-room-1',
            seqId: 2,
            senderId: myUuid,
            clientMsgId: 'c-mine',
            messageType: ChatMessageType.text,
            bodyText: 'hi',
            createdAt: DateTime.utc(2026, 11, 16, 8, 48),
          ),
        ],
        currentUserId: myUuid,
        peerDeliveredWatermarks: const {'conv-room-1': 2},
        peerReadWatermarks: const {'conv-room-1': 2},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatDriftDatabaseProvider.overrideWithValue(db),
            chatWsServiceProvider.overrideWithValue(_FakeChatWsService()),
            localPushOrchestratorProvider.overrideWithValue(_FakePushOrchestrator()),
            deviceTokenLifecycleServiceProvider.overrideWithValue(_FakeTokenLifecycle()),
            activeChatRoomControllerProvider('conv-room-1').overrideWith(
              () => _FakeRoomController(),
            ),
          ],
          child: const MaterialApp(
            home: SocialCoffeeChatRoomScreen(conversationId: 'conv-room-1'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final peerRect =
          tester.getRect(find.byKey(const ValueKey('bubble_box_c-peer')));
      final mineRect =
          tester.getRect(find.byKey(const ValueKey('bubble_box_c-mine')));
      expect(mineRect.right, greaterThan(peerRect.right));
      expect(find.byKey(const ValueKey('read')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
      await db.close();
    });
  });
}

class _NoopRustApiClient implements RustApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakePushOrchestrator implements LocalPushOrchestrator {
  @override
  void setActiveChatRoomId(String? conversationId) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeTokenLifecycle implements DeviceTokenLifecycleService {
  @override
  Future<void> syncActiveChatRoom(String? conversationId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeChatWsService implements ChatWsService {
  @override
  WsConnectionState get currentState => WsConnectionState.connected;

  @override
  Stream<WsConnectionState> get connectionStateStream =>
      const Stream<WsConnectionState>.empty();

  @override
  Stream<ServerTypingIndicatorFrame> get typingStream =>
      const Stream<ServerTypingIndicatorFrame>.empty();

  @override
  Stream<ServerFrameErrorFrame> get errorStream =>
      const Stream<ServerFrameErrorFrame>.empty();

  @override
  Future<bool> setActiveRoom(String? conversationId) async => true;

  @override
  Future<void> connectIfAuthenticated() async {}

  @override
  Future<bool> sendFrame(ClientFrame frame) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeRoomController extends ActiveChatRoomController {
  @override
  Stream<List<LocalChatMessageView>> build(String conversationId) {
    final db = ref.watch(chatDriftDatabaseProvider);
    return db.watchMessageViews(conversationId);
  }
}
