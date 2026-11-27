import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/multimodal_route_models.dart';
import '../../models/beans_radar_models.dart';

/// Google-Maps-Grade Multi-Modal Route HUD Bar:
/// - Membandingkan 3 moda (Motor / Mobil / Jalan Kaki) lengkap dengan ETA masing-masing moda.
/// - Toggle "Hindari Tol" untuk Mobil, pemilih Rute Alternatif, Panduan Turn-by-Turn Bahasa Indonesia,
///   "Mulai" Navigasi Live in-app, & "GMaps" dengan parameter travelmode tepat.
class RadarActiveRouteBar extends StatefulWidget {
  final RadarRouteResult? route;
  final MultiModalRouteComparison? comparison;
  final int selectedAlternativeIndex;
  final bool avoidTolls;
  final bool isLoading;
  final RadarTravelMode selectedMode;
  final ValueChanged<RadarTravelMode> onModeChanged;
  final ValueChanged<int>? onSelectAlternative;
  final VoidCallback? onToggleAvoidTolls;
  final VoidCallback? onStartLiveNavigation;
  final VoidCallback onCloseRoute;
  final VoidCallback? onLaunchExternalNavigation;
  final VoidCallback? onTapDestination;

  const RadarActiveRouteBar({
    super.key,
    required this.route,
    this.comparison,
    this.selectedAlternativeIndex = 0,
    this.avoidTolls = false,
    required this.isLoading,
    required this.selectedMode,
    required this.onModeChanged,
    this.onSelectAlternative,
    this.onToggleAvoidTolls,
    this.onStartLiveNavigation,
    required this.onCloseRoute,
    this.onLaunchExternalNavigation,
    this.onTapDestination,
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
                    'Menghitung rute terpisah Jalan Kaki, Motor & Mobil...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    final cmp = widget.comparison;
    final bundleAlts = cmp?.bundleFor(widget.selectedMode).allRoutes ?? const <RadarRouteAlternative>[];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _modeAccent(widget.selectedMode).withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.selectedMode.icon,
                color: _modeLightAccent(widget.selectedMode),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onTapDestination,
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
                        const SizedBox(width: 5),
                        if (widget.isLoading)
                          const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Color(0xFFD4A373),
                            ),
                          )
                        else if (route.modeBadge.isNotEmpty)
                          Flexible(
                            child: Text(
                              '• ${route.modeBadge}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFCBBFB2),
                                fontSize: 9.8,
                                fontWeight: FontWeight.w600,
                              ),
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

        // Row 2: Full-width 3-Modal Switcher ('Motor', 'Mobil', 'Jalan' + ETA pill, always visible at 360px)
        Row(
          children: List.generate(RadarTravelMode.values.length, (i) {
            final m = RadarTravelMode.values[i];
            final active = widget.selectedMode == m;
            final etaStr = cmp?.bundleFor(m).primary.durationLabel;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < RadarTravelMode.values.length - 1 ? 5 : 0,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () => widget.onModeChanged(m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.accentGold
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
                          if (etaStr != null) ...[
                            const SizedBox(width: 3),
                            Text(
                              etaStr,
                              style: TextStyle(
                                fontSize: 9.2,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? const Color(0xFF451A03)
                                    : const Color(0xFFA8A29E),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),

        // Row 3: "Hindari Tol" / Alternatif Rute di kiri + "Arah", "Mulai", & GMaps di kanan
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.selectedMode == RadarTravelMode.drive &&
                        widget.onToggleAvoidTolls != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: widget.onToggleAvoidTolls,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: widget.avoidTolls
                                  ? const Color(0xFF2563EB)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.avoidTolls
                                    ? const Color(0xFF60A5FA)
                                    : Colors.white24,
                              ),
                            ),
                            child: Text(
                              widget.avoidTolls ? '✓ Hindari Tol' : 'Hindari Tol',
                              style: const TextStyle(
                                color: Color(0xFFF9F5EE),
                                fontSize: 9.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (bundleAlts.length > 1)
                      ...List.generate(bundleAlts.length, (idx) {
                        final alt = bundleAlts[idx];
                        final isSel = idx == widget.selectedAlternativeIndex;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: widget.onSelectAlternative != null
                                ? () => widget.onSelectAlternative!(idx)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel
                                      ? AppTheme.accentGold
                                      : Colors.white24,
                                ),
                              ),
                              child: Text(
                                idx == 0
                                    ? 'Tercepat • ${alt.durationLabel}'
                                    : '${alt.deltaMinutesLabel(bundleAlts.first)} • ${alt.distanceLabel}',
                                style: TextStyle(
                                  color: isSel
                                      ? AppTheme.accentGold
                                      : const Color(0xFFCBBFB2),
                                  fontSize: 9.8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            if (route.steps.isNotEmpty)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _showSteps = !_showSteps),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
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
            if (widget.onStartLiveNavigation != null)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onStartLiveNavigation,
                child: Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 13, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        'Mulai',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4.5),
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

  static Color _modeAccent(RadarTravelMode mode) {
    switch (mode) {
      case RadarTravelMode.walk:
        return const Color(0xFF0D9488);
      case RadarTravelMode.motorcycle:
        return const Color(0xFFD97706);
      case RadarTravelMode.drive:
        return const Color(0xFF2563EB);
    }
  }

  static Color _modeLightAccent(RadarTravelMode mode) {
    switch (mode) {
      case RadarTravelMode.walk:
        return const Color(0xFF5EEAD4);
      case RadarTravelMode.motorcycle:
        return const Color(0xFFFCD34D);
      case RadarTravelMode.drive:
        return const Color(0xFF60A5FA);
    }
  }
}
