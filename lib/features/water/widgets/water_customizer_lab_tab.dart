import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../services/water_chemistry_engine.dart';

/// Tab 1: Lab Kustomisasi Mineral & Simulasi "Apa Jadinya Jika Ditambah..." berbasis stoikiometri aktual.
class WaterCustomizerLabTab extends StatelessWidget {
  final BaseWaterPreset baseWater;
  final List<BaseWaterPreset> availableBases;
  final MineralAddition addition;
  final double batchLiters;
  final ValueChanged<BaseWaterPreset> onBaseWaterChanged;
  final ValueChanged<MineralAddition> onAdditionChanged;
  final ValueChanged<double> onBatchLitersChanged;

  const WaterCustomizerLabTab({
    super.key,
    required this.baseWater,
    required this.availableBases,
    required this.addition,
    required this.batchLiters,
    required this.onBaseWaterChanged,
    required this.onAdditionChanged,
    required this.onBatchLitersChanged,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = WaterChemistryEngine.analyze(
      baseWater: baseWater,
      addition: addition,
    );

    final scoreColor = analysis.readinessScore >= 82
        ? const Color(0xFF0F766E)
        : (analysis.readinessScore >= 60
            ? const Color(0xFFB45309)
            : const Color(0xFFC2410C));

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
      children: [
        // 1. LIVE WATER CHEMISTRY DASHBOARD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scoreColor, scoreColor.withValues(alpha: 0.84)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: scoreColor.withValues(alpha: 0.24),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
                          'SIMULASI KIMIA AIR REAL-TIME',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white70,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          baseWater.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${analysis.readinessScore}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const Text(
                          'Skor SCA',
                          style: TextStyle(fontSize: 8.5, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetricTile('GH', '${analysis.ghPpm.round()} ppm'),
                  const SizedBox(width: 6),
                  _MetricTile('KH', '${analysis.khPpm.round()} ppm'),
                  const SizedBox(width: 6),
                  _MetricTile('TDS', '${analysis.estimatedTdsPpm.round()} ppm'),
                  const SizedBox(width: 6),
                  _MetricTile('EC', '${analysis.estimatedEcUsCm.round()} µS'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SubPill('pH ${analysis.estimatedPh.toStringAsFixed(2)}'),
                  const SizedBox(width: 6),
                  _SubPill('GH:KH ${analysis.ghKhRatio.toStringAsFixed(1)}:1'),
                  const SizedBox(width: 6),
                  _SubPill('Mg:Ca ${analysis.mgCaRatio.toStringAsFixed(1)}:1'),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  analysis.profileSummary,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Colors.white,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. AIR DASAR + VOLUME BATCH + QUICK EXPERIMENT PRESETS
        _LabCard(
          title: '1. Pilih Air Dasar & Target Eksperimen',
          icon: CupertinoIcons.drop_fill,
          accent: const Color(0xFF0369A1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: availableBases.map((b) {
                    final sel = b.id == baseWater.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => onBaseWaterChanged(b),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF0369A1) : AppTheme.bgCream,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sel
                                  ? const Color(0xFF0369A1)
                                  : AppTheme.primaryBrown.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Text(
                            b.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: sel ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                baseWater.subtitle,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),

              // Dilusi RO aktif otomatis jika air dasar mengandung mineral tinggi
              if (baseWater.tdsPpm > 30) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Campur Dilusi Air RO (0 ppm):',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${(addition.roDilutionRatio * 100).round()}% RO',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: addition.roDilutionRatio,
                  min: 0,
                  max: 0.9,
                  divisions: 18,
                  activeColor: const Color(0xFF0369A1),
                  onChanged: (v) =>
                      onAdditionChanged(addition.copyWith(roDilutionRatio: v)),
                ),
              ],

              const SizedBox(height: 8),
              // Quick Preset Actions
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _QuickActionChip(
                    label: 'SCA Balance',
                    onTap: () {
                      onBaseWaterChanged(WaterChemistryEngine.baseWaters.first);
                      onAdditionChanged(const MineralAddition(
                        epsomSaltMgPerL: 110,
                        calciumChlorideMgPerL: 34,
                        bakingSodaMgPerL: 42,
                        potassiumBicarbMgPerL: 30,
                      ));
                    },
                  ),
                  _QuickActionChip(
                    label: 'V60 Acid Pop',
                    onTap: () {
                      onBaseWaterChanged(WaterChemistryEngine.baseWaters.first);
                      onAdditionChanged(const MineralAddition(
                        epsomSaltMgPerL: 165,
                        calciumChlorideMgPerL: 18,
                        bakingSodaMgPerL: 0,
                        potassiumBicarbMgPerL: 44,
                      ));
                    },
                  ),
                  _QuickActionChip(
                    label: 'Espresso Creamy',
                    onTap: () {
                      onBaseWaterChanged(WaterChemistryEngine.baseWaters.first);
                      onAdditionChanged(const MineralAddition(
                        epsomSaltMgPerL: 85,
                        calciumChlorideMgPerL: 65,
                        bakingSodaMgPerL: 65,
                        potassiumBicarbMgPerL: 15,
                      ));
                    },
                  ),
                  _QuickActionChip(
                    label: 'Reset 0',
                    isMuted: true,
                    onTap: () => onAdditionChanged(const MineralAddition()),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Volume Batch
              Row(
                children: [
                  const Text(
                    'Batch:',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [0.5, 1.0, 2.0, 5.0, 19.0].map((liters) {
                          final sel = (batchLiters - liters).abs() < 0.01;
                          final label = liters == 19.0
                              ? '19L Galon'
                              : (liters == 0.5 ? '0.5L' : '${liters.round()}L');
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => onBatchLitersChanged(liters),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: sel ? AppTheme.primaryBrown : AppTheme.bgCream,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: sel ? Colors.white : AppTheme.textDark,
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
        const SizedBox(height: 12),

        // 3. KUSTOMISASI 4 MINERAL INTERAKTIF ("DITAMBAH INI -> JADI APA?")
        _LabCard(
          title: '2. Kustomisasi Mineral (mg/L)',
          icon: CupertinoIcons.lab_flask_solid,
          accent: const Color(0xFF0F766E),
          child: Column(
            children: [
              _MineralSliderRow(
                title: 'Epsom Salt (MgSO₄·7H₂O)',
                effect: 'Tarik rasa buah, floral & manis · +GH (Mg²⁺)',
                valueMgL: addition.epsomSaltMgPerL,
                maxMgL: 350,
                batchLiters: batchLiters,
                color: const Color(0xFF0F766E),
                onChanged: (v) =>
                    onAdditionChanged(addition.copyWith(epsomSaltMgPerL: v)),
              ),
              const Divider(height: 14),
              _MineralSliderRow(
                title: 'Calcium Chloride (CaCl₂·2H₂O)',
                effect: 'Pertebal body creamy & cokelat · +GH (Ca²⁺/Cl⁻)',
                valueMgL: addition.calciumChlorideMgPerL,
                maxMgL: 200,
                batchLiters: batchLiters,
                color: const Color(0xFF1565C0),
                onChanged: (v) =>
                    onAdditionChanged(addition.copyWith(calciumChlorideMgPerL: v)),
              ),
              const Divider(height: 14),
              _MineralSliderRow(
                title: 'Baking Soda (NaHCO₃)',
                effect: 'Buffer asam tajam & bulatkan rasa · +KH (Na⁺)',
                valueMgL: addition.bakingSodaMgPerL,
                maxMgL: 150,
                batchLiters: batchLiters,
                color: const Color(0xFFC2410C),
                onChanged: (v) =>
                    onAdditionChanged(addition.copyWith(bakingSodaMgPerL: v)),
              ),
              const Divider(height: 14),
              _MineralSliderRow(
                title: 'Potassium Bicarb (KHCO₃)',
                effect: 'Buffer bersih tanpa Natrium · +KH (K⁺ Clarity)',
                valueMgL: addition.potassiumBicarbMgPerL,
                maxMgL: 150,
                batchLiters: batchLiters,
                color: const Color(0xFF7C3AED),
                onChanged: (v) =>
                    onAdditionChanged(addition.copyWith(potassiumBicarbMgPerL: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. PREDIKSI SENSORI 5 SUMBU
        _LabCard(
          title: '3. Prediksi Dampak Sensori di Cangkir',
          icon: CupertinoIcons.sparkles,
          accent: const Color(0xFF7C3AED),
          child: Column(
            children: [
              _SensoryBar('Kecerahan Asam (Acidity)', analysis.sensory.acidityClarity, const Color(0xFF8E24AA)),
              _SensoryBar('Rasa Manis (Sweetness)', analysis.sensory.sweetness, const Color(0xFF0F766E)),
              _SensoryBar('Body & Mouthfeel', analysis.sensory.bodyMouthfeel, const Color(0xFF8D4925)),
              _SensoryBar('Aroma Floral & Buah', analysis.sensory.floralAroma, const Color(0xFF1565C0)),
              _SensoryBar('Keseimbangan (Balance)', analysis.sensory.smoothnessBalance, const Color(0xFFD97706)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 5. PENJELASAN ILMIAH "APA EFEKNYA?" + KEAMANAN BOILER
        _LabCard(
          title: '4. Analisis Reaksi Mineral & Keamanan Mesin',
          icon: CupertinoIcons.checkmark_shield_fill,
          accent: analysis.boilerStatus == BoilerSafetyStatus.optimal
              ? const Color(0xFF15803D)
              : const Color(0xFFB45309),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: analysis.boilerStatus == BoilerSafetyStatus.optimal
                      ? const Color(0xFFF0FDF4)
                      : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: analysis.boilerStatus == BoilerSafetyStatus.optimal
                        ? const Color(0xFFBBF7D0)
                        : Colors.amber.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.boilerHeadline,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: analysis.boilerStatus == BoilerSafetyStatus.optimal
                            ? const Color(0xFF166534)
                            : Colors.brown.shade900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      analysis.boilerAdvice,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textDark, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...analysis.whatIfInsights.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBrown)),
                      Expanded(
                        child: Text(
                          line,
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.textDark, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 16),
              const Text(
                'Komposisi Ionik Terlarut (mg/L):',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _IonPill('Mg²⁺', '${analysis.mgIonMgL.toStringAsFixed(1)} mg/L'),
                  _IonPill('Ca²⁺', '${analysis.caIonMgL.toStringAsFixed(1)} mg/L'),
                  _IonPill('Na⁺', '${analysis.naIonMgL.toStringAsFixed(1)} mg/L'),
                  _IonPill('K⁺', '${analysis.kIonMgL.toStringAsFixed(1)} mg/L'),
                  _IonPill('SO₄²⁻', '${analysis.so4IonMgL.toStringAsFixed(1)} mg/L'),
                  _IonPill('Cl⁻', '${analysis.clIonMgL.toStringAsFixed(1)} mg/L'),
                  _IonPill('HCO₃⁻', '${analysis.hco3IonMgL.toStringAsFixed(1)} mg/L'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.white70)),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubPill extends StatelessWidget {
  final String text;

  const _SubPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _LabCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Widget child;

  const _LabCard({
    required this.title,
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
              Icon(icon, size: 17, color: accent),
              const SizedBox(width: 7),
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
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MineralSliderRow extends StatelessWidget {
  final String title;
  final String effect;
  final double valueMgL;
  final double maxMgL;
  final double batchLiters;
  final Color color;
  final ValueChanged<double> onChanged;

  const _MineralSliderRow({
    required this.title,
    required this.effect,
    required this.valueMgL,
    required this.maxMgL,
    required this.batchLiters,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalGrams = (valueMgL * batchLiters) / 1000.0;
    // Larutan stok 1% (10g/L) -> 1 mL = 10 mg garam
    final stockMl = (valueMgL * batchLiters) / 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    effect,
                    style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${valueMgL.round()} mg/L',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
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
            value: valueMgL.clamp(0, maxMgL),
            min: 0,
            max: maxMgL,
            divisions: (maxMgL / 5).round(),
            onChanged: onChanged,
          ),
        ),
        Text(
          'Takaran batch (${batchLiters == 0.5 ? "0.5" : batchLiters.round()}L): ${totalGrams.toStringAsFixed(3)} g bubuk  •  atau ${stockMl.toStringAsFixed(1)} mL stok 1%',
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppTheme.primaryBrown),
        ),
      ],
    );
  }
}

class _SensoryBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SensoryBar(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
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
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${value.round()}%',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: (value / 100.0).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: color.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isMuted;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMuted ? Colors.grey.shade100 : AppTheme.primaryBrown.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isMuted
                ? Colors.grey.shade300
                : AppTheme.primaryBrown.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isMuted ? AppTheme.textMuted : AppTheme.primaryBrown,
          ),
        ),
      ),
    );
  }
}

class _IonPill extends StatelessWidget {
  final String ion;
  final String val;

  const _IonPill(this.ion, this.val);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7D9C6)),
      ),
      child: Text(
        '$ion: $val',
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.textDark),
      ),
    );
  }
}
