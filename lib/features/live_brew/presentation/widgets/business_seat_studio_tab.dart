import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/live_brew_mirror_models.dart';
import '../controllers/live_brew_mirror_controller.dart';
import '../services/cafe_seat_qr_print_service.dart';

class BusinessSeatStudioTab extends ConsumerStatefulWidget {
  final ValueChanged<CafeSeatModel>? onStartBrewForSeat;

  const BusinessSeatStudioTab({super.key, this.onStartBrewForSeat});

  @override
  ConsumerState<BusinessSeatStudioTab> createState() => _BusinessSeatStudioTabState();
}

class _BusinessSeatStudioTabState extends ConsumerState<BusinessSeatStudioTab> {
  final TextEditingController _slugCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _welcomeCtrl = TextEditingController();
  final TextEditingController _wifiSsidCtrl = TextEditingController();
  final TextEditingController _wifiPassCtrl = TextEditingController();
  final TextEditingController _prefixCtrl = TextEditingController(text: 'Meja');
  final TextEditingController _startNumCtrl = TextEditingController(text: '1');
  final TextEditingController _endNumCtrl = TextEditingController(text: '6');
  final TextEditingController _zoneCtrl = TextEditingController(text: 'Slow Bar Lantai 1');

  CafeSeatKind _seatKind = CafeSeatKind.meja;
  String _accentHex = '#D4A373';
  bool _hydrated = false;

  @override
  void dispose() {
    _slugCtrl.dispose();
    _nameCtrl.dispose();
    _welcomeCtrl.dispose();
    _wifiSsidCtrl.dispose();
    _wifiPassCtrl.dispose();
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

  void _openPrintDialog(BusinessBrandingModel branding, List<CafeSeatModel> targetSeats) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1714),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Studio Cetak Barcode (${targetSeats.length} Meja/Kursi)',
              style: const TextStyle(
                color: Color(0xFFF9F5EE),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...SeatQrPrintLayout.values.map(
              (layout) => ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFD4A373)),
                title: Text(
                  layout.label,
                  style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                ),
                trailing: IconButton(
                  tooltip: 'Bagikan PDF',
                  icon: const Icon(CupertinoIcons.share, color: Color(0xFFD4A373), size: 18),
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
            const Divider(color: Colors.white24),
            if (targetSeats.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.print_rounded, color: Color(0xFF22C55E)),
                title: const Text(
                  'Cetak Langsung Printer Thermal Bluetooth (58mm/80mm)',
                  style: TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _openThermalBluetoothPicker(branding, targetSeats.first);
                },
              ),
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
          content: Text('Belum ada printer thermal Bluetooth yang ter-pair di perangkat ini.'),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1714),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pilih Printer Thermal Bluetooth',
            style: TextStyle(color: Color(0xFFF9F5EE), fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...printers.map(
            (p) => ListTile(
              leading: const Icon(Icons.bluetooth_connected, color: Color(0xFFD4A373)),
              title: Text(p.name, style: const TextStyle(color: Color(0xFFF9F5EE))),
              subtitle: Text(p.macAdress, style: const TextStyle(color: Colors.white54)),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await CafeSeatQrPrintService.printSeatQrToThermalBluetooth(
                  macAddress: p.macAdress,
                  branding: branding,
                  seat: seat,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1714),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.45)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.building_2_fill, color: Color(0xFFD4A373), size: 38),
              SizedBox(height: 12),
              Text(
                'Studio Barcode Meja & POS Sync (Akun Business)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF9F5EE),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Upgrade ke Coffee Labs Business untuk membuat URL kafe kustom (coffeelabs.com/livebrew/nama-cafe/meja-04), cetak PDF Table Tent A6/A4, cetak Thermal Bluetooth, & sinkronisasi progress pesanan POS real-time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFCBBFB2), fontSize: 12.5, height: 1.45),
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
          cafeDisplayName: _nameCtrl.text.isEmpty ? 'Coffee Labs Bar' : _nameCtrl.text,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        // Branding Kafe Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1714),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Branding Kafe & URL Kustom',
                style: TextStyle(
                  color: Color(0xFFF9F5EE),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                decoration: _input('Nama Kafe'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _slugCtrl,
                style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                decoration: _input('Slug URL (coffeelabs.com/livebrew/{slug}/...)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wifiSsidCtrl,
                      style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 12.5),
                      decoration: _input('Nama Wi-Fi (Opsional)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _wifiPassCtrl,
                      style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 12.5),
                      decoration: _input('Password Wi-Fi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await ctrl.saveCafeBranding(
                      cafeSlug: _slugCtrl.text.trim(),
                      cafeDisplayName: _nameCtrl.text.trim(),
                      primaryColorHex: '#12100E',
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
                        const SnackBar(content: Text('Branding kafe & URL kustom disimpan!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A373),
                    foregroundColor: const Color(0xFF12100E),
                  ),
                  child: const Text(
                    'Simpan Branding Kafe',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Batch Generator Meja & Kursi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1714),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate Massal Meja / Kursi Bar',
                style: TextStyle(
                  color: Color(0xFFF9F5EE),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _prefixCtrl,
                      style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                      decoration: _input('Awalan (Meja / Kursi)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _startNumCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                      decoration: _input('Dari'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _endNumCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
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
                      dropdownColor: const Color(0xFF1C1714),
                      style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 12.5),
                      decoration: _input('Tipe'),
                      items: CafeSeatKind.values
                          .map((k) => DropdownMenuItem(value: k, child: Text(k.labelId)))
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
                      style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 12.5),
                      decoration: _input('Zona / Area'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final start = int.tryParse(_startNumCtrl.text) ?? 1;
                        final end = int.tryParse(_endNumCtrl.text) ?? start;
                        ctrl.generateBatchSeats(
                          prefix: _prefixCtrl.text.trim().isEmpty ? 'Meja' : _prefixCtrl.text.trim(),
                          startNumber: start,
                          endNumber: end,
                          kind: _seatKind,
                          zoneArea: _zoneCtrl.text.trim(),
                          capacityPersons: _seatKind == CafeSeatKind.kursiBar ? 1 : 2,
                        );
                      },
                      icon: const Icon(CupertinoIcons.add_circled_solid, size: 16),
                      label: const Text('Buat Barcode'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A373),
                        foregroundColor: const Color(0xFF12100E),
                      ),
                    ),
                  ),
                  if (state.seats.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _openPrintDialog(branding, state.seats),
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text('Cetak Semua'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF9F5EE),
                        side: const BorderSide(color: Color(0xFFD4A373)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Daftar Meja & Kursi Aktif
        ...state.seats.map((seat) {
          final hasOrder = seat.activePosOrderNumber != null;
          final isLive = seat.activeLiveSessionId != null;
          final badgeColor = isLive
              ? const Color(0xFFDC2626)
              : (hasOrder ? const Color(0xFFD97706) : const Color(0xFF16A34A));
          final statusText = isLive
              ? 'Live Brewing'
              : (hasOrder ? 'POS ${seat.activePosOrderNumber}' : 'Kosong');

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1714),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(data: seat.brandedUrl, size: 52),
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
                                color: Color(0xFFF9F5EE),
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.2),
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
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        seat.brandedUrl.replaceFirst('https://', ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFFD4A373), fontSize: 10.5),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _openPrintDialog(branding, [seat]),
                            child: const Text(
                              '🖨️ Cetak QR',
                              style: TextStyle(
                                color: Color(0xFFF9F5EE),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          if (widget.onStartBrewForSeat != null)
                            InkWell(
                              onTap: () => widget.onStartBrewForSeat!(seat),
                              child: const Text(
                                '📡 Mulai Seduh',
                                style: TextStyle(
                                  color: Color(0xFFD4A373),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
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
      labelStyle: const TextStyle(color: Color(0xFFCBBFB2), fontSize: 11.5),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
    );
  }
}
