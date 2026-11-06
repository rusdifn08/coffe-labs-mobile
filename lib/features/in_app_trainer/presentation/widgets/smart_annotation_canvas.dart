import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/smart_tap_annotator_service.dart';

/// Canvas interaktif ala Roboflow Smart Annotation:
/// Pengguna cukup mengetuk (tap) bungkusan kopi untuk menghasilkan Bounding Box otomatis,
/// dan dapat menggeser 4 titik sudut untuk menyesuaikan area potongan kemasan.
class SmartAnnotationCanvas extends StatefulWidget {
  final File imageFile;
  final Rect? currentBox;
  final ValueChanged<Rect> onBoxChanged;
  final VoidCallback? onSnapped;

  const SmartAnnotationCanvas({
    super.key,
    required this.imageFile,
    required this.currentBox,
    required this.onBoxChanged,
    this.onSnapped,
  });

  @override
  State<SmartAnnotationCanvas> createState() => _SmartAnnotationCanvasState();
}

class _SmartAnnotationCanvasState extends State<SmartAnnotationCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;
  bool _isSnapping = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _pulseScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOutBack),
    );
    _pulseCtrl.forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap(TapUpDetails details, Size renderSize) async {
    if (renderSize.width <= 0 || renderSize.height <= 0) return;

    final normX = (details.localPosition.dx / renderSize.width).clamp(0.0, 1.0);
    final normY = (details.localPosition.dy / renderSize.height).clamp(0.0, 1.0);

    setState(() => _isSnapping = true);
    HapticFeedback.mediumImpact();

    try {
      final snapped = await SmartTapAnnotatorService.snapBoundingBox(
        imageFile: widget.imageFile,
        tapNormalized: Offset(normX, normY),
      );

      widget.onBoxChanged(snapped);
      widget.onSnapped?.call();
      _pulseCtrl.forward(from: 0.0);
    } catch (e) {
      debugPrint('Snap error: $e');
    } finally {
      if (mounted) setState(() => _isSnapping = false);
    }
  }

  void _updateHandle({
    required int handleIndex, // 0: Top-Left, 1: Top-Right, 2: Bottom-Left, 3: Bottom-Right
    required DragUpdateDetails details,
    required Size renderSize,
  }) {
    final current = widget.currentBox ?? const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);
    final deltaX = details.delta.dx / renderSize.width;
    final deltaY = details.delta.dy / renderSize.height;

    double left = current.left;
    double top = current.top;
    double right = current.right;
    double bottom = current.bottom;

    const minSize = 0.08;

    switch (handleIndex) {
      case 0: // Top-Left
        left = (left + deltaX).clamp(0.0, right - minSize);
        top = (top + deltaY).clamp(0.0, bottom - minSize);
        break;
      case 1: // Top-Right
        right = (right + deltaX).clamp(left + minSize, 1.0);
        top = (top + deltaY).clamp(0.0, bottom - minSize);
        break;
      case 2: // Bottom-Left
        left = (left + deltaX).clamp(0.0, right - minSize);
        bottom = (bottom + deltaY).clamp(top + minSize, 1.0);
        break;
      case 3: // Bottom-Right
        right = (right + deltaX).clamp(left + minSize, 1.0);
        bottom = (bottom + deltaY).clamp(top + minSize, 1.0);
        break;
    }

    widget.onBoxChanged(Rect.fromLTRB(left, top, right, bottom));
  }

  @override
  Widget build(BuildContext context) {
    final box = widget.currentBox ?? const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);

    return LayoutBuilder(
      builder: (context, constraints) {
        final renderW = constraints.maxWidth;
        final renderH = constraints.maxHeight;

        final pixelLeft = box.left * renderW;
        final pixelTop = box.top * renderH;
        final pixelW = (box.right - box.left) * renderW;
        final pixelH = (box.bottom - box.top) * renderH;

        return Stack(
          children: [
            // 1. Gambar Utama dengan Gesture Tap untuk Smart Click-to-Box
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onTapUp: (details) => _handleTap(details, Size(renderW, renderH)),
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.cover,
                    width: renderW,
                    height: renderH,
                  ),
                ),
              ),
            ),

            // 2. Dim Scrim di luar Bounding Box untuk memfokuskan produk kopi
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ScrimOverlayPainter(
                    activeRect: Rect.fromLTWH(pixelLeft, pixelTop, pixelW, pixelH),
                  ),
                ),
              ),
            ),

            // 3. Glowing Neon-Gold Bounding Box
            Positioned(
              left: pixelLeft,
              top: pixelTop,
              width: pixelW,
              height: pixelH,
              child: ScaleTransition(
                scale: _pulseScale,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Label Badge di pojok kiri atas kotak
                      Positioned(
                        left: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.center_focus_strong, size: 10, color: Colors.black),
                              SizedBox(width: 3),
                              Text(
                                'COFFEE BAG',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Empat Titik Sudut Draggable Handles
            // Top-Left Handle
            Positioned(
              left: pixelLeft - 12,
              top: pixelTop - 12,
              child: _buildHandle(
                onPanUpdate: (d) => _updateHandle(
                  handleIndex: 0,
                  details: d,
                  renderSize: Size(renderW, renderH),
                ),
              ),
            ),

            // Top-Right Handle
            Positioned(
              left: pixelLeft + pixelW - 12,
              top: pixelTop - 12,
              child: _buildHandle(
                onPanUpdate: (d) => _updateHandle(
                  handleIndex: 1,
                  details: d,
                  renderSize: Size(renderW, renderH),
                ),
              ),
            ),

            // Bottom-Left Handle
            Positioned(
              left: pixelLeft - 12,
              top: pixelTop + pixelH - 12,
              child: _buildHandle(
                onPanUpdate: (d) => _updateHandle(
                  handleIndex: 2,
                  details: d,
                  renderSize: Size(renderW, renderH),
                ),
              ),
            ),

            // Bottom-Right Handle
            Positioned(
              left: pixelLeft + pixelW - 12,
              top: pixelTop + pixelH - 12,
              child: _buildHandle(
                onPanUpdate: (d) => _updateHandle(
                  handleIndex: 3,
                  details: d,
                  renderSize: Size(renderW, renderH),
                ),
              ),
            ),

            // 5. Loading Snapping Indicator
            if (_isSnapping)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF59E0B),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),

            // 6. Petunjuk Cerdas di bagian bawah canvas
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, size: 14, color: Color(0xFFF59E0B)),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Ketuk bungkusan kopi untuk Smart-Snap • Geser sudut untuk merapikan',
                        style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHandle({required GestureDragUpdateCallback onPanUpdate}) {
    return GestureDetector(
      onPanUpdate: onPanUpdate,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter untuk menggelapkan area di luar bounding box
class _ScrimOverlayPainter extends CustomPainter {
  final Rect activeRect;

  const _ScrimOverlayPainter({required this.activeRect});

  @override
  void paint(Canvas canvas, Size size) {
    final background = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()..addRRect(RRect.fromRectAndRadius(activeRect, const Radius.circular(8)));
    final combined = Path.combine(PathOperation.difference, background, cutout);

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.42)
      ..style = PaintingStyle.fill;

    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(covariant _ScrimOverlayPainter oldDelegate) =>
      oldDelegate.activeRect != activeRect;
}
