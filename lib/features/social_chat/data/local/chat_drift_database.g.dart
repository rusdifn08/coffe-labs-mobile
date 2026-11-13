// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_drift_database.dart';

// ignore_for_file: type=lint
class $LocalConversationsTable extends LocalConversations
    with TableInfo<$LocalConversationsTable, LocalConversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DIRECT'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeqIdMeta = const VerificationMeta(
    'lastSeqId',
  );
  @override
  late final GeneratedColumn<int> lastSeqId = GeneratedColumn<int>(
    'last_seq_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localSyncedSeqIdMeta = const VerificationMeta(
    'localSyncedSeqId',
  );
  @override
  late final GeneratedColumn<int> localSyncedSeqId = GeneratedColumn<int>(
    'local_synced_seq_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _myReadSeqIdMeta = const VerificationMeta(
    'myReadSeqId',
  );
  @override
  late final GeneratedColumn<int> myReadSeqId = GeneratedColumn<int>(
    'my_read_seq_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _peerUserIdMeta = const VerificationMeta(
    'peerUserId',
  );
  @override
  late final GeneratedColumn<String> peerUserId = GeneratedColumn<String>(
    'peer_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peerUsernameMeta = const VerificationMeta(
    'peerUsername',
  );
  @override
  late final GeneratedColumn<String> peerUsername = GeneratedColumn<String>(
    'peer_username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peerOnlineMeta = const VerificationMeta(
    'peerOnline',
  );
  @override
  late final GeneratedColumn<bool> peerOnline = GeneratedColumn<bool>(
    'peer_online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("peer_online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _peerLastSeenAtMeta = const VerificationMeta(
    'peerLastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> peerLastSeenAt =
      GeneratedColumn<DateTime>(
        'peer_last_seen_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _peerDeliveredSeqIdMeta =
      const VerificationMeta('peerDeliveredSeqId');
  @override
  late final GeneratedColumn<int> peerDeliveredSeqId = GeneratedColumn<int>(
    'peer_delivered_seq_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _peerReadSeqIdMeta = const VerificationMeta(
    'peerReadSeqId',
  );
  @override
  late final GeneratedColumn<int> peerReadSeqId = GeneratedColumn<int>(
    'peer_read_seq_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastMessagePreviewMeta =
      const VerificationMeta('lastMessagePreview');
  @override
  late final GeneratedColumn<String> lastMessagePreview =
      GeneratedColumn<String>(
        'last_message_preview',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>(
        'last_message_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    title,
    avatarUrl,
    lastSeqId,
    localSyncedSeqId,
    unreadCount,
    myReadSeqId,
    peerUserId,
    peerUsername,
    peerOnline,
    peerLastSeenAt,
    peerDeliveredSeqId,
    peerReadSeqId,
    lastMessagePreview,
    lastMessageAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalConversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('last_seq_id')) {
      context.handle(
        _lastSeqIdMeta,
        lastSeqId.isAcceptableOrUnknown(data['last_seq_id']!, _lastSeqIdMeta),
      );
    }
    if (data.containsKey('local_synced_seq_id')) {
      context.handle(
        _localSyncedSeqIdMeta,
        localSyncedSeqId.isAcceptableOrUnknown(
          data['local_synced_seq_id']!,
          _localSyncedSeqIdMeta,
        ),
      );
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('my_read_seq_id')) {
      context.handle(
        _myReadSeqIdMeta,
        myReadSeqId.isAcceptableOrUnknown(
          data['my_read_seq_id']!,
          _myReadSeqIdMeta,
        ),
      );
    }
    if (data.containsKey('peer_user_id')) {
      context.handle(
        _peerUserIdMeta,
        peerUserId.isAcceptableOrUnknown(
          data['peer_user_id']!,
          _peerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('peer_username')) {
      context.handle(
        _peerUsernameMeta,
        peerUsername.isAcceptableOrUnknown(
          data['peer_username']!,
          _peerUsernameMeta,
        ),
      );
    }
    if (data.containsKey('peer_online')) {
      context.handle(
        _peerOnlineMeta,
        peerOnline.isAcceptableOrUnknown(data['peer_online']!, _peerOnlineMeta),
      );
    }
    if (data.containsKey('peer_last_seen_at')) {
      context.handle(
        _peerLastSeenAtMeta,
        peerLastSeenAt.isAcceptableOrUnknown(
          data['peer_last_seen_at']!,
          _peerLastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('peer_delivered_seq_id')) {
      context.handle(
        _peerDeliveredSeqIdMeta,
        peerDeliveredSeqId.isAcceptableOrUnknown(
          data['peer_delivered_seq_id']!,
          _peerDeliveredSeqIdMeta,
        ),
      );
    }
    if (data.containsKey('peer_read_seq_id')) {
      context.handle(
        _peerReadSeqIdMeta,
        peerReadSeqId.isAcceptableOrUnknown(
          data['peer_read_seq_id']!,
          _peerReadSeqIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_preview')) {
      context.handle(
        _lastMessagePreviewMeta,
        lastMessagePreview.isAcceptableOrUnknown(
          data['last_message_preview']!,
          _lastMessagePreviewMeta,
        ),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalConversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalConversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      lastSeqId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seq_id'],
      )!,
      localSyncedSeqId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_synced_seq_id'],
      )!,
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      myReadSeqId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}my_read_seq_id'],
      )!,
      peerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_user_id'],
      ),
      peerUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_username'],
      ),
      peerOnline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}peer_online'],
      )!,
      peerLastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}peer_last_seen_at'],
      ),
      peerDeliveredSeqId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peer_delivered_seq_id'],
      )!,
      peerReadSeqId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peer_read_seq_id'],
      )!,
      lastMessagePreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_preview'],
      ),
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_at'],
      ),
    );
  }

  @override
  $LocalConversationsTable createAlias(String alias) {
    return $LocalConversationsTable(attachedDatabase, alias);
  }
}

class LocalConversation extends DataClass
    implements Insertable<LocalConversation> {
  final String id;
  final String kind;
  final String title;
  final String? avatarUrl;
  final int lastSeqId;
  final int localSyncedSeqId;
  final int unreadCount;
  final int myReadSeqId;
  final String? peerUserId;
  final String? peerUsername;
  final bool peerOnline;
  final DateTime? peerLastSeenAt;
  final int peerDeliveredSeqId;
  final int peerReadSeqId;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  const LocalConversation({
    required this.id,
    required this.kind,
    required this.title,
    this.avatarUrl,
    required this.lastSeqId,
    required this.localSyncedSeqId,
    required this.unreadCount,
    required this.myReadSeqId,
    this.peerUserId,
    this.peerUsername,
    required this.peerOnline,
    this.peerLastSeenAt,
    required this.peerDeliveredSeqId,
    required this.peerReadSeqId,
    this.lastMessagePreview,
    this.lastMessageAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['last_seq_id'] = Variable<int>(lastSeqId);
    map['local_synced_seq_id'] = Variable<int>(localSyncedSeqId);
    map['unread_count'] = Variable<int>(unreadCount);
    map['my_read_seq_id'] = Variable<int>(myReadSeqId);
    if (!nullToAbsent || peerUserId != null) {
      map['peer_user_id'] = Variable<String>(peerUserId);
    }
    if (!nullToAbsent || peerUsername != null) {
      map['peer_username'] = Variable<String>(peerUsername);
    }
    map['peer_online'] = Variable<bool>(peerOnline);
    if (!nullToAbsent || peerLastSeenAt != null) {
      map['peer_last_seen_at'] = Variable<DateTime>(peerLastSeenAt);
    }
    map['peer_delivered_seq_id'] = Variable<int>(peerDeliveredSeqId);
    map['peer_read_seq_id'] = Variable<int>(peerReadSeqId);
    if (!nullToAbsent || lastMessagePreview != null) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview);
    }
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    return map;
  }

  LocalConversationsCompanion toCompanion(bool nullToAbsent) {
    return LocalConversationsCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      lastSeqId: Value(lastSeqId),
      localSyncedSeqId: Value(localSyncedSeqId),
      unreadCount: Value(unreadCount),
      myReadSeqId: Value(myReadSeqId),
      peerUserId: peerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(peerUserId),
      peerUsername: peerUsername == null && nullToAbsent
          ? const Value.absent()
          : Value(peerUsername),
      peerOnline: Value(peerOnline),
      peerLastSeenAt: peerLastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(peerLastSeenAt),
      peerDeliveredSeqId: Value(peerDeliveredSeqId),
      peerReadSeqId: Value(peerReadSeqId),
      lastMessagePreview: lastMessagePreview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessagePreview),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
    );
  }

  factory LocalConversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalConversation(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      lastSeqId: serializer.fromJson<int>(json['lastSeqId']),
      localSyncedSeqId: serializer.fromJson<int>(json['localSyncedSeqId']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      myReadSeqId: serializer.fromJson<int>(json['myReadSeqId']),
      peerUserId: serializer.fromJson<String?>(json['peerUserId']),
      peerUsername: serializer.fromJson<String?>(json['peerUsername']),
      peerOnline: serializer.fromJson<bool>(json['peerOnline']),
      peerLastSeenAt: serializer.fromJson<DateTime?>(json['peerLastSeenAt']),
      peerDeliveredSeqId: serializer.fromJson<int>(json['peerDeliveredSeqId']),
      peerReadSeqId: serializer.fromJson<int>(json['peerReadSeqId']),
      lastMessagePreview: serializer.fromJson<String?>(
        json['lastMessagePreview'],
      ),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'lastSeqId': serializer.toJson<int>(lastSeqId),
      'localSyncedSeqId': serializer.toJson<int>(localSyncedSeqId),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'myReadSeqId': serializer.toJson<int>(myReadSeqId),
      'peerUserId': serializer.toJson<String?>(peerUserId),
      'peerUsername': serializer.toJson<String?>(peerUsername),
      'peerOnline': serializer.toJson<bool>(peerOnline),
      'peerLastSeenAt': serializer.toJson<DateTime?>(peerLastSeenAt),
      'peerDeliveredSeqId': serializer.toJson<int>(peerDeliveredSeqId),
      'peerReadSeqId': serializer.toJson<int>(peerReadSeqId),
      'lastMessagePreview': serializer.toJson<String?>(lastMessagePreview),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
    };
  }

  LocalConversation copyWith({
    String? id,
    String? kind,
    String? title,
    Value<String?> avatarUrl = const Value.absent(),
    int? lastSeqId,
    int? localSyncedSeqId,
    int? unreadCount,
    int? myReadSeqId,
    Value<String?> peerUserId = const Value.absent(),
    Value<String?> peerUsername = const Value.absent(),
    bool? peerOnline,
    Value<DateTime?> peerLastSeenAt = const Value.absent(),
    int? peerDeliveredSeqId,
    int? peerReadSeqId,
    Value<String?> lastMessagePreview = const Value.absent(),
    Value<DateTime?> lastMessageAt = const Value.absent(),
  }) => LocalConversation(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    lastSeqId: lastSeqId ?? this.lastSeqId,
    localSyncedSeqId: localSyncedSeqId ?? this.localSyncedSeqId,
    unreadCount: unreadCount ?? this.unreadCount,
    myReadSeqId: myReadSeqId ?? this.myReadSeqId,
    peerUserId: peerUserId.present ? peerUserId.value : this.peerUserId,
    peerUsername: peerUsername.present ? peerUsername.value : this.peerUsername,
    peerOnline: peerOnline ?? this.peerOnline,
    peerLastSeenAt: peerLastSeenAt.present
        ? peerLastSeenAt.value
        : this.peerLastSeenAt,
    peerDeliveredSeqId: peerDeliveredSeqId ?? this.peerDeliveredSeqId,
    peerReadSeqId: peerReadSeqId ?? this.peerReadSeqId,
    lastMessagePreview: lastMessagePreview.present
        ? lastMessagePreview.value
        : this.lastMessagePreview,
    lastMessageAt: lastMessageAt.present
        ? lastMessageAt.value
        : this.lastMessageAt,
  );
  LocalConversation copyWithCompanion(LocalConversationsCompanion data) {
    return LocalConversation(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      lastSeqId: data.lastSeqId.present ? data.lastSeqId.value : this.lastSeqId,
      localSyncedSeqId: data.localSyncedSeqId.present
          ? data.localSyncedSeqId.value
          : this.localSyncedSeqId,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      myReadSeqId: data.myReadSeqId.present
          ? data.myReadSeqId.value
          : this.myReadSeqId,
      peerUserId: data.peerUserId.present
          ? data.peerUserId.value
          : this.peerUserId,
      peerUsername: data.peerUsername.present
          ? data.peerUsername.value
          : this.peerUsername,
      peerOnline: data.peerOnline.present
          ? data.peerOnline.value
          : this.peerOnline,
      peerLastSeenAt: data.peerLastSeenAt.present
          ? data.peerLastSeenAt.value
          : this.peerLastSeenAt,
      peerDeliveredSeqId: data.peerDeliveredSeqId.present
          ? data.peerDeliveredSeqId.value
          : this.peerDeliveredSeqId,
      peerReadSeqId: data.peerReadSeqId.present
          ? data.peerReadSeqId.value
          : this.peerReadSeqId,
      lastMessagePreview: data.lastMessagePreview.present
          ? data.lastMessagePreview.value
          : this.lastMessagePreview,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalConversation(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastSeqId: $lastSeqId, ')
          ..write('localSyncedSeqId: $localSyncedSeqId, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('myReadSeqId: $myReadSeqId, ')
          ..write('peerUserId: $peerUserId, ')
          ..write('peerUsername: $peerUsername, ')
          ..write('peerOnline: $peerOnline, ')
          ..write('peerLastSeenAt: $peerLastSeenAt, ')
          ..write('peerDeliveredSeqId: $peerDeliveredSeqId, ')
          ..write('peerReadSeqId: $peerReadSeqId, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('lastMessageAt: $lastMessageAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    title,
    avatarUrl,
    lastSeqId,
    localSyncedSeqId,
    unreadCount,
    myReadSeqId,
    peerUserId,
    peerUsername,
    peerOnline,
    peerLastSeenAt,
    peerDeliveredSeqId,
    peerReadSeqId,
    lastMessagePreview,
    lastMessageAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalConversation &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.avatarUrl == this.avatarUrl &&
          other.lastSeqId == this.lastSeqId &&
          other.localSyncedSeqId == this.localSyncedSeqId &&
          other.unreadCount == this.unreadCount &&
          other.myReadSeqId == this.myReadSeqId &&
          other.peerUserId == this.peerUserId &&
          other.peerUsername == this.peerUsername &&
          other.peerOnline == this.peerOnline &&
          other.peerLastSeenAt == this.peerLastSeenAt &&
          other.peerDeliveredSeqId == this.peerDeliveredSeqId &&
          other.peerReadSeqId == this.peerReadSeqId &&
          other.lastMessagePreview == this.lastMessagePreview &&
          other.lastMessageAt == this.lastMessageAt);
}

class LocalConversationsCompanion extends UpdateCompanion<LocalConversation> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String?> avatarUrl;
  final Value<int> lastSeqId;
  final Value<int> localSyncedSeqId;
  final Value<int> unreadCount;
  final Value<int> myReadSeqId;
  final Value<String?> peerUserId;
  final Value<String?> peerUsername;
  final Value<bool> peerOnline;
  final Value<DateTime?> peerLastSeenAt;
  final Value<int> peerDeliveredSeqId;
  final Value<int> peerReadSeqId;
  final Value<String?> lastMessagePreview;
  final Value<DateTime?> lastMessageAt;
  final Value<int> rowid;
  const LocalConversationsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.lastSeqId = const Value.absent(),
    this.localSyncedSeqId = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.myReadSeqId = const Value.absent(),
    this.peerUserId = const Value.absent(),
    this.peerUsername = const Value.absent(),
    this.peerOnline = const Value.absent(),
    this.peerLastSeenAt = const Value.absent(),
    this.peerDeliveredSeqId = const Value.absent(),
    this.peerReadSeqId = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalConversationsCompanion.insert({
    required String id,
    this.kind = const Value.absent(),
    required String title,
    this.avatarUrl = const Value.absent(),
    this.lastSeqId = const Value.absent(),
    this.localSyncedSeqId = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.myReadSeqId = const Value.absent(),
    this.peerUserId = const Value.absent(),
    this.peerUsername = const Value.absent(),
    this.peerOnline = const Value.absent(),
    this.peerLastSeenAt = const Value.absent(),
    this.peerDeliveredSeqId = const Value.absent(),
    this.peerReadSeqId = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<LocalConversation> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? avatarUrl,
    Expression<int>? lastSeqId,
    Expression<int>? localSyncedSeqId,
    Expression<int>? unreadCount,
    Expression<int>? myReadSeqId,
    Expression<String>? peerUserId,
    Expression<String>? peerUsername,
    Expression<bool>? peerOnline,
    Expression<DateTime>? peerLastSeenAt,
    Expression<int>? peerDeliveredSeqId,
    Expression<int>? peerReadSeqId,
    Expression<String>? lastMessagePreview,
    Expression<DateTime>? lastMessageAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (lastSeqId != null) 'last_seq_id': lastSeqId,
      if (localSyncedSeqId != null) 'local_synced_seq_id': localSyncedSeqId,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (myReadSeqId != null) 'my_read_seq_id': myReadSeqId,
      if (peerUserId != null) 'peer_user_id': peerUserId,
      if (peerUsername != null) 'peer_username': peerUsername,
      if (peerOnline != null) 'peer_online': peerOnline,
      if (peerLastSeenAt != null) 'peer_last_seen_at': peerLastSeenAt,
      if (peerDeliveredSeqId != null)
        'peer_delivered_seq_id': peerDeliveredSeqId,
      if (peerReadSeqId != null) 'peer_read_seq_id': peerReadSeqId,
      if (lastMessagePreview != null)
        'last_message_preview': lastMessagePreview,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? title,
    Value<String?>? avatarUrl,
    Value<int>? lastSeqId,
    Value<int>? localSyncedSeqId,
    Value<int>? unreadCount,
    Value<int>? myReadSeqId,
    Value<String?>? peerUserId,
    Value<String?>? peerUsername,
    Value<bool>? peerOnline,
    Value<DateTime?>? peerLastSeenAt,
    Value<int>? peerDeliveredSeqId,
    Value<int>? peerReadSeqId,
    Value<String?>? lastMessagePreview,
    Value<DateTime?>? lastMessageAt,
    Value<int>? rowid,
  }) {
    return LocalConversationsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastSeqId: lastSeqId ?? this.lastSeqId,
      localSyncedSeqId: localSyncedSeqId ?? this.localSyncedSeqId,
      unreadCount: unreadCount ?? this.unreadCount,
      myReadSeqId: myReadSeqId ?? this.myReadSeqId,
      peerUserId: peerUserId ?? this.peerUserId,
      peerUsername: peerUsername ?? this.peerUsername,
      peerOnline: peerOnline ?? this.peerOnline,
      peerLastSeenAt: peerLastSeenAt ?? this.peerLastSeenAt,
      peerDeliveredSeqId: peerDeliveredSeqId ?? this.peerDeliveredSeqId,
      peerReadSeqId: peerReadSeqId ?? this.peerReadSeqId,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (lastSeqId.present) {
      map['last_seq_id'] = Variable<int>(lastSeqId.value);
    }
    if (localSyncedSeqId.present) {
      map['local_synced_seq_id'] = Variable<int>(localSyncedSeqId.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (myReadSeqId.present) {
      map['my_read_seq_id'] = Variable<int>(myReadSeqId.value);
    }
    if (peerUserId.present) {
      map['peer_user_id'] = Variable<String>(peerUserId.value);
    }
    if (peerUsername.present) {
      map['peer_username'] = Variable<String>(peerUsername.value);
    }
    if (peerOnline.present) {
      map['peer_online'] = Variable<bool>(peerOnline.value);
    }
    if (peerLastSeenAt.present) {
      map['peer_last_seen_at'] = Variable<DateTime>(peerLastSeenAt.value);
    }
    if (peerDeliveredSeqId.present) {
      map['peer_delivered_seq_id'] = Variable<int>(peerDeliveredSeqId.value);
    }
    if (peerReadSeqId.present) {
      map['peer_read_seq_id'] = Variable<int>(peerReadSeqId.value);
    }
    if (lastMessagePreview.present) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConversationsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastSeqId: $lastSeqId, ')
          ..write('localSyncedSeqId: $localSyncedSeqId, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('myReadSeqId: $myReadSeqId, ')
          ..write('peerUserId: $peerUserId, ')
          ..write('peerUsername: $peerUsername, ')
          ..write('peerOnline: $peerOnline, ')
          ..write('peerLastSeenAt: $peerLastSeenAt, ')
          ..write('peerDeliveredSeqId: $peerDeliveredSeqId, ')
          ..write('peerReadSeqId: $peerReadSeqId, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMessagesTable extends LocalMessages
    with TableInfo<$LocalMessagesTable, LocalMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientMsgIdMeta = const VerificationMeta(
    'clientMsgId',
  );
  @override
  late final GeneratedColumn<String> clientMsgId = GeneratedColumn<String>(
    'client_msg_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverMsgIdMeta = const VerificationMeta(
    'serverMsgId',
  );
  @override
  late final GeneratedColumn<String> serverMsgId = GeneratedColumn<String>(
    'server_msg_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqIdMeta = const VerificationMeta('seqId');
  @override
  late final GeneratedColumn<int> seqId = GeneratedColumn<int>(
    'seq_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _replyToMsgIdMeta = const VerificationMeta(
    'replyToMsgId',
  );
  @override
  late final GeneratedColumn<String> replyToMsgId = GeneratedColumn<String>(
    'reply_to_msg_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageTypeMeta = const VerificationMeta(
    'messageType',
  );
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
    'message_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('TEXT'),
  );
  static const VerificationMeta _bodyTextMeta = const VerificationMeta(
    'bodyText',
  );
  @override
  late final GeneratedColumn<String> bodyText = GeneratedColumn<String>(
    'body_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attachmentJsonMeta = const VerificationMeta(
    'attachmentJson',
  );
  @override
  late final GeneratedColumn<String> attachmentJson = GeneratedColumn<String>(
    'attachment_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryStatusMeta = const VerificationMeta(
    'deliveryStatus',
  );
  @override
  late final GeneratedColumn<String> deliveryStatus = GeneratedColumn<String>(
    'delivery_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientMsgId,
    serverMsgId,
    conversationId,
    seqId,
    senderId,
    replyToMsgId,
    messageType,
    bodyText,
    attachmentJson,
    deliveryStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_msg_id')) {
      context.handle(
        _clientMsgIdMeta,
        clientMsgId.isAcceptableOrUnknown(
          data['client_msg_id']!,
          _clientMsgIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientMsgIdMeta);
    }
    if (data.containsKey('server_msg_id')) {
      context.handle(
        _serverMsgIdMeta,
        serverMsgId.isAcceptableOrUnknown(
          data['server_msg_id']!,
          _serverMsgIdMeta,
        ),
      );
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('seq_id')) {
      context.handle(
        _seqIdMeta,
        seqId.isAcceptableOrUnknown(data['seq_id']!, _seqIdMeta),
      );
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('reply_to_msg_id')) {
      context.handle(
        _replyToMsgIdMeta,
        replyToMsgId.isAcceptableOrUnknown(
          data['reply_to_msg_id']!,
          _replyToMsgIdMeta,
        ),
      );
    }
    if (data.containsKey('message_type')) {
      context.handle(
        _messageTypeMeta,
        messageType.isAcceptableOrUnknown(
          data['message_type']!,
          _messageTypeMeta,
        ),
      );
    }
    if (data.containsKey('body_text')) {
      context.handle(
        _bodyTextMeta,
        bodyText.isAcceptableOrUnknown(data['body_text']!, _bodyTextMeta),
      );
    }
    if (data.containsKey('attachment_json')) {
      context.handle(
        _attachmentJsonMeta,
        attachmentJson.isAcceptableOrUnknown(
          data['attachment_json']!,
          _attachmentJsonMeta,
        ),
      );
    }
    if (data.containsKey('delivery_status')) {
      context.handle(
        _deliveryStatusMeta,
        deliveryStatus.isAcceptableOrUnknown(
          data['delivery_status']!,
          _deliveryStatusMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientMsgId};
  @override
  LocalMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMessage(
      clientMsgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_msg_id'],
      )!,
      serverMsgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_msg_id'],
      ),
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      seqId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq_id'],
      ),
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      replyToMsgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_to_msg_id'],
      ),
      messageType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_type'],
      )!,
      bodyText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_text'],
      ),
      attachmentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_json'],
      ),
      deliveryStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalMessagesTable createAlias(String alias) {
    return $LocalMessagesTable(attachedDatabase, alias);
  }
}

class LocalMessage extends DataClass implements Insertable<LocalMessage> {
  final String clientMsgId;
  final String? serverMsgId;
  final String conversationId;
  final int? seqId;
  final String senderId;
  final String? replyToMsgId;
  final String messageType;
  final String? bodyText;
  final String? attachmentJson;
  final String deliveryStatus;
  final DateTime createdAt;
  const LocalMessage({
    required this.clientMsgId,
    this.serverMsgId,
    required this.conversationId,
    this.seqId,
    required this.senderId,
    this.replyToMsgId,
    required this.messageType,
    this.bodyText,
    this.attachmentJson,
    required this.deliveryStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_msg_id'] = Variable<String>(clientMsgId);
    if (!nullToAbsent || serverMsgId != null) {
      map['server_msg_id'] = Variable<String>(serverMsgId);
    }
    map['conversation_id'] = Variable<String>(conversationId);
    if (!nullToAbsent || seqId != null) {
      map['seq_id'] = Variable<int>(seqId);
    }
    map['sender_id'] = Variable<String>(senderId);
    if (!nullToAbsent || replyToMsgId != null) {
      map['reply_to_msg_id'] = Variable<String>(replyToMsgId);
    }
    map['message_type'] = Variable<String>(messageType);
    if (!nullToAbsent || bodyText != null) {
      map['body_text'] = Variable<String>(bodyText);
    }
    if (!nullToAbsent || attachmentJson != null) {
      map['attachment_json'] = Variable<String>(attachmentJson);
    }
    map['delivery_status'] = Variable<String>(deliveryStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalMessagesCompanion toCompanion(bool nullToAbsent) {
    return LocalMessagesCompanion(
      clientMsgId: Value(clientMsgId),
      serverMsgId: serverMsgId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverMsgId),
      conversationId: Value(conversationId),
      seqId: seqId == null && nullToAbsent
          ? const Value.absent()
          : Value(seqId),
      senderId: Value(senderId),
      replyToMsgId: replyToMsgId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyToMsgId),
      messageType: Value(messageType),
      bodyText: bodyText == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyText),
      attachmentJson: attachmentJson == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentJson),
      deliveryStatus: Value(deliveryStatus),
      createdAt: Value(createdAt),
    );
  }

  factory LocalMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMessage(
      clientMsgId: serializer.fromJson<String>(json['clientMsgId']),
      serverMsgId: serializer.fromJson<String?>(json['serverMsgId']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      seqId: serializer.fromJson<int?>(json['seqId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      replyToMsgId: serializer.fromJson<String?>(json['replyToMsgId']),
      messageType: serializer.fromJson<String>(json['messageType']),
      bodyText: serializer.fromJson<String?>(json['bodyText']),
      attachmentJson: serializer.fromJson<String?>(json['attachmentJson']),
      deliveryStatus: serializer.fromJson<String>(json['deliveryStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientMsgId': serializer.toJson<String>(clientMsgId),
      'serverMsgId': serializer.toJson<String?>(serverMsgId),
      'conversationId': serializer.toJson<String>(conversationId),
      'seqId': serializer.toJson<int?>(seqId),
      'senderId': serializer.toJson<String>(senderId),
      'replyToMsgId': serializer.toJson<String?>(replyToMsgId),
      'messageType': serializer.toJson<String>(messageType),
      'bodyText': serializer.toJson<String?>(bodyText),
      'attachmentJson': serializer.toJson<String?>(attachmentJson),
      'deliveryStatus': serializer.toJson<String>(deliveryStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalMessage copyWith({
    String? clientMsgId,
    Value<String?> serverMsgId = const Value.absent(),
    String? conversationId,
    Value<int?> seqId = const Value.absent(),
    String? senderId,
    Value<String?> replyToMsgId = const Value.absent(),
    String? messageType,
    Value<String?> bodyText = const Value.absent(),
    Value<String?> attachmentJson = const Value.absent(),
    String? deliveryStatus,
    DateTime? createdAt,
  }) => LocalMessage(
    clientMsgId: clientMsgId ?? this.clientMsgId,
    serverMsgId: serverMsgId.present ? serverMsgId.value : this.serverMsgId,
    conversationId: conversationId ?? this.conversationId,
    seqId: seqId.present ? seqId.value : this.seqId,
    senderId: senderId ?? this.senderId,
    replyToMsgId: replyToMsgId.present ? replyToMsgId.value : this.replyToMsgId,
    messageType: messageType ?? this.messageType,
    bodyText: bodyText.present ? bodyText.value : this.bodyText,
    attachmentJson: attachmentJson.present
        ? attachmentJson.value
        : this.attachmentJson,
    deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalMessage copyWithCompanion(LocalMessagesCompanion data) {
    return LocalMessage(
      clientMsgId: data.clientMsgId.present
          ? data.clientMsgId.value
          : this.clientMsgId,
      serverMsgId: data.serverMsgId.present
          ? data.serverMsgId.value
          : this.serverMsgId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      seqId: data.seqId.present ? data.seqId.value : this.seqId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      replyToMsgId: data.replyToMsgId.present
          ? data.replyToMsgId.value
          : this.replyToMsgId,
      messageType: data.messageType.present
          ? data.messageType.value
          : this.messageType,
      bodyText: data.bodyText.present ? data.bodyText.value : this.bodyText,
      attachmentJson: data.attachmentJson.present
          ? data.attachmentJson.value
          : this.attachmentJson,
      deliveryStatus: data.deliveryStatus.present
          ? data.deliveryStatus.value
          : this.deliveryStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessage(')
          ..write('clientMsgId: $clientMsgId, ')
          ..write('serverMsgId: $serverMsgId, ')
          ..write('conversationId: $conversationId, ')
          ..write('seqId: $seqId, ')
          ..write('senderId: $senderId, ')
          ..write('replyToMsgId: $replyToMsgId, ')
          ..write('messageType: $messageType, ')
          ..write('bodyText: $bodyText, ')
          ..write('attachmentJson: $attachmentJson, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientMsgId,
    serverMsgId,
    conversationId,
    seqId,
    senderId,
    replyToMsgId,
    messageType,
    bodyText,
    attachmentJson,
    deliveryStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMessage &&
          other.clientMsgId == this.clientMsgId &&
          other.serverMsgId == this.serverMsgId &&
          other.conversationId == this.conversationId &&
          other.seqId == this.seqId &&
          other.senderId == this.senderId &&
          other.replyToMsgId == this.replyToMsgId &&
          other.messageType == this.messageType &&
          other.bodyText == this.bodyText &&
          other.attachmentJson == this.attachmentJson &&
          other.deliveryStatus == this.deliveryStatus &&
          other.createdAt == this.createdAt);
}

class LocalMessagesCompanion extends UpdateCompanion<LocalMessage> {
  final Value<String> clientMsgId;
  final Value<String?> serverMsgId;
  final Value<String> conversationId;
  final Value<int?> seqId;
  final Value<String> senderId;
  final Value<String?> replyToMsgId;
  final Value<String> messageType;
  final Value<String?> bodyText;
  final Value<String?> attachmentJson;
  final Value<String> deliveryStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalMessagesCompanion({
    this.clientMsgId = const Value.absent(),
    this.serverMsgId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.seqId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.replyToMsgId = const Value.absent(),
    this.messageType = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.attachmentJson = const Value.absent(),
    this.deliveryStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMessagesCompanion.insert({
    required String clientMsgId,
    this.serverMsgId = const Value.absent(),
    required String conversationId,
    this.seqId = const Value.absent(),
    required String senderId,
    this.replyToMsgId = const Value.absent(),
    this.messageType = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.attachmentJson = const Value.absent(),
    this.deliveryStatus = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientMsgId = Value(clientMsgId),
       conversationId = Value(conversationId),
       senderId = Value(senderId),
       createdAt = Value(createdAt);
  static Insertable<LocalMessage> custom({
    Expression<String>? clientMsgId,
    Expression<String>? serverMsgId,
    Expression<String>? conversationId,
    Expression<int>? seqId,
    Expression<String>? senderId,
    Expression<String>? replyToMsgId,
    Expression<String>? messageType,
    Expression<String>? bodyText,
    Expression<String>? attachmentJson,
    Expression<String>? deliveryStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientMsgId != null) 'client_msg_id': clientMsgId,
      if (serverMsgId != null) 'server_msg_id': serverMsgId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (seqId != null) 'seq_id': seqId,
      if (senderId != null) 'sender_id': senderId,
      if (replyToMsgId != null) 'reply_to_msg_id': replyToMsgId,
      if (messageType != null) 'message_type': messageType,
      if (bodyText != null) 'body_text': bodyText,
      if (attachmentJson != null) 'attachment_json': attachmentJson,
      if (deliveryStatus != null) 'delivery_status': deliveryStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMessagesCompanion copyWith({
    Value<String>? clientMsgId,
    Value<String?>? serverMsgId,
    Value<String>? conversationId,
    Value<int?>? seqId,
    Value<String>? senderId,
    Value<String?>? replyToMsgId,
    Value<String>? messageType,
    Value<String?>? bodyText,
    Value<String?>? attachmentJson,
    Value<String>? deliveryStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalMessagesCompanion(
      clientMsgId: clientMsgId ?? this.clientMsgId,
      serverMsgId: serverMsgId ?? this.serverMsgId,
      conversationId: conversationId ?? this.conversationId,
      seqId: seqId ?? this.seqId,
      senderId: senderId ?? this.senderId,
      replyToMsgId: replyToMsgId ?? this.replyToMsgId,
      messageType: messageType ?? this.messageType,
      bodyText: bodyText ?? this.bodyText,
      attachmentJson: attachmentJson ?? this.attachmentJson,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientMsgId.present) {
      map['client_msg_id'] = Variable<String>(clientMsgId.value);
    }
    if (serverMsgId.present) {
      map['server_msg_id'] = Variable<String>(serverMsgId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (seqId.present) {
      map['seq_id'] = Variable<int>(seqId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (replyToMsgId.present) {
      map['reply_to_msg_id'] = Variable<String>(replyToMsgId.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    if (bodyText.present) {
      map['body_text'] = Variable<String>(bodyText.value);
    }
    if (attachmentJson.present) {
      map['attachment_json'] = Variable<String>(attachmentJson.value);
    }
    if (deliveryStatus.present) {
      map['delivery_status'] = Variable<String>(deliveryStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessagesCompanion(')
          ..write('clientMsgId: $clientMsgId, ')
          ..write('serverMsgId: $serverMsgId, ')
          ..write('conversationId: $conversationId, ')
          ..write('seqId: $seqId, ')
          ..write('senderId: $senderId, ')
          ..write('replyToMsgId: $replyToMsgId, ')
          ..write('messageType: $messageType, ')
          ..write('bodyText: $bodyText, ')
          ..write('attachmentJson: $attachmentJson, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOutboxQueueTable extends PendingOutboxQueue
    with TableInfo<$PendingOutboxQueueTable, PendingOutboxQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOutboxQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientMsgIdMeta = const VerificationMeta(
    'clientMsgId',
  );
  @override
  late final GeneratedColumn<String> clientMsgId = GeneratedColumn<String>(
    'client_msg_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _framePayloadJsonMeta = const VerificationMeta(
    'framePayloadJson',
  );
  @override
  late final GeneratedColumn<String> framePayloadJson = GeneratedColumn<String>(
    'frame_payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientMsgId,
    conversationId,
    framePayloadJson,
    retryCount,
    lastAttemptAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_outbox_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOutboxQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_msg_id')) {
      context.handle(
        _clientMsgIdMeta,
        clientMsgId.isAcceptableOrUnknown(
          data['client_msg_id']!,
          _clientMsgIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientMsgIdMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('frame_payload_json')) {
      context.handle(
        _framePayloadJsonMeta,
        framePayloadJson.isAcceptableOrUnknown(
          data['frame_payload_json']!,
          _framePayloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_framePayloadJsonMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientMsgId};
  @override
  PendingOutboxQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOutboxQueueData(
      clientMsgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_msg_id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      framePayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frame_payload_json'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingOutboxQueueTable createAlias(String alias) {
    return $PendingOutboxQueueTable(attachedDatabase, alias);
  }
}

class PendingOutboxQueueData extends DataClass
    implements Insertable<PendingOutboxQueueData> {
  final String clientMsgId;
  final String conversationId;
  final String framePayloadJson;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final DateTime createdAt;
  const PendingOutboxQueueData({
    required this.clientMsgId,
    required this.conversationId,
    required this.framePayloadJson,
    required this.retryCount,
    this.lastAttemptAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_msg_id'] = Variable<String>(clientMsgId);
    map['conversation_id'] = Variable<String>(conversationId);
    map['frame_payload_json'] = Variable<String>(framePayloadJson);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingOutboxQueueCompanion toCompanion(bool nullToAbsent) {
    return PendingOutboxQueueCompanion(
      clientMsgId: Value(clientMsgId),
      conversationId: Value(conversationId),
      framePayloadJson: Value(framePayloadJson),
      retryCount: Value(retryCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      createdAt: Value(createdAt),
    );
  }

  factory PendingOutboxQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOutboxQueueData(
      clientMsgId: serializer.fromJson<String>(json['clientMsgId']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      framePayloadJson: serializer.fromJson<String>(json['framePayloadJson']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientMsgId': serializer.toJson<String>(clientMsgId),
      'conversationId': serializer.toJson<String>(conversationId),
      'framePayloadJson': serializer.toJson<String>(framePayloadJson),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingOutboxQueueData copyWith({
    String? clientMsgId,
    String? conversationId,
    String? framePayloadJson,
    int? retryCount,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    DateTime? createdAt,
  }) => PendingOutboxQueueData(
    clientMsgId: clientMsgId ?? this.clientMsgId,
    conversationId: conversationId ?? this.conversationId,
    framePayloadJson: framePayloadJson ?? this.framePayloadJson,
    retryCount: retryCount ?? this.retryCount,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingOutboxQueueData copyWithCompanion(PendingOutboxQueueCompanion data) {
    return PendingOutboxQueueData(
      clientMsgId: data.clientMsgId.present
          ? data.clientMsgId.value
          : this.clientMsgId,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      framePayloadJson: data.framePayloadJson.present
          ? data.framePayloadJson.value
          : this.framePayloadJson,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOutboxQueueData(')
          ..write('clientMsgId: $clientMsgId, ')
          ..write('conversationId: $conversationId, ')
          ..write('framePayloadJson: $framePayloadJson, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientMsgId,
    conversationId,
    framePayloadJson,
    retryCount,
    lastAttemptAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOutboxQueueData &&
          other.clientMsgId == this.clientMsgId &&
          other.conversationId == this.conversationId &&
          other.framePayloadJson == this.framePayloadJson &&
          other.retryCount == this.retryCount &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.createdAt == this.createdAt);
}

class PendingOutboxQueueCompanion
    extends UpdateCompanion<PendingOutboxQueueData> {
  final Value<String> clientMsgId;
  final Value<String> conversationId;
  final Value<String> framePayloadJson;
  final Value<int> retryCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PendingOutboxQueueCompanion({
    this.clientMsgId = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.framePayloadJson = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingOutboxQueueCompanion.insert({
    required String clientMsgId,
    required String conversationId,
    required String framePayloadJson,
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : clientMsgId = Value(clientMsgId),
       conversationId = Value(conversationId),
       framePayloadJson = Value(framePayloadJson),
       createdAt = Value(createdAt);
  static Insertable<PendingOutboxQueueData> custom({
    Expression<String>? clientMsgId,
    Expression<String>? conversationId,
    Expression<String>? framePayloadJson,
    Expression<int>? retryCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientMsgId != null) 'client_msg_id': clientMsgId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (framePayloadJson != null) 'frame_payload_json': framePayloadJson,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingOutboxQueueCompanion copyWith({
    Value<String>? clientMsgId,
    Value<String>? conversationId,
    Value<String>? framePayloadJson,
    Value<int>? retryCount,
    Value<DateTime?>? lastAttemptAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PendingOutboxQueueCompanion(
      clientMsgId: clientMsgId ?? this.clientMsgId,
      conversationId: conversationId ?? this.conversationId,
      framePayloadJson: framePayloadJson ?? this.framePayloadJson,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientMsgId.present) {
      map['client_msg_id'] = Variable<String>(clientMsgId.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (framePayloadJson.present) {
      map['frame_payload_json'] = Variable<String>(framePayloadJson.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOutboxQueueCompanion(')
          ..write('clientMsgId: $clientMsgId, ')
          ..write('conversationId: $conversationId, ')
          ..write('framePayloadJson: $framePayloadJson, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ChatDriftDatabase extends GeneratedDatabase {
  _$ChatDriftDatabase(QueryExecutor e) : super(e);
  $ChatDriftDatabaseManager get managers => $ChatDriftDatabaseManager(this);
  late final $LocalConversationsTable localConversations =
      $LocalConversationsTable(this);
  late final $LocalMessagesTable localMessages = $LocalMessagesTable(this);
  late final $PendingOutboxQueueTable pendingOutboxQueue =
      $PendingOutboxQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localConversations,
    localMessages,
    pendingOutboxQueue,
  ];
}

typedef $$LocalConversationsTableCreateCompanionBuilder =
    LocalConversationsCompanion Function({
      required String id,
      Value<String> kind,
      required String title,
      Value<String?> avatarUrl,
      Value<int> lastSeqId,
      Value<int> localSyncedSeqId,
      Value<int> unreadCount,
      Value<int> myReadSeqId,
      Value<String?> peerUserId,
      Value<String?> peerUsername,
      Value<bool> peerOnline,
      Value<DateTime?> peerLastSeenAt,
      Value<int> peerDeliveredSeqId,
      Value<int> peerReadSeqId,
      Value<String?> lastMessagePreview,
      Value<DateTime?> lastMessageAt,
      Value<int> rowid,
    });
typedef $$LocalConversationsTableUpdateCompanionBuilder =
    LocalConversationsCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String> title,
      Value<String?> avatarUrl,
      Value<int> lastSeqId,
      Value<int> localSyncedSeqId,
      Value<int> unreadCount,
      Value<int> myReadSeqId,
      Value<String?> peerUserId,
      Value<String?> peerUsername,
      Value<bool> peerOnline,
      Value<DateTime?> peerLastSeenAt,
      Value<int> peerDeliveredSeqId,
      Value<int> peerReadSeqId,
      Value<String?> lastMessagePreview,
      Value<DateTime?> lastMessageAt,
      Value<int> rowid,
    });

class $$LocalConversationsTableFilterComposer
    extends Composer<_$ChatDriftDatabase, $LocalConversationsTable> {
  $$LocalConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeqId => $composableBuilder(
    column: $table.lastSeqId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localSyncedSeqId => $composableBuilder(
    column: $table.localSyncedSeqId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get myReadSeqId => $composableBuilder(
    column: $table.myReadSeqId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerUserId => $composableBuilder(
    column: $table.peerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peerUsername => $composableBuilder(
    column: $table.peerUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get peerOnline => $composableBuilder(
    column: $table.peerOnline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get peerLastSeenAt => $composableBuilder(
    column: $table.peerLastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peerDeliveredSeqId => $composableBuilder(
    column: $table.peerDeliveredSeqId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peerReadSeqId => $composableBuilder(
    column: $table.peerReadSeqId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalConversationsTableOrderingComposer
    extends Composer<_$ChatDriftDatabase, $LocalConversationsTable> {
  $$LocalConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeqId => $composableBuilder(
    column: $table.lastSeqId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localSyncedSeqId => $composableBuilder(
    column: $table.localSyncedSeqId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get myReadSeqId => $composableBuilder(
    column: $table.myReadSeqId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerUserId => $composableBuilder(
    column: $table.peerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peerUsername => $composableBuilder(
    column: $table.peerUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get peerOnline => $composableBuilder(
    column: $table.peerOnline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get peerLastSeenAt => $composableBuilder(
    column: $table.peerLastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peerDeliveredSeqId => $composableBuilder(
    column: $table.peerDeliveredSeqId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peerReadSeqId => $composableBuilder(
    column: $table.peerReadSeqId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalConversationsTableAnnotationComposer
    extends Composer<_$ChatDriftDatabase, $LocalConversationsTable> {
  $$LocalConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<int> get lastSeqId =>
      $composableBuilder(column: $table.lastSeqId, builder: (column) => column);

  GeneratedColumn<int> get localSyncedSeqId => $composableBuilder(
    column: $table.localSyncedSeqId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get myReadSeqId => $composableBuilder(
    column: $table.myReadSeqId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peerUserId => $composableBuilder(
    column: $table.peerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peerUsername => $composableBuilder(
    column: $table.peerUsername,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get peerOnline => $composableBuilder(
    column: $table.peerOnline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get peerLastSeenAt => $composableBuilder(
    column: $table.peerLastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get peerDeliveredSeqId => $composableBuilder(
    column: $table.peerDeliveredSeqId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get peerReadSeqId => $composableBuilder(
    column: $table.peerReadSeqId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );
}

class $$LocalConversationsTableTableManager
    extends
        RootTableManager<
          _$ChatDriftDatabase,
          $LocalConversationsTable,
          LocalConversation,
          $$LocalConversationsTableFilterComposer,
          $$LocalConversationsTableOrderingComposer,
          $$LocalConversationsTableAnnotationComposer,
          $$LocalConversationsTableCreateCompanionBuilder,
          $$LocalConversationsTableUpdateCompanionBuilder,
          (
            LocalConversation,
            BaseReferences<
              _$ChatDriftDatabase,
              $LocalConversationsTable,
              LocalConversation
            >,
          ),
          LocalConversation,
          PrefetchHooks Function()
        > {
  $$LocalConversationsTableTableManager(
    _$ChatDriftDatabase db,
    $LocalConversationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalConversationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> lastSeqId = const Value.absent(),
                Value<int> localSyncedSeqId = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int> myReadSeqId = const Value.absent(),
                Value<String?> peerUserId = const Value.absent(),
                Value<String?> peerUsername = const Value.absent(),
                Value<bool> peerOnline = const Value.absent(),
                Value<DateTime?> peerLastSeenAt = const Value.absent(),
                Value<int> peerDeliveredSeqId = const Value.absent(),
                Value<int> peerReadSeqId = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConversationsCompanion(
                id: id,
                kind: kind,
                title: title,
                avatarUrl: avatarUrl,
                lastSeqId: lastSeqId,
                localSyncedSeqId: localSyncedSeqId,
                unreadCount: unreadCount,
                myReadSeqId: myReadSeqId,
                peerUserId: peerUserId,
                peerUsername: peerUsername,
                peerOnline: peerOnline,
                peerLastSeenAt: peerLastSeenAt,
                peerDeliveredSeqId: peerDeliveredSeqId,
                peerReadSeqId: peerReadSeqId,
                lastMessagePreview: lastMessagePreview,
                lastMessageAt: lastMessageAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> kind = const Value.absent(),
                required String title,
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> lastSeqId = const Value.absent(),
                Value<int> localSyncedSeqId = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<int> myReadSeqId = const Value.absent(),
                Value<String?> peerUserId = const Value.absent(),
                Value<String?> peerUsername = const Value.absent(),
                Value<bool> peerOnline = const Value.absent(),
                Value<DateTime?> peerLastSeenAt = const Value.absent(),
                Value<int> peerDeliveredSeqId = const Value.absent(),
                Value<int> peerReadSeqId = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConversationsCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                avatarUrl: avatarUrl,
                lastSeqId: lastSeqId,
                localSyncedSeqId: localSyncedSeqId,
                unreadCount: unreadCount,
                myReadSeqId: myReadSeqId,
                peerUserId: peerUserId,
                peerUsername: peerUsername,
                peerOnline: peerOnline,
                peerLastSeenAt: peerLastSeenAt,
                peerDeliveredSeqId: peerDeliveredSeqId,
                peerReadSeqId: peerReadSeqId,
                lastMessagePreview: lastMessagePreview,
                lastMessageAt: lastMessageAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalConversationsTable, LocalConversation>(
                    table,
                  ),
                  BaseReferences<
                    _$ChatDriftDatabase,
                    $LocalConversationsTable,
                    LocalConversation
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$ChatDriftDatabase,
      $LocalConversationsTable,
      LocalConversation,
      $$LocalConversationsTableFilterComposer,
      $$LocalConversationsTableOrderingComposer,
      $$LocalConversationsTableAnnotationComposer,
      $$LocalConversationsTableCreateCompanionBuilder,
      $$LocalConversationsTableUpdateCompanionBuilder,
      (
        LocalConversation,
        BaseReferences<
          _$ChatDriftDatabase,
          $LocalConversationsTable,
          LocalConversation
        >,
      ),
      LocalConversation,
      PrefetchHooks Function()
    >;
typedef $$LocalMessagesTableCreateCompanionBuilder =
    LocalMessagesCompanion Function({
      required String clientMsgId,
      Value<String?> serverMsgId,
      required String conversationId,
      Value<int?> seqId,
      required String senderId,
      Value<String?> replyToMsgId,
      Value<String> messageType,
      Value<String?> bodyText,
      Value<String?> attachmentJson,
      Value<String> deliveryStatus,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalMessagesTableUpdateCompanionBuilder =
    LocalMessagesCompanion Function({
      Value<String> clientMsgId,
      Value<String?> serverMsgId,
      Value<String> conversationId,
      Value<int?> seqId,
      Value<String> senderId,
      Value<String?> replyToMsgId,
      Value<String> messageType,
      Value<String?> bodyText,
      Value<String?> attachmentJson,
      Value<String> deliveryStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalMessagesTableFilterComposer
    extends Composer<_$ChatDriftDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverMsgId => $composableBuilder(
    column: $table.serverMsgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seqId => $composableBuilder(
    column: $table.seqId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyToMsgId => $composableBuilder(
    column: $table.replyToMsgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyText => $composableBuilder(
    column: $table.bodyText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentJson => $composableBuilder(
    column: $table.attachmentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMessagesTableOrderingComposer
    extends Composer<_$ChatDriftDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverMsgId => $composableBuilder(
    column: $table.serverMsgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seqId => $composableBuilder(
    column: $table.seqId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyToMsgId => $composableBuilder(
    column: $table.replyToMsgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyText => $composableBuilder(
    column: $table.bodyText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentJson => $composableBuilder(
    column: $table.attachmentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMessagesTableAnnotationComposer
    extends Composer<_$ChatDriftDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverMsgId => $composableBuilder(
    column: $table.serverMsgId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seqId =>
      $composableBuilder(column: $table.seqId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get replyToMsgId => $composableBuilder(
    column: $table.replyToMsgId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageType => $composableBuilder(
    column: $table.messageType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyText =>
      $composableBuilder(column: $table.bodyText, builder: (column) => column);

  GeneratedColumn<String> get attachmentJson => $composableBuilder(
    column: $table.attachmentJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalMessagesTableTableManager
    extends
        RootTableManager<
          _$ChatDriftDatabase,
          $LocalMessagesTable,
          LocalMessage,
          $$LocalMessagesTableFilterComposer,
          $$LocalMessagesTableOrderingComposer,
          $$LocalMessagesTableAnnotationComposer,
          $$LocalMessagesTableCreateCompanionBuilder,
          $$LocalMessagesTableUpdateCompanionBuilder,
          (
            LocalMessage,
            BaseReferences<
              _$ChatDriftDatabase,
              $LocalMessagesTable,
              LocalMessage
            >,
          ),
          LocalMessage,
          PrefetchHooks Function()
        > {
  $$LocalMessagesTableTableManager(
    _$ChatDriftDatabase db,
    $LocalMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientMsgId = const Value.absent(),
                Value<String?> serverMsgId = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<int?> seqId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String?> replyToMsgId = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<String?> bodyText = const Value.absent(),
                Value<String?> attachmentJson = const Value.absent(),
                Value<String> deliveryStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMessagesCompanion(
                clientMsgId: clientMsgId,
                serverMsgId: serverMsgId,
                conversationId: conversationId,
                seqId: seqId,
                senderId: senderId,
                replyToMsgId: replyToMsgId,
                messageType: messageType,
                bodyText: bodyText,
                attachmentJson: attachmentJson,
                deliveryStatus: deliveryStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientMsgId,
                Value<String?> serverMsgId = const Value.absent(),
                required String conversationId,
                Value<int?> seqId = const Value.absent(),
                required String senderId,
                Value<String?> replyToMsgId = const Value.absent(),
                Value<String> messageType = const Value.absent(),
                Value<String?> bodyText = const Value.absent(),
                Value<String?> attachmentJson = const Value.absent(),
                Value<String> deliveryStatus = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalMessagesCompanion.insert(
                clientMsgId: clientMsgId,
                serverMsgId: serverMsgId,
                conversationId: conversationId,
                seqId: seqId,
                senderId: senderId,
                replyToMsgId: replyToMsgId,
                messageType: messageType,
                bodyText: bodyText,
                attachmentJson: attachmentJson,
                deliveryStatus: deliveryStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalMessagesTable, LocalMessage>(table),
                  BaseReferences<
                    _$ChatDriftDatabase,
                    $LocalMessagesTable,
                    LocalMessage
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$ChatDriftDatabase,
      $LocalMessagesTable,
      LocalMessage,
      $$LocalMessagesTableFilterComposer,
      $$LocalMessagesTableOrderingComposer,
      $$LocalMessagesTableAnnotationComposer,
      $$LocalMessagesTableCreateCompanionBuilder,
      $$LocalMessagesTableUpdateCompanionBuilder,
      (
        LocalMessage,
        BaseReferences<_$ChatDriftDatabase, $LocalMessagesTable, LocalMessage>,
      ),
      LocalMessage,
      PrefetchHooks Function()
    >;
typedef $$PendingOutboxQueueTableCreateCompanionBuilder =
    PendingOutboxQueueCompanion Function({
      required String clientMsgId,
      required String conversationId,
      required String framePayloadJson,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PendingOutboxQueueTableUpdateCompanionBuilder =
    PendingOutboxQueueCompanion Function({
      Value<String> clientMsgId,
      Value<String> conversationId,
      Value<String> framePayloadJson,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PendingOutboxQueueTableFilterComposer
    extends Composer<_$ChatDriftDatabase, $PendingOutboxQueueTable> {
  $$PendingOutboxQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get framePayloadJson => $composableBuilder(
    column: $table.framePayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOutboxQueueTableOrderingComposer
    extends Composer<_$ChatDriftDatabase, $PendingOutboxQueueTable> {
  $$PendingOutboxQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get framePayloadJson => $composableBuilder(
    column: $table.framePayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOutboxQueueTableAnnotationComposer
    extends Composer<_$ChatDriftDatabase, $PendingOutboxQueueTable> {
  $$PendingOutboxQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientMsgId => $composableBuilder(
    column: $table.clientMsgId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get framePayloadJson => $composableBuilder(
    column: $table.framePayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingOutboxQueueTableTableManager
    extends
        RootTableManager<
          _$ChatDriftDatabase,
          $PendingOutboxQueueTable,
          PendingOutboxQueueData,
          $$PendingOutboxQueueTableFilterComposer,
          $$PendingOutboxQueueTableOrderingComposer,
          $$PendingOutboxQueueTableAnnotationComposer,
          $$PendingOutboxQueueTableCreateCompanionBuilder,
          $$PendingOutboxQueueTableUpdateCompanionBuilder,
          (
            PendingOutboxQueueData,
            BaseReferences<
              _$ChatDriftDatabase,
              $PendingOutboxQueueTable,
              PendingOutboxQueueData
            >,
          ),
          PendingOutboxQueueData,
          PrefetchHooks Function()
        > {
  $$PendingOutboxQueueTableTableManager(
    _$ChatDriftDatabase db,
    $PendingOutboxQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOutboxQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOutboxQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOutboxQueueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> clientMsgId = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> framePayloadJson = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingOutboxQueueCompanion(
                clientMsgId: clientMsgId,
                conversationId: conversationId,
                framePayloadJson: framePayloadJson,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientMsgId,
                required String conversationId,
                required String framePayloadJson,
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingOutboxQueueCompanion.insert(
                clientMsgId: clientMsgId,
                conversationId: conversationId,
                framePayloadJson: framePayloadJson,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingOutboxQueueTable, PendingOutboxQueueData>(
                    table,
                  ),
                  BaseReferences<
                    _$ChatDriftDatabase,
                    $PendingOutboxQueueTable,
                    PendingOutboxQueueData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOutboxQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$ChatDriftDatabase,
      $PendingOutboxQueueTable,
      PendingOutboxQueueData,
      $$PendingOutboxQueueTableFilterComposer,
      $$PendingOutboxQueueTableOrderingComposer,
      $$PendingOutboxQueueTableAnnotationComposer,
      $$PendingOutboxQueueTableCreateCompanionBuilder,
      $$PendingOutboxQueueTableUpdateCompanionBuilder,
      (
        PendingOutboxQueueData,
        BaseReferences<
          _$ChatDriftDatabase,
          $PendingOutboxQueueTable,
          PendingOutboxQueueData
        >,
      ),
      PendingOutboxQueueData,
      PrefetchHooks Function()
    >;

class $ChatDriftDatabaseManager {
  final _$ChatDriftDatabase _db;
  $ChatDriftDatabaseManager(this._db);
  $$LocalConversationsTableTableManager get localConversations =>
      $$LocalConversationsTableTableManager(_db, _db.localConversations);
  $$LocalMessagesTableTableManager get localMessages =>
      $$LocalMessagesTableTableManager(_db, _db.localMessages);
  $$PendingOutboxQueueTableTableManager get pendingOutboxQueue =>
      $$PendingOutboxQueueTableTableManager(_db, _db.pendingOutboxQueue);
}
