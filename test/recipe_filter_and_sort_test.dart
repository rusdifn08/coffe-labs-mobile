import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/recipe_feed/models/recipe_sort_option.dart';
import 'package:coffee_hub_mobile/features/recipe_feed/utils/recipe_filter_matcher.dart';
import 'package:coffee_hub_mobile/features/recipe_feed/widgets/recipe_feed_search_bar.dart';
import 'package:coffee_hub_mobile/features/recipe_feed/widgets/recipe_filter_modal.dart';
import 'package:coffee_hub_mobile/features/recipe_feed/widgets/recipe_sort_modal.dart';
import 'package:coffee_hub_mobile/utils/barista_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecipeSortOption & 5 Sort Categories Tests', () {
    test('RecipeSortOption has 5 sort categories plus defaultCurated', () {
      final options = RecipeSortOption.values;
      expect(options.length, 6);
      expect(options.contains(RecipeSortOption.defaultCurated), isTrue);
      expect(options.contains(RecipeSortOption.alphabetical), isTrue);
      expect(options.contains(RecipeSortOption.newest), isTrue);
      expect(options.contains(RecipeSortOption.fastestBrew), isTrue);
      expect(options.contains(RecipeSortOption.coffeeDose), isTrue);
      expect(options.contains(RecipeSortOption.baristaName), isTrue);
    });

    test('All sort categories have valid labels, descriptions and icons', () {
      for (final opt in RecipeSortOption.values) {
        expect(opt.label.isNotEmpty, isTrue);
        expect(opt.description.isNotEmpty, isTrue);
        expect(opt.icon, isNotNull);
      }
      expect(RecipeSortOption.alphabetical.label, contains('Abjad'));
      expect(RecipeSortOption.newest.label, contains('Terbaru'));
      expect(RecipeSortOption.fastestBrew.label, contains('Waktu Seduh'));
      expect(RecipeSortOption.coffeeDose.label, contains('Dosis Kopi'));
      expect(RecipeSortOption.baristaName.label, contains('Nama Barista'));
    });

    test('Recipe sorting algorithms work correctly on sample dataset', () {
      final sample = [
        {
          'id': '10',
          'title': 'V60 Kasuya 4:6',
          'author': 'Tetsu Kasuya',
          'totalTimeSeconds': 210,
          'coffeeWeightGrams': 20,
          'isCustom': false,
        },
        {
          'id': '25',
          'title': 'Aeropress Nordic Light',
          'author': 'Tim Wendelboe',
          'totalTimeSeconds': 90,
          'coffeeWeightGrams': 11,
          'isCustom': false,
        },
        {
          'id': '5',
          'title': 'Kalita Wave Cafe Flow',
          'author': 'Mikaela Wallgren',
          'totalTimeSeconds': 150,
          'coffeeWeightGrams': 15,
          'isCustom': true,
        },
      ];

      // 1. Abjad (A - Z)
      final sortedAlpha = List<Map<String, dynamic>>.from(sample)
        ..sort((a, b) => a['title'].toString().toLowerCase().compareTo(b['title'].toString().toLowerCase()));
      expect(sortedAlpha.first['title'], 'Aeropress Nordic Light');
      expect(sortedAlpha.last['title'], 'V60 Kasuya 4:6');

      // 2. Terbaru (Custom first, then highest ID)
      final sortedNewest = List<Map<String, dynamic>>.from(sample)
        ..sort((a, b) {
          final isCustomA = a['isCustom'] == true ? 1 : 0;
          final isCustomB = b['isCustom'] == true ? 1 : 0;
          if (isCustomA != isCustomB) return isCustomB.compareTo(isCustomA);
          return (int.tryParse(b['id'].toString()) ?? 0).compareTo(int.tryParse(a['id'].toString()) ?? 0);
        });
      expect(sortedNewest.first['title'], 'Kalita Wave Cafe Flow'); // custom
      expect(sortedNewest[1]['title'], 'Aeropress Nordic Light'); // id 25

      // 3. Waktu Seduh Tercepat
      final sortedFastest = List<Map<String, dynamic>>.from(sample)
        ..sort((a, b) => (a['totalTimeSeconds'] as int).compareTo(b['totalTimeSeconds'] as int));
      expect(sortedFastest.first['totalTimeSeconds'], 90);
      expect(sortedFastest.last['totalTimeSeconds'], 210);

      // 4. Dosis Kopi Terkecil
      final sortedDose = List<Map<String, dynamic>>.from(sample)
        ..sort((a, b) => (a['coffeeWeightGrams'] as int).compareTo(b['coffeeWeightGrams'] as int));
      expect(sortedDose.first['coffeeWeightGrams'], 11);
      expect(sortedDose.last['coffeeWeightGrams'], 20);

      // 5. Nama Barista (A - Z)
      final sortedBarista = List<Map<String, dynamic>>.from(sample)
        ..sort((a, b) => BaristaUtils.cleanName(a['author'].toString()).toLowerCase().compareTo(
            BaristaUtils.cleanName(b['author'].toString()).toLowerCase()));
      expect(sortedBarista.first['author'], 'Mikaela Wallgren');
      expect(sortedBarista.last['author'], 'Tim Wendelboe');
    });
  });

  group('RecipeFeedSearchBar & Sort Button Widget Tests', () {
    testWidgets('RecipeFeedSearchBar renders sort icon button without text next to filter button', (tester) async {
      bool filterTapped = false;
      bool sortTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeFeedSearchBar(
              activeFilterCount: 0,
              categories: const ['All', 'V60', 'Aeropress'],
              selectedCategory: 'All',
              selectedPourFilter: 'Semua',
              selectedDripperFilter: 'Semua',
              selectedBaristaFilter: 'Semua',
              selectedNoteFilter: 'Semua',
              selectedOriginFilter: 'Semua',
              onSearchChanged: (_) {},
              onOpenFilter: () => filterTapped = true,
              onOpenSort: () => sortTapped = true,
              isSortActive: false,
              onCategorySelected: (_) {},
              onRemovePourFilter: () {},
              onRemoveDripperFilter: () {},
              onRemoveBaristaFilter: () {},
              onRemoveNoteFilter: () {},
              onRemoveOriginFilter: () {},
              onResetAll: () {},
            ),
          ),
        ),
      );

      // Find Filter text and icon
      expect(find.text('Filter'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.slider_horizontal_3), findsOneWidget);

      // Find Sort icon button (icon without text)
      final sortIconFinder = find.byIcon(CupertinoIcons.arrow_up_arrow_down);
      expect(sortIconFinder, findsOneWidget);

      // Tap Sort icon
      await tester.tap(sortIconFinder);
      await tester.pump();
      expect(sortTapped, isTrue);

      // Tap Filter button
      await tester.tap(find.text('Filter'));
      await tester.pump();
      expect(filterTapped, isTrue);
    });

    testWidgets('Sort button highlights and active sort chip displays when sort is active', (tester) async {
      bool resetSortTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeFeedSearchBar(
              activeFilterCount: 0,
              categories: const ['All'],
              selectedCategory: 'All',
              selectedPourFilter: 'Semua',
              selectedDripperFilter: 'Semua',
              selectedBaristaFilter: 'Semua',
              selectedNoteFilter: 'Semua',
              selectedOriginFilter: 'Semua',
              onSearchChanged: (_) {},
              onOpenFilter: () {},
              onOpenSort: () {},
              isSortActive: true,
              activeSortLabel: 'Abjad (A - Z)',
              onResetSort: () => resetSortTapped = true,
              onCategorySelected: (_) {},
              onRemovePourFilter: () {},
              onRemoveDripperFilter: () {},
              onRemoveBaristaFilter: () {},
              onRemoveNoteFilter: () {},
              onRemoveOriginFilter: () {},
              onResetAll: () {},
            ),
          ),
        ),
      );

      // Should display active chip with 'Abjad (A - Z)'
      expect(find.text('Abjad (A - Z)'), findsOneWidget);

      // Tap chip delete icon to reset sort
      final closeIcon = find.descendant(
        of: find.byType(Row),
        matching: find.byIcon(CupertinoIcons.xmark_circle_fill),
      );
      expect(closeIcon, findsWidgets);
      await tester.tap(closeIcon.first);
      await tester.pump();
      expect(resetSortTapped, isTrue);
    });
  });

  group('RecipeFilterModal & RecipeSortModal Interaction Tests', () {
    testWidgets('RecipeSortModal allows selecting a category and triggers callback', (tester) async {
      RecipeSortOption? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  RecipeSortModal.show(
                    context: context,
                    currentSort: RecipeSortOption.defaultCurated,
                    onSortSelected: (opt) => selected = opt,
                  );
                },
                child: const Text('Open Sort'),
              ),
            ),
          ),
        ),
      );

      // Open Modal
      await tester.tap(find.text('Open Sort'));
      await tester.pumpAndSettle();

      // Check that 5 categories are displayed
      expect(find.text('Abjad (A - Z)'), findsOneWidget);
      expect(find.text('Terbaru'), findsOneWidget);
      expect(find.text('Waktu Seduh Tercepat'), findsOneWidget);
      expect(find.text('Dosis Kopi (Terkecil)'), findsOneWidget);
      expect(find.text('Nama Barista (A - Z)'), findsOneWidget);

      // Tap 'Waktu Seduh Tercepat'
      await tester.tap(find.text('Waktu Seduh Tercepat'));
      await tester.pumpAndSettle();

      expect(selected, RecipeSortOption.fastestBrew);
    });

    testWidgets(
      'RecipeFilterModal renders Metode Seduh 3D, core Tasting Notes, flag-only Indonesia, bottom +/- Pouring stepper, and removes Barista & Teknik Seduh',
      (tester) async {
        tester.view.physicalSize = const Size(375, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        Map<String, String>? appliedFilters;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    RecipeFilterModal.show(
                      context: context,
                      selectedPourFilter: 'Semua',
                      selectedDripperFilter: 'Semua',
                      selectedOriginFilter: 'Semua',
                      selectedNoteFilter: 'Semua',
                      onApplyFilters: ({
                        required String pourFilter,
                        required String dripperFilter,
                        required String baristaFilter,
                        required String category,
                        required String originFilter,
                        required String noteFilter,
                        required String noteCategoryTab,
                      }) {
                        appliedFilters = {
                          'pour': pourFilter,
                          'dripper': dripperFilter,
                          'barista': baristaFilter,
                          'category': category,
                          'origin': originFilter,
                          'note': noteFilter,
                          'tab': noteCategoryTab,
                        };
                      },
                      onResetAll: () {},
                    );
                  },
                  child: const Text('Open Filter'),
                ),
              ),
            ),
          ),
        );

        // Open Filter Modal
        await tester.tap(find.text('Open Filter'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // 1. Metode Seduh replaces Pilih Dripper; Barista & Teknik Seduh are removed
        expect(find.text('Metode Seduh'), findsOneWidget);
        expect(find.textContaining('Pilih Dripper'), findsNothing);
        expect(find.textContaining('Pilih Barista'), findsNothing);
        expect(find.textContaining('Teknik Seduh'), findsNothing);

        // 2. No preset pour choice chips; only +/- stepper at the bottom
        expect(find.text('1-2x Pour'), findsNothing);
        expect(find.text('Full Immersion'), findsNothing);
        expect(find.text('5x+ Pouring'), findsNothing);

        // 3. Streamlined core Tasting Notes
        expect(find.text('Floral'), findsOneWidget);
        expect(find.text('Fruity'), findsOneWidget);
        expect(find.text('Chocolaty'), findsOneWidget);

        // Select 'Aeropress' 3D method & 'Floral' note
        await tester.tap(find.text('Aeropress'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Floral'));
        await tester.pumpAndSettle();

        // 4. Flag-only Indonesia button (no verbose 'Barista Indonesia' text)
        final modalVerticalScrollable = find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        );
        expect(find.textContaining('Barista Indonesia'), findsNothing);
        final indoFlagBtn = find.byKey(const Key('origin_indonesia_flag_btn'));
        await tester.scrollUntilVisible(
          indoFlagBtn,
          150,
          scrollable: modalVerticalScrollable.first,
        );
        await tester.pumpAndSettle();
        expect(indoFlagBtn, findsOneWidget);
        expect(
          find.descendant(of: indoFlagBtn, matching: find.byType(BaristaFlagBadge)),
          findsOneWidget,
        );
        await tester.tap(indoFlagBtn);
        await tester.pumpAndSettle();

        // 5. Jumlah Pouring at bottom (below Asal Barista & Durasi) with only - and +
        final pourTitleFinder = find.text('Jumlah Pouring');
        await tester.scrollUntilVisible(
          pourTitleFinder,
          150,
          scrollable: modalVerticalScrollable.first,
        );
        await tester.pumpAndSettle();
        final originTitleY = tester.getTopLeft(find.text('Asal Barista & Durasi')).dy;
        final pourTitleY = tester.getTopLeft(pourTitleFinder).dy;
        expect(pourTitleY, greaterThan(originTitleY));

        final incBtn = find.byKey(const Key('pour_increment_btn'));
        final decBtn = find.byKey(const Key('pour_decrement_btn'));
        await tester.scrollUntilVisible(
          incBtn,
          150,
          scrollable: modalVerticalScrollable.first,
        );
        await tester.pumpAndSettle();

        // Tap + three times -> 3x, then - once -> 2x
        await tester.tap(incBtn);
        await tester.tap(incBtn);
        await tester.tap(incBtn);
        await tester.pumpAndSettle();
        expect(find.text('3x'), findsOneWidget);

        await tester.tap(decBtn);
        await tester.pumpAndSettle();
        expect(find.text('2x'), findsOneWidget);

        // Apply filters
        final applyButton = find.textContaining('Terapkan Filter');
        expect(applyButton, findsOneWidget);
        await tester.tap(applyButton);
        await tester.pumpAndSettle();

        expect(appliedFilters, isNotNull);
        expect(appliedFilters!['dripper'], 'AeroPress');
        expect(appliedFilters!['note'], 'Floral');
        expect(appliedFilters!['origin'], 'Indonesia');
        expect(appliedFilters!['pour'], '2x Pour');
      },
    );

    test('RecipeFilterMatcher handles exact numeric pours, 3D methods, and core tasting notes', () {
      final v60Recipe = {
        'title': 'Kasuya V60 Floral',
        'method': 'Hario V60',
        'category': 'V60 Pour Over',
        'tastingNotes': 'Jasmine, White Peach, Milk Chocolate',
        'steps': [
          {'title': 'Bloom', 'waterAddedGrams': 40, 'durationSeconds': 30},
          {'title': 'Pour 2', 'waterAddedGrams': 100, 'durationSeconds': 45},
          {'title': 'Pour 3', 'waterAddedGrams': 100, 'durationSeconds': 45},
        ],
      };

      expect(RecipeFilterMatcher.matchesPour(v60Recipe, '3x Pour'), isTrue);
      expect(RecipeFilterMatcher.matchesPour(v60Recipe, '2x Pour'), isFalse);
      expect(RecipeFilterMatcher.matchesDripper(v60Recipe, 'V60'), isTrue);
      expect(RecipeFilterMatcher.matchesDripper(v60Recipe, 'AeroPress'), isFalse);
      expect(RecipeFilterMatcher.matchesNote(v60Recipe, 'Floral'), isTrue);
      expect(RecipeFilterMatcher.matchesNote(v60Recipe, 'Fruity'), isTrue);
      expect(RecipeFilterMatcher.matchesNote(v60Recipe, 'Chocolaty'), isTrue);
      expect(RecipeFilterMatcher.matchesNote(v60Recipe, 'Nutty'), isFalse);
    });
  });
}
