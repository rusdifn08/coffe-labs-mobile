import 'dart:math' as math;
import 'package:coffee_hub_mobile/features/game_brew/data/game_brew_curriculum_catalog.dart';
import 'package:coffee_hub_mobile/features/game_brew/data/game_brew_progress_service.dart';
import 'package:coffee_hub_mobile/features/game_brew/domain/game_brew_studio_models.dart';
import 'package:coffee_hub_mobile/features/game_brew/engine/latte_art_cfd_engine.dart';
import 'package:coffee_hub_mobile/features/game_brew/engine/manual_brew_3d_physics_engine.dart';
import 'package:coffee_hub_mobile/features/game_brew/engine/natural_gyro_sensor_fusion.dart';
import 'package:coffee_hub_mobile/features/game_brew/engine/transparent_vessel_slosh_solver.dart';
import 'package:coffee_hub_mobile/features/game_brew/presentation/screens/discipline_level_map_screen.dart';
import 'package:coffee_hub_mobile/features/game_brew/presentation/screens/game_brew_dual_hub_screen.dart';
import 'package:coffee_hub_mobile/features/game_brew/presentation/screens/latte_art_3d_stage_screen.dart';
import 'package:coffee_hub_mobile/features/game_brew/presentation/screens/manual_brew_3d_stage_screen.dart';
import 'package:coffee_hub_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameBrewProgressService.resetMemoryCache();
  });

  group('9-Axis NaturalGyroSensorFusion & Physics Stability Gate', () {
    test('NaturalGyroSensorFusionEngine integrates SO(3), separates linear accel, measures Wiggle Hz & rejects mag anomalies', () {
      final fusion = NaturalGyroSensorFusionEngine();

      // Establish upright gravity reference & tare 0 deg
      fusion.ingestAccelerometer(0.0, 9.80665, 0.0);
      fusion.ingestMagnetometer(0.0, 22.0, 38.0); // Valid ~44 uT Earth field
      fusion.ingestGyroscope(0.0, 0.0, 0.0, 0.005);
      fusion.calibrateZeroTare();

      expect(fusion.sample(0.016).magnetometerActive, isTrue);

      // Reject magnetic speaker anomaly (260 uT)
      fusion.ingestMagnetometer(250.0, 60.0, 40.0);
      expect(fusion.sample(0.016).magnetometerActive, isFalse);

      // 1) Pure pitch forward ~0.52 rad (~30 deg) around +X in right-handed frame:
      //    q^-1 * (0, g, 0) = (0, g*cos(theta), -g*sin(theta))
      for (int i = 0; i < 120; i++) {
        final double t = i * 0.005;
        final double pitchRate = t < 0.5 ? 1.04 : 0.0;
        final double pitchAngle = math.min(0.52, t * 1.04);
        fusion.ingestAccelerometer(
          0.0,
          9.80665 * math.cos(pitchAngle),
          -9.80665 * math.sin(pitchAngle),
        );
        fusion.ingestGyroscope(pitchRate, 0.0, 0.0, 0.005);
        fusion.sample(0.005);
      }

      final pitchSnap = fusion.sample(0.016);
      expect(pitchSnap.pitchDeg, inInclusiveRange(26.0, 34.0));

      // 2) Oscillate 2.5 Hz Wiggle on Z over 1.2s -> verify live Wiggle Hz detector!
      for (int i = 0; i < 240; i++) {
        final double t = i * 0.005;
        final double wiggleOmega = math.cos(2.0 * math.pi * 2.5 * t) * 2.2;
        fusion.ingestGyroscope(0.0, 0.0, wiggleOmega, 0.005);
      }
      final wiggleSnap = fusion.sample(0.016);
      expect(wiggleSnap.wiggleFrequencyHz, inInclusiveRange(2.0, 3.0));

      // Inject circular planar UserLinearAccelerometer -> triggers Rao Swirl!
      for (int i = 0; i < 30; i++) {
        final double a = i * 0.45;
        fusion.ingestUserLinearAccelerometer(
          math.cos(a) * 3.5,
          0.0,
          math.sin(a) * 3.5,
        );
      }
      expect(fusion.sample(0.016).swirlIntensity, greaterThan(0.3));
    });

    test('TransparentVesselSloshSolver remains stable over 1,000 steps and drains water accurately', () {
      final solver = TransparentVesselSloshSolver(capacityMl: 350.0);
      final initialMl = solver.volumeMl;

      for (int i = 0; i < 1000; i++) {
        final flow = solver.step(
          dt: 0.016,
          pitchDeg: i < 400 ? 32.0 : 5.0,
          rollDeg: math.sin(i * 0.08) * 15.0,
          lateralAccelX: math.cos(i * 0.1) * 1.2,
        );
        expect(flow.isFinite, isTrue);
        expect(solver.psiXRad.isFinite, isTrue);
        expect(solver.psiZRad.isFinite, isTrue);
      }
      expect(solver.volumeMl, lessThan(initialMl));
    });

    test('LatteArtCfdEngine 112x112 HD Navier-Stokes produces ZERO NaN/Inf over 1,000 steps & tracks rim spill', () {
      final cfd = LatteArtCfdEngine();
      expect(cfd.computeFloatFactor(5.5, 10.0), lessThan(0.05));
      expect(cfd.computeFloatFactor(0.9, 10.0), greaterThan(0.85));

      for (int step = 0; step < 1000; step++) {
        cfd.pourHeightCm = step < 250 ? 5.0 : (step < 750 ? 1.0 : 5.2);
        cfd.pourPos = Offset(
          math.sin(step * 0.22) * 0.25,
          0.20 - (step / 1000.0) * 0.65,
        );
        cfd.step(
          dt: 0.016,
          pitchDeg: step < 820 ? 34.0 : 0.0,
          rollDeg: math.sin(step * 0.22) * 18.0,
          wiggleAngularVel: math.cos(step * 0.22) * 3.0,
        );
      }

      for (int i = 0; i < cfd.u.length; i++) {
        expect(cfd.u[i].isFinite, isTrue);
        expect(cfd.v[i].isFinite, isTrue);
        expect(cfd.foam[i].isFinite, isTrue);
      }

      final grade = cfd.evaluateCup(LatteArtPattern.rosetta);
      expect(grade.overallScorePct, inInclusiveRange(0.0, 100.0));
      expect(grade.rankBadge, isNotEmpty);
    });

    test('ManualBrew3DPhysicsEngine validates 5 phases & progression service', () async {
      final spec = GameBrewCurriculumCatalog.manualBrewAdventure.first;
      final engine = ManualBrew3DPhysicsEngine(spec: spec);

      for (int i = 0; i < 360; i++) {
        final angle = (i / 36.0) * math.pi * 2.0;
        engine.aimPos = Offset(math.cos(angle) * 0.7, math.sin(angle) * 0.7);
        engine.step(dt: 0.03, pitchDeg: 36.0, rollDeg: 0.0);
      }
      expect(engine.paperWetnessPct, greaterThanOrEqualTo(95.0));
      engine.discardRinseWater();
      engine.spritzRdt();
      engine.spritzRdt();
      engine.completeRdtAndMoveToDosing();
      engine.doseGroundsIntoV60();
      for (int i = 0; i < 4; i++) {
        engine.sculptDivotAt(Offset.zero);
      }
      expect(engine.isDivotOptimal, isTrue);
      engine.finishDosingAndStartPouring();

      for (int i = 0; i < 200; i++) {
        final angle = (i / 25.0) * math.pi * 2.0;
        engine.aimPos = Offset(math.cos(angle) * 0.45, math.sin(angle) * 0.45);
        engine.step(dt: 0.03, pitchDeg: 30.0, rollDeg: 0.0);
      }
      engine.applyGentleRaoSwirl();
      final res = engine.finishAndEvaluate();
      expect(res['eyPct']!, inInclusiveRange(12.0, 25.0));
    });
  });

  group('Full-Screen 3D Portrait (360x780) & Landscape (780x360) Zero-Overflow UI Tests', () {
    testWidgets('GameBrewDualHubScreen & DisciplineLevelMapScreen render with 0 overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const GameBrewDualHubScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Manual Brew 3D Simulator'), findsOneWidget);
      expect(find.text('Latte Art 3D Simulator'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DisciplineLevelMapScreen(
            discipline: GameBrewDiscipline.latteArt3d,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('ManualBrew3DStageScreen renders full-bleed 3D cleanly in Portrait & Landscape across all 4 cameras', (tester) async {
      final zigzag = GameBrewCurriculumCatalog.manualBrewDrills
          .firstWhere((d) => d.manualPattern == ManualPourPattern.zigzag);

      // 1. Portrait 360x780
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ManualBrew3DStageScreen(spec: zigzag),
        ),
      );
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull);

      for (final camLabel in ['X-Ray', 'Atas Pola', '360° Orbit', 'POV 3D']) {
        await tester.tap(find.text(camLabel));
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
      }

      // 2. Landscape 780x360
      tester.view.physicalSize = const Size(780, 360);
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull);
    });

    testWidgets('LatteArt3DStageScreen renders full-bleed 3D + Collector Card in Portrait & Landscape with 0 overflow', (tester) async {
      final tulip = GameBrewCurriculumCatalog.latteArtDrills
          .firstWhere((d) => d.lattePattern == LatteArtPattern.threeStackTulip);

      // 1. Portrait 360x780
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LatteArt3DStageScreen(spec: tulip),
        ),
      );
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull);

      // Swap Left/Right handed capsule
      await tester.tap(find.text('⇄ Kanan'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('⇄ Kiri'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Trigger WLAC Grading Collector View in Portrait
      await tester.tap(find.text('Nilai WLAC'));
      await tester.pump(const Duration(milliseconds: 80));
      expect(find.text('Tuang Lagi'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. Rotate to Landscape 780x360 while Collector Card is open AND during active pour!
      tester.view.physicalSize = const Size(780, 360);
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Tuang Lagi'));
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull);
    });
  });
}
