// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brew_log_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider Dependency Injection untuk [BrewLogRepository].

@ProviderFor(brewLogRepository)
final brewLogRepositoryProvider = BrewLogRepositoryProvider._();

/// Provider Dependency Injection untuk [BrewLogRepository].

final class BrewLogRepositoryProvider
    extends
        $FunctionalProvider<
          BrewLogRepository,
          BrewLogRepository,
          BrewLogRepository
        >
    with $Provider<BrewLogRepository> {
  /// Provider Dependency Injection untuk [BrewLogRepository].
  BrewLogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brewLogRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brewLogRepositoryHash();

  @$internal
  @override
  $ProviderElement<BrewLogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BrewLogRepository create(Ref ref) {
    return brewLogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrewLogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrewLogRepository>(value),
    );
  }
}

String _$brewLogRepositoryHash() => r'e8d5bd045b91f60226e2cf7eb45c569eaa8ca6be';
