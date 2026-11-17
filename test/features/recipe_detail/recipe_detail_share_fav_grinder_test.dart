import 'dart:ui' as ui;

import 'package:coffee_hub_mobile/data/brew_visual_catalog.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/services/recipe_share_service.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/widgets/animated_favorite_heart_button.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/widgets/recipe_cover_background.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/widgets/recipe_detail_app_bar.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/widgets/recipe_detail_bottom_bar.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/widgets/recipe_share_card.dart';
import 'package:coffee_hub_mobile/features/recipe_detail/widgets/recipe_share_sheet.dart';
import 'package:coffee_hub_mobile/features/recipe_editor/widgets/editor_grinder_picker_modal.dart';
import 'package:coffee_hub_mobile/features/recipe_editor/widgets/editor_grinder_section.dart';
import 'package:coffee_hub_mobile/features/recipe_editor/widgets/grinder_thumbnail_image.dart';
import 'package:coffee_hub_mobile/screens/recipe_detail_screen.dart';
import 'package:coffee_hub_mobile/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _konstantinosRecipe() => {
      'id': 2,
      'title': 'Inovasi Pemecahan Biji Dingin (2015 Juara 2)',
      'author': 'Konstantinos Iatridis 🇬🇷',
      'coverImageUrl': 'assets/images/avatars/covers/konstantinos_iatridis.jpg',
      'authorAvatarUrl':
          'assets/images/avatars/portraits/konstantinos_iatridis.jpg',
      'authorImageUrl': 'assets/images/avatars/covers/konstantinos_iatridis.jpg',
      'beanName': 'Ninety Plus Perci Pinnacle Gesha',
      'variety': 'Panama Geisha',
      'process': 'Washed Process',
      'method': 'Hario V60',
      'category': 'V60 Pour Over',
      'waterTempCelsius': 92,
      'grindSize': 'Coarse',
      'coffeeWeightGrams': 20,
      'totalWaterWeightGrams': 300,
      'iceWeightGrams': 0,
      'totalTimeSeconds': 180,
      'tastingNotes': ['Papaya', 'Orange Blossom', 'Bergamot'],
      'description':
          'Konstantinos memperkenalkan teknik pembekuan biji sebelum digiling agar distribusi partikel lebih seragam.',
      'isCustom': false,
      'steps': [
        {
          'stepOrder': 1,
          'title': 'Blooming',
          'durationSeconds': 30,
          'waterAddedGrams': 60,
        },
        {
          'stepOrder': 2,
          'title': 'Main Pour',
          'durationSeconds': 150,
          'waterAddedGrams': 240,
        },
      ],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ApiService.clearMemoryCache();
  });

  group('Asset Bundle & Cover Resolution', () {
    test('All 28 grinders, covers, portraits, methods, and fallback decode cleanly', () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets();

      final coverAssets =
          assets.where((k) => k.startsWith('assets/images/avatars/covers/')).toList();
      final portraitAssets =
          assets.where((k) => k.startsWith('assets/images/avatars/portraits/')).toList();
      final methodAssets =
          assets.where((k) => k.startsWith('assets/images/methods/')).toList();

      expect(coverAssets.length, greaterThanOrEqualTo(51));
      expect(portraitAssets.length, greaterThanOrEqualTo(85));
      expect(methodAssets.length, greaterThanOrEqualTo(18));
      expect(assets, contains('assets/images/avatars/generic_fallback.jpg'));
      expect(assets, contains('assets/images/avatars/covers/konstantinos_iatridis.jpg'));

      for (final g in BrewVisualCatalog.grinderModels) {
        expect(assets, contains(g.imagePath), reason: 'Missing ${g.imagePath}');
        final bytes = await rootBundle.load(g.imagePath);
        final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThan(0));
        expect(frame.image.height, greaterThan(0));
      }

      final konstBytes =
          await rootBundle.load('assets/images/avatars/covers/konstantinos_iatridis.jpg');
      final konstCodec =
          await ui.instantiateImageCodec(konstBytes.buffer.asUint8List());
      final konstFrame = await konstCodec.getNextFrame();
      expect(konstFrame.image.width, greaterThan(0));
    });

    test('RecipeCoverBackground cascades past generic fallback to portrait & method asset', () {
      final candidates = RecipeCoverBackground.buildCandidatePaths(
        coverImageUrl: 'assets/images/avatars/generic_fallback.jpg',
        portraitUrl: 'assets/images/avatars/portraits/konstantinos_iatridis.jpg',
        methodName: 'Hario V60',
      );
      expect(candidates, [
        'assets/images/avatars/portraits/konstantinos_iatridis.jpg',
        'assets/images/methods/hario_v60.png',
      ]);
    });
  });

  group('RecipeShareService Architecture', () {
    test('Builds clean brewingcoffee.vercel.app share URI & social formats', () {
      final recipe = _konstantinosRecipe();
      final uri = RecipeShareService.buildShareUri(recipe);

      expect(uri.scheme, 'https');
      expect(uri.host, 'brewingcoffee.vercel.app');
      expect(uri.queryParameters['recipe'], '2');
      expect(uri.queryParameters['author'], 'Konstantinos Iatridis');
      expect(uri.queryParameters['method'], 'Hario V60');
      expect(uri.queryParameters['dose'], '20g');
      expect(uri.queryParameters['water'], '300g');
      expect(uri.queryParameters['temp'], '92C');

      final wa = RecipeShareService.formatWhatsAppMessage(recipe);
      expect(wa, contains('https://brewingcoffee.vercel.app/'));
      expect(wa, contains('Konstantinos Iatridis'));
      expect(wa, contains('*20g*'));

      final threads = RecipeShareService.formatThreadsPost(recipe);
      expect(threads, contains('https://brewingcoffee.vercel.app/'));
      expect(threads, contains('#CoffeeLabs'));

      final ig = RecipeShareService.formatInstagramCaption(recipe);
      expect(ig, contains('https://brewingcoffee.vercel.app/'));
      expect(ig, contains('Hario V60'));
    });
  });

  group('RecipeDetail UI: No Top Print, Animated Pink-Red Love, Share & Cover', () {
    testWidgets(
      'Renders Konstantinos cover, removes top print icon, toggles persistent pink-red love, and opens social Share sheet at 375x780',
      (tester) async {
        tester.view.physicalSize = const Size(375, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: RecipeDetailScreen(recipeData: _konstantinosRecipe()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // 1. Cover header uses RecipeCoverBackground with Konstantinos cover asset
        final coverFinder = find.descendant(
          of: find.byType(RecipeDetailAppBar),
          matching: find.byType(RecipeCoverBackground),
        );
        expect(coverFinder, findsOneWidget);
        final coverWidget = tester.widget<RecipeCoverBackground>(coverFinder);
        expect(
          coverWidget.coverImageUrl,
          'assets/images/avatars/covers/konstantinos_iatridis.jpg',
        );

        // 2. Print button removed from Top AppBar, kept only in Bottom Bar
        expect(
          find.descendant(
            of: find.byType(RecipeDetailAppBar),
            matching: find.byIcon(CupertinoIcons.printer_fill),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(RecipeDetailBottomBar),
            matching: find.byIcon(CupertinoIcons.printer_fill),
          ),
          findsOneWidget,
        );

        // 3. Favorite heart button starts unfavorited, turns pink-red & stays active, then toggles off
        final heartFinder = find.byType(AnimatedFavoriteHeartButton);
        expect(heartFinder, findsOneWidget);
        expect(
          tester.widget<AnimatedFavoriteHeartButton>(heartFinder).isFavorite,
          isFalse,
        );
        expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);

        await tester.tap(heartFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          tester.widget<AnimatedFavoriteHeartButton>(heartFinder).isFavorite,
          isTrue,
        );
        final filledHeartIcon =
            tester.widget<Icon>(find.byIcon(CupertinoIcons.heart_fill));
        expect(filledHeartIcon.color, const Color(0xFFFF2E63));

        // Remains pink-red after settling
        await tester.pump(const Duration(seconds: 2));
        expect(
          tester.widget<AnimatedFavoriteHeartButton>(heartFinder).isFavorite,
          isTrue,
        );

        // Tap again to remove from favorites
        await tester.tap(heartFinder);
        await tester.pumpAndSettle();
        expect(
          tester.widget<AnimatedFavoriteHeartButton>(heartFinder).isFavorite,
          isFalse,
        );
        expect(find.byIcon(CupertinoIcons.heart), findsOneWidget);

        // 4. Share button in top bar opens RecipeShareSheet with WhatsApp, Instagram, Threads & landing link
        final shareBtn = find.descendant(
          of: find.byType(RecipeDetailAppBar),
          matching: find.byIcon(CupertinoIcons.share),
        );
        expect(shareBtn, findsOneWidget);
        await tester.tap(shareBtn);
        await tester.pumpAndSettle();

        expect(find.byType(RecipeShareSheet), findsOneWidget);
        expect(find.byType(RecipeShareCard), findsOneWidget);
        expect(find.text('WhatsApp'), findsOneWidget);
        expect(find.text('Instagram'), findsOneWidget);
        expect(find.text('Threads'), findsOneWidget);
        expect(find.text('Sosmed Lain'), findsOneWidget);
        expect(find.textContaining('brewingcoffee.vercel.app'), findsWidgets);
      },
    );
  });

  group('EditorGrinderSection & Picker Overflow/Fallback Safety', () {
    testWidgets('EditorGrinderSection & Picker render with zero overflow on 375x780 even with broken path',
        (tester) async {
      tester.view.physicalSize = const Size(375, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      const brokenGrinder = GrinderModel(
        id: 'broken_test',
        name: 'Grinder Super Panjang Ultra Presisi Testing Overflow Guard',
        brand: 'Test',
        typeDescription: 'Conical Burr 48mm Specialty Manual Grinder',
        imagePath: 'assets/images/grinders/nonexistent_grinder.png',
        isElectric: false,
        minClicks: 10,
        maxClicks: 40,
        defaultClicks: 22,
        micronsPerClick: 30,
        fineClick: 14,
        medFineClick: 18,
        mediumClick: 22,
        medCoarseClick: 26,
        coarseClick: 32,
      );

      final descCtrl = TextEditingController();
      addTearDown(descCtrl.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: EditorGrinderSection(
                selectedGrinder: brokenGrinder,
                selectedGrindPreset: 'Medium',
                currentClicks: 22,
                grindPresets: const [
                  {'label': 'Fine', 'desc': 'Espresso'},
                  {'label': 'Medium', 'desc': 'V60'},
                ],
                descController: descCtrl,
                onOpenGrinderPicker: () {},
                onPresetSelected: (_) {},
                onClicksChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(GrinderThumbnailImage), findsOneWidget);

      // Verify Picker modal opens & renders all 28 grinders without overflow
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => EditorGrinderPickerModal.show(
                  context: ctx,
                  selectedGrinder: BrewVisualCatalog.grinderModels.first,
                  onSelected: (_) {},
                ),
                child: const Text('Buka Picker'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Buka Picker'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Pilih Grinder Kopi'), findsOneWidget);
      expect(find.byType(GrinderThumbnailImage), findsWidgets);
    });
  });
}
