import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ScaleFlowRateGauge extends StatelessWidget {
  final double flowRate;
  final bool isEn;

  const ScaleFlowRateGauge({
    super.key,
    required this.flowRate,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    Color gaugeColor = Colors.grey;
    String status = isEn ? 'Drip / Pause' : 'Tetesan Lambat';

    if (flowRate >= 2.8 && flowRate <= 5.2) {
      gaugeColor = Colors.greenAccent;
      status = isEn ? 'Sweet Spot (Ideal Pour)' : 'Sweet Spot (Laju Ideal)';
    } else if (flowRate > 5.2) {
      gaugeColor = Colors.orangeAccent;
      status = isEn ? 'Heavy Agitation' : 'Agitasi Cepat';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.drop_fill, size: 14, color: AppTheme.accentGold),
            const SizedBox(width: 4),
            Text(
              '${flowRate.toStringAsFixed(1)} g/s',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gaugeColor),
            ),
            const SizedBox(width: 8),
            Text(
              '• $status',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: gaugeColor),
            ),
          ],
        ),
      ],
    );
  }
}
