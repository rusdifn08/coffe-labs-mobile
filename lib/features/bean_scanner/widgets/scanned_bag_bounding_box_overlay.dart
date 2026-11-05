import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/resolved_coffee_bean.dart';

class ScannedBagBoundingBoxOverlay extends StatelessWidget {
  final File imageFile;
  final List<ClassifiedOcrBlock> blocks;
  final double height;

  const ScannedBagBoundingBoxOverlay({
    super.key,
    required this.imageFile,
    required this.blocks,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    final activeBlocks = blocks.where((b) => b.role != BlockRole.ignoredNoise).toList();

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF141210),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5C3A21), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          if (imageFile.existsSync())
            Image.file(
              imageFile,
              fit: BoxFit.cover,
            )
          else
            Container(color: const Color(0xFF221E1A)),

          // Subtle contrast vignette
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),

          // Spatial Bounding Boxes overlay
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                children: activeBlocks.map((block) {
                  // Only plot boxes that have coordinates
                  if (block.normalizedHeight <= 0.005) return const SizedBox.shrink();

                  final top = (block.topY * h).clamp(4.0, h - 35.0);
                  final left = (block.leftX * w).clamp(4.0, w - 80.0);
                  final boxW = max(55.0, (block.normalizedWidth * w).clamp(30.0, w - left - 4.0));
                  final boxH = max(24.0, (block.normalizedHeight * h).clamp(20.0, 60.0));

                  final color = block.role.color;

                  return Positioned(
                    top: top,
                    left: left,
                    width: boxW,
                    height: boxH,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: color, width: 1.6),
                        borderRadius: BorderRadius.circular(6),
                        color: color.withValues(alpha: 0.16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -11,
                            left: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black54, blurRadius: 3),
                                ],
                              ),
                              child: Text(
                                block.role.badgeLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Bottom Quick Legend Pills Strip
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLegendPill('Roastery', const Color(0xFFD4AF37)),
                  const SizedBox(width: 5),
                  _buildLegendPill('Origin', const Color(0xFF4E8752)),
                  const SizedBox(width: 5),
                  _buildLegendPill('Proses', const Color(0xFF9E2A3B)),
                  const SizedBox(width: 5),
                  _buildLegendPill('Notes/Detail', const Color(0xFF3B82A6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
