import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../repositories/recipe_repository.dart';

part 'recipe_list_controller.freezed.dart';
part 'recipe_list_controller.g.dart';

/// State immutable untuk kriteria pencarian dan filter resep menggunakan Freezed.
@freezed
abstract class RecipeFilterState with _$RecipeFilterState {
  const factory RecipeFilterState({
    @Default('') String searchQuery,
    @Default('Semua') String selectedCategory,
    @Default('Semua') String selectedMethod,
    @Default(false) bool favoritesOnly,
  }) = _RecipeFilterState;
}

/// Notifier untuk mengelola state filter dan pencarian resep.
@riverpod
class RecipeFilterController extends _$RecipeFilterController {
  @override
  RecipeFilterState build() => const RecipeFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setMethod(String method) {
    state = state.copyWith(selectedMethod: method);
  }

  void toggleFavoritesOnly() {
    state = state.copyWith(favoritesOnly: !state.favoritesOnly);
  }

  void resetFilters() {
    state = const RecipeFilterState();
  }
}

/// AsyncNotifier untuk mengelola daftar resep kopi (offline seeds + custom lokal + cloud sync).
@riverpod
class RecipeListController extends _$RecipeListController {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.watch(recipeRepositoryProvider);
    return repo.getRecipes();
  }

  /// Memuat ulang daftar resep dengan memaksa bypass memory cache.
  Future<void> refreshRecipes() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(recipeRepositoryProvider);
      return repo.getRecipes(forceRefresh: true);
    });
  }

  /// Menambah atau memperbarui resep custom.
  Future<void> saveRecipe(Map<String, dynamic> recipe) async {
    final repo = ref.read(recipeRepositoryProvider);
    await repo.saveCustomRecipe(recipe);
    ref.invalidateSelf();
  }

  /// Menghapus resep custom atau menyembunyikan resep default.
  Future<void> deleteRecipe(int id) async {
    final repo = ref.read(recipeRepositoryProvider);
    await repo.deleteRecipe(id);
    ref.invalidateSelf();
  }

  /// Menyukai / menghapus favorit resep.
  Future<bool> toggleFavorite(int id) async {
    final repo = ref.read(recipeRepositoryProvider);
    final isFav = await repo.toggleFavorite(id);
    ref.invalidate(favoriteIdsProvider);
    return isFav;
  }
}

/// Provider yang menyediakan set ID resep yang difavoritkan.
@riverpod
Future<Set<int>> favoriteIds(Ref ref) async {
  final repo = ref.watch(recipeRepositoryProvider);
  return repo.getFavorites();
}

/// Provider terhitung (computed selector) yang menghasilkan resep terfilter secara reaktif.
@riverpod
List<Map<String, dynamic>> filteredRecipes(Ref ref) {
  final recipesAsync = ref.watch(recipeListControllerProvider);
  final filter = ref.watch(recipeFilterControllerProvider);
  final favoritesAsync = ref.watch(favoriteIdsProvider);
  final favorites = favoritesAsync.value ?? <int>{};

  return recipesAsync.maybeWhen(
    data: (recipes) {
      return recipes.where((r) {
        // Filter Favorit
        final int id = r['id'] is int ? r['id'] as int : int.tryParse(r['id'].toString()) ?? 0;
        if (filter.favoritesOnly && !favorites.contains(id)) {
          return false;
        }

        // Filter Kategori
        if (filter.selectedCategory != 'Semua' &&
            filter.selectedCategory.isNotEmpty &&
            (r['category']?.toString() ?? '') != filter.selectedCategory) {
          return false;
        }

        // Filter Metode
        if (filter.selectedMethod != 'Semua' &&
            filter.selectedMethod.isNotEmpty &&
            (r['method']?.toString() ?? '') != filter.selectedMethod) {
          return false;
        }

        // Filter Pencarian Teks
        if (filter.searchQuery.trim().isNotEmpty) {
          final q = filter.searchQuery.toLowerCase().trim();
          final title = (r['title']?.toString() ?? '').toLowerCase();
          final author = (r['author']?.toString() ?? '').toLowerCase();
          final beanName = (r['beanName']?.toString() ?? '').toLowerCase();
          final notes = (r['notes']?.toString() ?? '').toLowerCase();
          if (!title.contains(q) && !author.contains(q) && !beanName.contains(q) && !notes.contains(q)) {
            return false;
          }
        }

        return true;
      }).toList();
    },
    orElse: () => [],
  );
}
