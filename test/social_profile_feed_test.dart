import 'package:coffee_hub_mobile/core/network/dio_client.dart';
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
import 'package:coffee_hub_mobile/features/social_profile_feed/domain/models/social_thread_models.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/presentation/controllers/social_profile_controllers.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/presentation/screens/social_user_profile_screen.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/presentation/widgets/barista_rank_showcase_header.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/presentation/widgets/live_or_recent_brew_spotlight_card.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/presentation/widgets/thread_pouring_curve_card.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/presentation/widgets/thread_post_card.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/presentation/widgets/thread_recipe_attachment_card.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/presentation/widgets/thread_scanned_bean_badge.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Modul 3.2 Domain Models', () {
    test('MaterializedProfileView computes rank accent & tier gradients', () {
      const trialProfile = MaterializedProfileView(
        userId: 'u-1',
        username: 'barista_a',
        displayName: 'Barista A',
        accountTier: 'Trial',
        baristaLevel: 12,
      );
      expect(trialProfile.rankAccentColor, const Color(0xFF94A3B8));
      expect(trialProfile.tierRingGradient.length, 2);

      const proProfile = MaterializedProfileView(
        userId: 'u-2',
        username: 'pro_brewer',
        displayName: 'Pro Brewer',
        accountTier: 'Pro',
        baristaLevel: 30,
      );
      expect(proProfile.rankAccentColor, const Color(0xFFD4AF37));
      expect(proProfile.tierRingGradient, const [
        Color(0xFFFDE68A),
        Color(0xFFD4AF37),
        Color(0xFFB45309),
      ]);

      const bizProfile = MaterializedProfileView(
        userId: 'u-3',
        username: 'champ_roaster',
        displayName: 'Champion Roaster',
        accountTier: 'Business',
        baristaLevel: 85,
      );
      expect(bizProfile.rankAccentColor, const Color(0xFFA78BFA));
      expect(bizProfile.tierRingGradient.length, 3);
    });

    test('ThreadAttachment roundtrips all 3 tagged wire JSON variants', () {
      const recipe = ThreadAttachment.interactiveRecipeCard(
        recipeId: 'wbrc-2024',
        title: 'Ryan Wibawa Bhineka',
        brewerName: 'Ryan Wibawa',
        method: 'V60',
        coffeeDoseG: 15,
        totalWaterMl: 240,
        primaryTempC: 93,
        secondaryTempC: 88,
        targetDurationSec: 150,
        stepsPreview: [
          RecipeStepMiniDto(
            stepNumber: 1,
            title: 'Bloom',
            durationSec: 40,
            waterAddedMl: 45,
          ),
        ],
      );
      final parsedRecipe = ThreadAttachment.tryFromWireJson(recipe.toWireJson());
      expect(parsedRecipe, isA<InteractiveRecipeCardAttachment>());
      expect(
        (parsedRecipe as InteractiveRecipeCardAttachment).title,
        'Ryan Wibawa Bhineka',
      );

      const curve = ThreadAttachment.pouringTelemetryCurve(
        sessionId: 'sess-99',
        recipeTitle: 'Switch Hybrid',
        beanName: 'Halu Banana',
        accuracyScorePct: 96.4,
        totalDurationSec: 140,
        curvePoints: [
          PourCurvePoint(tSec: 0, actualMl: 0, targetMl: 0, tempC: 93),
          PourCurvePoint(tSec: 40, actualMl: 42, targetMl: 40, tempC: 92),
        ],
      );
      final parsedCurve = ThreadAttachment.tryFromWireJson(curve.toWireJson());
      expect(parsedCurve, isA<PouringTelemetryCurveAttachment>());
      expect(
        (parsedCurve as PouringTelemetryCurveAttachment).accuracyScorePct,
        96.4,
      );

      const bean = ThreadAttachment.scannedCoffeeBagTag(
        classSlug: 'fugol_halubanana_wine',
        roastery: 'Fugol Coffee Roasters',
        beanName: 'Halu Banana Wine',
        origin: 'Jawa Barat',
        process: 'Anaerobic Natural',
        altitudeMasl: '1500 mdpl',
        tastingNotes: ['Banana', 'Caramel', 'Winey'],
        confidencePct: 98.5,
      );
      final parsedBean = ThreadAttachment.tryFromWireJson(bean.toWireJson());
      expect(parsedBean, isA<ScannedCoffeeBagTagAttachment>());
      expect(
        (parsedBean as ScannedCoffeeBagTagAttachment).tastingNotes,
        contains('Banana'),
      );

      expect(
        ThreadAttachment.tryFromWireJson({'type': 'unknown', 'data': {}}),
        isNull,
      );
    });
  });

  group('Modul 3.2 Showcase & Feed Widgets', () {
    testWidgets('BaristaRankShowcaseHeader displays XP, badges & actions', (
      tester,
    ) async {
      var followedTapped = false;
      var followersListTapped = false;

      final profile = MaterializedProfileView(
        userId: 'u-champ',
        username: 'hendri_v60',
        displayName: 'Hendri Kurniawan',
        bio: 'Pour-over enthusiast • Comandante 22 klik',
        accountTier: 'Pro',
        totalXp: 4250,
        baristaLevel: 26,
        baristaRankTitle: 'Precision Pourer',
        levelProgressRatio: 0.65,
        nextLevelXp: 5000,
        currentStreakDays: 14,
        unlockedBadgeIds: const [1, 2, 3, 4],
        topFeaturedBadges: const [
          BaristaBadgeItem(
            id: 1,
            slug: 'bloom_master',
            title: 'Bloom Master',
            rarity: 'RARE',
          ),
        ],
        followersCount: 128,
        followingCount: 42,
        totalBrewsCount: 89,
        totalRecipeTriesReceived: 310,
        isFollowingViewer: true,
        isFollowedByViewer: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BaristaRankShowcaseHeader(
                profile: profile,
                onToggleFollow: () => followedTapped = true,
                onMessagePeer: () {},
                onEditProfile: () {},
                onTapFollowers: () => followersListTapped = true,
                onTapFollowing: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Hendri Kurniawan'), findsOneWidget);
      expect(find.text('@hendri_v60'), findsOneWidget);
      expect(find.text('Mengikuti Anda'), findsOneWidget);
      expect(find.text('Lv.26'), findsOneWidget);
      expect(find.text('Precision Pourer'), findsOneWidget);
      expect(find.text('14h Streak'), findsOneWidget);
      expect(find.text('4250 XP (65% ke Lv.27)'), findsOneWidget);
      expect(find.text('4 Lencana'), findsOneWidget);
      expect(find.text('Bloom Master'), findsOneWidget);
      expect(find.text('310x'), findsOneWidget);

      await tester.tap(find.text('Ikuti'));
      await tester.pump();
      expect(followedTapped, isTrue);

      await tester.tap(find.text('Pengikut'));
      await tester.pump();
      expect(followersListTapped, isTrue);
    });

    testWidgets('LiveOrRecentBrewSpotlightCard renders live status & CTA', (
      tester,
    ) async {
      var tried = false;
      final snap = RecentBrewSnapshot(
        recipeId: '1',
        recipeTitle: 'Tetsu 4:6 V60',
        beanName: 'Argopuro Walida',
        roastery: 'Space Roastery',
        process: 'Natural',
        method: 'V60',
        primaryTempC: 92,
        secondaryTempC: 88,
        coffeeDoseG: 15,
        totalWaterMl: 225,
        targetDurationSec: 210,
        brewedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        isLive: true,
        accuracyScore: 95.8,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveOrRecentBrewSpotlightCard(
              snapshot: snap,
              onTryExactBrew: () => tried = true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('LIVE BREWING NOW'), findsOneWidget);
      expect(find.text('Argopuro Walida • Space Roastery'), findsOneWidget);
      expect(find.text('Presisi 95.8%'), findsOneWidget);

      await tester.tap(find.text('Ikut Seduh Resep Ini'));
      await tester.pump();
      expect(tried, isTrue);
    });

    testWidgets(
      'ThreadPostCard renders attachments and fires like/repost/tryRecipe callbacks',
      (tester) async {
        var liked = false;
        var reposted = false;
        String? triedRecipeId;

        const recipeCard = ThreadAttachment.interactiveRecipeCard(
          recipeId: 'rec-42',
          title: 'Hario Switch 3-Pour Hybrid',
          brewerName: 'Bayu Prawiro',
          method: 'Switch',
          coffeeDoseG: 15,
          totalWaterMl: 220,
          primaryTempC: 93,
          secondaryTempC: 88,
          targetDurationSec: 140,
          stepsPreview: [
            RecipeStepMiniDto(
              stepNumber: 1,
              title: 'Bloom Buka',
              durationSec: 40,
              waterAddedMl: 40,
            ),
          ],
        );

        final item = SocialThreadItem(
          id: 'th-1',
          authorId: 'u-1',
          authorUsername: 'bayu_prawiro',
          authorDisplayName: 'Bayu Prawiro',
          authorBaristaLevel: 60,
          authorBaristaRankTitle: 'World Recipe Architect',
          kind: 'CREATED_RECIPE',
          bodyText: 'Seduhan hybrid dual temperature pagi ini super manis!',
          rawAttachment: recipeCard.toWireJson(),
          likesCount: 24,
          repliesCount: 5,
          repostsCount: 3,
          tryRecipeCount: 19,
          isPinnedOnProfile: true,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    ThreadPostCard(
                      thread: item,
                      onTapThread: () {},
                      onTapAuthor: () {},
                      onToggleLike: () => liked = true,
                      onToggleRepost: () => reposted = true,
                      onTryRecipe: (c) => triedRecipeId = c.recipeId,
                    ),
                    const SizedBox(height: 12),
                    const ThreadPouringCurveCard(
                      telemetry: PouringTelemetryCurveAttachment(
                        sessionId: 's-1',
                        recipeTitle: 'V60 Precision',
                        beanName: 'Kintamani Washed',
                        accuracyScorePct: 97.2,
                        totalDurationSec: 150,
                        curvePoints: [
                          PourCurvePoint(
                            tSec: 0,
                            actualMl: 0,
                            targetMl: 0,
                            tempC: 92,
                          ),
                          PourCurvePoint(
                            tSec: 150,
                            actualMl: 240,
                            targetMl: 240,
                            tempC: 90,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const ThreadScannedBeanBadge(
                      bean: ScannedCoffeeBagTagAttachment(
                        classSlug: 'halu_banana',
                        roastery: 'Fugol',
                        beanName: 'Halu Banana',
                        origin: 'Garut',
                        process: 'Natural',
                        altitudeMasl: '1500 mdpl',
                        tastingNotes: ['Banana', 'Caramel'],
                        confidencePct: 99,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Disematkan di Profil'), findsOneWidget);
        expect(find.text('Hario Switch 3-Pour Hybrid'), findsOneWidget);
        expect(find.text('Try This Recipe (Dipakai 19x)'), findsOneWidget);
        expect(find.text('97.2% Akurasi'), findsOneWidget);
        expect(find.text('Fugol • Halu Banana'), findsOneWidget);

        await tester.tap(find.text('Try This Recipe (Dipakai 19x)'));
        await tester.pump();
        expect(triedRecipeId, 'rec-42');

        await tester.tap(find.text('24'));
        await tester.pump();
        expect(liked, isTrue);

        await tester.tap(find.text('3'));
        await tester.pump();
        expect(reposted, isTrue);
      },
    );

    testWidgets('ThreadRecipeAttachmentCard computes ratio formatting', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreadRecipeAttachmentCard(
              card: const InteractiveRecipeCardAttachment(
                recipeId: 'rec-1',
                title: 'Clean Kalita',
                brewerName: 'Tetsu',
                method: 'Kalita',
                coffeeDoseG: 15,
                totalWaterMl: 240,
                primaryTempC: 91,
                targetDurationSec: 165,
              ),
              tryCount: 7,
              onTryRecipe: () {},
            ),
          ),
        ),
      );

      expect(find.text('Tetsu • Kalita • Rasio 1:16.0'), findsOneWidget);
      expect(find.text('2:45'), findsOneWidget);
    });

    test('SocialProfileApiService caches profile and maps HTTP 500 to friendly ApiException',
        () async {
      final dio = Dio();
      var serverHits = 0;
      var return500 = false;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            serverHits++;
            if (return500) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 500,
                    data: {'message': 'Server gangguan sementara.'},
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            }
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': {
                    'user_id': 'u-risaha15',
                    'username': 'risaha15',
                    'display_name': 'Risa Hanipah',
                    'bio': 'V60 Enthusiast',
                    'barista_level': 8,
                    'followers_count': 12,
                  },
                },
              ),
            );
          },
        ),
      );

      final api = SocialProfileApiService(dio);
      final p1 = await api.getProfile('risaha15');
      expect(p1.username, 'risaha15');
      expect(serverHits, 1);

      // L1 cache hit avoids redundant HTTP call
      final p2 = await api.getProfile('@risaha15');
      expect(p2.displayName, 'Risa Hanipah');
      expect(serverHits, 1);

      // Force refresh returning 500 while cached -> stale fallback survives cleanly!
      return500 = true;
      final stale = await api.getProfile('risaha15', forceRefresh: true);
      expect(stale.username, 'risaha15');

      // Unknown uncached target with 500 -> clean ApiException without developer.mozilla URL
      await expectLater(
        () => api.getProfile('other_user'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Server gangguan sementara.',
          ),
        ),
      );
    });

    testWidgets(
      'SocialUserProfileScreen recovers cleanly from transient error and displays @risaha15 profile & mutual status',
      (tester) async {
        final fakeProfileApi = _FakeRisahaProfileApi()..failOnce = true;
        final fakeGraphApi = _FakeRisahaGraphApi();
        final fakeWs = _FakeProfileWsStub();
        addTearDown(fakeWs.dispose);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              socialProfileApiServiceProvider.overrideWithValue(fakeProfileApi),
              socialGraphApiServiceProvider.overrideWithValue(fakeGraphApi),
              chatWsServiceProvider.overrideWithValue(fakeWs),
            ],
            child: const MaterialApp(
              home: SocialUserProfileScreen(targetUserOrUsername: 'risaha15'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Terjadi gangguan internal'), findsOneWidget);
        expect(find.textContaining('developer.mozilla.org'), findsNothing);

        await tester.tap(find.text('Coba Lagi'));
        await tester.pumpAndSettle();

        expect(find.text('@risaha15'), findsAtLeastNWidgets(1));
        expect(find.text('Risa Hanipah'), findsOneWidget);
        expect(find.text('Teman Mutual'), findsOneWidget);
      },
    );
  });
}

class _FakeRisahaProfileApi extends SocialProfileApiService {
  _FakeRisahaProfileApi() : super(Dio());
  bool failOnce = false;

  @override
  Future<MaterializedProfileView> getProfile(
    String targetUserOrUsername, {
    bool forceRefresh = false,
  }) async {
    if (failOnce) {
      failOnce = false;
      throw const ApiException(
        message: 'Terjadi gangguan internal pada server Rust (500).',
        statusCode: 500,
      );
    }
    return const MaterializedProfileView(
      userId: 'u-risaha15',
      username: 'risaha15',
      displayName: 'Risa Hanipah',
      bio: 'V60 & Japanese Iced Coffee',
      accountTier: 'Pro',
      baristaLevel: 8,
      baristaRankTitle: 'Home Brewer',
      followersCount: 15,
      followingCount: 10,
      isFollowedByViewer: true,
      isFollowingViewer: true,
    );
  }

  @override
  Future<CursorPaginatedResult<SocialThreadItem>> getProfileTabThreads({
    required String targetUserOrUsername,
    required ProfileFeedTab tab,
    String? cursor,
    int limit = 20,
  }) async {
    return const CursorPaginatedResult(
      items: [],
      nextCursor: null,
      hasMore: false,
    );
  }
}

class _FakeRisahaGraphApi extends SocialGraphApiService {
  _FakeRisahaGraphApi() : super(Dio());

  @override
  Future<RelationshipSnapshot> getRelationshipSnapshot(
    String targetUserOrUsername,
  ) async {
    return const RelationshipSnapshot(
      targetUserId: 'u-risaha15',
      state: RelationshipState.mutual,
      isMutual: true,
      isFollowedByTarget: true,
      followersCount: 15,
      followingCount: 10,
    );
  }
}

class _FakeProfileWsStub extends ChatWsService {
  final ChatDriftDatabase _db;
  _FakeProfileWsStub._(this._db) : super(_db, ChatApiService(Dio()));
  factory _FakeProfileWsStub() =>
      _FakeProfileWsStub._(ChatDriftDatabase(NativeDatabase.memory()));

  @override
  Future<void> connectIfAuthenticated() async {}

  @override
  Stream<ServerSocialGraphEventFrame> get socialGraphEvents =>
      const Stream<ServerSocialGraphEventFrame>.empty();

  @override
  Future<void> dispose() async {
    await super.dispose();
    await _db.close();
  }
}
