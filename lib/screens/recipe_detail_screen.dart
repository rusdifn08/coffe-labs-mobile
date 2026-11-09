import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/recipes/controllers/recipe_list_controller.dart';
import '../features/recipe_detail/widgets/recipe_detail_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import '../services/coffee_translator.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import '../services/trial_service.dart';
import 'barista_profile_screen.dart';
import 'brew_timer_screen.dart';
import 'onboarding_screen.dart';
import '../features/recipe_detail/utils/recipe_attribute_deducer.dart';
import '../features/recipe_detail/widgets/grinder_converter_sheet.dart';
import '../features/recipe_detail/widgets/recipe_params_summary.dart';
import '../features/recipe_detail/widgets/recipe_specs_card.dart';
import '../features/recipe_detail/widgets/recipe_checklist_card.dart';
import '../features/recipe_detail/widgets/recipe_steps_list.dart';
import '../features/recipe_detail/widgets/recipe_detail_bottom_bar.dart';
import '../features/recipe_detail/widgets/recipe_dose_scaler.dart';
import '../features/masterclass/screens/pre_brew_masterclass_screen.dart';
import '../features/bean_scanner/controllers/selected_brew_bean_controller.dart';
import '../features/bean_scanner/models/resolved_coffee_bean.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final dynamic recipeData;

  const RecipeDetailScreen({super.key, required this.recipeData});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late Map<String, dynamic> _recipe;
  bool _isFavorite = false;
  late int _baseCoffeeGrams;
  late int _scaledCoffeeGrams;
  final Set<int> _checkedPrep = {};
  bool _showPrepChecklist = false;

  static const List<int> _dosePresets = [12, 15, 18, 20, 24, 30];

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipeData is Map
        ? ApiService.sanitizeRecipe(widget.recipeData as Map)
        : ApiService.sanitizeRecipe({});
    _baseCoffeeGrams = ((_recipe['coffeeWeightGrams'] as num?)?.round() ?? 15).clamp(1, 200);
    _scaledCoffeeGrams = _baseCoffeeGrams;
    _loadFavorite();
  }

  double get _scaleFactor => _scaledCoffeeGrams / _baseCoffeeGrams;

  /// Menyuntikkan identitas biji kopi hasil scan kamera (Smart Coffee Bag Scanner)
  /// ke dalam resep, sehingga header Brew Timer otomatis menampilkan nama kopi
  /// yang benar-benar dipindai (mis. "Halu Banana", "Puntang Wine").
  Map<String, dynamic> _applyScannedBeanIdentity(Map<String, dynamic> recipe) {
    final ResolvedCoffeeBean? scanned = ref.read(selectedBrewBeanProvider);
    if (scanned == null) return recipe;

    final copy = Map<String, dynamic>.from(recipe);
    final cleanBeanName = scanned.beanName.trim();
    if (cleanBeanName.isNotEmpty && cleanBeanName != 'Specialty Coffee') {
      copy['beanName'] = cleanBeanName;
      // Simpan juga untuk pencarian judul/atribusi pada deducer
      copy['origin'] = scanned.origin;
    }
    if (scanned.variety.trim().isNotEmpty) {
      copy['variety'] = scanned.variety;
    }
    if (scanned.process.trim().isNotEmpty) {
      copy['process'] = scanned.process;
    }
    if (scanned.roasteryName.trim().isNotEmpty && scanned.roasteryName != 'Specialty Roastery') {
      copy['scannedRoastery'] = scanned.roasteryName;
    }
    copy['scannedBeanName'] = cleanBeanName;
    copy['scannedProcess'] = scanned.process;
    copy['scannedVariety'] = scanned.variety;
    return copy;
  }

  Map<String, dynamic> _buildScaledRecipe() {
    Map<String, dynamic> source = _recipe;
    if (_scaledCoffeeGrams != _baseCoffeeGrams) {
      final factor = _scaleFactor;
      final baseWater = _recipe['totalWaterWeightGrams'] as int;
      final baseIce = _recipe['iceWeightGrams'] as int;
      final rawSteps = _recipe['steps'] as List<dynamic>;

      int sumStepWater = 0;
      final List<Map<String, dynamic>> scaledSteps = [];
      for (final s in rawSteps) {
        final map = Map<String, dynamic>.from(s as Map);
        final w = (map['waterAddedGrams'] ?? map['waterGrams'] ?? 0) as int;
        final scaledW = (w * factor).round();
        sumStepWater += scaledW;
        map['waterAddedGrams'] = scaledW;
        map['waterGrams'] = scaledW;
        map['cumulativeWaterGrams'] = sumStepWater;
        scaledSteps.add(map);
      }

      final scaledTotalWater = sumStepWater > 0 ? sumStepWater : (baseWater * factor).round();
      final scaledIce = (baseIce * factor).round();

      final copy = Map<String, dynamic>.from(_recipe);
      copy['coffeeWeightGrams'] = _scaledCoffeeGrams;
      copy['totalWaterWeightGrams'] = scaledTotalWater;
      copy['iceWeightGrams'] = scaledIce;
      copy['steps'] = scaledSteps;
      source = copy;
    }

    return _applyScannedBeanIdentity(source);
  }

  Future<void> _startBrewing() async {
    final canBrew = await TrialService.canBrew();
    if (!mounted) return;
    if (!canBrew) {
      final remaining = await TrialService.getRemainingLockDuration();
      if (!mounted) return;
      final days = remaining != null ? (remaining.inDays + 1) : 7;
      TrialService.showLockedDialog(
        context: context,
        title: 'Batas Seduh Trial Tercapai',
        message: 'Anda telah mencapai batas 10 kali seduh pada mode trial. Fitur seduh terkunci selama 1 minggu ($days hari tersisa).\n\nSilakan login atau daftar akun resmi yang disetujui Admin untuk seduh tanpa batas!',
        onLoginTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
        },
      );
      return;
    }
    final scaled = _buildScaledRecipe();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrewTimerScreen(recipeData: scaled)),
    );
  }

  Future<void> _loadFavorite() async {
    final id = _recipe['id'] as int?;
    if (id == null) return;
    final fav = await ApiService.isFavorite(id);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final id = _recipe['id'] as int?;
    if (id == null) return;
    await ApiService.toggleFavorite(id);
    setState(() => _isFavorite = !_isFavorite);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final favIds = ref.watch(favoriteIdsProvider).value ?? <int>{};
    final bool isFav = favIds.contains(_recipe['id'] as int? ?? -1);
    final scaledRecipe = _buildScaledRecipe();
    final String rawTitle = scaledRecipe['title'] as String;
    final String rawAuthor = scaledRecipe['author'] as String;
    final String authorName = BaristaUtils.cleanName(rawAuthor);
    final String countryCode = BaristaUtils.countryCode(rawAuthor);
    final String description = scaledRecipe['description'] as String;
    final String category = scaledRecipe['category'] as String;
    final String method = scaledRecipe['method'] as String;
    final String grindSize = scaledRecipe['grindSize'] as String;
    final String waterPpm = scaledRecipe['waterPpm'] as String;
    final String tastingNotes = scaledRecipe['tastingNotes'] as String;
    final num coffeeWeight = (scaledRecipe['coffeeWeightGrams'] as num?) ?? 15;
    final int totalWater = (scaledRecipe['totalWaterWeightGrams'] as num?)?.toInt() ?? 225;
    final int iceWeight = (scaledRecipe['iceWeightGrams'] as num?)?.toInt() ?? 0;
    final int waterTemp = (scaledRecipe['waterTempCelsius'] as num?)?.toInt() ?? 92;
    final int totalTimeSeconds = (scaledRecipe['totalTimeSeconds'] as num?)?.toInt() ?? 130;
    final String coverImageUrl = BaristaUtils.coverUrlFromRecipe(scaledRecipe);
    final String authorAvatarUrl = BaristaUtils.imageUrlFromRecipe(scaledRecipe);

    final int totalLiquid = totalWater + iceWeight;
    final String ratio = coffeeWeight > 0 ? '1:${(totalLiquid / coffeeWeight).toStringAsFixed(1)}' : '-';

    final List<dynamic> steps = scaledRecipe['steps'] as List<dynamic>;
    final List<String> notesList = tastingNotes
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final bool isEn = LanguageService.isEnglish;
    final String title = isEn ? CoffeeTranslator.translateTitle(rawTitle) : rawTitle;

    final List<String> prepChecklist = [
      isEn
          ? 'Rinse paper filter (Paper Rinse) & preheat server'
          : 'Bilas kertas filter (Paper Rinse) & panaskan server',
      isEn
          ? 'Weigh & grind ${coffeeWeight}g coffee (${BaristaUtils.shortGrindLabel(grindSize)})'
          : 'Timbang & giling ${coffeeWeight}g kopi (${BaristaUtils.shortGrindLabel(grindSize)})',
      iceWeight > 0
          ? (isEn
              ? 'Prepare ${iceWeight}g ice in server + ${totalWater}g hot water ($waterTemp°C)'
              : 'Siapkan ${iceWeight}g es batu di server + ${totalWater}g air panas ($waterTemp°C)')
          : (isEn
              ? 'Heat at least ${totalWater + 50}ml water to $waterTemp°C'
              : 'Panaskan minimal ${totalWater + 50}ml air hingga suhu $waterTemp°C'),
      isEn
          ? 'Add grounds to dripper, flatten bed, and Tare scale to 0.0g'
          : 'Tuang bubuk kopi ke dripper, ratakan bed, dan Tare timbangan ke 0.0g',
    ];

    final beanInfo = RecipeAttributeDeducer.parseBeanInfo(scaledRecipe);
    final beanNameOnly = beanInfo['name']!;
    final variety = beanInfo['variety']!;
    final process = beanInfo['process']!;

    IconData processIcon = Icons.water_drop_rounded;
    final pLower = process.toLowerCase();
    if (pLower.contains('wine')) {
      processIcon = Icons.wine_bar_rounded;
    } else if (pLower.contains('thermal')) {
      processIcon = Icons.whatshot_rounded;
    } else if (pLower.contains('anaerob') ||
        pLower.contains('ferment') ||
        pLower.contains('yeast') ||
        pLower.contains('inocul') ||
        pLower.contains('koji') ||
        pLower.contains('carbonic') ||
        pLower.contains('maceration')) {
      processIcon = Icons.science_rounded;
    } else if (pLower.contains('wet hulled') || pLower.contains('giling basah')) {
      processIcon = Icons.eco_rounded;
    } else if (pLower.contains('natural') || pLower.contains('sun') || pLower.contains('dry')) {
      processIcon = Icons.wb_sunny_rounded;
    } else if (pLower.contains('honey') || pLower.contains('pulped')) {
      processIcon = Icons.bubble_chart_rounded;
    }

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: CustomScrollView(
        slivers: [
          RecipeDetailAppBar(
            coverImageUrl: coverImageUrl,
            authorName: authorName,
            countryCode: countryCode,
            isFavorite: isFav,
            scaledRecipe: scaledRecipe,
            onToggleFavorite: _toggleFavorite,
                    ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(color: AppTheme.primaryBrown, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          method,
                          style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                      if (iceWeight > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(CupertinoIcons.snow, size: 13, color: Colors.blueAccent),
                              const SizedBox(width: 4),
                              Text(
                                'Es ${iceWeight}g',
                                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(title, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 25, height: 1.25)),
                  const SizedBox(height: 16),

                  // Author Info
                  GestureDetector(
                    onTap: () {
                      final recipeId = widget.recipeData['id']?.toString() ?? 'recipe';
                      final heroTag = 'detail_${BaristaUtils.slugFromAuthor(rawAuthor)}_$recipeId';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BaristaProfileScreen(
                            rawAuthor: rawAuthor,
                            imageUrl: authorAvatarUrl,
                            coverImageUrl: coverImageUrl,
                            heroTag: heroTag,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        children: [
                          BaristaAvatar(
                            imageUrl: authorAvatarUrl,
                            radius: 24,
                            heroTag: 'detail_${BaristaUtils.slugFromAuthor(rawAuthor)}_${widget.recipeData['id'] ?? "recipe"}',
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Brewer / Recipe Creator', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        authorName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (countryCode.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Flag.fromString(countryCode, height: 13, width: 18),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(CupertinoIcons.chevron_right, size: 16, color: AppTheme.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Interactive Dose Scaler
                  RecipeDoseScaler(
                    scaledCoffeeGrams: _scaledCoffeeGrams,
                    baseCoffeeGrams: _baseCoffeeGrams,
                    dosePresets: _dosePresets,
                    onDoseChanged: (dose) => setState(() => _scaledCoffeeGrams = dose),
                    onReset: () => setState(() => _scaledCoffeeGrams = _baseCoffeeGrams),
                  ),
                  const SizedBox(height: 16),

                  // Technical Parameters Grid (2x3)
                  RecipeParamsSummary(
                    coffeeWeight: coffeeWeight,
                    totalWater: totalWater,
                    iceWeight: iceWeight,
                    ratio: ratio,
                    waterTemp: waterTemp,
                    totalTimeSeconds: totalTimeSeconds,
                    waterPpm: waterPpm,
                    formatTime: _formatTime,
                  ),
                  const SizedBox(height: 16),

                  // Bean & Grind Details Card + Grinder Converter Button
                  RecipeSpecsCard(
                    grindSize: grindSize,
                    method: method,
                    beanNameOnly: beanNameOnly,
                    variety: variety,
                    process: process,
                    processIcon: processIcon,
                    notesList: notesList,
                    onGrinderConverterPressed: () => GrinderConverterSheet.show(context, grindSize),
                  ),
                  const SizedBox(height: 16),

                  // Interactive Pre-Brew Preparation Checklist
                  RecipeChecklistCard(
                    showPrepChecklist: _showPrepChecklist,
                    checkedPrep: _checkedPrep,
                    prepChecklist: prepChecklist,
                    onToggleExpand: () => setState(() => _showPrepChecklist = !_showPrepChecklist),
                    onToggleItem: (idx) {
                      setState(() {
                        if (_checkedPrep.contains(idx)) {
                          _checkedPrep.remove(idx);
                        } else {
                          _checkedPrep.add(idx);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Description, Philosophy & Pour Steps
                  RecipeStepsList(
                    steps: steps,
                    iceWeight: iceWeight,
                    totalWater: totalWater,
                    description: description,
                    formatTime: _formatTime,
                    method: method,
                    category: category,
                    title: title,
                    ingredients: scaledRecipe['ingredients'] as List?,
                    coffeeWeight: _scaledCoffeeGrams,
                  ),

                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: RecipeDetailBottomBar(
        scaledRecipe: scaledRecipe,
        scaledCoffeeGrams: _scaledCoffeeGrams,
        baseCoffeeGrams: _baseCoffeeGrams,
        coffeeWeight: coffeeWeight,
        totalWater: totalWater,
        onStartBrew: _startBrewing,
        onOpenMasterclass: () => PreBrewMasterclassScreen.show(
          context: context,
          recipeData: scaledRecipe,
        ),
      ),
    );
  }
}
