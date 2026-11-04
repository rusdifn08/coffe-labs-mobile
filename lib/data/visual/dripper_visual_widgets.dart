import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../brew_visual_catalog.dart';

class DripperGraphicBadge extends StatelessWidget {
  final DripperVisualItem item;
  final double size;

  const DripperGraphicBadge({
    super.key,
    required this.item,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.color.withValues(alpha: 0.18),
            item.color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: item.color.withValues(alpha: 0.3)),
      ),
      child: CustomPaint(
        painter: _DripperShapePainter(shapeType: item.shapeType, color: item.color),
      ),
    );
  }
}

class _DripperShapePainter extends CustomPainter {
  final String shapeType;
  final Color color;

  _DripperShapePainter({required this.shapeType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    if (shapeType == 'aeropress') {
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.32, h * 0.28, w * 0.36, h * 0.50), const Radius.circular(3));
      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, stroke);
      canvas.drawLine(Offset(w * 0.38, h * 0.16), Offset(w * 0.62, h * 0.16), stroke);
      canvas.drawLine(Offset(w * 0.50, h * 0.16), Offset(w * 0.50, h * 0.45), stroke);
      canvas.drawLine(Offset(w * 0.25, h * 0.78), Offset(w * 0.75, h * 0.78), stroke);
      return;
    }

    if (shapeType == 'frenchpress') {
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.26, h * 0.26, w * 0.42, h * 0.54), const Radius.circular(4));
      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, stroke);
      canvas.drawCircle(Offset(w * 0.47, h * 0.17), 3.0, stroke);
      canvas.drawLine(Offset(w * 0.47, h * 0.20), Offset(w * 0.47, h * 0.58), stroke);
      canvas.drawLine(Offset(w * 0.30, h * 0.58), Offset(w * 0.64, h * 0.58), stroke);
      final handle = Path()
        ..moveTo(w * 0.68, h * 0.34)
        ..lineTo(w * 0.78, h * 0.34)
        ..lineTo(w * 0.78, h * 0.68)
        ..lineTo(w * 0.68, h * 0.68);
      canvas.drawPath(handle, stroke);
      return;
    }

    if (shapeType == 'flat') {
      final path = Path()
        ..moveTo(w * 0.20, h * 0.26)
        ..lineTo(w * 0.80, h * 0.26)
        ..lineTo(w * 0.66, h * 0.72)
        ..lineTo(w * 0.34, h * 0.72)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
      canvas.drawLine(Offset(w * 0.40, h * 0.26), Offset(w * 0.43, h * 0.72), stroke);
      canvas.drawLine(Offset(w * 0.60, h * 0.26), Offset(w * 0.57, h * 0.72), stroke);
      canvas.drawLine(Offset(w * 0.24, h * 0.76), Offset(w * 0.76, h * 0.76), stroke);
      return;
    }

    if (shapeType == 'origami') {
      final path = Path()
        ..moveTo(w * 0.18, h * 0.24)
        ..lineTo(w * 0.82, h * 0.24)
        ..lineTo(w * 0.56, h * 0.74)
        ..lineTo(w * 0.44, h * 0.74)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
      canvas.drawLine(Offset(w * 0.34, h * 0.24), Offset(w * 0.47, h * 0.74), stroke);
      canvas.drawLine(Offset(w * 0.50, h * 0.24), Offset(w * 0.50, h * 0.74), stroke);
      canvas.drawLine(Offset(w * 0.66, h * 0.24), Offset(w * 0.53, h * 0.74), stroke);
      return;
    }

    // Default V60 / Switch / Iced V60 Cone
    final cone = Path()
      ..moveTo(w * 0.20, h * 0.24)
      ..lineTo(w * 0.80, h * 0.24)
      ..lineTo(w * 0.56, h * 0.68)
      ..lineTo(w * 0.44, h * 0.68)
      ..close();
    canvas.drawPath(cone, fill);
    canvas.drawPath(cone, stroke);
    canvas.drawArc(Rect.fromLTWH(w * 0.32, h * 0.30, w * 0.36, h * 0.28), 0.3, 1.8, false, stroke);
    canvas.drawLine(Offset(w * 0.26, h * 0.72), Offset(w * 0.74, h * 0.72), stroke);

    if (shapeType == 'switch' || shapeType == 'clever') {
      final baseRect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.36, h * 0.68, w * 0.28, h * 0.12), const Radius.circular(3));
      canvas.drawRRect(baseRect, fill);
      canvas.drawRRect(baseRect, stroke);
      canvas.drawLine(Offset(w * 0.64, h * 0.74), Offset(w * 0.78, h * 0.78), stroke);
    } else if (shapeType == 'iced_v60') {
      final iceRect = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.41, h * 0.75, w * 0.18, h * 0.14), const Radius.circular(3));
      canvas.drawRRect(iceRect, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Badge visual untuk Tasting Notes lengkap dengan gambar/ikon warna sesuai rasanya.
class FlavorNoteVisualBadge extends StatelessWidget {
  final String noteText;
  final bool selected;
  final VoidCallback? onTap;

  const FlavorNoteVisualBadge({
    super.key,
    required this.noteText,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = BrewVisualCatalog.matchNote(noteText);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? item.color : item.color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? item.color : item.color.withValues(alpha: 0.30),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.25) : Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(item.emoji, style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                noteText,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : item.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              const Icon(CupertinoIcons.check_mark, size: 12, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
