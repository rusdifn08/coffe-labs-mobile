// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brew_journal_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier untuk mengelola catatan jurnal seduh, evaluasi rasa (tasting notes), dan rating.

@ProviderFor(BrewJournalController)
final brewJournalControllerProvider = BrewJournalControllerProvider._();

/// AsyncNotifier untuk mengelola catatan jurnal seduh, evaluasi rasa (tasting notes), dan rating.
final class BrewJournalControllerProvider
    extends
        $AsyncNotifierProvider<
          BrewJournalController,
          List<Map<String, dynamic>>
        > {
  /// AsyncNotifier untuk mengelola catatan jurnal seduh, evaluasi rasa (tasting notes), dan rating.
  BrewJournalControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brewJournalControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brewJournalControllerHash();

  @$internal
  @override
  BrewJournalController create() => BrewJournalController();
}

String _$brewJournalControllerHash() =>
    r'1cdd7fe756c4b7b93f29cb99a6015827c62c85a9';

/// AsyncNotifier untuk mengelola catatan jurnal seduh, evaluasi rasa (tasting notes), dan rating.

abstract class _$BrewJournalController
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
