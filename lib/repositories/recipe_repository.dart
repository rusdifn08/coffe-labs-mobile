import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/rust_api_client.dart';
import '../services/recipe_sanitizer.dart';
import '../services/seed_data.dart';

part 'recipe_repository.g.dart';

/// Kontrak Repositori Resep Kopi (Offline-first dengan sinkronisasi Rust API).
abstract class RecipeRepository {
  Future<List<Map<String, dynamic>>> getRecipes({bool forceRefresh = false});
  Future<Map<String, dynamic>?> getRecipeById(int id);
  Future<void> saveCustomRecipe(Map<String, dynamic> recipe);
  Future<void> deleteRecipe(int id);
  Future<bool> toggleFavorite(int id);
  Future<Set<int>> getFavorites();
  Future<void> syncWithRustBackend();
}

/// Implementasi RecipeRepository yang mengombinasikan seed resep lokal, cache SharedPreferences,
/// dan cloud backup ke Rust Axum backend.
class RecipeRepositoryImpl implements RecipeRepository {
  static const String _customRecipesKey = 'coffeehub_custom_recipes_v2';
  static const String _deletedDefaultIdsKey = 'coffeehub_deleted_default_ids_v1';
  static const String _favoritesKey = 'coffeehub_favorites_v1';

  final RustApiClient _apiClient;
  List<Map<String, dynamic>>? _cachedRecipes;
  Set<int>? _cachedFavorites;

  RecipeRepositoryImpl({required RustApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<Map<String, dynamic>>> getRecipes({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedRecipes != null) {
      return List<Map<String, dynamic>>.from(_cachedRecipes!);
    }

    final prefs = await SharedPreferences.getInstance();
    final customJsonStr = prefs.getString(_customRecipesKey) ?? '[]';
    final deletedIdsRaw = prefs.getStringList(_deletedDefaultIdsKey) ?? [];
    final deletedDefaultIds = deletedIdsRaw.map((e) => int.tryParse(e) ?? -1).toSet();

    // 1. Muat resep default dari SeedData
    final defaultSeeds = SeedData.getDefaultRecipes();
    final List<Map<String, dynamic>> recipes = [];

    for (final r in defaultSeeds) {
      final id = RecipeSanitizer.toInt(r['id'], 0);
      if (deletedDefaultIds.contains(id)) continue;
      recipes.add(RecipeSanitizer.sanitizeRecipe(r, fallbackId: id));
    }

    // 2. Gabungkan resep custom buatan pengguna
    try {
      final decodedCustom = json.decode(customJsonStr) as List<dynamic>;
      for (int i = 0; i < decodedCustom.length; i++) {
        final item = decodedCustom[i];
        if (item is Map) {
          final sanitized = RecipeSanitizer.sanitizeRecipe(item, fallbackId: 500 + i);
          sanitized['isCustom'] = true;
          recipes.add(sanitized);
        }
      }
    } catch (_) {}

    _cachedRecipes = recipes;
    return List<Map<String, dynamic>>.from(recipes);
  }

  @override
  Future<Map<String, dynamic>?> getRecipeById(int id) async {
    final all = await getRecipes();
    try {
      return all.firstWhere((r) => r['id'] == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCustomRecipe(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final customJsonStr = prefs.getString(_customRecipesKey) ?? '[]';
    List<dynamic> customList = [];
    try {
      customList = json.decode(customJsonStr) as List<dynamic>;
    } catch (_) {
      customList = [];
    }

    final int recipeId = RecipeSanitizer.toInt(recipe['id'], 0);
    final sanitized = RecipeSanitizer.sanitizeRecipe(recipe, fallbackId: recipeId > 0 ? recipeId : DateTime.now().millisecondsSinceEpoch);
    sanitized['isCustom'] = true;

    final existingIndex = customList.indexWhere((item) => item is Map && item['id'] == sanitized['id']);
    if (existingIndex >= 0) {
      customList[existingIndex] = sanitized;
    } else {
      customList.insert(0, sanitized);
    }

    await prefs.setString(_customRecipesKey, json.encode(customList));
    _cachedRecipes = null; // Invalidate cache

    // Asynchronous background sync to Rust backend
    try {
      await _apiClient.post('/api/recipes', body: sanitized);
    } catch (_) {}
  }

  @override
  Future<void> deleteRecipe(int id) async {
    final prefs = await SharedPreferences.getInstance();

    // Cek resep custom
    final customJsonStr = prefs.getString(_customRecipesKey) ?? '[]';
    try {
      final customList = json.decode(customJsonStr) as List<dynamic>;
      final initialLen = customList.length;
      customList.removeWhere((item) => item is Map && item['id'] == id);
      if (customList.length < initialLen) {
        await prefs.setString(_customRecipesKey, json.encode(customList));
        _cachedRecipes = null;
        try {
          await _apiClient.delete('/api/recipes/$id');
        } catch (_) {}
        return;
      }
    } catch (_) {}

    // Resep default: tandai sebagai terhapus
    final deletedList = prefs.getStringList(_deletedDefaultIdsKey) ?? [];
    if (!deletedList.contains(id.toString())) {
      deletedList.add(id.toString());
      await prefs.setStringList(_deletedDefaultIdsKey, deletedList);
      _cachedRecipes = null;
    }
  }

  @override
  Future<bool> toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList(_favoritesKey) ?? [];
    final idStr = id.toString();
    bool isNowFav = false;

    if (favList.contains(idStr)) {
      favList.remove(idStr);
      isNowFav = false;
    } else {
      favList.add(idStr);
      isNowFav = true;
    }

    await prefs.setStringList(_favoritesKey, favList);
    _cachedFavorites = favList.map((e) => int.tryParse(e) ?? -1).toSet();
    return isNowFav;
  }

  @override
  Future<Set<int>> getFavorites() async {
    if (_cachedFavorites != null) return Set<int>.from(_cachedFavorites!);
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList(_favoritesKey) ?? [];
    _cachedFavorites = favList.map((e) => int.tryParse(e) ?? -1).toSet();
    return Set<int>.from(_cachedFavorites!);
  }

  @override
  Future<void> syncWithRustBackend() async {
    try {
      final response = await _apiClient.get('/api/recipes/sync');
      if (response is List) {
        for (final item in response) {
          if (item is Map<String, dynamic>) {
            await saveCustomRecipe(item);
          }
        }
      }
    } catch (_) {}
  }
}

/// Provider Dependency Injection untuk [RecipeRepository].
@riverpod
RecipeRepository recipeRepository(Ref ref) {
  final apiClient = ref.watch(rustApiClientProvider);
  return RecipeRepositoryImpl(apiClient: apiClient);
}
