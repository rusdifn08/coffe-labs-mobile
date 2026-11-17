import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../screens/brew_timer_screen.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/brew_archetype.dart';
import '../controllers/cold_brew_alarm_hub_controller.dart';

/// Layar Arketipe Steep-and-Release / Perendaman:
/// Menangani AeroPress (Standard vs Inverted), Clever/Switch, French Press (9m Hoffmann + alarm sedimentasi), & Vietnam Phin.
class SteepAndReleaseImmersionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> recipe;
  final ImmersionSubMethod subMethod;

  const SteepAndReleaseImmersionScreen({
    super.key,
    required this.recipe,
    required this.subMethod,
  });

  @override
  ConsumerState<SteepAndReleaseImmersionScreen> createState() =>
      _SteepAndReleaseImmersionScreenState();
}

class _SteepAndReleaseImmersionScreenState
    extends ConsumerState<SteepAndReleaseImmersionScreen> {
  bool _invertedMode = false;

  @override
  void initState() {
    super.initState();
    final joined =
        '${widget.recipe['title'] ?? ''} ${widget.recipe['description'] ?? ''} ${widget.recipe['method'] ?? ''}'
            .toLowerCase();
    _invertedMode = joined.contains('inverted') || joined.contains('terbalik');
  }

  Future<void> _scheduleFrenchPressSettleAlarm() async {
    final doseG =
        (widget.recipe['coffeeWeightGrams'] as num?)?.toDouble() ?? 30.0;
    final waterMl =
        (widget.recipe['totalWaterWeightGrams'] as num?)?.toDouble() ?? 500.0;
    await ref.read(coldBrewAlarmHubProvider.notifier).scheduleBatch(
          recipeId: (widget.recipe['id'] as num?)?.toInt(),
          recipeTitle:
              '${widget.recipe['title'] ?? 'French Press'} (Sedimentasi 5m)',
          methodSlug: 'french_press',
          brewMode: 'IMMERSION_SETTLE_5M',
          coffeeDoseG: doseG,
          waterMl: waterMl,
          ambientTempC: 92.0,
          duration: const Duration(minutes: 5),
          recipeSnapshot: widget.recipe,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alarm pengendapan 5 menit French Press dijadwalkan!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.recipe['title']?.toString() ?? 'Immersion Brew';
    final dose = (widget.recipe['coffeeWeightGrams'] as num?)?.toDouble() ?? 15;
    final water =
        (widget.recipe['totalWaterWeightGrams'] as num?)?.toDouble() ?? 250;
    final skmGrams = (dose * 1.4).round();

    final String archetypeTitle = switch (widget.subMethod) {
      ImmersionSubMethod.aeropress => 'AeroPress Pressure Cockpit',
      ImmersionSubMethod.frenchPress => 'French Press Steep & Settle',
      ImmersionSubMethod.cleverSwitch => 'Clever / Switch Release Valve',
      ImmersionSubMethod.vietnamPhin => 'Vietnam Drip (Phin Tetes Lambat)',
      ImmersionSubMethod.cuppingBowl => 'SCA Cupping Protocol',
    };

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(
          archetypeTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      '${dose.toStringAsFixed(1)}g kopi · ${water.toStringAsFixed(0)}ml air panas',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    if (widget.subMethod == ImmersionSubMethod.aeropress) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Standar'),
                            selected: !_invertedMode,
                            onSelected: (_) =>
                                setState(() => _invertedMode = false),
                          ),
                          ChoiceChip(
                            label: const Text('Inverted (Terbalik)'),
                            selected: _invertedMode,
                            onSelected: (_) =>
                                setState(() => _invertedMode = true),
                          ),
                        ],
                      ),
                      if (_invertedMode)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: const Text(
                            'Peringatan Keamanan Inverted: Tekan plunger minimal 2 cm masuk silinder & kunci cap sebelum membalik ke server. Berhenti menekan saat mendengar desis udara.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                    ],
                    if (widget.subMethod == ImmersionSubMethod.cleverSwitch) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Tips Clever & Switch: Masukkan air panas lebih dahulu sebelum bubuk kopi (Water-First) untuk mencegah penyumbatan katup & mempercepat drawdown 2x lipat.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                    if (widget.subMethod == ImmersionSubMethod.vietnamPhin) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Panduan Cà Phê Sữa Đá: Tuang ±${skmGrams}g susu kental manis di dasar gelas. Targetkan laju tetesan Phin 1 tetes/detik selama 4–5 menit.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ],
                    if (widget.subMethod == ImmersionSubMethod.frenchPress) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _scheduleFrenchPressSettleAlarm,
                        icon: const Icon(Icons.alarm_rounded, size: 18),
                        label: const Text(
                          'Pasang Alarm Sedimentasi 5 Menit (Hoffmann)',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBrown,
                          side: const BorderSide(color: AppTheme.primaryBrown),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BrewTimerScreen(recipeData: widget.recipe),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Mulai Panduan Ekstraksi Terpandu',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
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
