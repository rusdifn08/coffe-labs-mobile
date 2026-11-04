import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/smart_scale_service.dart';
import '../../../theme/app_theme.dart';

class ScaleSimulationCard extends StatelessWidget {
  final bool isEn;
  final SmartScaleService scaleService;

  const ScaleSimulationCard({
    super.key,
    required this.isEn,
    required this.scaleService,
  });

  @override
  Widget build(BuildContext context) {
    if (!scaleService.isSimulationMode) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF26211C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.play_circle_fill, color: AppTheme.accentGold, size: 16),
              const SizedBox(width: 6),
              Text(
                isEn ? 'Interactive Scale Simulator (Testing Mode)' : 'Simulator Timbangan Interaktif',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.accentGold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isEn
                ? 'Simulate coffee pouring physics without physical hardware scale.'
                : 'Simulasikan penuangan air tanpa perlu hardware timbangan fisik.',
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                backgroundColor: const Color(0xFF332D26),
                label: Text(
                  isEn ? '+15g Coffee' : '+15g Kopi',
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
                onPressed: () => scaleService.simulateAddCoffee(15.0),
              ),
              ActionChip(
                backgroundColor: const Color(0xFF332D26),
                label: Text(
                  isEn ? 'Bloom Pour (3.0 g/s)' : 'Tuang Bloom (3.0 g/s)',
                  style: const TextStyle(fontSize: 11, color: Colors.cyanAccent),
                ),
                onPressed: () => scaleService.setSimulatedFlowRate(3.0),
              ),
              ActionChip(
                backgroundColor: const Color(0xFF332D26),
                label: Text(
                  isEn ? 'Main Spiral (4.5 g/s)' : 'Tuang Utama (4.5 g/s)',
                  style: const TextStyle(fontSize: 11, color: AppTheme.accentGold),
                ),
                onPressed: () => scaleService.setSimulatedFlowRate(4.5),
              ),
              ActionChip(
                backgroundColor: const Color(0xFF332D26),
                label: Text(
                  isEn ? 'Stop Pour (0 g/s)' : 'Hentikan Tuang (0 g/s)',
                  style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                ),
                onPressed: () => scaleService.setSimulatedFlowRate(0.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
