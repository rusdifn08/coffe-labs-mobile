import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:coffee_hub_mobile/features/qris_billing/domain/services/emvco_qris_converter.dart';
import 'package:coffee_hub_mobile/features/qris_billing/presentation/screens/dynamic_qris_checkout_screen.dart';
import 'package:coffee_hub_mobile/features/qris_billing/presentation/screens/subscription_activated_success_screen.dart';
import 'package:coffee_hub_mobile/features/qris_billing/presentation/screens/subscription_plan_selector_screen.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:coffee_hub_mobile/services/subscription_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('QRIS Promo 2026 — Pure-Dart EMVCo Engine & Tier Unlock', () {
    test('EmvcoQrisConverter converts official Coffeelabs Livin Merchant QRIS for 99K Pro & 249K Business with exact CRC-16', () {
      expect(
        EmvcoQrisConverter.verifyQrisCrc16(
          EmvcoQrisConverter.defaultCoffeelabsStaticQris,
        ),
        isTrue,
      );

      final proQris = EmvcoQrisConverter.buildDynamicQris(99240);
      expect(proQris.startsWith('000201010212'), isTrue);
      expect(proQris.contains('5405992405802ID'), isTrue);
      expect(proQris.contains('5910Coffeelabs'), isTrue);
      expect(EmvcoQrisConverter.verifyQrisCrc16(proQris), isTrue);

      final bizQris = EmvcoQrisConverter.buildDynamicQris(249842);
      expect(bizQris.startsWith('000201010212'), isTrue);
      expect(bizQris.contains('54062498425802ID'), isTrue);
      expect(bizQris.contains('5910Coffeelabs'), isTrue);
      expect(EmvcoQrisConverter.verifyQrisCrc16(bizQris), isTrue);

      final resilientPro = EmvcoQrisConverter.buildResilientLifetimeInvoice(
        planCode: 'PRO_LIFETIME',
        explicitUniqueCode: 240,
      );
      expect(resilientPro.baseAmountIdr, 99000);
      expect(resilientPro.totalPayableIdr, 99240);
      expect(resilientPro.isLifetime, isTrue);
      expect(resilientPro.formattedTotal, 'Rp 99.240');
      expect(EmvcoQrisConverter.verifyQrisCrc16(resilientPro.dynamicQrisPayload), isTrue);

      final resilientBiz = EmvcoQrisConverter.buildResilientLifetimeInvoice(
        planCode: 'BUSINESS_LIFETIME',
        explicitUniqueCode: 842,
      );
      expect(resilientBiz.baseAmountIdr, 249000);
      expect(resilientBiz.totalPayableIdr, 249842);
      expect(resilientBiz.isBusiness, isTrue);
      expect(resilientBiz.isLifetime, isTrue);
      expect(resilientBiz.formattedTotal, 'Rp 249.842');
      expect(EmvcoQrisConverter.verifyQrisCrc16(resilientBiz.dynamicQrisPayload), isTrue);
    });

    test('AuthService.applyUpgradedTierSession upgrades trial account to Pro and Business instantaneously without logout', () async {
      const initialUser = AuthUser(
        id: 'user-trial-01',
        username: 'barista_demo',
        fullName: 'Barista Demo',
        role: 'user',
        status: 'approved',
        tier: 'trial',
        avatarUrl: 'assets/images/characters/avatar_1.png',
      );
      SharedPreferences.setMockInitialValues({
        'coffeehub_auth_user_json': jsonEncode(initialUser.toJson()),
        'coffeehub_auth_jwt_token': 'old.jwt.token',
      });

      expect(await SubscriptionService.isProOrBusiness(), isFalse);
      expect(await SubscriptionService.isBusiness(), isFalse);

      final proUser = await AuthService.applyUpgradedTierSession(
        newTier: 'pro',
        planCode: 'PRO_LIFETIME',
        freshAccessToken: 'fresh.pro.jwt',
      );
      expect(proUser?.tier, 'pro');
      expect(proUser?.isPro, isTrue);
      expect(await AuthService.getToken(), 'fresh.pro.jwt');
      expect(await SubscriptionService.isProOrBusiness(), isTrue);

      final bizUser = await AuthService.applyUpgradedTierSession(
        newTier: 'business',
        planCode: 'BUSINESS_LIFETIME',
        freshAccessToken: 'fresh.biz.jwt',
      );
      expect(bizUser?.tier, 'business');
      expect(bizUser?.isBusiness, isTrue);
      expect(await AuthService.getToken(), 'fresh.biz.jwt');
      expect(await SubscriptionService.isBusiness(), isTrue);
    });
  });

  group('Compact QRIS UI Gate — 360px No-Overflow & No Dinamis/Lifetime Wording', () {
    testWidgets('SubscriptionPlanSelectorScreen renders compact 99K Pro & 249K Business cleanly at 360x780 without Dinamis/Lifetime wording', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SubscriptionPlanSelectorScreen(initialTier: 'pro'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.text('Pilih Lisensi Coffee Labs'), findsOneWidget);
      expect(find.text('PROMO AKHIR 2026'), findsOneWidget);
      expect(find.text('Rp 99.000'), findsWidgets);
      expect(find.text('Bayar via QRIS'), findsOneWidget);
      expect(find.textContaining('Dinamis'), findsNothing);
      expect(find.textContaining('Lifetime'), findsNothing);
      expect(find.textContaining('LIFETIME'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(ListView), const Offset(0, -280));
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text('Rp 249.000'), findsOneWidget);
      expect(find.textContaining('Dinamis'), findsNothing);
      expect(find.textContaining('Lifetime'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DynamicQrisCheckoutScreen fits compact Coffeelabs QRIS card, Save CTA & Instant Verify CTA above the fold at 360x780', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final invoice = EmvcoQrisConverter.buildResilientLifetimeInvoice(
        planCode: 'PRO_LIFETIME',
        explicitUniqueCode: 240,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: DynamicQrisCheckoutScreen(initialInvoice: invoice),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Pembayaran QRIS'), findsOneWidget);
      expect(find.text('QRIS'), findsOneWidget);
      expect(find.text('GPN'), findsOneWidget);
      expect(find.text('Coffee Labs Indonesia'), findsOneWidget);
      expect(find.text('Rp 99.240'), findsOneWidget);
      expect(find.text('Salin Nominal'), findsOneWidget);
      // Both primary CTAs fit on screen without even needing to scroll!
      expect(find.text('Simpan Gambar QRIS ke Galeri'), findsOneWidget);
      expect(find.text('Sudah Bayar? Verifikasi & Aktifkan'), findsOneWidget);
      expect(find.textContaining('Dinamis'), findsNothing);
      expect(find.textContaining('Lifetime'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SubscriptionActivatedSuccessScreen renders Business confirmation cleanly at 360x780 without Lifetime wording', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SubscriptionActivatedSuccessScreen(
            newTier: 'business',
            invoiceNumber: 'CL-LT-20261119-8F3K1',
            amountPaidLabel: 'Rp 249.842',
            isLifetime: true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('PEMBAYARAN QRIS BERHASIL'), findsOneWidget);
      expect(find.text('Coffee Labs Indonesia'), findsOneWidget);
      expect(find.textContaining('Coffee Labs Business'), findsWidgets);
      expect(find.text('Aktif Penuh (Sekali Bayar)'), findsOneWidget);
      expect(find.text('Rp 249.842'), findsOneWidget);
      expect(find.textContaining('Lifetime'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
