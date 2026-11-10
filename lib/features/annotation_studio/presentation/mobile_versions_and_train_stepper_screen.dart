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
    final state = ref.watch(annotationStudioProvider);
    final validImages = state.images.where((i) => i.isAnnotated && !i.isRejected).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Deep Espresso Obsidian
      appBar: AppBar(
        backgroundColor: const Color(0xFF12100E),
        elevation: 0,
        title: const Text(
          'MobileNetV4 Version & Train',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF8B5CF6),
            secondary: Color(0xFFD4A373),
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
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D28D9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(_trainingProgress >= 1.0 ? Icons.check : Icons.rocket_launch, size: 18),
                        label: Text(
                          _isTraining
                              ? 'Sedang Melatih...'
                              : (_trainingProgress >= 1.0 ? 'Selesai & Tutup' : 'Mulai Train MobileNetV4 NCM'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D28D9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: details.onStepContinue,
                    child: const Text('Lanjut'),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.white60),
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
              title: const Text('1. Source Images (Valid Bag)', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                '${validImages.length} Kemasan Kopi (Otomatis membuang foto non-kopi)',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${validImages.length} Foto Kemasan Kopi Terverifikasi',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${state.rejectedCount} foto bukan kopi berhasil disaring oleh Non-Coffee Gatekeeper dan tidak disertakan ke training.',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),

            // STEP 2: TRAIN / VAL SPLIT
            Step(
              title: const Text('2. Train / Val Split & Class Selector', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                '${(_trainRatio * 100).toInt()}% Train / ${((1 - _trainRatio) * 100).toInt()}% Val',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
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
                    activeColor: const Color(0xFF8B5CF6),
                    onChanged: (val) => setState(() => _trainRatio = val),
                  ),
                  const SizedBox(height: 10),
                  const Text('Pilih Class untuk Versi Ini:', style: TextStyle(color: Colors.white, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.classes.map((cls) {
                      final isSelected = _selectedClassSlugs.contains(cls.classSlug);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(cls.classSlug, style: const TextStyle(fontSize: 10)),
                        selectedColor: const Color(0xFF6D28D9),
                        checkmarkColor: Colors.white,
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
              title: const Text('3. On-Device Preprocessing', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Auto-Orient, Mask Isolation, CLAHE Contrast & 256x256 Resize',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B26),
                  borderRadius: BorderRadius.circular(12),
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

            // STEP 4: AUGMENTATION
            Step(
              title: const Text('4. Isolate Augmentation', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                '15x variasi per foto di background Isolate (Multi-Angle, Foil Sheen)',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Horizontal Flip & Jitter', style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: _augFlip,
                    activeColor: const Color(0xFF8B5CF6),
                    onChanged: (val) => setState(() => _augFlip = val ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text('Rotasi ±12° & Perspektif', style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: _augRotate,
                    activeColor: const Color(0xFF8B5CF6),
                    onChanged: (val) => setState(() => _augRotate = val ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text('Simulasi Kilau Foil / Pantulan Plastik', style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: _augFoilSheen,
                    activeColor: const Color(0xFF8B5CF6),
                    onChanged: (val) => setState(() => _augFoilSheen = val ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text('Variasi Pencahayaan Kafe (CCT 2700K - 6500K)', style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: _augLighting,
                    activeColor: const Color(0xFF8B5CF6),
                    onChanged: (val) => setState(() => _augLighting = val ?? true),
                  ),
                ],
              ),
            ),

            // STEP 5: TRAIN MOBILENETV4 NCM
            Step(
              title: const Text('5. Train & Update MobileNetV4 NCM', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Ekstraksi 1280-D L2-norm, Centroid & K=2 Sub-Centroids ke SQLite',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              isActive: _currentStep >= 4,
              state: _trainingProgress >= 1.0 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isTraining || _trainingProgress > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _trainingProgress,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _trainingStatusText,
                      style: const TextStyle(color: Color(0xFFD4A373), fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_completedClasses.isNotEmpty) ...[
                    const Text('Class Berhasil Dilatih:', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _completedClasses.map((c) {
                        return Chip(
                          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                          side: const BorderSide(color: Color(0xFF10B981)),
                          label: Text(c, style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
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
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }
}
