// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_profile_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(socialProfileApiService)
final socialProfileApiServiceProvider = SocialProfileApiServiceProvider._();

final class SocialProfileApiServiceProvider
    extends
        $FunctionalProvider<
          SocialProfileApiService,
          SocialProfileApiService,
          SocialProfileApiService
        >
    with $Provider<SocialProfileApiService> {
  SocialProfileApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialProfileApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialProfileApiServiceHash();

  @$internal
  @override
  $ProviderElement<SocialProfileApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SocialProfileApiService create(Ref ref) {
    return socialProfileApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialProfileApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialProfileApiService>(value),
    );
  }
}

String _$socialProfileApiServiceHash() =>
    r'1f4dc85371d26b6db6c9fa419c02ab07d7981362';

@ProviderFor(PublicProfileController)
final publicProfileControllerProvider = PublicProfileControllerFamily._();

final class PublicProfileControllerProvider
    extends
        $AsyncNotifierProvider<
          PublicProfileController,
          MaterializedProfileView
        > {
  PublicProfileControllerProvider._({
    required PublicProfileControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publicProfileControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicProfileControllerHash();

  @override
  String toString() {
    return r'publicProfileControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PublicProfileController create() => PublicProfileController();

  @override
  bool operator ==(Object other) {
    return other is PublicProfileControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicProfileControllerHash() =>
    r'dc3bde5accf89e406b119875dd4c323c2be9f28c';

final class PublicProfileControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PublicProfileController,
          AsyncValue<MaterializedProfileView>,
          MaterializedProfileView,
          FutureOr<MaterializedProfileView>,
          String
        > {
  PublicProfileControllerFamily._()
    : super(
        retry: null,
        name: r'publicProfileControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublicProfileControllerProvider call(String targetUserOrUsername) =>
      PublicProfileControllerProvider._(
        argument: targetUserOrUsername,
        from: this,
      );

  @override
  String toString() => r'publicProfileControllerProvider';
}

abstract class _$PublicProfileController
    extends $AsyncNotifier<MaterializedProfileView> {
  late final _$args = ref.$arg as String;
  String get targetUserOrUsername => _$args;

  FutureOr<MaterializedProfileView> build(String targetUserOrUsername);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<MaterializedProfileView>,
              MaterializedProfileView
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<MaterializedProfileView>,
                MaterializedProfileView
              >,
              AsyncValue<MaterializedProfileView>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(ProfileTabFeedController)
final profileTabFeedControllerProvider = ProfileTabFeedControllerFamily._();

final class ProfileTabFeedControllerProvider
    extends
        $AsyncNotifierProvider<
          ProfileTabFeedController,
          CursorPaginatedThreadsState
        > {
  ProfileTabFeedControllerProvider._({
    required ProfileTabFeedControllerFamily super.from,
    required (String, ProfileFeedTab) super.argument,
  }) : super(
         retry: null,
         name: r'profileTabFeedControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileTabFeedControllerHash();

  @override
  String toString() {
    return r'profileTabFeedControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ProfileTabFeedController create() => ProfileTabFeedController();

  @override
  bool operator ==(Object other) {
    return other is ProfileTabFeedControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileTabFeedControllerHash() =>
    r'5549ea07e7e0783d586e42be1dd29dbdf72ef066';

final class ProfileTabFeedControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileTabFeedController,
          AsyncValue<CursorPaginatedThreadsState>,
          CursorPaginatedThreadsState,
          FutureOr<CursorPaginatedThreadsState>,
          (String, ProfileFeedTab)
        > {
  ProfileTabFeedControllerFamily._()
    : super(
        retry: null,
        name: r'profileTabFeedControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileTabFeedControllerProvider call(
    String targetUserOrUsername,
    ProfileFeedTab tab,
  ) => ProfileTabFeedControllerProvider._(
    argument: (targetUserOrUsername, tab),
    from: this,
  );

  @override
  String toString() => r'profileTabFeedControllerProvider';
}

abstract class _$ProfileTabFeedController
    extends $AsyncNotifier<CursorPaginatedThreadsState> {
  late final _$args = ref.$arg as (String, ProfileFeedTab);
  String get targetUserOrUsername => _$args.$1;
  ProfileFeedTab get tab => _$args.$2;

  FutureOr<CursorPaginatedThreadsState> build(
    String targetUserOrUsername,
    ProfileFeedTab tab,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CursorPaginatedThreadsState>,
              CursorPaginatedThreadsState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CursorPaginatedThreadsState>,
                CursorPaginatedThreadsState
              >,
              AsyncValue<CursorPaginatedThreadsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(ThreadDetailController)
final threadDetailControllerProvider = ThreadDetailControllerFamily._();

final class ThreadDetailControllerProvider
    extends
        $AsyncNotifierProvider<ThreadDetailController, ThreadDetailResponse> {
  ThreadDetailControllerProvider._({
    required ThreadDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'threadDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$threadDetailControllerHash();

  @override
  String toString() {
    return r'threadDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ThreadDetailController create() => ThreadDetailController();

  @override
  bool operator ==(Object other) {
    return other is ThreadDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$threadDetailControllerHash() =>
    r'1302c692d445eaa2d35153db8fdf30cf6dab111d';

final class ThreadDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ThreadDetailController,
          AsyncValue<ThreadDetailResponse>,
          ThreadDetailResponse,
          FutureOr<ThreadDetailResponse>,
          String
        > {
  ThreadDetailControllerFamily._()
    : super(
        retry: null,
        name: r'threadDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ThreadDetailControllerProvider call(String threadId) =>
      ThreadDetailControllerProvider._(argument: threadId, from: this);

  @override
  String toString() => r'threadDetailControllerProvider';
}

abstract class _$ThreadDetailController
    extends $AsyncNotifier<ThreadDetailResponse> {
  late final _$args = ref.$arg as String;
  String get threadId => _$args;

  FutureOr<ThreadDetailResponse> build(String threadId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ThreadDetailResponse>, ThreadDetailResponse>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ThreadDetailResponse>,
                ThreadDetailResponse
              >,
              AsyncValue<ThreadDetailResponse>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(baristaDirectorySearch)
final baristaDirectorySearchProvider = BaristaDirectorySearchFamily._();

final class BaristaDirectorySearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProfileDirectoryEntry>>,
          List<ProfileDirectoryEntry>,
          FutureOr<List<ProfileDirectoryEntry>>
        >
    with
        $FutureModifier<List<ProfileDirectoryEntry>>,
        $FutureProvider<List<ProfileDirectoryEntry>> {
  BaristaDirectorySearchProvider._({
    required BaristaDirectorySearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'baristaDirectorySearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$baristaDirectorySearchHash();

  @override
  String toString() {
    return r'baristaDirectorySearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProfileDirectoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProfileDirectoryEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return baristaDirectorySearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BaristaDirectorySearchProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$baristaDirectorySearchHash() =>
    r'81f5e0db77f7655ccf788c9e9334a6b27a3551af';

final class BaristaDirectorySearchFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ProfileDirectoryEntry>>,
          String
        > {
  BaristaDirectorySearchFamily._()
    : super(
        retry: null,
        name: r'baristaDirectorySearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BaristaDirectorySearchProvider call(String query) =>
      BaristaDirectorySearchProvider._(argument: query, from: this);

  @override
  String toString() => r'baristaDirectorySearchProvider';
}
