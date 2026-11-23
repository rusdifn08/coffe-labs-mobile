import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage/user_scoped_storage.dart';
import 'recipe_sanitizer.dart';
import 'seed_data.dart';
import '../utils/barista_utils.dart';

class ApiService {
  static const String _customRecipesKey = 'coffeehub_custom_recipes_v2';
  static const String _deletedDefaultIdsKey = 'coffeehub_deleted_default_ids_v1';
  static const String _basecampsKey = 'coffeehub_basecamps_v12';
  static const String _historyKey = 'coffeehub_history_v3';
  static const String _favoritesKey = 'coffeehub_favorites_v1';
  static const String _journalKey = 'coffeehub_brew_journal_v1';

  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  static String? _cachedForUserId;
  static List<Map<String, dynamic>>? _recipesCache;
  static List<dynamic>? _historyCache;
  static Set<int>? _favoritesCache;
  static List<Map<String, dynamic>>? _uniqueBaristasCache;

  static void _ensureCacheMatchesUser(String uid) {
    if (_cachedForUserId != uid) {
      clearMemoryCache();
      _cachedForUserId = uid;
    }
  }

  static void clearMemoryCache() {
    _cachedForUserId = null;
    _recipesCache = null;
    _historyCache = null;
    _favoritesCache = null;
    _uniqueBaristasCache = null;
  }

  static void clearFavoritesCache() {
    _favoritesCache = null;
  }

  static void _notifyChanged({bool pushCloud = true}) {
    _uniqueBaristasCache = null;
    changeNotifier.value++;
    if (pushCloud) {
      UserScopedStorage.notifyDataMutated();
    }
  }

  /// Menjamin tidak ada satupun field resep atau step yang bernilai null.
  static Map<String, dynamic> sanitizeRecipe(Map<dynamic, dynamic> raw, {int fallbackId = 1}) {
    return RecipeSanitizer.sanitizeRecipe(raw, fallbackId: fallbackId);
  }

  /// Mengekspor seluruh koleksi personal milik `userId` untuk sinkronisasi ke NeonDB Cloud.
  static Future<Map<String, dynamic>> exportCloudCollections({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = userId != null && userId.trim().isNotEmpty
        ? UserScopedStorage.normalizeUserId(userId)
        : await UserScopedStorage.resolveActiveUserId(prefs: prefs);

    List<dynamic> decodeList(String baseKey) {
      final raw = prefs.getString(UserScopedStorage.scopedKey(baseKey, userId: uid));
      if (raw == null || raw.isEmpty) return const [];
      try {
        final parsed = json.decode(raw);
        return parsed is List ? parsed : const [];
      } catch (_) {
        return const [];
      }
    }

    List<int> decodeIds(String baseKey) {
      final raw = prefs.getStringList(UserScopedStorage.scopedKey(baseKey, userId: uid)) ?? const [];
      return raw.map((e) => int.tryParse(e) ?? -1).where((e) => e > 0).toSet().toList();
    }

    return {
      'brew_history': decodeList(_historyKey),
      'brew_journal': decodeList(_journalKey),
      'favorite_recipe_ids': decodeIds(_favoritesKey),
      'custom_recipes': decodeList(_customRecipesKey),
      'deleted_default_ids': decodeIds(_deletedDefaultIdsKey),
    };
  }

  /// Menerapkan koleksi personal hasil hidrasi cloud ke partisi milik `userId`.
  static Future<void> applyCloudCollections({
    required String userId,
    required List<dynamic> brewHistory,
    required List<dynamic> brewJournal,
    required List<int> favoriteRecipeIds,
    required List<dynamic> customRecipes,
    required List<int> deletedDefaultIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = UserScopedStorage.normalizeUserId(userId);
    final sanitizedHistory = brewHistory
        .whereType<Map>()
        .take(50)
        .map((r) => sanitizeRecipe(r))
        .toList();
    final sanitizedJournal = brewJournal
        .whereType<Map>()
        .take(100)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final sanitizedCustom = <Map<String, dynamic>>[];
    for (int i = 0; i < customRecipes.length && sanitizedCustom.length < 100; i++) {
      final item = customRecipes[i];
      if (item is Map) {
        final s = sanitizeRecipe(item, fallbackId: 500 + i);
        s['isCustom'] = true;
        sanitizedCustom.add(s);
      }
    }
    final favStrings = favoriteRecipeIds.where((e) => e > 0).toSet().map((e) => e.toString()).toList();
    final delStrings = deletedDefaultIds.where((e) => e > 0).toSet().map((e) => e.toString()).toList();

    await Future.wait([
      prefs.setString(UserScopedStorage.scopedKey(_historyKey, userId: uid), json.encode(sanitizedHistory)),
      prefs.setString(UserScopedStorage.scopedKey(_journalKey, userId: uid), json.encode(sanitizedJournal)),
      prefs.setStringList(UserScopedStorage.scopedKey(_favoritesKey, userId: uid), favStrings),
      prefs.setString(UserScopedStorage.scopedKey(_customRecipesKey, userId: uid), json.encode(sanitizedCustom)),
      prefs.setStringList(UserScopedStorage.scopedKey(_deletedDefaultIdsKey, userId: uid), delStrings),
    ]);

    clearMemoryCache();
    _notifyChanged(pushCloud: false);
  }

  // --- RECIPES (100% OFFLINE: DEFAULT DARI SEED_DATA + CUSTOM PER-USER) ---
  static Future<List<dynamic>> getRecipes({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    _ensureCacheMatchesUser(uid);

    if (!forceRefresh && _recipesCache != null) {
      return List<dynamic>.from(_recipesCache!);
    }

    final customKey = UserScopedStorage.scopedKey(_customRecipesKey, userId: uid);
    final deletedKey = UserScopedStorage.scopedKey(_deletedDefaultIdsKey, userId: uid);

    final customJsonStr = prefs.getString(customKey) ?? '[]';
    final deletedIdsRaw = prefs.getStringList(deletedKey) ?? [];
    final deletedDefaultIds = deletedIdsRaw.map((e) => int.tryParse(e) ?? -1).toSet();

    // 1. Muat seluruh resep default langsung dari SeedData (selalu terbarui & 100% offline)
    final defaultSeeds = SeedData.getDefaultRecipes();
    final List<Map<String, dynamic>> allRecipes = [];

    for (final r in defaultSeeds) {
      final id = RecipeSanitizer.toInt(r['id'], 0);
      if (deletedDefaultIds.contains(id)) continue;
      allRecipes.add(sanitizeRecipe(r, fallbackId: id));
    }

    // 2. Gabungkan resep custom buatan pengguna aktif di urutan teratas
    final List<Map<String, dynamic>> customRecipes = [];
    try {
      final rawCustomList = json.decode(customJsonStr) as List<dynamic>;
      for (int i = 0; i < rawCustomList.length; i++) {
        final item = rawCustomList[i];
        if (item is Map) {
          final sanitized = sanitizeRecipe(item, fallbackId: 500 + i);
          sanitized['isCustom'] = true;
          customRecipes.add(sanitized);
        }
      }
    } catch (_) {}

    // Urutkan resep default secara rapi (Neo Brew & 50 resep baru + WBrC historis)
    allRecipes.sort((a, b) {
      final idA = a['id'] as int;
      final idB = b['id'] as int;
      if (idA == 100) return -1;
      if (idB == 100) return 1;
      if (idA > 100 && idB <= 100) return -1;
      if (idB > 100 && idA <= 100) return 1;
      if (idA > 100 && idB > 100) return idA.compareTo(idB);
      int score(int id) {
        final group = (id - 1) ~/ 3;
        final rank = (id - 1) % 3;
        return (1000 - group) * 10 + rank;
      }
      return score(idA).compareTo(score(idB));
    });

    final merged = <Map<String, dynamic>>[...customRecipes, ...allRecipes];
    _recipesCache = merged;
    return List<dynamic>.from(merged);
  }

  static Future<Map<String, dynamic>> createRecipe(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    final customKey = UserScopedStorage.scopedKey(_customRecipesKey, userId: uid);
    final currentRecipes = await getRecipes();

    var newId = 501;
    for (final r in currentRecipes) {
      final rId = RecipeSanitizer.toInt(r['id'], 0);
      if (rId >= newId) newId = rId + 1;
    }

    data['id'] = newId;
    data['isCustom'] = true;
    data['createdAt'] = DateTime.now().toIso8601String();

    final sanitized = sanitizeRecipe(data, fallbackId: newId);
    sanitized['isCustom'] = true;

    final customJsonStr = prefs.getString(customKey);
    List<dynamic> customList = [];
    if (customJsonStr != null) {
      try {
        customList = json.decode(customJsonStr) as List<dynamic>;
      } catch (_) {}
    }
    customList.insert(0, sanitized);
    await prefs.setString(customKey, json.encode(customList));

    _recipesCache = null;
    await getRecipes(forceRefresh: true);
    _notifyChanged();
    return sanitized;
  }

  static Future<void> deleteRecipe(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    final customKey = UserScopedStorage.scopedKey(_customRecipesKey, userId: uid);
    final deletedKey = UserScopedStorage.scopedKey(_deletedDefaultIdsKey, userId: uid);

    final customJsonStr = prefs.getString(customKey);
    if (customJsonStr != null) {
      try {
        final customList = json.decode(customJsonStr) as List<dynamic>;
        final beforeLen = customList.length;
        customList.removeWhere((r) => r is Map && RecipeSanitizer.toInt(r['id'], -1) == id);
        if (customList.length != beforeLen) {
          await prefs.setString(customKey, json.encode(customList));
        }
      } catch (_) {}
    }

    final deletedIds = (prefs.getStringList(deletedKey) ?? []).toSet();
    deletedIds.add(id.toString());
    await prefs.setStringList(deletedKey, deletedIds.toList());

    _recipesCache = null;
    await removeFavorite(id);
    await getRecipes(forceRefresh: true);
    _notifyChanged();
  }

  static Future<List<dynamic>> getRecipesByAuthor(String rawAuthor) async {
    final name = BaristaUtils.cleanName(rawAuthor).toLowerCase();
    final recipes = await getRecipes();
    return recipes.where((r) {
      final a = BaristaUtils.cleanName(r['author']?.toString() ?? '').toLowerCase();
      return a == name;
    }).toList();
  }

  // --- BASECAMPS ---
  static Future<List<dynamic>> getBasecamps() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(_basecampsKey, prefs: prefs);
    final jsonStr = prefs.getString(key);

    if (jsonStr == null) {
      return [];
    }

    try {
      final list = json.decode(jsonStr) as List<dynamic>;
      final cleaned = list
          .where((b) =>
              b['name'] != 'WBrC Champions Club' &&
              b['name'] != 'Hybrid Dripper Enthusiast')
          .toList();
      return cleaned;
    } catch (_) {
      return [];
    }
  }

  static Future<void> createBasecamp(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(_basecampsKey, prefs: prefs);
    final currentBasecamps = await getBasecamps();

    var newId = 1;
    for (final r in currentBasecamps) {
      if (r['id'] != null && r['id'] >= newId) newId = (r['id'] as int) + 1;
    }
    data['id'] = newId;

    currentBasecamps.insert(0, data);
    await prefs.setString(key, json.encode(currentBasecamps));
    _notifyChanged(pushCloud: false);
  }

  static Future<void> deleteBasecamp(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(_basecampsKey, prefs: prefs);
    final currentBasecamps = await getBasecamps();
    currentBasecamps.removeWhere((r) => r['id'] == id);
    await prefs.setString(key, json.encode(currentBasecamps));
    _notifyChanged(pushCloud: false);
  }

  // --- HISTORY ---
  static Future<void> recordBrew(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    _ensureCacheMatchesUser(uid);
    final historyKey = UserScopedStorage.scopedKey(_historyKey, userId: uid);

    final jsonStr = prefs.getString(historyKey);
    var history = jsonStr != null ? json.decode(jsonStr) as List<dynamic> : <dynamic>[];

    final record = sanitizeRecipe(recipe);
    record['brewedAt'] = DateTime.now().toIso8601String();

    history.insert(0, record);
    if (history.length > 50) history = history.sublist(0, 50);

    _historyCache = history;
    await prefs.setString(historyKey, json.encode(history));
    _notifyChanged();
  }

  static Future<List<dynamic>> getBrewHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    _ensureCacheMatchesUser(uid);

    if (_historyCache != null) return List<dynamic>.from(_historyCache!);
    final historyKey = UserScopedStorage.scopedKey(_historyKey, userId: uid);
    final jsonStr = prefs.getString(historyKey);
    if (jsonStr == null) return [];
    final rawHistory = json.decode(jsonStr) as List<dynamic>;
    final history = rawHistory
        .whereType<Map>()
        .map((r) => sanitizeRecipe(r))
        .toList();
    _historyCache = history;
    return List<dynamic>.from(history);
  }

  static Future<List<dynamic>> getFrequentBrews() async {
    final history = await getBrewHistory();
    if (history.isEmpty) return [];

    final counts = <int, int>{};
    final recipes = <int, dynamic>{};

    for (final record in history) {
      final id = record['id'] as int?;
      if (id == null) continue;
      counts[id] = (counts[id] ?? 0) + 1;
      recipes[id] = record;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => recipes[e.key]).toList();
  }

  // --- FAVORITES ---
  static Future<Set<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    _ensureCacheMatchesUser(uid);

    if (_favoritesCache != null) return Set<int>.from(_favoritesCache!);
    final favKey = UserScopedStorage.scopedKey(_favoritesKey, userId: uid);
    final raw = prefs.getStringList(favKey) ?? [];
    _favoritesCache = raw.map((e) => int.tryParse(e) ?? -1).where((e) => e > 0).toSet();
    return Set<int>.from(_favoritesCache!);
  }

  static Future<bool> isFavorite(int id) async {
    final ids = await getFavoriteIds();
    return ids.contains(id);
  }

  static Future<void> toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    _ensureCacheMatchesUser(uid);
    final favKey = UserScopedStorage.scopedKey(_favoritesKey, userId: uid);

    final ids = await getFavoriteIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    _favoritesCache = ids;
    await prefs.setStringList(favKey, ids.map((e) => e.toString()).toList());
    _notifyChanged();
  }

  static Future<void> removeFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    _ensureCacheMatchesUser(uid);
    final favKey = UserScopedStorage.scopedKey(_favoritesKey, userId: uid);

    final ids = await getFavoriteIds();
    ids.remove(id);
    _favoritesCache = ids;
    await prefs.setStringList(favKey, ids.map((e) => e.toString()).toList());
    _notifyChanged();
  }

  static Future<List<dynamic>> getFavoriteRecipes() async {
    final ids = await getFavoriteIds();
    if (ids.isEmpty) return [];
    final recipes = await getRecipes();
    return recipes.where((r) => ids.contains(r['id'])).toList();
  }

  // --- BREW JOURNAL ---
  static Future<List<dynamic>> getJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(_journalKey, prefs: prefs);
    final jsonStr = prefs.getString(key);
    if (jsonStr == null) return [];
    return json.decode(jsonStr) as List<dynamic>;
  }

  static Future<void> addJournalEntry(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(_journalKey, prefs: prefs);
    final entries = await getJournalEntries();
    entry['id'] ??= DateTime.now().millisecondsSinceEpoch;
    entry['createdAt'] ??= DateTime.now().toIso8601String();
    entries.insert(0, entry);
    if (entries.length > 100) {
      entries.removeRange(100, entries.length);
    }
    await prefs.setString(key, json.encode(entries));
    _notifyChanged();
  }

  static Future<void> updateJournalEntry(Map<String, dynamic> updatedEntry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(_journalKey, prefs: prefs);
    final entries = await getJournalEntries();
    final targetId = updatedEntry['id'];
    updatedEntry['updatedAt'] = DateTime.now().toIso8601String();
    final idx = entries.indexWhere((e) => e is Map && e['id'] == targetId);
    if (idx >= 0) {
      entries[idx] = updatedEntry;
    } else {
      entries.insert(0, updatedEntry);
    }
    await prefs.setString(key, json.encode(entries));
    _notifyChanged();
  }

  static Future<void> deleteJournalEntry(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await UserScopedStorage.scopedKeyAsync(_journalKey, prefs: prefs);
    final entries = await getJournalEntries();
    entries.removeWhere((e) => e['id'] == id);
    await prefs.setString(key, json.encode(entries));
    _notifyChanged();
  }

  /// Daftar barista unik dari resep (untuk toolkit / spotlight) — dihitung dengan algoritma O(N) & di-cache.
  static Future<List<Map<String, dynamic>>> getUniqueBaristas() async {
    final uid = await UserScopedStorage.resolveActiveUserId();
    _ensureCacheMatchesUser(uid);

    if (_uniqueBaristasCache != null) {
      return List<Map<String, dynamic>>.from(_uniqueBaristasCache!);
    }

    final recipes = await getRecipes();
    final countsByCleanName = <String, int>{};
    for (final r in recipes) {
      final author = r['author']?.toString() ?? '';
      final name = BaristaUtils.cleanName(author).toLowerCase();
      if (name.isEmpty) continue;
      countsByCleanName[name] = (countsByCleanName[name] ?? 0) + 1;
    }

    final seen = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final r in recipes) {
      final author = r['author']?.toString() ?? '';
      final clean = BaristaUtils.cleanName(author);
      final name = clean.toLowerCase();
      if (name.isEmpty || seen.contains(name)) continue;
      seen.add(name);
      result.add({
        'author': author,
        'name': clean,
        'imageUrl': r['authorAvatarUrl'] ?? r['authorImageUrl'],
        'coverImageUrl': r['coverImageUrl'] ?? r['authorImageUrl'],
        'country': BaristaUtils.countryLabel(author),
        'countryCode': BaristaUtils.countryCode(author),
        'recipeCount': countsByCleanName[name] ?? 1,
      });
    }
    result.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    _uniqueBaristasCache = result;
    return List<Map<String, dynamic>>.from(result);
  }
}
