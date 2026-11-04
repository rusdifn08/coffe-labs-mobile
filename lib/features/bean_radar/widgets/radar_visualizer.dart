import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class RadarVisualizer extends StatelessWidget {
  final AnimationController pulseController;
  final bool hasNearbyItems;
  final String currentLocationName;
  final VoidCallback onSelectCity;

  const RadarVisualizer({
    super.key,
    required this.pulseController,
    required this.hasNearbyItems,
    required this.currentLocationName,
    required this.onSelectCity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      color: AppTheme.bgCream,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse Circles
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              final progress = pulseController.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140 + progress * 70,
                    height: 140 + progress * 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentGold.withValues(alpha: (1.0 - progress) * 0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 80 + progress * 50,
                    height: 80 + progress * 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentGold.withValues(alpha: (1.0 - progress) * 0.08),
                    ),
                  ),
                ],
              );
            },
          ),

          // Radar Crosshairs
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
            ),
          ),

          // Center User Pin
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBrown,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(CupertinoIcons.location_solid, color: Colors.white, size: 24),
          ),

          // Nearby Ping dots
          if (hasNearbyItems) ...[
            Positioned(
              top: 45,
              left: 70,
              child: _buildRadarBlip('0.8 km'),
            ),
            Positioned(
              bottom: 40,
              right: 80,
              child: _buildRadarBlip('1.4 km'),
            ),
            Positioned(
              top: 60,
              right: 65,
              child: _buildRadarBlip('2.2 km'),
            ),
          ],

          // Location Pill at bottom of radar
          Positioned(
            bottom: 12,
            child: GestureDetector(
              onTap: onSelectCity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.placemark_fill, size: 14, color: AppTheme.accentGold),
                    const SizedBox(width: 6),
                    Text(
                      currentLocationName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryBrown),
                    ),
                    const SizedBox(width: 4),
                    const Icon(CupertinoIcons.chevron_down, size: 12, color: AppTheme.primaryBrown),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarBlip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
