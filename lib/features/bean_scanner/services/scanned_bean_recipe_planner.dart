import '../../../models/bean_ai_customization_models.dart';
import '../../../models/bean_recommendation_models.dart';
import '../models/resolved_coffee_bean.dart';

/// Menyusun rekomendasi resep presisi berdasarkan seluruh aspek biji kopi
/// hasil Smart Detection & Knowledge Graph (origin, varietas, proses, roast,
/// ketinggian MDPL, dan tasting notes).
class ScannedBeanRecipePlanner {
  static BeanRoastLevel parseRoastLevel(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('medium-dark') || (lower.contains('medium') && lower.contains('dark'))) {
      return BeanRoastLevel.mediumDark;
    }
    if (lower.contains('dark') || lower.contains('espresso')) {
      return BeanRoastLevel.dark;
    }
    if (lower.contains('medium-light') ||
        lower.contains('light-medium') ||
        lower.contains('light to medium') ||
        lower.contains('omni')) {
      return BeanRoastLevel.mediumLight;
    }
    if (lower.contains('light') || lower.contains('filter')) {
      return BeanRoastLevel.light;
    }
    return BeanRoastLevel.medium;
  }

  static BeanProcess parseProcess(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('anaerob') ||
        lower.contains('wine') ||
        lower.contains('carbonic') ||
        lower.contains('maceration') ||
        lower.contains('ferment') ||
        lower.contains('koji') ||
        lower.contains('thermal shock')) {
      return BeanProcess.anaerobic;
    }
    if (lower.contains('giling basah') ||
        lower.contains('wet hulled') ||
        lower.contains('wet-hulled') ||
        lower.contains('semi washed')) {
      return BeanProcess.wetHulled;
    }
    if (lower.contains('honey') || lower.contains('pulped')) {
      return BeanProcess.honey;
    }
    if (lower.contains('natural') || lower.contains('dry process') || lower.contains('sundried')) {
      return BeanProcess.natural;
    }
    return BeanProcess.washed;
  }

  static BeanDripper parseDripper(
    String? preferredDripper,
    BeanProcess process,
    BeanRoastLevel roast,
    List<String> tastingNotes,
  ) {
    final pref = (preferredDripper ?? '').toLowerCase();
    if (pref.contains('origami')) return BeanDripper.origami;
    if (pref.contains('kalita')) return BeanDripper.kalita;
    if (pref.contains('aeropress')) return BeanDripper.aeropress;
    if (pref.contains('chemex')) return BeanDripper.chemex;
    if (pref.contains('clever')) return BeanDripper.clever;
    if (pref.contains('v60')) return BeanDripper.v60;

    final notesLow = tastingNotes.join(' ').toLowerCase();
    if (process == BeanProcess.natural ||
        process == BeanProcess.anaerobic ||
        notesLow.contains('watermelon') ||
        notesLow.contains('tropical') ||
        notesLow.contains('strawberry')) {
      return BeanDripper.origami;
    }
    if (roast == BeanRoastLevel.mediumDark || roast == BeanRoastLevel.dark) {
      return BeanDripper.kalita;
    }
    return BeanDripper.v60;
  }

  static int? _parseMaxAltitude(String? altitude) {
    if (altitude == null || altitude.trim().isEmpty) return null;
    final matches = RegExp(r'\d{3,4}').allMatches(altitude).toList();
    if (matches.isEmpty) return null;
    return matches.map((m) => int.tryParse(m.group(0)!) ?? 0).reduce((a, b) => a > b ? a : b);
  }

  static List<RecommendedRecipeSummary> buildRecommendations({
    required String displayBeanName,
    required String origin,
    required String variety,
    required String processRaw,
    required String roastRaw,
    String? altitudeMasl,
    required List<String> tastingNotes,
    int? targetTempOverride,
    String? preferredDripper,
    String? baristaOpinion,
  }) {
    final roast = parseRoastLevel(roastRaw);
    final process = parseProcess(processRaw);
    final primaryDripper = parseDripper(preferredDripper, process, roast, tastingNotes);

    final notesJoined = tastingNotes.join(' ').toLowerCase();
    final varietyLow = variety.toLowerCase();
    final procLow = processRaw.toLowerCase();
    final altMax = _parseMaxAltitude(altitudeMasl) ?? 1500;

    // 1. Tentukan FlavorGoal & PouringParadigm berdasarkan karakter kopi
    FlavorGoal primaryGoal = FlavorGoal.sweetBalanced;
    PouringParadigm primaryParadigm = PouringParadigm.tetsu46;

    if (process == BeanProcess.washed &&
        (varietyLow.contains('geisha') ||
            varietyLow.contains('gesha') ||
            varietyLow.contains('heirloom') ||
            notesJoined.contains('floral') ||
            notesJoined.contains('jasmine') ||
            notesJoined.contains('bergamot') ||
            notesJoined.contains('tea'))) {
      primaryGoal = FlavorGoal.highAcidity;
      primaryParadigm = PouringParadigm.hoffmannUltimate;
    } else if (process == BeanProcess.wetHulled ||
        roast == BeanRoastLevel.mediumDark ||
        roast == BeanRoastLevel.dark ||
        notesJoined.contains('dark chocolate') ||
        notesJoined.contains('earthy') ||
        notesJoined.contains('herbal')) {
      primaryGoal = FlavorGoal.heavyBody;
      primaryParadigm = PouringParadigm.osmoticFlow;
    } else if (procLow.contains('wine') || procLow.contains('anaerob')) {
      primaryGoal = FlavorGoal.sweetBalanced;
      primaryParadigm = PouringParadigm.tetsu46;
    } else if (process == BeanProcess.honey) {
      primaryGoal = FlavorGoal.sweetBalanced;
      primaryParadigm = PouringParadigm.specialtyStandard;
    }

    // 2. Penyesuaian ketinggian MDPL (High-grown > 1650m lebih padat selnya)
    final int altMicronAdj = altMax >= 1700 ? -15 : (altMax <= 1300 ? 15 : 0);

    // Hitung resep baseline lalu sesuaikan ke suhu terkalibrasi (bila ada)
    final basePrimary = BeanRecommenderEngine.calculate(
      beanName: displayBeanName,
      origin: origin,
      variety: variety,
      tastingNotes: tastingNotes,
      roast: roast,
      process: process,
      goal: primaryGoal,
      dripper: primaryDripper,
      dose: 15.0,
      pouringParadigm: primaryParadigm,
      customMicronAdjust: altMicronAdj,
    );

    final int tempDelta = targetTempOverride != null ? (targetTempOverride - basePrimary.waterTemp) : 0;
    final primaryRecipe = tempDelta == 0
        ? basePrimary
        : BeanRecommenderEngine.calculate(
            beanName: displayBeanName,
            origin: origin,
            variety: variety,
            tastingNotes: tastingNotes,
            roast: roast,
            process: process,
            goal: primaryGoal,
            dripper: primaryDripper,
            dose: 15.0,
            pouringParadigm: primaryParadigm,
            customTempAdjust: tempDelta,
            customMicronAdjust: altMicronAdj,
          );

    final primarySlug = '${primaryParadigm.name}-${primaryDripper.name}-${process.name}';
    final topNotesPreview = tastingNotes.take(3).join(', ');
    final dripperShort = primaryDripper.label.split('(').first.trim();

    final primaryTitle = _buildFriendlyTitle(
      paradigm: primaryParadigm,
      dripperShort: dripperShort,
      processRaw: processRaw,
      notesLower: notesJoined,
    );

    final primarySummary = RecommendedRecipeSummary(
      slug: primarySlug,
      name: primaryTitle,
      targetNotes: topNotesPreview.isNotEmpty
          ? 'Menonjolkan $topNotesPreview ($processRaw)'
          : '${primaryParadigm.badge} untuk karakter $processRaw',
      suggestedTempC: primaryRecipe.waterTemp,
      ratio: '1:${primaryRecipe.brewRatio.toStringAsFixed(0)} (${primaryRecipe.coffeeDose.round()}g : ${primaryRecipe.totalWater.round()}ml)',
      method: dripperShort,
      grindSize: '${primaryRecipe.grindMicrons} µm • ${primaryRecipe.grindClickLabel}',
      coffeeGrams: primaryRecipe.coffeeDose.round(),
      totalWaterGrams: primaryRecipe.totalWater.round(),
      totalTimeSeconds: primaryRecipe.totalTimeSeconds,
      description: baristaOpinion != null && baristaOpinion.trim().isNotEmpty
          ? '$baristaOpinion\n\n${primaryRecipe.scientificReason}'
          : primaryRecipe.scientificReason,
      steps: primaryRecipe.steps,
    );

    // 3. Rekomendasi Alternatif (#2): Pendekatan Clean Clarity V60 / Balanced 3-Pulse
    final altDripper = primaryDripper == BeanDripper.v60 ? BeanDripper.kalita : BeanDripper.v60;
    final altParadigm = primaryParadigm == PouringParadigm.hoffmannUltimate
        ? PouringParadigm.tetsu46
        : PouringParadigm.hoffmannUltimate;
    final altGoal = primaryGoal == FlavorGoal.highAcidity ? FlavorGoal.sweetBalanced : FlavorGoal.highAcidity;

    final altRecipe = BeanRecommenderEngine.calculate(
      beanName: displayBeanName,
      origin: origin,
      variety: variety,
      tastingNotes: tastingNotes,
      roast: roast,
      process: process,
      goal: altGoal,
      dripper: altDripper,
      dose: 15.0,
      pouringParadigm: altParadigm,
      customTempAdjust: tempDelta,
      customMicronAdjust: altMicronAdj,
    );
    final altDripperShort = altDripper.label.split('(').first.trim();

    final altSummary = RecommendedRecipeSummary(
      slug: '${altParadigm.name}-${altDripper.name}',
      name: '${altParadigm.label} • $altDripperShort',
      targetNotes: altGoal == FlavorGoal.highAcidity
          ? 'Kejernihan aroma & keasaman cerah ($topNotesPreview)'
          : 'Manis seimbang & tekstur lembut',
      suggestedTempC: altRecipe.waterTemp,
      ratio: '1:${altRecipe.brewRatio.toStringAsFixed(1)} (${altRecipe.coffeeDose.round()}g : ${altRecipe.totalWater.round()}ml)',
      method: altDripperShort,
      grindSize: '${altRecipe.grindMicrons} µm • ${altRecipe.grindClickLabel}',
      coffeeGrams: altRecipe.coffeeDose.round(),
      totalWaterGrams: altRecipe.totalWater.round(),
      totalTimeSeconds: altRecipe.totalTimeSeconds,
      description: altRecipe.scientificReason,
      steps: altRecipe.steps,
    );

    return [primarySummary, altSummary];
  }

  static String _buildFriendlyTitle({
    required PouringParadigm paradigm,
    required String dripperShort,
    required String processRaw,
    required String notesLower,
  }) {
    final pLow = processRaw.toLowerCase();
    if (pLow.contains('wine') || pLow.contains('anaerob')) {
      return '${paradigm.label} (Tropical Wine Focus)';
    }
    if (pLow.contains('natural') &&
        (notesLower.contains('watermelon') || notesLower.contains('berry') || notesLower.contains('mango'))) {
      return '${paradigm.label} • Sweet Fruit ($dripperShort)';
    }
    if (pLow.contains('washed')) {
      return '${paradigm.label} • Clean Clarity';
    }
    if (pLow.contains('honey')) {
      return 'Balanced Honey Pour ($dripperShort)';
    }
    return '${paradigm.label} ($dripperShort)';
  }
}
