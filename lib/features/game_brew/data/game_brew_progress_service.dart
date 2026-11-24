import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/game_brew_studio_models.dart';
import 'game_brew_curriculum_catalog.dart';

/// Persists stars, best physics scores, and level unlocks for both
/// Manual Brew 3D and Latte Art 3D (Adventure + Direct Technique Drills).
class GameBrewProgressService {
  static const String _storageKey = 'coffee_labs_game_brew_3d_progress_v2';

  static final ValueNotifier<Map<String, LevelProgressRecord>> progressNotifier =
      ValueNotifier<Map<String, LevelProgressRecord>>({});

  static bool _loaded = false;

  static Future<Map<String, LevelProgressRecord>> load({
    bool forceRefresh = false,
  }) async {
    if (_loaded && !forceRefresh) return progressNotifier.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
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
          progressNotifier.value = parsed;
        }
      } else {
        progressNotifier.value = {};
      }
      _loaded = true;
    } catch (e) {
      debugPrint('GameBrewProgressService.load error: $e');
    }
    return progressNotifier.value;
  }

  static Future<LevelProgressRecord> recordRun({
    required String levelCode,
    required int stars,
    required double scorePct,
    required Map<String, double> metrics,
  }) async {
    await load();
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
    await _persist(current);
    return updated;
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

  static Future<void> _persist(Map<String, LevelProgressRecord> map) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = map.map((k, v) => MapEntry(k, v.toJson()));
      await prefs.setString(_storageKey, json.encode(payload));
    } catch (e) {
      debugPrint('GameBrewProgressService._persist error: $e');
    }
  }

  @visibleForTesting
  static void resetMemoryCache() {
    _loaded = false;
    progressNotifier.value = {};
  }
}
