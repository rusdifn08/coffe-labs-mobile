import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/radar_filter_state.dart';
import '../../models/beans_radar_models.dart';
import 'radar_gps_controller.dart';

/// Single Source of Truth untuk seluruh filter peta & bottom sheet agar 0% pin bocor.
final strictRadarFilterStateProvider = Provider<RadarFilterState>((ref) {
  final s = ref.watch(beansRadarGpsProvider);
  return RadarFilterState(
    radarScope: s.radarMode,
    strictCategory: s.strictCategory,
    openNowOnly: s.openNowOnly,
    minRating: s.minRating,
    searchQuery: s.searchQuery,
    radiusKm: s.selectedRadiusKm,
  );
});

final strictFilteredRadarPlacesProvider = Provider<List<RadarPlaceCard>>((ref) {
  final filter = ref.watch(strictRadarFilterStateProvider);
  final places = ref.watch(beansRadarGpsProvider.select((s) => s.places));
  final filtered = places.where(filter.matchesPlace).toList();
  return filtered;
});

final strictRadarPinSignatureProvider = Provider<String>((ref) {
  final filter = ref.watch(strictRadarFilterStateProvider);
  final places = ref.watch(strictFilteredRadarPlacesProvider);
  final selectedId =
      ref.watch(beansRadarGpsProvider.select((s) => s.selectedPlaceId));
  return filter.signatureFor(places, selectedPlaceId: selectedId);
});
