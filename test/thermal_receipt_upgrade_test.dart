import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/services/receipt_print_service.dart';
import 'package:coffee_hub_mobile/services/receipt_settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockRecipe = {
    'id': 'test-recipe-123',
    'title': 'Melodrip Zero Bypass V60',
    'author': 'Elika Liftee',
    'method': 'Hario V60',
    'coffeeWeightGrams': 15,
    'totalWaterWeightGrams': 250,
    'grindSize': 'Fine',
    'waterTempCelsius': 95,
    'steps': [
      {'durationSeconds': 40, 'waterWeightGrams': 50},
      {'durationSeconds': 60, 'waterWeightGrams': 50},
      {'durationSeconds': 50, 'waterWeightGrams': 75},
      {'durationSeconds': 50, 'waterWeightGrams': 75},
    ],
  };

  group('Thermal Receipt Upgrade & Proportional Design Tests', () {
    test('Default Header has proportional layout with icon and store name', () {
      final text = ReceiptPrintService.generateThermalReceiptText(
        mockRecipe,
        tastingNotes: ['Balanced Sweetness', 'Clean Acidity', 'Aromatic Finish'],
      );

      expect(text, contains('☕ COFFEE LABS ☕'));
      expect(text, contains('SPECIALTY COFFEE HUB'));
      expect(text, contains('================================'));
      expect(text, contains('No. Sesi'));
    });

    test('Custom Store Name, Tagline, and Icon are applied properly', () {
      const customSettings = ReceiptSettings(
        storeName: 'ELIKA ROASTERS',
        tagline: 'ARTISAN SLOW BAR',
        icon: '👑',
        baristaName: 'Elika Head Brewer',
        footerNote: 'ENJOY YOUR COFFEE',
        subFooter: 'Handcrafted With Precision',
        socialHandle: '@elika.roasters',
        paperWidthMm: 58,
      );

      final text = ReceiptPrintService.generateThermalReceiptText(
        mockRecipe,
        settings: customSettings,
      );

      expect(text, contains('👑 ELIKA ROASTERS 👑'));
      expect(text, contains('ARTISAN SLOW BAR'));
      expect(text, contains('Barista:'));
      expect(text, contains('Elika Head Brewer'));
      expect(text, contains('ENJOY YOUR COFFEE'));
      expect(text, contains('IG: @elika.roasters'));
    });

    test('All parentheses (...) are eliminated from receipt output', () {
      final text = ReceiptPrintService.generateThermalReceiptText(
        mockRecipe,
        tastingNotes: ['Bright Citric', 'Jasmine Flower'],
      );

      // Verify that no parentheses remain in parameter labels or titles
      expect(text.contains('(Thermal POS)'), isFalse);
      expect(text.contains('(Dose)'), isFalse);
      expect(text.contains('(Yield)'), isFalse);
      expect(text.contains('(POUR PROFILE)'), isFalse);
      expect(text.contains('(TASTING NOTES)'), isFalse);

      // Verify clean replacement labels
      expect(text, contains('PARAMETER SEDUH:'));
      expect(text, contains('Dosis Kopi'));
      expect(text, contains('Total Air'));
      expect(text, contains('TAHAPAN TUANGAN:'));
      expect(text, contains('CATATAN RASA:'));
      expect(text, contains('Total 50g'));
      expect(text, contains('Total 250g'));

      // Ensure no '(' or ')' exists in the entire generated receipt text
      expect(text.contains('('), isFalse, reason: 'Tanda kurung buka "(" tidak boleh ada di struk');
      expect(text.contains(')'), isFalse, reason: 'Tanda kurung tutup ")" tidak boleh ada di struk');
    });

    test('generateReceiptPdf produces valid PDF byte array', () async {
      final pdfBytes = await ReceiptPrintService.generateReceiptPdf(
        mockRecipe,
        tastingNotes: ['Sweet Plum', 'Vanilla'],
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // Valid PDF files start with '%PDF-' header
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('ReceiptSettings model copyWith works properly', () {
      const initial = ReceiptSettings.defaultSettings;
      final updated = initial.copyWith(
        storeName: 'MY SPECIALTY CAFE',
        icon: '🌿',
      );

      expect(updated.storeName, equals('MY SPECIALTY CAFE'));
      expect(updated.icon, equals('🌿'));
      expect(updated.tagline, equals(initial.tagline));
    });
  });
}
