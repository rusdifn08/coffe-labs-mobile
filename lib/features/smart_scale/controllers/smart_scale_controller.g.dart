// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_scale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier untuk mengontrol koneksi timbangan Bluetooth dan pembacaan massa real-time.

@ProviderFor(SmartScaleController)
final smartScaleControllerProvider = SmartScaleControllerProvider._();

/// Notifier untuk mengontrol koneksi timbangan Bluetooth dan pembacaan massa real-time.
final class SmartScaleControllerProvider
    extends $NotifierProvider<SmartScaleController, SmartScaleState> {
  /// Notifier untuk mengontrol koneksi timbangan Bluetooth dan pembacaan massa real-time.
  SmartScaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smartScaleControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smartScaleControllerHash();

  @$internal
  @override
  SmartScaleController create() => SmartScaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmartScaleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmartScaleState>(value),
    );
  }
}

String _$smartScaleControllerHash() =>
    r'4e4725e3fd2651c5b278580bdf2df39d19c59540';

/// Notifier untuk mengontrol koneksi timbangan Bluetooth dan pembacaan massa real-time.

abstract class _$SmartScaleController extends $Notifier<SmartScaleState> {
  SmartScaleState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SmartScaleState, SmartScaleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SmartScaleState, SmartScaleState>,
              SmartScaleState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
