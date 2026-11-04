// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rust_api_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider Dependency Injection untuk [RustApiClient] yang menyuntikkan singleton [dioClientProvider].

@ProviderFor(rustApiClient)
final rustApiClientProvider = RustApiClientProvider._();

/// Provider Dependency Injection untuk [RustApiClient] yang menyuntikkan singleton [dioClientProvider].

final class RustApiClientProvider
    extends $FunctionalProvider<RustApiClient, RustApiClient, RustApiClient>
    with $Provider<RustApiClient> {
  /// Provider Dependency Injection untuk [RustApiClient] yang menyuntikkan singleton [dioClientProvider].
  RustApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rustApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rustApiClientHash();

  @$internal
  @override
  $ProviderElement<RustApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RustApiClient create(Ref ref) {
    return rustApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RustApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RustApiClient>(value),
    );
  }
}

String _$rustApiClientHash() => r'2aefc3e35b3d7421ae2910ea666a83f09b66a9c9';
