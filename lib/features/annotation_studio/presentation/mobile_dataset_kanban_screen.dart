import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/models/studio_image_item.dart';
import 'controllers/annotation_studio_controller.dart';
import 'mobile_full_annotation_studio_screen.dart';
import 'mobile_versions_and_train_stepper_screen.dart';
import 'widgets/batch_auto_label_config_sheet.dart';

/// Roboflow Studio Kanban & Dataset Management Screen
/// Didesain dengan palet warna cerah resmi Coffee Labs (Warm Cream, White, Espresso & Gold),
/// mendukung multi/single gallery picker yang andal di Windows & Mobile,
/// serta tombol 1-tap muat contoh dataset demo kemasan kopi.
class MobileDatasetKanbanScreen extends ConsumerStatefulWidget {
  const MobileDatasetKanbanScreen({super.key});

  @override
  ConsumerState<MobileDatasetKanbanScreen> createState() => _MobileDatasetKanbanScreenState();
}

class _MobileDatasetKanbanScreenState extends ConsumerState<MobileDatasetKanbanScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingSamples = false;

  Future<File> _persistImageFile(String originalPath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final datasetDir = Directory(p.join(docsDir.path, 'annotation_dataset'));
    if (!await datasetDir.exists()) {
      await datasetDir.create(recursive: true);
    }
    final ext = p.extension(originalPath).isNotEmpty ? p.extension(originalPath) : '.jpg';
    final targetPath = p.join(datasetDir.path, 'img_${DateTime.now().microsecondsSinceEpoch}$ext');
    final copied = await File(originalPath).copy(targetPath);
    return copied;
  }

  Future<void> _pickFromGallery() async {
    try {
      List<XFile> picked = [];

      // 1. Coba pickMultipleMedia (bekerja mulus di Windows Desktop via file_selector dan di Mobile)
      try {
        picked = await _picker.pickMultipleMedia();
      } catch (e) {
        debugPrint('pickMultipleMedia notice ($e), trying pickMultiImage fallback');
      }

      // 2. Jika kosong atau tidak didukung, coba pickMultiImage
      if (picked.isEmpty) {
        try {
          picked = await _picker.pickMultiImage();
        } catch (e) {
          debugPrint('pickMultiImage notice ($e), trying single pickImage');
        }
      }

      // 3. Fallback utama: single pickImage dari galeri/folder
      if (picked.isEmpty) {
        try {
          final single = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 95);
          if (single != null) {
            picked = [single];
          }
        } catch (e) {
          debugPrint('pickImage single notice ($e)');
        }
      }

      if (picked.isNotEmpty) {
        final List<File> persistedFiles = [];
        for (final xf in picked) {
          try {
            final persisted = await _persistImageFile(xf.path);
            persistedFiles.add(persisted);
          } catch (_) {
            persistedFiles.add(File(xf.path));
          }
        }

        await ref.read(annotationStudioProvider.notifier).addImages(persistedFiles);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${persistedFiles.length} foto kemasan berhasil ditambahkan ke antrean.'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto dari galeri: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 95);
      if (photo != null) {
        final persisted = await _persistImageFile(photo.path);
        await ref.read(annotationStudioProvider.notifier).addImages([persisted]);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto kamera berhasil ditambahkan ke antrean.'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto kamera: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _loadDemoDataset() async {
    if (_isLoadingSamples) return;
    setState(() => _isLoadingSamples = true);

    try {
      final sampleAssets = [
        'assets/images/beans/makmur_jaya_halu_banana_natural.jpg',
        'assets/images/beans/fugol_coffee_arabika_berry_smash.jpg',
        'assets/images/beans/anomali_coffee_bali_kintamani.jpg',
      ];

      final docsDir = await getApplicationDocumentsDirectory();
      final datasetDir = Directory(p.join(docsDir.path, 'annotation_dataset'));
      if (!await datasetDir.exists()) {
        await datasetDir.create(recursive: true);
      }

      final List<File> files = [];
      for (final assetPath in sampleAssets) {
        try {
          final byteData = await rootBundle.load(assetPath);
          final fileName = p.basename(assetPath);
          final targetFile = File(p.join(datasetDir.path, 'demo_${DateTime.now().millisecondsSinceEpoch}_$fileName'));
          await targetFile.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
          files.add(targetFile);
        } catch (e) {
          debugPrint('Error loading sample asset $assetPath: $e');
        }
      }

      if (files.isNotEmpty) {
        await ref.read(annotationStudioProvider.notifier).addImages(files);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${files.length} contoh kemasan kopi resmi berhasil dimuat ke Roboflow Studio!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading demo dataset: $e');
    } finally {
      if (mounted) setState(() => _isLoadingSamples = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFF9F6F0);
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    final state = ref.watch(annotationStudioProvider);
    final notifier = ref.read(annotationStudioProvider.notifier);

    // Filter images according to active tab
    List<StudioImageItem> filteredList = [];
    if (state.selectedTab == 'unassigned') {
      filteredList = state.images
          .where((i) => (i.status == 'unassigned' || i.status == 'annotating') && !i.isRejected)
          .toList();
    } else if (state.selectedTab == 'annotated') {
      filteredList = state.images.where((i) => i.status == 'annotated' && !i.isRejected).toList();
    } else if (state.selectedTab == 'rejected') {
      filteredList = state.images
          .where((i) => i.isRejected || i.status == 'rejected_non_coffee' || i.status == 'null_background')
          .toList();
    } else {
      filteredList = state.images;
    }

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: bgCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1),
              ),
              child: const Icon(Icons.dataset_outlined, size: 15, color: Color(0xFFB45309)),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Roboflow Studio',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Batch Auto-Labeler & NCM',
                    style: TextStyle(color: textMuted, fontSize: 9.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Demo Dataset Button
          IconButton(
            tooltip: 'Muat Contoh Kemasan Demo',
            padding: const EdgeInsets.all(7),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFD97706), size: 19),
            onPressed: _loadDemoDataset,
          ),
          // Import coffee.json Button
          IconButton(
            tooltip: 'Import coffee.json',
            padding: const EdgeInsets.all(7),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.file_download_outlined, color: Color(0xFF6B4423), size: 19),
            onPressed: () async {
              final count = await notifier.importCoffeeJson();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$count class katalog berhasil diimpor dari coffee.json.'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
          ),
          // Auto-Label Batch Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.smart_toy_outlined, size: 13),
              label: const Text('Auto-Label', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const BatchAutoLabelConfigSheet(),
                );
              },
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Horizontal Scroll)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEFE8DE))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill(
                    title: 'Semua',
                    count: state.totalImages,
                    isActive: state.selectedTab == 'all',
                    onTap: () => notifier.setSelectedTab('all'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    title: 'Belum Terlabel',
                    count: state.unassignedCount,
                    badgeColor: const Color(0xFFD97706),
                    isActive: state.selectedTab == 'unassigned',
                    onTap: () => notifier.setSelectedTab('unassigned'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    title: 'Kemasan Kopi (Ready)',
                    count: state.annotatedCount,
                    badgeColor: const Color(0xFF059669),
                    isActive: state.selectedTab == 'annotated',
                    onTap: () => notifier.setSelectedTab('annotated'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    title: '🚫 Non-Kopi / Ditolak',
                    count: state.rejectedCount,
                    badgeColor: const Color(0xFFEF4444),
                    isActive: state.selectedTab == 'rejected',
                    onTap: () => notifier.setSelectedTab('rejected'),
                  ),
                ],
              ),
            ),
          ),

          // Rejected Tab Quick Actions Bar
          if (state.selectedTab == 'rejected' && state.rejectedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFEF2F2),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Foto non-kopi otomatis dikecualikan dari proses training',
                      style: TextStyle(color: Color(0xFF991B1B), fontSize: 11),
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 14),
                    label: const Text('Hapus Semua', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      final del = await notifier.deleteAllRejected();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$del foto non-kopi berhasil dihapus.'),
                            backgroundColor: const Color(0xFFEF4444),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

          // Images Grid
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6B4423)),
                  )
                : filteredList.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.74,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return _buildImageCard(item);
                        },
                      ),
          ),
        ],
      ),

      // Bottom Navigation / Action Toolbar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEFE8DE))),
          boxShadow: [
            BoxShadow(
              color: Color(0x085C3A21),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Add Photo Options
            IconButton(
              tooltip: 'Ambil Foto Kemasan',
              icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF6B4423)),
              onPressed: _pickFromCamera,
            ),
            IconButton(
              tooltip: 'Pilih Foto dari Galeri',
              icon: const Icon(Icons.photo_library_outlined, color: Color(0xFFD97706)),
              onPressed: _pickFromGallery,
            ),
            const SizedBox(width: 8),

            // Stepper Training Launch Button
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4423),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.model_training, size: 17),
                label: Text(
                  'Latih Versi NCM (${state.annotatedCount} Kemasan)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: state.annotatedCount == 0
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MobileVersionsAndTrainStepperScreen(),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String title,
    required int count,
    Color badgeColor = const Color(0xFF6B4423),
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? badgeColor : const Color(0xFFF3EDE6),
          border: Border.all(
            color: isActive ? badgeColor : const Color(0xFFE5DDD3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF5C4E43),
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withValues(alpha: 0.25) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF2D1F17),
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(StudioImageItem item) {
    final file = File(item.filePath);
    final bool fileExists = file.existsSync();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(annotationStudioProvider.notifier).setActiveItem(item);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MobileFullAnnotationStudioScreen(imageItem: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.isRejected
                  ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                  : item.isAnnotated
                      ? const Color(0xFF059669).withValues(alpha: 0.5)
                      : const Color(0xFFEFE8DE),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5C3A21).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview with status overlay
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    fileExists
                        ? Image.file(file, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFFF3EDE6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image_rounded, color: Color(0xFFEF4444), size: 28),
                                const SizedBox(height: 4),
                                const Text(
                                  'File Hilang',
                                  style: TextStyle(color: Color(0xFFDC2626), fontSize: 9.5, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () {
                                    if (item.id != null) {
                                      ref.read(annotationStudioProvider.notifier).deleteImage(item.id!);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                    // Top Status Badge
                    Positioned(
                      top: 6,
                      left: 6,
                      right: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (item.isRejected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                border: Border.all(color: const Color(0xFFEF4444)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '🚫 NON-COFFEE',
                                style: TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (item.isAnnotated)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: item.isNewClass
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFEFF6FF),
                                border: Border.all(
                                  color: item.isNewClass
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF2563EB),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.isNewClass ? '✨ NEW OCR' : '✓ MATCHED',
                                style: TextStyle(
                                  color: item.isNewClass
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF2563EB),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                border: Border.all(color: const Color(0xFFF59E0B)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '⏳ Belum Dianotasi',
                                style: TextStyle(color: Color(0xFFB45309), fontSize: 8.5, fontWeight: FontWeight.bold),
                              ),
                            ),

                          // Polygon indicator icon
                          if (item.polygon.length >= 3)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF7C3AED),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.polyline, size: 9, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Card Bottom Details
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.classSlug ?? 'unassigned_bag',
                      style: TextStyle(
                        color: item.isRejected ? const Color(0xFFEF4444) : const Color(0xFF2D1F17),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.isRejected
                          ? (item.rejectionReason ?? 'Bukan kemasan kopi valid')
                          : '${item.brand ?? "brand"} • ${item.process ?? "proses"}',
                      style: const TextStyle(color: Color(0xFF8F857D), fontSize: 9.5),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD8A8), width: 1.5),
              ),
              child: const Icon(Icons.photo_library_outlined, size: 44, color: Color(0xFFD97706)),
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum Ada Foto Kemasan Kopi',
              style: TextStyle(color: Color(0xFF2D1F17), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih foto dari galeri komputer/HP atau gunakan contoh kemasan resmi untuk mulai.',
              style: TextStyle(color: Color(0xFF8F857D), fontSize: 11.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Tombol 1: Pilih dari Galeri
            SizedBox(
              width: 240,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4423),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 17),
                label: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                onPressed: _pickFromGallery,
              ),
            ),
            const SizedBox(height: 10),

            // Tombol 2: Muat Contoh Kemasan Demo
            SizedBox(
              width: 240,
              height: 40,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB45309),
                  backgroundColor: const Color(0xFFFFFBEB),
                  side: const BorderSide(color: Color(0xFFFDE68A)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isLoadingSamples
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB45309)),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('✨ Muat Contoh Kopi Demo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: _isLoadingSamples ? null : _loadDemoDataset,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
