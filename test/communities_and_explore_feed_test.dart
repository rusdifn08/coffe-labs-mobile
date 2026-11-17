import 'dart:convert';

import 'package:coffee_hub_mobile/features/communities/data/communities_api_service.dart';
import 'package:coffee_hub_mobile/features/communities/data/communities_local_cache.dart';
import 'package:coffee_hub_mobile/features/communities/domain/community_models.dart';
import 'package:coffee_hub_mobile/features/communities/presentation/controllers/communities_controllers.dart';
import 'package:coffee_hub_mobile/features/communities/presentation/utils/crockford_input_formatter.dart';
import 'package:coffee_hub_mobile/features/communities/presentation/widgets/create_club_sheet.dart';
import 'package:coffee_hub_mobile/features/communities/presentation/widgets/join_club_by_secret_id_sheet.dart';
import 'package:coffee_hub_mobile/features/explore_feed/data/explore_feed_api_service.dart';
import 'package:coffee_hub_mobile/features/explore_feed/domain/explore_feed_models.dart';
import 'package:coffee_hub_mobile/features/explore_feed/presentation/controllers/explore_feed_controllers.dart';
import 'package:coffee_hub_mobile/features/explore_feed/presentation/screens/social_explore_and_feed_screen.dart';
import 'package:coffee_hub_mobile/features/notifications/data/services/device_token_lifecycle_service.dart';
import 'package:coffee_hub_mobile/features/notifications/data/services/notification_api_service.dart';
import 'package:coffee_hub_mobile/features/notifications/domain/models/notification_models.dart';
import 'package:coffee_hub_mobile/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:coffee_hub_mobile/features/social_chat/data/local/chat_drift_database.dart';
import 'package:coffee_hub_mobile/features/social_chat/data/services/chat_api_service.dart';
import 'package:coffee_hub_mobile/features/social_chat/data/services/chat_ws_service.dart';
import 'package:coffee_hub_mobile/features/social_chat/domain/chat_protocol.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/controllers/chat_controllers.dart';
import 'package:coffee_hub_mobile/features/social_graph/data/services/social_graph_api_service.dart';
import 'package:coffee_hub_mobile/features/social_graph/domain/models/social_graph_models.dart';
import 'package:coffee_hub_mobile/features/social_graph/presentation/controllers/relationship_controller.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/data/services/social_profile_api_service.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/domain/models/social_profile_models.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/presentation/controllers/social_profile_controllers.dart';
import 'package:coffee_hub_mobile/screens/basecamp_screen.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CrockfordSecretIdInputFormatter', () {
    test('normalizes typos O->0, I/L->1 and formats CLB-XXXX-XXXXXX', () {
      final formatter = CrockfordSecretIdInputFormatter();
      final res = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'clb-4fok-il2p4w999'),
      );
      expect(res.text, 'CLB-4F0K-112P4W');
      expect(
        CrockfordSecretIdInputFormatter.normalizeCore('o-i-l 1234567'),
        '0111234567',
      );
    });
  });

  group('Module 3.5 JSON Wire Contracts', () {
    test('parses CommunityWorkspace and JoinClubResponse', () {
      final ws = CommunityWorkspace.fromJson({
        'community': {
          'id': 'club-1',
          'handle_slug': 'v60-lab',
          'name': 'V60 Lab',
          'description': 'Eksperimen pour over',
          'privacy_level': 'SECRET_VAULT',
          'owner_id': 'user-1',
          'focus_tags': ['V60', 'Ethiopia'],
          'members_count': 42,
          'threads_count': 12,
          'shared_recipes_count': 8,
          'total_club_xp': 450,
          'viewer_role': 'OWNER',
          'is_member': true,
          'created_at': '2026-11-13T10:00:00Z',
        },
        'channels': [
          {
            'id': 'ch-1',
            'community_id': 'club-1',
            'name': '#general-lounge',
            'kind': 'REALTIME_CHAT',
            'linked_conversation_id': 'conv-1',
            'display_order': 1,
            'is_readonly_announcement': false,
          },
        ],
        'my_role': 'OWNER',
        'is_member': true,
        'can_post': true,
        'can_manage_invites': true,
        'active_secret_code_preview': 'CLB-4F9K-2X8P4W',
      });

      expect(ws.community.privacyLevel, 'SECRET_VAULT');
      expect(ws.channels.first.linkedConversationId, 'conv-1');
      expect(ws.canManageInvites, isTrue);
    });

    test('parses flattened RecommendedThreadItem inside ForYouFeedResponse', () {
      final res = ForYouFeedResponse.fromJson({
        'user_top_tastes': ['Citrus & Bergamot', 'V60 & Pour-Over'],
        'next_offset': 20,
        'has_more': true,
        'items': [
          {
            'id': 'thr-1',
            'author_id': 'auth-1',
            'author_username': 'barista_koko',
            'author_display_name': 'Barista Koko',
            'body_text': 'V60 Ethiopia Washed mantap!',
            'created_at': '2026-11-13T11:00:00Z',
            'relevance_score': 0.89,
            'taste_match_pct': 92,
            'reason_badge': 'Cocok 92% • Selera Kopimu',
            'is_trending': true,
            'community_id': 'club-1',
            'community_name': 'V60 Lab',
          },
        ],
      });

      expect(res.hasMore, isTrue);
      expect(res.userTopTastes, contains('V60 & Pour-Over'));
      expect(res.items.single.thread.authorUsername, 'barista_koko');
      expect(res.items.single.tasteMatchPct, 92);
      expect(res.items.single.communityName, 'V60 Lab');
    });
  });

  testWidgets('JoinClubBySecretIdSheet validates incomplete Secret ID',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: JoinClubBySecretIdSheet()),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'ab12');
    await tester.tap(find.text('Join Club').last);
    await tester.pump();

    expect(find.text('CLB-AB12'), findsOneWidget);
    expect(
      find.text('Masukkan 10 karakter lengkap kode Secret ID.'),
      findsOneWidget,
    );
  });

  group('Coffee Club Unified Hub, Direct Invites & Accept/Decline', () {
    test('parses ClubMemberInvitation and RespondInvitationResponse contracts', () {
      final invite = ClubMemberInvitation.fromJson({
        'id': 'inv-1',
        'community_id': 'club-99',
        'community_name': 'Malabar V60 Guild',
        'community_slug': 'malabar-v60-guild',
        'community_description': 'Diskusi proses wine',
        'privacy_level': 'RESTRICTED',
        'members_count': 12,
        'focus_tags': ['V60', 'Wine'],
        'inviter_id': 'user-owner',
        'inviter_username': 'rusdifn08',
        'inviter_display_name': 'Admin Rusdi',
        'role_granted': 'BARISTA_MEMBER',
        'message': 'Gabung ya!',
        'status': 'PENDING',
        'created_at': '2026-11-16T02:00:00Z',
      });
      expect(invite.communityName, 'Malabar V60 Guild');
      expect(invite.inviterUsername, 'rusdifn08');
      expect(invite.status, 'PENDING');

      final resp = RespondInvitationResponse.fromJson({
        'invitation_id': 'inv-1',
        'community_id': 'club-99',
        'status': 'ACCEPTED',
      });
      expect(resp.status, 'ACCEPTED');
      expect(resp.communityId, 'club-99');
    });

    testWidgets(
        'CreateClubSheet lets founder pick invitees & submit invitedUserIds',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'coffeehub_auth_user_json': json.encode({
          'id': 'owner-uuid',
          'username': 'rusdifn08',
          'full_name': 'Rusdi',
          'role': 'user',
          'status': 'approved',
        }),
      });
      final fakeCommApi = _FakeCommunitiesApiService();
      final fakeProfileApi = _FakeProfilesApiService();
      final fakeGraphApi = _FakeMutualGraphApiService();
      final fakeChatApi = _FakeEmptyChatApiService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communitiesApiProvider.overrideWithValue(fakeCommApi),
            socialProfileApiServiceProvider.overrideWithValue(fakeProfileApi),
            socialGraphApiServiceProvider.overrideWithValue(fakeGraphApi),
            chatApiServiceProvider.overrideWithValue(fakeChatApi),
          ],
          child: const MaterialApp(
            home: Scaffold(body: CreateClubSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Club'), findsOneWidget);
      expect(find.text('Saling Follow'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Nama Coffee Club'),
        'Gayo Coffee Club',
      );
      await tester.pump();
      expect(find.text('coffeelabs.app/club/gayo-coffee-club'), findsOneWidget);

      await tester.ensureVisible(find.text('+ Undang').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('+ Undang').first);
      await tester.pumpAndSettle();

      expect(find.text('Barista Diundang (1)'), findsOneWidget);
      expect(find.text('New Club (1 Undangan)'), findsOneWidget);

      await tester.ensureVisible(find.text('New Club (1 Undangan)'));
      await tester.tap(find.text('New Club (1 Undangan)'));
      await tester.pump();

      expect(fakeCommApi.lastCreatedName, 'Gayo Coffee Club');
      expect(fakeCommApi.lastInvitedUserIds, ['peer-risa-id']);
    });

    testWidgets(
        'ClubInviteUsersPicker still loads Saling Follow mutual friends when /profiles fails 500',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'coffeehub_auth_user_json': json.encode({
          'id': 'owner-uuid',
          'username': 'rusdifn08',
          'full_name': 'Rusdi',
          'role': 'user',
          'status': 'approved',
        }),
      });
      final fakeCommApi = _FakeCommunitiesApiService();
      final failingProfilesApi = _FakeProfilesApiService()..shouldFailExplore = true;
      final fakeGraphApi = _FakeMutualGraphApiService();
      final fakeChatApi = _FakeEmptyChatApiService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communitiesApiProvider.overrideWithValue(fakeCommApi),
            socialProfileApiServiceProvider.overrideWithValue(failingProfilesApi),
            socialGraphApiServiceProvider.overrideWithValue(fakeGraphApi),
            chatApiServiceProvider.overrideWithValue(fakeChatApi),
          ],
          child: const MaterialApp(
            home: Scaffold(body: CreateClubSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tidak dapat memuat daftar barista.'), findsNothing);
      expect(find.text('Risa Hanipah'), findsOneWidget);
      expect(find.text('Saling Follow'), findsOneWidget);
    });

    testWidgets(
        'BasecampScreen uses centered Coffee Club header, compact card without description, Join Club & New Club buttons, reversed icon tabs, and Accept/Decline invites',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeCommApi = _FakeCommunitiesApiService();
      final fakeExploreApi = _FakeExploreFeedApiService();
      final localDb = CommunitiesLocalDatabase(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communitiesApiProvider.overrideWithValue(fakeCommApi),
            communitiesLocalDbProvider.overrideWithValue(localDb),
            exploreFeedApiProvider.overrideWithValue(fakeExploreApi),
          ],
          child: const MaterialApp(home: BasecampScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Coffee Club'), findsNWidgets(2));
      final headerCenterDx =
          tester.getCenter(find.text('Coffee Club').first).dx;
      expect((headerCenterDx - 195.0).abs(), lessThan(1.5));

      expect(find.text('Komunitas & Basecamp Barista'), findsOneWidget);
      expect(
        find.textContaining('Buat grup sendiri, undang barista langsung'),
        findsNothing,
      );
      expect(find.text('Social Coffee Explore'), findsNothing);
      expect(find.text('✨ For You'), findsNothing);
      expect(find.text('🔥 Trending'), findsNothing);
      expect(find.byTooltip('Trending'), findsOneWidget);
      expect(find.byTooltip('For You'), findsOneWidget);
      final tabClubX = tester.getCenter(find.text('Coffee Club').last).dx;
      final tabTrendX = tester.getCenter(find.byTooltip('Trending')).dx;
      final tabForYouX = tester.getCenter(find.byTooltip('For You')).dx;
      expect(tabClubX, lessThan(tabTrendX));
      expect(tabTrendX, lessThan(tabForYouX));
      expect(find.text('Join Club'), findsOneWidget);
      expect(find.text('New Club'), findsOneWidget);
      expect(find.text('Gabung Secret ID'), findsNothing);
      expect(find.text('+ Club'), findsNothing);
      expect(find.text('Create Basecamp'), findsNothing);
      expect(find.text('Undangan Masuk Coffee Club'), findsOneWidget);
      expect(find.text('Bandung Brewing Collective'), findsOneWidget);
      expect(find.text('Terima & Gabung'), findsOneWidget);
      expect(find.text('Tolak'), findsOneWidget);

      await tester.tap(find.text('Tolak').first);
      await tester.pumpAndSettle();

      expect(fakeCommApi.declinedIds, ['inv-pending-1']);
      expect(find.text('Undangan Masuk Coffee Club'), findsNothing);

      // Seed another invite and verify Terima & Gabung calls acceptInvitation
      fakeCommApi.pendingInvites = [
        ClubMemberInvitation(
          id: 'inv-pending-2',
          communityId: 'club-77',
          communityName: 'Java Pour-Over Lab',
          communitySlug: 'java-pour-over',
          communityDescription: 'Seduh manual bareng',
          privacyLevel: 'PUBLIC',
          membersCount: 8,
          focusTags: const ['V60'],
          inviterId: 'peer-risa-id',
          inviterUsername: 'risa_h',
          inviterDisplayName: 'Risa Hanipah',
          roleGranted: 'BARISTA_MEMBER',
          message: 'Ayo masuk!',
          status: 'PENDING',
          createdAt: DateTime.now(),
        ),
      ];
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SocialExploreAndFeedScreen)),
      );
      container.invalidate(pendingClubInvitationsProvider);
      await tester.pumpAndSettle();

      expect(find.text('Java Pour-Over Lab'), findsOneWidget);
      await tester.tap(find.text('Terima & Gabung'));
      await tester.pumpAndSettle();
      expect(fakeCommApi.acceptedIds, ['inv-pending-2']);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
      await localDb.close();
    });

    testWidgets(
        'NotificationCenterScreen renders Accept & Decline buttons for CLUB_MEMBER_INVITED',
        (tester) async {
      final fakeCommApi = _FakeCommunitiesApiService();
      final fakeNotifApi = _FakeClubNotifApiService();
      final fakeWs = _FakeChatWsStub();
      addTearDown(fakeWs.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            communitiesApiProvider.overrideWithValue(fakeCommApi),
            notificationApiServiceProvider.overrideWithValue(fakeNotifApi),
            chatWsServiceProvider.overrideWithValue(fakeWs),
          ],
          child: const MaterialApp(home: NotificationCenterScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tolak'), findsOneWidget);
      expect(find.text('Terima & Gabung'), findsOneWidget);

      await tester.tap(find.text('Terima & Gabung'));
      await tester.pumpAndSettle();

      expect(fakeCommApi.acceptedIds, ['inv-notif-1']);
      expect(find.text('Bergabung ke Coffee Club ✓'), findsOneWidget);
    });
  });
}

class _FakeProfilesApiService extends SocialProfileApiService {
  _FakeProfilesApiService() : super(Dio());
  bool shouldFailExplore = false;

  @override
  Future<CursorPaginatedResult<ProfileDirectoryEntry>> exploreProfiles({
    String? query,
    String? cursor,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    if (shouldFailExplore) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/social/profiles'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/social/profiles'),
          statusCode: 500,
        ),
        type: DioExceptionType.badResponse,
      );
    }
    return const CursorPaginatedResult(
      items: [
        ProfileDirectoryEntry(
          userId: 'peer-risa-id',
          username: 'risa_h',
          displayName: 'Risa Hanipah',
          bio: 'V60 Enthusiast',
          accountTier: 'Pro',
          totalXp: 320,
          baristaLevel: 6,
          baristaRankTitle: 'Pour-Over Artisan',
          followersCount: 18,
          totalThreadsCount: 5,
          isFollowedByViewer: true,
        ),
        ProfileDirectoryEntry(
          userId: 'peer-budi-id',
          username: 'budi_v60',
          displayName: 'Budi Roaster',
          bio: 'Espresso Fan',
          accountTier: 'Trial',
          totalXp: 100,
          baristaLevel: 2,
          baristaRankTitle: 'Home Brewer',
          followersCount: 4,
          totalThreadsCount: 1,
          isFollowedByViewer: false,
        ),
      ],
      nextCursor: null,
      hasMore: false,
    );
  }
}

class _FakeMutualGraphApiService extends SocialGraphApiService {
  _FakeMutualGraphApiService() : super(Dio());

  @override
  Future<SocialGraphCursorPage<SocialGraphUserItem>> listConnections({
    required String targetUserOrUsername,
    required String kind,
    String? cursor,
    int limit = 20,
  }) async {
    if (kind == 'mutual' || kind == 'following') {
      return SocialGraphCursorPage(
        items: [
          SocialGraphUserItem(
            userId: 'peer-risa-id',
            username: 'risa_h',
            displayName: 'Risa Hanipah',
            baristaLevel: 6,
            baristaRankTitle: 'Pour-Over Artisan',
            accountTier: 'Pro',
            relationshipState: RelationshipState.mutual,
            followedAt: DateTime.utc(2026, 11, 10),
          ),
        ],
        nextCursor: null,
        hasMore: false,
      );
    }
    return const SocialGraphCursorPage(items: [], nextCursor: null, hasMore: false);
  }
}

class _FakeEmptyChatApiService extends ChatApiService {
  _FakeEmptyChatApiService() : super(Dio());

  @override
  Future<List<ChatPeerDto>> searchPeers({String? query, int limit = 25}) async =>
      const [];
}

class _FakeCommunitiesApiService extends CommunitiesApiService {
  _FakeCommunitiesApiService() : super(Dio());

  String? lastCreatedName;
  List<String> lastInvitedUserIds = [];
  final List<String> acceptedIds = [];
  final List<String> declinedIds = [];

  List<ClubMemberInvitation> pendingInvites = [
    ClubMemberInvitation(
      id: 'inv-pending-1',
      communityId: 'club-101',
      communityName: 'Bandung Brewing Collective',
      communitySlug: 'bandung-brewing',
      communityDescription: 'Kalibrasi harian V60',
      privacyLevel: 'RESTRICTED',
      membersCount: 15,
      focusTags: const ['V60', 'Gayo'],
      inviterId: 'peer-risa-id',
      inviterUsername: 'risa_h',
      inviterDisplayName: 'Risa Hanipah',
      roleGranted: 'BARISTA_MEMBER',
      message: 'Masuk basecamp baru yuk!',
      status: 'PENDING',
      createdAt: DateTime.utc(2026, 11, 16, 8, 0),
    ),
  ];

  @override
  Future<DiscoverCommunitiesResponse> discoverCommunities({
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    return const DiscoverCommunitiesResponse(
      myClubs: [],
      discoverClubs: [],
      hasMore: false,
    );
  }

  @override
  Future<CommunityWorkspace> createCommunity({
    required String name,
    String? handleSlug,
    required String description,
    required String privacyLevel,
    List<String> focusTags = const [],
    List<String> invitedUserIds = const [],
    String? inviteMessage,
  }) async {
    lastCreatedName = name;
    lastInvitedUserIds = invitedUserIds;
    return CommunityWorkspace(
      community: CommunitySummary(
        id: 'club-new-1',
        handleSlug: 'gayo-coffee-club',
        name: name,
        description: description,
        privacyLevel: privacyLevel,
        ownerId: 'owner-uuid',
        focusTags: focusTags,
        membersCount: 1,
        threadsCount: 0,
        sharedRecipesCount: 0,
        totalClubXp: 50,
        isMember: true,
        createdAt: DateTime.now(),
      ),
      channels: const [],
      isMember: true,
      canPost: true,
      canManageInvites: true,
    );
  }

  @override
  Future<List<ClubMemberInvitation>> getPendingInvitations() async {
    return List<ClubMemberInvitation>.from(pendingInvites);
  }

  @override
  Future<RespondInvitationResponse> acceptInvitation(String inviteId) async {
    acceptedIds.add(inviteId);
    pendingInvites.removeWhere((i) => i.id == inviteId);
    return RespondInvitationResponse(
      invitationId: inviteId,
      communityId: 'club-77',
      status: 'ACCEPTED',
    );
  }

  @override
  Future<RespondInvitationResponse> declineInvitation(String inviteId) async {
    declinedIds.add(inviteId);
    pendingInvites.removeWhere((i) => i.id == inviteId);
    return RespondInvitationResponse(
      invitationId: inviteId,
      communityId: 'club-101',
      status: 'DECLINED',
    );
  }
}

class _FakeExploreFeedApiService extends ExploreFeedApiService {
  _FakeExploreFeedApiService() : super(Dio());

  @override
  Future<ForYouFeedResponse> getForYouFeed({
    int cursorOffset = 0,
    int limit = 20,
    String? methodFilter,
    bool refresh = false,
  }) async {
    return const ForYouFeedResponse(
      items: [],
      userTopTastes: [],
      nextOffset: null,
      hasMore: false,
    );
  }

  @override
  Future<TrendingFeedResponse> getTrendingFeed({int limit = 25}) async {
    return TrendingFeedResponse(items: const [], updatedAt: DateTime.now());
  }

  @override
  Future<RecommendedClubsResponse> getRecommendedClubs() async {
    return const RecommendedClubsResponse(items: [], userTopTastes: []);
  }
}

class _FakeClubNotifApiService extends NotificationApiService {
  _FakeClubNotifApiService() : super(Dio());

  @override
  Future<NotificationInboxPage> getInbox({
    String category = '',
    String? cursor,
    int limit = 25,
  }) async {
    return NotificationInboxPage(
      unreadCount: 1,
      hasMore: false,
      items: [
        NotificationInboxItem(
          id: 'notif-club-1',
          category: 'SOCIAL_GRAPH',
          eventType: 'CLUB_MEMBER_INVITED',
          title: 'Risa Hanipah mengundangmu ke Coffee Club Java Pour-Over Lab',
          body: '"Gabung ya!"',
          deepLinkPath: '/social/clubs',
          actionPayload: const {
            'entity_id': 'inv-notif-1',
            'conversation_id': 'club-77',
            'action_buttons': ['ACCEPT_CLUB_INVITE', 'DECLINE_CLUB_INVITE'],
          },
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  @override
  Future<int> getUnreadCount() async => 1;

  @override
  Future<int> markAsRead(String notificationId) async => 0;
}

class _FakeChatWsStub extends ChatWsService {
  final ChatDriftDatabase _db;
  _FakeChatWsStub._(this._db) : super(_db, ChatApiService(Dio()));
  factory _FakeChatWsStub() =>
      _FakeChatWsStub._(ChatDriftDatabase(NativeDatabase.memory()));

  @override
  Future<void> connectIfAuthenticated() async {}

  @override
  Stream<ServerPushNotificationEventFrame> get pushNotificationEvents =>
      const Stream<ServerPushNotificationEventFrame>.empty();

  @override
  Future<void> dispose() async {
    await super.dispose();
    await _db.close();
  }
}
