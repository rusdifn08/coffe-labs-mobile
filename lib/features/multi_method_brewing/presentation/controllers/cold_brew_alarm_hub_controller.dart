import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/native_persistent_alarm_service.dart';
import '../../domain/active_long_brew_batch.dart';

final coldBrewAlarmHubProvider =
    NotifierProvider<ColdBrewAlarmHubController, List<ActiveLongBrewBatch>>(
  ColdBrewAlarmHubController.new,
);

class ColdBrewAlarmHubController extends Notifier<List<ActiveLongBrewBatch>> {
  Timer? _tickTimer;

  static bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  List<ActiveLongBrewBatch> build() {
    NativePersistentAlarmService.instance.attachDio(ref.watch(dioClientProvider));

    if (!_isTestEnv) {
      unawaited(hydrate());
      _tickTimer?.cancel();
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _checkDueAndTick();
      });
    }

    ref.onDispose(() {
      _tickTimer?.cancel();
    });
    return const [];
  }

  Future<void> hydrate() async {
    await NativePersistentAlarmService.instance.initialize();
    final loaded = await NativePersistentAlarmService.instance.loadBatches();
    state = loaded;
  }

  void _checkDueAndTick() {
    if (state.isEmpty) return;
    final now = DateTime.now();
    bool hasNewlyRinging = false;
    final nextList = <ActiveLongBrewBatch>[];

    for (final b in state) {
      if ((b.status == 'ACTIVE' || b.status == 'SNOOZED') &&
          !b.targetFinishAt.isAfter(now)) {
        hasNewlyRinging = true;
        nextList.add(b.copyWith(status: 'RINGING'));
      } else {
        nextList.add(b);
      }
    }

    state = nextList;
    if (hasNewlyRinging) {
      unawaited(NativePersistentAlarmService.instance.playRingingTone());
    }
  }

  Future<ActiveLongBrewBatch> scheduleBatch({
    int? recipeId,
    required String recipeTitle,
    required String methodSlug,
    required String brewMode,
    required double coffeeDoseG,
    required double waterMl,
    required double ambientTempC,
    int? dripRateBpm,
    required Duration duration,
    Map<String, dynamic>? recipeSnapshot,
  }) async {
    final now = DateTime.now();
    final batch = ActiveLongBrewBatch(
      id: 'cb_${now.millisecondsSinceEpoch}_${recipeTitle.hashCode & 0xfff}',
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      methodSlug: methodSlug,
      brewMode: brewMode,
      coffeeDoseG: coffeeDoseG,
      waterMl: waterMl,
      ambientTempC: ambientTempC,
      dripRateBpm: dripRateBpm,
      startedAt: now,
      targetFinishAt: now.add(duration),
      totalDurationSec: duration.inSeconds,
      status: 'ACTIVE',
      recipeSnapshot: recipeSnapshot,
    );

    final updated =
        await NativePersistentAlarmService.instance.scheduleBatch(batch);
    state = updated;
    return updated.firstWhere((e) => e.id == batch.id, orElse: () => batch);
  }

  Future<void> snoozeBatch(String batchId, {int minutes = 15}) async {
    state = await NativePersistentAlarmService.instance.snoozeBatch(
      batchId,
      minutes: minutes,
    );
  }

  Future<void> completeBatch(String batchId) async {
    state = await NativePersistentAlarmService.instance.completeOrCancelBatch(
      batchId,
      completed: true,
    );
  }

  Future<void> cancelBatch(String batchId) async {
    state = await NativePersistentAlarmService.instance.completeOrCancelBatch(
      batchId,
      completed: false,
    );
  }
}
