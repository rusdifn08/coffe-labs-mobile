import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'seed_data.dart';
import '../utils/barista_utils.dart';

class ApiService {
  static const String _recipesKey = 'coffeehub_recipes_v11';
  static const String _basecampsKey = 'coffeehub_basecamps_v11';
  static const String _historyKey = 'coffeehub_history_v3';
  static const String _favoritesKey = 'coffeehub_favorites_v1';
  static const String _journalKey = 'coffeehub_brew_journal_v1';

  static List<dynamic>? _recipesCache;
  static List<dynamic>? _historyCache;
  static Set<int>? _favoritesCache;

  static void clearMemoryCache() {
    _recipesCache = null;
    _historyCache = null;
    _favoritesCache = null;
  }

  // --- RECIPES ---
  static Future<List<dynamic>> getRecipes({bool forceRefresh = false}) async {
    if (!forceRefresh && _recipesCache != null) {
      return List<dynamic>.from(_recipesCache!);
    }

    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(_recipesKey);

    // Migrasi dari key lama sekali
    jsonStr ??= prefs.getString('coffeehub_recipes_v10');
    jsonStr ??= prefs.getString('coffeehub_recipes_v9');

    List<dynamic> recipes;
    if (jsonStr == null) {
      final seed = SeedData.getDefaultRecipes();
      await prefs.setString(_recipesKey, json.encode(seed));
      recipes = seed;
    } else {
      recipes = json.decode(jsonStr) as List<dynamic>;
      // Pastikan Neo Brew ada + sync foto author dari seed terbaru
      final seed = SeedData.getDefaultRecipes();
      final seedById = {for (final r in seed) r['id']: r};
      bool mutated = false;

      if (!recipes.any((r) => r['id'] == 100) && seedById.containsKey(100)) {
        recipes.add(seedById[100]);
        mutated = true;
      }

      for (var i = 0; i < recipes.length; i++) {
        final id = recipes[i]['id'];
        final seeded = seedById[id];
        if (seeded == null) continue;
        final oldCover = recipes[i]['coverImageUrl']?.toString() ??
            recipes[i]['authorImageUrl']?.toString() ?? '';
        final newCover = seeded['coverImageUrl']?.toString() ??
            seeded['authorImageUrl']?.toString() ?? '';
        if (newCover.isNotEmpty && oldCover != newCover) {
          recipes[i]['coverImageUrl'] = newCover;
          recipes[i]['authorImageUrl'] = newCover;
          mutated = true;
        }
        final oldAvatar = recipes[i]['authorAvatarUrl']?.toString() ?? '';
        final newAvatar = seeded['authorAvatarUrl']?.toString() ?? '';
        if (newAvatar.isNotEmpty && oldAvatar != newAvatar) {
          recipes[i]['authorAvatarUrl'] = newAvatar;
          mutated = true;
        }
        if (recipes[i]['author'] != seeded['author']) {
          recipes[i]['author'] = seeded['author'];
          mutated = true;
        }
      }

      if (mutated) {
        await prefs.setString(_recipesKey, json.encode(recipes));
      } else if (prefs.getString(_recipesKey) == null) {
        await prefs.setString(_recipesKey, json.encode(recipes));
      }
    }

    recipes.sort((a, b) {
      final idA = a['id'] as int;
      final idB = b['id'] as int;
      int score(int id) {
        final group = (id - 1) ~/ 3;
        final rank = (id - 1) % 3;
        return (1000 - group) * 10 + rank;
      }
      return score(idA).compareTo(score(idB));
    });

    _recipesCache = recipes;
    return List<dynamic>.from(recipes);
  }

  static Future<void> createRecipe(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentRecipes = await getRecipes();

    var newId = 1;
    for (final r in currentRecipes) {
      if (r['id'] != null && r['id'] >= newId) newId = r['id'] + 1;
    }
    data['id'] = newId;
    data['createdAt'] = DateTime.now().toIso8601String();

    currentRecipes.insert(0, data);
    _recipesCache = currentRecipes;
    await prefs.setString(_recipesKey, json.encode(currentRecipes));
  }

  static Future<void> deleteRecipe(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final currentRecipes = await getRecipes();
    currentRecipes.removeWhere((r) => r['id'] == id);
    _recipesCache = currentRecipes;
    await prefs.setString(_recipesKey, json.encode(currentRecipes));
    await removeFavorite(id);
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
    String? jsonStr = prefs.getString(_basecampsKey) ??
        prefs.getString('coffeehub_basecamps_v10') ??
        prefs.getString('coffeehub_basecamps_v9');

    if (jsonStr == null) {
      final seed = SeedData.getDefaultBasecamps();
      await prefs.setString(_basecampsKey, json.encode(seed));
      return seed;
    }

    return json.decode(jsonStr) as List<dynamic>;
  }

  static Future<void> createBasecamp(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBasecamps = await getBasecamps();

    var newId = 1;
    for (final r in currentBasecamps) {
      if (r['id'] != null && r['id'] >= newId) newId = r['id'] + 1;
    }
    data['id'] = newId;

    currentBasecamps.insert(0, data);
    await prefs.setString(_basecampsKey, json.encode(currentBasecamps));
  }

  static Future<void> deleteBasecamp(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBasecamps = await getBasecamps();
    currentBasecamps.removeWhere((r) => r['id'] == id);
    await prefs.setString(_basecampsKey, json.encode(currentBasecamps));
  }

  // --- HISTORY ---
  static Future<void> recordBrew(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_historyKey);
    var history = jsonStr != null ? json.decode(jsonStr) as List<dynamic> : <dynamic>[];

    final record = Map<String, dynamic>.from(recipe);
    record['brewedAt'] = DateTime.now().toIso8601String();

    history.insert(0, record);
    if (history.length > 50) history = history.sublist(0, 50);

    _historyCache = history;
    await prefs.setString(_historyKey, json.encode(history));
  }

  static Future<List<dynamic>> getBrewHistory() async {
    if (_historyCache != null) return List<dynamic>.from(_historyCache!);
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_historyKey);
    if (jsonStr == null) return [];
    final history = json.decode(jsonStr) as List<dynamic>;
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
    if (_favoritesCache != null) return Set<int>.from(_favoritesCache!);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? [];
    _favoritesCache = raw.map(int.parse).toSet();
    return Set<int>.from(_favoritesCache!);
  }

  static Future<bool> isFavorite(int id) async {
    final ids = await getFavoriteIds();
    return ids.contains(id);
  }

  static Future<void> toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getFavoriteIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    _favoritesCache = ids;
    await prefs.setStringList(_favoritesKey, ids.map((e) => e.toString()).toList());
  }

  static Future<void> removeFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getFavoriteIds();
    ids.remove(id);
    _favoritesCache = ids;
    await prefs.setStringList(_favoritesKey, ids.map((e) => e.toString()).toList());
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
    final jsonStr = prefs.getString(_journalKey);
    if (jsonStr == null) return [];
    return json.decode(jsonStr) as List<dynamic>;
  }

  static Future<void> addJournalEntry(Map<String, dynamic> entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getJournalEntries();
    entry['id'] = DateTime.now().millisecondsSinceEpoch;
    entry['createdAt'] = DateTime.now().toIso8601String();
    entries.insert(0, entry);
    if (entries.length > 100) {
      entries.removeRange(100, entries.length);
    }
    await prefs.setString(_journalKey, json.encode(entries));
  }

  static Future<void> deleteJournalEntry(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getJournalEntries();
    entries.removeWhere((e) => e['id'] == id);
    await prefs.setString(_journalKey, json.encode(entries));
  }

  /// Daftar barista unik dari resep (untuk toolkit / spotlight).
  static Future<List<Map<String, dynamic>>> getUniqueBaristas() async {
    final recipes = await getRecipes();
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final r in recipes) {
      final author = r['author']?.toString() ?? '';
      final name = BaristaUtils.cleanName(author).toLowerCase();
      if (name.isEmpty || seen.contains(name)) continue;
      seen.add(name);
      result.add({
        'author': author,
        'name': BaristaUtils.cleanName(author),
        'imageUrl': r['authorAvatarUrl'] ?? r['authorImageUrl'],
        'coverImageUrl': r['coverImageUrl'] ?? r['authorImageUrl'],
        'country': BaristaUtils.countryLabel(author),
        'countryCode': BaristaUtils.countryCode(author),
        'recipeCount': recipes
            .where((x) =>
                BaristaUtils.cleanName(x['author']?.toString() ?? '').toLowerCase() ==
                name)
            .length,
      });
    }
    result.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    return result;
  }
}
