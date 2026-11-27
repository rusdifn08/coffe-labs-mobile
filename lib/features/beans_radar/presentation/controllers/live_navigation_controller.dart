import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../data/radar_routing_service.dart';
import '../../domain/models/multimodal_route_models.dart';
import '../../models/beans_radar_models.dart';
import 'radar_gps_controller.dart';

/// Live Turn-by-Turn Navigation Controller:
/// 1. Viterbi / Geometric Snap-to-Road (kunci kursor GPS ke garis jalan saat d_perp <= 25m).
/// 2. Hysteresis Auto-Reroute (hitung ulang otomatis jika melenceng > 35m selama 3 pembacaan berturut).
/// 3. Panduan Suara Bahasa Indonesia via `flutter_tts` (bisa di-mute kapan saja).
class LiveNavigationController extends Notifier<LiveNavigationState> {
  FlutterTts? _tts;
  StreamSubscription<Position>? _navPosSub;
  bool _ttsInitialized = false;

  @override
  LiveNavigationState build() {
    ref.onDispose(() {
      _navPosSub?.cancel();
      try {
        _tts?.stop();
      } catch (_) {}
    });
    return const LiveNavigationState();
  }

  bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  Future<void> _ensureTts() async {
    if (_ttsInitialized || _isTestEnv) return;
    _ttsInitialized = true;
    try {
      _tts = FlutterTts();
      await _tts?.setLanguage('id-ID');
      await _tts?.setSpeechRate(0.5);
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    if (state.voiceMuted || _isTestEnv || text.trim().isEmpty) return;
    await _ensureTts();
    try {
      await _tts?.stop();
      await _tts?.speak(text);
    } catch (_) {}
  }

  Future<void> startNavigation(RadarRouteResult route) async {
    final firstInstr = route.steps.isNotEmpty
        ? route.steps.first.instruction
        : 'Mulai perjalanan menuju ${route.destination.name}';
    state = LiveNavigationState(
      isActive: true,
      isRerouting: false,
      voiceMuted: state.voiceMuted,
      offRouteStrikeCount: 0,
      activeStepIndex: 0,
      currentInstruction: firstInstr,
      remainingDistanceMeters: route.distanceMeters,
      remainingDurationSeconds: route.durationSeconds,
      snappedPosition: route.origin,
    );
    unawaited(speak(firstInstr));

    if (_isTestEnv) return;
    try {
      await _navPosSub?.cancel();
      _navPosSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
        ),
      ).listen((pos) {
        onGpsSample(
          LatLng(pos.latitude, pos.longitude),
          headingDeg: pos.heading,
        );
      });
    } catch (_) {}
  }

  void stopNavigation() {
    _navPosSub?.cancel();
    _navPosSub = null;
    try {
      _tts?.stop();
    } catch (_) {}
    state = const LiveNavigationState();
  }

  void toggleVoiceMute() {
    final nextMuted = !state.voiceMuted;
    if (nextMuted) {
      try {
        _tts?.stop();
      } catch (_) {}
    }
    state = state.copyWith(voiceMuted: nextMuted);
  }

  /// Evaluasi satu sampel GPS terhadap polyline aktif: Snap-to-Road atau trigger Auto-Reroute (>35m, 3x).
  Future<void> onGpsSample(LatLng rawGps, {double? headingDeg}) async {
    if (!state.isActive) return;
    final radarState = ref.read(beansRadarGpsProvider);
    final route = radarState.activeRoute;
    if (route == null || route.points.length < 2) return;

    final proj = projectPointOntoPolyline(
      rawGps,
      route.points,
      headingDeg: headingDeg,
    );

    final speedMps = route.mode == RadarTravelMode.walk
        ? 1.33
        : (route.mode == RadarTravelMode.motorcycle ? 8.5 : 6.8);
    final remDur = (proj.remainingMeters / speedMps).clamp(15.0, 86400.0);
    final stepIdx = route.steps.isEmpty
        ? 0
        : ((proj.closestSegmentIndex /
                    (route.points.length - 1).clamp(1, 999)) *
                route.steps.length)
            .floor()
            .clamp(0, route.steps.length - 1);
    final nextInstr = route.steps.isNotEmpty
        ? route.steps[stepIdx].instruction
        : state.currentInstruction;

    final prevInstr = state.currentInstruction;
    final strikes = proj.isOffRoute ? state.offRouteStrikeCount + 1 : 0;

    state = state.copyWith(
      snappedPosition: proj.snappedPoint,
      currentBearingDeg: proj.segmentBearingDeg,
      remainingDistanceMeters: proj.remainingMeters,
      remainingDurationSeconds: remDur,
      activeStepIndex: stepIdx,
      currentInstruction: nextInstr,
      offRouteStrikeCount: strikes,
    );

    if (nextInstr != prevInstr && strikes == 0) {
      unawaited(speak(nextInstr));
    }

    if (strikes >= 3 && !state.isRerouting) {
      await _triggerAutoReroute(rawGps, headingDeg, radarState);
    }
  }

  Future<void> _triggerAutoReroute(
    LatLng currentGps,
    double? headingDeg,
    RadarGpsState radarState,
  ) async {
    final route = radarState.activeRoute;
    if (route == null) return;
    state = state.copyWith(
      isRerouting: true,
      currentInstruction: 'Menghitung ulang rute terbaik...',
    );
    unawaited(speak('Menghitung ulang rute terbaik'));
    try {
      final routing = ref.read(radarRoutingServiceProvider);
      final updated = await routing.navigateLive(
        originLat: currentGps.latitude,
        originLng: currentGps.longitude,
        destination: route.destination,
        mode: radarState.routeMode,
        avoidTolls: radarState.avoidTolls,
        bearingDeg: headingDeg,
      );
      ref.read(beansRadarGpsProvider.notifier).applyReroutedPath(updated);
      final firstInstr = updated.steps.isNotEmpty
          ? updated.steps.first.instruction
          : 'Lanjutkan mengikuti rute baru';
      state = state.copyWith(
        isRerouting: false,
        offRouteStrikeCount: 0,
        activeStepIndex: 0,
        currentInstruction: firstInstr,
        remainingDistanceMeters: updated.distanceMeters,
        remainingDurationSeconds: updated.durationSeconds,
        snappedPosition: updated.origin,
      );
    } catch (_) {
      state = state.copyWith(isRerouting: false, offRouteStrikeCount: 0);
    }
  }
}

final liveNavigationProvider =
    NotifierProvider<LiveNavigationController, LiveNavigationState>(
  LiveNavigationController.new,
);
