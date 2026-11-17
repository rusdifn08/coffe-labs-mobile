import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/active_long_brew_batch.dart';

/// Layanan Alarm Latar Belakang Persisten untuk Cold Brew, Cold Drip, & French Press Sediment.
/// Menggunakan `AndroidScheduleMode.alarmClock` (Android), Time-Sensitive Notification (iOS),
/// SharedPreferences Store lokal (bertahan setelah app kill/reboot), dan sinkronisasi server FCM.
class NativePersistentAlarmService {
  NativePersistentAlarmService._();
  static final NativePersistentAlarmService instance =
      NativePersistentAlarmService._();

  static const String _storageKey = 'cold_brew_active_batches_v1';
  static const String alarmChannelId = 'cold_brew_alarm_critical_v1';
  static const String alarmChannelName = 'Alarm Selesai Cold Brew';
  static const String alarmChannelDesc =
      'Notifikasi prioritas maksimal agar ekstraksi Cold Brew & Kyoto Drip disaring tepat waktu.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _alarmTapCtrl =
      StreamController<String>.broadcast();
  bool _initialized = false;
  bool _tzInitialized = false;
  Dio? _dio;

  Stream<String> get alarmTapStream => _alarmTapCtrl.stream;

  static bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  static bool get _supportsScheduledNotifications =>
      !kIsWeb &&
      !_isTestEnv &&
      (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  void attachDio(Dio dio) {
    _dio = dio;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!_tzInitialized) {
      tz_data.initializeTimeZones();
      _tzInitialized = true;
    }

    if (!_supportsScheduledNotifications) return;

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: android,
          iOS: darwin,
          macOS: darwin,
        ),
        onDidReceiveNotificationResponse: (resp) {
          final raw = resp.payload;
          if (raw != null && raw.startsWith('/brew/cold-brew-alarm/')) {
            _alarmTapCtrl.add(raw);
          }
        },
      );

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          alarmChannelId,
          alarmChannelName,
          description: alarmChannelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );
      await androidImpl?.requestExactAlarmsPermission();
      await androidImpl?.requestNotificationsPermission();
    } catch (_) {}

    await rescheduleAllActiveAlarms();
  }

  Future<List<ActiveLongBrewBatch>> loadBatches() async {
    final prefs = await SharedPreferences.getInstance();
    final list = ActiveLongBrewBatch.decodeList(prefs.getString(_storageKey));
    final now = DateTime.now();
    return list.map((b) {
      if ((b.status == 'ACTIVE' || b.status == 'SNOOZED') &&
          !b.targetFinishAt.isAfter(now)) {
        return b.copyWith(status: 'RINGING');
      }
      return b;
    }).toList();
  }

  Future<void> _saveBatches(List<ActiveLongBrewBatch> batches) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(batches.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<List<ActiveLongBrewBatch>> scheduleBatch(
    ActiveLongBrewBatch batch,
  ) async {
    await initialize();
    var finalBatch = batch;

    // Best-effort sinkronisasi ke PostgreSQL + Redis ZSET + FCM Backup Server
    if (_dio != null && !_isTestEnv) {
      try {
        final res = await _dio!.post<Map<String, dynamic>>(
          '/api/v1/brew/long-alarms',
          data: {
            'recipe_id': batch.recipeId,
            'recipe_title': batch.recipeTitle,
            'method_slug': batch.methodSlug,
            'brew_mode': batch.brewMode,
            'coffee_dose_g': batch.coffeeDoseG,
            'water_ml': batch.waterMl,
            'ambient_temp_c': batch.ambientTempC,
            'drip_rate_bpm': batch.dripRateBpm,
            'duration_seconds': batch.totalDurationSec,
          },
        );
        final serverId = res.data?['data']?['id']?.toString();
        if (serverId != null && serverId.isNotEmpty) {
          finalBatch = finalBatch.copyWith(serverAlarmId: serverId);
        }
      } catch (_) {}
    }

    final existing = await loadBatches();
    final updated = [
      finalBatch,
      ...existing.where((e) => e.id != finalBatch.id),
    ];
    await _saveBatches(updated);
    await _scheduleOsAlarmForBatch(finalBatch);
    return updated;
  }

  Future<List<ActiveLongBrewBatch>> snoozeBatch(
    String batchId, {
    int minutes = 15,
  }) async {
    await stopRingingTone();
    final existing = await loadBatches();
    final newFinish = DateTime.now().add(Duration(minutes: minutes));
    final updated = <ActiveLongBrewBatch>[];
    ActiveLongBrewBatch? target;

    for (final b in existing) {
      if (b.id == batchId) {
        final next = b.copyWith(
          targetFinishAt: newFinish,
          status: 'SNOOZED',
          snoozeCount: b.snoozeCount + 1,
        );
        target = next;
        updated.add(next);
      } else {
        updated.add(b);
      }
    }

    await _saveBatches(updated);
    if (target != null) {
      await _scheduleOsAlarmForBatch(target);
      if (target.serverAlarmId != null && _dio != null && !_isTestEnv) {
        unawaited(_fireBestEffort(() async {
          await _dio!.post<dynamic>(
            '/api/v1/brew/long-alarms/${target!.serverAlarmId}/snooze',
            data: {'snooze_minutes': minutes},
          );
        }));
      }
    }
    return updated;
  }

  Future<List<ActiveLongBrewBatch>> completeOrCancelBatch(
    String batchId, {
    bool completed = true,
  }) async {
    await stopRingingTone();
    final existing = await loadBatches();
    final target = existing.where((e) => e.id == batchId).firstOrNull;
    final remaining = existing.where((e) => e.id != batchId).toList();
    await _saveBatches(remaining);

    if (target != null) {
      await _cancelOsAlarmsForBatch(target);
      if (target.serverAlarmId != null && _dio != null && !_isTestEnv) {
        unawaited(_fireBestEffort(() async {
          if (completed) {
            await _dio!.post<dynamic>(
              '/api/v1/brew/long-alarms/${target.serverAlarmId}/complete',
            );
          } else {
            await _dio!.delete<dynamic>(
              '/api/v1/brew/long-alarms/${target.serverAlarmId}',
            );
          }
        }));
      }
    }
    return remaining;
  }

  Future<void> _fireBestEffort(Future<void> Function() task) async {
    try {
      await task();
    } catch (_) {}
  }

  Future<void> rescheduleAllActiveAlarms() async {
    if (!_supportsScheduledNotifications) return;
    final batches = await loadBatches();
    final now = DateTime.now();
    for (final b in batches) {
      if ((b.status == 'ACTIVE' || b.status == 'SNOOZED') &&
          b.targetFinishAt.isAfter(now)) {
        await _scheduleOsAlarmForBatch(b);
      }
    }
  }

  Future<void> playRingingTone() async {
    if (_isTestEnv || kIsWeb) return;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await FlutterRingtonePlayer().playAlarm(
          looping: true,
          volume: 0.9,
          asAlarm: true,
        );
      }
    } catch (_) {}
  }

  Future<void> stopRingingTone() async {
    if (_isTestEnv || kIsWeb) return;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await FlutterRingtonePlayer().stop();
      }
    } catch (_) {}
  }

  Future<void> _scheduleOsAlarmForBatch(ActiveLongBrewBatch batch) async {
    if (!_supportsScheduledNotifications) return;
    try {
      final finishTz = tz.TZDateTime.from(batch.targetFinishAt.toUtc(), tz.UTC);
      final details = NotificationDetails(
        android: const AndroidNotificationDetails(
          alarmChannelId,
          alarmChannelName,
          channelDescription: alarmChannelDesc,
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          autoCancel: false,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

      await _plugin.zonedSchedule(
        id: batch.notificationId,
        title: 'Saring Cold Brew Sekarang!',
        body:
            '${batch.recipeTitle} (${batch.coffeeDoseG.toStringAsFixed(0)}g : ${batch.waterMl.toStringAsFixed(0)}ml) telah selesai tepat waktu.',
        scheduledDate: finishTz,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: '/brew/cold-brew-alarm/${batch.id}',
      );

      // Checkpoint 1 jam agitasi kerak bila durasi >= 6 jam
      final checkpointAt = batch.startedAt.add(const Duration(hours: 1));
      if (batch.totalDurationSec >= 21600 &&
          checkpointAt.isBefore(batch.targetFinishAt) &&
          checkpointAt.isAfter(DateTime.now())) {
        await _plugin.zonedSchedule(
          id: batch.notificationId ^ 0x10203,
          title: 'Checkpoint 1 Jam Cold Brew',
          body:
              'Tekan perlahan crust bubuk ${batch.recipeTitle} yang mengapung agar ekstraksi merata.',
          scheduledDate: tz.TZDateTime.from(checkpointAt.toUtc(), tz.UTC),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: '/brew/cold-brew-alarm/${batch.id}',
        );
      }
    } catch (_) {}
  }

  Future<void> _cancelOsAlarmsForBatch(ActiveLongBrewBatch batch) async {
    if (!_supportsScheduledNotifications) return;
    try {
      await _plugin.cancel(id: batch.notificationId);
      await _plugin.cancel(id: batch.notificationId ^ 0x10203);
    } catch (_) {}
  }
}
