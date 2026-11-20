import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, gzip;
import 'dart:typed_data' show Uint8List;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/monitoring_models.dart';

class TelemetryBatchOutboxService {
  TelemetryBatchOutboxService._();
  static final TelemetryBatchOutboxService instance = TelemetryBatchOutboxService._();

  static const String _outboxStorageKey = 'coffeehub_monitoring_outbox_v1';
  static const int _maxQueueSize = 180;
  static const int _flushBatchThreshold = 20;
  static const int maxIdleRegularSec = 180;
  static const int maxIdleBrewOrAodSec = 900;

  final Uuid _uuid = const Uuid();
  final List<TelemetryEventItem> _queue = [];
  Dio? _dio;
  Timer? _flushTimer;
  Timer? _heartbeatTimer;
  Timer? _routeHeartbeatDebounce;
  Timer? _persistDebounce;

  String _sessionId = const Uuid().v4();
  String _currentRoute = '/';
  String _currentFeature = 'general';
  bool _isBrewing = false;
  bool _isAodMode = false;
  bool _isFlushing = false;
  bool _initialized = false;
  bool _disposed = false;
  DateTime? _endpointCooldownUntil;
  String? _cooldownBaseUrl;

  static bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  void resetEndpointCooldown() {
    _endpointCooldownUntil = null;
    _cooldownBaseUrl = null;
  }

  bool get isEndpointInCooldown {
    final until = _endpointCooldownUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  int get queuedCount => _queue.length;

  bool _isInEndpointCooldown(Dio dio) {
    final activeBase = dio.options.baseUrl;
    if (_cooldownBaseUrl != null && _cooldownBaseUrl != activeBase) {
      resetEndpointCooldown();
      return false;
    }
    final until = _endpointCooldownUntil;
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      resetEndpointCooldown();
      return false;
    }
    return true;
  }

  void _triggerCooldownIfUnsupported(DioException e, Dio dio) {
    final code = e.response?.statusCode;
    if (code == 404 || code == 405) {
      _cooldownBaseUrl = e.requestOptions.baseUrl.isNotEmpty
          ? e.requestOptions.baseUrl
          : dio.options.baseUrl;
      _endpointCooldownUntil = DateTime.now().add(const Duration(minutes: 10));
    }
  }

  void attachDio(Dio dio) {
    _dio = dio;
    _disposed = false;
    if (!_initialized) {
      _initialized = true;
      unawaited(_restoreAndSchedule());
    }
  }

  Future<void> _restoreAndSchedule() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      final raw = prefs.getStringList(_outboxStorageKey);
      if (raw != null && raw.isNotEmpty) {
        for (final line in raw.take(60)) {
          try {
            final decoded = jsonDecode(line) as Map<String, dynamic>;
            _queue.add(TelemetryEventItem.fromJson(decoded));
          } catch (_) {}
        }
      }
    } catch (_) {}

    if (_disposed) return;

    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(flushNow());
    });

    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      unawaited(sendHeartbeat());
    });
  }

  static String mapRouteToFeature(String route) {
    final lower = route.toLowerCase();
    if (lower.contains('aod') || lower.contains('kiosk')) return 'aod_kiosk';
    if (lower.contains('brew/timer') || lower.contains('brew-timer') || lower.contains('smart-scale')) {
      return 'brew_timer';
    }
    if (lower.contains('social/clubs') || lower.contains('/c/')) return 'coffee_club';
    if (lower.contains('social')) return 'social_coffee';
    if (lower.contains('bean-radar') || lower.contains('dial-in') || lower.contains('in-app-trainer')) {
      return 'ai_scanner';
    }
    if (lower.contains('recipe') || lower.contains('add-recipe') || lower.contains('favorites')) {
      return 'recipe_lab';
    }
    if (lower.contains('marketplace')) return 'marketplace';
    if (lower.contains('business')) return 'business_pos';
    if (lower.contains('barista')) return 'gamification';
    return 'general';
  }

  String _platformLabel() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    return 'mobile';
  }

  void setBrewingActive(bool active) {
    _isBrewing = active;
  }

  void setAodActive(bool active) {
    _isAodMode = active;
  }

  void rotateSession() {
    _sessionId = _uuid.v4();
  }

  void updateActiveRoute(String route) {
    _currentRoute = route;
    _currentFeature = mapRouteToFeature(route);
    if (_isTestEnv) return;
    _routeHeartbeatDebounce?.cancel();
    _routeHeartbeatDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!_disposed) {
        unawaited(sendHeartbeat());
      }
    });
  }

  void enqueueScreenDwell({
    required String routeName,
    required int elapsedSeconds,
  }) {
    final feature = mapRouteToFeature(routeName);
    final isExtended = _isAodMode || feature == 'aod_kiosk' || feature == 'brew_timer' || _isBrewing;
    final cap = isExtended ? maxIdleBrewOrAodSec : maxIdleRegularSec;
    final clamped = elapsedSeconds.clamp(0, cap);
    if (clamped <= 0) return;

    _addEvent(
      TelemetryEventItem(
        eventId: _uuid.v4(),
        sessionId: _sessionId,
        eventType: 'SCREEN_VIEW',
        featureBucket: feature,
        routeName: routeName,
        durationSec: clamped,
        isAodMode: _isAodMode || feature == 'aod_kiosk',
        recordedAt: DateTime.now().toUtc(),
      ),
    );
  }

  void enqueueLifecycleEvent(String eventType, {String? routeName}) {
    final route = routeName ?? _currentRoute;
    _addEvent(
      TelemetryEventItem(
        eventId: _uuid.v4(),
        sessionId: _sessionId,
        eventType: eventType,
        featureBucket: mapRouteToFeature(route),
        routeName: route,
        durationSec: 0,
        isAodMode: _isAodMode,
        recordedAt: DateTime.now().toUtc(),
      ),
    );
  }

  void recordBrewExperiment({
    String? recipeId,
    required String recipeTitle,
    required String brewMethod,
    String? beanOrigin,
    required int durationSec,
    required bool completed,
    required int stepsCompleted,
    int? rating,
  }) {
    _addEvent(
      TelemetryEventItem(
        eventId: _uuid.v4(),
        sessionId: _sessionId,
        eventType: 'BREW_COMPLETE',
        featureBucket: 'brew_timer',
        routeName: '/brew/timer',
        durationSec: durationSec.clamp(0, maxIdleBrewOrAodSec),
        isAodMode: _isAodMode,
        metadataJson: {
          'recipe_id': ?recipeId,
          'recipe_title': recipeTitle,
          'brew_method': brewMethod,
          'bean_origin': ?beanOrigin,
          'completed': completed,
          'steps_completed': stepsCompleted,
          'rating': ?rating,
        },
        recordedAt: DateTime.now().toUtc(),
      ),
    );
  }

  void _addEvent(TelemetryEventItem item) {
    if (_queue.length >= _maxQueueSize) {
      _queue.removeAt(0);
    }
    _queue.add(item);
    if (_queue.length >= _flushBatchThreshold) {
      unawaited(flushNow());
    } else if (_isTestEnv) {
      unawaited(_persistQueueSnapshot());
    } else {
      _persistDebounce?.cancel();
      _persistDebounce = Timer(const Duration(milliseconds: 500), () {
        if (!_disposed) {
          unawaited(_persistQueueSnapshot());
        }
      });
    }
  }

  Future<void> sendHeartbeat({bool bypassTestGuard = false}) async {
    final dio = _dio;
    if (dio == null || (!bypassTestGuard && _isTestEnv) || _isInEndpointCooldown(dio)) return;
    try {
      await dio.post<dynamic>(
        '/api/v1/monitoring/heartbeat',
        data: {
          'active_route': _currentRoute,
          'feature_bucket': _currentFeature,
          'platform': _platformLabel(),
          'is_brewing': _isBrewing,
          'is_aod_mode': _isAodMode,
        },
        options: Options(extra: const {'silentTelemetry': true}),
      );
    } on DioException catch (e) {
      _triggerCooldownIfUnsupported(e, dio);
    } catch (_) {}
  }

  Future<void> flushNow({bool bypassTestGuard = false}) async {
    final dio = _dio;
    if (_isFlushing || _queue.isEmpty || dio == null) return;
    if (!bypassTestGuard && _isTestEnv) return;
    if (_isInEndpointCooldown(dio)) return;
    _isFlushing = true;

    final batch = _queue.take(50).toList();
    try {
      final payloadMap = {
        'platform': _platformLabel(),
        'active_route': _currentRoute,
        'active_feature': _currentFeature,
        'is_brewing': _isBrewing,
        'events': batch.map((e) => e.toJson()).toList(),
      };
      final rawJson = jsonEncode(payloadMap);
      if (!kIsWeb) {
        final compressed = Uint8List.fromList(gzip.encode(utf8.encode(rawJson)));
        await dio.post<dynamic>(
          '/api/v1/monitoring/ingest-batch',
          data: compressed,
          options: Options(
            extra: const {'silentTelemetry': true},
            headers: {
              'Content-Encoding': 'gzip',
              'Content-Type': 'application/json',
              'Content-Length': compressed.length.toString(),
            },
          ),
        );
      } else {
        await dio.post<dynamic>(
          '/api/v1/monitoring/ingest-batch',
          data: payloadMap,
          options: Options(extra: const {'silentTelemetry': true}),
        );
      }

      _queue.removeRange(0, batch.length.clamp(0, _queue.length));
      await _persistQueueSnapshot();
    } on DioException catch (e) {
      _triggerCooldownIfUnsupported(e, dio);
      await _persistQueueSnapshot();
    } catch (_) {
      await _persistQueueSnapshot();
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _persistQueueSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _queue.take(100).map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_outboxStorageKey, encoded);
    } catch (_) {}
  }

  void dispose() {
    _disposed = true;
    _initialized = false;
    _flushTimer?.cancel();
    _flushTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _routeHeartbeatDebounce?.cancel();
    _routeHeartbeatDebounce = null;
    _persistDebounce?.cancel();
    _persistDebounce = null;
  }
}
