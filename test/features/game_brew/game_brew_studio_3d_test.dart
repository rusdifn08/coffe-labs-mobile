import 'dart:math' as math;
import 'package:coffee_hub_mobile/features/game_brew/data/game_brew_curriculum_catalog.dart';
import 'package:coffee_hub_mobile/features/game_brew/data/game_brew_progress_service.dart';
import 'package:coffee_hub_mobile/features/game_brew/domain/game_brew_studio_models.dart';
import 'package:coffee_hub_mobile/features/game_brew/engine/latte_art_cfd_engine.dart';
import 'package:coffee_hub_mobile/features/game_brew/engine/manual_brew_3d_physics_engine.dart';
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

  group('Part 5 Physics Stability & Scientific Accuracy Gate', () {
    test('TransparentVesselSloshSolver remains stable over 1,000 steps and drains water accurately', () {
      final solver = TransparentVesselSloshSolver(capacityMl: 350.0);
      final initialMl = solver.volumeMl;

      for (int i = 0; i < 1000; i++) {
        final pitch = i < 400 ? 32.0 : 5.0;
        final flow = solver.step(
          dt: 0.016,
          pitchDeg: pitch,
          rollDeg: math.sin(i * 0.08) * 15.0,
          lateralAccelX: math.cos(i * 0.1) * 1.2,
        );
        expect(flow.isFinite, isTrue);
        expect(solver.psiXRad.isFinite, isTrue);
        expect(solver.psiZRad.isFinite, isTrue);
      }
      expect(solver.volumeMl, lessThan(initialMl));
      expect(solver.volumeMl, greaterThanOrEqualTo(0.0));
    });

    test('LatteArtCfdEngine 2D Navier-Stokes produces ZERO NaN/Inf over 1,000 steps & validates Dive vs Float', () {
      final cfd = LatteArtCfdEngine();

      // Verify Dive vs Float physical buoyancy curve
      expect(cfd.computeFloatFactor(5.5, 10.0), lessThan(0.05)); // High pour dives
      expect(cfd.computeFloatFactor(0.9, 10.0), greaterThan(0.85)); // Low pour floats

      for (int step = 0; step < 1000; step++) {
        if (step < 250) {
          cfd.pourHeightCm = 5.0; // Dive phase
          cfd.pourPos = const Offset(0.0, 0.05);
        } else if (step < 750) {
          cfd.pourHeightCm = 1.0; // Float Rosetta wiggle phase
          cfd.pourPos = Offset(
            math.sin(step * 0.25) * 0.28,
            0.25 - ((step - 250) / 500.0) * 0.55,
          );
        } else {
          cfd.pourHeightCm = 5.2; // Pull-through cut
          cfd.pourPos = Offset(0.0, -0.35 - ((step - 750) / 250.0) * 0.35);
        }
        cfd.step(
          dt: 0.016,
          pitchDeg: step < 850 ? 34.0 : 0.0,
          rollDeg: math.sin(step * 0.25) * 18.0,
          wiggleAngularVel: math.cos(step * 0.25) * 3.0,
        );
      }

      for (int i = 0; i < cfd.u.length; i++) {
        expect(cfd.u[i].isFinite, isTrue);
        expect(cfd.v[i].isFinite, isTrue);
        expect(cfd.foam[i].isFinite, isTrue);
      }

      final grade = cfd.evaluateCup(LatteArtPattern.rosetta);
      expect(grade.overallScorePct, inInclusiveRange(0.0, 100.0));
      expect(grade.symmetryPct, inInclusiveRange(0.0, 100.0));
      expect(grade.contrastPct, inInclusiveRange(0.0, 100.0));
      expect(grade.patternFidelityPct, inInclusiveRange(0.0, 100.0));
    });

    test('ManualBrew3DPhysicsEngine validates 5 phases: Wet Filter, RDT, Divot, Pattern Pour, Rao Swirl & EY%', () {
      final spec = GameBrewCurriculumCatalog.manualBrewAdventure.first;
      final engine = ManualBrew3DPhysicsEngine(spec: spec);

      // Phase 1: Wet filter around circumference
      for (int i = 0; i < 360; i++) {
        final angle = (i / 36.0) * math.pi * 2.0;
        engine.aimPos = Offset(math.cos(angle) * 0.7, math.sin(angle) * 0.7);
        engine.step(dt: 0.03, pitchDeg: 36.0, rollDeg: 0.0);
      }
      expect(engine.paperWetnessPct, greaterThanOrEqualTo(95.0));
      engine.discardRinseWater();
      expect(engine.phase, ManualBrewPhase.rdtSpritz);

      // Phase 2: Optimal RDT (2 spritzes)
      engine.spritzRdt();
      engine.spritzRdt();
      expect(engine.rdtStatusLabel, contains('Optimal'));
      engine.completeRdtAndMoveToDosing();

      // Phase 3: Dose & Center Divot sculpting (4-9 mm)
      engine.doseGroundsIntoV60();
      for (int i = 0; i < 4; i++) {
        engine.sculptDivotAt(Offset.zero);
      }
      expect(engine.isDivotOptimal, isTrue);
      engine.finishDosingAndStartPouring();

      // Phase 4: Clockwise Circular Pour + Rayleigh-Plateau check
      engine.pourHeightCm = 12.5;
      engine.step(dt: 0.03, pitchDeg: 32.0, rollDeg: 0.0);
      expect(engine.isRayleighBreakup, isTrue);

      engine.pourHeightCm = 7.0;
      for (int i = 0; i < 250; i++) {
        final angle = (i / 25.0) * math.pi * 2.0;
        engine.aimPos = Offset(math.cos(angle) * 0.45, math.sin(angle) * 0.45);
        engine.step(dt: 0.03, pitchDeg: 30.0, rollDeg: 0.0);
      }
      expect(engine.patternAccuracyPct, greaterThan(70.0));
      expect(engine.wettingCoveragePct, greaterThan(40.0));

      // Phase 5: Rao Swirl & Evaluate
      engine.applyGentleRaoSwirl();
      final res = engine.finishAndEvaluate();
      expect(res['eyPct']!, inInclusiveRange(12.0, 25.0));
      expect(res['overall']!, greaterThan(40.0));
    });

    test('Progress service unlocks Lv.2 only after Lv.1 >= 1 star while Direct Drills are always unlocked', () async {
      final mb1 = GameBrewCurriculumCatalog.manualBrewAdventure[0];
      final mb2 = GameBrewCurriculumCatalog.manualBrewAdventure[1];
      final zigzagDrill = GameBrewCurriculumCatalog.manualBrewDrills
          .firstWhere((d) => d.manualPattern == ManualPourPattern.zigzag);

      expect(GameBrewProgressService.isLevelUnlocked(mb1), isTrue);
      expect(GameBrewProgressService.isLevelUnlocked(mb2), isFalse);
      expect(GameBrewProgressService.isLevelUnlocked(zigzagDrill), isTrue);

      await GameBrewProgressService.recordRun(
        levelCode: mb1.code,
        stars: 2,
        scorePct: 81.5,
        metrics: const {'eyPct': 20.1},
      );
      expect(GameBrewProgressService.isLevelUnlocked(mb2), isTrue);
      expect(
        GameBrewProgressService.totalStarsFor(GameBrewDiscipline.manualBrew3d),
        2,
      );
    });
  });

  group('Game Brew Studio 3D 360x780 Zero-Overflow UI Tests', () {
    testWidgets('GameBrewDualHubScreen renders both flagship games, direct drills & Coming Soon with 0 overflow', (tester) async {
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

      await tester.scrollUntilVisible(
        find.text('Espresso Dial-In & 9-Bar 3D'),
        220,
      );
      expect(find.text('Espresso Dial-In & 9-Bar 3D'), findsOneWidget);
      expect(find.text('COMING SOON'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DisciplineLevelMapScreen renders 10 Adventure levels & Direct Drills cleanly at 360x780', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DisciplineLevelMapScreen(
            discipline: GameBrewDiscipline.manualBrew3d,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ritual Kertas & Air Bilasan'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Latihan Teknik'));
      await tester.pumpAndSettle();
      expect(find.text('Latihan Circular Pour (↻)'), findsOneWidget);
      expect(find.text('Latihan Reverse Circular Pour (↺)'), findsOneWidget);
      expect(find.text('Latihan Zigzag Pour (↔)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ManualBrew3DStageScreen & LatteArt3DStageScreen render cleanly at 360x780', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Test Manual Brew 3D Zigzag Drill
      final zigzag = GameBrewCurriculumCatalog.manualBrewDrills
          .firstWhere((d) => d.manualPattern == ManualPourPattern.zigzag);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ManualBrew3DStageScreen(spec: zigzag),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Latihan Zigzag Pour (↔)'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test Latte Art 3D Rosetta Drill
      final rosetta = GameBrewCurriculumCatalog.latteArtDrills
          .firstWhere((d) => d.lattePattern == LatteArtPattern.rosetta);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LatteArt3DStageScreen(spec: rosetta),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Latihan Classic Rosetta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
