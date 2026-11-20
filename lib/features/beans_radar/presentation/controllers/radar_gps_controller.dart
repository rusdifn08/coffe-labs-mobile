import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/beans_radar_repository.dart';
import '../../data/radar_routing_service.dart';
import '../../models/beans_radar_models.dart';

class RadarMapBounds {
  final double north;
  final double south;
  final double east;
  final double west;
  final double centerLat;
  final double centerLng;

  const RadarMapBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    required this.centerLat,
    required this.centerLng,
  });
}

class RadarGpsState {
  final double userLat;
  final double userLng;
  final double queryLat;
  final double queryLng;
  final String locationLabel;
  final RadarLocationSource locationSource;
  final bool hasRealGpsFix;
  final bool permissionDenied;
  final bool permissionDeniedForever;
  final bool gpsServiceDisabled;
  final bool isLocating;
  final double? compassHeadingDeg;
  final RadarAppMode radarMode;
  final CoffeePlaceCategory selectedCategory;
  final double selectedRadiusKm;
  final RadarSortMode sortMode;
  final bool openNowOnly;
  final double minRating;
  final bool sellsBeansOnly;
  final String searchQuery;
  final bool showSearchAreaButton;
  final RadarMapBounds? pendingMapBounds;
  final String? selectedPlaceId;
  final List<RadarPlaceCard> places;
  final RadarSearchMeta? meta;
  final bool isLoadingPlaces;
  final bool isOfflineFallback;
  final String? statusBanner;

  // In-App Road Polyline Routing State
  final RadarRouteResult? activeRoute;
  final bool isLoadingRoute;
  final RadarTravelMode routeMode;
  final String? routeError;
  final int cameraRevision;

  const RadarGpsState({
    // Koordinat tengah Nusantara hanya saat menunggu deteksi GPS/IP nyata (bukan berpura-pura di Jakarta)
    this.userLat = -2.5489,
    this.userLng = 118.0149,
    this.queryLat = -2.5489,
    this.queryLng = 118.0149,
    this.locationLabel = 'Mendeteksi Lokasi Anda...',
    this.locationSource = RadarLocationSource.detecting,
    this.hasRealGpsFix = false,
    this.permissionDenied = false,
    this.permissionDeniedForever = false,
    this.gpsServiceDisabled = false,
    this.isLocating = true,
    this.compassHeadingDeg,
    this.radarMode = RadarAppMode.all,
    this.selectedCategory = CoffeePlaceCategory.all,
    this.selectedRadiusKm = 15.0,
    this.sortMode = RadarSortMode.nearest,
    this.openNowOnly = false,
    this.minRating = 0.0,
    this.sellsBeansOnly = false,
    this.searchQuery = '',
    this.showSearchAreaButton = false,
    this.pendingMapBounds,
    this.selectedPlaceId,
    this.places = const [],
    this.meta,
    this.isLoadingPlaces = true,
    this.isOfflineFallback = false,
    this.statusBanner,
    this.activeRoute,
    this.isLoadingRoute = false,
    this.routeMode = RadarTravelMode.motorcycle,
    this.routeError,
    this.cameraRevision = 0,
  });

  bool get hasUsableLocation =>
      locationSource == RadarLocationSource.realGps ||
      locationSource == RadarLocationSource.networkIp ||
      locationSource == RadarLocationSource.manualCity;

  RadarGpsState copyWith({
    double? userLat,
    double? userLng,
    double? queryLat,
    double? queryLng,
    String? locationLabel,
    RadarLocationSource? locationSource,
    bool? hasRealGpsFix,
    bool? permissionDenied,
    bool? permissionDeniedForever,
    bool? gpsServiceDisabled,
    bool? isLocating,
    double? compassHeadingDeg,
    RadarAppMode? radarMode,
    CoffeePlaceCategory? selectedCategory,
    double? selectedRadiusKm,
    RadarSortMode? sortMode,
    bool? openNowOnly,
    double? minRating,
    bool? sellsBeansOnly,
    String? searchQuery,
    bool? showSearchAreaButton,
    RadarMapBounds? pendingMapBounds,
    String? selectedPlaceId,
    bool clearSelectedPlace = false,
    List<RadarPlaceCard>? places,
    RadarSearchMeta? meta,
    bool? isLoadingPlaces,
    bool? isOfflineFallback,
    String? statusBanner,
    bool clearStatusBanner = false,
    RadarRouteResult? activeRoute,
    bool clearActiveRoute = false,
    bool? isLoadingRoute,
    RadarTravelMode? routeMode,
    String? routeError,
    bool clearRouteError = false,
    int? cameraRevision,
  }) {
    return RadarGpsState(
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      queryLat: queryLat ?? this.queryLat,
      queryLng: queryLng ?? this.queryLng,
      locationLabel: locationLabel ?? this.locationLabel,
      locationSource: locationSource ?? this.locationSource,
      hasRealGpsFix: hasRealGpsFix ?? this.hasRealGpsFix,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      permissionDeniedForever:
          permissionDeniedForever ?? this.permissionDeniedForever,
      gpsServiceDisabled: gpsServiceDisabled ?? this.gpsServiceDisabled,
      isLocating: isLocating ?? this.isLocating,
      compassHeadingDeg: compassHeadingDeg ?? this.compassHeadingDeg,
      radarMode: radarMode ?? this.radarMode,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedRadiusKm: selectedRadiusKm ?? this.selectedRadiusKm,
      sortMode: sortMode ?? this.sortMode,
      openNowOnly: openNowOnly ?? this.openNowOnly,
      minRating: minRating ?? this.minRating,
      sellsBeansOnly: sellsBeansOnly ?? this.sellsBeansOnly,
      searchQuery: searchQuery ?? this.searchQuery,
      showSearchAreaButton: showSearchAreaButton ?? this.showSearchAreaButton,
      pendingMapBounds: pendingMapBounds ?? this.pendingMapBounds,
      selectedPlaceId:
          clearSelectedPlace ? null : (selectedPlaceId ?? this.selectedPlaceId),
      places: places ?? this.places,
      meta: meta ?? this.meta,
      isLoadingPlaces: isLoadingPlaces ?? this.isLoadingPlaces,
      isOfflineFallback: isOfflineFallback ?? this.isOfflineFallback,
      statusBanner:
          clearStatusBanner ? null : (statusBanner ?? this.statusBanner),
      activeRoute:
          clearActiveRoute ? null : (activeRoute ?? this.activeRoute),
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      routeMode: routeMode ?? this.routeMode,
      routeError: clearRouteError ? null : (routeError ?? this.routeError),
      cameraRevision: cameraRevision ?? this.cameraRevision,
    );
  }
}

class RadarGpsController extends Notifier<RadarGpsState> {
  StreamSubscription<Position>? _posSub;
  StreamSubscription<CompassEvent>? _compassSub;
  Timer? _searchDebounce;

  static const Map<String, List<double>> indonesiaCityHubs = {
    'Bandung (Dago/Braga)': [-6.9175, 107.6191],
    'Jakarta Pusat (Monas/Thamrin)': [-6.1944, 106.8229],
    'Jakarta Selatan (Senopati/Blok M)': [-6.2355, 106.8055],
    'Yogyakarta (Malioboro/Sleman)': [-7.7828, 110.3671],
    'Surabaya (Gubeng/Pusat)': [-7.2655, 112.7485],
    'Malang (Soekarno Hatta)': [-7.9545, 112.6165],
    'Semarang (Simpang Lima)': [-6.9904, 110.4229],
    'Solo (Surakarta)': [-7.5711, 110.8225],
    'Bali (Canggu/Ubud/Denpasar)': [-8.6500, 115.2167],
    'Medan (Pusat Kesawan)': [3.5897, 98.6738],
    'Makassar (Losari)': [-5.1477, 119.4327],
    'Balikpapan': [-1.2379, 116.8529],
    'Palembang': [-2.9761, 104.7754],
    'Pekanbaru': [0.5071, 101.4478],
    'Padang': [-0.9471, 100.4172],
    'Pontianak': [-0.0263, 109.3425],
    'Banjarmasin': [-3.3186, 114.5944],
    'Manado': [1.4748, 124.8421],
    'Banda Aceh': [5.5483, 95.3238],
    'Jayapura': [-2.5916, 140.6690],
  };

  @override
  RadarGpsState build() {
    ref.onDispose(() {
      _posSub?.cancel();
      _compassSub?.cancel();
      _searchDebounce?.cancel();
    });
    Future.microtask(initialize);
    return const RadarGpsState();
  }

  BeansRadarRepository get _repo => ref.read(beansRadarRepositoryProvider);
  RadarRoutingService get _routing => ref.read(radarRoutingServiceProvider);
  bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  Future<void> setRadarMode(RadarAppMode mode, {bool reload = true}) async {
    if (state.radarMode == mode && !reload) return;
    state = state.copyWith(
      radarMode: mode,
      selectedCategory: CoffeePlaceCategory.all,
      clearActiveRoute: true,
    );
    if (reload && state.hasUsableLocation) {
      await _loadNearbyForCurrentQuery();
    }
  }

  Future<void> initialize() async {
    if (_isTestEnv) {
      // Pada widget test headless, gunakan posisi Bandung agar stabil dan deterministik
      state = state.copyWith(
        userLat: -6.9175,
        userLng: 107.6191,
        queryLat: -6.9175,
        queryLng: 107.6191,
        locationLabel: 'Bandung',
        locationSource: RadarLocationSource.manualCity,
        isLocating: false,
      );
      await _loadNearbyForCurrentQuery();
      return;
    }

    _startCompassStream();
    await acquireLiveGps(requestPermissionIfNeeded: true);
  }

  void _startCompassStream() {
    try {
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        return;
      }
      _compassSub?.cancel();
      _compassSub = FlutterCompass.events?.listen((event) {
        if (event.heading != null) {
          state = state.copyWith(compassHeadingDeg: event.heading);
        }
      });
    } catch (_) {}
  }

  /// Akuisisi GPS Nyata:
  /// 1. Utamakan GPS perangkat (`Geolocator`) pada Android, iOS & Windows Location Service.
  /// 2. Jika GPS perangkat MATI / ditolak (umum pada Windows Desktop) -> JANGAN palsukan Jakarta!
  ///    Deteksi lokasi IP/Wi-Fi NYATA pengguna via `ipwho.is` / `geojs.io` & tampilkan status transparan.
  /// 3. Jika GPS mati DAN offline -> tampilkan prompt "GPS Tidak Aktif — Aktifkan GPS atau Pilih Kota".
  Future<bool> acquireLiveGps({bool requestPermissionIfNeeded = true}) async {
    if (_isTestEnv) {
      await _loadNearbyForCurrentQuery();
      return false;
    }

    state = state.copyWith(isLocating: true, clearStatusBanner: true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _handleGpsUnavailableFallback(
          gpsServiceDisabled: true,
          permissionDenied: false,
          permissionDeniedForever: false,
          reasonPrefix: 'GPS perangkat tidak aktif',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermissionIfNeeded) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return _handleGpsUnavailableFallback(
          gpsServiceDisabled: false,
          permissionDenied: true,
          permissionDeniedForever: false,
          reasonPrefix: 'Izin lokasi GPS belum diberikan',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        return _handleGpsUnavailableFallback(
          gpsServiceDisabled: false,
          permissionDenied: true,
          permissionDeniedForever: true,
          reasonPrefix: 'Izin lokasi GPS diblokir di pengaturan',
        );
      }

      // Step 1: snap ke last known position (khusus mobile; Windows tidak selalu mendukung)
      if (!Platform.isWindows) {
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            state = state.copyWith(
              userLat: lastKnown.latitude,
              userLng: lastKnown.longitude,
              queryLat: lastKnown.latitude,
              queryLng: lastKnown.longitude,
              locationSource: RadarLocationSource.realGps,
              hasRealGpsFix: true,
              permissionDenied: false,
              permissionDeniedForever: false,
              gpsServiceDisabled: false,
              cameraRevision: state.cameraRevision + 1,
            );
            unawaited(_loadNearbyForCurrentQuery());
          }
        } catch (_) {}
      }

      // Step 2: lock GPS presisi tinggi
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 7),
        ),
      );
      await _applyGpsFix(current, forceReload: true);

      // Step 3: Live stream hemat baterai (25m)
      await _posSub?.cancel();
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 25,
        ),
      ).listen((pos) {
        _applyGpsFix(pos, forceReload: false);
      });
      return true;
    } catch (_) {
      return _handleGpsUnavailableFallback(
        gpsServiceDisabled: true,
        permissionDenied: false,
        permissionDeniedForever: false,
        reasonPrefix: 'Sinyal GPS perangkat tidak tersedia',
      );
    }
  }

  Future<bool> _handleGpsUnavailableFallback({
    required bool gpsServiceDisabled,
    required bool permissionDenied,
    required bool permissionDeniedForever,
    required String reasonPrefix,
  }) async {
    final netLoc = await _routing.detectRealNetworkLocation();
    if (netLoc != null) {
      state = state.copyWith(
        userLat: netLoc.latitude,
        userLng: netLoc.longitude,
        queryLat: netLoc.latitude,
        queryLng: netLoc.longitude,
        locationLabel: netLoc.cityLabel,
        locationSource: RadarLocationSource.networkIp,
        hasRealGpsFix: false,
        gpsServiceDisabled: gpsServiceDisabled,
        permissionDenied: permissionDenied,
        permissionDeniedForever: permissionDeniedForever,
        isLocating: false,
        statusBanner:
            '$reasonPrefix — mendeteksi lokasi jaringan nyata (${netLoc.cityLabel}). Aktifkan GPS perangkat untuk akurasi titik presisi.',
        cameraRevision: state.cameraRevision + 1,
      );
      await _loadNearbyForCurrentQuery();
      return false;
    }

    // Benar-benar offline & GPS mati -> jangan berpura-pura di Jakarta!
    state = state.copyWith(
      locationLabel: 'GPS Tidak Aktif',
      locationSource: RadarLocationSource.unavailable,
      hasRealGpsFix: false,
      gpsServiceDisabled: gpsServiceDisabled,
      permissionDenied: permissionDenied,
      permissionDeniedForever: permissionDeniedForever,
      isLocating: false,
      isLoadingPlaces: false,
      places: const [],
      statusBanner:
          '$reasonPrefix & lokasi jaringan tidak terjangkau. Aktifkan GPS perangkat atau pilih kota Anda secara manual.',
    );
    return false;
  }

  Future<void> _applyGpsFix(Position pos, {required bool forceReload}) async {
    final movedMeters = RadarPlaceCard.haversineMeters(
      state.queryLat,
      state.queryLng,
      pos.latitude,
      pos.longitude,
    );
    final shouldRecenter =
        forceReload || !state.hasRealGpsFix || movedMeters > 80;
    state = state.copyWith(
      userLat: pos.latitude,
      userLng: pos.longitude,
      queryLat: shouldRecenter ? pos.latitude : state.queryLat,
      queryLng: shouldRecenter ? pos.longitude : state.queryLng,
      locationSource: RadarLocationSource.realGps,
      hasRealGpsFix: true,
      permissionDenied: false,
      gpsServiceDisabled: false,
      isLocating: false,
      showSearchAreaButton: false,
      clearStatusBanner: true,
      cameraRevision:
          shouldRecenter ? state.cameraRevision + 1 : state.cameraRevision,
    );
    if (shouldRecenter) {
      unawaited(_reverseGeocode(pos.latitude, pos.longitude));
      await _loadNearbyForCurrentQuery();
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      if (!kIsWeb && Platform.isWindows) {
        final net = await _routing.detectRealNetworkLocation();
        if (net != null) {
          state = state.copyWith(locationLabel: net.cityLabel);
          return;
        }
      }
      final marks = await Geocoding().placemarkFromCoordinates(lat, lng);
      if (marks.isNotEmpty) {
        final p = marks.first;
        final parts = <String>[
          if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
          if ((p.subAdministrativeArea ?? p.locality ?? '').trim().isNotEmpty)
            (p.subAdministrativeArea ?? p.locality)!.trim(),
        ];
        if (parts.isNotEmpty) {
          state = state.copyWith(locationLabel: parts.join(', '));
        }
      }
    } catch (_) {}
  }

  Future<void> selectCityPreset(String name, double lat, double lng) async {
    state = state.copyWith(
      userLat: lat,
      userLng: lng,
      queryLat: lat,
      queryLng: lng,
      locationLabel: name,
      locationSource: RadarLocationSource.manualCity,
      showSearchAreaButton: false,
      clearSelectedPlace: true,
      clearActiveRoute: true,
      clearStatusBanner: true,
      cameraRevision: state.cameraRevision + 1,
    );
    await _loadNearbyForCurrentQuery();
  }

  /// Hitung & gambar garis rute jalan (Polyline) LANGSUNG di dalam peta aplikasi!
  Future<void> requestInAppRoute(
    RadarPlaceCard place, {
    RadarTravelMode? mode,
  }) async {
    final targetMode = mode ?? state.routeMode;
    state = state.copyWith(
      selectedPlaceId: place.id,
      isLoadingRoute: true,
      routeMode: targetMode,
      clearRouteError: true,
    );
    try {
      final route = await _routing.fetchInAppRoadRoute(
        originLat: state.userLat,
        originLng: state.userLng,
        destination: place,
        mode: targetMode,
      );
      state = state.copyWith(
        activeRoute: route,
        isLoadingRoute: false,
        clearRouteError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingRoute: false,
        routeError: 'Gagal menghitung rute jalan: $e',
      );
    }
  }

  Future<void> changeRouteMode(RadarTravelMode mode) async {
    final cur = state.activeRoute;
    if (cur == null) {
      state = state.copyWith(routeMode: mode);
      return;
    }
    await requestInAppRoute(cur.destination, mode: mode);
  }

  void clearActiveRoute() {
    state = state.copyWith(clearActiveRoute: true, clearRouteError: true);
  }

  void onMapBoundsMoved(RadarMapBounds bounds) {
    final distMoved = RadarPlaceCard.haversineMeters(
      state.queryLat,
      state.queryLng,
      bounds.centerLat,
      bounds.centerLng,
    );
    state = state.copyWith(
      pendingMapBounds: bounds,
      showSearchAreaButton: distMoved > 750,
    );
  }

  Future<void> searchPendingMapArea() async {
    final b = state.pendingMapBounds;
    if (b == null) return;
    state = state.copyWith(
      isLoadingPlaces: true,
      queryLat: b.centerLat,
      queryLng: b.centerLng,
      locationLabel: 'Area Peta Dipilih',
      showSearchAreaButton: false,
    );
    final res = await _repo.fetchViewport(
      north: b.north,
      south: b.south,
      east: b.east,
      west: b.west,
      radarMode: state.radarMode,
      category: state.selectedCategory,
      openNowOnly: state.openNowOnly,
      minRating: state.minRating,
      sellsBeansOnly: state.sellsBeansOnly,
    );
    state = state.copyWith(
      places: res.items,
      meta: res.meta,
      isLoadingPlaces: false,
      isOfflineFallback: res.isOfflineFallback,
    );
  }

  void selectPlace(String? placeId) {
    state = state.copyWith(
      selectedPlaceId: placeId,
      clearSelectedPlace: placeId == null,
    );
  }

  Future<void> setCategory(CoffeePlaceCategory cat) async {
    state = state.copyWith(selectedCategory: cat);
    await _loadNearbyForCurrentQuery();
  }

  Future<void> setRadiusKm(double radiusKm) async {
    state = state.copyWith(selectedRadiusKm: radiusKm);
    await _loadNearbyForCurrentQuery();
  }

  Future<void> setSortMode(RadarSortMode mode) async {
    state = state.copyWith(sortMode: mode);
    await _loadNearbyForCurrentQuery();
  }

  Future<void> toggleOpenNow() async {
    state = state.copyWith(openNowOnly: !state.openNowOnly);
    await _loadNearbyForCurrentQuery();
  }

  Future<void> toggleMinRating45() async {
    final next = state.minRating >= 4.5 ? 0.0 : 4.5;
    state = state.copyWith(minRating: next);
    await _loadNearbyForCurrentQuery();
  }

  void onSearchChanged(String val) {
    state = state.copyWith(searchQuery: val);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 280),
      _loadNearbyForCurrentQuery,
    );
  }

  Future<void> _loadNearbyForCurrentQuery() async {
    state = state.copyWith(isLoadingPlaces: true);
    final res = await _repo.fetchNearby(
      lat: state.queryLat,
      lng: state.queryLng,
      radiusKm: state.selectedRadiusKm,
      radarMode: state.radarMode,
      category: state.selectedCategory,
      openNowOnly: state.openNowOnly,
      minRating: state.minRating,
      sellsBeansOnly: state.sellsBeansOnly,
      sort: state.sortMode,
      search: state.searchQuery,
    );
    state = state.copyWith(
      places: res.items,
      meta: res.meta,
      isLoadingPlaces: false,
      isOfflineFallback: res.isOfflineFallback,
    );
  }
}

final beansRadarGpsProvider =
    NotifierProvider<RadarGpsController, RadarGpsState>(
  RadarGpsController.new,
);
