import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/services/smart_sam_engine_service.dart';
import '../controllers/annotation_studio_state.dart';
import 'studio_magnifier_loupe.dart';

class StudioInteractiveCanvas extends StatefulWidget {
  final File imageFile;
  final List<Offset> polygon; // Normalized [0.0 - 1.0]
  final Rect? bbox; // Normalized [0.0 - 1.0]
  final Color classColor;
  final String? classLabel;
  final StudioTool activeTool;
  final SamPromptMode samPromptMode;
  final List<SamPromptPoint> samPromptPoints;
  final int? selectedVertexIndex;
  final bool isLayerVisible;
  final double layerOpacity;
  final bool isLayerLocked;

  // Callbacks
  final ValueChanged<Offset>? onSamPointTapped;
  final ValueChanged<Rect>? onSmartBoxDrawn;
  final ValueChanged<Rect>? onBoundingBoxDrawn;
  final ValueChanged<Offset>? onPolygonVertexAdded;
  final VoidCallback? onPolygonClosed;
  final void Function(int index, Offset newPos)? onVertexMoved;
  final void Function(int index, Offset newPos)? onVertexInserted;
  final ValueChanged<int>? onVertexDeleted;
  final ValueChanged<int?>? onVertexSelected;

  const StudioInteractiveCanvas({
    super.key,
    required this.imageFile,
    required this.polygon,
    this.bbox,
    this.classColor = const Color(0xFF7C3AED),
    this.classLabel,
    this.activeTool = StudioTool.samPoints,
    this.samPromptMode = SamPromptMode.positive,
    this.samPromptPoints = const [],
    this.selectedVertexIndex,
    this.isLayerVisible = true,
    this.layerOpacity = 0.25,
    this.isLayerLocked = false,
    this.onSamPointTapped,
    this.onSmartBoxDrawn,
    this.onBoundingBoxDrawn,
    this.onPolygonVertexAdded,
    this.onPolygonClosed,
    this.onVertexMoved,
    this.onVertexInserted,
    this.onVertexDeleted,
    this.onVertexSelected,
  });

  @override
  State<StudioInteractiveCanvas> createState() => _StudioInteractiveCanvasState();
}

class _StudioInteractiveCanvasState extends State<StudioInteractiveCanvas> {
  final TransformationController _transformController = TransformationController();
  Size _imageNaturalSize = const Size(1000, 1000);

  // Interaction State
  int? _activeDraggingIndex;
  Offset? _touchFocalPoint;
  Offset? _liveCursorScreenPos;
  Offset? _dragStartScreenPos;
  Offset? _dragCurrentScreenPos;

  @override
  void initState() {
    super.initState();
    _resolveImageDimensions();
  }

  @override
  void didUpdateWidget(StudioInteractiveCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFile.path != widget.imageFile.path) {
      _resolveImageDimensions();
    }
  }

  void _resolveImageDimensions() {
    final file = widget.imageFile;
    if (!file.existsSync()) return;

    final imageProvider = FileImage(file);
    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        if (mounted) {
          setState(() {
            _imageNaturalSize = Size(
              info.image.width.toDouble(),
              info.image.height.toDouble(),
            );
          });
        }
      }, onError: (exception, stackTrace) {
        debugPrint('Image size resolve fallback: $exception');
      }),
    );
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Rect _calculateImageRect(Size canvasSize) {
    final fitted = applyBoxFit(BoxFit.contain, _imageNaturalSize, canvasSize);
    final dw = fitted.destination.width;
    final dh = fitted.destination.height;
    final ox = (canvasSize.width - dw) / 2.0;
    final oy = (canvasSize.height - dh) / 2.0;
    return Rect.fromLTWH(ox, oy, dw, dh);
  }

  Offset _toNorm(Offset screenPos, Rect imageRect) {
    final nx = ((screenPos.dx - imageRect.left) / imageRect.width).clamp(0.005, 0.995);
    final ny = ((screenPos.dy - imageRect.top) / imageRect.height).clamp(0.005, 0.995);
    return Offset(nx, ny);
  }

  int? _findNearestVertex(Offset touchScreenPos, Rect imageRect) {
    if (widget.polygon.isEmpty) return null;
    const double hitRadius = 28.0;

    int? nearest;
    double minDistance = hitRadius;

    for (int i = 0; i < widget.polygon.length; i++) {
      final p = widget.polygon[i];
      final screenX = imageRect.left + (p.dx * imageRect.width);
      final screenY = imageRect.top + (p.dy * imageRect.height);
      final dist = (Offset(screenX, screenY) - touchScreenPos).distance;

      if (dist < minDistance) {
        minDistance = dist;
        nearest = i;
      }
    }
    return nearest;
  }

  int? _findNearestEdge(Offset touchScreenPos, Rect imageRect) {
    if (widget.polygon.length < 3) return null;
    const double hitRadius = 24.0;

    int? bestEdge;
    double minDistance = hitRadius;

    for (int i = 0; i < widget.polygon.length; i++) {
      final p1 = widget.polygon[i];
      final p2 = widget.polygon[(i + 1) % widget.polygon.length];

      final s1 = Offset(imageRect.left + p1.dx * imageRect.width, imageRect.top + p1.dy * imageRect.height);
      final s2 = Offset(imageRect.left + p2.dx * imageRect.width, imageRect.top + p2.dy * imageRect.height);

      final mid = Offset((s1.dx + s2.dx) / 2.0, (s1.dy + s2.dy) / 2.0);
      final dist = (mid - touchScreenPos).distance;

      if (dist < minDistance) {
        minDistance = dist;
        bestEdge = i + 1;
      }
    }
    return bestEdge;
  }

  @override
  Widget build(BuildContext context) {
    final bool isPanZoom = widget.activeTool == StudioTool.panZoom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        final imageRect = _calculateImageRect(canvasSize);

        final canvasContent = Stack(
          fit: StackFit.expand,
          children: [
            // Base Image clamped with exact aspect-fit positioning
            Positioned.fromRect(
              rect: imageRect,
              child: widget.imageFile.existsSync()
                  ? Image.file(
                      widget.imageFile,
                      fit: BoxFit.fill,
                    )
                  : Container(
                      color: const Color(0xFFF3EDE6),
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.black26),
                      ),
                    ),
            ),

            // Polygon, Bounding Box, SAM Prompts, Drag Preview Overlay
            CustomPaint(
              size: canvasSize,
              painter: _StudioCanvasPainter(
                imageRect: imageRect,
                polygon: widget.polygon,
                bbox: widget.bbox,
                classColor: widget.classColor,
                classLabel: widget.classLabel,
                activeTool: widget.activeTool,
                samPromptPoints: widget.samPromptPoints,
                selectedVertexIndex: _activeDraggingIndex ?? widget.selectedVertexIndex,
                dragStart: _dragStartScreenPos,
                dragCurrent: _dragCurrentScreenPos,
                cursorPos: _liveCursorScreenPos,
                imagePixelSize: _imageNaturalSize,
                isLayerVisible: widget.isLayerVisible,
                layerOpacity: widget.layerOpacity,
                isLayerLocked: widget.isLayerLocked,
              ),
            ),
          ],
        );

        Widget gestureWrapped = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTapDown: (details) {
            if (widget.isLayerLocked) return;
            if (widget.activeTool == StudioTool.vertexEdit) {
              final idx = _findNearestVertex(details.localPosition, imageRect);
              if (idx != null) {
                widget.onVertexDeleted?.call(idx);
              }
            } else if (widget.activeTool == StudioTool.polygon) {
              widget.onPolygonClosed?.call();
            }
          },
          onTapUp: (details) {
            final touchPos = details.localPosition;
            final norm = _toNorm(touchPos, imageRect);

            if (widget.activeTool == StudioTool.samPoints) {
              widget.onSamPointTapped?.call(norm);
            } else if (widget.activeTool == StudioTool.polygon) {
              if (widget.isLayerLocked) return;
              // Check if tapped near first vertex to close
              if (widget.polygon.length >= 3) {
                final first = widget.polygon.first;
                final firstScreen = Offset(
                  imageRect.left + first.dx * imageRect.width,
                  imageRect.top + first.dy * imageRect.height,
                );
                if ((firstScreen - touchPos).distance <= 26.0) {
                  widget.onPolygonClosed?.call();
                  return;
                }
              }
              widget.onPolygonVertexAdded?.call(norm);
            } else if (widget.activeTool == StudioTool.vertexEdit) {
              if (widget.isLayerLocked) return;
              final tappedIdx = _findNearestVertex(touchPos, imageRect);
              if (tappedIdx != null) {
                widget.onVertexSelected?.call(tappedIdx);
              } else {
                // Check if tapped edge midpoint to insert
                final edgeIdx = _findNearestEdge(touchPos, imageRect);
                if (edgeIdx != null) {
                  widget.onVertexInserted?.call(edgeIdx, norm);
                } else {
                  widget.onVertexSelected?.call(null);
                }
              }
            }
          },
          onPanStart: (details) {
            if (widget.isLayerLocked) return;
            final touchPos = details.localPosition;

            if (widget.activeTool == StudioTool.smartBox || widget.activeTool == StudioTool.boundingBox) {
              setState(() {
                _dragStartScreenPos = touchPos;
                _dragCurrentScreenPos = touchPos;
              });
            } else if (widget.activeTool == StudioTool.vertexEdit) {
              final idx = _findNearestVertex(touchPos, imageRect);
              if (idx != null) {
                setState(() {
                  _activeDraggingIndex = idx;
                  _touchFocalPoint = touchPos;
                });
                widget.onVertexSelected?.call(idx);
              }
            }
          },
          onPanUpdate: (details) {
            final touchPos = details.localPosition;

            if (widget.activeTool == StudioTool.smartBox || widget.activeTool == StudioTool.boundingBox) {
              setState(() {
                _dragCurrentScreenPos = touchPos;
              });
            } else if (widget.activeTool == StudioTool.vertexEdit && _activeDraggingIndex != null) {
              setState(() {
                _touchFocalPoint = touchPos;
              });
              final norm = _toNorm(touchPos, imageRect);
              widget.onVertexMoved?.call(_activeDraggingIndex!, norm);
            } else if (widget.activeTool == StudioTool.polygon) {
              setState(() {
                _liveCursorScreenPos = touchPos;
              });
            }
          },
          onPanEnd: (_) {
            if ((widget.activeTool == StudioTool.smartBox || widget.activeTool == StudioTool.boundingBox) &&
                _dragStartScreenPos != null &&
                _dragCurrentScreenPos != null) {
              final p1 = _toNorm(_dragStartScreenPos!, imageRect);
              final p2 = _toNorm(_dragCurrentScreenPos!, imageRect);

              final normBox = Rect.fromLTRB(
                math.min(p1.dx, p2.dx),
                math.min(p1.dy, p2.dy),
                math.max(p1.dx, p2.dx),
                math.max(p1.dy, p2.dy),
              );

              if (normBox.width >= 0.03 && normBox.height >= 0.03) {
                if (widget.activeTool == StudioTool.smartBox) {
                  widget.onSmartBoxDrawn?.call(normBox);
                } else {
                  widget.onBoundingBoxDrawn?.call(normBox);
                }
              }

              setState(() {
                _dragStartScreenPos = null;
                _dragCurrentScreenPos = null;
              });
            } else if (widget.activeTool == StudioTool.vertexEdit) {
              setState(() {
                _activeDraggingIndex = null;
                _touchFocalPoint = null;
              });
            }
          },
          child: canvasContent,
        );

        return Stack(
          children: [
            // If Pan/Zoom mode is active, wrap in InteractiveViewer
            if (isPanZoom)
              InteractiveViewer(
                transformationController: _transformController,
                minScale: 1.0,
                maxScale: 5.0,
                child: canvasContent,
              )
            else
              gestureWrapped,

            // Magnifier Loupe above touch during vertex editing
            if (_activeDraggingIndex != null && _touchFocalPoint != null)
              StudioMagnifierLoupe(
                focalPoint: _touchFocalPoint!,
                scale: 2.2,
                child: canvasContent,
              ),
          ],
        );
      },
    );
  }
}

/// CustomPainter rendering annotations, BBox, SAM Prompts, and live previews
class _StudioCanvasPainter extends CustomPainter {
  final Rect imageRect;
  final List<Offset> polygon;
  final Rect? bbox;
  final Color classColor;
  final String? classLabel;
  final StudioTool activeTool;
  final List<SamPromptPoint> samPromptPoints;
  final int? selectedVertexIndex;
  final Offset? dragStart;
  final Offset? dragCurrent;
  final Offset? cursorPos;
  final Size imagePixelSize;
  final bool isLayerVisible;
  final double layerOpacity;
  final bool isLayerLocked;

  _StudioCanvasPainter({
    required this.imageRect,
    required this.polygon,
    this.bbox,
    required this.classColor,
    this.classLabel,
    required this.activeTool,
    required this.samPromptPoints,
    this.selectedVertexIndex,
    this.dragStart,
    this.dragCurrent,
    this.cursorPos,
    required this.imagePixelSize,
    required this.isLayerVisible,
    required this.layerOpacity,
    required this.isLayerLocked,
  });

  Offset _toScreen(Offset norm) => Offset(
        imageRect.left + (norm.dx * imageRect.width),
        imageRect.top + (norm.dy * imageRect.height),
      );

  Rect _toScreenRect(Rect norm) => Rect.fromLTRB(
        imageRect.left + (norm.left * imageRect.width),
        imageRect.top + (norm.top * imageRect.height),
        imageRect.left + (norm.right * imageRect.width),
        imageRect.top + (norm.bottom * imageRect.height),
      );

  @override
  void paint(Canvas canvas, Size size) {
    // If layer visibility is turned OFF, only draw live drag previews and SAM points
    if (isLayerVisible) {
      // 1. Draw Bounding Box Guideline (Subtle)
      if (bbox != null) {
        final screenBox = _toScreenRect(bbox!);

        final boxPaint = Paint()
          ..color = classColor.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawRRect(
          RRect.fromRectAndRadius(screenBox, const Radius.circular(8)),
          boxPaint,
        );

        // Label Header Pill (Top-Left of box)
        if (classLabel != null && classLabel!.isNotEmpty) {
          final lockSuffix = isLayerLocked ? ' 🔒' : '';
          final textSpan = TextSpan(
            text: '${classLabel!.replaceAll('_', ' ').toUpperCase()}$lockSuffix',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          );
          final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
          final pillRect = Rect.fromLTWH(
            screenBox.left,
            math.max(imageRect.top, screenBox.top - 20),
            tp.width + 14,
            18,
          );

          final pillPaint = Paint()..color = classColor;
          canvas.drawRRect(RRect.fromRectAndRadius(pillRect, const Radius.circular(5)), pillPaint);
          tp.paint(canvas, Offset(pillRect.left + 7, pillRect.top + 2));
        }

        // Dimensions Pill (Bottom-Right of box)
        final int pxW = (bbox!.width * imagePixelSize.width).round();
        final int pxH = (bbox!.height * imagePixelSize.height).round();
        final dimSpan = TextSpan(
          text: '$pxW × $pxH',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 8.5,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        );
        final dimTp = TextPainter(text: dimSpan, textDirection: TextDirection.ltr)..layout();
        final dimPillRect = Rect.fromLTWH(
          screenBox.right - dimTp.width - 10,
          math.min(imageRect.bottom - 16, screenBox.bottom + 4),
          dimTp.width + 8,
          15,
        );
        final dimPaint = Paint()..color = Colors.black87;
        canvas.drawRRect(RRect.fromRectAndRadius(dimPillRect, const Radius.circular(4)), dimPaint);
        dimTp.paint(canvas, Offset(dimPillRect.left + 4, dimPillRect.top + 1.5));
      }

      // 2. Draw Polygon Contour & Shading
      if (polygon.length >= 3) {
        final path = Path();
        final firstScreen = _toScreen(polygon.first);
        path.moveTo(firstScreen.dx, firstScreen.dy);

        for (int i = 1; i < polygon.length; i++) {
          final pt = _toScreen(polygon[i]);
          path.lineTo(pt.dx, pt.dy);
        }
        path.close();

        // Translucent shaded fill with user-controlled opacity
        final fillPaint = Paint()
          ..color = classColor.withValues(alpha: layerOpacity)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);

        // Solid Contour Stroke
        final strokePaint = Paint()
          ..color = classColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, strokePaint);
      }

      // 3. Draw Polygon Vertices & Edge Midpoints (in VertexEdit & Polygon tools)
      if (activeTool == StudioTool.vertexEdit || activeTool == StudioTool.polygon) {
        for (int i = 0; i < polygon.length; i++) {
          final screenPos = _toScreen(polygon[i]);
          final bool isSelected = (i == selectedVertexIndex);
          final bool isFirst = (i == 0);

          // Halo if selected
          if (isSelected) {
            canvas.drawCircle(
              screenPos,
              12.0,
              Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.40),
            );
          }

          // Distinct gold ring for start vertex
          if (isFirst && activeTool == StudioTool.polygon) {
            canvas.drawCircle(
              screenPos,
              9.0,
              Paint()
                ..color = const Color(0xFFD4AF37)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.0,
            );
          }

          // Vertex Circle Handle
          canvas.drawCircle(
            screenPos,
            isSelected ? 7.0 : 5.5,
            Paint()..color = isSelected ? const Color(0xFFD4AF37) : classColor,
          );
          canvas.drawCircle(
            screenPos,
            isSelected ? 7.0 : 5.5,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8,
          );

          // Edge Midpoint Indicator (VertexEdit tool: allows 1-tap vertex insertion)
          if (activeTool == StudioTool.vertexEdit && polygon.length >= 3 && !isLayerLocked) {
            final nextPt = _toScreen(polygon[(i + 1) % polygon.length]);
            final midScreen = Offset((screenPos.dx + nextPt.dx) / 2.0, (screenPos.dy + nextPt.dy) / 2.0);

            canvas.drawCircle(
              midScreen,
              3.5,
              Paint()..color = Colors.white.withValues(alpha: 0.65),
            );
            canvas.drawCircle(
              midScreen,
              3.5,
              Paint()
                ..color = classColor
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0,
            );
          }
        }
      }
    }

    // 4. Draw Rubberband Line (in Manual Polygon tool)
    if (activeTool == StudioTool.polygon && polygon.isNotEmpty && cursorPos != null) {
      final lastScreen = _toScreen(polygon.last);
      final rubberPaint = Paint()
        ..color = classColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      canvas.drawLine(lastScreen, cursorPos!, rubberPaint);
    }

    // 5. Draw SAM Interactive Prompt Points (+ Green, - Red)
    for (final pt in samPromptPoints) {
      final screenPos = _toScreen(pt.normalizedPoint);
      final bool isPos = pt.isPositive;
      final Color markColor = isPos ? const Color(0xFF10B981) : const Color(0xFFEF4444);

      // Outer Glow
      canvas.drawCircle(
        screenPos,
        14.0,
        Paint()..color = markColor.withValues(alpha: 0.30),
      );

      // Solid Circle
      canvas.drawCircle(
        screenPos,
        8.0,
        Paint()..color = markColor,
      );
      canvas.drawCircle(
        screenPos,
        8.0,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // Label (+ or -)
      final labelSpan = TextSpan(
        text: isPos ? '+' : '−',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      );
      final tp = TextPainter(text: labelSpan, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(screenPos.dx - (tp.width / 2.0), screenPos.dy - (tp.height / 2.0)));
    }

    // 6. Live Bounding Box / Box SAM Dragging Preview
    if (dragStart != null && dragCurrent != null) {
      final rect = Rect.fromPoints(dragStart!, dragCurrent!);

      // Translucent Fill
      final previewFill = Paint()
        ..color = (activeTool == StudioTool.smartBox ? const Color(0xFF7C3AED) : const Color(0xFFD4AF37))
            .withValues(alpha: 0.16)
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, previewFill);

      // Dashed Stroke
      final previewStroke = Paint()
        ..color = activeTool == StudioTool.smartBox ? const Color(0xFF7C3AED) : const Color(0xFFD4AF37)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(rect, previewStroke);

      // Live size tooltip
      final int liveW = (rect.width * (imagePixelSize.width / imageRect.width)).round().abs();
      final int liveH = (rect.height * (imagePixelSize.height / imageRect.height)).round().abs();
      final text = activeTool == StudioTool.smartBox ? '⚡ SAM Box: $liveW × $liveH' : '$liveW × $liveH';

      final tipSpan = TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.0,
          fontWeight: FontWeight.bold,
        ),
      );
      final tipTp = TextPainter(text: tipSpan, textDirection: TextDirection.ltr)..layout();
      final tipRect = Rect.fromLTWH(rect.left, math.max(0, rect.top - 20), tipTp.width + 12, 17);

      final tipPaint = Paint()
        ..color = activeTool == StudioTool.smartBox ? const Color(0xFF7C3AED) : const Color(0xFFD4AF37);
      canvas.drawRRect(RRect.fromRectAndRadius(tipRect, const Radius.circular(4)), tipPaint);
      tipTp.paint(canvas, Offset(tipRect.left + 6, tipRect.top + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _StudioCanvasPainter oldDelegate) {
    return oldDelegate.polygon != polygon ||
        oldDelegate.bbox != bbox ||
        oldDelegate.classColor != classColor ||
        oldDelegate.classLabel != classLabel ||
        oldDelegate.activeTool != activeTool ||
        oldDelegate.samPromptPoints != samPromptPoints ||
        oldDelegate.selectedVertexIndex != selectedVertexIndex ||
        oldDelegate.dragStart != dragStart ||
        oldDelegate.dragCurrent != dragCurrent ||
        oldDelegate.cursorPos != cursorPos ||
        oldDelegate.imageRect != imageRect ||
        oldDelegate.isLayerVisible != isLayerVisible ||
        oldDelegate.layerOpacity != layerOpacity ||
        oldDelegate.isLayerLocked != isLayerLocked;
  }
}
