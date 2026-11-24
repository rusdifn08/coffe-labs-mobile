import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/smart_scale_model.dart';

/// Persists Smart Scale brew curves & telemetry logs locally.
class ScaleBrewHistoryService {
  static const String _storageKey = 'coffee_labs_scale_brew_logs_v1';
  static const int _maxLogs = 50;
  static const int _maxStoredPoints = 240;

  static final ValueNotifier<List<ScaleBrewLog>> logsNotifier =
      ValueNotifier<List<ScaleBrewLog>>([]);

  static bool _loaded = false;

  static Future<List<ScaleBrewLog>> loadLogs({bool forceRefresh = false}) async {
    if (_loaded && !forceRefresh) return logsNotifier.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = json.decode(raw);
        if (decoded is List) {
          final parsed = decoded
              .whereType<Map>()
              .map((m) => ScaleBrewLog.fromJson(Map<String, dynamic>.from(m)))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          logsNotifier.value = parsed;
        }
      } else {
        logsNotifier.value = [];
      }
      _loaded = true;
    } catch (e) {
      debugPrint('ScaleBrewHistoryService.loadLogs error: $e');
    }
    return logsNotifier.value;
  }

  static Future<ScaleBrewLog> saveLog(ScaleBrewLog log) async {
    await loadLogs();
    final compactPoints = _downsamplePoints(log.points, _maxStoredPoints);
    final sanitized = ScaleBrewLog(
      id: log.id,
      createdAt: log.createdAt,
      mode: log.mode,
      recipeTitle: log.recipeTitle,
      methodName: log.methodName,
      deviceName: log.deviceName,
      coffeeDoseGrams: log.coffeeDoseGrams,
      targetWaterGrams: log.targetWaterGrams,
      finalWeightGrams: log.finalWeightGrams,
      durationSeconds: log.durationSeconds,
      avgFlowRate: log.avgFlowRate,
      peakFlowRate: log.peakFlowRate,
      points: compactPoints,
      notes: log.notes,
    );

    final updated = [
      sanitized,
      ...logsNotifier.value.where((e) => e.id != sanitized.id),
    ].take(_maxLogs).toList();

    logsNotifier.value = updated;
    await _persist(updated);
    return sanitized;
  }

  static Future<void> deleteLog(String id) async {
    await loadLogs();
    final updated = logsNotifier.value.where((e) => e.id != id).toList();
    logsNotifier.value = updated;
    await _persist(updated);
  }

  static Future<void> _persist(List<ScaleBrewLog> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(logs.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('ScaleBrewHistoryService._persist error: $e');
    }
  }

  static List<WeightDataPoint> _downsamplePoints(
    List<WeightDataPoint> source,
    int maxCount,
  ) {
    if (source.length <= maxCount) return List<WeightDataPoint>.from(source);
    final result = <WeightDataPoint>[];
    final step = (source.length - 1) / (maxCount - 1);
    for (int i = 0; i < maxCount; i++) {
      final idx = (i * step).round().clamp(0, source.length - 1);
      result.add(source[idx]);
    }
    return result;
  }

  @visibleForTesting
  static void resetMemoryCache() {
    _loaded = false;
    logsNotifier.value = [];
  }
}
