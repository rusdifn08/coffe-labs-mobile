import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/grinder_spec.dart';
import '../services/grinder_conversion_engine.dart';
import 'brand_model_selector_card.dart';

/// Tab Mode 1: Konverter Grinder-ke-Grinder Presisi (Asal -> Tujuan)
/// dengan pemilih Merek -> Model, terjemahan Klik <-> Angka Dial Fisik (Putaran.Angka.Klik),
/// dan panduan Zero Point anti-halusinasi.
class GrinderToGrinderTab extends StatefulWidget {
  final double initialMicrons;
  final ValueChanged<double>? onMicronsChanged;

  const GrinderToGrinderTab({
    super.key,
    required this.initialMicrons,
    this.onMicronsChanged,
  });

  @override
  State<GrinderToGrinderTab> createState() => _GrinderToGrinderTabState();
}

class _GrinderToGrinderTabState extends State<GrinderToGrinderTab> {
  late GrinderSpec _sourceGrinder;
  late GrinderSpec _targetGrinder;
  late double _sourceSetting;

  @override
  void initState() {
    super.initState();
    _sourceGrinder = GrinderConversionEngine.findById('timemore_c3') ??
        GrinderConversionEngine.allGrinders.first;
    _targetGrinder = GrinderConversionEngine.findById('kingrinder_k6') ??
        GrinderConversionEngine.allGrinders[1];
    _sourceSetting = GrinderConversionEngine.micronsToSetting(
          _sourceGrinder,
          widget.initialMicrons,
        ) ??
        15.0;
  }

  double _stepIncrement(GrinderSpec spec) {
    if (spec.dialType == DialSystemType.fellowSubStep && spec.clicksPerNumber > 0) {
      return 1.0 / spec.clicksPerNumber;
    }
    if (spec.valueDecimals == 0) return 1.0;
    if ((spec.maxSetting - spec.minSetting) <= 20) return 0.5;
    return 1.0;
  }

  void _updateSourceSetting(double rawVal) {
    final snapped = GrinderConversionEngine.snapSetting(_sourceGrinder, rawVal);
    setState(() => _sourceSetting = snapped);
    final microns = GrinderConversionEngine.settingToMicrons(_sourceGrinder, snapped);
    widget.onMicronsChanged?.call(microns);
  }

  void _selectSourceGrinder(GrinderSpec newSource) {
    final currentMicrons = _sourceGrinder.isCalibrated
        ? GrinderConversionEngine.settingToMicrons(_sourceGrinder, _sourceSetting)
        : widget.initialMicrons;
    setState(() {
      _sourceGrinder = newSource;
      _sourceSetting = GrinderConversionEngine.micronsToSetting(newSource, currentMicrons) ??
          newSource.minSetting;
    });
  }

  void _selectTargetGrinder(GrinderSpec newTarget) {
    setState(() => _targetGrinder = newTarget);
  }

  void _swapGrinders(GrinderConversionResult current) {
    final nextSource = _targetGrinder;
    final nextTarget = _sourceGrinder;
    final nextSetting = current.targetReading?.rawValue ??
        GrinderConversionEngine.micronsToSetting(nextSource, current.estimatedMicrons) ??
        nextSource.minSetting;
    setState(() {
      _sourceGrinder = nextSource;
      _targetGrinder = nextTarget;
      _sourceSetting = GrinderConversionEngine.snapSetting(nextSource, nextSetting);
    });
  }

  void _snapSourceToMicrons(double targetMicrons) {
    if (!_sourceGrinder.isCalibrated) return;
    final setting = GrinderConversionEngine.micronsToSetting(_sourceGrinder, targetMicrons);
    if (setting != null) {
      _updateSourceSetting(setting);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = GrinderConversionEngine.convert(
      source: _sourceGrinder,
      sourceSetting: _sourceSetting,
      target: _targetGrinder,
    );

    final inc = _stepIncrement(_sourceGrinder);
    final range = (_sourceGrinder.maxSetting - _sourceGrinder.minSetting).clamp(1.0, 1000.0);
    final divisions = _sourceGrinder.valueDecimals == 0
        ? range.round().clamp(1, 500)
        : (range / inc).round().clamp(10, 400);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        // 1. KARTU GRINDER ASAL
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'GRINDER ASAL',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CalibrationChip(tier: _sourceGrinder.calibrationTier),
                ],
              ),
              const SizedBox(height: 10),
              BrandModelSelectorCard(
                roleLabel: 'Grinder Asal',
                accentColor: AppTheme.primaryBrown,
                selectedGrinder: _sourceGrinder,
                onGrinderSelected: _selectSourceGrinder,
              ),
              const SizedBox(height: 12),
              if (_sourceGrinder.isCalibrated) ...[
                // Live Dial Readout + Stepper (- / +)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBrown.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.16)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _StepCircleButton(
                            icon: CupertinoIcons.minus,
                            onTap: () => _updateSourceSetting(_sourceSetting - inc),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  result.sourceReading.primaryDisplay,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    'Posisi Dial: ${result.sourceReading.physicalNotation}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBrown,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StepCircleButton(
                            icon: CupertinoIcons.plus,
                            onTap: () => _updateSourceSetting(_sourceSetting + inc),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.primaryBrown,
                          inactiveTrackColor: AppTheme.primaryBrown.withValues(alpha: 0.18),
                          thumbColor: AppTheme.primaryBrown,
                        ),
                        child: Slider(
                          value: _sourceSetting.clamp(
                            _sourceGrinder.minSetting,
                            _sourceGrinder.maxSetting,
                          ),
                          min: _sourceGrinder.minSetting,
                          max: _sourceGrinder.maxSetting,
                          divisions: divisions,
                          onChanged: _updateSourceSetting,
                        ),
                      ),
                      Text(
                        result.sourceReading.humanInstruction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textDark,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Quick brew-method snap pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _MethodSnapPill('Espresso', BrewMicronAnchors.espresso, result.estimatedMicrons, _snapSourceToMicrons),
                      const SizedBox(width: 6),
                      _MethodSnapPill('Moka Pot', BrewMicronAnchors.mokaPot, result.estimatedMicrons, _snapSourceToMicrons),
                      const SizedBox(width: 6),
                      _MethodSnapPill('AeroPress', BrewMicronAnchors.aeroPress, result.estimatedMicrons, _snapSourceToMicrons),
                      const SizedBox(width: 6),
                      _MethodSnapPill('V60', BrewMicronAnchors.v60, result.estimatedMicrons, _snapSourceToMicrons),
                      const SizedBox(width: 6),
                      _MethodSnapPill('French Press', BrewMicronAnchors.frenchPress, result.estimatedMicrons, _snapSourceToMicrons),
                      const SizedBox(width: 6),
                      _MethodSnapPill('Cold Brew', BrewMicronAnchors.coldBrew, result.estimatedMicrons, _snapSourceToMicrons),
                    ],
                  ),
                ),
              ] else ...[
                _WarningBanner(text: result.sourceReading.humanInstruction),
              ],
            ],
          ),
        ),

        // 2. JEMBATAN MIKRON & TOMBOL TUKAR
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00695C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF00695C).withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.circle_grid_hex_fill, size: 18, color: Color(0xFF00695C)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Partikel: ~${result.estimatedMicrons.round()} µm · ${result.brewZoneLabel}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00695C),
                              ),
                            ),
                            Text(
                              'Tekstur: ${GrinderConversionEngine.textureForMicrons(result.estimatedMicrons)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppTheme.primaryBrown,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _swapGrinders(result),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.arrow_up_arrow_down, color: Colors.white, size: 17),
                        SizedBox(height: 2),
                        Text(
                          'Tukar',
                          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. KARTU GRINDER TUJUAN & HASIL KONVERSI PRESISI
        _SectionCard(
          borderColor: const Color(0xFF15803D).withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF15803D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'GRINDER TUJUAN',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CalibrationChip(tier: _targetGrinder.calibrationTier),
                ],
              ),
              const SizedBox(height: 10),
              BrandModelSelectorCard(
                roleLabel: 'Grinder Tujuan',
                accentColor: const Color(0xFF15803D),
                selectedGrinder: _targetGrinder,
                onGrinderSelected: _selectTargetGrinder,
              ),
              const SizedBox(height: 14),

              // HERO RESULT BOX
              if (result.targetReading != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _targetGrinder.isCalibrated
                          ? const [Color(0xFF14532D), Color(0xFF15803D)]
                          : const [Color(0xFF475569), Color(0xFF64748B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SETELAN REKOMENDASI PRESISI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        result.targetReading!.primaryDisplay,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Posisi Dial Fisik: ${result.targetReading!.physicalNotation}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result.targetReading!.humanInstruction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (result.targetReading!.warning != null) ...[
                  const SizedBox(height: 10),
                  _WarningBanner(text: result.targetReading!.warning!),
                ],
              ],

              if (result.notice != null) ...[
                const SizedBox(height: 10),
                _WarningBanner(text: result.notice!, isInfo: true),
              ],

              const SizedBox(height: 12),
              // Detail Zero-Point & Catatan Pabrikan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(CupertinoIcons.info_circle_fill, size: 14, color: AppTheme.primaryBrown),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Catatan Kalibrasi & Zero Point',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _targetGrinder.calibrationNote,
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textDark, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _SectionCard({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ?? AppTheme.primaryBrown.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StepCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: CircleBorder(
        side: BorderSide(color: AppTheme.primaryBrown.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, color: AppTheme.primaryBrown),
        ),
      ),
    );
  }
}

class _MethodSnapPill extends StatelessWidget {
  final String label;
  final double microns;
  final double currentMicrons;
  final ValueChanged<double> onSelect;

  const _MethodSnapPill(this.label, this.microns, this.currentMicrons, this.onSelect);

  @override
  Widget build(BuildContext context) {
    final active = (currentMicrons - microns).abs() < 45;
    return GestureDetector(
      onTap: () => onSelect(microns),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBrown : AppTheme.bgCream,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: active ? AppTheme.primaryBrown : AppTheme.primaryBrown.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.w600,
            color: active ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}

class _CalibrationChip extends StatelessWidget {
  final CalibrationTier tier;

  const _CalibrationChip({required this.tier});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (tier) {
      CalibrationTier.fullMultiAnchor => ('Multi-Jangkar', const Color(0xFF15803D)),
      CalibrationTier.partialAnchor => ('Kalibrasi Parsial', const Color(0xFFB45309)),
      CalibrationTier.specOnly => ('Spec-Only', const Color(0xFF64748B)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String text;
  final bool isInfo;

  const _WarningBanner({required this.text, this.isInfo = false});

  @override
  Widget build(BuildContext context) {
    final bg = isInfo ? const Color(0xFFEFF6FF) : Colors.amber.shade50;
    final border = isInfo ? const Color(0xFFBFDBFE) : Colors.amber.shade300;
    final fg = isInfo ? const Color(0xFF1E3A8A) : Colors.brown.shade900;
    final icon = isInfo ? CupertinoIcons.lightbulb_fill : CupertinoIcons.exclamationmark_triangle_fill;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11.5, color: fg, height: 1.35, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
