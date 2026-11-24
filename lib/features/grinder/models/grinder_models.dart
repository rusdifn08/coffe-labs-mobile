import '../services/grinder_conversion_engine.dart';
import 'grinder_spec.dart';

/// Model profil grinder kompatibel ke belakang yang kini ditenagai penuh
/// oleh [GrinderConversionEngine] (102 grinder terverifikasi, interpolasi multi-jangkar).
class GrinderProfile {
  final String id;
  final String brand;
  final String name;
  final String origin;
  final String burrType;
  final String finesProfile;
  final String detail;
  final int colorHex;
  final GrinderSpec spec;
  final String Function(double microns) calculateSetting;

  const GrinderProfile({
    required this.id,
    required this.brand,
    required this.name,
    required this.origin,
    required this.burrType,
    required this.finesProfile,
    required this.detail,
    required this.colorHex,
    required this.spec,
    required this.calculateSetting,
  });
}

class GrinderCatalog {
  static int _colorForBrand(String brand, GrinderCategory category) {
    switch (brand) {
      case 'Comandante':
        return 0xFF5D4037;
      case '1Zpresso':
        return 0xFF00695C;
      case 'Timemore':
        return 0xFFE65100;
      case 'KINGrinder':
        return 0xFF4527A0;
      case 'MHW-3BOMBER':
        return 0xFF283593;
      case 'Kinu':
        return 0xFF37474F;
      case 'Baratza':
        return 0xFF1565C0;
      case 'Fellow':
        return 0xFF263238;
      case 'DF / Turin':
        return 0xFF00838F;
      case 'Mahlkönig':
        return 0xFFB71C1C;
      case 'Eureka':
        return 0xFFAD1457;
      case 'Latina':
        return 0xFF6D4C41;
      default:
        return category == GrinderCategory.electric ? 0xFF1E40AF : 0xFF5D4037;
    }
  }

  static List<GrinderProfile> getProfiles({
    GrinderCategory? category,
    String? brand,
  }) {
    final specs = GrinderConversionEngine.searchGrinders(
      '',
      category: category,
      brand: brand,
    );
    return specs.map((spec) {
      return GrinderProfile(
        id: spec.id,
        brand: spec.brand,
        name: spec.fullName,
        origin: '${spec.dialPlacement} · ${spec.dialStructureSummary}',
        burrType: spec.burrSpec,
        finesProfile: spec.category == GrinderCategory.electric ? 'Elektrik' : 'Manual',
        detail: spec.calibrationNote,
        colorHex: _colorForBrand(spec.brand, spec.category),
        spec: spec,
        calculateSetting: (m) {
          if (!spec.isCalibrated) return 'Kalibrasi Visual';
          final val = GrinderConversionEngine.micronsToSetting(spec, m);
          if (val == null) return 'Kalibrasi Visual';
          final reading = GrinderConversionEngine.formatDialReading(
            spec,
            val,
            targetMicrons: m,
          );
          if (reading.primaryDisplay == reading.physicalNotation ||
              reading.physicalNotation.startsWith('Skala ') ||
              reading.physicalNotation.startsWith('Angka ')) {
            return reading.primaryDisplay;
          }
          return '${reading.primaryDisplay} (${reading.physicalNotation})';
        },
      );
    }).toList(growable: false);
  }
}
