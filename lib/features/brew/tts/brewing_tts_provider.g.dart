// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brewing_tts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod controller providing access to the hands-free barista voice guidance.

@ProviderFor(BrewingTTSNotifier)
final brewingTTSProvider = BrewingTTSNotifierProvider._();

/// Riverpod controller providing access to the hands-free barista voice guidance.
final class BrewingTTSNotifierProvider
    extends $NotifierProvider<BrewingTTSNotifier, BrewingTTSState> {
  /// Riverpod controller providing access to the hands-free barista voice guidance.
  BrewingTTSNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brewingTTSProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brewingTTSNotifierHash();

  @$internal
  @override
  BrewingTTSNotifier create() => BrewingTTSNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrewingTTSState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrewingTTSState>(value),
    );
  }
}

String _$brewingTTSNotifierHash() =>
    r'c16feb95f7831fd654e97d6f2b0c1a5a40424711';

/// Riverpod controller providing access to the hands-free barista voice guidance.

abstract class _$BrewingTTSNotifier extends $Notifier<BrewingTTSState> {
  BrewingTTSState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BrewingTTSState, BrewingTTSState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BrewingTTSState, BrewingTTSState>,
              BrewingTTSState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
