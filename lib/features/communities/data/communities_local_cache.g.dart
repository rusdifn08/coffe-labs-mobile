// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communities_local_cache.dart';

// ignore_for_file: type=lint
class $CachedCommunitiesTable extends CachedCommunities
    with TableInfo<$CachedCommunitiesTable, CachedCommunity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCommunitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isJoinedMeta = const VerificationMeta(
    'isJoined',
  );
  @override
  late final GeneratedColumn<bool> isJoined = GeneratedColumn<bool>(
    'is_joined',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_joined" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payloadJson, isJoined, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_communities';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCommunity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('is_joined')) {
      context.handle(
        _isJoinedMeta,
        isJoined.isAcceptableOrUnknown(data['is_joined']!, _isJoinedMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedCommunity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCommunity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      isJoined: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_joined'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedCommunitiesTable createAlias(String alias) {
    return $CachedCommunitiesTable(attachedDatabase, alias);
  }
}

class CachedCommunity extends DataClass implements Insertable<CachedCommunity> {
  final String id;
  final String payloadJson;
  final bool isJoined;
  final DateTime cachedAt;
  const CachedCommunity({
    required this.id,
    required this.payloadJson,
    required this.isJoined,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload_json'] = Variable<String>(payloadJson);
    map['is_joined'] = Variable<bool>(isJoined);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedCommunitiesCompanion toCompanion(bool nullToAbsent) {
    return CachedCommunitiesCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      isJoined: Value(isJoined),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedCommunity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCommunity(
      id: serializer.fromJson<String>(json['id']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      isJoined: serializer.fromJson<bool>(json['isJoined']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'isJoined': serializer.toJson<bool>(isJoined),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedCommunity copyWith({
    String? id,
    String? payloadJson,
    bool? isJoined,
    DateTime? cachedAt,
  }) => CachedCommunity(
    id: id ?? this.id,
    payloadJson: payloadJson ?? this.payloadJson,
    isJoined: isJoined ?? this.isJoined,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedCommunity copyWithCompanion(CachedCommunitiesCompanion data) {
    return CachedCommunity(
      id: data.id.present ? data.id.value : this.id,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      isJoined: data.isJoined.present ? data.isJoined.value : this.isJoined,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCommunity(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('isJoined: $isJoined, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadJson, isJoined, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCommunity &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.isJoined == this.isJoined &&
          other.cachedAt == this.cachedAt);
}

class CachedCommunitiesCompanion extends UpdateCompanion<CachedCommunity> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<bool> isJoined;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedCommunitiesCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.isJoined = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCommunitiesCompanion.insert({
    required String id,
    required String payloadJson,
    this.isJoined = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson),
       cachedAt = Value(cachedAt);
  static Insertable<CachedCommunity> custom({
    Expression<String>? id,
    Expression<String>? payloadJson,
    Expression<bool>? isJoined,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (isJoined != null) 'is_joined': isJoined,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCommunitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? payloadJson,
    Value<bool>? isJoined,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedCommunitiesCompanion(
      id: id ?? this.id,
      payloadJson: payloadJson ?? this.payloadJson,
      isJoined: isJoined ?? this.isJoined,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (isJoined.present) {
      map['is_joined'] = Variable<bool>(isJoined.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCommunitiesCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('isJoined: $isJoined, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedForYouFeedItemsTable extends CachedForYouFeedItems
    with TableInfo<$CachedForYouFeedItemsTable, CachedForYouFeedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedForYouFeedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortRankMeta = const VerificationMeta(
    'sortRank',
  );
  @override
  late final GeneratedColumn<int> sortRank = GeneratedColumn<int>(
    'sort_rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    threadId,
    payloadJson,
    sortRank,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_for_you_feed_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedForYouFeedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('sort_rank')) {
      context.handle(
        _sortRankMeta,
        sortRank.isAcceptableOrUnknown(data['sort_rank']!, _sortRankMeta),
      );
    } else if (isInserting) {
      context.missing(_sortRankMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {threadId};
  @override
  CachedForYouFeedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedForYouFeedItem(
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      sortRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_rank'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedForYouFeedItemsTable createAlias(String alias) {
    return $CachedForYouFeedItemsTable(attachedDatabase, alias);
  }
}

class CachedForYouFeedItem extends DataClass
    implements Insertable<CachedForYouFeedItem> {
  final String threadId;
  final String payloadJson;
  final int sortRank;
  final DateTime cachedAt;
  const CachedForYouFeedItem({
    required this.threadId,
    required this.payloadJson,
    required this.sortRank,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['thread_id'] = Variable<String>(threadId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['sort_rank'] = Variable<int>(sortRank);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedForYouFeedItemsCompanion toCompanion(bool nullToAbsent) {
    return CachedForYouFeedItemsCompanion(
      threadId: Value(threadId),
      payloadJson: Value(payloadJson),
      sortRank: Value(sortRank),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedForYouFeedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedForYouFeedItem(
      threadId: serializer.fromJson<String>(json['threadId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      sortRank: serializer.fromJson<int>(json['sortRank']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'threadId': serializer.toJson<String>(threadId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'sortRank': serializer.toJson<int>(sortRank),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedForYouFeedItem copyWith({
    String? threadId,
    String? payloadJson,
    int? sortRank,
    DateTime? cachedAt,
  }) => CachedForYouFeedItem(
    threadId: threadId ?? this.threadId,
    payloadJson: payloadJson ?? this.payloadJson,
    sortRank: sortRank ?? this.sortRank,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedForYouFeedItem copyWithCompanion(CachedForYouFeedItemsCompanion data) {
    return CachedForYouFeedItem(
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      sortRank: data.sortRank.present ? data.sortRank.value : this.sortRank,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedForYouFeedItem(')
          ..write('threadId: $threadId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('sortRank: $sortRank, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(threadId, payloadJson, sortRank, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedForYouFeedItem &&
          other.threadId == this.threadId &&
          other.payloadJson == this.payloadJson &&
          other.sortRank == this.sortRank &&
          other.cachedAt == this.cachedAt);
}

class CachedForYouFeedItemsCompanion
    extends UpdateCompanion<CachedForYouFeedItem> {
  final Value<String> threadId;
  final Value<String> payloadJson;
  final Value<int> sortRank;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedForYouFeedItemsCompanion({
    this.threadId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.sortRank = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedForYouFeedItemsCompanion.insert({
    required String threadId,
    required String payloadJson,
    required int sortRank,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : threadId = Value(threadId),
       payloadJson = Value(payloadJson),
       sortRank = Value(sortRank),
       cachedAt = Value(cachedAt);
  static Insertable<CachedForYouFeedItem> custom({
    Expression<String>? threadId,
    Expression<String>? payloadJson,
    Expression<int>? sortRank,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (threadId != null) 'thread_id': threadId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (sortRank != null) 'sort_rank': sortRank,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedForYouFeedItemsCompanion copyWith({
    Value<String>? threadId,
    Value<String>? payloadJson,
    Value<int>? sortRank,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedForYouFeedItemsCompanion(
      threadId: threadId ?? this.threadId,
      payloadJson: payloadJson ?? this.payloadJson,
      sortRank: sortRank ?? this.sortRank,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (sortRank.present) {
      map['sort_rank'] = Variable<int>(sortRank.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedForYouFeedItemsCompanion(')
          ..write('threadId: $threadId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('sortRank: $sortRank, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CommunitiesLocalDatabase extends GeneratedDatabase {
  _$CommunitiesLocalDatabase(QueryExecutor e) : super(e);
  $CommunitiesLocalDatabaseManager get managers =>
      $CommunitiesLocalDatabaseManager(this);
  late final $CachedCommunitiesTable cachedCommunities =
      $CachedCommunitiesTable(this);
  late final $CachedForYouFeedItemsTable cachedForYouFeedItems =
      $CachedForYouFeedItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedCommunities,
    cachedForYouFeedItems,
  ];
}

typedef $$CachedCommunitiesTableCreateCompanionBuilder =
    CachedCommunitiesCompanion Function({
      required String id,
      required String payloadJson,
      Value<bool> isJoined,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedCommunitiesTableUpdateCompanionBuilder =
    CachedCommunitiesCompanion Function({
      Value<String> id,
      Value<String> payloadJson,
      Value<bool> isJoined,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedCommunitiesTableFilterComposer
    extends Composer<_$CommunitiesLocalDatabase, $CachedCommunitiesTable> {
  $$CachedCommunitiesTableFilterComposer({
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

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isJoined => $composableBuilder(
    column: $table.isJoined,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedCommunitiesTableOrderingComposer
    extends Composer<_$CommunitiesLocalDatabase, $CachedCommunitiesTable> {
  $$CachedCommunitiesTableOrderingComposer({
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

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isJoined => $composableBuilder(
    column: $table.isJoined,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedCommunitiesTableAnnotationComposer
    extends Composer<_$CommunitiesLocalDatabase, $CachedCommunitiesTable> {
  $$CachedCommunitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isJoined =>
      $composableBuilder(column: $table.isJoined, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedCommunitiesTableTableManager
    extends
        RootTableManager<
          _$CommunitiesLocalDatabase,
          $CachedCommunitiesTable,
          CachedCommunity,
          $$CachedCommunitiesTableFilterComposer,
          $$CachedCommunitiesTableOrderingComposer,
          $$CachedCommunitiesTableAnnotationComposer,
          $$CachedCommunitiesTableCreateCompanionBuilder,
          $$CachedCommunitiesTableUpdateCompanionBuilder,
          (
            CachedCommunity,
            BaseReferences<
              _$CommunitiesLocalDatabase,
              $CachedCommunitiesTable,
              CachedCommunity
            >,
          ),
          CachedCommunity,
          PrefetchHooks Function()
        > {
  $$CachedCommunitiesTableTableManager(
    _$CommunitiesLocalDatabase db,
    $CachedCommunitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedCommunitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedCommunitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedCommunitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<bool> isJoined = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCommunitiesCompanion(
                id: id,
                payloadJson: payloadJson,
                isJoined: isJoined,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payloadJson,
                Value<bool> isJoined = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedCommunitiesCompanion.insert(
                id: id,
                payloadJson: payloadJson,
                isJoined: isJoined,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedCommunitiesTable, CachedCommunity>(table),
                  BaseReferences<
                    _$CommunitiesLocalDatabase,
                    $CachedCommunitiesTable,
                    CachedCommunity
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedCommunitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$CommunitiesLocalDatabase,
      $CachedCommunitiesTable,
      CachedCommunity,
      $$CachedCommunitiesTableFilterComposer,
      $$CachedCommunitiesTableOrderingComposer,
      $$CachedCommunitiesTableAnnotationComposer,
      $$CachedCommunitiesTableCreateCompanionBuilder,
      $$CachedCommunitiesTableUpdateCompanionBuilder,
      (
        CachedCommunity,
        BaseReferences<
          _$CommunitiesLocalDatabase,
          $CachedCommunitiesTable,
          CachedCommunity
        >,
      ),
      CachedCommunity,
      PrefetchHooks Function()
    >;
typedef $$CachedForYouFeedItemsTableCreateCompanionBuilder =
    CachedForYouFeedItemsCompanion Function({
      required String threadId,
      required String payloadJson,
      required int sortRank,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedForYouFeedItemsTableUpdateCompanionBuilder =
    CachedForYouFeedItemsCompanion Function({
      Value<String> threadId,
      Value<String> payloadJson,
      Value<int> sortRank,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedForYouFeedItemsTableFilterComposer
    extends Composer<_$CommunitiesLocalDatabase, $CachedForYouFeedItemsTable> {
  $$CachedForYouFeedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortRank => $composableBuilder(
    column: $table.sortRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedForYouFeedItemsTableOrderingComposer
    extends Composer<_$CommunitiesLocalDatabase, $CachedForYouFeedItemsTable> {
  $$CachedForYouFeedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortRank => $composableBuilder(
    column: $table.sortRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedForYouFeedItemsTableAnnotationComposer
    extends Composer<_$CommunitiesLocalDatabase, $CachedForYouFeedItemsTable> {
  $$CachedForYouFeedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortRank =>
      $composableBuilder(column: $table.sortRank, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedForYouFeedItemsTableTableManager
    extends
        RootTableManager<
          _$CommunitiesLocalDatabase,
          $CachedForYouFeedItemsTable,
          CachedForYouFeedItem,
          $$CachedForYouFeedItemsTableFilterComposer,
          $$CachedForYouFeedItemsTableOrderingComposer,
          $$CachedForYouFeedItemsTableAnnotationComposer,
          $$CachedForYouFeedItemsTableCreateCompanionBuilder,
          $$CachedForYouFeedItemsTableUpdateCompanionBuilder,
          (
            CachedForYouFeedItem,
            BaseReferences<
              _$CommunitiesLocalDatabase,
              $CachedForYouFeedItemsTable,
              CachedForYouFeedItem
            >,
          ),
          CachedForYouFeedItem,
          PrefetchHooks Function()
        > {
  $$CachedForYouFeedItemsTableTableManager(
    _$CommunitiesLocalDatabase db,
    $CachedForYouFeedItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedForYouFeedItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CachedForYouFeedItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedForYouFeedItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> threadId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> sortRank = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedForYouFeedItemsCompanion(
                threadId: threadId,
                payloadJson: payloadJson,
                sortRank: sortRank,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String threadId,
                required String payloadJson,
                required int sortRank,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedForYouFeedItemsCompanion.insert(
                threadId: threadId,
                payloadJson: payloadJson,
                sortRank: sortRank,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CachedForYouFeedItemsTable,
                    CachedForYouFeedItem
                  >(table),
                  BaseReferences<
                    _$CommunitiesLocalDatabase,
                    $CachedForYouFeedItemsTable,
                    CachedForYouFeedItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedForYouFeedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$CommunitiesLocalDatabase,
      $CachedForYouFeedItemsTable,
      CachedForYouFeedItem,
      $$CachedForYouFeedItemsTableFilterComposer,
      $$CachedForYouFeedItemsTableOrderingComposer,
      $$CachedForYouFeedItemsTableAnnotationComposer,
      $$CachedForYouFeedItemsTableCreateCompanionBuilder,
      $$CachedForYouFeedItemsTableUpdateCompanionBuilder,
      (
        CachedForYouFeedItem,
        BaseReferences<
          _$CommunitiesLocalDatabase,
          $CachedForYouFeedItemsTable,
          CachedForYouFeedItem
        >,
      ),
      CachedForYouFeedItem,
      PrefetchHooks Function()
    >;

class $CommunitiesLocalDatabaseManager {
  final _$CommunitiesLocalDatabase _db;
  $CommunitiesLocalDatabaseManager(this._db);
  $$CachedCommunitiesTableTableManager get cachedCommunities =>
      $$CachedCommunitiesTableTableManager(_db, _db.cachedCommunities);
  $$CachedForYouFeedItemsTableTableManager get cachedForYouFeedItems =>
      $$CachedForYouFeedItemsTableTableManager(_db, _db.cachedForYouFeedItems);
}
