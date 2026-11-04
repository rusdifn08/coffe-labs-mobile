// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_brew_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier untuk mengontrol sesi seduh dan timer aktif dengan integrasi Barista TTS.

@ProviderFor(ActiveBrewController)
final activeBrewControllerProvider = ActiveBrewControllerFamily._();

/// Notifier untuk mengontrol sesi seduh dan timer aktif dengan integrasi Barista TTS.
final class ActiveBrewControllerProvider
    extends $NotifierProvider<ActiveBrewController, ActiveBrewState> {
  /// Notifier untuk mengontrol sesi seduh dan timer aktif dengan integrasi Barista TTS.
  ActiveBrewControllerProvider._({
    required ActiveBrewControllerFamily super.from,
    required Map<String, dynamic> super.argument,
  }) : super(
         retry: null,
         name: r'activeBrewControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeBrewControllerHash();

  @override
  String toString() {
    return r'activeBrewControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActiveBrewController create() => ActiveBrewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveBrewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveBrewState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveBrewControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeBrewControllerHash() =>
    r'66c5e7d333690d047d94090fe63e9f55e0aacbc5';

/// Notifier untuk mengontrol sesi seduh dan timer aktif dengan integrasi Barista TTS.

final class ActiveBrewControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ActiveBrewController,
          ActiveBrewState,
          ActiveBrewState,
          ActiveBrewState,
          Map<String, dynamic>
        > {
  ActiveBrewControllerFamily._()
    : super(
        retry: null,
        name: r'activeBrewControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier untuk mengontrol sesi seduh dan timer aktif dengan integrasi Barista TTS.

  ActiveBrewControllerProvider call(Map<String, dynamic> recipe) =>
      ActiveBrewControllerProvider._(argument: recipe, from: this);

  @override
  String toString() => r'activeBrewControllerProvider';
}

/// Notifier untuk mengontrol sesi seduh dan timer aktif dengan integrasi Barista TTS.

abstract class _$ActiveBrewController extends $Notifier<ActiveBrewState> {
  late final _$args = ref.$arg as Map<String, dynamic>;
  Map<String, dynamic> get recipe => _$args;

  ActiveBrewState build(Map<String, dynamic> recipe);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ActiveBrewState, ActiveBrewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActiveBrewState, ActiveBrewState>,
              ActiveBrewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
