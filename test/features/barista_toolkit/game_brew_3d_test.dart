import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

import 'package:coffee_hub_mobile/features/barista_toolkit/data/barista_toolkit_seed_data.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/game_brew/game_brew_v60_screen.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/game_brew_3d/engine/gyro_kettle_physics_engine.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/game_brew_3d/engine/v60_3d_scene_renderer.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/game_brew_3d/engine/v60_bed_heightfield_solver.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/game_brew_3d/ui/game_brew_3d_simulator_screen.dart';

void main() {
  group('Multi-Engine 3D V60 Physics Tests', () {
    test('GyroKettlePhysicsEngine Zero-Tare, volume critical angle & laminar/turbulent transition', () {
      final kettle = GyroKettlePhysicsEngine();
      kettle.startSensorFusion(
        initialKettleWaterMl: 350.0,
        initialTempCelsius: 92.0,
        preferHardwareGyro: false,
      );

      // Saat ketel penuh (350ml), sudut kritis minimal ~8°
      final critFull = kettle.computeCriticalSpoutAngleDeg();
      expect(critFull, closeTo(8.0, 0.2));

      // Kalibrasi pegangan setelah miring ergonomis
      kettle.ingestGyroscope(0.55, 0.0, 0.0, 0.02);
      kettle.calibrateZeroTare();
      final afterTare = kettle.stepHydrodynamics(
        0.02,
        forceUseGyroOrientationForTest: true,
      );
      expect(afterTare.pitchDeg, lessThan(1.5));

      // Tuang Laminar lewat virtual tilt (~22° -> laminar <= 6.8 ml/s)
      kettle.setVirtualPourTilt(0.40);
      late KettleTelemetryState laminarState;
      for (int i = 0; i < 30; i++) {
        laminarState = kettle.stepHydrodynamics(0.02);
      }
      expect(laminarState.flowRegime, KettleFlowRegime.laminar);
      expect(laminarState.flowRateMlPerSec, greaterThan(0.5));
      expect(laminarState.flowRateMlPerSec, lessThanOrEqualTo(6.8));

      // Miringkan ekstrem (virtual tilt 0.96) -> flow turbulen (> 6.8 ml/s)
      kettle.setVirtualPourTilt(0.96);
      late KettleTelemetryState turbulentState;
      for (int i = 0; i < 40; i++) {
        turbulentState = kettle.stepHydrodynamics(0.02);
      }
      expect(turbulentState.flowRegime, KettleFlowRegime.turbulent);
      expect(turbulentState.flowRateMlPerSec, greaterThan(6.8));

      // Ketika air di ketel berkurang drastis, sudut ambang kritis meningkat (> 10°)
      for (int i = 0; i < 600; i++) {
        kettle.stepHydrodynamics(0.05);
      }
      expect(kettle.computeCriticalSpoutAngleDeg(), greaterThan(critFull + 4.0));

      kettle.dispose();
    });

    test('GyroKettlePhysicsEngine mendeteksi Gentle Rao Swirl dari impulse akselerometer', () {
      final kettle = GyroKettlePhysicsEngine();
      kettle.startSensorFusion(
        initialKettleWaterMl: 300.0,
        initialTempCelsius: 92.0,
        preferHardwareGyro: false,
      );

      for (int i = 0; i < 12; i++) {
        final double ax = i.isEven ? 3.5 : -3.5;
        final double ay = i % 3 == 0 ? 3.2 : -2.8;
        kettle.ingestAccelerometer(ax, ay, 9.81);
      }
      final state = kettle.stepHydrodynamics(0.016);
      expect(state.swirlIntensity, greaterThan(0.2));
      kettle.dispose();
    });

    test('V60BedPercolationSolver cratering vs Rao Swirl Laplacian flat bed & bypass detection', () {
      final solver = V60BedPercolationSolver();
      final initialScore = solver.computeFlatBedUniformityScore();

      // Tuang deras diam di satu titik -> mengerosi kawah tengah
      for (int i = 0; i < 80; i++) {
        solver.stepPercolation(
          dt: 0.05,
          inflowRateMlSec: 9.2,
          impactPos: Vector2(0.0, 0.0),
          swirlIntensity: 0.0,
          waterTempC: 92.0,
          targetWaterMl: 225.0,
          totalPouredMl: 90.0,
        );
      }
      final crateredScore = solver.computeFlatBedUniformityScore();
      expect(crateredScore, lessThan(initialScore));

      // Terapkan Gentle Rao Swirl -> meratakan ampas ke Flat Coffee Bed
      for (int i = 0; i < 60; i++) {
        solver.stepPercolation(
          dt: 0.05,
          inflowRateMlSec: 0.0,
          impactPos: Vector2.zero(),
          swirlIntensity: 0.95,
          waterTempC: 90.0,
          targetWaterMl: 225.0,
          totalPouredMl: 225.0,
        );
      }
      expect(solver.computeFlatBedUniformityScore(), greaterThan(crateredScore));

      // Aliran menabrak bibir cone (r > 0.88) mencatat Filter Bypass
      solver.stepPercolation(
        dt: 0.05,
        inflowRateMlSec: 4.5,
        impactPos: Vector2(0.95, 0.1),
        swirlIntensity: 0.0,
        waterTempC: 92.0,
        targetWaterMl: 225.0,
        totalPouredMl: 120.0,
      );
      expect(solver.bypassEventsCount, greaterThanOrEqualTo(1));
    });
  });

  group('Game Brew 3D Widget Integration Tests', () {
    testWidgets('GameBrewV60Screen membuka Simulator 3D dengan POV, X-Ray, 360° & tuang virtual',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameBrewV60Screen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.text('Game Brew V60: Kedai Senja'), findsOneWidget);
      expect(find.text('Tetes Pertama di Kedai Senja'), findsOneWidget);
      expect(find.text('Mode Sandbox Bebas 3D (Latihan Instan)'), findsOneWidget);

      // Masuk ke Chapter 1 Simulator 3D
      await tester.tap(find.text('Tetes Pertama di Kedai Senja'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(GameBrew3DSimulatorScreen), findsOneWidget);
      expect(find.text('Barista POV'), findsOneWidget);
      expect(find.text('3D X-Ray'), findsOneWidget);
      expect(find.text('360° Orbit'), findsOneWidget);

      // Ganti sudut kamera 3D
      await tester.tap(find.text('3D X-Ray'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('360° Orbit'));
      await tester.pump(const Duration(milliseconds: 100));

      // Geser Tuang Ketel Slider ke 65% lalu jalankan simulasi beberapa tick
      final slider = find.byKey(const Key('virtual_tilt_slider'));
      expect(slider, findsOneWidget);
      await tester.drag(slider, const Offset(110, 0));
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 80));
      }

      // Aktifkan Rao Swirl & buka panel penjelasan sains
      await tester.tap(find.text('Rao Swirl'));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(find.byTooltip('Penjelasan Sains Ekstraksi'));
      await tester.pump(const Duration(milliseconds: 80));
      expect(find.text('LABORATORIUM FISIKA V60'), findsOneWidget);
    });

    testWidgets('Mode Sandbox Bebas 3D dari GameBrewV60Screen lancar di layar ponsel 375x780',
        (tester) async {
      tester.view.physicalSize = const Size(375, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GameBrewV60Screen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));

      await tester.tap(find.textContaining('Light Crisp'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Free Brew 3D Sandbox'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Mode Sandbox Dual-Temp 3D menampilkan tombol Air 70°C', (tester) async {
      final dualTemp = BaristaToolkitFallbackSeed.offlineChapters()[3];
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: GameBrew3DSimulatorScreen(
              chapter: dualTemp,
              isSandboxMode: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Free Brew 3D Sandbox'), findsOneWidget);
      expect(find.text('Air 70°C'), findsOneWidget);
      await tester.tap(find.text('Air 70°C'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('70°C'), findsWidgets);
    });

    test('V603DFlameSimulatorGame upacara pra-seduh: basahi kertas, angkat dripper, buang air & tuang kopi',
        () {
      final game = V603DFlameSimulatorGame(
        doseG: 15.0,
        targetWaterMl: 225.0,
        bloomMl: 45.0,
        bloomSec: 35.0,
        initialTempC: 92.0,
        targetTimeSec: 145.0,
        idealFlowMlS: 4.5,
      );
      addTearDown(game.disposeNotifier);

      final initSnap = game.snapshotNotifier.value;
      expect(initSnap.interactiveStage, BrewInteractiveStage.wettingPaper);
      expect(initSnap.coffeeGroundsAdded, isFalse);
      expect(initSnap.paperWetnessPct, 0.0);

      // Tuang air panas untuk membasahi kertas filter
      game.setVirtualPourTilt(0.75);
      for (int i = 0; i < 40; i++) {
        game.tickExternalPhysics(0.05);
      }
      final wetSnap = game.snapshotNotifier.value;
      expect(wetSnap.paperWetnessPct, greaterThan(45.0));
      expect(wetSnap.rinseWaterMl, greaterThan(2.0));

      // Angkat dripper V60 dari atas Glass Server
      game.setVirtualPourTilt(0.0);
      game.toggleLiftDripper();
      for (int i = 0; i < 12; i++) {
        game.tickExternalPhysics(0.1);
      }
      final liftedSnap = game.snapshotNotifier.value;
      expect(liftedSnap.isDripperLifted, isTrue);
      expect(liftedSnap.dripperLiftProgress, greaterThan(0.7));
      expect(liftedSnap.interactiveStage, BrewInteractiveStage.liftAndDiscard);

      // Miringkan teko kaca buang air bilasan
      game.discardRinseWater();
      for (int i = 0; i < 16; i++) {
        game.tickExternalPhysics(0.1);
      }
      final discardSnap = game.snapshotNotifier.value;
      expect(discardSnap.rinseDiscarded || discardSnap.serverTiltRad > 0.0, isTrue);
      expect(discardSnap.rinseWaterMl, closeTo(0.0, 0.5));

      // Tuang bubuk kopi & mulai fase blooming
      game.dropCoffeeGrounds();
      for (int i = 0; i < 8; i++) {
        game.tickExternalPhysics(0.1);
      }
      final brewSnap = game.snapshotNotifier.value;
      expect(brewSnap.coffeeGroundsAdded, isTrue);
      expect(brewSnap.isDripperLifted, isFalse);
      expect(brewSnap.interactiveStage, BrewInteractiveStage.blooming);
    });

    testWidgets('Tombol interaktif Angkat Dripper, Buang Air & Tuang Kopi lancar di 375x780',
        (tester) async {
      tester.view.physicalSize = const Size(375, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final ch1 = BaristaToolkitFallbackSeed.offlineChapters().first;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: GameBrew3DSimulatorScreen(chapter: ch1),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.byKey(const Key('lift_dripper_btn')), findsOneWidget);
      expect(find.byKey(const Key('discard_rinse_btn')), findsOneWidget);
      expect(find.byKey(const Key('drop_coffee_btn')), findsOneWidget);
      expect(find.byKey(const Key('skip_prebrew_btn')), findsOneWidget);

      await tester.tap(find.byKey(const Key('lift_dripper_btn')));
      await tester.pump(const Duration(milliseconds: 80));
      expect(find.text('Turun Dripper'), findsOneWidget);

      await tester.tap(find.byKey(const Key('discard_rinse_btn')));
      await tester.pump(const Duration(milliseconds: 80));

      await tester.tap(find.byKey(const Key('drop_coffee_btn')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('lift_dripper_btn')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
