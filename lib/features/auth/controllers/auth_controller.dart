import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/user_scoped_storage.dart';
import '../../../repositories/auth_repository.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_cloud_sync_service.dart';
import '../../brew/controllers/brew_history_controller.dart';
import '../../notifications/data/services/device_token_lifecycle_service.dart';
import '../../notifications/presentation/controllers/notification_center_controller.dart';
import '../../recipes/controllers/recipe_list_controller.dart';
import '../../social_chat/presentation/controllers/chat_controllers.dart';

part 'auth_controller.g.dart';

/// AsyncNotifier untuk otentikasi pengguna, peran, status persetujuan, dan tier langganan.
@riverpod
class AuthController extends _$AuthController {
  bool _suppressNotifier = false;

  @override
  Future<AuthUser?> build() async {
    void onAuthChanged() {
      if (_suppressNotifier) return;
      ref.invalidateSelf();
    }

    AuthService.changeNotifier.addListener(onAuthChanged);
    ref.onDispose(() {
      AuthService.changeNotifier.removeListener(onAuthChanged);
    });

    UserCloudSyncService.ensureHooksRegistered();
    final repo = ref.watch(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    if (user != null) {
      UserScopedStorage.setActiveUserId(user.id);
      unawaited(UserCloudSyncService.hydrateFromCloud(user: user));
    } else {
      UserScopedStorage.resetToGuest();
    }
    return user;
  }

  /// Eksekusi proses login akun barista.
  Future<AuthResult> login({required String username, required String password}) async {
    final repo = ref.read(authRepositoryProvider);
    _suppressNotifier = true;
    late final AuthResult result;
    try {
      result = await repo.login(username: username, password: password);
    } finally {
      _suppressNotifier = false;
    }
    if (result.success && result.user != null) {
      state = AsyncValue.data(result.user);
      ref.invalidate(brewHistoryControllerProvider);
      ref.invalidate(recipeListControllerProvider);
      ref.invalidate(favoriteIdsProvider);
      ref.invalidate(chatRoomListControllerProvider);
      unawaited(
        ref
            .read(deviceTokenLifecycleServiceProvider)
            .initializeAndSyncToken(requestPermission: true),
      );
      unawaited(ref.read(chatWsServiceProvider).connectIfAuthenticated());
      unawaited(
        ref.read(unreadNotificationsCountProvider.notifier).refresh(),
      );
    }
    return result;
  }

  /// Eksekusi proses pendaftaran akun barista baru.
  Future<AuthResult> register({
    required String username,
    required String password,
    required String fullName,
    String? email,
    required String avatarUrl,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    _suppressNotifier = true;
    late final AuthResult result;
    try {
      result = await repo.register(
        username: username,
        password: password,
        fullName: fullName,
        email: email,
        avatarUrl: avatarUrl,
      );
    } finally {
      _suppressNotifier = false;
    }
    if (result.success && result.user != null) {
      state = AsyncValue.data(result.user);
      ref.invalidate(brewHistoryControllerProvider);
      ref.invalidate(recipeListControllerProvider);
      ref.invalidate(favoriteIdsProvider);
      ref.invalidate(chatRoomListControllerProvider);
      unawaited(
        ref
            .read(deviceTokenLifecycleServiceProvider)
            .initializeAndSyncToken(requestPermission: true),
      );
      unawaited(ref.read(chatWsServiceProvider).connectIfAuthenticated());
      unawaited(
        ref.read(unreadNotificationsCountProvider.notifier).refresh(),
      );
    }
    return result;
  }

  /// Logout akun pengguna.
  Future<void> logout() async {
    try {
      await ref.read(deviceTokenLifecycleServiceProvider).unregisterOnLogout();
    } catch (_) {}
    try {
      final ws = ref.read(chatWsServiceProvider);
      await ws.setActiveRoom(null);
      await ws.disconnect();
    } catch (_) {}
    try {
      await ref.read(chatDriftDatabaseProvider).clearAllUserData();
    } catch (_) {}

    final repo = ref.read(authRepositoryProvider);
    _suppressNotifier = true;
    try {
      await repo.logout();
    } finally {
      _suppressNotifier = false;
    }
    ref.invalidate(brewHistoryControllerProvider);
    ref.invalidate(recipeListControllerProvider);
    ref.invalidate(favoriteIdsProvider);
    ref.invalidate(chatRoomListControllerProvider);
    ref.read(unreadNotificationsCountProvider.notifier).setCount(0);
    state = const AsyncValue.data(null);
  }

  /// Upgrade tier langganan pengguna (Pro / Business).
  Future<bool> upgradePlan(String planId) async {
    final repo = ref.read(authRepositoryProvider);
    final success = await repo.upgradeTier(planId);
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }
}

/// Selector sederhana untuk memeriksa apakah pengguna berstatus admin.
@riverpod
bool isUserAdmin(Ref ref) {
  final userAsync = ref.watch(authControllerProvider);
  return userAsync.maybeWhen(
    data: (user) => user?.isAdmin ?? false,
    orElse: () => false,
  );
}
