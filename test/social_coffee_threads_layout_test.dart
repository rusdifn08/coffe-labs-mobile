import 'package:coffee_hub_mobile/features/notifications/presentation/controllers/notification_center_controller.dart';
import 'package:coffee_hub_mobile/features/social/widgets/social_community_banner.dart';
import 'package:coffee_hub_mobile/features/social/widgets/social_threads_account_search.dart';
import 'package:coffee_hub_mobile/features/social/widgets/social_threads_bottom_nav_bar.dart';
import 'package:coffee_hub_mobile/features/social/widgets/social_threads_header_widgets.dart';
import 'package:coffee_hub_mobile/features/social_chat/data/services/chat_api_service.dart';
import 'package:coffee_hub_mobile/features/social_chat/domain/chat_protocol.dart';
import 'package:coffee_hub_mobile/features/social_chat/presentation/controllers/chat_controllers.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/data/services/social_profile_api_service.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/domain/models/social_profile_models.dart';
import 'package:coffee_hub_mobile/features/social_profile_feed/presentation/controllers/social_profile_controllers.dart';
import 'package:coffee_hub_mobile/models/social_coffee.dart';
import 'package:coffee_hub_mobile/screens/admin_approval_screen.dart';
import 'package:coffee_hub_mobile/screens/social_coffee_screen.dart';
import 'package:coffee_hub_mobile/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeUnreadCountNotifier extends UnreadNotificationsCountNotifier {
  @override
  int build() => 0;
}

class _FakeSocialProfileApiService extends SocialProfileApiService {
  bool shouldFailExplore = false;
  int exploreCalls = 0;

  _FakeSocialProfileApiService() : super(Dio());

  static const _seedEntries = <ProfileDirectoryEntry>[
    ProfileDirectoryEntry(
      userId: '1de33d23-2fac-42ce-877a-378abbc594df',
      username: 'rusdifn08',
      displayName: 'Admin Rusdi',
      bio: 'Coffee Labs Core',
      accountTier: 'Business',
      totalXp: 500,
      baristaLevel: 10,
      baristaRankTitle: 'Pour-Over Artisan',
      followersCount: 12,
      totalThreadsCount: 4,
      isFollowedByViewer: false,
    ),
    ProfileDirectoryEntry(
      userId: '0bf4f0e5-863b-40b8-9474-255c2169849d',
      username: 'rusdifn088',
      displayName: 'Rusdi The fadli',
      bio: 'V60 Daily Brewer',
      accountTier: 'Trial',
      totalXp: 120,
      baristaLevel: 3,
      baristaRankTitle: 'Home Brewer',
      followersCount: 5,
      totalThreadsCount: 2,
      isFollowedByViewer: false,
    ),
    ProfileDirectoryEntry(
      userId: '5a40c995-d6a6-4595-baa5-ae8120a304f1',
      username: 'aegner01',
      displayName: 'Aegner Billik',
      bio: 'Gayo Explorer',
      accountTier: 'Trial',
      totalXp: 90,
      baristaLevel: 2,
      baristaRankTitle: 'Home Brewer',
      followersCount: 3,
      totalThreadsCount: 1,
      isFollowedByViewer: false,
    ),
  ];

  @override
  Future<CursorPaginatedResult<ProfileDirectoryEntry>> exploreProfiles({
    String? query,
    String? cursor,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    exploreCalls++;
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
    final clean = SocialProfileApiService.normalizeDirectoryQuery(query);
    final matched = _seedEntries.where((e) {
      if (clean.isEmpty) return true;
      return e.username.toLowerCase().contains(clean) ||
          e.displayName.toLowerCase().contains(clean);
    }).toList();
    for (final m in matched) {
      _fakeCache[m.userId] = m;
    }
    return CursorPaginatedResult(
      items: matched,
      nextCursor: null,
      hasMore: false,
    );
  }

  final Map<String, ProfileDirectoryEntry> _fakeCache = {};

  @override
  List<ProfileDirectoryEntry> searchCachedProfiles(String? rawQuery) {
    final clean = SocialProfileApiService.normalizeDirectoryQuery(rawQuery);
    return _fakeCache.values.where((e) {
      if (clean.isEmpty) return true;
      return e.username.toLowerCase().contains(clean) ||
          e.displayName.toLowerCase().contains(clean);
    }).toList();
  }

  @override
  Future<FollowToggleResult> toggleFollow(String targetUserOrUsername) async {
    return FollowToggleResult(
      targetUserId: targetUserOrUsername,
      isFollowedByViewer: true,
      followersCount: 6,
    );
  }
}

List<SocialPost> _samplePosts() => [
      SocialPost(
        id: 'p1',
        userId: 'u1',
        authorName: 'rusdifn08',
        authorAvatar: 'assets/images/characters/avatar_1.png',
        authorRole: 'Barista',
        content: 'Halo Ini Aegner, ekstraksi manis V60 multi-pour.',
        recipeId: 101,
        recipeSnapshot: const {
          'id': 101,
          'title': 'Metode Multi-Pour Neo Brew (2026)',
          'method': 'Hario V60 / Neo',
          'coffeeWeightGrams': 20,
          'totalWaterWeightGrams': 300,
          'waterTempCelsius': 92,
          'tastingNotes': 'Balanced Sweetness, Clean Acidity',
        },
        likesCount: 12,
        commentsCount: 3,
        copiesCount: 4,
        tags: const ['V60', 'PourOver'],
        isLikedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SocialPost(
        id: 'p2',
        userId: 'u2',
        authorName: 'Ryan Wibawa',
        authorAvatar: 'assets/images/characters/avatar_2.png',
        authorRole: 'Indonesian Barista Champion',
        content: 'Pagi ini coba Gayo natural suhu 91C, aroma floral kuat banget.',
        likesCount: 45,
        commentsCount: 0,
        copiesCount: 0,
        tags: const ['GayoWine'],
        isLikedByMe: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      ),
      SocialPost(
        id: 'p3',
        userId: 'u3',
        authorName: 'adefauziahp',
        authorAvatar: 'assets/images/characters/avatar_3.png',
        authorRole: 'Home Brewer',
        content: 'Seduhan pagi pakai V60 02 tetap manis.',
        likesCount: 8,
        commentsCount: 0,
        copiesCount: 0,
        tags: const ['V60'],
        isLikedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
    ];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'coffeehub_user_name': 'rusdifn08',
    });
  });

  testWidgets(
    'SocialCoffeeScreen uses Threads layout, warm Coffee Labs colors, bottom navbar, left back to Coffee Labs, and right 2-line sidebar',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (rootCtx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(rootCtx).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            SocialCoffeeScreen(initialPosts: _samplePosts()),
                      ),
                    );
                  },
                  child: const Text('Open Social'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Social'));
      await tester.pumpAndSettle();

      // 1. Warm Cream theme preserved & zero overflow
      expect(tester.takeException(), isNull);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, AppTheme.bgCream);

      // 2. Top AppBar: Back on Left, Messenger icon & 2-line Sidebar toggle on Right
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppTheme.bgCream);

      final backFinder = find.byTooltip('Kembali ke Coffee Labs');
      final messengerFinder = find.byTooltip('Pesan Barista');
      final menuFinder = find.byTooltip('Menu Sidebar');
      expect(backFinder, findsOneWidget);
      expect(messengerFinder, findsOneWidget);
      expect(menuFinder, findsOneWidget);
      expect(find.byType(ThreadsMessengerIcon), findsOneWidget);
      expect(find.byType(ThreadsTwoLineMenuIcon), findsOneWidget);

      final backCenter = tester.getCenter(backFinder);
      final messengerCenter = tester.getCenter(messengerFinder);
      final menuCenter = tester.getCenter(menuFinder);
      final titleTextFinder = find.text('Social Coffee');
      expect(titleTextFinder, findsOneWidget);
      final titleRect = tester.getRect(titleTextFinder);
      // Teks judul tepat di tengah layar (390 / 2 = 195) dan tidak terpotong
      expect((titleRect.center.dx - 195.0).abs(), lessThan(1.5));
      final emblemFinder = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/images/coffee_labs_emblem.png',
      );
      expect(emblemFinder, findsOneWidget);
      final emblemRect = tester.getRect(emblemFinder);
      expect(emblemRect.right, lessThanOrEqualTo(titleRect.left));
      expect(backCenter.dx, lessThan(emblemRect.left));
      expect(titleRect.right, lessThan(messengerCenter.dx));
      expect(messengerCenter.dx, lessThan(menuCenter.dx));

      // Uji responsif juga di layar ponsel sempit 360px -> judul utuh tanpa overflow
      final textWidget = tester.widget<Text>(titleTextFinder);
      expect(textWidget.data, 'Social Coffee');

      // 3. No old stacked card banners & no floating action button
      expect(find.byType(SocialCommunityBanner), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(SocialThreadsComposerHeader), findsOneWidget);
      expect(
        find.text('Apa yang baru? Bagikan teknik seduh atau resep...'),
        findsOneWidget,
      );

      // 4. Bottom Navigation Bar present with 5 items including center '+'
      expect(find.byType(SocialThreadsBottomNavBar), findsOneWidget);
      expect(find.byTooltip('Buat Postingan Baru'), findsOneWidget);

      // 5. Feed posts rendered cleanly without cards, role badge strictly below author name, & filter tabs work
      expect(find.text('rusdifn08'), findsAtLeastNWidgets(1));
      expect(find.text('Ryan Wibawa'), findsOneWidget);
      expect(find.text('Indonesian Barista Champion'), findsOneWidget);
      final authorRect = tester.getRect(find.text('Ryan Wibawa'));
      final roleRect = tester.getRect(find.text('Indonesian Barista Champion'));
      expect(authorRect.width, greaterThan(40));
      expect(roleRect.top, greaterThanOrEqualTo(authorRect.bottom - 1));
      expect(find.text('Lihat 3 balasan'), findsOneWidget);

      await tester.tap(find.text('Resep Kopi'));
      await tester.pumpAndSettle();
      expect(find.text('Metode Multi-Pour Neo Brew (2026)'), findsOneWidget);
      expect(find.text('Ryan Wibawa'), findsNothing);

      // 6. Tapping bottom Search focuses on Coffee Labs Account Search (other accounts) & offers Postingan & Jelajah
      await tester.tap(find.byTooltip('Cari & Explore'));
      await tester.pumpAndSettle();
      expect(find.text('Cari Akun'), findsOneWidget);
      expect(find.text('Akun Coffee Labs'), findsOneWidget);
      expect(find.text('rusdifn08'), findsNothing);
      expect(find.text('Ryan Wibawa'), findsOneWidget);
      expect(find.text('adefauziahp'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Ryan');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('Ryan Wibawa'), findsOneWidget);
      expect(find.text('adefauziahp'), findsNothing);

      await tester.tap(find.byIcon(CupertinoIcons.clear_circled_solid));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Postingan & Jelajah'));
      await tester.pumpAndSettle();
      expect(find.text('For You, Trending & Coffee Club'), findsOneWidget);
      expect(find.text('Coffee Club'), findsOneWidget);

      await tester.tap(find.byTooltip('Aktivitas & Obrolan'));
      await tester.pumpAndSettle();
      expect(find.text('Aktivitas'), findsNWidgets(2));
      expect(find.text('Obrolan Barista'), findsOneWidget);

      await tester.tap(find.byTooltip('Profil Barista Saya'));
      await tester.pumpAndSettle();
      expect(find.text('Profil Lengkap & Rank'), findsOneWidget);

      // 7. Right 2-line menu opens endDrawer from right side
      await tester.tap(menuFinder);
      await tester.pumpAndSettle();
      expect(find.byType(SocialThreadsEndDrawer), findsOneWidget);
      expect(find.text('Direct & Group Chat Barista'), findsOneWidget);

      // Close drawer by tapping back inside drawer or outside, then test left Back button
      await tester.tapAt(const Offset(20, 400));
      await tester.pumpAndSettle();
      await tester.tap(backFinder);
      await tester.pumpAndSettle();
      expect(find.text('Open Social'), findsOneWidget);
    },
  );

  testWidgets(
    'Live ProviderScope account search uses instant SWR cache, optimistic follow without N+1 storm, and zero hang on HTTP 500',
    (tester) async {
      final fakeApi = _FakeSocialProfileApiService();
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            socialProfileApiServiceProvider.overrideWithValue(fakeApi),
            unreadNotificationsCountProvider.overrideWith(
              () => _FakeUnreadCountNotifier(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: SocialCoffeeScreen(initialPosts: _samplePosts()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Search tab -> initial empty query shows peers & hides self
      await tester.tap(find.byTooltip('Cari & Explore'));
      await tester.pumpAndSettle();
      expect(find.byType(SocialThreadsAccountSearchView), findsOneWidget);
      expect(find.text('Rusdi The fadli'), findsOneWidget);
      expect(find.text('Aegner Billik'), findsOneWidget);
      expect(find.text('Admin Rusdi'), findsNothing);
      expect(fakeApi.exploreCalls, 1);

      // Tap 'Ikuti' -> optimistic update without N+1 calls
      await tester.tap(find.text('Ikuti').first);
      await tester.pumpAndSettle();
      expect(find.text('Mengikuti'), findsOneWidget);

      // Search explicit handle 'rusdifn08' while backend errors with 500 -> NO infinite spinner, instant cache + self badge!
      fakeApi.shouldFailExplore = true;
      await tester.enterText(find.byType(TextField), 'rusdifn08');
      await tester.pump();
      // Immediately shows cached L1 match without waiting for network retry!
      expect(find.text('Rusdi The fadli'), findsOneWidget);
      expect(find.text('Admin Rusdi'), findsOneWidget);
      expect(find.text('Akun Anda'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 220));
      await tester.pumpAndSettle();
      expect(find.text('Menampilkan data cache lokal'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'Cari Akun finds newly registered users like kiyam via chat/peers fallback without Buka Directory Lengkap overflow',
    (tester) async {
      final failingProfileApi = _FakeSocialProfileApiService()
        ..shouldFailExplore = true;
      final fakeChatPeersApi = _FakeKiyamChatApiService();
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            socialProfileApiServiceProvider
                .overrideWithValue(failingProfileApi),
            chatApiServiceProvider.overrideWithValue(fakeChatPeersApi),
            unreadNotificationsCountProvider.overrideWith(
              () => _FakeUnreadCountNotifier(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: SocialCoffeeScreen(initialPosts: _samplePosts()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Cari & Explore'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'kiyam');
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('kiyam'), findsAtLeastNWidgets(1));
      expect(find.textContaining('@kiyam'), findsOneWidget);
      expect(find.text('Buka Directory Lengkap'), findsNothing);

      // Search non-existent user -> clean empty state without overflow or Buka Directory Lengkap button
      await tester.enterText(find.byType(TextField), 'tidakada999');
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Buka Directory Lengkap'), findsNothing);
      expect(find.text('Muat Ulang'), findsOneWidget);
    },
  );

  testWidgets(
    'AdminApprovalScreen tabs render without overflow at 390px phone width',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminApprovalScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.text('Manajemen Pengguna'), findsOneWidget);
      expect(find.text('Baru'), findsOneWidget);
    },
  );
}

class _FakeKiyamChatApiService extends ChatApiService {
  _FakeKiyamChatApiService() : super(Dio());

  @override
  Future<List<ChatPeerDto>> searchPeers({String? query, int limit = 25}) async {
    final clean = (query ?? '').trim().toLowerCase();
    const kiyam = ChatPeerDto(
      id: 'uuid-kiyam-1',
      username: 'kiyam',
      fullName: 'kiyam',
      role: 'user',
    );
    if (clean.isEmpty || 'kiyam'.contains(clean)) {
      return const [kiyam];
    }
    return const [];
  }
}
