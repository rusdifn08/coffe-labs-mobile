import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/freshness_models.dart';

/// Professional Brew Parameters Adaptation Card based on Bean Degassing Curve.
class FreshnessDialCard extends StatelessWidget {
  final BrewAdjustment adjustment;
  final bool isEspresso;

  const FreshnessDialCard({
    super.key,
    required this.adjustment,
    required this.isEspresso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.primaryBrown, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kalibrasi Parameter Seduh (Adaptif)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  isEspresso ? 'Pre-Infusion' : 'Durasi Blooming',
                  '${adjustment.bloomTimeSeconds}s',
                  isEspresso ? 'Waktu pembasahan' : '${adjustment.bloomWaterRatio.toStringAsFixed(1)}x rasio air',
                  CupertinoIcons.timer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  'Suhu Air Seduh',
                  '${adjustment.recommendedTempC}°C',
                  'Target optimal',
                  CupertinoIcons.thermometer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Penyesuaian Gilingan:',
            adjustment.grindAdvice,
            CupertinoIcons.circle_grid_hex_fill,
            const Color(0xFF5D4037),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Agitasi & Perlakuan Gas:',
            adjustment.agitationAdvice,
            CupertinoIcons.wind,
            const Color(0xFF00897B),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppTheme.primaryBrown),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBrown),
          ),
          Text(
            sub,
            style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String content, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11.5, color: Colors.black87, height: 1.3),
              children: [
                TextSpan(
                  text: '$title ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                TextSpan(text: content),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
