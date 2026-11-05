import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/business_pos_models.dart';
import '../../../services/business_pos_api_service.dart';
import '../../../theme/business_theme.dart';
import '../models/business_stock_models.dart';
import '../services/business_stock_service.dart';
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

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header: Store Info & Mode Personal Switcher Pill
                _buildHeader(),
                const SizedBox(height: 16),

                // 2. Alert Low Stock (jika ada bahan menipis)
                if (lowStockCount > 0) ...[
                  _buildLowStockWarning(lowStockCount),
                  const SizedBox(height: 14),
                ],

                // 3. Omset & KPI Cards
                _buildMetricsGrid(),
                const SizedBox(height: 18),

                // 4. Quick Action Grid (Kasir, Display, Stock, Shift)
                _buildQuickActionsGrid(),
                const SizedBox(height: 20),

                // 5. Estimasi Kapasitas Seduh Hari Ini
                _buildCapacityBanner(brewCapacity),
                const SizedBox(height: 20),

                // 6. Grafik Jam Sibuk Kafe (Peak Hours)
                _buildPeakHoursSection(),
                const SizedBox(height: 20),

                // 7. Top 5 Menu Terlaris Hari Ini
                _buildTopSellingSection(),
                const SizedBox(height: 20),

                // 8. Hardware & Barista Live Status
                _buildOperationalStatusCard(),
                const SizedBox(height: 32),
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
        // Emblem Logo
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFF8A6C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: BusinessTheme.goldAccent.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              CupertinoIcons.flame_fill,
              color: Colors.black,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Outlet Name & Badge
        Expanded(
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
                      color: BusinessTheme.goldAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: BusinessTheme.goldAccent, width: 0.8),
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
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Dashboard Performa & Operasional Kedai',
                style: TextStyle(
                  color: BusinessTheme.textMuted,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),

        // Quick Switcher Pill: [ 👤 Mode Personal ]
        InkWell(
          onTap: widget.onSwitchToPersonal,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: BusinessTheme.cardElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: BusinessTheme.goldAccent.withValues(alpha: 0.4),
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
      onTap: () => widget.onNavigateToTab?.call(3), // Jump ke Stock Opname
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: BusinessTheme.statusWarning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: BusinessTheme.statusWarning.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: BusinessTheme.statusWarning,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$count Bahan Baku Menipis — Tap untuk cek Stock Opname',
                style: const TextStyle(
                  color: BusinessTheme.textLight,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: BusinessTheme.statusWarning,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        // Omset Utama (Full width)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BusinessTheme.cardDecoration(
            hasGoldGlow: true,
            borderColor: BusinessTheme.goldAccent.withValues(alpha: 0.35),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'OMSET HARI INI',
                    style: TextStyle(
                      color: BusinessTheme.goldAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: BusinessTheme.statusSuccess.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.arrow_up_right, color: BusinessTheme.statusSuccess, size: 12),
                        SizedBox(width: 3),
                        Text(
                          '+18.4% vs kemarin',
                          style: TextStyle(
                            color: BusinessTheme.statusSuccess,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Rp 1.845.000',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Akumulasi 48 transaksi kasir • 100% lunas terselesaikan',
                style: TextStyle(color: BusinessTheme.textMuted, fontSize: 11.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3 Metrik Cepat
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Transaksi',
                value: '48 Order',
                sub: 'Selesai kasir',
                icon: CupertinoIcons.check_mark_circled,
                color: const Color(0xFF60A5FA),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Cup Kopi',
                value: '62 Cup',
                sub: 'Terjual hari ini',
                icon: CupertinoIcons.sparkles,
                color: BusinessTheme.goldAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Rata-rata',
                value: 'Rp 38.4k',
                sub: 'Per pelanggan',
                icon: CupertinoIcons.chart_pie,
                color: const Color(0xFF34D399),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BusinessTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: BusinessTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: BusinessTheme.textLight,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(color: BusinessTheme.textMutedDark, fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AKSI CEPAT OPERASIONAL',
          style: TextStyle(
            color: BusinessTheme.goldAccent,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                title: 'POS Kasir',
                subtitle: 'Catat & cetak pesanan',
                icon: CupertinoIcons.cart_badge_plus,
                badge: 'TAB 2',
                color: BusinessTheme.goldAccent,
                onTap: () => widget.onNavigateToTab?.call(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                title: 'Display Kiosk',
                subtitle: 'AMOLED AOD menu',
                icon: CupertinoIcons.device_laptop,
                badge: 'TAB 3',
                color: const Color(0xFF60A5FA),
                onTap: () => widget.onNavigateToTab?.call(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                title: 'Stock Opname',
                subtitle: 'Bahan baku & biji',
                icon: CupertinoIcons.archivebox_fill,
                badge: 'TAB 4',
                color: const Color(0xFF34D399),
                onTap: () => widget.onNavigateToTab?.call(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                title: 'Rekap Shift',
                subtitle: 'Laporan kasir hari ini',
                icon: CupertinoIcons.doc_text_fill,
                badge: 'SHIFT',
                color: const Color(0xFFF472B6),
                onTap: _openShiftSummaryModal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BusinessTheme.cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: BusinessTheme.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: BusinessTheme.textMuted,
                      fontSize: 10.5,
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

  Widget _buildCapacityBanner(int capacity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E261A),
            BusinessTheme.cardBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BusinessTheme.borderHighlighted, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BusinessTheme.goldAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.hourglass_bottomhalf_fill, color: BusinessTheme.goldAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimasi Kapasitas Seduh Hari Ini',
                  style: TextStyle(
                    color: BusinessTheme.textLight,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tersisa stok cukup untuk ~$capacity cangkir kopi specialty sebelum restock berikutnya.',
                  style: const TextStyle(
                    color: BusinessTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakHoursSection() {
    final hours = [
      {'time': '07:00', 'ratio': 0.25, 'label': 'Opening'},
      {'time': '08:00', 'ratio': 0.90, 'label': 'Rush 1'},
      {'time': '10:00', 'ratio': 0.45, 'label': ''},
      {'time': '12:00', 'ratio': 0.70, 'label': 'Lunch'},
      {'time': '14:00', 'ratio': 0.50, 'label': ''},
      {'time': '17:00', 'ratio': 0.65, 'label': 'Coffee Break'},
      {'time': '19:00', 'ratio': 0.95, 'label': 'Rush 2'},
      {'time': '21:00', 'ratio': 0.35, 'label': 'Closing'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BusinessTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ANALISIS JAM SIBUK (PEAK HOURS)',
                style: TextStyle(
                  color: BusinessTheme.goldAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'Pagi & Malam Hari',
                style: TextStyle(color: BusinessTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: hours.map((h) {
              final ratio = h['ratio'] as double;
              final isPeak = ratio >= 0.85;
              final height = ratio * 70;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPeak)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: BusinessTheme.goldAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PEAK',
                        style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
                      ),
                    )
                  else
                    const SizedBox(height: 16),
                  Container(
                    width: 22,
                    height: height,
                    decoration: BoxDecoration(
                      color: isPeak
                          ? BusinessTheme.goldAccent
                          : BusinessTheme.goldAccent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    h['time'] as String,
                    style: TextStyle(
                      color: isPeak ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
                      fontSize: 9.5,
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

  Widget _buildTopSellingSection() {
    final topItems = [
      {'name': 'Geisha Panama Boquete Pour Over', 'sold': '18 cup', 'rev': 'Rp 630.000'},
      {'name': 'Iced Oat Flat White (Oatside)', 'sold': '15 cup', 'rev': 'Rp 720.000'},
      {'name': 'Single Origin Filter V60 Ethiopia', 'sold': '11 cup', 'rev': 'Rp 462.000'},
      {'name': 'Cappuccino Double Ristretto', 'sold': '9 cup', 'rev': 'Rp 225.000'},
      {'name': 'Cold Drip Reserve 12-Hour Extraction', 'sold': '7 cup', 'rev': 'Rp 315.000'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BusinessTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOP 5 MENU TERLARIS HARI INI',
                style: TextStyle(
                  color: BusinessTheme.goldAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text('Terjual', style: TextStyle(color: BusinessTheme.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          ...topItems.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: idx <= 3
                          ? BusinessTheme.goldAccent.withValues(alpha: 0.2)
                          : BusinessTheme.borderSubtle,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$idx',
                      style: TextStyle(
                        color: idx <= 3 ? BusinessTheme.goldAccent : BusinessTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['name']!,
                      style: const TextStyle(
                        color: BusinessTheme.textLight,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['sold']!,
                        style: const TextStyle(
                          color: BusinessTheme.goldAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item['rev']!,
                        style: const TextStyle(
                          color: BusinessTheme.textMutedDark,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.all(16),
      decoration: BusinessTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STATUS OPERASIONAL BAR & PERANGKAT',
            style: TextStyle(
              color: BusinessTheme.goldAccent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            label: 'Barista Bertugas',
            status: 'Labs Business Demo (@bisnis123)',
            icon: CupertinoIcons.person_badge_plus,
            isOnline: true,
          ),
          const Divider(height: 18, color: BusinessTheme.borderSubtle),
          _buildStatusRow(
            label: 'Printer Bluetooth 58mm',
            status: 'Siap Cetak Struk Kasir',
            icon: CupertinoIcons.printer,
            isOnline: true,
          ),
          const Divider(height: 18, color: BusinessTheme.borderSubtle),
          _buildStatusRow(
            label: 'Mesin Espresso Bar',
            status: '9.2 Bar • Boiler 93.5°C Stabil',
            icon: CupertinoIcons.gear,
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
        Icon(icon, color: BusinessTheme.textMuted, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: BusinessTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? BusinessTheme.statusSuccess : BusinessTheme.statusDanger,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status,
          style: const TextStyle(
            color: BusinessTheme.textLight,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
