import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../models/beans_radar_models.dart';
import '../controllers/radar_gps_controller.dart';
import 'coffee_radar_place_card.dart';

class BeansRadarBottomSheet extends StatelessWidget {
  final RadarGpsState state;
  final ValueChanged<RadarSortMode> onSortChanged;
  final ValueChanged<RadarPlaceCard> onSelectPlaceCard;
  final ValueChanged<RadarPlaceCard> onOpenRoute;
  final ValueChanged<RadarPlaceCard>? onOpenLineup;
  final VoidCallback onExpandNationwide;
  final VoidCallback onRetryGps;
  final VoidCallback? onPickCityManual;

  const BeansRadarBottomSheet({
    super.key,
    required this.state,
    required this.onSortChanged,
    required this.onSelectPlaceCard,
    required this.onOpenRoute,
    this.onOpenLineup,
    required this.onExpandNationwide,
    required this.onRetryGps,
    this.onPickCityManual,
  });

  @override
  Widget build(BuildContext context) {
    final hasRoute = state.activeRoute != null || state.isLoadingRoute;

    return DraggableScrollableSheet(
      initialChildSize: hasRoute ? 0.25 : 0.44,
      minChildSize: 0.22,
      maxChildSize: 0.90,
      snap: true,
      snapSizes: const [0.22, 0.44, 0.90],
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 14,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
                child: Row(
                  children: [
                    Icon(
                      state.hasRealGpsFix
                          ? CupertinoIcons.location_fill
                          : (state.locationSource == RadarLocationSource.networkIp
                              ? Icons.wifi_tethering_rounded
                              : CupertinoIcons.map_pin_ellipse),
                      size: 15,
                      color: state.hasRealGpsFix
                          ? Colors.green.shade700
                          : (state.locationSource == RadarLocationSource.networkIp
                              ? const Color(0xFF2563EB)
                              : AppTheme.primaryBrown),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.locationSource == RadarLocationSource.unavailable
                                ? 'GPS Tidak Aktif'
                                : 'Sekitar ${state.locationLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            _subtitleText(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<RadarSortMode>(
                      initialValue: state.sortMode,
                      onSelected: onSortChanged,
                      itemBuilder: (_) => RadarSortMode.values
                          .map(
                            (m) => PopupMenuItem<RadarSortMode>(
                              value: m,
                              child: Text(m.label),
                            ),
                          )
                          .toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryBrown.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.arrow_up_arrow_down,
                              size: 12,
                              color: AppTheme.primaryBrown,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.sortMode.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.statusBanner != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.info_circle_fill,
                          size: 15,
                          color: Color(0xFFB45309),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.statusBanner!,
                            style: const TextStyle(
                              fontSize: 10.8,
                              color: Color(0xFF92400E),
                              height: 1.25,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: onRetryGps,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text(
                            'Aktifkan GPS',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: state.isLoadingPlaces && state.places.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryBrown,
                        ),
                      )
                    : state.places.isEmpty
                        ? _EmptyRadarState(
                            radiusKm: state.selectedRadiusKm,
                            isGpsUnavailable: state.locationSource ==
                                RadarLocationSource.unavailable,
                            onExpandNationwide: onExpandNationwide,
                            onRetryGps: onRetryGps,
                            onPickCityManual: onPickCityManual,
                          )
                        : ListView.separated(
                            controller: scrollCtrl,
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                            itemCount: state.places.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final place = state.places[idx];
                              return CoffeeRadarPlaceCard(
                                place: place,
                                isSelected: place.id == state.selectedPlaceId,
                                onTapCard: () => onSelectPlaceCard(place),
                                onTapRoute: () => onOpenRoute(place),
                                onTapLineup: place.linkedRoasteryId != null &&
                                        onOpenLineup != null
                                    ? () => onOpenLineup!(place)
                                    : null,
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _subtitleText() {
    final count = state.places.length;
    final modeTitle = state.radarMode.title;
    final srcLabel = state.hasRealGpsFix
        ? 'GPS Akurat'
        : (state.locationSource == RadarLocationSource.networkIp
            ? 'Lokasi IP/Wi-Fi'
            : (state.locationSource == RadarLocationSource.manualCity
                ? 'Kota Pilihan'
                : 'GPS Mati'));
    final total = state.meta?.totalIndexedPlaces ?? 0;
    final idxSuffix = total >= 1000 ? ' • ${(total / 1000).toStringAsFixed(1)}K+ DB' : '';
    return '$count hasil $modeTitle • $srcLabel$idxSuffix';
  }
}

class _EmptyRadarState extends StatelessWidget {
  final double radiusKm;
  final bool isGpsUnavailable;
  final VoidCallback onExpandNationwide;
  final VoidCallback onRetryGps;
  final VoidCallback? onPickCityManual;

  const _EmptyRadarState({
    required this.radiusKm,
    required this.isGpsUnavailable,
    required this.onExpandNationwide,
    required this.onRetryGps,
    this.onPickCityManual,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Icon(
          CupertinoIcons.location_slash,
          size: 38,
          color: AppTheme.textMuted,
        ),
        const SizedBox(height: 10),
        Text(
          isGpsUnavailable
              ? 'GPS perangkat tidak aktif. Aktifkan GPS untuk deteksi lokasi nyata Anda atau pilih kota tujuan.'
              : 'Belum ada lokasi pada radius ${radiusKm.toInt()} km di sekitar titik ini.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (isGpsUnavailable) ...[
              ElevatedButton.icon(
                onPressed: onRetryGps,
                icon: const Icon(CupertinoIcons.location_fill, size: 15),
                label: const Text('Aktifkan GPS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                ),
              ),
              if (onPickCityManual != null)
                OutlinedButton.icon(
                  onPressed: onPickCityManual,
                  icon: const Icon(CupertinoIcons.map_pin_ellipse, size: 15),
                  label: const Text('Pilih Kota'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                  ),
                ),
            ] else
              ElevatedButton(
                onPressed: onExpandNationwide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Perluas Radius ke 150 km'),
              ),
          ],
        ),
      ],
    );
  }
}
