import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../models/beans_radar_models.dart';

@immutable
class RadarRouteAlternative {
  final String routeId;
  final String label;
  final String provider;
  final RadarTravelMode mode;
  final bool cacheHit;
  final double distanceMeters;
  final double durationSeconds;
  final double trafficMultiplier;
  final bool hasToll;
  final bool avoidedTolls;
  final bool usesAlleys;
  final String modeBadge;
  final List<LatLng> points;
  final List<RadarRouteStep> steps;

  const RadarRouteAlternative({
    required this.routeId,
    required this.label,
    required this.provider,
    required this.mode,
    required this.cacheHit,
    required this.distanceMeters,
    required this.durationSeconds,
    this.trafficMultiplier = 1.0,
    this.hasToll = false,
    this.avoidedTolls = true,
    this.usesAlleys = false,
    this.modeBadge = '',
    required this.points,
    this.steps = const [],
  });

  String get distanceLabel => RadarPlaceCard.formatDistance(distanceMeters);

  String get durationLabel {
    final mins = (durationSeconds / 60.0).ceil().clamp(1, 999);
    if (mins < 60) return '$mins mnt';
    final h = mins ~/ 60;
    final rem = mins % 60;
    return rem == 0 ? '$h jam' : '$h jam $rem mnt';
  }

  String deltaMinutesLabel(RadarRouteAlternative fastest) {
    final diffMin = ((durationSeconds - fastest.durationSeconds) / 60.0).round();
    if (diffMin <= 0) return 'Tercepat';
    return '+$diffMin mnt';
  }

  factory RadarRouteAlternative.fromBackendJson(
    Map<String, dynamic> json, {
    required RadarTravelMode fallbackMode,
  }) {
    final poly6 = (json['polyline6'] ?? '').toString();
    var pts = parseBackendLatLngs(json['coordinates']);
    if (pts.length < 2 && poly6.isNotEmpty) {
      pts = decodePolyline6(poly6);
    }
    final steps = (json['steps'] as List? ?? const [])
        .whereType<Map>()
        .map((s) => RadarRouteStep.fromJson(s.cast<String, dynamic>()))
        .toList();

    return RadarRouteAlternative(
      routeId: (json['route_id'] ?? 'route_0').toString(),
      label: (json['label'] ?? 'Rute Terbaik').toString(),
      provider: (json['provider'] ?? 'backend').toString(),
      mode: parseBackendTravelMode(json['mode']?.toString(), fallbackMode),
      cacheHit: json['cache_hit'] == true,
      distanceMeters: ((json['distance_meters'] as num?) ?? 0).toDouble(),
      durationSeconds: ((json['duration_seconds'] as num?) ?? 0).toDouble(),
      trafficMultiplier:
          ((json['traffic_multiplier'] as num?) ?? 1.0).toDouble(),
      hasToll: json['has_toll'] == true,
      avoidedTolls: json['avoided_tolls'] == true,
      usesAlleys: json['uses_alleys'] == true,
      modeBadge: (json['mode_badge'] ?? '').toString(),
      points: pts,
      steps: steps,
    );
  }
}

@immutable
class ModeRouteBundle {
  final RadarTravelMode mode;
  final RadarRouteAlternative primary;
  final List<RadarRouteAlternative> alternatives;

  const ModeRouteBundle({
    required this.mode,
    required this.primary,
    this.alternatives = const [],
  });

  List<RadarRouteAlternative> get allRoutes => [primary, ...alternatives];

  factory ModeRouteBundle.fromBackendJson(
    Map<String, dynamic> json,
    RadarTravelMode fallbackMode,
  ) {
    final pJson = (json['primary'] as Map?)?.cast<String, dynamic>() ?? const {};
    final primary = RadarRouteAlternative.fromBackendJson(
      pJson,
      fallbackMode: fallbackMode,
    );
    final alts = (json['alternatives'] as List? ?? const [])
        .whereType<Map>()
        .map((a) => RadarRouteAlternative.fromBackendJson(
              a.cast<String, dynamic>(),
              fallbackMode: fallbackMode,
            ))
        .where((a) => a.points.length >= 2)
        .toList();
    return ModeRouteBundle(mode: primary.mode, primary: primary, alternatives: alts);
  }
}

@immutable
class MultiModalRouteComparison {
  final RadarPlaceCard destination;
  final LatLng origin;
  final String timezoneAbbr;
  final bool isRushHour;
  final bool avoidTolls;
  final ModeRouteBundle foot;
  final ModeRouteBundle motorcycle;
  final ModeRouteBundle car;

  const MultiModalRouteComparison({
    required this.destination,
    required this.origin,
    this.timezoneAbbr = 'WIB',
    this.isRushHour = false,
    this.avoidTolls = false,
    required this.foot,
    required this.motorcycle,
    required this.car,
  });

  ModeRouteBundle bundleFor(RadarTravelMode mode) {
    switch (mode) {
      case RadarTravelMode.walk:
        return foot;
      case RadarTravelMode.motorcycle:
        return motorcycle;
      case RadarTravelMode.drive:
        return car;
    }
  }

  RadarRouteResult toActiveRouteResult({
    required RadarTravelMode mode,
    int selectedAltIndex = 0,
  }) {
    final bundle = bundleFor(mode);
    final list = bundle.allRoutes;
    final safeIdx =
        selectedAltIndex >= 0 && selectedAltIndex < list.length ? selectedAltIndex : 0;
    final chosen = list[safeIdx];
    return RadarRouteResult(
      destination: destination,
      mode: mode,
      provider: chosen.provider,
      cacheHit: chosen.cacheHit,
      distanceMeters: chosen.distanceMeters,
      durationSeconds: chosen.durationSeconds,
      origin: origin,
      points: chosen.points,
      steps: chosen.steps,
      alternatives: list,
      selectedAlternativeIndex: safeIdx,
      hasToll: chosen.hasToll,
      usesAlleys: chosen.usesAlleys,
      modeBadge: chosen.modeBadge,
      trafficMultiplier: chosen.trafficMultiplier,
    );
  }
}

@immutable
class SnapToRoadProjection {
  final LatLng snappedPoint;
  final double crossTrackMeters;
  final int closestSegmentIndex;
  final double segmentBearingDeg;
  final double remainingMeters;
  final bool isSnapped;
  final bool isOffRoute;

  const SnapToRoadProjection({
    required this.snappedPoint,
    required this.crossTrackMeters,
    required this.closestSegmentIndex,
    required this.segmentBearingDeg,
    required this.remainingMeters,
    required this.isSnapped,
    required this.isOffRoute,
  });
}

@immutable
class LiveNavigationState {
  final bool isActive;
  final bool isRerouting;
  final bool voiceMuted;
  final int offRouteStrikeCount;
  final int activeStepIndex;
  final String currentInstruction;
  final double remainingDistanceMeters;
  final double remainingDurationSeconds;
  final LatLng? snappedPosition;
  final double? currentBearingDeg;

  const LiveNavigationState({
    this.isActive = false,
    this.isRerouting = false,
    this.voiceMuted = false,
    this.offRouteStrikeCount = 0,
    this.activeStepIndex = 0,
    this.currentInstruction = '',
    this.remainingDistanceMeters = 0,
    this.remainingDurationSeconds = 0,
    this.snappedPosition,
    this.currentBearingDeg,
  });

  LiveNavigationState copyWith({
    bool? isActive,
    bool? isRerouting,
    bool? voiceMuted,
    int? offRouteStrikeCount,
    int? activeStepIndex,
    String? currentInstruction,
    double? remainingDistanceMeters,
    double? remainingDurationSeconds,
    LatLng? snappedPosition,
    double? currentBearingDeg,
  }) {
    return LiveNavigationState(
      isActive: isActive ?? this.isActive,
      isRerouting: isRerouting ?? this.isRerouting,
      voiceMuted: voiceMuted ?? this.voiceMuted,
      offRouteStrikeCount: offRouteStrikeCount ?? this.offRouteStrikeCount,
      activeStepIndex: activeStepIndex ?? this.activeStepIndex,
      currentInstruction: currentInstruction ?? this.currentInstruction,
      remainingDistanceMeters:
          remainingDistanceMeters ?? this.remainingDistanceMeters,
      remainingDurationSeconds:
          remainingDurationSeconds ?? this.remainingDurationSeconds,
      snappedPosition: snappedPosition ?? this.snappedPosition,
      currentBearingDeg: currentBearingDeg ?? this.currentBearingDeg,
    );
  }
}

RadarTravelMode parseBackendTravelMode(String? raw, RadarTravelMode fallback) {
  switch ((raw ?? '').trim().toUpperCase()) {
    case 'FOOT':
    case 'WALK':
    case 'WALKING':
      return RadarTravelMode.walk;
    case 'CAR':
    case 'DRIVE':
    case 'DRIVING':
      return RadarTravelMode.drive;
    case 'MOTORCYCLE':
    case 'MOTOR':
      return RadarTravelMode.motorcycle;
    default:
      return fallback;
  }
}

List<LatLng> parseBackendLatLngs(dynamic raw) {
  if (raw is! List) return const [];
  final out = <LatLng>[];
  for (final p in raw) {
    if (p is List && p.length >= 2 && p[0] is num && p[1] is num) {
      out.add(LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()));
    }
  }
  return out;
}

List<LatLng> decodePolyline6(String encoded) {
  final out = <LatLng>[];
  var index = 0;
  var lat = 0;
  var lng = 0;
  while (index < encoded.length) {
    int b;
    var shift = 0;
    var result = 0;
    do {
      if (index >= encoded.length) return out;
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      if (index >= encoded.length) return out;
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    out.add(LatLng(lat / 1e6, lng / 1e6));
  }
  return out;
}

double computeBearingDegrees(LatLng a, LatLng b) {
  const rad = math.pi / 180.0;
  final phi1 = a.latitude * rad;
  final phi2 = b.latitude * rad;
  final dl = (b.longitude - a.longitude) * rad;
  final y = math.sin(dl) * math.cos(phi2);
  final x = math.cos(phi1) * math.sin(phi2) -
      math.sin(phi1) * math.cos(phi2) * math.cos(dl);
  return ((math.atan2(y, x) * 180.0 / math.pi) + 360.0) % 360.0;
}

/// Viterbi/Geometric Snap-to-Road: memproyeksikan posisi GPS mentah ke segmen polyline terdekat.
SnapToRoadProjection projectPointOntoPolyline(
  LatLng gps,
  List<LatLng> polyline, {
  double? headingDeg,
}) {
  if (polyline.length < 2) {
    final target = polyline.isNotEmpty ? polyline.first : gps;
    final dist = RadarPlaceCard.haversineMeters(
      gps.latitude,
      gps.longitude,
      target.latitude,
      target.longitude,
    );
    return SnapToRoadProjection(
      snappedPoint: dist <= 25.0 ? target : gps,
      crossTrackMeters: dist,
      closestSegmentIndex: 0,
      segmentBearingDeg: headingDeg ?? 0.0,
      remainingMeters: dist,
      isSnapped: dist <= 25.0,
      isOffRoute: dist > 35.0,
    );
  }

  var bestScore = double.infinity;
  var bestCrossTrack = double.infinity;
  var bestSnap = gps;
  var bestSeg = 0;
  var bestBearing = 0.0;
  final cosLat = math.cos(gps.latitude * math.pi / 180.0).clamp(0.2, 1.0);

  for (var i = 0; i < polyline.length - 1; i++) {
    final a = polyline[i];
    final b = polyline[i + 1];
    final ax = a.longitude * cosLat;
    final ay = a.latitude;
    final bx = b.longitude * cosLat;
    final by = b.latitude;
    final px = gps.longitude * cosLat;
    final py = gps.latitude;

    final dx = bx - ax;
    final dy = by - ay;
    final lenSq = dx * dx + dy * dy;
    final t = lenSq > 1e-12
        ? (((px - ax) * dx + (py - ay) * dy) / lenSq).clamp(0.0, 1.0)
        : 0.0;
    final cand = LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
    final dist = RadarPlaceCard.haversineMeters(
      gps.latitude,
      gps.longitude,
      cand.latitude,
      cand.longitude,
    );
    final segBearing = computeBearingDegrees(a, b);
    var score = dist;
    if (headingDeg != null && headingDeg.isFinite) {
      final diff = ((headingDeg - segBearing + 540.0) % 360.0) - 180.0;
      if (diff.abs() > 55.0) {
        score += 18.0; // Penalti Viterbi bagi segmen berlawanan arah
      }
    }
    if (score < bestScore) {
      bestScore = score;
      bestCrossTrack = dist;
      bestSnap = cand;
      bestSeg = i;
      bestBearing = segBearing;
    }
  }

  var rem = RadarPlaceCard.haversineMeters(
    bestSnap.latitude,
    bestSnap.longitude,
    polyline[bestSeg + 1].latitude,
    polyline[bestSeg + 1].longitude,
  );
  for (var i = bestSeg + 1; i < polyline.length - 1; i++) {
    rem += RadarPlaceCard.haversineMeters(
      polyline[i].latitude,
      polyline[i].longitude,
      polyline[i + 1].latitude,
      polyline[i + 1].longitude,
    );
  }

  var headingAligned = true;
  if (headingDeg != null && headingDeg.isFinite) {
    final diff = ((headingDeg - bestBearing + 540.0) % 360.0) - 180.0;
    headingAligned = diff.abs() <= 55.0;
  }

  final snapped = bestCrossTrack <= 25.0 && headingAligned;
  return SnapToRoadProjection(
    snappedPoint: snapped ? bestSnap : gps,
    crossTrackMeters: bestCrossTrack,
    closestSegmentIndex: bestSeg,
    segmentBearingDeg: bestBearing,
    remainingMeters: rem,
    isSnapped: snapped,
    isOffRoute: bestCrossTrack > 35.0,
  );
}
