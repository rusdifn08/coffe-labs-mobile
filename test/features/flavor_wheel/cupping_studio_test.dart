import 'package:coffee_hub_mobile/screens/flavor_wheel_screen.dart';
import 'package:coffee_hub_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SCA Cupping Lab Compact 3-Step Studio (360x780)', () {
    testWidgets(
      'renders all 3 guided tabs, demo data, and zero overflow at 360x780',
      (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FlavorWheelScreen(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // AppBar & 3 tabs visible
        expect(find.text('SCA Cupping Lab'), findsOneWidget);
        expect(find.text('1. Sampel'), findsOneWidget);
        expect(find.text('2. Rasa & Notes'), findsOneWidget);
        expect(find.text('3. Skor SCA'), findsOneWidget);

        // Load Demo Data (populates multi-varieties, notes, aftertaste, scores)
        await tester.tap(find.text('Contoh Demo'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('91.25'), findsOneWidget);

        // Navigate to Step 2: Rasa & Notes
        await tester.tap(find.text('2. Rasa & Notes'));
        await tester.pumpAndSettle();
        expect(find.text('Flavor Wheel & Tasting Notes'), findsOneWidget);
        expect(find.text('Aftertaste (Sensasi Akhir)'), findsOneWidget);
        expect(find.text('Mouthfeel / Body (Tekstur)'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Navigate to Step 3: Skor SCA
        await tester.tap(find.text('3. Skor SCA'));
        await tester.pumpAndSettle();
        expect(find.text('Fragrance & Aroma'), findsOneWidget);
        expect(find.text('Simpan Sesi Cupping ke Journal'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Test SCA Defect deduction (-2 lowers 91.25 -> 89.25)
        await tester.scrollUntilVisible(
          find.text('Taint (-2)'),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(find.text('Taint (-2)'));
        await tester.pumpAndSettle();
        expect(find.text('89.25'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'supports multi-select Varieties popup & Process popup without horizontal scroll',
      (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FlavorWheelScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Open Multi-Select Varieties Popup
        await tester.tap(find.text('Varietas Kopi (Multi-Pilih)'));
        await tester.pumpAndSettle();
        expect(find.text('Pilih Varietas Kopi'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Select a second variety (Pink Bourbon) in addition to default Bourbon
        await tester.tap(find.text('Pink Bourbon').first);
        await tester.pumpAndSettle();
        expect(find.text('Terapkan Varietas (2)'), findsOneWidget);

        await tester.tap(find.text('Terapkan Varietas (2)'));
        await tester.pumpAndSettle();
        expect(find.text('Bourbon'), findsOneWidget);
        expect(find.text('Pink Bourbon'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Open Process Popup & select Natural Anaerobic as well
        await tester.tap(find.text('Proses Pasca-Panen'));
        await tester.pumpAndSettle();
        expect(find.text('Pilih Proses Pasca-Panen'), findsOneWidget);
        await tester.tap(find.text('Natural').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Terapkan Pilihan (2)'));
        await tester.pumpAndSettle();
        expect(find.text('Natural'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'opens Tasting Notes & Aftertaste popups cleanly from Step 2 with zero overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FlavorWheelScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Go to Step 2
        await tester.tap(find.text('2. Rasa & Notes'));
        await tester.pumpAndSettle();

        // Open SCA Flavor Wheel Popup
        await tester.tap(find.text('Pilih Tasting Notes (SCA Wheel)'));
        await tester.pumpAndSettle();
        expect(find.text('SCA Flavor Wheel & Notes'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Close popup via confirm button
        await tester.tap(find.textContaining('Simpan Tasting Notes'));
        await tester.pumpAndSettle();

        // Open Aftertaste Popup
        await tester.tap(find.text('Karakter Aftertaste'));
        await tester.pumpAndSettle();
        expect(find.text('Lingering Sweetness'), findsOneWidget);
        await tester.tap(find.text('Lingering Sweetness'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Terapkan Pilihan (2)'));
        await tester.pumpAndSettle();
        expect(find.text('Lingering Sweetness'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
