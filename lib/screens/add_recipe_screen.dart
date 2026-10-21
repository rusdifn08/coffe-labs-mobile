import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../data/brew_visual_catalog.dart';

class _StepDraft {
  final TextEditingController titleCtrl;
  final TextEditingController durationCtrl;
  final TextEditingController waterCtrl;
  final TextEditingController instructionCtrl;

  _StepDraft({
    String title = '',
    String duration = '35',
    String water = '50',
    String instruction = '',
  })  : titleCtrl = TextEditingController(text: title),
        durationCtrl = TextEditingController(text: duration),
        waterCtrl = TextEditingController(text: water),
        instructionCtrl = TextEditingController(text: instruction);

  void dispose() {
    titleCtrl.dispose();
    durationCtrl.dispose();
    waterCtrl.dispose();
    instructionCtrl.dispose();
  }
}

class AddRecipeScreen extends StatefulWidget {
  final Map<String, dynamic>? initialRecipe;

  const AddRecipeScreen({super.key, this.initialRecipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _beanController = TextEditingController();
  final _methodController = TextEditingController(text: 'Hario V60 02');
  final _grindController = TextEditingController();
  final _tempController = TextEditingController(text: '92');
  final _coffeeController = TextEditingController(text: '15');
  final _waterController = TextEditingController(text: '225');
  final _iceController = TextEditingController(text: '0');
  final _tastingController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'V60';
  String _selectedGrindPreset = 'Medium';
  String _selectedDripperName = 'Hario V60 02';
  bool _customDripperManual = false;

  // BEAN CUSTOMIZATION STATE
  String _selectedBeanName = 'Aceh Gayo';
  String _selectedVariety = 'Sigarar Utang / TimTim';
  String _selectedRoast = 'Light-Medium';
  String _selectedProcess = 'Natural';
  bool _customBeanManual = false;

  // TASTING NOTES STATE
  final Set<String> _selectedNoteLabels = {
    'Caramel & Brown Sugar',
    'Sweet Orange',
    'Clean & Juicy Finish',
  };

  // GRINDER & CLICKS INTERACTIVE STATE
  GrinderModel _selectedGrinder = BrewVisualCatalog.grinderModels.first; // Comandante C40
  int _currentClicks = 23;

  bool _autoSyncWater = true;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = const [
    {'label': 'V60', 'icon': CupertinoIcons.drop_fill, 'method': 'Hario V60 02'},
    {'label': 'Japanese', 'icon': CupertinoIcons.snow, 'method': 'Hario V60 02 + Es di Server'},
    {'label': 'AeroPress', 'icon': CupertinoIcons.bolt_fill, 'method': 'AeroPress Standard / Inverted'},
    {'label': 'French Press', 'icon': CupertinoIcons.flame_fill, 'method': 'French Press Carafe'},
    {'label': 'Immersion', 'icon': CupertinoIcons.timer_fill, 'method': 'AeroPress / Clever Dripper'},
    {'label': 'Hybrid', 'icon': CupertinoIcons.lab_flask_solid, 'method': 'Hario Switch 02'},
    {'label': 'Flat Bottom', 'icon': CupertinoIcons.cube_fill, 'method': 'Kalita Wave 185 / Orea V4'},
    {'label': 'Origami', 'icon': CupertinoIcons.star_fill, 'method': 'Origami Dripper Air S'},
    {'label': 'Cone', 'icon': CupertinoIcons.triangle_fill, 'method': 'Chemex / Kono Dripper'},
  ];

  final List<Map<String, String>> _grindPresets = const [
    {'label': 'Fine', 'desc': 'Halus (~450µm)'},
    {'label': 'Medium-Fine', 'desc': 'Sedang-Halus (~570µm)'},
    {'label': 'Medium', 'desc': 'Sedang Standar (~660µm)'},
    {'label': 'Medium-Coarse', 'desc': 'Sedang-Kasar (~780µm)'},
    {'label': 'Coarse', 'desc': 'Kasar (~900µm)'},
  ];

  final List<_StepDraft> _steps = [];

  bool get _isIcedMethod {
    final cat = _selectedCategory.toLowerCase();
    final meth = _methodController.text.toLowerCase();
    return cat.contains('japanese') || cat.contains('ice') || meth.contains('es') || meth.contains('ice');
  }

  @override
  void initState() {
    super.initState();
    _loadAuthorName();
    _currentClicks = _selectedGrinder.getClicksForPreset(_selectedGrindPreset);
    _syncGrindText();

    if (widget.initialRecipe != null) {
      _populateFromInitial(ApiService.sanitizeRecipe(widget.initialRecipe!));
    } else {
      _syncBeanText();
      _syncTastingFromSelectedIds();
      _applyTemplate('v60_3pour', updateMeta: false);
    }
    _coffeeController.addListener(_onParamChanged);
    _waterController.addListener(_onParamChanged);
    _iceController.addListener(_onParamChanged);
  }

  void _syncBeanText() {
    if (!_customBeanManual) {
      _beanController.text = '$_selectedBeanName ($_selectedVariety • $_selectedProcess • $_selectedRoast)';
    }
  }

  void _syncGrindText() {
    final unit = _selectedGrinder.isElectric ? 'Setting' : 'Klik';
    _grindController.text =
        '$_selectedGrindPreset ($_currentClicks $unit ${_selectedGrinder.name} • ${_selectedGrinder.estimateMicrons(_currentClicks)})';
  }

  void _syncTastingFromSelectedIds() {
    if (_selectedNoteLabels.isNotEmpty) {
      _tastingController.text = _selectedNoteLabels.join(', ');
    }
  }

  void _populateFromInitial(Map<String, dynamic> r) {
    _titleController.text = '${r['title']} (Custom)';
    _beanController.text = (r['beanName'] ?? '').toString();
    _methodController.text = (r['method'] ?? 'Hario V60 02').toString();
    _grindController.text = (r['grindSize'] ?? 'Medium').toString();
    _tempController.text = (r['waterTempCelsius'] ?? 92).toString();
    _coffeeController.text = (r['coffeeWeightGrams'] ?? 15).toString();
    _waterController.text = (r['totalWaterWeightGrams'] ?? 225).toString();
    _iceController.text = (r['iceWeightGrams'] ?? 0).toString();
    _tastingController.text = (r['tastingNotes'] ?? '').toString();
    _descController.text = (r['description'] ?? '').toString();
    var cat = (r['category'] ?? 'V60').toString();
    if (cat == 'V60 Pour Over') cat = 'V60';
    if (cat == 'Japanese Iced') cat = 'Japanese';
    if (_categories.any((c) => c['label'] == cat)) {
      _selectedCategory = cat;
    }
    _clearSteps();
    final rawSteps = r['steps'] as List<dynamic>? ?? [];
    for (final s in rawSteps) {
      if (s is Map) {
        final d = _StepDraft(
          title: (s['title'] ?? 'Pour').toString(),
          duration: (s['durationSeconds'] ?? s['timeSeconds'] ?? 30).toString(),
          water: (s['waterAddedGrams'] ?? s['waterGrams'] ?? 0).toString(),
          instruction: (s['instruction'] ?? '').toString(),
        );
        _attachStepListeners(d);
        _steps.add(d);
      }
    }
    if (_steps.isEmpty) {
      _applyTemplate('v60_3pour', updateMeta: false);
    }
  }

  Future<void> _loadAuthorName() async {
    final name = await ProfileService.getUserName();
    if (!mounted) return;
    if (_authorController.text.trim().isEmpty) {
      setState(() {
        _authorController.text = '$name 🇮🇩';
      });
    }
  }

  void _onParamChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _coffeeController.removeListener(_onParamChanged);
    _waterController.removeListener(_onParamChanged);
    _iceController.removeListener(_onParamChanged);
    _titleController.dispose();
    _authorController.dispose();
    _beanController.dispose();
    _methodController.dispose();
    _grindController.dispose();
    _tempController.dispose();
    _coffeeController.dispose();
    _waterController.dispose();
    _iceController.dispose();
    _tastingController.dispose();
    _descController.dispose();
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  void _attachStepListeners(_StepDraft draft) {
    draft.waterCtrl.addListener(() {
      if (_autoSyncWater && mounted) {
        final sum = _sumStepWater();
        if (sum > 0) {
          _waterController.text = sum.toString();
        }
      }
      if (mounted) setState(() {});
    });
    draft.durationCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  int _sumStepWater() {
    int total = 0;
    for (final s in _steps) {
      total += int.tryParse(s.waterCtrl.text.trim()) ?? 0;
    }
    return total;
  }

  int _sumStepDuration() {
    int total = 0;
    for (final s in _steps) {
      total += int.tryParse(s.durationCtrl.text.trim()) ?? 0;
    }
    return total;
  }

  void _clearSteps() {
    for (final s in _steps) {
      s.dispose();
    }
    _steps.clear();
  }

  void _addStep() {
    final prevWater = _steps.isEmpty ? 50 : 60;
    final draft = _StepDraft(
      title: 'Tuangan ${_steps.length + 1}',
      duration: '35',
      water: prevWater.toString(),
      instruction: 'Tuang melingkar secara perlahan dan jaga debit aliran stabil.',
    );
    _attachStepListeners(draft);
    setState(() {
      _steps.add(draft);
      if (_autoSyncWater) {
        _waterController.text = _sumStepWater().toString();
      }
    });
  }

  void _removeStep(int index) {
    if (_steps.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep minimal harus memiliki 1 step seduh!')),
      );
      return;
    }
    setState(() {
      final removed = _steps.removeAt(index);
      removed.dispose();
      if (_autoSyncWater) {
        _waterController.text = _sumStepWater().toString();
      }
    });
  }

  void _applyTemplate(String key, {bool updateMeta = true}) {
    _clearSteps();
    switch (key) {
      case 'japanese_iced':
        if (updateMeta) {
          _selectedCategory = 'Japanese';
          _methodController.text = 'Hario V60 02 + Es di Server';
          _coffeeController.text = '16';
          _waterController.text = '150';
          _iceController.text = '90';
          _tempController.text = '93';
        }
        _addStepRaw('Bloom Cepat', 35, 45, 'Tuang air 93°C di tengah memutar halus untuk bloom.');
        _addStepRaw('Main Pour 1', 35, 55, 'Tuang spiral perlahan langsung menetes ke es server.');
        _addStepRaw('Concentrated Finish', 35, 50, 'Tuang sisa air konsentrat tinggi, swirl server hingga es larut.');
        break;

      case 'immersion':
        if (updateMeta) {
          _selectedCategory = 'Immersion';
          _methodController.text = 'AeroPress Inverted / Clever Dripper';
          _coffeeController.text = '15';
          _waterController.text = '225';
          _iceController.text = '0';
          _tempController.text = '90';
        }
        _addStepRaw('Tuang Penuh & Aduk', 40, 225, 'Tuang seluruh air 225g sekaligus, aduk 5 putaran perlahan.');
        _addStepRaw('Steep Rendam', 90, 0, 'Biarkan kopi terendam penuh selama 1 menit 30 detik.');
        _addStepRaw('Press / Release', 35, 0, 'Tekan plunger secara konsisten atau letakkan Clever di server.');
        break;

      case 'hybrid_switch':
        if (updateMeta) {
          _selectedCategory = 'Hybrid';
          _methodController.text = 'Hario Switch 02';
          _coffeeController.text = '16';
          _waterController.text = '240';
          _iceController.text = '0';
          _tempController.text = '92';
        }
        _addStepRaw('Open Valve Bloom', 40, 60, 'Klep terbuka: Tuang 60g air perkolasi standar.');
        _addStepRaw('Open Valve Pour 2', 40, 60, 'Klep masih terbuka: Tuang 60g kedua untuk mengejar acidity.');
        _addStepRaw('Close Valve Steep', 60, 120, 'Tutup klep: Tuang 120g air sisa dan biarkan terendam 1 menit.');
        _addStepRaw('Release Drain', 30, 0, 'Buka klep Switch untuk pengurasan cairan manis dan bersih.');
        break;

      case 'v60_3pour':
      default:
        if (updateMeta) {
          _selectedCategory = 'V60';
          _methodController.text = 'Hario V60 02';
          _coffeeController.text = '15';
          _waterController.text = '225';
          _iceController.text = '0';
          _tempController.text = '92';
        }
        _addStepRaw('Bloom', 40, 50, 'Tuang 50g melingkar basahi seluruh bubuk kopi, swirl 1x.');
        _addStepRaw('Second Pour', 40, 85, 'Tuang spiral perlahan dari tengah keluar hingga 135g.');
        _addStepRaw('Final Pour & Drawdown', 40, 90, 'Tuang sisa 90g di tengah dengan debit lembut hingga total 225g.');
        break;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _addStepRaw(String title, int duration, int water, String instruction) {
    final d = _StepDraft(
      title: title,
      duration: duration.toString(),
      water: water.toString(),
      instruction: instruction,
    );
    _attachStepListeners(d);
    _steps.add(d);
  }

  // ==========================================
  // MODAL: ADVANCED BEAN PICKER & CUSTOMIZER
  // ==========================================
  void _showBeanSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String searchQuery = '';
        String selectedOriginFilter = 'Semua';
        int visibleCount = 10; // Tampilan awal 10 kopi (2x5)

        String tempBeanName = _selectedBeanName;
        String tempVariety = _selectedVariety;
        String tempRoast = _selectedRoast;
        String tempProcess = _selectedProcess;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredBeans = BrewVisualCatalog.beans.where((b) {
              final matchesQuery = b.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  b.region.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  b.defaultVariety.toLowerCase().contains(searchQuery.toLowerCase());
              if (!matchesQuery) return false;

              if (selectedOriginFilter == 'Sumatra 🇮🇩' || selectedOriginFilter == 'Sumatra') {
                return b.region.toLowerCase().contains('sumatra') ||
                    b.region.toLowerCase().contains('aceh') ||
                    b.region.toLowerCase().contains('bengkulu') ||
                    b.region.toLowerCase().contains('lampung');
              } else if (selectedOriginFilter == 'Jawa 🇮🇩' || selectedOriginFilter == 'Jawa') {
                return b.region.toLowerCase().contains('jawa') ||
                    b.region.toLowerCase().contains('garut') ||
                    b.region.toLowerCase().contains('bandung');
              } else if (selectedOriginFilter == 'Bali & Nusra 🇮🇩' || selectedOriginFilter == 'Bali & Nusra') {
                return b.region.toLowerCase().contains('bali') ||
                    b.region.toLowerCase().contains('ntt') ||
                    b.region.toLowerCase().contains('ntb') ||
                    b.region.toLowerCase().contains('lombok') ||
                    b.region.toLowerCase().contains('flores');
              } else if (selectedOriginFilter == 'Sulawesi 🇮🇩' || selectedOriginFilter == 'Sulawesi') {
                return b.region.toLowerCase().contains('sulawesi') ||
                    b.region.toLowerCase().contains('toraja') ||
                    b.region.toLowerCase().contains('enrekang');
              } else if (selectedOriginFilter == 'Papua 🇮🇩' || selectedOriginFilter == 'Papua') {
                return b.region.toLowerCase().contains('papua') ||
                    b.region.toLowerCase().contains('wamena');
              } else if (selectedOriginFilter == 'Internasional 🌍' || selectedOriginFilter == 'Internasional') {
                return !b.region.contains('🇮🇩');
              }
              return true;
            }).toList();

            final displayedBeans = filteredBeans.take(visibleCount).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Biji Kopi Nusantara & Dunia',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Origin terlengkap tanpa proses di nama (pilih proses di bawah)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search Bar + Filter Otomatis
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari kopi (Kamojang, Puntang, Gayo, Halu...)',
                              prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: AppTheme.primaryBrown),
                              filled: true,
                              fillColor: AppTheme.bgCream.withValues(alpha: 0.6),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                searchQuery = val;
                                visibleCount = 10;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Tombol Filter Otomatis di samping search
                        PopupMenuButton<String>(
                          tooltip: 'Filter Otomatis Wilayah',
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          icon: Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: selectedOriginFilter != 'Semua'
                                  ? AppTheme.primaryBrown
                                  : AppTheme.primaryBrown.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              CupertinoIcons.slider_horizontal_3,
                              color: selectedOriginFilter != 'Semua' ? Colors.white : AppTheme.primaryBrown,
                              size: 19,
                            ),
                          ),
                          onSelected: (val) {
                            setModalState(() {
                              selectedOriginFilter = val;
                              visibleCount = 10;
                            });
                          },
                          itemBuilder: (context) => [
                            'Semua',
                            'Jawa 🇮🇩',
                            'Sumatra 🇮🇩',
                            'Bali & Nusra 🇮🇩',
                            'Sulawesi 🇮🇩',
                            'Papua 🇮🇩',
                            'Internasional 🌍',
                          ].map((f) {
                            return PopupMenuItem(
                              value: f,
                              child: Row(
                                children: [
                                  if (selectedOriginFilter == f)
                                    const Icon(CupertinoIcons.checkmark, size: 16, color: AppTheme.primaryBrown)
                                  else
                                    const SizedBox(width: 16),
                                  const SizedBox(width: 8),
                                  Text(f, style: TextStyle(fontWeight: selectedOriginFilter == f ? FontWeight.bold : FontWeight.normal)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Horizontal Quick Region Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: ['Semua', 'Jawa 🇮🇩', 'Sumatra 🇮🇩', 'Bali & Nusra 🇮🇩', 'Sulawesi 🇮🇩', 'Papua 🇮🇩', 'Internasional 🌍'].map((reg) {
                        final isSel = selectedOriginFilter == reg;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(reg, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            selected: isSel,
                            selectedColor: AppTheme.primaryBrown,
                            labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textDark),
                            backgroundColor: AppTheme.bgCream,
                            onSelected: (_) {
                              setModalState(() {
                                selectedOriginFilter = reg;
                                visibleCount = 10;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 14),

                  // SCROLLABLE BODY (2-GRID COFFEE + MORE BUTTON + CUSTOMIZATION PANEL)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menampilkan ${displayedBeans.length} dari ${filteredBeans.length} Kopi',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                            ),
                            if (selectedOriginFilter != 'Semua')
                              TextButton(
                                onPressed: () => setModalState(() {
                                  selectedOriginFilter = 'Semua';
                                  visibleCount = 10;
                                }),
                                child: const Text('Reset Filter', style: TextStyle(fontSize: 11, color: AppTheme.primaryBrown)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 2-GRID CARD LAYOUT
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.88,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: displayedBeans.length,
                          itemBuilder: (context, index) {
                            final bean = displayedBeans[index];
                            final isSelected = tempBeanName == bean.name;

                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  tempBeanName = bean.name;
                                  tempVariety = bean.defaultVariety;
                                  tempProcess = bean.process;
                                  tempRoast = bean.roast;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: isSelected ? bean.color.withValues(alpha: 0.12) : AppTheme.surfaceWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? bean.color : Colors.grey.shade300,
                                    width: isSelected ? 2.2 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: bean.color.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(bean.emoji, style: const TextStyle(fontSize: 22)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      bean.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? bean.color : AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      bean.region,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.bgCream,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        bean.defaultVariety,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? bean.color : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // TOMBOL MORE / TAMPILKAN LEBIH BANYAK (2x5 -> 2x10 -> 2x15...)
                        if (filteredBeans.length > visibleCount) ...[
                          const SizedBox(height: 14),
                          Center(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBrown,
                                side: const BorderSide(color: AppTheme.primaryBrown, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              ),
                              icon: const Icon(CupertinoIcons.chevron_down_circle_fill, size: 18),
                              label: Text(
                                'Tampilkan Lebih Banyak ($visibleCount / ${filteredBeans.length})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  visibleCount += 10;
                                });
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // CUSTOMIZATION PANEL (VARIETAS, ROAST, PROSES DI BAWAHNYA)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCream,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Kustomisasi Profil Biji Terpilih:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBrown,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // VARIETAS
                              const Text('Varietas Kopi:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                              const SizedBox(height: 6),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: BrewVisualCatalog.varieties.map((v) {
                                    final sel = tempVariety == v;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ChoiceChip(
                                        label: Text(v, style: const TextStyle(fontSize: 11)),
                                        selected: sel,
                                        selectedColor: AppTheme.accentAmber,
                                        labelStyle: TextStyle(color: sel ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.w600),
                                        onSelected: (_) => setModalState(() => tempVariety = v),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // ROAST LEVEL
                              const Text('Tingkat Roasting (Roast Level):', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: BrewVisualCatalog.roastLevels.map((r) {
                                  final sel = tempRoast == r;
                                  Color roastColor = const Color(0xFFD7CCC8);
                                  if (r == 'Light') roastColor = const Color(0xFFD7CCC8);
                                  if (r == 'Light-Medium') roastColor = const Color(0xFFBCAAA4);
                                  if (r == 'Medium') roastColor = const Color(0xFF8D6E63);
                                  if (r == 'Medium-Dark') roastColor = const Color(0xFF5D4037);
                                  if (r == 'Dark') roastColor = const Color(0xFF3E2723);

                                  return ChoiceChip(
                                    avatar: CircleAvatar(radius: 5, backgroundColor: roastColor),
                                    label: Text(r, style: const TextStyle(fontSize: 11)),
                                    selected: sel,
                                    selectedColor: AppTheme.primaryBrown,
                                    labelStyle: TextStyle(color: sel ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.w600),
                                    onSelected: (_) => setModalState(() => tempRoast = r),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // PROCESS
                              const Text('Proses Pasca-Panen (Process):', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                              const SizedBox(height: 6),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: BrewVisualCatalog.processes.map((p) {
                                    final sel = tempProcess == p;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ChoiceChip(
                                        label: Text(p, style: const TextStyle(fontSize: 11)),
                                        selected: sel,
                                        selectedColor: AppTheme.primaryBrown,
                                        labelStyle: TextStyle(color: sel ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.w600),
                                        onSelected: (_) => setModalState(() => tempProcess = p),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(CupertinoIcons.checkmark_alt, color: Colors.white),
                      label: Text(
                        'Gunakan Biji: $tempBeanName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          _customBeanManual = false;
                          _selectedBeanName = tempBeanName;
                          _selectedVariety = tempVariety;
                          _selectedRoast = tempRoast;
                          _selectedProcess = tempProcess;
                          _syncBeanText();
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // MODAL: ADVANCED TASTING NOTES PICKER
  // ==========================================
  void _showTastingNotesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String searchQuery = '';
        String selectedGroupFilter = '🍑 Fruity (Tropical & Stone)';
        final Set<String> tempSelected = Set.from(_selectedNoteLabels);

        final groups = [
          '🍑 Fruity (Tropical & Stone)',
          '🍎 Orchard Fruit',
          '🍓 Berry',
          '🍋 Citrus',
          '🌸 Floral',
          '🍯 Sweet',
          '🍫 Cocoa',
          '🥜 Nutty',
          '🪵 Spices & Herbal',
          '🍷 Winey & Ferment',
          '🍵 Tea-like',
          '✨ Mouthfeel',
        ];

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredNotes = BrewVisualCatalog.flavorNotes.where((note) {
              final matchesQuery = searchQuery.isEmpty ||
                  note.label.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  note.group.toLowerCase().contains(searchQuery.toLowerCase());
              if (!matchesQuery) return false;
              if (selectedGroupFilter.contains('Fruity')) {
                return note.group == 'Stone Fruit' || note.group == 'Tropical';
              }
              if (selectedGroupFilter.contains('Orchard')) {
                return note.group == 'Orchard Fruit';
              }
              if (selectedGroupFilter.contains('Spices')) {
                return note.group == 'Herbal';
              }
              if (selectedGroupFilter.contains('Winey')) {
                return note.group == 'Winey';
              }
              if (selectedGroupFilter.contains('Tea')) {
                return note.group == 'Tea-like';
              }
              if (selectedGroupFilter.contains('Mouthfeel')) {
                return note.group == 'Mouthfeel';
              }
              final cleanGrp = selectedGroupFilter.replaceAll(RegExp(r'[^\w\s]'), '').trim().toLowerCase();
              return note.group.toLowerCase().contains(cleanGrp);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.86,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Tasting Notes Lengkap',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pilih aroma & rasa (bisa lebih dari satu)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari notes (misal: jasmine, citrus, berry...)',
                        prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: AppTheme.primaryBrown),
                        filled: true,
                        fillColor: AppTheme.bgCream.withValues(alpha: 0.6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Group Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: groups.map((grp) {
                        final isSel = selectedGroupFilter == grp;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(grp, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            selected: isSel,
                            selectedColor: AppTheme.primaryBrown,
                            labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textDark),
                            backgroundColor: AppTheme.bgCream,
                            onSelected: (_) {
                              setModalState(() {
                                selectedGroupFilter = grp;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 16),

                  // Notes Grid / Wrap
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: filteredNotes.map((note) {
                          final isSelected = tempSelected.contains(note.label);
                          return FlavorNoteVisualBadge(
                            noteText: note.label,
                            selected: isSelected,
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  tempSelected.remove(note.label);
                                } else {
                                  tempSelected.add(note.label);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Floating Bottom Confirmation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSelected.clear();
                            });
                          },
                          child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBrown,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedNoteLabels.clear();
                                _selectedNoteLabels.addAll(tempSelected);
                                _syncTastingFromSelectedIds();
                              });
                              Navigator.pop(ctx);
                            },
                            child: Text(
                              'Terapkan (${tempSelected.length} Notes)',
                              style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // MODAL: ADVANCED 2-GRID GRINDER PICKER
  // ==========================================
  void _showGrinderPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String searchQuery = '';
        String typeFilter = 'Semua';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredGrinders = BrewVisualCatalog.grinderModels.where((g) {
              final matchesQuery = g.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  g.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  g.typeDescription.toLowerCase().contains(searchQuery.toLowerCase());
              if (!matchesQuery) return false;
              if (typeFilter == 'Hand Grinder') {
                return !g.isElectric;
              } else if (typeFilter == 'Electric') {
                return g.isElectric;
              }
              return true;
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Grinder Kopi',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '18 Grinder populer dunia & favorit barista Indonesia',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari grinder (Comandante, Timemore, DF64, Latina...)',
                        prefixIcon: const Icon(CupertinoIcons.search, size: 18, color: AppTheme.primaryBrown),
                        filled: true,
                        fillColor: AppTheme.bgCream.withValues(alpha: 0.6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: ['Semua', 'Hand Grinder', 'Electric'].map((t) {
                        final isSel = typeFilter == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(t, style: TextStyle(fontSize: 11.5, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            selected: isSel,
                            selectedColor: AppTheme.primaryBrown,
                            labelStyle: TextStyle(color: isSel ? Colors.white : AppTheme.textDark),
                            backgroundColor: AppTheme.bgCream,
                            onSelected: (_) => setModalState(() => typeFilter = t),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 16),

                  // 2-GRID CARD LAYOUT
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.74,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredGrinders.length,
                      itemBuilder: (context, index) {
                        final g = filteredGrinders[index];
                        final isSelected = _selectedGrinder.id == g.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedGrinder = g;
                              _currentClicks = g.getClicksForPreset(_selectedGrindPreset);
                              _syncGrindText();
                            });
                            Navigator.pop(ctx);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryBrown.withValues(alpha: 0.08)
                                  : AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryBrown : Colors.grey.shade300,
                                width: isSelected ? 2.2 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Image with badge
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            g.imagePath,
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: g.isElectric ? AppTheme.accentAmber : AppTheme.primaryBrown,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            g.isElectric ? 'ELEKTRIK' : 'MANUAL',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: AppTheme.primaryBrown,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(CupertinoIcons.checkmark, size: 12, color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Grinder Name
                                Text(
                                  g.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppTheme.primaryBrown : AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),

                                // Burr / Subtitle
                                Text(
                                  g.typeDescription,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
                                ),
                                const SizedBox(height: 4),

                                // Clicks range pill
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryBrown.withValues(alpha: 0.14)
                                        : AppTheme.bgCream,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${g.minClicks} - ${g.maxClicks} Klik',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppTheme.primaryBrown : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // HELPER STEPPER WIDGET (+ / -)
  // ==========================================
  Widget _buildParamStepper({
    required String title,
    required String unit,
    required double value,
    required double min,
    required double max,
    required double step,
    required IconData icon,
    required Function(double newVal) onChanged,
    String? subtitle,
  }) {
    final displayValue = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCream.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryBrown),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(
                  '($subtitle)',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minus button
              Material(
                color: value > min ? AppTheme.primaryBrown : Colors.grey.shade400,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: value > min
                      ? () {
                          final next = (value - step).clamp(min, max);
                          onChanged(double.parse(next.toStringAsFixed(1)));
                        }
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(CupertinoIcons.minus, color: Colors.white, size: 16),
                  ),
                ),
              ),

              // Value display
              Column(
                children: [
                  Text(
                    '$displayValue $unit',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ],
              ),

              // Plus button
              Material(
                color: value < max ? AppTheme.primaryBrown : Colors.grey.shade400,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: value < max
                      ? () {
                          final next = (value + step).clamp(min, max);
                          onChanged(double.parse(next.toStringAsFixed(1)));
                        }
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(CupertinoIcons.plus, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 step seduh!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      int totalTime = 0;
      int cumulativeWater = 0;
      final List<Map<String, dynamic>> parsedSteps = [];

      for (int i = 0; i < _steps.length; i++) {
        final s = _steps[i];
        final time = (int.tryParse(s.durationCtrl.text.trim()) ?? 30).clamp(1, 3600);
        final water = (int.tryParse(s.waterCtrl.text.trim()) ?? 0).clamp(0, 5000);
        totalTime += time;
        cumulativeWater += water;

        final rawTitle = s.titleCtrl.text.trim();
        final stepTitle = rawTitle.isEmpty ? 'Step ${i + 1}' : rawTitle;
        final rawInstruction = s.instructionCtrl.text.trim();
        final instruction = rawInstruction.isNotEmpty
            ? rawInstruction
            : (water > 0
                ? 'Tuang ${water}g air secara merata hingga mencapai ${cumulativeWater}g dalam ${time}s.'
                : 'Biarkan fase imersi / pengurasan (drawdown) berlangsung selama ${time}s.');

        parsedSteps.add({
          'stepOrder': i + 1,
          'title': stepTitle,
          'durationSeconds': time,
          'waterAddedGrams': water,
          'timeSeconds': time,
          'waterGrams': water,
          'cumulativeWaterGrams': cumulativeWater,
          'instruction': instruction,
        });
      }

      final coffeeGrams = (num.tryParse(_coffeeController.text.trim()) ?? 15).clamp(1, 500);
      final inputWater = int.tryParse(_waterController.text.trim()) ?? 0;
      final totalWaterGrams = inputWater > 0 ? inputWater : (cumulativeWater > 0 ? cumulativeWater : 225);
      final iceGrams = _isIcedMethod ? (int.tryParse(_iceController.text.trim()) ?? 90).clamp(0, 2000) : 0;
      final tempCelsius = (int.tryParse(_tempController.text.trim()) ?? 92).clamp(40, 100);

      final titleText = _titleController.text.trim().isEmpty
          ? 'Resep $_selectedCategory Saya'
          : _titleController.text.trim();
      final authorText = _authorController.text.trim().isEmpty
          ? 'Barista 🇮🇩'
          : _authorController.text.trim();
      final beanText = _beanController.text.trim().isEmpty
          ? 'Arabika Nusantara Single Origin'
          : _beanController.text.trim();
      final methodText = _methodController.text.trim().isEmpty
          ? _selectedCategory
          : _methodController.text.trim();
      final grindText = _grindController.text.trim().isEmpty
          ? 'Medium (23 Klik Comandante C40)'
          : _grindController.text.trim();
      final tastingText = _tastingController.text.trim().isEmpty
          ? 'Sweet, Balanced, Clean Finish'
          : _tastingController.text.trim();
      final descText = _descController.text.trim().isEmpty
          ? 'Resep seduh $_selectedCategory menggunakan alat $methodText dengan suhu $tempCelsius°C dan gilingan $grindText.'
          : _descController.text.trim();

      // Gunakan avatar user yang sedang aktif untuk resep buatannya sendiri
      final userAvatar = await ProfileService.getUserImagePath();

      final Map<String, dynamic> payload = {
        'title': titleText,
        'author': authorText,
        'coverImageUrl': userAvatar,
        'authorAvatarUrl': userAvatar,
        'authorImageUrl': userAvatar,
        'beanName': beanText,
        'grindSize': grindText,
        'method': methodText,
        'category': _selectedCategory,
        'waterTempCelsius': tempCelsius,
        'coffeeWeightGrams': coffeeGrams,
        'totalWaterWeightGrams': totalWaterGrams,
        'iceWeightGrams': iceGrams,
        'waterPpm': '75 ppm',
        'tastingNotes': tastingText,
        'totalTimeSeconds': totalTime,
        'description': descText,
        'isCustom': true,
        'steps': parsedSteps,
      };

      await ApiService.createRecipe(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil disimpan & siap digunakan!'),
            backgroundColor: AppTheme.primaryBrown,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan resep: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coffee = num.tryParse(_coffeeController.text.trim()) ?? 15;
    final water = int.tryParse(_waterController.text.trim()) ?? _sumStepWater();
    final ice = _isIcedMethod ? (int.tryParse(_iceController.text.trim()) ?? 90) : 0;
    final totalLiquid = water + ice;
    final ratio = coffee > 0 ? (totalLiquid / coffee).toStringAsFixed(1) : '15.0';
    final totalTime = _sumStepDuration();

    int runningWater = 0;

    // 5 Notes terpopuler untuk preview langsung di layar utama
    const popularNotes = [
      'Jasmine',
      'Sweet Orange',
      'White Peach',
      'Caramel & Brown Sugar',
      'Dark Chocolate',
    ];

    // 5 Beans terpopuler untuk preview horizontal di layar utama
    final popularBeans = BrewVisualCatalog.beans.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Buat Resep Brew Baru'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // LIVE SUMMARY BANNER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ringkasan Kalkulasi Resep',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedCategory,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryStat('Kopi', '${coffee}g'),
                      _summaryStat('Air Panas', '${water}g'),
                      if (_isIcedMethod) _summaryStat('Es Batu', '${ice}g'),
                      _summaryStat('Rasio', '1:$ratio'),
                      _summaryStat('Durasi', _formatTime(totalTime)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QUICK TEMPLATES
            _buildSectionTitle('1. Gunakan Template Cepat (Opsional)'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _templateChip('V60 3-Pour', CupertinoIcons.drop_fill, () => _applyTemplate('v60_3pour')),
                  const SizedBox(width: 8),
                  _templateChip('Japanese Iced (Es)', CupertinoIcons.snow, () => _applyTemplate('japanese_iced')),
                  const SizedBox(width: 8),
                  _templateChip('Full Immersion', CupertinoIcons.timer_fill, () => _applyTemplate('immersion')),
                  const SizedBox(width: 8),
                  _templateChip('Hybrid Switch', CupertinoIcons.lab_flask_solid, () => _applyTemplate('hybrid_switch')),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // CATEGORY & VISUAL DRIPPER PICKER
            _buildSectionTitle('2. Pilih Alat Dripper & Metode Seduh'),
            const Text(
              'Tap gambar alat seduh di bawah tanpa perlu ketik manual (atau pilih Lainnya):',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 112,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...BrewVisualCatalog.drippers.map((d) {
                    final selected = !_customDripperManual && _selectedDripperName == d.name;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _customDripperManual = false;
                          _selectedDripperName = d.name;
                          _selectedCategory = d.defaultCategory;
                          _methodController.text = d.name;
                          if (d.defaultCategory == 'Japanese' || d.defaultCategory == 'Japanese Iced') {
                            _iceController.text = '90';
                          } else {
                            _iceController.text = '0';
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 108,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selected ? d.color.withValues(alpha: 0.14) : AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? d.color : Colors.grey.shade300,
                            width: selected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DripperGraphicBadge(item: d, size: 42),
                            const SizedBox(height: 6),
                            Text(
                              d.shortName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                                color: selected ? d.color : AppTheme.textDark,
                              ),
                            ),
                            Text(
                              d.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _customDripperManual = true;
                      });
                    },
                    child: Container(
                      width: 108,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _customDripperManual
                            ? AppTheme.primaryBrown.withValues(alpha: 0.14)
                            : AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _customDripperManual ? AppTheme.primaryBrown : Colors.grey.shade300,
                          width: _customDripperManual ? 2.0 : 1.0,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.bgCream,
                            child: Icon(CupertinoIcons.pencil, color: AppTheme.primaryBrown, size: 20),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Lainnya',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                          ),
                          Text(
                            'Ketik Manual',
                            style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_customDripperManual) ...[
              const SizedBox(height: 12),
              _buildTextField(
                _methodController,
                'Ketik Nama Alat Dripper Manual',
                CupertinoIcons.wrench_fill,
                isRequired: false,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final label = cat['label'] as String;
                final icon = cat['icon'] as IconData;
                final isSelected = _selectedCategory == label;
                return ChoiceChip(
                  avatar: Icon(icon, size: 15, color: isSelected ? Colors.white : AppTheme.primaryBrown),
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryBrown,
                  backgroundColor: AppTheme.surfaceWhite,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = label;
                      if (label == 'Japanese' || label == 'Japanese Iced') {
                        _iceController.text = '90';
                      } else {
                        _iceController.text = '0';
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // SECTION 3: BEAN & TASTING NOTES
            _buildSectionTitle('3. Biji Kopi, Varietas & Tasting Notes'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    _titleController,
                    'Judul Resep (contoh: Sweet Floral V60 Ryan)',
                    CupertinoIcons.tag_fill,
                  ),
                  _buildTextField(
                    _authorController,
                    'Nama Pembuat Resep (Barista)',
                    CupertinoIcons.person_fill,
                  ),
                  const Divider(height: 20),

                  // BEAN SELECTION HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Biji Kopi / Origin:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      TextButton.icon(
                        onPressed: _showBeanSelectionModal,
                        icon: const Icon(CupertinoIcons.square_grid_2x2_fill, size: 14, color: AppTheme.primaryBrown),
                        label: const Text(
                          'Lihat Semua',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                        ),
                      ),
                    ],
                  ),

                  // TOP 5 BEANS HORIZONTAL
                  SizedBox(
                    height: 98,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...popularBeans.map((bean) {
                          final selected = !_customBeanManual && _selectedBeanName == bean.name;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _customBeanManual = false;
                                _selectedBeanName = bean.name;
                                _selectedVariety = bean.defaultVariety;
                                _selectedProcess = bean.process;
                                _selectedRoast = bean.roast;
                                _syncBeanText();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 154,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: selected ? bean.color.withValues(alpha: 0.12) : AppTheme.bgCream,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected ? bean.color : Colors.grey.shade300,
                                  width: selected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: bean.color.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(bean.emoji, style: const TextStyle(fontSize: 20)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bean.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: selected ? bean.color : AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${bean.process} • ${bean.roast}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: _showBeanSelectionModal,
                          child: Container(
                            width: 130,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCream,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.primaryBrown, width: 1.5),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.sparkles, color: AppTheme.primaryBrown, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  'Semua Biji',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                                ),
                                Text(
                                  'Kustom Varietas',
                                  style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ACTIVE BEAN INFO BANNER
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.info_circle_fill, size: 16, color: AppTheme.primaryBrown),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _beanController.text.isEmpty ? 'Pilih biji di atas' : _beanController.text,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.primaryBrown),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _customBeanManual = !_customBeanManual),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                _customBeanManual ? 'Tutup Edit' : 'Edit Teks',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentAmber),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_customBeanManual) ...[
                    const SizedBox(height: 6),
                    _buildTextField(
                      _beanController,
                      'Ketik Kustom Teks Biji Kopi / Origin',
                      CupertinoIcons.pencil,
                      isRequired: false,
                    ),
                  ],

                  const Divider(height: 22),

                  // TASTING NOTES HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pilih Tasting Notes:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      TextButton.icon(
                        onPressed: _showTastingNotesModal,
                        icon: const Icon(CupertinoIcons.sparkles, size: 14, color: AppTheme.primaryBrown),
                        label: Text(
                          'Lihat Semua',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                        ),
                      ),
                    ],
                  ),

                  // 5 POPULAR NOTES + CURRENTLY SELECTED NOTES
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...popularNotes.map((label) {
                        final isSelected = _selectedNoteLabels.contains(label);
                        return FlavorNoteVisualBadge(
                          noteText: label,
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedNoteLabels.remove(label);
                              } else {
                                _selectedNoteLabels.add(label);
                              }
                              _syncTastingFromSelectedIds();
                            });
                          },
                        );
                      }),
                      ..._selectedNoteLabels
                          .where((l) => !popularNotes.contains(l))
                          .map((label) {
                        return FlavorNoteVisualBadge(
                          noteText: label,
                          selected: true,
                          onTap: () {
                            setState(() {
                              _selectedNoteLabels.remove(label);
                              _syncTastingFromSelectedIds();
                            });
                          },
                        );
                      }),
                      GestureDetector(
                        onTap: _showTastingNotesModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.primaryBrown, width: 1.2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.plus_circle_fill, size: 14, color: AppTheme.primaryBrown),
                              SizedBox(width: 4),
                              Text(
                                'More Notes...',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_selectedNoteLabels.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Ringkasan Notes: ${_tastingController.text}',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // SECTION 4: TECHNICAL PARAMETERS & STEPPER BUTTONS
            _buildSectionTitle('4. Parameter Teknis Seduh (+ / -)'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildParamStepper(
                          title: 'Kopi',
                          unit: 'g',
                          icon: CupertinoIcons.cube_box,
                          value: double.tryParse(_coffeeController.text.trim()) ?? 15.0,
                          min: 5.0,
                          max: 60.0,
                          step: 0.5,
                          onChanged: (val) {
                            setState(() {
                              _coffeeController.text = val % 1 == 0 ? val.toInt().toString() : val.toString();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildParamStepper(
                          title: 'Suhu Air',
                          unit: '°C',
                          icon: CupertinoIcons.thermometer,
                          value: double.tryParse(_tempController.text.trim()) ?? 92.0,
                          min: 50.0,
                          max: 100.0,
                          step: 1.0,
                          onChanged: (val) {
                            setState(() {
                              _tempController.text = val.toInt().toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildParamStepper(
                          title: 'Air Panas',
                          unit: 'g',
                          icon: CupertinoIcons.drop,
                          value: double.tryParse(_waterController.text.trim()) ?? 225.0,
                          min: 50.0,
                          max: 1000.0,
                          step: 5.0,
                          onChanged: (val) {
                            setState(() {
                              _waterController.text = val.toInt().toString();
                            });
                          },
                        ),
                      ),
                      if (_isIcedMethod) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildParamStepper(
                            title: 'Es Batu',
                            unit: 'g',
                            subtitle: 'di Server',
                            icon: CupertinoIcons.snow,
                            value: double.tryParse(_iceController.text.trim()) ?? 90.0,
                            min: 10.0,
                            max: 500.0,
                            step: 5.0,
                            onChanged: (val) {
                              setState(() {
                                _iceController.text = val.toInt().toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_isIcedMethod)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '❄️ Flash Brew Aktif: Es batu langsung di dalam server untuk mendinginkan ekstraksi.',
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.blue.shade700),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // SECTION 5: GRINDER SELECTOR & CLICKS
            _buildSectionTitle('5. Pemilihan Grinder & Ukuran Gilingan'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grinder yang Digunakan:',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),

                  // VISUAL SELECTED GRINDER CARD
                  GestureDetector(
                    onTap: _showGrinderPickerModal,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCream.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              _selectedGrinder.imagePath,
                              width: 58,
                              height: 58,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: _selectedGrinder.isElectric ? AppTheme.accentAmber : AppTheme.primaryBrown,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _selectedGrinder.isElectric ? 'ELEKTRIK' : 'MANUAL',
                                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_selectedGrinder.minClicks} - ${_selectedGrinder.maxClicks} Klik',
                                      style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedGrinder.name,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                                Text(
                                  _selectedGrinder.typeDescription,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBrown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(CupertinoIcons.square_grid_2x2, size: 14),
                            label: const Text('Pilih', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: _showGrinderPickerModal,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Presets
                  const Text(
                    'Preset Kehalusan:',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _grindPresets.map((g) {
                      final label = g['label']!;
                      final selected = _selectedGrindPreset == label;
                      return ChoiceChip(
                        label: Text(label, style: const TextStyle(fontSize: 11)),
                        selected: selected,
                        selectedColor: AppTheme.accentAmber,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedGrindPreset = label;
                            _currentClicks = _selectedGrinder.getClicksForPreset(label);
                            _syncGrindText();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // INTERACTIVE STEPPER & CLICK DISPLAY
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCream.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Minus Button
                            Material(
                              color: _currentClicks > _selectedGrinder.minClicks
                                  ? AppTheme.primaryBrown
                                  : Colors.grey.shade400,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _currentClicks > _selectedGrinder.minClicks
                                    ? () {
                                        setState(() {
                                          _currentClicks--;
                                          _syncGrindText();
                                        });
                                      }
                                    : null,
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(CupertinoIcons.minus, color: Colors.white, size: 20),
                                ),
                              ),
                            ),

                            // Center Info
                            Column(
                              children: [
                                Text(
                                  '$_currentClicks Klik',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBrown,
                                  ),
                                ),
                                Text(
                                  '${_selectedGrinder.estimateMicrons(_currentClicks)} • $_selectedGrindPreset',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                                ),
                                Text(
                                  _selectedGrinder.name,
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                                ),
                              ],
                            ),

                            // Plus Button
                            Material(
                              color: _currentClicks < _selectedGrinder.maxClicks
                                  ? AppTheme.primaryBrown
                                  : Colors.grey.shade400,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _currentClicks < _selectedGrinder.maxClicks
                                    ? () {
                                        setState(() {
                                          _currentClicks++;
                                          _syncGrindText();
                                        });
                                      }
                                    : null,
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(CupertinoIcons.plus, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Continuous Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.primaryBrown,
                            inactiveTrackColor: Colors.grey.shade300,
                            thumbColor: AppTheme.accentAmber,
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _currentClicks.toDouble().clamp(
                                  _selectedGrinder.minClicks.toDouble(),
                                  _selectedGrinder.maxClicks.toDouble(),
                                ),
                            min: _selectedGrinder.minClicks.toDouble(),
                            max: _selectedGrinder.maxClicks.toDouble(),
                            divisions: _selectedGrinder.maxClicks - _selectedGrinder.minClicks,
                            onChanged: (val) {
                              setState(() {
                                _currentClicks = val.round();
                                _syncGrindText();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  _buildTextField(
                    _descController,
                    'Catatan Filosofi & Teknik Seduh (Opsional)',
                    CupertinoIcons.text_quote,
                    maxLines: 2,
                    isRequired: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // SECTION 6: BREWING STEPS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('6. Tahapan Tuangan (Steps)'),
                TextButton.icon(
                  onPressed: _addStep,
                  icon: const Icon(CupertinoIcons.add_circled_solid, color: AppTheme.primaryBrown),
                  label: const Text(
                    'Tambah Step',
                    style: TextStyle(color: AppTheme.primaryBrown, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Checkbox(
                    value: _autoSyncWater,
                    activeColor: AppTheme.primaryBrown,
                    onChanged: (v) {
                      setState(() {
                        _autoSyncWater = v ?? true;
                        if (_autoSyncWater) {
                          final sum = _sumStepWater();
                          if (sum > 0) _waterController.text = sum.toString();
                        }
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Otomatis jumlahkan air step ke total air',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),

            ...List.generate(_steps.length, (index) {
              final step = _steps[index];
              final stepWater = int.tryParse(step.waterCtrl.text.trim()) ?? 0;
              runningWater += stepWater;
              final currentTarget = runningWater;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryBrown,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              step.titleCtrl.text.isEmpty ? 'Tuangan ${index + 1}' : step.titleCtrl.text,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (stepWater > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Target: ${currentTarget}g',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBrown,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 18),
                              onPressed: () => _removeStep(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      step.titleCtrl,
                      'Nama Tuangan (contoh: Bloom, Second Pour)',
                      CupertinoIcons.pen,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            step.waterCtrl,
                            'Air Ditambah (+g)',
                            CupertinoIcons.drop_fill,
                            isNumber: true,
                            allowZero: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            step.durationCtrl,
                            'Durasi (detik)',
                            CupertinoIcons.timer,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      step.instructionCtrl,
                      'Instruksi Teknik (contoh: Tuang spiral lalu swirl 2x)',
                      CupertinoIcons.info_circle,
                      isRequired: false,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox.shrink()
                    : const Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.white),
                label: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Resep Saya',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _templateChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 15, color: AppTheme.primaryBrown),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: AppTheme.surfaceWhite,
      side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
      onPressed: onTap,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool allowZero = false,
    bool isRequired = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        maxLines: maxLines,
        validator: (value) {
          final trimmed = value?.trim() ?? '';
          if (!isRequired && trimmed.isEmpty) return null;
          if (trimmed.isEmpty) return 'Wajib diisi';
          if (isNumber) {
            final parsed = num.tryParse(trimmed);
            if (parsed == null) return 'Angka tidak valid';
            if (!allowZero && parsed <= 0) return 'Harus > 0';
            if (allowZero && parsed < 0) return 'Minimal 0';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: AppTheme.primaryBrown),
          filled: true,
          fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
          ),
        ),
      ),
    );
  }
}
