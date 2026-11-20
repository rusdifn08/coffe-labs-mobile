import 'package:coffee_hub_mobile/features/business_pos/widgets/business_suite_launcher_card.dart';
import 'package:coffee_hub_mobile/features/profile/widgets/profile_subscription_card.dart';
import 'package:coffee_hub_mobile/features/profile/widgets/subscription_checkout_sheet.dart';
import 'package:coffee_hub_mobile/models/subscription_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Subscription Plan & Purchase Sheet Updated Features', () {
    test('SubscriptionPlan.pro and SubscriptionPlan.business reflect upgraded features', () {
      final proFeatures = SubscriptionPlan.pro.features.join('\n');
      expect(proFeatures, contains('500+ Resep'));
      expect(proFeatures, contains('Seduh Tanpa Batas'));
      expect(proFeatures, contains('Toolkit Barista'));
      expect(proFeatures, contains('Game V60 3D'));
      expect(proFeatures, contains('E-Book DRM'));
      expect(proFeatures, contains('AI Bean Scanner'));
      expect(proFeatures, isNot(contains('409+')));
      expect(proFeatures, isNot(contains('8 Grinder')));

      final businessFeatures = SubscriptionPlan.business.features.join('\n');
      expect(businessFeatures, contains('500+ Resep'));
      expect(businessFeatures, contains('Toolkit Barista'));
      expect(businessFeatures, contains('POS Kasir'));
      expect(businessFeatures, contains('OLED/AMOLED Always-On'));
      expect(businessFeatures, contains('Stok Opname'));
      expect(businessFeatures, contains('Cetak Struk Thermal Bluetooth'));
      expect(businessFeatures, contains('QR Live Brew'));
    });

    testWidgets(
      'SubscriptionCheckoutSheet renders all Pro & Business features cleanly at 375x780 without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(375, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SubscriptionCheckoutSheet(
                  initialPlan: SubscriptionPlan.pro,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pilih Lisensi Coffee Labs'), findsOneWidget);
        expect(find.textContaining('500+ Resep Juara Dunia & Nusantara'), findsOneWidget);
        expect(find.textContaining('Seduh Tanpa Batas (Unlimited Brews)'), findsOneWidget);
        expect(find.textContaining('Toolkit Barista Lengkap 21 Fitur'), findsOneWidget);

        // Scroll inside sheet to check Business card features
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -320));
        await tester.pump();

        expect(find.textContaining('Seluruh Fitur Coffee Labs Pro (500+ Resep, Seduh Tanpa Batas & Toolkit Barista)'), findsOneWidget);
        expect(find.textContaining('POS Kasir Lengkap'), findsOneWidget);
        expect(find.textContaining('Display Kiosk Pelanggan'), findsOneWidget);
        expect(find.textContaining('Stok Opname'), findsOneWidget);
        expect(find.textContaining('Cetak Struk Thermal Bluetooth'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ProfileSubscriptionCard & BusinessSuiteLauncherCard display updated copy',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProfileSubscriptionCard(
                        currentPlan: SubscriptionPlan.trial,
                        isTrial: true,
                        onRefresh: () {},
                      ),
                      const BusinessSuiteLauncherCard(isBusiness: false),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('500+ Resep, Seduh Tanpa Batas & Toolkit Barista'),
          findsOneWidget,
        );

        await tester.tap(find.text('Mode Business'));
        await tester.pumpAndSettle();

        expect(find.text('Business Suite Eksklusif'), findsOneWidget);
        expect(find.textContaining('Stok Opname Bahan Kafe'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
