import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/chat_protocol.dart';
import '../../domain/chat_view_models.dart';

part 'chat_drift_database.g.dart';

class LocalConversations extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text().withDefault(const Constant('DIRECT'))();
  TextColumn get title => text()();
  TextColumn get avatarUrl => text().nullable()();
  IntColumn get lastSeqId => integer().withDefault(const Constant(0))();
  IntColumn get localSyncedSeqId => integer().withDefault(const Constant(0))();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  IntColumn get myReadSeqId => integer().withDefault(const Constant(0))();
  TextColumn get peerUserId => text().nullable()();
  TextColumn get peerUsername => text().nullable()();
  BoolColumn get peerOnline => boolean().withDefault(const Constant(false))();
  DateTimeColumn get peerLastSeenAt => dateTime().nullable()();
  IntColumn get peerDeliveredSeqId => integer().withDefault(const Constant(0))();
  IntColumn get peerReadSeqId => integer().withDefault(const Constant(0))();
  TextColumn get lastMessagePreview => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMessages extends Table {
  TextColumn get clientMsgId => text()();
  TextColumn get serverMsgId => text().nullable()();
  TextColumn get conversationId => text()();
  IntColumn get seqId => integer().nullable()();
  TextColumn get senderId => text()();
  TextColumn get replyToMsgId => text().nullable()();
  TextColumn get messageType => text().withDefault(const Constant('TEXT'))();
  TextColumn get bodyText => text().nullable()();
  TextColumn get attachmentJson => text().nullable()();
  TextColumn get deliveryStatus => text().withDefault(const Constant('sending'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {clientMsgId};
}

class PendingOutboxQueue extends Table {
  TextColumn get clientMsgId => text()();
  TextColumn get conversationId => text()();
  TextColumn get framePayloadJson => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {clientMsgId};
}

@DriftDatabase(
  tables: [LocalConversations, LocalMessages, PendingOutboxQueue],
)
class ChatDriftDatabase extends _$ChatDriftDatabase {
  ChatDriftDatabase([QueryExecutor? executor]) : super(executor ?? _openNative());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openNative() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'coffee_labs_social_chat_v1.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _ensureIndexesAndFts5();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA journal_mode = WAL;');
          await _ensureIndexesAndFts5();
        },
      );

  Future<void> _ensureIndexesAndFts5() async {
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_local_msgs_conv_seq
      ON local_messages (conversation_id, seq_id DESC, created_at DESC);
    ''');

    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS local_messages_fts
      USING fts5(client_msg_id UNINDEXED, conversation_id UNINDEXED, searchable_text);
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_local_msgs_fts_insert
      AFTER INSERT ON local_messages
      BEGIN
        INSERT INTO local_messages_fts (client_msg_id, conversation_id, searchable_text)
        VALUES (
          NEW.client_msg_id,
          NEW.conversation_id,
          COALESCE(NEW.body_text, '') || ' ' || COALESCE(NEW.attachment_json, '')
        );
      END;
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_local_msgs_fts_update
      AFTER UPDATE OF body_text, attachment_json ON local_messages
      BEGIN
        DELETE FROM local_messages_fts WHERE client_msg_id = OLD.client_msg_id;
        INSERT INTO local_messages_fts (client_msg_id, conversation_id, searchable_text)
        VALUES (
          NEW.client_msg_id,
          NEW.conversation_id,
          COALESCE(NEW.body_text, '') || ' ' || COALESCE(NEW.attachment_json, '')
        );
      END;
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_local_msgs_fts_delete
      AFTER DELETE ON local_messages
      BEGIN
        DELETE FROM local_messages_fts WHERE client_msg_id = OLD.client_msg_id;
      END;
    ''');
  }

  Stream<List<LocalConversation>> watchConversations() {
    final fallbackEpoch = Constant<DateTime>(DateTime.fromMillisecondsSinceEpoch(0));
    return (select(localConversations)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: coalesce([t.lastMessageAt, fallbackEpoch]),
                  mode: OrderingMode.desc,
                ),
            (t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Stream<LocalConversation?> watchConversationById(String conversationId) {
    return (select(localConversations)..where((t) => t.id.equals(conversationId)))
        .watchSingleOrNull();
  }

  Stream<List<LocalMessage>> watchMessagesForConversation(String conversationId) {
    return customSelect(
      '''
      SELECT * FROM local_messages
      WHERE conversation_id = ?
      ORDER BY COALESCE(seq_id, 9223372036854775807) DESC, created_at DESC
      ''',
      variables: [Variable.withString(conversationId)],
      readsFrom: {localMessages},
    ).watch().map((rows) => rows.map((r) => localMessages.map(r.data)).toList());
  }

  Stream<List<ChatConversationView>> watchConversationViews() {
    return watchConversations().map(
      (list) => list.map(_toConversationView).toList(),
    );
  }

  Stream<ChatConversationView?> watchConversationViewById(String conversationId) {
    return watchConversationById(conversationId).map(
      (row) => row == null ? null : _toConversationView(row),
    );
  }

  Stream<List<LocalChatMessageView>> watchMessageViews(String conversationId) {
    return watchMessagesForConversation(conversationId).map(
      (list) => list.map(_toMessageView).toList(),
    );
  }

  Future<List<LocalChatMessageView>> searchMessagesFtsViews(String rawQuery) async {
    final rows = await searchMessagesFts(rawQuery);
    return rows.map(_toMessageView).toList();
  }

  ChatConversationView _toConversationView(LocalConversation c) =>
      ChatConversationView(
        id: c.id,
        kind: c.kind,
        title: c.title,
        avatarUrl: c.avatarUrl,
        lastSeqId: c.lastSeqId,
        localSyncedSeqId: c.localSyncedSeqId,
        unreadCount: c.unreadCount,
        myReadSeqId: c.myReadSeqId,
        peerUserId: c.peerUserId,
        peerUsername: c.peerUsername,
        peerOnline: c.peerOnline,
        peerLastSeenAt: c.peerLastSeenAt,
        peerDeliveredSeqId: c.peerDeliveredSeqId,
        peerReadSeqId: c.peerReadSeqId,
        lastMessagePreview: c.lastMessagePreview,
        lastMessageAt: c.lastMessageAt,
      );

  LocalChatMessageView _toMessageView(LocalMessage m) => LocalChatMessageView(
        clientMsgId: m.clientMsgId,
        serverMsgId: m.serverMsgId,
        conversationId: m.conversationId,
        seqId: m.seqId,
        senderId: m.senderId,
        replyToMsgId: m.replyToMsgId,
        messageType: m.messageType,
        bodyText: m.bodyText,
        attachmentJson: m.attachmentJson,
        deliveryStatus: m.deliveryStatus,
        createdAt: m.createdAt,
      );

  Future<List<LocalMessage>> searchMessagesFts(String rawQuery) async {
    final cleanTokens = rawQuery
        .replaceAll(RegExp(r'["*:\^()+-]'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .map((t) => '"$t"*')
        .join(' ');
    if (cleanTokens.isEmpty) return const [];

    final rows = await customSelect(
      '''
      SELECT m.*
      FROM local_messages_fts f
      INNER JOIN local_messages m ON m.client_msg_id = f.client_msg_id
      WHERE local_messages_fts MATCH ?
      ORDER BY m.created_at DESC
      LIMIT 40
      ''',
      variables: [Variable.withString(cleanTokens)],
      readsFrom: {localMessages},
    ).get();
    return rows.map((r) => localMessages.map(r.data)).toList();
  }

  Future<void> upsertConversationsFromServer(
    List<ChatConversationDto> items,
  ) async {
    await batch((b) {
      for (final item in items) {
        b.insert(
          localConversations,
          LocalConversationsCompanion.insert(
            id: item.id,
            kind: Value(item.kind),
            title: item.title,
            avatarUrl: Value(item.avatarUrl),
            lastSeqId: Value(item.lastSeqId),
            localSyncedSeqId: Value(item.lastSeqId),
            unreadCount: Value(item.unreadCount),
            myReadSeqId: Value(item.myReadSeqId),
            peerUserId: Value(item.peerUserId),
            peerUsername: Value(item.peerUsername),
            peerOnline: Value(item.peerOnline),
            peerLastSeenAt: Value(item.peerLastSeenAt),
            peerDeliveredSeqId: Value(item.peerDeliveredSeqId),
            peerReadSeqId: Value(item.peerReadSeqId),
            lastMessagePreview: Value(item.lastMessagePreview),
            lastMessageAt: Value(item.lastMessageAt),
          ),
          onConflict: DoUpdate(
            (old) => LocalConversationsCompanion(
              title: Value(item.title),
              avatarUrl: Value(item.avatarUrl),
              lastSeqId: Value(item.lastSeqId),
              unreadCount: Value(item.unreadCount),
              myReadSeqId: Value(item.myReadSeqId),
              peerOnline: Value(item.peerOnline),
              peerLastSeenAt: Value(item.peerLastSeenAt),
              peerDeliveredSeqId: Value(item.peerDeliveredSeqId),
              peerReadSeqId: Value(item.peerReadSeqId),
              lastMessagePreview: Value(item.lastMessagePreview),
              lastMessageAt: Value(item.lastMessageAt),
            ),
          ),
        );
      }
    });
  }

  Future<void> insertOptimisticAndEnqueue({
    required String clientMsgId,
    required String conversationId,
    required String senderId,
    required ChatMessageType messageType,
    String? bodyText,
    InteractiveAttachment? attachment,
    String? replyToMsgId,
    required String previewText,
    required Map<String, dynamic> wireFrameJson,
  }) async {
    final now = DateTime.now().toUtc();
    final attachmentJsonStr =
        attachment != null ? json.encode(attachment.toJson()) : null;

    await transaction(() async {
      await into(localMessages).insertOnConflictUpdate(
        LocalMessagesCompanion.insert(
          clientMsgId: clientMsgId,
          conversationId: conversationId,
          senderId: senderId,
          replyToMsgId: Value(replyToMsgId),
          messageType: Value(messageType.wireValue),
          bodyText: Value(bodyText),
          attachmentJson: Value(attachmentJsonStr),
          deliveryStatus: const Value('sending'),
          createdAt: now,
        ),
      );

      await into(pendingOutboxQueue).insertOnConflictUpdate(
        PendingOutboxQueueCompanion.insert(
          clientMsgId: clientMsgId,
          conversationId: conversationId,
          framePayloadJson: json.encode(wireFrameJson),
          createdAt: now,
        ),
      );

      await (update(localConversations)
            ..where((c) => c.id.equals(conversationId)))
          .write(
        LocalConversationsCompanion(
          lastMessagePreview: Value(previewText),
          lastMessageAt: Value(now),
        ),
      );
    });
  }

  static bool isSameSender(String a, String b) {
    final left = a.trim().toLowerCase();
    final right = b.trim().toLowerCase();
    return left.isNotEmpty && left == right;
  }

  static int _statusRank(String status) {
    return switch (status) {
      'sending' => 0,
      'failed' => 0,
      'sent' => 1,
      'delivered' => 2,
      'read' => 3,
      _ => 1,
    };
  }

  static String _pickMonotonicStatus(String? existingStatus, String candidate) {
    if (existingStatus == null || existingStatus.isEmpty) return candidate;
    return _statusRank(existingStatus) >= _statusRank(candidate)
        ? existingStatus
        : candidate;
  }

  /// Memperbaiki `sender_id = 'local_barista'` historis ke UUID pengguna resmi agar bubble kanan/kiri akurat.
  Future<void> reconcileLocalSenderId(String realUserId) async {
    final clean = realUserId.trim();
    if (clean.isEmpty || clean == 'local_barista') return;
    await customStatement(
      '''
      UPDATE local_messages
      SET sender_id = ?
      WHERE sender_id = 'local_barista'
      ''',
      [clean],
    );
  }

  Future<String?> getMessageDeliveryStatus(String clientMsgId) async {
    final row = await (select(localMessages)
          ..where((m) => m.clientMsgId.equals(clientMsgId)))
        .getSingleOrNull();
    return row?.deliveryStatus;
  }

  Future<void> applySentAck({
    required String clientMsgId,
    required String serverMsgId,
    required String conversationId,
    required int seqId,
    required DateTime createdAt,
  }) async {
    await transaction(() async {
      await (delete(pendingOutboxQueue)
            ..where((q) => q.clientMsgId.equals(clientMsgId)))
          .go();

      final existing = await (select(localMessages)
            ..where((m) => m.clientMsgId.equals(clientMsgId)))
          .getSingleOrNull();
      final nextStatus = _pickMonotonicStatus(existing?.deliveryStatus, 'sent');

      await (update(localMessages)
            ..where((m) => m.clientMsgId.equals(clientMsgId)))
          .write(
        LocalMessagesCompanion(
          serverMsgId: Value(serverMsgId),
          seqId: Value(seqId),
          deliveryStatus: Value(nextStatus),
          createdAt: Value(createdAt),
        ),
      );

      await customStatement(
        '''
        UPDATE local_conversations
        SET last_seq_id = MAX(last_seq_id, ?),
            local_synced_seq_id = MAX(local_synced_seq_id, ?),
            my_read_seq_id = MAX(my_read_seq_id, ?)
        WHERE id = ?
        ''',
        [seqId, seqId, seqId, conversationId],
      );
    });
  }

  Future<void> markOutboxFailed(String clientMsgId) async {
    await transaction(() async {
      await (update(pendingOutboxQueue)
            ..where((q) => q.clientMsgId.equals(clientMsgId)))
          .write(
        PendingOutboxQueueCompanion.custom(
          retryCount: pendingOutboxQueue.retryCount + const Constant(1),
          lastAttemptAt: Constant(DateTime.now().toUtc()),
        ),
      );
      await (update(localMessages)
            ..where((m) =>
                m.clientMsgId.equals(clientMsgId) &
                m.deliveryStatus.equals('sending')))
          .write(const LocalMessagesCompanion(deliveryStatus: Value('failed')));
    });
  }

  Future<void> retryOutboxEntry(String clientMsgId) async {
    await (update(localMessages)..where((m) => m.clientMsgId.equals(clientMsgId)))
        .write(const LocalMessagesCompanion(deliveryStatus: Value('sending')));
  }

  Future<void> upsertIncomingMessages({
    required List<ChatMessageDto> messages,
    required String currentUserId,
    required Map<String, int> peerDeliveredWatermarks,
    required Map<String, int> peerReadWatermarks,
  }) async {
    if (messages.isEmpty &&
        peerDeliveredWatermarks.isEmpty &&
        peerReadWatermarks.isEmpty) {
      return;
    }

    await transaction(() async {
      final convIdsToUpdate = <String>{
        ...peerDeliveredWatermarks.keys,
        ...peerReadWatermarks.keys,
      };
      for (final convId in convIdsToUpdate) {
        final delSeq = peerDeliveredWatermarks[convId] ?? 0;
        final readSeq = peerReadWatermarks[convId] ?? 0;
        await customStatement(
          '''
          UPDATE local_conversations
          SET peer_delivered_seq_id = MAX(peer_delivered_seq_id, ?),
              peer_read_seq_id = MAX(peer_read_seq_id, ?)
          WHERE id = ?
          ''',
          [delSeq > readSeq ? delSeq : readSeq, readSeq, convId],
        );
      }

      if (messages.isEmpty) return;

      final clientIds = messages.map((m) => m.clientMsgId).toList();
      final existingRows = await (select(localMessages)
            ..where((m) => m.clientMsgId.isIn(clientIds)))
          .get();
      final existingByClientId = {
        for (final row in existingRows) row.clientMsgId: row,
      };

      final convWatermarksRows = await (select(localConversations)
            ..where((c) => c.id.isIn(messages.map((m) => m.conversationId).toSet())))
          .get();
      final convById = {for (final c in convWatermarksRows) c.id: c};

      for (final msg in messages) {
        await (delete(pendingOutboxQueue)
              ..where((q) => q.clientMsgId.equals(msg.clientMsgId)))
            .go();

        final convRow = convById[msg.conversationId];
        final incomingRead = peerReadWatermarks[msg.conversationId] ?? 0;
        final incomingDel = peerDeliveredWatermarks[msg.conversationId] ?? 0;
        final peerRead = incomingRead > (convRow?.peerReadSeqId ?? 0)
            ? incomingRead
            : (convRow?.peerReadSeqId ?? 0);
        final peerDelivered = incomingDel > (convRow?.peerDeliveredSeqId ?? 0)
            ? incomingDel
            : (convRow?.peerDeliveredSeqId ?? 0);

        String candidateStatus = 'sent';
        if (isSameSender(msg.senderId, currentUserId)) {
          if (msg.seqId <= peerRead && peerRead > 0) {
            candidateStatus = 'read';
          } else if (msg.seqId <= peerDelivered && peerDelivered > 0) {
            candidateStatus = 'delivered';
          }
        } else {
          candidateStatus = 'delivered';
        }

        final existing = existingByClientId[msg.clientMsgId];
        final statusStr =
            _pickMonotonicStatus(existing?.deliveryStatus, candidateStatus);

        final attachStr = msg.attachment != null
            ? json.encode(msg.attachment!.toJson())
            : null;
        final preview = _previewFromDto(msg);

        await into(localMessages).insertOnConflictUpdate(
          LocalMessagesCompanion.insert(
            clientMsgId: msg.clientMsgId,
            serverMsgId: Value(msg.id),
            conversationId: msg.conversationId,
            seqId: Value(msg.seqId),
            senderId: msg.senderId,
            replyToMsgId: Value(msg.replyToMsgId),
            messageType: Value(msg.messageType.wireValue),
            bodyText: Value(msg.bodyText),
            attachmentJson: Value(attachStr),
            deliveryStatus: Value(statusStr),
            createdAt: msg.createdAt,
          ),
        );

        await customStatement(
          '''
          UPDATE local_conversations
          SET last_seq_id = MAX(last_seq_id, ?),
              local_synced_seq_id = MAX(local_synced_seq_id, ?),
              unread_count = CASE
                WHEN LOWER(?) <> LOWER(?) AND ? > my_read_seq_id THEN MAX(0, MAX(last_seq_id, ?) - my_read_seq_id)
                ELSE unread_count
              END
          WHERE id = ?
          ''',
          [
            msg.seqId,
            msg.seqId,
            msg.senderId,
            currentUserId,
            msg.seqId,
            msg.seqId,
            msg.conversationId,
          ],
        );

        await (update(localConversations)
              ..where((c) => c.id.equals(msg.conversationId)))
            .write(
          LocalConversationsCompanion(
            lastMessagePreview: Value(preview),
            lastMessageAt: Value(msg.createdAt),
          ),
        );
      }

      if (currentUserId.isNotEmpty) {
        for (final convId in convIdsToUpdate) {
          final readSeq = peerReadWatermarks[convId] ?? 0;
          final delSeq = peerDeliveredWatermarks[convId] ?? 0;
          if (readSeq > 0) {
            await customStatement(
              '''
              UPDATE local_messages
              SET delivery_status = 'read'
              WHERE conversation_id = ? AND LOWER(sender_id) = LOWER(?)
                AND seq_id IS NOT NULL AND seq_id <= ?
              ''',
              [convId, currentUserId, readSeq],
            );
          }
          if (delSeq > 0) {
            await customStatement(
              '''
              UPDATE local_messages
              SET delivery_status = 'delivered'
              WHERE conversation_id = ? AND LOWER(sender_id) = LOWER(?)
                AND seq_id IS NOT NULL AND seq_id <= ?
                AND delivery_status IN ('sending', 'failed', 'sent')
              ''',
              [convId, currentUserId, delSeq],
            );
          }
        }
      }
    });
  }

  Future<void> applyReceiptWatermark({
    required String conversationId,
    required String currentUserId,
    required String actorUserId,
    required ReceiptStatus status,
    required int upToSeqId,
  }) async {
    if (isSameSender(actorUserId, currentUserId)) {
      if (status == ReceiptStatus.read) {
        await customStatement(
          '''
          UPDATE local_conversations
          SET my_read_seq_id = MAX(my_read_seq_id, ?),
              unread_count = MAX(0, last_seq_id - MAX(my_read_seq_id, ?))
          WHERE id = ?
          ''',
          [upToSeqId, upToSeqId, conversationId],
        );
      }
      return;
    }

    await transaction(() async {
      if (status == ReceiptStatus.read) {
        await customStatement(
          '''
          UPDATE local_conversations
          SET peer_read_seq_id = MAX(peer_read_seq_id, ?),
              peer_delivered_seq_id = MAX(peer_delivered_seq_id, ?)
          WHERE id = ?
          ''',
          [upToSeqId, upToSeqId, conversationId],
        );
        await customStatement(
          '''
          UPDATE local_messages
          SET delivery_status = 'read'
          WHERE conversation_id = ? AND LOWER(sender_id) = LOWER(?) AND seq_id IS NOT NULL AND seq_id <= ?
          ''',
          [conversationId, currentUserId, upToSeqId],
        );
      } else if (status == ReceiptStatus.delivered) {
        await customStatement(
          '''
          UPDATE local_conversations
          SET peer_delivered_seq_id = MAX(peer_delivered_seq_id, ?)
          WHERE id = ?
          ''',
          [upToSeqId, conversationId],
        );
        await customStatement(
          '''
          UPDATE local_messages
          SET delivery_status = 'delivered'
          WHERE conversation_id = ? AND LOWER(sender_id) = LOWER(?)
            AND seq_id IS NOT NULL AND seq_id <= ?
            AND delivery_status IN ('sending', 'failed', 'sent')
          ''',
          [conversationId, currentUserId, upToSeqId],
        );
      }
    });
  }

  Future<int> getLatestSeqForConversation(String conversationId) async {
    final row = await (select(localConversations)
          ..where((c) => c.id.equals(conversationId)))
        .getSingleOrNull();
    return row?.lastSeqId ?? 0;
  }

  Future<void> markLocalRoomReadUpTo(String conversationId, int seqId) async {
    await customStatement(
      '''
      UPDATE local_conversations
      SET my_read_seq_id = MAX(my_read_seq_id, ?),
          unread_count = MAX(0, last_seq_id - MAX(my_read_seq_id, ?))
      WHERE id = ?
      ''',
      [seqId, seqId, conversationId],
    );
  }

  Future<void> updatePeerPresence(
    String userId,
    bool isOnline,
    DateTime? lastSeenAt,
  ) async {
    await (update(localConversations)..where((c) => c.peerUserId.equals(userId)))
        .write(
      LocalConversationsCompanion(
        peerOnline: Value(isOnline),
        peerLastSeenAt: Value(lastSeenAt),
      ),
    );
  }

  Future<List<PendingOutboxQueueData>> getOutboxFifo() {
    return (select(pendingOutboxQueue)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<List<ConversationCursorDto>> getSyncCursors() async {
    final rows = await select(localConversations).get();
    return rows
        .map((r) => ConversationCursorDto(
              conversationId: r.id,
              localMaxSeqId: r.localSyncedSeqId,
            ))
        .toList();
  }

  /// Menghapus seluruh cache percakapan, pesan, outbox, dan indeks FTS5 milik akun sebelumnya
  /// agar tidak pernah bocor ke akun baru saat pergantian sesi di perangkat yang sama.
  Future<void> clearAllUserData() async {
    await transaction(() async {
      await delete(pendingOutboxQueue).go();
      await delete(localMessages).go();
      await delete(localConversations).go();
      await customStatement('DELETE FROM local_messages_fts;');
    });
  }

  static String _previewFromDto(ChatMessageDto msg) {
    final att = msg.attachment;
    if (att is V60RecipeCardAttachment) return '☕ Resep: ${att.title}';
    if (att is CoffeeBeanCardAttachment) {
      return '🫘 Biji: ${att.beanName} (${att.roastery})';
    }
    if (att is BrewImageMediaAttachment) {
      return att.caption?.isNotEmpty == true ? att.caption! : '📷 Foto seduhan';
    }
    if (att is BrewSessionResultAttachment) {
      return '🏆 Seduh ${att.title}: ${att.accuracyScore}%';
    }
    return msg.bodyText ?? '';
  }
}
