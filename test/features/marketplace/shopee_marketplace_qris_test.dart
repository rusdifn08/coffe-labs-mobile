import 'package:coffee_hub_mobile/features/checkout/widgets/checkout_receipt_sheet.dart';
import 'package:coffee_hub_mobile/features/checkout/widgets/qris_payment_sheet.dart';
import 'package:coffee_hub_mobile/features/marketplace/utils/coffee_bag_image_resolver.dart';
import 'package:coffee_hub_mobile/features/marketplace/utils/qris_payload_builder.dart';
import 'package:coffee_hub_mobile/features/marketplace/widgets/coffee_bag_product_visual.dart';
import 'package:coffee_hub_mobile/features/marketplace/widgets/shopee_coffee_product_card.dart';
import 'package:coffee_hub_mobile/features/marketplace_detail/widgets/marketplace_variant_picker_sheet.dart';
import 'package:coffee_hub_mobile/screens/checkout_screen.dart';
import 'package:coffee_hub_mobile/screens/marketplace_product_detail_screen.dart';
import 'package:coffee_hub_mobile/screens/marketplace_screen.dart';
import 'package:coffee_hub_mobile/services/marketplace_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await MarketplaceService.instance.clearCart();
  });

  test('No product in MarketplaceService uses barista portraits or UI screenshots', () {
    final products = MarketplaceService.instance.products;
    expect(products.length, greaterThan(100));

    for (final p in products) {
      expect(
        p.imageUrl.toLowerCase().contains('avatars/'),
        isFalse,
        reason: 'Product ${p.id} leaked portrait image ${p.imageUrl}',
      );
      expect(
        CoffeeBagImageResolver.isBlockedPortraitOrScreenshot('assets/images/avatars/covers/mikael_jasin.jpg'),
        isTrue,
      );
      expect(
        CoffeeBagImageResolver.isBlockedPortraitOrScreenshot('assets/images/beans/fugol_sample_a.jpg'),
        isTrue,
      );
    }
  });

  test('EMVCo Dynamic QRIS payload has valid CRC16 and non-QRIS payment is rejected', () async {
    final qr = MarketplaceQrisPayloadBuilder.buildDynamicPayload(
      orderCode: 'CL-2026-TEST01',
      totalIdr: 165000,
    );
    expect(qr.startsWith('000201010212'), isTrue);
    expect(qr.contains('5303360'), isTrue);
    expect(qr.contains('5406165000'), isTrue);
    expect(qr.contains('CL-2026-TEST01'), isTrue);
    final bodyWithoutCrc = qr.substring(0, qr.length - 4);
    final crc = qr.substring(qr.length - 4);
    expect(crc, MarketplaceQrisPayloadBuilder.computeCrc16(bodyWithoutCrc));

    expect(
      () => MarketplaceService.instance.placeOrder(
        recipientName: 'Rusdi',
        phoneNumber: '08123456',
        shippingAddress: 'Jakarta',
        courierName: 'SiCepat',
        shippingFee: 20000,
        paymentMethod: 'BCA VA',
      ),
      throwsArgumentError,
    );
  });

  test('Marketplace has zero vouchers, zero Fresh Deals, and zero fake discounts', () {
    final service = MarketplaceService.instance;
    expect(service.flashSaleProducts, isEmpty);
    expect(service.applyVoucher('COFFEEFIRST'), isFalse);
    expect(service.applyVoucher('FREESHIP'), isFalse);
    expect(service.appliedVoucher, isNull);
    expect(service.voucherDiscount, 0);

    for (final p in service.products) {
      expect(p.isFlashSale, isFalse, reason: '${p.id} must not be flash sale');
      expect(p.discountPct, 0, reason: '${p.id} must have transparent pricing (0% fake discount)');
      expect(p.originalPrice200g, isNull);
    }
  });

  testWidgets(
      'Shopee/Tokopedia-style Marketplace renders 5-tab navbar without vouchers/Fresh Deals at 360x780 and flows to QRIS checkout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: MarketplaceScreen()));
    await tester.pump(const Duration(milliseconds: 250));

    // Zero voucher & zero Fresh Deals UI
    expect(find.textContaining('FRESH DEALS'), findsNothing);
    expect(find.textContaining('COFFEEFIRST'), findsNothing);
    expect(find.text('PROMO QRIS'), findsNothing);
    expect(find.text('-15%'), findsNothing);

    // Shopee / Tokopedia 5-tab bottom navbar + clean Trust & Official Roastery UI
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Roastery'), findsOneWidget);
    expect(find.text('Favorit'), findsOneWidget);
    expect(find.text('Keranjang'), findsOneWidget);
    expect(find.text('Pesanan'), findsOneWidget);
    expect(find.text('Roastery Official Pilihan'), findsOneWidget);
    expect(find.text('Single Origin'), findsWidgets);
    expect(find.text('Espresso'), findsWidgets);
    expect(find.text('Filter V60'), findsWidgets);
    expect(find.text('Terkait'), findsOneWidget);
    expect(find.byType(ShopeeCoffeeProductCard), findsWidgets);
    expect(find.byType(CoffeeBagProductVisual), findsWidgets);
    expect(tester.takeException(), isNull);

    // Navigate across all navbar tabs cleanly
    for (final tab in ['Roastery', 'Favorit', 'Keranjang', 'Pesanan', 'Beranda']) {
      await tester.tap(find.text(tab));
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
    }

    // Tap first product card to enter Shopee-style Detail Page
    await tester.tap(find.byType(ShopeeCoffeeProductCard).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MarketplaceProductDetailScreen), findsOneWidget);
    expect(find.text('Kunjungi Roastery'), findsOneWidget);
    expect(find.text('+ Keranjang'), findsOneWidget);
    expect(find.text('Beli Sekarang'), findsOneWidget);

    // Tap Beli Sekarang -> Variant Picker Sheet
    await tester.tap(find.text('Beli Sekarang'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(MarketplaceVariantPickerSheet), findsOneWidget);
    expect(find.text('Pilih Berat Kemasan'), findsOneWidget);
    expect(find.text('Pilih Gilingan (Grind Size)'), findsOneWidget);

    // Confirm purchase -> navigates straight to QRIS-only CheckoutScreen
    await tester.tap(find.textContaining('Beli Sekarang via QRIS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(CheckoutScreen), findsOneWidget);
    expect(find.text('QRIS (Semua E-Wallet & Mobile Banking)'), findsOneWidget);
    expect(find.text('BCA Virtual Account'), findsNothing);
    expect(find.text('Mandiri Virtual Account'), findsNothing);
    expect(find.text('GoPay / GoPay Later'), findsNothing);

    // Tap Bayar via QRIS -> shows Dynamic QRIS QR Code Sheet
    await tester.tap(find.text('Bayar via QRIS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(QrisPaymentSheet), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Pembayaran QRIS Dinamis'), findsOneWidget);
    expect(find.text('Saya Sudah Bayar QRIS'), findsOneWidget);

    // Confirm QRIS payment -> opens Receipt Modal with QRIS confirmation
    await tester.ensureVisible(find.text('Saya Sudah Bayar QRIS'));
    await tester.tap(find.text('Saya Sudah Bayar QRIS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(QrisPaymentSheet), findsNothing);
    expect(find.text('Pesanan Berhasil Dibuat!'), findsOneWidget);
    expect(find.text('QRIS'), findsOneWidget);
    expect(CheckoutReceiptSheet, isNotNull);
  });
}
