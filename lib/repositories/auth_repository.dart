import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/rust_api_client.dart';
import '../core/storage/user_scoped_storage.dart';
import '../features/gamification/services/gamification_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/user_cloud_sync_service.dart';

part 'auth_repository.g.dart';

/// Kontrak Repositori Otentikasi & Akun Coffee Labs.
abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();
  Future<AuthResult> login({required String username, required String password});
  Future<AuthResult> register({
    required String username,
    required String password,
    required String fullName,
    String? email,
    required String avatarUrl,
  });
  Future<void> logout();
  Future<bool> upgradeTier(String planId);
}

/// Implementasi AuthRepository yang terhubung ke Rust Axum backend.
class AuthRepositoryImpl implements AuthRepository {
  static const String _userSessionKey = 'coffeehub_auth_session_user';
  static const String _authTokenKey = 'coffeehub_auth_token_v1';
  static const String _legacyUserKey = 'coffeehub_auth_user_json';
  static const String _legacyTokenKey = 'coffeehub_auth_jwt_token';

  final RustApiClient _apiClient;
  AuthUser? _cachedUser;
  int _lastAuthChangeVersion = -1;

  AuthRepositoryImpl({required RustApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthUser?> getCurrentUser() async {
    final version = AuthService.changeNotifier.value;
    if (_cachedUser != null &&
        _cachedUser!.id.trim().isNotEmpty &&
        _lastAuthChangeVersion == version) {
      return _cachedUser;
    }

    final resolved = await AuthService.getCurrentUser();
    _lastAuthChangeVersion = AuthService.changeNotifier.value;
    _cachedUser = resolved;
    return resolved;
  }

  Future<void> _persistUnifiedSession(AuthUser user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await AuthService.persistSessionMirrors(prefs, user: user, token: token);
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
    _cachedUser = user;
    GamificationService.instance.notifySessionSwitched();
    ProfileService.notifySessionSwitched();
    ApiService.changeNotifier.value++;
    AuthService.changeNotifier.value++;
    _lastAuthChangeVersion = AuthService.changeNotifier.value;
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
        await _persistUnifiedSession(user, token);

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
    String? email,
    required String avatarUrl,
  }) async {
    try {
      final cleanEmail = email?.trim().toLowerCase();
      final response = await _apiClient.post('/api/auth/register', body: {
        'username': username.trim().toLowerCase(),
        'password': password,
        'full_name': fullName.trim(),
        if (cleanEmail != null && cleanEmail.isNotEmpty) 'email': cleanEmail,
        'avatar_url': avatarUrl,
      });

      if (response is Map) {
        final userMap = response['user'] as Map<String, dynamic>? ?? response as Map<String, dynamic>;
        final user = AuthUser.fromJson(userMap);
        final token = response['token']?.toString() ?? 'session_token_${user.id}';
        await _persistUnifiedSession(user, token);

        return AuthResult(success: true, message: 'Registrasi berhasil', user: user, token: token);
      }
      return const AuthResult(success: false, message: 'Format respon backend tidak valid.');
    } catch (e) {
      return AuthResult(success: false, message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    await UserCloudSyncService.flushPendingSync();
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_userSessionKey),
      prefs.remove(_authTokenKey),
      prefs.remove(_legacyUserKey),
      prefs.remove(_legacyTokenKey),
    ]);
    UserScopedStorage.resetToGuest();
    ApiService.clearMemoryCache();
    _cachedUser = null;
    GamificationService.instance.notifySessionSwitched();
    ProfileService.notifySessionSwitched();
    ApiService.changeNotifier.value++;
    AuthService.changeNotifier.value++;
    _lastAuthChangeVersion = AuthService.changeNotifier.value;
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
