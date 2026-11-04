import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/beans/controllers/bean_inventory_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/bean_dial_in/widgets/bean_ai_customizer_card.dart';
import '../features/bean_dial_in/widgets/bean_ai_extraction_metrics_card.dart';
import '../features/bean_dial_in/widgets/bean_barista_opinion_card.dart';
import '../features/bean_dial_in/widgets/bean_custom_goal_card.dart';
import '../features/bean_dial_in/widgets/bean_dose_slider_card.dart';
import '../features/bean_dial_in/widgets/bean_input_selector_card.dart';
import '../features/bean_dial_in/widgets/bean_pour_schedule_card.dart';
import '../features/bean_dial_in/widgets/bean_recipe_parameter_card.dart';
import '../features/bean_dial_in/widgets/bean_sensory_radar_card.dart';
import '../features/bean_dial_in/widgets/roastery_bean_selector_card.dart';
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
  ConsumerState<BeanRecipeRecommenderScreen> createState() => _BeanRecipeRecommenderScreenState();
}

class _BeanRecipeRecommenderScreenState extends ConsumerState<BeanRecipeRecommenderScreen> {
  // Mode: Catalog Roastery vs Custom Bean
  bool _isCatalogMode = true;

  late List<CuratedRoasteryBean> _catalogBeans;
  late CuratedRoasteryBean _selectedCatalogBean;

  // Custom Bean controllers (if user wants custom entry)
  final TextEditingController _customBeanCtrl = TextEditingController(text: 'Aceh Gayo Pantan Musara');
  BeanRoastLevel _customRoast = BeanRoastLevel.light;
  BeanProcess _customProcess = BeanProcess.washed;

  // Common parameters
  FlavorGoal _flavorGoal = FlavorGoal.sweetBalanced;
  BeanDripper _dripper = BeanDripper.v60;
  double _coffeeDose = 15.0;

  // AI Customization parameters
  BeanRoastAge _roastAge = BeanRoastAge.peak;
  WaterProfile _waterProfile = WaterProfile.scaStandard;
  PouringParadigm _pouringParadigm = PouringParadigm.specialtyStandard;
  int _customTempAdjust = 0;
  int _customMicronAdjust = 0;
  double _customRatioAdjust = 0.0;

  final List<String> _popularOrigins = [
    'Aceh Gayo Pantan Musara',
    'Gunung Halu West Java',
    'Bali Kintamani Ulian',
    'Toraja Sapan',
    'Flores Bajawa',
    'Java Ijen Raung',
    'Ethiopia Yirgacheffe',
    'Colombia Geisha',
  ];

  late RecommendedBrewRecipe _recipe;

  @override
  void initState() {
    super.initState();
    _catalogBeans = CuratedRoasteryBean.getAllCatalogBeans();
    _selectedCatalogBean = _catalogBeans.firstWhere(
      (b) => b.roasteryName.contains('Space') || b.badge != null,
      orElse: () => _catalogBeans.first,
    );
    _dripper = _selectedCatalogBean.recommendedDripper;
    _recalculate();
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
    final BeanRoastLevel roast = _isCatalogMode ? _selectedCatalogBean.roastLevel : _customRoast;
    final BeanProcess process = _isCatalogMode ? _selectedCatalogBean.process : _customProcess;
    final String origin = _isCatalogMode ? _selectedCatalogBean.origin : '';
    final String variety = _isCatalogMode ? _selectedCatalogBean.variety : '';
    final List<String> notes = _isCatalogMode ? _selectedCatalogBean.tastingNotesList : const [];

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
        content: Row(
          children: [
            const Icon(CupertinoIcons.sparkles, color: Colors.amber, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'AI Dial-In: ${tweak.suggestion}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
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

  @override
  Widget build(BuildContext context) {
    final beansAsync = ref.watch(beanInventoryControllerProvider);
    final catalogBeans = beansAsync.value ?? _catalogBeans;
    final isEn = LanguageService.isEnglish;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? 'Smart Brew AI Dial-In' : 'Smart Brew AI Dial-In ☕'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.circle_grid_hex_fill),
            tooltip: 'Matriks Grinder',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GrinderConverterScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeSwitcher(),
            const SizedBox(height: 12),

            // Bean Selector (Catalog vs Custom)
            if (_isCatalogMode)
              RoasteryBeanSelectorCard(
                allBeans: catalogBeans,
                selectedBean: _selectedCatalogBean,
                onBeanSelected: _onCatalogBeanSelected,
                onSwitchToCustom: () {
                  setState(() => _isCatalogMode = false);
                  _recalculate();
                },
              )
            else ...[
              BeanInputSelectorCard(
                beanNameCtrl: _customBeanCtrl,
                selectedRoast: _customRoast,
                selectedProcess: _customProcess,
                popularOrigins: _popularOrigins,
                onRoastChanged: (r) {
                  setState(() => _customRoast = r);
                  _recalculate();
                },
                onProcessChanged: (p) {
                  setState(() => _customProcess = p);
                  _recalculate();
                },
                onRecalculate: _recalculate,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(CupertinoIcons.arrow_2_squarepath, size: 14),
                  label: const Text('Kembali ke Katalog Roastery Resmi', style: TextStyle(fontSize: 11.5)),
                  onPressed: () {
                    setState(() => _isCatalogMode = true);
                    _recalculate();
                  },
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Barista Opinion & Brew Style Tuning
            if (_isCatalogMode)
              BeanBaristaOpinionCard(
                selectedBean: _selectedCatalogBean,
                selectedGoal: _flavorGoal,
                selectedDripper: _dripper,
                onGoalChanged: (goal) {
                  setState(() => _flavorGoal = goal);
                  _recalculate();
                },
                onDripperChanged: (dripper) {
                  setState(() => _dripper = dripper);
                  _recalculate();
                },
              )
            else
              BeanCustomGoalCard(
                selectedGoal: _flavorGoal,
                selectedDripper: _dripper,
                onGoalChanged: (goal) {
                  setState(() => _flavorGoal = goal);
                  _recalculate();
                },
                onDripperChanged: (dripper) {
                  setState(() => _dripper = dripper);
                  _recalculate();
                },
              ),

            const SizedBox(height: 14),

            // AI Roasting Age, Water PPM, & Pouring Paradigm Customizer
            BeanAiCustomizerCard(
              selectedRoastAge: _roastAge,
              selectedWaterProfile: _waterProfile,
              selectedParadigm: _pouringParadigm,
              onRoastAgeChanged: (age) {
                setState(() => _roastAge = age);
                _recalculate();
              },
              onWaterProfileChanged: (water) {
                setState(() => _waterProfile = water);
                _recalculate();
              },
              onParadigmChanged: (paradigm) {
                setState(() => _pouringParadigm = paradigm);
                _recalculate();
              },
              onApplyTweak: _onApplyAiTweak,
            ),

            const SizedBox(height: 14),

            // Dose Slider
            BeanDoseSliderCard(
              dose: _coffeeDose,
              totalWater: _recipe.totalWater,
              brewRatio: _recipe.brewRatio,
              onDoseChanged: (v) {
                setState(() => _coffeeDose = v);
                _recalculate();
              },
            ),

            const SizedBox(height: 16),

            // Recipe Parameters (Grind, Microns, Clicks, Temperature)
            BeanRecipeParameterCard(recipe: _recipe),

            const SizedBox(height: 14),

            // AI Extraction Science Metrics (TDS, EY, Flow rate)
            BeanAiExtractionMetricsCard(
              recipe: _recipe,
              roastAge: _roastAge,
              waterProfile: _waterProfile,
            ),

            const SizedBox(height: 14),

            // Predicted Sensory Radar (5-Axis)
            BeanSensoryRadarCard(recipe: _recipe),

            const SizedBox(height: 14),

            // Pour Schedule & Flow Curve
            BeanPourScheduleCard(recipe: _recipe),

            const SizedBox(height: 24),

            // Action Button: Start Brewing
            ElevatedButton.icon(
              onPressed: _startTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
              icon: const Icon(CupertinoIcons.play_circle_fill, size: 22),
              label: Text(
                isEn ? 'Start Brew with Live Timer ⏱️' : 'Mulai Seduh Resep Ini Sekarang ⏱️',
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                if (!_isCatalogMode) {
                  setState(() => _isCatalogMode = true);
                  _recalculate();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: _isCatalogMode ? AppTheme.primaryBrown : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.checkmark_seal_fill, size: 14, color: _isCatalogMode ? AppTheme.accentGold : Colors.grey),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Katalog (${_catalogBeans.length}+)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: _isCatalogMode ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                if (_isCatalogMode) {
                  setState(() => _isCatalogMode = false);
                  _recalculate();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: !_isCatalogMode ? AppTheme.primaryBrown : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.pencil, size: 14, color: !_isCatalogMode ? AppTheme.accentGold : Colors.grey),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Biji Kustom',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: !_isCatalogMode ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
