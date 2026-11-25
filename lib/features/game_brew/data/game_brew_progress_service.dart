import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/user_scoped_storage.dart';
import '../domain/game_brew_studio_models.dart';
import 'game_brew_curriculum_catalog.dart';

/// Persists stars, best physics scores, and level unlocks for both
/// Manual Brew 3D and Latte Art 3D (Adventure + Direct Technique Drills),
/// strictly isolated per user (`u_<userId>_*`) and synced via `UserCloudSyncService`.
class GameBrewProgressService {
  static const String _storageKey = 'coffee_labs_game_brew_3d_progress_v2';

  static final ValueNotifier<Map<String, LevelProgressRecord>> progressNotifier =
      ValueNotifier<Map<String, LevelProgressRecord>>({});

  static bool _loaded = false;
  static String? _loadedForUserId;

  static Future<Map<String, LevelProgressRecord>> load({
    bool forceRefresh = false,
    String? userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = (userId != null && userId.trim().isNotEmpty)
          ? UserScopedStorage.normalizeUserId(userId)
          : await UserScopedStorage.resolveActiveUserId(prefs: prefs);

      if (_loaded && !forceRefresh && _loadedForUserId == uid) {
        return progressNotifier.value;
      }

      final scopedKey = UserScopedStorage.scopedKey(_storageKey, userId: uid);
      var raw = prefs.getString(scopedKey);

      // Migrate legacy global key once for the active user if scoped key is empty.
      if ((raw == null || raw.isEmpty) && uid != UserScopedStorage.guestScope) {
        final legacyRaw = prefs.getString(_storageKey);
        if (legacyRaw != null && legacyRaw.isNotEmpty) {
          raw = legacyRaw;
          await prefs.setString(scopedKey, legacyRaw);
          await prefs.remove(_storageKey);
        }
      }

      progressNotifier.value = _decodeProgressMap(raw);
      _loaded = true;
      _loadedForUserId = uid;
    } catch (e) {
      debugPrint('GameBrewProgressService.load error: $e');
    }
    return progressNotifier.value;
  }

  static Map<String, LevelProgressRecord> _decodeProgressMap(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        final parsed = <String, LevelProgressRecord>{};
        decoded.forEach((key, value) {
          if (value is Map) {
            parsed[key.toString()] = LevelProgressRecord.fromJson(
              Map<String, dynamic>.from(value),
            );
          }
        });
        return parsed;
      }
    } catch (_) {}
    return {};
  }

  static Future<LevelProgressRecord> recordRun({
    required String levelCode,
    required int stars,
    required double scorePct,
    required Map<String, double> metrics,
    String? userId,
  }) async {
    await load(userId: userId);
    final current = Map<String, LevelProgressRecord>.from(progressNotifier.value);
    final prev = current[levelCode];
    final clampedStars = stars.clamp(0, 3);

    final updated = LevelProgressRecord(
      code: levelCode,
      stars: prev == null ? clampedStars : (clampedStars > prev.stars ? clampedStars : prev.stars),
      bestScorePct: prev == null
          ? scorePct
          : (scorePct > prev.bestScorePct ? scorePct : prev.bestScorePct),
      bestMetrics: (prev == null || scorePct >= prev.bestScorePct)
          ? metrics
          : prev.bestMetrics,
      attempts: (prev?.attempts ?? 0) + 1,
      updatedAt: DateTime.now(),
    );

    current[levelCode] = updated;
    progressNotifier.value = current;
    await _persist(current, userId: userId);
    UserScopedStorage.notifyDataMutated();
    return updated;
  }

  /// Exports scoped Game Brew 3D progress map for `UserCloudSyncService`.
  static Future<Map<String, dynamic>> exportCloudProgress({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = (userId != null && userId.trim().isNotEmpty)
        ? UserScopedStorage.normalizeUserId(userId)
        : await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    final raw = prefs.getString(UserScopedStorage.scopedKey(_storageKey, userId: uid));
    final map = _decodeProgressMap(raw);
    return map.map((k, v) => MapEntry(k, v.toJson()));
  }

  /// Merges cloud Game Brew 3D progress into the user's scoped partition (max stars & score).
  static Future<bool> applyCloudProgress({
    required String userId,
    required Map<String, dynamic> cloudProgress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = UserScopedStorage.normalizeUserId(userId);
    final scopedKey = UserScopedStorage.scopedKey(_storageKey, userId: uid);
    final localMap = _decodeProgressMap(prefs.getString(scopedKey));

    final merged = Map<String, LevelProgressRecord>.from(localMap);
    bool localAhead = false;

    final cloudParsed = <String, LevelProgressRecord>{};
    cloudProgress.forEach((key, val) {
      if (val is Map) {
        cloudParsed[key] = LevelProgressRecord.fromJson(Map<String, dynamic>.from(val));
      }
    });

    cloudParsed.forEach((code, cloudRec) {
      final localRec = merged[code];
      if (localRec == null) {
        merged[code] = cloudRec;
      } else {
        final maxStars = localRec.stars > cloudRec.stars ? localRec.stars : cloudRec.stars;
        final maxScore =
            localRec.bestScorePct > cloudRec.bestScorePct ? localRec.bestScorePct : cloudRec.bestScorePct;
        final maxAttempts = localRec.attempts > cloudRec.attempts ? localRec.attempts : cloudRec.attempts;
        if (localRec.stars > cloudRec.stars || localRec.bestScorePct > cloudRec.bestScorePct) {
          localAhead = true;
        }
        merged[code] = LevelProgressRecord(
          code: code,
          stars: maxStars,
          bestScorePct: maxScore,
          bestMetrics: localRec.bestScorePct >= cloudRec.bestScorePct
              ? localRec.bestMetrics
              : cloudRec.bestMetrics,
          attempts: maxAttempts,
          updatedAt: localRec.updatedAt.isAfter(cloudRec.updatedAt)
              ? localRec.updatedAt
              : cloudRec.updatedAt,
        );
      }
    });

    for (final code in localMap.keys) {
      if (!cloudParsed.containsKey(code)) {
        localAhead = true;
      }
    }

    final payload = merged.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(scopedKey, json.encode(payload));

    if (_loadedForUserId == uid || UserScopedStorage.activeUserId == uid) {
      progressNotifier.value = merged;
      _loaded = true;
      _loadedForUserId = uid;
    }
    return localAhead;
  }

  /// Resets in-memory cache when switching/logging out accounts.
  static void notifySessionSwitched() {
    _loaded = false;
    _loadedForUserId = null;
    progressNotifier.value = {};
  }

  static bool isLevelUnlocked(GameBrewLevelSpec spec) {
    if (spec.isDirectDrill || spec.levelNumber <= 1) return true;
    final list = GameBrewCurriculumCatalog.adventureFor(spec.discipline);
    final prevIdx = spec.levelNumber - 2;
    if (prevIdx < 0 || prevIdx >= list.length) return true;
    final prevCode = list[prevIdx].code;
    final prevRec = progressNotifier.value[prevCode];
    return (prevRec?.stars ?? 0) >= 1;
  }

  static int totalStarsFor(GameBrewDiscipline discipline) {
    final list = GameBrewCurriculumCatalog.adventureFor(discipline);
    int total = 0;
    for (final lvl in list) {
      total += progressNotifier.value[lvl.code]?.stars ?? 0;
    }
    return total;
  }

  static int completedLevelsFor(GameBrewDiscipline discipline) {
    final list = GameBrewCurriculumCatalog.adventureFor(discipline);
    int count = 0;
    for (final lvl in list) {
      if ((progressNotifier.value[lvl.code]?.stars ?? 0) >= 1) count++;
    }
    return count;
  }

  static int get totalCombinedStars =>
      totalStarsFor(GameBrewDiscipline.manualBrew3d) +
      totalStarsFor(GameBrewDiscipline.latteArt3d);

  static Future<void> _persist(Map<String, LevelProgressRecord> map, {String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = (userId != null && userId.trim().isNotEmpty)
          ? UserScopedStorage.normalizeUserId(userId)
          : await UserScopedStorage.resolveActiveUserId(prefs: prefs);
      final payload = map.map((k, v) => MapEntry(k, v.toJson()));
      await prefs.setString(
        UserScopedStorage.scopedKey(_storageKey, userId: uid),
        json.encode(payload),
      );
      _loadedForUserId = uid;
    } catch (e) {
      debugPrint('GameBrewProgressService._persist error: $e');
    }
  }

  @visibleForTesting
  static void resetMemoryCache() {
    _loaded = false;
    _loadedForUserId = null;
    progressNotifier.value = {};
  }
}
