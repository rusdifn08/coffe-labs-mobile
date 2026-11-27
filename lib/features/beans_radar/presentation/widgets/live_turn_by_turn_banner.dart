import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/models/multimodal_route_models.dart';
import '../../models/beans_radar_models.dart';

/// Google-Maps-Style Live Turn-by-Turn HUD Banner dengan arah belokan, sisa jarak/ETA,
/// status auto-reroute Viterbi, tombol mute suara (`flutter_tts`), dan tombol Selesai.
class LiveTurnByTurnBanner extends StatelessWidget {
  final LiveNavigationState navState;
  final RadarPlaceCard destination;
  final RadarTravelMode travelMode;
  final VoidCallback onToggleMute;
  final VoidCallback onStopNavigation;

  const LiveTurnByTurnBanner({
    super.key,
    required this.navState,
    required this.destination,
    required this.travelMode,
    required this.onToggleMute,
    required this.onStopNavigation,
  });

  String _formatRemainingEta(double sec) {
    final mins = (sec / 60.0).ceil().clamp(1, 999);
    if (mins < 60) return '$mins mnt';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? '$h jam' : '$h jam $m mnt';
  }

  IconData _turnIcon(String instr) {
    final lower = instr.toLowerCase();
    if (lower.contains('kiri')) return Icons.turn_left_rounded;
    if (lower.contains('kanan')) return Icons.turn_right_rounded;
    if (lower.contains('putar')) return Icons.u_turn_left_rounded;
    if (lower.contains('bundaran')) return Icons.roundabout_left_rounded;
    if (lower.contains('tiba')) return Icons.flag_rounded;
    return Icons.straight_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = navState.isRerouting
        ? const Color(0xFF92400E)
        : const Color(0xFF065F46);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF34D399).withValues(alpha: 0.55),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: navState.isRerouting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _turnIcon(navState.currentInstruction),
                        color: Colors.white,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      navState.currentInstruction.isNotEmpty
                          ? navState.currentInstruction
                          : 'Ikuti rute menuju ${destination.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(travelMode.icon, size: 12, color: const Color(0xFFA7F3D0)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Sisa ${RadarPlaceCard.formatDistance(navState.remainingDistanceMeters)} • ${_formatRemainingEta(navState.remainingDurationSeconds)} ke ${destination.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFD1FAE5),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: navState.voiceMuted ? 'Aktifkan Suara' : 'Bisukan Suara',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                onPressed: onToggleMute,
                icon: Icon(
                  navState.voiceMuted
                      ? CupertinoIcons.speaker_slash_fill
                      : CupertinoIcons.speaker_2_fill,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onStopNavigation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
