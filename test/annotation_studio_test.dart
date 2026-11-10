import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:coffee_hub_mobile/features/annotation_studio/domain/models/coffee_annotation_class.dart';
import 'package:coffee_hub_mobile/features/annotation_studio/domain/models/studio_image_item.dart';
import 'package:coffee_hub_mobile/features/annotation_studio/domain/services/coffee_bag_segmenter_service.dart';
import 'package:coffee_hub_mobile/features/annotation_studio/domain/services/coffee_ocr_parser_service.dart';
import 'package:coffee_hub_mobile/features/annotation_studio/domain/services/non_coffee_gatekeeper_service.dart';
import 'package:coffee_hub_mobile/features/annotation_studio/data/local/studio_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('1. Non-Coffee Gatekeeper (OOD / Invalid Media Filter) Tests', () {
    const int imgW = 1000;
    const int imgH = 1000;

    test('Valid Coffee Bag Pouch passes all 4 gatekeeper conditions', () {
      final bbox = Rect.fromLTWH(200, 150, 600, 700); // w=600, h=700, aspect=0.85, area=0.42
      final poly = [
        const Offset(270, 150),
        const Offset(730, 150),
        const Offset(800, 206),
        const Offset(800, 800),
        const Offset(750, 850),
        const Offset(250, 850),
        const Offset(200, 800),
        const Offset(200, 206),
      ];

      final result = NonCoffeeGatekeeperService.evaluate(
        boundingBox: bbox,
        polygonPoints: poly,
        imageWidth: imgW,
        imageHeight: imgH,
        detectionConfidence: 0.88,
        detectedTextLines: ['Fugol Coffee', 'Halu Banana', 'Wine'],
      );

      expect(result.isValidCoffeeBag, isTrue);
      expect(result.rejectionReason, isNull);
      expect(result.areaRatio, inInclusiveRange(0.025, 0.95));
      expect(result.aspectRatio, inInclusiveRange(0.20, 2.40));
      expect(result.solidity, greaterThanOrEqualTo(0.62));
    });

    test('Rejects tiny noise/dust below minimum area ratio (area < 2.5%)', () {
      final bbox = Rect.fromLTWH(100, 100, 80, 80); // area = 6400 / 1,000,000 = 0.64%
      final poly = [
        const Offset(100, 100),
        const Offset(180, 100),
        const Offset(180, 180),
        const Offset(100, 180),
      ];

      final result = NonCoffeeGatekeeperService.evaluate(
        boundingBox: bbox,
        polygonPoints: poly,
        imageWidth: imgW,
        imageHeight: imgH,
        detectionConfidence: 0.75,
      );

      expect(result.isValidCoffeeBag, isFalse);
      expect(result.rejectionReason, contains('Area Ratio tidak wajar'));
    });

    test('Rejects ultra-wide non-bag objects (aspect ratio > 2.40)', () {
      final bbox = Rect.fromLTWH(50, 400, 900, 200); // aspect ratio = 4.5
      final poly = [
        const Offset(50, 400),
        const Offset(950, 400),
        const Offset(950, 600),
        const Offset(50, 600),
      ];

      final result = NonCoffeeGatekeeperService.evaluate(
        boundingBox: bbox,
        polygonPoints: poly,
        imageWidth: imgW,
        imageHeight: imgH,
        detectionConfidence: 0.80,
      );

      expect(result.isValidCoffeeBag, isFalse);
      expect(result.rejectionReason, contains('Aspect Ratio bukan kemasan kantong/pouch'));
    });

    test('Rejects low visual confidence below detection threshold', () {
      final bbox = Rect.fromLTWH(200, 200, 500, 600);
      final poly = [
        const Offset(200, 200),
        const Offset(700, 200),
        const Offset(700, 800),
        const Offset(200, 800),
      ];

      final result = NonCoffeeGatekeeperService.evaluate(
        boundingBox: bbox,
        polygonPoints: poly,
        imageWidth: imgW,
        imageHeight: imgH,
        detectionConfidence: 0.25, // < 0.42 default
      );

      expect(result.isValidCoffeeBag, isFalse);
      expect(result.rejectionReason, contains('Visual Confidence terlalu rendah'));
    });
  });

  group('2. Coffee Packaging OCR & Semantic Slug Generator Tests', () {
    final existingClasses = [
      'fugol_halubanana_wine',
      'twentyfr_acehgayo_natural',
      'anomali_torajasapan_washed',
      'tanamera_balikintamani_honey',
      'wanoja_watermelonsmash_anaerobicnatural',
    ];

    test('Extracts canonical {brand}_{nama_kopi}_{proses} from raw OCR text lines', () {
      final ocrRegions = [
        const OcrTextRegion(text: 'Fugol Coffee Roasters', confidence: 0.95, yRel: 0.15, fontHeight: 32),
        const OcrTextRegion(text: 'Halu Banana', confidence: 0.98, yRel: 0.45, fontHeight: 48),
        const OcrTextRegion(text: 'Natural Wine Process', confidence: 0.92, yRel: 0.65, fontHeight: 24),
        const OcrTextRegion(text: '200g Whole Bean', confidence: 0.90, yRel: 0.85, fontHeight: 16),
      ];

      final result = CoffeePackagingOcrEngine.parseCoffeeEntities(
        ocrRegions: ocrRegions,
        existingClasses: existingClasses,
      );

      expect(result.brand, equals('fugol'));
      expect(result.coffeeName, equals('halubanana'));
      expect(result.process, equals('wine'));
      expect(result.generatedSlug, equals('fugol_halubanana_wine'));
      expect(result.isNewClass, isFalse); // Matches existing class >= 0.85
      expect(result.matchedExistingClass, equals('fugol_halubanana_wine'));
      expect(result.similarityScore, greaterThanOrEqualTo(0.85));
    });

    test('Identifies newly discovered coffee packaging and marks isNewClass = true', () {
      final ocrRegions = [
        const OcrTextRegion(text: '5758 Coffee Lab', confidence: 0.95, yRel: 0.12, fontHeight: 28),
        const OcrTextRegion(text: 'Gunung Puntang', confidence: 0.97, yRel: 0.40, fontHeight: 44),
        const OcrTextRegion(text: 'Anaerobic Washed', confidence: 0.93, yRel: 0.60, fontHeight: 26),
      ];

      final result = CoffeePackagingOcrEngine.parseCoffeeEntities(
        ocrRegions: ocrRegions,
        existingClasses: existingClasses,
      );

      expect(result.brand, equals('5758'));
      expect(result.coffeeName, equals('gunungpuntang'));
      expect(result.process, equals('anaerobicwashed'));
      expect(result.generatedSlug, equals('5758_gunungpuntang_anaerobicwashed'));
      expect(result.isNewClass, isTrue);
    });

    test('Strips packaging stopwords (netto, p-irt, 100% arabica, roast date)', () {
      final ocrRegions = [
        const OcrTextRegion(text: 'TwentyFR', confidence: 0.95, yRel: 0.15, fontHeight: 30),
        const OcrTextRegion(text: '100% Arabica Aceh Gayo Specialty Coffee', confidence: 0.95, yRel: 0.45, fontHeight: 40),
        const OcrTextRegion(text: 'Netto 250gr P-IRT 123456 Halal', confidence: 0.88, yRel: 0.70, fontHeight: 18),
        const OcrTextRegion(text: 'Dry Process Natural', confidence: 0.91, yRel: 0.80, fontHeight: 22),
      ];

      final result = CoffeePackagingOcrEngine.parseCoffeeEntities(
        ocrRegions: ocrRegions,
        existingClasses: existingClasses,
      );

      expect(result.brand, equals('twentyfr'));
      expect(result.coffeeName, equals('acehgayo'));
      expect(result.process, equals('natural'));
      expect(result.generatedSlug, equals('twentyfr_acehgayo_natural'));
      expect(result.isNewClass, isFalse);
    });
  });

  group('3. Coffee Bag Segmenter & RDP Simplification Tests', () {
    test('RDP algorithm simplifies complex path while preserving endpoints', () {
      final points = [
        const Offset(0, 0),
        const Offset(10, 1),
        const Offset(20, -1),
        const Offset(50, 20),
        const Offset(80, 19),
        const Offset(100, 0),
      ];

      final simplified = CoffeeBagSegmenterService.simplifyRdp(points, 5.0);
      expect(simplified.length, lessThan(points.length));
      expect(simplified.first, equals(points.first));
      expect(simplified.last, equals(points.last));
    });

    test('generateContouredPouchPolygon produces bounded points in [0.0 - 1.0]', () {
      const box = Rect.fromLTWH(0.2, 0.15, 0.6, 0.7);
      final poly = CoffeeBagSegmenterService.generateContouredPouchPolygon(box);

      expect(poly.length, greaterThanOrEqualTo(4));
      for (final p in poly) {
        expect(p.dx, inInclusiveRange(0.0, 1.0));
        expect(p.dy, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('4. Studio SQLite Database Persistence Tests', () {
    test('Can insert, query, and filter studio images and classes', () async {
      await StudioDatabase.clearAll();

      final cls = CoffeeAnnotationClass(
        classSlug: 'fugol_halubanana_wine',
        displayName: 'Fugol Halu Banana Wine',
        colorHex: '#8B5CF6',
        brand: 'fugol',
        coffeeName: 'halubanana',
        process: 'wine',
        createdAt: DateTime.now(),
      );
      await StudioDatabase.upsertClass(cls);

      final imgValid = StudioImageItem(
        filePath: 'test/sample_bag.jpg',
        status: 'annotated',
        classSlug: 'fugol_halubanana_wine',
        brand: 'fugol',
        coffeeName: 'halubanana',
        process: 'wine',
        createdAt: DateTime.now(),
      );
      final idValid = await StudioDatabase.insertImage(imgValid);
      expect(idValid, greaterThan(0));

      final imgRejected = StudioImageItem(
        filePath: 'test/empty_table.jpg',
        status: 'rejected_non_coffee',
        isRejected: true,
        rejectionReason: 'Solidity Poligon terlalu rendah',
        createdAt: DateTime.now(),
      );
      final idRejected = await StudioDatabase.insertImage(imgRejected);
      expect(idRejected, greaterThan(0));

      final allImages = await StudioDatabase.getAllImages();
      expect(allImages.length, equals(2));

      final annotated = await StudioDatabase.getAllImages(filterTab: 'annotated');
      expect(annotated.length, equals(1));
      expect(annotated.first.classSlug, equals('fugol_halubanana_wine'));

      final rejected = await StudioDatabase.getAllImages(filterTab: 'rejected');
      expect(rejected.length, equals(1));
      expect(rejected.first.isRejected, isTrue);

      final deleted = await StudioDatabase.deleteAllRejectedImages();
      expect(deleted, equals(1));

      final remaining = await StudioDatabase.getAllImages();
      expect(remaining.length, equals(1));
      expect(remaining.first.status, equals('annotated'));
    });
  });
}
