import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/business_pos_models.dart';
import '../../../providers/workspace_mode_provider.dart';
import '../../../services/app_update_service.dart';
import '../../../services/business_pos_api_service.dart';
import '../../../theme/business_theme.dart';
import '../services/thermal_receipt_service.dart';
import '../widgets/add_menu_item_modal.dart';
import '../widgets/business_svg_icons.dart';
import '../widgets/manage_menu_modal.dart';
import '../widgets/receipt_preview_modal.dart';
import 'shift_summary_screen.dart';

class BusinessSettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSwitchToPersonal;

  const BusinessSettingsScreen({super.key, this.onSwitchToPersonal});

  @override
  ConsumerState<BusinessSettingsScreen> createState() =>
      _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState
    extends ConsumerState<BusinessSettingsScreen> {
  BusinessStoreConfig _config = BusinessStoreConfig.defaultBarConfig();
  List<BusinessMenuItem> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
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

  void _handleSwitchToPersonal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BusinessTheme.cardElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.person_crop_circle, color: BusinessTheme.goldAccent, size: 24),
            SizedBox(width: 10),
            Text(
              'Kembali ke Mode Personal?',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Anda akan keluar dari Mode Business dan kembali ke halaman personal barista (seduh harian, resep dunia, dan toolkit).',
          style: TextStyle(color: BusinessTheme.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tetap di Bisnis', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(workspaceModeProvider.notifier).forceSetMode(WorkspaceMode.personalBrewer);
              widget.onSwitchToPersonal?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BusinessTheme.goldAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Beralih ke Personal', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _printTestReceipt() {
    final dummyReceipt = ThermalReceiptData(
      storeName: _config.storeName,
      storeAddress: 'Coffee Labs Bar Counter • Specialty Espresso',
      cashierName: 'Barista Utama',
      customerName: 'Pelanggan Meja Bar #01',
      orderNumber: '#TEST-01',
      orderTime: DateTime.now(),
      items: [
        if (_menuItems.isNotEmpty)
          PosCartItem(menuItem: _menuItems.first, quantity: 2)
        else
          PosCartItem(
            menuItem: const BusinessMenuItem(
              id: 'test',
              storeId: 'default',
              name: 'Cappuccino Artisan',
              description: '',
              category: 'Milk Based',
              priceCents: 35000,
              assetUrl: '',
              assetFormat: 'PNG',
            ),
            quantity: 1,
          ),
      ],
      subtotal: 70000,
      discount: 0,
      tax: 0,
      grandTotal: 70000,
      paymentMethod: 'QRIS',
    );

    ReceiptPreviewModal.show(
      context,
      data: dummyReceipt,
      onNewTransaction: () {},
    );
  }

  void _openManageMenu() {
    ManageMenuModal.show(context, menuItems: _menuItems, onMenuChanged: _loadSettings);
  }

  void _openAddMenu() {
    AddMenuItemModal.show(context, onMenuAdded: _loadSettings);
  }

  void _openShiftSummary() {
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
    return Scaffold(
      backgroundColor: BusinessTheme.bgDark,
      appBar: AppBar(
        backgroundColor: BusinessTheme.bgSurface,
        elevation: 0,
        title: const Row(
          children: [
            Icon(CupertinoIcons.gear_alt_fill, color: BusinessTheme.goldAccent, size: 20),
            SizedBox(width: 8),
            Text(
              'Pengaturan Bisnis',
              style: TextStyle(
                color: BusinessTheme.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: BusinessTheme.goldAccent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Prominent Mode Switcher Card to Mode Personal
                  _buildModePersonalSwitcherCard(),
                  const SizedBox(height: 20),

                  // 2. Outlet & Store Profile
                  _buildStoreProfileCard(),
                  const SizedBox(height: 20),

                  // 3. Hardware & Peripherals (Printer, Kiosk PIN)
                  _buildHardwareCard(),
                  const SizedBox(height: 20),

                  // 4. Menu & Catalog Management Shortcuts
                  _buildMenuManagementCard(),
                  const SizedBox(height: 20),

                  // 5. Shift & Cashier Audit
                  _buildShiftAuditCard(),
                  const SizedBox(height: 20),

                  // 6. OTA & System Updates
                  _buildOtaUpdateCard(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
    );
  }

  Widget _buildModePersonalSwitcherCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF262016), Color(0xFF171513)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BusinessTheme.goldAccent.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: BusinessTheme.goldAccent.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: BusinessTheme.goldAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: BusinessTheme.goldAccent, width: 1.0),
                ),
                child: const Icon(
                  CupertinoIcons.arrow_2_squarepath,
                  color: BusinessTheme.goldAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beralih Workspace',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Saat ini berada di Mode Business Kafe',
                      style: TextStyle(
                        color: BusinessTheme.goldAccent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Ingin menyeduh kopi personal, melihat resep dunia, atau menggunakan kalkulator rasio barista? Anda dapat beralih ke Mode Personal kapan saja dengan bebas.',
            style: TextStyle(
              color: BusinessTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _handleSwitchToPersonal,
              icon: const Icon(CupertinoIcons.person_crop_circle, size: 20),
              label: const Text(
                'Kembali ke Mode Personal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: BusinessTheme.goldAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreProfileCard() {
    return Container(
      decoration: BusinessTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROFIL OUTLET & LISENSI',
                style: TextStyle(
                  color: BusinessTheme.goldAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              InkWell(
                onTap: _showEditStoreDialog,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.pencil, color: BusinessTheme.goldAccent, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Ubah Profil & Logo',
                        style: TextStyle(color: BusinessTheme.goldAccent, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              BusinessSvgIcon.cafeEmblem(logoType: _config.logoIconType, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _config.storeName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _config.storeTagline,
                      style: const TextStyle(color: BusinessTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: BusinessTheme.borderSubtle),
          _buildInfoRow(
            label: 'Alamat Struk',
            value: 'Coffee Labs Bar Counter • Specialty Espresso',
            icon: CupertinoIcons.location_solid,
          ),
          const Divider(height: 18, color: BusinessTheme.borderSubtle),
          _buildInfoRow(
            label: 'Status Lisensi',
            value: 'Business Suite Aktif (Unlimited Struk)',
            icon: CupertinoIcons.rosette,
            valueColor: BusinessTheme.goldAccent,
          ),
        ],
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
          title: const Text(
            'Ubah Identitas Kafe / Resto',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  ),
                ),
                const SizedBox(height: 14),
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
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'PILIH LOGO EMBLEM KAFE',
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
                            BusinessSvgIcon.cafeEmblem(logoType: type, size: 26),
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
              ),
              child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHardwareCard() {
    return Container(
      decoration: BusinessTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERANGKAT & HARDWARE KASIR',
            style: TextStyle(
              color: BusinessTheme.goldAccent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(CupertinoIcons.printer, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Printer Thermal Bluetooth',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Format standar 58mm ESC/POS • Otomatis Potong',
                      style: TextStyle(color: BusinessTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _printTestReceipt,
                style: OutlinedButton.styleFrom(
                  foregroundColor: BusinessTheme.goldAccent,
                  side: const BorderSide(color: BusinessTheme.goldAccent),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Test Print', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 20, color: BusinessTheme.borderSubtle),
          _buildInfoRow(
            label: 'Keamanan PIN Kiosk Display',
            value: '1234 (Tekan lama logo)',
            icon: CupertinoIcons.lock_shield_fill,
          ),
          const Divider(height: 20, color: BusinessTheme.borderSubtle),
          _buildInfoRow(
            label: 'Pajak & Biaya Tambahan',
            value: 'PPN 0% • Bebas Service Charge',
            icon: CupertinoIcons.percent,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuManagementCard() {
    return Container(
      decoration: BusinessTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MANAJEMEN KATALOG MENU',
            style: TextStyle(
              color: BusinessTheme.goldAccent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: BusinessTheme.goldAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(CupertinoIcons.square_grid_2x2_fill, color: BusinessTheme.goldAccent, size: 18),
                  ),
                  title: const Text('Kelola & Urutkan Menu',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Atur urutan tampil, ketersediaan, dan harga menu',
                      style: TextStyle(color: BusinessTheme.textMuted, fontSize: 11)),
                  trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white38, size: 16),
                  onTap: _openManageMenu,
                ),
                const Divider(height: 1, color: BusinessTheme.borderSubtle),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: BusinessTheme.statusSuccess.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(CupertinoIcons.plus_circle_fill, color: BusinessTheme.statusSuccess, size: 18),
                  ),
                  title: const Text('Tambah Menu Baru',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Upload aset foto berlatar transparan atau pilih katalog',
                      style: TextStyle(color: BusinessTheme.textMuted, fontSize: 11)),
                  trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white38, size: 16),
                  onTap: _openAddMenu,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftAuditCard() {
    return Container(
      decoration: BusinessTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LAPORAN AUDIT & SHIFT BARISTA',
            style: TextStyle(
              color: BusinessTheme.goldAccent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF472B6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.doc_text_fill, color: Color(0xFFF472B6), size: 18),
              ),
              title: const Text('Laporan Shift Hari Ini',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text('Lihat rincian Cash, QRIS, EDC, dan total diskon',
                  style: TextStyle(color: BusinessTheme.textMuted, fontSize: 11)),
              trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white38, size: 16),
              onTap: _openShiftSummary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtaUpdateCard() {
    return Container(
      decoration: BusinessTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.arrow_2_circlepath,
                      color: BusinessTheme.goldAccent, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'SISTEM PEMBARUAN & OTA',
                    style: TextStyle(
                      color: BusinessTheme.goldAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF10B981), size: 12),
                    SizedBox(width: 4),
                    Text(
                      'OTA AKTIF',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            label: 'Versi Aplikasi POS',
            value: 'v2.0.0 (Build #2)',
            icon: CupertinoIcons.info_circle_fill,
            valueColor: Colors.white,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'Mesin Distribusi Update',
            value: 'Shorebird 2.x & Version Gatekeeper',
            icon: CupertinoIcons.bolt_fill,
            valueColor: BusinessTheme.goldAccent,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            label: 'Mode Update Kiosk',
            value: 'Silent Background & Force OTA',
            icon: CupertinoIcons.device_laptop,
            valueColor: Colors.white70,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {
                AppUpdateService.checkForUpdate(context: context, isManual: true);
              },
              icon: const Icon(CupertinoIcons.arrow_clockwise, size: 16),
              label: const Text(
                'Periksa Pembaruan Sistem (OTA)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: BusinessTheme.goldAccent,
                side: const BorderSide(color: BusinessTheme.goldAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: BusinessTheme.textMuted, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: BusinessTheme.textMuted, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? BusinessTheme.textLight,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
