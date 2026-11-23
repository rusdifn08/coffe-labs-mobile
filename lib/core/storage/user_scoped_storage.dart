import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Otoritas isolasi penyimpanan lokal multi-akun (per-user namespace) di Coffee Labs.
///
/// Menjamin setiap akun yang login di perangkat yang sama memiliki partisi data sendiri
/// (`u_<userId>_<baseKey>`) sehingga EXP, Level, Riwayat Seduh, Jurnal, Favorit,
/// Resep Custom, dan Avatar TIDAK pernah tercampur antar akun.
class UserScopedStorage {
  UserScopedStorage._();

  static const String guestScope = 'guest';
  static const String _userKey = 'coffeehub_auth_user_json';
  static const String _sessionUserKey = 'coffeehub_auth_session_user';
  static const String _tokenKey = 'coffeehub_auth_jwt_token';
  static const String _v1TokenKey = 'coffeehub_auth_token_v1';

  static String _activeUserId = guestScope;

  /// Notifier yang selalu memicu rebuild/refresh saat akun aktif berganti (login / logout / switch).
  static final ValueNotifier<String> activeUserIdNotifier =
      ValueNotifier<String>(guestScope);

  /// Callback opsional yang dipasang oleh `UserCloudSyncService` untuk mendorong mutasi lokal ke cloud.
  static VoidCallback? onUserDataMutated;

  static String get activeUserId => _activeUserId;
  static bool get isGuestScope => _activeUserId == guestScope;

  /// Memberi sinyal bahwa data milik pengguna aktif berubah dan perlu dijadwalkan sinkronisasi cloud.
  static void notifyDataMutated() {
    if (!isGuestScope) {
      onUserDataMutated?.call();
    }
  }

  /// Normalisasi ID pengguna menjadi segmen key yang aman dan deterministik.
  static String normalizeUserId(String? raw) {
    if (raw == null) return guestScope;
    final clean = raw.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
    return clean.isEmpty ? guestScope : clean;
  }

  /// Menetapkan pengguna aktif secara sinkron (dipanggil saat login / logout / switch akun).
  static void setActiveUserId(String? rawUserId) {
    final normalized = normalizeUserId(rawUserId);
    if (_activeUserId != normalized) {
      _activeUserId = normalized;
      activeUserIdNotifier.value = normalized;
    }
  }

  /// Mengembalikan ruang lingkup ke mode tamu (`guest`) saat logout.
  static void resetToGuest() {
    setActiveUserId(guestScope);
  }

  /// Reset status internal (khusus untuk unit test yang membersihkan SharedPreferences).
  static void resetForTesting() {
    _activeUserId = guestScope;
    activeUserIdNotifier.value = guestScope;
    onUserDataMutated = null;
  }

  /// Memastikan `_activeUserId` sinkron dengan sesi login yang tersimpan di SharedPreferences.
  static Future<String> resolveActiveUserId({SharedPreferences? prefs}) async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    final detected = _extractUserIdFromPrefs(sp);
    if (_activeUserId != detected) {
      _activeUserId = detected;
      activeUserIdNotifier.value = detected;
    }
    return _activeUserId;
  }

  /// Mengembalikan key yang dipartisi per-user secara sinkron.
  static String scopedKey(String baseKey, {String? userId}) {
    final uid = normalizeUserId(userId ?? _activeUserId);
    return 'u_${uid}_$baseKey';
  }

  /// Mengembalikan key yang dipartisi per-user setelah memastikan sesi aktif terdeteksi.
  static Future<String> scopedKeyAsync(
    String baseKey, {
    String? userId,
    SharedPreferences? prefs,
  }) async {
    if (userId != null && userId.trim().isNotEmpty) {
      return scopedKey(baseKey, userId: userId);
    }
    final uid = await resolveActiveUserId(prefs: prefs);
    return scopedKey(baseKey, userId: uid);
  }

  static String _extractUserIdFromPrefs(SharedPreferences sp) {
    final rawJson = sp.getString(_userKey) ?? sp.getString(_sessionUserKey);
    if (rawJson != null && rawJson.trim().isNotEmpty) {
      try {
        final decoded = json.decode(rawJson);
        if (decoded is Map<String, dynamic>) {
          final id = decoded['id']?.toString().trim() ?? '';
          if (id.isNotEmpty) return normalizeUserId(id);
          final username = decoded['username']?.toString().trim() ?? '';
          if (username.isNotEmpty) return normalizeUserId('usr_$username');
        }
      } catch (_) {}
    }

    final token = (sp.getString(_tokenKey) ?? sp.getString(_v1TokenKey))?.trim();
    if (token != null && token.isNotEmpty) {
      final sub = _extractJwtSub(token);
      if (sub != null && sub.isNotEmpty) {
        return normalizeUserId(sub);
      }
    }

    return guestScope;
  }

  static String? _extractJwtSub(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final normalized = base64Url.normalize(parts[1]);
      final decoded = json.decode(utf8.decode(base64Url.decode(normalized)));
      if (decoded is Map<String, dynamic>) {
        final sub = (decoded['sub'] ?? decoded['user_id'])?.toString().trim();
        if (sub != null && sub.isNotEmpty) return sub;
      }
    } catch (_) {}
    return null;
  }
}
