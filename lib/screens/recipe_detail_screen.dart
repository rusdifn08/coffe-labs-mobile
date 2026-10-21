import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/barista_utils.dart';
import '../data/brew_visual_catalog.dart';
import '../services/trial_service.dart';
import 'add_recipe_screen.dart';
import 'barista_profile_screen.dart';
import 'brew_timer_screen.dart';
import 'onboarding_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final dynamic recipeData;

  const RecipeDetailScreen({super.key, required this.recipeData});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isFavorite = false;
  late Map<String, dynamic> _recipe;
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
    _baseCoffeeGrams = (_recipe['coffeeWeightGrams'] as int).clamp(1, 200);
    _scaledCoffeeGrams = _baseCoffeeGrams;
    _loadFavorite();
  }

  double get _scaleFactor => _scaledCoffeeGrams / _baseCoffeeGrams;

  Map<String, dynamic> _buildScaledRecipe() {
    if (_scaledCoffeeGrams == _baseCoffeeGrams) return _recipe;
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
    return copy;
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

  void _showGrinderConverterSheet(String rawGrind) {
    final conversions = BaristaUtils.grinderConversions(rawGrind);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Konversi Klik Grinder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            Text(
              'Referensi resep: $rawGrind',
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryBrown, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            ...conversions.entries.map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                    Flexible(
                      child: Text(
                        e.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Map<String, String> _parseBeanInfo(Map<String, dynamic> recipe) {
    final rawBean = (recipe['beanName'] ?? '').toString().trim();
    String name = rawBean;
    String variety = (recipe['variety'] ?? recipe['beanVariety'] ?? '').toString().trim();
    String process = (recipe['process'] ?? recipe['beanProcess'] ?? '').toString().trim();
    String roast = (recipe['roastLevel'] ?? '').toString().trim();

    String extraInfo = '';
    if (rawBean.contains('(') && rawBean.contains(')')) {
      final startIdx = rawBean.indexOf('(');
      final endIdx = rawBean.lastIndexOf(')');
      name = rawBean.substring(0, startIdx).trim();
      extraInfo = rawBean.substring(startIdx + 1, endIdx).trim();

      // Jika formatnya: Varietas • Proses • Roast
      if (extraInfo.contains('•')) {
        final parts = extraInfo.split('•').map((p) => p.trim()).toList();
        if (parts.isNotEmpty && variety.isEmpty) variety = parts[0];
        if (parts.length > 1 && process.isEmpty) process = parts[1];
        if (parts.length > 2 && roast.isEmpty) roast = parts[2];
      }
    }

    final fullContext = '$rawBean $extraInfo ${recipe['description'] ?? ''} ${recipe['title'] ?? ''}'.toLowerCase();

    // 1. Deteksi Proses Kopi Otomatis
    if (process.isEmpty) {
      if (fullContext.contains('wine process') ||
          fullContext.contains('winey') ||
          fullContext.contains('kopi wine') ||
          fullContext.contains('(wine') ||
          fullContext.contains('wine /') ||
          fullContext.contains('fermentasi wine') ||
          (fullContext.contains('wine') && !fullContext.contains('winemaking'))) {
        process = 'Wine Process';
      } else if (fullContext.contains('thermal shock')) {
        process = 'Thermal Shock';
      } else if (fullContext.contains('carbonic') ||
          fullContext.contains('maceration') ||
          fullContext.contains(' cm ') ||
          fullContext.contains('gesha cm') ||
          fullContext.contains('carbonic natural')) {
        if (fullContext.contains('natural')) {
          process = 'Carbonic Maceration Natural';
        } else if (fullContext.contains('washed')) {
          process = 'Carbonic Maceration Washed';
        } else {
          process = 'Carbonic Maceration';
        }
      } else if (fullContext.contains('koji')) {
        process = 'Koji Fermented';
      } else if (fullContext.contains('yeast') ||
          fullContext.contains('co-ferment') ||
          fullContext.contains('fruit ferment') ||
          fullContext.contains('strawberry natural') ||
          fullContext.contains('mossto')) {
        process = 'Yeast / Co-Fermentation';
      } else if (fullContext.contains('wet-hulled') ||
          fullContext.contains('wet hulled') ||
          fullContext.contains('giling basah')) {
        process = 'Wet Hulled (Giling Basah)';
      } else if (fullContext.contains('double anaerobic')) {
        process = 'Double Anaerobic';
      } else if (fullContext.contains('anaerobic') || fullContext.contains('anaerob')) {
        if (fullContext.contains('natural')) {
          process = 'Anaerobic Natural';
        } else if (fullContext.contains('washed')) {
          process = 'Anaerobic Washed';
        } else if (fullContext.contains('honey')) {
          process = 'Anaerobic Honey';
        } else {
          process = 'Anaerobic Fermentation';
        }
      } else if (fullContext.contains('black honey')) {
        process = 'Black Honey';
      } else if (fullContext.contains('red honey')) {
        process = 'Red Honey';
      } else if (fullContext.contains('yellow honey')) {
        process = 'Yellow Honey';
      } else if (fullContext.contains('honey') || fullContext.contains('pulped')) {
        process = 'Honey Process';
      } else if (fullContext.contains('extended natural')) {
        process = 'Extended Natural';
      } else if (fullContext.contains('lactic natural')) {
        process = 'Lactic Natural';
      } else if (fullContext.contains('natural') || fullContext.contains('dry process') || fullContext.contains('sundried')) {
        process = 'Natural Process';
      } else if (fullContext.contains('double washed')) {
        process = 'Double Washed';
      } else if (fullContext.contains('extended washed')) {
        process = 'Extended Washed';
      } else if (fullContext.contains('washed') || fullContext.contains('wet process')) {
        process = 'Washed';
      } else {
        process = 'Washed Process';
      }
    }

    // 2. Deteksi Varietas Kopi Otomatis yang Akurat
    if (variety.isEmpty || variety.toLowerCase().contains('arabica specialty') || variety.toLowerCase().contains('arabica single origin')) {
      if (fullContext.contains('geisha') || fullContext.contains('gesha')) {
        variety = 'Geisha / Gesha';
      } else if (fullContext.contains('pink bourbon')) {
        variety = 'Pink Bourbon';
      } else if (fullContext.contains('red bourbon')) {
        variety = 'Red Bourbon';
      } else if (fullContext.contains('yellow bourbon')) {
        variety = 'Yellow Bourbon';
      } else if (fullContext.contains('bourbon')) {
        variety = 'Bourbon';
      } else if (fullContext.contains('pacamara')) {
        variety = 'Pacamara';
      } else if (fullContext.contains('sl28') || fullContext.contains('sl34') || fullContext.contains('sl-28') || fullContext.contains('sl-34')) {
        variety = 'SL28 / SL34';
      } else if (fullContext.contains('caturra') && fullContext.contains('catuai')) {
        variety = 'Caturra / Catuai';
      } else if (fullContext.contains('caturra')) {
        variety = 'Caturra';
      } else if (fullContext.contains('catuai')) {
        variety = 'Catuai';
      } else if (fullContext.contains('sudan rume') || fullContext.contains('rume sudan')) {
        variety = 'Sudan Rume';
      } else if (fullContext.contains('eugenioides')) {
        variety = 'Coffea Eugenioides';
      } else if (fullContext.contains('wush wush')) {
        variety = 'Wush Wush';
      } else if (fullContext.contains('sidra')) {
        variety = 'Sidra';
      } else if (fullContext.contains('laurina')) {
        variety = 'Laurina';
      } else if (fullContext.contains('castillo')) {
        variety = 'Castillo';
      } else if (fullContext.contains('typica')) {
        variety = 'Typica';
      } else if (fullContext.contains('sigarar utang') || fullContext.contains('timtim') || fullContext.contains('ateng')) {
        variety = 'Sigarar Utang / TimTim';
      } else if (fullContext.contains('s795') || fullContext.contains('s-795') || fullContext.contains('kartika')) {
        variety = 'S-795 / Kartika';
      } else if (fullContext.contains('kopyol')) {
        variety = 'Kopyol';
      } else if (fullContext.contains('heirloom') || fullContext.contains('kurume')) {
        variety = 'Ethiopian Heirloom';
      }
      // Infer berdasarkan Origin Terkenal di Dunia
      else if (fullContext.contains('ethiopia') || fullContext.contains('yirgacheffe') || fullContext.contains('guji') || fullContext.contains('sidama') || fullContext.contains('nekisse')) {
        variety = 'Ethiopian Heirloom';
      } else if (fullContext.contains('kenya') || fullContext.contains('nyeri') || fullContext.contains('kirinyaga')) {
        variety = 'SL28 / SL34';
      } else if (fullContext.contains('panama') || fullContext.contains('boquete') || fullContext.contains('volcan')) {
        variety = 'Panama Geisha';
      } else if (fullContext.contains('colombia') || fullContext.contains('huila') || fullContext.contains('cauca')) {
        variety = 'Castillo / Caturra';
      } else if (fullContext.contains('costa rica') || fullContext.contains('tarrazu')) {
        variety = 'Caturra / Catuai';
      } else if (fullContext.contains('guatemala') || fullContext.contains('antigua')) {
        variety = 'Bourbon / Caturra';
      } else if (fullContext.contains('gayo') || fullContext.contains('aceh')) {
        variety = 'Ateng Super / TimTim';
      } else if (fullContext.contains('toraja') || fullContext.contains('sapan')) {
        variety = 'S-795 / Typica';
      } else if (fullContext.contains('kintamani') || fullContext.contains('bali')) {
        variety = 'Kopyol / S-795';
      } else if (fullContext.contains('flores') || fullContext.contains('bajawa')) {
        variety = 'Kartika / S-795';
      } else if (fullContext.contains('puntang')) {
        variety = 'Red Bourbon / Typica';
      } else if (fullContext.contains('kerinci')) {
        variety = 'Andung Sari / Sigarar Utang';
      } else if (fullContext.contains('latimojong') || fullContext.contains('enrekang')) {
        variety = 'S-795 / Typica';
      } else if (fullContext.contains('halu') || fullContext.contains('kamojang') || fullContext.contains('manglayang') || fullContext.contains('jawa') || fullContext.contains('java')) {
        variety = 'Typica / Sigarar Utang';
      } else if (fullContext.contains('papua') || fullContext.contains('wamena')) {
        variety = 'Typica / Bourbon';
      } else if (fullContext.contains('brazil') || fullContext.contains('brasil')) {
        variety = 'Mundo Novo / Catuai';
      } else {
        variety = 'Single Origin Heirloom';
      }
    }

    if (name.isEmpty) name = 'Single Origin Specialty';

    String processAndRoast = process;
    if (roast.isNotEmpty) {
      final roastFormatted = roast.toLowerCase().contains('roast') ? roast : '$roast Roast';
      processAndRoast = '$process • $roastFormatted';
    }

    return {
      'name': name,
      'variety': variety,
      'process': processAndRoast,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scaledRecipe = _buildScaledRecipe();
    final String title = scaledRecipe['title'] as String;
    final String rawAuthor = scaledRecipe['author'] as String;
    final String authorName = BaristaUtils.cleanName(rawAuthor);
    final String countryCode = BaristaUtils.countryCode(rawAuthor);
    final String description = scaledRecipe['description'] as String;
    final String category = scaledRecipe['category'] as String;
    final String method = scaledRecipe['method'] as String;
    final String grindSize = scaledRecipe['grindSize'] as String;
    final String waterPpm = scaledRecipe['waterPpm'] as String;
    final String tastingNotes = scaledRecipe['tastingNotes'] as String;
    final int coffeeWeight = scaledRecipe['coffeeWeightGrams'] as int;
    final int totalWater = scaledRecipe['totalWaterWeightGrams'] as int;
    final int iceWeight = scaledRecipe['iceWeightGrams'] as int;
    final int waterTemp = scaledRecipe['waterTempCelsius'] as int;
    final int totalTimeSeconds = scaledRecipe['totalTimeSeconds'] as int;
    final String coverImageUrl = scaledRecipe['coverImageUrl'] as String;
    final String authorAvatarUrl = scaledRecipe['authorAvatarUrl'] as String;

    final int totalLiquid = totalWater + iceWeight;
    final String ratio = coffeeWeight > 0 ? '1:${(totalLiquid / coffeeWeight).toStringAsFixed(1)}' : '1:15';

    final List<dynamic> steps = scaledRecipe['steps'] as List<dynamic>;
    final List<String> notesList = tastingNotes
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final List<String> prepChecklist = [
      'Bilas kertas filter (Paper Rinse) & panaskan server',
      'Timbang & giling ${coffeeWeight}g kopi (${BaristaUtils.shortGrindLabel(grindSize)})',
      iceWeight > 0
          ? 'Siapkan ${iceWeight}g es batu di server + ${totalWater}g air panas ($waterTemp°C)'
          : 'Panaskan minimal ${totalWater + 50}ml air hingga suhu $waterTemp°C',
      'Tuang bubuk kopi ke dripper, ratakan bed, dan Tare timbangan ke 0.0g',
    ];

    int cumulativeWater = 0;
    int cumulativeTime = 0;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: AppTheme.primaryBrown,
            elevation: 2,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (countryCode.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Flag.fromString(countryCode, height: 12, width: 17, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  BaristaUtils.buildOfflineImage(
                    coverImageUrl,
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppTheme.bgCream,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(CupertinoIcons.back, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 3.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Duplikat & Modifikasi ke Resep Saya',
                    icon: const Icon(CupertinoIcons.doc_on_doc, color: Colors.white, size: 18),
                    onPressed: () async {
                      final didAdd = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddRecipeScreen(initialRecipe: scaledRecipe),
                        ),
                      );
                      if (didAdd == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Resep berhasil diduplikasi ke My Custom Brews!')),
                        );
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 7.0, bottom: 7.0, right: 12.0, left: 3.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: _isFavorite ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
                    icon: Icon(
                      _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                      size: 20,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
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
                                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(title, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 25, height: 1.2)),
                  const SizedBox(height: 16),

                  // Author Info
                  GestureDetector(
                    onTap: () {
                      final heroTag = 'detail_${BaristaUtils.slugFromAuthor(rawAuthor)}';
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
                            heroTag: 'detail_${BaristaUtils.slugFromAuthor(rawAuthor)}',
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

                  // INTERACTIVE DOSE & PORTION SCALER
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.16)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(CupertinoIcons.slider_horizontal_3, size: 16, color: AppTheme.primaryBrown),
                                SizedBox(width: 6),
                                Text(
                                  'Sesuaikan Dosis Kopi (Auto-Scale)',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                            if (_scaledCoffeeGrams != _baseCoffeeGrams)
                              GestureDetector(
                                onTap: () => setState(() => _scaledCoffeeGrams = _baseCoffeeGrams),
                                child: const Text(
                                  'Reset Asli',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: _scaledCoffeeGrams > 8
                                  ? () => setState(() => _scaledCoffeeGrams--)
                                  : null,
                              icon: const Icon(CupertinoIcons.minus_circle_fill, color: AppTheme.primaryBrown),
                            ),
                            Text(
                              '${_scaledCoffeeGrams}g',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: _scaledCoffeeGrams < 60
                                  ? () => setState(() => _scaledCoffeeGrams++)
                                  : null,
                              icon: const Icon(CupertinoIcons.plus_circle_fill, color: AppTheme.primaryBrown),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _dosePresets.map((dose) {
                                    final selected = _scaledCoffeeGrams == dose;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: GestureDetector(
                                        onTap: () => setState(() => _scaledCoffeeGrams = dose),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: selected ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: selected
                                                  ? AppTheme.primaryBrown
                                                  : AppTheme.primaryBrown.withValues(alpha: 0.2),
                                            ),
                                          ),
                                          child: Text(
                                            '${dose}g',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: selected ? Colors.white : AppTheme.textDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Technical Parameters Grid (2x3)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildParamItem(CupertinoIcons.circle_bottomthird_split, 'Dose Kopi', '${coffeeWeight}g'),
                            _buildParamItem(
                              CupertinoIcons.drop_fill,
                              iceWeight > 0 ? 'Air + Es' : 'Total Air',
                              iceWeight > 0 ? '${totalWater}g + ${iceWeight}g' : '${totalWater}g',
                            ),
                            _buildParamItem(CupertinoIcons.divide, 'Rasio', ratio),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildParamItem(CupertinoIcons.thermometer, 'Suhu Air', '$waterTemp°C'),
                            _buildParamItem(CupertinoIcons.timer, 'Total Waktu', _formatTime(totalTimeSeconds)),
                            _buildParamItem(CupertinoIcons.drop, 'Mineral Air', waterPpm),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bean & Grind Details Card + Grinder Converter Button
                  Builder(
                    builder: (_) {
                      final shortGrind = BaristaUtils.shortGrindLabel(grindSize);
                      final beanInfo = _parseBeanInfo(scaledRecipe);
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

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBrown.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Gilingan Row (Hanya label ukuran misal Medium + Tombol Konversi Grinder)
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(CupertinoIcons.circle_grid_hex, size: 19, color: AppTheme.primaryBrown),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    shortGrind,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _showGrinderConverterSheet(grindSize),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentAmber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.3)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(CupertinoIcons.compass, size: 13, color: AppTheme.primaryBrown),
                                        SizedBox(width: 5),
                                        Text(
                                          'Konversi Grinder',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryBrown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: Color(0xFFF2ECE4)),
                            ),

                            // 2. Alat Dripper Row
                            Row(
                              children: [
                                DripperGraphicBadge(
                                  item: BrewVisualCatalog.matchDripper(method),
                                  size: 36,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    method,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: Color(0xFFF2ECE4)),
                            ),

                            // 3. Biji Kopi Row (Icon Biji Kopi)
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.coffee_rounded, size: 20, color: AppTheme.primaryBrown),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    beanNameOnly,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: Color(0xFFF2ECE4)),
                            ),

                            // 4. Varietas Row (Icon Daun / Tanaman Varietas)
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.eco_rounded, size: 20, color: Color(0xFF2E7D32)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    variety,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: Color(0xFFF2ECE4)),
                            ),

                            // 5. Proses Row (Icon Proses Pasca-Panen: Air/Matahari/Lab Fermentasi)
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE65100).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(processIcon, size: 20, color: const Color(0xFFD84315)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    process,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // 6. Tasting Notes Row
                            if (notesList.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(height: 1, color: Color(0xFFF2ECE4)),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.sparkles, size: 14, color: AppTheme.accentAmber),
                                    SizedBox(width: 6),
                                    Text(
                                      'Profil Rasa (Tasting Notes)',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: notesList
                                    .map((note) => FlavorNoteVisualBadge(noteText: note))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // INTERACTIVE PRE-BREW CHECKLIST (DEFAULT HIDDEN DENGAN LOGO MATA)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _showPrepChecklist = !_showPrepChecklist),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(CupertinoIcons.checkmark_seal_fill, size: 16, color: AppTheme.primaryBrown),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Checklist Persiapan Sebelum Brew',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBrown.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${_checkedPrep.length}/${prepChecklist.length}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    _showPrepChecklist ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                                    size: 20,
                                    color: _showPrepChecklist ? AppTheme.primaryBrown : AppTheme.textMuted,
                                  ),
                                  tooltip: _showPrepChecklist ? 'Sembunyikan Persiapan' : 'Tampilkan Persiapan',
                                  onPressed: () => setState(() => _showPrepChecklist = !_showPrepChecklist),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_showPrepChecklist) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          ...prepChecklist.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final text = entry.value;
                            final done = _checkedPrep.contains(idx);
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (done) {
                                    _checkedPrep.remove(idx);
                                  } else {
                                    _checkedPrep.add(idx);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    Icon(
                                      done ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                                      size: 18,
                                      color: done ? Colors.green : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: done ? AppTheme.textMuted : AppTheme.textDark,
                                          decoration: done ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description / Philosophy
                  Text('Filosofi & Teknik Ekstraksi', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(color: AppTheme.textDark, height: 1.6, fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  // Pour Steps
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tahapan Seduh', style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        '${steps.length} Tahap',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBrown),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (iceWeight > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.snow, color: Colors.blueAccent, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Persiapan Japanese Iced: Masukkan ${iceWeight}g es batu ke dalam server sebelum memulai tuangan air panas (${totalWater}g).',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ...steps.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final Map<String, dynamic> s = Map<String, dynamic>.from(entry.value as Map);
                    final int waterAdded = (s['waterAddedGrams'] ?? s['waterGrams'] ?? 0) as int;
                    final int duration = (s['durationSeconds'] ?? s['timeSeconds'] ?? 30) as int;
                    final int startSec = cumulativeTime;
                    cumulativeTime += duration;
                    final int endSec = cumulativeTime;
                    cumulativeWater += waterAdded;
                    final int targetScale = cumulativeWater;
                    final String instruction = (s['instruction'] ?? '').toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryBrown,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${idx + 1}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s['title']?.toString() ?? 'Step ${idx + 1}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_formatTime(startSec)} → ${_formatTime(endSec)} (${duration}s)',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: waterAdded > 0
                                      ? Colors.blueAccent.withValues(alpha: 0.1)
                                      : AppTheme.accentAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  waterAdded > 0 ? '+${waterAdded}g → ${targetScale}g' : 'Imersi / Tunggu',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: waterAdded > 0 ? Colors.blueAccent : AppTheme.primaryBrown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (instruction.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              instruction,
                              style: const TextStyle(fontSize: 12.5, color: AppTheme.textDark, height: 1.45),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _startBrewing,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(CupertinoIcons.play_fill, color: Colors.white, size: 20),
            label: Text(
              _scaledCoffeeGrams != _baseCoffeeGrams
                  ? 'Mulai Brew (${coffeeWeight}g → ${totalWater}g Air)'
                  : 'Mulai Guided Brewing',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParamItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryBrown, size: 20),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}
