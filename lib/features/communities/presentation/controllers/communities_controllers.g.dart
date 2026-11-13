// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communities_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(communitiesApi)
final communitiesApiProvider = CommunitiesApiProvider._();

final class CommunitiesApiProvider
    extends
        $FunctionalProvider<
          CommunitiesApiService,
          CommunitiesApiService,
          CommunitiesApiService
        >
    with $Provider<CommunitiesApiService> {
  CommunitiesApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communitiesApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communitiesApiHash();

  @$internal
  @override
  $ProviderElement<CommunitiesApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommunitiesApiService create(Ref ref) {
    return communitiesApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommunitiesApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommunitiesApiService>(value),
    );
  }
}

String _$communitiesApiHash() => r'b0b5715dcb163f5e33d5df1662429e8ea279fdb0';

@ProviderFor(communitiesLocalDb)
final communitiesLocalDbProvider = CommunitiesLocalDbProvider._();

final class CommunitiesLocalDbProvider
    extends
        $FunctionalProvider<
          CommunitiesLocalDatabase,
          CommunitiesLocalDatabase,
          CommunitiesLocalDatabase
        >
    with $Provider<CommunitiesLocalDatabase> {
  CommunitiesLocalDbProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communitiesLocalDbProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communitiesLocalDbHash();

  @$internal
  @override
  $ProviderElement<CommunitiesLocalDatabase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommunitiesLocalDatabase create(Ref ref) {
    return communitiesLocalDb(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommunitiesLocalDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommunitiesLocalDatabase>(value),
    );
  }
}

String _$communitiesLocalDbHash() =>
    r'a76942f7c10bb26ae121c30e132557fb0cde1b65';

@ProviderFor(ExploreCommunitiesController)
final exploreCommunitiesControllerProvider =
    ExploreCommunitiesControllerFamily._();

final class ExploreCommunitiesControllerProvider
    extends
        $AsyncNotifierProvider<
          ExploreCommunitiesController,
          DiscoverCommunitiesResponse
        > {
  ExploreCommunitiesControllerProvider._({
    required ExploreCommunitiesControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'exploreCommunitiesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exploreCommunitiesControllerHash();

  @override
  String toString() {
    return r'exploreCommunitiesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ExploreCommunitiesController create() => ExploreCommunitiesController();

  @override
  bool operator ==(Object other) {
    return other is ExploreCommunitiesControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exploreCommunitiesControllerHash() =>
    r'1603f6e877b284bfa5e08b892ad13405fb0e6f8e';

final class ExploreCommunitiesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ExploreCommunitiesController,
          AsyncValue<DiscoverCommunitiesResponse>,
          DiscoverCommunitiesResponse,
          FutureOr<DiscoverCommunitiesResponse>,
          String?
        > {
  ExploreCommunitiesControllerFamily._()
    : super(
        retry: null,
        name: r'exploreCommunitiesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExploreCommunitiesControllerProvider call({String? query}) =>
      ExploreCommunitiesControllerProvider._(argument: query, from: this);

  @override
  String toString() => r'exploreCommunitiesControllerProvider';
}

abstract class _$ExploreCommunitiesController
    extends $AsyncNotifier<DiscoverCommunitiesResponse> {
  late final _$args = ref.$arg as String?;
  String? get query => _$args;

  FutureOr<DiscoverCommunitiesResponse> build({String? query});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<DiscoverCommunitiesResponse>,
              DiscoverCommunitiesResponse
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DiscoverCommunitiesResponse>,
                DiscoverCommunitiesResponse
              >,
              AsyncValue<DiscoverCommunitiesResponse>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(query: _$args));
  }
}

@ProviderFor(CommunityWorkspaceController)
final communityWorkspaceControllerProvider =
    CommunityWorkspaceControllerFamily._();

final class CommunityWorkspaceControllerProvider
    extends
        $AsyncNotifierProvider<
          CommunityWorkspaceController,
          CommunityWorkspace
        > {
  CommunityWorkspaceControllerProvider._({
    required CommunityWorkspaceControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'communityWorkspaceControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityWorkspaceControllerHash();

  @override
  String toString() {
    return r'communityWorkspaceControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommunityWorkspaceController create() => CommunityWorkspaceController();

  @override
  bool operator ==(Object other) {
    return other is CommunityWorkspaceControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityWorkspaceControllerHash() =>
    r'b79aee814ec87efec1fee7415ec2358e932eae6d';

final class CommunityWorkspaceControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CommunityWorkspaceController,
          AsyncValue<CommunityWorkspace>,
          CommunityWorkspace,
          FutureOr<CommunityWorkspace>,
          String
        > {
  CommunityWorkspaceControllerFamily._()
    : super(
        retry: null,
        name: r'communityWorkspaceControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommunityWorkspaceControllerProvider call(String communityId) =>
      CommunityWorkspaceControllerProvider._(argument: communityId, from: this);

  @override
  String toString() => r'communityWorkspaceControllerProvider';
}

abstract class _$CommunityWorkspaceController
    extends $AsyncNotifier<CommunityWorkspace> {
  late final _$args = ref.$arg as String;
  String get communityId => _$args;

  FutureOr<CommunityWorkspace> build(String communityId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CommunityWorkspace>, CommunityWorkspace>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CommunityWorkspace>, CommunityWorkspace>,
              AsyncValue<CommunityWorkspace>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(clubFeedItems)
final clubFeedItemsProvider = ClubFeedItemsFamily._();

final class ClubFeedItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SocialThreadItem>>,
          List<SocialThreadItem>,
          FutureOr<List<SocialThreadItem>>
        >
    with
        $FutureModifier<List<SocialThreadItem>>,
        $FutureProvider<List<SocialThreadItem>> {
  ClubFeedItemsProvider._({
    required ClubFeedItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubFeedItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubFeedItemsHash();

  @override
  String toString() {
    return r'clubFeedItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SocialThreadItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SocialThreadItem>> create(Ref ref) {
    final argument = this.argument as String;
    return clubFeedItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubFeedItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubFeedItemsHash() => r'7d996d3c5a26d5f53ee69a6d583f77f3800d22c4';

final class ClubFeedItemsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SocialThreadItem>>, String> {
  ClubFeedItemsFamily._()
    : super(
        retry: null,
        name: r'clubFeedItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClubFeedItemsProvider call(String communityId) =>
      ClubFeedItemsProvider._(argument: communityId, from: this);

  @override
  String toString() => r'clubFeedItemsProvider';
}

@ProviderFor(clubRecipeVaultItems)
final clubRecipeVaultItemsProvider = ClubRecipeVaultItemsFamily._();

final class ClubRecipeVaultItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SocialThreadItem>>,
          List<SocialThreadItem>,
          FutureOr<List<SocialThreadItem>>
        >
    with
        $FutureModifier<List<SocialThreadItem>>,
        $FutureProvider<List<SocialThreadItem>> {
  ClubRecipeVaultItemsProvider._({
    required ClubRecipeVaultItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubRecipeVaultItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubRecipeVaultItemsHash();

  @override
  String toString() {
    return r'clubRecipeVaultItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SocialThreadItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SocialThreadItem>> create(Ref ref) {
    final argument = this.argument as String;
    return clubRecipeVaultItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubRecipeVaultItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubRecipeVaultItemsHash() =>
    r'9c333f62a2fc536d64bd41ee5d5c70ba96f4c285';

final class ClubRecipeVaultItemsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SocialThreadItem>>, String> {
  ClubRecipeVaultItemsFamily._()
    : super(
        retry: null,
        name: r'clubRecipeVaultItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClubRecipeVaultItemsProvider call(String communityId) =>
      ClubRecipeVaultItemsProvider._(argument: communityId, from: this);

  @override
  String toString() => r'clubRecipeVaultItemsProvider';
}

@ProviderFor(clubLeaderboardItems)
final clubLeaderboardItemsProvider = ClubLeaderboardItemsFamily._();

final class ClubLeaderboardItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CommunityLeaderboardEntry>>,
          List<CommunityLeaderboardEntry>,
          FutureOr<List<CommunityLeaderboardEntry>>
        >
    with
        $FutureModifier<List<CommunityLeaderboardEntry>>,
        $FutureProvider<List<CommunityLeaderboardEntry>> {
  ClubLeaderboardItemsProvider._({
    required ClubLeaderboardItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubLeaderboardItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubLeaderboardItemsHash();

  @override
  String toString() {
    return r'clubLeaderboardItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CommunityLeaderboardEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CommunityLeaderboardEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return clubLeaderboardItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubLeaderboardItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubLeaderboardItemsHash() =>
    r'a78dd1d85c8a614b33efa152d9a4525adbbc58ee';

final class ClubLeaderboardItemsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CommunityLeaderboardEntry>>,
          String
        > {
  ClubLeaderboardItemsFamily._()
    : super(
        retry: null,
        name: r'clubLeaderboardItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClubLeaderboardItemsProvider call(String communityId) =>
      ClubLeaderboardItemsProvider._(argument: communityId, from: this);

  @override
  String toString() => r'clubLeaderboardItemsProvider';
}

@ProviderFor(clubInvitesList)
final clubInvitesListProvider = ClubInvitesListFamily._();

final class ClubInvitesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CommunityInviteSecret>>,
          List<CommunityInviteSecret>,
          FutureOr<List<CommunityInviteSecret>>
        >
    with
        $FutureModifier<List<CommunityInviteSecret>>,
        $FutureProvider<List<CommunityInviteSecret>> {
  ClubInvitesListProvider._({
    required ClubInvitesListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubInvitesListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubInvitesListHash();

  @override
  String toString() {
    return r'clubInvitesListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CommunityInviteSecret>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CommunityInviteSecret>> create(Ref ref) {
    final argument = this.argument as String;
    return clubInvitesList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubInvitesListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubInvitesListHash() => r'3187b5fb29952edad9c261578f34d2ae52f3b6ba';

final class ClubInvitesListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CommunityInviteSecret>>,
          String
        > {
  ClubInvitesListFamily._()
    : super(
        retry: null,
        name: r'clubInvitesListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClubInvitesListProvider call(String communityId) =>
      ClubInvitesListProvider._(argument: communityId, from: this);

  @override
  String toString() => r'clubInvitesListProvider';
}

@ProviderFor(SecretIdJoinController)
final secretIdJoinControllerProvider = SecretIdJoinControllerProvider._();

final class SecretIdJoinControllerProvider
    extends $AsyncNotifierProvider<SecretIdJoinController, JoinClubResponse?> {
  SecretIdJoinControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secretIdJoinControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secretIdJoinControllerHash();

  @$internal
  @override
  SecretIdJoinController create() => SecretIdJoinController();
}

String _$secretIdJoinControllerHash() =>
    r'c29831fe6fbb99e57b5d4e30b33e80c10c9545e0';

abstract class _$SecretIdJoinController
    extends $AsyncNotifier<JoinClubResponse?> {
  FutureOr<JoinClubResponse?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<JoinClubResponse?>, JoinClubResponse?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<JoinClubResponse?>, JoinClubResponse?>,
              AsyncValue<JoinClubResponse?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
