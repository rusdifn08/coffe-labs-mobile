import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/class_slug_generator.dart';
import 'controllers/in_app_bean_trainer_controller.dart';
import 'widgets/smart_annotation_canvas.dart';
import 'widgets/training_telemetry_modal.dart';

/// Studio Pelatihan AI On-Device (In-App Few-Shot Transfer Learning & Smart Annotation).
/// Memungkinkan barista memotret 3 sudut kemasan (Depan, Kiri, Kanan),
/// tap-to-snap bounding box, dan melatih model klasifikasi kopi langsung di HP (Offline).
class InAppBeanTrainerScreen extends ConsumerStatefulWidget {
  final String? initialRoastery;
  final String? initialBeanName;
  final String? initialProcess;
  final List<String>? initialNotes;

  const InAppBeanTrainerScreen({
    super.key,
    this.initialRoastery,
    this.initialBeanName,
    this.initialProcess,
    this.initialNotes,
  });

  @override
  ConsumerState<InAppBeanTrainerScreen> createState() => _InAppBeanTrainerScreenState();
}

class _InAppBeanTrainerScreenState extends ConsumerState<InAppBeanTrainerScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _brandCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _varietalCtrl = TextEditingController();
  final TextEditingController _altitudeCtrl = TextEditingController();
  final TextEditingController _newNoteCtrl = TextEditingController();

  int _altitudeMin = 1200;
  int _altitudeMax = 1600;

  static const List<String> _varietalPresets = [
    'Geisha / Gesha',
    'Bourbon',
    'Typica',
    'Ateng Super / TimTim',
    'Sigarar Utang',
    'Andungsari',
    'Kartika',
    'Caturra',
    'Catuai',
    'SL28',
    'SL34',
    'Pacamara',
    'Pink Bourbon',
    'Yellow Bourbon',
    'Heirloom / Landrace',
    'Mixed Varieties',
  ];

  static const List<String> _processOptions = [
    'Natural',
    'Washed',
    'Honey',
    'Anaerobic Natural',
    'Anaerobic Washed',
    'Wine Process',
    'Carbonic Maceration',
    'Thermal Shock',
    'Wet Hulled (Giling Basah)',
  ];

  static const List<String> _commonNotes = [
    'Jasmine',
    'Peach',
    'Blueberry',
    'Strawberry',
    'Citrus',
    'Bergamot',
    'Caramel',
    'Dark Chocolate',
    'Milk Chocolate',
    'Black Tea',
    'Crisp Green Apple',
    'Tropical Mango',
    'Orange Blossom',
    'Honey',
    'Lavender',
    'Plum',
    'Vanilla',
    'Floral',
  ];

  static const List<String> _roasteryPresets = [
    'Two Hands',
    'Space Roastery',
    'Fugol Coffee',
    'Common Grounds',
    'Tanamera',
    'Anomali',
    'Smoking Barrels',
  ];

  static const List<String> _originPresets = [
    'Kamojang',
    'Gayo Pantan Musara',
    'Kerinci Gunung Tujuh',
    'Ijen Sweet Java',
    'Toraja Sapan',
    'Bali Kintamani',
    'Flores Bajawa',
    'Ethiopia Yirgacheffe',
  ];

  static const List<String> _slotLabels = ['Depan', 'Kiri', 'Kanan'];

  @override
  void initState() {
    super.initState();
    final draft = ref.read(inAppTrainerControllerProvider).draft;
    _brandCtrl.text = widget.initialRoastery?.isNotEmpty == true
        ? widget.initialRoastery!
        : draft.roasteryBrand;
    _nameCtrl.text = widget.initialBeanName?.isNotEmpty == true
        ? widget.initialBeanName!
        : draft.beanName;
    _varietalCtrl.text = draft.varietal;

    _parseAltitude(draft.altitudeMasl);
    _altitudeCtrl.text = '$_altitudeMin - $_altitudeMax MDPL';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(inAppTrainerControllerProvider.notifier);
      if (widget.initialRoastery?.isNotEmpty == true) {
        notifier.updateMetadata(brand: widget.initialRoastery!);
      }
      if (widget.initialBeanName?.isNotEmpty == true) {
        notifier.updateMetadata(beanName: widget.initialBeanName!);
      }
      if (widget.initialProcess?.isNotEmpty == true) {
        notifier.updateMetadata(process: widget.initialProcess!);
      }
      if (widget.initialNotes != null && widget.initialNotes!.isNotEmpty) {
        notifier.updateMetadata(tastingNotes: widget.initialNotes!);
      }
      notifier.updateMetadata(
        altitude: '$_altitudeMin - $_altitudeMax MDPL',
      );
    });
  }

  void _parseAltitude(String raw) {
    final numbers = RegExp(r'\d+').allMatches(raw).map((m) => int.parse(m.group(0)!)).toList();
    if (numbers.length >= 2) {
      _altitudeMin = numbers[0];
      _altitudeMax = numbers[1];
    } else if (numbers.length == 1) {
      _altitudeMin = numbers[0];
      _altitudeMax = numbers[0] + 400;
    } else {
      _altitudeMin = 1200;
      _altitudeMax = 1600;
    }
  }

  void _updateAltitude({int? newMin, int? newMax}) {
    setState(() {
      if (newMin != null) _altitudeMin = newMin.clamp(500, 3000);
      if (newMax != null) _altitudeMax = newMax.clamp(500, 3000);
      if (_altitudeMin > _altitudeMax) {
        if (newMin != null) _altitudeMax = _altitudeMin;
        if (newMax != null) _altitudeMin = _altitudeMax;
      }
      final formatted = '$_altitudeMin - $_altitudeMax MDPL';
      _altitudeCtrl.text = formatted;
      ref.read(inAppTrainerControllerProvider.notifier).updateMetadata(altitude: formatted);
    });
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _nameCtrl.dispose();
    _varietalCtrl.dispose();
    _altitudeCtrl.dispose();
    _newNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int slotIndex, ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (picked != null) {
        final ctrl = ref.read(inAppTrainerControllerProvider.notifier);
        ctrl.addOrUpdateSample(
          index: slotIndex,
          imagePath: picked.path,
          boundingBox: const Rect.fromLTWH(0.08, 0.08, 0.84, 0.84),
        );
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Alur pengambilan 3 foto sekaligus secara berurutan: Depan -> Kiri -> Kanan.
  Future<void> _startSequentialCapture([ImageSource source = ImageSource.camera]) async {
    final ctrl = ref.read(inAppTrainerControllerProvider.notifier);
    final angles = [
      {'title': 'Depan', 'hint': 'Posisikan kemasan tegak lurus tampak depan'},
      {'title': 'Kiri', 'hint': 'Miringkan kemasan ke sisi kiri ~25°'},
      {'title': 'Kanan', 'hint': 'Miringkan kemasan ke sisi kanan ~25°'},
    ];

    for (int i = 0; i < 3; i++) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(CupertinoIcons.camera, color: Color(0xFFD4AF37), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Langkah ${i + 1}/3 (${angles[i]['title']}): ${angles[i]['hint']}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF1E1714),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (picked == null) {
        if (mounted && i > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pengambilan foto dihentikan. $i foto tersimpan.'),
              backgroundColor: const Color(0xFFF59E0B),
            ),
          );
        }
        return;
      }

      ctrl.addOrUpdateSample(
        index: i,
        imagePath: picked.path,
        boundingBox: const Rect.fromLTWH(0.08, 0.08, 0.84, 0.84),
      );
      ctrl.selectSampleIndex(i);
      HapticFeedback.mediumImpact();

      if (i < 2) {
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }

    if (mounted) {
      ctrl.selectSampleIndex(0);
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Lengkap! 3 foto kemasan (Depan, Kiri, Kanan) siap di-annotasi.'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSequentialCaptureOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1714),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ambil 3 Foto Berurutan',
                style: TextStyle(
                  color: Color(0xFFF9F5EE),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Alur otomatis: Depan ➔ Sisi Kiri (~25°) ➔ Sisi Kanan (~25°)',
                style: TextStyle(color: Colors.white60, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(CupertinoIcons.camera_fill, color: Color(0xFFD4AF37)),
                title: const Text('Buka Kamera (Berurutan Langsung)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Rekomendasi barista untuk akurasi terbaik', style: TextStyle(color: Colors.white38, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _startSequentialCapture(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.photo_fill, color: Color(0xFFD4AF37)),
                title: const Text('Pilih dari Galeri (Berurutan)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Pilih 3 foto dari galeri HP satu per satu', style: TextStyle(color: Colors.white38, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _startSequentialCapture(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerSheet(int slotIndex) {
    final label = _slotLabels[slotIndex.clamp(0, 2)];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1714),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ambil Foto $label',
                style: const TextStyle(
                  color: Color(0xFFF9F5EE),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(CupertinoIcons.camera_fill, color: Color(0xFFD4AF37)),
                title: const Text('Kamera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(slotIndex, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.photo_fill, color: Color(0xFFD4AF37)),
                title: const Text('Galeri Foto', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(slotIndex, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startTrainingProcess() async {
    final state = ref.read(inAppTrainerControllerProvider);
    if (!state.canTrain) return;

    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Consumer(
        builder: (context, ref, child) {
          final liveState = ref.watch(inAppTrainerControllerProvider);
          return TrainingTelemetryModal(
            phase: liveState.phase,
            statusMessage: liveState.statusMessage,
            overallProgress: liveState.progress,
            currentAugmentation: liveState.currentAugmentation,
            totalAugmentations: liveState.totalAugmentations,
            latestThumbnailBytes: liveState.latestThumbnailBytes,
            currentEpoch: liveState.currentEpoch,
            totalEpochs: liveState.totalEpochs,
            currentLoss: liveState.currentLoss,
            currentAccuracy: liveState.currentAccuracy,
            onDismiss: () {
              Navigator.of(dialogCtx, rootNavigator: true).pop();
              if (liveState.phase == TrainingPhase.completed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'AI siap mengenali ${liveState.trainedResult?.displayTitle}!',
                    ),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
          );
        },
      ),
    );

    await ref.read(inAppTrainerControllerProvider.notifier).startTraining();
  }

  void _showAddNoteDialog() {
    _newNoteCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1714),
        title: const Text('Tambah Tasting Note', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _newNoteCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Misal: Lavender, Earl Grey...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = _newNoteCtrl.text.trim();
              if (text.isNotEmpty) {
                final currentNotes = List<String>.from(
                  ref.read(inAppTrainerControllerProvider).draft.tastingNotes,
                );
                if (!currentNotes.contains(text)) {
                  currentNotes.add(text);
                  ref.read(inAppTrainerControllerProvider.notifier).updateMetadata(
                        tastingNotes: currentNotes,
                      );
                }
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inAppTrainerControllerProvider);
    final draft = state.draft;
    final selectedIdx = state.selectedSampleIndex;
    final activeSample =
        (selectedIdx >= 0 && selectedIdx < draft.samples.length) ? draft.samples[selectedIdx] : null;

    final slug = ClassSlugGenerator.generate(
      brand: draft.roasteryBrand,
      beanName: draft.beanName,
      process: draft.process,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF14100E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1412),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_left, color: Color(0xFFD4AF37)),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Studio Pelatihan AI',
              style: TextStyle(
                color: Color(0xFFF9F5EE),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'On-Device Few-Shot Transfer Learning',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.info_circle, color: Colors.white70),
            onPressed: _showExplanationSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card 1: 3 Foto Kemasan & Smart Annotation Canvas
            _buildAnnotationSection(state, activeSample, selectedIdx),
            const SizedBox(height: 20),

            // Card 2: Metadata Biji Kopi
            _buildMetadataFormSection(draft, slug),
            const SizedBox(height: 20),

            // Card 3: Preview ML Class Head
            _buildMlHeadPreview(slug, draft),
          ],
        ),
      ),
      bottomSheet: _buildBottomActionBar(state),
    );
  }

  Widget _buildAnnotationSection(
    InAppTrainerState state,
    dynamic activeSample,
    int selectedIdx,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1513),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tanpa "(Min. 3 Sudut)" dan menggunakan Expanded agar tidak overflow
          Row(
            children: [
              const Icon(CupertinoIcons.camera_viewfinder, color: Color(0xFFD4AF37), size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '1. Foto Kemasan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: state.draft.samples.length >= 3
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.draft.samples.length}/3 Foto',
                  style: TextStyle(
                    color: state.draft.samples.length >= 3
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tombol Alur Cepat: Ambil 3 Foto Sekaligus Berurutan (Depan ➔ Kiri ➔ Kanan)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showSequentialCaptureOptions,
              icon: const Icon(Icons.burst_mode, size: 18),
              label: const Text(
                'Ambil 3 Foto Berurutan (Depan ➔ Kiri ➔ Kanan)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF422B1D),
                foregroundColor: const Color(0xFFF9F5EE),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFD4AF37), width: 1.1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3 Thumbnail Slot Selector (Hanya label Depan, Kiri, Kanan)
          Row(
            children: [
              _buildPhotoSlot(
                index: 0,
                label: 'Depan',
                tag: 'front',
                isSelected: selectedIdx == 0,
                state: state,
              ),
              const SizedBox(width: 8),
              _buildPhotoSlot(
                index: 1,
                label: 'Kiri',
                tag: 'angle_left',
                isSelected: selectedIdx == 1,
                state: state,
              ),
              const SizedBox(width: 8),
              _buildPhotoSlot(
                index: 2,
                label: 'Kanan',
                tag: 'angle_right',
                isSelected: selectedIdx == 2,
                state: state,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Area Smart Annotation Canvas
          if (activeSample != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 320,
                width: double.infinity,
                child: SmartAnnotationCanvas(
                  imageFile: File(activeSample.imagePath),
                  currentBox: activeSample.boundingBoxNormalized,
                  onBoxChanged: (newBox) {
                    ref
                        .read(inAppTrainerControllerProvider.notifier)
                        .updateBoundingBox(selectedIdx, newBox);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.touch_app_outlined, size: 14, color: Color(0xFFD4AF37)),
                    SizedBox(width: 4),
                    Text(
                      'Tap kemasan untuk Auto-Snap • Geser sudut untuk fine-tune',
                      style: TextStyle(color: Colors.white54, fontSize: 10.5),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showImagePickerSheet(selectedIdx),
                  icon: const Icon(Icons.refresh, size: 14, color: Color(0xFFD4AF37)),
                  label: const Text(
                    'Ganti Foto',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Placeholder bila slot aktif belum memiliki foto
            GestureDetector(
              onTap: () => _showImagePickerSheet(selectedIdx),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF241D1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.camera_fill,
                          color: Color(0xFFD4AF37),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ambil Foto ${_slotLabels[selectedIdx.clamp(0, 2)]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ketuk di sini untuk buka Kamera / Galeri',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoSlot({
    required int index,
    required String label,
    required String tag,
    required bool isSelected,
    required InAppTrainerState state,
  }) {
    final hasPhoto = index < state.draft.samples.length;
    final sample = hasPhoto ? state.draft.samples[index] : null;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (hasPhoto) {
            ref.read(inAppTrainerControllerProvider.notifier).selectSampleIndex(index);
          } else {
            _showImagePickerSheet(index);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2C221D) : const Color(0xFF221A17),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD4AF37)
                  : hasPhoto
                      ? const Color(0xFF10B981)
                      : Colors.white12,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 64,
                  width: double.infinity,
                  child: hasPhoto && File(sample!.imagePath).existsSync()
                      ? Image.file(
                          File(sample.imagePath),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFF181210),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: Colors.white30,
                            size: 22,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white70,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataFormSection(dynamic draft, String slug) {
    final ctrl = ref.read(inAppTrainerControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1513),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.tag_fill, color: Color(0xFFD4AF37), size: 18),
              SizedBox(width: 8),
              Text(
                '2. Metadata Kopi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Roastery Brand
          _buildTextField(
            label: 'Brand / Roastery *',
            hint: 'Misal: Two Hands, Space Roastery, Fugol...',
            controller: _brandCtrl,
            onChanged: (val) => ctrl.updateMetadata(brand: val),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _roasteryPresets.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, idx) {
                final b = _roasteryPresets[idx];
                return ActionChip(
                  backgroundColor: const Color(0xFF221A17),
                  side: const BorderSide(color: Colors.white12),
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  label: Text(b, style: const TextStyle(color: Colors.white60, fontSize: 10.5)),
                  onPressed: () {
                    setState(() {
                      _brandCtrl.text = b;
                    });
                    ctrl.updateMetadata(brand: b);
                    HapticFeedback.selectionClick();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Bean Name / Origin
          _buildTextField(
            label: 'Nama Kopi / Origin *',
            hint: 'Misal: Kamojang Apple Cider, Gayo Pantan Musara...',
            controller: _nameCtrl,
            onChanged: (val) => ctrl.updateMetadata(beanName: val),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _originPresets.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, idx) {
                final o = _originPresets[idx];
                return ActionChip(
                  backgroundColor: const Color(0xFF221A17),
                  side: const BorderSide(color: Colors.white12),
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  label: Text(o, style: const TextStyle(color: Colors.white60, fontSize: 10.5)),
                  onPressed: () {
                    setState(() {
                      _nameCtrl.text = o;
                    });
                    ctrl.updateMetadata(beanName: o);
                    HapticFeedback.selectionClick();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Varietas (Preset Pilihan Chip + Input Kustom)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Varietas:',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              if (_varietalCtrl.text.isNotEmpty)
                Flexible(
                  child: Text(
                    _varietalCtrl.text,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _varietalPresets.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, idx) {
                final v = _varietalPresets[idx];
                final isSel = _varietalCtrl.text.toLowerCase() == v.toLowerCase();
                return ChoiceChip(
                  label: Text(v),
                  selected: isSel,
                  selectedColor: const Color(0xFFD4AF37),
                  backgroundColor: const Color(0xFF251D1A),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.black : Colors.white70,
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSel ? const Color(0xFFD4AF37) : Colors.white12,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _varietalCtrl.text = v;
                      });
                      ctrl.updateMetadata(varietal: v);
                      HapticFeedback.selectionClick();
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          _buildTextField(
            label: 'Atau Input Varietas Kustom',
            hint: 'Misal: Typica, Ateng Super, Gesha...',
            controller: _varietalCtrl,
            onChanged: (val) => ctrl.updateMetadata(varietal: val),
          ),
          const SizedBox(height: 16),

          // Proses Pascapanen Filter Chips
          const Text(
            'Proses Pascapanen:',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _processOptions.map((proc) {
              final isSel = draft.process.toLowerCase() == proc.toLowerCase();
              return ChoiceChip(
                label: Text(proc),
                selected: isSel,
                selectedColor: const Color(0xFFD4AF37),
                backgroundColor: const Color(0xFF28201C),
                labelStyle: TextStyle(
                  color: isSel ? Colors.black : Colors.white70,
                  fontSize: 11.5,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSel ? const Color(0xFFD4AF37) : Colors.white12,
                ),
                onSelected: (val) {
                  if (val) {
                    ctrl.updateMetadata(process: proc);
                    HapticFeedback.selectionClick();
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Ketinggian Stepper (+50 dan -50 MDPL)
          _buildAltitudeStepperSection(),
          const SizedBox(height: 16),

          // Tasting Notes dari Katalog Resep Dunia
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tasting Notes:',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: _showAddNoteDialog,
                icon: const Icon(Icons.add, size: 14, color: Color(0xFFD4AF37)),
                label: const Text(
                  '+ Tambah Kustom',
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11),
                ),
              ),
            ],
          ),
          if (draft.tastingNotes.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...draft.tastingNotes.map((note) {
                  return Chip(
                    backgroundColor: const Color(0xFF2C221D),
                    side: const BorderSide(color: Color(0xFF5C3A21)),
                    label: Text(
                      note,
                      style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 11),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 13, color: Colors.white54),
                    onDeleted: () {
                      final updated = List<String>.from(draft.tastingNotes)..remove(note);
                      ctrl.updateMetadata(tastingNotes: updated);
                      HapticFeedback.lightImpact();
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const Text(
            'Pilih dari World Recipe (Tap untuk Tambah / Hapus):',
            style: TextStyle(color: Colors.white38, fontSize: 10.5),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _commonNotes.map((note) {
              final isSelected = draft.tastingNotes.contains(note);
              return FilterChip(
                selected: isSelected,
                selectedColor: const Color(0xFFD4AF37),
                backgroundColor: const Color(0xFF221A17),
                checkmarkColor: Colors.black,
                side: BorderSide(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white10,
                ),
                label: Text(
                  note,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onSelected: (selected) {
                  final updated = List<String>.from(draft.tastingNotes);
                  if (selected) {
                    if (!updated.contains(note)) updated.add(note);
                  } else {
                    updated.remove(note);
                  }
                  ctrl.updateMetadata(tastingNotes: updated);
                  HapticFeedback.selectionClick();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Interactive Stepper Ketinggian dengan tombol + 50 dan - 50 (Format: MDPL).
  Widget _buildAltitudeStepperSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF221A17),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.terrain, color: Color(0xFFD4AF37), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Ketinggian (Altitude)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                ),
                child: Text(
                  '$_altitudeMin - $_altitudeMax MDPL',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stepper baris Batas Bawah & Batas Atas dengan tombol + 50 dan - 50
          Row(
            children: [
              // Min Altitude
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1513),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Batas Bawah',
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_altitudeMin MDPL',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStepperButton(
                            label: '- 50',
                            onTap: () => _updateAltitude(newMin: _altitudeMin - 50),
                          ),
                          const SizedBox(width: 6),
                          _buildStepperButton(
                            label: '+ 50',
                            onTap: () => _updateAltitude(newMin: _altitudeMin + 50),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Max Altitude
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1513),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Batas Atas',
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_altitudeMax MDPL',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStepperButton(
                            label: '- 50',
                            onTap: () => _updateAltitude(newMax: _altitudeMax - 50),
                          ),
                          const SizedBox(width: 6),
                          _buildStepperButton(
                            label: '+ 50',
                            onTap: () => _updateAltitude(newMax: _altitudeMax + 50),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tombol Geser Rentang +/- 50 MDPL Sekaligus
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateAltitude(
                    newMin: _altitudeMin - 50,
                    newMax: _altitudeMax - 50,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Geser - 50 MDPL', style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateAltitude(
                    newMin: _altitudeMin + 50,
                    newMax: _altitudeMax + 50,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD4AF37),
                    side: const BorderSide(color: Color(0xFFD4AF37)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Geser + 50 MDPL', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2C221D),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF5C3A21)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFF9F5EE),
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF251D1A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMlHeadPreview(String slug, dynamic draft) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161311),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_scanner, color: Color(0xFFD4AF37), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deterministic ML Class Identifier:',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  slug.isEmpty ? 'brand_beanname_process' : slug,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '45 Tensors',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(InAppTrainerState state) {
    final canTrain = state.canTrain;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1412),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canTrain ? _startTrainingProcess : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              disabledBackgroundColor: Colors.white12,
              foregroundColor: Colors.black,
              disabledForegroundColor: Colors.white24,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: canTrain ? 6 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.model_training,
                  size: 20,
                  color: canTrain ? Colors.black : Colors.white24,
                ),
                const SizedBox(width: 10),
                Text(
                  canTrain
                      ? 'Latih Model On-Device (60 Epochs)'
                      : 'Lengkapi 3 Foto & Nama Kopi (${state.draft.samples.length}/3)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: canTrain ? Colors.black : Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExplanationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1714),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.psychology, color: Color(0xFFD4AF37), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Arsitektur Transfer Learning',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                '1. Smart Tap Annotation:\n'
                'Deteksi kemasan otomatis menggunakan gradient thresholding & flood fill.\n\n'
                '2. 15x Background Augmentation:\n'
                '3 foto diekspansi menjadi 45 tensor dengan rotasi, perspektif 3D, pencahayaan kafe 2700K, dan specular glares.\n\n'
                '3. Cosine-Margin Head (AdamW):\n'
                'Melatih head klasifikasi 960-dimensi langsung di memori HP dalam 60 epoch tanpa panas berlebih atau jank UI.',
                style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Mengerti'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
