import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../in_app_trainer/services/on_device_transfer_learner.dart';
import '../../in_app_trainer/services/trained_coffee_storage_service.dart';
import '../models/bean_scan_state.dart';
import '../models/resolved_coffee_bean.dart';
import '../services/bean_scanner_api_service.dart';
import '../services/bean_vision_scanner_service.dart';

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
      final visionResult = await BeanVisionScannerService.processPhoto(imageFile);

      // 1. Prioritas Tingkat-1: Evaluasi On-Device Transfer Learning Models (<60ms)
      try {
        final customModels = await TrainedCoffeeStorageService.getAllModels();
        if (customModels.isNotEmpty) {
          final match = OnDeviceTransferLearner.matchImage(
            croppedImage: visionResult.croppedImageFile,
            models: customModels,
          );

          if (match != null && match.isAboveThreshold) {
            final meta = match.model.coffeeMetadata;
            final brand = meta['brand']?.toString() ?? match.model.displayTitle;
            final beanName = meta['bean_name']?.toString() ?? match.model.displayTitle;
            final varietal = meta['varietal']?.toString() ?? 'Specialty Blend';
            final process = meta['process']?.toString() ?? 'Natural';
            final altitude = meta['altitude_masl']?.toString() ?? '1400 - 1800 MASL';
            final notesList = (meta['tasting_notes'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                ['Blueberry', 'Milk Chocolate'];

            final customResolved = ResolvedCoffeeBean(
              beanId: 'trained_${match.model.classSlug}',
              isCatalogVerified: true,
              confidenceScore: (match.similarityScore * 100).clamp(92.0, 99.8),
              roasteryName: brand,
              beanName: beanName,
              origin: brand,
              variety: varietal,
              process: process,
              roastLevel: 'Medium Roast',
              altitudeMasl: altitude,
              tastingNotes: notesList,
              recommendedWaterTempC: 92,
              recommendedRecipes: [
                RecommendedRecipeSummary(
                  slug: 'v60-transfer-learning',
                  name: 'V60 Precision Pourover (Custom Trained)',
                  targetNotes: notesList.take(3).join(', '),
                  suggestedTempC: 92,
                  ratio: '1:15',
                ),
              ],
              localCroppedImagePath: visionResult.croppedImageFile.path,
              notesSource: 'ON_DEVICE_AI_FEW_SHOT_MODEL',
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

      // 2. Prioritas Tingkat-2: OCR Heuristics & Backend AI Resolution
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
