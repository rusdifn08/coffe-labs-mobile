import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/studio_image_item.dart';
import 'controllers/annotation_studio_controller.dart';
import 'controllers/annotation_studio_state.dart';
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

  void _showClassSelectorDialog() {
    final state = ref.read(annotationStudioProvider);
    final notifier = ref.read(annotationStudioProvider.notifier);
    final currentItem = state.activeItem ?? widget.imageItem;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.label_rounded, color: Color(0xFF7C3AED), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Pilih Class Kemasan Kopi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D1F17),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: state.classes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final cls = state.classes[idx];
                      final bool isSelected = cls.classSlug == currentItem.classSlug;
                      final Color tagColor = _parseColor(cls.colorHex);

                      return InkWell(
                        onTap: () {
                          notifier.saveActiveItem(
                            classSlug: cls.classSlug,
                            brand: cls.brand,
                            coffeeName: cls.coffeeName,
                            process: cls.process,
                            isNewClass: false,
                          );
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? tagColor.withValues(alpha: 0.12) : const Color(0xFFF9F6F0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? tagColor : Colors.black.withValues(alpha: 0.06),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: tagColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cls.displayName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: const Color(0xFF2D1F17),
                                      ),
                                    ),
                                    Text(
                                      '${cls.brand.toUpperCase()} • ${cls.process.toUpperCase()}',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFF8F857D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF7C3AED);
    }
  }

  String _getInstructionText(AnnotationStudioState state) {
    switch (state.activeTool) {
      case StudioTool.samPoints:
        return state.samPromptMode == SamPromptMode.positive
            ? 'Ketuk kemasan untuk tanda (+ Inklusi)'
            : 'Ketuk area luar untuk tanda (- Eksklusi Background)';
      case StudioTool.smartBox:
        return 'Tarik kotak di sekitar kemasan untuk SAM Auto-Contour';
      case StudioTool.boundingBox:
        return 'Tarik kotak untuk membuat bounding box kemasan';
      case StudioTool.polygon:
        return 'Ketuk untuk menambah titik sudut (${state.activePolygon.length} titik) • Dobel tap untuk tutup';
      case StudioTool.vertexEdit:
        return 'Geser titik sudut • Dobel tap hapus • Ketuk garis untuk tambah titik';
      case StudioTool.panZoom:
        return 'Cubit layar untuk zoom (hingga 5x) dan geser tampilan';
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
    final bool fileExists = file.existsSync();

    // Determine class display color
    Color activeClassColor = const Color(0xFF7C3AED);
    if (currentItem.classSlug != null) {
      final matched = state.classes.where((c) => c.classSlug == currentItem.classSlug);
      if (matched.isNotEmpty) {
        activeClassColor = _parseColor(matched.first.colorHex);
      }
    }

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: InkWell(
          onTap: _showClassSelectorDialog,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: activeClassColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              currentItem.classSlug?.replaceAll('_', ' ').toUpperCase() ?? 'COFFEE BAG',
                              style: const TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: textMuted, size: 18),
                        ],
                      ),
                      Text(
                        '${state.activePolygon.length} Titik Sudut Poligon • ${_toolDisplayName(state.activeTool)}',
                        style: const TextStyle(color: textMuted, fontSize: 10.0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          // Undo Button
          IconButton(
            tooltip: 'Undo (Urungkan)',
            icon: Icon(
              Icons.undo_rounded,
              size: 20,
              color: state.canUndo ? textDark : textMuted.withValues(alpha: 0.35),
            ),
            onPressed: state.canUndo ? () => notifier.undo() : null,
          ),

          // Redo Button
          IconButton(
            tooltip: 'Redo (Ulangi)',
            icon: Icon(
              Icons.redo_rounded,
              size: 20,
              color: state.canRedo ? textDark : textMuted.withValues(alpha: 0.35),
            ),
            onPressed: state.canRedo ? () => notifier.redo() : null,
          ),

          // Auto-Label + OCR Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.auto_fix_high, size: 13),
              label: const Text('Auto-Label', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
              onPressed: _triggerAutoLabel,
            ),
          ),

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
          if (fileExists)
            Positioned.fill(
              child: StudioInteractiveCanvas(
                imageFile: file,
                polygon: state.activePolygon,
                bbox: state.activeBbox,
                classLabel: currentItem.classSlug,
                classColor: activeClassColor,
                activeTool: state.activeTool,
                samPromptMode: state.samPromptMode,
                samPromptPoints: state.samPromptPoints,
                selectedVertexIndex: state.selectedVertexIndex,
                onSamPointTapped: (normPoint) {
                  notifier.addSamPoint(normPoint);
                },
                onSmartBoxDrawn: (normBox) {
                  notifier.applySmartBox(normBox);
                },
                onBoundingBoxDrawn: (normBox) {
                  notifier.applyBoundingBox(normBox);
                },
                onPolygonVertexAdded: (normPoint) {
                  notifier.addPolygonVertex(normPoint);
                },
                onPolygonClosed: () {
                  notifier.closeManualPolygon();
                },
                onVertexMoved: (idx, newPos) {
                  notifier.moveVertex(idx, newPos);
                },
                onVertexInserted: (idx, newPos) {
                  notifier.insertPolygonVertex(idx, newPos);
                },
                onVertexDeleted: (idx) {
                  notifier.deletePolygonVertex(idx);
                },
                onVertexSelected: (idx) {
                  notifier.selectVertex(idx);
                },
              ),
            )
          else
            // Safe File Missing Placeholder
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image_rounded, size: 48, color: Color(0xFFEF4444)),
                    const SizedBox(height: 12),
                    const Text(
                      'Foto Tidak Ditemukan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'File di jalur:\n${currentItem.filePath}\ntelah dipindahkan atau dihapus dari penyimpanan.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: textMuted),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kembali ke Kanban'),
                    ),
                  ],
                ),
              ),
            ),

          // Top Notice Instruction Pill
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
                      _toolIcon(state.activeTool),
                      size: 15,
                      color: const Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _getInstructionText(state),
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

          // Bottom Control Stack
          Positioned(
            bottom: 20,
            left: 14,
            right: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Contextual Tool Sub-Actions Pill
                _buildToolSubActions(context, state, notifier),
                const SizedBox(height: 8),

                // Main Bottom Floating Tool Selector Pill
                _buildMainToolBar(context, state, notifier, activeClassColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolSubActions(
    BuildContext context,
    AnnotationStudioState state,
    AnnotationStudioController notifier,
  ) {
    if (state.activeTool == StudioTool.samPoints) {
      final isPos = state.samPromptMode == SamPromptMode.positive;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFE8DE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode Toggle: + Include vs - Exclude
            InkWell(
              onTap: () => notifier.setSamPromptMode(SamPromptMode.positive),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isPos ? const Color(0xFF10B981) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle, size: 14, color: isPos ? Colors.white : const Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(
                      '+ Inklusi',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isPos ? Colors.white : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => notifier.setSamPromptMode(SamPromptMode.negative),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: !isPos ? const Color(0xFFEF4444) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.remove_circle, size: 14, color: !isPos ? Colors.white : const Color(0xFFEF4444)),
                    const SizedBox(width: 4),
                    Text(
                      '− Eksklusi',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: !isPos ? Colors.white : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.samPromptPoints.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(width: 1, height: 16, color: Colors.black12),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                tooltip: 'Reset Titik SAM',
                icon: const Icon(Icons.clear_all_rounded, color: Color(0xFFEF4444)),
                onPressed: () => notifier.clearSamPoints(),
              ),
            ],
          ],
        ),
      );
    }

    if (state.activeTool == StudioTool.polygon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFE8DE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.activePolygon.length >= 3)
              TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 14),
                label: const Text('Tutup Poligon', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                onPressed: () => notifier.closeManualPolygon(),
              ),
            if (state.activePolygon.isNotEmpty)
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                tooltip: 'Hapus Titik Terakhir',
                icon: const Icon(Icons.backspace_outlined, color: Color(0xFFD97706)),
                onPressed: () => notifier.removeLastPolygonVertex(),
              ),
            IconButton(
              visualDensity: VisualDensity.compact,
              iconSize: 16,
              tooltip: 'Reset Poligon',
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              onPressed: () => notifier.resetPolygon(),
            ),
          ],
        ),
      );
    }

    if (state.activeTool == StudioTool.vertexEdit) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFE8DE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: const Color(0xFF6B4423),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 14),
              label: const Text('Reset Pouch Shape', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
              onPressed: () => notifier.resetToPouchTemplate(),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              iconSize: 16,
              tooltip: 'Hapus Poligon',
              icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444)),
              onPressed: () => notifier.resetPolygon(),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMainToolBar(
    BuildContext context,
    AnnotationStudioState state,
    AnnotationStudioController notifier,
    Color activeClassColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEFE8DE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C3A21).withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToolIconBtn(
              tool: StudioTool.samPoints,
              icon: Icons.auto_fix_high_rounded,
              label: 'SAM 3',
              activeTool: state.activeTool,
              onTap: () => notifier.setTool(StudioTool.samPoints),
            ),
            _buildToolIconBtn(
              tool: StudioTool.smartBox,
              icon: Icons.flash_on_rounded,
              label: 'Box SAM',
              activeTool: state.activeTool,
              onTap: () => notifier.setTool(StudioTool.smartBox),
            ),
            _buildToolIconBtn(
              tool: StudioTool.boundingBox,
              icon: Icons.crop_square_rounded,
              label: 'BBox',
              activeTool: state.activeTool,
              onTap: () => notifier.setTool(StudioTool.boundingBox),
            ),
            _buildToolIconBtn(
              tool: StudioTool.polygon,
              icon: Icons.polyline_rounded,
              label: 'Poligon',
              activeTool: state.activeTool,
              onTap: () => notifier.setTool(StudioTool.polygon),
            ),
            _buildToolIconBtn(
              tool: StudioTool.vertexEdit,
              icon: Icons.edit_location_alt_rounded,
              label: 'Edit',
              activeTool: state.activeTool,
              onTap: () => notifier.setTool(StudioTool.vertexEdit),
            ),
            _buildToolIconBtn(
              tool: StudioTool.panZoom,
              icon: Icons.pan_tool_rounded,
              label: 'Pan',
              activeTool: state.activeTool,
              onTap: () => notifier.setTool(StudioTool.panZoom),
            ),
            Container(width: 1, height: 22, color: Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 4)),
            // Class Picker Button
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2D1F17),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                visualDensity: VisualDensity.compact,
              ),
              icon: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: activeClassColor, shape: BoxShape.circle),
              ),
              label: const Text('Class', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: _showClassSelectorDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolIconBtn({
    required StudioTool tool,
    required IconData icon,
    required String label,
    required StudioTool activeTool,
    required VoidCallback onTap,
  }) {
    final bool isActive = tool == activeTool;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF7C3AED).withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF6B4423),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.0,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF7C3AED) : const Color(0xFF6B4423),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toolDisplayName(StudioTool tool) {
    switch (tool) {
      case StudioTool.samPoints:
        return 'SAM 3 Interactive';
      case StudioTool.smartBox:
        return 'Box SAM Prompt';
      case StudioTool.boundingBox:
        return 'Bounding Box';
      case StudioTool.polygon:
        return 'Manual Poligon';
      case StudioTool.vertexEdit:
        return 'Edit Sudut';
      case StudioTool.panZoom:
        return 'Pan & Zoom';
    }
  }

  IconData _toolIcon(StudioTool tool) {
    switch (tool) {
      case StudioTool.samPoints:
        return Icons.auto_fix_high_rounded;
      case StudioTool.smartBox:
        return Icons.flash_on_rounded;
      case StudioTool.boundingBox:
        return Icons.crop_square_rounded;
      case StudioTool.polygon:
        return Icons.polyline_rounded;
      case StudioTool.vertexEdit:
        return Icons.edit_location_alt_rounded;
      case StudioTool.panZoom:
        return Icons.pan_tool_rounded;
    }
  }
}
