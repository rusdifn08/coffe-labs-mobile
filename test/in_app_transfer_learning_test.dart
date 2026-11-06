import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coffee_hub_mobile/features/in_app_trainer/domain/class_slug_generator.dart';
import 'package:coffee_hub_mobile/features/in_app_trainer/domain/trained_coffee_class_model.dart';
import 'package:coffee_hub_mobile/features/in_app_trainer/services/on_device_transfer_learner.dart';
import 'package:coffee_hub_mobile/features/in_app_trainer/services/trained_coffee_storage_service.dart';
import 'package:coffee_hub_mobile/features/in_app_trainer/services/visual_bag_embedder.dart';

void main() {
  group('In-App Transfer Learning - Slug Generator', () {
    test('generate cleans noise, roastery stop words, and generates snake_case slug', () {
      final slug = ClassSlugGenerator.generate(
        brand: 'Two Hands Roastery & Coffee Co.',
        beanName: 'Kamojang Specialty Apple Cider',
        process: 'Anaerobic Natural',
      );

      expect(slug, contains('two_hands'));
      expect(slug, contains('kamojang'));
      expect(slug, contains('natural'));
      expect(slug.contains(' '), isFalse);
      expect(slug.contains('&'), isFalse);
    });

    test('generate handles edge-cases with fallback', () {
      final slug = ClassSlugGenerator.generate(
        brand: '',
        beanName: '',
        process: '',
      );
      expect(slug, equals('custom_coffee_bean'));
    });
  });

  group('In-App Transfer Learning - Domain & Storage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('TrainedCoffeeClassModel serializes and deserializes correctly', () async {
      final dummyWeights = List<double>.generate(VisualBagEmbedder.dim, (i) => i * 0.001);
      final dummySub = [
        List<double>.generate(VisualBagEmbedder.dim, (i) => (i + 1) * 0.001),
      ];

      final model = TrainedCoffeeClassModel(
        classSlug: 'twohands_kamojang_natural',
        displayTitle: 'Two Hands - Kamojang Natural',
        weightsVector: dummyWeights,
        subCentroids: dummySub,
        cosineThreshold: 0.82,
        augmentedSampleCount: 45,
        validationAccuracy: 0.96,
        ocrSignatureTokens: ['twohands', 'kamojang', 'cider'],
        coffeeMetadata: {
          'brand': 'Two Hands',
          'bean_name': 'Kamojang',
          'process': 'Natural',
        },
        createdAt: DateTime.parse('2026-11-06T00:00:00Z'),
      );

      final jsonMap = model.toJson();
      final revived = TrainedCoffeeClassModel.fromJson(jsonMap);

      expect(revived.classSlug, equals('twohands_kamojang_natural'));
      expect(revived.displayTitle, equals('Two Hands - Kamojang Natural'));
      expect(revived.weightsVector.length, equals(VisualBagEmbedder.dim));
      expect(revived.subCentroids.length, equals(1));
      expect(revived.cosineThreshold, equals(0.82));
      expect(revived.augmentedSampleCount, equals(45));
      expect(revived.validationAccuracy, equals(0.96));
      expect(revived.ocrSignatureTokens, contains('kamojang'));
    });

    test('TrainedCoffeeStorageService persists and reads models offline', () async {
      final dummyWeights = List<double>.generate(VisualBagEmbedder.dim, (i) => 0.05);
      final model = TrainedCoffeeClassModel(
        classSlug: 'space_roastery_gayo',
        displayTitle: 'Space Roastery - Gayo',
        weightsVector: dummyWeights,
        subCentroids: [],
        cosineThreshold: 0.80,
        augmentedSampleCount: 45,
        validationAccuracy: 0.98,
        coffeeMetadata: {
          'brand': 'Space Roastery',
          'bean_name': 'Gayo',
        },
        createdAt: DateTime.now(),
      );

      await TrainedCoffeeStorageService.saveModel(model);

      final loaded = await TrainedCoffeeStorageService.getAllModels();
      expect(loaded.length, equals(1));
      expect(loaded.first.classSlug, equals('space_roastery_gayo'));
    });
  });

  group('In-App Transfer Learning - VisualBagEmbedder Feature Math', () {
    test('embed produces 512-dimensional L2-normalized vector', () {
      final image = img.Image(width: 224, height: 224);
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          image.setPixelRgb(x, y, (x * 2) % 256, (y * 2) % 256, 120);
        }
      }

      final vec = VisualBagEmbedder.embed(image);
      expect(vec.length, equals(512));

      // L2 norm check (norm should be approximately 1.0)
      double normSq = 0.0;
      for (final v in vec) {
        normSq += v * v;
      }
      expect((normSq - 1.0).abs(), lessThan(0.01));
    });

    test('Stage 0 matchEmbeddings recognizes matching visual and ocr tokens', () {
      final dummyWeights = List<double>.generate(VisualBagEmbedder.dim, (i) => (i % 2 == 0 ? 0.05 : -0.05));
      final model = TrainedCoffeeClassModel(
        classSlug: 'bandung_kopi_malabar_wine',
        displayTitle: 'Bandung Kopi - Malabar Wine',
        weightsVector: dummyWeights,
        subCentroids: [],
        cosineThreshold: 0.80,
        augmentedSampleCount: 45,
        validationAccuracy: 0.99,
        ocrSignatureTokens: ['bandung', 'malabar', 'wine'],
        coffeeMetadata: {
          'brand': 'Bandung Kopi',
          'bean_name': 'Malabar Wine',
          'process': 'Wine Process',
        },
        createdAt: DateTime.now(),
      );

      final match = OnDeviceTransferLearner.matchEmbeddings(
        queries: [Float32List.fromList(dummyWeights)],
        models: [model],
        ocrText: 'BANDUNG KOPI MALABAR WINE',
      );

      expect(match, isNotNull);
      expect(match!.isAboveThreshold, isTrue);
      expect(match.model.classSlug, 'bandung_kopi_malabar_wine');
    });
  });
}
