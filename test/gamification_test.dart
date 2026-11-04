import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/gamification/models/coffee_level.dart';
import 'package:coffee_hub_mobile/features/gamification/services/gamification_service.dart';
import 'package:coffee_hub_mobile/features/gamification/widgets/gamified_avatar.dart';
import 'package:coffee_hub_mobile/features/profile/widgets/user_profile_header_card.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CoffeeLevel & Gamification Tests', () {
    test('All 10 Tiers are defined with unique levels and valid EXP bounds', () {
      expect(CoffeeLevel.allLevels.length, equals(10));

      for (int i = 0; i < CoffeeLevel.allLevels.length; i++) {
        final lvl = CoffeeLevel.allLevels[i];
        expect(lvl.level, equals(i + 1));
        expect(lvl.title.isNotEmpty, isTrue);
        expect(lvl.indonesianTitle.isNotEmpty, isTrue);
        expect(lvl.borderGradient.length, greaterThanOrEqualTo(2));
      }
    });

    test('CoffeeLevel.fromExp correctly maps EXP points to appropriate ranks', () {
      // Level 1: Novice Brewer (0 - 199)
      expect(CoffeeLevel.fromExp(0).level, equals(1));
      expect(CoffeeLevel.fromExp(150).title, equals('Novice Brewer'));

      // Level 2: Aroma Explorer (200 - 499)
      expect(CoffeeLevel.fromExp(200).level, equals(2));
      expect(CoffeeLevel.fromExp(350).title, equals('Aroma Explorer'));

      // Level 3: Extraction Craftsman (500 - 999)
      expect(CoffeeLevel.fromExp(500).level, equals(3));

      // Level 4: Dial-In Alchemist (1000 - 1799)
      expect(CoffeeLevel.fromExp(1250).title, equals('Dial-In Alchemist'));

      // Level 6: Master of TDS (3000 - 4499)
      expect(CoffeeLevel.fromExp(3500).title, equals('Master of TDS & Solutes'));

      // Level 10: Legendary Q-Grader (12500+)
      expect(CoffeeLevel.fromExp(15000).level, equals(10));
      expect(CoffeeLevel.fromExp(20000).title, equals('Legendary Q-Grader & Coffee Luminary'));
    });

    test('Progress calculation and expNeededToNext work properly', () {
      final lvl4 = CoffeeLevel.fromExp(1400); // Level 4 (1000 to 1800)
      expect(lvl4.level, equals(4));
      expect(lvl4.expNeededToNext(1400), equals(400));
      expect(lvl4.getProgress(1400), equals(0.5)); // (1400 - 1000) / 800 = 0.5
    });

    test('GamificationService awards EXP for brewing and toolkit sessions', () async {
      final service = GamificationService.instance;

      final initialStats = await service.getStats();
      expect(initialStats.totalExp, equals(25)); // from initial streak of 1 day

      // Record a completed brew
      await service.recordBrewCompleted(hasRating: true, hasNotes: true);
      final statsAfterBrew = await service.getStats();
      // 25 (initial) + 50 (brew) + 15 (rating) + 25 (notes) + 25 (first check-in streak bonus) = 140
      expect(statsAfterBrew.totalExp, equals(140));
      expect(statsAfterBrew.brewsCount, equals(1));

      // Record a toolkit session
      await service.recordToolkitUsed('Matriks Grinder');
      final statsAfterToolkit = await service.getStats();
      expect(statsAfterToolkit.totalExp, equals(160)); // 140 + 20 = 160
      expect(statsAfterToolkit.toolkitCount, equals(1));
    });

    testWidgets('GamifiedAvatar renders without crashing with Level 4 aura', (tester) async {
      final lvl4 = CoffeeLevel.fromExp(1200);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GamifiedAvatar(
              radius: 36,
              level: lvl4,
              showLevelBadge: true,
            ),
          ),
        ),
      );

      expect(find.byType(GamifiedAvatar), findsOneWidget);
      expect(find.text('Lv.4'), findsOneWidget);
    });

    testWidgets('UserProfileHeaderCard renders integrated gamification in header', (tester) async {
      final lvl = CoffeeLevel.fromExp(3500);
      final stats = GamificationStats(
        totalExp: 3500,
        level: lvl,
        brewsCount: 30,
        cuppingCount: 15,
        toolkitCount: 20,
        streakDays: 7,
        progress: 0.33,
        expToNext: 1000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserProfileHeaderCard(
              currentUser: null,
              displayName: 'the barista',
              avatarPath: null,
              isTrial: true,
              isAdmin: false,
              gamificationStats: stats,
              onTapAvatar: () {},
            ),
          ),
        ),
      );

      expect(find.text('the barista'), findsOneWidget);
      expect(find.text('LEVEL 6'), findsOneWidget);
      expect(find.text('Master of TDS & Solutes'), findsWidgets);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('Seduhan'), findsOneWidget);
      expect(find.text('Roadmap'), findsOneWidget);
    });

    test('PresetAdminService logs in admin1 through admin10 with exact corresponding levels', () async {
      for (int i = 1; i <= 10; i++) {
        final username = 'admin$i';
        final password = 'admin$i';

        final result = await AuthService.login(username: username, password: password);
        expect(result.success, isTrue);
        expect(result.user, isNotNull);
        expect(result.user!.role, equals('admin'));
        expect(result.user!.isApproved, isTrue);

        final stats = await GamificationService.instance.getStats();
        expect(stats.level.level, equals(i), reason: 'admin$i should have Level $i');
      }
    });

    test('PresetAdminService rejects wrong password for admin accounts', () async {
      final result = await AuthService.login(username: 'admin1', password: 'wrongpassword');
      expect(result.success, isFalse);
    });
  });
}
