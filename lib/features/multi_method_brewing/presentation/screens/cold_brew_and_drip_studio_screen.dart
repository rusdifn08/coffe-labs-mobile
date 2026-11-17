import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/arrhenius_coldbrew_calculator.dart';
import '../controllers/cold_brew_alarm_hub_controller.dart';
import '../widgets/cold_brew_alarm_ringing_modal.dart';

/// Layar Khusus Cold Brew & Kyoto Slow Drip:
/// TIDAK memakai timer seduh langsung. Menampilkan Step-by-Step Persiapan,
/// Kalkulator Kinetika Arrhenius / Metronom Kyoto, & Jadwal Alarm OS Latar Belakang.
class ColdBrewAndDripStudioScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> recipe;

  const ColdBrewAndDripStudioScreen({super.key, required this.recipe});

  @override
  ConsumerState<ColdBrewAndDripStudioScreen> createState() =>
      _ColdBrewAndDripStudioScreenState();
}

class _ColdBrewAndDripStudioScreenState
    extends ConsumerState<ColdBrewAndDripStudioScreen> {
  late ColdBrewMode _mode;
  late double _hours;
  int _dripBpm = 40;
  bool _metronomePulseOn = false;
  Timer? _metronomeTimer;
  final Set<int> _checkedSteps = {};

  double get _doseG =>
      (widget.recipe['coffeeWeightGrams'] as num?)?.toDouble() ?? 50.0;
  double get _waterMl =>
      (widget.recipe['totalWaterWeightGrams'] as num?)?.toDouble() ?? 500.0;

  List<Map<String, dynamic>> get _steps {
    final raw = widget.recipe['steps'] as List? ?? [];
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    final joined =
        '${widget.recipe['title'] ?? ''} ${widget.recipe['category'] ?? ''}'
            .toLowerCase();
    final tempC = (widget.recipe['waterTempCelsius'] as num?)?.toDouble() ?? 4.0;
    final seededSec =
        (widget.recipe['totalTimeSeconds'] as num?)?.toInt() ?? 43200;

    if (joined.contains('kyoto') || joined.contains('drip')) {
      _mode = ColdBrewMode.kyotoDrip;
      final d = ArrheniusColdBrewCalculator.calculateKyotoDripDuration(
        waterMl: _waterMl,
        dripRateBpm: _dripBpm,
      );
      _hours = seededSec >= 14400
          ? (seededSec / 3600).clamp(6.0, 24.0)
          : (d.inSeconds / 3600).clamp(6.0, 24.0);
    } else if (tempC >= 16) {
      _mode = ColdBrewMode.immersionRoom;
      _hours = seededSec >= 21600
          ? (seededSec / 3600).clamp(8.0, 24.0)
          : 12.0;
    } else {
      _mode = ColdBrewMode.immersionFridge;
      _hours = seededSec >= 21600
          ? (seededSec / 3600).clamp(8.0, 24.0)
          : 16.0;
    }

    if (!_isTestEnv && _mode == ColdBrewMode.kyotoDrip) {
      _restartMetronome();
    }
  }

  @override
  void dispose() {
    _metronomeTimer?.cancel();
    super.dispose();
  }

  void _restartMetronome() {
    _metronomeTimer?.cancel();
    if (_isTestEnv || _mode != ColdBrewMode.kyotoDrip) return;
    final ms = ArrheniusColdBrewCalculator.dripIntervalMs(_dripBpm);
    _metronomeTimer = Timer.periodic(Duration(milliseconds: ms ~/ 2), (_) {
      if (mounted) setState(() => _metronomePulseOn = !_metronomePulseOn);
    });
  }

  void _selectMode(ColdBrewMode mode) {
    setState(() {
      _mode = mode;
      if (mode == ColdBrewMode.immersionFridge) {
        _hours = ArrheniusColdBrewCalculator.calculateImmersionDuration(
                  tempCelsius: 4.0,
                ).inMinutes /
            60.0;
      } else if (mode == ColdBrewMode.immersionRoom) {
        _hours = ArrheniusColdBrewCalculator.calculateImmersionDuration(
                  tempCelsius: 22.0,
                ).inMinutes /
            60.0;
      } else {
        _hours = ArrheniusColdBrewCalculator.calculateKyotoDripDuration(
                  waterMl: _waterMl,
                  dripRateBpm: _dripBpm,
                ).inMinutes /
            60.0;
      }
      _hours = (_hours * 2).round() / 2.0;
    });
    if (mode == ColdBrewMode.kyotoDrip) {
      _restartMetronome();
    } else {
      _metronomeTimer?.cancel();
    }
  }

  Future<void> _scheduleAlarm() async {
    final duration = Duration(minutes: (_hours * 60).round());
    final modeStr = switch (_mode) {
      ColdBrewMode.immersionFridge => 'IMMERSION_FRIDGE',
      ColdBrewMode.immersionRoom => 'IMMERSION_ROOM',
      ColdBrewMode.kyotoDrip => 'KYOTO_DRIP',
    };
    final tempC = switch (_mode) {
      ColdBrewMode.immersionFridge => 4.0,
      ColdBrewMode.immersionRoom => 22.0,
      ColdBrewMode.kyotoDrip => 18.0,
    };

    final batch = await ref.read(coldBrewAlarmHubProvider.notifier).scheduleBatch(
          recipeId: (widget.recipe['id'] as num?)?.toInt(),
          recipeTitle: widget.recipe['title']?.toString() ?? 'Cold Brew',
          methodSlug: _mode == ColdBrewMode.kyotoDrip ? 'kyoto_drip' : 'cold_brew',
          brewMode: modeStr,
          coffeeDoseG: _doseG,
          waterMl: _waterMl,
          ambientTempC: tempC,
          dripRateBpm: _mode == ColdBrewMode.kyotoDrip ? _dripBpm : null,
          duration: duration,
          recipeSnapshot: widget.recipe,
        );

    if (!mounted) return;
    final finish = batch.targetFinishAt;
    final hh = finish.hour.toString().padLeft(2, '0');
    final mm = finish.minute.toString().padLeft(2, '0');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alarm OS dijadwalkan untuk selesai pukul $hh:$mm (${_hours.toStringAsFixed(1)} jam).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.recipe['title']?.toString() ?? 'Cold Brew & Drip';
    final dilution = ArrheniusColdBrewCalculator.calculateDilution(
      coffeeDoseG: _doseG,
      waterMl: _waterMl,
    );
    final activeBatches = ref.watch(coldBrewAlarmHubProvider);
    final finishPreview =
        DateTime.now().add(Duration(minutes: (_hours * 60).round()));
    final fHh = finishPreview.hour.toString().padLeft(2, '0');
    final fMm = finishPreview.minute.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text(
          'Cold Brew Studio & Alarm',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFEFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'MODE STEP-BY-STEP + ALARM OS (TANPA LIVE TIMER)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0E7490),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_doseG.toStringAsFixed(0)}g kopi · ${_waterMl.toStringAsFixed(0)}ml air (${dilution.brewRatioLabel})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Active alarm card if already running
              if (activeBatches.isNotEmpty) ...[
                InkWell(
                  onTap: () =>
                      ColdBrewAlarmRingingModal.show(context, activeBatches.first),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFEFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF0891B2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.alarm_on_rounded,
                          color: Color(0xFF0E7490),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Alarm aktif: ${activeBatches.first.recipeTitle} (${ArrheniusColdBrewCalculator.formatHHMMSS(activeBatches.first.remainingAt(DateTime.now()))})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0E7490),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF0E7490),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Step-by-Step Preparation Checklist
              const Text(
                'Panduan Persiapan Step-by-Step',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(_steps.length, (i) {
                final step = _steps[i];
                final checked = _checkedSteps.contains(i);
                final sTitle = step['title']?.toString() ?? 'Langkah ${i + 1}';
                final sInst = step['instruction']?.toString() ?? '';
                final water = (step['waterAddedGrams'] as num?)?.toInt() ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: AppTheme.surfaceWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: checked
                            ? const Color(0xFF0891B2)
                            : AppTheme.borderWarm,
                      ),
                    ),
                    child: CheckboxListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      value: checked,
                    activeColor: const Color(0xFF0891B2),
                    onChanged: (_) => setState(() {
                      if (checked) {
                        _checkedSteps.remove(i);
                      } else {
                        _checkedSteps.add(i);
                      }
                    }),
                    title: Text(
                      water > 0 ? '${i + 1}. $sTitle (+${water}ml)' : '${i + 1}. $sTitle',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        decoration:
                            checked ? TextDecoration.lineThrough : null,
                        color: AppTheme.textDark,
                      ),
                    ),
                    subtitle: sInst.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              sInst,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          )
                        : null,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Arrhenius Temperature / Drip Mode Configurator
              const Text(
                'Suhu Simpan & Kalibrasi Alarm Latar Belakang',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Kulkas 4°C'),
                    selected: _mode == ColdBrewMode.immersionFridge,
                    onSelected: (_) => _selectMode(ColdBrewMode.immersionFridge),
                  ),
                  ChoiceChip(
                    label: const Text('Suhu Ruang 22°C'),
                    selected: _mode == ColdBrewMode.immersionRoom,
                    onSelected: (_) => _selectMode(ColdBrewMode.immersionRoom),
                  ),
                  ChoiceChip(
                    label: const Text('Kyoto Slow Drip'),
                    selected: _mode == ColdBrewMode.kyotoDrip,
                    onSelected: (_) => _selectMode(ColdBrewMode.kyotoDrip),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Durasi Alarm Ekstraksi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${_hours.toStringAsFixed(1)} Jam · ~$fHh:$fMm',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _hours.clamp(6.0, 24.0),
                      min: 6.0,
                      max: 24.0,
                      divisions: 36,
                      activeColor: AppTheme.primaryBrown,
                      onChanged: (v) => setState(() => _hours = v),
                    ),
                    if (_mode == ColdBrewMode.kyotoDrip) ...[
                      const Divider(),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _metronomePulseOn
                                  ? const Color(0xFF0891B2)
                                  : AppTheme.dividerColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Metronom Katup Kyoto: $_dripBpm Tetes/Menit (1 tetes tiap ${(ArrheniusColdBrewCalculator.dripIntervalMs(_dripBpm) / 1000).toStringAsFixed(2)} dtk)',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0E7490),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _dripBpm.toDouble(),
                        min: 20,
                        max: 70,
                        divisions: 50,
                        activeColor: const Color(0xFF0891B2),
                        onChanged: (v) {
                          setState(() => _dripBpm = v.round());
                          _restartMetronome();
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Dilution Calculator Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimasi Hasil & Pengenceran Siap Minum (1:15)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Konsentrat Bersih: ~${dilution.concentrateYieldMl.toStringAsFixed(0)} ml · Tambah Air/Susu: +${dilution.suggestedDilutionMl.toStringAsFixed(0)} ml (atau ${dilution.suggestedIceG.toStringAsFixed(0)}g es batu).',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Start Persistent OS Alarm CTA
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _scheduleAlarm,
                  icon: const Icon(Icons.alarm_add_rounded),
                  label: Text(
                    'Mulai & Pasang Alarm (${_hours.toStringAsFixed(1)} Jam)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E7490),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
