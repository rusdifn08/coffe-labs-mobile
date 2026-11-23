import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffee_hub_mobile/core/storage/user_scoped_storage.dart';
import 'package:coffee_hub_mobile/features/gamification/services/gamification_service.dart';
import 'package:coffee_hub_mobile/services/api_service.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:coffee_hub_mobile/services/profile_service.dart';
import 'package:coffee_hub_mobile/widgets/user_avatar_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _simulateLoginSession({
  required String id,
  required String username,
  required String fullName,
  required String avatarUrl,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final user = AuthUser(
    id: id,
    username: username,
    fullName: fullName,
    role: 'user',
    status: 'approved',
    tier: 'pro',
    avatarUrl: avatarUrl,
  );
  await AuthService.persistSessionMirrors(
    prefs,
    user: user,
    token: 'mock_token_$id',
  );
  UserScopedStorage.setActiveUserId(user.id);
  ApiService.clearMemoryCache();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    UserScopedStorage.resetForTesting();
    ApiService.clearMemoryCache();
  });

  group('Multi-Tenant Per-User Data Isolation', () {
    test('Switching users on the same device isolates EXP, Level, Brew History, Favorites, Journal, Custom Recipes, and Avatar', () async {
      // 1. Akun A (Admin Rusdi) login & memiliki progres Lv.4 + riwayat seduh + favorit + resep custom + avatar
      await _simulateLoginSession(
        id: '11111111-1111-1111-1111-111111111111',
        username: 'rusdifn08',
        fullName: 'Admin Rusdi',
        avatarUrl: 'https://res.cloudinary.com/demo/image/upload/rusdi.jpg',
      );
      await GamificationService.instance.setLevelStats(
        exp: 1720,
        brews: 2,
        cupping: 1,
        toolkit: 71,
        streak: 4,
      );
      await ProfileService.setUserName('Admin Rusdi');
      await ProfileService.setUserImagePath(
        'https://res.cloudinary.com/demo/image/upload/rusdi.jpg',
      );
      await ApiService.recordBrew({
        'id': 100,
        'title': 'V60 Ethiopian Geisha Rusdi',
        'author': 'Admin Rusdi',
      });
      await ApiService.toggleFavorite(100);
      await ApiService.addJournalEntry({'coffeeName': 'Geisha Rusdi', 'rating': 5});
      await ApiService.createRecipe({'title': 'Resep Khusus Rusdi', 'author': 'Admin Rusdi'});

      final statsA = await GamificationService.instance.getStats();
      expect(statsA.totalExp, 1720);
      expect(statsA.level.level, 4);
      expect(statsA.toolkitCount, 71);
      expect((await ApiService.getBrewHistory()).length, 1);
      expect(await ApiService.getFavoriteIds(), contains(100));
      expect((await ApiService.getJournalEntries()).length, 1);

      // 2. Akun A logout -> Akun B (Risa Hanipah) login di HP yang SAMA
      await AuthService.logout();
      expect(UserScopedStorage.isGuestScope, isTrue);

      await _simulateLoginSession(
        id: '22222222-2222-2222-2222-222222222222',
        username: 'risaha15',
        fullName: 'Risa Hanipah',
        avatarUrl: 'assets/images/characters/avatar_7.png',
      );
      await ProfileService.applyCloudProfile(
        userId: '22222222-2222-2222-2222-222222222222',
        fullName: 'Risa Hanipah',
        avatarUrl: 'assets/images/characters/avatar_7.png',
      );

      // Verifikasi ZERO BLEED: Akun B mulai dari Lv.1 (25 EXP starter streak), 0 Toolkit, 0 History, 0 Favorit, avatar sendiri
      final statsBInitial = await GamificationService.instance.getStats();
      expect(statsBInitial.totalExp, 25);
      expect(statsBInitial.level.level, 1);
      expect(statsBInitial.toolkitCount, 0);
      expect(statsBInitial.brewsCount, 0);
      expect(await ApiService.getBrewHistory(), isEmpty);
      expect(await ApiService.getFavoriteIds(), isEmpty);
      expect(await ApiService.getJournalEntries(), isEmpty);
      expect(await ProfileService.getUserName(), 'Risa Hanipah');
      expect(
        await ProfileService.getUserImagePath(),
        'assets/images/characters/avatar_7.png',
      );

      // Akun B membuat aktivitas sendiri
      await GamificationService.instance.recordBrewCompleted(hasRating: true);
      await ApiService.toggleFavorite(105);
      final statsBAfter = await GamificationService.instance.getStats();
      expect(statsBAfter.brewsCount, 1);
      expect(statsBAfter.totalExp, greaterThanOrEqualTo(65));

      // 3. Logout Akun B -> Login kembali Akun A: seluruh progres Akun A utuh & tidak tercampur Akun B
      await AuthService.logout();
      await _simulateLoginSession(
        id: '11111111-1111-1111-1111-111111111111',
        username: 'rusdifn08',
        fullName: 'Admin Rusdi',
        avatarUrl: 'https://res.cloudinary.com/demo/image/upload/rusdi.jpg',
      );

      final statsARestored = await GamificationService.instance.getStats();
      expect(statsARestored.totalExp, 1720);
      expect(statsARestored.level.level, 4);
      expect(statsARestored.toolkitCount, 71);
      expect(await ApiService.getFavoriteIds(), equals({100}));
      expect((await ApiService.getBrewHistory()).first['title'], 'V60 Ethiopian Geisha Rusdi');
      expect(
        await ProfileService.getUserImagePath(),
        'https://res.cloudinary.com/demo/image/upload/rusdi.jpg',
      );
    });

    test('Legacy unscoped SharedPreferences keys never contaminate a newly logged-in user', () async {
      SharedPreferences.setMockInitialValues({
        'gamification_total_exp_v2': 9999,
        'gamification_toolkit_count': 71,
        'coffeehub_history_v3': json.encode([{'id': 1, 'title': 'Legacy Leak'}]),
        'coffeehub_user_image': 'assets/images/characters/avatar_9.png',
      });
      UserScopedStorage.resetForTesting();
      ApiService.clearMemoryCache();

      await _simulateLoginSession(
        id: '33333333-3333-3333-3333-333333333333',
        username: 'barista_baru',
        fullName: 'Barista Baru',
        avatarUrl: 'assets/images/characters/avatar_2.png',
      );
      await ProfileService.applyCloudProfile(
        userId: '33333333-3333-3333-3333-333333333333',
        fullName: 'Barista Baru',
        avatarUrl: 'assets/images/characters/avatar_2.png',
      );

      final stats = await GamificationService.instance.getStats();
      expect(stats.totalExp, 25);
      expect(stats.toolkitCount, 0);
      expect(await ApiService.getBrewHistory(), isEmpty);
      expect(
        await ProfileService.getUserImagePath(),
        'assets/images/characters/avatar_2.png',
      );
    });

    test('Cloud snapshot hydration restores full user state on a brand-new phone', () async {
      const uid = '44444444-4444-4444-4444-444444444444';
      await _simulateLoginSession(
        id: uid,
        username: 'lintas_hp',
        fullName: 'Lintas HP Barista',
        avatarUrl: 'https://res.cloudinary.com/demo/image/upload/f_auto,q_auto/barista.png',
      );

      await GamificationService.instance.applyCloudSnapshot(
        userId: uid,
        totalExp: 2450,
        brewsCount: 22,
        toolkitCount: 18,
        cuppingCount: 9,
        streakDays: 6,
        lastActivityDate: '2026-11-23',
      );
      await ApiService.applyCloudCollections(
        userId: uid,
        brewHistory: [
          {'id': 100, 'title': 'Cloud Synced Brew', 'brewedAt': '2026-11-23T08:00:00Z'},
        ],
        brewJournal: [
          {'id': 9001, 'coffeeName': 'Gayo Honey', 'rating': 5},
        ],
        favoriteRecipeIds: const [100, 102],
        customRecipes: [
          {'id': 777, 'title': 'Cloud Custom V60', 'isCustom': true},
        ],
        deletedDefaultIds: const [],
      );
      await ProfileService.applyCloudProfile(
        userId: uid,
        fullName: 'Lintas HP Barista',
        avatarUrl: 'https://res.cloudinary.com/demo/image/upload/f_auto,q_auto/barista.png',
      );

      final stats = await GamificationService.instance.getStats();
      expect(stats.totalExp, 2450);
      expect(stats.level.level, 5);
      expect(stats.brewsCount, 22);
      expect(stats.toolkitCount, 18);
      expect(stats.cuppingCount, 9);
      expect(stats.streakDays, 6);
      expect((await ApiService.getBrewHistory()).first['title'], 'Cloud Synced Brew');
      expect((await ApiService.getJournalEntries()).first['coffeeName'], 'Gayo Honey');
      expect(await ApiService.getFavoriteIds(), equals({100, 102}));
      final recipes = await ApiService.getRecipes(forceRefresh: true);
      expect(recipes.any((r) => r['title'] == 'Cloud Custom V60'), isTrue);
    });
  });

  group('Avatar Resolution & Chat Avatar Widget', () {
    test('ProfileService.getImageProvider supports HTTPS network URLs and asset paths', () {
      final netProvider = ProfileService.getImageProvider(
        'https://res.cloudinary.com/demo/image/upload/f_auto,q_auto/avatar_sample.jpg',
      );
      expect(netProvider, isA<CachedNetworkImageProvider>());

      final assetProvider = ProfileService.getImageProvider(
        'assets/images/characters/avatar_5.png',
      );
      expect(assetProvider, isA<AssetImage>());
      expect((assetProvider as AssetImage).assetName, 'assets/images/characters/avatar_5.png');

      expect(ProfileService.tryGetImageProvider(''), isNull);
      expect(ProfileService.tryGetImageProvider(null), isNull);
    });

    testWidgets('UserAvatarCircle renders fallback initial when avatarUrl is null and asset image when set', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                UserAvatarCircle(
                  avatarUrl: null,
                  displayName: 'Risa Hanipah',
                  radius: 20,
                ),
                UserAvatarCircle(
                  avatarUrl: 'assets/images/characters/avatar_4.png',
                  displayName: 'Admin Rusdi',
                  radius: 20,
                  isOnline: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('R'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
