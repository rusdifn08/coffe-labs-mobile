import 'package:flutter/material.dart';

import '../../../../screens/brew_timer_screen.dart';
import '../../../../theme/app_theme.dart';

/// Pra-layar Khusus Flash-Chill Japanese Iced Filter (non-V60):
/// Memastikan pembagian Es Batu di server vs Air Seduh Panas konsentrat tepat sebelum timer jalan.
class FlashChillIcedBrewScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const FlashChillIcedBrewScreen({super.key, required this.recipe});

  @override
  State<FlashChillIcedBrewScreen> createState() =>
      _FlashChillIcedBrewScreenState();
}

class _FlashChillIcedBrewScreenState extends State<FlashChillIcedBrewScreen> {
  bool _iceReady = false;
  bool _rinsed = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.recipe['title']?.toString() ?? 'Japanese Iced Drip';
    final doseG = (widget.recipe['coffeeWeightGrams'] as num?)?.toDouble() ?? 18.0;
    final hotWaterG =
        (widget.recipe['totalWaterWeightGrams'] as num?)?.toDouble() ?? 180.0;
    final rawIceG = (widget.recipe['iceWeightGrams'] as num?)?.toDouble() ?? 0.0;
    final iceG = rawIceG > 0 ? rawIceG : (hotWaterG * 0.65).roundToDouble();
    final totalBeverage = hotWaterG + iceG;
    final icePct = totalBeverage > 0 ? ((iceG / totalBeverage) * 100).round() : 40;
    final hotPct = 100 - icePct;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text(
          'Flash-Chill Japanese Iced',
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SplitTile(
                            icon: Icons.ac_unit_rounded,
                            color: const Color(0xFF0284C7),
                            label: 'Es Batu di Server ($icePct%)',
                            value: '${iceG.toStringAsFixed(0)} g',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SplitTile(
                            icon: Icons.water_drop_rounded,
                            color: AppTheme.primaryBrown,
                            label: 'Air Panas Ketel ($hotPct%)',
                            value: '${hotWaterG.toStringAsFixed(0)} ml',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Total Minuman Akhir: ${totalBeverage.toStringAsFixed(0)} ml · Dosis Kopi ${doseG.toStringAsFixed(1)} g',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                tileColor: AppTheme.surfaceWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.borderWarm),
                ),
                value: _rinsed,
                activeColor: AppTheme.primaryBrown,
                title: const Text(
                  'Bilas kertas filter & buang air bilasan sebelum memasukkan es',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                onChanged: (v) => setState(() => _rinsed = v ?? false),
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                tileColor: AppTheme.surfaceWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.borderWarm),
                ),
                value: _iceReady,
                activeColor: const Color(0xFF0284C7),
                title: Text(
                  'Timbang ${iceG.toStringAsFixed(0)}g es batu kristal ke dalam server',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                onChanged: (v) => setState(() => _iceReady = v ?? false),
              ),
              const SizedBox(height: 22),
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
                  label: Text(
                    'Mulai Seduh Konsentrat (${hotWaterG.toStringAsFixed(0)}ml)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
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

class _SplitTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _SplitTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
