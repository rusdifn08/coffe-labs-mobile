import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/utils/external_url_launcher.dart';
import '../../../../theme/app_theme.dart';
import '../../data/live_brew_v2_api_service.dart';
import '../../domain/live_brew_mirror_models.dart';
import '../controllers/live_brew_mirror_controller.dart';
import '../services/cafe_seat_qr_print_service.dart';
import '../services/live_brew_qr_card_exporter.dart';

class BusinessSeatStudioTab extends ConsumerStatefulWidget {
  final ValueChanged<CafeSeatModel>? onStartBrewForSeat;

  const BusinessSeatStudioTab({super.key, this.onStartBrewForSeat});

  @override
  ConsumerState<BusinessSeatStudioTab> createState() =>
      _BusinessSeatStudioTabState();
}

class _BusinessSeatStudioTabState extends ConsumerState<BusinessSeatStudioTab> {
  final TextEditingController _slugCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _welcomeCtrl = TextEditingController();
  final TextEditingController _wifiSsidCtrl = TextEditingController();
  final TextEditingController _wifiPassCtrl = TextEditingController();
  final TextEditingController _singleSeatCtrl = TextEditingController();
  final TextEditingController _prefixCtrl = TextEditingController(text: 'Meja');
  final TextEditingController _startNumCtrl = TextEditingController(text: '1');
  final TextEditingController _endNumCtrl = TextEditingController(text: '6');
  final TextEditingController _zoneCtrl =
      TextEditingController(text: 'Slow Bar Lantai 1');

  CafeSeatKind _seatKind = CafeSeatKind.meja;
  String _accentHex = '#5D3A1A';
  bool _hydrated = false;

  @override
  void dispose() {
    _slugCtrl.dispose();
    _nameCtrl.dispose();
    _welcomeCtrl.dispose();
    _wifiSsidCtrl.dispose();
    _wifiPassCtrl.dispose();
    _singleSeatCtrl.dispose();
    _prefixCtrl.dispose();
    _startNumCtrl.dispose();
    _endNumCtrl.dispose();
    _zoneCtrl.dispose();
    super.dispose();
  }

  void _hydrateFromBranding(BusinessBrandingModel? b) {
    if (_hydrated || b == null) return;
    _hydrated = true;
    _slugCtrl.text = b.cafeSlug;
    _nameCtrl.text = b.cafeDisplayName;
    _welcomeCtrl.text = b.welcomeMessage;
    _wifiSsidCtrl.text = b.wifiSsid ?? '';
    _wifiPassCtrl.text = b.wifiPassword ?? '';
    _accentHex = b.accentColorHex;
  }

  void _openPrintDialog(
    BusinessBrandingModel branding,
    List<CafeSeatModel> targetSeats,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderWarm,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Studio Cetak Barcode (${targetSeats.length} Meja/Kursi)',
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...SeatQrPrintLayout.values.map(
              (layout) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppTheme.primaryBrown,
                  ),
                  title: Text(
                    layout.label,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: 'Bagikan PDF',
                    icon: const Icon(
                      CupertinoIcons.share,
                      color: AppTheme.primaryBrown,
                      size: 18,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      CafeSeatQrPrintService.sharePdfFile(
                        branding: branding,
                        seats: targetSeats,
                        layout: layout,
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    CafeSeatQrPrintService.openNativePdfPrintDialog(
                      branding: branding,
                      seats: targetSeats,
                      layout: layout,
                    );
                  },
                ),
              ),
            ),
            if (targetSeats.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.print_rounded,
                    color: Color(0xFF16A34A),
                  ),
                  title: const Text(
                    'Cetak Langsung Printer Thermal Bluetooth (58mm/80mm)',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _openThermalBluetoothPicker(
                      branding,
                      targetSeats.first,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openThermalBluetoothPicker(
    BusinessBrandingModel branding,
    CafeSeatModel seat,
  ) async {
    final printers = await CafeSeatQrPrintService.scanPairedThermalPrinters();
    if (!mounted) return;
    if (printers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Belum ada printer thermal Bluetooth yang ter-pair di perangkat ini.',
          ),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pilih Printer Thermal Bluetooth',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...printers.map(
            (p) => Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.borderWarm),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.bluetooth_connected,
                  color: Color(0xFF16A34A),
                ),
                title: Text(
                  p.name,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  p.macAdress,
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok =
                      await CafeSeatQrPrintService.printSeatQrToThermalBluetooth(
                    macAddress: p.macAdress,
                    branding: branding,
                    seat: seat,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        ok
                            ? 'QR ${seat.seatLabel} berhasil dicetak ke printer thermal!'
                            : 'Gagal terhubung ke printer thermal.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveBrewMirrorProvider);
    final ctrl = ref.read(liveBrewMirrorProvider.notifier);
    _hydrateFromBranding(state.branding);

    if (!state.isBusinessUser) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.borderWarm),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.building_2_fill,
                color: AppTheme.primaryBrown,
                size: 40,
              ),
              SizedBox(height: 12),
              Text(
                'Studio Barcode Meja & POS Sync (Akun Business)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Upgrade ke Coffee Labs Business untuk membuat URL kafe kustom (brewingcoffee.vercel.app/livebrew/nama-cafe/meja-01), cetak PDF Table Tent A6/A4, cetak Thermal Bluetooth, & sinkronisasi progress pesanan POS real-time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final branding = state.branding ??
        BusinessBrandingModel(
          storeId: '',
          cafeSlug: _slugCtrl.text.isEmpty ? 'coffee-labs-bar' : _slugCtrl.text,
          cafeDisplayName:
              _nameCtrl.text.isEmpty ? 'Coffee Labs Bar' : _nameCtrl.text,
        );

    final previewSlug = _slugCtrl.text.trim().isEmpty
        ? branding.cafeSlug
        : _slugCtrl.text.trim().toLowerCase().replaceAll(' ', '-');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Scoped Studio Error Banner (Friendly copy, NEVER raw DioException!)
        if (state.studioError != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.studioError!,
                        style: const TextStyle(
                          color: Color(0xFF991B1B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      if (state.requiresAuthRelogin) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: ctrl.loadBusinessStudio,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF991B1B),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            minimumSize: Size.zero,
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 14),
                          label: const Text(
                            'Muat Ulang Sesi',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // 1. Branding Kafe Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderWarm),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.storefront_rounded,
                      color: AppTheme.primaryBrown, size: 19),
                  SizedBox(width: 8),
                  Text(
                    'Branding Kafe & URL Kustom',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppTheme.textDark, fontSize: 13),
                decoration: _input('Nama Kafe (contoh: Kopi Senja Slow Bar)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _slugCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: AppTheme.textDark, fontSize: 13),
                decoration: _input('Slug URL (contoh: kopi-senja)'),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  'Link Live: brewingcoffee.vercel.app/livebrew/$previewSlug/meja-01',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.primaryBrown,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wifiSsidCtrl,
                      style:
                          const TextStyle(color: AppTheme.textDark, fontSize: 12.5),
                      decoration: _input('Nama Wi-Fi (Opsional)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _wifiPassCtrl,
                      style:
                          const TextStyle(color: AppTheme.textDark, fontSize: 12.5),
                      decoration: _input('Password Wi-Fi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: state.isSavingBranding
                      ? null
                      : () async {
                          final ok = await ctrl.saveCafeBranding(
                            cafeSlug: _slugCtrl.text.trim(),
                            cafeDisplayName: _nameCtrl.text.trim(),
                            primaryColorHex: '#5D3A1A',
                            accentColorHex: _accentHex,
                            welcomeMessage: _welcomeCtrl.text.trim().isEmpty
                                ? 'Selamat menikmati seduhan spesial kami!'
                                : _welcomeCtrl.text.trim(),
                            wifiSsid: _wifiSsidCtrl.text.trim().isEmpty
                                ? null
                                : _wifiSsidCtrl.text.trim(),
                            wifiPassword: _wifiPassCtrl.text.trim().isEmpty
                                ? null
                                : _wifiPassCtrl.text.trim(),
                          );
                          if (ok != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  'Branding kafe & URL kustom berhasil disimpan!',
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isSavingBranding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Branding Kafe',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Tambah 1 Meja / Kursi Cepat + Generate Massal
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.qr_code_2_rounded,
                      color: AppTheme.primaryBrown, size: 19),
                  SizedBox(width: 8),
                  Text(
                    'Tambah & Generate QR Meja / Kursi Bar',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quick single seat input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _singleSeatCtrl,
                      style:
                          const TextStyle(color: AppTheme.textDark, fontSize: 13),
                      decoration: _input('Tambah 1 QR (mis. VIP 01 / Slow Bar A)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: state.isGeneratingSeats
                        ? null
                        : () async {
                            final label = _singleSeatCtrl.text.trim();
                            if (label.isEmpty) return;
                            final created = await ctrl.createSingleSeat(
                              seatLabel: label,
                              kind: _seatKind,
                              zoneArea: _zoneCtrl.text.trim(),
                            );
                            if (created != null && context.mounted) {
                              _singleSeatCtrl.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    'QR "${created.seatLabel}" berhasil ditambahkan!',
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text(
                      'Tambah',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: AppTheme.borderWarm),
              ),

              const Text(
                'Generate Massal Sekaligus',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _prefixCtrl,
                      style:
                          const TextStyle(color: AppTheme.textDark, fontSize: 13),
                      decoration: _input('Awalan (Meja / Kursi)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _startNumCtrl,
                      keyboardType: TextInputType.number,
                      style:
                          const TextStyle(color: AppTheme.textDark, fontSize: 13),
                      decoration: _input('Dari'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _endNumCtrl,
                      keyboardType: TextInputType.number,
                      style:
                          const TextStyle(color: AppTheme.textDark, fontSize: 13),
                      decoration: _input('Sampai'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CafeSeatKind>(
                      initialValue: _seatKind,
                      dropdownColor: Colors.white,
                      style:
                          const TextStyle(color: AppTheme.textDark, fontSize: 12.5),
                      decoration: _input('Tipe'),
                      items: CafeSeatKind.values
                          .map(
                            (k) => DropdownMenuItem(
                              value: k,
                              child: Text(k.labelId),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _seatKind = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _zoneCtrl,
                      style:
                          const TextStyle(color: AppTheme.textDark, fontSize: 12.5),
                      decoration: _input('Zona / Area'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.isGeneratingSeats
                          ? null
                          : () async {
                              final start = int.tryParse(_startNumCtrl.text) ?? 1;
                              final end = int.tryParse(_endNumCtrl.text) ?? start;
                              final created = await ctrl.generateBatchSeats(
                                prefix: _prefixCtrl.text.trim().isEmpty
                                    ? 'Meja'
                                    : _prefixCtrl.text.trim(),
                                startNumber: start,
                                endNumber: end,
                                kind: _seatKind,
                                zoneArea: _zoneCtrl.text.trim(),
                                capacityPersons:
                                    _seatKind == CafeSeatKind.kursiBar ? 1 : 2,
                              );
                              if (created.isNotEmpty && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      '${created.length} QR meja/kursi siap cetak berhasil dibuat!',
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: state.isGeneratingSeats
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(CupertinoIcons.add_circled_solid, size: 17),
                      label: const Text(
                        'Buat Barcode',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (state.seats.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _openPrintDialog(branding, state.seats),
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text(
                        'Cetak Semua',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBrown,
                        side: const BorderSide(color: AppTheme.primaryBrown),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (state.seats.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Text(
              'DAFTAR BARCODE MEJA & KURSI (${state.seats.length})',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],

        // 3. Daftar Meja & Kursi Aktif
        ...state.seats.map((seat) {
          final hasOrder = seat.activePosOrderNumber != null;
          final isLive = seat.activeLiveSessionId != null;
          final seatUrl = LiveBrewV2ApiService.normalizePublicShareUrl(seat.brandedUrl);
          final badgeColor = isLive
              ? const Color(0xFFDC2626)
              : (hasOrder ? const Color(0xFFD97706) : const Color(0xFF16A34A));
          final statusText = isLive
              ? 'Live Brewing'
              : (hasOrder ? 'POS ${seat.activePosOrderNumber}' : 'Siap Pakai');

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderWarm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderWarm),
                  ),
                  child: QrImageView(data: seatUrl, size: 58),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              seat.seatLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => ctrl.deleteSeat(seat.id),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(3),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 17,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        seatUrl.replaceFirst('https://', ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.primaryBrown,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _SeatActionChip(
                            icon: Icons.copy_rounded,
                            label: 'Salin',
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: seatUrl));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Link ${seat.seatLabel} disalin!'),
                                ),
                              );
                            },
                          ),
                          _SeatActionChip(
                            icon: Icons.open_in_browser_rounded,
                            label: 'Buka',
                            onTap: () => launchExternalUri(Uri.parse(seatUrl)),
                          ),
                          _SeatActionChip(
                            icon: Icons.qr_code_2_rounded,
                            label: 'Kirim QR',
                            onTap: () => LiveBrewQrCardExporter.shareQrCardWithCaption(
                              liveUrl: seatUrl,
                              title: branding.cafeDisplayName,
                              subtitle: seat.zoneArea,
                              seatLabel: seat.seatLabel,
                            ),
                          ),
                          _SeatActionChip(
                            icon: Icons.print_rounded,
                            label: 'Cetak',
                            onTap: () => _openPrintDialog(branding, [seat]),
                          ),
                          if (widget.onStartBrewForSeat != null)
                            _SeatActionChip(
                              icon: Icons.sensors_rounded,
                              label: 'Mulai Seduh',
                              highlighted: true,
                              onTap: () => widget.onStartBrewForSeat!(seat),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
      filled: true,
      fillColor: AppTheme.bgCream,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppTheme.borderWarm),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppTheme.borderWarm),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 1.4),
      ),
    );
  }
}

class _SeatActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  const _SeatActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: highlighted ? AppTheme.primaryBrown : AppTheme.bgCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: highlighted ? AppTheme.primaryBrown : AppTheme.borderWarm,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: highlighted ? Colors.white : AppTheme.primaryBrown,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: highlighted ? Colors.white : AppTheme.textDark,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
