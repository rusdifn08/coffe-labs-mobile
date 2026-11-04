import 'package:flutter/material.dart';

class CoffeeBeanIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CoffeeBeanIcon({super.key, this.size = 10, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CoffeeBeanPainter(color: color),
      ),
    );
  }
}

class _CoffeeBeanPainter extends CustomPainter {
  final Color color;

  const _CoffeeBeanPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.12).clamp(0.8, 1.4)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.45); // ~26 degree tilt

    // Draw the oval body of coffee bean
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.72,
      height: size.height * 0.96,
    );
    canvas.drawOval(rect, fillPaint);

    // The iconic center crease curve of the bean
    final path = Path();
    final h = size.height * 0.38;
    final w = size.width * 0.14;
    path.moveTo(0, -h);
    path.cubicTo(w, -h * 0.35, -w, h * 0.35, 0, h);
    canvas.drawPath(path, linePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CoffeeBeanPainter oldDelegate) => oldDelegate.color != color;
}
