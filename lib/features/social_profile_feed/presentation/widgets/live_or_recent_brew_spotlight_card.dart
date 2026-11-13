import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../social/utils/social_time_formatter.dart';
import '../../domain/models/social_profile_models.dart';

class LiveOrRecentBrewSpotlightCard extends StatelessWidget {
  final RecentBrewSnapshot snapshot;
  final VoidCallback onTryExactBrew;

  const LiveOrRecentBrewSpotlightCard({
    super.key,
    required this.snapshot,
    required this.onTryExactBrew,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = snapshot.isLive &&
        DateTime.now().difference(snapshot.brewedAt).inMinutes < 15;
    final accent =
        isLive ? const Color(0xFF10B981) : const Color(0xFFD97706);

    final tempText = snapshot.secondaryTempC != null
        ? '${snapshot.primaryTempC ?? 92}°C → ${snapshot.secondaryTempC}°C'
        : '${snapshot.primaryTempC ?? 92}°C';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLive
              ? const [Color(0xFFECFDF5), Color(0xFFFFFFFF)]
              : const [Color(0xFFFFFBEB), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PulsingStatusDot(color: accent, animate: isLive),
              const SizedBox(width: 7),
              Text(
                isLive ? 'LIVE BREWING NOW' : 'AKTIVITAS SEDUH TERAKHIR',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: accent,
                ),
              ),
              const Spacer(),
              Text(
                SocialTimeFormatter.formatRelative(snapshot.brewedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${snapshot.beanName} • ${snapshot.roastery}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Resep: ${snapshot.recipeTitle} (${snapshot.method} • $tempText)',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (snapshot.accuracyScore != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 13,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Presisi ${snapshot.accuracyScore!.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ] else
                const Spacer(),
              ElevatedButton.icon(
                onPressed: onTryExactBrew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                icon: const Icon(CupertinoIcons.play_arrow_solid, size: 13),
                label: const Text(
                  'Ikut Seduh Resep Ini',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulsingStatusDot extends StatefulWidget {
  final Color color;
  final bool animate;

  const _PulsingStatusDot({required this.color, required this.animate});

  @override
  State<_PulsingStatusDot> createState() => _PulsingStatusDotState();
}

class _PulsingStatusDotState extends State<_PulsingStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.animate) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulsingStatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.animate && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1.0).animate(_ctrl),
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.6),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}
