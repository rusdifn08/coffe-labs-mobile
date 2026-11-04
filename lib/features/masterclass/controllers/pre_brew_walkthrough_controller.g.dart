// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_brew_walkthrough_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Orchestrator controller synchronizing Rive Animation SMIInputs with Barista TTS narration.

@ProviderFor(PreBrewWalkthroughController)
final preBrewWalkthroughControllerProvider =
    PreBrewWalkthroughControllerFamily._();

/// Orchestrator controller synchronizing Rive Animation SMIInputs with Barista TTS narration.
final class PreBrewWalkthroughControllerProvider
    extends
        $NotifierProvider<
          PreBrewWalkthroughController,
          PreBrewWalkthroughState
        > {
  /// Orchestrator controller synchronizing Rive Animation SMIInputs with Barista TTS narration.
  PreBrewWalkthroughControllerProvider._({
    required PreBrewWalkthroughControllerFamily super.from,
    required Map<String, dynamic> super.argument,
  }) : super(
         retry: null,
         name: r'preBrewWalkthroughControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$preBrewWalkthroughControllerHash();

  @override
  String toString() {
    return r'preBrewWalkthroughControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PreBrewWalkthroughController create() => PreBrewWalkthroughController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreBrewWalkthroughState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreBrewWalkthroughState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PreBrewWalkthroughControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$preBrewWalkthroughControllerHash() =>
    r'3f83df88432cb997c56e9495a0ecdd9755133df3';

/// Orchestrator controller synchronizing Rive Animation SMIInputs with Barista TTS narration.

final class PreBrewWalkthroughControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PreBrewWalkthroughController,
          PreBrewWalkthroughState,
          PreBrewWalkthroughState,
          PreBrewWalkthroughState,
          Map<String, dynamic>
        > {
  PreBrewWalkthroughControllerFamily._()
    : super(
        retry: null,
        name: r'preBrewWalkthroughControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Orchestrator controller synchronizing Rive Animation SMIInputs with Barista TTS narration.

  PreBrewWalkthroughControllerProvider call(Map<String, dynamic> recipe) =>
      PreBrewWalkthroughControllerProvider._(argument: recipe, from: this);

  @override
  String toString() => r'preBrewWalkthroughControllerProvider';
}

/// Orchestrator controller synchronizing Rive Animation SMIInputs with Barista TTS narration.

abstract class _$PreBrewWalkthroughController
    extends $Notifier<PreBrewWalkthroughState> {
  late final _$args = ref.$arg as Map<String, dynamic>;
  Map<String, dynamic> get recipe => _$args;

  PreBrewWalkthroughState build(Map<String, dynamic> recipe);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<PreBrewWalkthroughState, PreBrewWalkthroughState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PreBrewWalkthroughState, PreBrewWalkthroughState>,
              PreBrewWalkthroughState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
