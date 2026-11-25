import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/moderation/content_moderation_guard.dart';
import '../core/network/backend_endpoint_manager.dart';
import '../core/storage/user_scoped_storage.dart';
import '../features/game_brew/data/game_brew_progress_service.dart';
import '../features/gamification/services/gamification_service.dart';
import 'api_service.dart';
import 'profile_service.dart';
import 'trial_service.dart';
import 'subscription_service.dart';
import 'admin_user_service.dart';
import 'preset_admin_service.dart';
import 'user_cloud_sync_service.dart';
import '../models/admin_user_stats.dart';
import '../models/subscription_plan.dart';

class AuthUser {
  final String id;
  final String username;
  final String? email;
  final String fullName;
  final String role;
  final String status;
  final String tier;
  final String? subscriptionPlanId;
  final String avatarUrl;
  final String? createdAt;
  final DateTime? trialFullUntil;
  final String? trialPolicyOverride;

  const AuthUser({
    required this.id,
    required this.username,
    this.email,
    required this.fullName,
    required this.role,
    required this.status,
    this.tier = 'trial',
    this.subscriptionPlanId,
    required this.avatarUrl,
    this.createdAt,
    this.trialFullUntil,
    this.trialPolicyOverride,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final username = json['username']?.toString() ?? '';
    final rawEmail = json['email']?.toString().trim();
    final email = (rawEmail != null && rawEmail.isNotEmpty) ? rawEmail : null;
    final rawTier = (json['tier']?.toString() ?? '').toLowerCase().trim();
    final inferredTier = rawTier.isNotEmpty
        ? rawTier
        : (username.toLowerCase() == 'bisnis123' ? 'business' : 'trial');
    final rawPlanId = json['subscription_plan_id']?.toString() ??
        json['subscriptionPlanId']?.toString();
    final inferredPlanId = rawPlanId != null && rawPlanId.isNotEmpty
        ? rawPlanId
        : (inferredTier == 'business'
            ? 'plan_business'
            : (inferredTier == 'pro' ? 'plan_pro' : 'plan_trial'));
    final rawTrialUntil =
        (json['trial_full_until'] ?? json['trialFullUntil'])?.toString();
    final parsedTrialUntil = (rawTrialUntil != null && rawTrialUntil.isNotEmpty)
        ? DateTime.tryParse(rawTrialUntil)
        : null;
    final trialOverride =
        (json['trial_policy_override'] ?? json['trialPolicyOverride'])
            ?.toString();

    return AuthUser(
      id: json['id']?.toString() ?? '',
      username: username,
      email: email,
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? 'Barista',
      role: json['role']?.toString() ?? 'user',
      status: json['status']?.toString() ?? 'pending',
      tier: inferredTier,
      subscriptionPlanId: inferredPlanId,
      avatarUrl: json['avatar_url']?.toString() ?? json['avatarUrl']?.toString() ?? 'assets/images/characters/avatar_1.png',
      createdAt: json['created_at']?.toString(),
      trialFullUntil: parsedTrialUntil,
      trialPolicyOverride: trialOverride,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'full_name': fullName,
    'role': role,
    'status': status,
    'tier': tier,
    'subscription_plan_id': subscriptionPlanId,
    'avatar_url': avatarUrl,
    'created_at': createdAt,
    'trial_full_until': trialFullUntil?.toIso8601String(),
    'trial_policy_override': trialPolicyOverride,
  };

  bool get hasActiveFullTrialOverride =>
      !isBusiness &&
      !isPro &&
      !isAdmin &&
      trialPolicyOverride == 'full_trial_7d_non_business' &&
      trialFullUntil != null &&
      DateTime.now().isBefore(trialFullUntil!);

  bool get isAdmin => role == 'admin';
  bool get isApproved => status == 'approved';
  bool get isBusiness => tier.toLowerCase() == 'business' || username.toLowerCase() == 'bisnis123';
  bool get isPro => tier.toLowerCase() == 'pro' || isBusiness;
}

class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final AuthUser? user;
  final String? status; // 'approved' | 'pending' | 'declined'

  const AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.status,
  });

  factory AuthResult.success(String token, AuthUser user, String message) {
    return AuthResult(
      success: true,
      message: message,
      token: token,
      user: user,
      status: user.status,
    );
  }

  factory AuthResult.pending(String message) {
    return AuthResult(
      success: false,
      message: message,
      status: 'pending',
    );
  }

  factory AuthResult.declined(String message) {
    return AuthResult(
      success: false,
      message: message,
      status: 'declined',
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult(
      success: false,
      message: message,
      status: 'error',
    );
  }
}

class AuthService {
  static const String _tokenKey = 'coffeehub_auth_jwt_token';
  static const String _v1TokenKey = 'coffeehub_auth_token_v1';
  static const String _userKey = 'coffeehub_auth_user_json';
  static const String _sessionUserKey = 'coffeehub_auth_session_user';
  static const String defaultProductionUrl =
      BackendEndpointManager.defaultProductionUrl;

  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);
  static final http.Client _httpClient = http.Client();
  static Timer? _keepAliveTimer;

  static bool? _cachedIsLoggedIn;
  static bool? _cachedIsAdmin;

  static bool? get cachedIsLoggedIn => _cachedIsLoggedIn;
  static bool? get cachedIsAdmin => _cachedIsAdmin;

  static void updateCachedSessionState({
    required bool isLoggedIn,
    required bool isAdmin,
  }) {
    _cachedIsLoggedIn = isLoggedIn;
    _cachedIsAdmin = isAdmin;
  }

  static void resetSessionCache() {
    _cachedIsLoggedIn = null;
    _cachedIsAdmin = null;
  }

  /// Melakukan ping senyap ke backend di background saat app mulai
  /// dan menjadwalkan heartbeat otomatis setiap 10 menit untuk menjaga koneksi aktif
  static void warmUpBackend() {
    _sendHeartbeat();
    // Jangan jadwalkan periodic timer saat test runner berjalan
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _sendHeartbeat();
    });
  }

  static void _sendHeartbeat() {
    getBaseUrl().then((url) {
      _httpClient
          .get(Uri.parse('$url/api/health'), headers: {'Connection': 'keep-alive'})
          .timeout(const Duration(seconds: 15))
          .then((res) {
        if (res.statusCode == 200) {
          debugPrint('☕ Backend heartbeat sukses ($url) - Server online');
        } else if (res.statusCode >= 502 && res.statusCode <= 504) {
          unawaited(
            BackendEndpointManager.instance.failoverOnTransportError(failedUrl: url),
          );
        }
      }).catchError((_) {
        unawaited(
          BackendEndpointManager.instance.failoverOnTransportError(failedUrl: url),
        );
      });
    }).catchError((_) {});
  }

  /// Deteksi Base URL backend secara dinamis via [BackendEndpointManager]:
  /// Mendukung Multi-CDN Discovery (Vercel -> jsDelivr -> GitHub Raw) & Auto-Failover ke VPS.
  static Future<String> getBaseUrl() =>
      BackendEndpointManager.instance.getActiveBaseUrl();

  /// Memperbarui alamat server backend (override manual admin / kosongkan untuk auto-discovery)
  static Future<void> setCustomBaseUrl(String url) async {
    await BackendEndpointManager.instance.setManualOverrideUrl(url);
    changeNotifier.value++;
  }

  /// Cek apakah pengguna saat ini sudah login dengan akun resmi & approved
  /// (berlaku untuk semua tier akun termasuk Trial terdaftar, Pro, Business, & Admin).
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      _cachedIsLoggedIn = false;
      _cachedIsAdmin = false;
      return false;
    }

    final user = await getCurrentUser();
    final loggedIn = user != null && (user.isApproved || user.isAdmin);
    _cachedIsLoggedIn = loggedIn;
    _cachedIsAdmin = loggedIn && user.isAdmin;
    return loggedIn;
  }

  /// Cek apakah pengguna berada di Mode Pengunjung anonim (tanpa akun login).
  static Future<bool> isAnonymousVisitor() async {
    final loggedIn = await isLoggedIn();
    if (loggedIn) return false;
    return TrialService.isTrialMode();
  }

  /// Cek apakah pengguna yang sedang login memiliki hak akses ADMIN
  static Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    final admin = user != null && user.isAdmin;
    _cachedIsAdmin = admin;
    return admin;
  }

  /// Mendekode payload JSON dari JWT (Base64Url) untuk fallback ekstraksi klaim `sub`.
  static Map<String, dynamic>? decodeJwtPayload(String? token) {
    if (token == null || token.trim().isEmpty) return null;
    try {
      final parts = token.trim().split('.');
      if (parts.length < 2) return null;
      final normalized = base64Url.normalize(parts[1]);
      final raw = utf8.decode(base64Url.decode(normalized));
      final decoded = json.decode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Sinkronisasi kedua skema key sesi (`AuthService` & `AuthRepositoryImpl`) agar state Riverpod selalu konsisten.
  static Future<void> persistSessionMirrors(
    SharedPreferences prefs, {
    required AuthUser user,
    String? token,
  }) async {
    final userJson = json.encode(user.toJson());
    await Future.wait([
      prefs.setString(_userKey, userJson),
      prefs.setString(_sessionUserKey, userJson),
      if (token != null && token.trim().isNotEmpty) ...[
        prefs.setString(_tokenKey, token.trim()),
        prefs.setString(_v1TokenKey, token.trim()),
      ],
    ]);
  }

  /// Menerapkan hasil upgrade tier instan (Pro / Business) dari QRIS Dinamis tanpa perlu logout-login ulang.
  static Future<AuthUser?> applyUpgradedTierSession({
    required String newTier,
    String? planCode,
    String? freshAccessToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedTier = newTier.toLowerCase().trim() == 'business' ? 'business' : 'pro';
    final plan = normalizedTier == 'business'
        ? SubscriptionPlan.business
        : SubscriptionPlan.pro;

    final existing = await getCurrentUser();
    AuthUser? updatedUser;
    if (existing != null) {
      updatedUser = AuthUser(
        id: existing.id,
        username: existing.username,
        email: existing.email,
        fullName: existing.fullName,
        role: existing.role,
        status: existing.status,
        tier: normalizedTier,
        subscriptionPlanId: planCode ?? plan.id,
        avatarUrl: existing.avatarUrl,
        createdAt: existing.createdAt,
        trialFullUntil: null,
        trialPolicyOverride: null,
      );
      await persistSessionMirrors(
        prefs,
        user: updatedUser,
        token: freshAccessToken,
      );
    } else if (freshAccessToken != null && freshAccessToken.trim().isNotEmpty) {
      await Future.wait([
        prefs.setString(_tokenKey, freshAccessToken.trim()),
        prefs.setString(_v1TokenKey, freshAccessToken.trim()),
      ]);
    }

    await SubscriptionService.activatePlan(
      plan,
      paymentMethod: 'QRIS Dinamis Livin\' Merchant',
    );
    changeNotifier.value++;
    return updatedUser;
  }

  /// Mengambil JWT token yang tersimpan di memori perangkat
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final primary = prefs.getString(_tokenKey)?.trim();
    if (primary != null && primary.isNotEmpty) return primary;
    final secondary = prefs.getString(_v1TokenKey)?.trim();
    return (secondary != null && secondary.isNotEmpty) ? secondary : null;
  }

  /// Mengambil profil pengguna yang sedang login (dengan sinkronisasi multi-key & fallback JWT `sub`)
  static Future<AuthUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_userKey) ?? prefs.getString(_sessionUserKey);
    final token = await getToken();
    final claims = decodeJwtPayload(token);
    final jwtSub = (claims?['sub'] ?? claims?['user_id'])?.toString().trim() ?? '';

    AuthUser? parsed;
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = json.decode(rawJson) as Map<String, dynamic>;
        parsed = AuthUser.fromJson(decoded);
      } catch (_) {}
    }

    if (parsed != null) {
      if (parsed.id.trim().isEmpty && jwtSub.isNotEmpty) {
        return AuthUser(
          id: jwtSub,
          username: parsed.username,
          email: parsed.email,
          fullName: parsed.fullName,
          role: parsed.role,
          status: parsed.status,
          tier: parsed.tier,
          subscriptionPlanId: parsed.subscriptionPlanId,
          avatarUrl: parsed.avatarUrl,
          createdAt: parsed.createdAt,
        );
      }
      return parsed;
    }

    if (jwtSub.isNotEmpty && claims != null) {
      return AuthUser(
        id: jwtSub,
        username: claims['username']?.toString() ?? 'barista',
        fullName: claims['full_name']?.toString() ??
            claims['username']?.toString() ??
            'Barista Coffee Labs',
        role: claims['role']?.toString() ?? 'user',
        status: claims['status']?.toString() ?? 'approved',
        tier: claims['tier']?.toString() ?? 'trial',
        avatarUrl: 'assets/images/characters/avatar_1.png',
      );
    }

    return null;
  }

  static Map<String, dynamic> _safeDecodeJson(String rawBody, int statusCode) {
    try {
      final decoded = json.decode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    if (statusCode == 429 || rawBody.toLowerCase().contains('too many requests')) {
      return {
        'success': false,
        'message': 'Server sedang sibuk memproses permintaan. Silakan tunggu 3 detik lalu tekan tombol sekali lagi.',
      };
    }
    return {
      'success': false,
      'message': rawBody.trim().isNotEmpty
          ? rawBody.trim()
          : 'Terjadi kesalahan komunikasi dengan server (HTTP $statusCode).',
    };
  }

  ///Login dengan Username dan Password
  static Future<AuthResult> login({
    required String username,
    required String password,
    bool notify = true,
  }) async {
    // 1. Dukungan akun preset testing admin1 s/d admin10 untuk review border gamifikasi
    final presetResult = await PresetAdminService.tryLogin(username, password, notify: notify);
    if (presetResult != null) return presetResult;

    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/auth/login');
      final encodedBody = json.encode({
        'username': username.trim(),
        'password': password,
      });

      http.Response response = await _httpClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
            body: encodedBody,
          )
          .timeout(const Duration(seconds: 45));

      // Helper evaluasi apakah kegagalan bersifat transien (cold-start Render / idle drop NeonDB)
      bool isTransientFailure(http.Response res) {
        if (res.statusCode == 429 || res.statusCode == 502 || res.statusCode == 503) {
          return true;
        }
        if (res.statusCode == 500 &&
            (res.body.contains('DATABASE_ERROR') ||
                res.body.contains('gangguan pemrosesan data') ||
                res.body.contains('NeonDB') ||
                res.body.contains('connection'))) {
          return true;
        }
        return false;
      }

      // Auto-retry cerdas jika terkena gangguan serverless / cold-start proxy
      int retryCount = 0;
      while (isTransientFailure(response) && retryCount < 2) {
        retryCount++;
        debugPrint('⚠️ Auth Login retry ke-$retryCount (HTTP ${response.statusCode})...');
        await Future.delayed(Duration(milliseconds: 600 * retryCount));
        try {
          response = await _httpClient
              .post(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Connection': 'keep-alive',
                },
                body: encodedBody,
              )
              .timeout(const Duration(seconds: 20));
        } catch (_) {}
      }

      final data = _safeDecodeJson(response.body, response.statusCode);

      if (response.statusCode == 200) {
        final payload = (data['data'] as Map<String, dynamic>?) ?? data;
        final token = payload['token'] as String;
        final user = AuthUser.fromJson(payload['user'] as Map<String, dynamic>);

        final prefs = await SharedPreferences.getInstance();

        // Auto-sinkronisasi subscription tier ke SubscriptionService secara tegas & terisolasi
        if (user.isBusiness) {
          await SubscriptionService.activatePlan(
            SubscriptionPlan.business,
            paymentMethod: 'Business Commercial License',
          );
          await TrialService.setTrialMode(false);
        } else if (user.isPro) {
          await SubscriptionService.activatePlan(
            SubscriptionPlan.pro,
            paymentMethod: 'Pro Lifetime License',
          );
          await TrialService.setTrialMode(false);
        } else if (user.isAdmin) {
          await SubscriptionService.activatePlan(
            SubscriptionPlan.business,
            paymentMethod: 'Administrator License',
          );
          await TrialService.setTrialMode(false);
        } else {
          // Akun non-business (Trial / Standard User) WAJIB reset ke Trial murni!
          await SubscriptionService.resetToTrial();
          await TrialService.setTrialMode(true);
        }

        await persistSessionMirrors(prefs, user: user, token: token);
        UserScopedStorage.setActiveUserId(user.id);
        ApiService.clearMemoryCache();
        await ProfileService.applyCloudProfile(
          userId: user.id,
          fullName: user.fullName,
          avatarUrl: user.avatarUrl,
        );
        UserCloudSyncService.ensureHooksRegistered();
        try {
          await UserCloudSyncService.hydrateFromCloud(
            user: user,
            force: true,
          ).timeout(const Duration(seconds: 6));
        } catch (_) {}
        GamificationService.instance.notifySessionSwitched();
        GameBrewProgressService.notifySessionSwitched();
        ProfileService.notifySessionSwitched();
        ApiService.changeNotifier.value++;

        updateCachedSessionState(
          isLoggedIn: user.isApproved || user.isAdmin,
          isAdmin: user.isAdmin,
        );
        if (notify) {
          changeNotifier.value++;
        }
        return AuthResult.success(token, user, data['message'] ?? 'Login berhasil!');
      } else if (response.statusCode == 403) {
        final status = data['status']?.toString();
        if (status == 'pending') {
          return AuthResult.pending(
            data['message'] ??
                'Akun Anda sedang menunggu persetujuan dari Admin (rusdifn08). Harap tunggu hingga disetujui.',
          );
        } else if (status == 'declined') {
          return AuthResult.declined(
            data['message'] ??
                'Pendaftaran akun Anda telah ditolak oleh Admin.',
          );
        }
        return AuthResult.error(data['message'] ?? 'Akses ditolak.');
      } else if (response.statusCode == 401) {
        return AuthResult.error(data['message'] ?? 'Username atau password salah.');
      } else {
        return AuthResult.error(data['message'] ?? 'Terjadi kesalahan (${response.statusCode}).');
      }
    } on TimeoutException {
      return AuthResult.error(
        'Koneksi timeout (server Cloud Render sedang bangun dari mode siaga, proses ini memakan waktu ~30 detik). Silakan coba tekan tombol Login sekali lagi.',
      );
    } on SocketException {
      return AuthResult.error(
        'Tidak dapat terhubung ke server backend Cloud Render. Periksa koneksi internet Anda atau coba sesaat lagi.',
      );
    } catch (e) {
      return AuthResult.error('Gagal login: $e');
    }
  }

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validasi format alamat email standar sebelum dikirim ke backend.
  static bool isValidEmail(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed.length > 160 || trimmed.contains('..')) {
      return false;
    }
    return _emailRegex.hasMatch(trimmed);
  }

  /// Pendaftaran akun baru (menerima email aktif untuk reset password & info pembaruan)
  static Future<AuthResult> register({
    required String username,
    required String password,
    required String fullName,
    String? email,
    String? avatarUrl,
  }) async {
    final cleanEmail = email?.trim().toLowerCase();
    if (cleanEmail != null && cleanEmail.isNotEmpty && !isValidEmail(cleanEmail)) {
      return AuthResult.error('Format alamat email tidak valid. Contoh: nama@gmail.com');
    }
    final verdict = ContentModerationGuard.inspectMultiple({
      'Username': username,
      'Nama lengkap': fullName,
    });
    if (!verdict.isAllowed) {
      return AuthResult.error(
        verdict.userMessage ?? 'Username atau nama mengandung kata tidak pantas.',
      );
    }
    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/auth/register');
      final encodedBody = json.encode({
        'username': username.trim(),
        'password': password,
        'full_name': fullName.trim(),
        if (cleanEmail != null && cleanEmail.isNotEmpty) 'email': cleanEmail,
        'avatar_url': avatarUrl,
      });

      http.Response response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: encodedBody,
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 429 || response.statusCode == 502 || response.statusCode == 503) {
        try {
          final localUri = Uri.parse('http://localhost:3000/api/auth/register');
          final localRes = await http
              .post(
                localUri,
                headers: {'Content-Type': 'application/json'},
                body: encodedBody,
              )
              .timeout(const Duration(seconds: 4));
          if (localRes.statusCode != 429 && localRes.statusCode < 500) {
            response = localRes;
          }
        } catch (_) {}
      }
      if (response.statusCode == 429 || response.statusCode == 502 || response.statusCode == 503) {
        await Future.delayed(const Duration(seconds: 5));
        response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: encodedBody,
            )
            .timeout(const Duration(seconds: 45));
      }

      final data = _safeDecodeJson(response.body, response.statusCode);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final rawUser = data['data'] is Map<String, dynamic>
            ? (data['data']['user'] ?? data['data'])
            : data['user'];
        final userData = rawUser is Map<String, dynamic> ? AuthUser.fromJson(rawUser) : null;
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Pendaftaran berhasil! Akun Anda aktif dan siap digunakan untuk login.',
          user: userData,
          status: 'approved',
        );
      } else if (response.statusCode == 409) {
        final serverMsg = data['message']?.toString().trim();
        return AuthResult.error(
          (serverMsg != null && serverMsg.isNotEmpty)
              ? serverMsg
              : 'Username "$username" atau email sudah terdaftar di sistem. Silakan beralih ke menu Login.',
        );
      } else {
        return AuthResult.error(data['message'] ?? 'Gagal mendaftar (${response.statusCode}).');
      }
    } on TimeoutException {
      return AuthResult.error(
        'Koneksi timeout karena server Cloud Render sedang bangun dari mode siaga. Data pendaftaran Anda mungkin sudah tersimpan di server. Silakan coba beralih ke menu Login untuk mencoba masuk atau periksa status akun.',
      );
    } on SocketException {
      return AuthResult.error(
        'Tidak dapat terhubung ke server backend Cloud Render. Periksa koneksi internet Anda atau coba sesaat lagi.',
      );
    } catch (e) {
      return AuthResult.error('Gagal mendaftar: $e');
    }
  }

  /// Mengubah password pengguna aktif
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Sesi telah berakhir. Silakan login kembali.'};
      }

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/auth/change-password');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 25));

      final data = _safeDecodeJson(response.body, response.statusCode);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Password berhasil diubah!'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal mengubah password.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghubungi server: $e'};
    }
  }

  /// Meminta kode reset password 6 digit yang dikirim langsung ke email terdaftar pengguna.
  static Future<Map<String, dynamic>> requestPasswordReset({
    required String identifier,
  }) async {
    final cleanId = identifier.trim();
    if (cleanId.isEmpty) {
      return {
        'success': false,
        'message': 'Masukkan alamat email atau username akun Anda terlebih dahulu.',
      };
    }
    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/auth/forgot-password');
      final response = await _httpClient
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'identifier': cleanId}),
          )
          .timeout(const Duration(seconds: 30));

      final data = _safeDecodeJson(response.body, response.statusCode);
      if (response.statusCode == 200) {
        final payload = data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : const <String, dynamic>{};
        return {
          'success': true,
          'message': data['message']?.toString() ??
              'Kode reset 6 digit telah dikirim ke email terdaftar Anda.',
          'maskedEmail': payload['masked_email']?.toString(),
          'expiresInSeconds': (payload['expires_in_seconds'] as num?)?.toInt() ?? 900,
        };
      }
      return {
        'success': false,
        'message': data['message']?.toString() ??
            'Gagal mengirim kode reset password (${response.statusCode}).',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan timeout. Silakan coba beberapa saat lagi.',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal meminta kode reset: $e'};
    }
  }

  /// Konfirmasi reset password menggunakan kode 6 digit dari email dan password baru.
  static Future<Map<String, dynamic>> confirmPasswordReset({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    final cleanId = identifier.trim();
    final cleanCode = code.trim();
    if (cleanId.isEmpty || cleanCode.length != 6) {
      return {
        'success': false,
        'message': 'Masukkan kode verifikasi 6 digit yang dikirim ke email Anda.',
      };
    }
    if (newPassword.length < 6) {
      return {
        'success': false,
        'message': 'Password baru minimal harus 6 karakter.',
      };
    }
    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/auth/reset-password');
      final response = await _httpClient
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'identifier': cleanId,
              'code': cleanCode,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = _safeDecodeJson(response.body, response.statusCode);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message']?.toString() ??
              'Password berhasil direset! Silakan login dengan password baru.',
        };
      }
      return {
        'success': false,
        'message': data['message']?.toString() ??
            'Gagal mereset password (${response.statusCode}).',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Koneksi timeout. Silakan coba kirim ulang.',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal mereset password: $e'};
    }
  }

  /// Logout pengguna dan bersihkan sesi secara tuntas tanpa residu lisensi maupun data akun
  static Future<void> logout() async {
    // Kirim mutasi lokal terakhir ke cloud sebelum token dihapus
    await UserCloudSyncService.flushPendingSync();

    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_v1TokenKey),
      prefs.remove(_userKey),
      prefs.remove(_sessionUserKey),
    ]);
    // Isolasi total: reset namespace ke guest & bersihkan cache in-memory
    UserScopedStorage.resetToGuest();
    ApiService.clearMemoryCache();
    // Hapus total lisensi lokal agar pengguna berikutnya tidak tertular Business / Pro
    await SubscriptionService.resetToTrial();
    await TrialService.setTrialMode(false);
    updateCachedSessionState(isLoggedIn: false, isAdmin: false);
    GamificationService.instance.notifySessionSwitched();
    GameBrewProgressService.notifySessionSwitched();
    ProfileService.notifySessionSwitched();
    ApiService.changeNotifier.value++;
    changeNotifier.value++;
  }

  static DateTime? _lastSyncTime;

  /// Sinkronisasi data profil pengguna terkini dari server backend (Ground Truth RBAC)
  static Future<AuthUser?> syncProfile({bool force = false}) async {
    final now = DateTime.now();
    if (!force && _lastSyncTime != null && now.difference(_lastSyncTime!) < const Duration(seconds: 15)) {
      return getCurrentUser();
    }
    _lastSyncTime = now;

    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return null;

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/v1/auth/me');

      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = _safeDecodeJson(response.body, response.statusCode);
        final rawUser = data['data'] is Map<String, dynamic>
            ? data['data']
            : (data['user'] is Map<String, dynamic> ? data['user'] : null);
        if (rawUser != null) {
          final user = AuthUser.fromJson(rawUser as Map<String, dynamic>);
          final rawFreshToken = (data['fresh_access_token'] ?? data['token'])?.toString().trim();
          final effectiveToken =
              (rawFreshToken != null && rawFreshToken.isNotEmpty) ? rawFreshToken : token;
          final prefs = await SharedPreferences.getInstance();
          final oldUserJson = prefs.getString(_userKey);
          final newUserJson = json.encode(user.toJson());
          final hasChanged = oldUserJson != newUserJson;

          await persistSessionMirrors(prefs, user: user, token: effectiveToken);
          UserScopedStorage.setActiveUserId(user.id);
          await ProfileService.applyCloudProfile(
            userId: user.id,
            fullName: user.fullName,
            avatarUrl: user.avatarUrl,
          );
          unawaited(UserCloudSyncService.hydrateFromCloud(user: user, force: force));
          updateCachedSessionState(
            isLoggedIn: user.isApproved || user.isAdmin,
            isAdmin: user.isAdmin,
          );

          if (user.isBusiness || user.isAdmin) {
            await SubscriptionService.activatePlan(
              SubscriptionPlan.business,
              paymentMethod: user.isAdmin ? 'Administrator License' : 'Business Commercial License',
            );
            await TrialService.setTrialMode(false);
          } else if (user.isPro) {
            await SubscriptionService.activatePlan(
              SubscriptionPlan.pro,
              paymentMethod: 'Pro Lifetime License',
            );
            await TrialService.setTrialMode(false);
          } else {
            // User trial / standard: pastikan SubscriptionService strictly trial!
            await SubscriptionService.resetToTrial();
            await TrialService.setTrialMode(true);
          }

          if (hasChanged) {
            changeNotifier.value++;
          }
          return user;
        }
      }
    } catch (_) {}
    return getCurrentUser();
  }

  // ================= ADMIN FUNCTIONS =================

  /// Mengambil data statistik ringkas pengguna untuk Dashboard Admin
  static Future<AdminUserStats> getAdminUserStats() => AdminUserService.getAdminUserStats();

  /// Ambil daftar seluruh user (Khusus Admin)
  static Future<List<AuthUser>> getAdminUsers() => AdminUserService.getAdminUsers();

  /// Setujui / Aktifkan akun user oleh Admin
  static Future<bool> acceptUser(String userId) => AdminUserService.acceptUser(userId);

  /// Tolak / Nonaktifkan (Decline) user oleh Admin
  static Future<bool> declineUser(String userId) => AdminUserService.declineUser(userId);

  /// Hapus user dari database (Khusus Admin)
  static Future<bool> deleteUser(String userId) => AdminUserService.deleteUser(userId);

  /// Ubah tier/kebijakan akses akun user oleh Admin ('trial' | 'trial_7d' | 'pro' | 'business')
  static Future<bool> updateUserTier(
    String userId,
    String tier, {
    int? trialDays,
  }) =>
      AdminUserService.updateUserTier(userId, tier, trialDays: trialDays);
}
