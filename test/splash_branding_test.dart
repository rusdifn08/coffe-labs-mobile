import 'dart:io';
import 'package:coffee_hub_mobile/core/router/app_router.dart';
import 'package:coffee_hub_mobile/features/auth/widgets/auth_header.dart';
import 'package:coffee_hub_mobile/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Brand PNG logo assets exist and are non-empty', () {
    for (final path in [
      'assets/icon.png',
      'assets/icon_foreground.png',
      'assets/images/coffee_labs_emblem.png',
      'assets/images/coffee_labs_logo.png',
    ]) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'Missing brand asset $path');
      expect(file.lengthSync(), greaterThan(1024), reason: 'Empty asset $path');
    }
  });

  testWidgets('SplashScreen displays animated Coffee Labs logo and navigates cleanly', (tester) async {
    SharedPreferences.setMockInitialValues({
      'coffeehub_user_name': 'Barista Test',
      'coffeehub_is_trial_mode': true,
    });

    String? navigatedRoute;
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) {
            navigatedRoute = AppRoutes.home;
            return const Scaffold(body: Text('Home Destination'));
          },
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, _) {
            navigatedRoute = AppRoutes.onboarding;
            return const Scaffold(body: Text('Onboarding Destination'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Coffee Labs'), findsOneWidget);
    expect(find.text('MASTER YOUR BREW'), findsOneWidget);
    expect(find.text('SPECIALTY BREWING INTELLIGENCE'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);
    final image = tester.widget<Image>(imageFinder);
    expect((image.image as AssetImage).assetName, 'assets/images/coffee_labs_emblem.png');

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 300));
    expect(navigatedRoute, AppRoutes.home);
  });

  testWidgets('AuthHeader renders transparent Coffee Labs emblem', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthHeader(isSignUpMode: false),
        ),
      ),
    );

    expect(find.text('Coffee Labs'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/images/coffee_labs_emblem.png');
  });
}
