// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bean_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider Dependency Injection untuk [BeanRepository].

@ProviderFor(beanRepository)
final beanRepositoryProvider = BeanRepositoryProvider._();

/// Provider Dependency Injection untuk [BeanRepository].

final class BeanRepositoryProvider
    extends $FunctionalProvider<BeanRepository, BeanRepository, BeanRepository>
    with $Provider<BeanRepository> {
  /// Provider Dependency Injection untuk [BeanRepository].
  BeanRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'beanRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$beanRepositoryHash();

  @$internal
  @override
  $ProviderElement<BeanRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BeanRepository create(Ref ref) {
    return beanRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BeanRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BeanRepository>(value),
    );
  }
}

String _$beanRepositoryHash() => r'e63585a9298f238ec938beab207916be05f7819f';
