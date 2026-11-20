import 'dart:async';
import 'package:dio/dio.dart';
import '../models/coffee_level.dart';
import '../models/gamification_reward_delta.dart';
import 'gamification_service.dart';

/// Monotonic Stopwatch-backed tracker for True Proof-of-Brew Validation.
/// Prevents clock tampering and fake click-based brew counts.
class VerifiedBrewSessionTracker {
  final Dio _dio;
  final Stopwatch _activeWatch = Stopwatch();
  final Stopwatch _pausedWatch = Stopwatch();
  String? _sessionId;
  int _completedStepsMask = 0;

  VerifiedBrewSessionTracker(this._dio);

  Future<void> startSession({
    required String methodId,
    required String methodDisplayName,
    required String archetype,
    required String recipeId,
    required String recipeTitle,
    required int targetDurationSec,
    required int totalStepsCount,
    String? beanName,
    String? roasteryName,
  }) async {
    _activeWatch
      ..reset()
      ..start();
    _pausedWatch
      ..reset()
      ..stop();
    _completedStepsMask = 0;

    try {
      final res = await _dio.post(
        '/api/v1/gamification/brews/start',
        data: {
          'method_id': methodId,
          'method_display_name': methodDisplayName,
          'archetype': archetype,
          'recipe_id': recipeId,
          'recipe_title': recipeTitle,
          'target_duration_sec': targetDurationSec.clamp(15, 86400),
          'total_steps_count': totalStepsCount.clamp(1, 30),
          if (beanName != null) 'bean_name': beanName,
          if (roasteryName != null) 'roastery_name': roasteryName,
        },
      );
      final data = res.data?['data'] as Map<String, dynamic>?;
      _sessionId = data?['session_id']?.toString();
    } catch (_) {
      _sessionId = null;
    }
  }

  void pause() {
    if (_activeWatch.isRunning) {
      _activeWatch.stop();
      _pausedWatch.start();
    }
  }

  void resume() {
    if (!_activeWatch.isRunning) {
      _pausedWatch.stop();
      _activeWatch.start();
    }
  }

  void markStepCompleted(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < 62) {
      _completedStepsMask |= (1 << stepIndex);
    }
  }

  Future<GamificationRewardDelta> completeSession({
    required String methodDisplayName,
    double? accuracyScore,
    double? coffeeDoseG,
    double? waterTotalMl,
    int? waterTempC,
  }) async {
    _activeWatch.stop();
    _pausedWatch.stop();
    final activeMs = _activeWatch.elapsedMilliseconds;
    final pausedMs = _pausedWatch.elapsedMilliseconds;

    final beforeStats = await GamificationService.instance.getStats();

    if (_sessionId != null) {
      try {
        final res = await _dio.post(
          '/api/v1/gamification/brews/$_sessionId/complete',
          data: {
            'active_elapsed_ms': activeMs,
            'paused_ms': pausedMs,
            'completed_steps_mask': _completedStepsMask,
            if (accuracyScore != null) 'accuracy_score': accuracyScore,
            if (coffeeDoseG != null) 'coffee_dose_g': coffeeDoseG,
            if (waterTotalMl != null) 'water_total_ml': waterTotalMl,
            if (waterTempC != null) 'water_temp_c': waterTempC,
          },
        );
        final data = res.data?['data'] as Map<String, dynamic>?;
        if (data != null) {
          unawaited(GamificationService.instance.recordBrewCompleted());
          return GamificationRewardDelta.fromJson(data);
        }
      } catch (_) {}
    }

    // Offline / fallback deterministic delta
    await GamificationService.instance.recordBrewCompleted();
    final afterStats = await GamificationService.instance.getStats();
    final gained = (afterStats.totalExp - beforeStats.totalExp).clamp(50, 500);
    return GamificationRewardDelta(
      sourceKind: 'VERIFIED_BREW',
      sourceLabel: 'Seduhan $methodDisplayName Selesai!',
      xpBefore: beforeStats.totalExp,
      xpGained: gained,
      xpAfter: afterStats.totalExp,
      levelBefore: beforeStats.level.level,
      levelAfter: afterStats.level.level,
      didLevelUp: afterStats.level.level > beforeStats.level.level,
      rankBefore: beforeStats.level.title,
      rankAfter: afterStats.level.title,
      progressRatioBefore: beforeStats.progress,
      progressRatioAfter: afterStats.progress,
      newStreakDays: afterStats.streakDays,
      breakdownItems: [
        XpBreakdownItem(label: 'Seduhan Selesai', xp: gained),
      ],
    );
  }
}
