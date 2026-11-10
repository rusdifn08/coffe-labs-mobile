import 'dart:ui';
import '../models/auto_label_config.dart';

/// Diagnostic assessment result of Non-Coffee Photo Gatekeeper
class GatekeeperEvaluationResult {
  final bool isValidCoffeeBag;
  final String? rejectionReason;
  final double confidenceScore;
  final double areaRatio;
  final double aspectRatio;
  final double solidity;
  final List<String> passedConditions;
  final List<String> failedConditions;

  const GatekeeperEvaluationResult({
    required this.isValidCoffeeBag,
    this.rejectionReason,
    required this.confidenceScore,
    required this.areaRatio,
    required this.aspectRatio,
    required this.solidity,
    this.passedConditions = const [],
    this.failedConditions = const [],
  });

  static const GatekeeperEvaluationResult emptyOrCorrupt = GatekeeperEvaluationResult(
    isValidCoffeeBag: false,
    rejectionReason: 'Citra kosong atau format tidak terbaca',
    confidenceScore: 0.0,
    areaRatio: 0.0,
    aspectRatio: 0.0,
    solidity: 0.0,
    failedConditions: ['Semua syarat gerbang gagal'],
  );
}

/// Automatic Non-Coffee Photo Gatekeeper & Rejection Filter (OOD / Invalid Media Filter)
/// Strictly eliminates non-coffee photos (empty tables, cups without packaging, blurry/dark scenes, faces, random objects)
class NonCoffeeGatekeeperService {
  /// Evaluates a candidate packaging bounding box & polygon against the 4 mathematical gatekeeper rules
  static GatekeeperEvaluationResult evaluate({
    required Rect boundingBox,
    required List<Offset> polygonPoints,
    required int imageWidth,
    required int imageHeight,
    double detectionConfidence = 0.85,
    List<String> detectedTextLines = const [],
    AutoLabelConfig config = const AutoLabelConfig(),
  }) {
    if (imageWidth <= 0 || imageHeight <= 0 || boundingBox.isEmpty) {
      return GatekeeperEvaluationResult.emptyOrCorrupt;
    }

    final double totalImageArea = (imageWidth * imageHeight).toDouble();
    final double boxArea = (boundingBox.width * boundingBox.height).toDouble();
    final double areaRatio = (boxArea / totalImageArea).clamp(0.0, 1.0);
    final double aspectRatio = boundingBox.height > 0
        ? boundingBox.width / boundingBox.height
        : 1.0;

    // Calculate Polygon Area & Convex Hull Solidity
    final double polygonArea = _calculatePolygonArea(polygonPoints);
    final List<Offset> convexHull = _computeConvexHull(polygonPoints);
    final double hullArea = _calculatePolygonArea(convexHull);
    final double solidity = hullArea > 0 ? (polygonArea / hullArea).clamp(0.0, 1.0) : 1.0;

    final passed = <String>[];
    final failed = <String>[];

    // Syarat 1: Ambang Kepercayaan Deteksi Visual (s_i >= tau_det, default 0.42)
    final bool passConf = detectionConfidence >= config.detectionThreshold;
    if (passConf) {
      passed.add('Visual Confidence: ${(detectionConfidence * 100).toStringAsFixed(1)}% >= ${(config.detectionThreshold * 100).toStringAsFixed(0)}%');
    } else {
      failed.add('Visual Confidence terlalu rendah: ${(detectionConfidence * 100).toStringAsFixed(1)}% < ${(config.detectionThreshold * 100).toStringAsFixed(0)}%');
    }

    // Syarat 2: Rasio Luas Minimum & Maksimum terhadap Kanvas (0.025 <= area_ratio <= 0.95)
    final bool passArea = areaRatio >= config.minAreaRatio && areaRatio <= config.maxAreaRatio;
    if (passArea) {
      passed.add('Area Ratio: ${(areaRatio * 100).toStringAsFixed(1)}% (dalam batas ${config.minAreaRatio * 100}% - ${config.maxAreaRatio * 100}%)');
    } else {
      failed.add('Area Ratio tidak wajar: ${(areaRatio * 100).toStringAsFixed(1)}%');
    }

    // Syarat 3: Rasio Aspek Geometri Kemasan Pouch (0.20 <= w_i / h_i <= 2.40)
    final bool passAspect = aspectRatio >= config.minAspectRatio && aspectRatio <= config.maxAspectRatio;
    if (passAspect) {
      passed.add('Aspect Ratio: ${aspectRatio.toStringAsFixed(2)} (dalam rentang stand-up pouch)');
    } else {
      failed.add('Aspect Ratio bukan kemasan kantong/pouch: ${aspectRatio.toStringAsFixed(2)}');
    }

    // Syarat 4: Skor Kepadatan Poligon (Contour Solidity >= 0.62)
    final bool passSolidity = solidity >= config.minSolidity;
    if (passSolidity) {
      passed.add('Solidity Poligon: ${(solidity * 100).toStringAsFixed(1)}% >= ${(config.minSolidity * 100).toStringAsFixed(0)}%');
    } else {
      failed.add('Solidity Poligon terlalu cekung/berongga: ${(solidity * 100).toStringAsFixed(1)}%');
    }

    // Syarat Tambahan: Jika Solidity < 0.75, wajib memiliki teks kemasan kopi
    bool passTextPresence = true;
    if (solidity < 0.75 && detectedTextLines.isEmpty) {
      passTextPresence = false;
      failed.add('Poligon kurang solid (${(solidity * 100).toStringAsFixed(1)}%) dan tidak ditemukan teks kemasan');
    }

    final bool isValid = passConf && passArea && passAspect && passSolidity && passTextPresence;

    String? reason;
    if (!isValid) {
      reason = failed.join('; ');
    }

    return GatekeeperEvaluationResult(
      isValidCoffeeBag: isValid,
      rejectionReason: reason,
      confidenceScore: detectionConfidence,
      areaRatio: areaRatio,
      aspectRatio: aspectRatio,
      solidity: solidity,
      passedConditions: passed,
      failedConditions: failed,
    );
  }

  /// Calculates polygon area using the Shoelace formula (Gauss's area formula)
  static double _calculatePolygonArea(List<Offset> points) {
    if (points.length < 3) return 0.0;
    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      area += (points[i].dx * points[j].dy) - (points[j].dx * points[i].dy);
    }
    return (area.abs() / 2.0);
  }

  /// Andrew's Monotone Chain 2D Convex Hull algorithm O(n log n)
  static List<Offset> _computeConvexHull(List<Offset> points) {
    if (points.length <= 3) return points;

    final sorted = [...points]..sort((a, b) {
        final cmpX = a.dx.compareTo(b.dx);
        return cmpX != 0 ? cmpX : a.dy.compareTo(b.dy);
      });

    // 2D cross product of OA and OB vectors
    double crossProduct(Offset o, Offset a, Offset b) {
      return (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
    }

    // Build lower hull
    final lower = <Offset>[];
    for (final p in sorted) {
      while (lower.length >= 2 && crossProduct(lower[lower.length - 2], lower.last, p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }

    // Build upper hull
    final upper = <Offset>[];
    for (final p in sorted.reversed) {
      while (upper.length >= 2 && crossProduct(upper[upper.length - 2], upper.last, p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }

    lower.removeLast();
    upper.removeLast();
    return [...lower, ...upper];
  }
}
