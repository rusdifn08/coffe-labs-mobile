import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/flavor_wheel/data/cupping_constants.dart';
import '../features/flavor_wheel/widgets/bean_catalog_modal.dart';
import '../features/flavor_wheel/widgets/cupping_aftertaste_mouthfeel_section.dart';
import '../features/flavor_wheel/widgets/cupping_app_bar.dart';
import '../features/flavor_wheel/widgets/cupping_coffee_info_section.dart';
import '../features/flavor_wheel/widgets/cupping_flavor_notes_section.dart';
import '../features/flavor_wheel/widgets/cupping_hero_score_card.dart';
import '../features/flavor_wheel/widgets/cupping_notes_section.dart';
import '../features/flavor_wheel/widgets/cupping_sensory_scores_section.dart';
import '../features/flavor_wheel/widgets/variety_picker_modal.dart';
import '../features/flavor_wheel/services/cupping_session_helper.dart';
import '../theme/app_theme.dart';

class FlavorWheelScreen extends StatefulWidget {
  const FlavorWheelScreen({super.key});

  @override
  State<FlavorWheelScreen> createState() => _FlavorWheelScreenState();
}

class _FlavorWheelScreenState extends State<FlavorWheelScreen> {
  // 1. INFORMASI SAMPEL KOPI (Default Bersih / Siap Diisi Cupper)
  final TextEditingController _beanNameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _cupperController = TextEditingController(text: 'Q-Grader Cupper');
  final TextEditingController _customVarietyController = TextEditingController();
  final TextEditingController _customProcessController = TextEditingController();

  String _selectedVariety = 'Bourbon';
  bool _isCustomVariety = false;

  String _selectedProcess = 'Washed';
  bool _isCustomProcess = false;

  String _selectedRoast = 'Light-Medium';

  // 2. TASTING NOTES & FLAVOR WHEEL (Default Kosong)
  final Set<String> _selectedNotes = {};
  String _activeNoteCategory = '🍑 Fruity (Tropis & Batu)';
  final TextEditingController _customNoteInputController = TextEditingController();

  // 3. SKOR SENSORI CUPPING (STANDAR SCA: 6.00 - 10.00)
  bool _hasEvaluated = false;
  double _aromaScore = 8.00;
  double _acidityScore = 8.00;
  double _sweetnessScore = 8.00;
  double _mouthfeelScore = 8.00;
  double _aftertasteScore = 8.00;
  double _balanceScore = 8.00;

  // 4. AFTERTASTE
  String _selectedAftertasteDesc = 'Juicy';
  bool _isCustomAftertaste = false;
  final TextEditingController _customAftertasteController = TextEditingController();

  // 5. MOUTHFEEL
  String _selectedMouthfeelDesc = 'Silky & Smooth';
  bool _isCustomMouthfeel = false;
  final TextEditingController _customMouthfeelController = TextEditingController();

  // 6. CATATAN KESIMPULAN
  final TextEditingController _cuppingNotesController = TextEditingController();

  @override
  void dispose() {
    _beanNameController.dispose();
    _originController.dispose();
    _cupperController.dispose();
    _customVarietyController.dispose();
    _customProcessController.dispose();
    _customNoteInputController.dispose();
    _customAftertasteController.dispose();
    _customMouthfeelController.dispose();
    _cuppingNotesController.dispose();
    super.dispose();
  }

  // Perhitungan Skor Total Cupping SCA (Standar 100 poin)
  double get _totalCuppingScore {
    if (!_hasEvaluated) return 0.0;
    final sum = _aromaScore + _acidityScore + _sweetnessScore + _mouthfeelScore + _aftertasteScore + _balanceScore;
    return (40.0 + sum).clamp(0.0, 100.0);
  }

  String get _cuppingGradeLabel => CuppingConstants.getGradeLabel(_hasEvaluated, _totalCuppingScore);
  Color get _cuppingGradeColor => CuppingConstants.getGradeColor(_hasEvaluated, _totalCuppingScore);

  void _loadDemoCuppingData() {
    setState(() {
      _hasEvaluated = true;
      _beanNameController.text = CuppingDemoData.beanName;
      _originController.text = CuppingDemoData.origin;
      _cupperController.text = CuppingDemoData.cupper;
      _selectedVariety = CuppingDemoData.variety;
      _isCustomVariety = false;
      _selectedProcess = CuppingDemoData.process;
      _isCustomProcess = false;
      _selectedRoast = CuppingDemoData.roast;
      _selectedNotes.clear();
      _selectedNotes.addAll(CuppingDemoData.notes);
      _selectedAftertasteDesc = CuppingDemoData.aftertaste;
      _isCustomAftertaste = false;
      _selectedMouthfeelDesc = CuppingDemoData.mouthfeel;
      _isCustomMouthfeel = false;
      _aromaScore = CuppingDemoData.aromaScore;
      _acidityScore = CuppingDemoData.acidityScore;
      _sweetnessScore = CuppingDemoData.sweetnessScore;
      _mouthfeelScore = CuppingDemoData.mouthfeelScore;
      _aftertasteScore = CuppingDemoData.aftertasteScore;
      _balanceScore = CuppingDemoData.balanceScore;
      _cuppingNotesController.text = CuppingDemoData.notesText;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contoh sampel demo cupping berhasil dimuat!'),
        backgroundColor: AppTheme.primaryBrown,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetCuppingForm() {
    setState(() {
      _hasEvaluated = false;
      _beanNameController.clear();
      _originController.clear();
      _cupperController.text = 'Q-Grader Cupper';
      _customVarietyController.clear();
      _customProcessController.clear();
      _selectedVariety = 'Bourbon';
      _isCustomVariety = false;
      _selectedProcess = 'Washed';
      _isCustomProcess = false;
      _selectedRoast = 'Light-Medium';
      _selectedNotes.clear();
      _selectedAftertasteDesc = 'Juicy';
      _isCustomAftertaste = false;
      _selectedMouthfeelDesc = 'Silky & Smooth';
      _isCustomMouthfeel = false;
      _aromaScore = 8.00;
      _acidityScore = 8.00;
      _sweetnessScore = 8.00;
      _mouthfeelScore = 8.00;
      _aftertasteScore = 8.00;
      _balanceScore = 8.00;
      _cuppingNotesController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulir cupping berhasil dikosongkan (lembar baru).'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String get _effectiveAftertaste {
    if (_isCustomAftertaste) {
      final t = _customAftertasteController.text.trim();
      return t.isEmpty ? 'Juicy' : t;
    }
    return _selectedAftertasteDesc;
  }

  String get _effectiveMouthfeel {
    if (_isCustomMouthfeel) {
      final t = _customMouthfeelController.text.trim();
      return t.isEmpty ? 'Silky & Smooth' : t;
    }
    return _selectedMouthfeelDesc;
  }

  String get _effectiveVariety {
    if (_isCustomVariety) {
      final t = _customVarietyController.text.trim();
      return t.isEmpty ? 'Single Origin Variety' : t;
    }
    return _selectedVariety;
  }

  String get _effectiveProcess {
    if (_isCustomProcess) {
      final t = _customProcessController.text.trim();
      return t.isEmpty ? 'Washed Process' : t;
    }
    return _selectedProcess;
  }

  void _openVarietyModal() {
    VarietyPickerModal.show(
      context: context,
      effectiveVariety: _effectiveVariety,
      onSelectVariety: (item) {
        setState(() {
          _selectedVariety = item;
          _isCustomVariety = false;
        });
      },
      onSelectCustom: (customVal) {
        setState(() {
          _selectedVariety = 'Custom...';
          _isCustomVariety = true;
          _customVarietyController.text = customVal;
        });
      },
    );
  }

  void _openBeanCatalogModal() {
    BeanCatalogModal.show(
      context: context,
      onSelectBean: (b) {
        setState(() {
          _beanNameController.text = b.name;
          _originController.text = b.region;
          if (CuppingConstants.popularVarieties.contains(b.defaultVariety)) {
            _selectedVariety = b.defaultVariety;
            _isCustomVariety = false;
          } else {
            _isCustomVariety = true;
            _customVarietyController.text = b.defaultVariety;
            _selectedVariety = 'Custom...';
          }

          if (CuppingConstants.popularProcesses.contains(b.process)) {
            _selectedProcess = b.process;
            _isCustomProcess = false;
          } else {
            _isCustomProcess = true;
            _customProcessController.text = b.process;
            _selectedProcess = 'Custom...';
          }

          _selectedRoast = CuppingConstants.normalizeRoast(b.roast);
          for (final n in b.defaultNotes) {
            _selectedNotes.add(n);
          }
        });
      },
    );
  }

  void _addCustomNote() {
    final note = _customNoteInputController.text.trim();
    if (note.isNotEmpty) {
      setState(() {
        _selectedNotes.add(note);
        _customNoteInputController.clear();
      });
    }
  }

  Future<void> _saveCuppingSession() async {
    await CuppingSessionHelper.save(
      context: context,
      hasEvaluated: _hasEvaluated,
      beanName: _beanNameController.text,
      origin: _originController.text,
      variety: _effectiveVariety,
      process: _effectiveProcess,
      roast: _selectedRoast,
      cupper: _cupperController.text,
      aftertaste: _effectiveAftertaste,
      mouthfeel: _effectiveMouthfeel,
      selectedNotes: _selectedNotes,
      evalNotes: _cuppingNotesController.text,
      score: _totalCuppingScore,
      cuppingGradeLabel: _cuppingGradeLabel,
      aromaScore: _aromaScore,
      acidityScore: _acidityScore,
      sweetnessScore: _sweetnessScore,
      mouthfeelScore: _mouthfeelScore,
      aftertasteScore: _aftertasteScore,
      balanceScore: _balanceScore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: CuppingAppBar(
        onOpenBeanCatalog: _openBeanCatalogModal,
        onOpenVarietyModal: _openVarietyModal,
        onResetForm: _resetCuppingForm,
        onLoadDemo: _loadDemoCuppingData,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO CARD: SKOR CUPPING REAL-TIME & STATUS GRADE SCA
            CuppingHeroScoreCard(
              hasEvaluated: _hasEvaluated,
              totalCuppingScore: _totalCuppingScore,
              cuppingGradeColor: _cuppingGradeColor,
              cuppingGradeLabel: _cuppingGradeLabel,
              aromaScore: _aromaScore,
              acidityScore: _acidityScore,
              sweetnessScore: _sweetnessScore,
              mouthfeelScore: _mouthfeelScore,
              aftertasteScore: _aftertasteScore,
              onStartEvaluate: () => setState(() => _hasEvaluated = true),
              onLoadDemo: _loadDemoCuppingData,
              onReset: _resetCuppingForm,
            ),
            const SizedBox(height: 18),

            // SEKSI 1: INFORMASI SAMPEL KOPI (BIJI, ASAL, VARIETAS, PROSES, ROAST)
            CuppingCoffeeInfoSection(
              beanNameController: _beanNameController,
              originController: _originController,
              cupperController: _cupperController,
              customVarietyController: _customVarietyController,
              customProcessController: _customProcessController,
              selectedVariety: _selectedVariety,
              isCustomVariety: _isCustomVariety,
              selectedProcess: _selectedProcess,
              isCustomProcess: _isCustomProcess,
              selectedRoast: _selectedRoast,
              effectiveVariety: _effectiveVariety,
              effectiveProcess: _effectiveProcess,
              popularVarieties: CuppingConstants.popularVarieties,
              popularProcesses: CuppingConstants.popularProcesses,
              roastPresets: CuppingConstants.roastPresets,
              onOpenBeanCatalog: _openBeanCatalogModal,
              onOpenVarietyCatalog: _openVarietyModal,
              onSelectVarietyChip: (item) {
                setState(() {
                  _selectedVariety = item;
                  _isCustomVariety = item == 'Custom...';
                  if (!_isCustomVariety) _customVarietyController.clear();
                });
              },
              onSelectProcessChip: (item) {
                setState(() {
                  _selectedProcess = item;
                  _isCustomProcess = item == 'Custom...';
                  if (!_isCustomProcess) _customProcessController.clear();
                });
              },
              onRoastChanged: (v) => setState(() => _selectedRoast = v),
            ),
            const SizedBox(height: 18),

            // SEKSI 2: FLAVOR WHEEL & TASTING NOTES VISUAL
            CuppingFlavorNotesSection(
              activeNoteCategory: _activeNoteCategory,
              noteCategories: CuppingConstants.noteCategories,
              selectedNotes: _selectedNotes,
              customNoteInputController: _customNoteInputController,
              onCategorySelected: (cat) => setState(() => _activeNoteCategory = cat),
              onToggleNote: (note) {
                setState(() {
                  if (_selectedNotes.contains(note)) {
                    _selectedNotes.remove(note);
                  } else {
                    _selectedNotes.add(note);
                  }
                });
              },
              onAddCustomNote: _addCustomNote,
              onRemoveNote: (note) => setState(() => _selectedNotes.remove(note)),
            ),
            const SizedBox(height: 18),

            // SEKSI 3 & 4: AFTERTASTE & MOUTHFEEL / BODY
            CuppingAftertasteMouthfeelSection(
              aftertasteScore: _aftertasteScore,
              effectiveAftertaste: _effectiveAftertaste,
              selectedAftertasteDesc: _selectedAftertasteDesc,
              isCustomAftertaste: _isCustomAftertaste,
              aftertastePresets: CuppingConstants.aftertastePresets,
              customAftertasteController: _customAftertasteController,
              onAftertasteScoreChanged: (v) => setState(() {
                _aftertasteScore = v;
                _hasEvaluated = true;
              }),
              onSelectAftertastePreset: (item) {
                setState(() {
                  _selectedAftertasteDesc = item;
                  _isCustomAftertaste = item == 'Custom...';
                  if (!_isCustomAftertaste) _customAftertasteController.clear();
                });
              },
              mouthfeelScore: _mouthfeelScore,
              effectiveMouthfeel: _effectiveMouthfeel,
              selectedMouthfeelDesc: _selectedMouthfeelDesc,
              isCustomMouthfeel: _isCustomMouthfeel,
              mouthfeelPresets: CuppingConstants.mouthfeelPresets,
              customMouthfeelController: _customMouthfeelController,
              onMouthfeelScoreChanged: (v) => setState(() {
                _mouthfeelScore = v;
                _hasEvaluated = true;
              }),
              onSelectMouthfeelPreset: (item) {
                setState(() {
                  _selectedMouthfeelDesc = item;
                  _isCustomMouthfeel = item == 'Custom...';
                  if (!_isCustomMouthfeel) _customMouthfeelController.clear();
                });
              },
            ),
            const SizedBox(height: 18),

            // SEKSI 5: PROFIL SENSORIS LAINNYA (AROMA, ACIDITY, SWEETNESS, BALANCE)
            CuppingSensoryScoresSection(
              aromaScore: _aromaScore,
              acidityScore: _acidityScore,
              sweetnessScore: _sweetnessScore,
              balanceScore: _balanceScore,
              hasEvaluated: _hasEvaluated,
              cuppingNotesController: _cuppingNotesController,
              onAromaChanged: (v) => setState(() => _aromaScore = v),
              onAcidityChanged: (v) => setState(() => _acidityScore = v),
              onSweetnessChanged: (v) => setState(() => _sweetnessScore = v),
              onBalanceChanged: (v) => setState(() => _balanceScore = v),
              onFirstEvaluation: () => setState(() => _hasEvaluated = true),
            ),
            const SizedBox(height: 18),

            // SEKSI 6: CATATAN SENSORIS CUPPER & EVALUASI
            CuppingNotesSection(controller: _cuppingNotesController),
            const SizedBox(height: 24),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveCuppingSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 20),
                label: const Text(
                  'Simpan Sesi Cupping ke Journal',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
