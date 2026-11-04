import 'package:flutter/material.dart';

/// Widget Running Text (Marquee) profesional untuk teks nama rank / judul panjang:
/// - Otomatis mengukur lebar teks: Jika muat, tampil statis tanpa animasi (hemat CPU/baterai).
/// - Jika tidak muat (overflow), teks bergulir horizontal secara lembut (smooth auto-scroll).
/// - Memiliki jeda baca di awal (1.8 detik) dan jeda di akhir (1.8 detik).
/// - Dilengkapi soft gradient fade di tepi kanan/kiri agar tampilan elegan & profesional.
class ProfessionalRunningText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double velocity; // Kecepatan gerak (pixel per detik)
  final Duration pauseDuration;
  final Alignment alignment;
  final double fadeWidth;

  const ProfessionalRunningText({
    super.key,
    required this.text,
    this.style,
    this.velocity = 28.0, // 28 px/detik: kecepatan ideal membaca mata manusia
    this.pauseDuration = const Duration(milliseconds: 1800),
    this.alignment = Alignment.centerLeft,
    this.fadeWidth = 14.0,
  });

  @override
  State<ProfessionalRunningText> createState() => _ProfessionalRunningTextState();
}

class _ProfessionalRunningTextState extends State<ProfessionalRunningText>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  AnimationController? _animController;
  Animation<double>? _scrollAnimation;

  double _maxScrollExtent = 0.0;
  bool _isOverflowing = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStartScroll());
  }

  @override
  void didUpdateWidget(covariant ProfessionalRunningText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _stopAnimation();
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStartScroll());
    }
  }

  void _stopAnimation() {
    _animController?.stop();
    _animController?.dispose();
    _animController = null;
    _scrollAnimation = null;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  void _checkAndStartScroll() {
    if (!mounted || _isDisposed) return;
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll > 1.5) {
      if (!_isOverflowing || _maxScrollExtent != maxScroll) {
        setState(() {
          _isOverflowing = true;
          _maxScrollExtent = maxScroll;
        });
      }
      _startMarqueeCycle(maxScroll);
    } else {
      if (_isOverflowing) {
        setState(() {
          _isOverflowing = false;
          _maxScrollExtent = 0.0;
        });
      }
    }
  }

  void _startMarqueeCycle(double maxScroll) async {
    _stopAnimation();
    if (!mounted || _isDisposed) return;

    final scrollDurationSeconds = (maxScroll / widget.velocity).clamp(1.5, 12.0);
    final scrollDuration = Duration(milliseconds: (scrollDurationSeconds * 1000).toInt());

    // Total siklus: Pause Awal + Scroll ke Akhir + Pause Akhir + Return Halus
    final returnDuration = Duration(milliseconds: (scrollDuration.inMilliseconds * 0.4).toInt().clamp(600, 2000));
    final totalCycleDuration = widget.pauseDuration + scrollDuration + widget.pauseDuration + returnDuration;

    _animController = AnimationController(vsync: this, duration: totalCycleDuration);

    final p1 = widget.pauseDuration.inMilliseconds / totalCycleDuration.inMilliseconds;
    final p2 = (widget.pauseDuration + scrollDuration).inMilliseconds / totalCycleDuration.inMilliseconds;
    final p3 = (widget.pauseDuration + scrollDuration + widget.pauseDuration).inMilliseconds / totalCycleDuration.inMilliseconds;

    _scrollAnimation = TweenSequence<double>([
      // 1. Jeda tenang di awal
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: p1 * 100),
      // 2. Gliding halus ke teks paling kanan
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: maxScroll).chain(CurveTween(curve: Curves.easeInOut)),
        weight: (p2 - p1) * 100,
      ),
      // 3. Jeda di akhir agar pengguna selesai membaca
      TweenSequenceItem(tween: ConstantTween<double>(maxScroll), weight: (p3 - p2) * 100),
      // 4. Kembali secara anggun ke awal
      TweenSequenceItem(
        tween: Tween<double>(begin: maxScroll, end: 0.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: (1.0 - p3) * 100,
      ),
    ]).animate(_animController!);

    _scrollAnimation!.addListener(() {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollAnimation!.value);
      }
    });

    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_isDisposed) {
        _animController?.forward(from: 0.0);
      }
    });

    _animController!.forward();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) _checkAndStartScroll();
        });

        Widget content = SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(), // Scroll dikendalikan oleh animasi
          child: Align(
            alignment: widget.alignment,
            child: Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        );

        // Jika teks overflow, tambahkan soft fade mask di tepi kanan
        if (_isOverflowing && widget.fadeWidth > 0) {
          return ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [
                  0.0,
                  (bounds.width - widget.fadeWidth).clamp(0.0, bounds.width) / bounds.width,
                  1.0,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: content,
          );
        }

        return content;
      },
    );
  }
}
