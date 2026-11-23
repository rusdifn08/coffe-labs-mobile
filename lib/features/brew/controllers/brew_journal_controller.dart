import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/user_scoped_storage.dart';
import '../../../repositories/brew_log_repository.dart';
import '../../../services/api_service.dart';
import '../journal/models/brew_journal_entry.dart';

part 'brew_journal_controller.g.dart';

/// AsyncNotifier untuk mengelola catatan jurnal seduh, grafik sensorik,
/// pembaruan fleksibel (edit/update), dan catatan tambahan (follow-up notes).
@riverpod
class BrewJournalController extends _$BrewJournalController {
  bool _isSelfMutating = false;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    void onScopeOrDataChanged() {
      if (_isSelfMutating || !ref.mounted) return;
      ref.invalidateSelf();
    }

    UserScopedStorage.activeUserIdNotifier.addListener(onScopeOrDataChanged);
    ApiService.changeNotifier.addListener(onScopeOrDataChanged);
    ref.onDispose(() {
      UserScopedStorage.activeUserIdNotifier.removeListener(onScopeOrDataChanged);
      ApiService.changeNotifier.removeListener(onScopeOrDataChanged);
    });

    final repo = ref.watch(brewLogRepositoryProvider);
    return repo.getJournalEntries();
  }

  Future<void> _reloadState(BrewLogRepository repo) async {
    final fresh = await repo.getJournalEntries();
    if (ref.mounted) {
      state = AsyncValue.data(fresh);
    }
  }

  /// Menambah catatan jurnal seduh baru.
  Future<void> addEntry(Map<String, dynamic> entry) async {
    final repo = ref.read(brewLogRepositoryProvider);
    _isSelfMutating = true;
    try {
      await repo.saveJournalEntry(entry);
    } finally {
      _isSelfMutating = false;
    }
    await _reloadState(repo);
  }

  /// Memperbarui seluruh isi catatan jurnal (judul, grind, rating, grafik sensorik, notes, dll).
  Future<void> updateEntry(BrewJournalEntry updated) async {
    final repo = ref.read(brewLogRepositoryProvider);
    final stamped = updated.copyWith(updatedAt: DateTime.now());
    _isSelfMutating = true;
    try {
      await repo.saveJournalEntry(stamped.toMap());
    } finally {
      _isSelfMutating = false;
    }
    await _reloadState(repo);
  }

  /// Menambahkan catatan tambahan (follow-up note) bertanggal ke suatu entri jurnal.
  Future<BrewJournalEntry> addFollowUpNote(
    BrewJournalEntry entry,
    String noteText,
  ) async {
    final trimmed = noteText.trim();
    if (trimmed.isEmpty) return entry;
    final nextNotes = [
      JournalFollowUpNote(
        id: DateTime.now().microsecondsSinceEpoch,
        text: trimmed,
        createdAt: DateTime.now(),
      ),
      ...entry.additionalNotes,
    ];
    final updated = entry.copyWith(
      additionalNotes: nextNotes,
      updatedAt: DateTime.now(),
    );
    await updateEntry(updated);
    return updated;
  }

  /// Mengedit teks catatan tambahan tertentu di dalam entri jurnal.
  Future<BrewJournalEntry> editFollowUpNote(
    BrewJournalEntry entry,
    int noteId,
    String newText,
  ) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) return entry;
    final nextNotes = entry.additionalNotes
        .map(
          (n) => n.id == noteId
              ? n.copyWith(text: trimmed, updatedAt: DateTime.now())
              : n,
        )
        .toList();
    final updated = entry.copyWith(
      additionalNotes: nextNotes,
      updatedAt: DateTime.now(),
    );
    await updateEntry(updated);
    return updated;
  }

  /// Menghapus salah satu catatan tambahan dari entri jurnal.
  Future<BrewJournalEntry> deleteFollowUpNote(
    BrewJournalEntry entry,
    int noteId,
  ) async {
    final nextNotes =
        entry.additionalNotes.where((n) => n.id != noteId).toList();
    final updated = entry.copyWith(
      additionalNotes: nextNotes,
      updatedAt: DateTime.now(),
    );
    await updateEntry(updated);
    return updated;
  }

  /// Menghapus catatan jurnal tertentu.
  Future<void> deleteEntry(int id) async {
    final repo = ref.read(brewLogRepositoryProvider);
    _isSelfMutating = true;
    try {
      await repo.deleteJournalEntry(id);
    } finally {
      _isSelfMutating = false;
    }
    await _reloadState(repo);
  }
}
