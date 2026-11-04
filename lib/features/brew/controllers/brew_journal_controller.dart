import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../repositories/brew_log_repository.dart';

part 'brew_journal_controller.g.dart';

/// AsyncNotifier untuk mengelola catatan jurnal seduh, evaluasi rasa (tasting notes), dan rating.
@riverpod
class BrewJournalController extends _$BrewJournalController {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.watch(brewLogRepositoryProvider);
    return repo.getJournalEntries();
  }

  /// Menambah catatan jurnal seduh baru.
  Future<void> addEntry(Map<String, dynamic> entry) async {
    final repo = ref.read(brewLogRepositoryProvider);
    await repo.saveJournalEntry(entry);
    ref.invalidateSelf();
  }

  /// Menghapus catatan jurnal tertentu.
  Future<void> deleteEntry(int id) async {
    final repo = ref.read(brewLogRepositoryProvider);
    await repo.deleteJournalEntry(id);
    ref.invalidateSelf();
  }
}
