// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier keluarga (Family Notifier) untuk mengelola satu sesi resep detail secara reaktif.

@ProviderFor(RecipeDetailController)
final recipeDetailControllerProvider = RecipeDetailControllerFamily._();

/// Notifier keluarga (Family Notifier) untuk mengelola satu sesi resep detail secara reaktif.
final class RecipeDetailControllerProvider
    extends $NotifierProvider<RecipeDetailController, RecipeDetailState> {
  /// Notifier keluarga (Family Notifier) untuk mengelola satu sesi resep detail secara reaktif.
  RecipeDetailControllerProvider._({
    required RecipeDetailControllerFamily super.from,
    required Map<String, dynamic> super.argument,
  }) : super(
         retry: null,
         name: r'recipeDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recipeDetailControllerHash();

  @override
  String toString() {
    return r'recipeDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecipeDetailController create() => RecipeDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecipeDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipeDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeDetailControllerHash() =>
    r'43b1480eb2f99c63f5fb6837d7704b77d37e1087';

/// Notifier keluarga (Family Notifier) untuk mengelola satu sesi resep detail secara reaktif.

final class RecipeDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RecipeDetailController,
          RecipeDetailState,
          RecipeDetailState,
          RecipeDetailState,
          Map<String, dynamic>
        > {
  RecipeDetailControllerFamily._()
    : super(
        retry: null,
        name: r'recipeDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier keluarga (Family Notifier) untuk mengelola satu sesi resep detail secara reaktif.

  RecipeDetailControllerProvider call(Map<String, dynamic> initialRecipe) =>
      RecipeDetailControllerProvider._(argument: initialRecipe, from: this);

  @override
  String toString() => r'recipeDetailControllerProvider';
}

/// Notifier keluarga (Family Notifier) untuk mengelola satu sesi resep detail secara reaktif.

abstract class _$RecipeDetailController extends $Notifier<RecipeDetailState> {
  late final _$args = ref.$arg as Map<String, dynamic>;
  Map<String, dynamic> get initialRecipe => _$args;

  RecipeDetailState build(Map<String, dynamic> initialRecipe);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RecipeDetailState, RecipeDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RecipeDetailState, RecipeDetailState>,
              RecipeDetailState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
