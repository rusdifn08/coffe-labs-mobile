import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'studio_magnifier_loupe.dart';

class StudioInteractiveCanvas extends StatefulWidget {
  final File imageFile;
  final List<Offset> polygon; // Normalized [0.0 - 1.0]
  final Rect? bbox; // Normalized [0.0 - 1.0]
  final Color classColor;
  final String? classLabel;
  final bool isSmartTapMode;
  final int? selectedVertexIndex;
  final ValueChanged<Offset>? onSmartTap;
  final void Function(int index, Offset newPos)? onVertexMoved;
  final ValueChanged<int?>? onVertexSelected;

  const StudioInteractiveCanvas({
    super.key,
    required this.imageFile,
    required this.polygon,
    this.bbox,
    this.classColor = const Color(0xFF8B5CF6),
    this.classLabel,
    this.isSmartTapMode = false,
    this.selectedVertexIndex,
    this.onSmartTap,
    this.onVertexMoved,
    this.onVertexSelected,
  });

  @override
  State<StudioInteractiveCanvas> createState() => _StudioInteractiveCanvasState();
}

class _StudioInteractiveCanvasState extends State<StudioInteractiveCanvas> {
  final TransformationController _transformController = TransformationController();
  int? _activeDraggingIndex;
  Offset? _touchFocalPoint;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasW = constraints.maxWidth;
        final canvasH = constraints.maxHeight;

        final canvasContent = Stack(
          fit: StackFit.expand,
          children: [
            // Base Image
            Image.file(
              widget.imageFile,
              fit: BoxFit.contain,
              width: canvasW,
              height: canvasH,
            ),

            // Polygon & Bounding Box Overlay
            CustomPaint(
              size: Size(canvasW, canvasH),
              painter: _StudioPolygonPainter(
                polygon: widget.polygon,
                bbox: widget.bbox,
                classColor: widget.classColor,
                classLabel: widget.classLabel,
                selectedVertexIndex: _activeDraggingIndex ?? widget.selectedVertexIndex,
              ),
            ),
          ],
        );

        return Stack(
          children: [
            GestureDetector(
              onTapUp: (details) {
                if (widget.isSmartTapMode) {
                  final norm = Offset(
                    (details.localPosition.dx / canvasW).clamp(0.0, 1.0),
                    (details.localPosition.dy / canvasH).clamp(0.0, 1.0),
                  );
                  widget.onSmartTap?.call(norm);
                } else {
                  // Check if vertex tapped
                  final tappedIdx = _findNearestVertex(details.localPosition, Size(canvasW, canvasH));
                  widget.onVertexSelected?.call(tappedIdx);
                }
              },
              onPanStart: (details) {
                final idx = _findNearestVertex(details.localPosition, Size(canvasW, canvasH));
                if (idx != null) {
                  setState(() {
                    _activeDraggingIndex = idx;
                    _touchFocalPoint = details.localPosition;
                  });
                  widget.onVertexSelected?.call(idx);
                }
              },
              onPanUpdate: (details) {
                if (_activeDraggingIndex != null) {
                  setState(() {
                    _touchFocalPoint = details.localPosition;
                  });
                  final norm = Offset(
                    (details.localPosition.dx / canvasW).clamp(0.0, 1.0),
                    (details.localPosition.dy / canvasH).clamp(0.0, 1.0),
                  );
                  widget.onVertexMoved?.call(_activeDraggingIndex!, norm);
                }
              },
              onPanEnd: (_) {
                setState(() {
                  _activeDraggingIndex = null;
                  _touchFocalPoint = null;
                });
              },
              child: canvasContent,
            ),

            // Magnifier Loupe during touch drag
            if (_activeDraggingIndex != null && _touchFocalPoint != null)
              StudioMagnifierLoupe(
                focalPoint: _touchFocalPoint!,
                child: canvasContent,
              ),
          ],
        );
      },
    );
  }

  int? _findNearestVertex(Offset touch, Size size) {
    if (widget.polygon.isEmpty) return null;
    const double hitRadius = 32.0;

    int? nearest;
    double minDistance = hitRadius;

    for (int i = 0; i < widget.polygon.length; i++) {
      final p = widget.polygon[i];
      final screenX = p.dx * size.width;
      final screenY = p.dy * size.height;
      final distance = (Offset(screenX, screenY) - touch).distance;

      if (distance < minDistance) {
        minDistance = distance;
        nearest = i;
      }
    }
    return nearest;
  }
}

class _StudioPolygonPainter extends CustomPainter {
  final List<Offset> polygon;
  final Rect? bbox;
  final Color classColor;
  final String? classLabel;
  final int? selectedVertexIndex;

  _StudioPolygonPainter({
    required this.polygon,
    this.bbox,
    required this.classColor,
    this.classLabel,
    this.selectedVertexIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Bounding Box (Subtle guideline)
    if (bbox != null) {
      final rect = Rect.fromLTRB(
        bbox!.left * size.width,
        bbox!.top * size.height,
        bbox!.right * size.width,
        bbox!.bottom * size.height,
      );

      final boxPaint = Paint()
        ..color = classColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        boxPaint,
      );

      // Label Header Pill
      if (classLabel != null && classLabel!.isNotEmpty) {
        final textSpan = TextSpan(
          text: classLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
        final pillRect = Rect.fromLTWH(rect.left, math.max(0, rect.top - 20), tp.width + 12, 18);

        final pillPaint = Paint()..color = classColor;
        canvas.drawRRect(RRect.fromRectAndRadius(pillRect, const Radius.circular(4)), pillPaint);
        tp.paint(canvas, Offset(pillRect.left + 6, pillRect.top + 2));
      }
    }

    if (polygon.length < 3) return;

    // 2. Draw Polygon Contour & Shading
    final path = Path();
    final first = Offset(polygon[0].dx * size.width, polygon[0].dy * size.height);
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < polygon.length; i++) {
      final pt = Offset(polygon[i].dx * size.width, polygon[i].dy * size.height);
      path.lineTo(pt.dx, pt.dy);
    }
    path.close();

    // Fill
    final fillPaint = Paint()
      ..color = classColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = classColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // 3. Draw Vertices (Interactive Control Points)
    for (int i = 0; i < polygon.length; i++) {
      final pt = Offset(polygon[i].dx * size.width, polygon[i].dy * size.height);
      final isSelected = selectedVertexIndex == i;

      final handlePaint = Paint()
        ..color = isSelected ? const Color(0xFFD4A373) : Colors.white
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isSelected ? Colors.white : classColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.5;

      canvas.drawCircle(pt, isSelected ? 8.0 : 6.0, handlePaint);
      canvas.drawCircle(pt, isSelected ? 8.0 : 6.0, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StudioPolygonPainter oldDelegate) {
    return oldDelegate.polygon != polygon ||
        oldDelegate.bbox != bbox ||
        oldDelegate.classColor != classColor ||
        oldDelegate.selectedVertexIndex != selectedVertexIndex;
  }
}
