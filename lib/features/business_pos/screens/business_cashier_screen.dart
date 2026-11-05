import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/business_pos_models.dart';
import '../../../providers/pos_cart_provider.dart';
import '../../../providers/workspace_mode_provider.dart';
import '../../../services/business_pos_api_service.dart';
import '../services/thermal_receipt_service.dart';
import '../widgets/add_menu_item_modal.dart';
import '../widgets/manage_menu_modal.dart';
import '../widgets/menu_grid_configurator_modal.dart';
import '../widgets/oled_compatibility_dialog.dart';
import '../widgets/pos_discount_modal.dart';
import '../widgets/receipt_preview_modal.dart';
import '../widgets/business_menu_asset_image.dart';
import 'customer_aod_menu_screen.dart';
import 'oled_diagnostic_screen.dart';
import 'shift_summary_screen.dart';

class BusinessCashierScreen extends ConsumerStatefulWidget {
  const BusinessCashierScreen({super.key});

  @override
  ConsumerState<BusinessCashierScreen> createState() => _BusinessCashierScreenState();
}

class _BusinessCashierScreenState extends ConsumerState<BusinessCashierScreen> {
  BusinessStoreConfig _config = BusinessStoreConfig.defaultBarConfig();
  List<BusinessMenuItem> _menuItems = [];
  String _selectedCategory = 'All';
  String _selectedScope = 'All'; // 'All', 'aod', 'pos'
  bool _isLoading = true;
  int _discountAmount = 0;
  String _discountReason = '';

  // Akumulator Metrik Shift Barista
  int _shiftTotalSales = 0;
  int _shiftTotalOrders = 0;
  int _shiftCashTotal = 0;
  int _shiftQrisTotal = 0;
  int _shiftCardTotal = 0;
  int _shiftDiscountTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final conf = await BusinessPosApiService.fetchStoreConfig();
    final items = await BusinessPosApiService.fetchMenuList();
    if (mounted) {
      setState(() {
        if (conf != null) _config = conf;
        _menuItems = items;
        _isLoading = false;
      });
    }
  }

  void _openGridConfigModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MenuGridConfiguratorModal(
        config: _config,
        onConfigUpdated: _loadData,
      ),
    );
  }

  void _openAddMenuModal() {
    AddMenuItemModal.show(context, onMenuAdded: _loadData);
  }

  void _openManageMenuModal() {
    ManageMenuModal.show(context, menuItems: _menuItems, onMenuChanged: _loadData);
  }

  void _openOledDiagnostics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OledDiagnosticScreen()),
    );
  }

  void _openShiftSummary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShiftSummaryScreen(
          totalSales: _shiftTotalSales,
          totalOrders: _shiftTotalOrders,
          cashTotal: _shiftCashTotal,
          qrisTotal: _shiftQrisTotal,
          cardTotal: _shiftCardTotal,
          discountTotal: _shiftDiscountTotal,
          onResetShift: () {
            setState(() {
              _shiftTotalSales = 0;
              _shiftTotalOrders = 0;
              _shiftCashTotal = 0;
              _shiftQrisTotal = 0;
              _shiftCardTotal = 0;
              _shiftDiscountTotal = 0;
            });
          },
        ),
      ),
    );
  }

  void _launchCustomerAod() {
    // Validasi panel layar OLED/AMOLED sebelum masuk mode kiosk
    OledCompatibilityDialog.checkAndShowIfNeeded(
      context,
      onProceed: () {
        ref.read(workspaceModeProvider.notifier).forceSetMode(WorkspaceMode.customerAodDisplay);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerAodMenuScreen(config: _config, initialMenuItems: _menuItems),
          ),
        );
      },
      onOpenDiagnostic: _openOledDiagnostics,
    );
  }

  Future<void> _processCheckout() async {
    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty) return;

    final subtotal = cart.subtotal;
    final finalTotal = (subtotal - _discountAmount).clamp(0, 999999999);

    final success = await BusinessPosApiService.submitPosOrder({
      'customer_name': cart.customerName ?? 'Bar Customer',
      'payment_method': cart.paymentMethod,
      'items': cart.items
          .map((i) => {
                'menu_item_id': i.menuItem.id,
                'item_name': i.menuItem.name,
                'quantity': i.quantity,
                'unit_price_cents': i.menuItem.priceCents,
                'modifiers_json': i.modifiers,
              })
          .toList(),
    });

    if (mounted) {
      if (success) {
        // Akumulasi data shift kasir
        setState(() {
          _shiftTotalSales += finalTotal;
          _shiftTotalOrders += 1;
          _shiftDiscountTotal += _discountAmount;
          if (cart.paymentMethod == 'Cash') {
            _shiftCashTotal += finalTotal;
          } else if (cart.paymentMethod == 'QRIS') {
            _shiftQrisTotal += finalTotal;
          } else {
            _shiftCardTotal += finalTotal;
          }
        });

        // Susun data struk termal
        final receiptData = ThermalReceiptData(
          storeName: _config.storeName,
          storeAddress: 'Coffee Labs Bar Counter • Specialty Espresso',
          cashierName: 'Barista Utama',
          customerName: cart.customerName ?? 'Pelanggan Meja Bar',
          orderNumber: '#${(DateTime.now().millisecondsSinceEpoch % 9000) + 1000}',
          orderTime: DateTime.now(),
          items: cart.items,
          subtotal: subtotal,
          discount: _discountAmount,
          tax: 0,
          grandTotal: finalTotal,
          paymentMethod: cart.paymentMethod,
          footerNote: _discountReason.isNotEmpty ? 'Promo: $_discountReason' : null,
        );

        // Reset keranjang belanja & diskon
        ref.read(posCartProvider.notifier).clearCart();
        setState(() {
          _discountAmount = 0;
          _discountReason = '';
        });

        // Munculkan preview struk termal autentik
        ReceiptPreviewModal.show(
          context,
          data: receiptData,
          onNewTransaction: () {
            // Siap melayani pesanan berikutnya
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrWide = screenWidth >= 750;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () {
            ref.read(workspaceModeProvider.notifier).forceSetMode(WorkspaceMode.personalBrewer);
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
              ),
              child: const Text(
                'POS KASIR',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _config.storeName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.plus_circle_fill, color: Color(0xFFD4AF37)),
            tooltip: 'Tambah Menu (Pajangan / Kasir)',
            onPressed: _openAddMenuModal,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.square_grid_2x2_fill, color: Colors.white70),
            tooltip: 'Kelola & Urutkan Menu',
            onPressed: _openManageMenuModal,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.chart_bar_square_fill, color: Color(0xFFD4AF37)),
            tooltip: 'Rekap Kasir & Tutup Shift',
            onPressed: _openShiftSummary,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.waveform_path_ecg, color: Colors.white70),
            tooltip: 'Diagnostik Layar OLED / AMOLED',
            onPressed: _openOledDiagnostics,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.slider_horizontal_3, color: Colors.white70),
            tooltip: 'Konfigurasi Grid AOD',
            onPressed: _openGridConfigModal,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _launchCustomerAod,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(CupertinoIcons.tv_fill, size: 16),
              label: const Text('Mode Pajangan (AOD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator(color: Color(0xFFD4AF37)))
          : isTabletOrWide
              ? Row(
                  children: [
                    // Sisi Kiri: Menu Grid (60% Lebar)
                    Expanded(
                      flex: 60,
                      child: _buildMenuCatalogSection(),
                    ),
                    const VerticalDivider(width: 1, color: Colors.white12),
                    // Sisi Kanan: Live Receipt & Cart (40% Lebar)
                    Expanded(
                      flex: 40,
                      child: _buildLiveReceiptSection(),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(child: _buildMenuCatalogSection()),
                    _buildMobileCartSummary(),
                  ],
                ),
    );
  }

  Widget _buildMenuCatalogSection() {
    final categories = ['All', ...{..._menuItems.map((m) => m.category)}];

    // Filter menu berdasarkan Scope (Semua vs Pajangan AOD vs Kasir Saja)
    List<BusinessMenuItem> scopeFiltered = _menuItems;
    if (_selectedScope == 'aod') {
      scopeFiltered = _menuItems.where((m) => m.showInAod).toList();
    } else if (_selectedScope == 'pos') {
      scopeFiltered = _menuItems.where((m) => m.showInPos).toList();
    }

    final filtered = _selectedCategory == 'All'
        ? scopeFiltered
        : scopeFiltered.where((m) => m.category == _selectedCategory).toList();

    return Column(
      children: [
        // Barista Quick Action Strip
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_menuItems.length} Total Menu',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Text(
                '• PIN Kiosk: 1234',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              InkWell(
                onTap: _openAddMenuModal,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.plus, size: 13, color: Colors.black),
                      SizedBox(width: 4),
                      Text(
                        'Tambah Menu',
                        style: TextStyle(color: Colors.black, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _openManageMenuModal,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242424),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.square_grid_2x2, size: 13, color: Color(0xFFD4AF37)),
                      SizedBox(width: 4),
                      Text(
                        'Kelola',
                        style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scope Switcher Tabs (Semua vs Pajangan AOD vs Kasir Saja)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          child: Row(
            children: [
              _buildScopeTab('Semua Menu', 'All', _menuItems.length),
              const SizedBox(width: 8),
              _buildScopeTab('Pajangan AOD', 'aod', _menuItems.where((m) => m.showInAod).length),
              const SizedBox(width: 8),
              _buildScopeTab('Kasir Saja', 'pos', _menuItems.where((m) => m.showInPos).length),
            ],
          ),
        ),

        // Category Filter Horizontal List
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              final isSel = cat == _selectedCategory;
              return ChoiceChip(
                label: Text(
                  cat,
                  style: TextStyle(
                    color: isSel ? Colors.black : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSel,
                selectedColor: const Color(0xFFD4AF37),
                backgroundColor: const Color(0xFF1E1E1E),
                side: BorderSide(color: isSel ? const Color(0xFFD4AF37) : Colors.white12),
                onSelected: (_) => setState(() => _selectedCategory = cat),
              );
            },
          ),
        ),

        // Menu Cards Grid
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.tray, color: Colors.white38, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        _selectedScope == 'aod'
                            ? 'Belum ada menu yang diatur untuk tayang di AOD.\nBuka "Kelola" dan nyalakan switch AOD.'
                            : 'Tidak ada menu pada kategori ini.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisExtent: 205,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final item = filtered[i];
                    return InkWell(
                      onTap: () {
                        ref.read(posCartProvider.notifier).addItem(item);
                      },
                      onLongPress: () {
                        _showQuickMenuSheet(item);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges (AOD / POS Scope)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (item.showInAod)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'AOD DISPLAY',
                                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 8.5, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                if (!item.isAvailable)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'HABIS',
                                      style: TextStyle(color: Colors.redAccent, fontSize: 8.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            Expanded(
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: BusinessMenuAssetImage(
                                    assetUrl: item.assetUrl,
                                    assetFormat: item.assetFormat,
                                    fit: BoxFit.cover,
                                    fallbackIconSize: 36,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Center(
                              child: Text(
                                item.formattedPrice,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildScopeTab(String label, String scopeKey, int count) {
    final isSel = _selectedScope == scopeKey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedScope = scopeKey),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFD4AF37).withValues(alpha: 0.15) : const Color(0xFF181818),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel ? const Color(0xFFD4AF37) : Colors.white10,
              width: isSel ? 1.2 : 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSel ? const Color(0xFFD4AF37) : Colors.white70,
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFD4AF37) : Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSel ? Colors.black : Colors.white60,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickMenuSheet(BusinessMenuItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(item.formattedPrice, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              ListTile(
                leading: Icon(
                  item.showInAod ? CupertinoIcons.tv_fill : CupertinoIcons.tv,
                  color: const Color(0xFFD4AF37),
                ),
                title: Text(item.showInAod ? 'Sembunyikan dari Layar AOD' : 'Tampilkan di Layar AOD', style: const TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await BusinessPosApiService.updateMenuItem(item.id, {
                    'show_in_aod': !item.showInAod,
                  });
                  _loadData();
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
                title: const Text('Hapus Menu Ini', style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await BusinessPosApiService.deleteMenuItem(item.id);
                  _loadData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveReceiptSection() {
    final cart = ref.watch(posCartProvider);
    final subtotal = cart.subtotal;
    final finalTotal = (subtotal - _discountAmount).clamp(0, 999999999);

    final formattedFinalTotal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(finalTotal);

    final formattedDiscount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(_discountAmount);

    return Container(
      color: const Color(0xFF141414),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.doc_text_fill, color: Color(0xFFD4AF37), size: 18),
                  SizedBox(width: 8),
                  Text('Pesanan Kasir Aktif', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              if (cart.items.isNotEmpty)
                TextButton(
                  onPressed: () {
                    ref.read(posCartProvider.notifier).clearCart();
                    setState(() {
                      _discountAmount = 0;
                      _discountReason = '';
                    });
                  },
                  child: const Text('Kosongkan', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                ),
            ],
          ),

          // Metode Pembayaran Bar Kasir
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildPaymentTab('Cash', cart.paymentMethod == 'Cash'),
                _buildPaymentTab('QRIS', cart.paymentMethod == 'QRIS'),
                _buildPaymentTab('EDC', cart.paymentMethod == 'EDC'),
              ],
            ),
          ),

          const Divider(color: Colors.white12),

          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.cart, color: Colors.white24, size: 40),
                        SizedBox(height: 10),
                        Text(
                          'Pilih menu di sebelah kiri untuk menambah ke pesanan kasir.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final cItem = cart.items[i];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cItem.menuItem.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  Text(
                                    cItem.menuItem.formattedPrice,
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(CupertinoIcons.minus_circle_fill, size: 20, color: Colors.white38),
                                  onPressed: () => ref.read(posCartProvider.notifier).decrementItem(cItem.menuItem.id),
                                ),
                                Text('${cItem.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(CupertinoIcons.plus_circle_fill, size: 20, color: Color(0xFFD4AF37)),
                                  onPressed: () => ref.read(posCartProvider.notifier).addItem(cItem.menuItem),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const Divider(color: Colors.white12),

          // Subtotal & Tombol Diskon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:', style: TextStyle(color: Colors.white60, fontSize: 12)),
              Text(cart.formattedTotal, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),

          if (_discountAmount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.tag_fill, size: 12, color: Colors.greenAccent),
                    const SizedBox(width: 4),
                    Text(
                      _discountReason.isNotEmpty ? _discountReason : 'Diskon',
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => setState(() {
                        _discountAmount = 0;
                        _discountReason = '';
                      }),
                      child: const Icon(CupertinoIcons.clear_circled, size: 14, color: Colors.white38),
                    ),
                  ],
                ),
                Text('-$formattedDiscount', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ],

          const SizedBox(height: 6),

          // Tombol Buka Modal Diskon
          OutlinedButton.icon(
            onPressed: cart.items.isEmpty
                ? null
                : () {
                    PosDiscountModal.show(
                      context,
                      subtotal: subtotal,
                      onApply: (discountAmount, reason) {
                        setState(() {
                          _discountAmount = discountAmount;
                          _discountReason = reason;
                        });
                      },
                    );
                  },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD4AF37), width: 0.8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(CupertinoIcons.tag, size: 13, color: Color(0xFFD4AF37)),
            label: Text(
              _discountAmount > 0 ? 'Ubah Diskon Promosi' : 'Terapkan Diskon / Promosi',
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          // Total Pembayaran Akhir
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                formattedFinalTotal,
                style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: cart.items.isEmpty ? null : _processCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(CupertinoIcons.printer_fill, size: 18),
            label: const Text('Bayar & Cetak Struk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab(String method, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(posCartProvider.notifier).setPaymentMethod(method),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            method,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCartSummary() {
    final cart = ref.watch(posCartProvider);
    if (cart.items.isEmpty) return const SizedBox.shrink();

    final subtotal = cart.subtotal;
    final finalTotal = (subtotal - _discountAmount).clamp(0, 999999999);
    final formattedFinalTotal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(finalTotal);

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1A1A1A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${cart.items.length} Menu Terpilih • ${cart.paymentMethod}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              Text(formattedFinalTotal, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _processCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(CupertinoIcons.printer_fill, size: 16),
            label: const Text('Bayar & Struk', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
