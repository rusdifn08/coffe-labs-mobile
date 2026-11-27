import 'package:coffee_hub_mobile/features/game_brew/domain/game_brew_studio_models.dart';
import 'package:coffee_hub_mobile/features/game_brew/engine/latte_art_cfd_engine.dart';
import 'package:coffee_hub_mobile/features/game_brew/engine/manual_brew_3d_physics_engine.dart';
import 'package:coffee_hub_mobile/features/game_brew/engine/natural_gyro_sensor_fusion.dart';
import 'package:coffee_hub_mobile/features/game_brew/engine/transparent_vessel_slosh_solver.dart';
import 'package:coffee_hub_mobile/features/game_brew/presentation/screens/latte_art_3d_stage_screen.dart';
import 'package:coffee_hub_mobile/features/game_brew/presentation/screens/manual_brew_3d_stage_screen.dart';
import 'package:coffee_hub_mobile/features/game_brew/widgets/barista_precision_joystick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'BaristaJoystickController enforces radial deadzone, non-linear slow-to-fast speed curve, and circular boundary clamping',
    () {
      final ctrl = BaristaJoystickController(
        deadzone: 0.08,
        responseGamma: 1.85,
        maxSpeedNormPerSec: 1.55,
        workspaceMaxRadius: 0.86,
      );

      // Inside deadzone -> stays completely idle
      ctrl.updateInput(const Offset(0.05, 0.02), engaged: true);
      final posIdle = ctrl.stepPosition(Offset.zero, 0.016);
      expect(posIdle, Offset.zero);
      expect(ctrl.state.tier, JoystickSpeedTier.idle);

      // Slight deflection (25%) -> Halus (micro precision)
      ctrl.reset();
      ctrl.updateInput(const Offset(0.25, 0.0), engaged: true);
      for (int i = 0; i < 15; i++) {
        ctrl.stepPosition(Offset.zero, 0.016);
      }
      final slowSpeed = ctrl.state.speedNormPerSec;
      expect(ctrl.state.tier, JoystickSpeedTier.micro);
      expect(slowSpeed, greaterThan(0.03));
      expect(slowSpeed, lessThan(0.25));

      // Medium deflection (55%) -> Sedang
      ctrl.updateInput(const Offset(0.55, 0.0), engaged: true);
      for (int i = 0; i < 15; i++) {
        ctrl.stepPosition(Offset.zero, 0.016);
      }
      final medSpeed = ctrl.state.speedNormPerSec;
      expect(ctrl.state.tier, JoystickSpeedTier.medium);
      expect(medSpeed, greaterThan(slowSpeed * 2.5));

      // Full deflection (100%) -> Cepat (dramatically faster than slight push!)
      ctrl.updateInput(const Offset(1.0, 0.0), engaged: true);
      for (int i = 0; i < 20; i++) {
        ctrl.stepPosition(Offset.zero, 0.016);
      }
      final fastSpeed = ctrl.state.speedNormPerSec;
      expect(ctrl.state.tier, JoystickSpeedTier.fast);
      expect(fastSpeed, greaterThan(slowSpeed * 6.0));

      // Circular boundary clamp keeps nozzle inside dripper/cup circle
      Offset pos = Offset.zero;
      ctrl.updateInput(const Offset(1.0, 1.0), engaged: true);
      for (int i = 0; i < 120; i++) {
        pos = ctrl.stepPosition(pos, 0.016);
      }
      expect(pos.distance, lessThanOrEqualTo(0.861));
    },
  );

  test(
    'NaturalGyroSensorFusionEngine initializes at 0 deg on any comfortable grip and only pours on forward tilt',
    () {
      final gyro = NaturalGyroSensorFusionEngine();

      // Comfortable 45 deg holding posture: ay = 6.93, az = 6.93 -> must read 0 deg STOP!
      for (int i = 0; i < 20; i++) {
        gyro.ingestAccelerometer(0.0, 6.93, 6.93);
        gyro.ingestGyroscope(0.0, 0.0, 0.0, 0.016);
      }
      final resting = gyro.sample(0.016);
      expect(resting.pitchDeg, lessThan(1.0));

      // Tilting phone backward toward user (upright: ay = 9.3, az = 3.0) -> stays 0 deg STOP!
      for (int i = 0; i < 25; i++) {
        gyro.ingestAccelerometer(0.0, 9.3, 3.0);
        gyro.ingestGyroscope(0.0, 0.0, 0.0, 0.016);
      }
      final tiltedBack = gyro.sample(0.016);
      expect(tiltedBack.pitchDeg, equals(0.0));

      // Tilting phone forward to pour (flatter: ay = 2.0, az = 9.6) -> positive pour angle!
      NaturalSensorSnapshot tiltedForward = const NaturalSensorSnapshot();
      for (int i = 0; i < 35; i++) {
        gyro.ingestAccelerometer(0.0, 2.0, 9.6);
        gyro.ingestGyroscope(0.0, 0.0, 0.0, 0.016);
        tiltedForward = gyro.sample(0.016);
      }
      expect(tiltedForward.pitchDeg, greaterThan(18.0));
    },
  );

  test(
    'TransparentVesselSloshSolver conserves volume and scales Torricelli debit & Reynolds number with tilt',
    () {
      final solver = TransparentVesselSloshSolver(
        capacityMl: 350.0,
        initialVolumeMl: 300.0,
      );

      // Upright -> 0 ml/s
      final f0 = solver.step(dt: 0.016, pitchDeg: 0.0, rollDeg: 0.0);
      expect(f0, equals(0.0));
      expect(solver.volumeMl, equals(300.0));

      // Gentle tilt (18 deg) -> controlled laminar flow
      double gentleFlow = 0.0;
      for (int i = 0; i < 40; i++) {
        gentleFlow = solver.step(dt: 0.016, pitchDeg: 18.0, rollDeg: 0.0);
      }
      expect(gentleFlow, greaterThan(1.0));
      expect(gentleFlow, lessThan(6.5));
      expect(solver.streamVelocityMS, greaterThan(0.0));
      expect(solver.reynoldsNumber, greaterThan(0.0));

      // Steep tilt (42 deg) -> higher debit than gentle tilt
      double steepFlow = 0.0;
      for (int i = 0; i < 40; i++) {
        steepFlow = solver.step(dt: 0.016, pitchDeg: 42.0, rollDeg: 0.0);
      }
      expect(steepFlow, greaterThan(gentleFlow));
      // Mass conservation: remaining + dispensed == initial 300 ml
      expect(
        solver.volumeMl + solver.totalDispensedMl,
        closeTo(300.0, 0.05),
      );
    },
  );

  test(
    'ManualBrew3DPhysicsEngine Phase 1 exposes accurate rinse telemetry & driest filter target',
    () {
      const spec = GameBrewLevelSpec(
        code: 'MB-01',
        discipline: GameBrewDiscipline.manualBrew3d,
        levelNumber: 1,
        difficulty: GameBrewDifficulty.basic,
        title: 'Ritual Kertas & Air Bilasan',
        subtitle: 'Basahi filter',
        mentorTip: 'Putar merata',
        manualPattern: ManualPourPattern.circularCw,
        requirePreBrewRitual: true,
        targetWaterMl: 180.0,
      );
      final engine = ManualBrew3DPhysicsEngine(spec: spec);

      for (int i = 0; i < 40; i++) {
        engine.step(dt: 0.016, pitchDeg: 28.0, rollDeg: 0.0);
      }
      expect(engine.activeScaleWaterMl, greaterThan(1.0));
      expect(engine.activeWetnessPct, greaterThan(5.0));
      expect(engine.driestFilterTargetPos.distance, closeTo(0.72, 0.02));
      expect(engine.coachingHint, contains('joystick'));
    },
  );

  testWidgets(
    'ManualBrew3DStageScreen and LatteArt3DStageScreen render bottom joystick cleanly on 360x780 viewport',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const mbSpec = GameBrewLevelSpec(
        code: 'MB-01',
        discipline: GameBrewDiscipline.manualBrew3d,
        levelNumber: 1,
        difficulty: GameBrewDifficulty.basic,
        title: 'Ritual Kertas & Air Bilasan',
        subtitle: 'Basahi filter',
        mentorTip: 'Putar merata',
        manualPattern: ManualPourPattern.circularCw,
        requirePreBrewRitual: true,
        targetWaterMl: 180.0,
      );

      await tester.pumpWidget(
        const MaterialApp(home: ManualBrew3DStageScreen(spec: mbSpec)),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(BaristaPrecisionJoystick), findsOneWidget);
      expect(find.text('ARAH KETEL'), findsOneWidget);
      expect(find.text('Bilas'), findsOneWidget);
      expect(find.text('Debit'), findsOneWidget);
      expect(find.text('Ketel'), findsOneWidget);

      const laSpec = GameBrewLevelSpec(
        code: 'LA-03',
        discipline: GameBrewDiscipline.latteArt3d,
        levelNumber: 3,
        difficulty: GameBrewDifficulty.basic,
        title: 'Classic Heart',
        subtitle: 'Bola foam & pull-through cut',
        mentorTip: 'Mulai tinggi lalu rendah',
        lattePattern: LatteArtPattern.heart,
      );

      await tester.pumpWidget(
        const MaterialApp(home: LatteArt3DStageScreen(spec: laSpec)),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(BaristaPrecisionJoystick), findsOneWidget);
      expect(find.text('ARAH PITCHER'), findsOneWidget);
      expect(find.text('↑ Tinggi (Dive)'), findsOneWidget);
      expect(find.text('Cut ↑'), findsOneWidget);
      expect(find.text('Nilai WLAC'), findsOneWidget);
    },
  );

  test('LatteArtCfdEngine coaching hints adapt across Dive, Float, and Cut stages', () {
    final cfd = LatteArtCfdEngine();
    expect(cfd.currentLatteStage, 0);
    expect(cfd.coachingHintFor(LatteArtPattern.rosetta), contains('DIVE'));

    cfd.cupVolumeMl = 125.0; // 62.5%
    expect(cfd.currentLatteStage, 1);
    expect(cfd.coachingHintFor(LatteArtPattern.rosetta), contains('Goyangkan joystick'));

    cfd.cupVolumeMl = 175.0; // 87.5%
    expect(cfd.currentLatteStage, 2);
    expect(cfd.coachingHintFor(LatteArtPattern.rosetta), contains('CUT'));
  });
}
