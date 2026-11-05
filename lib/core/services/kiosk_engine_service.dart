import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

class KioskBootState {
  final bool isLocked;
  final bool bootIntoAod;
  final String? cachedMenuJson;
  final String? cachedConfigJson;
  final bool isDeviceOwner;
  final bool hasOverlayPermission;

  const KioskBootState({
    required this.isLocked,
    required this.bootIntoAod,
    this.cachedMenuJson,
    this.cachedConfigJson,
    this.isDeviceOwner = false,
    this.hasOverlayPermission = false,
  });

  bool get bootIntoAodKiosk => bootIntoAod;

  factory KioskBootState.fromMap(Map<dynamic, dynamic> map) {
    return KioskBootState(
      isLocked: map['isLocked'] == true,
      bootIntoAod: map['bootIntoAod'] == true,
      cachedMenuJson: map['cachedMenu'] as String?,
      cachedConfigJson: map['cachedConfig'] as String?,
      isDeviceOwner: map['isDeviceOwner'] == true,
      hasOverlayPermission: map['hasOverlayPermission'] == true,
    );
  }
}

class KioskEngineService {
  static const MethodChannel _channel = MethodChannel('com.coffeelabs.app/kiosk_engine');

  /// Hitung SHA-256 hash dari PIN 4-6 digit secara konsisten
  static String hashPin(String rawPin) {
    final bytes = utf8.encode(rawPin.trim());
    return sha256.convert(bytes).toString();
  }

  /// Ambil status Kiosk & data Direct-Boot saat app cold-boot
  static Future<KioskBootState> getKioskBootState() async {
    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>('getKioskBootState');
      if (res != null) {
        return KioskBootState.fromMap(res);
      }
    } catch (_) {}
    return const KioskBootState(isLocked: false, bootIntoAod: false);
  }

  /// Ambil salinan payload konfigurasi dan menu dari Direct-Boot Device Protected Storage
  static Future<Map<String, dynamic>> getDirectBootPayload() async {
    final bootState = await getKioskBootState();
    return {
      'is_locked': bootState.isLocked,
      'boot_into_aod': bootState.bootIntoAod,
      'config_json': bootState.cachedConfigJson,
      'menu_json': bootState.cachedMenuJson,
    };
  }

  /// Aktifkan Single-App Kiosk Lock permanen (Anti-Home, Anti-Back, Anti-Notifikasi)
  static Future<Map<String, dynamic>> enableStrictKiosk({
    required String pin,
    required String storeId,
  }) async {
    final pinSha256 = hashPin(pin);
    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'enableStrictKiosk',
        {
          'pinSha256': pinSha256,
          'storeId': storeId,
        },
      );
      if (res != null) {
        return Map<String, dynamic>.from(res);
      }
    } catch (e) {
      return {'locked': false, 'error': e.toString()};
    }
    return {'locked': true, 'mode': 'HYBRID_LAUNCHER_WATCHDOG'};
  }

  /// Lepas Kiosk Lock & kembalikan HP ke Launcher bawaan
  static Future<bool> disableStrictKiosk() async {
    try {
      final res = await _channel.invokeMethod<bool>('disableStrictKiosk');
      return res ?? true;
    } catch (_) {
      return false;
    }
  }

  /// Cek izin Overlay (SYSTEM_ALERT_WINDOW) untuk pengecualian BAL Android 10-16
  static Future<bool> hasOverlayPermission() async {
    try {
      final res = await _channel.invokeMethod<bool>('hasOverlayPermission');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Buka menu pengaturan OS untuk memberikan izin Overlay
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  /// Tampilkan dialog OS untuk memilih Default Home Launcher
  static Future<void> promptSelectHomeLauncher() async {
    try {
      await _channel.invokeMethod('promptSelectHomeLauncher');
    } catch (_) {}
  }

  /// Verifikasi PIN kasir secara offline melawan hash di Direct-Boot Storage
  static Future<bool> verifyPinOffline(String pin) async {
    final pinSha256 = hashPin(pin);
    try {
      final res = await _channel.invokeMethod<bool>(
        'verifyPinOffline',
        {'pinSha256': pinSha256},
      );
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Simpan katalog menu & store config ke Direct-Boot Device Protected Storage
  static Future<void> cacheMenuForDirectBoot({
    required String menuJson,
    required String configJson,
  }) async {
    try {
      await _channel.invokeMethod(
        'cacheMenuForDirectBoot',
        {
          'menuJson': menuJson,
          'configJson': configJson,
        },
      );
    } catch (_) {}
  }

  /// Sembunyikan bilah navigasi dan status bar Android (Immersive Sticky)
  static Future<void> applyImmersiveStickyBars() async {
    try {
      await _channel.invokeMethod('applyImmersiveStickyBars');
    } catch (_) {}
  }
}
