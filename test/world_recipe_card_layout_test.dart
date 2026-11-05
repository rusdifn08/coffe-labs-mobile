import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/recipe_feed/widgets/recipe_feed_grid_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleRecipe1LineTitle = {
    'id': 1,
    'title': 'Caffè Breve',
    'author': 'American Specialty Barista 🇺🇸',
    'category': 'Espresso Based',
    'grindSize': 'Fine',
    'coffeeWeightGrams': 18,
    'totalWaterWeightGrams': 190,
    'iceWeightGrams': 0,
    'description': 'Varian latte gaya Amerika ultra creamy. Double espresso berpadu half-and-half steamed.',
    'tastingNotes': 'Caramel,Creamy,Rich',
    'steps': [
      {'stepOrder': 1, 'title': 'Extraction', 'durationSeconds': 25, 'waterAddedGrams': 36},
    ],
  };

  final sampleRecipe2LineTitle = {
    'id': 2,
    'title': 'Cafelat Robot Pure Manual Lever 6-Bar',
    'author': 'Paul Pratt 🇬🇧',
    'category': 'Manual Lever Espresso',
    'grindSize': 'Fine Espresso',
    'coffeeWeightGrams': 18,
    'totalWaterWeightGrams': 40,
    'iceWeightGrams': 0,
    'description': 'Desain lever mekanik legendaris tanpa kebutuhan listrik.',
    'tastingNotes': 'Chocolate,Floral',
    'steps': [
      {'stepOrder': 1, 'title': 'Pre-infusion', 'durationSeconds': 10, 'waterAddedGrams': 20},
      {'stepOrder': 2, 'title': 'Extraction', 'durationSeconds': 25, 'waterAddedGrams': 20},
    ],
  };

  Widget buildTestCard(Map<String, dynamic> recipe) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 175,
            height: 208,
            child: RecipeFeedGridCard(
              rawRecipe: recipe,
              index: 0,
              isTrial: false,
              onTap: () {},
              onBaristaTap: () {},
              onTrialLocked: () {},
            ),
          ),
        ),
      ),
    );
  }

  group('World Recipes Grid Card Uniform Layout Tests', () {
    testWidgets('Does not display recipe description in the card', (tester) async {
      await tester.pumpWidget(buildTestCard(sampleRecipe1LineTitle));
      await tester.pumpAndSettle();

      // Description must NOT exist in the card
      expect(find.text(sampleRecipe1LineTitle['description'] as String), findsNothing);
      expect(find.textContaining('Varian latte gaya Amerika'), findsNothing);
    });

    testWidgets('Renders 1-line title inside Container with height 36 and Alignment.centerLeft', (tester) async {
      await tester.pumpWidget(buildTestCard(sampleRecipe1LineTitle));
      await tester.pumpAndSettle();

      expect(find.text('Caffè Breve'), findsOneWidget);

      final titleContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Caffè Breve'),
          matching: find.byType(Container),
        ).first,
      );

      final constraints = titleContainer.constraints;
      expect(constraints?.minHeight, 36.0);
      expect(constraints?.maxHeight, 36.0);
      expect(titleContainer.alignment, Alignment.centerLeft);
    });

    testWidgets('Renders 2-line title inside Container with height 36 and Alignment.centerLeft', (tester) async {
      await tester.pumpWidget(buildTestCard(sampleRecipe2LineTitle));
      await tester.pumpAndSettle();

      expect(find.text('Cafelat Robot Pure Manual Lever 6-Bar'), findsOneWidget);

      final titleContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Cafelat Robot Pure Manual Lever 6-Bar'),
          matching: find.byType(Container),
        ).first,
      );

      final constraints = titleContainer.constraints;
      expect(constraints?.minHeight, 36.0);
      expect(constraints?.maxHeight, 36.0);
      expect(titleContainer.alignment, Alignment.centerLeft);
    });

    testWidgets('Contains brewer name, tasting notes row, category & grind, and Brew button', (tester) async {
      await tester.pumpWidget(buildTestCard(sampleRecipe1LineTitle));
      await tester.pumpAndSettle();

      // Brewer name
      expect(find.text('American Specialty Barista'), findsOneWidget);

      // Tasting notes / pour counter
      expect(find.text('1x Pour'), findsOneWidget);

      // Category and grind
      expect(find.text('Espresso Based'), findsOneWidget);
      expect(find.text('Fine'), findsOneWidget);

      // Brew button
      expect(find.text('Brew'), findsOneWidget);
    });
  });
}
