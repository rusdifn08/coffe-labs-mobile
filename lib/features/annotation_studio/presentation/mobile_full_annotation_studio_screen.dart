import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/studio_image_item.dart';
import '../domain/services/coffee_ocr_parser_service.dart';
import 'controllers/annotation_studio_controller.dart';
import 'widgets/smart_ocr_class_bottom_sheet.dart';
import 'widgets/studio_interactive_canvas.dart';

class MobileFullAnnotationStudioScreen extends ConsumerStatefulWidget {
  final StudioImageItem imageItem;

  const MobileFullAnnotationStudioScreen({
    super.key,
    required this.imageItem,
  });

  @override
  ConsumerState<MobileFullAnnotationStudioScreen> createState() =>
      _MobileFullAnnotationStudioScreenState();
}

class _MobileFullAnnotationStudioScreenState
    extends ConsumerState<MobileFullAnnotationStudioScreen> {
  bool _isSmartTapMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(annotationStudioProvider.notifier).setActiveItem(widget.imageItem);
    });
  }

  void _triggerAutoLabel() async {
    final notifier = ref.read(annotationStudioProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Menjalankan Segmentasi Poligon & OCR On-Device...'),
          ],
        ),
        backgroundColor: Color(0xFF7C3AED),
        duration: Duration(seconds: 2),
      ),
    );

    final result = await notifier.autoLabelActiveImage();

    if (!mounted || result == null) return;

    if (result.isRejected) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            '🚫 Foto Tidak Sesuai: ${result.rejectionReason ?? "Bukan Coffee Bag"}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Tutup',
            textColor: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    } else {
      // Valid Coffee Bag -> Show SmartOcrClassBottomSheet
      final ocr = result.ocrResult;
      if (ocr != null && mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => SmartOcrClassBottomSheet(
            ocrResult: ocr,
            existingClasses: ref.read(annotationStudioProvider).classes,
            onConfirm: ({
              required String classSlug,
              required String brand,
              required String coffeeName,
              required String process,
              required bool isNewClass,
            }) {
              notifier.saveActiveItem(
                classSlug: classSlug,
                brand: brand,
                coffeeName: coffeeName,
                process: process,
                isNewClass: isNewClass,
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFF9F6F0);
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    final state = ref.watch(annotationStudioProvider);
    final notifier = ref.read(annotationStudioProvider.notifier);
    final currentItem = state.activeItem ?? widget.imageItem;
    final file = File(currentItem.filePath);

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentItem.classSlug ?? 'Anotasi Kemasan Kopi',
              style: const TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${state.activePolygon.length} Titik Sudut Poligon RDP • Sentuh & Geser',
              style: const TextStyle(color: textMuted, fontSize: 10.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // Auto-Label + OCR Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.auto_fix_high, size: 14),
              label: const Text('Auto-Label + OCR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: _triggerAutoLabel,
            ),
          ),
          const SizedBox(width: 4),

          // Save / Done Button
          IconButton(
            tooltip: 'Simpan Anotasi',
            icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 24),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Touch Canvas
          Positioned.fill(
            child: StudioInteractiveCanvas(
              imageFile: file,
              polygon: state.activePolygon,
              bbox: state.activeBbox,
              classLabel: currentItem.classSlug,
              classColor: const Color(0xFF7C3AED),
              isSmartTapMode: _isSmartTapMode,
              selectedVertexIndex: state.selectedVertexIndex,
              onSmartTap: (normPoint) {
                notifier.smartPointSelect(normPoint);
                setState(() => _isSmartTapMode = false);
              },
              onVertexSelected: (idx) {
                notifier.selectVertex(idx);
              },
              onVertexMoved: (idx, newPos) {
                notifier.moveVertex(idx, newPos);
              },
            ),
          ),

          // Top Floating Tool Pill
          Positioned(
            top: 14,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEFE8DE), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5C3A21).withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isSmartTapMode ? Icons.touch_app_rounded : Icons.pan_tool_alt_rounded,
                      size: 15,
                      color: _isSmartTapMode ? const Color(0xFF7C3AED) : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _isSmartTapMode
                            ? 'Ketuk kemasan untuk snap poligon otomatis'
                            : 'Geser titik sudut untuk menyesuaikan bentuk kemasan',
                        style: const TextStyle(color: textDark, fontSize: 11, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Toolbar (Bottom Center)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFEFE8DE), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5C3A21).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Smart Tap Mode Toggle
                    IconButton(
                      tooltip: '1-Tap Smart Point',
                      icon: Icon(
                        Icons.touch_app_rounded,
                        color: _isSmartTapMode ? const Color(0xFF7C3AED) : const Color(0xFF6B4423),
                      ),
                      onPressed: () {
                        setState(() => _isSmartTapMode = !_isSmartTapMode);
                      },
                    ),

                    // Reset Polygon
                    IconButton(
                      tooltip: 'Reset Poligon ke Standar Pouch',
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF8F857D)),
                      onPressed: () {
                        notifier.smartPointSelect(const Offset(0.5, 0.5));
                      },
                    ),

                    const SizedBox(
                      height: 22,
                      child: VerticalDivider(color: Color(0xFFEFE8DE), width: 14),
                    ),

                    // Class Editor Button
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFB45309),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      icon: const Icon(Icons.edit_note_rounded, size: 19),
                      label: Text(
                        currentItem.classSlug ?? 'Pilih Class',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () {
                        final ocr = CoffeeOcrResult(
                          rawLines: currentItem.ocrLines,
                          brand: currentItem.brand ?? '',
                          coffeeName: currentItem.coffeeName ?? '',
                          process: currentItem.process ?? '',
                          generatedSlug: currentItem.classSlug ?? 'fugol_halubanana_wine',
                          confidence: currentItem.confidence,
                        );

                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => SmartOcrClassBottomSheet(
                            ocrResult: ocr,
                            existingClasses: state.classes,
                            onConfirm: ({
                              required String classSlug,
                              required String brand,
                              required String coffeeName,
                              required String process,
                              required bool isNewClass,
                            }) {
                              notifier.saveActiveItem(
                                classSlug: classSlug,
                                brand: brand,
                                coffeeName: coffeeName,
                                process: process,
                                isNewClass: isNewClass,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
