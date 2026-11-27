import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/world_indonesia_beans_service.dart';
import '../features/bean_dial_in/widgets/compact_dial_in_sections.dart';
import '../features/bean_dial_in/widgets/roastery_bean_picker_modal.dart';
import '../features/beans/controllers/bean_inventory_controller.dart';
import '../models/bean_ai_customization_models.dart';
import '../models/bean_recommendation_models.dart';
import '../models/curated_roastery_bean.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';
import 'brew_timer_screen.dart';
import 'grinder_converter_screen.dart';

class BeanRecipeRecommenderScreen extends ConsumerStatefulWidget {
  const BeanRecipeRecommenderScreen({super.key});

  @override
  ConsumerState<BeanRecipeRecommenderScreen> createState() =>
      _BeanRecipeRecommenderScreenState();
}

class _BeanRecipeRecommenderScreenState
    extends ConsumerState<BeanRecipeRecommenderScreen> {
  bool _isCatalogMode = true;

  late List<CuratedRoasteryBean> _catalogBeans;
  // Tidak langsung dipilih saat masuk: user memilih Roastery -> Biji Kopi dengan sadar!
  CuratedRoasteryBean? _selectedCatalogBean;

  final TextEditingController _customBeanCtrl =
      TextEditingController(text: 'Aceh Gayo Pantan Musara');
  BeanRoastLevel _customRoast = BeanRoastLevel.light;
  BeanProcess _customProcess = BeanProcess.washed;

  FlavorGoal _flavorGoal = FlavorGoal.sweetBalanced;
  BeanDripper _dripper = BeanDripper.v60;
  double _coffeeDose = 15.0;

  BeanRoastAge _roastAge = BeanRoastAge.peak;
  WaterProfile _waterProfile = WaterProfile.scaStandard;
  PouringParadigm _pouringParadigm = PouringParadigm.specialtyStandard;
  int _customTempAdjust = 0;
  int _customMicronAdjust = 0;
  double _customRatioAdjust = 0.0;

  final List<String> _popularOrigins = const [
    'Aceh Gayo Pantan Musara',
    'Sumatra Kerinci Kayu Aro',
    'Sumatra Solok Radjo',
    'Gunung Halu West Java',
    'Gunung Puntang West Java',
    'Temanggung Sindoro',
    'Java Ijen Raung',
    'Bali Kintamani Ulian',
    'Flores Bajawa & Colol',
    'Toraja Sapan',
    'Papua Wamena & Tiom',
    'Liberika Tungkal Jambi',
    'Excelsa Wonosalam',
    'Ethiopia Yirgacheffe',
    'Ethiopia Guji Uraga',
    'Colombia Huila Pink Bourbon',
    'Panama Boquete Geisha',
    'Kenya Nyeri SL28',
    'Costa Rica Tarrazú Honey',
    'Brazil Cerrado Mineiro',
    'Guatemala Huehuetenango',
  ];

  RecommendedBrewRecipe? _recipe;

  bool get _hasActiveSelection => !_isCatalogMode || _selectedCatalogBean != null;

  @override
  void initState() {
    super.initState();
    _catalogBeans = WorldIndonesiaBeansService.instance.mergeWithCuratedBeans(
      CuratedRoasteryBean.getAllCatalogBeans(),
    );
    WorldIndonesiaBeansService.instance.ensureLoaded().then((_) {
      if (!mounted) return;
      final merged = WorldIndonesiaBeansService.instance.mergeWithCuratedBeans(
        CuratedRoasteryBean.getAllCatalogBeans(),
      );
      if (merged.length != _catalogBeans.length) {
        setState(() => _catalogBeans = merged);
      }
    });
  }

  @override
  void dispose() {
    _customBeanCtrl.dispose();
    super.dispose();
  }

  void _onCatalogBeanSelected(CuratedRoasteryBean bean) {
    final autoParadigm = BeanRecommenderEngine.recommendParadigm(
      roast: bean.roastLevel,
      process: bean.process,
      descriptors: '${bean.name} ${bean.origin} ${bean.variety} ${bean.processRaw}',
    );
    final autoWater = BeanRecommenderEngine.recommendWaterProfile(
      roast: bean.roastLevel,
      process: bean.process,
    );
    setState(() {
      _selectedCatalogBean = bean;
      _dripper = bean.recommendedDripper;
      _pouringParadigm = autoParadigm;
      _waterProfile = autoWater;
      _customTempAdjust = 0;
      _customMicronAdjust = 0;
      _customRatioAdjust = 0.0;
    });
    _recalculate();
  }

  void _recalculate() {
    if (_isCatalogMode && _selectedCatalogBean == null) {
      setState(() => _recipe = null);
      return;
    }

    final bean = _selectedCatalogBean;
    final String beanTitle = _isCatalogMode && bean != null
        ? '${bean.roasteryName} • ${bean.name}'
        : _customBeanCtrl.text;
    final roast = _isCatalogMode && bean != null ? bean.roastLevel : _customRoast;
    final process = _isCatalogMode && bean != null ? bean.process : _customProcess;
    final origin = _isCatalogMode && bean != null ? bean.origin : '';
    final variety = _isCatalogMode && bean != null ? bean.variety : '';
    final notes = _isCatalogMode && bean != null
        ? bean.tastingNotesList
        : const <String>[];

    setState(() {
      _recipe = BeanRecommenderEngine.calculate(
        beanName: beanTitle,
        origin: origin,
        variety: variety,
        tastingNotes: notes,
        roast: roast,
        process: process,
        goal: _flavorGoal,
        dripper: _dripper,
        dose: _coffeeDose,
        roastAge: _roastAge,
        waterProfile: _waterProfile,
        pouringParadigm: _pouringParadigm,
        customTempAdjust: _customTempAdjust,
        customMicronAdjust: _customMicronAdjust,
        customRatioAdjust: _customRatioAdjust,
      );
    });
  }

  void _onApplyAiTweak(AiTweakAction tweak) {
    setState(() {
      _customTempAdjust += tweak.tempAdjust;
      _customMicronAdjust += tweak.micronAdjust;
      _customRatioAdjust += tweak.ratioAdjust;
      if (tweak == AiTweakAction.boostSweetness) {
        _pouringParadigm = PouringParadigm.tetsu46;
      }
    });
    _recalculate();

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'AI Dial-In: ${tweak.suggestion}',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _startTimer() {
    final recipe = _recipe;
    if (recipe == null) return;
    final recipeMap = recipe.toRecipeMap();
    final bean = _selectedCatalogBean;
    if (_isCatalogMode && bean != null) {
      recipeMap['roastery'] = bean.roasteryName;
      recipeMap['location'] = bean.roasteryLocation;
      recipeMap['officialNotes'] = bean.tastingNotes;
      recipeMap['opinion'] = bean.baristaOpinion;
      recipeMap['roastAge'] = _roastAge.label;
      recipeMap['waterProfile'] = _waterProfile.label;
      recipeMap['pouringParadigm'] = _pouringParadigm.label;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: recipeMap)),
    );
  }

  void _openQuickGuideSheet(BuildContext context) {
    showDialInInfoSheet(
      context: context,
      title: 'Cara Pakai Smart Brew Dial-In',
      items: const [
        (
          icon: CupertinoIcons.building_2_fill,
          color: AppTheme.primaryBrown,
          heading: '1. Pilih Roastery → Biji Kopi',
          body: 'Pilih Roastery terlebih dahulu lalu pilih biji kopi dari katalog, atau beralih ke Biji Kustom.',
        ),
        (
          icon: Icons.tune_rounded,
          color: Color(0xFF007A87),
          heading: '2. Kalibrasi Standar SCA Otomatis',
          body: 'Smart Brew menyesuaikan suhu, gilingan, rasio, kimia air, dan teknik tuang sesuai karakter sangrai, proses, dan varietas biji.',
        ),
        (
          icon: CupertinoIcons.play_circle_fill,
          color: Color(0xFFD97706),
          heading: '3. Mulai Seduh Presisi',
          body: 'Tinjau resep, jadwal tuang, dan klik grinder lalu tekan tombol Mulai Seduh.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final beansAsync = ref.watch(beanInventoryControllerProvider);
    final catalogBeans = beansAsync.value ?? _catalogBeans;
    final isEn = LanguageService.isEnglish;
    final activeRecipe = _recipe;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text(
          'Smart Brew Dial-In',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 21),
            tooltip: 'Panduan Singkat',
            onPressed: () => _openQuickGuideSheet(context),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.circle_grid_hex_fill, size: 20),
            tooltip: 'Matriks Grinder',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GrinderConverterScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
        children: [
          _buildModeSwitcher(),
          const SizedBox(height: 10),

          CompactBeanSelectorSection(
            isCatalogMode: _isCatalogMode,
            allBeans: catalogBeans,
            selectedBean: _selectedCatalogBean,
            onBeanSelected: _onCatalogBeanSelected,
            customBeanCtrl: _customBeanCtrl,
            customRoast: _customRoast,
            customProcess: _customProcess,
            popularOrigins: _popularOrigins,
            onCustomRoastChanged: (r) {
              setState(() => _customRoast = r);
              _recalculate();
            },
            onCustomProcessChanged: (p) {
              setState(() => _customProcess = p);
              _recalculate();
            },
            onRecalculate: _recalculate,
          ),
          const SizedBox(height: 10),

          if (!_hasActiveSelection || activeRecipe == null)
            _buildInternationalRoastCheatSheet()
          else ...[
            CompactBrewConfigSection(
              selectedGoal: _flavorGoal,
              selectedDripper: _dripper,
              dose: _coffeeDose,
              totalWater: activeRecipe.totalWater,
              brewRatio: activeRecipe.brewRatio,
              roastAge: _roastAge,
              waterProfile: _waterProfile,
              pouringParadigm: _pouringParadigm,
              onGoalChanged: (goal) {
                setState(() => _flavorGoal = goal);
                _recalculate();
              },
              onDripperChanged: (dripper) {
                setState(() => _dripper = dripper);
                _recalculate();
              },
              onDoseChanged: (v) {
                setState(() => _coffeeDose = v);
                _recalculate();
              },
              onRoastAgeChanged: (age) {
                setState(() => _roastAge = age);
                _recalculate();
              },
              onWaterProfileChanged: (w) {
                setState(() => _waterProfile = w);
                _recalculate();
              },
              onParadigmChanged: (p) {
                setState(() => _pouringParadigm = p);
                _recalculate();
              },
              onApplyTweak: _onApplyAiTweak,
            ),
            const SizedBox(height: 10),
            CompactDialInResultSection(
              recipe: activeRecipe,
              roastAge: _roastAge,
              waterProfile: _waterProfile,
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.borderWarm)),
          ),
          child: !_hasActiveSelection || activeRecipe == null
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      RoasteryBeanPickerModal.show(
                        context: context,
                        allBeans: catalogBeans,
                        selectedBean: _selectedCatalogBean,
                        onBeanSelected: _onCatalogBeanSelected,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.building_2_fill, size: 16),
                    label: Text(
                      isEn ? 'Choose Roastery & Bean' : 'Pilih Roastery & Biji Kopi',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dripper.label.split('(').first.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            activeRecipe.iceWeightGrams > 0
                                ? '${_coffeeDose.round()}g → ${activeRecipe.hotWaterGrams}ml + ${activeRecipe.iceWeightGrams}g Es • ${activeRecipe.waterTemp}°C'
                                : '${_coffeeDose.round()}g → ${activeRecipe.totalWater.round()}ml • ${activeRecipe.waterTemp}°C',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(CupertinoIcons.play_fill, size: 16),
                      label: Text(
                        isEn ? 'Start Brew' : 'Mulai Seduh',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Friendly international SCA quick reference shown before user picks a bean
  Widget _buildInternationalRoastCheatSheet() {
    const cards = [
      (
        title: 'Light Roast (Filter / Nordic)',
        spec: '93–95°C • 550–600 µm • 1:16 • V60 / Origami',
        tip: 'Suhu tinggi & blooming 45s membuka aroma bunga, citrus, & buah segar.',
        color: Color(0xFFB45309),
      ),
      (
        title: 'Medium Roast (Sweet Balance)',
        spec: '90–91°C • 640–680 µm • 1:15 • Kalita / V60',
        tip: 'Keseimbangan manis gula karamel, cokelat susu, dan body lembut.',
        color: Color(0xFF8D4925),
      ),
      (
        title: 'Anaerobic / Fermentasi Intens',
        spec: '88–90°C • 680–730 µm • 1:15.5 • Minim Agitasi',
        tip: 'Sangat mudah larut: turunkan suhu & perkasar gilingan agar buah bersih.',
        color: Color(0xFF0F766E),
      ),
      (
        title: 'Medium-Dark / Dark Roast',
        spec: '84–88°C • 740–820 µm • 1:13.5–14 • Osmotic',
        tip: 'Suhu rendah & tuangan lembut di tengah mengunci rasa cokelat anti-pahit.',
        color: Color(0xFF3E2723),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.sparkles, size: 15, color: AppTheme.accentAmber),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Panduan Cepat Standar SCA Internasional',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...cards.map(
            (c) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: c.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.spec,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.tip,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Row(
        children: [
          _modeTab(
            active: _isCatalogMode,
            icon: CupertinoIcons.building_2_fill,
            label: 'Katalog Roastery',
            onTap: () {
              if (!_isCatalogMode) {
                setState(() => _isCatalogMode = true);
                _recalculate();
              }
            },
          ),
          const SizedBox(width: 4),
          _modeTab(
            active: !_isCatalogMode,
            icon: CupertinoIcons.pencil,
            label: 'Biji Kustom',
            onTap: () {
              if (_isCatalogMode) {
                setState(() => _isCatalogMode = false);
                _recalculate();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _modeTab({
    required bool active,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryBrown : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: active ? AppTheme.accentGold : AppTheme.textMuted),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
