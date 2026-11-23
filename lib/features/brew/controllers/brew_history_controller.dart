import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/user_scoped_storage.dart';
import '../../../repositories/brew_log_repository.dart';
import '../../../services/api_service.dart';

part 'brew_history_controller.g.dart';

/// AsyncNotifier untuk mengelola riwayat seduh kopi dan catatan hasil rasa per-akun.
@riverpod
class BrewHistoryController extends _$BrewHistoryController {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    void onScopeOrDataChanged() {
      if (ref.mounted) ref.invalidateSelf();
    }

    UserScopedStorage.activeUserIdNotifier.addListener(onScopeOrDataChanged);
    ApiService.changeNotifier.addListener(onScopeOrDataChanged);
    ref.onDispose(() {
      UserScopedStorage.activeUserIdNotifier.removeListener(onScopeOrDataChanged);
      ApiService.changeNotifier.removeListener(onScopeOrDataChanged);
    });

    final repo = ref.watch(brewLogRepositoryProvider);
    return repo.getBrewHistory();
  }

  /// Menyimpan catatan hasil seduh baru.
  Future<void> saveBrewRecord(Map<String, dynamic> record) async {
    final repo = ref.read(brewLogRepositoryProvider);
    await repo.saveBrewRecord(record);
    ref.invalidateSelf();
  }

  /// Sinkronisasi riwayat seduh ke Rust backend.
  Future<void> syncWithCloud() async {
    final repo = ref.read(brewLogRepositoryProvider);
    await repo.syncWithRustBackend();
    ref.invalidateSelf();
  }
}
