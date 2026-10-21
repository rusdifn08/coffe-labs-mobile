import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coffee_hub_mobile/main.dart';
import 'package:coffee_hub_mobile/services/api_service.dart';
import 'package:coffee_hub_mobile/services/seed_data.dart';
import 'package:coffee_hub_mobile/services/trial_service.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:coffee_hub_mobile/services/app_update_service.dart';
import 'package:coffee_hub_mobile/models/feedback_item.dart';
import 'package:coffee_hub_mobile/data/roastery_catalog.dart';
import 'package:coffee_hub_mobile/data/brew_visual_catalog.dart';
import 'package:coffee_hub_mobile/models/social_coffee.dart';
import 'package:coffee_hub_mobile/services/social_service.dart';

void main() {
  testWidgets('CoffeeHubApp launches SplashScreen and navigates', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'coffeehub_user_name': 'Tester',
      'coffeehub_is_trial_mode': true,
    });

    await tester.pumpWidget(const CoffeeHubApp());
    expect(find.text('Coffee Labs'), findsOneWidget);
    expect(find.text('Master Your Brew'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Tester'), findsWidgets);
  });

  test('Offline default recipes and custom recipe sanitization have zero nulls', () async {
    SharedPreferences.setMockInitialValues({});
    final defaults = SeedData.getDefaultRecipes();
    expect(defaults.length, equals(159));

    final recipes = await ApiService.getRecipes();
    expect(recipes.length, equals(defaults.length));

    for (final r in recipes) {
      expect(r['id'], isNotNull);
      expect(r['title'], isNotNull);
      expect(r['author'], isNotNull);
      expect(r['method'], isNotNull);
      expect(r['category'], isNotNull);
      expect(r['grindSize'], isNotNull);
      expect(r['coffeeWeightGrams'], isPositive);
      expect(r['totalWaterWeightGrams'], isPositive);
      expect(r['totalTimeSeconds'], isPositive);
      expect(r['variety'], isNotNull);
      expect(r['variety'].toString(), isNotEmpty);
      expect(r['process'], isNotNull);
      expect(r['process'].toString(), isNotEmpty);
      final steps = r['steps'] as List<dynamic>;
      expect(steps, isNotEmpty);
      for (final s in steps) {
        expect(s['stepOrder'], isNotNull);
        expect(s['title'], isNotNull);
        expect(s['durationSeconds'], isPositive);
        expect(s['waterAddedGrams'], isNotNull);
        expect(s['instruction'], isNotNull);
      }
    }

    final yoshuaWine = recipes.firstWhere((r) => r['id'] == 111) as Map<String, dynamic>;
    expect(yoshuaWine['process'], equals('Wine Process'));
    expect(yoshuaWine['variety'], contains('Ateng'));
    expect(BrewVisualCatalog.processes.contains('Wine Process'), isTrue);

    // Test adding a custom recipe with legacy/partial keys to ensure zero nulls
    await ApiService.createRecipe({
      'title': 'Custom V60 Test',
      'coffeeWeightGrams': 15,
      'steps': [
        {'title': 'Bloom', 'timeSeconds': 35, 'waterGrams': 45},
        {'title': 'Main Pour', 'durationSeconds': 90, 'waterAddedGrams': 180},
      ],
    });

    final afterAdd = await ApiService.getRecipes();
    final custom = afterAdd.first as Map<String, dynamic>;
    expect(custom['isCustom'], isTrue);
    expect(custom['title'], equals('Custom V60 Test'));
    expect(custom['totalWaterWeightGrams'], equals(225));
    expect(custom['totalTimeSeconds'], equals(125));
    final customSteps = custom['steps'] as List<dynamic>;
    expect(customSteps.length, equals(2));
    expect(customSteps[0]['durationSeconds'], equals(35));
    expect(customSteps[0]['waterAddedGrams'], equals(45));
    expect(customSteps[0]['instruction'], isNotEmpty);
  });

  test('TrialService limits brews to 10 and locks, resets after 7 days', () async {
    SharedPreferences.setMockInitialValues({
      'coffeehub_is_trial_mode': true,
      'coffeehub_trial_brews_count': 0,
    });

    // Check initial state
    expect(await TrialService.isTrialMode(), isTrue);
    expect(await TrialService.canBrew(), isTrue);
    expect(await TrialService.getTrialBrewsCount(), equals(0));
    expect(await TrialService.isRecipeAccessible(0), isTrue);
    expect(await TrialService.isRecipeAccessible(9), isTrue);
    expect(await TrialService.isRecipeAccessible(10), isFalse);

    // Record 9 brews
    for (int i = 0; i < 9; i++) {
      await TrialService.recordTrialBrew();
    }
    expect(await TrialService.getTrialBrewsCount(), equals(9));
    expect(await TrialService.canBrew(), isTrue);

    // 10th brew locks trial
    await TrialService.recordTrialBrew();
    expect(await TrialService.getTrialBrewsCount(), equals(10));
    expect(await TrialService.canBrew(), isFalse);
    expect(await TrialService.isBrewLocked(), isTrue);

    // Simulate 8 days later
    final prefs = await SharedPreferences.getInstance();
    final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8)).millisecondsSinceEpoch;
    await prefs.setInt('coffeehub_trial_lock_timestamp', eightDaysAgo);

    // Now it should auto reset
    expect(await TrialService.canBrew(), isTrue);
    expect(await TrialService.getTrialBrewsCount(), equals(0));
  });

  test('AuthUser and Admin model verification', () {
    final adminUser = AuthUser.fromJson({
      'id': 'uuid-admin',
      'username': 'rusdifn08',
      'full_name': 'Admin Rusdi',
      'role': 'admin',
      'status': 'approved',
      'avatar_url': 'assets/images/characters/avatar_1.png',
    });

    expect(adminUser.isAdmin, isTrue);
    expect(adminUser.isApproved, isTrue);
    expect(adminUser.username, equals('rusdifn08'));

    final pendingUser = AuthUser.fromJson({
      'id': 'uuid-user-1',
      'username': 'barista_kopi',
      'full_name': 'Barista Kopi',
      'role': 'user',
      'status': 'pending',
    });

    expect(pendingUser.isAdmin, isFalse);
    expect(pendingUser.isApproved, isFalse);
  });

  test('FeedbackItem and Category model parsing', () {
    final catBug = FeedbackCategory.fromKey('bug_report');
    expect(catBug.label, contains('Bug'));
    expect(catBug.emoji, equals('🐛'));

    final catFeature = FeedbackCategory.fromKey('feature_request');
    expect(catFeature.emoji, equals('💡'));

    final item = FeedbackItem.fromJson({
      'id': 'fb-123',
      'username': 'rusdi_tester',
      'user_role': 'user',
      'category': 'bug_report',
      'feature_affected': 'Brew Timer & Stopwatch',
      'title': 'Test bug',
      'description': 'Description details',
      'rating': 4,
      'app_version': '1.0.0',
      'device_info': 'Android',
      'status': 'pending',
      'created_at': '2026-10-21T09:00:00Z',
    });

    expect(item.id, equals('fb-123'));
    expect(item.rating, equals(4));
    expect(item.categoryInfo.emoji, equals('🐛'));
    expect(FeedbackStatusHelper.getLabel(item.status), equals('Menunggu'));
  });

  test('VersionCheckResult parsing & The Hybrid 3-Tier action codes', () {
    final upToDate = VersionCheckResult.fromJson({
      'action_code': 'UP_TO_DATE',
      'latest_base_version': '1.0.0',
      'latest_build_number': 1,
      'is_force_update': false,
      'release_notes': 'Aplikasi optimal.',
    });
    expect(upToDate.isUpToDate, isTrue);
    expect(upToDate.isShorebirdPatch, isFalse);
    expect(upToDate.isStoreUpdate, isFalse);

    final shorebirdPatch = VersionCheckResult.fromJson({
      'action_code': 'FORCE_OTA_PATCH',
      'target_patch': 2,
      'latest_base_version': '1.0.0',
      'latest_build_number': 1,
      'is_force_update': false,
      'release_notes': 'Patch perbaikan dialektika timer.',
    });
    expect(shorebirdPatch.isUpToDate, isFalse);
    expect(shorebirdPatch.isShorebirdPatch, isTrue);
    expect(shorebirdPatch.targetPatch, equals(2));
    expect(shorebirdPatch.isStoreUpdate, isFalse);

    final forceStore = VersionCheckResult.fromJson({
      'action_code': 'FORCE_STORE_UPDATE',
      'latest_base_version': '2.0.0',
      'latest_build_number': 10,
      'is_force_update': true,
      'release_notes': 'Pembaruan native arsitektur besar.',
      'download_url': 'https://coffee-labs.id/download',
    });
    expect(forceStore.isUpToDate, isFalse);
    expect(forceStore.isShorebirdPatch, isFalse);
    expect(forceStore.isStoreUpdate, isTrue);
    expect(forceStore.isForceUpdate, isTrue);
    expect(forceStore.downloadUrl, equals('https://coffee-labs.id/download'));
  });

  test('AppUpdateService Shorebird graceful fallback in test/debug environment', () {
    // In test environment, Shorebird engine is not running and shouldn't throw unhandled errors
    expect(AppUpdateService.isShorebirdAvailable, isFalse);
  });

  test('RoasteryCatalog has 50 rich roasteries and zero null lineup fields', () {
    final list = RoasteryCatalog.list;
    expect(list.length, equals(50));

    int totalLineups = 0;
    for (final r in list) {
      expect(r.id, isNotEmpty);
      expect(r.name, isNotEmpty);
      expect(r.location, isNotEmpty);
      expect(r.address, isNotEmpty);
      expect(r.latitude, isNotNull);
      expect(r.longitude, isNotNull);
      expect(r.lineups, isNotEmpty);
      totalLineups += r.lineups.length;

      for (final l in r.lineups) {
        expect(l.name, isNotEmpty);
        expect(l.origin, isNotEmpty);
        expect(l.variety, isNotEmpty);
        expect(l.process, isNotEmpty);
        expect(l.roastProfile, isNotEmpty);
        expect(l.tastingNotes, isNotEmpty);
        expect(l.price100g, isNotEmpty);
        expect(l.price200g, isNotEmpty);
      }
    }
    expect(totalLineups, greaterThanOrEqualTo(100));
  });

  test('SocialPost and SocialComment model parsing, copy recipe to custom recipe & like counter', () async {
    SharedPreferences.setMockInitialValues({});

    final postJson = {
      'id': 'test-post-uuid',
      'author_name': 'Mikael Jasin 🇮🇩',
      'author_avatar': 'assets/images/characters/avatar_1.png',
      'author_role': 'World Barista Champion',
      'content': 'Tips ekstraksi sweetness tinggi di V60 dengan rasio 1:15.',
      'recipe_id': 102,
      'recipe_snapshot': {
        'title': 'Sweetness Boost V60',
        'method': 'Hario V60 02',
        'category': 'V60',
        'coffeeWeightGrams': 15,
        'totalWaterWeightGrams': 225,
        'waterTempCelsius': 91,
        'grindSize': 'Medium (22 Klik)',
        'tastingNotes': 'Peach, Honey, Jasmine',
        'steps': [
          {'title': 'Bloom', 'durationSeconds': 40, 'waterAddedGrams': 45},
          {'title': 'Pour 2', 'durationSeconds': 90, 'waterAddedGrams': 180},
        ],
      },
      'likes_count': 10,
      'comments_count': 3,
      'copies_count': 5,
      'tags': ['V60', 'Sweetness'],
      'is_liked_by_me': false,
      'created_at': DateTime.now().toIso8601String(),
    };

    final post = SocialPost.fromJson(postJson);
    expect(post.id, equals('test-post-uuid'));
    expect(post.authorName, equals('Mikael Jasin 🇮🇩'));
    expect(post.likesCount, equals(10));
    expect(post.recipeSnapshot, isNotNull);
    expect(post.recipeSnapshot!['title'], equals('Sweetness Boost V60'));
    expect(post.tags, contains('V60'));

    // Test toggle like locally
    post.isLikedByMe = true;
    post.likesCount++;
    expect(post.isLikedByMe, isTrue);
    expect(post.likesCount, equals(11));

    // Test copy recipe to custom recipes
    final copied = await SocialService.copyRecipeToMyRecipes(post);
    expect(copied, isNotNull);
    expect(copied!['title'], contains('Sweetness Boost V60'));
    expect(copied['isCustom'], isTrue);
    expect(copied['coffeeWeightGrams'], equals(15));
    expect(copied['totalWaterWeightGrams'], equals(225));

    // Test comment parsing
    final comment = SocialComment.fromJson({
      'id': 'c1',
      'post_id': post.id,
      'author_name': 'Ryan Wibawa',
      'author_avatar': 'assets/images/characters/avatar_2.png',
      'content': 'Mantap resepnya!',
      'created_at': DateTime.now().toIso8601String(),
    });
    expect(comment.id, equals('c1'));
    expect(comment.authorName, equals('Ryan Wibawa'));
    expect(comment.content, equals('Mantap resepnya!'));
  });
}
