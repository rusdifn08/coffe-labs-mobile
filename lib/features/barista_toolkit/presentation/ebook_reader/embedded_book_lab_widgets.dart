import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import 'coffee_dictionary_az_screen.dart';

/// Mini-simulator interaktif yang dirender langsung di antara paragraf E-Book AST.
class EmbeddedBookLabWidget extends StatefulWidget {
  final String widgetKind;
  final String title;
  final Color textColor;
  final Color cardBgColor;

  const EmbeddedBookLabWidget({
    super.key,
    required this.widgetKind,
    required this.title,
    required this.textColor,
    required this.cardBgColor,
  });

  @override
  State<EmbeddedBookLabWidget> createState() => _EmbeddedBookLabWidgetState();
}

class _EmbeddedBookLabWidgetState extends State<EmbeddedBookLabWidget> {
  double _p1 = 620.0;
  double _p2 = 93.0;
  double _p3 = 35.0;

  @override
  void initState() {
    super.initState();
    switch (widget.widgetKind) {
      case 'WATER_ION_SIMULATOR':
        _p1 = 25.0; // Ca ppm
        _p2 = 35.0; // Mg ppm
        _p3 = 35.0; // KH ppm
      case 'BREWER_RATIO_SLIDER':
        _p1 = 15.0; // Dose g
        _p2 = 250.0; // Water ml
      case 'SCA_CUPPING_FORM_CALCULATOR':
        _p1 = 8.5; // Average attribute score (x10 = 85)
        _p2 = 0.0; // Defects
      default:
        _p1 = 620.0; // Grind um
        _p2 = 93.0; // Temp C
        _p3 = 3.5; // Slurry height cm
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_rounded, color: AppTheme.accentGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title.isNotEmpty ? widget.title : widget.widgetKind,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: widget.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildLabControls(context),
        ],
      ),
    );
  }

  Widget _buildLabControls(BuildContext context) {
    if (widget.widgetKind == 'WATER_ION_SIMULATOR') {
      final gh = 2.497 * _p1 + 4.118 * _p2;
      final balance = _p3 < 20
          ? 'Tajam / Sour'
          : (_p3 > 70 ? 'Flat & Dull' : 'Sweet & Crisp SCA Sweet Spot');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GH Total: ${gh.toStringAsFixed(0)} ppm CaCO₃ • KH: ${_p3.toInt()} ppm → $balance',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentGold),
          ),
          _sliderRow('Ca²⁺ Creamy', _p1, 0, 60, (v) => setState(() => _p1 = v)),
          _sliderRow('Mg²⁺ Fruity', _p2, 0, 60, (v) => setState(() => _p2 = v)),
          _sliderRow('KH Buffer', _p3, 5, 110, (v) => setState(() => _p3 = v)),
        ],
      );
    }

    if (widget.widgetKind == 'BREWER_RATIO_SLIDER') {
      final ratio = (_p2 / (_p1 <= 0 ? 15 : _p1));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rasio Seduh 1:${ratio.toStringAsFixed(2)} (${(_p1 / (_p2 / 1000)).toStringAsFixed(0)} g/L) • Bloom ${(2.5 * _p1).toInt()}–${(3.0 * _p1).toInt()} mL',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentGold),
          ),
          _sliderRow('Dosis (g)', _p1, 10, 35, (v) => setState(() => _p1 = v)),
          _sliderRow('Air (mL)', _p2, 150, 600, (v) => setState(() => _p2 = v)),
        ],
      );
    }

    if (widget.widgetKind == 'SCA_CUPPING_FORM_CALCULATOR') {
      final total = (_p1 * 10 - _p2 * 2).clamp(0, 100);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skor SCA: ${total.toStringAsFixed(2)} (${total >= 80 ? "Specialty Grade" : "Below Specialty"})',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentGold),
          ),
          _sliderRow('Rata-rata Atribut', _p1, 6.0, 9.5, (v) => setState(() => _p1 = v)),
          _sliderRow('Cacat Taint', _p2, 0, 4, (v) => setState(() => _p2 = v)),
        ],
      );
    }

    if (widget.widgetKind == 'INTERACTIVE_A_Z_DICTIONARY') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBrown,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CoffeeDictionaryAzScreen()),
          ),
          icon: const Icon(Icons.menu_book_rounded, size: 18),
          label: const Text('Buka Kamus Istilah Kopi Lengkap A–Z'),
        ),
      );
    }

    // Default interactive simulator: Darcy Flow & Permeability Explorer
    final viscFactor = 1.0 + (_p2 - 75.0) * 0.015;
    final flowEst = ((_p1 / 620.0) * (_p3 / 3.5) * viscFactor * 4.5).clamp(1.2, 12.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimasi Laju Perkolasi Darcy Q: ${flowEst.toStringAsFixed(1)} ml/s (drawdown ~${(250 / flowEst + 45).round()} dtk)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentGold),
        ),
        _sliderRow('Gilingan µm', _p1, 400, 1300, (v) => setState(() => _p1 = v)),
        _sliderRow('Suhu °C', _p2, 70, 100, (v) => setState(() => _p2 = v)),
      ],
    );
  }

  Widget _sliderRow(
    String label,
    double val,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            '$label (${val.toStringAsFixed(val < 15 ? 1 : 0)})',
            style: TextStyle(fontSize: 11, color: widget.textColor.withValues(alpha: 0.85)),
          ),
        ),
        Expanded(
          child: Slider(
            value: val.clamp(min, max),
            min: min,
            max: max,
            activeColor: AppTheme.accentGold,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
