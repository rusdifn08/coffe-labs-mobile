import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class OcrTextRegion {
  final String text;
  final double confidence;
  final double yRel;
  final double fontHeight;

  const OcrTextRegion({
    required this.text,
    required this.confidence,
    required this.yRel,
    required this.fontHeight,
  });
}

class CoffeeOcrResult {
  final List<String> rawLines;
  final String brand;
  final String coffeeName;
  final String process;
  final String generatedSlug;
  final double confidence;
  final String? matchedExistingClass;
  final double similarityScore;
  final bool isNewClass;

  const CoffeeOcrResult({
    required this.rawLines,
    required this.brand,
    required this.coffeeName,
    required this.process,
    required this.generatedSlug,
    required this.confidence,
    this.matchedExistingClass,
    this.similarityScore = 0.0,
    this.isNewClass = true,
  });

  String get canonicalSlug => generatedSlug;
}

class CoffeePackagingOcrEngine {
  static const Set<String> knownBrands = {
    'fugol', 'twentyfr', '5758', 'anomali', 'tanamera', 'sakha', 'space',
    'otten', 'commongrounds', 'instinct', 'smokingbarrels', 'herd', 'kuro',
    'simetri', 'expatroasters', 'hungrybird', 'sensa', 'strada', 'morph',
    'elmakko', 'javadancer', 'wisangkopi', 'fore', 'kenangan', 'pointcoffee',
    'djournal', 'excelso', 'kapalapi', 'torabika', 'goodday', 'indocafe', 'bak',
    'bandungkopi', 'tigaikat', 'wanoja', 'gardja', 'twohands'
  };

  static final List<MapEntry<RegExp, String>> processPatterns = [
    MapEntry(RegExp(r'\b(anaerobic\s*natural)\b', caseSensitive: false), 'anaerobicnatural'),
    MapEntry(RegExp(r'\b(anaerobic\s*washed)\b', caseSensitive: false), 'anaerobicwashed'),
    MapEntry(RegExp(r'\b(anaerobic\s*honey)\b', caseSensitive: false), 'anaerobichoney'),
    MapEntry(RegExp(r'\b(carbonic\s*maceration|cm\s*natural)\b', caseSensitive: false), 'carbonic'),
    MapEntry(RegExp(r'\b(thermal\s*shock)\b', caseSensitive: false), 'thermalshock'),
    MapEntry(RegExp(r'\b(black\s*honey)\b', caseSensitive: false), 'blackhoney'),
    MapEntry(RegExp(r'\b(red\s*honey)\b', caseSensitive: false), 'redhoney'),
    MapEntry(RegExp(r'\b(yellow\s*honey)\b', caseSensitive: false), 'yellowhoney'),
    MapEntry(RegExp(r'\b(white\s*honey)\b', caseSensitive: false), 'whitehoney'),
    MapEntry(RegExp(r'\b(semi\s*washed|wet\s*hulled|giling\s*basah)\b', caseSensitive: false), 'semiwashed'),
    MapEntry(RegExp(r'\b(full\s*washed|fully\s*washed|washed|wet\s*process)\b', caseSensitive: false), 'washed'),
    MapEntry(RegExp(r'\b(wine\s*process|natural\s*wine|winey|wine)\b', caseSensitive: false), 'wine'),
    MapEntry(RegExp(r'\b(anaerobic)\b', caseSensitive: false), 'anaerobic'),
    MapEntry(RegExp(r'\b(natural\s*process|dry\s*process|natural)\b', caseSensitive: false), 'natural'),
    MapEntry(RegExp(r'\b(honey\s*process|honey)\b', caseSensitive: false), 'honey'),
    MapEntry(RegExp(r'\b(lactic)\b', caseSensitive: false), 'lactic'),
    MapEntry(RegExp(r'\b(koji)\b', caseSensitive: false), 'koji'),
    MapEntry(RegExp(r'\b(decaf|decaffeinated)\b', caseSensitive: false), 'decaf'),
    MapEntry(RegExp(r'\b(espresso\s*blend|espresso\s*roast|espresso)\b', caseSensitive: false), 'espresso'),
  ];

  static const List<String> knownOrigins = [
    'halu banana', 'halubanana', 'gunung halu', 'halu', 'aceh gayo', 'gayo',
    'toraja sapan', 'toraja', 'bali kintamani', 'kintamani', 'flores bajawa',
    'bajawa', 'java preanger', 'preanger', 'gunung puntang', 'puntang',
    'gunung malabar', 'malabar', 'papua wamena', 'wamena', 'kerinci',
    'mandheling', 'lintong', 'temanggung', 'sindoro', 'ijen', 'raung',
    'argopuro', 'garut', 'ciwidey', 'pangalengan', 'kamojang', 'manglayang',
    'sidikalang', 'sipirok', 'solok radjo', 'solok', 'lampung', 'manggarai',
    'tambora', 'ethiopia', 'yirgacheffe', 'guji', 'sidamo', 'colombia',
    'brazil', 'cerrado', 'kenya', 'panama', 'geisha', 'gesha', 'pink bourbon',
    'bourbon', 'caturra', 'typica', 'sl28', 'abyssinia', 'house blend',
    'signature blend', 'breakfast blend', 'watermelon smash', 'watermelonsmash'
  ];

  static final RegExp stopwordsRegex = RegExp(
    r'\b(\d+\s*(g|gr|gram|grams|kg|ml|oz)|100%|80%|20%|50%|70%|30%|'
    r'arabica|arabika|robusta|blend\s*of|fresh\s*roasting|fresh\s*grinding|'
    r'fresh\s*bean|better\s*brew|roasting\s*date|roast\s*date|dari\s*gunung|'
    r'untuk\s*cita\s*rasa|cita\s*rasa\s*terbaik|'
    r'guarantee|perfect\s*for|es\s*kopi\s*susu|single\s*origin|specialty|'
    r'coffee|roasters|roastery|company|co\.|lab|beans|bean|whole\s*bean|ground|'
    r'biji\s*kopi|kopi\s*bubuk|kopi|netto|net\s*weight|net\s*wt|p-irt|halal|bpom|'
    r'roast\s*level|light\s*roast|medium\s*roast|dark\s*roast|omni\s*roast|'
    r'notes|tasting\s*notes|process|proses|origin|region|altitude|masl|mdpl|'
    r'varietal|variety|producer|processor|grade\s*1)\b',
    caseSensitive: false,
  );

  /// Preprocess packaging area: sets outside pixels to white (255) and enhances contrast
  static img.Image preprocessIsolatedBag({
    required img.Image sourceImage,
    required List<int> bboxXyxy, // [x1, y1, x2, y2]
    List<math.Point<int>>? polygonPoints,
  }) {
    final int wImg = sourceImage.width;
    final int hImg = sourceImage.height;
    final int x1 = bboxXyxy[0].clamp(0, wImg - 1);
    final int y1 = bboxXyxy[1].clamp(0, hImg - 1);
    final int x2 = bboxXyxy[2].clamp(x1 + 1, wImg);
    final int y2 = bboxXyxy[3].clamp(y1 + 1, hImg);

    final img.Image cropped = img.copyCrop(
      sourceImage,
      x: x1,
      y: y1,
      width: x2 - x1,
      height: y2 - y1,
    );

    if (polygonPoints != null && polygonPoints.length >= 3) {
      for (int py = 0; py < cropped.height; py++) {
        for (int px = 0; px < cropped.width; px++) {
          if (!_isPointInPolygon(px + x1, py + y1, polygonPoints)) {
            cropped.setPixelRgb(px, py, 255, 255, 255);
          }
        }
      }
    }

    // Peningkatan kontras lokal untuk mengatasi pantulan cahaya plastik/foil kemasan
    return img.contrast(img.normalize(cropped, min: 0, max: 255), contrast: 118);
  }

  static bool _isPointInPolygon(int x, int y, List<math.Point<int>> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].x, yi = polygon[i].y;
      final xj = polygon[j].x, yj = polygon[j].y;
      final intersect = ((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / ((yj - yi) == 0 ? 1e-5 : (yj - yi)) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  static String _cleanSlugToken(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
  }

  static CoffeeOcrResult parseCoffeeEntities({
    required List<OcrTextRegion> ocrRegions,
    required List<String> existingClasses,
    String fallbackFilename = '',
  }) {
    final Set<String> dynamicBrands = {...knownBrands};
    for (final clsName in existingClasses) {
      final parts = clsName.toLowerCase().split('_');
      if (parts.length >= 2 && parts[0].length >= 3) {
        dynamicBrands.add(parts[0]);
      }
    }

    final sortedByY = [...ocrRegions]..sort((a, b) => a.yRel.compareTo(b.yRel));
    final List<String> rawLines = sortedByY.map((r) => r.text).toList();
    final String fullTextLower = rawLines.join(' ').toLowerCase();
    final String alphaNumSpace = fullTextLower.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');

    // 1. DETEKSI SLOT BRAND
    String detectedBrand = '';
    final sortedBrands = dynamicBrands.toList()..sort((a, b) => b.length.compareTo(a.length));
    for (final bCand in sortedBrands) {
      if (RegExp(r'\b' + RegExp.escape(bCand) + r'\b').hasMatch(alphaNumSpace)) {
        detectedBrand = _cleanSlugToken(bCand);
        break;
      }
    }

    if (detectedBrand.isEmpty && ocrRegions.isNotEmpty) {
      final topRegions = sortedByY.where((r) => r.yRel <= 0.35);
      for (final tr in topRegions) {
        final candidate = tr.text.replaceAll(stopwordsRegex, '');
        final candidateClean = _cleanSlugToken(candidate);
        if (candidateClean.length >= 3 && !knownOrigins.any((o) => _cleanSlugToken(o) == candidateClean)) {
          detectedBrand = candidateClean.substring(0, math.min(16, candidateClean.length));
          break;
        }
      }
    }

    // 2. DETEKSI SLOT PROSES PASCAPANEN
    String detectedProcess = '';
    for (final entry in processPatterns) {
      if (entry.key.hasMatch(fullTextLower)) {
        detectedProcess = entry.value;
        break;
      }
    }

    // 3. DETEKSI SLOT NAMA KOPI / ORIGIN
    String detectedCoffeeName = '';
    final sortedOrigins = [...knownOrigins]..sort((a, b) => b.length.compareTo(a.length));
    for (final origin in sortedOrigins) {
      if (RegExp(r'\b' + RegExp.escape(origin) + r'\b').hasMatch(fullTextLower)) {
        detectedCoffeeName = _cleanSlugToken(origin);
        break;
      }
    }

    if (detectedCoffeeName.isEmpty && ocrRegions.isNotEmpty) {
      final sortedByFont = [...ocrRegions]..sort((a, b) => b.fontHeight.compareTo(a.fontHeight));
      for (final reg in sortedByFont) {
        String cleanedLine = reg.text.replaceAll(stopwordsRegex, ' ');
        if (detectedBrand.isNotEmpty) {
          cleanedLine = cleanedLine.replaceAll(
            RegExp(r'\b' + RegExp.escape(detectedBrand) + r'\b', caseSensitive: false),
            ' ',
          );
        }
        if (detectedProcess.isNotEmpty) {
          cleanedLine = cleanedLine.replaceAll(
            RegExp(r'\b' + RegExp.escape(detectedProcess) + r'\b', caseSensitive: false),
            ' ',
          );
        }
        final slugCand = _cleanSlugToken(cleanedLine);
        if (slugCand.length >= 3) {
          detectedCoffeeName = slugCand.substring(0, math.min(22, slugCand.length));
          break;
        }
      }
    }

    // 4. RAKIT SLUG BAKU: {brand}_{nama_kopi}_{proses}
    final slugParts = [detectedBrand, detectedCoffeeName, detectedProcess]
        .where((p) => p.isNotEmpty)
        .toList();
    final String generatedSlug =
        slugParts.isNotEmpty ? slugParts.join('_') : 'unlabeled_coffee_bag';

    // 5. SMART CLASS MATCHING TERHADAP CLASS YANG SUDAH ADA DI SQLITE
    String? bestExisting;
    double bestSim = 0.0;
    for (final clsName in existingClasses) {
      final clsNorm = clsName.toLowerCase().trim().replaceAll(' ', '_');
      final seqSim = _sequenceSimilarity(generatedSlug, clsNorm);
      final genTokens = generatedSlug.split('_').toSet();
      final clsTokens = clsNorm.split('_').toSet();
      final unionLen = genTokens.union(clsTokens).length;
      final jaccard = unionLen == 0 ? 0.0 : genTokens.intersection(clsTokens).length / unionLen;
      final combinedSim = (0.65 * seqSim) + (0.35 * jaccard);

      if (combinedSim > bestSim) {
        bestSim = combinedSim;
        bestExisting = clsName;
      }
    }

    final bool isNew = !(bestExisting != null && bestSim >= 0.85);
    final double avgConf = ocrRegions.isEmpty
        ? 0.5
        : ocrRegions.map((e) => e.confidence).reduce((a, b) => a + b) / ocrRegions.length;

    return CoffeeOcrResult(
      rawLines: rawLines,
      brand: detectedBrand.isNotEmpty ? detectedBrand : 'unknownbrand',
      coffeeName: detectedCoffeeName.isNotEmpty ? detectedCoffeeName : 'unknowncoffee',
      process: detectedProcess.isNotEmpty ? detectedProcess : 'standard',
      generatedSlug: generatedSlug,
      confidence: avgConf,
      matchedExistingClass: bestExisting,
      similarityScore: bestSim,
      isNewClass: isNew,
    );
  }

  static double _sequenceSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    final int distance = _levenshtein(s1, s2);
    return 1.0 - (distance / math.max(s1.length, s2.length));
  }

  static int _levenshtein(String a, String b) {
    final List<List<int>> dp = List.generate(
      a.length + 1,
      (_) => List<int>.filled(b.length + 1, 0),
    );
    for (int i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce(math.min);
      }
    }
    return dp[a.length][b.length];
  }

  /// Runs full OCR on an image file, extracting text regions using ML Kit on mobile with pure Dart fallback
  static Future<CoffeeOcrResult> processImageFile({
    required File imageFile,
    required List<String> existingClasses,
    List<ui.Offset>? normalizedPolygon,
    List<double>? normalizedBbox,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final sourceImg = img.decodeImage(bytes);
    if (sourceImg == null) {
      return parseCoffeeEntities(
        ocrRegions: [],
        existingClasses: existingClasses,
      );
    }

    final int wImg = sourceImg.width;
    final int hImg = sourceImg.height;

    // Convert normalized bbox / polygon to pixel space
    List<int> pixelBbox;
    if (normalizedBbox != null && normalizedBbox.length >= 4) {
      pixelBbox = [
        (normalizedBbox[0] * wImg).round(),
        (normalizedBbox[1] * hImg).round(),
        (normalizedBbox[2] * wImg).round(),
        (normalizedBbox[3] * hImg).round(),
      ];
    } else {
      pixelBbox = [0, 0, wImg, hImg];
    }

    List<math.Point<int>>? pixelPoly;
    if (normalizedPolygon != null && normalizedPolygon.length >= 3) {
      pixelPoly = normalizedPolygon
          .map((p) => math.Point<int>((p.dx * wImg).round(), (p.dy * hImg).round()))
          .toList();
    }

    // Preprocess isolated bag
    final processedImg = preprocessIsolatedBag(
      sourceImage: sourceImg,
      bboxXyxy: pixelBbox,
      polygonPoints: pixelPoly,
    );

    // Save temporary isolated image for OCR
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/ocr_prep_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(img.encodeJpg(processedImg, quality: 90));

    final ocrRegions = <OcrTextRegion>[];

    // Try Google ML Kit Text Recognizer on supported mobile platforms
    final bool isMobilePlatform = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (isMobilePlatform) {
      try {
        final inputImage = InputImage.fromFilePath(tempFile.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        await textRecognizer.close();

        final double bagHeight = (pixelBbox[3] - pixelBbox[1]).toDouble();
        for (final block in recognizedText.blocks) {
          for (final line in block.lines) {
            final text = line.text.trim();
            if (text.isEmpty) continue;

            final double yCenter = line.boundingBox.center.dy;
            final double yRel = bagHeight > 0 ? (yCenter / bagHeight).clamp(0.0, 1.0) : 0.0;
            final double fontHeight = line.boundingBox.height;

            ocrRegions.add(OcrTextRegion(
              text: text,
              confidence: 0.90,
              yRel: yRel,
              fontHeight: fontHeight,
            ));
          }
        }
      } catch (e) {
        debugPrint('MLKit OCR notice: $e. Falling back to filename/text heuristics.');
      }
    }

    // Fallback: If OCR returns no lines, extract tokens from filename
    if (ocrRegions.isEmpty) {
      final nameTokens = imageFile.uri.pathSegments.last.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
      final parts = nameTokens.split(RegExp(r'[-_ ]+'));
      for (int i = 0; i < parts.length; i++) {
        final p = parts[i].trim();
        if (p.isNotEmpty) {
          ocrRegions.add(OcrTextRegion(
            text: p,
            confidence: 0.70,
            yRel: i / math.max(1, parts.length),
            fontHeight: 20.0,
          ));
        }
      }
    }

    try {
      if (await tempFile.exists()) await tempFile.delete();
    } catch (_) {}

    return parseCoffeeEntities(
      ocrRegions: ocrRegions,
      existingClasses: existingClasses,
    );
  }
}
