// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier untuk mengelola state filter dan pencarian resep.

@ProviderFor(RecipeFilterController)
final recipeFilterControllerProvider = RecipeFilterControllerProvider._();

/// Notifier untuk mengelola state filter dan pencarian resep.
final class RecipeFilterControllerProvider
    extends $NotifierProvider<RecipeFilterController, RecipeFilterState> {
  /// Notifier untuk mengelola state filter dan pencarian resep.
  RecipeFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipeFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipeFilterControllerHash();

  @$internal
  @override
  RecipeFilterController create() => RecipeFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecipeFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipeFilterState>(value),
    );
  }
}

String _$recipeFilterControllerHash() =>
    r'20576763187f5da64b9d59ea47eaea2557854ef0';

/// Notifier untuk mengelola state filter dan pencarian resep.

abstract class _$RecipeFilterController extends $Notifier<RecipeFilterState> {
  RecipeFilterState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RecipeFilterState, RecipeFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RecipeFilterState, RecipeFilterState>,
              RecipeFilterState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// AsyncNotifier untuk mengelola daftar resep kopi (offline seeds + custom lokal + cloud sync).

@ProviderFor(RecipeListController)
final recipeListControllerProvider = RecipeListControllerProvider._();

/// AsyncNotifier untuk mengelola daftar resep kopi (offline seeds + custom lokal + cloud sync).
final class RecipeListControllerProvider
    extends
        $AsyncNotifierProvider<
          RecipeListController,
          List<Map<String, dynamic>>
        > {
  /// AsyncNotifier untuk mengelola daftar resep kopi (offline seeds + custom lokal + cloud sync).
  RecipeListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipeListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipeListControllerHash();

  @$internal
  @override
  RecipeListController create() => RecipeListController();
}

String _$recipeListControllerHash() =>
    r'841e013bc5303938d371eaef0fda1383e1364b28';

/// AsyncNotifier untuk mengelola daftar resep kopi (offline seeds + custom lokal + cloud sync).

abstract class _$RecipeListController
    extends $AsyncNotifier<List<Map<String, dynamic>>> {
  FutureOr<List<Map<String, dynamic>>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<Map<String, dynamic>>>,
              List<Map<String, dynamic>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<Map<String, dynamic>>>,
                List<Map<String, dynamic>>
              >,
              AsyncValue<List<Map<String, dynamic>>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Provider yang menyediakan set ID resep yang difavoritkan.

@ProviderFor(favoriteIds)
final favoriteIdsProvider = FavoriteIdsProvider._();

/// Provider yang menyediakan set ID resep yang difavoritkan.

final class FavoriteIdsProvider
    extends
        $FunctionalProvider<AsyncValue<Set<int>>, Set<int>, FutureOr<Set<int>>>
    with $FutureModifier<Set<int>>, $FutureProvider<Set<int>> {
  /// Provider yang menyediakan set ID resep yang difavoritkan.
  FavoriteIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<int>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Set<int>> create(Ref ref) {
    return favoriteIds(ref);
  }
}

String _$favoriteIdsHash() => r'ccd05230fdedac1088f6d30516ac29f0e9b0f7ec';

/// Provider terhitung (computed selector) yang menghasilkan resep terfilter secara reaktif.

@ProviderFor(filteredRecipes)
final filteredRecipesProvider = FilteredRecipesProvider._();

/// Provider terhitung (computed selector) yang menghasilkan resep terfilter secara reaktif.

final class FilteredRecipesProvider
    extends
        $FunctionalProvider<
          List<Map<String, dynamic>>,
          List<Map<String, dynamic>>,
          List<Map<String, dynamic>>
        >
    with $Provider<List<Map<String, dynamic>>> {
  /// Provider terhitung (computed selector) yang menghasilkan resep terfilter secara reaktif.
  FilteredRecipesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredRecipesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredRecipesHash();

  @$internal
  @override
  $ProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Map<String, dynamic>> create(Ref ref) {
    return filteredRecipes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Map<String, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Map<String, dynamic>>>(value),
    );
  }
}

String _$filteredRecipesHash() => r'4d20aea8fb46ebe10d512ee9a59c49949ee6153e';
