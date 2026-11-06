import 'dart:ui';

/// Model representasi 1 sampel foto yang telah dianotasi dengan bounding box.
class AnnotatedTrainingSample {
  final String id;
  final String imagePath;
  final Rect boundingBoxNormalized; // Rect dengan koordinat 0.0 .. 1.0
  final String angleTag; // 'front', 'angle_left', 'angle_right', 'custom'
  final DateTime capturedAt;

  const AnnotatedTrainingSample({
    required this.id,
    required this.imagePath,
    required this.boundingBoxNormalized,
    required this.angleTag,
    required this.capturedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'box': [
          boundingBoxNormalized.left,
          boundingBoxNormalized.top,
          boundingBoxNormalized.right,
          boundingBoxNormalized.bottom,
        ],
        'angleTag': angleTag,
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory AnnotatedTrainingSample.fromJson(Map<String, dynamic> json) {
    final boxList = (json['box'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ??
        [0.05, 0.05, 0.95, 0.95];
    return AnnotatedTrainingSample(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      boundingBoxNormalized: Rect.fromLTRB(
        boxList[0],
        boxList[1],
        boxList[2],
        boxList[3],
      ),
      angleTag: json['angleTag'] as String? ?? 'front',
      capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  AnnotatedTrainingSample copyWith({
    String? id,
    String? imagePath,
    Rect? boundingBoxNormalized,
    String? angleTag,
    DateTime? capturedAt,
  }) {
    return AnnotatedTrainingSample(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      boundingBoxNormalized: boundingBoxNormalized ?? this.boundingBoxNormalized,
      angleTag: angleTag ?? this.angleTag,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }
}
