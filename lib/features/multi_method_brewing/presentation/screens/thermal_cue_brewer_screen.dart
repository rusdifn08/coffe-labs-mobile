import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../screens/brew_timer_screen.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/brew_archetype.dart';

/// Layar Panduan Isyarat Termal & Tekanan Uap untuk Moka Pot, Turkish Cezve Ibrik, & Syphon.
class ThermalCueBrewerScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final ThermalCueSubMethod subMethod;

  const ThermalCueBrewerScreen({
    super.key,
    required this.recipe,
    required this.subMethod,
  });

  @override
  State<ThermalCueBrewerScreen> createState() => _ThermalCueBrewerScreenState();
}

class _ThermalCueBrewerScreenState extends State<ThermalCueBrewerScreen> {
  int _phaseIdx = 0;
  int _elapsedSec = 0;
  Timer? _timer;
  bool _running = false;

  List<(String, String)> get _cues => switch (widget.subMethod) {
        ThermalCueSubMethod.mokaPot => const [
            (
              '1. Pre-Boil Air Ketel (Kurangi Rasa Logam)',
              'Isi ruang bawah dengan air panas ±80°C tepat di bawah katup pengaman kuningan.'
            ),
            (
              '2. Api Kecil — Tunggu Aliran Emas Pertama',
              'Biarkan tutup atas terbuka untuk memantau. Begitu cairan madu mengalir mulus, kecilkan api.'
            ),
            (
              '3. Isyarat Kritis: Matikan Api Sebelum Sputtering',
              'Saat warna memucat kuning & terdengar bunyi desis, langsung angkat & dinginkan dasar pot di handuk basah!'
            ),
          ],
        ThermalCueSubMethod.turkishCezve => const [
            (
              '1. Aduk Sekali Sebelum Api Menyala',
              'Campur bubuk gilingan ekstra halus + air, aduk satu kali hingga larut lalu jangan diaduk lagi.'
            ),
            (
              '2. Api Lilin Konstan — Bangun Kerak Köpük',
              'Pantau pinggiran cezve saat partikel terangkat perlahan tanpa mendidih.'
            ),
            (
              '3. Busa Naik Pertama — Angkat Seketika!',
              'JANGAN BIARKAN MENDIDIH! Angkat cezve begitu mahkota busa emas mencapai bibir leher pot.'
            ),
          ],
        ThermalCueSubMethod.syphonVacuum => const [
            (
              '1. Panaskan Labu Bawah & Naikkan Air',
              'Rapatkan corong kaca atas hingga seluruh air naik membentuk kestabilan vakum.'
            ),
            (
              '2. Imersi & Cross-Paddle Stir (40–60s)',
              'Masukkan kopi, aduk merata dengan spatula bambu pada suhu 91–94°C.'
            ),
            (
              '3. Matikan Pemanas -> Vacuum Drawdown!',
              'Matikan kompor/halogen, lap dasar labu dengan kain lembap dingin agar tarikan vakum tuntas membentuk gundukan dome.'
            ),
          ],
      };

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleStopwatch() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsedSec++);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.recipe['title']?.toString() ?? 'Thermal Brewer';
    final mm = (_elapsedSec ~/ 60).toString().padLeft(2, '0');
    final ss = (_elapsedSec % 60).toString().padLeft(2, '0');
    final cues = _cues;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text(
          'Thermal-Cue Precision Brewer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$mm:$ss',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBrown,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _toggleStopwatch,
                          icon: Icon(
                            _running
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(_running ? 'Jeda' : 'Stopwatch Pengaman'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            _timer?.cancel();
                            setState(() {
                              _running = false;
                              _elapsedSec = 0;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tandai Isyarat Fisik Secara Langsung',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(cues.length, (i) {
                final (head, desc) = cues[i];
                final active = _phaseIdx == i;
                final done = i < _phaseIdx;
                return InkWell(
                  onTap: () => setState(() => _phaseIdx = i),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFFFF7ED)
                          : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active
                            ? const Color(0xFFEA580C)
                            : (done ? Colors.green : AppTheme.borderWarm),
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          head,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: active
                                ? const Color(0xFF9A3412)
                                : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BrewTimerScreen(recipeData: widget.recipe),
                      ),
                    );
                  },
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Buka Mode Timer Berurutan Lengkap'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
