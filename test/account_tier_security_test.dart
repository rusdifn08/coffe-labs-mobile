import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coffee_hub_mobile/models/subscription_plan.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:coffee_hub_mobile/services/subscription_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Account Tier & RBAC Security Isolation Tests', () {
    test('Newly registered standard user strictly gets Trial tier and no Business access', () async {
      SharedPreferences.setMockInitialValues({
        'coffeehub_auth_user_json': json.encode({
          'id': 'user_123',
          'username': 'risaha15',
          'full_name': 'Risa Hanipah',
          'role': 'user',
          'status': 'approved',
          'tier': 'trial',
          'avatar_url': 'assets/images/characters/avatar_1.png',
        }),
      });

      final user = await AuthService.getCurrentUser();
      expect(user, isNotNull);
      expect(user!.isBusiness, isFalse);
      expect(user.isAdmin, isFalse);
      expect(user.isPro, isFalse);

      final plan = await SubscriptionService.getCurrentPlan();
      expect(plan.tier, equals(SubscriptionTier.trial));

      final isBiz = await SubscriptionService.isBusiness();
      expect(isBiz, isFalse);

      final isPro = await SubscriptionService.isProOrBusiness();
      expect(isPro, isFalse);
    });

    test('Stale device Business preference NEVER infects an authenticated Trial user', () async {
      // Simulate leftover business plan from previous admin/demo session
      SharedPreferences.setMockInitialValues({
        'coffeehub_active_subscription_plan': 'plan_business',
        'coffee_labs_is_premium_pro': true,
        'coffeehub_auth_user_json': json.encode({
          'id': 'user_123',
          'username': 'risaha15',
          'full_name': 'Risa Hanipah',
          'role': 'user',
          'status': 'approved',
          'tier': 'trial',
          'avatar_url': 'assets/images/characters/avatar_1.png',
        }),
      });

      // User account authority must override stale device keys
      final plan = await SubscriptionService.getCurrentPlan();
      expect(plan.tier, equals(SubscriptionTier.trial));

      final isBiz = await SubscriptionService.isBusiness();
      expect(isBiz, isFalse);

      final isPro = await SubscriptionService.isProOrBusiness();
      expect(isPro, isFalse);
    });

    test('Admin user rusdifn08 gets Business access', () async {
      SharedPreferences.setMockInitialValues({
        'coffeehub_auth_user_json': json.encode({
          'id': 'admin_1',
          'username': 'rusdifn08',
          'full_name': 'Admin Rusdi',
          'role': 'admin',
          'status': 'approved',
          'tier': 'business',
          'avatar_url': 'assets/images/characters/avatar_1.png',
        }),
      });

      final user = await AuthService.getCurrentUser();
      expect(user!.isAdmin, isTrue);
      expect(user.isBusiness, isTrue);

      final isBiz = await SubscriptionService.isBusiness();
      expect(isBiz, isTrue);

      final plan = await SubscriptionService.getCurrentPlan();
      expect(plan.tier, equals(SubscriptionTier.business));
    });

    test('Demo user bisnis123 gets Business access', () async {
      SharedPreferences.setMockInitialValues({
        'coffeehub_auth_user_json': json.encode({
          'id': 'demo_1',
          'username': 'bisnis123',
          'full_name': 'Coffee Labs Business Demo',
          'role': 'user',
          'status': 'approved',
          'tier': 'business',
          'avatar_url': 'assets/images/characters/avatar_2.png',
        }),
      });

      final user = await AuthService.getCurrentUser();
      expect(user!.isBusiness, isTrue);

      final isBiz = await SubscriptionService.isBusiness();
      expect(isBiz, isTrue);
    });

    test('Logout thoroughly purges all session and subscription keys', () async {
      SharedPreferences.setMockInitialValues({
        'coffeehub_auth_jwt_token': 'mock_token',
        'coffeehub_auth_user_json': json.encode({
          'id': 'admin_1',
          'username': 'rusdifn08',
          'full_name': 'Admin Rusdi',
          'role': 'admin',
          'status': 'approved',
          'tier': 'business',
          'avatar_url': 'assets/images/characters/avatar_1.png',
        }),
        'coffeehub_active_subscription_plan': 'plan_business',
        'coffee_labs_is_premium_pro': true,
      });

      await AuthService.logout();

      final user = await AuthService.getCurrentUser();
      expect(user, isNull);

      final token = await AuthService.getToken();
      expect(token, isNull);

      final plan = await SubscriptionService.getCurrentPlan();
      expect(plan.tier, equals(SubscriptionTier.trial));

      final isBiz = await SubscriptionService.isBusiness();
      expect(isBiz, isFalse);

      final isPro = await SubscriptionService.isProOrBusiness();
      expect(isPro, isFalse);
    });
  });
}
