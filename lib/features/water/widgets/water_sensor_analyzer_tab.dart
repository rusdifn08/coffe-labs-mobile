import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../services/water_chemistry_engine.dart';

/// Tab 2: Deteksi Air & Multi-Sensor Analyzer (TDS/EC · Ion Selektif ISE · E-Tongue Multi-Sensor).
class WaterSensorAnalyzerTab extends StatefulWidget {
  final ValueChanged<BaseWaterPreset> onOptimizeInLab;

  const WaterSensorAnalyzerTab({
    super.key,
    required this.onOptimizeInLab,
  });

  @override
  State<WaterSensorAnalyzerTab> createState() => _WaterSensorAnalyzerTabState();
}

class _WaterSensorAnalyzerTabState extends State<WaterSensorAnalyzerTab> {
  bool _inputAsEc = false; // false = TDS (ppm), true = EC (µS/cm)
  double _ecUsCm = 156.0; // ~100 ppm pada faktor 0.64
  double _tdsFactor = 0.64; // 0.50 NaCl, 0.64 KCl/Kopi, 0.70 442
  double _freeChlorine = 0.0;
  double _chloride = 12.0;
  double _nitrate = 2.0;
  double _ammonium = 0.0;
  double _sodiumSalinity = 8.0;
  double _measuredPh = 7.1;

  void _applyWaterSample({
    required double tds,
    required double cl2,
    required double cl,
    required double no3,
    required double nh4,
    required double na,
    required double ph,
  }) {
    setState(() {
      _ecUsCm = (tds / _tdsFactor).clamp(0, 1200);
      _freeChlorine = cl2;
      _chloride = cl;
      _nitrate = no3;
      _ammonium = nh4;
      _sodiumSalinity = na;
      _measuredPh = ph;
    });
  }

  @override
  Widget build(BuildContext context) {
    final readings = WaterSensorReadings(
      ecUsCm: _ecUsCm,
      tdsFactor: _tdsFactor,
      freeChlorineMgL: _freeChlorine,
      chlorideMgL: _chloride,
      nitrateMgL: _nitrate,
      ammoniumMgL: _ammonium,
      sodiumSalinityMgL: _sodiumSalinity,
      measuredPh: _measuredPh,
    );
    final report = WaterChemistryEngine.diagnoseSensors(readings);

    final heroColor = report.overallScore >= 80
        ? const Color(0xFF0F766E)
        : (report.overallScore >= 55
            ? const Color(0xFFB45309)
            : const Color(0xFFDC2626));

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
      children: [
        // 1. E-TONGUE MULTI-SENSOR VERDICT HERO
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [heroColor, heroColor.withValues(alpha: 0.86)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HASIL DETEKSI MULTI-SENSOR AIR',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white70,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          report.tdsCategory,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${report.overallScore}/100',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Kesiapan',
                          style: TextStyle(fontSize: 8.5, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                report.recommendedAction,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Colors.white,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onOptimizeInLab(report.estimatedBaseWater),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: heroColor,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  icon: const Icon(CupertinoIcons.lab_flask_solid, size: 15),
                  label: const Text(
                    'Optimasi & Racik Air Ini di Lab Kustom',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. PANEL SENSOR 1: TDS / KONDUKTIVITAS (EC)
        _SensorPanelCard(
          badge: 'SENSOR 1',
          title: 'Sensor TDS / Konduktivitas (EC)',
          subtitle:
              'Mengukur daya hantar listrik air dari ion mineral terlarut (ppm atau µS/cm). Semakin banyak ion mineral, semakin tinggi EC & TDS.',
          icon: CupertinoIcons.gauge,
          accent: const Color(0xFF0369A1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Indonesian water samples
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SampleChip('Amidis/RO (5 ppm)', () => _applyWaterSample(tds: 5, cl2: 0, cl: 1, no3: 0, nh4: 0, na: 1, ph: 6.8)),
                    const SizedBox(width: 6),
                    _SampleChip('Cleo (15 ppm)', () => _applyWaterSample(tds: 15, cl2: 0, cl: 2, no3: 1, nh4: 0, na: 2, ph: 7.0)),
                    const SizedBox(width: 6),
                    _SampleChip('Mineral Ideal (100 ppm)', () => _applyWaterSample(tds: 100, cl2: 0, cl: 12, no3: 2, nh4: 0, na: 8, ph: 7.2)),
                    const SizedBox(width: 6),
                    _SampleChip('PDAM Kaporit (240 ppm)', () => _applyWaterSample(tds: 240, cl2: 0.4, cl: 42, no3: 14, nh4: 0.2, na: 24, ph: 7.6)),
                    const SizedBox(width: 6),
                    _SampleChip('Sumur Sadah (420 ppm)', () => _applyWaterSample(tds: 420, cl2: 0.0, cl: 65, no3: 52, nh4: 0.8, na: 38, ph: 8.1)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Toggle input mode TDS vs EC
              Row(
                children: [
                  Expanded(
                    child: _ModePill(
                      label: 'TDS: ${report.tdsPpm.round()} ppm',
                      selected: !_inputAsEc,
                      color: const Color(0xFF0369A1),
                      onTap: () => setState(() => _inputAsEc = false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModePill(
                      label: 'EC: ${report.ecUsCm.round()} µS/cm',
                      selected: _inputAsEc,
                      color: const Color(0xFF0369A1),
                      onTap: () => setState(() => _inputAsEc = true),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _inputAsEc
                    ? _ecUsCm.clamp(0, 1000)
                    : report.tdsPpm.clamp(0, 650),
                min: 0,
                max: _inputAsEc ? 1000 : 650,
                divisions: 100,
                activeColor: const Color(0xFF0369A1),
                onChanged: (v) {
                  setState(() {
                    _ecUsCm = _inputAsEc ? v : (v / _tdsFactor);
                  });
                },
              ),
              // Faktor konversi probe
              Row(
                children: [
                  const Text('Faktor Probe:', style: TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FactorPill('0.50 NaCl', 0.50, _tdsFactor, (f) => setState(() => _tdsFactor = f)),
                          const SizedBox(width: 5),
                          _FactorPill('0.64 KCl (Kopi)', 0.64, _tdsFactor, (f) => setState(() => _tdsFactor = f)),
                          const SizedBox(width: 5),
                          _FactorPill('0.70 442', 0.70, _tdsFactor, (f) => setState(() => _tdsFactor = f)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.tdsDiagnosis,
                style: const TextStyle(fontSize: 11.5, color: AppTheme.textDark, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. PANEL SENSOR 2: ION SELEKTIF (ISE) / ANALYZER SPESIFIK
        _SensorPanelCard(
          badge: 'SENSOR 2',
          title: 'Sensor Ion Selektif (ISE) & pH',
          subtitle:
              'Membaca konsentrasi ion spesifik (klorin, klorida, nitrat, amonium, salinitas/natrium) untuk aplikasi roastery, kafe, & pemantauan air baku.',
          icon: Icons.science_rounded,
          accent: const Color(0xFF7C3AED),
          child: Column(
            children: [
              _IonSlider(
                label: 'pH Meter Air',
                valueText: _measuredPh.toStringAsFixed(1),
                value: _measuredPh,
                min: 5.5,
                max: 9.0,
                divisions: 35,
                color: const Color(0xFF0F766E),
                onChanged: (v) => setState(() => _measuredPh = v),
              ),
              _IonSlider(
                label: 'Klorin Bebas / Kaporit (Cl₂)',
                valueText: '${_freeChlorine.toStringAsFixed(2)} mg/L',
                value: _freeChlorine,
                min: 0.0,
                max: 1.5,
                divisions: 30,
                color: const Color(0xFFDC2626),
                onChanged: (v) => setState(() => _freeChlorine = v),
              ),
              _IonSlider(
                label: 'Klorida (Cl⁻ · Risiko Korosi >50)',
                valueText: '${_chloride.round()} mg/L',
                value: _chloride,
                min: 0,
                max: 120,
                divisions: 24,
                color: const Color(0xFFC2410C),
                onChanged: (v) => setState(() => _chloride = v),
              ),
              _IonSlider(
                label: 'Nitrat (NO₃⁻ · Batas WHO <50)',
                valueText: '${_nitrate.round()} mg/L',
                value: _nitrate,
                min: 0,
                max: 80,
                divisions: 40,
                color: const Color(0xFF7C3AED),
                onChanged: (v) => setState(() => _nitrate = v),
              ),
              _IonSlider(
                label: 'Amonium (NH₄⁺ · Ideal <0.5)',
                valueText: '${_ammonium.toStringAsFixed(2)} mg/L',
                value: _ammonium,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                color: const Color(0xFF9333EA),
                onChanged: (v) => setState(() => _ammonium = v),
              ),
              _IonSlider(
                label: 'Salinitas / Natrium (Na⁺ · Ideal <20)',
                valueText: '${_sodiumSalinity.round()} mg/L',
                value: _sodiumSalinity,
                min: 0,
                max: 80,
                divisions: 40,
                color: const Color(0xFF1565C0),
                onChanged: (v) => setState(() => _sodiumSalinity = v),
              ),
              if (report.iseAlerts.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: report.iseAlerts
                        .map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              a,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.brown.shade900,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Text(
                    '✓ Seluruh pembacaan ISE (Klorin, Klorida, Nitrat, Amonium, Salinitas, & pH) bersih dalam ambang aman specialty coffee.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. PANEL SENSOR 3: E-TONGUE / MULTI-SENSOR PATTERN FINGERPRINT
        _SensorPanelCard(
          badge: 'SENSOR 3',
          title: 'Sensor E-Tongue / Multi-Sensor Array',
          subtitle:
              'Menggabungkan array beberapa elektroda sensor & algoritma pola untuk mengenali sidik jari rasa mineral maupun kontaminan dalam pengujian lanjutan.',
          icon: CupertinoIcons.sparkles,
          accent: AppTheme.primaryBrown,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...report.eTongueChannels.entries.map((entry) {
                final isRisk = entry.key.contains('Off-Flavor') || entry.key.contains('Flat');
                final barColor = isRisk
                    ? (entry.value > 45 ? const Color(0xFFDC2626) : const Color(0xFFD97706))
                    : const Color(0xFF0F766E);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            '${entry.value.round()}%',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: barColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: (entry.value / 100.0).clamp(0.0, 1.0),
                          minHeight: 7,
                          backgroundColor: barColor.withValues(alpha: 0.14),
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 16),
              const Text(
                'Ringkasan Perbandingan 3 Jenis Sensor Air:',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              const _SensorRefBullet(
                title: 'TDS / EC Meter',
                detail: 'Cepat & ekonomis (µS/cm · ppm), cocok cek harian total mineral & filter RO, namun tidak bisa membedakan Mg²⁺ vs Ca²⁺ vs Na⁺.',
              ),
              const _SensorRefBullet(
                title: 'Ion Selektif (ISE)',
                detail: 'Membaca ion spesifik (NO₃⁻, NH₄⁺, Cl⁻, salinitas) secara selektif untuk QC kafe/roastery, keamanan boiler, & uji lingkungan.',
              ),
              const _SensorRefBullet(
                title: 'E-Tongue Multi-Sensor',
                detail: 'Menggabungkan multi-sensor + algoritma pengenalan pola untuk memetakan profil rasa mineral & mendeteksi kontaminan riset lanjutan.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SensorPanelCard extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget child;

  const _SensorPanelCard({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE4D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.35),
          ),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SampleChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SampleChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE7D9C6)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModePill({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : AppTheme.bgCream,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}

class _FactorPill extends StatelessWidget {
  final String label;
  final double factor;
  final double current;
  final ValueChanged<double> onSelect;

  const _FactorPill(this.label, this.factor, this.current, this.onSelect);

  @override
  Widget build(BuildContext context) {
    final sel = (factor - current).abs() < 0.01;
    return GestureDetector(
      onTap: () => onSelect(factor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primaryBrown : AppTheme.bgCream,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: sel ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}

class _IonSlider extends StatelessWidget {
  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final ValueChanged<double> onChanged;

  const _IonSlider({
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              valueText,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.16),
            thumbColor: color,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _SensorRefBullet extends StatelessWidget {
  final String title;
  final String detail;

  const _SensorRefBullet({required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.35),
          children: [
            TextSpan(
              text: '• $title: ',
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryBrown),
            ),
            TextSpan(text: detail),
          ],
        ),
      ),
    );
  }
}
