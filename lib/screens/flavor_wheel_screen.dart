import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/flavor_wheel/data/cupping_constants.dart';
import '../features/flavor_wheel/services/cupping_session_helper.dart';
import '../features/flavor_wheel/widgets/bean_catalog_modal.dart';
import '../features/flavor_wheel/widgets/cupping_aftertaste_mouthfeel_section.dart';
import '../features/flavor_wheel/widgets/cupping_app_bar.dart';
import '../features/flavor_wheel/widgets/cupping_coffee_info_section.dart';
import '../features/flavor_wheel/widgets/cupping_flavor_notes_section.dart';
import '../features/flavor_wheel/widgets/cupping_hero_score_card.dart';
import '../features/flavor_wheel/widgets/cupping_selection_modals.dart';
import '../features/flavor_wheel/widgets/cupping_sensory_scores_section.dart';
import '../features/flavor_wheel/widgets/variety_picker_modal.dart';
import '../theme/app_theme.dart';

/// Professional 3-Step SCA Coffee Cupping Studio:
/// Step 1 (`1. Sampel`): Sample identity, multi-select Varieties popup, Process popup, Roast
/// Step 2 (`2. Rasa & Notes`): Flavor Wheel popup, Aftertaste & Mouthfeel popups + sliders
/// Step 3 (`3. Skor SCA`): Full SCA attributes, Defect deduction, Summary & Save to Journal
class FlavorWheelScreen extends StatefulWidget {
  const FlavorWheelScreen({super.key});

  @override
  State<FlavorWheelScreen> createState() => _FlavorWheelScreenState();
}

class _FlavorWheelScreenState extends State<FlavorWheelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Step 1: Sample Info (supports multi-select varieties & processes!)
  final TextEditingController _beanNameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _cupperController =
      TextEditingController(text: 'Q-Grader Cupper');

  final Set<String> _selectedVarieties = {'Bourbon'};
  final Set<String> _selectedProcesses = {'Washed'};
  String _selectedRoast = 'Light-Medium';

  // Step 2: Flavor Wheel, Aftertaste & Mouthfeel (all popup multi-select!)
  final Set<String> _selectedNotes = {};
  final Set<String> _selectedAftertaste = {'Juicy'};
  final Set<String> _selectedMouthfeel = {'Silky & Smooth'};

  // Step 3: SCA Sensory Scores (6.00 – 10.00 in 0.25 steps)
  bool _hasEvaluated = false;
  double _aromaScore = 8.00;
  double _acidityScore = 8.00;
  double _sweetnessScore = 8.00;
  double _mouthfeelScore = 8.00;
  double _aftertasteScore = 8.00;
  double _balanceScore = 8.00;
  int _defectDeduction = 0;

  final TextEditingController _cuppingNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _beanNameController.dispose();
    _originController.dispose();
    _cupperController.dispose();
    _cuppingNotesController.dispose();
    super.dispose();
  }

  double get _totalCuppingScore {
    if (!_hasEvaluated) return 0.0;
    final sum = _aromaScore +
        _acidityScore +
        _sweetnessScore +
        _mouthfeelScore +
        _aftertasteScore +
        _balanceScore;
    return (40.0 + sum - _defectDeduction).clamp(0.0, 100.0);
  }

  String get _cuppingGradeLabel =>
      CuppingConstants.getGradeLabel(_hasEvaluated, _totalCuppingScore);
  Color get _cuppingGradeColor =>
      CuppingConstants.getGradeColor(_hasEvaluated, _totalCuppingScore);

  String get _effectiveVariety => _selectedVarieties.isEmpty
      ? 'Single Origin Variety'
      : _selectedVarieties.join(', ');

  String get _effectiveProcess => _selectedProcesses.isEmpty
      ? 'Washed'
      : _selectedProcesses.join(', ');

  String get _effectiveAftertaste => _selectedAftertaste.isEmpty
      ? 'Clean & Refreshing'
      : _selectedAftertaste.join(', ');

  String get _effectiveMouthfeel => _selectedMouthfeel.isEmpty
      ? 'Silky & Smooth'
      : _selectedMouthfeel.join(', ');

  void _loadDemoCuppingData() {
    setState(() {
      _hasEvaluated = true;
      _beanNameController.text = CuppingDemoData.beanName;
      _originController.text = CuppingDemoData.origin;
      _cupperController.text = CuppingDemoData.cupper;
      _selectedVarieties
        ..clear()
        ..addAll(CuppingDemoData.varieties);
      _selectedProcesses
        ..clear()
        ..addAll(CuppingDemoData.processes);
      _selectedRoast = CuppingDemoData.roast;
      _selectedNotes
        ..clear()
        ..addAll(CuppingDemoData.notes);
      _selectedAftertaste
        ..clear()
        ..addAll(CuppingDemoData.aftertaste);
      _selectedMouthfeel
        ..clear()
        ..addAll(CuppingDemoData.mouthfeel);
      _aromaScore = CuppingDemoData.aromaScore;
      _acidityScore = CuppingDemoData.acidityScore;
      _sweetnessScore = CuppingDemoData.sweetnessScore;
      _mouthfeelScore = CuppingDemoData.mouthfeelScore;
      _aftertasteScore = CuppingDemoData.aftertasteScore;
      _balanceScore = CuppingDemoData.balanceScore;
      _defectDeduction = 0;
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
      _selectedVarieties
        ..clear()
        ..add('Bourbon');
      _selectedProcesses
        ..clear()
        ..add('Washed');
      _selectedRoast = 'Light-Medium';
      _selectedNotes.clear();
      _selectedAftertaste
        ..clear()
        ..add('Juicy');
      _selectedMouthfeel
        ..clear()
        ..add('Silky & Smooth');
      _aromaScore = 8.00;
      _acidityScore = 8.00;
      _sweetnessScore = 8.00;
      _mouthfeelScore = 8.00;
      _aftertasteScore = 8.00;
      _balanceScore = 8.00;
      _defectDeduction = 0;
      _cuppingNotesController.clear();
    });
    _tabController.animateTo(0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulir cupping berhasil dikosongkan (lembar baru).'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openVarietyModal() {
    VarietyPickerModal.show(
      context: context,
      selectedVarieties: _selectedVarieties,
      onConfirmVarieties: (updated) {
        setState(() {
          _selectedVarieties
            ..clear()
            ..addAll(updated);
        });
      },
    );
  }

  void _openProcessModal() {
    CuppingOptionPickerModal.show(
      context: context,
      title: 'Pilih Proses Pasca-Panen',
      subtitle: 'Bisa pilih 1 atau proses kombinasi',
      icon: Icons.science_rounded,
      accentColor: const Color(0xFFC2410C),
      options: CuppingConstants.popularProcesses,
      selectedValues: _selectedProcesses,
      customHint: 'Tambah proses custom (mis. Honey Anaerobic)...',
      onConfirm: (updated) {
        setState(() {
          _selectedProcesses
            ..clear()
            ..addAll(updated);
        });
      },
    );
  }

  void _openFlavorNotesModal() {
    FlavorNotesPickerModal.show(
      context: context,
      selectedNotes: _selectedNotes,
      onConfirm: (updated) {
        setState(() {
          _selectedNotes
            ..clear()
            ..addAll(updated);
        });
      },
    );
  }

  void _openAftertasteModal() {
    CuppingOptionPickerModal.show(
      context: context,
      title: 'Karakter Aftertaste',
      subtitle: 'Pilih sensasi akhir yang tertinggal',
      icon: CupertinoIcons.drop_triangle_fill,
      accentColor: const Color(0xFFD97706),
      options: CuppingConstants.aftertastePresets,
      selectedValues: _selectedAftertaste,
      customHint: 'Tambah aftertaste custom (mis. Honeyed Finish)...',
      onConfirm: (updated) {
        setState(() {
          _selectedAftertaste
            ..clear()
            ..addAll(updated);
        });
      },
    );
  }

  void _openMouthfeelModal() {
    CuppingOptionPickerModal.show(
      context: context,
      title: 'Tekstur Mouthfeel / Body',
      subtitle: 'Pilih bobot & kehalusan di lidah',
      icon: CupertinoIcons.circle_bottomthird_split,
      accentColor: const Color(0xFF0F766E),
      options: CuppingConstants.mouthfeelPresets,
      selectedValues: _selectedMouthfeel,
      customHint: 'Tambah tekstur custom (mis. Creamy Mentega)...',
      onConfirm: (updated) {
        setState(() {
          _selectedMouthfeel
            ..clear()
            ..addAll(updated);
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
          _selectedVarieties
            ..clear()
            ..addAll(
              b.defaultVariety
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            );
          _selectedProcesses
            ..clear()
            ..add(b.process);
          _selectedRoast = CuppingConstants.normalizeRoast(b.roast);
          for (final n in b.defaultNotes) {
            _selectedNotes.add(n);
          }
        });
      },
    );
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryBrown,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textMuted,
                labelStyle: const TextStyle(
                  fontSize: 11.2,
                  fontWeight: FontWeight.w800,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11.2,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(text: '1. Sampel'),
                  Tab(text: '2. Rasa & Notes'),
                  Tab(text: '3. Skor SCA'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Compact Persistent SCA Score Strip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: CuppingHeroScoreCard(
              hasEvaluated: _hasEvaluated,
              totalCuppingScore: _totalCuppingScore,
              cuppingGradeColor: _cuppingGradeColor,
              cuppingGradeLabel: _cuppingGradeLabel,
              aromaScore: _aromaScore,
              acidityScore: _acidityScore,
              sweetnessScore: _sweetnessScore,
              mouthfeelScore: _mouthfeelScore,
              aftertasteScore: _aftertasteScore,
              balanceScore: _balanceScore,
              onStartEvaluate: () {
                setState(() => _hasEvaluated = true);
                _tabController.animateTo(1);
              },
              onLoadDemo: _loadDemoCuppingData,
              onReset: _resetCuppingForm,
            ),
          ),

          // Guided 3-Step Cupping Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // STEP 1: IDENTITAS SAMPEL KOPI
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                  child: Column(
                    children: [
                      CuppingCoffeeInfoSection(
                        beanNameController: _beanNameController,
                        originController: _originController,
                        cupperController: _cupperController,
                        selectedVarieties: _selectedVarieties,
                        selectedProcesses: _selectedProcesses,
                        selectedRoast: _selectedRoast,
                        roastPresets: CuppingConstants.roastPresets,
                        onOpenBeanCatalog: _openBeanCatalogModal,
                        onOpenVarietyPopup: _openVarietyModal,
                        onRemoveVariety: (v) =>
                            setState(() => _selectedVarieties.remove(v)),
                        onOpenProcessPopup: _openProcessModal,
                        onRemoveProcess: (p) =>
                            setState(() => _selectedProcesses.remove(p)),
                        onRoastChanged: (r) =>
                            setState(() => _selectedRoast = r),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (!_hasEvaluated) {
                              setState(() => _hasEvaluated = true);
                            }
                            _tabController.animateTo(1);
                          },
                          icon: const Icon(CupertinoIcons.sparkles, size: 17),
                          label: const Text(
                            'Lanjut: Evaluasi Rasa & Notes',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // STEP 2: FLAVOR WHEEL, AFTERTASTE & MOUTHFEEL
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                  child: Column(
                    children: [
                      CuppingFlavorNotesSection(
                        selectedNotes: _selectedNotes,
                        onOpenNotesPopup: _openFlavorNotesModal,
                        onRemoveNote: (n) =>
                            setState(() => _selectedNotes.remove(n)),
                      ),
                      const SizedBox(height: 12),
                      CuppingAftertasteMouthfeelSection(
                        aftertasteScore: _aftertasteScore,
                        selectedAftertaste: _selectedAftertaste,
                        onAftertasteScoreChanged: (v) => setState(() {
                          _aftertasteScore = v;
                          _hasEvaluated = true;
                        }),
                        onOpenAftertastePopup: _openAftertasteModal,
                        onRemoveAftertaste: (item) =>
                            setState(() => _selectedAftertaste.remove(item)),
                        mouthfeelScore: _mouthfeelScore,
                        selectedMouthfeel: _selectedMouthfeel,
                        onMouthfeelScoreChanged: (v) => setState(() {
                          _mouthfeelScore = v;
                          _hasEvaluated = true;
                        }),
                        onOpenMouthfeelPopup: _openMouthfeelModal,
                        onRemoveMouthfeel: (item) =>
                            setState(() => _selectedMouthfeel.remove(item)),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => _tabController.animateTo(0),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryBrown,
                              side: const BorderSide(color: AppTheme.borderWarm),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: const Text(
                              'Sampel',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: () => _tabController.animateTo(2),
                                icon: const Icon(
                                  CupertinoIcons.slider_horizontal_3,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Lanjut: Skor SCA',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBrown,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // STEP 3: SKOR SENSORI SCA, RINGKASAN & SIMPAN
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                  child: Column(
                    children: [
                      _buildSampleQuickSummaryCard(),
                      const SizedBox(height: 12),
                      CuppingSensoryScoresSection(
                        aromaScore: _aromaScore,
                        acidityScore: _acidityScore,
                        sweetnessScore: _sweetnessScore,
                        balanceScore: _balanceScore,
                        defectDeduction: _defectDeduction,
                        hasEvaluated: _hasEvaluated,
                        cuppingNotesController: _cuppingNotesController,
                        onAromaChanged: (v) => setState(() => _aromaScore = v),
                        onAcidityChanged: (v) =>
                            setState(() => _acidityScore = v),
                        onSweetnessChanged: (v) =>
                            setState(() => _sweetnessScore = v),
                        onBalanceChanged: (v) =>
                            setState(() => _balanceScore = v),
                        onDefectDeductionChanged: (d) =>
                            setState(() => _defectDeduction = d),
                        onFirstEvaluation: () =>
                            setState(() => _hasEvaluated = true),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _saveCuppingSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            size: 19,
                          ),
                          label: const Text(
                            'Simpan Sesi Cupping ke Journal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleQuickSummaryCard() {
    final bean = _beanNameController.text.trim().isEmpty
        ? 'Sampel Kopi Belum Dinamai'
        : _beanNameController.text.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bean,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 5,
            children: [
              _summaryBadge(_effectiveVariety, const Color(0xFF2E7D32)),
              _summaryBadge(_effectiveProcess, const Color(0xFFC2410C)),
              _summaryBadge(_selectedRoast, AppTheme.primaryBrown),
              if (_selectedNotes.isNotEmpty)
                _summaryBadge(
                  '${_selectedNotes.length} Tasting Notes',
                  const Color(0xFF0F766E),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.2,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
