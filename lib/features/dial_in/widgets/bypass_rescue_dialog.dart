import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Kalkulator Penyelamat Kopi Over-extracted via Bypass Dilution (Water Bypass)
class BypassRescueDialog extends StatefulWidget {
  const BypassRescueDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const BypassRescueDialog(),
    );
  }

  @override
  State<BypassRescueDialog> createState() => _BypassRescueDialogState();
}

class _BypassRescueDialogState extends State<BypassRescueDialog> {
  double _cupWeightGrams = 200.0;
  String _harshnessLevel = 'Sedang'; // Ringan, Sedang, Sangat Pahit

  double get _bypassWaterRecommended {
    if (_harshnessLevel == 'Ringan') {
      return _cupWeightGrams * 0.05; // 5% bypass
    } else if (_harshnessLevel == 'Sedang') {
      return _cupWeightGrams * 0.10; // 10% bypass
    } else {
      return _cupWeightGrams * 0.15; // 15% bypass
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00796B).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.drop_fill, color: Color(0xFF00796B), size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Bypass Rescue Calculator',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jika seduhan Anda terlalu pahit, pekat atau tenggorokan terasa kering, teknik Bypass (menambahkan air panas bersih setelah seduh) dapat menyelamatkan cangkir seketika!',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.35),
            ),
            const SizedBox(height: 14),

            // Cup weight input
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Berat Kopi di Cangkir:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                Text('${_cupWeightGrams.round()} g', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.primaryBrown)),
              ],
            ),
            Slider(
              value: _cupWeightGrams,
              min: 100,
              max: 500,
              divisions: 40,
              activeColor: AppTheme.primaryBrown,
              onChanged: (val) => setState(() => _cupWeightGrams = val),
            ),
            const SizedBox(height: 8),

            // Harshness Selector
            const Text('Tingkat Kepahitan / Kering:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: ['Ringan', 'Sedang', 'Sangat Pahit'].map((level) {
                final isSelected = _harshnessLevel == level;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _harshnessLevel = level),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00796B) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? const Color(0xFF00796B) : Colors.grey.shade300),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        level,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Recommendation Result Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF80CBC4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(CupertinoIcons.sparkles, size: 16, color: Color(0xFF00796B)),
                      SizedBox(width: 6),
                      Text(
                        'Rekomendasi Bypass:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tambahkan ${_bypassWaterRecommended.round()} mL air panas (85°C - 90°C) langsung ke cangkir Anda.',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF00796B)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Aduk perlahan. Rasa pahit/sepet polifenol akan melunak dan aroma manis buah akan kembali mekar.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF004D40), height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBrown,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
