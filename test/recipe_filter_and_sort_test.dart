import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/recipe_feed/models/recipe_sort_option.dart';
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

    testWidgets('RecipeFilterModal properly calls onApplyFilters with selected criteria', (tester) async {
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
                    selectedBaristaFilter: 'Semua',
                    selectedCategory: 'All',
                    selectedOriginFilter: 'Semua',
                    selectedNoteFilter: 'Semua',
                    selectedNoteCategoryTab: 'floral',
                    uniqueBaristas: const [],
                    categories: const ['All', 'V60', 'Aeropress'],
                    pourFilterOptions: const ['Semua', 'Single Pour', '2x Pouring'],
                    originFilterOptions: const ['Semua', 'Indonesia 🇮🇩'],
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

      // Select 'Single Pour'
      expect(find.text('Single Pour'), findsOneWidget);
      await tester.tap(find.text('Single Pour'));
      await tester.pumpAndSettle();

      // Tap 'Terapkan Filter'
      final applyButton = find.textContaining('Terapkan Filter');
      expect(applyButton, findsOneWidget);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Verify that appliedFilters was called with 'Single Pour'
      expect(appliedFilters, isNotNull);
      expect(appliedFilters!['pour'], 'Single Pour');
    });
  });
}
