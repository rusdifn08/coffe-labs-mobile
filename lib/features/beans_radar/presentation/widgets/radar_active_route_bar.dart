import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../models/beans_radar_models.dart';

/// Panel HUD Rute In-App: menampilkan jarak, ETA, pemilih moda (Motor / Mobil / Jalan),
/// panduan belokan langsung di dalam aplikasi, tombol Tutup Rute, serta opsi Navigasi Suara.
class RadarActiveRouteBar extends StatefulWidget {
  final RadarRouteResult? route;
  final bool isLoading;
  final RadarTravelMode selectedMode;
  final ValueChanged<RadarTravelMode> onModeChanged;
  final VoidCallback onCloseRoute;
  final VoidCallback? onLaunchExternalNavigation;

  const RadarActiveRouteBar({
    super.key,
    required this.route,
    required this.isLoading,
    required this.selectedMode,
    required this.onModeChanged,
    required this.onCloseRoute,
    this.onLaunchExternalNavigation,
  });

  @override
  State<RadarActiveRouteBar> createState() => _RadarActiveRouteBarState();
}

class _RadarActiveRouteBarState extends State<RadarActiveRouteBar> {
  bool _showSteps = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.route == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4A373).withValues(alpha: 0.55),
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
      child: widget.isLoading && widget.route == null
          ? const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFD4A373),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Menghitung jalur rute jalan tercepat di peta...',
                    style: TextStyle(
                      color: Color(0xFFF9F5EE),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            )
          : _buildActiveContent(widget.route!),
    );
  }

  Widget _buildActiveContent(RadarRouteResult route) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.alt_route_rounded,
                color: Color(0xFF60A5FA),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.destination.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF9F5EE),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${route.distanceLabel} • ${route.durationLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF4ADE80),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (widget.isLoading)
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Color(0xFFD4A373),
                          ),
                        )
                      else
                        Text(
                          route.cacheHit ? '• Instan' : '• Peta',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFCBBFB2),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Tutup Rute',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              onPressed: widget.onCloseRoute,
              icon: const Icon(
                CupertinoIcons.xmark_circle_fill,
                color: Color(0xFFA8A29E),
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Mode Switcher + Steps Toggle + Optional Native Navigation (Zero-Overflow 360px)
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: RadarTravelMode.values.map((m) {
                    final active = widget.selectedMode == m;
                    return Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(9),
                        onTap: () => widget.onModeChanged(m),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? AppTheme.accentGold
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                m.icon,
                                size: 12,
                                color: active
                                    ? const Color(0xFF12100E)
                                    : const Color(0xFFF9F5EE),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                m.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: active
                                      ? const Color(0xFF12100E)
                                      : const Color(0xFFF9F5EE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (route.steps.isNotEmpty)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _showSteps = !_showSteps),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showSteps ? 'Tutup' : 'Arah',
                        style: const TextStyle(
                          color: Color(0xFFD4A373),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Icon(
                        _showSteps
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFFD4A373),
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.onLaunchExternalNavigation != null)
              Tooltip(
                message: 'Navigasi Suara Google Maps',
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: widget.onLaunchExternalNavigation,
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.55),
                      ),
                    ),
                    child: const Icon(
                      Icons.navigation_rounded,
                      size: 13,
                      color: Color(0xFF4ADE80),
                    ),
                  ),
                ),
              ),
          ],
        ),

        if (_showSteps && route.steps.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 115),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: route.steps.length,
              separatorBuilder: (_, _) => const Divider(
                height: 8,
                color: Colors.white12,
              ),
              itemBuilder: (_, i) {
                final st = route.steps[i];
                return Row(
                  children: [
                    Text(
                      '${i + 1}.',
                      style: const TextStyle(
                        color: Color(0xFFD4A373),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        st.instruction,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF9F5EE),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      RadarPlaceCard.formatDistance(st.distanceMeters),
                      style: const TextStyle(
                        color: Color(0xFFA8A29E),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
