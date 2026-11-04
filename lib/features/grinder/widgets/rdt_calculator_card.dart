import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Kartu Kalkulator RDT (Ross Droplet Technique) & Analisis Fines Burr
class RdtCalculatorCard extends StatefulWidget {
  final double currentMicrons;

  const RdtCalculatorCard({super.key, required this.currentMicrons});

  @override
  State<RdtCalculatorCard> createState() => _RdtCalculatorCardState();
}

class _RdtCalculatorCardState extends State<RdtCalculatorCard> {
  String _roastLevel = 'Medium'; // Light, Medium, Dark
  int _doseGrams = 15;
  final bool _isDryClimate = true;

  int get _dropletsRecommended {
    int drops = 1;
    if (_doseGrams > 20) drops++;
    if (_roastLevel == 'Dark') drops++;
    if (_isDryClimate) drops++;
    return drops.clamp(1, 4);
  }

  double get _retentionEstimate {
    double base = 0.5;
    if (_roastLevel == 'Dark') base += 0.4;
    if (widget.currentMicrons < 400) base += 0.5;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0D5C7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.drop_fill, color: Color(0xFF00796B), size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RDT & Anti-Static Estimator',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF2C1810)),
                    ),
                    Text(
                      'Ross Droplet Technique cegah retensi bubuk & static',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_dropletsRecommended Semprot / Drop',
                  style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dose & Roast selectors
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dosis:', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _doseGrams,
                          isDense: true,
                          items: [12, 15, 18, 20, 24, 30].map((d) {
                            return DropdownMenuItem(value: d, child: Text('${d}g', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _doseGrams = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Roast:', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _roastLevel,
                          isDense: true,
                          items: ['Light', 'Medium', 'Dark'].map((r) {
                            return DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _roastLevel = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Insight tip
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.info_circle_fill, size: 14, color: Color(0xFF2E7D32)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tanpa RDT, estimasi retensi statis adalah ~${_retentionEstimate.toStringAsFixed(1)}g. Gunakan spray/tetes air 0.05g pada biji sebelum grinding.',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF1B5E20), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
