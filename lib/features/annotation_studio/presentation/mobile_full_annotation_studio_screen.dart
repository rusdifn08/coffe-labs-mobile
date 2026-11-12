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
          initialChildSize: 0.60,
          minChildSize: 0.40,
          maxChildSize: 0.90,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.label_rounded, color: Color(0xFF7C3AED), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Semua Class Kemasan Kopi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D1F17),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF7C3AED),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _showAddNewClassSheet(context, notifier);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
                      final Color tagColor = cls.color;

                      return InkWell(
                        onTap: () {
                          notifier.selectClass(cls.classSlug);
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

  void _showAddNewClassSheet(BuildContext context, AnnotationStudioController notifier) {
    final brandController = TextEditingController();
    final nameController = TextEditingController();
    String selectedProcess = 'natural';
    String selectedColor = '#7C3AED';

    const roasterySuggestions = [
      'Tiga Ikat',
      'Fugol',
      'Makmur Jaya',
      'Anomali',
      'Space Roastery',
      'Otten Coffee',
    ];

    const processOptions = [
      'natural',
      'wine',
      'washed',
      'honey',
      'anaerobic',
      'experimental',
      'wet hulled',
    ];

    const colorPalette = [
      '#7C3AED', // Purple
      '#059669', // Emerald
      '#D97706', // Amber
      '#2563EB', // Blue
      '#E11D48', // Rose
      '#0D9488', // Teal
      '#D4AF37', // Gold
      '#6366F1', // Indigo
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final String brandText = brandController.text.trim();
            final String nameText = nameController.text.trim();
            final String cleanB = brandText.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
            final String cleanN = nameText.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
            final String previewSlug = cleanB.isNotEmpty && cleanN.isNotEmpty
                ? '${cleanB}_${cleanN}_$selectedProcess'
                : 'roastery_namakopi_$selectedProcess';

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Icon(Icons.add_box_rounded, color: Color(0xFF7C3AED), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Tambah Class Kemasan Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1F17),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Brand / Roastery Input
                    const Text(
                      'Brand / Roastery',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2D1F17)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: brandController,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Tiga Ikat Coffee',
                        hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        filled: true,
                        fillColor: const Color(0xFFF9F6F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Roastery Quick Suggestions
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: roasterySuggestions.map((sug) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () {
                                brandController.text = sug;
                                setSheetState(() {});
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0EBE1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  sug,
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B4423), fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Nama Kopi / Varietas
                    const Text(
                      'Nama Kopi / Biji',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2D1F17)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Halu Banana Natural',
                        hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        filled: true,
                        fillColor: const Color(0xFFF9F6F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Process Selection
                    const Text(
                      'Metode Pasca-Panen (Proses)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2D1F17)),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: processOptions.map((proc) {
                          final isSelected = proc == selectedProcess;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(proc.toUpperCase()),
                              selected: isSelected,
                              selectedColor: const Color(0xFF7C3AED).withValues(alpha: 0.16),
                              checkmarkColor: const Color(0xFF7C3AED),
                              labelStyle: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF6B4423),
                              ),
                              onSelected: (_) {
                                setSheetState(() => selectedProcess = proc);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Color Palette Selector
                    const Text(
                      'Warna Tag Class',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2D1F17)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: colorPalette.map((hex) {
                        final color = _parseColor(hex);
                        final isSelected = selectedColor == hex;
                        return InkWell(
                          onTap: () => setSheetState(() => selectedColor = hex),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2D1F17) : Colors.white,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Live Slug Preview Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EBE1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFB45309)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Slug AI: $previewSlug',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D1F17),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Simpan & Terapkan Class', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          if (brandController.text.trim().isEmpty || nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Brand dan Nama Kopi wajib diisi.'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          await notifier.createAndAssignClass(
                            brand: brandController.text.trim(),
                            coffeeName: nameController.text.trim(),
                            process: selectedProcess,
                            colorHex: selectedColor,
                          );

                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Class "$previewSlug" berhasil dibuat dan diterapkan!'),
                                backgroundColor: const Color(0xFF059669),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
        activeClassColor = matched.first.color;
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Studio Anotasi AI',
              style: TextStyle(
                color: textDark,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Roboflow Engine • On-Device Segmenter',
              style: TextStyle(color: textMuted, fontSize: 9.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // Undo Button
          IconButton(
            tooltip: 'Undo (Urungkan)',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.undo_rounded,
              size: 19,
              color: state.canUndo ? textDark : textMuted.withValues(alpha: 0.35),
            ),
            onPressed: state.canUndo ? () => notifier.undo() : null,
          ),

          // Redo Button
          IconButton(
            tooltip: 'Redo (Ulangi)',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.redo_rounded,
              size: 19,
              color: state.canRedo ? textDark : textMuted.withValues(alpha: 0.35),
            ),
            onPressed: state.canRedo ? () => notifier.redo() : null,
          ),

          // Auto-Label + OCR Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 22),
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
                isLayerVisible: state.isLayerVisible,
                layerOpacity: state.layerOpacity,
                isLayerLocked: state.isLayerLocked,
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

          // Top Group: Instruction Pill + Top Class & Layer Ribbon
          Positioned(
            top: 10,
            left: 14,
            right: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Instruction Notice Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEFE8DE), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5C3A21).withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _toolIcon(state.activeTool),
                        size: 14,
                        color: const Color(0xFF7C3AED),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          _getInstructionText(state),
                          style: const TextStyle(color: textDark, fontSize: 10.5, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Class & Layer Control Hub (Right Above Image Canvas)
                _buildClassAndLayerHeaderRibbon(
                  context: context,
                  state: state,
                  notifier: notifier,
                  currentItem: currentItem,
                  activeClassColor: activeClassColor,
                ),
              ],
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

  /// Top Class & Layer Control Ribbon positioned right below instruction pill and above image
  Widget _buildClassAndLayerHeaderRibbon({
    required BuildContext context,
    required AnnotationStudioState state,
    required AnnotationStudioController notifier,
    required StudioImageItem currentItem,
    required Color activeClassColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFE8DE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C3A21).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ROW 1: Class Selector & Creator Strip
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 5),
            child: Row(
              children: [
                // + Tambah Class Button
                InkWell(
                  onTap: () => _showAddNewClassSheet(context, notifier),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF7C3AED), width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: Color(0xFF7C3AED)),
                        SizedBox(width: 3),
                        Text(
                          'Class',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(width: 1, height: 18, color: Colors.black12),
                const SizedBox(width: 6),

                // Horizontal Scrollable Class Pills
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: state.classes.map((cls) {
                        final bool isSelected = cls.classSlug == currentItem.classSlug;
                        final Color tagColor = cls.color;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => notifier.selectClass(cls.classSlug),
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? tagColor.withValues(alpha: 0.14)
                                    : const Color(0xFFF9F6F0),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? tagColor : Colors.black.withValues(alpha: 0.08),
                                  width: isSelected ? 1.6 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: tagColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    cls.displayName,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? const Color(0xFF2D1F17) : const Color(0xFF6B4423),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.check_rounded, size: 12, color: tagColor),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // More classes icon button (opens full list sheet)
                InkWell(
                  onTap: _showClassSelectorDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.tune_rounded, size: 16, color: Color(0xFF8F857D)),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.8, color: Color(0xFFF0EAE2)),

          // ROW 2: Layer Management Strip (Visibility, Opacity, Lock, Layer Info)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 5),
            child: Row(
              children: [
                // Visibility Toggle (Eye)
                InkWell(
                  onTap: () => notifier.toggleLayerVisibility(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: state.isLayerVisible
                          ? const Color(0xFF059669).withValues(alpha: 0.10)
                          : const Color(0xFFEF4444).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.isLayerVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          size: 13,
                          color: state.isLayerVisible ? const Color(0xFF059669) : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.isLayerVisible ? 'Layer Aktif' : 'Tersembunyi',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: state.isLayerVisible ? const Color(0xFF059669) : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Opacity Stepper
                InkWell(
                  onTap: () => notifier.cycleLayerOpacity(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F6F0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.opacity_rounded, size: 13, color: Color(0xFF7C3AED)),
                        const SizedBox(width: 3),
                        Text(
                          '${(state.layerOpacity * 100).round()}% Opacity',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D1F17),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Lock Toggle
                InkWell(
                  onTap: () => notifier.toggleLayerLock(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: state.isLayerLocked
                          ? const Color(0xFFD4AF37).withValues(alpha: 0.15)
                          : const Color(0xFFF9F6F0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: state.isLayerLocked ? const Color(0xFFD4AF37) : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.isLayerLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                          size: 13,
                          color: state.isLayerLocked ? const Color(0xFFB45309) : const Color(0xFF8F857D),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          state.isLayerLocked ? 'Terkunci' : 'Buka Kunci',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: state.isLayerLocked ? const Color(0xFFB45309) : const Color(0xFF2D1F17),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Layer Info Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: activeClassColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.activePolygon.length >= 3
                        ? '${state.activePolygon.length} Titik'
                        : (state.activeBbox != null ? 'BBox' : '0 Layer'),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: activeClassColor,
                    ),
                  ),
                ),
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
            // Class Manager Button
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
