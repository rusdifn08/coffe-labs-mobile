import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:coffee_hub_mobile/core/network/dio_client.dart';
import 'package:coffee_hub_mobile/core/network/isolate_json_transformer.dart';
import 'package:coffee_hub_mobile/core/performance/transition_aware_deferred_builder.dart';
import 'package:coffee_hub_mobile/core/services/kiosk_engine_service.dart';
import 'package:coffee_hub_mobile/core/widgets/optimized_coffee_image.dart';
import 'package:coffee_hub_mobile/features/brew_methods/models/brew_method_item.dart';
import 'package:coffee_hub_mobile/features/brew_methods/widgets/brew_method_card.dart';
import 'package:coffee_hub_mobile/screens/brew_selection_screen.dart';
import 'package:coffee_hub_mobile/screens/home_screen.dart';
import 'package:coffee_hub_mobile/screens/main_layout.dart';
import 'package:coffee_hub_mobile/screens/recipe_feed_screen.dart';
import 'package:coffee_hub_mobile/screens/toolkit_screen.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:coffee_hub_mobile/services/main_navigation_service.dart';
import 'package:coffee_hub_mobile/services/trial_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'coffeehub_is_trial_mode': true,
      'coffeehub_user_name': 'PerfTester',
    });
    MainNavigationService.switchTab(0);
    KioskEngineService.resetBootStateCache();
    AuthService.resetSessionCache();
    TrialService.resetPolicyMemoryCache();
  });

  group('60-120 FPS Core Performance Architecture', () {
    testWidgets(
      '1. TransitionAwareDeferredBuilder defers heavy child until route transition completes',
      (tester) async {
        int heavyBuildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 260),
                        pageBuilder: (_, _, _) => Scaffold(
                          body: TransitionAwareDeferredBuilder(
                            enableInTestEnv: true,
                            lightweightPlaceholder:
                                const Text('SHELL_LOADING'),
                            heavyBuilder: (_) {
                              heavyBuildCount++;
                              return const Text('HEAVY_CONTENT_MOUNTED');
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('PUSH'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('PUSH'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // During route animation (50ms < 260ms): ONLY lightweight shell renders, 0 heavy builds!
        expect(find.text('SHELL_LOADING'), findsOneWidget);
        expect(find.text('HEAVY_CONTENT_MOUNTED'), findsNothing);
        expect(heavyBuildCount, equals(0));

        // After route animation finishes + post-frame callback
        await tester.pumpAndSettle();
        expect(find.text('SHELL_LOADING'), findsNothing);
        expect(find.text('HEAVY_CONTENT_MOUNTED'), findsOneWidget);
        expect(heavyBuildCount, greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      '2. OptimizedCoffeeImage rewrites Cloudinary URLs and enforces DPR-capped cacheWidth (<= 2.5x)',
      (tester) async {
        const rawUrl =
            'https://res.cloudinary.com/demo/image/upload/v1234/v60.png';
        final optimized = OptimizedCoffeeImage.optimizeCloudinaryUrl(rawUrl, 240);
        expect(
          optimized,
          equals(
            'https://res.cloudinary.com/demo/image/upload/f_auto,q_auto:eco,w_240,c_limit/v1234/v60.png',
          ),
        );
        // Does not double-inject parameters
        expect(
          OptimizedCoffeeImage.optimizeCloudinaryUrl(optimized, 240),
          equals(optimized),
        );

        tester.view.devicePixelRatio = 4.0;
        tester.view.physicalSize = const Size(1440, 2960);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const OptimizedCoffeeImage(
                    imageUrlOrAsset: 'assets/images/methods/v60.png',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(
                    width: 150,
                    height: 175,
                    child: BrewMethodCard(
                      item: BrewMethodItem.allMethods.first,
                      isEn: false,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        final images = tester.widgetList<Image>(find.byType(Image)).toList();
        expect(images, isNotEmpty);
        // 100 * min(4.0, 2.5) = 250
        final resizeProvider = images.first.image as ResizeImage;
        expect(resizeProvider.width, equals(250));
      },
    );

    test('3. IsolateJsonTransformer handles small & large (>10KB) JSON payloads and is wired into Dio', () async {
      final smallJson = json.encode({'ok': true, 'count': 3});
      final smallDecoded =
          await IsolateJsonTransformer.parseJsonInBackground(smallJson);
      expect(smallDecoded['count'], equals(3));

      final largeItems = List.generate(
        260,
        (i) => {'id': i, 'name': 'Coffee Bean Roastery Item #$i', 'note': 'Jasmine Peach'},
      );
      final largeJson = json.encode({'items': largeItems});
      expect(largeJson.length, greaterThanOrEqualTo(IsolateJsonTransformer.isolateThresholdBytes));

      final largeDecoded =
          await IsolateJsonTransformer.parseJsonInBackground(largeJson);
      expect((largeDecoded['items'] as List).length, equals(260));

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final dio = container.read(dioClientProvider);
      expect(dio.transformer, isA<IsolateJsonTransformer>());
    });

    testWidgets(
      '4. MainLayout lazy-hydrates 5-tab IndexedStack on demand without mounting unvisited tabs',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: MainLayout()),
          ),
        );
        await tester.pump();

        // Tab 0 (Home) is mounted; unvisited tabs (Recipes, BrewSelection, Toolkit) are deferred!
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(RecipeFeedScreen), findsNothing);
        expect(find.byType(BrewSelectionScreen), findsNothing);
        expect(find.byType(ToolkitScreen), findsNothing);

        // Switch to Toolkit (tab 3)
        MainNavigationService.switchTab(3);
        await tester.pump();

        // Toolkit is now mounted, Home remains preserved (offstage) in IndexedStack, unvisited tabs stay unmounted
        expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
        expect(find.byType(ToolkitScreen), findsOneWidget);
        expect(find.byType(RecipeFeedScreen, skipOffstage: false), findsNothing);
      },
    );

    testWidgets(
      '5. ToolkitScreen uses CustomScrollView + SliverGrid without nested shrinkWrap GridView',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: ToolkitScreen()),
          ),
        );
        await tester.pump();

        expect(find.byType(CustomScrollView), findsOneWidget);
        expect(find.byType(GridView, skipOffstage: false), findsNothing);
        // CustomScrollView mounts slivers lazily as the user scrolls
        expect(find.byType(SliverGrid), findsAtLeastNWidgets(2));

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
        await tester.pump();
        expect(find.textContaining('Kimia Air Seduh'), findsOneWidget);
        expect(find.byType(GridView, skipOffstage: false), findsNothing);
      },
    );
  });
}
