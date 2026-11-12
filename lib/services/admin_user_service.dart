import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_user_stats.dart';
import 'auth_service.dart';

class AdminUserService {
  static final http.Client _client = http.Client();
  static AdminUserStats? _cachedStats;
  static DateTime? _cachedStatsTime;
  static const Duration _statsTtl = Duration(seconds: 30);

  /// Ambil ringkasan statistik user untuk Dashboard Admin (Total Pengguna, Registrasi Baru, dsb)
  static Future<AdminUserStats> getAdminUserStats({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh && _cachedStats != null && _cachedStatsTime != null) {
      if (now.difference(_cachedStatsTime!) < _statsTtl) {
        return _cachedStats!;
      }
    }

    try {
      final token = await AuthService.getToken();
      if (token == null) return _cachedStats ?? AdminUserStats.empty();

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/users/stats');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['data'] != null) {
          _cachedStats = AdminUserStats.fromJson(data['data'] as Map<String, dynamic>);
          _cachedStatsTime = DateTime.now();
          return _cachedStats!;
        }
      }
      return _cachedStats ?? AdminUserStats.empty();
    } catch (_) {
      return _cachedStats ?? AdminUserStats.empty();
    }
  }

  /// Ambil daftar seluruh user (Khusus Admin)
  static Future<List<AuthUser>> getAdminUsers() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/users');

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

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

  /// Setujui / Aktifkan akun user oleh Admin
  static Future<bool> acceptUser(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/users/$userId/accept');

      final response = await _client.post(
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

  /// Nonaktifkan / Tolak (Decline) user oleh Admin
  static Future<bool> declineUser(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final baseUrl = await AuthService.getBaseUrl();
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

  /// Hapus user permanen dari database (Khusus Admin)
  static Future<bool> deleteUser(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final baseUrl = await AuthService.getBaseUrl();
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

  /// Ubah tier langganan user secara langsung (Khusus Admin: trial / pro / business)
  static Future<bool> updateUserTier(String userId, String tier) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/users/$userId/tier');

      final response = await _client.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'tier': tier.trim().toLowerCase()}),
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
