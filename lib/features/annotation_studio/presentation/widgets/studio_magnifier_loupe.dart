import 'package:flutter/material.dart';

/// Touch Magnifier Loupe showing a magnified circular view around the active vertex touch point
class StudioMagnifierLoupe extends StatelessWidget {
  final Offset focalPoint;
  final Widget child;
  final double scale;
  final double size;

  const StudioMagnifierLoupe({
    super.key,
    required this.focalPoint,
    required this.child,
    this.scale = 2.0,
    this.size = 110.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: focalPoint.dx - (size / 2),
      top: focalPoint.dy - size - 40,
      width: size,
      height: size,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4A373), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              children: [
                Transform.translate(
                  offset: Offset(
                    (size / 2) - (focalPoint.dx * scale),
                    (size / 2) - (focalPoint.dy * scale),
                  ),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: child,
                  ),
                ),
                // Center reticle
                Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
