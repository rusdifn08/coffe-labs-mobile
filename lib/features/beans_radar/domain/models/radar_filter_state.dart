import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/beans_radar_models.dart';

/// Mirror dari 16-bit Category Bitmask pada Rust `src/modules/beans_radar/category_bitmask.rs`.
class RadarCategoryBitmask {
  static const int flagRoastery = 1 << 0; // 0x0001
  static const int flagBeanSeller = 1 << 1; // 0x0002
  static const int flagSpecialtyCafe = 1 << 2; // 0x0004
  static const int flagCoffeeShop = 1 << 3; // 0x0008
  static const int flagCafeResto = 1 << 4; // 0x0010
  static const int flagSlowBarV60 = 1 << 5; // 0x0020

  static int computeForPlace(RadarPlaceCard place) {
    var flags = 0;
    switch (place.category) {
      case CoffeePlaceCategory.roastery:
        flags |= flagRoastery | flagBeanSeller;
        break;
      case CoffeePlaceCategory.beanSeller:
        flags |= flagBeanSeller;
        break;
      case CoffeePlaceCategory.specialtyCafe:
        flags |= flagSpecialtyCafe;
        break;
      case CoffeePlaceCategory.cafeResto:
        flags |= flagCafeResto;
        break;
      case CoffeePlaceCategory.coffeeShop:
      case CoffeePlaceCategory.all:
        flags |= flagCoffeeShop;
        break;
    }

    if (place.radarKind == 'ROASTERY_AND_CAFE') {
      flags |= flagRoastery | flagBeanSeller;
    } else if (place.radarKind == 'BEAN_SELLER') {
      flags |= flagBeanSeller;
    }

    if (place.sellsRoastBeans) {
      flags |= flagBeanSeller;
    }
    if (place.hasManualBrewV60) {
      flags |= flagSlowBarV60;
    }
    return flags;
  }
}

enum StrictRadarCategory {
  all,
  roastery,
  beanSeller,
  cafe,
  specialtyCafe,
  resto,
  slowBar,
}

extension StrictRadarCategoryX on StrictRadarCategory {
  String get apiValue {
    switch (this) {
      case StrictRadarCategory.all:
        return 'ALL';
      case StrictRadarCategory.roastery:
        return 'ROASTERY';
      case StrictRadarCategory.beanSeller:
        return 'BEAN_SELLER';
      case StrictRadarCategory.cafe:
        return 'CAFE';
      case StrictRadarCategory.specialtyCafe:
        return 'SPECIALTY_CAFE';
      case StrictRadarCategory.resto:
        return 'RESTO';
      case StrictRadarCategory.slowBar:
        return 'SLOW_BAR';
    }
  }

  String chipLabelForScope(RadarAppMode scope) {
    switch (this) {
      case StrictRadarCategory.all:
        if (scope == RadarAppMode.beans) return 'Semua Beans';
        if (scope == RadarAppMode.cafe) return 'Semua Cafe';
        return 'Semua';
      case StrictRadarCategory.roastery:
        return 'Roastery';
      case StrictRadarCategory.beanSeller:
        return 'Penjual Biji';
      case StrictRadarCategory.cafe:
        return 'Cafe';
      case StrictRadarCategory.specialtyCafe:
        return 'Specialty';
      case StrictRadarCategory.resto:
        return 'Resto Kopi';
      case StrictRadarCategory.slowBar:
        return 'Slow Bar / V60';
    }
  }

  IconData get iconData {
    switch (this) {
      case StrictRadarCategory.all:
        return CupertinoIcons.compass_fill;
      case StrictRadarCategory.roastery:
        return CupertinoIcons.flame_fill;
      case StrictRadarCategory.beanSeller:
        return CupertinoIcons.bag_fill;
      case StrictRadarCategory.cafe:
        return Icons.coffee_rounded;
      case StrictRadarCategory.specialtyCafe:
        return Icons.coffee_maker_rounded;
      case StrictRadarCategory.resto:
        return Icons.restaurant_rounded;
      case StrictRadarCategory.slowBar:
        return CupertinoIcons.drop_fill;
    }
  }

  CoffeePlaceCategory toLegacyCategory() {
    switch (this) {
      case StrictRadarCategory.roastery:
        return CoffeePlaceCategory.roastery;
      case StrictRadarCategory.beanSeller:
        return CoffeePlaceCategory.beanSeller;
      case StrictRadarCategory.cafe:
        return CoffeePlaceCategory.coffeeShop;
      case StrictRadarCategory.specialtyCafe:
        return CoffeePlaceCategory.specialtyCafe;
      case StrictRadarCategory.resto:
        return CoffeePlaceCategory.cafeResto;
      case StrictRadarCategory.all:
      case StrictRadarCategory.slowBar:
        return CoffeePlaceCategory.all;
    }
  }

  static StrictRadarCategory fromLegacyCategory(CoffeePlaceCategory cat) {
    switch (cat) {
      case CoffeePlaceCategory.roastery:
        return StrictRadarCategory.roastery;
      case CoffeePlaceCategory.beanSeller:
        return StrictRadarCategory.beanSeller;
      case CoffeePlaceCategory.coffeeShop:
        return StrictRadarCategory.cafe;
      case CoffeePlaceCategory.specialtyCafe:
        return StrictRadarCategory.specialtyCafe;
      case CoffeePlaceCategory.cafeResto:
        return StrictRadarCategory.resto;
      case CoffeePlaceCategory.all:
        return StrictRadarCategory.all;
    }
  }
}

/// Unified Single-Source-of-Truth Filter State untuk Peta (`SuperclusterLayer`) & Daftar Bawah.
@immutable
class RadarFilterState {
  final RadarAppMode radarScope;
  final StrictRadarCategory strictCategory;
  final bool openNowOnly;
  final double minRating;
  final String searchQuery;
  final double radiusKm;

  const RadarFilterState({
    required this.radarScope,
    required this.strictCategory,
    required this.openNowOnly,
    required this.minRating,
    required this.searchQuery,
    required this.radiusKm,
  });

  List<StrictRadarCategory> get availableCategories {
    switch (radarScope) {
      case RadarAppMode.beans:
        return const [
          StrictRadarCategory.all,
          StrictRadarCategory.roastery,
          StrictRadarCategory.beanSeller,
          StrictRadarCategory.slowBar,
        ];
      case RadarAppMode.cafe:
        return const [
          StrictRadarCategory.all,
          StrictRadarCategory.cafe,
          StrictRadarCategory.resto,
          StrictRadarCategory.specialtyCafe,
          StrictRadarCategory.slowBar,
        ];
      case RadarAppMode.all:
        return const [
          StrictRadarCategory.all,
          StrictRadarCategory.roastery,
          StrictRadarCategory.cafe,
          StrictRadarCategory.resto,
          StrictRadarCategory.specialtyCafe,
          StrictRadarCategory.beanSeller,
          StrictRadarCategory.slowBar,
        ];
    }
  }

  bool matchesPlace(RadarPlaceCard place) {
    final flags = RadarCategoryBitmask.computeForPlace(place);

    final bool scopeOk;
    switch (radarScope) {
      case RadarAppMode.all:
        scopeOk = true;
        break;
      case RadarAppMode.beans:
        scopeOk = (flags &
                (RadarCategoryBitmask.flagRoastery |
                    RadarCategoryBitmask.flagBeanSeller)) !=
            0;
        break;
      case RadarAppMode.cafe:
        scopeOk = (flags &
                (RadarCategoryBitmask.flagSpecialtyCafe |
                    RadarCategoryBitmask.flagCoffeeShop |
                    RadarCategoryBitmask.flagCafeResto |
                    RadarCategoryBitmask.flagRoastery)) !=
            0;
        break;
    }
    if (!scopeOk) return false;

    switch (strictCategory) {
      case StrictRadarCategory.all:
        break;
      case StrictRadarCategory.roastery:
        if ((flags & RadarCategoryBitmask.flagRoastery) == 0) return false;
        break;
      case StrictRadarCategory.beanSeller:
        if ((flags & RadarCategoryBitmask.flagBeanSeller) == 0) return false;
        break;
      case StrictRadarCategory.cafe:
        if ((flags &
                    (RadarCategoryBitmask.flagSpecialtyCafe |
                        RadarCategoryBitmask.flagCoffeeShop)) ==
                0 ||
            (flags & RadarCategoryBitmask.flagCafeResto) != 0) {
          return false;
        }
        break;
      case StrictRadarCategory.specialtyCafe:
        if ((flags & RadarCategoryBitmask.flagSpecialtyCafe) == 0) return false;
        break;
      case StrictRadarCategory.resto:
        if ((flags & RadarCategoryBitmask.flagCafeResto) == 0) return false;
        break;
      case StrictRadarCategory.slowBar:
        if ((flags & RadarCategoryBitmask.flagSlowBarV60) == 0) return false;
        break;
    }

    if (openNowOnly && !place.openStatus.isOpenNow) return false;
    if (place.rating < minRating) return false;

    final needle = searchQuery.trim().toLowerCase();
    if (needle.isNotEmpty) {
      final hit = place.name.toLowerCase().contains(needle) ||
          place.fullAddress.toLowerCase().contains(needle) ||
          place.cityKabupaten.toLowerCase().contains(needle) ||
          place.districtKecamatan.toLowerCase().contains(needle) ||
          (place.featuredBeanSummary ?? '').toLowerCase().contains(needle);
      if (!hit) return false;
    }
    return true;
  }

  String signatureFor(List<RadarPlaceCard> places, {String? selectedPlaceId}) {
    final idsHash = Object.hashAll(places.map((p) => p.id));
    return '${radarScope.apiValue}_${strictCategory.apiValue}_${openNowOnly}_${minRating.toStringAsFixed(1)}_${searchQuery.trim()}_${radiusKm.toInt()}_${places.length}_${idsHash}_${selectedPlaceId ?? 'none'}';
  }
}
