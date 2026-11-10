import 'dart:convert';
import 'dart:ui';

/// Model for an image item inside In-App Mobile Roboflow Annotation Studio.
class StudioImageItem {
  final int? id;
  final String filePath;
  final String status; // 'unassigned', 'annotating', 'annotated', 'rejected_non_coffee'
  final bool isRejected;
  final String? rejectionReason;
  final String? classSlug; // canonical {brand}_{nama_kopi}_{proses}
  final String? brand;
  final String? coffeeName;
  final String? process;
  final List<Offset> polygon; // Normalized [0.0 - 1.0] coordinates
  final List<double> bbox; // [x1, y1, x2, y2] normalized [0.0 - 1.0]
  final List<String> ocrLines;
  final bool isNewClass;
  final double confidence;
  final DateTime createdAt;

  const StudioImageItem({
    this.id,
    required this.filePath,
    this.status = 'unassigned',
    this.isRejected = false,
    this.rejectionReason,
    this.classSlug,
    this.brand,
    this.coffeeName,
    this.process,
    this.polygon = const [],
    this.bbox = const [],
    this.ocrLines = const [],
    this.isNewClass = true,
    this.confidence = 0.0,
    required this.createdAt,
  });

  bool get isAnnotated => status == 'annotated' && !isRejected;
  bool get isPending => status == 'unassigned' || status == 'annotating';

  StudioImageItem copyWith({
    int? id,
    String? filePath,
    String? status,
    bool? isRejected,
    String? rejectionReason,
    String? classSlug,
    String? brand,
    String? coffeeName,
    String? process,
    List<Offset>? polygon,
    List<double>? bbox,
    List<String>? ocrLines,
    bool? isNewClass,
    double? confidence,
    DateTime? createdAt,
  }) {
    return StudioImageItem(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      status: status ?? this.status,
      isRejected: isRejected ?? this.isRejected,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      classSlug: classSlug ?? this.classSlug,
      brand: brand ?? this.brand,
      coffeeName: coffeeName ?? this.coffeeName,
      process: process ?? this.process,
      polygon: polygon ?? this.polygon,
      bbox: bbox ?? this.bbox,
      ocrLines: ocrLines ?? this.ocrLines,
      isNewClass: isNewClass ?? this.isNewClass,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'file_path': filePath,
      'status': status,
      'is_rejected': isRejected ? 1 : 0,
      'rejection_reason': rejectionReason,
      'class_slug': classSlug,
      'brand': brand,
      'coffee_name': coffeeName,
      'process': process,
      'polygon_json': json.encode(polygon.map((p) => [p.dx, p.dy]).toList()),
      'bbox_json': json.encode(bbox),
      'ocr_lines_json': json.encode(ocrLines),
      'is_new_class': isNewClass ? 1 : 0,
      'confidence': confidence,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StudioImageItem.fromMap(Map<String, dynamic> map) {
    List<Offset> poly = [];
    try {
      final rawPoly = map['polygon_json'];
      if (rawPoly is String && rawPoly.isNotEmpty) {
        final decoded = json.decode(rawPoly) as List;
        for (final item in decoded) {
          if (item is List && item.length >= 2) {
            poly.add(Offset((item[0] as num).toDouble(), (item[1] as num).toDouble()));
          }
        }
      }
    } catch (_) {}

    List<double> box = [];
    try {
      final rawBox = map['bbox_json'];
      if (rawBox is String && rawBox.isNotEmpty) {
        final decoded = json.decode(rawBox) as List;
        box = decoded.map((e) => (e as num).toDouble()).toList();
      }
    } catch (_) {}

    List<String> lines = [];
    try {
      final rawLines = map['ocr_lines_json'];
      if (rawLines is String && rawLines.isNotEmpty) {
        final decoded = json.decode(rawLines) as List;
        lines = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    return StudioImageItem(
      id: map['id'] as int?,
      filePath: map['file_path'] as String,
      status: (map['status'] as String?) ?? 'unassigned',
      isRejected: (map['is_rejected'] as int?) == 1,
      rejectionReason: map['rejection_reason'] as String?,
      classSlug: map['class_slug'] as String?,
      brand: map['brand'] as String?,
      coffeeName: map['coffee_name'] as String?,
      process: map['process'] as String?,
      polygon: poly,
      bbox: box,
      ocrLines: lines,
      isNewClass: (map['is_new_class'] as int?) == 1,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
