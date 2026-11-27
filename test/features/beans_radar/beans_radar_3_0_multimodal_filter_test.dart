import 'package:coffee_hub_mobile/features/beans_radar/data/beans_radar_repository.dart';
import 'package:coffee_hub_mobile/features/beans_radar/data/radar_routing_service.dart';
import 'package:coffee_hub_mobile/features/beans_radar/domain/models/multimodal_route_models.dart';
import 'package:coffee_hub_mobile/features/beans_radar/domain/models/radar_filter_state.dart';
import 'package:coffee_hub_mobile/features/beans_radar/models/beans_radar_models.dart';
import 'package:coffee_hub_mobile/features/beans_radar/presentation/controllers/live_navigation_controller.dart';
import 'package:coffee_hub_mobile/features/beans_radar/presentation/controllers/radar_gps_controller.dart';
import 'package:coffee_hub_mobile/screens/bean_radar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class _StrictSeedRepository extends BeansRadarRepository {
  _StrictSeedRepository() : super(api: null);

  final List<RadarPlaceCard> _places = const [
    RadarPlaceCard(
      id: 'tovi-roastery',
      slug: 'tovi-incorporated',
      name: 'Tovi Incorporated Roastery',
      category: CoffeePlaceCategory.roastery,
      radarKind: 'ROASTERY_AND_CAFE',
      subCategories: ['Roastery', 'Manual Brew V60'],
      latitude: -6.9125,
      longitude: 107.6145,
      h3Res7: '878c1479effffff',
      fullAddress: 'Jl. Riung Hegar Raya No. 22, Cisaranten, Gedebage, Bandung',
      districtKecamatan: 'Gedebage',
      cityKabupaten: 'Bandung',
      province: 'Jawa Barat',
      rating: 4.9,
      reviewsCount: 310,
      bayesianScore: 4.86,
      priceLevel: 2,
      distanceMeters: 729,
      distanceLabel: '729 m',
      walkEtaMin: 9,
      rideEtaMin: 3,
      openStatus: OpenStatusInfo(
        isOpenNow: true,
        isClosingSoon: false,
        statusLabelId: 'Buka • Tutup 22:00 WIB',
        timezoneAbbr: 'WIB',
      ),
      sellsRoastBeans: true,
      servesCafe: true,
      hasManualBrewV60: true,
      featuredBeanSummary: 'Java Halu • V60',
      isVerifiedPartner: true,
    ),
    RadarPlaceCard(
      id: 'pure-cafe-braga',
      slug: 'braga-coffee-house',
      name: 'Braga Daily Cafe',
      category: CoffeePlaceCategory.coffeeShop,
      radarKind: 'CAFE',
      subCategories: ['Coffee Shop'],
      latitude: -6.9195,
      longitude: 107.6215,
      h3Res7: '878c1479effffff',
      fullAddress: 'Jl. Gedebage Selatan No. 5, Bandung',
      districtKecamatan: 'Gedebage',
      cityKabupaten: 'Bandung',
      province: 'Jawa Barat',
      rating: 4.7,
      reviewsCount: 540,
      bayesianScore: 4.68,
      priceLevel: 2,
      distanceMeters: 420,
      distanceLabel: '420 m',
      walkEtaMin: 5,
      rideEtaMin: 2,
      openStatus: OpenStatusInfo(
        isOpenNow: true,
        isClosingSoon: false,
        statusLabelId: 'Buka • 08:00 - 22:00 WIB',
        timezoneAbbr: 'WIB',
      ),
      sellsRoastBeans: false,
      servesCafe: true,
      hasManualBrewV60: false,
      isVerifiedPartner: false,
    ),
    RadarPlaceCard(
      id: 'resto-kopi-bistro',
      slug: 'nusa-resto-kopi',
      name: 'Nusa Resto Kopi & Grill',
      category: CoffeePlaceCategory.cafeResto,
      radarKind: 'CAFE',
      subCategories: ['Cafe Resto'],
      latitude: -6.9150,
      longitude: 107.6235,
      h3Res7: '878c1479effffff',
      fullAddress: 'Summarecon Agung Blok B, Bandung',
      districtKecamatan: 'Gedebage',
      cityKabupaten: 'Bandung',
      province: 'Jawa Barat',
      rating: 4.5,
      reviewsCount: 410,
      bayesianScore: 4.49,
      priceLevel: 2,
      distanceMeters: 520,
      distanceLabel: '520 m',
      walkEtaMin: 6,
      rideEtaMin: 2,
      openStatus: OpenStatusInfo(
        isOpenNow: true,
        isClosingSoon: false,
        statusLabelId: 'Buka • 10:00 - 22:00 WIB',
        timezoneAbbr: 'WIB',
      ),
      sellsRoastBeans: false,
      servesCafe: true,
      hasManualBrewV60: false,
      isVerifiedPartner: false,
    ),
  ];

  @override
  Future<RadarNearbyResult> fetchNearby({
    required double lat,
    required double lng,
    double radiusKm = 10.0,
    RadarAppMode radarMode = RadarAppMode.all,
    CoffeePlaceCategory category = CoffeePlaceCategory.all,
    bool openNowOnly = false,
    double minRating = 0.0,
    bool sellsBeansOnly = false,
    RadarSortMode sort = RadarSortMode.nearest,
    String search = '',
    int limit = 80,
  }) async {
    final filter = RadarFilterState(
      radarScope: radarMode,
      strictCategory: StrictRadarCategoryX.fromLegacyCategory(category),
      openNowOnly: openNowOnly,
      minRating: minRating,
      searchQuery: search,
      radiusKm: radiusKm,
    );
    final items = _places.where(filter.matchesPlace).toList();
    return RadarNearbyResult(
      meta: RadarSearchMeta(
        centerLat: lat,
        centerLng: lng,
        radiusKm: radiusKm,
        queryH3Res7: 'POSTGIS',
        engineLatencyUs: 450,
        cacheTier: 'STRICT_TEST',
        totalIndexedPlaces: 3,
        totalMatched: items.length,
      ),
      items: items,
    );
  }
}

class _MultiModalFakeRoutingService extends RadarRoutingService {
  _MultiModalFakeRoutingService() : super(api: null);

  int navigateCallCount = 0;

  @override
  Future<MultiModalRouteComparison> compareAllModes({
    required double originLat,
    required double originLng,
    required RadarPlaceCard destination,
    bool avoidTolls = false,
  }) async {
    final origin = LatLng(originLat, originLng);
    final dest = LatLng(destination.latitude, destination.longitude);

    return MultiModalRouteComparison(
      destination: destination,
      origin: origin,
      timezoneAbbr: 'WIB',
      isRushHour: true,
      avoidTolls: avoidTolls,
      foot: ModeRouteBundle(
        mode: RadarTravelMode.walk,
        primary: RadarRouteAlternative(
          routeId: 'foot_0',
          label: 'Rute Jalan Kaki',
          provider: 'valhalla',
          mode: RadarTravelMode.walk,
          cacheHit: true,
          distanceMeters: 729,
          durationSeconds: 540,
          usesAlleys: true,
          modeBadge: 'Trotoar & Gang • Bebas Macet',
          points: [
            origin,
            const LatLng(-6.9535, 107.6925),
            dest,
          ],
          steps: const [
            RadarRouteStep(
              instruction: 'Jalan kaki lewat gang perumahan ke Jl. Riung Hegar',
              distanceMeters: 729,
              durationSeconds: 540,
            ),
          ],
        ),
      ),
      motorcycle: ModeRouteBundle(
        mode: RadarTravelMode.motorcycle,
        primary: RadarRouteAlternative(
          routeId: 'moto_0',
          label: 'Rute Motor Cepat',
          provider: 'valhalla',
          mode: RadarTravelMode.motorcycle,
          cacheHit: true,
          distanceMeters: 980,
          durationSeconds: 180,
          usesAlleys: true,
          modeBadge: 'Bebas Tol • Lewat Gang',
          points: [
            origin,
            const LatLng(-6.9548, 107.6950),
            dest,
          ],
          steps: const [
            RadarRouteStep(
              instruction: 'Ambil jalur motor lewat Jl. Gedebage Selatan',
              distanceMeters: 980,
              durationSeconds: 180,
            ),
          ],
        ),
        alternatives: [
          RadarRouteAlternative(
            routeId: 'moto_1',
            label: 'Alternatif 1',
            provider: 'valhalla',
            mode: RadarTravelMode.motorcycle,
            cacheHit: false,
            distanceMeters: 1120,
            durationSeconds: 300,
            usesAlleys: true,
            modeBadge: 'Bebas Tol • Lewat Gang',
            points: [
              origin,
              const LatLng(-6.9580, 107.6915),
              dest,
            ],
            steps: const [],
          ),
        ],
      ),
      car: ModeRouteBundle(
        mode: RadarTravelMode.drive,
        primary: RadarRouteAlternative(
          routeId: 'car_0',
          label: 'Rute Mobil',
          provider: 'valhalla',
          mode: RadarTravelMode.drive,
          cacheHit: true,
          distanceMeters: avoidTolls ? 1850 : 2100,
          durationSeconds: avoidTolls ? 480 : 420,
          hasToll: !avoidTolls,
          avoidedTolls: avoidTolls,
          modeBadge: avoidTolls ? 'Non-Tol • Jalur Mobil' : 'Boleh Tol • Jalur Arteri',
          points: [
            origin,
            const LatLng(-6.9595, 107.6970),
            dest,
          ],
          steps: const [
            RadarRouteStep(
              instruction: 'Belok kanan mengikuti Jl. Soekarno-Hatta',
              distanceMeters: 1850,
              durationSeconds: 420,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<RadarRouteResult> navigateLive({
    required double originLat,
    required double originLng,
    required RadarPlaceCard destination,
    required RadarTravelMode mode,
    bool avoidTolls = false,
    double? bearingDeg,
  }) async {
    navigateCallCount++;
    return RadarRouteResult(
      destination: destination,
      mode: mode,
      provider: 'valhalla',
      cacheHit: false,
      distanceMeters: 640,
      durationSeconds: 140,
      origin: LatLng(originLat, originLng),
      points: [
        LatLng(originLat, originLng),
        LatLng(destination.latitude, destination.longitude),
      ],
      steps: const [
        RadarRouteStep(
          instruction: 'Rute baru terhitung menuju tujuan',
          distanceMeters: 640,
          durationSeconds: 140,
        ),
      ],
    );
  }
}

void main() {
  test('RadarFilterState strict 16-bit bitmask prevents pin leakage across scopes & categories', () async {
    final repo = _StrictSeedRepository();
    final all = (await repo.fetchNearby(lat: -6.9565, lng: 107.6942)).items;
    expect(all.length, 3);

    // Beans Radar: ONLY Tovi Roastery (ZERO Braga Daily Cafe, ZERO Nusa Resto Kopi)
    final beansOnly = all.where(
      const RadarFilterState(
        radarScope: RadarAppMode.beans,
        strictCategory: StrictRadarCategory.all,
        openNowOnly: false,
        minRating: 0,
        searchQuery: '',
        radiusKm: 15,
      ).matchesPlace,
    ).toList();
    expect(beansOnly.map((e) => e.id).toList(), ['tovi-roastery']);

    // Cafe category: ONLY Braga Daily Cafe (ZERO Nusa Resto Kopi, ZERO pure Roastery)
    final cafeOnly = all.where(
      const RadarFilterState(
        radarScope: RadarAppMode.cafe,
        strictCategory: StrictRadarCategory.cafe,
        openNowOnly: false,
        minRating: 0,
        searchQuery: '',
        radiusKm: 15,
      ).matchesPlace,
    ).toList();
    expect(cafeOnly.map((e) => e.id).toList(), ['pure-cafe-braga']);

    // Resto category: ONLY Nusa Resto Kopi
    final restoOnly = all.where(
      const RadarFilterState(
        radarScope: RadarAppMode.all,
        strictCategory: StrictRadarCategory.resto,
        openNowOnly: false,
        minRating: 0,
        searchQuery: '',
        radiusKm: 15,
      ).matchesPlace,
    ).toList();
    expect(restoOnly.map((e) => e.id).toList(), ['resto-kopi-bistro']);
  });

  test('Viterbi Snap-to-Road locks <= 25m GPS & LiveNavigation triggers auto-reroute after 3 strikes > 35m', () async {
    const polyline = [
      LatLng(-6.9565, 107.6942),
      LatLng(-6.9510, 107.6942),
    ];
    // 10m east of north-bound polyline with aligned heading (0 deg) -> snapped
    final snap = projectPointOntoPolyline(
      const LatLng(-6.9540, 107.69429),
      polyline,
      headingDeg: 2.0,
    );
    expect(snap.isSnapped, isTrue);
    expect(snap.isOffRoute, isFalse);
    expect(snap.snappedPoint.longitude, closeTo(107.6942, 0.0001));

    // Off-route hysteresis check via ProviderContainer
    final routingFake = _MultiModalFakeRoutingService();
    final repoFake = _StrictSeedRepository();
    final container = ProviderContainer(
      overrides: [
        beansRadarRepositoryProvider.overrideWithValue(repoFake),
        radarRoutingServiceProvider.overrideWithValue(routingFake),
      ],
    );
    addTearDown(container.dispose);

    final places = (await repoFake.fetchNearby(lat: -6.9565, lng: 107.6942)).items;
    final radarCtrl = container.read(beansRadarGpsProvider.notifier);
    await radarCtrl.requestInAppRoute(places.first, mode: RadarTravelMode.motorcycle);

    final navCtrl = container.read(liveNavigationProvider.notifier);
    await navCtrl.startNavigation(container.read(beansRadarGpsProvider).activeRoute!);

    // 3 consecutive samples > 100m away from route -> triggers auto-reroute once
    const farGps = LatLng(-6.9540, 107.6980);
    await navCtrl.onGpsSample(farGps);
    expect(container.read(liveNavigationProvider).offRouteStrikeCount, 1);
    await navCtrl.onGpsSample(farGps);
    expect(container.read(liveNavigationProvider).offRouteStrikeCount, 2);
    await navCtrl.onGpsSample(farGps);
    expect(routingFake.navigateCallCount, 1);
  });

  testWidgets(
    'Beans Radar 3.0 switches distinct Foot/Motor/Car routes, toggles Hindari Tol, & filters strictly with 0 overflow at 360x780',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeRouting = _MultiModalFakeRoutingService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            beansRadarRepositoryProvider.overrideWithValue(_StrictSeedRepository()),
            radarRoutingServiceProvider.overrideWithValue(fakeRouting),
          ],
          child: const MaterialApp(
            home: BeanRadarScreen(
              enableNetworkTiles: false,
              initialMode: RadarAppMode.beans,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In Beans Radar mode, only Tovi Roastery is shown (ZERO Resto Kopi or non-bean Cafe!)
      expect(find.byKey(const ValueKey('pin_tovi-roastery')), findsOneWidget);
      expect(find.byKey(const ValueKey('pin_pure-cafe-braga')), findsNothing);
      expect(find.byKey(const ValueKey('pin_resto-kopi-bistro')), findsNothing);
      expect(find.text('Resto Kopi'), findsNothing); // scoped chip hidden in Beans Radar

      // Switch to Cafe Radar -> strict chips appear, pure Cafe & Resto appear; filter Resto shows ONLY Resto
      await tester.tap(find.text('Cafe Radar'));
      await tester.pumpAndSettle();
      expect(find.text('Resto Kopi'), findsOneWidget);
      await tester.tap(find.text('Resto Kopi'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pin_resto-kopi-bistro')), findsOneWidget);
      expect(find.byKey(const ValueKey('pin_tovi-roastery')), findsNothing);
      expect(find.byKey(const ValueKey('pin_pure-cafe-braga')), findsNothing);

      // Tap Lihat Rute on Resto Kopi -> compares all 3 modes cleanly
      await tester.tap(find.text('Lihat Rute').first);
      await tester.pumpAndSettle();

      expect(find.text('980 m • 3 mnt'), findsOneWidget); // Motor primary
      await tester.tap(find.text('Jalan'));
      await tester.pumpAndSettle();
      expect(find.text('729 m • 9 mnt'), findsOneWidget); // Walking distinct path!

      await tester.tap(find.text('Mobil'));
      await tester.pumpAndSettle();
      expect(find.text('2.1 km • 7 mnt'), findsOneWidget); // Car with toll
      expect(find.text('Hindari Tol'), findsOneWidget);

      await tester.tap(find.text('Hindari Tol'));
      await tester.pumpAndSettle();
      expect(find.text('1.9 km • 8 mnt'), findsOneWidget); // Car non-toll distinct ETA!

      expect(tester.takeException(), isNull);
    },
  );
}
