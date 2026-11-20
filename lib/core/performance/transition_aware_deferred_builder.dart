import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Mencegah freeze saat navigasi (push/pop) dengan menunda pembangunan
/// widget berat (Chart, Kamera, Grid besar, Rive, 3D) sampai animasi transisi
/// rute selesai 100%.
class TransitionAwareDeferredBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) heavyBuilder;
  final Widget? lightweightPlaceholder;
  final bool enableInTestEnv;

  const TransitionAwareDeferredBuilder({
    super.key,
    required this.heavyBuilder,
    this.lightweightPlaceholder,
    this.enableInTestEnv = false,
  });

  @override
  State<TransitionAwareDeferredBuilder> createState() =>
      _TransitionAwareDeferredBuilderState();
}

class _TransitionAwareDeferredBuilderState
    extends State<TransitionAwareDeferredBuilder> {
  Animation<double>? _routeAnimation;
  bool _isTransitionCompleted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!widget.enableInTestEnv &&
        !kIsWeb &&
        Platform.environment.containsKey('FLUTTER_TEST')) {
      _isTransitionCompleted = true;
      return;
    }

    final modalRoute = ModalRoute.of(context);
    final newAnimation = modalRoute?.animation;

    if (modalRoute == null || newAnimation == null) {
      _isTransitionCompleted = true;
      return;
    }

    if (_routeAnimation != newAnimation) {
      _routeAnimation?.removeStatusListener(_onAnimationStatusChanged);
      _routeAnimation = newAnimation;
      _routeAnimation!.addStatusListener(_onAnimationStatusChanged);
    }

    // Pada Frame-0 Navigator.push, Flutter merender route dalam status offstage dengan
    // kAlwaysCompleteAnimation untuk kalkulasi Hero. Tahan heavyBuilder selama offstage!
    if (modalRoute.offstage) {
      return;
    }

    if (newAnimation.isCompleted) {
      _isTransitionCompleted = true;
    }
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        !_isTransitionCompleted &&
        mounted) {
      final modalRoute = ModalRoute.of(context);
      if (modalRoute != null && modalRoute.offstage) return;
      // Jadwalkan pada frame idle berikutnya agar akhir animasi tidak tersendat.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isTransitionCompleted = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onAnimationStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTransitionCompleted) {
      return RepaintBoundary(child: widget.heavyBuilder(context));
    }
    return widget.lightweightPlaceholder ?? const SizedBox.expand();
  }
}
