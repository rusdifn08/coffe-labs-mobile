import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/brew_methods/models/brew_method_item.dart';
import 'package:coffee_hub_mobile/services/user_brew_usage_service.dart';

void main() {
  group('UserBrewUsageService (Personalized Methods & Barista Spotlight)', () {
    test('sortMethodsByUserUsage prioritizes methods strictly descending by brew count (e.g. V60 5x, AeroPress 3x)', () {
      final mockHistory = [
        // Hario V60: 5x
        {'method': 'Hario V60 02', 'category': 'V60 Pour Over', 'title': 'V60 Sweet Pour'},
        {'method': 'V60 Switch', 'category': 'V60 Pour Over', 'title': 'V60 Immersion'},
        {'method': 'Hario V60', 'category': 'V60 Pour Over', 'title': 'Single-Pour Sweet V60'},
        {'method': 'Hario V60', 'category': 'V60 Pour Over', 'title': 'V60 Osmotic 4-Pour'},
        {'method': 'Hario V60', 'category': 'V60 Pour Over', 'title': 'V60 Championship'},
        // AeroPress: 3x
        {'method': 'AeroPress Inverted', 'category': 'AeroPress', 'title': 'Aeropress Champion'},
        {'method': 'AeroPress Standard', 'category': 'AeroPress', 'title': 'Aeropress Fine'},
        {'method': 'AeroPress', 'category': 'AeroPress', 'title': 'AeroPress Light'},
        // Japanese Drip: 2x
        {'method': 'Japanese Iced V60', 'category': 'Iced Pour Over', 'title': 'Japanese Drip Flash'},
        {'method': 'Japanese Drip', 'category': 'Iced Pour Over', 'title': 'Japanese Iced Sweetness'},
        // Vietnam Drip: 1x
        {'method': 'Vietnam Drip', 'category': 'Immersion & Drip', 'title': 'Classic Vietnamese Iced Phin'},
      ];

      final sorted = UserBrewUsageService.sortMethodsByUserUsage(
        BrewMethodItem.allMethods,
        mockHistory,
      );

      // V60 has 5 brews -> index 0, userBrewCount == 5
      expect(sorted[0].id, equals('hario_v60'));
      expect(sorted[0].userBrewCount, equals(5));

      // AeroPress has 3 brews -> index 1, userBrewCount == 3
      expect(sorted[1].id, equals('aeropress'));
      expect(sorted[1].userBrewCount, equals(3));

      // Japanese Drip has 2 brews -> index 2, userBrewCount == 2
      expect(sorted[2].id, equals('japanese_drip'));
      expect(sorted[2].userBrewCount, equals(2));

      // Vietnam Drip has 1 brew -> index 3, userBrewCount == 1
      expect(sorted[3].id, equals('vietnam_drip'));
      expect(sorted[3].userBrewCount, equals(1));
    });

    test('sortMethodsByUserUsage handles empty history with popular default ordering and 0 count', () {
      final sorted = UserBrewUsageService.sortMethodsByUserUsage(
        BrewMethodItem.allMethods,
        [],
      );

      expect(sorted.isNotEmpty, isTrue);
      expect(sorted[0].id, equals('hario_v60'));
      expect(sorted[0].userBrewCount, equals(0));
      expect(sorted[1].id, equals('aeropress'));
      expect(sorted[1].userBrewCount, equals(0));
    });

    test('sortBaristasByUserUsage prioritizes baristas strictly descending (e.g. Tetsu Kasuya 5x, Ryan Wibawa 3x)', () {
      final mockBaristas = [
        {'name': '% Arabica', 'author': '% Arabica', 'recipeCount': 2},
        {'name': '1/15 Coffee', 'author': '1/15 Coffee', 'recipeCount': 3},
        {'name': 'Alessandro Galtieri', 'author': 'Alessandro Galtieri (Italia)', 'recipeCount': 4},
        {'name': 'Ryan Wibawa', 'author': 'Ryan Wibawa 🇮🇩', 'recipeCount': 8},
        {'name': 'Tetsu Kasuya', 'author': 'Tetsu Kasuya 🇯🇵', 'recipeCount': 10},
        {'name': 'Konstantinos Iatridis', 'author': 'Konstantinos Iatridis 🇬🇷', 'recipeCount': 5},
        {'name': 'Mikael Jasin', 'author': 'Mikael Jasin 🇮🇩', 'recipeCount': 6},
      ];

      final mockHistory = [
        // Tetsu Kasuya 5x
        {'author': 'Tetsu Kasuya 🇯🇵', 'title': '4:6 Method'},
        {'author': 'Tetsu Kasuya', 'title': 'Neo Brew'},
        {'author': 'Tetsu Kasuya 🇯🇵', 'title': 'Single-Pour Sweet V60'},
        {'author': 'Tetsu Kasuya', 'title': 'Devil Switch'},
        {'author': 'Tetsu Kasuya', 'title': 'Championship Pour'},
        // Ryan Wibawa 3x
        {'author': 'Ryan Wibawa 🇮🇩', 'title': 'Osmotic Pour'},
        {'author': 'Ryan Wibawa', 'title': 'Gayo Natural'},
        {'author': 'Ryan Wibawa 🇮🇩', 'title': 'WBrC Osmotic'},
        // Konstantinos Iatridis 2x
        {'author': 'Konstantinos Iatridis 🇬🇷', 'title': 'Cryogenic Grind'},
        {'author': 'Konstantinos Iatridis', 'title': 'Frozen Beans'},
      ];

      final sorted = UserBrewUsageService.sortBaristasByUserUsage(
        mockBaristas,
        mockHistory,
      );

      // Tetsu Kasuya: 5x -> index 0
      expect(sorted[0]['name'], equals('Tetsu Kasuya'));
      expect(sorted[0]['userBrewCount'], equals(5));

      // Ryan Wibawa: 3x -> index 1
      expect(sorted[1]['name'], equals('Ryan Wibawa'));
      expect(sorted[1]['userBrewCount'], equals(3));

      // Konstantinos Iatridis: 2x -> index 2
      expect(sorted[2]['name'], equals('Konstantinos Iatridis'));
      expect(sorted[2]['userBrewCount'], equals(2));

      // Among 0-brew baristas, prestigious champion Mikael Jasin ranks above % Arabica and 1/15 Coffee
      final zeroBrews = sorted.sublist(3);
      expect(zeroBrews.first['name'], equals('Mikael Jasin'));
    });

    test('BrewMethodItem includes all 4 newly requested methods with valid assets', () {
      final methodIds = BrewMethodItem.allMethods.map((m) => m.id).toSet();

      expect(methodIds.contains('japanese_drip'), isTrue);
      expect(methodIds.contains('vietnam_drip'), isTrue);
      expect(methodIds.contains('origami_dripper'), isTrue);
      expect(methodIds.contains('turkish_coffee'), isTrue);

      final japanese = BrewMethodItem.allMethods.firstWhere((m) => m.id == 'japanese_drip');
      expect(japanese.imageAsset, equals('assets/images/methods/japanese_drip.png'));

      final vietnam = BrewMethodItem.allMethods.firstWhere((m) => m.id == 'vietnam_drip');
      expect(vietnam.imageAsset, equals('assets/images/methods/vietnam_drip.png'));

      final origami = BrewMethodItem.allMethods.firstWhere((m) => m.id == 'origami_dripper');
      expect(origami.imageAsset, equals('assets/images/methods/origami_dripper.png'));

      final turkish = BrewMethodItem.allMethods.firstWhere((m) => m.id == 'turkish_coffee');
      expect(turkish.imageAsset, equals('assets/images/methods/turkish_coffee.png'));
    });
  });
}
