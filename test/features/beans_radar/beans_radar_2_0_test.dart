import 'package:coffee_hub_mobile/features/beans_radar/data/beans_radar_repository.dart';
import 'package:coffee_hub_mobile/features/beans_radar/data/radar_routing_service.dart';
import 'package:coffee_hub_mobile/features/beans_radar/models/beans_radar_models.dart';
import 'package:coffee_hub_mobile/screens/bean_radar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class _FakeBeansRadarRepository extends BeansRadarRepository {
  _FakeBeansRadarRepository() : super(api: null);

  final List<RadarPlaceCard> _seedPlaces = const [
    RadarPlaceCard(
      id: 'place-1',
      slug: 'two-hands-full-dago',
      name: 'Two Hands Full Specialty Coffee',
      category: CoffeePlaceCategory.specialtyCafe,
      radarKind: 'ROASTERY_AND_CAFE',
      subCategories: ['Specialty Cafe', 'Manual Brew V60'],
      latitude: -6.9012,
      longitude: 107.6122,
      h3Res7: '878c1479effffff',
      fullAddress: 'Jl. Ir. H. Juanda No. 113, Coblong, Bandung',
      districtKecamatan: 'Coblong',
      cityKabupaten: 'Bandung',
      province: 'Jawa Barat',
      rating: 4.9,
      reviewsCount: 1420,
      bayesianScore: 4.89,
      priceLevel: 2,
      distanceMeters: 340,
      distanceLabel: '340 m',
      walkEtaMin: 6,
      rideEtaMin: 2,
      openStatus: OpenStatusInfo(
        isOpenNow: true,
        isClosingSoon: false,
        statusLabelId: 'Buka • Tutup 22:00 WIB',
        timezoneAbbr: 'WIB',
      ),
      sellsRoastBeans: true,
      servesCafe: true,
      hasManualBrewV60: true,
      featuredBeanSummary: 'Java Halu Honey • V60',
      thumbnailUrl: '',
      isVerifiedPartner: true,
    ),
    RadarPlaceCard(
      id: 'place-3',
      slug: 'kopi-toko-djawa-braga',
      name: 'Kopi Toko Djawa Braga',
      category: CoffeePlaceCategory.coffeeShop,
      radarKind: 'CAFE',
      subCategories: ['Coffee Shop', 'Cafe'],
      latitude: -6.9178,
      longitude: 107.6095,
      h3Res7: '878c1479effffff',
      fullAddress: 'Jl. Braga No. 81, Bandung',
      districtKecamatan: 'Sumur Bandung',
      cityKabupaten: 'Bandung',
      province: 'Jawa Barat',
      rating: 4.7,
      reviewsCount: 2500,
      bayesianScore: 4.69,
      priceLevel: 2,
      distanceMeters: 850,
      distanceLabel: '850 m',
      walkEtaMin: 11,
      rideEtaMin: 3,
      openStatus: OpenStatusInfo(
        isOpenNow: true,
        isClosingSoon: false,
        statusLabelId: 'Buka • Tutup 22:00 WIB',
        timezoneAbbr: 'WIB',
      ),
      sellsRoastBeans: false,
      servesCafe: true,
      hasManualBrewV60: false,
      featuredBeanSummary: null,
      thumbnailUrl: '',
      isVerifiedPartner: false,
    ),
    RadarPlaceCard(
      id: 'place-2',
      slug: 'fugol-coffee-roasters',
      name: 'Fugol Coffee Roasters Bandung',
      category: CoffeePlaceCategory.roastery,
      radarKind: 'ROASTERY_AND_CAFE',
      subCategories: ['Coffee Roastery', 'Micro Lot'],
      latitude: -6.9095,
      longitude: 107.6198,
      h3Res7: '878c1479effffff',
      fullAddress: 'Jl. Cikutra No. 48, Cibeunying Kaler, Bandung',
      districtKecamatan: 'Cibeunying Kaler',
      cityKabupaten: 'Bandung',
      province: 'Jawa Barat',
      rating: 4.8,
      reviewsCount: 980,
      bayesianScore: 4.79,
      priceLevel: 2,
      distanceMeters: 1450,
      distanceLabel: '1.5 km',
      walkEtaMin: null,
      rideEtaMin: 4,
      openStatus: OpenStatusInfo(
        isOpenNow: true,
        isClosingSoon: false,
        statusLabelId: 'Buka • Tutup 21:00 WIB',
        timezoneAbbr: 'WIB',
      ),
      sellsRoastBeans: true,
      servesCafe: true,
      hasManualBrewV60: true,
      featuredBeanSummary: 'Gayo Anaerobic Natural',
      thumbnailUrl: '',
      isVerifiedPartner: true,
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
    final q = search.trim().toLowerCase();
    final filtered = _seedPlaces
        .where((p) => p.matchesRadarMode(radarMode))
        .where((p) => category == CoffeePlaceCategory.all || p.category == category)
        .where((p) => !openNowOnly || p.openStatus.isOpenNow)
        .where((p) => p.rating >= minRating)
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
        .toList();

    return RadarNearbyResult(
      meta: RadarSearchMeta(
        centerLat: lat,
        centerLng: lng,
        radiusKm: radiusKm,
        queryH3Res7: 'POSTGIS',
        engineLatencyUs: 720,
        cacheTier: 'POSTGIS_GIST_10K',
        totalIndexedPlaces: 10500,
        totalMatched: filtered.length,
      ),
      items: filtered,
    );
  }

  @override
  Future<RadarPlaceDetail?> fetchPlaceDetail(
    String placeId, {
    required double originLat,
    required double originLng,
  }) async {
    final card = _seedPlaces.firstWhere(
      (p) => p.id == placeId,
      orElse: () => _seedPlaces.first,
    );
    return RadarPlaceDetail(
      card: card,
      timezone: 'Asia/Jakarta',
      is24Hours: false,
      openingHours: const {
        'mon': [['08:00', '22:00']],
      },
      phoneNumber: '0812-3456-7890',
      whatsappNumber: '6281234567890',
      instagramHandle: 'coffeelabs.id',
      websiteUrl: 'https://coffeelabs.id',
      isFavorite: false,
      linkedRoasteryLineups: const [],
    );
  }
}

class _FakeRadarRoutingService extends RadarRoutingService {
  _FakeRadarRoutingService() : super(api: null);

  @override
  Future<RadarRouteResult> fetchInAppRoadRoute({
    required double originLat,
    required double originLng,
    required RadarPlaceCard destination,
    required RadarTravelMode mode,
  }) async {
    return RadarRouteResult(
      destination: destination,
      mode: mode,
      provider: 'geoapify',
      cacheHit: true,
      distanceMeters: 1480,
      durationSeconds: mode == RadarTravelMode.walk ? 1080 : 300,
      origin: LatLng(originLat, originLng),
      points: [
        LatLng(originLat, originLng),
        const LatLng(-6.9120, 107.6160),
        LatLng(destination.latitude, destination.longitude),
      ],
      steps: const [
        RadarRouteStep(
          instruction: 'Belok kanan ke Jl. Braga',
          distanceMeters: 740,
          durationSeconds: 150,
        ),
        RadarRouteStep(
          instruction: 'Tiba di lokasi tujuan',
          distanceMeters: 740,
          durationSeconds: 150,
        ),
      ],
    );
  }
}

void main() {
  test('RadarPlaceCard Haversine math & Dual-Scope membership work accurately', () {
    final distMeters = RadarPlaceCard.haversineMeters(
      -6.1944,
      106.8229,
      -6.9015,
      107.6128,
    );
    expect(distMeters, greaterThan(110000));
    expect(distMeters, lessThan(130000));
    expect(RadarPlaceCard.formatDistance(340), '340 m');
    expect(RadarPlaceCard.formatDistance(1840), '1.8 km');

    final repo = _FakeBeansRadarRepository();
    final roasteryAndCafe = repo._seedPlaces[0];
    final cafeOnly = repo._seedPlaces[1];
    expect(roasteryAndCafe.matchesRadarMode(RadarAppMode.cafe), isTrue);
    expect(roasteryAndCafe.matchesRadarMode(RadarAppMode.beans), isTrue);
    expect(cafeOnly.matchesRadarMode(RadarAppMode.cafe), isTrue);
    expect(cafeOnly.matchesRadarMode(RadarAppMode.beans), isFalse);
  });

  testWidgets(
    'Beans Radar & Cafe Radar 3.0 renders dual switcher, in-app road polyline route HUD & detail sheet cleanly at 360x780',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            beansRadarRepositoryProvider.overrideWithValue(
              _FakeBeansRadarRepository(),
            ),
            radarRoutingServiceProvider.overrideWithValue(
              _FakeRadarRoutingService(),
            ),
          ],
          child: const MaterialApp(
            home: BeanRadarScreen(
              enableNetworkTiles: false,
              initialMode: RadarAppMode.cafe,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi Dual Radar Switcher & Search
      expect(find.text('Cafe Radar'), findsOneWidget);
      expect(find.text('Beans Radar'), findsOneWidget);
      expect(find.text('Two Hands Full Specialty Coffee'), findsOneWidget);

      // Expand DraggableScrollableSheet ke 0.90 untuk memverifikasi daftar kafe (termasuk Cafe biasa + Roastery & Cafe)
      final scrollFinder = find.byType(CustomScrollView).first;
      await tester.drag(scrollFinder, const Offset(0, -360));
      await tester.pumpAndSettle();
      expect(find.text('Kopi Toko Djawa Braga'), findsOneWidget);

      // Kembalikan sheet ke posisi semula agar switcher di atas bisa ditekan
      await tester.drag(scrollFinder, const Offset(0, 360));
      await tester.pumpAndSettle();

      // Pindah ke Beans Radar -> Cafe biasa hilang, Roastery & Cafe Penjual Beans tetap ada!
      await tester.tap(find.text('Beans Radar'));
      await tester.pumpAndSettle();
      expect(find.text('Two Hands Full Specialty Coffee'), findsOneWidget);
      expect(find.text('Kopi Toko Djawa Braga'), findsNothing);

      // Simulasi persis skenario user: tarik bottom sheet penuh ke atas (~90%), lalu ketuk "Lihat Rute"
      await tester.drag(scrollFinder, const Offset(0, -360));
      await tester.pumpAndSettle();
      final expandedTopY = tester.getTopLeft(scrollFinder).dy;
      expect(expandedTopY, lessThan(220));

      // Tap "Lihat Rute" -> bottom sheet harus OTOMATIS turun ke bawah & fokus ke peta rute ala Google Maps!
      await tester.tap(find.text('Lihat Rute').first);
      await tester.pumpAndSettle();

      final collapsedTopY = tester.getTopLeft(scrollFinder).dy;
      expect(collapsedTopY, greaterThan(620));
      expect(find.text('1.5 km • 5 mnt'), findsOneWidget);
      expect(find.text('Motor'), findsOneWidget);
      expect(find.text('Mobil'), findsOneWidget);
      expect(find.text('Jalan'), findsOneWidget);
      expect(find.text('Arah'), findsOneWidget);
      expect(find.byTooltip('Fokus ke Rute'), findsOneWidget);
      // Saat dirutekan: hanya pin tujuan rute yang tampil di peta, seluruh pin cafe lain disembunyikan!
      expect(find.byKey(const ValueKey('route_dest_place-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('pin_place-2')), findsNothing);
      expect(find.byKey(const ValueKey('pin_place-3')), findsNothing);
      // Header bar ringkas tetap ter-pin rapi di bagian atas bottom sheet yang turun ke bawah!
      expect(find.text('Daftar'), findsOneWidget);

      // Ketuk nama tujuan pada Route HUD untuk membuka Detail Sheet -> verifikasi CTA 'Lihat Rute di Peta'
      await tester.tap(find.text('Two Hands Full Specialty Coffee').first);
      await tester.pumpAndSettle();
      expect(find.text('Lihat Rute di Peta'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);

      // Ketuk area luar (bagian atas yang redup di luar modal sheet) -> langsung keluar kembali ke peta rute!
      await tester.tapAt(const Offset(180, 50));
      await tester.pumpAndSettle();
      expect(find.text('Lihat Rute di Peta'), findsNothing);

      // Buka lagi lalu ketuk tombol Tutup (X) -> keluar dengan mulus!
      await tester.tap(find.text('Two Hands Full Specialty Coffee').first);
      await tester.pumpAndSettle();
      expect(find.text('Lihat Rute di Peta'), findsOneWidget);
      await tester.tap(find.byTooltip('Tutup Detail'));
      await tester.pumpAndSettle();
      expect(find.text('Lihat Rute di Peta'), findsNothing);

      // Tutup Rute (X) -> kontrol jelajah kembali tampil, bottom sheet naik lagi, & pin cafe lain kembali muncul!
      await tester.tap(find.byTooltip('Tutup Rute'));
      await tester.pumpAndSettle();
      expect(find.text('Beans Radar'), findsOneWidget);
      expect(find.byKey(const ValueKey('route_dest_place-1')), findsNothing);
      final restoredTopY = tester.getTopLeft(scrollFinder).dy;
      expect(restoredTopY, lessThan(520));

      expect(tester.takeException(), isNull);
    },
  );
}
