// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_feed_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exploreFeedApi)
final exploreFeedApiProvider = ExploreFeedApiProvider._();

final class ExploreFeedApiProvider
    extends
        $FunctionalProvider<
          ExploreFeedApiService,
          ExploreFeedApiService,
          ExploreFeedApiService
        >
    with $Provider<ExploreFeedApiService> {
  ExploreFeedApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreFeedApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreFeedApiHash();

  @$internal
  @override
  $ProviderElement<ExploreFeedApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExploreFeedApiService create(Ref ref) {
    return exploreFeedApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreFeedApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreFeedApiService>(value),
    );
  }
}

String _$exploreFeedApiHash() => r'7b0dcc6c05b8b822fbbdee5d84ed5c04f22aa084';

@ProviderFor(ForYouFeedController)
final forYouFeedControllerProvider = ForYouFeedControllerFamily._();

final class ForYouFeedControllerProvider
    extends $AsyncNotifierProvider<ForYouFeedController, ForYouFeedResponse> {
  ForYouFeedControllerProvider._({
    required ForYouFeedControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'forYouFeedControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$forYouFeedControllerHash();

  @override
  String toString() {
    return r'forYouFeedControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ForYouFeedController create() => ForYouFeedController();

  @override
  bool operator ==(Object other) {
    return other is ForYouFeedControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$forYouFeedControllerHash() =>
    r'4365f108a9aa364c34053e6d9770f124dd59fc06';

final class ForYouFeedControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ForYouFeedController,
          AsyncValue<ForYouFeedResponse>,
          ForYouFeedResponse,
          FutureOr<ForYouFeedResponse>,
          String
        > {
  ForYouFeedControllerFamily._()
    : super(
        retry: null,
        name: r'forYouFeedControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ForYouFeedControllerProvider call({String methodFilter = 'ALL'}) =>
      ForYouFeedControllerProvider._(argument: methodFilter, from: this);

  @override
  String toString() => r'forYouFeedControllerProvider';
}

abstract class _$ForYouFeedController
    extends $AsyncNotifier<ForYouFeedResponse> {
  late final _$args = ref.$arg as String;
  String get methodFilter => _$args;

  FutureOr<ForYouFeedResponse> build({String methodFilter = 'ALL'});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ForYouFeedResponse>, ForYouFeedResponse>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ForYouFeedResponse>, ForYouFeedResponse>,
              AsyncValue<ForYouFeedResponse>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(methodFilter: _$args));
  }
}

@ProviderFor(trendingFeed)
final trendingFeedProvider = TrendingFeedProvider._();

final class TrendingFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrendingFeedResponse>,
          TrendingFeedResponse,
          FutureOr<TrendingFeedResponse>
        >
    with
        $FutureModifier<TrendingFeedResponse>,
        $FutureProvider<TrendingFeedResponse> {
  TrendingFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingFeedHash();

  @$internal
  @override
  $FutureProviderElement<TrendingFeedResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrendingFeedResponse> create(Ref ref) {
    return trendingFeed(ref);
  }
}

String _$trendingFeedHash() => r'f731a113499585323ab908c16ffd3ba9cc8dee99';

@ProviderFor(recommendedClubs)
final recommendedClubsProvider = RecommendedClubsProvider._();

final class RecommendedClubsProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecommendedClubsResponse>,
          RecommendedClubsResponse,
          FutureOr<RecommendedClubsResponse>
        >
    with
        $FutureModifier<RecommendedClubsResponse>,
        $FutureProvider<RecommendedClubsResponse> {
  RecommendedClubsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendedClubsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendedClubsHash();

  @$internal
  @override
  $FutureProviderElement<RecommendedClubsResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RecommendedClubsResponse> create(Ref ref) {
    return recommendedClubs(ref);
  }
}

String _$recommendedClubsHash() => r'9c2422bc0a00f5efd051b1643cd8bdb634979719';
