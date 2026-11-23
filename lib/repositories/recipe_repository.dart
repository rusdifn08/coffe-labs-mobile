import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/rust_api_client.dart';
import '../core/storage/user_scoped_storage.dart';
import '../services/api_service.dart';
import '../services/recipe_sanitizer.dart';
import '../services/seed_data.dart';

part 'recipe_repository.g.dart';

/// Kontrak Repositori Resep Kopi (Offline-first terisolasi per-user dengan sinkronisasi Rust API).
abstract class RecipeRepository {
  Future<List<Map<String, dynamic>>> getRecipes({bool forceRefresh = false});
  Future<Map<String, dynamic>?> getRecipeById(int id);
  Future<void> saveCustomRecipe(Map<String, dynamic> recipe);
  Future<void> deleteRecipe(int id);
  Future<bool> toggleFavorite(int id);
  Future<Set<int>> getFavorites();
  Future<void> syncWithRustBackend();
}

/// Implementasi RecipeRepository yang mengombinasikan seed resep lokal, partisi SharedPreferences
/// milik masing-masing akun, dan sinkronisasi cloud ke Rust Axum backend.
class RecipeRepositoryImpl implements RecipeRepository {
  static const String _customRecipesKey = 'coffeehub_custom_recipes_v2';
  static const String _deletedDefaultIdsKey = 'coffeehub_deleted_default_ids_v1';
  static const String _favoritesKey = 'coffeehub_favorites_v1';

  final RustApiClient _apiClient;
  String? _cachedUserId;
  int _cachedApiVersion = -1;
  List<Map<String, dynamic>>? _cachedRecipes;
  Set<int>? _cachedFavorites;

  RecipeRepositoryImpl({required RustApiClient apiClient}) : _apiClient = apiClient;

  void _ensureFreshCache(String uid) {
    final ver = ApiService.changeNotifier.value;
    if (_cachedUserId != uid || _cachedApiVersion != ver) {
      _cachedRecipes = null;
      _cachedFavorites = null;
      _cachedUserId = uid;
      _cachedApiVersion = ver;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecipes({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    _ensureFreshCache(uid);

    if (!forceRefresh && _cachedRecipes != null) {
      return _cachedRecipes!;
    }

    final customJsonStr =
        prefs.getString(UserScopedStorage.scopedKey(_customRecipesKey, userId: uid)) ?? '[]';
    final deletedIdsRaw =
        prefs.getStringList(UserScopedStorage.scopedKey(_deletedDefaultIdsKey, userId: uid)) ?? [];
    final deletedDefaultIds = deletedIdsRaw.map((e) => int.tryParse(e) ?? -1).toSet();

    // 1. Muat resep default dari SeedData
    final defaultSeeds = SeedData.getDefaultRecipes();
    final List<Map<String, dynamic>> recipes = [];

    for (final r in defaultSeeds) {
      final id = RecipeSanitizer.toInt(r['id'], 0);
      if (deletedDefaultIds.contains(id)) continue;
      recipes.add(RecipeSanitizer.sanitizeRecipe(r, fallbackId: id));
    }

    // 2. Gabungkan resep custom buatan pengguna aktif
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
    return _cachedRecipes!;
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
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    final customKey = UserScopedStorage.scopedKey(_customRecipesKey, userId: uid);
    final customJsonStr = prefs.getString(customKey) ?? '[]';
    List<dynamic> customList = [];
    try {
      customList = json.decode(customJsonStr) as List<dynamic>;
    } catch (_) {
      customList = [];
    }

    final int recipeId = RecipeSanitizer.toInt(recipe['id'], 0);
    final sanitized = RecipeSanitizer.sanitizeRecipe(
      recipe,
      fallbackId: recipeId > 0 ? recipeId : DateTime.now().millisecondsSinceEpoch,
    );
    sanitized['isCustom'] = true;

    final existingIndex = customList.indexWhere((item) => item is Map && item['id'] == sanitized['id']);
    if (existingIndex >= 0) {
      customList[existingIndex] = sanitized;
    } else {
      customList.insert(0, sanitized);
    }

    await prefs.setString(customKey, json.encode(customList));
    _cachedRecipes = null;
    ApiService.clearMemoryCache();
    ApiService.changeNotifier.value++;
    _cachedApiVersion = ApiService.changeNotifier.value;
    UserScopedStorage.notifyDataMutated();

    try {
      await _apiClient.post('/api/recipes', body: sanitized);
    } catch (_) {}
  }

  @override
  Future<void> deleteRecipe(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    final customKey = UserScopedStorage.scopedKey(_customRecipesKey, userId: uid);
    final deletedKey = UserScopedStorage.scopedKey(_deletedDefaultIdsKey, userId: uid);

    final customJsonStr = prefs.getString(customKey) ?? '[]';
    try {
      final customList = json.decode(customJsonStr) as List<dynamic>;
      final initialLen = customList.length;
      customList.removeWhere((item) => item is Map && item['id'] == id);
      if (customList.length < initialLen) {
        await prefs.setString(customKey, json.encode(customList));
        _cachedRecipes = null;
        ApiService.clearMemoryCache();
        ApiService.changeNotifier.value++;
        _cachedApiVersion = ApiService.changeNotifier.value;
        UserScopedStorage.notifyDataMutated();
        try {
          await _apiClient.delete('/api/recipes/$id');
        } catch (_) {}
        return;
      }
    } catch (_) {}

    final deletedList = prefs.getStringList(deletedKey) ?? [];
    if (!deletedList.contains(id.toString())) {
      deletedList.add(id.toString());
      await prefs.setStringList(deletedKey, deletedList);
      _cachedRecipes = null;
      ApiService.clearMemoryCache();
      ApiService.changeNotifier.value++;
      _cachedApiVersion = ApiService.changeNotifier.value;
      UserScopedStorage.notifyDataMutated();
    }
  }

  @override
  Future<bool> toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    final favKey = UserScopedStorage.scopedKey(_favoritesKey, userId: uid);
    final favList = prefs.getStringList(favKey) ?? [];
    final idStr = id.toString();
    bool isNowFav = false;

    if (favList.contains(idStr)) {
      favList.remove(idStr);
      isNowFav = false;
    } else {
      favList.add(idStr);
      isNowFav = true;
    }

    await prefs.setStringList(favKey, favList);
    _cachedFavorites = favList.map((e) => int.tryParse(e) ?? -1).where((e) => e > 0).toSet();
    ApiService.clearFavoritesCache();
    ApiService.changeNotifier.value++;
    _cachedApiVersion = ApiService.changeNotifier.value;
    UserScopedStorage.notifyDataMutated();
    return isNowFav;
  }

  @override
  Future<Set<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = await UserScopedStorage.resolveActiveUserId(prefs: prefs);
    _ensureFreshCache(uid);
    if (_cachedFavorites != null) return Set<int>.from(_cachedFavorites!);
    final favList =
        prefs.getStringList(UserScopedStorage.scopedKey(_favoritesKey, userId: uid)) ?? [];
    _cachedFavorites = favList.map((e) => int.tryParse(e) ?? -1).where((e) => e > 0).toSet();
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
