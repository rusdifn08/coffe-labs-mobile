import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../screens/onboarding_screen.dart';

/// Helper navigasi otentikasi agar perpindahan ke/dari OnboardingScreen
/// selalu konsisten antara GoRouter dan fallback Navigator imperatif.
class AuthNavigationHelper {
  AuthNavigationHelper._();

  static void openLoginScreen(BuildContext context, {bool upgrade = true}) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      final target = upgrade
          ? '${AppRoutes.onboarding}?upgrade=true'
          : AppRoutes.onboarding;
      router.push(target);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  static void returnHomeAfterAuth(BuildContext context) {
    final rootNav = Navigator.of(context, rootNavigator: true);
    if (rootNav.canPop()) {
      rootNav.popUntil((route) => route.isFirst);
    }

    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go(AppRoutes.home);
    }
  }
}
