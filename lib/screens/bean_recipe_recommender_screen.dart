import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/world_indonesia_beans_service.dart';
import '../features/bean_dial_in/widgets/compact_dial_in_sections.dart';
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
  late CuratedRoasteryBean _selectedCatalogBean;

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

  late RecommendedBrewRecipe _recipe;

  @override
  void initState() {
    super.initState();
    _catalogBeans = WorldIndonesiaBeansService.instance.mergeWithCuratedBeans(
      CuratedRoasteryBean.getAllCatalogBeans(),
    );
    _selectedCatalogBean = _catalogBeans.firstWhere(
      (b) => b.roasteryName.contains('Space') || b.badge != null,
      orElse: () => _catalogBeans.first,
    );
    _dripper = _selectedCatalogBean.recommendedDripper;
    _recalculate();
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
    setState(() {
      _selectedCatalogBean = bean;
      _dripper = bean.recommendedDripper;
      _customTempAdjust = 0;
      _customMicronAdjust = 0;
      _customRatioAdjust = 0.0;
    });
    _recalculate();
  }

  void _recalculate() {
    final String beanTitle = _isCatalogMode
        ? '${_selectedCatalogBean.roasteryName} • ${_selectedCatalogBean.name}'
        : _customBeanCtrl.text;
    final roast = _isCatalogMode ? _selectedCatalogBean.roastLevel : _customRoast;
    final process = _isCatalogMode ? _selectedCatalogBean.process : _customProcess;
    final origin = _isCatalogMode ? _selectedCatalogBean.origin : '';
    final variety = _isCatalogMode ? _selectedCatalogBean.variety : '';
    final notes = _isCatalogMode ? _selectedCatalogBean.tastingNotesList : const <String>[];

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AI Dial-In: ${tweak.suggestion}', style: const TextStyle(fontSize: 12)),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _startTimer() {
    final recipeMap = _recipe.toRecipeMap();
    if (_isCatalogMode) {
      recipeMap['roastery'] = _selectedCatalogBean.roasteryName;
      recipeMap['location'] = _selectedCatalogBean.roasteryLocation;
      recipeMap['officialNotes'] = _selectedCatalogBean.tastingNotes;
      recipeMap['opinion'] = _selectedCatalogBean.baristaOpinion;
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
          icon: CupertinoIcons.checkmark_seal_fill,
          color: AppTheme.primaryBrown,
          heading: '1. Pilih Kopi',
          body: 'Pilih biji dari Katalog Roastery resmi atau masukkan karakter biji kustom Anda.',
        ),
        (
          icon: Icons.tune_rounded,
          color: Color(0xFF007A87),
          heading: '2. Atur Target & Dosis',
          body: 'Tentukan karakter rasa, alat dripper, serta dosis kopi. Tekan Koreksi jika cangkir terlalu asam/pahit.',
        ),
        (
          icon: CupertinoIcons.play_circle_fill,
          color: Color(0xFFD97706),
          heading: '3. Mulai Seduh Presisi',
          body: 'Tinjau resep & jadwal tuangan, lalu tekan tombol Mulai Seduh di bagian bawah.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final beansAsync = ref.watch(beanInventoryControllerProvider);
    final catalogBeans = beansAsync.value ?? _catalogBeans;
    final isEn = LanguageService.isEnglish;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(
          isEn ? 'Smart Brew Dial-In' : 'Smart Brew Dial-In',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
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
          _buildModeSwitcher(catalogBeans.length),
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

          CompactBrewConfigSection(
            selectedGoal: _flavorGoal,
            selectedDripper: _dripper,
            dose: _coffeeDose,
            totalWater: _recipe.totalWater,
            brewRatio: _recipe.brewRatio,
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
            recipe: _recipe,
            roastAge: _roastAge,
            waterProfile: _waterProfile,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.borderWarm)),
          ),
          child: Row(
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
                      '${_coffeeDose.round()}g → ${_recipe.totalWater.round()}ml • ${_recipe.waterTemp}°C',
                      style: const TextStyle(
                        fontSize: 12,
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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(CupertinoIcons.play_fill, size: 16),
                label: Text(
                  isEn ? 'Start Brew' : 'Mulai Seduh',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitcher(int beanCount) {
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
            icon: CupertinoIcons.checkmark_seal_fill,
            label: 'Katalog ($beanCount+)',
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
          padding: const EdgeInsets.symmetric(vertical: 7),
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
