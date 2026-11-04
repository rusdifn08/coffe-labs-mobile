// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bean_inventory_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Filter Notifier untuk katalog biji roastery.

@ProviderFor(BeanFilterController)
final beanFilterControllerProvider = BeanFilterControllerProvider._();

/// Filter Notifier untuk katalog biji roastery.
final class BeanFilterControllerProvider
    extends $NotifierProvider<BeanFilterController, BeanFilterState> {
  /// Filter Notifier untuk katalog biji roastery.
  BeanFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'beanFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$beanFilterControllerHash();

  @$internal
  @override
  BeanFilterController create() => BeanFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BeanFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BeanFilterState>(value),
    );
  }
}

String _$beanFilterControllerHash() =>
    r'd1613e1c81ae818115607b1d4d037537d400c54f';

/// Filter Notifier untuk katalog biji roastery.

abstract class _$BeanFilterController extends $Notifier<BeanFilterState> {
  BeanFilterState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BeanFilterState, BeanFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BeanFilterState, BeanFilterState>,
              BeanFilterState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// AsyncNotifier untuk katalog biji kopi roastery terkurasi.

@ProviderFor(BeanInventoryController)
final beanInventoryControllerProvider = BeanInventoryControllerProvider._();

/// AsyncNotifier untuk katalog biji kopi roastery terkurasi.
final class BeanInventoryControllerProvider
    extends
        $AsyncNotifierProvider<
          BeanInventoryController,
          List<CuratedRoasteryBean>
        > {
  /// AsyncNotifier untuk katalog biji kopi roastery terkurasi.
  BeanInventoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'beanInventoryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$beanInventoryControllerHash();

  @$internal
  @override
  BeanInventoryController create() => BeanInventoryController();
}

String _$beanInventoryControllerHash() =>
    r'1788296e19183a6d41da2299d39734b570675d4b';

/// AsyncNotifier untuk katalog biji kopi roastery terkurasi.

abstract class _$BeanInventoryController
    extends $AsyncNotifier<List<CuratedRoasteryBean>> {
  FutureOr<List<CuratedRoasteryBean>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<CuratedRoasteryBean>>,
              List<CuratedRoasteryBean>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CuratedRoasteryBean>>,
                List<CuratedRoasteryBean>
              >,
              AsyncValue<List<CuratedRoasteryBean>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Computed selector untuk daftar biji terfilter secara instan dan reaktif.

@ProviderFor(filteredBeans)
final filteredBeansProvider = FilteredBeansProvider._();

/// Computed selector untuk daftar biji terfilter secara instan dan reaktif.

final class FilteredBeansProvider
    extends
        $FunctionalProvider<
          List<CuratedRoasteryBean>,
          List<CuratedRoasteryBean>,
          List<CuratedRoasteryBean>
        >
    with $Provider<List<CuratedRoasteryBean>> {
  /// Computed selector untuk daftar biji terfilter secara instan dan reaktif.
  FilteredBeansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredBeansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredBeansHash();

  @$internal
  @override
  $ProviderElement<List<CuratedRoasteryBean>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<CuratedRoasteryBean> create(Ref ref) {
    return filteredBeans(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CuratedRoasteryBean> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CuratedRoasteryBean>>(value),
    );
  }
}

String _$filteredBeansHash() => r'86eaba600f2042041db0a75dab2304c6edd14f8e';
