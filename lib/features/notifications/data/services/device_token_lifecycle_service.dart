import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../services/auth_service.dart';
import 'local_push_orchestrator.dart';
import 'notification_api_service.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final notificationApiServiceProvider = Provider<NotificationApiService>(
  (ref) => NotificationApiService(ref.watch(dioClientProvider)),
);

final deviceTokenLifecycleServiceProvider =
    Provider<DeviceTokenLifecycleService>((ref) {
  final service = DeviceTokenLifecycleService(
    ref.watch(notificationApiServiceProvider),
    ref.watch(flutterSecureStorageProvider),
    ref.watch(localPushOrchestratorProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

class PushNotificationDiagnostics {
  final bool osPermissionEnabled;
  final bool firebaseConfigured;
  final bool fcmTokenRegistered;
  final String statusNote;

  const PushNotificationDiagnostics({
    required this.osPermissionEnabled,
    required this.firebaseConfigured,
    required this.fcmTokenRegistered,
    required this.statusNote,
  });
}

class DeviceTokenLifecycleService {
  static const String _installationIdKey = 'coffeelabs_device_installation_id_v1';
  static const Uuid _uuid = Uuid();

  final NotificationApiService _api;
  final FlutterSecureStorage _secureStorage;
  final LocalPushOrchestrator _orchestrator;

  StreamSubscription<String>? _registeredSub;
  String? _cachedInstallationId;
  String? _lastSyncedToken;
  bool _isKioskAodActive = false;
  bool _initialized = false;
  bool _firebaseReady = false;
  String? _lastFirebaseError;

  DeviceTokenLifecycleService(
    this._api,
    this._secureStorage,
    this._orchestrator,
  );

  bool get isKioskAodActive => _isKioskAodActive;
  bool get isFirebaseReady => _firebaseReady;
  bool get hasSyncedFcmToken =>
      _lastSyncedToken != null && _lastSyncedToken!.isNotEmpty;

  bool get _isTestEnvironment =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  bool get _supportsFirebaseMessaging {
    if (kIsWeb || _isTestEnvironment) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  String get _platformWireValue {
    if (kIsWeb) return 'WEB';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'IOS';
      case TargetPlatform.macOS:
        return 'IOS';
      case TargetPlatform.android:
        return 'ANDROID';
      default:
        return 'DESKTOP';
    }
  }

  /// Mendapatkan UUID stabil perangkat dari FlutterSecureStorage (dengan fallback SharedPreferences).
  Future<String> getOrCreateDeviceInstallationId() async {
    if (_cachedInstallationId != null && _cachedInstallationId!.isNotEmpty) {
      return _cachedInstallationId!;
    }

    try {
      final stored = await _secureStorage.read(key: _installationIdKey);
      if (stored != null && stored.trim().isNotEmpty) {
        _cachedInstallationId = stored.trim();
        return _cachedInstallationId!;
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final prefStored = prefs.getString(_installationIdKey);
    if (prefStored != null && prefStored.trim().isNotEmpty) {
      _cachedInstallationId = prefStored.trim();
      return _cachedInstallationId!;
    }

    final generated = _uuid.v4();
    _cachedInstallationId = generated;
    try {
      await _secureStorage.write(key: _installationIdKey, value: generated);
    } catch (_) {
      await prefs.setString(_installationIdKey, generated);
    }
    return generated;
  }

  /// Menjamin Firebase terinisialisasi secara aman tanpa crash jika `google-services.json`
  /// atau `GoogleService-Info.plist` belum terpasang di lingkungan build lokal.
  Future<bool> ensureFirebaseInitialized() async {
    if (!_supportsFirebaseMessaging) return false;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firebaseReady = Firebase.apps.isNotEmpty;
      if (_firebaseReady) _lastFirebaseError = null;
      return _firebaseReady;
    } catch (e) {
      _firebaseReady = false;
      _lastFirebaseError = e.toString();
      debugPrint('Push Notification Firebase init dilewati (config belum ada): $e');
      return false;
    }
  }

  Future<PushNotificationDiagnostics> inspectDiagnostics() async {
    final osEnabled = await _orchestrator.areOsNotificationsEnabled();
    final fbReady = _firebaseReady || await ensureFirebaseInitialized();
    final String note;
    if (!osEnabled) {
      note =
          'Izin notifikasi Android belum aktif. Ketuk "Aktifkan Izin Notifikasi" agar pop-up pesan bisa muncul.';
    } else if (!fbReady) {
      note =
          'Pop-up real-time aktif saat aplikasi berjalan (WebSocket). Untuk push saat aplikasi ditutup total, build APK perlu menyertakan google-services.json dari Firebase Console.';
    } else if (!hasSyncedFcmToken) {
      note = 'Firebase aktif, sedang menyinkronkan token FCM perangkat ke server...';
    } else {
      note =
          'Push Notification penuh (FCM Background + Real-Time WebSocket Heads-Up) aktif & siap menerima pesan.';
    }
    return PushNotificationDiagnostics(
      osPermissionEnabled: osEnabled,
      firebaseConfigured: fbReady,
      fcmTokenRegistered: hasSyncedFcmToken,
      statusNote: note,
    );
  }

  Future<void> initializeAndSyncToken({bool requestPermission = false}) async {
    // 1. SELALU minta izin OS Android 13+ / iOS walaupun Firebase belum dikonfigurasi,
    // agar notifikasi pop-up real-time via WebSocket & local notifications tidak diblokir OS!
    if (requestPermission) {
      try {
        await _orchestrator.requestOsNotificationPermissions();
      } catch (e) {
        debugPrint('Request izin notifikasi OS error: $e');
      }
    }

    final jwt = await AuthService.getToken();
    if (jwt == null || jwt.trim().isEmpty) return;

    final firebaseReady = await ensureFirebaseInitialized();
    if (!firebaseReady) return;

    try {
      final messaging = FirebaseMessaging.instance;
      if (requestPermission) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        await messaging.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: true,
          sound: false,
        );
      }

      if (!_initialized) {
        _initialized = true;
        _registeredSub ??= messaging.onRegistered.listen((newToken) {
          unawaited(_syncFcmTokenToBackend(newToken));
        });
      }

      String? apnsToken;
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        apnsToken = await messaging.getAPNSToken();
      }

      // Gunakan API v17 resmi register() + onRegistered dengan fallback getToken()
      String? fcmToken;
      try {
        final nextTokenFuture = messaging.onRegistered.first.timeout(
          const Duration(seconds: 6),
          onTimeout: () => '',
        );
        await messaging.register();
        fcmToken = await nextTokenFuture;
      } catch (_) {}

      if (fcmToken == null || fcmToken.trim().isEmpty) {
        try {
          // ignore: deprecated_member_use
          fcmToken = await messaging.getToken().timeout(const Duration(seconds: 6));
        } catch (_) {}
      }

      if (fcmToken != null && fcmToken.trim().isNotEmpty) {
        await _syncFcmTokenToBackend(fcmToken, apnsToken: apnsToken);
      }
    } catch (e) {
      debugPrint('Sinkronisasi FCM token dilewati: $e');
    }
  }

  Future<void> _syncFcmTokenToBackend(
    String fcmToken, {
    String? apnsToken,
  }) async {
    final jwt = await AuthService.getToken();
    if (jwt == null || jwt.trim().isEmpty) return;
    final cleanToken = fcmToken.trim();
    if (cleanToken.isEmpty || cleanToken == _lastSyncedToken) return;

    try {
      final installationId = await getOrCreateDeviceInstallationId();
      await _api.registerDeviceToken(
        deviceInstallationId: installationId,
        platform: _platformWireValue,
        fcmToken: cleanToken,
        apnsToken: apnsToken,
        appVersion: '2.5.4',
        isKioskAodActive: _isKioskAodActive,
      );
      _lastSyncedToken = cleanToken;
    } catch (e) {
      debugPrint('Gagal registrasi token FCM ke server: $e');
    }
  }

  Future<void> syncKioskAodLockState(bool isLocked) async {
    _isKioskAodActive = isLocked;
    final jwt = await AuthService.getToken();
    if (jwt == null || jwt.trim().isEmpty) return;

    try {
      final installationId = await getOrCreateDeviceInstallationId();
      await _api.updateKioskMode(
        deviceInstallationId: installationId,
        isKioskAodActive: isLocked,
      );
    } catch (e) {
      debugPrint('Sinkronisasi mode AOD Kiosk ke backend gagal (non-fatal): $e');
    }
  }

  Future<void> syncActiveChatRoom(String? conversationId) async {
    final jwt = await AuthService.getToken();
    if (jwt == null || jwt.trim().isEmpty) return;

    try {
      await _api.setActiveChatRoom(conversationId);
    } catch (_) {}
  }

  Future<void> unregisterOnLogout() async {
    _lastSyncedToken = null;
    try {
      final installationId = await getOrCreateDeviceInstallationId();
      await _api.unregisterDeviceToken(deviceInstallationId: installationId);
    } catch (_) {}

    if (_supportsFirebaseMessaging && Firebase.apps.isNotEmpty) {
      try {
        await FirebaseMessaging.instance.unregister();
      } catch (_) {}
    }
  }

  String? get lastFirebaseError => _lastFirebaseError;

  void dispose() {
    _registeredSub?.cancel();
    _registeredSub = null;
  }
}
