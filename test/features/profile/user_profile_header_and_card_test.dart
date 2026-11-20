import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_hub_mobile/features/profile/widgets/profile_subscription_card.dart';
import 'package:coffee_hub_mobile/features/profile/widgets/user_profile_header_card.dart';
import 'package:coffee_hub_mobile/models/subscription_plan.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';

void main() {
  const proUser = AuthUser(
    id: 'u-pro',
    username: 'risaha15',
    fullName: 'Risa Hanipah',
    role: 'user',
    status: 'active',
    tier: 'pro',
    avatarUrl: '',
  );

  const bizUser = AuthUser(
    id: 'u-biz',
    username: 'roastery_bandung',
    fullName: 'Risa Specialty Coffee Roastery Nusantara',
    role: 'user',
    status: 'active',
    tier: 'business',
    avatarUrl: '',
  );

  testWidgets(
    'PRO profile renders sleek PRO badge beside name, removes COFFEE LABS PRO, and hides active license card',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  UserProfileHeaderCard(
                    currentUser: proUser,
                    displayName: proUser.fullName,
                    avatarPath: null,
                    isTrial: false,
                    isAdmin: false,
                    currentTier: SubscriptionTier.pro,
                    onTapAvatar: () {},
                  ),
                  ProfileSubscriptionCard(
                    currentPlan: SubscriptionPlan.pro,
                    isTrial: false,
                    onRefresh: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Risa Hanipah'), findsOneWidget);
      expect(find.byKey(const Key('profile_tier_badge_pro')), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      expect(find.text('COFFEE LABS PRO'), findsNothing);
      expect(find.textContaining('Lisensi Aktif'), findsNothing);
      expect(find.textContaining('Upgrade ke Business'), findsNothing);

      // Verify PRO badge sits horizontally beside the name (to its right, same row)
      final nameRect = tester.getRect(find.text('Risa Hanipah'));
      final badgeRect = tester.getRect(find.byKey(const Key('profile_tier_badge_pro')));
      expect(badgeRect.left, greaterThanOrEqualTo(nameRect.right));
      expect((badgeRect.center.dy - nameRect.center.dy).abs(), lessThan(6.0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'BUSINESS profile renders BUSINESS badge beside long name at 360px without overflow and hides active license card',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  UserProfileHeaderCard(
                    currentUser: bizUser,
                    displayName: bizUser.fullName,
                    avatarPath: null,
                    isTrial: false,
                    isAdmin: false,
                    currentTier: SubscriptionTier.business,
                    onTapAvatar: () {},
                  ),
                  ProfileSubscriptionCard(
                    currentPlan: SubscriptionPlan.business,
                    isTrial: false,
                    onRefresh: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_tier_badge_business')), findsOneWidget);
      expect(find.text('BUSINESS'), findsOneWidget);
      expect(find.text('BUSINESS CAFE'), findsNothing);
      expect(find.textContaining('Lisensi Aktif'), findsNothing);

      final nameRect = tester.getRect(find.text(bizUser.fullName));
      final badgeRect =
          tester.getRect(find.byKey(const Key('profile_tier_badge_business')));
      expect(badgeRect.left, greaterThanOrEqualTo(nameRect.right));
      expect((badgeRect.center.dy - nameRect.center.dy).abs(), lessThan(6.0));
      expect(tester.takeException(), isNull);
    },
  );
}
