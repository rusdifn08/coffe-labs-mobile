import 'dart:ui';
import '../../domain/models/auto_label_config.dart';
import '../../domain/models/coffee_annotation_class.dart';
import '../../domain/models/studio_image_item.dart';
import '../../domain/services/smart_sam_engine_service.dart';

/// Available mobile annotation tools matching Roboflow Studio
enum StudioTool {
  samPoints, // 🪄 Smart SAM Point (+/- prompt clicks)
  smartBox, // ⚡ Box SAM (Drag box -> Auto-contour inside box)
  boundingBox, // 🔲 Standard BBox (Drag box -> 4-point rectangle)
  polygon, // 📐 Manual Polygon (Point-by-point vertices)
  vertexEdit, // ✏️ Edit Vertices (Drag vertex, tap edge to add, double-tap to remove)
  panZoom, // 🖐️ Pan & Zoom (Pinch and drag view)
}

/// Prompt type for Smart SAM Mode
enum SamPromptMode {
  positive, // (+) Green: Foreground / Include
  negative, // (-) Red: Background / Exclude
}

/// Snapshot of annotation state for Undo/Redo history
class StudioAnnotationSnapshot {
  final List<Offset> polygon;
  final Rect? bbox;
  final List<SamPromptPoint> samPoints;

  const StudioAnnotationSnapshot({
    required this.polygon,
    this.bbox,
    this.samPoints = const [],
  });
}

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

  // Roboflow Studio v5.0 Upgrades
  final StudioTool activeTool;
  final SamPromptMode samPromptMode;
  final List<SamPromptPoint> samPromptPoints;
  final List<StudioAnnotationSnapshot> undoStack;
  final List<StudioAnnotationSnapshot> redoStack;

  // Layer Management State
  final bool isLayerVisible;
  final double layerOpacity;
  final bool isLayerLocked;

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
    this.activeTool = StudioTool.samPoints,
    this.samPromptMode = SamPromptMode.positive,
    this.samPromptPoints = const [],
    this.undoStack = const [],
    this.redoStack = const [],
    this.isLayerVisible = true,
    this.layerOpacity = 0.25,
    this.isLayerLocked = false,
  });

  int get totalImages => images.length;
  int get unassignedCount =>
      images.where((i) => (i.status == 'unassigned' || i.status == 'annotating') && !i.isRejected).length;
  int get annotatedCount => images.where((i) => i.status == 'annotated' && !i.isRejected).length;
  int get rejectedCount => images.where((i) => i.isRejected || i.status == 'rejected_non_coffee').length;

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

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
    StudioTool? activeTool,
    SamPromptMode? samPromptMode,
    List<SamPromptPoint>? samPromptPoints,
    List<StudioAnnotationSnapshot>? undoStack,
    List<StudioAnnotationSnapshot>? redoStack,
    bool? isLayerVisible,
    double? layerOpacity,
    bool? isLayerLocked,
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
      activeTool: activeTool ?? this.activeTool,
      samPromptMode: samPromptMode ?? this.samPromptMode,
      samPromptPoints: samPromptPoints ?? this.samPromptPoints,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      isLayerVisible: isLayerVisible ?? this.isLayerVisible,
      layerOpacity: layerOpacity ?? this.layerOpacity,
      isLayerLocked: isLayerLocked ?? this.isLayerLocked,
    );
  }
}
