import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/widgets/brew_dripper_glass_icon.dart';
import 'package:coffee_hub_mobile/widgets/notched_nav_bar_painter.dart';

void main() {
  group('BrewDripperGlassIcon & NotchedNavBarPainter', () {
    testWidgets('BrewDripperGlassIcon renders without error with custom color and size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BrewDripperGlassIcon(
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BrewDripperGlassIcon), findsOneWidget);
    });

    test('NotchedNavBarPainter creates valid path with scoop notch in center', () {
      const painter = NotchedNavBarPainter(
        backgroundColor: Colors.white,
        borderColor: Colors.grey,
        buttonCenterY: 3.0,
        buttonRadius: 27.0,
        gap: 5.0,
        filletRadius: 14.0,
      );

      final path = painter.createPath(const Size(390, 68));
      expect(path, isNotNull);
      final bounds = path.getBounds();
      expect(bounds.width, equals(390));
      expect(bounds.height, greaterThanOrEqualTo(68));
      // Top bounds must be 0.0 (no upward bulge or horns)
      expect(bounds.top, equals(0.0));

      final topBorderPath = painter.createTopBorderPath(const Size(390, 68));
      expect(topBorderPath, isNotNull);
      final borderBounds = topBorderPath.getBounds();
      expect(borderBounds.top, equals(0.0));
      expect(borderBounds.bottom, greaterThan(0.0));
    });

    testWidgets('CustomPaint renders NotchedNavBarPainter on canvas cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(390, 68),
              painter: const NotchedNavBarPainter(
                backgroundColor: Colors.white,
                borderColor: Color(0xFFEDE5DE),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
