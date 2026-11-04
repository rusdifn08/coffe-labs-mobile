import '../../brew/timer/utils/brew_method_helper.dart';
import '../../brew/tts/voice_text_normalizer.dart';
import '../models/recipe_walkthrough_step.dart';

/// Service delivering Pre-Brew Masterclasses for complex brewing methods.
/// Includes championship walkthroughs (WBrC 2026 Sandwich Technique, Tetsu Kasuya 4:6)
/// and method-aware dynamic generators tailored to every recipe in the catalog.
class MasterclassDataService {
  /// Masterclass for WBrC 2026 Sandwich Technique (Double Filter & Separated Grinds)
  static final RecipeMasterclass wbrcSandwichTechnique = RecipeMasterclass(
    recipeId: 'wbrc_2026_sandwich',
    title: 'WBrC 2026 Championship Sandwich Technique',
    techniqueName: 'Double Filter Sandwich Technique',
    brewerName: 'WBrC Innovation Lab',
    recommendedDripper: 'Hario V60 / Orea V4 Flat Bottom',
    methodFamilyName: 'sandwich',
    coffeeGrams: 20,
    totalWaterGrams: 300,
    waterTempCelsius: 93,
    grindSize: 'Dual Sieve 400µm & 850µm',
    overview:
        'Teknik kejuaraan dunia menggunakan dua lapis kertas saring terpisah untuk memisahkan partikel halus (fines) di dasar dan bubuk kasar (coarse) di atas, menghasilkan clean cup ekstrem tanpa channeling.',
    steps: const [
      RecipeWalkthroughStep(
        stepIndex: 0,
        title: '1. Pemisahan Fines & Coarse',
        phaseName: 'Persiapan Bubuk',
        ttsText:
            'Selamat datang di Masterclass Sandwich Technique. Langkah pertama, pisahkan bubuk kopi menggunakan ayakan Kruve. Pisahkan 5 gram bubuk halus atau fines 400 mikron, dan 15 gram bubuk kasar 850 mikron.',
        visualCues: [
          'Gunakan saringan Kruve 400µm & 850µm',
          'Pisahkan 5g fines untuk lapisan dasar & 15g coarse untuk atas',
        ],
        animationState: 'fines_separation',
        durationSeconds: 12,
        coffeeGrams: 20,
        totalWaterGrams: 300,
        waterTempCelsius: 93,
        grindLabel: '400µm + 850µm',
      ),
      RecipeWalkthroughStep(
        stepIndex: 1,
        title: '2. Pemasangan Filter Pertama',
        phaseName: 'Setup Dripper',
        ttsText:
            'Pasang kertas filter pertama di dasar dripper. Bilas kertas dengan air panas untuk menghilangkan aroma kertas saring dan memanaskan suhu dripper secara merata.',
        visualCues: [
          'Pasang kertas saring pertama di dasar dripper',
          'Bilas air panas 93°C secara merata lalu buang air bilasan',
        ],
        animationState: 'first_filter',
        durationSeconds: 10,
        coffeeGrams: 20,
        totalWaterGrams: 300,
        waterTempCelsius: 93,
      ),
      RecipeWalkthroughStep(
        stepIndex: 2,
        title: '3. Peletakan Lapisan Dasar Fines',
        phaseName: 'Dosing Dasar',
        ttsText:
            'Tuangkan 5 gram bubuk fines secara merata di atas filter pertama. Ratakan dengan jarum WDT agar tidak ada gumpalan mikro yang memicu channeling ekstraksi.',
        visualCues: [
          'Tuang 5g fines di dasar filter pertama',
          'Ratakan permukaan dengan jarum WDT di seluruh dasar',
        ],
        animationState: 'fines_bed',
        durationSeconds: 11,
        coffeeGrams: 5,
        totalWaterGrams: 300,
        waterTempCelsius: 93,
      ),
      RecipeWalkthroughStep(
        stepIndex: 3,
        title: '4. Filter Kedua (Lapisan Sandwich)',
        phaseName: 'Sandwich Barrier',
        ttsText:
            'Letakkan filter kertas kedua tepat di atas bubuk fines. Filter kedua ini berfungsi sebagai sekat pelindung agar partikel halus tidak terangkat naik saat air panas dituangkan.',
        visualCues: [
          'Letakkan kertas saring bundar kedua di atas fines',
          'Mengunci fines agar tidak menyumbat pori-pori atas',
        ],
        animationState: 'second_filter',
        durationSeconds: 11,
        coffeeGrams: 5,
        totalWaterGrams: 300,
        waterTempCelsius: 93,
      ),
      RecipeWalkthroughStep(
        stepIndex: 4,
        title: '5. Lapisan Bubuk Kasar (Coarse Bed)',
        phaseName: 'Dosing Atas',
        ttsText:
            'Sekarang, tuangkan 15 gram bubuk kasar di atas filter kedua. Anda kini memiliki konstruksi sandwich dua tingkat dengan permeabilitas aliran air yang sangat stabil.',
        visualCues: [
          'Tuangkan 15g bubuk kasar di atas filter kedua',
          'Konstruksi sandwich siap menerima tuangan air',
        ],
        animationState: 'coarse_bed',
        durationSeconds: 12,
        coffeeGrams: 20,
        totalWaterGrams: 300,
        waterTempCelsius: 93,
      ),
      RecipeWalkthroughStep(
        stepIndex: 5,
        title: '6. Teknik Seduh Suhu Ganda',
        phaseName: 'Ekstraksi Dual-Kettle',
        ttsText:
            'Mulai seduh dengan air 93 derajat celcius pada tuangan pertama untuk mengekstrak aroma floral, lalu lanjutkan air 88 derajat celcius pada tuangan akhir untuk memaksimalkan rasa manis tanpa kepahitan.',
        visualCues: [
          'Tuangan awal 93°C untuk ekstraksi aroma volatil',
          'Tuangan akhir 88°C untuk mengunci rasa manis karamel',
        ],
        animationState: 'spiral_pour',
        stepWaterGrams: 300,
        cumulativeWaterGrams: 300,
        totalWaterGrams: 300,
        waterTempCelsius: 93,
        coffeeGrams: 20,
        durationSeconds: 14,
        autoAdvance: false,
      ),
    ],
  );

  /// Masterclass for Tetsu Kasuya 4:6 Method
  static final RecipeMasterclass tetsuKasuya46Method = RecipeMasterclass(
    recipeId: 'tetsu_kasuya_46',
    title: 'Tetsu Kasuya 4:6 Method Masterclass',
    techniqueName: 'Dynamic 4:6 Ratio Separation',
    brewerName: 'Tetsu Kasuya (World Brewers Cup Champion)',
    recommendedDripper: 'Hario V60 Ceramic / Kasuya Model',
    methodFamilyName: 'pourOver',
    coffeeGrams: 20,
    totalWaterGrams: 300,
    waterTempCelsius: 92,
    grindSize: 'Coarse 1000 µm',
    overview:
        'Konsep revolusioner membagi air menjadi 40% di awal untuk mengatur rasa manis dan asam, serta 60% di akhir untuk mengontrol ketebalan body kopi.',
    steps: const [
      RecipeWalkthroughStep(
        stepIndex: 0,
        title: '1. Konsep Rasio 40% & 60%',
        phaseName: 'Teori 4:6',
        ttsText:
            'Metode 4 banding 6 membagi total 300 mililiter air menjadi dua fase: 40 persen pertama yaitu 120 mililiter untuk mengatur keasaman dan kemanisan, serta 60 persen kedua yaitu 180 mililiter untuk menentukan ketebalan bodi cangkir.',
        visualCues: [
          'Total 300ml air dibagi rasio 40% (120ml) & 60% (180ml)',
          'Ukuran gilingan kasar (coarse 1000µm) seperti garam laut',
        ],
        animationState: 'grind_calibrate',
        coffeeGrams: 20,
        totalWaterGrams: 300,
        waterTempCelsius: 92,
        grindLabel: 'Coarse 1000µm',
        durationSeconds: 12,
      ),
      RecipeWalkthroughStep(
        stepIndex: 1,
        title: '2. Tuangan Pertama: Acidity Bloom',
        phaseName: 'Fase 40% (Tuangan 1)',
        ttsText:
            'Tuangan pertama sebanyak 50 gram air bersuhu 92 derajat celcius menentukan tingkat keasaman segar. Biarkan blooming selama 45 detik hingga seluruh air tiris.',
        visualCues: [
          'Tuang 50g air suhu 92°C spiral memutar (Target: 50g)',
          'Biarkan blooming hingga menit 0:45 sampai tiris',
        ],
        animationState: 'bloom_pour',
        stepWaterGrams: 50,
        cumulativeWaterGrams: 50,
        totalWaterGrams: 300,
        waterTempCelsius: 92,
        coffeeGrams: 20,
        durationSeconds: 12,
      ),
      RecipeWalkthroughStep(
        stepIndex: 2,
        title: '3. Tuangan Kedua: Sweetness Balance',
        phaseName: 'Fase 40% (Tuangan 2)',
        ttsText:
            'Tuang 70 gram air pada menit 0:45 hingga timbangan mencapai 120 gram. Tuangan kedua yang lebih besar ini mengunci kemanisan fruktosa alami kopi.',
        visualCues: [
          'Tuang +70g air saat bubuk mulai tampak kering',
          'Total air pada server mencapai 120g (Fase 40% selesai)',
        ],
        animationState: 'pulse_46_pour',
        stepWaterGrams: 70,
        cumulativeWaterGrams: 120,
        totalWaterGrams: 300,
        waterTempCelsius: 92,
        coffeeGrams: 20,
        durationSeconds: 12,
      ),
      RecipeWalkthroughStep(
        stepIndex: 3,
        title: '4. Fase 60%: Body & Strength',
        phaseName: 'Fase 60% (3 Tuangan)',
        ttsText:
            'Sisa 180 gram air dibagi rata menjadi tiga kali tuangan masing-masing 60 gram hingga total mencapai 300 gram. Tiga tuangan ini menghasilkan bodi kopi yang bulat, tebal, dan seimbang.',
        visualCues: [
          'Bagi 180g menjadi 3 tuangan masing-masing +60g (180g, 240g, 300g)',
          'Tunggu air tiris sebelum setiap tuangan berikutnya',
        ],
        animationState: 'pulse_46_pour',
        stepWaterGrams: 180,
        cumulativeWaterGrams: 300,
        totalWaterGrams: 300,
        waterTempCelsius: 92,
        coffeeGrams: 20,
        durationSeconds: 13,
        autoAdvance: false,
      ),
    ],
  );

  /// Resolves a tailored, method-specific Pre-Brew Masterclass for any recipe.
  static RecipeMasterclass getMasterclassForRecipe(Map<String, dynamic> recipe) {
    final title = (recipe['title'] ?? '').toString().toLowerCase();
    final method = (recipe['method'] ?? '').toString().toLowerCase();
    final description = (recipe['description'] ?? '').toString().toLowerCase();

    if (title.contains('sandwich') || description.contains('sandwich') || method.contains('sandwich')) {
      return wbrcSandwichTechnique;
    }
    if (title.contains('4:6') || title.contains('kasuya') || description.contains('4:6') || method.contains('4:6')) {
      return tetsuKasuya46Method;
    }

    final family = BrewMethodHelper.detectFamily(
      method: recipe['method']?.toString(),
      category: recipe['category']?.toString(),
    );

    final recipeTitle = (recipe['title'] ?? 'Resep Spesialti').toString();
    final brewer = (recipe['brewer'] ?? 'Coffee Labs Master Barista').toString();
    final methodLabel = (recipe['method'] ?? family.label).toString();
    final num coffeeGrams = (recipe['coffeeWeightGrams'] is num) ? (recipe['coffeeWeightGrams'] as num) : 15;
    final int waterGrams = (recipe['totalWaterWeightGrams'] is num) ? (recipe['totalWaterWeightGrams'] as num).toInt() : 225;
    final int waterTemp = (recipe['waterTempCelsius'] is num) ? (recipe['waterTempCelsius'] as num).toInt() : 91;
    final int iceGrams = (recipe['iceWeightGrams'] is num) ? (recipe['iceWeightGrams'] as num).toInt() : 0;
    final String grind = (recipe['grindSize'] ?? 'Medium 900 µm').toString();
    final String spokenGrind = VoiceTextNormalizer.normalizeInstruction(grind);
    final rawSteps = (recipe['steps'] as List<dynamic>?) ?? [];

    final List<RecipeWalkthroughStep> steps = [];
    int sIdx = 0;

    // 1. Method-Specific Preparation Step
    String prepAnim = 'grind_calibrate';
    if (family == BrewMethodFamily.mokaPot) prepAnim = 'moka_boiler_prep';
    if (family == BrewMethodFamily.espresso) prepAnim = 'espresso_puck_prep';
    if (family == BrewMethodFamily.syphon) prepAnim = 'syphon_vacuum';

    steps.add(RecipeWalkthroughStep(
      stepIndex: sIdx++,
      title: '1. Persiapan & Kalibrasi Gilingan',
      phaseName: 'Kalibrasi Dosis',
      ttsText:
          'Selamat datang di Masterclass $recipeTitle. Timbang $coffeeGrams gram biji kopi dengan gilingan $spokenGrind, serta siapkan $waterGrams mililiter air pada suhu $waterTemp derajat celcius.',
      visualCues: [
        'Timbang $coffeeGrams gram biji kopi secara presisi',
        'Atur grinder pada ukuran $grind & siapkan air $waterTemp°C',
      ],
      animationState: prepAnim,
      durationSeconds: 11,
      coffeeGrams: coffeeGrams,
      totalWaterGrams: waterGrams,
      waterTempCelsius: waterTemp,
      grindLabel: grind,
    ));

    // 2. Method-Specific Equipment Setup Step
    steps.add(_buildEquipmentStep(
      sIdx: sIdx++,
      family: family,
      methodLabel: methodLabel,
      waterGrams: waterGrams,
      waterTemp: waterTemp,
      iceGrams: iceGrams,
      coffeeGrams: coffeeGrams,
      grind: grind,
    ));

    // 3. Recipe-Specific Extraction Steps (mapped directly from recipe['steps'])
    int cumWater = 0;
    for (int i = 0; i < rawSteps.length; i++) {
      final s = rawSteps[i];
      if (s is Map) {
        final rawStepTitle = (s['title'] ?? 'Tahap ${i + 1}').toString();
        final cleanStepTitle = rawStepTitle.replaceAll(RegExp(r'^\d+\.\s*'), '').trim();
        final instruction = (s['instruction'] ?? '').toString();
        final int stepWater = ((s['waterAddedGrams'] ?? s['waterGrams'] ?? 0) as num).toInt();
        cumWater += stepWater;
        final int dur = ((s['durationSeconds'] ?? s['timeSeconds'] ?? 30) as num).toInt();

        final animState = _resolveStepAnimationState(
          family: family,
          stepIndexInRecipe: i,
          recipeTitle: title,
          stepTitle: cleanStepTitle.toLowerCase(),
          instruction: instruction.toLowerCase(),
          stepWater: stepWater,
        );

        final spokenBody = VoiceTextNormalizer.buildStepPrompt(
          title: cleanStepTitle,
          instruction: instruction,
          stepIndex: i,
          stepWaterGrams: stepWater,
          cumulativeWaterGrams: cumWater,
          waterTempCelsius: waterTemp,
          durationSeconds: dur,
        );

        steps.add(RecipeWalkthroughStep(
          stepIndex: sIdx++,
          title: '${i + 3}. $cleanStepTitle',
          phaseName: _resolvePhaseBadge(family, i, stepWater),
          ttsText: spokenBody,
          visualCues: [
            if (stepWater > 0) 'Tuang +${stepWater}g air suhu $waterTemp°C (Target timbangan: ${cumWater}g)',
            'Durasi tahapan: $dur detik',
            if (instruction.isNotEmpty) instruction.replaceAll('until', 'hingga'),
          ],
          animationState: animState,
          durationSeconds: 12,
          autoAdvance: i < rawSteps.length - 1,
          stepWaterGrams: stepWater,
          cumulativeWaterGrams: cumWater > 0 ? cumWater : waterGrams,
          totalWaterGrams: waterGrams,
          waterTempCelsius: waterTemp,
          coffeeGrams: coffeeGrams,
          iceGrams: iceGrams,
          grindLabel: grind,
        ));
      }
    }

    return RecipeMasterclass(
      recipeId: recipe['id'] ?? recipeTitle,
      title: 'Masterclass $recipeTitle',
      techniqueName: 'Masterclass $recipeTitle',
      brewerName: brewer,
      recommendedDripper: methodLabel,
      methodFamilyName: family.name,
      coffeeGrams: coffeeGrams,
      totalWaterGrams: waterGrams,
      waterTempCelsius: waterTemp,
      grindSize: grind,
      overview: (recipe['description'] ?? 'Panduan visual dan narasi langkah demi langkah untuk mengekstrak karakter terbaik dari $recipeTitle.').toString(),
      steps: steps,
    );
  }

  static RecipeWalkthroughStep _buildEquipmentStep({
    required int sIdx,
    required BrewMethodFamily family,
    required String methodLabel,
    required int waterGrams,
    required int waterTemp,
    required int iceGrams,
    required num coffeeGrams,
    required String grind,
  }) {
    if (iceGrams > 0) {
      return RecipeWalkthroughStep(
        stepIndex: sIdx,
        title: '2. Persiapan Es Server & Bilas Filter',
        phaseName: 'Setup Flash Brew',
        ttsText:
            'Masukkan $iceGrams gram es batu kristal ke dalam bejana server. Pasang kertas filter pada dripper di atasnya setelah dibilas air panas, lalu masukkan $coffeeGrams gram bubuk kopi.',
        visualCues: [
          'Masukkan ${iceGrams}g es batu ke dalam server bawah',
          'Bilas kertas filter dengan air panas & tuang ${coffeeGrams}g kopi',
        ],
        animationState: 'ice_server_prep',
        durationSeconds: 10,
        coffeeGrams: coffeeGrams,
        totalWaterGrams: waterGrams,
        waterTempCelsius: waterTemp,
        iceGrams: iceGrams,
        grindLabel: grind,
      );
    }

    final (String title, String phase, String tts, List<String> cues, String anim) = switch (family) {
      BrewMethodFamily.mokaPot => (
        '2. Pengisian Boiler & Corong Kopi',
        'Rakit Moka Pot',
        'Tuang air panas $waterTemp derajat celcius ke boiler bawah Moka Pot tepat di bawah katup pengaman. Masukkan $coffeeGrams gram bubuk kopi ke keranjang corong dan ratakan tanpa ditekan.',
        ['Isi boiler bawah dengan air panas di bawah katup pengaman', 'Isi corong dengan ${coffeeGrams}g kopi tanpa tamping'],
        'moka_boiler_prep',
      ),
      BrewMethodFamily.espresso => (
        '2. Distribusi WDT & Tamping Portafilter',
        'Puck Prep',
        'Masukkan $coffeeGrams gram bubuk kopi halus ke basket portafilter. Urai gumpalan dengan jarum WDT, lalu tekan rata menggunakan tamper dengan tekanan 15 kilogram.',
        ['Distribusi bubuk kopi dengan jarum WDT hingga homogen', 'Tamping tegak lurus secara rata (tekanan ~15 kg)'],
        'espresso_puck_prep',
      ),
      BrewMethodFamily.aeropress => (
        '2. Setup Chamber & Bilas Micro-Filter',
        'Setup AeroPress',
        'Pasang kertas micro-filter pada filter cap AeroPress dan bilas dengan air panas. Siapkan tabung chamber dan masukkan $coffeeGrams gram bubuk kopi.',
        ['Pasang dan bilas kertas filter pada cap AeroPress', 'Masukkan ${coffeeGrams}g bubuk kopi ke dalam chamber'],
        'aeropress_plunge',
      ),
      BrewMethodFamily.syphon => (
        '2. Pemasangan Cloth Filter & Pemanas Bola Bawah',
        'Setup Syphon',
        'Kaitkan rantai filter kain di dasar tabung kaca atas Syphon hingga rapat di tengah. Isi bola kaca bawah dengan $waterGrams mililiter air panas dan nyalakan pemanas.',
        ['Kaitkan pegas cloth filter di dasar tabung atas', 'Isi bola kaca bawah dengan ${waterGrams}g air panas'],
        'syphon_vacuum',
      ),
      BrewMethodFamily.hybrid => (
        '2. Kunci Katup Switch & Bilas Filter',
        'Setup Katup Hybrid',
        'Pastikan tuas katup silikon berada pada posisi tertutup, bilas kertas filter dengan air panas lalu buang air bilasan, dan masukkan $coffeeGrams gram bubuk kopi.',
        ['Bilas kertas filter dan buang air bilasan', 'Pastikan katup Switch/Clever tertutup & tuang ${coffeeGrams}g kopi'],
        'hybrid_switch_valve',
      ),
      _ => (
        '2. Pemasangan & Bilas Filter',
        'Setup $methodLabel',
        'Pasang kertas filter pada $methodLabel Anda. Bilas seluruh permukaan kertas dengan air panas untuk menghilangkan bau kertas dan menghangatkan server, lalu tuang $coffeeGrams gram kopi.',
        ['Lipat jahitan kertas filter dan pasang di $methodLabel', 'Bilas air panas memutar & masukkan ${coffeeGrams}g kopi'],
        'filter_rinse',
      ),
    };

    return RecipeWalkthroughStep(
      stepIndex: sIdx,
      title: title,
      phaseName: phase,
      ttsText: tts,
      visualCues: cues,
      animationState: anim,
      durationSeconds: 10,
      coffeeGrams: coffeeGrams,
      totalWaterGrams: waterGrams,
      waterTempCelsius: waterTemp,
      grindLabel: grind,
    );
  }

  static String _resolveStepAnimationState({
    required BrewMethodFamily family,
    required int stepIndexInRecipe,
    required String recipeTitle,
    required String stepTitle,
    required String instruction,
    required int stepWater,
  }) {
    return switch (family) {
      BrewMethodFamily.mokaPot => 'moka_flame_erupt',
      BrewMethodFamily.espresso => 'espresso_9bar_shot',
      BrewMethodFamily.aeropress => 'aeropress_plunge',
      BrewMethodFamily.syphon => 'syphon_vacuum',
      BrewMethodFamily.immersionPress => 'french_press_steep',
      BrewMethodFamily.coldBrew => 'cold_brew_tower',
      BrewMethodFamily.hybrid => 'hybrid_switch_valve',
      BrewMethodFamily.turkish || BrewMethodFamily.vietnamesePhin => 'ibrik_phin_brew',
      BrewMethodFamily.pourOver => (stepIndexInRecipe == 0 || stepTitle.contains('bloom'))
          ? 'bloom_pour'
          : (stepWater == 0 || stepTitle.contains('drawdown') || stepTitle.contains('tiris') || stepTitle.contains('swirl') || stepTitle.contains('spin'))
              ? 'swirl_drawdown'
              : (recipeTitle.contains('osmotic') || stepTitle.contains('osmotic') || stepTitle.contains('center') || stepTitle.contains('tengah'))
                  ? 'osmotic_pour'
                  : 'spiral_pour',
    };
  }

  static String _resolvePhaseBadge(BrewMethodFamily family, int stepIdx, int stepWater) {
    if (family == BrewMethodFamily.mokaPot) return 'Ekstraksi Stovetop';
    if (family == BrewMethodFamily.espresso) return 'Ekstraksi Tekanan 9-Bar';
    if (family == BrewMethodFamily.aeropress) return 'Imersi & Plunge';
    if (family == BrewMethodFamily.syphon) return 'Ekstraksi Vakum';
    if (stepIdx == 0) return 'Fase Blooming';
    if (stepWater == 0) return 'Fase Drawdown';
    return 'Tuangan +${stepWater}g Air';
  }
}
