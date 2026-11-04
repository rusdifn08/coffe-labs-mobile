// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brew_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier untuk mengelola riwayat seduh kopi dan catatan hasil rasa.

@ProviderFor(BrewHistoryController)
final brewHistoryControllerProvider = BrewHistoryControllerProvider._();

/// AsyncNotifier untuk mengelola riwayat seduh kopi dan catatan hasil rasa.
final class BrewHistoryControllerProvider
    extends
        $AsyncNotifierProvider<
          BrewHistoryController,
          List<Map<String, dynamic>>
        > {
  /// AsyncNotifier untuk mengelola riwayat seduh kopi dan catatan hasil rasa.
  BrewHistoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brewHistoryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brewHistoryControllerHash();

  @$internal
  @override
  BrewHistoryController create() => BrewHistoryController();
}

String _$brewHistoryControllerHash() =>
    r'899ab604fd67ff3f011b400c7633b4b3650bb03d';

/// AsyncNotifier untuk mengelola riwayat seduh kopi dan catatan hasil rasa.

abstract class _$BrewHistoryController
    extends $AsyncNotifier<List<Map<String, dynamic>>> {
  FutureOr<List<Map<String, dynamic>>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<Map<String, dynamic>>>,
              List<Map<String, dynamic>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<Map<String, dynamic>>>,
                List<Map<String, dynamic>>
              >,
              AsyncValue<List<Map<String, dynamic>>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
