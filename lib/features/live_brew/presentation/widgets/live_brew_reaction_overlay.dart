import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../controllers/live_brew_mirror_controller.dart';

/// Floating real-time audience reaction particles (`👏`, `☕`, `🔥`, `❤️`)
/// rendered over `BrewTimerScreen` and `BrewerLiveStudioTab` whenever a viewer
/// taps a reaction on the Live Brew landing page or mobile viewer.
class LiveBrewReactionOverlay extends ConsumerStatefulWidget {
  const LiveBrewReactionOverlay({super.key});

  @override
  ConsumerState<LiveBrewReactionOverlay> createState() =>
      _LiveBrewReactionOverlayState();
}

class _LiveBrewReactionOverlayState
    extends ConsumerState<LiveBrewReactionOverlay> {
  final List<_ActiveReactionBubble> _bubbles = [];
  int _lastSeenReactionId = 0;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(liveBrewMirrorProvider).recentReactions;
    if (existing.isNotEmpty) {
      _lastSeenReactionId = existing.last.id;
    }
  }

  void _spawnBubble(IncomingLiveReaction reaction) {
    final seed = reaction.id * 37;
    final horizontalFraction = 0.12 + ((seed % 76) / 100.0);
    final bubble = _ActiveReactionBubble(
      id: reaction.id,
      emoji: reaction.emoji,
      horizontalFraction: horizontalFraction,
    );
    setState(() {
      _bubbles.add(bubble);
      if (_bubbles.length > 16) {
        _bubbles.removeAt(0);
      }
    });
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      setState(() {
        _bubbles.removeWhere((b) => b.id == bubble.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<IncomingLiveReaction>>(
      liveBrewMirrorProvider.select((s) => s.recentReactions),
      (prev, next) {
        for (final r in next) {
          if (r.id > _lastSeenReactionId) {
            _lastSeenReactionId = r.id;
            _spawnBubble(r);
          }
        }
      },
    );

    if (_bubbles.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: _bubbles.map((b) {
              return _FloatingEmojiBubble(
                key: ValueKey(b.id),
                emoji: b.emoji,
                left: constraints.maxWidth * b.horizontalFraction,
                startBottom: 96,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _ActiveReactionBubble {
  final int id;
  final String emoji;
  final double horizontalFraction;

  const _ActiveReactionBubble({
    required this.id,
    required this.emoji,
    required this.horizontalFraction,
  });
}

class _FloatingEmojiBubble extends StatefulWidget {
  final String emoji;
  final double left;
  final double startBottom;

  const _FloatingEmojiBubble({
    super.key,
    required this.emoji,
    required this.left,
    required this.startBottom,
  });

  @override
  State<_FloatingEmojiBubble> createState() => _FloatingEmojiBubbleState();
}

class _FloatingEmojiBubbleState extends State<_FloatingEmojiBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rise;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _rise = Tween<double>(begin: 0, end: 210).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.25).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 70),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final sway = math.sin(_ctrl.value * math.pi * 2.5) * 14.0;
        return Positioned(
          left: (widget.left + sway).clamp(8.0, double.infinity),
          bottom: widget.startBottom + _rise.value,
          child: Opacity(
            opacity: _opacity.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderWarm),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          widget.emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

/// Compact glowing green live dot pill shown subtly on `BrewTimerScreen`
/// ONLY while a Live Brew session is broadcasting. Zero animation ticker
/// overhead when Live Brew is inactive.
class LiveBrewActiveStatusPill extends ConsumerWidget {
  final VoidCallback onTap;

  const LiveBrewActiveStatusPill({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(
      liveBrewMirrorProvider.select((s) => s.activeSession),
    );
    if (session == null) return const SizedBox.shrink();

    return _PulsingLivePill(
      viewersCount: session.activeViewersCount,
      cheersCount: session.cheersCount,
      onTap: onTap,
    );
  }
}

class _PulsingLivePill extends StatefulWidget {
  final int viewersCount;
  final int cheersCount;
  final VoidCallback onTap;

  const _PulsingLivePill({
    required this.viewersCount,
    required this.cheersCount,
    required this.onTap,
  });

  @override
  State<_PulsingLivePill> createState() => _PulsingLivePillState();
}

class _PulsingLivePillState extends State<_PulsingLivePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF86EFAC)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, _) => Opacity(
                opacity: 0.35 + (_pulseCtrl.value * 0.65),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${widget.viewersCount} 👁 • ${widget.cheersCount} 👏',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
