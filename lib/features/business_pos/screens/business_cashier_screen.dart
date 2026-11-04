import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/business_pos_models.dart';
import '../../../providers/pos_cart_provider.dart';
import '../../../providers/workspace_mode_provider.dart';
import '../../../services/business_pos_api_service.dart';
import '../widgets/add_menu_item_modal.dart';
import '../widgets/manage_menu_modal.dart';
import '../widgets/menu_grid_configurator_modal.dart';
import 'customer_aod_menu_screen.dart';

class BusinessCashierScreen extends ConsumerStatefulWidget {
  const BusinessCashierScreen({super.key});

  @override
  ConsumerState<BusinessCashierScreen> createState() => _BusinessCashierScreenState();
}

class _BusinessCashierScreenState extends ConsumerState<BusinessCashierScreen> {
  BusinessStoreConfig _config = BusinessStoreConfig.defaultBarConfig();
  List<BusinessMenuItem> _menuItems = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

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

  void _launchCustomerAod() {
    ref.read(workspaceModeProvider.notifier).forceSetMode(WorkspaceMode.customerAodDisplay);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerAodMenuScreen(config: _config),
      ),
    );
  }

  Future<void> _processCheckout() async {
    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty) return;

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
        ref.read(posCartProvider.notifier).clearCart();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.greenAccent),
                SizedBox(width: 8),
                Text('Pembayaran Berhasil', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            content: Text(
              'Pesanan ${cart.formattedTotal} telah dicatat ke sistem kasir.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup', style: TextStyle(color: Color(0xFFD4AF37))),
              ),
            ],
          ),
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
            tooltip: 'Tambah Menu Display & Kasir',
            onPressed: _openAddMenuModal,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.square_grid_2x2_fill, color: Colors.white70),
            tooltip: 'Kelola Katalog Menu',
            onPressed: _openManageMenuModal,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.slider_horizontal_3, color: Color(0xFFD4AF37)),
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
    final filtered = _selectedCategory == 'All'
        ? _menuItems
        : _menuItems.where((m) => m.category == _selectedCategory).toList();

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
                '${_menuItems.length} Menu Aktif',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Text(
                '• PIN Kiosk: 1234',
                style: TextStyle(color: Colors.white38, fontSize: 11),
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
                label: Text(cat, style: TextStyle(color: isSel ? Colors.black : Colors.white70, fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
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
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisExtent: 195,
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
                  // Quick options on long press
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
                      Expanded(
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.assetUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.local_cafe, color: Color(0xFFD4AF37), size: 36),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.formattedPrice,
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w800, fontSize: 12),
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

  Widget _buildLiveReceiptSection() {
    final cart = ref.watch(posCartProvider);

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
                  Text('Pesanan Aktif', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              if (cart.items.isNotEmpty)
                TextButton(
                  onPressed: () => ref.read(posCartProvider.notifier).clearCart(),
                  child: const Text('Kosongkan', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                ),
            ],
          ),
          const Divider(color: Colors.white12),

          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Text(
                      'Pilih menu di sebelah kiri untuk menambah ke pesanan kasir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 12),
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
          // Total & Checkout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                cart.formattedTotal,
                style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ElevatedButton(
            onPressed: cart.items.isEmpty ? null : _processCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Bayar & Selesaikan Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCartSummary() {
    final cart = ref.watch(posCartProvider);
    if (cart.items.isEmpty) return const SizedBox.shrink();

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
              Text('${cart.items.length} Menu Terpilih', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              Text(cart.formattedTotal, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            onPressed: _processCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
