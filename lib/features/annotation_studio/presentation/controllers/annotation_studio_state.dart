import 'dart:ui';
import '../../domain/models/auto_label_config.dart';
import '../../domain/models/coffee_annotation_class.dart';
import '../../domain/models/studio_image_item.dart';

class AnnotationStudioState {
  final bool isLoading;
  final String selectedTab; // 'all', 'unassigned', 'annotated', 'rejected'
  final List<StudioImageItem> images;
  final List<CoffeeAnnotationClass> classes;
  final AutoLabelConfig config;

  // Batch Processing Progress
  final bool isBatchProcessing;
  final int batchCurrent;
  final int batchTotal;
  final String batchStatusMessage;
  final String batchBrand;
  final String batchCoffeeName;
  final String batchProcess;
  final int batchLabeledCount;
  final int batchRejectedCount;

  // Active Editor State
  final StudioImageItem? activeItem;
  final List<Offset> activePolygon;
  final Rect? activeBbox;
  final int? selectedVertexIndex;
  final bool isSmartTapping;

  const AnnotationStudioState({
    this.isLoading = false,
    this.selectedTab = 'all',
    this.images = const [],
    this.classes = const [],
    this.config = const AutoLabelConfig(),
    this.isBatchProcessing = false,
    this.batchCurrent = 0,
    this.batchTotal = 0,
    this.batchStatusMessage = '',
    this.batchBrand = '',
    this.batchCoffeeName = '',
    this.batchProcess = '',
    this.batchLabeledCount = 0,
    this.batchRejectedCount = 0,
    this.activeItem,
    this.activePolygon = const [],
    this.activeBbox,
    this.selectedVertexIndex,
    this.isSmartTapping = false,
  });

  int get totalImages => images.length;
  int get unassignedCount =>
      images.where((i) => (i.status == 'unassigned' || i.status == 'annotating') && !i.isRejected).length;
  int get annotatedCount => images.where((i) => i.status == 'annotated' && !i.isRejected).length;
  int get rejectedCount => images.where((i) => i.isRejected || i.status == 'rejected_non_coffee').length;

  AnnotationStudioState copyWith({
    bool? isLoading,
    String? selectedTab,
    List<StudioImageItem>? images,
    List<CoffeeAnnotationClass>? classes,
    AutoLabelConfig? config,
    bool? isBatchProcessing,
    int? batchCurrent,
    int? batchTotal,
    String? batchStatusMessage,
    String? batchBrand,
    String? batchCoffeeName,
    String? batchProcess,
    int? batchLabeledCount,
    int? batchRejectedCount,
    StudioImageItem? activeItem,
    List<Offset>? activePolygon,
    Rect? activeBbox,
    int? selectedVertexIndex,
    bool? isSmartTapping,
  }) {
    return AnnotationStudioState(
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
      images: images ?? this.images,
      classes: classes ?? this.classes,
      config: config ?? this.config,
      isBatchProcessing: isBatchProcessing ?? this.isBatchProcessing,
      batchCurrent: batchCurrent ?? this.batchCurrent,
      batchTotal: batchTotal ?? this.batchTotal,
      batchStatusMessage: batchStatusMessage ?? this.batchStatusMessage,
      batchBrand: batchBrand ?? this.batchBrand,
      batchCoffeeName: batchCoffeeName ?? this.batchCoffeeName,
      batchProcess: batchProcess ?? this.batchProcess,
      batchLabeledCount: batchLabeledCount ?? this.batchLabeledCount,
      batchRejectedCount: batchRejectedCount ?? this.batchRejectedCount,
      activeItem: activeItem ?? this.activeItem,
      activePolygon: activePolygon ?? this.activePolygon,
      activeBbox: activeBbox ?? this.activeBbox,
      selectedVertexIndex: selectedVertexIndex ?? this.selectedVertexIndex,
      isSmartTapping: isSmartTapping ?? this.isSmartTapping,
    );
  }
}
