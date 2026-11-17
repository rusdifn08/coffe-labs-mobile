import 'dart:convert';

import 'package:coffee_hub_mobile/features/auth/utils/auth_navigation_helper.dart';
import 'package:coffee_hub_mobile/features/profile/widgets/profile_trial_card.dart';
import 'package:coffee_hub_mobile/features/recipe_feed/widgets/recipe_feed_grid_card.dart';
import 'package:coffee_hub_mobile/models/trial_access_policy.dart';
import 'package:coffee_hub_mobile/screens/admin_trial_control_screen.dart';
import 'package:coffee_hub_mobile/screens/settings_screen.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:coffee_hub_mobile/services/language_service.dart';
import 'package:coffee_hub_mobile/services/trial_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'coffeehub_language': 'id'});
    await LanguageService.getLanguage();
    TrialService.resetPolicyMemoryCache();
  });

  group('1. Admin Trial Policy & 7-Day Non-Business Full Access Switcher', () {
    test(
      'Switching to 7-Day Full Access unlocks all brewer features while keeping Business Suite strictly locked, and auto-locks on expiry',
      () async {
        // Default strict limited
        await TrialService.setLocalPolicy(TrialAccessPolicy.strictLimited);
        expect(
          TrialService.isFeatureUnlockedSync(TrialFeature.allRecipes),
          isFalse,
        );
        expect(
          TrialService.isFeatureUnlockedSync(TrialFeature.smartBrewDialIn),
          isFalse,
        );
        expect(
          TrialService.isFeatureUnlockedSync(TrialFeature.toolkitPro),
          isFalse,
        );
        expect(
          TrialService.isFeatureUnlockedSync(TrialFeature.businessSuite),
          isFalse,
        );

        // Activate 7-day full non-business trial
        final now = DateTime(2026, 11, 17, 12, 0);
        final policy7d = TrialAccessPolicy.fullTrial7DaysNonBusiness(
          durationDays: 7,
          activatedAt: now,
        );
        await TrialService.setLocalPolicy(policy7d);

        expect(policy7d.isFull7DayNonBusiness, isTrue);
        expect(policy7d.allowBusinessSuite, isFalse);

        // Day 3: all non-business features unlocked, businessSuite STILL locked
        final day3 = now.add(const Duration(days: 3));
        expect(
          TrialService.isFeatureUnlockedSync(TrialFeature.allRecipes, now: day3),
          isTrue,
        );
        expect(
          TrialService.isFeatureUnlockedSync(
            TrialFeature.smartBrewDialIn,
            now: day3,
          ),
          isTrue,
        );
        expect(
          TrialService.isFeatureUnlockedSync(TrialFeature.aiScanner, now: day3),
          isTrue,
        );
        expect(
          TrialService.isFeatureUnlockedSync(TrialFeature.toolkitPro, now: day3),
          isTrue,
        );
        expect(
          TrialService.isFeatureUnlockedSync(
            TrialFeature.learningAcademy,
            now: day3,
          ),
          isTrue,
        );
        expect(
          TrialService.isFeatureUnlockedSync(TrialFeature.brewDoctor, now: day3),
          isTrue,
        );
        expect(
          TrialService.isFeatureUnlockedSync(
            TrialFeature.unlimitedBrews,
            now: day3,
          ),
          isTrue,
        );
        expect(
          TrialService.isFeatureUnlockedSync(
            TrialFeature.businessSuite,
            now: day3,
          ),
          isFalse,
        );

        // Day 8 (expired): automatically reverts to locked
        final day8 = now.add(const Duration(days: 8));
        expect(
          TrialService.isFeatureUnlockedSync(TrialFeature.allRecipes, now: day8),
          isFalse,
        );
        expect(
          TrialService.isFeatureUnlockedSync(TrialFeature.toolkitPro, now: day8),
          isFalse,
        );
      },
    );

    testWidgets(
      'AdminTrialControlScreen switches to 7-Day Full Non-Business mode & saves at 375x780 without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(375, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          const MaterialApp(home: AdminTrialControlScreen()),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('MODE TERBATAS (STRICT)'), findsOneWidget);

        // Tap 7-Day Full Access (Non-Bisnis) preset
        await tester.tap(
          find.text('Trial 7 Hari Full Access (Non-Bisnis)'),
        );
        await tester.pumpAndSettle();

        expect(find.text('TRIAL 7 HARI FULL (NON-BISNIS)'), findsOneWidget);
        expect(
          find.textContaining(
            'Proteksi Bisnis Aktif: Kasir POS & OLED Kiosk tetap terkunci',
          ),
          findsOneWidget,
        );

        // Tap Save button
        await tester.tap(
          find.text('Simpan & Terapkan Live ke Akun Trial'),
        );
        await tester.pumpAndSettle();

        expect(TrialService.currentPolicySync.isFull7DayNonBusiness, isTrue);
        expect(TrialService.currentPolicySync.unlockAllRecipes, isTrue);
        expect(TrialService.currentPolicySync.allowBusinessSuite, isFalse);
      },
    );
  });

  group('2. Trial Recipe Lock Security: Filter & Search Anti-Bypass', () {
    testWidgets(
      'Locked recipe (#15) stays LOCKED even when filtered/searched to grid index 0',
      (tester) async {
        await TrialService.setTrialMode(true);
        await TrialService.setLocalPolicy(TrialAccessPolicy.strictLimited);

        // Full unfiltered catalog of 20 recipes (IDs 1..20)
        final unfilteredCatalog = List.generate(
          20,
          (i) => {
            'id': i + 1,
            'title': i == 14
                ? 'Dinamika Profil Tanpa Pahit (2018 Juara 1)'
                : 'Resep Kurasi #${i + 1}',
            'author': i == 14 ? 'Emi Fukahori 🇨🇭' : 'Barista #${i + 1}',
            'category': i == 14 ? 'Hybrid' : 'V60',
            'method': i == 14 ? 'Hario Switch' : 'Hario V60',
            'coffeeWeightGrams': 17,
            'totalWaterWeightGrams': 220,
            'totalTimeSeconds': 160,
            'isCustom': false,
          },
        );

        final canonicalFreeIds =
            TrialService.computeCanonicalFreeIds(unfilteredCatalog);
        expect(canonicalFreeIds.length, 10);
        expect(canonicalFreeIds.contains(1), isTrue);
        expect(canonicalFreeIds.contains(15), isFalse);

        // Simulate user searching "Fukahori" or filtering "Hybrid":
        // Recipe #15 is now at filtered index 0!
        final filteredRecipe15 = unfilteredCatalog[14];
        final isLockedAtFilteredIndex0 = TrialService.isRecipeLockedSync(
          filteredRecipe15,
          isTrial: true,
          canonicalFreeIds: canonicalFreeIds,
        );
        expect(
          isLockedAtFilteredIndex0,
          isTrue,
          reason:
              'Recipe #15 must remain locked even when filtered/searched to index 0!',
        );

        bool openedDetail = false;
        bool triggeredLockDialog = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 220,
                height: 220,
                child: RecipeFeedGridCard(
                  rawRecipe: filteredRecipe15,
                  index: 0, // Filtered index 0!
                  isTrial: true,
                  isLockedOverride: isLockedAtFilteredIndex0,
                  onTap: () => openedDetail = true,
                  onBaristaTap: () {},
                  onTrialLocked: () => triggeredLockDialog = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Card at index 0 MUST still display 'Terkunci' and block opening detail!
        expect(find.text('Terkunci'), findsWidgets);
        await tester.tap(find.byType(RecipeFeedGridCard));
        await tester.pump();
        expect(openedDetail, isFalse);
        expect(triggeredLockDialog, isTrue);

        // When Admin switches ON 7-Day Full Non-Business Trial, Recipe #15 unlocks cleanly
        await TrialService.setLocalPolicy(
          TrialAccessPolicy.fullTrial7DaysNonBusiness(),
        );
        expect(
          TrialService.isRecipeLockedSync(
            filteredRecipe15,
            isTrial: true,
            canonicalFreeIds: canonicalFreeIds,
          ),
          isFalse,
        );
      },
    );
  });

  group('3. Login / Guest Bug Fix in Settings, Profile & Return-Home Navigation', () {
    testWidgets(
      'Logged-in Trial user (Risa Hanipah) is recognized as logged in, never shown as Pengunjung in Profile/Settings, and AuthNavigationHelper pops cleanly',
      (tester) async {
        tester.view.physicalSize = const Size(375, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final risaJson = json.encode({
          'id': 'user_risa_01',
          'username': 'risaha15',
          'full_name': 'Risa Hanipah',
          'role': 'user',
          'status': 'approved',
          'tier': 'trial',
          'avatar_url': 'assets/images/characters/avatar_1.png',
        });

        SharedPreferences.setMockInitialValues({
          'coffeehub_language': 'id',
          'coffeehub_is_trial_mode': true,
          'coffeehub_auth_jwt_token': 'valid_jwt_token_risa',
          'coffeehub_auth_user_json': risaJson,
          'coffeehub_auth_session_user': risaJson,
        });
        await LanguageService.getLanguage();

        // 1. AuthService.isLoggedIn() MUST be true even when trial_mode is true!
        expect(await AuthService.isLoggedIn(), isTrue);
        expect(await AuthService.isAnonymousVisitor(), isFalse);

        final user = await AuthService.getCurrentUser();
        expect(user, isNotNull);
        expect(user!.fullName, 'Risa Hanipah');

        // 2. ProfileTrialCard shows active logged-in account, NOT "Mode Pengunjung" or "Masuk"
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProfileTrialCard(currentUser: user),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Akun @risaha15'), findsOneWidget);
        expect(find.text('LOGIN AKTIF'), findsOneWidget);
        expect(find.textContaining('Mode Pengunjung'), findsNothing);
        expect(find.text('Masuk'), findsNothing);

        // 3. SettingsScreen shows active logged-in account session card, NOT Visitor Mode
        await tester.pumpWidget(
          const MaterialApp(home: SettingsScreen()),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.textContaining('Risa Hanipah (@risaha15)'),
          findsOneWidget,
        );
        expect(find.text('AKTIF'), findsOneWidget);
        expect(
          find.text('Mode Pengunjung (Belum Login)'),
          findsNothing,
        );

        // 4. AuthNavigationHelper.returnHomeAfterAuth pops pushed imperative routes cleanly
        bool poppedBackToRoot = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (rootCtx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(rootCtx).push(
                      MaterialPageRoute(
                        builder: (pushedCtx) => Scaffold(
                          body: ElevatedButton(
                            onPressed: () {
                              AuthNavigationHelper.returnHomeAfterAuth(
                                pushedCtx,
                              );
                              poppedBackToRoot =
                                  !Navigator.of(rootCtx).canPop();
                            },
                            child: const Text('Finish Login'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Login'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open Login'));
        await tester.pumpAndSettle();
        expect(find.text('Finish Login'), findsOneWidget);

        await tester.tap(find.text('Finish Login'));
        await tester.pumpAndSettle();
        expect(poppedBackToRoot, isTrue);
        expect(find.text('Open Login'), findsOneWidget);
      },
    );
  });
}
