// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_scale_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider Dependency Injection untuk [SmartScaleRepository].

@ProviderFor(smartScaleRepository)
final smartScaleRepositoryProvider = SmartScaleRepositoryProvider._();

/// Provider Dependency Injection untuk [SmartScaleRepository].

final class SmartScaleRepositoryProvider
    extends
        $FunctionalProvider<
          SmartScaleRepository,
          SmartScaleRepository,
          SmartScaleRepository
        >
    with $Provider<SmartScaleRepository> {
  /// Provider Dependency Injection untuk [SmartScaleRepository].
  SmartScaleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smartScaleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smartScaleRepositoryHash();

  @$internal
  @override
  $ProviderElement<SmartScaleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SmartScaleRepository create(Ref ref) {
    return smartScaleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmartScaleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmartScaleRepository>(value),
    );
  }
}

String _$smartScaleRepositoryHash() =>
    r'366229e198ac026fb60fe752682a6d1e733abd77';
