import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/services/recipe_sanitizer.dart';
import 'package:coffee_hub_mobile/utils/barista_utils.dart';
import 'package:coffee_hub_mobile/features/recipe_feed/widgets/recipe_feed_grid_card.dart';
import 'package:flutter/material.dart';

void main() {
  group('Brewer Avatar & Cover Resolution Tests', () {
    test('BaristaUtils.imageUrlFromRecipe resolves real portraits for Indonesian champions', () {
      final pepengRecipe = {
        'title': 'V60 Tenang Tanpa Agitasi (Gaya Klinik Kopi)',
        'author': 'Pepeng (Klinik Kopi) 🇮🇩',
        'authorAvatarUrl': 'assets/images/avatars/avatar_6.jpg', // stale reference
      };
      final resolvedPepeng = BaristaUtils.imageUrlFromRecipe(pepengRecipe);
      expect(resolvedPepeng, equals('assets/images/avatars/portraits/pepeng_klinik_kopi.jpg'));

      final wisnuRecipe = {
        'title': 'Indonesia AeroPress Championship Inverted Recipe',
        'author': 'Wisnu Aji 🇮🇩',
        'authorAvatarUrl': 'assets/images/avatars/generic_fallback.jpg',
      };
      final resolvedWisnu = BaristaUtils.imageUrlFromRecipe(wisnuRecipe);
      expect(resolvedWisnu, equals('assets/images/avatars/portraits/wisnu_aji.jpg'));

      final melvinRecipe = {
        'title': 'Origami Sensory Bali Kintamani Natural',
        'author': 'Melvin (Fugol Coffee) 🇮🇩',
      };
      final resolvedMelvin = BaristaUtils.imageUrlFromRecipe(melvinRecipe);
      expect(resolvedMelvin, equals('assets/images/avatars/portraits/melvin_fugol.jpg'));

      final mirzaRecipe = {
        'title': 'V60 Osmotic Flow Toraja Sapan',
        'author': 'Mirza Luqman 🇮🇩',
      };
      final resolvedMirza = BaristaUtils.imageUrlFromRecipe(mirzaRecipe);
      expect(resolvedMirza, equals('assets/images/avatars/portraits/mirza_luqman.jpg'));
    });

    test('BaristaUtils.coverUrlFromRecipe resolves real covers for champions', () {
      final pepengRecipe = {
        'title': 'V60 Tenang Tanpa Agitasi (Gaya Klinik Kopi)',
        'author': 'Pepeng (Klinik Kopi) 🇮🇩',
        'coverImageUrl': 'assets/images/avatars/covers/wataru_iidaka.jpg', // mismatched cover
      };
      final resolvedCover = BaristaUtils.coverUrlFromRecipe(pepengRecipe);
      expect(resolvedCover, equals('assets/images/avatars/covers/pepeng_klinik_kopi.jpg'));
    });

    test('RecipeSanitizer automatically upgrades stale authorAvatarUrl and mismatched coverImageUrl', () {
      final rawRecipe = {
        'id': 117,
        'title': 'V60 Tenang Tanpa Agitasi (Gaya Klinik Kopi)',
        'author': 'Pepeng (Klinik Kopi) 🇮🇩',
        'coverImageUrl': 'assets/images/avatars/covers/wataru_iidaka.jpg',
        'authorAvatarUrl': 'assets/images/avatars/avatar_6.jpg',
      };
      final sanitized = RecipeSanitizer.sanitizeRecipe(rawRecipe);
      expect(sanitized['authorAvatarUrl'], equals('assets/images/avatars/portraits/pepeng_klinik_kopi.jpg'));
      expect(sanitized['coverImageUrl'], equals('assets/images/avatars/covers/pepeng_klinik_kopi.jpg'));
    });

    testWidgets('RecipeFeedGridCard passes resolved portrait to BaristaAvatar', (tester) async {
      final recipe = {
        'id': 117,
        'title': 'V60 Tenang Tanpa Agitasi (Gaya Klinik Kopi)',
        'author': 'Pepeng (Klinik Kopi) 🇮🇩',
        'authorAvatarUrl': 'assets/images/avatars/avatar_6.jpg', // legacy dummy
        'coffeeWeightGrams': 15,
        'totalWaterWeightGrams': 225,
        'totalTimeSeconds': 140,
        'category': 'V60',
        'description': 'Filosofi Klinik Kopi',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
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

      final avatarFinder = find.byType(BaristaAvatar);
      expect(avatarFinder, findsOneWidget);
      final baristaAvatar = tester.widget<BaristaAvatar>(avatarFinder);
      expect(baristaAvatar.imageUrl, equals('assets/images/avatars/portraits/pepeng_klinik_kopi.jpg'));
    });

    testWidgets('RecipeFeedGridCard safely renders recipes with double coffeeWeightGrams (e.g. 12.5g)', (tester) async {
      final recipeWithDouble = {
        'id': 185,
        'title': 'Kreator Double Bloom - Double-Blooming V60 Clean & Sweet 12.5g',
        'author': 'Kreator Double Bloom 🇮🇩',
        'coffeeWeightGrams': 12.5,
        'totalWaterWeightGrams': 200.0,
        'iceWeightGrams': 0.0,
        'totalTimeSeconds': 130,
        'category': 'V60',
        'description': 'Resep rasio presisi',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: RecipeFeedGridCard(
                rawRecipe: recipeWithDouble,
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

      expect(tester.takeException(), isNull);
      expect(find.text('12.5g'), findsOneWidget);
    });
  });
}
