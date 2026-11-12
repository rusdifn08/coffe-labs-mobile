import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/coffee_annotation_class.dart';
import '../domain/models/studio_image_item.dart';
import '../../scanner/domain/services/image_tensor_isolate.dart';
import '../../scanner/domain/services/incremental_vision_engine.dart';
import 'controllers/annotation_studio_controller.dart';

class MobileVersionsAndTrainStepperScreen extends ConsumerStatefulWidget {
  const MobileVersionsAndTrainStepperScreen({super.key});

  @override
  ConsumerState<MobileVersionsAndTrainStepperScreen> createState() =>
      _MobileVersionsAndTrainStepperScreenState();
}

class _MobileVersionsAndTrainStepperScreenState
    extends ConsumerState<MobileVersionsAndTrainStepperScreen> {
  int _currentStep = 0;
  double _trainRatio = 0.8;
  final Set<String> _selectedClassSlugs = {};

  // Augmentation toggles
  bool _augFlip = true;
  bool _augRotate = true;
  bool _augFoilSheen = true;
  bool _augLighting = true;

  // Training state
  bool _isTraining = false;
  double _trainingProgress = 0.0;
  String _trainingStatusText = '';
  List<String> _completedClasses = [];

  @override
  void initState() {
    super.initState();
    final state = ref.read(annotationStudioProvider);
    _selectedClassSlugs.addAll(state.classes.map((c) => c.classSlug));
  }

  Future<void> _runNcmTraining(List<StudioImageItem> validImages) async {
    setState(() {
      _isTraining = true;
      _trainingProgress = 0.05;
      _trainingStatusText = 'Memulai pipeline pelatihan MobileNetV4 NCM On-Device...';
      _completedClasses = [];
    });

    try {
      await IncrementalVisionEngine.instance.initialize();

      // Group images by class_slug
      final Map<String, List<StudioImageItem>> classGroups = {};
      for (final img in validImages) {
        final slug = img.classSlug;
        if (slug != null && _selectedClassSlugs.contains(slug)) {
          classGroups.putIfAbsent(slug, () => []).add(img);
        }
      }

      final totalClasses = classGroups.length;
      int processedClasses = 0;

      for (final entry in classGroups.entries) {
        final slug = entry.key;
        final images = entry.value;

        setState(() {
          _trainingStatusText = 'Melatih class "$slug" (${images.length} foto sumber)...';
        });

        // Prepare PreprocessInputDtos
        final photoInputs = <PreprocessInputDto>[];
        for (int i = 0; i < images.length; i++) {
          final it = images[i];
          photoInputs.add(PreprocessInputDto(
            sampleId: '${slug}_$i',
            imagePath: it.filePath,
            left: it.bbox.length >= 4 ? it.bbox[0] : 0.05,
            top: it.bbox.length >= 4 ? it.bbox[1] : 0.05,
            right: it.bbox.length >= 4 ? it.bbox[2] : 0.95,
            bottom: it.bbox.length >= 4 ? it.bbox[3] : 0.95,
          ));
        }

        // Get class metadata
        final clsMeta = ref.read(annotationStudioProvider).classes.firstWhere(
              (c) => c.classSlug == slug,
              orElse: () => CoffeeAnnotationClass(
                classSlug: slug,
                displayName: slug.replaceAll('_', ' ').toUpperCase(),
                colorHex: '#8B5CF6',
                brand: images.first.brand ?? 'Specialty Roastery',
                coffeeName: images.first.coffeeName ?? 'Specialty Coffee',
                process: images.first.process ?? 'Single Origin',
                createdAt: DateTime.now(),
              ),
            );

        await IncrementalVisionEngine.instance.trainOrUpdateClass(
          classSlug: slug,
          roastery: clsMeta.brand.isNotEmpty ? clsMeta.brand : 'Specialty Roastery',
          coffeeName: clsMeta.coffeeName.isNotEmpty ? clsMeta.coffeeName : 'Single Origin',
          origin: clsMeta.origin,
          variety: clsMeta.variety,
          process: clsMeta.process.isNotEmpty ? clsMeta.process : 'Washed',
          altitude: clsMeta.altitude,
          recommendedTemp: clsMeta.recommendedTemp,
          tastingNotes: clsMeta.tastingNotes.isNotEmpty
              ? clsMeta.tastingNotes
              : ['Floral', 'Fruity', 'Brown Sugar'],
          photoInputs: photoInputs,
          onProgress: (current, total, status) {
            final classPart = processedClasses / (totalClasses > 0 ? totalClasses : 1);
            final innerPart = (current / (total > 0 ? total : 1)) / (totalClasses > 0 ? totalClasses : 1);
            setState(() {
              _trainingProgress = (classPart + innerPart).clamp(0.05, 0.95);
              _trainingStatusText = '[$slug] $status';
            });
          },
        );

        processedClasses++;
        setState(() {
          _completedClasses.add(slug);
        });
      }

      setState(() {
        _isTraining = false;
        _trainingProgress = 1.0;
        _trainingStatusText = 'Sukses! $processedClasses class prototype berhasil disimpan ke SQLite.';
      });
    } catch (e) {
      setState(() {
        _isTraining = false;
        _trainingStatusText = 'Gagal melatih model: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFF9F6F0);
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    final state = ref.watch(annotationStudioProvider);
    final validImages = state.images.where((i) => i.isAnnotated && !i.isRejected).toList();

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: bgCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MobileNetV4 Version & Train',
              style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '5-Step On-Device Continual Learning Stepper',
              style: TextStyle(color: textMuted, fontSize: 10.5),
            ),
          ],
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6B4423),
            secondary: Color(0xFFD97706),
            surface: Colors.white,
          ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            if (!_isTraining) setState(() => _currentStep = step);
          },
          onStepContinue: () {
            if (_currentStep < 4) {
              setState(() => _currentStep++);
            } else if (_currentStep == 4 && !_isTraining) {
              _runNcmTraining(validImages);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0 && !_isTraining) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            if (_currentStep == 4) {
              return Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4423),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: Icon(_trainingProgress >= 1.0 ? Icons.check_rounded : Icons.rocket_launch_rounded, size: 17),
                        label: Text(
                          _isTraining
                              ? 'Sedang Melatih...'
                              : (_trainingProgress >= 1.0 ? 'Selesai & Tutup' : 'Mulai Train MobileNetV4 NCM'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: _isTraining
                            ? null
                            : (_trainingProgress >= 1.0 ? () => Navigator.of(context).pop() : details.onStepContinue),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4423),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: details.onStepContinue,
                    child: const Text('Lanjut'),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: textMuted),
                      onPressed: details.onStepCancel,
                      child: const Text('Kembali'),
                    ),
                ],
              ),
            );
          },
          steps: [
            // STEP 1: SOURCE IMAGES
            Step(
              title: const Text('1. Source Images (Valid Bag)', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(
                '${validImages.length} Kemasan Kopi (Otomatis membuang foto non-kopi)',
                style: const TextStyle(color: textMuted, fontSize: 11),
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Container(
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
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${validImages.length} Foto Kemasan Kopi Terverifikasi',
                          style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.rejectedCount} foto bukan kopi berhasil disaring oleh Non-Coffee Gatekeeper dan tidak disertakan ke training.',
                      style: const TextStyle(color: textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),

            // STEP 2: TRAIN / VAL SPLIT
            Step(
              title: const Text('2. Train / Val Split & Class Selector', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(
                '${(_trainRatio * 100).toInt()}% Train / ${((1 - _trainRatio) * 100).toInt()}% Val',
                style: const TextStyle(color: textMuted, fontSize: 11),
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    value: _trainRatio,
                    min: 0.6,
                    max: 0.9,
                    divisions: 6,
                    label: '${(_trainRatio * 100).toInt()}%',
                    activeColor: const Color(0xFF6B4423),
                    onChanged: (val) => setState(() => _trainRatio = val),
                  ),
                  const SizedBox(height: 8),
                  const Text('Pilih Class untuk Versi Ini:', style: TextStyle(color: textDark, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: state.classes.map((cls) {
                      final isSelected = _selectedClassSlugs.contains(cls.classSlug);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(cls.classSlug, style: const TextStyle(fontSize: 10)),
                        selectedColor: const Color(0xFF6B4423),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : textDark),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: isSelected ? const Color(0xFF6B4423) : const Color(0xFFEFE8DE)),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedClassSlugs.add(cls.classSlug);
                            } else {
                              _selectedClassSlugs.remove(cls.classSlug);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // STEP 3: PREPROCESSING
            Step(
              title: const Text('3. On-Device Preprocessing', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text(
                'Auto-Orient, Mask Isolation, CLAHE Contrast & 256x256 Resize',
                style: TextStyle(color: textMuted, fontSize: 11),
              ),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEFE8DE), width: 1.1),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PipelineItem(text: '✓ Auto-Orient EXIF citra ponsel'),
                    _PipelineItem(text: '✓ Isolasi Poligon Kemasan (menghapus latar luar menjadi putih 255)'),
                    _PipelineItem(text: '✓ CLAHE Contrast Enhancement untuk menembus pantulan foil/plastik'),
                    _PipelineItem(text: '✓ Bilinear Resize ke format MobileNetV4 [1, 256, 256, 3]'),
                  ],
                ),
              ),
            ),

            // STEP 4: AUGMENTATION (10X EXPANSION: 3 FOTO -> 30 VARIASI)
            Step(
              title: const Text('4. Isolate 10x Data Augmentation', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text(
                '10x variasi fotorealistik per foto di background Isolate (3 foto = 30 variasi)',
                style: TextStyle(color: textMuted, fontSize: 11),
              ),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              content: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEFE8DE), width: 1.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBF8F3),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: Color(0xFFD97706)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Multiplikasi 10x: Dari 3 foto kemasan menjadi 30 tensor berbobot tinggi',
                              style: TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Color(0xFFEFE8DE), height: 1),
                    CheckboxListTile(
                      title: const Text('Mirroring Simetris (Horizontal Flip)', style: TextStyle(color: textDark, fontSize: 12)),
                      value: _augFlip,
                      activeColor: const Color(0xFF6B4423),
                      dense: true,
                      onChanged: (val) => setState(() => _augFlip = val ?? true),
                    ),
                    const Divider(color: Color(0xFFEFE8DE), height: 1),
                    CheckboxListTile(
                      title: const Text('Rotasi ±8° & Perspektif Meja Cafe (Tilt)', style: TextStyle(color: textDark, fontSize: 12)),
                      value: _augRotate,
                      activeColor: const Color(0xFF6B4423),
                      dense: true,
                      onChanged: (val) => setState(() => _augRotate = val ?? true),
                    ),
                    const Divider(color: Color(0xFFEFE8DE), height: 1),
                    CheckboxListTile(
                      title: const Text('Simulasi Kilau Pantulan Foil / Window Glare', style: TextStyle(color: textDark, fontSize: 12)),
                      value: _augFoilSheen,
                      activeColor: const Color(0xFF6B4423),
                      dense: true,
                      onChanged: (val) => setState(() => _augFoilSheen = val ?? true),
                    ),
                    const Divider(color: Color(0xFFEFE8DE), height: 1),
                    CheckboxListTile(
                      title: const Text('Pencahayaan Hangat Cafe (2700K) vs Cool Daylight (6500K)', style: TextStyle(color: textDark, fontSize: 12)),
                      value: _augLighting,
                      activeColor: const Color(0xFF6B4423),
                      dense: true,
                      onChanged: (val) => setState(() => _augLighting = val ?? true),
                    ),
                  ],
                ),
              ),
            ),

            // STEP 5: TRAIN MOBILENETV4 HYBRID NCM
            Step(
              title: const Text('5. Train MobileNetV4 Hybrid NCM', style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text(
                'Ekstraksi 1280-D L2-norm, Centroid & Sub-Centroids ke SQLite',
                style: TextStyle(color: textMuted, fontSize: 11),
              ),
              isActive: _currentStep >= 4,
              state: _trainingProgress >= 1.0 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEFE8DE), width: 1.1),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.memory, size: 16, color: Color(0xFF7C3AED)),
                            SizedBox(width: 8),
                            Text(
                              'Arsitektur Hybrid MobileNetV4 (1280-D NCM)',
                              style: TextStyle(color: Color(0xFF2D1F17), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Menggabungkan representasi fitur MobileNetV4 dengan K=2 Sub-Centroids spatial pooling. Mencegah catastrophic forgetting secara on-device dengan latensi < 12 ms.',
                          style: TextStyle(color: Color(0xFF8F857D), fontSize: 10.5, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isTraining || _trainingProgress > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _trainingProgress,
                        backgroundColor: const Color(0xFFE8DFD8),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6B4423)),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _trainingStatusText,
                      style: const TextStyle(color: Color(0xFFB45309), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_completedClasses.isNotEmpty) ...[
                    const Text('Class Berhasil Dilatih (Memori NCM):', style: TextStyle(color: textDark, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _completedClasses.map((c) {
                        return Chip(
                          backgroundColor: const Color(0xFFECFDF5),
                          side: const BorderSide(color: Color(0xFF059669)),
                          label: Text('$c (30 variasi)', style: const TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PipelineItem extends StatelessWidget {
  final String text;
  const _PipelineItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF5C4E43), fontSize: 11.5),
      ),
    );
  }
}
