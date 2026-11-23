import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/rust_api_client.dart';
import '../core/storage/user_scoped_storage.dart';
import '../services/api_service.dart';

part 'brew_log_repository.g.dart';

/// Kontrak Repositori Riwayat Seduh dan Jurnal Evaluasi Rasa.
abstract class BrewLogRepository {
  Future<List<Map<String, dynamic>>> getBrewHistory();
  Future<void> saveBrewRecord(Map<String, dynamic> record);
  Future<List<Map<String, dynamic>>> getJournalEntries();
  Future<void> saveJournalEntry(Map<String, dynamic> entry);
  Future<void> deleteJournalEntry(int id);
  Future<void> syncWithRustBackend();
}

/// Implementasi BrewLogRepository terisolasi per-user (`u_<userId>_*`) dengan sinkronisasi Rust API.
class BrewLogRepositoryImpl implements BrewLogRepository {
  static const String _historyKey = 'coffeehub_history_v3';
  static const String _journalKey = 'coffeehub_brew_journal_v1';

  final RustApiClient _apiClient;
  String? _cachedUserId;
  int _cachedApiVersion = -1;
  List<Map<String, dynamic>>? _cachedHistory;
  List<Map<String, dynamic>>? _cachedJournal;

  BrewLogRepositoryImpl({required RustApiClient apiClient}) : _apiClient = apiClient;

  void _ensureFreshCache(String uid) {
    final ver = ApiService.changeNotifier.value;
    if (_cachedUserId != uid || _cachedApiVersion != ver) {
      _cachedHistory = null;
      _cachedJournal = null;
      _cachedUserId = uid;
      _cachedApiVersion = ver;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBrewHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    _ensureFreshCache(uid);
    if (_cachedHistory != null) return List<Map<String, dynamic>>.from(_cachedHistory!);

    final jsonStr = prefs.getString(UserScopedStorage.scopedKey(_historyKey, userId: uid));
    if (jsonStr == null) return [];

    try {
      final rawList = json.decode(jsonStr) as List<dynamic>;
      final result = rawList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      _cachedHistory = result;
      return List<Map<String, dynamic>>.from(result);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveBrewRecord(Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    final history = await getBrewHistory();
    history.insert(0, record);

    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    _cachedHistory = history;
    await prefs.setString(
      UserScopedStorage.scopedKey(_historyKey, userId: uid),
      json.encode(history),
    );
    ApiService.clearMemoryCache();
    ApiService.changeNotifier.value++;
    _cachedApiVersion = ApiService.changeNotifier.value;
    UserScopedStorage.notifyDataMutated();

    try {
      await _apiClient.post('/api/brew-logs', body: record);
    } catch (_) {}
  }

  @override
  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    _ensureFreshCache(uid);
    if (_cachedJournal != null) return List<Map<String, dynamic>>.from(_cachedJournal!);

    final jsonStr = prefs.getString(UserScopedStorage.scopedKey(_journalKey, userId: uid));
    if (jsonStr == null) return [];

    try {
      final rawList = json.decode(jsonStr) as List<dynamic>;
      final result = rawList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      _cachedJournal = result;
      return List<Map<String, dynamic>>.from(result);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveJournalEntry(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    final entries = await getJournalEntries();

    final entryId = entry['id'] ?? DateTime.now().millisecondsSinceEpoch;
    entry['id'] = entryId;

    final existingIndex = entries.indexWhere((e) => e['id'] == entryId);
    if (existingIndex >= 0) {
      entries[existingIndex] = entry;
    } else {
      entries.insert(0, entry);
    }

    _cachedJournal = entries;
    await prefs.setString(
      UserScopedStorage.scopedKey(_journalKey, userId: uid),
      json.encode(entries),
    );
    ApiService.changeNotifier.value++;
    _cachedApiVersion = ApiService.changeNotifier.value;
    UserScopedStorage.notifyDataMutated();

    try {
      await _apiClient.post('/api/brew-logs/journal', body: entry);
    } catch (_) {}
  }

  @override
  Future<void> deleteJournalEntry(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    final entries = await getJournalEntries();
    entries.removeWhere((e) => e['id'] == id);

    _cachedJournal = entries;
    await prefs.setString(
      UserScopedStorage.scopedKey(_journalKey, userId: uid),
      json.encode(entries),
    );
    ApiService.changeNotifier.value++;
    _cachedApiVersion = ApiService.changeNotifier.value;
    UserScopedStorage.notifyDataMutated();

    try {
      await _apiClient.delete('/api/brew-logs/journal/$id');
    } catch (_) {}
  }

  @override
  Future<void> syncWithRustBackend() async {
    try {
      final response = await _apiClient.get('/api/brew-logs');
      if (response is List) {
        for (final item in response) {
          if (item is Map<String, dynamic>) {
            await saveBrewRecord(item);
          }
        }
      }
    } catch (_) {}
  }
}

/// Provider Dependency Injection untuk [BrewLogRepository].
@riverpod
BrewLogRepository brewLogRepository(Ref ref) {
  final apiClient = ref.watch(rustApiClientProvider);
  return BrewLogRepositoryImpl(apiClient: apiClient);
}
