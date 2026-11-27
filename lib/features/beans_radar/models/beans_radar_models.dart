import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/roastery.dart';

enum RadarAppMode { all, cafe, beans }

extension RadarAppModeX on RadarAppMode {
  String get apiValue {
    switch (this) {
      case RadarAppMode.all:
        return 'ALL';
      case RadarAppMode.cafe:
        return 'CAFE';
      case RadarAppMode.beans:
        return 'BEANS';
    }
  }

  String get title {
    switch (this) {
      case RadarAppMode.all:
        return 'Semua';
      case RadarAppMode.cafe:
        return 'Cafe Radar';
      case RadarAppMode.beans:
        return 'Beans Radar';
    }
  }

  String get searchHint {
    switch (this) {
      case RadarAppMode.cafe:
        return 'Cari cafe, resto, coffee shop...';
      case RadarAppMode.beans:
        return 'Cari roastery, penjual biji kopi...';
      case RadarAppMode.all:
        return 'Cari kafe, roastery, biji kopi...';
    }
  }
}

enum RadarLocationSource {
  detecting,
  realGps,
  networkIp,
  manualCity,
  unavailable,
}

enum RadarTravelMode { motorcycle, drive, walk }

extension RadarTravelModeX on RadarTravelMode {
  String get apiValue {
    switch (this) {
      case RadarTravelMode.motorcycle:
        return 'motorcycle';
      case RadarTravelMode.drive:
        return 'drive';
      case RadarTravelMode.walk:
        return 'walk';
    }
  }

  String get osrmProfile => this == RadarTravelMode.walk ? 'foot' : 'driving';

  String get googleMapsTravelMode {
    switch (this) {
      case RadarTravelMode.walk:
        return 'walking';
      case RadarTravelMode.motorcycle:
        return 'two-wheeler';
      case RadarTravelMode.drive:
        return 'driving';
    }
  }

  String get osrmFossgisBaseUrl {
    switch (this) {
      case RadarTravelMode.walk:
        return 'https://routing.openstreetmap.de/routed-foot/route/v1/foot';
      case RadarTravelMode.motorcycle:
        return 'https://routing.openstreetmap.de/routed-bike/route/v1/driving';
      case RadarTravelMode.drive:
        return 'https://routing.openstreetmap.de/routed-car/route/v1/driving';
    }
  }

  String get backendEnumValue {
    switch (this) {
      case RadarTravelMode.walk:
        return 'FOOT';
      case RadarTravelMode.motorcycle:
        return 'MOTORCYCLE';
      case RadarTravelMode.drive:
        return 'CAR';
    }
  }

  String get label {
    switch (this) {
      case RadarTravelMode.motorcycle:
        return 'Motor';
      case RadarTravelMode.drive:
        return 'Mobil';
      case RadarTravelMode.walk:
        return 'Jalan';
    }
  }

  IconData get icon {
    switch (this) {
      case RadarTravelMode.motorcycle:
        return Icons.two_wheeler_rounded;
      case RadarTravelMode.drive:
        return Icons.directions_car_rounded;
      case RadarTravelMode.walk:
        return Icons.directions_walk_rounded;
    }
  }
}

class RadarRouteStep {
  final String instruction;
  final double distanceMeters;
  final double durationSeconds;
  final String maneuverType;
  final String streetName;
  final double? lat;
  final double? lng;

  const RadarRouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    this.maneuverType = 'continue',
    this.streetName = '',
    this.lat,
    this.lng,
  });

  factory RadarRouteStep.fromJson(Map<String, dynamic> json) {
    return RadarRouteStep(
      instruction: (json['instruction'] ?? 'Ikuti jalur utama').toString(),
      distanceMeters: ((json['distance_meters'] as num?) ?? 0).toDouble(),
      durationSeconds: ((json['duration_seconds'] as num?) ?? 0).toDouble(),
      maneuverType: (json['maneuver_type'] ?? 'continue').toString(),
      streetName: (json['street_name'] ?? '').toString(),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}

class RadarRouteResult {
  final RadarPlaceCard destination;
  final RadarTravelMode mode;
  final String provider;
  final bool cacheHit;
  final double distanceMeters;
  final double durationSeconds;
  final LatLng origin;
  final List<LatLng> points;
  final List<RadarRouteStep> steps;
  final List<dynamic> alternatives;
  final int selectedAlternativeIndex;
  final bool hasToll;
  final bool usesAlleys;
  final String modeBadge;
  final double trafficMultiplier;

  const RadarRouteResult({
    required this.destination,
    required this.mode,
    required this.provider,
    required this.cacheHit,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.origin,
    required this.points,
    required this.steps,
    this.alternatives = const [],
    this.selectedAlternativeIndex = 0,
    this.hasToll = false,
    this.usesAlleys = false,
    this.modeBadge = '',
    this.trafficMultiplier = 1.0,
  });

  String get distanceLabel => RadarPlaceCard.formatDistance(distanceMeters);

  String get durationLabel {
    final mins = (durationSeconds / 60.0).ceil().clamp(1, 999);
    if (mins < 60) return '$mins mnt';
    final h = mins ~/ 60;
    final rem = mins % 60;
    return rem == 0 ? '$h jam' : '$h jam $rem mnt';
  }
}

enum CoffeePlaceCategory {
  all,
  roastery,
  specialtyCafe,
  coffeeShop,
  beanSeller,
  cafeResto,
}

extension CoffeePlaceCategoryX on CoffeePlaceCategory {
  String get apiValue {
    switch (this) {
      case CoffeePlaceCategory.all:
        return 'ALL';
      case CoffeePlaceCategory.roastery:
        return 'ROASTERY';
      case CoffeePlaceCategory.specialtyCafe:
        return 'SPECIALTY_CAFE';
      case CoffeePlaceCategory.coffeeShop:
        return 'COFFEE_SHOP';
      case CoffeePlaceCategory.beanSeller:
        return 'BEAN_SELLER';
      case CoffeePlaceCategory.cafeResto:
        return 'CAFE_RESTO';
    }
  }

  String get chipLabel {
    switch (this) {
      case CoffeePlaceCategory.all:
        return 'Semua';
      case CoffeePlaceCategory.roastery:
        return 'Roastery';
      case CoffeePlaceCategory.specialtyCafe:
        return 'Specialty';
      case CoffeePlaceCategory.coffeeShop:
        return 'Coffee Shop';
      case CoffeePlaceCategory.beanSeller:
        return 'Jual Biji';
      case CoffeePlaceCategory.cafeResto:
        return 'Cafe Resto';
    }
  }

  String get fullLabel {
    switch (this) {
      case CoffeePlaceCategory.all:
        return 'Semua Tempat Kopi';
      case CoffeePlaceCategory.roastery:
        return 'Roastery & Cafe';
      case CoffeePlaceCategory.specialtyCafe:
        return 'Specialty Cafe';
      case CoffeePlaceCategory.coffeeShop:
        return 'Coffee Shop';
      case CoffeePlaceCategory.beanSeller:
        return 'Toko Biji Kopi';
      case CoffeePlaceCategory.cafeResto:
        return 'Cafe & Resto';
    }
  }

  IconData get iconData {
    switch (this) {
      case CoffeePlaceCategory.all:
        return CupertinoIcons.compass_fill;
      case CoffeePlaceCategory.roastery:
        return CupertinoIcons.flame_fill;
      case CoffeePlaceCategory.specialtyCafe:
        return Icons.coffee_maker_rounded;
      case CoffeePlaceCategory.coffeeShop:
        return Icons.coffee_rounded;
      case CoffeePlaceCategory.beanSeller:
        return CupertinoIcons.bag_fill;
      case CoffeePlaceCategory.cafeResto:
        return Icons.restaurant_rounded;
    }
  }

  static CoffeePlaceCategory fromApi(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'ROASTERY':
      case 'ROASTERY_AND_CAFE':
        return CoffeePlaceCategory.roastery;
      case 'SPECIALTY_CAFE':
        return CoffeePlaceCategory.specialtyCafe;
      case 'BEAN_SELLER':
        return CoffeePlaceCategory.beanSeller;
      case 'CAFE_RESTO':
        return CoffeePlaceCategory.cafeResto;
      case 'ALL':
      case 'SEMUA':
        return CoffeePlaceCategory.all;
      default:
        return CoffeePlaceCategory.coffeeShop;
    }
  }
}

enum RadarSortMode { nearest, rating, smart }

extension RadarSortModeX on RadarSortMode {
  String get apiValue {
    switch (this) {
      case RadarSortMode.nearest:
        return 'nearest';
      case RadarSortMode.rating:
        return 'rating';
      case RadarSortMode.smart:
        return 'smart';
    }
  }

  String get label {
    switch (this) {
      case RadarSortMode.nearest:
        return 'Terdekat';
      case RadarSortMode.rating:
        return 'Rating Tertinggi';
      case RadarSortMode.smart:
        return 'Rekomendasi';
    }
  }
}

class OpenStatusInfo {
  final bool isOpenNow;
  final bool isClosingSoon;
  final String statusLabelId;
  final String timezoneAbbr;

  const OpenStatusInfo({
    required this.isOpenNow,
    required this.isClosingSoon,
    required this.statusLabelId,
    required this.timezoneAbbr,
  });

  factory OpenStatusInfo.fromJson(Map<String, dynamic> json) {
    return OpenStatusInfo(
      isOpenNow: json['is_open_now'] == true,
      isClosingSoon: json['is_closing_soon'] == true,
      statusLabelId: (json['status_label_id'] ?? 'Buka').toString(),
      timezoneAbbr: (json['timezone_abbr'] ?? 'WIB').toString(),
    );
  }
}

class RadarPlaceCard {
  final String id;
  final String slug;
  final String? linkedRoasteryId;
  final String name;
  final CoffeePlaceCategory category;
  final String radarKind; // 'CAFE' | 'BEAN_SELLER' | 'ROASTERY_AND_CAFE'
  final List<String> subCategories;
  final double latitude;
  final double longitude;
  final String h3Res7;
  final String fullAddress;
  final String districtKecamatan;
  final String cityKabupaten;
  final String province;
  final double rating;
  final int reviewsCount;
  final double bayesianScore;
  final int priceLevel;
  final double distanceMeters;
  final String distanceLabel;
  final int? walkEtaMin;
  final int rideEtaMin;
  final OpenStatusInfo openStatus;
  final bool sellsRoastBeans;
  final bool servesCafe;
  final bool hasManualBrewV60;
  final String? featuredBeanSummary;
  final String? googleMapsUrl;
  final String? thumbnailUrl;
  final bool isVerifiedPartner;

  const RadarPlaceCard({
    required this.id,
    required this.slug,
    this.linkedRoasteryId,
    required this.name,
    required this.category,
    this.radarKind = 'CAFE',
    required this.subCategories,
    required this.latitude,
    required this.longitude,
    required this.h3Res7,
    required this.fullAddress,
    required this.districtKecamatan,
    required this.cityKabupaten,
    required this.province,
    required this.rating,
    required this.reviewsCount,
    required this.bayesianScore,
    required this.priceLevel,
    required this.distanceMeters,
    required this.distanceLabel,
    this.walkEtaMin,
    required this.rideEtaMin,
    required this.openStatus,
    required this.sellsRoastBeans,
    this.servesCafe = true,
    required this.hasManualBrewV60,
    this.featuredBeanSummary,
    this.googleMapsUrl,
    this.thumbnailUrl,
    required this.isVerifiedPartner,
  });

  bool matchesRadarMode(RadarAppMode mode) {
    switch (mode) {
      case RadarAppMode.all:
        return true;
      case RadarAppMode.cafe:
        if (category == CoffeePlaceCategory.beanSeller && !servesCafe) {
          return false;
        }
        return servesCafe || radarKind == 'CAFE' || radarKind == 'ROASTERY_AND_CAFE';
      case RadarAppMode.beans:
        return sellsRoastBeans ||
            category == CoffeePlaceCategory.roastery ||
            category == CoffeePlaceCategory.beanSeller ||
            radarKind == 'BEAN_SELLER' ||
            radarKind == 'ROASTERY_AND_CAFE';
    }
  }

  String get etaDisplayLabel {
    if (walkEtaMin != null && distanceMeters <= 1200) {
      return '$distanceLabel • 🚶 $walkEtaMin mnt';
    }
    return '$distanceLabel • 🛵 $rideEtaMin mnt';
  }

  String get formattedReviewsCount {
    if (reviewsCount <= 0) return '';
    final digits = reviewsCount.toString();
    final buf = StringBuffer();
    var c = 0;
    for (var i = digits.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(digits[i]);
      c++;
    }
    return '(${buf.toString().split('').reversed.join()})';
  }

  factory RadarPlaceCard.fromJson(Map<String, dynamic> json) {
    final distM = ((json['distance_meters'] as num?) ?? 0).toDouble();
    final kind = (json['kind'] ??
            (json['sells_roast_beans'] == true ? 'ROASTERY_AND_CAFE' : 'CAFE'))
        .toString()
        .toUpperCase();
    final sellsBeans = json['sells_beans'] == true ||
        json['sells_roast_beans'] == true ||
        kind == 'BEAN_SELLER' ||
        kind == 'ROASTERY_AND_CAFE';
    final serves = json['serves_cafe'] != false && kind != 'BEAN_SELLER';

    final featuredList = json['featured_beans'] is List
        ? (json['featured_beans'] as List).map((e) => e.toString()).toList()
        : const <String>[];
    final methodsList = json['brewing_methods'] is List
        ? (json['brewing_methods'] as List).map((e) => e.toString()).toList()
        : const <String>[];

    final catRaw = (json['category'] ?? json['category_tag'] ?? kind).toString();
    final tz = (json['timezone'] ?? 'Asia/Jakarta').toString();
    final tzAbbr = tz.contains('Jayapura')
        ? 'WIT'
        : (tz.contains('Makassar') ? 'WITA' : 'WIB');

    return RadarPlaceCard(
      id: (json['id'] ?? '').toString(),
      slug: (json['slug'] ?? json['id'] ?? '').toString(),
      linkedRoasteryId: json['linked_roastery_id']?.toString(),
      name: (json['name'] ?? '').toString(),
      category: CoffeePlaceCategoryX.fromApi(catRaw),
      radarKind: kind,
      subCategories: (json['sub_categories'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          methodsList,
      latitude: ((json['latitude'] as num?) ?? 0).toDouble(),
      longitude: ((json['longitude'] as num?) ?? 0).toDouble(),
      h3Res7: (json['h3_res7'] ?? '').toString(),
      fullAddress: (json['full_address'] ?? json['address'] ?? '').toString(),
      districtKecamatan:
          (json['district_kecamatan'] ?? json['district'] ?? '').toString(),
      cityKabupaten:
          (json['city_kabupaten'] ?? json['city'] ?? '').toString(),
      province: (json['province'] ?? 'Indonesia').toString(),
      rating: ((json['rating'] as num?) ?? 4.5).toDouble(),
      reviewsCount: ((json['reviews_count'] as num?) ?? 0).toInt(),
      bayesianScore: ((json['bayesian_score'] as num?) ?? 4.45).toDouble(),
      priceLevel: ((json['price_level'] as num?) ?? 2).toInt(),
      distanceMeters: distM,
      distanceLabel:
          (json['distance_label'] ?? formatDistance(distM)).toString(),
      walkEtaMin: (json['walk_eta_min'] as num?)?.toInt() ??
          (json['eta_walking_min'] as num?)?.toInt(),
      rideEtaMin: ((json['ride_eta_min'] as num?) ??
              (json['eta_driving_min'] as num?) ??
              math.max(1, (distM / 450.0).ceil()))
          .toInt(),
      openStatus: json['open_status'] is Map<String, dynamic>
          ? OpenStatusInfo.fromJson(json['open_status'] as Map<String, dynamic>)
          : OpenStatusInfo(
              isOpenNow: true,
              isClosingSoon: false,
              statusLabelId: 'Buka • 08:00 - 22:00 $tzAbbr',
              timezoneAbbr: tzAbbr,
            ),
      sellsRoastBeans: sellsBeans,
      servesCafe: serves,
      hasManualBrewV60: json['has_manual_brew_v60'] == true ||
          methodsList.any((m) => m.toUpperCase().contains('V60')),
      featuredBeanSummary: json['featured_bean_summary']?.toString() ??
          (featuredList.isNotEmpty ? featuredList.first : null),
      googleMapsUrl: json['google_maps_url']?.toString(),
      thumbnailUrl: (json['thumbnail_url'] ?? json['image_url'])?.toString(),
      isVerifiedPartner:
          json['is_verified_partner'] == true || json['is_verified'] == true,
    );
  }

  factory RadarPlaceCard.fromCompactAssetJson(
    Map<String, dynamic> m, {
    required double originLat,
    required double originLng,
  }) {
    final lat = ((m['lat'] as num?) ?? 0).toDouble();
    final lng = ((m['lng'] as num?) ?? 0).toDouble();
    final distM = haversineMeters(originLat, originLng, lat, lng);
    final roadM = math.max(10.0, distM) * 1.32;
    final walkMin = distM <= 1200 ? (roadM / 81.0).ceil().clamp(1, 30) : null;
    final rideMin = (roadM / 410.0).ceil().clamp(1, 240);
    final kind = (m['k'] ?? 'CAFE').toString().toUpperCase();
    final sellsBeans = kind == 'BEAN_SELLER' || kind == 'ROASTERY_AND_CAFE';
    final serves = kind != 'BEAN_SELLER';
    final fb = (m['fb'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    final bm = (m['bm'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    final tz = (m['tz'] ?? 'Asia/Jakarta').toString();
    final tzAbbr = tz.contains('Jayapura')
        ? 'WIT'
        : (tz.contains('Makassar') ? 'WITA' : 'WIB');
    final rt = ((m['rt'] as num?) ?? 4.5).toDouble();
    final rc = ((m['rc'] as num?) ?? 0).toInt();

    return RadarPlaceCard(
      id: (m['id'] ?? '').toString(),
      slug: (m['id'] ?? '').toString(),
      name: (m['n'] ?? '').toString(),
      category: CoffeePlaceCategoryX.fromApi((m['cat'] ?? kind).toString()),
      radarKind: kind,
      subCategories: bm,
      latitude: lat,
      longitude: lng,
      h3Res7: '',
      fullAddress: (m['addr'] ?? '').toString(),
      districtKecamatan: (m['dist'] ?? '').toString(),
      cityKabupaten: (m['city'] ?? '').toString(),
      province: (m['prov'] ?? 'Indonesia').toString(),
      rating: rt,
      reviewsCount: rc,
      bayesianScore: (rc * rt + 25 * 4.45) / (rc + 25.0),
      priceLevel: 2,
      distanceMeters: distM,
      distanceLabel: formatDistance(distM),
      walkEtaMin: walkMin,
      rideEtaMin: rideMin,
      openStatus: OpenStatusInfo(
        isOpenNow: true,
        isClosingSoon: false,
        statusLabelId: 'Buka • 08:00 - 22:00 $tzAbbr',
        timezoneAbbr: tzAbbr,
      ),
      sellsRoastBeans: sellsBeans,
      servesCafe: serves,
      hasManualBrewV60: bm.any((e) => e.toUpperCase().contains('V60')),
      featuredBeanSummary: fb.isNotEmpty ? fb.first : null,
      googleMapsUrl:
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      thumbnailUrl: m['img']?.toString(),
      isVerifiedPartner: m['ver'] == true,
    );
  }

  factory RadarPlaceCard.fromRoasteryFallback({
    required Roastery roastery,
    required double originLat,
    required double originLng,
  }) {
    final distMeters = haversineMeters(
      originLat,
      originLng,
      roastery.latitude,
      roastery.longitude,
    );
    final roadM = math.max(10.0, distMeters) * 1.32;
    final walkMin =
        distMeters <= 1200 ? (roadM / (1.35 * 60)).ceil().clamp(1, 30) : null;
    final rideMin = (roadM / (6.8 * 60)).ceil().clamp(1, 180);
    final firstBean = roastery.lineups.isNotEmpty ? roastery.lineups.first : null;
    final safeAddr =
        roastery.address.toLowerCase().contains('jl. roastery no. 75')
            ? roastery.location
            : roastery.address;

    return RadarPlaceCard(
      id: roastery.id,
      slug: roastery.id,
      linkedRoasteryId: roastery.id,
      name: roastery.name,
      category: CoffeePlaceCategory.roastery,
      radarKind: 'ROASTERY_AND_CAFE',
      subCategories: const ['Coffee Roastery', 'Manual Brew V60'],
      latitude: roastery.latitude,
      longitude: roastery.longitude,
      h3Res7: '',
      fullAddress: safeAddr,
      districtKecamatan: '',
      cityKabupaten: roastery.location,
      province: 'Indonesia',
      rating: roastery.rating,
      reviewsCount: 48,
      bayesianScore: (48 * roastery.rating + 25 * 4.45) / 73.0,
      priceLevel: 2,
      distanceMeters: distMeters,
      distanceLabel: formatDistance(distMeters),
      walkEtaMin: walkMin,
      rideEtaMin: rideMin,
      openStatus: const OpenStatusInfo(
        isOpenNow: true,
        isClosingSoon: false,
        statusLabelId: 'Buka • 08:00 - 22:00 WIB',
        timezoneAbbr: 'WIB',
      ),
      sellsRoastBeans: true,
      servesCafe: true,
      hasManualBrewV60: true,
      featuredBeanSummary: firstBean != null
          ? '${firstBean.name} • ${firstBean.price200g}/200g'
          : roastery.salesHighlight,
      googleMapsUrl:
          'https://www.google.com/maps/dir/?api=1&destination=${roastery.latitude},${roastery.longitude}',
      thumbnailUrl: roastery.imageUrl.startsWith('http')
          ? roastery.imageUrl
          : 'assets/images/roasteries/${roastery.id}.png',
      isVerifiedPartner: true,
    );
  }

  static double haversineMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const r = 6371008.8;
    const p = math.pi / 180.0;
    final phi1 = lat1 * p;
    final phi2 = lat2 * p;
    final dPhi = (lat2 - lat1) * p;
    final dLmb = (lng2 - lng1) * p;
    final a = math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) * math.cos(phi2) * math.sin(dLmb / 2) * math.sin(dLmb / 2);
    return 2.0 * r * math.atan2(math.sqrt(a), math.sqrt(math.max(0.0, 1.0 - a)));
  }

  static String formatDistance(double meters) {
    if (meters < 1000.0) return '${meters.round()} m';
    return '${(meters / 1000.0).toStringAsFixed(1)} km';
  }
}

class RadarLineupPreview {
  final String id;
  final String name;
  final String origin;
  final String roastProfile;
  final String process;
  final String tastingNotes;
  final String price100gLabel;
  final String price200gLabel;
  final String? bagImageUrl;
  final String? badge;

  const RadarLineupPreview({
    required this.id,
    required this.name,
    required this.origin,
    required this.roastProfile,
    required this.process,
    required this.tastingNotes,
    required this.price100gLabel,
    required this.price200gLabel,
    this.bagImageUrl,
    this.badge,
  });

  factory RadarLineupPreview.fromJson(Map<String, dynamic> json) {
    return RadarLineupPreview(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      origin: (json['origin'] ?? '').toString(),
      roastProfile: (json['roast_profile'] ?? '').toString(),
      process: (json['process'] ?? '').toString(),
      tastingNotes: (json['tasting_notes'] ?? '').toString(),
      price100gLabel: (json['price_100g_label'] ?? '').toString(),
      price200gLabel: (json['price_200g_label'] ?? '').toString(),
      bagImageUrl: json['bag_image_url']?.toString(),
      badge: json['badge']?.toString(),
    );
  }
}

class RadarPlaceDetail {
  final RadarPlaceCard card;
  final String timezone;
  final bool is24Hours;
  final Map<String, List<List<String>>> openingHours;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? instagramHandle;
  final String? websiteUrl;
  final bool isFavorite;
  final List<RadarLineupPreview> linkedRoasteryLineups;

  const RadarPlaceDetail({
    required this.card,
    required this.timezone,
    required this.is24Hours,
    required this.openingHours,
    this.phoneNumber,
    this.whatsappNumber,
    this.instagramHandle,
    this.websiteUrl,
    required this.isFavorite,
    required this.linkedRoasteryLineups,
  });

  factory RadarPlaceDetail.fromJson(Map<String, dynamic> json) {
    final hoursMap = <String, List<List<String>>>{};
    if (json['opening_hours'] is Map) {
      (json['opening_hours'] as Map).forEach((k, v) {
        if (v is List) {
          hoursMap[k.toString()] = v
              .whereType<List>()
              .map((pair) => pair.map((e) => e.toString()).toList())
              .toList();
        }
      });
    }
    return RadarPlaceDetail(
      card: RadarPlaceCard.fromJson(
        (json['card'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      timezone: (json['timezone'] ?? 'Asia/Jakarta').toString(),
      is24Hours: json['is_24_hours'] == true,
      openingHours: hoursMap,
      phoneNumber: json['phone_number']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString(),
      instagramHandle: json['instagram_handle']?.toString(),
      websiteUrl: json['website_url']?.toString(),
      isFavorite: json['is_favorite'] == true,
      linkedRoasteryLineups: (json['linked_roastery_lineups'] as List?)
              ?.whereType<Map>()
              .map((e) => RadarLineupPreview.fromJson(e.cast<String, dynamic>()))
              .toList() ??
          const [],
    );
  }
}

class RadarSearchMeta {
  final double centerLat;
  final double centerLng;
  final double radiusKm;
  final String queryH3Res7;
  final int engineLatencyUs;
  final String cacheTier;
  final int totalIndexedPlaces;
  final int totalMatched;

  const RadarSearchMeta({
    required this.centerLat,
    required this.centerLng,
    required this.radiusKm,
    required this.queryH3Res7,
    required this.engineLatencyUs,
    required this.cacheTier,
    required this.totalIndexedPlaces,
    required this.totalMatched,
  });

  factory RadarSearchMeta.fromJson(Map<String, dynamic> json) {
    return RadarSearchMeta(
      centerLat: ((json['center_lat'] as num?) ?? -6.9175).toDouble(),
      centerLng: ((json['center_lng'] as num?) ?? 107.6191).toDouble(),
      radiusKm: ((json['radius_km'] as num?) ?? 10.0).toDouble(),
      queryH3Res7: (json['query_h3_res7'] ?? '').toString(),
      engineLatencyUs: ((json['engine_latency_us'] as num?) ?? 0).toInt(),
      cacheTier: (json['cache_tier'] ?? 'POSTGIS_GIST').toString(),
      totalIndexedPlaces:
          ((json['total_indexed_places'] as num?) ?? 10000).toInt(),
      totalMatched: ((json['total_matched'] as num?) ?? 0).toInt(),
    );
  }
}

class RadarNearbyResult {
  final RadarSearchMeta meta;
  final List<RadarPlaceCard> items;
  final bool isOfflineFallback;

  const RadarNearbyResult({
    required this.meta,
    required this.items,
    this.isOfflineFallback = false,
  });
}
