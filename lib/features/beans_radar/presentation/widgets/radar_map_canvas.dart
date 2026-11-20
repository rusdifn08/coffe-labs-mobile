import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../theme/app_theme.dart';
import '../../models/beans_radar_models.dart';
import '../controllers/radar_gps_controller.dart';

enum RadarBasemapStyle {
  googleRoadmap(
    id: 'google_roadmap',
    title: 'Google Maps (Jalan & Kafe)',
    subtitle: 'Peta jalan standar Google Maps Bahasa Indonesia',
    icon: Icons.map_rounded,
  ),
  googleTerrain(
    id: 'google_terrain',
    title: 'Google Maps Terrain',
    subtitle: 'Topografi kontur pegunungan & origin kopi',
    icon: Icons.terrain_rounded,
  ),
  googleHybrid(
    id: 'google_hybrid',
    title: 'Google Maps Satelit Hybrid',
    subtitle: 'Citra satelit resolusi tinggi + nama jalan',
    icon: Icons.satellite_alt_rounded,
  ),
  openStreetMap(
    id: 'osm_hd',
    title: 'OpenStreetMap HD',
    subtitle: 'Peta komunitas terbuka bebas kuota',
    icon: CupertinoIcons.globe,
  );

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const RadarBasemapStyle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  bool get isGoogle => this != RadarBasemapStyle.openStreetMap;

  String buildUrlTemplate(String apiKey) {
    final cleanKey = apiKey.trim();
    final keyParam = cleanKey.isNotEmpty ? '&key=$cleanKey' : '';
    switch (this) {
      case RadarBasemapStyle.googleRoadmap:
        return 'https://mt{s}.google.com/vt/lyrs=m&hl=id&gl=ID&x={x}&y={y}&z={z}$keyParam';
      case RadarBasemapStyle.googleTerrain:
        return 'https://mt{s}.google.com/vt/lyrs=p&hl=id&gl=ID&x={x}&y={y}&z={z}$keyParam';
      case RadarBasemapStyle.googleHybrid:
        return 'https://mt{s}.google.com/vt/lyrs=y&hl=id&gl=ID&x={x}&y={y}&z={z}$keyParam';
      case RadarBasemapStyle.openStreetMap:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  List<String> get subdomains =>
      isGoogle ? const ['0', '1', '2', '3'] : const [];
}

class RadarMapCanvas extends StatefulWidget {
  final MapController mapController;
  final double centerLat;
  final double centerLng;
  final double userLat;
  final double userLng;
  final bool hasUserLocation;
  final double? compassHeadingDeg;
  final List<RadarPlaceCard> places;
  final String? selectedPlaceId;
  final RadarRouteResult? activeRoute;
  final ValueChanged<RadarPlaceCard> onPlaceTapped;
  final ValueChanged<RadarMapBounds> onCameraMoved;
  final bool enableNetworkTiles;

  const RadarMapCanvas({
    super.key,
    required this.mapController,
    required this.centerLat,
    required this.centerLng,
    required this.userLat,
    required this.userLng,
    this.hasUserLocation = true,
    required this.compassHeadingDeg,
    required this.places,
    required this.selectedPlaceId,
    this.activeRoute,
    required this.onPlaceTapped,
    required this.onCameraMoved,
    this.enableNetworkTiles = true,
  });

  @override
  State<RadarMapCanvas> createState() => _RadarMapCanvasState();
}

class _RadarMapCanvasState extends State<RadarMapCanvas> {
  static const String _prefStyleKey = 'coffeehub_radar_basemap_style';
  static const String _prefGoogleApiKey = 'coffeehub_google_maps_api_key';
  static const String _envGoogleApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  RadarBasemapStyle _basemapStyle = RadarBasemapStyle.googleRoadmap;
  String _customGoogleApiKey = _envGoogleApiKey;

  @override
  void initState() {
    super.initState();
    _loadSavedMapPreferences();
  }

  @override
  void didUpdateWidget(covariant RadarMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeRoute != null &&
        widget.activeRoute != oldWidget.activeRoute &&
        widget.activeRoute!.points.length >= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitCameraToRoute(widget.activeRoute!);
      });
    }
  }

  void _fitCameraToRoute(RadarRouteResult route) {
    try {
      final bounds = LatLngBounds.fromPoints(route.points);
      widget.mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(44, 155, 44, 240),
          maxZoom: 16.5,
        ),
      );
    } catch (_) {}
  }

  Future<void> _loadSavedMapPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStyleId = prefs.getString(_prefStyleKey);
      final savedKey = prefs.getString(_prefGoogleApiKey);
      if (!mounted) return;
      setState(() {
        if (savedStyleId != null) {
          for (final s in RadarBasemapStyle.values) {
            if (s.id == savedStyleId) {
              _basemapStyle = s;
              break;
            }
          }
        }
        if (savedKey != null && savedKey.trim().isNotEmpty) {
          _customGoogleApiKey = savedKey.trim();
        }
      });
    } catch (_) {}
  }

  Future<void> _saveMapPreferences(
    RadarBasemapStyle style,
    String apiKey,
  ) async {
    setState(() {
      _basemapStyle = style;
      _customGoogleApiKey = apiKey.trim();
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefStyleKey, style.id);
      await prefs.setString(_prefGoogleApiKey, apiKey.trim());
    } catch (_) {}
  }

  Future<void> _openMapSettingsSheet() async {
    final keyCtrl = TextEditingController(text: _customGoogleApiKey);
    RadarBasemapStyle tempStyle = _basemapStyle;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                MediaQuery.of(sheetCtx).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        color: AppTheme.primaryBrown,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Jenis Peta & Google Maps API Key',
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'GOOGLE MAPS AKTIF',
                          style: TextStyle(
                            color: Color(0xFF15803D),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...RadarBasemapStyle.values.map((style) {
                    final selected = tempStyle == style;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setModalState(() => tempStyle = style);
                          _saveMapPreferences(style, keyCtrl.text);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primaryBrown.withValues(alpha: 0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryBrown
                                  : Colors.black12,
                              width: selected ? 1.6 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                style.icon,
                                size: 19,
                                color: selected
                                    ? AppTheme.primaryBrown
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      style.title,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: selected
                                            ? AppTheme.primaryBrown
                                            : AppTheme.textDark,
                                      ),
                                    ),
                                    Text(
                                      style.subtitle,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppTheme.primaryBrown,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  TextField(
                    controller: keyCtrl,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Google Maps API Key (Opsional)',
                      hintText:
                          'AIzaSy... (Kosongkan untuk mode Google Maps langsung)',
                      labelStyle: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.primaryBrown,
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _saveMapPreferences(tempStyle, keyCtrl.text);
                        Navigator.of(sheetCtx).pop();
                      },
                      icon: const Icon(Icons.check_rounded, size: 17),
                      label: const Text(
                        'Terapkan Pengaturan Peta',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = widget.places.map((place) {
      final isSelected = place.id == widget.selectedPlaceId ||
          place.id == widget.activeRoute?.destination.id;
      return Marker(
        key: ValueKey('pin_${place.id}'),
        point: LatLng(place.latitude, place.longitude),
        width: isSelected ? 84 : 68,
        height: isSelected ? 40 : 34,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => widget.onPlaceTapped(place),
          child: _CoffeePinPill(place: place, isSelected: isSelected),
        ),
      );
    }).toList();

    final route = widget.activeRoute;

    return ColoredBox(
      color: const Color(0xFFEDE6DA),
      child: Stack(
        children: [
          FlutterMap(
            mapController: widget.mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.centerLat, widget.centerLng),
              initialZoom: widget.hasUserLocation ? 13.6 : 5.2,
              minZoom: 4.5,
              maxZoom: 19.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  final b = event.camera.visibleBounds;
                  widget.onCameraMoved(
                    RadarMapBounds(
                      north: b.north,
                      south: b.south,
                      east: b.east,
                      west: b.west,
                      centerLat: event.camera.center.latitude,
                      centerLng: event.camera.center.longitude,
                    ),
                  );
                }
              },
            ),
            children: [
              if (widget.enableNetworkTiles)
                TileLayer(
                  key: ValueKey(
                    'tile_${_basemapStyle.id}_${_customGoogleApiKey.isNotEmpty}',
                  ),
                  urlTemplate:
                      _basemapStyle.buildUrlTemplate(_customGoogleApiKey),
                  subdomains: _basemapStyle.subdomains,
                  userAgentPackageName: 'Mozilla/5.0 (CoffeeLabs/3.0)',
                  tileProvider: CancellableNetworkTileProvider(),
                  maxNativeZoom: 19,
                ),

              // IN-APP ROAD POLYLINE LAYER (Jalur Rute Jalan Nyata di Dalam Peta)
              if (route != null && route.points.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route.points,
                      strokeWidth: 7.5,
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.78),
                    ),
                    Polyline(
                      points: route.points,
                      strokeWidth: 4.2,
                      color: const Color(0xFF3B82F6),
                    ),
                  ],
                ),

              if (widget.hasUserLocation)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.userLat, widget.userLng),
                      width: 68,
                      height: 68,
                      child: _UserGpsBeacon(
                        headingDeg: widget.compassHeadingDeg,
                      ),
                    ),
                    if (route != null)
                      Marker(
                        point: LatLng(
                          route.destination.latitude,
                          route.destination.longitude,
                        ),
                        width: 46,
                        height: 46,
                        alignment: Alignment.topCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.45),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),

              if (markers.isNotEmpty)
                SuperclusterLayer.immutable(
                  key: ValueKey(
                    'cluster_${markers.length}_${widget.selectedPlaceId ?? 'none'}',
                  ),
                  initialMarkers: markers,
                  indexBuilder: IndexBuilders.rootIsolate,
                  maxClusterRadius: 70,
                  clusterWidgetSize: const Size(42, 42),
                  calculateAggregatedClusterData: false,
                  builder: (ctx, pos, markerCount, _) => Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      markerCount > 99 ? '99+' : '$markerCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Floating Google Maps Layer & API Key Switcher
          Positioned(
            right: 12,
            top: 150,
            child: SafeArea(
              bottom: false,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                elevation: 4,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _openMapSettingsSheet,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _basemapStyle.icon,
                          size: 15,
                          color: AppTheme.primaryBrown,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _basemapStyle == RadarBasemapStyle.googleRoadmap
                              ? 'Google Maps'
                              : (_basemapStyle == RadarBasemapStyle.googleTerrain
                                  ? 'Terrain'
                                  : (_basemapStyle ==
                                          RadarBasemapStyle.googleHybrid
                                      ? 'Satelit'
                                      : 'OSM HD')),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoffeePinPill extends StatelessWidget {
  final RadarPlaceCard place;
  final bool isSelected;

  const _CoffeePinPill({required this.place, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppTheme.primaryBrown
        : (place.category == CoffeePlaceCategory.roastery ||
                place.radarKind == 'ROASTERY_AND_CAFE'
            ? const Color(0xFF4A2E1A)
            : Colors.white);
    final fgColor = isSelected ||
            place.category == CoffeePlaceCategory.roastery ||
            place.radarKind == 'ROASTERY_AND_CAFE'
        ? Colors.white
        : AppTheme.textDark;

    return AnimatedScale(
      scale: isSelected ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentGold
                : AppTheme.primaryBrown.withValues(alpha: 0.35),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              place.category.iconData,
              size: 12,
              color: isSelected
                  ? AppTheme.accentGold
                  : (fgColor == Colors.white
                      ? AppTheme.accentGold
                      : AppTheme.primaryBrown),
            ),
            const SizedBox(width: 3),
            Text(
              place.rating > 0 ? place.rating.toStringAsFixed(1) : '•',
              style: TextStyle(
                color: fgColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserGpsBeacon extends StatelessWidget {
  final double? headingDeg;

  const _UserGpsBeacon({this.headingDeg});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (headingDeg != null)
          Transform.rotate(
            angle: (headingDeg! * math.pi) / 180.0,
            child: CustomPaint(
              size: const Size(68, 68),
              painter: _HeadingConePainter(),
            ),
          ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.24),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeadingConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF3B82F6).withValues(alpha: 0.52),
          const Color(0xFF3B82F6).withValues(alpha: 0.0),
        ],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2 - 0.42,
      0.84,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
