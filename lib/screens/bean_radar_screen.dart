import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/performance/transition_aware_deferred_builder.dart';
import '../features/beans_radar/data/beans_radar_repository.dart';
import '../features/beans_radar/models/beans_radar_models.dart';
import '../features/beans_radar/presentation/controllers/radar_gps_controller.dart';
import '../features/beans_radar/presentation/widgets/beans_radar_bottom_sheet.dart';
import '../features/beans_radar/presentation/widgets/coffee_place_detail_sheet.dart';
import '../features/beans_radar/presentation/widgets/radar_active_route_bar.dart';
import '../features/beans_radar/presentation/widgets/radar_floating_controls.dart';
import '../features/beans_radar/presentation/widgets/radar_map_canvas.dart';
import '../features/roastery/controllers/roastery_catalog_controller.dart';
import '../features/roastery/screens/roastery_detail_screen.dart';
import '../models/roastery.dart';
import '../theme/app_theme.dart';

class BeanRadarScreen extends ConsumerStatefulWidget {
  final bool enableNetworkTiles;
  final RadarAppMode initialMode;

  const BeanRadarScreen({
    super.key,
    this.enableNetworkTiles = true,
    this.initialMode = RadarAppMode.beans,
  });

  @override
  ConsumerState<BeanRadarScreen> createState() => _BeanRadarScreenState();
}

class _BeanRadarScreenState extends ConsumerState<BeanRadarScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(beansRadarGpsProvider.notifier)
          .setRadarMode(widget.initialMode, reload: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _safeMoveMap(double lat, double lng, {double zoom = 13.8}) {
    try {
      _mapController.move(LatLng(lat, lng), zoom);
    } catch (_) {}
  }

  void _openCityPicker(RadarGpsController ctrl, RadarGpsState state) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Kota Eksplorasi Kopi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: RadarGpsController.indonesiaCityHubs.entries.map((e) {
                  final selected = e.key == state.locationLabel;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      CupertinoIcons.location_solid,
                      color:
                          selected ? AppTheme.primaryBrown : AppTheme.textMuted,
                    ),
                    title: Text(
                      e.key,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await ctrl.selectCityPreset(
                        e.key,
                        e.value[0],
                        e.value[1],
                      );
                      _safeMoveMap(e.value[0], e.value[1], zoom: 13.4);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLinkedRoastery(RadarPlaceCard place) {
    final roasteryId = place.linkedRoasteryId;
    if (roasteryId == null) return;
    final catalog = ref.read(roasteryCatalogProvider).allMergedRoasteries;
    Roastery? matched;
    for (final r in catalog) {
      if (r.id == roasteryId) {
        matched = r;
        break;
      }
    }
    if (matched == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoasteryDetailScreen(roastery: matched!),
      ),
    );
  }

  Future<void> _openPlaceDetail(
    RadarPlaceCard place,
    RadarGpsState state,
  ) async {
    final ctrl = ref.read(beansRadarGpsProvider.notifier);
    ctrl.selectPlace(place.id);
    _safeMoveMap(place.latitude, place.longitude, zoom: 15.0);
    await CoffeePlaceDetailSheet.show(
      context: context,
      place: place,
      repository: ref.read(beansRadarRepositoryProvider),
      originLat: state.queryLat,
      originLng: state.queryLng,
      onOpenLinkedRoastery: place.linkedRoasteryId != null
          ? () => _openLinkedRoastery(place)
          : null,
      onShowInAppRoute: () => ctrl.requestInAppRoute(place),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radarState = ref.watch(beansRadarGpsProvider);
    final radarCtrl = ref.read(beansRadarGpsProvider.notifier);

    ref.listen<RadarGpsState>(beansRadarGpsProvider, (prev, next) {
      if (prev != null &&
          next.cameraRevision != prev.cameraRevision &&
          next.hasUsableLocation) {
        _safeMoveMap(next.queryLat, next.queryLng, zoom: 13.6);
      }
      if (next.routeError != null && next.routeError != prev?.routeError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.routeError!),
            backgroundColor: const Color(0xFF991B1B),
          ),
        );
      }
    });

    final hasRouteHud =
        radarState.activeRoute != null || radarState.isLoadingRoute;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: TransitionAwareDeferredBuilder(
        lightweightPlaceholder: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrown),
        ),
        heavyBuilder: (_) => Stack(
          children: [
            Positioned.fill(
              child: RadarMapCanvas(
                mapController: _mapController,
                centerLat: radarState.queryLat,
                centerLng: radarState.queryLng,
                userLat: radarState.userLat,
                userLng: radarState.userLng,
                hasUserLocation: radarState.hasUsableLocation,
                compassHeadingDeg: radarState.compassHeadingDeg,
                places: radarState.places,
                selectedPlaceId: radarState.selectedPlaceId,
                activeRoute: radarState.activeRoute,
                enableNetworkTiles: widget.enableNetworkTiles,
                onPlaceTapped: (place) => _openPlaceDetail(place, radarState),
                onCameraMoved: radarCtrl.onMapBoundsMoved,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadarFloatingControls(
                    searchController: _searchController,
                    state: radarState,
                    onBack: () => Navigator.maybePop(context),
                    onRecenterGps: () async {
                      if (radarState.permissionDeniedForever) {
                        await Geolocator.openAppSettings();
                        return;
                      }
                      if (radarState.gpsServiceDisabled) {
                        await Geolocator.openLocationSettings();
                      }
                      final ok = await radarCtrl.acquireLiveGps();
                      final latest = ref.read(beansRadarGpsProvider);
                      if (ok || latest.hasUsableLocation) {
                        _safeMoveMap(
                          latest.userLat,
                          latest.userLng,
                          zoom: 14.2,
                        );
                      }
                    },
                    onOpenCityPicker: () =>
                        _openCityPicker(radarCtrl, radarState),
                    onSearchChanged: radarCtrl.onSearchChanged,
                    onRadarModeChanged: (m) => radarCtrl.setRadarMode(m),
                    onCategoryChanged: radarCtrl.setCategory,
                    onToggleOpenNow: radarCtrl.toggleOpenNow,
                    onToggleMinRating: radarCtrl.toggleMinRating45,
                    onRadiusChanged: radarCtrl.setRadiusKm,
                    onSearchThisArea: radarCtrl.searchPendingMapArea,
                  ),
                  if (hasRouteHud) ...[
                    const SizedBox(height: 8),
                    RadarActiveRouteBar(
                      route: radarState.activeRoute,
                      isLoading: radarState.isLoadingRoute,
                      selectedMode: radarState.routeMode,
                      onModeChanged: radarCtrl.changeRouteMode,
                      onCloseRoute: radarCtrl.clearActiveRoute,
                      onLaunchExternalNavigation: radarState.activeRoute != null
                          ? () => CoffeePlaceDetailSheet.launchDirections(
                                radarState.activeRoute!.destination,
                              )
                          : null,
                    ),
                  ],
                ],
              ),
            ),
            Positioned.fill(
              child: BeansRadarBottomSheet(
                state: radarState,
                onSortChanged: radarCtrl.setSortMode,
                onSelectPlaceCard: (p) => _openPlaceDetail(p, radarState),
                // Sekarang "Lihat Rute" langsung menggambar rute jalan di dalam peta aplikasi!
                onOpenRoute: (p) => radarCtrl.requestInAppRoute(p),
                onOpenLineup: _openLinkedRoastery,
                onExpandNationwide: () => radarCtrl.setRadiusKm(150.0),
                onRetryGps: () async {
                  if (radarState.gpsServiceDisabled) {
                    await Geolocator.openLocationSettings();
                  }
                  await radarCtrl.acquireLiveGps();
                },
                onPickCityManual: () => _openCityPicker(radarCtrl, radarState),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
