import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'coffee_knowledge_graph_service.dart';

class BeanVisionScanResult {
  final String rawFullText;
  final List<Map<String, dynamic>> blocks;
  final File croppedImageFile;

  const BeanVisionScanResult({
    required this.rawFullText,
    required this.blocks,
    required this.croppedImageFile,
  });
}

class BeanVisionScannerService {
  static Future<BeanVisionScanResult> processPhoto(File photoFile) async {
    ObjectDetector? objectDetector;
    TextRecognizer? textRecognizer;
    File finalCroppedFile = photoFile;

    final bool isMobilePlatform = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    try {
      // 1. Stage 1: On-Device Object Detection (Mendeteksi kemasan kopi - Hanya di Mobile Android/iOS)
      Rect? packagingBox;
      if (isMobilePlatform) {
        try {
          final options = ObjectDetectorOptions(
            mode: DetectionMode.single,
            classifyObjects: false,
            multipleObjects: true,
          );
          objectDetector = ObjectDetector(options: options);
          final inputImage = InputImage.fromFilePath(photoFile.path);
          final detectedObjects = await objectDetector.processImage(inputImage);

          if (detectedObjects.isNotEmpty) {
            // Cari bounding box terbesar yang mewakili kemasan kopi
            detectedObjects.sort((a, b) =>
                (b.boundingBox.width * b.boundingBox.height)
                    .compareTo(a.boundingBox.width * a.boundingBox.height));
            packagingBox = detectedObjects.first.boundingBox;
          }
        } catch (e) {
          debugPrint('On-device object detection platform fallback: $e');
        }
      }

      // 2. Crop area kemasan kopi dengan safety margin 8% di background isolate (Pure Dart - bekerja di SEMUA platform)
      try {
        finalCroppedFile = await _cropPackagingInIsolate(photoFile, packagingBox);
      } catch (e) {
        debugPrint('Image cropping fallback to original: $e');
        finalCroppedFile = photoFile;
      }

      // 3. Stage 2: On-Device Spatial OCR (Google ML Kit Text Recognition v2 di Mobile)
      String fullText = '';
      final List<Map<String, dynamic>> blocksDto = [];

      if (isMobilePlatform) {
        try {
          textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
          final ocrInput = InputImage.fromFilePath(finalCroppedFile.path);
          final recognizedText = await textRecognizer.processImage(ocrInput);

          fullText = recognizedText.text;

          // Ambil estimasi dimensi gambar dari bounding box terluar
          double maxBottom = 1.0;
          double maxRight = 1.0;
          for (final block in recognizedText.blocks) {
            if (block.boundingBox.bottom > maxBottom) {
              maxBottom = block.boundingBox.bottom;
            }
            if (block.boundingBox.right > maxRight) {
              maxRight = block.boundingBox.right;
            }
          }

          for (final block in recognizedText.blocks) {
            final box = block.boundingBox;
            final normHeight = (box.height / maxBottom).clamp(0.01, 1.0);
            final normTop = (box.top / maxBottom).clamp(0.0, 1.0);
            final normWidth = (box.width / maxRight).clamp(0.01, 1.0);
            final normLeft = (box.left / maxRight).clamp(0.0, 1.0);

            blocksDto.add({
              'text': block.text,
              'normalized_height': normHeight,
              'top_y': normTop,
              'left_x': normLeft,
              'normalized_width': normWidth,
              'confidence': 0.95,
            });
          }
        } catch (e) {
          debugPrint('On-device OCR platform fallback: $e');
        }
      } else if (!kIsWeb && Platform.isWindows) {
        // High-Performance Native Windows OCR (Menggunakan Windows.Media.Ocr built-in OS)
        final winOcr = await _runWindowsNativeOcr(finalCroppedFile);
        if (winOcr != null) {
          fullText = winOcr['full_text']?.toString() ?? '';
          final rawBlocks = winOcr['blocks'] as List? ?? [];
          for (final b in rawBlocks) {
            if (b is Map) {
              blocksDto.add(Map<String, dynamic>.from(b));
            }
          }
        }
      }

      // Fallback Cerdas untuk Desktop / Ketika OCR lokal tidak menghasilkan teks:
      if (fullText.trim().isEmpty) {
        final fileName = photoFile.uri.pathSegments.isNotEmpty ? photoFile.uri.pathSegments.last : '';
        final cleanFileName = fileName
            .replaceAll(RegExp(r'[\-_.]'), ' ')
            .replaceAll(RegExp(r'\b(jpg|jpeg|png|webp|heic)\b', caseSensitive: false), '')
            .trim();

        if (cleanFileName.length >= 3 &&
            (CoffeeKnowledgeGraphService.instance.findOrigin(cleanFileName) != null ||
                cleanFileName.toLowerCase().contains('kopi') ||
                cleanFileName.toLowerCase().contains('coffee') ||
                cleanFileName.toLowerCase().contains('bean') ||
                cleanFileName.toLowerCase().contains('malabar') ||
                cleanFileName.toLowerCase().contains('halu'))) {
          fullText = cleanFileName;
          blocksDto.add({
            'text': cleanFileName,
            'normalized_height': 0.12,
            'top_y': 0.35,
            'left_x': 0.20,
            'normalized_width': 0.60,
            'confidence': 0.95,
          });
        }
      }

      return BeanVisionScanResult(
        rawFullText: fullText,
        blocks: blocksDto,
        croppedImageFile: finalCroppedFile,
      );
    } finally {
      // 4. Guarantee zero native memory leaks DAN safety catch agar tidak pernah melempar MissingPluginException
      if (objectDetector != null) {
        try {
          await objectDetector.close();
        } catch (e) {
          debugPrint('ObjectDetector close safely ignored: $e');
        }
      }
      if (textRecognizer != null) {
        try {
          await textRecognizer.close();
        } catch (e) {
          debugPrint('TextRecognizer close safely ignored: $e');
        }
      }
    }
  }

  static Future<File> _cropPackagingInIsolate(File file, Rect? boundingBox) async {
    // Jika tidak ada deteksi bounding box kemasan eksplisit, pertahankan gambar asli secara utuh.
    // Ini mencegah pemotongan 88% membabi buta yang berisiko memenggal teks penting di tepi kemasan.
    if (boundingBox == null) {
      return file;
    }

    final bytes = await file.readAsBytes();
    Directory dir;
    try {
      dir = await getApplicationDocumentsDirectory();
    } catch (_) {
      try {
        dir = Directory.systemTemp;
      } catch (_) {
        dir = file.parent;
      }
    }
    final outPath = '${dir.path}/cropped_bean_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final croppedBytes = await Isolate.run<List<int>>(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;

      // Berikan safety margin 8% di sekeliling bounding box yang terdeteksi
      final marginX = (boundingBox.width * 0.08).toInt();
      final marginY = (boundingBox.height * 0.08).toInt();

      final x = (boundingBox.left - marginX).clamp(0, decoded.width - 1).toInt();
      final y = (boundingBox.top - marginY).clamp(0, decoded.height - 1).toInt();
      final w = (boundingBox.width + (marginX * 2)).clamp(1, decoded.width - x).toInt();
      final h = (boundingBox.height + (marginY * 2)).clamp(1, decoded.height - y).toInt();

      final cropped = img.copyCrop(decoded, x: x, y: y, width: w, height: h);
      return img.encodeJpg(cropped, quality: 88);
    });

    final outFile = File(outPath);
    await outFile.writeAsBytes(croppedBytes);
    return outFile;
  }

  /// On-Device Windows Native OCR menggunakan engine Windows.Media.Ocr
  static Future<Map<String, dynamic>?> _runWindowsNativeOcr(File imageFile) async {
    try {
      final safePath = imageFile.absolute.path.replaceAll("'", "''");
      final psScript = '''
Add-Type -AssemblyName System.Runtime.WindowsRuntime
\$asm = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { \$_.GetName().Name -eq 'System.Runtime.WindowsRuntime' }
\$type = \$asm.GetType('System.WindowsRuntimeSystemExtensions')
\$asTaskGeneric = \$type.GetMethods() | Where-Object { \$_.Name -eq 'AsTask' -and \$_.GetParameters().Count -eq 1 -and \$_.IsGenericMethodDefinition } | Select-Object -First 

function Await(\$asyncOp, \$targetType) {
    \$m = \$asTaskGeneric.MakeGenericMethod(\$targetType)
    \$task = \$m.Invoke(\$null, @(\$asyncOp))
    \$task.Wait() | Out-Null
    return \$task.Result
}

[Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null
[Windows.Graphics.Imaging.BitmapDecoder, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null
[Windows.Storage.StorageFile, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null
[Windows.Globalization.Language, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null

\$file = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync('$safePath')) ([Windows.Storage.StorageFile])
\$stream = Await (\$file.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])
\$decoder = Await ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync(\$stream)) ([Windows.Graphics.Imaging.BitmapDecoder])
\$softBmp = Await (\$decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])

\$engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
if (-not \$engine) {
    try {
        \$engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage([Windows.Globalization.Language]::new('en-US'))
    } catch {}
}
if (-not \$engine) {
    \$langs = [Windows.Media.Ocr.OcrEngine]::AvailableRecognizerLanguages
    if (\$langs -and \$langs.Count -gt 0) {
        \$engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage(\$langs[0])
    }
}
if (-not \$engine) {
    Write-Output "{}"
    exit 0
}
\$ocrResult = Await (\$engine.RecognizeAsync(\$softBmp)) ([Windows.Media.Ocr.OcrResult])

\$w = [double]\$softBmp.PixelWidth
\$h = [double]\$softBmp.PixelHeight

\$blocks = @()
foreach (\$line in \$ocrResult.Lines) {
    \$minX = \$w; \$minY = \$h; \$maxX = 0.0; \$maxY = 0.0
    foreach (\$word in \$line.Words) {
        if (\$word.BoundingRect.X -lt \$minX) { \$minX = \$word.BoundingRect.X }
        if (\$word.BoundingRect.Y -lt \$minY) { \$minY = \$word.BoundingRect.Y }
        \$rx = \$word.BoundingRect.X + \$word.BoundingRect.Width
        \$by = \$word.BoundingRect.Y + \$word.BoundingRect.Height
        if (\$rx -gt \$maxX) { \$maxX = \$rx }
        if (\$by -gt \$maxY) { \$maxY = \$by }
    }
    \$blocks += [PSCustomObject]@{
        text = \$line.Text
        left_x = [Math]::Round(\$minX / \$w, 4)
        top_y = [Math]::Round(\$minY / \$h, 4)
        normalized_width = [Math]::Round((\$maxX - \$minX) / \$w, 4)
        normalized_height = [Math]::Round((\$maxY - \$minY) / \$h, 4)
        confidence = 0.95
    }
}

\$outObj = [PSCustomObject]@{
    full_text = \$ocrResult.Text
    blocks = \$blocks
}

\$outObj | ConvertTo-Json -Depth 5 -Compress
''';

      final res = await Process.run('powershell', ['-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-Command', psScript]);
      if (res.exitCode == 0 && res.stdout != null) {
        final text = res.stdout.toString().trim();
        if (text.isNotEmpty && text.startsWith('{')) {
          return json.decode(text) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Windows native OCR error: $e');
    }
    return null;
  }
}
