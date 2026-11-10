import 'dart:io';
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
        backgroundColor: Color(0xFF6D28D9),
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
    final state = ref.watch(annotationStudioProvider);
    final notifier = ref.read(annotationStudioProvider.notifier);
    final currentItem = state.activeItem ?? widget.imageItem;
    final file = File(currentItem.filePath);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Deep Espresso Obsidian
      appBar: AppBar(
        backgroundColor: const Color(0xFF12100E),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentItem.classSlug ?? 'Anotasi Kemasan Kopi',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              '${state.activePolygon.length} Titik Sudut Poligon RDP',
              style: const TextStyle(color: Color(0xFFD4A373), fontSize: 11),
            ),
          ],
        ),
        actions: [
          // Auto-Label + OCR Button
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF6D28D9),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.auto_fix_high, size: 14),
            label: const Text('Auto-Label + OCR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: _triggerAutoLabel,
          ),
          const SizedBox(width: 8),

          // Save / Done Button
          IconButton(
            tooltip: 'Simpan Anotasi',
            icon: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
              classColor: const Color(0xFF8B5CF6),
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
            top: 16,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B26).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  _isSmartTapMode
                      ? '🎯 Ketuk di tengah kemasan untuk snap poligon otomatis'
                      : '👆 Geser titik sudut untuk menyesuaikan kontur kemasan',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ),

          // Floating Action Toolbar (Bottom Center)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B26),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF6D28D9).withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
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
                        Icons.touch_app,
                        color: _isSmartTapMode ? const Color(0xFFD4A373) : Colors.white70,
                      ),
                      onPressed: () {
                        setState(() => _isSmartTapMode = !_isSmartTapMode);
                      },
                    ),

                    // Reset Polygon
                    IconButton(
                      tooltip: 'Reset Poligon ke Standar Pouch',
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      onPressed: () {
                        notifier.smartPointSelect(const Offset(0.5, 0.5));
                      },
                    ),

                    const SizedBox(
                      height: 24,
                      child: VerticalDivider(color: Colors.white24, width: 16),
                    ),

                    // Class Editor Button
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFD4A373),
                      ),
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: Text(
                        currentItem.classSlug ?? 'Pilih Class',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
