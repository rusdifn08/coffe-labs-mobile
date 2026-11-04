/// Model data untuk katalog grinder kopi presisi
class GrinderProfile {
  final String name;
  final String origin;
  final String burrType; // 'Conical 48mm', 'Flat 64mm', 'Flat 98mm', etc.
  final String finesProfile; // 'Unimodal (Clarity)', 'Bimodal (Body & Texture)'
  final String detail;
  final int colorHex;
  final String Function(double microns) calculateSetting;

  const GrinderProfile({
    required this.name,
    required this.origin,
    required this.burrType,
    required this.finesProfile,
    required this.detail,
    required this.colorHex,
    required this.calculateSetting,
  });
}

class GrinderCatalog {
  static List<GrinderProfile> getProfiles() {
    return [
      GrinderProfile(
        name: 'Comandante C40 MK3/MK4',
        origin: '🇩🇪 Germany (30 clk/rot · ~30 µm/clk)',
        burrType: 'Nitro Blade Conical 39mm',
        finesProfile: 'Balanced Clarity & High Sweetness',
        detail: 'Baseline standar resep kompetisi dunia',
        colorHex: 0xFF5D4037,
        calculateSetting: (m) => '${((m - 60) / 30).round().clamp(4, 45)} clicks',
      ),
      GrinderProfile(
        name: 'Comandante C40 (Red Clix Axle)',
        origin: '🇩🇪 Double-thread Micro-axle (~15 µm/clk)',
        burrType: 'Nitro Blade Micro-pitch',
        finesProfile: 'Ultra High Micro-adjustability',
        detail: 'Presisi tinggi untuk kalibrasi espresso',
        colorHex: 0xFFC62828,
        calculateSetting: (m) => '${((m - 60) / 15).round().clamp(8, 90)} clicks',
      ),
      GrinderProfile(
        name: '1Zpresso K-Ultra / K-Max',
        origin: '🇹🇼 External Dial (100 clk/rot · ~20 µm/clk)',
        burrType: 'K-Burr Heptagonal 48mm',
        finesProfile: 'High Clarity & Vibrant Acidity',
        detail: '10 nomor dial luar, 10 klik per angka',
        colorHex: 0xFF00695C,
        calculateSetting: (m) {
          final total = (m / 20).round();
          final num = (total ~/ 10).clamp(1, 10);
          final click = total % 10;
          return '$num.$click ($total clk)';
        },
      ),
      GrinderProfile(
        name: '1Zpresso J-Max / J-Ultra',
        origin: '🇹🇼 Espresso Specialist (~8.8 µm/clk)',
        burrType: 'Titanium-coated Conical 48mm',
        finesProfile: 'Dense Crema & High Body',
        detail: 'Ultra fine micro-steps khusus espresso',
        colorHex: 0xFF37474F,
        calculateSetting: (m) {
          final total = (m / 8.8).round();
          final rot = total ~/ 90;
          final num = (total % 90) ~/ 10;
          final micro = total % 10;
          return '$rot.$num.$micro';
        },
      ),
      GrinderProfile(
        name: 'Timemore C2 / C3 / C3S',
        origin: '🇨🇳 Stepped Clicker (~83 µm/clk)',
        burrType: 'S2C 660 Conical 38mm',
        finesProfile: 'Medium Body, Entry Standard',
        detail: 'Grinder manual entry-level paling populer',
        colorHex: 0xFFE65100,
        calculateSetting: (m) => '${((m - 80) / 83).round().clamp(6, 32)} clicks',
      ),
      GrinderProfile(
        name: 'Timemore Sculptor 078 / 064',
        origin: '🇨🇳 Electric Rotary Stepless Flat Burr',
        burrType: 'Turbo / Ghost Tooth Flat 78mm',
        finesProfile: 'Ultra Unimodal, Minimal Fines',
        detail: 'Juara ekstraksi filter clarity tinggi',
        colorHex: 0xFF1B5E20,
        calculateSetting: (m) {
          final step = (1.0 + (m - 300) / 75).clamp(1.0, 18.0);
          return 'Dial ${step.toStringAsFixed(1)}';
        },
      ),
      GrinderProfile(
        name: 'Fellow Ode Gen 2',
        origin: '🇺🇸 Flat Burr Stepped (1.0 to 11.0)',
        burrType: 'Gen 2 Flat Burrs 64mm',
        finesProfile: 'Unimodal Filter Precision',
        detail: 'Burr flat 64mm optimal untuk filter',
        colorHex: 0xFF263238,
        calculateSetting: (m) {
          if (m < 500) return '1.0 (Out of range)';
          final step = (1.0 + (m - 500) / 95).clamp(1.0, 11.0);
          final whole = step.floor();
          final rem = step - whole;
          String sub = '';
          if (rem >= 0.66) {
            sub = '.2';
          } else if (rem >= 0.33) {
            sub = '.1';
          }
          return '$whole$sub';
        },
      ),
      GrinderProfile(
        name: 'Mahlkönig EK43 / EK43S',
        origin: '🇩🇪 Cafe & Championship Benchmark',
        burrType: 'Cast Steel Flat Burrs 98mm',
        finesProfile: 'World Champion High Yield & Clarity',
        detail: 'Standar kompetisi WBrC & kafe specialty',
        colorHex: 0xFFB71C1C,
        calculateSetting: (m) {
          final dial = (1.0 + (m - 150) / 70).clamp(1.0, 16.0);
          return 'Dial ${dial.toStringAsFixed(1)}';
        },
      ),
      GrinderProfile(
        name: 'Kingrinder K6',
        origin: '🇹🇼 60 Clicks/Rotation (~16 µm/clk)',
        burrType: 'Heptagonal Conical 48mm',
        finesProfile: 'Clean Cup & Smooth Acidity',
        detail: 'Top adjustment dial serba bisa',
        colorHex: 0xFF4527A0,
        calculateSetting: (m) => '${((m - 80) / 16).round().clamp(15, 180)} clicks',
      ),
      GrinderProfile(
        name: 'Baratza Encore ESP / Standard',
        origin: '🇺🇸 40 Stepped Ring (Dual-range)',
        burrType: 'M2 Conical Burrs 40mm',
        finesProfile: 'All-round Filter & Espresso',
        detail: '1-20 Micro Espresso, 21-40 Filter',
        colorHex: 0xFF1565C0,
        calculateSetting: (m) => 'Setting ${((m - 120) / 32).round().clamp(1, 40)}',
      ),
    ];
  }
}
