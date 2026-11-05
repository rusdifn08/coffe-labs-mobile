import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/business_pos/widgets/manage_menu_modal.dart';
import 'package:coffee_hub_mobile/features/business_pos/widgets/add_menu_item_modal.dart';
import 'package:coffee_hub_mobile/features/business_pos/widgets/pos_discount_modal.dart';
import 'package:coffee_hub_mobile/models/business_pos_models.dart';

void main() {
  final testItems = [
    const BusinessMenuItem(
      id: '1',
      storeId: 's1',
      name: 'Single Origin Filter',
      description: 'V60 brew with floral notes',
      category: 'Filter Coffee',
      priceCents: 42000,
      assetUrl: 'https://example.com/img.png',
      assetFormat: 'PNG',
      showInAod: true,
      showInPos: true,
    ),
  ];

  testWidgets('ManageMenuModal renders properly in dialog without paint assertion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                ManageMenuModal.show(context, menuItems: testItems, onMenuChanged: () {});
              },
              child: const Text('Open Manage'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Manage'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Kelola Katalog & Display AOD'), findsOneWidget);
    expect(find.text('Single Origin Filter'), findsOneWidget);
  });

  testWidgets('AddMenuItemModal renders properly in dialog without paint assertion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                AddMenuItemModal.show(context, onMenuAdded: () {});
              },
              child: const Text('Open Add'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Add'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tambah Menu Baru (POS & AOD)'), findsOneWidget);
  });

  testWidgets('PosDiscountModal renders properly without paint assertion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                PosDiscountModal.show(context, subtotal: 50000, onApply: (discount, reason) {});
              },
              child: const Text('Open Discount'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Discount'));
    await tester.pumpAndSettle();

    expect(find.text('Diskon & Potongan Barista'), findsOneWidget);
  });
}
