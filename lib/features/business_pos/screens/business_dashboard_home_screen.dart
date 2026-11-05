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
    final isLandscapeOrWide =
        mediaQuery.size.width >= 800 || mediaQuery.orientation == Orientation.landscape;

    final lowStockCount = BusinessStockService.getLowStockAlertCount(_stockItems);
    final brewCapacity = BusinessStockService.calculateTotalBrewCapacity(_stockItems);

    return Scaffold(
      backgroundColor: BusinessTheme.bgDark,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: BusinessTheme.goldAccent),
            )
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final canFitSinglePage = isLandscapeOrWide && availableHeight >= 500;

                  if (canFitSinglePage) {
                    // Responsive Full-Height Dashboard for Tablet / Landscape (All Cards Responsive with Min-Height)
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Top Header: Store Info with customizable Logo/Name & Switcher Pill
                          _buildHeader(),
                          const SizedBox(height: 6),

                          // 2. Alert Low Stock Banner (Compact inline)
                          if (lowStockCount > 0) ...[
                            _buildLowStockWarning(lowStockCount),
                            const SizedBox(height: 6),
                          ],

                          // 3. Omset, Transaksi, Cup Penjualan & Rata-rata DI DALAM 1 BARIS (Responsive)
                          Expanded(
                            flex: 12,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 80),
                              child: _buildUnifiedKpiRow(true, isExpanded: true),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 4. Aksi Cepat Operasional (1 Baris di Landscape, Responsive)
                          Expanded(
                            flex: 9,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 58),
                              child: _buildQuickActions(true, isExpanded: true),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 5. Executive 2-Column Command Center (Responsive full height)
                          Expanded(
                            flex: 29,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 200),
                              child: _buildLandscapeExecutiveColumns(brewCapacity, isExpanded: true),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Scrollable Fallback for Portrait / very compact heights
                  return RefreshIndicator(
                    color: BusinessTheme.goldAccent,
                    backgroundColor: BusinessTheme.cardBg,
                    onRefresh: _loadDashboardData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 10),
                          if (lowStockCount > 0) ...[
                            _buildLowStockWarning(lowStockCount),
                            const SizedBox(height: 10),
                          ],
                          _buildUnifiedKpiRow(isLandscapeOrWide),
                          const SizedBox(height: 12),
                          _buildQuickActions(isLandscapeOrWide),
                          const SizedBox(height: 12),
                          if (isLandscapeOrWide)
                            _buildLandscapeExecutiveColumns(brewCapacity, isExpanded: false)
                          else
                            _buildPortraitSequentialContent(brewCapacity),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
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
  Widget _buildUnifiedKpiRow(bool isWide, {bool isExpanded = false}) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Omset Card
          Expanded(
            flex: 3,
            child: _buildOmsetKpiCard(isExpanded: isExpanded),
          ),
          const SizedBox(width: 8),

          // 2. Transaksi Card
          Expanded(
            flex: 2,
            child: _buildMetricTile(
              title: 'Transaksi',
              value: '48 Order',
              sub: '100% lunas',
              iconBuilder: (size) => BusinessSvgIcon.transactions(size: size),
              isExpanded: isExpanded,
            ),
          ),
          const SizedBox(width: 8),

          // 3. Cup Penjualan Card
          Expanded(
            flex: 2,
            child: _buildMetricTile(
              title: 'Cup Kopi',
              value: '62 Cup',
              sub: 'Terjual hari ini',
              iconBuilder: (size) => BusinessSvgIcon.cupsSold(size: size),
              isExpanded: isExpanded,
            ),
          ),
          const SizedBox(width: 8),

          // 4. Rata-rata Order Card
          Expanded(
            flex: 2,
            child: _buildMetricTile(
              title: 'Rata-rata',
              value: 'Rp 38.4k',
              sub: 'Per pelanggan',
              iconBuilder: (size) => BusinessSvgIcon.averageOrder(size: size),
              isExpanded: isExpanded,
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
                iconBuilder: (size) => BusinessSvgIcon.transactions(size: size),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                title: 'Cup Kopi',
                value: '62 Cup',
                sub: 'Terjual hari ini',
                iconBuilder: (size) => BusinessSvgIcon.cupsSold(size: size),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                title: 'Rata-rata',
                value: 'Rp 38.4k',
                sub: 'Per order',
                iconBuilder: (size) => BusinessSvgIcon.averageOrder(size: size),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOmsetKpiCard({bool isExpanded = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BusinessTheme.cardDecoration(hasGoldGlow: true),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isTaller = constraints.maxHeight >= 95;
          final double iconSize = isTaller ? 38.0 : 30.0;
          final double valueFontSize = isTaller ? 20.0 : 17.0;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BusinessSvgIcon.omset(size: iconSize),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    Text(
                      'Rp 1.845.000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '48 transaksi kasir lunas',
                            style: TextStyle(color: BusinessTheme.textMuted, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isTaller) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: BusinessTheme.goldAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Target 92%',
                              style: TextStyle(color: BusinessTheme.goldAccent, fontSize: 8.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String sub,
    Widget? iconWidget,
    Widget Function(double size)? iconBuilder,
    bool isExpanded = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BusinessTheme.cardDecoration(),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isTaller = constraints.maxHeight >= 95;
          final double iconSize = isTaller ? 28.0 : 22.0;
          final double valueFontSize = isTaller ? 16.0 : 13.5;
          final icon = iconBuilder != null ? iconBuilder(iconSize) : (iconWidget ?? const SizedBox());

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: BusinessTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: TextStyle(
                        color: BusinessTheme.textLight,
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sub,
                      style: TextStyle(
                        color: isTaller ? BusinessTheme.goldAccent : BusinessTheme.textSecondary,
                        fontSize: 9.5,
                        fontWeight: isTaller ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 4 Aksi Cepat: 1 Baris di Landscape, 2x2 di Portrait
  Widget _buildQuickActions(bool isWide, {bool isExpanded = false}) {
    final actions = [
      {
        'title': 'POS Kasir',
        'sub': 'Catat & cetak pesanan',
        'iconBuilder': (double size) => BusinessSvgIcon.posCashier(size: size),
        'tab': 1,
      },
      {
        'title': 'Display Kiosk',
        'sub': 'AMOLED AOD showcase',
        'iconBuilder': (double size) => BusinessSvgIcon.displayKiosk(size: size),
        'tab': 2,
      },
      {
        'title': 'Stock Opname',
        'sub': 'Inventaris bahan baku',
        'iconBuilder': (double size) => BusinessSvgIcon.stockOpname(size: size),
        'tab': 3,
      },
      {
        'title': 'Rekap Shift',
        'sub': 'Laporan shift kasir',
        'iconBuilder': (double size) => BusinessSvgIcon.shiftReport(size: size),
        'action': _openShiftSummaryModal,
      },
    ];

    if (isWide) {
      // 1 BARIS PENUH DI MODE LANSKAP!
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actions.map((act) {
          final isLast = actions.indexOf(act) == actions.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 8.0),
              child: _buildActionCardItem(act, isExpanded: isExpanded),
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
            const SizedBox(width: 8),
            Expanded(child: _buildActionCardItem(actions[1])),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildActionCardItem(actions[2])),
            const SizedBox(width: 8),
            Expanded(child: _buildActionCardItem(actions[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCardItem(Map<String, dynamic> act, {bool isExpanded = false}) {
    final iconBuilder = act['iconBuilder'] as Widget Function(double size);

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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BusinessTheme.cardDecoration(),
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final isTaller = constraints.maxHeight >= 70;
            final iconSize = isTaller ? 24.0 : 20.0;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isTaller ? 7 : 5),
                  decoration: BoxDecoration(
                    color: BusinessTheme.bgSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: BusinessTheme.borderSubtle, width: 0.8),
                  ),
                  child: iconBuilder(iconSize),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        act['title'] as String,
                        style: TextStyle(
                          color: BusinessTheme.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: isTaller ? 12.5 : 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        act['sub'] as String,
                        style: TextStyle(
                          color: BusinessTheme.textMuted,
                          fontSize: isTaller ? 10 : 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isTaller)
                  const Icon(
                    CupertinoIcons.chevron_forward,
                    color: BusinessTheme.textMuted,
                    size: 13,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Mode Lanskap: 2 Kolom Ringkasan dalam 1 Layar (Responsive Height)
  Widget _buildLandscapeExecutiveColumns(int brewCapacity, {bool isExpanded = false}) {
    if (isExpanded) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Column: Estimasi Kapasitas & Peak Hours (Full Height)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: _buildCapacityBanner(brewCapacity, isExpanded: true),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 7,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 140),
                    child: _buildPeakHoursSection(isExpanded: true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Right Column: Top Menu Terlaris & Hardware Status (Full Height)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 95),
                    child: _buildTopSellingSection(isExpanded: true),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 5,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 95),
                    child: _buildOperationalStatusCard(isExpanded: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  Widget _buildCapacityBanner(int capacity, {bool isExpanded = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: BusinessTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BusinessTheme.borderSubtle, width: 1.0),
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isTaller = constraints.maxHeight >= 60;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BusinessSvgIcon.brewCapacity(size: isTaller ? 26 : 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Estimasi Kapasitas Seduh Hari Ini',
                            style: TextStyle(
                              color: BusinessTheme.textLight,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: BusinessTheme.goldAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '~$capacity Cup',
                            style: const TextStyle(
                              color: BusinessTheme.goldAccent,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stok aman untuk ~$capacity cangkir specialty sebelum restock.',
                      style: const TextStyle(
                        color: BusinessTheme.textSecondary,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isTaller) ...[
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (capacity / 300.0).clamp(0.1, 1.0),
                          minHeight: 3.5,
                          backgroundColor: BusinessTheme.borderSubtle,
                          color: BusinessTheme.goldAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeakHoursSection({bool isExpanded = false, double height = 120}) {
    final hours = [
      {'time': '07:00', 'ratio': 0.28, 'cup': '12', 'label': ''},
      {'time': '08:00', 'ratio': 0.90, 'cup': '42', 'label': 'PEAK'},
      {'time': '10:00', 'ratio': 0.45, 'cup': '21', 'label': ''},
      {'time': '12:00', 'ratio': 0.70, 'cup': '33', 'label': 'LUNCH'},
      {'time': '14:00', 'ratio': 0.50, 'cup': '24', 'label': ''},
      {'time': '17:00', 'ratio': 0.65, 'cup': '31', 'label': ''},
      {'time': '19:00', 'ratio': 0.95, 'cup': '45', 'label': 'PEAK'},
      {'time': '21:00', 'ratio': 0.35, 'cup': '16', 'label': ''},
    ];

    Widget buildChartContent(double totalHeight, double totalWidth) {
      final barWidth = (totalWidth / hours.length * 0.42).clamp(16.0, 32.0);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Bars & Badges Row (Expanded with background guidelines)
          Expanded(
            child: Stack(
              children: [
                // Horizontal reference grid lines
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        color: BusinessTheme.borderSubtle.withValues(alpha: 0.35),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        color: BusinessTheme.borderSubtle.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),

                // Bars Row: each hour is an Expanded column that distributes width evenly across the card
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: hours.map((h) {
                    final ratio = h['ratio'] as double;
                    final isPeak = ratio >= 0.85;
                    final isLunch = h['label'] == 'LUNCH';

                    return Expanded(
                      child: LayoutBuilder(
                        builder: (ctx, barColConstraints) {
                          final maxColH = barColConstraints.maxHeight;
                          final maxBarH = (maxColH - 24.0).clamp(10.0, 240.0);
                          final barHeight = (ratio * maxBarH).clamp(8.0, maxBarH);

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Badge / Cup count above bar
                              if (isPeak)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 3),
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: BusinessTheme.goldAccent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PEAK',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                )
                              else if (isLunch)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 3),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: BusinessTheme.bgSurface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: BusinessTheme.borderSubtle, width: 0.8),
                                  ),
                                  child: const Text(
                                    'LUNCH',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    '${h['cup']}',
                                    style: TextStyle(
                                      color: BusinessTheme.textMuted.withValues(alpha: 0.9),
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                              // The Bar itself with gradient and rounded cap
                              Container(
                                width: barWidth,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: isPeak
                                      ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            BusinessTheme.goldAccent,
                                            Color(0xFFC98C22),
                                          ],
                                        )
                                      : null,
                                  color: isPeak
                                      ? null
                                      : isLunch
                                          ? BusinessTheme.goldAccent.withValues(alpha: 0.60)
                                          : BusinessTheme.goldAccent.withValues(alpha: 0.28),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                                  boxShadow: isPeak
                                      ? [
                                          BoxShadow(
                                            color: BusinessTheme.goldAccent.withValues(alpha: 0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, -1),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // 2. Baseline Divider
          Container(
            height: 1,
            color: BusinessTheme.borderSubtle.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 5),

          // 3. Time Labels Row (each in an Expanded cell with textAlign: TextAlign.center)
          Row(
            children: hours.map((h) {
              final ratio = h['ratio'] as double;
              final isPeak = ratio >= 0.85;

              return Expanded(
                child: Text(
                  h['time'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isPeak ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
                    fontSize: 10,
                    fontWeight: isPeak ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BusinessTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: BusinessTheme.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: BusinessTheme.borderSubtle, width: 0.8),
                ),
                child: const Text(
                  'Pagi & Malam',
                  style: TextStyle(color: BusinessTheme.goldAccent, fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (isExpanded)
            Expanded(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  return buildChartContent(constraints.maxHeight, constraints.maxWidth);
                },
              ),
            )
          else
            SizedBox(
              height: height,
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  return buildChartContent(height, constraints.maxWidth);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopSellingSection({bool isExpanded = false, int? limit}) {
    final allTopItems = [
      {
        'name': 'Geisha Panama Pour Over',
        'sub': 'Filter • Gesha Specialty',
        'sold': '18 cup',
        'rev': 'Rp 630k',
        'pct': 0.29,
      },
      {
        'name': 'Iced Oat Flat White (Oatside)',
        'sub': 'Espresso • Oatside',
        'sold': '15 cup',
        'rev': 'Rp 720k',
        'pct': 0.24,
      },
      {
        'name': 'Single Origin Filter V60 Ethiopia',
        'sub': 'Manual Brew • Floral Jasmine',
        'sold': '11 cup',
        'rev': 'Rp 462k',
        'pct': 0.18,
      },
      {
        'name': 'Cappuccino Double Ristretto',
        'sub': 'Espresso • Fresh Milk',
        'sold': '9 cup',
        'rev': 'Rp 225k',
        'pct': 0.15,
      },
      {
        'name': 'Cold Drip Reserve 12-Hour',
        'sub': 'Slow Cold Drip',
        'sold': '7 cup',
        'rev': 'Rp 315k',
        'pct': 0.11,
      },
    ];

    Widget buildItemRow(int idx, Map<String, dynamic> item, bool showSubtitle, bool showProgress) {
      final isTop = idx <= 2;
      final pct = item['pct'] as double;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isTop
                        ? BusinessTheme.goldAccent.withValues(alpha: 0.22)
                        : BusinessTheme.borderSubtle,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$idx',
                    style: TextStyle(
                      color: isTop ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['name'] as String,
                        style: const TextStyle(
                          color: BusinessTheme.textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (showSubtitle)
                        Text(
                          item['sub'] as String,
                          style: const TextStyle(
                            color: BusinessTheme.textMuted,
                            fontSize: 9,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['sold'] as String,
                      style: const TextStyle(
                        color: BusinessTheme.goldAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (showSubtitle)
                      Text(
                        item['rev'] as String,
                        style: const TextStyle(
                          color: BusinessTheme.textMuted,
                          fontSize: 9,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (showProgress) ...[
              const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 2.0,
                  backgroundColor: BusinessTheme.borderSubtle.withValues(alpha: 0.4),
                  color: isTop ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BusinessTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 6),
          if (isExpanded)
            Expanded(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final int count;
                  final bool showSubtitle;
                  final bool showProgress;

                  if (limit != null) {
                    count = limit;
                    showSubtitle = false;
                    showProgress = false;
                  } else if (constraints.maxHeight >= 180) {
                    count = 5;
                    showSubtitle = true;
                    showProgress = true;
                  } else if (constraints.maxHeight >= 135) {
                    count = 4;
                    showSubtitle = true;
                    showProgress = false;
                  } else {
                    count = 3;
                    showSubtitle = false;
                    showProgress = false;
                  }

                  final itemsToShow = allTopItems.take(count).toList();

                  return Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                          maxWidth: constraints.maxWidth,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: itemsToShow
                              .asMap()
                              .entries
                              .map((e) => buildItemRow(e.key + 1, e.value, showSubtitle, showProgress))
                              .toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Column(
              children: allTopItems
                  .take(limit ?? 3)
                  .toList()
                  .asMap()
                  .entries
                  .map((e) => buildItemRow(e.key + 1, e.value, false, false))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildOperationalStatusCard({bool isExpanded = false}) {
    final allStatusList = [
      {
        'label': 'Barista Bertugas',
        'status': 'Labs Business Demo',
        'sub': 'Shift Aktif • Kasir Siap',
        'icon': CupertinoIcons.person_crop_circle_badge_checkmark,
        'isOnline': true,
      },
      {
        'label': 'Printer Thermal',
        'status': 'Bluetooth 58mm Siap',
        'sub': 'Paper Roll 85% • Siap Cetak',
        'icon': CupertinoIcons.printer,
        'isOnline': true,
      },
      {
        'label': 'Mesin Espresso',
        'status': '9.2 Bar • 93.5°C Stabil',
        'sub': 'Boiler Ready • PID Calibrated',
        'icon': CupertinoIcons.gauge,
        'isOnline': true,
      },
      {
        'label': 'Kiosk Display AOD',
        'status': 'Mode Menu Interaktif',
        'sub': 'Sync PIN 1234 • 60 FPS',
        'icon': CupertinoIcons.tv,
        'isOnline': true,
      },
      {
        'label': 'Cloud Sync & POS DB',
        'status': '0 Pending Transaksi',
        'sub': 'SQLite WAL Offline-First',
        'icon': CupertinoIcons.cloud_upload,
        'isOnline': true,
      },
    ];

    Widget buildStatusItem(Map<String, dynamic> item, bool showSubtitle) {
      final isOnline = item['isOnline'] as bool;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Icon(
              item['icon'] as IconData,
              color: BusinessTheme.goldAccent,
              size: 14,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['label'] as String,
                    style: const TextStyle(
                      color: BusinessTheme.textLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showSubtitle)
                    Text(
                      item['sub'] as String,
                      style: const TextStyle(
                        color: BusinessTheme.textMuted,
                        fontSize: 9,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isOnline ? BusinessTheme.statusSuccess : BusinessTheme.statusWarning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item['status'] as String,
                  style: TextStyle(
                    color: isOnline ? Colors.white : BusinessTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BusinessTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 6),
          if (isExpanded)
            Expanded(
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final int count;
                  final bool showSubtitle;

                  if (constraints.maxHeight >= 180) {
                    count = 5;
                    showSubtitle = true;
                  } else if (constraints.maxHeight >= 135) {
                    count = 4;
                    showSubtitle = true;
                  } else {
                    count = 3;
                    showSubtitle = false;
                  }

                  final itemsToShow = allStatusList.take(count).toList();

                  return Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                          maxWidth: constraints.maxWidth,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: itemsToShow
                              .map((item) => buildStatusItem(item, showSubtitle))
                              .toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Column(
              children: allStatusList
                  .take(3)
                  .map((item) => buildStatusItem(item, false))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
