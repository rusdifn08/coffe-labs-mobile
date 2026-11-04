import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/rust_api_client.dart';

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

/// Implementasi BrewLogRepository dengan penyimpanan offline SharedPreferences dan sinkronisasi Rust API.
class BrewLogRepositoryImpl implements BrewLogRepository {
  static const String _historyKey = 'coffeehub_history_v3';
  static const String _journalKey = 'coffeehub_brew_journal_v1';

  final RustApiClient _apiClient;
  List<Map<String, dynamic>>? _cachedHistory;
  List<Map<String, dynamic>>? _cachedJournal;

  BrewLogRepositoryImpl({required RustApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Map<String, dynamic>>> getBrewHistory() async {
    if (_cachedHistory != null) return List<Map<String, dynamic>>.from(_cachedHistory!);

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_historyKey);
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
    final history = await getBrewHistory();
    history.insert(0, record);

    if (history.length > 100) {
      history.removeRange(100, history.length);
    }

    _cachedHistory = history;
    await prefs.setString(_historyKey, json.encode(history));

    // Sinkronisasi background ke Rust backend
    try {
      await _apiClient.post('/api/brew-logs', body: record);
    } catch (_) {}
  }

  @override
  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    if (_cachedJournal != null) return List<Map<String, dynamic>>.from(_cachedJournal!);

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_journalKey);
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
    await prefs.setString(_journalKey, json.encode(entries));

    try {
      await _apiClient.post('/api/brew-logs/journal', body: entry);
    } catch (_) {}
  }

  @override
  Future<void> deleteJournalEntry(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getJournalEntries();
    entries.removeWhere((e) => e['id'] == id);

    _cachedJournal = entries;
    await prefs.setString(_journalKey, json.encode(entries));

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
