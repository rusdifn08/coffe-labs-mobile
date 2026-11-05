import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/router/app_router.dart';
import '../controllers/bean_scanner_controller.dart';
import '../controllers/selected_brew_bean_controller.dart';
import '../models/bean_scan_state.dart';
import '../models/resolved_coffee_bean.dart';

class SmartBeanCameraPopupModal extends ConsumerStatefulWidget {
  const SmartBeanCameraPopupModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (ctx) => const SmartBeanCameraPopupModal(),
    );
  }

  @override
  ConsumerState<SmartBeanCameraPopupModal> createState() => _SmartBeanCameraPopupModalState();
}

class _SmartBeanCameraPopupModalState extends ConsumerState<SmartBeanCameraPopupModal> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final backCam = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
        _cameraController = CameraController(
          backCam,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() => _isCameraReady = true);
        }
      }
    } catch (e) {
      debugPrint('Camera init platform fallback: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final next = !_isFlashOn;
      await _cameraController!.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      setState(() => _isFlashOn = next);
    } catch (_) {}
  }

  Future<void> _takePhoto() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final xfile = await _cameraController!.takePicture();
        final file = File(xfile.path);
        ref.read(beanScannerControllerProvider.notifier).processImage(file);
        return;
      } catch (e) {
        debugPrint('Camera take picture error: $e');
      }
    }

    // Fallback: ImagePicker camera
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 92);
    if (picked != null) {
      ref.read(beanScannerControllerProvider.notifier).processImage(File(picked.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
    if (picked != null) {
      ref.read(beanScannerControllerProvider.notifier).processImage(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beanScannerControllerProvider);
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF141210), // Deep Espresso Dark Background
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF5C3A21), width: 1.5)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header Bar
          _buildHeaderBar(),

          // Body Switcher based on State
          Expanded(
            child: switch (state) {
              BeanScanStateIdle() => _buildViewfinderView(),
              BeanScanStateCapturing() => _buildScanningAnimationView(null),
              BeanScanStateAnalyzing(:final imageFile) => _buildScanningAnimationView(imageFile),
              BeanScanStateResolved(:final bean, :final imageFile) => _buildResultView(bean, imageFile),
              BeanScanStateError(:final message) => _buildErrorView(message),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF5C3A21).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.center_focus_strong_rounded, color: Color(0xFFD4AF37), size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Coffee Bag Scanner',
                  style: TextStyle(color: Color(0xFFF9F5EE), fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Deteksi kemasan, varietas, proses & resep V60',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white38),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinderView() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera preview or aesthetic placeholder
                  if (_isCameraReady && _cameraController != null)
                    CameraPreview(_cameraController!)
                  else
                    Container(
                      color: const Color(0xFF1E1A17),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 54, color: Colors.white.withValues(alpha: 0.2)),
                            const SizedBox(height: 12),
                            const Text(
                              'Arahkan kamera ke kemasan kopi',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Overlay Guideline Corners
                  _buildPackagingGuideOverlay(),
                ],
              ),
            ),
          ),
        ),

        // Controls bar (Flash, Shutter, Gallery)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: const BoxDecoration(
            color: Color(0xFF191613),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Flash Button
              IconButton(
                icon: Icon(
                  _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: _isFlashOn ? const Color(0xFFD4AF37) : Colors.white70,
                  size: 26,
                ),
                onPressed: _toggleFlash,
              ),

              // Tactile Shutter Button
              GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF5C3A21),
                    border: Border.all(color: const Color(0xFFF9F5EE), width: 3.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5C3A21).withValues(alpha: 0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD4AF37),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 28),
                    ),
                  ),
                ),
              ),

              // Gallery Button
              IconButton(
                icon: const Icon(Icons.photo_library_outlined, color: Colors.white70, size: 26),
                onPressed: _pickFromGallery,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackagingGuideOverlay() {
    return Stack(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4), width: 1.2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        // Corner Accent Bracket Animation
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: CustomPaint(
              painter: _CornerBracketPainter(color: const Color(0xFFD4AF37)),
              child: const SizedBox.expand(),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 1500.ms),
        Positioned(
          bottom: 44,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'Posisikan kemasan kopi di dalam bingkai',
                style: TextStyle(color: Color(0xFFF9F5EE), fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningAnimationView(File? imageFile) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageFile != null && imageFile.existsSync())
          Image.file(imageFile, fit: BoxFit.cover)
        else
          Container(color: const Color(0xFF1E1A17)),

        Container(color: Colors.black.withValues(alpha: 0.55)),

        // Laser scan sweep line
        Column(
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.8), blurRadius: 16, spreadRadius: 4),
                ],
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Color(0xFFD4AF37), Colors.transparent],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 40, end: 400, duration: 1400.ms, curve: Curves.easeInOut),
          ],
        ),

        // Floating recognition steps
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 36),
            decoration: BoxDecoration(
              color: const Color(0xFF141210).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF5C3A21), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(color: Color(0xFFD4AF37), radius: 14),
                const SizedBox(height: 16),
                const Text(
                  'Menganalisis Kemasan Kopi...',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. On-device Object Detection\n2. Spatial OCR & Text Hierarchy\n3. Trigram Fuzzy & Lexicon Matching',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11.5, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(ResolvedCoffeeBean bean, File imageFile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Summary Banner with Thumbnail & Verification Badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1916),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF5C3A21), width: 1.2),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageFile,
                    width: 72,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: bean.isCatalogVerified
                                  ? const Color(0xFF1B5E20).withValues(alpha: 0.35)
                                  : const Color(0xFFD4AF37).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: bean.isCatalogVerified ? Colors.greenAccent : const Color(0xFFD4AF37),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              bean.isCatalogVerified ? '✓ Katalog Terverifikasi' : '✨ AI Smart Extract',
                              style: TextStyle(
                                color: bean.isCatalogVerified ? Colors.greenAccent : const Color(0xFFD4AF37),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${bean.confidenceScore.toStringAsFixed(0)}% Match',
                            style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        bean.beanName,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        bean.roasteryName,
                        style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${bean.origin} • ${bean.altitudeMasl ?? "1500 MDPL"}',
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Varietas & Proses Badges
          Row(
            children: [
              Expanded(
                child: _buildParameterTile('Varietas', bean.variety, CupertinoIcons.leaf_arrow_circlepath),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildParameterTile('Proses Pascapanen', bean.process, CupertinoIcons.drop_fill),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tasting Notes Chips
          const Text(
            'Tasting Notes (Sentuh untuk menghapus/sesuaikan):',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bean.tastingNotes.map((note) {
              return Chip(
                backgroundColor: const Color(0xFF26211D),
                side: const BorderSide(color: Color(0xFF5C3A21)),
                label: Text(note, style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 11.5)),
                deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white38),
                onDeleted: () {
                  final updatedNotes = List<String>.from(bean.tastingNotes)..remove(note);
                  ref.read(beanScannerControllerProvider.notifier).updateResolvedBean(
                        bean.copyWith(tastingNotes: updatedNotes),
                      );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Recommended Recipe Highlight Card
          if (bean.recommendedRecipes.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF241D17),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.star_fill, color: Color(0xFFD4AF37), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rekomendasi Resep V60 Terbaik:',
                          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          bean.recommendedRecipes.first.name,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${bean.recommendedRecipes.first.targetNotes} (Suhu: ${bean.recommendedWaterTempC}°C)',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Action Buttons: Foto Ulang & Next
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => ref.read(beanScannerControllerProvider.notifier).reset(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Foto Ulang'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Simpan ke state global untuk seduh presisi
                    ref.read(selectedBrewBeanProvider.notifier).setBean(bean);
                    Navigator.pop(context);
                    // Arahkan langsung ke halaman pemilihan resep
                    context.push('${AppRoutes.recipes}?autoRecommend=true');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.coffee, size: 18),
                  label: const Text(
                    'Next: Pilih Resep Seduh →',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParameterTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A17),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.orangeAccent, size: 44),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.read(beanScannerControllerProvider.notifier).reset(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C3A21),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;

  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const arm = 26.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(arm, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, arm), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - arm, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, arm), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(arm, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - arm), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - arm, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - arm), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
