import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/water_profile.dart';

/// Interactive card explaining the GH:KH buffer ratio and sensory impact.
class WaterBufferCard extends StatelessWidget {
  final WaterProfile profile;

  const WaterBufferCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final ratio = profile.bufferRatio;

    Color badgeColor;
    String badgeLabel;
    if (ratio > 3.0) {
      badgeColor = const Color(0xFF8E24AA);
      badgeLabel = 'Bright & Citric';
    } else if (ratio >= 1.6) {
      badgeColor = const Color(0xFF00897B);
      badgeLabel = 'Sweet & Balanced';
    } else {
      badgeColor = const Color(0xFFE65100);
      badgeLabel = 'Heavy & Rounded';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(CupertinoIcons.slider_horizontal_below_rectangle, size: 17, color: badgeColor),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Rasio Buffer Kimia (GH:KH)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ratio.toStringAsFixed(1)}:1 • $badgeLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                      color: badgeColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Ratio Visual Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE65100), // Heavy Buffer
                          Color(0xFF00897B), // Balanced
                          Color(0xFF8E24AA), // Bright Acidity
                        ],
                      ),
                    ),
                  ),
                  // Current ratio indicator pin
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (ratio / 4.0).clamp(0.05, 1.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Buffer Tinggi (Flat)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: Colors.grey),
                ),
              ),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  '1.6 - 2.5 (Harmonis)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: Colors.grey),
                ),
              ),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  '>3.0 (Acid Pop)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CupertinoIcons.sparkles, size: 14, color: Color(0xFF8D6E63)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    profile.sensoryDiagnosis,
                    style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.35),
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
