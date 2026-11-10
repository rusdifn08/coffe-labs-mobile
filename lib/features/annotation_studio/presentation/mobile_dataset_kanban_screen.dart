import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/models/studio_image_item.dart';
import 'controllers/annotation_studio_controller.dart';
import 'mobile_full_annotation_studio_screen.dart';
import 'mobile_versions_and_train_stepper_screen.dart';
import 'widgets/batch_auto_label_config_sheet.dart';

class MobileDatasetKanbanScreen extends ConsumerStatefulWidget {
  const MobileDatasetKanbanScreen({super.key});

  @override
  ConsumerState<MobileDatasetKanbanScreen> createState() => _MobileDatasetKanbanScreenState();
}

class _MobileDatasetKanbanScreenState extends ConsumerState<MobileDatasetKanbanScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage();
      if (picked.isNotEmpty) {
        final files = picked.map((x) => File(x.path)).toList();
        await ref.read(annotationStudioProvider.notifier).addImages(files);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${files.length} foto berhasil ditambahkan ke antrean.'),
              backgroundColor: const Color(0xFF6D28D9),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        await ref.read(annotationStudioProvider.notifier).addImages([File(photo.path)]);
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color(0xFF0B0F19), // Deep Espresso Obsidian
      appBar: AppBar(
        backgroundColor: const Color(0xFF12100E),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6D28D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dataset_outlined, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roboflow Studio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'On-Device Auto-Labeler & NCM Trainer',
                  style: TextStyle(color: Color(0xFFD4A373), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Import coffee.json Button
          IconButton(
            tooltip: 'Import coffee.json',
            icon: const Icon(Icons.file_download_outlined, color: Color(0xFFD4A373)),
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
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF6D28D9),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.smart_toy_outlined, size: 14),
            label: const Text('Auto-Label', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const BatchAutoLabelConfigSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Horizontal Scroll)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: const Color(0xFF12100E),
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
                    isActive: state.selectedTab == 'unassigned',
                    onTap: () => notifier.setSelectedTab('unassigned'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    title: 'Kemasan Kopi (Ready)',
                    count: state.annotatedCount,
                    badgeColor: const Color(0xFF10B981),
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
              color: const Color(0xFF1F1518),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Foto non-kopi otomatis dikecualikan dari training',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
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
                    child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  )
                : filteredList.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.76,
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
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFF12100E),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            // Add Photo Options
            IconButton(
              tooltip: 'Ambil Foto Kemasan',
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              onPressed: _pickFromCamera,
            ),
            IconButton(
              tooltip: 'Pilih Banyak Foto dari Galeri',
              icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
              onPressed: _pickFromGallery,
            ),
            const SizedBox(width: 8),

            // Stepper Training Launch Button
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A373),
                  foregroundColor: const Color(0xFF12100E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.model_training, size: 18),
                label: Text(
                  'Latih Versi NCM (${state.annotatedCount} Kemasan)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
    Color badgeColor = const Color(0xFF6D28D9),
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? badgeColor.withValues(alpha: 0.25) : const Color(0xFF1F2937),
          border: Border.all(
            color: isActive ? badgeColor : Colors.white12,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? badgeColor : Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
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

    return InkWell(
      onTap: () {
        ref.read(annotationStudioProvider.notifier).setActiveItem(item);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MobileFullAnnotationStudioScreen(imageItem: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isRejected
                ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                : item.isAnnotated
                    ? const Color(0xFF10B981).withValues(alpha: 0.5)
                    : Colors.white12,
          ),
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
                          color: Colors.white10,
                          child: const Icon(Icons.broken_image, color: Colors.white38),
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
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              border: Border.all(color: const Color(0xFFEF4444)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '🚫 NON-COFFEE',
                              style: TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (item.isAnnotated)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: item.isNewClass
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFEFF6FF),
                              border: Border.all(
                                color: item.isNewClass
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF3B82F6),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.isNewClass ? '✨ NEW OCR' : '✓ MATCHED',
                              style: TextStyle(
                                color: item.isNewClass
                                    ? const Color(0xFF047857)
                                    : const Color(0xFF1D4ED8),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '⏳ Belum Dianotasi',
                              style: TextStyle(color: Colors.white70, fontSize: 9),
                            ),
                          ),

                        // Polygon indicator icon
                        if (item.polygon.length >= 3)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6D28D9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.polyline, size: 10, color: Colors.white),
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
                      color: item.isRejected ? const Color(0xFFEF4444) : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.isRejected
                        ? (item.rejectionReason ?? 'Bukan kemasan kopi valid')
                        : '${item.brand ?? "brand"} • ${item.process ?? "proses"}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.photo_library_outlined, size: 48, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Foto Kemasan Kopi',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ambil foto kemasan atau pilih dari galeri untuk mulai anotasi.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D28D9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_photo_alternate, size: 18),
            label: const Text('Pilih dari Galeri'),
            onPressed: _pickFromGallery,
          ),
        ],
      ),
    );
  }
}
