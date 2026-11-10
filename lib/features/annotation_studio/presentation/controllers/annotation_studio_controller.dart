import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/studio_database.dart';
import '../../domain/models/auto_label_config.dart';
import '../../domain/models/coffee_annotation_class.dart';
import '../../domain/models/studio_image_item.dart';
import '../../domain/services/coffee_bag_segmenter_service.dart';
import 'annotation_studio_state.dart';

final annotationStudioProvider =
    NotifierProvider<AnnotationStudioController, AnnotationStudioState>(() {
  return AnnotationStudioController();
});

class AnnotationStudioController extends Notifier<AnnotationStudioState> {
  @override
  AnnotationStudioState build() {
    // Initial async load
    Future.microtask(() => loadStudioData());
    return const AnnotationStudioState(isLoading: true);
  }

  Future<void> loadStudioData() async {
    state = state.copyWith(isLoading: true);
    try {
      await StudioDatabase.seedInitialClassesIfEmpty();
      final classes = await StudioDatabase.getAllClasses();
      final images = await StudioDatabase.getAllImages();
      state = state.copyWith(
        isLoading: false,
        classes: classes,
        images: images,
      );
    } catch (e) {
      debugPrint('Error loading studio data: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void setSelectedTab(String tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void updateConfig(AutoLabelConfig config) {
    state = state.copyWith(config: config);
  }

  Future<int> importCoffeeJson() async {
    state = state.copyWith(isLoading: true);
    try {
      final imported = await StudioDatabase.seedInitialClassesIfEmpty();
      final classes = await StudioDatabase.getAllClasses();
      state = state.copyWith(isLoading: false, classes: classes);
      return imported;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 0;
    }
  }

  Future<void> addImages(List<File> files) async {
    for (final file in files) {
      final item = StudioImageItem(
        filePath: file.path,
        status: 'unassigned',
        createdAt: DateTime.now(),
      );
      await StudioDatabase.insertImage(item);
    }
    await _refreshImagesAndClasses();
  }

  Future<void> deleteImage(int id) async {
    await StudioDatabase.deleteImage(id);
    await _refreshImagesAndClasses();
  }

  Future<int> deleteAllRejected() async {
    final deleted = await StudioDatabase.deleteAllRejectedImages();
    await _refreshImagesAndClasses();
    return deleted;
  }

  void setActiveItem(StudioImageItem? item) {
    if (item == null) {
      state = state.copyWith(
        activeItem: null,
        activePolygon: [],
        activeBbox: null,
        selectedVertexIndex: null,
      );
      return;
    }

    Rect? bbox;
    if (item.bbox.length >= 4) {
      bbox = Rect.fromLTRB(item.bbox[0], item.bbox[1], item.bbox[2], item.bbox[3]);
    }

    state = state.copyWith(
      activeItem: item,
      activePolygon: List<Offset>.from(item.polygon),
      activeBbox: bbox,
      selectedVertexIndex: null,
    );
  }

  void updateActivePolygon(List<Offset> polygon) {
    if (polygon.isEmpty) return;

    double minX = polygon.first.dx;
    double minY = polygon.first.dy;
    double maxX = polygon.first.dx;
    double maxY = polygon.first.dy;

    for (final p in polygon) {
      minX = math.min(minX, p.dx);
      minY = math.min(minY, p.dy);
      maxX = math.max(maxX, p.dx);
      maxY = math.max(maxY, p.dy);
    }

    state = state.copyWith(
      activePolygon: polygon,
      activeBbox: Rect.fromLTRB(minX, minY, maxX, maxY),
    );
  }

  void selectVertex(int? index) {
    state = state.copyWith(selectedVertexIndex: index);
  }

  void moveVertex(int index, Offset newPos) {
    if (index < 0 || index >= state.activePolygon.length) return;
    final updated = List<Offset>.from(state.activePolygon);
    updated[index] = Offset(newPos.dx.clamp(0.01, 0.99), newPos.dy.clamp(0.01, 0.99));
    updateActivePolygon(updated);
  }

  /// 1-Tap Smart Point Selection on coffee bag
  void smartPointSelect(Offset tapNormalized) {
    final double cx = tapNormalized.dx.clamp(0.15, 0.85);
    final double cy = tapNormalized.dy.clamp(0.15, 0.85);
    const double halfW = 0.35;
    const double halfH = 0.38;

    final rect = Rect.fromLTRB(
      (cx - halfW).clamp(0.05, 0.95),
      (cy - halfH).clamp(0.05, 0.95),
      (cx + halfW).clamp(0.05, 0.95),
      (cy + halfH).clamp(0.05, 0.95),
    );

    final poly = CoffeeBagSegmenterService.generateContouredPouchPolygon(rect);
    state = state.copyWith(
      activeBbox: rect,
      activePolygon: poly,
      selectedVertexIndex: null,
    );
  }

  /// Save changes on active item
  Future<void> saveActiveItem({
    required String classSlug,
    required String brand,
    required String coffeeName,
    required String process,
    bool isNewClass = false,
  }) async {
    final current = state.activeItem;
    if (current == null) return;

    final bboxList = state.activeBbox != null
        ? [
            state.activeBbox!.left,
            state.activeBbox!.top,
            state.activeBbox!.right,
            state.activeBbox!.bottom,
          ]
        : current.bbox;

    final updated = current.copyWith(
      classSlug: classSlug,
      brand: brand,
      coffeeName: coffeeName,
      process: process,
      status: 'annotated',
      isRejected: false,
      rejectionReason: null,
      polygon: state.activePolygon,
      bbox: bboxList,
      isNewClass: isNewClass,
    );

    await StudioDatabase.updateImage(updated);

    // If new class, ensure class exists in SQLite
    if (isNewClass) {
      final existing = await StudioDatabase.getClassBySlug(classSlug);
      if (existing == null) {
        final newCls = CoffeeAnnotationClass(
          classSlug: classSlug,
          displayName: classSlug.replaceAll('_', ' ').toUpperCase(),
          colorHex: '#8B5CF6',
          brand: brand,
          coffeeName: coffeeName,
          process: process,
          createdAt: DateTime.now(),
        );
        await StudioDatabase.upsertClass(newCls);
      }
    }

    await _refreshImagesAndClasses();
    setActiveItem(updated);
  }

  /// Single Image Auto-Label
  Future<AutoLabelResult?> autoLabelActiveImage() async {
    final active = state.activeItem;
    if (active == null) return null;

    final file = File(active.filePath);
    if (!await file.exists()) return null;

    final existingSlugs = state.classes.map((c) => c.classSlug).toList();
    final result = await CoffeeBagSegmenterService.processSingleImage(
      imageFile: file,
      existingClasses: existingSlugs,
      config: state.config,
    );

    // Update state with result
    final bbox = result.boundingBox;
    final bboxList = [bbox.left, bbox.top, bbox.right, bbox.bottom];

    final updated = active.copyWith(
      status: result.isRejected ? 'rejected_non_coffee' : 'annotated',
      isRejected: result.isRejected,
      rejectionReason: result.rejectionReason,
      polygon: result.polygon,
      bbox: bboxList,
      ocrLines: result.ocrResult?.rawLines ?? [],
      classSlug: result.ocrResult?.canonicalSlug,
      brand: result.ocrResult?.brand,
      coffeeName: result.ocrResult?.coffeeName,
      process: result.ocrResult?.process,
      isNewClass: result.ocrResult?.isNewClass ?? true,
      confidence: result.confidence,
    );

    await StudioDatabase.updateImage(updated);
    await _refreshImagesAndClasses();

    state = state.copyWith(
      activeItem: updated,
      activeBbox: bbox,
      activePolygon: result.polygon,
    );

    return result;
  }

  /// Batch Auto-Labeling for all unassigned/pending images
  Future<void> runBatchAutoLabel() async {
    final targets = state.images
        .where((img) => (img.status == 'unassigned' || img.status == 'annotating') && !img.isRejected)
        .toList();

    if (targets.isEmpty) return;

    state = state.copyWith(
      isBatchProcessing: true,
      batchTotal: targets.length,
      batchCurrent: 0,
      batchLabeledCount: 0,
      batchRejectedCount: 0,
      batchStatusMessage: 'Menyiapkan pemrosesan batch on-device...',
    );

    final existingSlugs = state.classes.map((c) => c.classSlug).toList();
    int labeled = 0;
    int rejected = 0;

    for (int i = 0; i < targets.length; i++) {
      final item = targets[i];
      final file = File(item.filePath);

      state = state.copyWith(
        batchCurrent: i + 1,
        batchStatusMessage: 'Memproses citra (${i + 1}/${targets.length}): ${file.uri.pathSegments.last}',
      );

      if (!await file.exists()) {
        rejected++;
        continue;
      }

      final autoResult = await CoffeeBagSegmenterService.processSingleImage(
        imageFile: file,
        existingClasses: existingSlugs,
        config: state.config,
      );

      final bbox = autoResult.boundingBox;
      final bboxList = [bbox.left, bbox.top, bbox.right, bbox.bottom];

      if (autoResult.isRejected) {
        rejected++;
        final updated = item.copyWith(
          status: 'rejected_non_coffee',
          isRejected: true,
          rejectionReason: autoResult.rejectionReason ?? 'Gagal melewati gatekeeper',
          confidence: autoResult.confidence,
        );
        await StudioDatabase.updateImage(updated);
      } else {
        labeled++;
        final ocr = autoResult.ocrResult;
        String? targetSlug = ocr?.canonicalSlug;
        bool isNew = ocr?.isNewClass ?? true;

        if (!state.config.autoCreateNewClasses && isNew && ocr?.matchedExistingClass != null) {
          targetSlug = ocr!.matchedExistingClass;
          isNew = false;
        }

        final updated = item.copyWith(
          status: 'annotated',
          isRejected: false,
          polygon: autoResult.polygon,
          bbox: bboxList,
          ocrLines: ocr?.rawLines ?? [],
          classSlug: targetSlug,
          brand: ocr?.brand,
          coffeeName: ocr?.coffeeName,
          process: ocr?.process,
          isNewClass: isNew,
          confidence: autoResult.confidence,
        );
        await StudioDatabase.updateImage(updated);

        // If new class, add to SQLite class table
        if (isNew && targetSlug != null && !existingSlugs.contains(targetSlug)) {
          existingSlugs.add(targetSlug);
          final newCls = CoffeeAnnotationClass(
            classSlug: targetSlug,
            displayName: targetSlug.replaceAll('_', ' ').toUpperCase(),
            colorHex: _generateColorHex(targetSlug),
            brand: ocr?.brand ?? '',
            coffeeName: ocr?.coffeeName ?? '',
            process: ocr?.process ?? '',
            createdAt: DateTime.now(),
          );
          await StudioDatabase.upsertClass(newCls);
        }

        state = state.copyWith(
          batchBrand: ocr?.brand ?? '',
          batchCoffeeName: ocr?.coffeeName ?? '',
          batchProcess: ocr?.process ?? '',
        );
      }

      state = state.copyWith(
        batchLabeledCount: labeled,
        batchRejectedCount: rejected,
      );
    }

    state = state.copyWith(
      isBatchProcessing: false,
      batchStatusMessage: 'Selesai: $labeled kemasan terlabeli, $rejected foto ditolak.',
    );

    await _refreshImagesAndClasses();
  }

  static String _generateColorHex(String slug) {
    const palette = [
      '#8B5CF6', '#EC4899', '#3B82F6', '#10B981', '#F59E0B',
      '#6366F1', '#14B8A6', '#D946EF', '#F97316', '#06B6D4'
    ];
    final hash = slug.hashCode.abs();
    return palette[hash % palette.length];
  }

  Future<void> _refreshImagesAndClasses() async {
    final classes = await StudioDatabase.getAllClasses();
    final images = await StudioDatabase.getAllImages();
    state = state.copyWith(
      classes: classes,
      images: images,
    );
  }
}
