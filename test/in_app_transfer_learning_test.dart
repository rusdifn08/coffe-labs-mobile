import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coffee_hub_mobile/features/in_app_trainer/domain/annotated_training_sample.dart';
import 'package:coffee_hub_mobile/features/in_app_trainer/domain/class_slug_generator.dart';
import 'package:coffee_hub_mobile/features/in_app_trainer/domain/trained_coffee_class_model.dart';
import 'package:coffee_hub_mobile/features/in_app_trainer/services/on_device_transfer_learner.dart';
import 'package:coffee_hub_mobile/features/in_app_trainer/services/trained_coffee_storage_service.dart';

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
      final dummyWeights = List<double>.generate(960, (i) => i * 0.001);
      final dummySub = [
        List<double>.generate(960, (i) => (i + 1) * 0.001),
      ];

      final model = TrainedCoffeeClassModel(
        classSlug: 'twohands_kamojang_natural',
        displayTitle: 'Two Hands - Kamojang Natural',
        weightsVector960: dummyWeights,
        subCentroids: dummySub,
        cosineThreshold: 0.82,
        augmentedSampleCount: 45,
        validationAccuracy: 0.96,
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
      expect(revived.weightsVector960.length, equals(960));
      expect(revived.subCentroids.length, equals(1));
      expect(revived.cosineThreshold, equals(0.82));
      expect(revived.augmentedSampleCount, equals(45));
      expect(revived.validationAccuracy, equals(0.96));
    });

    test('TrainedCoffeeStorageService persists and reads models offline', () async {
      final dummyWeights = List<double>.generate(960, (i) => 0.05);
      final model = TrainedCoffeeClassModel(
        classSlug: 'space_roastery_gayo',
        displayTitle: 'Space Roastery - Gayo',
        weightsVector960: dummyWeights,
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

  group('In-App Transfer Learning - OnDeviceTransferLearner Feature Math', () {
    test('extractFeaturesFromTensor produces 960-dimensional normalized vector', () {
      final dummyFloats = Float32List(224 * 224 * 3);
      for (int i = 0; i < dummyFloats.length; i++) {
        dummyFloats[i] = (i % 256) / 255.0;
      }

      final vec = OnDeviceTransferLearner.extractFeaturesFromTensor(dummyFloats);
      expect(vec.length, equals(960));

      // L2 norm check (norm should be approximately 1.0)
      final norm = vec.norm();
      expect((norm - 1.0).abs(), lessThan(0.01));
    });
  });
}
