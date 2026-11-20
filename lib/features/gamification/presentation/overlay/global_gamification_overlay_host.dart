import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/gamification_reward_queue_controller.dart';
import '../models/gamification_reward_delta.dart';
import 'exp_orb_bezier_painter.dart';

/// Root-level 120 FPS Floating Profile EXP Animation Host.
/// Mounted in MaterialApp.router(builder: ...) so EXP rewards animate above any screen.
class GlobalGamificationOverlayHost extends ConsumerStatefulWidget {
  final Widget child;
  const GlobalGamificationOverlayHost({super.key, required this.child});

  @override
  ConsumerState<GlobalGamificationOverlayHost> createState() =>
      _GlobalGamificationOverlayHostState();
}

class _GlobalGamificationOverlayHostState
    extends ConsumerState<GlobalGamificationOverlayHost>
    with TickerProviderStateMixin {
  GamificationRewardDelta? _activeDelta;
  late final AnimationController _bannerCtrl;
  late final AnimationController _orbCtrl;
  late final AnimationController _barCtrl;
  final GlobalKey _barKey = GlobalKey();
  bool _firedHapticBurst = false;

  @override
  void initState() {
    super.initState();
    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    _orbCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  Future<void> _playReward(GamificationRewardDelta delta) async {
    setState(() {
      _activeDelta = delta;
      _firedHapticBurst = false;
    });
    _bannerCtrl.reset();
    _orbCtrl.reset();
    _barCtrl.reset();

    await _bannerCtrl.forward();
    if (!mounted) return;

    unawaited(_orbCtrl.forward());
    await Future.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    HapticFeedback.selectionClick();
    await _barCtrl.forward();
    if (delta.didLevelUp && !_firedHapticBurst) {
      _firedHapticBurst = true;
      HapticFeedback.heavyImpact();
    }

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    await _bannerCtrl.reverse();
    if (!mounted) return;

    setState(() => _activeDelta = null);
    ref.read(gamificationRewardQueueProvider.notifier).popFront();
  }

  Offset _resolveBarTip(Size screenSize) {
    final ctx = _barKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final topLeft = box.localToGlobal(Offset.zero);
        final ratio = _currentBarRatio();
        return Offset(
          topLeft.dx + box.size.width * ratio.clamp(0.05, 0.98),
          topLeft.dy + box.size.height * 0.5,
        );
      }
    }
    return Offset(screenSize.width * 0.55, 88);
  }

  double _currentBarRatio() {
    final d = _activeDelta;
    if (d == null) return 0.0;
    final t = Curves.easeOutCubic.transform(_barCtrl.value);
    if (!d.didLevelUp) {
      return d.progressRatioBefore +
          (d.progressRatioAfter - d.progressRatioBefore) * t;
    }
    if (t < 0.5) {
      final seg = t / 0.5;
      return d.progressRatioBefore + (1.0 - d.progressRatioBefore) * seg;
    }
    final seg = (t - 0.5) / 0.5;
    return d.progressRatioAfter * seg;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<GamificationRewardDelta>>(
      gamificationRewardQueueProvider,
      (prev, next) {
        if (_activeDelta == null && next.isNotEmpty) {
          _playReward(next.first);
        }
      },
    );

    final delta = _activeDelta;
    if (delta == null) return widget.child;

    final user = ref.watch(authControllerProvider).value;
    final displayName = user?.fullName ?? 'Barista Coffee Labs';
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _orbCtrl,
                builder: (context, _) => CustomPaint(
                  painter: ExpOrbBezierPainter(
                    progress: _orbCtrl.value,
                    startCenter: Offset(size.width * 0.5, size.height * 0.55),
                    targetTip: _resolveBarTip(size),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: SafeArea(
            bottom: false,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOutBack),
              ),
              child: Material(
                color: Colors.transparent,
                child: AnimatedBuilder(
                  animation: _barCtrl,
                  builder: (context, _) {
                    final t = Curves.easeOutCubic.transform(_barCtrl.value);
                    final showNewLevel = delta.didLevelUp && t >= 0.5;
                    final displayLevel =
                        showNewLevel ? delta.levelAfter : delta.levelBefore;
                    final displayRank =
                        showNewLevel ? delta.rankAfter : delta.rankBefore;
                    final displayXp = (delta.xpBefore +
                            (delta.xpGained * t).round())
                        .clamp(delta.xpBefore, delta.xpAfter);
                    final ratio = _currentBarRatio();

                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: showNewLevel
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFF2563EB).withValues(alpha: 0.25),
                          width: showNewLevel ? 1.8 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2563EB),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Lv.$displayLevel',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        delta.sourceLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '+${delta.xpGained} EXP',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$displayName • ✨ $displayRank',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        key: _barKey,
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: ratio.clamp(0.0, 1.0),
                                          minHeight: 7,
                                          backgroundColor:
                                              const Color(0xFFE2E8F0),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Color(0xFF2563EB)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$displayXp EXP',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
