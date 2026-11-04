import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/profile_service.dart';
import '../models/coffee_level.dart';

/// Avatar profil berbentuk kotak modern (squircle / rounded rectangle) dengan border dinamis bercahaya,
/// gradient unik sesuai level 1-10, efek rotasi kilau (shiny aura shimmer), dan dekorasi tingkat tinggi.
class GamifiedAvatar extends StatefulWidget {
  final double radius;
  final String? imagePath;
  final CoffeeLevel level;
  final bool showLevelBadge;
  final VoidCallback? onTap;

  const GamifiedAvatar({
    super.key,
    required this.radius,
    this.imagePath,
    required this.level,
    this.showLevelBadge = true,
    this.onTap,
  });

  @override
  State<GamifiedAvatar> createState() => _GamifiedAvatarState();
}

class _GamifiedAvatarState extends State<GamifiedAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (widget.level.hasShinyAura) {
      _animCtrl.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant GamifiedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.level.hasShinyAura && !_animCtrl.isAnimating) {
      _animCtrl.repeat();
    } else if (!widget.level.hasShinyAura && _animCtrl.isAnimating) {
      _animCtrl.stop();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius;
    final lvl = widget.level;
    final borderWidth = (r * 0.12).clamp(2.5, 4.0);
    final totalSize = (r * 2) + (borderWidth * 2) + 4;
    final outerRadius = (totalSize * 0.28).clamp(10.0, 20.0);
    final innerRadius = (r * 2 * 0.25).clamp(8.0, 16.0);

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: totalSize,
        height: totalSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Glowing Ambient Aura (Kotak rounded shadow)
            AnimatedBuilder(
              animation: _animCtrl,
              builder: (context, _) {
                final pulse = lvl.hasCosmicParticles
                    ? (math.sin(_animCtrl.value * math.pi * 2) * 2.5)
                    : 0.0;

                return Container(
                  width: totalSize - 4,
                  height: totalSize - 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(outerRadius),
                    boxShadow: [
                      BoxShadow(
                        color: lvl.glowColor.withValues(alpha: lvl.hasShinyAura ? 0.40 : 0.22),
                        blurRadius: (8 + (lvl.level * 1.5) + pulse).clamp(6.0, 24.0),
                        spreadRadius: (1.0 + (lvl.level * 0.3) + (pulse * 0.4)).clamp(1.0, 4.5),
                      ),
                      if (lvl.hasCosmicParticles)
                        BoxShadow(
                          color: lvl.accentColor.withValues(alpha: 0.35),
                          blurRadius: 16 + pulse,
                          spreadRadius: 2.0,
                        ),
                    ],
                  ),
                );
              },
            ),

            // 2. Rotating Gradient Border Kotak (Squircle)
            AnimatedBuilder(
              animation: _animCtrl,
              builder: (context, child) {
                final angle = lvl.hasShinyAura ? (_animCtrl.value * math.pi * 2) : (math.pi / 4);
                final alignX = math.cos(angle);
                final alignY = math.sin(angle);

                return Container(
                  width: totalSize - 4,
                  height: totalSize - 4,
                  padding: EdgeInsets.all(borderWidth),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(outerRadius),
                    gradient: LinearGradient(
                      begin: Alignment(alignX, alignY),
                      end: Alignment(-alignX, -alignY),
                      colors: lvl.borderGradient,
                    ),
                  ),
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(innerRadius),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(innerRadius),
                  child: Image(
                    image: ProfileService.getImageProvider(widget.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF3ECE4),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.person_fill,
                          size: r * 0.9,
                          color: const Color(0xFF8D6E63),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Specular Shine Sheen Sweep (Sapu kilau diagonal untuk Level 3+)
            if (lvl.hasShinyAura)
              AnimatedBuilder(
                animation: _animCtrl,
                builder: (context, _) {
                  final t = _animCtrl.value;
                  return Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(outerRadius),
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-1.8 + (t * 3.6), -1.8 + (t * 3.6)),
                              end: Alignment(-0.6 + (t * 3.6), -0.6 + (t * 3.6)),
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: lvl.hasCosmicParticles ? 0.60 : 0.40),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // 4. Ornate Corner Accent untuk Level Puncak (Level 8, 9, 10)
            if (lvl.level >= 8)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: lvl.level == 10
                        ? const Color(0xFFFFD700)
                        : (lvl.level == 9 ? const Color(0xFFBA68C8) : const Color(0xFFFF7043)),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    lvl.level == 10
                        ? CupertinoIcons.sparkles
                        : (lvl.level == 9 ? CupertinoIcons.star_fill : CupertinoIcons.rosette),
                    size: 8,
                    color: lvl.level == 10 ? const Color(0xFF5D4037) : Colors.white,
                  ),
                ),
              ),

            // 5. Level Pill Badge Overlaid di Bawah Kotak
            if (widget.showLevelBadge)
              Positioned(
                bottom: -3,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (r * 0.22).clamp(6.0, 10.0),
                    vertical: (r * 0.08).clamp(2.0, 4.0),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: lvl.borderGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(lvl.badgeIcon, size: (r * 0.3).clamp(8.0, 11.0), color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        'Lv.${lvl.level}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (r * 0.28).clamp(8.5, 11.0),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
