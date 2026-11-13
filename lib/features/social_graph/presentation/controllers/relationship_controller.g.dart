// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(socialGraphApiService)
final socialGraphApiServiceProvider = SocialGraphApiServiceProvider._();

final class SocialGraphApiServiceProvider
    extends
        $FunctionalProvider<
          SocialGraphApiService,
          SocialGraphApiService,
          SocialGraphApiService
        >
    with $Provider<SocialGraphApiService> {
  SocialGraphApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialGraphApiServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialGraphApiServiceHash();

  @$internal
  @override
  $ProviderElement<SocialGraphApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SocialGraphApiService create(Ref ref) {
    return socialGraphApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialGraphApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialGraphApiService>(value),
    );
  }
}

String _$socialGraphApiServiceHash() =>
    r'227cbdca3e4f7ba88b084cdc85158130637c7fe5';

@ProviderFor(RelationshipFeedbackBanner)
final relationshipFeedbackBannerProvider =
    RelationshipFeedbackBannerProvider._();

final class RelationshipFeedbackBannerProvider
    extends $NotifierProvider<RelationshipFeedbackBanner, String?> {
  RelationshipFeedbackBannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'relationshipFeedbackBannerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$relationshipFeedbackBannerHash();

  @$internal
  @override
  RelationshipFeedbackBanner create() => RelationshipFeedbackBanner();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$relationshipFeedbackBannerHash() =>
    r'139ac1deb9ca17e439252501c484f54806b8811d';

abstract class _$RelationshipFeedbackBanner extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(UserRelationshipController)
final userRelationshipControllerProvider = UserRelationshipControllerFamily._();

final class UserRelationshipControllerProvider
    extends
        $AsyncNotifierProvider<
          UserRelationshipController,
          RelationshipSnapshot
        > {
  UserRelationshipControllerProvider._({
    required UserRelationshipControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userRelationshipControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userRelationshipControllerHash();

  @override
  String toString() {
    return r'userRelationshipControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserRelationshipController create() => UserRelationshipController();

  @override
  bool operator ==(Object other) {
    return other is UserRelationshipControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userRelationshipControllerHash() =>
    r'8717fbb25773e1eec08bc658709bda4cd0b7ac3f';

final class UserRelationshipControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          UserRelationshipController,
          AsyncValue<RelationshipSnapshot>,
          RelationshipSnapshot,
          FutureOr<RelationshipSnapshot>,
          String
        > {
  UserRelationshipControllerFamily._()
    : super(
        retry: null,
        name: r'userRelationshipControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserRelationshipControllerProvider call(String targetUserOrUsername) =>
      UserRelationshipControllerProvider._(
        argument: targetUserOrUsername,
        from: this,
      );

  @override
  String toString() => r'userRelationshipControllerProvider';
}

abstract class _$UserRelationshipController
    extends $AsyncNotifier<RelationshipSnapshot> {
  late final _$args = ref.$arg as String;
  String get targetUserOrUsername => _$args;

  FutureOr<RelationshipSnapshot> build(String targetUserOrUsername);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<RelationshipSnapshot>, RelationshipSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RelationshipSnapshot>,
                RelationshipSnapshot
              >,
              AsyncValue<RelationshipSnapshot>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(MyPrivacySettingController)
final myPrivacySettingControllerProvider =
    MyPrivacySettingControllerProvider._();

final class MyPrivacySettingControllerProvider
    extends
        $AsyncNotifierProvider<
          MyPrivacySettingController,
          PrivacySettingSnapshot
        > {
  MyPrivacySettingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPrivacySettingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPrivacySettingControllerHash();

  @$internal
  @override
  MyPrivacySettingController create() => MyPrivacySettingController();
}

String _$myPrivacySettingControllerHash() =>
    r'261bfb661c026c9079eea37c560849f5af24a402';

abstract class _$MyPrivacySettingController
    extends $AsyncNotifier<PrivacySettingSnapshot> {
  FutureOr<PrivacySettingSnapshot> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PrivacySettingSnapshot>, PrivacySettingSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PrivacySettingSnapshot>,
                PrivacySettingSnapshot
              >,
              AsyncValue<PrivacySettingSnapshot>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SocialConnectionsTabController)
final socialConnectionsTabControllerProvider =
    SocialConnectionsTabControllerFamily._();

final class SocialConnectionsTabControllerProvider
    extends
        $AsyncNotifierProvider<
          SocialConnectionsTabController,
          GraphConnectionsPageState
        > {
  SocialConnectionsTabControllerProvider._({
    required SocialConnectionsTabControllerFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'socialConnectionsTabControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$socialConnectionsTabControllerHash();

  @override
  String toString() {
    return r'socialConnectionsTabControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SocialConnectionsTabController create() => SocialConnectionsTabController();

  @override
  bool operator ==(Object other) {
    return other is SocialConnectionsTabControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$socialConnectionsTabControllerHash() =>
    r'468740c82060f107769d4a7ae99da7ae39b402a9';

final class SocialConnectionsTabControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SocialConnectionsTabController,
          AsyncValue<GraphConnectionsPageState>,
          GraphConnectionsPageState,
          FutureOr<GraphConnectionsPageState>,
          (String, String)
        > {
  SocialConnectionsTabControllerFamily._()
    : super(
        retry: null,
        name: r'socialConnectionsTabControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SocialConnectionsTabControllerProvider call(
    String targetUserOrUsername,
    String kind,
  ) => SocialConnectionsTabControllerProvider._(
    argument: (targetUserOrUsername, kind),
    from: this,
  );

  @override
  String toString() => r'socialConnectionsTabControllerProvider';
}

abstract class _$SocialConnectionsTabController
    extends $AsyncNotifier<GraphConnectionsPageState> {
  late final _$args = ref.$arg as (String, String);
  String get targetUserOrUsername => _$args.$1;
  String get kind => _$args.$2;

  FutureOr<GraphConnectionsPageState> build(
    String targetUserOrUsername,
    String kind,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<GraphConnectionsPageState>,
              GraphConnectionsPageState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<GraphConnectionsPageState>,
                GraphConnectionsPageState
              >,
              AsyncValue<GraphConnectionsPageState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(PendingFollowRequestsController)
final pendingFollowRequestsControllerProvider =
    PendingFollowRequestsControllerProvider._();

final class PendingFollowRequestsControllerProvider
    extends
        $AsyncNotifierProvider<
          PendingFollowRequestsController,
          List<FollowRequestItem>
        > {
  PendingFollowRequestsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingFollowRequestsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingFollowRequestsControllerHash();

  @$internal
  @override
  PendingFollowRequestsController create() => PendingFollowRequestsController();
}

String _$pendingFollowRequestsControllerHash() =>
    r'dd88916337f6c34c6837d9fab517ed55c713cecb';

abstract class _$PendingFollowRequestsController
    extends $AsyncNotifier<List<FollowRequestItem>> {
  FutureOr<List<FollowRequestItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<FollowRequestItem>>,
              List<FollowRequestItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<FollowRequestItem>>,
                List<FollowRequestItem>
              >,
              AsyncValue<List<FollowRequestItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
