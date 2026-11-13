import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/community_models.dart';

part 'communities_local_cache.g.dart';

class CachedCommunities extends Table {
  TextColumn get id => text()();
  TextColumn get payloadJson => text()();
  BoolColumn get isJoined => boolean().withDefault(const Constant(false))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedForYouFeedItems extends Table {
  TextColumn get threadId => text()();
  TextColumn get payloadJson => text()();
  IntColumn get sortRank => integer()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {threadId};
}

@DriftDatabase(tables: [CachedCommunities, CachedForYouFeedItems])
class CommunitiesLocalDatabase extends _$CommunitiesLocalDatabase {
  CommunitiesLocalDatabase([QueryExecutor? executor])
      : super(executor ?? _openNative());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openNative() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'coffee_labs_communities_v1.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  Future<void> cacheMyClubs(List<CommunitySummary> clubs) async {
    final now = DateTime.now();
    await transaction(() async {
      await (delete(cachedCommunities)
            ..where((t) => t.isJoined.equals(true)))
          .go();
      for (final club in clubs) {
        await into(cachedCommunities).insertOnConflictUpdate(
          CachedCommunitiesCompanion.insert(
            id: club.id,
            payloadJson: jsonEncode(club.toJson()),
            isJoined: const Value(true),
            cachedAt: now,
          ),
        );
      }
    });
  }

  Future<List<CommunitySummary>> loadCachedMyClubs() async {
    final rows = await (select(cachedCommunities)
          ..where((t) => t.isJoined.equals(true)))
        .get();
    final out = <CommunitySummary>[];
    for (final row in rows) {
      try {
        final decoded =
            Map<String, dynamic>.from(jsonDecode(row.payloadJson) as Map);
        out.add(CommunitySummary.fromJson(decoded));
      } catch (_) {}
    }
    return out;
  }
}
