import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
