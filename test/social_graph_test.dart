import 'package:coffee_hub_mobile/features/social_graph/data/services/social_graph_api_service.dart';
import 'package:coffee_hub_mobile/features/social_graph/domain/models/social_graph_models.dart';
import 'package:coffee_hub_mobile/features/social_graph/presentation/controllers/relationship_controller.dart';
import 'package:coffee_hub_mobile/features/social_graph/presentation/screens/social_connections_tab_screen.dart';
import 'package:coffee_hub_mobile/features/social_graph/presentation/widgets/mutual_followers_banner_pill.dart';
import 'package:coffee_hub_mobile/features/social_graph/presentation/widgets/smart_follow_follback_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSocialGraphApi extends SocialGraphApiService {
  RelationshipSnapshot initialSnap;
  int followCalls = 0;
  int unfollowCalls = 0;
  int acceptCalls = 0;
  int rejectCalls = 0;
  bool throw403OnFollowers = false;

  _FakeSocialGraphApi(this.initialSnap) : super(Dio());

  @override
  Future<RelationshipSnapshot> getRelationshipSnapshot(String target) async {
    return initialSnap;
  }

  @override
  Future<FollowMutationResult> followUser(String target) async {
    followCalls++;
    final nextState = initialSnap.targetIsPrivate
        ? RelationshipState.requested
        : (initialSnap.isFollowedByTarget
              ? RelationshipState.mutual
              : RelationshipState.following);
    final nextFollowers = initialSnap.targetIsPrivate
        ? initialSnap.followersCount
        : initialSnap.followersCount + 1;
    initialSnap = initialSnap.copyWith(
      state: nextState,
      isMutual: nextState == RelationshipState.mutual,
      followersCount: nextFollowers,
    );
    return FollowMutationResult(
      targetUserId: initialSnap.targetUserId,
      state: nextState,
      status: initialSnap.targetIsPrivate ? 'PENDING' : 'ACCEPTED',
      targetFollowersCount: nextFollowers,
      targetFollowingCount: initialSnap.followingCount,
      mutualFollowersCount: initialSnap.mutualFollowersCount,
    );
  }

  @override
  Future<FollowMutationResult> unfollowUser(String target) async {
    unfollowCalls++;
    final nextState = initialSnap.isFollowedByTarget
        ? RelationshipState.followedByTarget
        : RelationshipState.none;
    final nextFollowers =
        (initialSnap.followersCount - 1).clamp(0, 1 << 30);
    initialSnap = initialSnap.copyWith(
      state: nextState,
      isMutual: false,
      followersCount: nextFollowers,
    );
    return FollowMutationResult(
      targetUserId: initialSnap.targetUserId,
      state: nextState,
      status: 'NONE',
      targetFollowersCount: nextFollowers,
      targetFollowingCount: initialSnap.followingCount,
      mutualFollowersCount: initialSnap.mutualFollowersCount,
    );
  }

  @override
  Future<PrivacySettingSnapshot> getPrivacySetting() async {
    return const PrivacySettingSnapshot(
      isPrivateAccount: true,
      pendingFollowRequestsCount: 1,
    );
  }

  @override
  Future<SocialGraphCursorPage<FollowRequestItem>> listPendingRequests({
    String? cursor,
    int limit = 20,
  }) async {
    return SocialGraphCursorPage(
      items: [
        FollowRequestItem(
          requesterId: 'req-1',
          username: 'barista_req',
          displayName: 'Barista Requester',
          baristaLevel: 14,
          requestedAt: DateTime.utc(2026, 11, 13),
        ),
      ],
      nextCursor: null,
      hasMore: false,
    );
  }

  @override
  Future<PendingRequestActionResult> handleFollowRequest({
    required String requesterId,
    required bool accept,
  }) async {
    if (accept) {
      acceptCalls++;
    } else {
      rejectCalls++;
    }
    return PendingRequestActionResult(
      requesterId: requesterId,
      action: accept ? 'accepted' : 'rejected',
      state: RelationshipState.followedByTarget,
      pendingFollowRequestsCount: 0,
      followersCount: accept ? 1 : 0,
    );
  }

  @override
  Future<SocialGraphCursorPage<SocialGraphUserItem>> listConnections({
    required String targetUserOrUsername,
    required String kind,
    String? cursor,
    int limit = 20,
  }) async {
    if (throw403OnFollowers && kind == 'followers') {
      throw DioException(
        requestOptions: RequestOptions(path: '/followers'),
        response: Response(
          requestOptions: RequestOptions(path: '/followers'),
          statusCode: 403,
        ),
      );
    }
    return SocialGraphCursorPage(
      items: [
        SocialGraphUserItem(
          userId: 'u-$kind-1',
          username: 'user_$kind',
          displayName: 'Brewer $kind',
          baristaLevel: 25,
          baristaRankTitle: 'Sensory Alchemist',
          relationshipState: kind == 'mutual'
              ? RelationshipState.mutual
              : RelationshipState.followedByTarget,
          followedAt: DateTime.utc(2026, 11, 13),
        ),
      ],
      nextCursor: null,
      hasMore: false,
    );
  }
}

void main() {
  group('Modul 3.3 Relationship Matrix & Events', () {
    test('6-way state machine computes next optimistic states cleanly', () {
      expect(
        RelationshipState.none.nextOptimisticState(
          isTargetPrivate: false,
          isFollowedByTarget: false,
        ),
        RelationshipState.following,
      );
      expect(
        RelationshipState.none.nextOptimisticState(
          isTargetPrivate: true,
          isFollowedByTarget: false,
        ),
        RelationshipState.requested,
      );
      expect(
        RelationshipState.followedByTarget.nextOptimisticState(
          isTargetPrivate: false,
          isFollowedByTarget: true,
        ),
        RelationshipState.mutual,
      );
      expect(
        RelationshipState.mutual.nextOptimisticState(
          isTargetPrivate: false,
          isFollowedByTarget: true,
        ),
        RelationshipState.followedByTarget,
      );
      expect(RelationshipState.followedByTarget.ctaLabel, 'Follback');
      expect(RelationshipState.mutual.ctaLabel, 'Teman Mutual');

      final evt = SocialGraphRealtimeEvent.fromPayload({
        'actor_id': 'u-9',
        'actor_username': 'ryan',
        'actor_display_name': 'Ryan Wibawa',
        'state': 'mutual',
        'action': 'follback',
        'message': 'Ryan Wibawa mengikuti Anda balik!',
        'created_at': '2026-11-13T10:00:00Z',
      });
      expect(evt.state, RelationshipState.mutual);
      expect(evt.action, 'follback');
    });
  });

  group('UserRelationshipController 350ms Coalescing Guard', () {
    test('rapid follow+unfollow within 350ms cancels out with 0 HTTP calls', () async {
      final api = _FakeSocialGraphApi(
        const RelationshipSnapshot(
          targetUserId: 'target-1',
          state: RelationshipState.followedByTarget,
          isFollowedByTarget: true,
          followersCount: 10,
        ),
      );
      final container = ProviderContainer(
        overrides: [socialGraphApiServiceProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
      final sub = container.listen(
        userRelationshipControllerProvider('target-1'),
        (_, _) {},
      );
      addTearDown(sub.close);

      final initial = await container.read(
        userRelationshipControllerProvider('target-1').future,
      );
      expect(initial.state, RelationshipState.followedByTarget);

      final notifier = container.read(
        userRelationshipControllerProvider('target-1').notifier,
      );
      await notifier.toggleFollow();
      expect(
        container
            .read(userRelationshipControllerProvider('target-1'))
            .value
            ?.state,
        RelationshipState.mutual,
      );
      expect(
        container
            .read(userRelationshipControllerProvider('target-1'))
            .value
            ?.followersCount,
        11,
      );

      // Undo immediately before 350ms window expires
      await notifier.toggleFollow();
      expect(
        container
            .read(userRelationshipControllerProvider('target-1'))
            .value
            ?.state,
        RelationshipState.followedByTarget,
      );

      await Future<void>.delayed(const Duration(milliseconds: 420));
      expect(api.followCalls, 0);
      expect(api.unfollowCalls, 0);
    });

    test('rapid toggle ending in net follow sends exactly 1 POST follow', () async {
      final api = _FakeSocialGraphApi(
        const RelationshipSnapshot(
          targetUserId: 'target-2',
          state: RelationshipState.none,
          followersCount: 5,
        ),
      );
      final container = ProviderContainer(
        overrides: [socialGraphApiServiceProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
      final sub = container.listen(
        userRelationshipControllerProvider('target-2'),
        (_, _) {},
      );
      addTearDown(sub.close);

      await container.read(userRelationshipControllerProvider('target-2').future);
      final notifier = container.read(
        userRelationshipControllerProvider('target-2').notifier,
      );

      await notifier.toggleFollow();
      await notifier.toggleFollow();
      await notifier.toggleFollow();

      await Future<void>.delayed(const Duration(milliseconds: 420));
      expect(api.followCalls, 1);
      expect(api.unfollowCalls, 0);
      final end =
          container.read(userRelationshipControllerProvider('target-2')).value;
      expect(end?.state, RelationshipState.following);
      expect(end?.followersCount, 6);
    });

    test('PendingFollowRequestsController optimistically accepts and updates privacy count', () async {
      final api = _FakeSocialGraphApi(
        const RelationshipSnapshot(targetUserId: 'me'),
      );
      final container = ProviderContainer(
        overrides: [socialGraphApiServiceProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);

      await container.read(myPrivacySettingControllerProvider.future);
      final requests = await container.read(
        pendingFollowRequestsControllerProvider.future,
      );
      expect(requests.length, 1);

      await container
          .read(pendingFollowRequestsControllerProvider.notifier)
          .handleRequest(requesterId: 'req-1', accept: true);

      expect(api.acceptCalls, 1);
      expect(
        container.read(pendingFollowRequestsControllerProvider).value,
        isEmpty,
      );
      expect(
        container
            .read(myPrivacySettingControllerProvider)
            .value
            ?.pendingFollowRequestsCount,
        0,
      );
    });
  });

  group('Modul 3.3 UI Widgets & Screens', () {
    testWidgets('RelationshipCtaButton & MutualFollowersBannerPill render and respond', (tester) async {
      var tappedCta = false;
      var tappedMutual = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RelationshipCtaButton(
                  state: RelationshipState.followedByTarget,
                  onTap: () => tappedCta = true,
                ),
                MutualFollowersBannerPill(
                  mutualCount: 5,
                  avatars: const [
                    MiniUserAvatar(
                      userId: '1',
                      username: 'bayu',
                      displayName: 'Bayu Prawiro',
                    ),
                    MiniUserAvatar(
                      userId: '2',
                      username: 'ryan',
                      displayName: 'Ryan Wibawa',
                    ),
                  ],
                  onTap: () => tappedMutual = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Follback'), findsOneWidget);
      expect(
        find.text('Diikuti oleh Bayu Prawiro, Ryan Wibawa, dan 3 lainnya'),
        findsOneWidget,
      );

      await tester.tap(find.text('Follback'));
      await tester.tap(
        find.text('Diikuti oleh Bayu Prawiro, Ryan Wibawa, dan 3 lainnya'),
      );
      expect(tappedCta, isTrue);
      expect(tappedMutual, isTrue);
    });

    testWidgets('SocialConnectionsTabScreen renders 3 tabs and handles 403 privacy lock', (tester) async {
      final api = _FakeSocialGraphApi(
        const RelationshipSnapshot(targetUserId: 'target-priv'),
      )..throw403OnFollowers = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [socialGraphApiServiceProvider.overrideWithValue(api)],
          child: const MaterialApp(
            home: SocialConnectionsTabScreen(
              targetUserOrUsername: 'target-priv',
              displayName: 'Private Brewer',
              initialTabIndex: 1,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Mutual'), findsOneWidget);
      expect(find.text('Pengikut'), findsOneWidget);
      expect(find.text('Mengikuti'), findsOneWidget);
      expect(find.text('Akun Ini Bersifat Privat'), findsOneWidget);

      await tester.tap(find.text('Mutual'));
      await tester.pumpAndSettle();
      expect(find.text('Brewer mutual'), findsOneWidget);
      expect(find.text('Teman Mutual'), findsOneWidget);
    });
  });
}
