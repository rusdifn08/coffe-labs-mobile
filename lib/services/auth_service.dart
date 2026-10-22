import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_service.dart';
import 'trial_service.dart';

class AuthUser {
  final String id;
  final String username;
  final String fullName;
  final String role;
  final String status;
  final String avatarUrl;
  final String? createdAt;

  const AuthUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.status,
    required this.avatarUrl,
    this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? 'Barista',
      role: json['role']?.toString() ?? 'user',
      status: json['status']?.toString() ?? 'pending',
      avatarUrl: json['avatar_url']?.toString() ?? json['avatarUrl']?.toString() ?? 'assets/images/characters/avatar_1.png',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'full_name': fullName,
    'role': role,
    'status': status,
    'avatar_url': avatarUrl,
    'created_at': createdAt,
  };

  bool get isAdmin => role == 'admin';
  bool get isApproved => status == 'approved';
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
  static const String _userKey = 'coffeehub_auth_user_json';
  static const String _serverUrlKey = 'coffeehub_backend_server_url';
  static const String defaultProductionUrl = 'https://coffe-labs-backend.onrender.com';

  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  /// Melakukan ping senyap ke backend di background saat app mulai
  /// untuk mengantisipasi cold-start Render free tier
  static void warmUpBackend() {
    getBaseUrl().then((url) {
      http.get(Uri.parse('$url/api/health')).timeout(const Duration(seconds: 30)).then((_) {
        debugPrint('☕ Backend warmup ping sukses: $url');
      }).catchError((_) {});
    }).catchError((_) {});
  }

  /// Deteksi Base URL backend secara dinamis:
  /// Mengutamakan URL Render Production, dengan dukungan override via SharedPreferences
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString(_serverUrlKey);
    if (customUrl != null && customUrl.trim().isNotEmpty) {
      final trimmed = customUrl.trim();
      // Jika masih tersimpan url lokal lama (localhost / 10.0.2.2), otomatis alihkan ke Render
      if (!trimmed.contains('localhost') && !trimmed.contains('10.0.2.2')) {
        return trimmed;
      }
    }

    return defaultProductionUrl;
  }

  /// Memperbarui alamat server backend jika diperlukan
  static Future<void> setCustomBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url.trim().isEmpty) {
      await prefs.remove(_serverUrlKey);
    } else {
      await prefs.setString(_serverUrlKey, url.trim());
    }
    changeNotifier.value++;
  }

  /// Cek apakah pengguna saat ini sudah login secara resmi dan approved
  static Future<bool> isLoggedIn() async {
    final inTrial = await TrialService.isTrialMode();
    if (inTrial) return false;

    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    final user = await getCurrentUser();
    return user != null && (user.isApproved || user.isAdmin);
  }

  /// Cek apakah pengguna yang sedang login memiliki hak akses ADMIN
  static Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user != null && user.isAdmin;
  }

  /// Mengambil JWT token yang tersimpan di memori perangkat
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Mengambil profil pengguna yang sedang login
  static Future<AuthUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_userKey);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final decoded = json.decode(rawJson) as Map<String, dynamic>;
      return AuthUser.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Login dengan Username dan Password
  static Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/auth/login');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 45));

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final payload = data['data'] as Map<String, dynamic>;
        final token = payload['token'] as String;
        final user = AuthUser.fromJson(payload['user'] as Map<String, dynamic>);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, json.encode(user.toJson()));

        // Sinkronisasi dengan ProfileService & matikan mode trial
        await ProfileService.setUserName(user.fullName);
        if (user.avatarUrl.isNotEmpty) {
          await ProfileService.setUserImagePath(user.avatarUrl);
        }
        await TrialService.setTrialMode(false);

        changeNotifier.value++;
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

  /// Pendaftaran akun baru (default berstatus PENDING hingga di-accept admin)
  static Future<AuthResult> register({
    required String username,
    required String password,
    required String fullName,
    String? avatarUrl,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/auth/register');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username.trim(),
          'password': password,
          'full_name': fullName.trim(),
          'avatar_url': avatarUrl,
        }),
      ).timeout(const Duration(seconds: 45));

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        final userData = data['data'] != null ? AuthUser.fromJson(data['data']) : null;
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Pendaftaran berhasil! Akun Anda sedang menunggu persetujuan (Accept) dari Admin.',
          user: userData,
          status: 'pending',
        );
      } else if (response.statusCode == 409) {
        return AuthResult.error(
          'Username "$username" sudah terdaftar di sistem. Jika ini akun Anda, silakan beralih ke menu Login untuk masuk atau memeriksa status akun.',
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

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Password berhasil diubah!'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal mengubah password.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghubungi server: $e'};
    }
  }

  /// Logout pengguna dan bersihkan sesi
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await TrialService.setTrialMode(false);
    changeNotifier.value++;
  }

  // ================= ADMIN FUNCTIONS =================

  /// Ambil daftar seluruh user (Khusus Admin)
  static Future<List<AuthUser>> getAdminUsers() async {
    try {
      final token = await getToken();
      if (token == null) return [];

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/users');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>? ?? [];
        return list.map((e) => AuthUser.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Setujui (Accept) user baru oleh Admin
  static Future<bool> acceptUser(String userId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/users/$userId/accept');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Tolak (Decline) user oleh Admin
  static Future<bool> declineUser(String userId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/users/$userId/decline');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Hapus user dari database (Khusus Admin)
  static Future<bool> deleteUser(String userId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final baseUrl = await getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/users/$userId');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
