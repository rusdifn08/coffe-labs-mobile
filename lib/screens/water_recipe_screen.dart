import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../features/water/models/water_profile.dart';
import '../features/water/services/water_chemistry_engine.dart';
import '../features/water/widgets/water_buffer_card.dart';
import '../features/water/widgets/water_customizer_lab_tab.dart';
import '../features/water/widgets/water_sensor_analyzer_tab.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// Professional Coffee Water Chemistry Lab (3-Tab Mobile-First System):
/// 1. Lab Kustom — Stoikiometri mineral & simulasi "Apa jadinya jika ditambah..."
/// 2. Deteksi & Sensor — TDS/EC Meter, Ion Selektif (ISE), & E-Tongue Multi-Sensor
/// 3. Resep Pro — 6 Preset air kompetisi dunia + Lotus Drops & DIY Salts
class WaterRecipeScreen extends StatefulWidget {
  const WaterRecipeScreen({super.key});

  @override
  State<WaterRecipeScreen> createState() => _WaterRecipeScreenState();
}

class _WaterRecipeScreenState extends State<WaterRecipeScreen> {
  int _activeTab = 0; // 0 = Lab Kustom, 1 = Deteksi & Sensor, 2 = Resep Pro
  int _volumeLiters = 1;
  String _selectedPreset = 'sca';

  // State untuk Tab 1: Lab Kustom Mineral
  BaseWaterPreset _selectedBaseWater = WaterChemistryEngine.baseWaters.first;
  BaseWaterPreset? _detectedSensorWater;
  double _customBatchLiters = 1.0;
  MineralAddition _customAddition = const MineralAddition(
    epsomSaltMgPerL: 110,
    calciumChlorideMgPerL: 34,
    bakingSodaMgPerL: 42,
    potassiumBicarbMgPerL: 30,
  );

  static const Map<String, WaterProfile> _profiles = {
    'sca': WaterProfile(
      name: 'SCA Standard Water',
      origin: 'Specialty Coffee Association Baseline',
      ghPpm: 68,
      khPpm: 40,
      description: 'Standar emas dunia. Keseimbangan harmonis antara ekstraksi manis dan keasaman bersih.',
      calciumDropsPerLiter: 4,
      magnesiumDropsPerLiter: 5,
      sodiumDropsPerLiter: 3,
      potassiumDropsPerLiter: 2,
      bakingSodaGramsPerLiter: 0.07,
      epsomSaltGramsPerLiter: 0.17,
      accentColor: Color(0xFF1E88E5),
    ),
    'barista_hustle': WaterProfile(
      name: 'Barista Hustle Melbourne',
      origin: 'Matt Perger Water Recipe #2',
      ghPpm: 100,
      khPpm: 50,
      description: 'Formula favorit kafe Melbourne. Buffer moderat dengan magnesium tinggi untuk aroma buah cerah.',
      calciumDropsPerLiter: 2,
      magnesiumDropsPerLiter: 8,
      sodiumDropsPerLiter: 4,
      potassiumDropsPerLiter: 2,
      bakingSodaGramsPerLiter: 0.08,
      epsomSaltGramsPerLiter: 0.25,
      accentColor: Color(0xFF00897B),
    ),
    'rao': WaterProfile(
      name: 'Scott Rao Light Roast Clarity',
      origin: 'Low Buffer High Extraction Profile',
      ghPpm: 85,
      khPpm: 25,
      description: 'Buffer rendah (KH 25 ppm) memaksimalkan letupan asam malat dan sitrat buah pada sangrai ringan.',
      calciumDropsPerLiter: 3,
      magnesiumDropsPerLiter: 6,
      sodiumDropsPerLiter: 2,
      potassiumDropsPerLiter: 1,
      bakingSodaGramsPerLiter: 0.04,
      epsomSaltGramsPerLiter: 0.21,
      accentColor: Color(0xFF8E24AA),
    ),
    'magnesium': WaterProfile(
      name: 'Hendon Magnesium Boost',
      origin: 'Christopher Hendon (Water for Coffee Science)',
      ghPpm: 110,
      khPpm: 45,
      description: 'Ion Magnesium (Mg2+) memiliki daya ikat tertinggi terhadap senyawa floral dan berry kompleks.',
      calciumDropsPerLiter: 1,
      magnesiumDropsPerLiter: 10,
      sodiumDropsPerLiter: 3,
      potassiumDropsPerLiter: 2,
      bakingSodaGramsPerLiter: 0.07,
      epsomSaltGramsPerLiter: 0.28,
      accentColor: Color(0xFFE65100),
    ),
    'wbrc_clarity': WaterProfile(
      name: 'WBrC Low-TDS Geisha',
      origin: 'World Brewers Cup Ultra-Clarity Profile',
      ghPpm: 52,
      khPpm: 18,
      description: 'TDS rendah & buffer minimal untuk memunculkan aroma jasmine, bergamot, dan peach pada Geisha / Light Washed.',
      calciumDropsPerLiter: 1,
      magnesiumDropsPerLiter: 5,
      sodiumDropsPerLiter: 1,
      potassiumDropsPerLiter: 2,
      bakingSodaGramsPerLiter: 0.03,
      epsomSaltGramsPerLiter: 0.13,
      accentColor: Color(0xFF0369A1),
    ),
    'espresso_safe': WaterProfile(
      name: 'Espresso Boiler-Safe',
      origin: 'Anti-Scaling & Creamy Crema Balance',
      ghPpm: 72,
      khPpm: 42,
      description: 'Didesain aman dari kerak boiler 93°C & bebas korosi klorida dengan body espresso kental dan manis.',
      calciumDropsPerLiter: 4,
      magnesiumDropsPerLiter: 4,
      sodiumDropsPerLiter: 3,
      potassiumDropsPerLiter: 2,
      bakingSodaGramsPerLiter: 0.07,
      epsomSaltGramsPerLiter: 0.14,
      accentColor: Color(0xFF5D4037),
    ),
  };

  void _openPresetInCustomizerLab(WaterProfile p) {
    final epsomMg = (p.epsomSaltGramsPerLiter * 1000).clamp(0, 350).toDouble();
    final sodaMg = (p.bakingSodaGramsPerLiter * 1000).clamp(0, 150).toDouble();
    final remainingGh = (p.ghPpm - (epsomMg * WaterChemistryEngine.epsomGhFactor)).clamp(0, 120);
    final caCl2Mg = (remainingGh / WaterChemistryEngine.cacl2GhFactor).clamp(0, 200).toDouble();

    setState(() {
      _selectedBaseWater = WaterChemistryEngine.baseWaters.first;
      _customBatchLiters = _volumeLiters.toDouble();
      _customAddition = MineralAddition(
        epsomSaltMgPerL: epsomMg,
        calciumChlorideMgPerL: caCl2Mg,
        bakingSodaMgPerL: sodaMg,
        potassiumBicarbMgPerL: 0,
      );
      _activeTab = 0;
    });
  }

  void _optimizeDetectedWaterInLab(BaseWaterPreset detected) {
    final suggestedDilution = detected.tdsPpm > 180
        ? (1.0 - (95.0 / detected.tdsPpm)).clamp(0.25, 0.85)
        : 0.0;
    final needsMinerals = detected.tdsPpm < 45;

    setState(() {
      _detectedSensorWater = detected;
      _selectedBaseWater = detected;
      _customAddition = MineralAddition(
        epsomSaltMgPerL: needsMinerals ? 110 : 0,
        calciumChlorideMgPerL: needsMinerals ? 30 : 0,
        bakingSodaMgPerL: needsMinerals ? 35 : 0,
        potassiumBicarbMgPerL: needsMinerals ? 20 : 0,
        roDilutionRatio: suggestedDilution,
      );
      _activeTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final availableBases = [
      ?_detectedSensorWater,
      ...WaterChemistryEngine.baseWaters,
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? 'Coffee Water Chemistry Lab' : 'Kimia Air Seduh Kopi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 3-Tab Mobile-First Switcher
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.14)),
              ),
              child: Row(
                children: [
                  _TabPill(
                    label: 'Lab Kustom',
                    icon: CupertinoIcons.lab_flask_solid,
                    selected: _activeTab == 0,
                    onTap: () => setState(() => _activeTab = 0),
                  ),
                  _TabPill(
                    label: 'Deteksi Air',
                    icon: CupertinoIcons.gauge,
                    selected: _activeTab == 1,
                    onTap: () => setState(() => _activeTab = 1),
                  ),
                  _TabPill(
                    label: 'Resep Pro',
                    icon: CupertinoIcons.drop_fill,
                    selected: _activeTab == 2,
                    onTap: () => setState(() => _activeTab = 2),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: IndexedStack(
              index: _activeTab,
              children: [
                WaterCustomizerLabTab(
                  baseWater: _selectedBaseWater,
                  availableBases: availableBases,
                  addition: _customAddition,
                  batchLiters: _customBatchLiters,
                  onBaseWaterChanged: (b) => setState(() => _selectedBaseWater = b),
                  onAdditionChanged: (a) => setState(() => _customAddition = a),
                  onBatchLitersChanged: (v) => setState(() => _customBatchLiters = v),
                ),
                WaterSensorAnalyzerTab(
                  onOptimizeInLab: _optimizeDetectedWaterInLab,
                ),
                _buildPresetsTab(isEn),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsTab(bool isEn) {
    final p = _profiles[_selectedPreset] ?? _profiles['sca']!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
      children: [
        // Banner Water Science
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [p.accentColor, p.accentColor.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: p.accentColor.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_volumeLiters L Destilasi/RO',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(p.origin, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildPpmBadge('GH (Hardness)', '${p.ghPpm} ppm', Colors.white)),
                  Expanded(child: _buildPpmBadge('KH (Alkalinity)', '${p.khPpm} ppm', Colors.white)),
                  Expanded(
                    child: _buildPpmBadge(
                      'Buffer Rasio',
                      '${p.bufferRatio.toStringAsFixed(1)}:1',
                      Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openPresetInCustomizerLab(p),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: p.accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(CupertinoIcons.lab_flask_solid, size: 15),
                  label: const Text(
                    'Modifikasi Resep Ini di Lab Kustom',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Buffer Ratio & Sensory Prediction Barometer (Overflow-free!)
        WaterBufferCard(profile: p),
        const SizedBox(height: 14),

        // Preset Selection Chips
        Text(
          isEn ? 'Water Mineral Profiles (6):' : 'Pilih Profil Target Air (6 Resep):',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _profiles.entries.map((e) {
              final active = e.key == _selectedPreset;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPreset = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.primaryBrown : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active ? AppTheme.primaryBrown : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      e.value.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.bold : FontWeight.w600,
                        color: active ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Volume Selector including 19L Gallon
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isEn ? 'Batch Volume:' : 'Volume Batch:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              Row(
                children: [1, 2, 5, 19].map((v) {
                  final sel = _volumeLiters == v;
                  return Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: GestureDetector(
                      onTap: () => setState(() => _volumeLiters = v),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? p.accentColor : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          v == 19 ? '19L' : '${v}L',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: sel ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Method A: Lotus Drops Recipe
        _buildMethodCard(
          title: 'Opsi 1: Tetes Konsentrat Mineral (Lotus Drops)',
          icon: CupertinoIcons.drop_fill,
          color: const Color(0xFF00897B),
          child: Column(
            children: [
              _buildDropRow('Magnesium (Mg²⁺)', p.magnesiumDropsPerLiter * _volumeLiters, 'Ekstraksi rasa buah & manis'),
              _buildDropRow('Calcium (Ca²⁺)', p.calciumDropsPerLiter * _volumeLiters, 'Menambah body & mouthfeel kental'),
              _buildDropRow('Sodium (Na⁺ / Buffer)', p.sodiumDropsPerLiter * _volumeLiters, 'Menetralkan asam kasar'),
              _buildDropRow('Potassium (K⁺ / Buffer)', p.potassiumDropsPerLiter * _volumeLiters, 'Menjaga kejernihan rasa cangkir'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Method B: DIY Raw Salts Recipe
        _buildMethodCard(
          title: 'Opsi 2: Racikan Garam Food-Grade (DIY)',
          icon: CupertinoIcons.sparkles,
          color: const Color(0xFF5D4037),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropRow(
                'Epsom Salt (MgSO₄ · 7H₂O)',
                null,
                '${(p.epsomSaltGramsPerLiter * _volumeLiters).toStringAsFixed(2)} g (Hardness GH)',
              ),
              _buildDropRow(
                'Baking Soda (NaHCO₃)',
                null,
                '${(p.bakingSodaGramsPerLiter * _volumeLiters).toStringAsFixed(2)} g (Buffer KH)',
              ),
              const SizedBox(height: 6),
              Text(
                isEn
                    ? 'Dissolve in 0 ppm distilled / demineralized water (Amidis / Cleo / Aquades).'
                    : 'Larutkan ke dalam air demineral 0 ppm (Amidis, Cleo murni, atau air destilasi).',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPpmBadge(String title, String val, Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: c.withValues(alpha: 0.7), fontSize: 10),
        ),
        Text(
          val,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 13.5),
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildDropRow(String name, int? drops, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 10.5)),
              ],
            ),
          ),
          if (drops != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$drops tetes',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppTheme.primaryBrown,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBrown : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13.5,
                color: selected ? Colors.white : AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppTheme.textMuted,
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
