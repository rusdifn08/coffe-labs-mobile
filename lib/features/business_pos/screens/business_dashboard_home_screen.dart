import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/business_pos_models.dart';
import '../../../services/business_pos_api_service.dart';
import '../../../theme/business_theme.dart';
import '../models/business_stock_models.dart';
import '../services/business_stock_service.dart';
import '../widgets/business_svg_icons.dart';
import 'shift_summary_screen.dart';

class BusinessDashboardHomeScreen extends ConsumerStatefulWidget {
  final void Function(int tabIndex)? onNavigateToTab;
  final VoidCallback? onSwitchToPersonal;

  const BusinessDashboardHomeScreen({
    super.key,
    this.onNavigateToTab,
    this.onSwitchToPersonal,
  });

  @override
  ConsumerState<BusinessDashboardHomeScreen> createState() =>
      _BusinessDashboardHomeScreenState();
}

class _BusinessDashboardHomeScreenState
    extends ConsumerState<BusinessDashboardHomeScreen> {
  BusinessStoreConfig _config = BusinessStoreConfig.defaultBarConfig();
  List<StockItem> _stockItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final conf = await BusinessPosApiService.fetchStoreConfig();
    final stock = await BusinessStockService.loadStockItems();

    if (mounted) {
      setState(() {
        if (conf != null) _config = conf;
        _stockItems = stock;
        _isLoading = false;
      });
    }
  }

  void _openShiftSummaryModal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShiftSummaryScreen(
          totalSales: 1845000,
          totalOrders: 48,
          cashTotal: 720000,
          qrisTotal: 965000,
          cardTotal: 160000,
          discountTotal: 45000,
          onResetShift: () {},
        ),
      ),
    );
  }

  void _showEditStoreDialog() {
    final nameController = TextEditingController(text: _config.storeName);
    final taglineController = TextEditingController(text: _config.storeTagline);
    String selectedLogo = _config.logoIconType;

    final logoOptions = [
      {'type': 'flame_bean', 'label': 'Roast Flame & Bean'},
      {'type': 'royal_portafilter', 'label': 'Royal Portafilter'},
      {'type': 'v60_dripper', 'label': 'V60 Origami Cone'},
      {'type': 'botanical_leaf', 'label': 'Arabica Branch'},
      {'type': 'geometric_cup', 'label': 'Modern Hexagon'},
      {'type': 'steaming_pitcher', 'label': 'Latte Pitcher'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: BusinessTheme.cardElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BusinessTheme.goldAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.pencil_circle_fill, color: BusinessTheme.goldAccent, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubah Identitas Kafe / Resto',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Ubah nama dan pilih logo emblem unik kafe Anda',
                      style: TextStyle(color: BusinessTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Resto / Kafe
                const Text(
                  'NAMA KAFE / RESTO',
                  style: TextStyle(color: BusinessTheme.goldAccent, fontSize: 10.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Kopi Kenangan Bar, Specialty Brew...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    filled: true,
                    fillColor: BusinessTheme.bgSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(CupertinoIcons.building_2_fill, color: BusinessTheme.goldAccent, size: 18),
                  ),
                ),
                const SizedBox(height: 14),

                // Tagline / Deskripsi Meja Bar
                const Text(
                  'DESKRIPSI / SLOGAN KAFE',
                  style: TextStyle(color: BusinessTheme.goldAccent, fontSize: 10.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: taglineController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Specialty Coffee Bar & Artisan Bakery',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                    filled: true,
                    fillColor: BusinessTheme.bgSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(CupertinoIcons.tag_fill, color: BusinessTheme.goldAccent, size: 18),
                  ),
                ),
                const SizedBox(height: 18),

                // Pilihan Logo SVG Buatan Sendiri
                const Text(
                  'PILIH LOGO EMBLEM SPESIAL KAFE',
                  style: TextStyle(color: BusinessTheme.goldAccent, fontSize: 10.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: logoOptions.map((opt) {
                    final type = opt['type']!;
                    final isSelected = selectedLogo == type;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedLogo = type),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? BusinessTheme.goldAccent.withValues(alpha: 0.18) : BusinessTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? BusinessTheme.goldAccent : BusinessTheme.borderSubtle,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BusinessSvgIcon.cafeEmblem(logoType: type, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              opt['label']!,
                              style: TextStyle(
                                color: isSelected ? BusinessTheme.goldAccent : BusinessTheme.textLight,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newTagline = taglineController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(ctx);
                  final updated = await BusinessPosApiService.updateStoreConfig({
                    'store_name': newName,
                    'store_tagline': newTagline.isNotEmpty ? newTagline : _config.storeTagline,
                    'logo_icon_type': selectedLogo,
                  });
                  if (mounted && updated != null) {
                    setState(() => _config = updated);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BusinessTheme.goldAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isWide = mediaQuery.size.width >= 900;

    final lowStockCount = BusinessStockService.getLowStockAlertCount(_stockItems);
    final brewCapacity = BusinessStockService.calculateTotalBrewCapacity(_stockItems);

    return Scaffold(
      backgroundColor: BusinessTheme.bgDark,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: BusinessTheme.goldAccent),
            )
          : SafeArea(
              child: RefreshIndicator(
                color: BusinessTheme.goldAccent,
                backgroundColor: BusinessTheme.cardBg,
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Header: Store Info with customizable Logo/Name & Switcher Pill
                      _buildHeader(),
                      const SizedBox(height: 10),

                      // 2. Alert Low Stock Banner (Compact inline)
                      if (lowStockCount > 0) ...[
                        _buildLowStockWarning(lowStockCount),
                        const SizedBox(height: 10),
                      ],

                      // 3. Omset, Transaksi, Cup Penjualan & Rata-rata DI DALAM 1 BARIS (Responsive)
                      _buildUnifiedKpiRow(isWide),
                      const SizedBox(height: 12),

                      // 4. Aksi Cepat Operasional (1 Baris di Landscape, 2x2 di Portrait)
                      _buildQuickActions(isWide),
                      const SizedBox(height: 12),

                      // 5. Executive 2-Column Command Center (Estimasi, Peak Hours | Top Selling, Status)
                      if (isWide)
                        _buildLandscapeExecutiveColumns(brewCapacity)
                      else
                        _buildPortraitSequentialContent(brewCapacity),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Customizable Cafe Logo Emblem (Tap to change)
        InkWell(
          onTap: _showEditStoreDialog,
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              BusinessSvgIcon.cafeEmblem(
                logoType: _config.logoIconType,
                size: 42,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: BusinessTheme.goldAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.pencil, size: 9, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Outlet Name (Tap to edit) & Tagline
        Expanded(
          child: InkWell(
            onTap: _showEditStoreDialog,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _config.storeName,
                        style: const TextStyle(
                          color: BusinessTheme.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: BusinessTheme.goldAccent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: BusinessTheme.goldAccent.withValues(alpha: 0.5), width: 0.8),
                      ),
                      child: const Text(
                        'BUSINESS',
                        style: TextStyle(
                          color: BusinessTheme.goldAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(CupertinoIcons.pencil, color: BusinessTheme.textMutedDark, size: 12),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _config.storeTagline,
                  style: const TextStyle(
                    color: BusinessTheme.textMuted,
                    fontSize: 11.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),

        // Mode Personal Pill Button
        InkWell(
          onTap: widget.onSwitchToPersonal,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: BusinessTheme.cardElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: BusinessTheme.goldAccent.withValues(alpha: 0.45),
                width: 1.0,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.person_crop_circle, color: BusinessTheme.goldAccent, size: 14),
                SizedBox(width: 5),
                Text(
                  'Mode Personal',
                  style: TextStyle(
                    color: BusinessTheme.goldAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockWarning(int count) {
    return InkWell(
      onTap: () => widget.onNavigateToTab?.call(3),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: BusinessTheme.statusWarning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: BusinessTheme.statusWarning.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: BusinessTheme.statusWarning,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$count Bahan Baku Menipis — Tap untuk cek Stock Opname',
                style: const TextStyle(
                  color: BusinessTheme.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: BusinessTheme.statusWarning,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }

  /// 4 KPI Metrics: Omset, Transaksi, Cup, Rata-rata DI DALAM 1 BARIS (Responsive)
  Widget _buildUnifiedKpiRow(bool isWide) {
    if (isWide) {
      return Row(
        children: [
          // 1. Omset Card
          Expanded(
            flex: 3,
            child: _buildOmsetKpiCard(),
          ),
          const SizedBox(width: 10),

          // 2. Transaksi Card
          Expanded(
            flex: 2,
            child: _buildMetricTile(
              title: 'Transaksi',
              value: '48 Order',
              sub: '100% lunas',
              iconWidget: BusinessSvgIcon.transactions(size: 26),
            ),
          ),
          const SizedBox(width: 10),

          // 3. Cup Penjualan Card
          Expanded(
            flex: 2,
            child: _buildMetricTile(
              title: 'Cup Kopi',
              value: '62 Cup',
              sub: 'Terjual hari ini',
              iconWidget: BusinessSvgIcon.cupsSold(size: 26),
            ),
          ),
          const SizedBox(width: 10),

          // 4. Rata-rata Order Card
          Expanded(
            flex: 2,
            child: _buildMetricTile(
              title: 'Rata-rata',
              value: 'Rp 38.4k',
              sub: 'Per pelanggan',
              iconWidget: BusinessSvgIcon.averageOrder(size: 26),
            ),
          ),
        ],
      );
    }

    // Portrait Mode: 2 baris (Omset atas, 3 Metrik bawah)
    return Column(
      children: [
        _buildOmsetKpiCard(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Transaksi',
                value: '48 Order',
                sub: '100% lunas',
                iconWidget: BusinessSvgIcon.transactions(size: 24),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                title: 'Cup Kopi',
                value: '62 Cup',
                sub: 'Terjual hari ini',
                iconWidget: BusinessSvgIcon.cupsSold(size: 24),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                title: 'Rata-rata',
                value: 'Rp 38.4k',
                sub: 'Per order',
                iconWidget: BusinessSvgIcon.averageOrder(size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOmsetKpiCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BusinessTheme.cardDecoration(hasGoldGlow: true),
      child: Row(
        children: [
          BusinessSvgIcon.omset(size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'OMSET HARI INI',
                        style: TextStyle(
                          color: BusinessTheme.goldAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: BusinessTheme.statusSuccess.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '+18.4%',
                        style: TextStyle(
                          color: BusinessTheme.statusSuccess,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Rp 1.845.000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const Text(
                  '48 transaksi kasir lunas',
                  style: TextStyle(color: BusinessTheme.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String sub,
    required Widget iconWidget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BusinessTheme.cardDecoration(),
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: BusinessTheme.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    color: BusinessTheme.textLight,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: const TextStyle(color: BusinessTheme.textMutedDark, fontSize: 9.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4 Aksi Cepat: 1 Baris di Landscape, 2x2 di Portrait
  Widget _buildQuickActions(bool isWide) {
    final actions = [
      {
        'title': 'POS Kasir',
        'sub': 'Catat & cetak pesanan',
        'icon': BusinessSvgIcon.posCashier(size: 28),
        'tab': 1,
      },
      {
        'title': 'Display Kiosk',
        'sub': 'AMOLED AOD showcase',
        'icon': BusinessSvgIcon.displayKiosk(size: 28),
        'tab': 2,
      },
      {
        'title': 'Stock Opname',
        'sub': 'Inventaris bahan baku',
        'icon': BusinessSvgIcon.stockOpname(size: 28),
        'tab': 3,
      },
      {
        'title': 'Rekap Shift',
        'sub': 'Laporan shift kasir',
        'icon': BusinessSvgIcon.shiftReport(size: 28),
        'action': _openShiftSummaryModal,
      },
    ];

    if (isWide) {
      // 1 BARIS PENUH DI MODE LANSKAP!
      return Row(
        children: actions.map((act) {
          final isLast = actions.indexOf(act) == actions.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 10.0),
              child: _buildActionCardItem(act),
            ),
          );
        }).toList(),
      );
    }

    // Portrait 2x2 Grid
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildActionCardItem(actions[0])),
            const SizedBox(width: 10),
            Expanded(child: _buildActionCardItem(actions[1])),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildActionCardItem(actions[2])),
            const SizedBox(width: 10),
            Expanded(child: _buildActionCardItem(actions[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCardItem(Map<String, dynamic> act) {
    return InkWell(
      onTap: () {
        if (act.containsKey('tab')) {
          widget.onNavigateToTab?.call(act['tab'] as int);
        } else if (act.containsKey('action')) {
          (act['action'] as VoidCallback).call();
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BusinessTheme.cardDecoration(),
        child: Row(
          children: [
            act['icon'] as Widget,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    act['title'] as String,
                    style: const TextStyle(
                      color: BusinessTheme.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    act['sub'] as String,
                    style: const TextStyle(
                      color: BusinessTheme.textMuted,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mode Lanskap: 2 Kolom Ringkasan dalam 1 Layar
  Widget _buildLandscapeExecutiveColumns(int brewCapacity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Estimasi Kapasitas & Peak Hours
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildCapacityBanner(brewCapacity),
              const SizedBox(height: 10),
              _buildPeakHoursSection(height: 75),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Right Column: Top Menu Terlaris & Hardware Status
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildTopSellingSection(limit: 3),
              const SizedBox(height: 10),
              _buildOperationalStatusCard(),
            ],
          ),
        ),
      ],
    );
  }

  /// Mode Potret: Konten Sekuensial Vertikal
  Widget _buildPortraitSequentialContent(int brewCapacity) {
    return Column(
      children: [
        _buildCapacityBanner(brewCapacity),
        const SizedBox(height: 12),
        _buildPeakHoursSection(height: 60),
        const SizedBox(height: 12),
        _buildTopSellingSection(limit: 4),
        const SizedBox(height: 12),
        _buildOperationalStatusCard(),
      ],
    );
  }

  Widget _buildCapacityBanner(int capacity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: BusinessTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BusinessTheme.borderSubtle, width: 1.0),
      ),
      child: Row(
        children: [
          BusinessSvgIcon.brewCapacity(size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Estimasi Kapasitas Seduh Hari Ini',
                  style: TextStyle(
                    color: BusinessTheme.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Stok aman untuk ~$capacity cangkir specialty sebelum restock.',
                  style: const TextStyle(
                    color: BusinessTheme.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakHoursSection({double height = 65}) {
    final hours = [
      {'time': '07:00', 'ratio': 0.25, 'label': ''},
      {'time': '08:00', 'ratio': 0.90, 'label': 'PEAK'},
      {'time': '10:00', 'ratio': 0.45, 'label': ''},
      {'time': '12:00', 'ratio': 0.70, 'label': 'LUNCH'},
      {'time': '14:00', 'ratio': 0.50, 'label': ''},
      {'time': '17:00', 'ratio': 0.65, 'label': ''},
      {'time': '19:00', 'ratio': 0.95, 'label': 'PEAK'},
      {'time': '21:00', 'ratio': 0.35, 'label': ''},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BusinessTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'ANALISIS JAM SIBUK (PEAK HOURS)',
                  style: TextStyle(
                    color: BusinessTheme.goldAccent,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Pagi & Malam',
                  style: TextStyle(color: BusinessTheme.textMuted, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: hours.map((h) {
              final ratio = h['ratio'] as double;
              final isPeak = ratio >= 0.85;
              final barHeight = ratio * height;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPeak)
                    Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: BusinessTheme.goldAccent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'PEAK',
                        style: TextStyle(color: Colors.black, fontSize: 7, fontWeight: FontWeight.w900),
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                  Container(
                    width: 18,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: isPeak
                          ? BusinessTheme.goldAccent
                          : BusinessTheme.goldAccent.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    h['time'] as String,
                    style: TextStyle(
                      color: isPeak ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
                      fontSize: 8.5,
                      fontWeight: isPeak ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingSection({int limit = 3}) {
    final topItems = [
      {'name': 'Geisha Panama Pour Over', 'sold': '18 cup', 'rev': 'Rp 630k'},
      {'name': 'Iced Oat Flat White (Oatside)', 'sold': '15 cup', 'rev': 'Rp 720k'},
      {'name': 'Single Origin Filter V60 Ethiopia', 'sold': '11 cup', 'rev': 'Rp 462k'},
      {'name': 'Cappuccino Double Ristretto', 'sold': '9 cup', 'rev': 'Rp 225k'},
    ].take(limit).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BusinessTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'TOP MENU TERLARIS HARI INI',
                  style: TextStyle(
                    color: BusinessTheme.goldAccent,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text('Terjual', style: TextStyle(color: BusinessTheme.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          ...topItems.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: idx <= 2
                          ? BusinessTheme.goldAccent.withValues(alpha: 0.22)
                          : BusinessTheme.borderSubtle,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$idx',
                      style: TextStyle(
                        color: idx <= 2 ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['name']!,
                      style: const TextStyle(
                        color: BusinessTheme.textLight,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    item['sold']!,
                    style: const TextStyle(
                      color: BusinessTheme.goldAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOperationalStatusCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BusinessTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STATUS OPERASIONAL BAR',
            style: TextStyle(
              color: BusinessTheme.goldAccent,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            label: 'Barista Bertugas',
            status: 'Labs Business Demo',
            icon: CupertinoIcons.person_crop_circle_badge_checkmark,
            isOnline: true,
          ),
          const Divider(height: 12, color: BusinessTheme.borderSubtle),
          _buildStatusRow(
            label: 'Printer Thermal',
            status: 'Bluetooth 58mm Siap',
            icon: CupertinoIcons.printer,
            isOnline: true,
          ),
          const Divider(height: 12, color: BusinessTheme.borderSubtle),
          _buildStatusRow(
            label: 'Mesin Espresso',
            status: '9.2 Bar • 93.5°C Stabil',
            icon: CupertinoIcons.gauge,
            isOnline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required String label,
    required String status,
    required IconData icon,
    required bool isOnline,
  }) {
    return Row(
      children: [
        Icon(icon, color: BusinessTheme.textMuted, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: BusinessTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isOnline ? BusinessTheme.statusSuccess : BusinessTheme.statusDanger,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          status,
          style: const TextStyle(
            color: BusinessTheme.textLight,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
