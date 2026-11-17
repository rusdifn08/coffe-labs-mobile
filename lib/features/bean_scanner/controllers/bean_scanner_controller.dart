import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../in_app_trainer/services/on_device_transfer_learner.dart';
import '../../in_app_trainer/services/trained_coffee_storage_service.dart';
import '../../scanner/domain/services/image_tensor_isolate.dart';
import '../../scanner/domain/services/incremental_vision_engine.dart';
import '../models/bean_scan_state.dart';
import '../models/resolved_coffee_bean.dart';
import '../services/bean_scanner_api_service.dart';
import '../services/bean_vision_scanner_service.dart';
import '../services/coffee_knowledge_graph_service.dart';
import '../services/scanned_bean_recipe_planner.dart';

class BeanScannerController extends Notifier<BeanScanState> {
  @override
  BeanScanState build() => const BeanScanStateIdle();

  void reset() {
    state = const BeanScanStateIdle();
  }

  void updateResolvedBean(ResolvedCoffeeBean updated) {
    final current = state;
    if (current is BeanScanStateResolved) {
      state = BeanScanStateResolved(bean: updated, imageFile: current.imageFile);
    }
  }

  Future<void> processImage(File imageFile) async {
    state = BeanScanStateAnalyzing(imageFile);
    try {
      await CoffeeKnowledgeGraphService.instance.initialize();
      final visionResult = await BeanVisionScannerService.processPhoto(imageFile);

      // STAGE 0 (PRIORITY #1): Class-Incremental Continual Learning (MobileNetV4 1280-D NCM Vision Engine)
      try {
        await IncrementalVisionEngine.instance.initialize();
        if (IncrementalVisionEngine.instance.knownClassCount > 0) {
          final tensor = await ImageTensorIsolate.preprocessSingleImage(visionResult.croppedImageFile);
          final match = IncrementalVisionEngine.instance.classifyImage(tensor);

          if (match.isRecognized && match.matchedRecord != null) {
            final rec = match.matchedRecord!;
            final confPercent = (match.confidence * 100).toStringAsFixed(0);
            final seedBean = ResolvedCoffeeBean(
              beanId: 'ncm_${rec.classSlug}',
              isCatalogVerified: true,
              confidenceScore: (match.confidence * 100).clamp(65.0, 99.5),
              roasteryName: rec.roastery,
              beanName: rec.coffeeName,
              origin: rec.origin,
              variety: rec.variety,
              process: rec.process,
              roastLevel: 'Light to Medium',
              altitudeMasl: rec.altitude,
              tastingNotes: rec.tastingNotes,
              recommendedWaterTempC: rec.recommendedTemp,
              recommendedRecipes: const [],
              localCroppedImagePath: visionResult.croppedImageFile.path,
              notesSource: '🎯 MobileNetV4 NCM Match ($confPercent%)',
            );
            final tailored = ScannedBeanRecipePlanner.buildRecommendations(
              displayBeanName: seedBean.fullDisplayName,
              origin: rec.origin,
              variety: rec.variety,
              processRaw: rec.process,
              roastRaw: seedBean.roastLevel,
              altitudeMasl: rec.altitude,
              tastingNotes: rec.tastingNotes,
              targetTempOverride: rec.recommendedTemp,
            );
            final ncmResolved = seedBean.copyWith(recommendedRecipes: tailored);

            state = BeanScanStateResolved(
              bean: ncmResolved,
              imageFile: visionResult.croppedImageFile,
            );
            return;
          }
        }
      } catch (ncmErr) {
        debugPrint('Stage 0 MobileNetV4 NCM classification skipped: $ncmErr');
      }

      // STAGE 0.5: Legacy On-Device Few-Shot Transfer Learning Models Fallback
      try {
        final customModels = await TrainedCoffeeStorageService.getAllModels();
        if (customModels.isNotEmpty) {
          final match = await OnDeviceTransferLearner.matchImage(
            imagePaths: [visionResult.croppedImageFile.path, imageFile.path],
            models: customModels,
            ocrText: visionResult.rawFullText,
          );

          if (match != null && match.isAboveThreshold) {
            final meta = match.model.coffeeMetadata;
            final brand = meta['brand']?.toString() ?? meta['roastery_name']?.toString() ?? match.model.displayTitle;
            final beanName = meta['bean_name']?.toString() ?? match.model.displayTitle;
            final varietal = meta['varietal']?.toString() ?? 'Specialty Blend';
            final process = meta['process']?.toString() ?? 'Natural';
            final altitude = meta['altitude_masl']?.toString() ?? '1400 - 1800 MDPL';
            final notesList = (meta['tasting_notes'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                ['Blueberry', 'Milk Chocolate'];

            final seedCustom = ResolvedCoffeeBean(
              beanId: 'trained_${match.model.classSlug}',
              isCatalogVerified: true,
              confidenceScore: 99.0,
              roasteryName: brand,
              beanName: beanName,
              origin: brand,
              variety: varietal,
              process: process,
              roastLevel: 'Medium Roast',
              altitudeMasl: altitude,
              tastingNotes: notesList,
              recommendedWaterTempC: 92,
              recommendedRecipes: const [],
              localCroppedImagePath: visionResult.croppedImageFile.path,
              notesSource: '🎯 Trained AI Model Match (99%)',
            );
            final customRecipes = ScannedBeanRecipePlanner.buildRecommendations(
              displayBeanName: seedCustom.fullDisplayName,
              origin: seedCustom.origin,
              variety: varietal,
              processRaw: process,
              roastRaw: seedCustom.roastLevel,
              altitudeMasl: altitude,
              tastingNotes: notesList,
            );
            final customResolved = seedCustom.copyWith(
              recommendedWaterTempC: customRecipes.first.suggestedTempC,
              recommendedRecipes: customRecipes,
            );

            state = BeanScanStateResolved(
              bean: customResolved,
              imageFile: visionResult.croppedImageFile,
            );
            return;
          }
        }
      } catch (tlError) {
        debugPrint('On-device transfer learning matching skipped: $tlError');
      }

      // STAGE 1: Smart OCR + Knowledge Graph Sommelier Inference
      final resolved = await BeanScannerApiService.resolveBean(
        rawFullText: visionResult.rawFullText,
        blocks: visionResult.blocks,
        croppedImagePath: visionResult.croppedImageFile.path,
      );

      state = BeanScanStateResolved(
        bean: resolved,
        imageFile: visionResult.croppedImageFile,
      );
    } catch (e) {
      state = BeanScanStateError('Gagal menganalisis kemasan kopi: $e');
    }
  }
}

final beanScannerControllerProvider =
    NotifierProvider<BeanScannerController, BeanScanState>(
  BeanScannerController.new,
);
