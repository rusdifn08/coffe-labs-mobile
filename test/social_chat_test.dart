import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_hub_mobile/features/social_chat/data/local/chat_drift_database.dart';
import 'package:coffee_hub_mobile/features/social_chat/domain/chat_protocol.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/widgets/interactive_bean_chat_bubble.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/widgets/interactive_recipe_chat_bubble.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/widgets/message_status_tick_icon.dart';

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
  });
}
