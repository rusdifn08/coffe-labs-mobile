/// 6 Arketipe Eksekusi Seduh Multi-Metode Coffee Labs.
/// Memastikan Hario V60 manual brew tetap berjalan dengan alur pour-over aslinya
/// sementara metode berjam-jam (Cold Brew / Drip) hanya memakai Step-by-Step + Alarm OS.
enum BrewExecutionArchetype {
  percolationPourOver,
  flashChillIcedFilter,
  steepAndReleaseImmersion,
  subSecondPressureEspresso,
  thermalCuePhaseBrewer,
  longHorizonPersistentAlarm,
}

enum ImmersionSubMethod {
  aeropress,
  frenchPress,
  cleverSwitch,
  cuppingBowl,
  vietnamPhin,
}

enum ThermalCueSubMethod {
  mokaPot,
  turkishCezve,
  syphonVacuum,
}

class MethodClassification {
  final BrewExecutionArchetype archetype;
  final bool isProtectedV60;
  final ImmersionSubMethod? immersionSubMethod;
  final ThermalCueSubMethod? thermalSubMethod;

  const MethodClassification({
    required this.archetype,
    this.isProtectedV60 = false,
    this.immersionSubMethod,
    this.thermalSubMethod,
  });

  bool get isColdBrewAlarmOnly =>
      archetype == BrewExecutionArchetype.longHorizonPersistentAlarm;
}

class MethodArchetypeMapper {
  const MethodArchetypeMapper._();

  static MethodClassification classify(Map<String, dynamic> recipe) {
    final method = (recipe['method'] ?? '').toString().toLowerCase();
    final category = (recipe['category'] ?? '').toString().toLowerCase();
    final title = (recipe['title'] ?? '').toString().toLowerCase();
    final joined = '$method $category $title';
    final tempC = (recipe['waterTempCelsius'] as num?)?.toDouble() ?? 92.0;
    final iceG = (recipe['iceWeightGrams'] as num?)?.toDouble() ?? 0.0;
    final totalSec = (recipe['totalTimeSeconds'] as num?)?.toInt() ?? 180;

    final isV60 = method.contains('v60') || category.contains('v60');

    // 1. Cold Brew & Kyoto Cold Drip: STRICTLY Step-by-Step + Persistent Alarm Only
    // Waspadai 'Kyoto' pada judul Japanese Iced V60 (ID 148) & Kyoto Latte Espresso (ID 524).
    final isEspressoMethod =
        method.contains('espresso') || category.contains('espresso');
    final isKyotoColdDrip = joined.contains('kyoto') &&
        (joined.contains('drip') || joined.contains('cold') || joined.contains('oji')) &&
        !isV60 &&
        !isEspressoMethod &&
        !joined.contains('japanese');
    final isColdBrewSignal = joined.contains('cold brew') ||
        joined.contains('cold drip') ||
        joined.contains('mizudashi') ||
        isKyotoColdDrip ||
        (tempC <= 10.0 && (joined.contains('cold') || totalSec >= 3600));
    if (isColdBrewSignal) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.longHorizonPersistentAlarm,
      );
    }

    // 2. Japanese Iced / Flash Chill Filter (V60 iced tetap dilindungi alurnya bila method V60)
    if (!isV60 &&
        (joined.contains('japanese') ||
            joined.contains('es di server') ||
            (iceG > 0 && !joined.contains('espresso')))) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.flashChillIcedFilter,
      );
    }

    // 3. Espresso
    if (joined.contains('espresso') && !joined.contains('moka')) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.subSecondPressureEspresso,
      );
    }

    // 4. Thermal Cue Phase Brewers (Moka Pot, Turkish Cezve, Syphon)
    if (joined.contains('moka')) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.thermalCuePhaseBrewer,
        thermalSubMethod: ThermalCueSubMethod.mokaPot,
      );
    }
    if (joined.contains('turkish') ||
        joined.contains('cezve') ||
        joined.contains('ibrik')) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.thermalCuePhaseBrewer,
        thermalSubMethod: ThermalCueSubMethod.turkishCezve,
      );
    }
    if (joined.contains('syphon') ||
        joined.contains('siphon') ||
        joined.contains('vacuum')) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.thermalCuePhaseBrewer,
        thermalSubMethod: ThermalCueSubMethod.syphonVacuum,
      );
    }

    // 5. Steep & Release Immersion / Cupping / Phin
    if (joined.contains('cupping')) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.steepAndReleaseImmersion,
        immersionSubMethod: ImmersionSubMethod.cuppingBowl,
      );
    }
    if (joined.contains('aeropress')) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.steepAndReleaseImmersion,
        immersionSubMethod: ImmersionSubMethod.aeropress,
      );
    }
    if (joined.contains('french press')) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.steepAndReleaseImmersion,
        immersionSubMethod: ImmersionSubMethod.frenchPress,
      );
    }
    if (joined.contains('clever') || joined.contains('switch')) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.steepAndReleaseImmersion,
        immersionSubMethod: ImmersionSubMethod.cleverSwitch,
      );
    }
    if (joined.contains('vietnam') || joined.contains('phin')) {
      return const MethodClassification(
        archetype: BrewExecutionArchetype.steepAndReleaseImmersion,
        immersionSubMethod: ImmersionSubMethod.vietnamPhin,
      );
    }

    // 6. V60 (Protected!) & other percolation pour-overs (Kalita, Origami, Chemex, Bee House, Bonmac, Drip Maker)
    return MethodClassification(
      archetype: BrewExecutionArchetype.percolationPourOver,
      isProtectedV60: isV60,
    );
  }
}
