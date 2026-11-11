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
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _selectedImage = file;
      _isEvaluating = true;
      _visionMatch = null;
      _autoLabelResult = null;
    });

    try {
      await IncrementalVisionEngine.instance.initialize();

      final tensor = await ImageTensorIsolate.preprocessSingleImage(file);
      final match = IncrementalVisionEngine.instance.classifyImage(tensor);

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
    const bgCream = Color(0xFFF9F6F0);
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 20),
      decoration: const BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8CFBE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.center_focus_strong_rounded, color: Color(0xFF0284C7), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uji Diagnostik Akurasi AI',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Live Cosine Similarity & Gatekeeper Telemetry',
                      style: TextStyle(color: textMuted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action buttons: Pick image
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B4423),
                    side: const BorderSide(color: Color(0xFFD8CFBE)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('Foto Kamera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => _pickAndEvaluate(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B4423),
                    side: const BorderSide(color: Color(0xFFD8CFBE)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: const Text('Pilih Galeri', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => _pickAndEvaluate(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Diagnostic Results Area
          Expanded(
            child: _isEvaluating
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF6B4423)),
                        SizedBox(height: 12),
                        Text(
                          'Menganalisis kemasan & menghitung Cosine Similarity...',
                          style: TextStyle(color: textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : _selectedImage == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_search_rounded, size: 48, color: textMuted.withValues(alpha: 0.4)),
                            const SizedBox(height: 8),
                            const Text(
                              'Pilih atau foto kemasan kopi untuk menguji akurasi model',
                              style: TextStyle(color: textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail & status
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFEFE8DE), width: 1.1),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(_selectedImage!, width: 64, height: 64, fit: BoxFit.cover),
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
                                                ? const Color(0xFF059669)
                                                : const Color(0xFFD97706),
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _visionMatch?.classSlug ?? 'Belum ada model yang cocok (Threshold 65%)',
                                          style: const TextStyle(
                                            color: textDark,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Inferensi: ${_visionMatch?.inferenceTimeMs.toStringAsFixed(1)} ms • ${_visionMatch?.totalClassesEvaluated} class',
                                          style: const TextStyle(color: textMuted, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Cosine Similarity Meter
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFEFE8DE), width: 1.1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Cosine Similarity Score',
                                        style: TextStyle(color: textDark, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${((_visionMatch?.confidence ?? 0.0) * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: (_visionMatch?.confidence ?? 0.0) >= 0.65
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFD97706),
                                          fontSize: 13,
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
                                      backgroundColor: const Color(0xFFE8DFD8),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        (_visionMatch?.confidence ?? 0.0) >= 0.65
                                            ? const Color(0xFF059669)
                                            : const Color(0xFFD97706),
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Gatekeeper Diagnostic Card
                            if (_autoLabelResult != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _autoLabelResult!.isRejected
                                        ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                                        : const Color(0xFF059669).withValues(alpha: 0.4),
                                    width: 1.1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _autoLabelResult!.isRejected ? Icons.cancel_outlined : Icons.check_circle_outlined,
                                          size: 16,
                                          color: _autoLabelResult!.isRejected
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF059669),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _autoLabelResult!.isRejected
                                              ? 'Non-Coffee Gatekeeper: DITOLAK'
                                              : 'Non-Coffee Gatekeeper: VALID KEMASAN KOPI',
                                          style: TextStyle(
                                            color: _autoLabelResult!.isRejected
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF059669),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Aspect Ratio: ${_autoLabelResult!.gatekeeperResult.aspectRatio.toStringAsFixed(2)} • Solidity: ${(_autoLabelResult!.gatekeeperResult.solidity * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(color: textMuted, fontSize: 10.5),
                                    ),
                                    if (_autoLabelResult!.ocrResult != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'OCR Parsed Slug: ${_autoLabelResult!.ocrResult!.canonicalSlug}',
                                        style: const TextStyle(color: Color(0xFFB45309), fontSize: 10.5, fontWeight: FontWeight.bold),
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
