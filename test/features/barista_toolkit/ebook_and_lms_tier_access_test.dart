import 'dart:convert';
import 'dart:io';

import 'package:coffee_hub_mobile/features/barista_toolkit/data/barista_toolkit_seed_data.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/domain/barista_toolkit_models.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/ebook_reader/ebook_library_screen.dart';
import 'package:coffee_hub_mobile/models/subscription_plan.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      return Directory.systemTemp.path;
    });
  });

  const proUser = AuthUser(
    id: 'u-risaha15',
    username: 'risaha15',
    fullName: 'Risa Hanipah',
    role: 'user',
    status: 'approved',
    tier: 'pro',
    avatarUrl: '',
  );

  const bizUser = AuthUser(
    id: 'u-biz',
    username: 'roastery_pro',
    fullName: 'Roastery Business',
    role: 'user',
    status: 'approved',
    tier: 'business',
    avatarUrl: '',
  );

  const adminUser = AuthUser(
    id: 'u-admin',
    username: 'rusdifn08',
    fullName: 'Superadmin',
    role: 'admin',
    status: 'approved',
    tier: 'trial',
    avatarUrl: '',
  );

  const trialUser = AuthUser(
    id: 'u-trial',
    username: 'barista_trial',
    fullName: 'Trial Barista',
    role: 'user',
    status: 'approved',
    tier: 'trial',
    avatarUrl: '',
  );

  test('ToolkitTierAccess unlocks Pro E-Books & LMS for Pro/Business/Admin/Full7dTrial and enforces Business/Trial boundaries', () {
    expect(ToolkitTierAccess.isUnlockedFor(requiredTier: 'Trial', user: proUser), isTrue);
    expect(ToolkitTierAccess.isUnlockedFor(requiredTier: 'Pro', user: proUser), isTrue);
    expect(ToolkitTierAccess.isUnlockedFor(requiredTier: 'Business', user: proUser), isFalse);

    expect(ToolkitTierAccess.isUnlockedFor(requiredTier: 'Pro', user: bizUser), isTrue);
    expect(ToolkitTierAccess.isUnlockedFor(requiredTier: 'Business', user: bizUser), isTrue);
    expect(ToolkitTierAccess.isUnlockedFor(requiredTier: 'Business', user: adminUser), isTrue);

    expect(ToolkitTierAccess.isUnlockedFor(requiredTier: 'Trial', user: trialUser), isTrue);
    expect(ToolkitTierAccess.isUnlockedFor(requiredTier: 'Pro', user: trialUser), isFalse);
    expect(ToolkitTierAccess.isUnlockedFor(requiredTier: 'Business', user: trialUser), isFalse);

    expect(
      ToolkitTierAccess.isUnlockedFor(
        requiredTier: 'Pro',
        user: trialUser,
        hasFullNonBusinessTrial: true,
      ),
      isTrue,
    );
    expect(
      ToolkitTierAccess.isUnlockedFor(
        requiredTier: 'Business',
        user: trialUser,
        hasFullNonBusinessTrial: true,
      ),
      isFalse,
    );

    expect(
      ToolkitTierAccess.isUnlockedFor(
        requiredTier: 'Pro',
        user: null,
        localPlan: SubscriptionPlan.pro,
      ),
      isTrue,
    );
  });

  testWidgets('EbookLibraryScreen unlocks CL-BOOK-03 (Pro) immediately for Pro account risaha15', (tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'coffeehub_auth_user_json': jsonEncode(proUser.toJson()),
      'coffeehub_auth_jwt_token': 'dummy-token',
    });

    await tester.runAsync(() async {
      await BaristaToolkitFallbackSeed.offlineEbooks();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: EbookLibraryScreen()),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    });
    await tester.pumpAndSettle();

    // Filter to CL-BOOK-03 (The Physics of Coffee Percolation & Extraction Kinetics)
    await tester.enterText(find.byType(TextField), 'Moroney');
    await tester.pumpAndSettle();

    expect(find.text('CL-BOOK-03'), findsOneWidget);
    expect(find.textContaining('The Physics of Coffee Percolation'), findsOneWidget);
    // Must NOT be locked for Pro user risaha15!
    expect(find.text('Terkunci (Pro)'), findsNothing);
    expect(find.textContaining('Unduh ke Perangkat'), findsWidgets);
  });
}
