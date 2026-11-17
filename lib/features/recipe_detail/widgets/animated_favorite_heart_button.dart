import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Tombol favorit beranimasi partikel cinta & spring bounce.
/// Tetap berwarna pink-merah menyala saat aktif hingga pengguna mengetuk lagi
/// untuk menghapus dari daftar favorit.
class AnimatedFavoriteHeartButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final String? tooltip;
  final double size;

  const AnimatedFavoriteHeartButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.tooltip,
    this.size = 40,
  });

  @override
  State<AnimatedFavoriteHeartButton> createState() =>
      _AnimatedFavoriteHeartButtonState();
}

class _AnimatedFavoriteHeartButtonState
    extends State<AnimatedFavoriteHeartButton>
    with SingleTickerProviderStateMixin {
  static const Color _pinkRedPrimary = Color(0xFFFF1E56);
  static const Color _pinkRedGlow = Color(0xFFFF4D7D);

  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _burstAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.38)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.38, end: 0.90)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.90, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 23,
      ),
    ]).animate(_controller);

    _burstAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedFavoriteHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isFavorite && widget.isFavorite) {
      _controller.forward(from: 0);
    } else if (oldWidget.isFavorite && !widget.isFavorite) {
      _controller.animateBack(0, duration: const Duration(milliseconds: 180));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isFavorite) {
      _controller.forward(from: 0);
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final isFav = widget.isFavorite;
    final tooltipText =
        widget.tooltip ?? (isFav ? 'Hapus dari Favorit' : 'Simpan ke Favorit');

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Expanding ring & mini heart burst when favorited
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _burstAnim,
              builder: (context, _) {
                final t = _burstAnim.value;
                if (t <= 0.01 || t >= 0.99 || !isFav) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  size: Size(widget.size * 2.1, widget.size * 2.1),
                  painter: _HeartBurstPainter(
                    progress: t,
                    color: _pinkRedGlow,
                    accentColor: const Color(0xFFFF85A1),
                  ),
                );
              },
            ),
          ),

          // Persistent Pink-Red Glowing Circle + Animated Heart Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFav
                  ? const Color(0xFF2C0B17).withValues(alpha: 0.78)
                  : Colors.black.withValues(alpha: 0.35),
              border: Border.all(
                color: isFav
                    ? _pinkRedGlow
                    : Colors.white.withValues(alpha: 0.16),
                width: isFav ? 1.5 : 1.0,
              ),
              boxShadow: isFav
                  ? [
                      BoxShadow(
                        color: _pinkRedPrimary.withValues(alpha: 0.45),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: tooltipText,
              onPressed: _handleTap,
              icon: AnimatedBuilder(
                animation: _scaleAnim,
                builder: (context, child) => Transform.scale(
                  scale: isFav ? _scaleAnim.value : 1.0,
                  child: child,
                ),
                child: Icon(
                  isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: isFav ? const Color(0xFFFF2E63) : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartBurstPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color accentColor;

  _HeartBurstPainter({
    required this.progress,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    // Expanding pink-red pulse ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * (1.0 - progress * 0.6);
    canvas.drawCircle(center, (size.width * 0.24) + (size.width * 0.26 * progress), ringPaint);

    // 6 mini floating sparks / hearts
    const int count = 6;
    for (int i = 0; i < count; i++) {
      final angle = (math.pi * 2 / count) * i - (math.pi / 2);
      final distance = (size.width * 0.18) + (size.width * 0.30 * progress);
      final pos = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      final radius = (3.4 * (1.0 - progress * 0.55)).clamp(0.8, 3.6);
      final particlePaint = Paint()
        ..color = (i.isEven ? color : accentColor).withValues(alpha: opacity * 0.9);
      canvas.drawCircle(pos, radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
