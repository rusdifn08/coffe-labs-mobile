import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/barista_toolkit_models.dart';

/// Laboratorium simulasi variabel interaktif untuk seluruh 30 Sub-Bab Kurikulum Manual Brew.
class LmsInteractiveLabWidget extends StatefulWidget {
  final LmsLessonModel lesson;

  const LmsInteractiveLabWidget({super.key, required this.lesson});

  @override
  State<LmsInteractiveLabWidget> createState() =>
      _LmsInteractiveLabWidgetState();
}

class _LmsInteractiveLabWidgetState extends State<LmsInteractiveLabWidget> {
  final Map<String, double> _nums = {};
  final Map<String, bool> _bools = {};
  final Map<String, String> _strs = {};

  @override
  void initState() {
    super.initState();
    _initDefaultsFromLesson();
  }

  @override
  void didUpdateWidget(covariant LmsInteractiveLabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lesson.id != widget.lesson.id) {
      _initDefaultsFromLesson();
    }
  }

  void _initDefaultsFromLesson() {
    _nums.clear();
    _bools.clear();
    _strs.clear();
    final defaults =
        (widget.lesson.simulationConfig['defaults'] as Map?) ?? const {};
    for (final entry in defaults.entries) {
      final k = entry.key.toString();
      final v = entry.value;
      if (v is num) {
        _nums[k] = v.toDouble();
      } else if (v is bool) {
        _bools[k] = v;
      } else if (v != null) {
        _strs[k] = v.toString();
      }
    }
  }

  double _num(String key, double fallback) => _nums[key] ?? fallback;
  bool _flag(String key, bool fallback) => _bools[key] ?? fallback;
  String _str(String key, String fallback) => _strs[key] ?? fallback;

  String get _labKind =>
      widget.lesson.simulationConfig['lab_kind']?.toString() ?? 'GENERIC_LAB';

  String get _labTitle =>
      widget.lesson.simulationConfig['title']?.toString() ??
      'Laboratorium Simulasi ${widget.lesson.subchapterCode}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1610),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.science_rounded,
                  color: AppTheme.accentGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _labTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      'Sub-Bab ${widget.lesson.subchapterCode} • $_labKind',
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Reset Default',
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white70, size: 19),
                onPressed: () => setState(_initDefaultsFromLesson),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSpecificLab(),
        ],
      ),
    );
  }

  Widget _buildSpecificLab() {
    switch (_labKind) {
      case 'BCC_XY_SIMULATOR':
        final dose = _num('dose_g', 15.0);
        final water = _num('water_ml', 250.0);
        final grind = _num('grind_um', 680.0);
        final ratio = water / dose;
        final ey = (20.4 + (700 - grind) / 85.0 + (ratio - 16.0) * 0.45)
            .clamp(14.5, 25.5);
        final tds = ((dose * (ey / 100.0)) / (water * 0.89)).clamp(0.85, 1.95) *
            100.0;
        final status = ey < 18.0
            ? 'Under-Extracted (Sour / Tajam)'
            : (ey > 22.2
                ? 'Over-Extracted (Bitter / Dry)'
                : (tds < 1.15
                    ? 'Sweet & Clean (Weak / Tea-Like)'
                    : 'SCA Golden Cup Sweet Spot'));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slider('Dosis Bubuk (g)', 'dose_g', dose, 12, 24, 'g'),
            _slider('Total Air Seduh (ml)', 'water_ml', water, 180, 380, 'ml'),
            _slider('Ukuran Gilingan (um)', 'grind_um', grind, 400, 1050, 'um'),
            _telemetryRow([
              ('Rasio', '1:${ratio.toStringAsFixed(1)}'),
              ('Est. EY', '${ey.toStringAsFixed(1)}%'),
              ('Est. TDS', '${tds.toStringAsFixed(2)}%'),
            ]),
            const SizedBox(height: 8),
            _verdictBox(status, ey >= 18 && ey <= 22.2),
          ],
        );

      case 'WATER_ION_LAB':
        final ca = _num('ca_ppm', 25.0);
        final mg = _num('mg_ppm', 35.0);
        final kh = _num('kh_ppm', 35.0);
        final gh = 2.497 * ca + 4.118 * mg;
        final ratio = ca > 0 ? mg / ca : 2.0;
        final verdict = kh < 20
            ? 'Buffer Rendah: Asam tajam menusuk & kurang stabil'
            : (kh > 65
                ? 'Buffer Tinggi: Asam teredam rata (Flat & Chalky)'
                : 'SCA Balanced: Manis buah & kejernihan optimal');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slider('Kalsium Ca2+ (Body/Krem)', 'ca_ppm', ca, 0, 80, 'ppm'),
            _slider('Magnesium Mg2+ (Fruity/Bright)', 'mg_ppm', mg, 0, 80, 'ppm'),
            _slider('Alkalinitas Buffer KH (HCO3-)', 'kh_ppm', kh, 5, 110, 'ppm'),
            _telemetryRow([
              ('Total GH', '${gh.toStringAsFixed(0)} ppm'),
              ('KH Buffer', '${kh.toStringAsFixed(0)} ppm'),
              ('Mg:Ca', '${ratio.toStringAsFixed(2)}x'),
            ]),
            const SizedBox(height: 8),
            _verdictBox(verdict, kh >= 20 && kh <= 65),
          ],
        );

      case 'DEGASSING_BLOOM_LAB':
        final age = _num('roast_age_days', 4.0);
        final bloom = _num('bloom_sec', 45.0);
        final ratio = _num('bloom_ratio', 3.0);
        final co2Residual = (100.0 / (1.0 + age * 0.25)).clamp(8.0, 92.0);
        final degasOk = (age < 5 && bloom >= 45 && ratio >= 2.5) ||
            (age >= 5 && bloom >= 30);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slider('Usia Pascasangrai (hari)', 'roast_age_days', age, 1, 30, 'hr'),
            _slider('Durasi Blooming (detik)', 'bloom_sec', bloom, 20, 90, 'dtk'),
            _slider('Rasio Air Bloom (x dosis)', 'bloom_ratio', ratio, 2.0, 4.0, 'x'),
            _telemetryRow([
              ('Sisa CO2', '${co2Residual.toStringAsFixed(0)}%'),
              ('Bloom Target', '${(15 * ratio).toStringAsFixed(0)} ml'),
            ]),
            const SizedBox(height: 8),
            _verdictBox(
              degasOk
                  ? 'Degassing Optimal: Gas CO2 lolos tanpa memblokir ekstraksi.'
                  : 'Perpanjang bloom 45–60s + 3x air untuk biji sangat segar!',
              degasOk,
            ),
          ],
        );

      case 'PARAGON_VOC_CHILL':
        final gap = _num('gap_mm', 3.5);
        final chillPct = _num('chill_fraction_pct', 30.0);
        final temp = _num('rock_temp_c', -15.0);
        final vocSave = ((gap <= 5.0 ? 88.0 : 52.0) +
                (chillPct >= 25 && chillPct <= 35 ? 10.0 : -12.0))
            .clamp(30.0, 99.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slider('Jarak Gap Corong–Bola (mm)', 'gap_mm', gap, 1.0, 14.0, 'mm'),
            _slider('Fraksi Chilling (%)', 'chill_fraction_pct', chillPct, 15, 65, '%'),
            _slider('Suhu Bola Chilling (C)', 'rock_temp_c', temp, -20, 5, 'C'),
            _telemetryRow([
              ('Retensi Ester/VOC', '${vocSave.toStringAsFixed(0)}%'),
              ('Zona Gap <5mm', gap <= 5.0 ? 'AMAN' : 'BOCOR UAP'),
            ]),
            const SizedBox(height: 8),
            _verdictBox(
              gap <= 5.0
                  ? 'Aroma floral & buah terkunci rapat ke cangkir tanpa pendinginan berlebih.'
                  : 'Turunkan jarak < 5 mm agar senyawa volatil tidak teroksidasi!',
              gap <= 5.0 && chillPct <= 40,
            ),
          ],
        );

      case 'DARCY_BED_LAB':
        final grind = _num('grind_um', 620.0);
        final height = _num('slurry_height_cm', 3.5);
        final temp = _num('water_temp_c', 93.0);
        final vis = 0.89 / (1.0 + (temp - 25.0) * 0.015);
        final qFlow = ((grind / 600.0) * (height / 3.0) / vis * 2.2)
            .clamp(0.8, 9.5);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slider('Ukuran Gilingan (um)', 'grind_um', grind, 350, 1000, 'um'),
            _slider('Tinggi Kolom Air h(t)', 'slurry_height_cm', height, 1.5, 7.0, 'cm'),
            _slider('Suhu Air (Viskositas)', 'water_temp_c', temp, 80, 98, 'C'),
            _telemetryRow([
              ('Laju Darcy Q', '${qFlow.toStringAsFixed(1)} ml/s'),
              ('Viskositas Rel.', vis.toStringAsFixed(2)),
            ]),
            const SizedBox(height: 8),
            _verdictBox(
              qFlow < 2.2
                  ? 'Hambatan bed sangat tinggi -> Risiko stalling & pahit.'
                  : (qFlow > 6.5
                      ? 'Terlalu cepat -> Kurang waktu kontak (Acidic/Thin).'
                      : 'Aliran Darcy Seimbang (1:55–2:30 drawdown).'),
              qFlow >= 2.2 && qFlow <= 6.5,
            ),
          ],
        );

      case 'FINES_MIGRATION_LAB':
        final swirl = _num('swirl_intensity', 0.25);
        final conical = _flag('is_conical', true);
        final choke = swirl > 0.65 || (swirl > 0.45 && conical);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slider('Intensitas Swirl', 'swirl_intensity', swirl, 0.0, 1.0, ''),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Geometri Kerucut V60 (vs Flat)',
                  style: TextStyle(color: Colors.white, fontSize: 12.5)),
              value: conical,
              onChanged: (v) => setState(() => _bools['is_conical'] = v),
            ),
            _verdictBox(
              choke
                  ? 'Peringatan Efek Kacang Brasil Terbalik: Fines turun menyumbat ujung filter!'
                  : 'Distribusi partikel merata — drawdown stabil & bebas genangan.',
              !choke,
            ),
          ],
        );

      case 'GOOSENECK_TURBULENCE_LAB':
        final height = _num('pour_height_cm', 8.0);
        final flow = _num('flow_ml_s', 5.2);
        final melodrip = _flag('use_melodrip', false);
        final energy = melodrip ? 12.0 : (height * flow * 1.4).clamp(10.0, 120.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slider('Tinggi Tuang Ketel (cm)', 'pour_height_cm', height, 2, 22, 'cm'),
            _slider('Laju Alir (ml/s)', 'flow_ml_s', flow, 2, 11, 'ml/s'),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pasang Dispersion Screen (Melodrip)',
                  style: TextStyle(color: Colors.white, fontSize: 12.5)),
              value: melodrip,
              onChanged: (v) => setState(() => _bools['use_melodrip'] = v),
            ),
            _telemetryRow([
              ('Energi Kinetik Bed', '${energy.toStringAsFixed(0)} mJ'),
              ('Mode Aliran', melodrip ? 'Ultra-Calm Drop' : 'Direct Jet'),
            ]),
          ],
        );

      case 'DRIPPER_CAD_LAB':
        final dripper = _str('dripper_id', 'v60');
        final preheated = _flag('preheated', true);
        final options = const ['v60', 'origami', 'solo', 'ufo', 'orea', 'april'];
        final specs = <String, (String, String)>{
          'v60': ('Kerucut 60° • Spiral Ribs', 'Cepat & high clarity; wajib swirl lembut.'),
          'origami': ('Kerucut 20 Lipatan', 'Bypass sangat rendah dengan wave filter, sangat tinggi dengan cone.'),
          'solo': ('Single-Hole Flat/Cone', 'Aliran stabil konstan & minim turbulensi tepi.'),
          'ufo': ('80° Ultra-Wide Shallow', 'Bed tipis merata; rasa manis eksplosif tanpa stall.'),
          'orea': ('Zero-Bypass Negotiatable', 'Ekstraksi tinggi merata (flat bottom) + sweet clarity.'),
          'april': ('Flat Bottom Raised Ribs', 'Menjaga aerasi bawah tanpa chokepoint.'),
        };
        final info = specs[dripper] ?? specs['v60']!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: options
                  .map(
                    (id) => ChoiceChip(
                      label: Text(id.toUpperCase()),
                      selected: dripper == id,
                      onSelected: (_) => setState(() => _strs['dripper_id'] = id),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 6),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pre-heat Dripper dengan Air Panas',
                  style: TextStyle(color: Colors.white, fontSize: 12.5)),
              value: preheated,
              onChanged: (v) => setState(() => _bools['preheated'] = v),
            ),
            _verdictBox(
              '${info.$1}: ${info.$2} ${preheated ? "(Slurry +2.5°C lebih stabil)" : "(Hati-hati penurunan suhu slurry!)"}',
              preheated,
            ),
          ],
        );

      case 'FILTER_MICROSTRUCTURE_LAB':
        final code = _str('filter_code', 'T-90');
        const map = {
          'T-92': ('Light Roast / Lambat', '+25 dtk', 'Body tebal, manis tinggi'),
          'T-90': ('Medium-Dark / Cepat', '±0 dtk (Baseline)', 'Seimbang & bersih'),
          'T-83': ('Dark Roast / Ultra Cepat', '-12 dtk', 'Cegah pahit & sepat'),
          'Sibarist': ('FAST Paper Abaca+Pine', '-22 dtk', 'Sangat jernih, aman di gilingan halus'),
        };
        final entry = map[code] ?? map['T-90']!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: map.keys
                  .map(
                    (k) => ChoiceChip(
                      label: Text(k),
                      selected: code == k,
                      onSelected: (_) => setState(() => _strs['filter_code'] = k),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            _telemetryRow([
              ('Karakter Kertas', entry.$1),
              ('Delta Waktu', entry.$2),
              ('Sensory', entry.$3),
            ]),
          ],
        );

      case 'KASUYA_46_EQUALIZER':
        final p1 = _num('pour1_g', 50.0);
        final p2 = _num('pour2_g', 70.0);
        final splits = _num('strength_splits', 3.0).round();
        final sweetnessTilt = p1 < 55
            ? 'Manis Dominan (Tuang 1 < Tuang 2)'
            : (p1 > 65 ? 'Asam Cerah Dominan' : 'Seimbang Manis–Asam');
        final bodyDesc = splits >= 4
            ? 'Kekuatan Body Tinggi ($splits tuangan akhir)'
            : (splits <= 2
                ? 'Body Ringan & Cepat ($splits tuangan akhir)'
                : 'Body Sedang Ideal ($splits tuangan akhir)');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slider('Tuangan 1 / 0:00 (g)', 'pour1_g', p1, 35, 85, 'g'),
            _slider('Tuangan 2 / 0:45 (g)', 'pour2_g', p2, 40, 90, 'g'),
            _slider('Jumlah Splits 60% Akhir', 'strength_splits', splits.toDouble(), 2, 4, 'x',
                divisions: 2),
            _telemetryRow([
              ('40% Profil Rasa', sweetnessTilt),
              ('60% Profil Body', bodyDesc),
            ]),
          ],
        );

      case 'HYBRID_SWITCH_DEVIL_LAB':
        final open = _flag('valve_open', true);
        final tHot = _num('kettle_temp_c', 93.0);
        final tDrop = _num('drop_target_c', 70.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                open
                    ? 'Posisi Katup Switch: TERBUKA (Fase Perkolasi 93°C)'
                    : 'Posisi Katup Switch: TERTUTUP (Fase Imersi 70°C)',
                style: const TextStyle(color: Colors.white, fontSize: 12.5),
              ),
              value: open,
              onChanged: (v) => setState(() => _bools['valve_open'] = v),
            ),
            _slider('Suhu Perkolasi Awal (C)', 'kettle_temp_c', tHot, 88, 96, 'C'),
            _slider('Thermal Drop Imersi (C)', 'drop_target_c', tDrop, 65, 80, 'C'),
            _verdictBox(
              open
                  ? 'Air mengalir bebas mengekstrak buah & gula cerah.'
                  : 'Suhu drop ke ${tDrop.toStringAsFixed(0)}°C menahan tanin pahit saat perendaman.',
              true,
            ),
          ],
        );

      case 'FLASH_BREW_THERMAL_LAB':
      case 'ICED_HOFFMANN_HEDRICK_LAB':
        final totalMl = _num('total_ml', 500.0);
        final hotPct = _num('hot_pct', 60.0);
        final hotMl = totalMl * (hotPct / 100.0);
        final iceG = totalMl - hotMl;
        final finalTemp = ((hotMl * 68.0 - iceG * 80.0) / totalMl).clamp(2.0, 28.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slider('Total Sajian (ml)', 'total_ml', totalMl, 250, 600, 'ml'),
            _slider('Persen Air Seduh Panas (%)', 'hot_pct', hotPct, 50, 75, '%'),
            _telemetryRow([
              ('Air Panas', '${hotMl.toStringAsFixed(0)} ml'),
              ('Es Server', '${iceG.toStringAsFixed(0)} g'),
              ('Suhu Akhir', '${finalTemp.toStringAsFixed(1)}°C'),
            ]),
            const SizedBox(height: 8),
            _verdictBox(
              finalTemp <= 12.0
                  ? 'Kesetimbangan kalor tepat: dingin menyegarkan tanpa encer.'
                  : 'Tambah sedikit rasio es agar semua es cukup menyerap panas.',
              finalTemp <= 12.0,
            ),
          ],
        );

      case 'COOLING_CURVE_SENSORY_LAB':
        final temp = _num('temp_c', 52.0);
        final zone = temp >= 68
            ? '70–75°C: Puncak Aroma Volatil (Hati-hati lidah tersengat)'
            : (temp >= 56
                ? '56–67°C: Kecerahan Acidity & Kompleksitas Floral Terbuka'
                : (temp >= 48
                    ? '48–55°C: Sweet Spot Persepsi Lidah Manusia!'
                    : '< 48°C: Acidity meningkat & body terasa lebih tipis'));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _slider('Suhu Cangkir Saat Dicicipi (C)', 'temp_c', temp, 42, 75, 'C'),
            _verdictBox(zone, temp >= 48 && temp <= 62),
          ],
        );

      default:
        // Tangkap seluruh lab sisanya secara terparameterisasi dari `simulationConfig['defaults']`
        return _buildGenericConfigLab();
    }
  }

  Widget _buildGenericConfigLab() {
    final entries = _nums.entries.toList();
    final boolEntries = _bools.entries.toList();
    final strEntries = _strs.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...strEntries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${e.key.toUpperCase()}: ${e.value}',
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        ...entries.map((e) {
          final maxVal = e.value > 150
              ? e.value * 1.5
              : (e.value > 40 ? 100.0 : (e.value <= 2 ? 2.0 : e.value * 2.0));
          return _slider(
            e.key.replaceAll('_', ' ').toUpperCase(),
            e.key,
            e.value,
            0.0,
            maxVal,
            '',
          );
        }),
        ...boolEntries.map(
          (e) => SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              e.key.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            value: e.value,
            onChanged: (v) => setState(() => _bools[e.key] = v),
          ),
        ),
        _verdictBox(
          'Simulasi aktif — ubah parameter untuk mengamati efek ekstraksi & laju seduh.',
          true,
        ),
      ],
    );
  }

  Widget _slider(
    String label,
    String key,
    double val,
    double min,
    double max,
    String unit, {
    int? divisions,
  }) {
    final safeVal = val.clamp(min, max);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${safeVal.toStringAsFixed(safeVal < 10 ? 1 : 0)}$unit',
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: safeVal,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppTheme.accentGold,
            inactiveColor: Colors.white24,
            onChanged: (v) => setState(() => _nums[key] = v),
          ),
        ],
      ),
    );
  }

  Widget _telemetryRow(List<(String, String)> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _verdictBox(String msg, bool good) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: good
            ? const Color(0xFF1B5E20).withValues(alpha: 0.35)
            : const Color(0xFFBF360C).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: good ? const Color(0xFF66BB6A) : const Color(0xFFFF8A65),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            good ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
            size: 16,
            color: good ? const Color(0xFFA5D6A7) : const Color(0xFFFFCCBC),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.white, fontSize: 11.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
