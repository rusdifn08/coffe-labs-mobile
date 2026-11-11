import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coffee_hub_mobile/features/scanner/domain/services/image_tensor_isolate.dart';
import 'package:coffee_hub_mobile/features/scanner/domain/services/incremental_vision_engine.dart';
import 'package:coffee_hub_mobile/features/annotation_studio/domain/services/coffee_bag_segmenter_service.dart';

class StudioLiveDiagnosticSheet extends StatefulWidget {
  const StudioLiveDiagnosticSheet({super.key});

  @override
  State<StudioLiveDiagnosticSheet> createState() => _StudioLiveDiagnosticSheetState();
}

class _StudioLiveDiagnosticSheetState extends State<StudioLiveDiagnosticSheet> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isEvaluating = false;
  VisionMatchResult? _visionMatch;
  AutoLabelResult? _autoLabelResult;

  Future<void> _pickAndEvaluate(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo == null) return;

      final file = File(photo.path);
      setState(() {
        _selectedImage = file;
        _isEvaluating = true;
        _visionMatch = null;
        _autoLabelResult = null;
      });

      // 1. Initialize vision engine
      await IncrementalVisionEngine.instance.initialize();

      // 2. Preprocess & Classify NCM Prototype
      final tensor = await ImageTensorIsolate.preprocessSingleImage(file);
      final match = IncrementalVisionEngine.instance.classifyImage(tensor);

      // 3. Run Segmenter & Gatekeeper
      final labelResult = await CoffeeBagSegmenterService.processSingleImage(
        imageFile: file,
        existingClasses: IncrementalVisionEngine.instance.cachedRecords.map((r) => r.classSlug).toList(),
      );

      setState(() {
        _isEvaluating = false;
        _visionMatch = match;
        _autoLabelResult = labelResult;
      });
    } catch (e) {
      setState(() => _isEvaluating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error diagnostik: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.only(top: 16, left: 18, right: 18, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1F1813), // Warm Dark Roast
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.center_focus_strong, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uji Diagnostik Akurasi AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Live Cosine Similarity & Non-Coffee Gatekeeper Tester',
                      style: TextStyle(color: Color(0xFFD4A373), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons: Pick image
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD4AF37),
                    side: const BorderSide(color: Color(0xFFD4AF37)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('Foto Kamera', style: TextStyle(fontSize: 12)),
                  onPressed: () => _pickAndEvaluate(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: const Text('Pilih Galeri', style: TextStyle(fontSize: 12)),
                  onPressed: () => _pickAndEvaluate(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Diagnostic Results Area
          Expanded(
            child: _isEvaluating
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFD4AF37)),
                        SizedBox(height: 12),
                        Text(
                          'Menganalisis kemasan & menghitung Cosine Similarity...',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : _selectedImage == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_search, size: 54, color: Colors.white.withValues(alpha: 0.2)),
                            const SizedBox(height: 10),
                            const Text(
                              'Pilih atau foto kemasan kopi untuk menguji akurasi model',
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail & status
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(_selectedImage!, width: 70, height: 70, fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _visionMatch?.isRecognized == true
                                            ? '🎯 RECOGNIZED MODEL'
                                            : '❓ UNRECOGNIZED / FALLBACK',
                                        style: TextStyle(
                                          color: _visionMatch?.isRecognized == true
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFECA400),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _visionMatch?.classSlug ?? 'Belum ada model yang cocok (Threshold 65%)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Inferensi: ${_visionMatch?.inferenceTimeMs.toStringAsFixed(1)} ms • ${_visionMatch?.totalClassesEvaluated} class',
                                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Cosine Similarity Meter
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF261D16),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF3B2D24)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Cosine Similarity Score',
                                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${((_visionMatch?.confidence ?? 0.0) * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: (_visionMatch?.confidence ?? 0.0) >= 0.65
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFECA400),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (_visionMatch?.confidence ?? 0.0).clamp(0.0, 1.0),
                                      backgroundColor: Colors.white12,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        (_visionMatch?.confidence ?? 0.0) >= 0.65
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFECA400),
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Gatekeeper Diagnostic Card
                            if (_autoLabelResult != null) ...[
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF261D16),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _autoLabelResult!.isRejected
                                        ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                                        : const Color(0xFF10B981).withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _autoLabelResult!.isRejected ? Icons.cancel : Icons.check_circle,
                                          size: 16,
                                          color: _autoLabelResult!.isRejected
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF10B981),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _autoLabelResult!.isRejected
                                              ? 'Non-Coffee Gatekeeper: DITOLAK'
                                              : 'Non-Coffee Gatekeeper: VALID KEMASAN KOPI',
                                          style: TextStyle(
                                            color: _autoLabelResult!.isRejected
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF10B981),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Aspect Ratio: ${_autoLabelResult!.gatekeeperResult.aspectRatio.toStringAsFixed(2)} • Solidity: ${(_autoLabelResult!.gatekeeperResult.solidity * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                                    ),
                                    if (_autoLabelResult!.ocrResult != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'OCR Parsed Slug: ${_autoLabelResult!.ocrResult!.canonicalSlug}',
                                        style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
