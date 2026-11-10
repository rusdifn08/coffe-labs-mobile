import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_user_stats.dart';
import 'auth_service.dart';

class AdminUserService {
  /// Ambil ringkasan statistik user untuk Dashboard Admin (Total Pengguna, Registrasi Baru, dsb)
  static Future<AdminUserStats> getAdminUserStats() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return AdminUserStats.empty();

      final baseUrl = await AuthService.getBaseUrl();
      final uri = Uri.parse('$baseUrl/api/admin/users/stats');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['data'] != null) {
          return AdminUserStats.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      return AdminUserStats.empty();
    } catch (_) {
      return AdminUserStats.empty();
    }
  }

  /// Ambil daftar seluruh user (Khusus Admin)
  static Future<List<AuthUser>> getAdminUsers() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final baseUrl = await AuthService.getBaseUrl();
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

  /// Setujui / Aktifkan akun user oleh Admin
  static Future<bool> acceptUser(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final baseUrl = await AuthService.getBaseUrl();
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

      final response = await http.patch(
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
