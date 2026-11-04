import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../repositories/brew_log_repository.dart';

part 'brew_history_controller.g.dart';

/// AsyncNotifier untuk mengelola riwayat seduh kopi dan catatan hasil rasa.
@riverpod
class BrewHistoryController extends _$BrewHistoryController {
  @override
  Future<List<Map<String, dynamic>>> build() async {
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
