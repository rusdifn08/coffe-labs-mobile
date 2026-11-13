import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../repositories/auth_repository.dart';
import '../../../services/auth_service.dart';
import '../../notifications/data/services/device_token_lifecycle_service.dart';
import '../../notifications/presentation/controllers/notification_center_controller.dart';
import '../../social_chat/presentation/controllers/chat_controllers.dart';

part 'auth_controller.g.dart';

/// AsyncNotifier untuk otentikasi pengguna, peran, status persetujuan, dan tier langganan.
@riverpod
class AuthController extends _$AuthController {
  @override
  Future<AuthUser?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return repo.getCurrentUser();
  }

  /// Eksekusi proses login akun barista.
  Future<AuthResult> login({required String username, required String password}) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(username: username, password: password);
    if (result.success && result.user != null) {
      state = AsyncValue.data(result.user);
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
    required String avatarUrl,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.register(
      username: username,
      password: password,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
    if (result.success && result.user != null) {
      state = AsyncValue.data(result.user);
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

    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
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
