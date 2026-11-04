import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Barometer Prediksi Sensorik Rasa Metode 4:6 Tetsu Kasuya
class FourSixFlavorBarometer extends StatelessWidget {
  final String stage1Balance; // 'sweetness', 'balanced', 'acidity'
  final int stage2Pours; // 1 (Light), 2 (Medium), 3 (Strong)
  final bool splitTempMode;

  const FourSixFlavorBarometer({
    super.key,
    required this.stage1Balance,
    required this.stage2Pours,
    required this.splitTempMode,
  });

  double get _acidityScore {
    if (stage1Balance == 'acidity') return 4.8;
    if (stage1Balance == 'sweetness') return 3.2;
    return 4.0;
  }

  double get _sweetnessScore {
    if (stage1Balance == 'sweetness') return 4.9;
    if (stage1Balance == 'acidity') return 3.4;
    return 4.2;
  }

  double get _bodyScore {
    if (stage2Pours == 3) return 4.8;
    if (stage2Pours == 2) return 3.8;
    return 2.8;
  }

  double get _clarityScore {
    double base = (stage2Pours == 1) ? 4.9 : (stage2Pours == 2 ? 4.2 : 3.5);
    if (splitTempMode) base = (base + 0.5).clamp(1.0, 5.0);
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.waveform_path_ecg, size: 16, color: Color(0xFFE65100)),
                  SizedBox(width: 6),
                  Text(
                    'Prediksi Profil Rasa di Cangkir',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C1810)),
                  ),
                ],
              ),
              if (splitTempMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: const Text(
                    'Split-Temp Active',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBar('Acidity (Kecerahan Asam)', _acidityScore, const Color(0xFFF57F17)),
          const SizedBox(height: 6),
          _buildBar('Sweetness (Kemanisan Alami)', _sweetnessScore, const Color(0xFFE65100)),
          const SizedBox(height: 6),
          _buildBar('Body & Texture (Kekentalan)', _bodyScore, const Color(0xFF5D4037)),
          const SizedBox(height: 6),
          _buildBar('Cup Clarity & Cleanliness', _clarityScore, const Color(0xFF00796B)),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.black87)),
            Text('${value.toStringAsFixed(1)} / 5.0', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value / 5.0).clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
