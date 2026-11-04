import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/water/models/water_profile.dart';
import '../features/water/widgets/water_buffer_card.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// Professional Coffee Water Chemistry & Remineralization Calculator.
class WaterRecipeScreen extends StatefulWidget {
  const WaterRecipeScreen({super.key});

  @override
  State<WaterRecipeScreen> createState() => _WaterRecipeScreenState();
}

class _WaterRecipeScreenState extends State<WaterRecipeScreen> {
  int _volumeLiters = 1;
  String _selectedPreset = 'sca';

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
  };

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final p = _profiles[_selectedPreset] ?? _profiles['sca']!;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? 'Coffee Water Chemistry' : 'Kimia Air Seduh Kopi'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_volumeLiters L Destilasi/RO',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(p.origin, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPpmBadge('GH (Hardness)', '${p.ghPpm} ppm', Colors.white),
                    const SizedBox(width: 14),
                    _buildPpmBadge('KH (Alkalinity)', '${p.khPpm} ppm', Colors.white),
                    const SizedBox(width: 14),
                    _buildPpmBadge('Buffer Rasio', '${p.bufferRatio.toStringAsFixed(1)}:1', Colors.white),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Buffer Ratio & Sensory Prediction Barometer
          WaterBufferCard(profile: p),
          const SizedBox(height: 14),

          // Preset Selection Chips
          Text(
            isEn ? 'Water Mineral Profiles:' : 'Pilih Profil Target Air:',
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
                        border: Border.all(color: active ? AppTheme.primaryBrown : Colors.grey.shade300),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEn ? 'Batch Volume:' : 'Volume Batch Air:',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Row(
                  children: [1, 2, 5, 19].map((v) {
                    final sel = _volumeLiters == v;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _volumeLiters = v),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? p.accentColor : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            v == 19 ? '19L Galon' : '${v}L',
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
            title: 'Opsi 2: Racikan Garam Dapur (DIY Food-Grade)',
            icon: CupertinoIcons.sparkles,
            color: const Color(0xFF5D4037),
            child: Column(
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
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildPpmBadge(String title, String val, Color c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: c.withValues(alpha: 0.7), fontSize: 10)),
        Text(val, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 13.5)),
      ],
    );
  }

  Widget _buildMethodCard({required String title, required IconData icon, required Color color, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color))),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBrown),
              ),
            ),
        ],
      ),
    );
  }
}
