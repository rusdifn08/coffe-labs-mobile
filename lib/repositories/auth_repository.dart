import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/rust_api_client.dart';
import '../services/auth_service.dart';

part 'auth_repository.g.dart';

/// Kontrak Repositori Otentikasi & Akun Coffee Labs.
abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();
  Future<AuthResult> login({required String username, required String password});
  Future<AuthResult> register({
    required String username,
    required String password,
    required String fullName,
    required String avatarUrl,
  });
  Future<void> logout();
  Future<bool> upgradeTier(String planId);
}

/// Implementasi AuthRepository yang terhubung ke Rust Axum backend.
class AuthRepositoryImpl implements AuthRepository {
  static const String _userSessionKey = 'coffeehub_auth_session_user';
  static const String _authTokenKey = 'coffeehub_auth_token_v1';

  final RustApiClient _apiClient;
  AuthUser? _cachedUser;

  AuthRepositoryImpl({required RustApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthUser?> getCurrentUser() async {
    if (_cachedUser != null) return _cachedUser;
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_userSessionKey);
    if (rawJson != null) {
      try {
        final decoded = json.decode(rawJson) as Map<String, dynamic>;
        _cachedUser = AuthUser.fromJson(decoded);
        return _cachedUser;
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<AuthResult> login({required String username, required String password}) async {
    try {
      final response = await _apiClient.post('/api/auth/login', body: {
        'username': username.trim().toLowerCase(),
        'password': password,
      });

      if (response is Map) {
        final userMap = response['user'] as Map<String, dynamic>? ?? response as Map<String, dynamic>;
        final user = AuthUser.fromJson(userMap);
        final token = response['token']?.toString() ?? 'session_token_${user.id}';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userSessionKey, json.encode(user.toJson()));
        await prefs.setString(_authTokenKey, token);
        _cachedUser = user;

        return AuthResult(success: true, message: 'Login berhasil', user: user, token: token);
      }
      return const AuthResult(success: false, message: 'Format respon backend tidak valid.');
    } catch (e) {
      // Fallback offline mock untuk pengembangan
      return AuthResult(success: false, message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<AuthResult> register({
    required String username,
    required String password,
    required String fullName,
    required String avatarUrl,
  }) async {
    try {
      final response = await _apiClient.post('/api/auth/register', body: {
        'username': username.trim().toLowerCase(),
        'password': password,
        'full_name': fullName.trim(),
        'avatar_url': avatarUrl,
      });

      if (response is Map) {
        final userMap = response['user'] as Map<String, dynamic>? ?? response as Map<String, dynamic>;
        final user = AuthUser.fromJson(userMap);
        final token = response['token']?.toString() ?? 'session_token_${user.id}';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userSessionKey, json.encode(user.toJson()));
        await prefs.setString(_authTokenKey, token);
        _cachedUser = user;

        return AuthResult(success: true, message: 'Registrasi berhasil', user: user, token: token);
      }
      return const AuthResult(success: false, message: 'Format respon backend tidak valid.');
    } catch (e) {
      return AuthResult(success: false, message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSessionKey);
    await prefs.remove(_authTokenKey);
    _cachedUser = null;
  }

  @override
  Future<bool> upgradeTier(String planId) async {
    try {
      final response = await _apiClient.post('/api/auth/upgrade', body: {'plan_id': planId});
      return response != null;
    } catch (_) {
      return false;
    }
  }
}

/// Provider Dependency Injection untuk [AuthRepository].
@riverpod
AuthRepository authRepository(Ref ref) {
  final apiClient = ref.watch(rustApiClientProvider);
  return AuthRepositoryImpl(apiClient: apiClient);
}
