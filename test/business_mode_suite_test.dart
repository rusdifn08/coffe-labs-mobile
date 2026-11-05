import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coffee_hub_mobile/models/business_pos_models.dart';
import 'package:coffee_hub_mobile/features/business_pos/models/business_stock_models.dart';
import 'package:coffee_hub_mobile/features/business_pos/services/business_stock_service.dart';
import 'package:coffee_hub_mobile/features/business_pos/screens/business_main_layout.dart';
import 'package:coffee_hub_mobile/features/business_pos/screens/business_dashboard_home_screen.dart';
import 'package:coffee_hub_mobile/providers/workspace_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Mode Business Suite & Workspace Tests', () {
    test('WorkspaceMode enum includes business and switches state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(workspaceModeProvider), WorkspaceMode.personalBrewer);

      container.read(workspaceModeProvider.notifier).switchToBusiness();
      expect(container.read(workspaceModeProvider), WorkspaceMode.business);

      container.read(workspaceModeProvider.notifier).switchToPersonal();
      expect(container.read(workspaceModeProvider), WorkspaceMode.personalBrewer);
    });

    test('BusinessStockService loads realistic cafe stock and calculates capacity', () async {
      final items = await BusinessStockService.loadStockItems();
      expect(items.isNotEmpty, true);

      // Verify categories
      final hasBeans = items.any((i) => i.category == StockCategory.beans);
      final hasDairy = items.any((i) => i.category == StockCategory.dairy);
      final hasSyrup = items.any((i) => i.category == StockCategory.syrup);
      final hasPackaging = items.any((i) => i.category == StockCategory.packaging);

      expect(hasBeans, true);
      expect(hasDairy, true);
      expect(hasSyrup, true);
      expect(hasPackaging, true);

      // Verify brew capacity calculation
      final capacity = BusinessStockService.calculateTotalBrewCapacity(items);
      expect(capacity, greaterThan(0));

      // Verify low stock detection
      final lowCount = BusinessStockService.getLowStockAlertCount(items);
      expect(lowCount, greaterThanOrEqualTo(1)); // Oat milk / syrup configured as low
    });

    test('BusinessStockService records restock and usage with audit logs', () async {
      final items = await BusinessStockService.loadStockItems();
      final bean = items.firstWhere((i) => i.category == StockCategory.beans);
      final initialQty = bean.currentQty;

      // 1. Restock 500g
      final successRestock = await BusinessStockService.restockItem(
        itemId: bean.id,
        addQty: 500,
        barista: 'Barista Tester',
        note: 'Restock test batch',
      );
      expect(successRestock, true);

      var updatedItems = await BusinessStockService.loadStockItems();
      var updatedBean = updatedItems.firstWhere((i) => i.id == bean.id);
      expect(updatedBean.currentQty, initialQty + 500);

      // 2. Record usage 100g
      final successUsage = await BusinessStockService.recordUsage(
        itemId: bean.id,
        deductQty: 100,
        barista: 'Barista Tester',
        note: 'Dial-in espresso morning',
        isWaste: true,
      );
      expect(successUsage, true);

      updatedItems = await BusinessStockService.loadStockItems();
      updatedBean = updatedItems.firstWhere((i) => i.id == bean.id);
      expect(updatedBean.currentQty, initialQty + 500 - 100);

      // 3. Verify logs
      final logs = await BusinessStockService.loadRecentLogs();
      expect(logs.isNotEmpty, true);
      expect(logs.any((l) => l.actionType == 'Waste/Tumpah'), true);
      expect(logs.any((l) => l.actionType == 'Restock'), true);
    });

    testWidgets('BusinessMainLayout renders 5 tabs and elevated Display center button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BusinessMainLayout(initialTabIndex: 0),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Tab labels in navigation bar
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Kasir'), findsWidgets);
      expect(find.text('Display'), findsWidgets);
      expect(find.text('Stock'), findsWidgets);
      expect(find.text('Setting'), findsWidgets);

      // Verify Mode Personal switcher pill in Home
      expect(find.text('Mode Personal'), findsOneWidget);

      // Switch to Display tab (center button)
      await tester.tap(find.text('Display').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Display screen should have Kiosk launcher button
      expect(find.text('Luncurkan Layar Penuh Kiosk AOD'), findsOneWidget);

      // Switch to Stock Opname tab
      await tester.tap(find.text('Stock').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Stock Opname screen should display inventory categories
      expect(find.text('Stock Opname Bahan Baku'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);

      // Switch to Setting tab
      await tester.tap(find.text('Setting').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Setting screen should display prominent Switch to Personal card
      expect(find.text('Kembali ke Mode Personal'), findsOneWidget);
    });

    testWidgets('BusinessDashboardHomeScreen renders 1-row KPIs, 4 Quick Actions and editable cafe identity', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BusinessDashboardHomeScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 4 KPI metrics verified
      expect(find.text('OMSET HARI INI'), findsOneWidget);
      expect(find.text('Rp 1.845.000'), findsOneWidget);
      expect(find.text('Transaksi'), findsOneWidget);
      expect(find.text('48 Order'), findsOneWidget);
      expect(find.text('Cup Kopi'), findsOneWidget);
      expect(find.text('62 Cup'), findsOneWidget);
      expect(find.text('Rata-rata'), findsOneWidget);
      expect(find.text('Rp 38.4k'), findsOneWidget);

      // 4 Quick action cards verified
      expect(find.text('POS Kasir'), findsOneWidget);
      expect(find.text('Display Kiosk'), findsOneWidget);
      expect(find.text('Stock Opname'), findsOneWidget);
      expect(find.text('Rekap Shift'), findsOneWidget);

      // Tap on Store Name / Header to trigger edit dialog
      await tester.tap(find.byIcon(CupertinoIcons.pencil).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Dialog should open
      expect(find.text('Ubah Identitas Kafe / Resto'), findsOneWidget);
      expect(find.text('PILIH LOGO EMBLEM SPESIAL KAFE'), findsOneWidget);
    });
  });
}
