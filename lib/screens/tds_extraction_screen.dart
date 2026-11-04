import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/tds/widgets/sca_chart_painter.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

/// SCA Brewing Control Chart, Extraction Yield (%) & LRR Retention Lab.
class TdsExtractionScreen extends StatefulWidget {
  const TdsExtractionScreen({super.key});

  @override
  State<TdsExtractionScreen> createState() => _TdsExtractionScreenState();
}

class _TdsExtractionScreenState extends State<TdsExtractionScreen> {
  double _coffeeDose = 15.0;
  double _beverageWeight = 225.0;
  double _tdsPercent = 1.30;
  double _lrrValue = 2.1; // Liquid Retained Ratio (g/g)

  double get _extractionYield {
    if (_coffeeDose <= 0) return 0.0;
    return (_beverageWeight * _tdsPercent) / _coffeeDose;
  }

  double get _brewRatio {
    if (_coffeeDose <= 0) return 0.0;
    return _beverageWeight / _coffeeDose;
  }

  double get _totalWaterEstimated {
    // Total air seduh = Beverage Yield + (Dose * LRR)
    return _beverageWeight + (_coffeeDose * _lrrValue);
  }

  String get _scaQuadrant {
    final ey = _extractionYield;
    final tds = _tdsPercent;

    final bool idealEy = ey >= 18.0 && ey <= 22.0;
    final bool idealTds = tds >= 1.15 && tds <= 1.45;

    if (idealEy && idealTds) {
      return 'Golden Cup Ideal (SCA Sweet Spot)';
    }
    if (ey < 18.0 && tds < 1.15) {
      return 'Under-developed & Weak (Kurang Sari & Encer)';
    }
    if (ey < 18.0 && tds > 1.45) {
      return 'Under-extracted & Strong (Pekat Asam Menusuk)';
    }
    if (ey > 22.0 && tds > 1.45) {
      return 'Over-extracted & Strong (Pahit Kasar & Pekat)';
    }
    if (ey > 22.0 && tds < 1.15) {
      return 'Over-extracted & Weak (Sepet Astringent Hambar)';
    }
    if (ey < 18.0) {
      return 'Under-extracted (Perlu Ekstraksi Lebih Tinggi)';
    }
    if (ey > 22.0) {
      return 'Over-extracted (Ekstraksi Berlebih)';
    }
    if (tds < 1.15) {
      return 'Weak (Cangkir Terlalu Encer)';
    }
    return 'Strong (Cangkir Terlalu Kuat / Pekat)';
  }

  Color get _quadrantColor {
    final ey = _extractionYield;
    final tds = _tdsPercent;
    if (ey >= 18.0 && ey <= 22.0 && tds >= 1.15 && tds <= 1.45) {
      return const Color(0xFF2E7D32);
    }
    if (ey < 18.0) return const Color(0xFFE65100);
    return const Color(0xFFC2185B);
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final ey = _extractionYield;
    final color = _quadrantColor;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? 'SCA Extraction Yield & TDS' : 'Kalkulator Ekstraksi & TDS'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Extraction Score Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEn ? 'EXTRACTION YIELD (EY)' : 'HASIL EKSTRAKSI (EY)', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('${ey.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(isEn ? 'TDS STRENGTH' : 'KEKUATAN TDS', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('${_tdsPercent.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _scaQuadrant,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Interactive 2D Chart
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SCA Brewing Control Chart (2D)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Golden Cup (18-22%)', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: ScaChartPainter(ey: ey, tds: _tdsPercent),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('14% EY', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text('EY Ideal (18% - 22%)', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                    Text('26% EY', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // LRR (Liquid Retained Ratio) Setting
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Liquid Retained Ratio (LRR):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                    Text('Est. Total Air: ${_totalWaterEstimated.round()}g', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBrown)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildLrrChip('Light Roast (1.9x)', 1.9),
                    const SizedBox(width: 6),
                    _buildLrrChip('Medium (2.1x)', 2.1),
                    const SizedBox(width: 6),
                    _buildLrrChip('Dark (2.3x)', 2.3),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Sliders
          _buildSliderCard(
            title: isEn ? 'Coffee Dose (Gram)' : 'Dosis Kopi Bubuk (Gram)',
            valueText: '${_coffeeDose.toStringAsFixed(1)} g',
            min: 10.0,
            max: 35.0,
            val: _coffeeDose,
            onChanged: (v) => setState(() => _coffeeDose = v),
          ),
          const SizedBox(height: 10),

          _buildSliderCard(
            title: isEn ? 'Beverage Yield Weight (Liquid)' : 'Berat Hasil Seduhan Cair (Beverage)',
            valueText: '${_beverageWeight.round()}g (Rasio 1:${_brewRatio.toStringAsFixed(1)})',
            min: 140.0,
            max: 450.0,
            val: _beverageWeight,
            onChanged: (v) => setState(() => _beverageWeight = v),
          ),
          const SizedBox(height: 10),

          _buildSliderCard(
            title: isEn ? 'Refractometer TDS (%)' : 'Hasil Baca Refraktometer TDS (%)',
            valueText: '${_tdsPercent.toStringAsFixed(2)}%',
            min: 0.80,
            max: 1.80,
            val: _tdsPercent,
            onChanged: (v) => setState(() => _tdsPercent = v),
          ),
          const SizedBox(height: 14),

          // Barista Prescription
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(CupertinoIcons.compass_fill, color: AppTheme.primaryBrown, size: 18),
                    SizedBox(width: 8),
                    Text('Rekomendasi Penyesuaian Seduh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  ],
                ),
                const Divider(height: 18),
                Text(_getPrescriptionText(ey, _tdsPercent, isEn), style: const TextStyle(fontSize: 12, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLrrChip(String label, double val) {
    final isSelected = (_lrrValue - val).abs() < 0.05;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _lrrValue = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBrown : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppTheme.primaryBrown : Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String valueText,
    required double min,
    required double max,
    required double val,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              Text(valueText, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBrown, fontSize: 13.5)),
            ],
          ),
          Slider(
            value: val,
            min: min,
            max: max,
            activeColor: AppTheme.primaryBrown,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _getPrescriptionText(double ey, double tds, bool isEn) {
    if (ey >= 18.0 && ey <= 22.0 && tds >= 1.15 && tds <= 1.45) {
      return isEn
          ? 'Perfect! Your extraction is inside the SCA Golden Cup Zone. You have achieved maximum sweetness and dissolved sugars without harsh bitterness.'
          : 'Sempurna! Seduhan Anda berada di dalam zona Golden Cup SCA. Gula karamel dan asam buah terlarut seimbang tanpa sisa pahit sepat.';
    }
    if (ey < 18.0) {
      return isEn
          ? 'Under-extracted: Grind finer by 1-2 clicks, increase water temperature (+1°C), or slightly increase liquid ratio to extract more soluble sugars.'
          : 'Under-extracted: Giling 1-2 klik lebih halus, naikkan suhu air (+1°C), atau perlebar sedikit rasio seduh agar senyawa gula manis terekstrak optimal.';
    }
    if (ey > 22.0) {
      return isEn
          ? 'Over-extracted: Grind coarser, lower water temperature, or reduce contact time to prevent extracting bitter dry tannins.'
          : 'Over-extracted: Giling lebih kasar, turunkan suhu air, atau perpendek waktu kontak air agar zat tannin pahit kering tidak terbawa.';
    }
    if (tds < 1.15) {
      return isEn
          ? 'Strength is too weak: Increase coffee dose (e.g. 15g -> 16.5g) to increase total dissolved solids body.'
          : 'Kekuatan rasa terlalu encer: Tingkatkan dosis kopi bubuk (misal dari 15g ke 16.5g) untuk mempertebal body cangkir.';
    }
    return isEn
        ? 'Strength is too heavy/muddy: Increase brew water or coarsen grind slightly.'
        : 'Rasa cangkir terlalu pekat menusuk: Perlebar rasio air atau giling sedikit lebih kasar.';
  }
}
