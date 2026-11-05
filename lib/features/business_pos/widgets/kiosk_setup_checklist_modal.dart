import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/kiosk_engine_service.dart';
import '../../../../models/business_pos_models.dart';
import '../presentation/controllers/aod_kiosk_controller.dart';
import '../screens/customer_aod_menu_screen.dart';

class KioskSetupChecklistModal extends ConsumerStatefulWidget {
  final BusinessStoreConfig config;
  final List<BusinessMenuItem> menuItems;

  const KioskSetupChecklistModal({
    super.key,
    required this.config,
    required this.menuItems,
  });

  static Future<void> show(
    BuildContext context, {
    required BusinessStoreConfig config,
    required List<BusinessMenuItem> menuItems,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KioskSetupChecklistModal(
        config: config,
        menuItems: menuItems,
      ),
    );
  }

  @override
  ConsumerState<KioskSetupChecklistModal> createState() => _KioskSetupChecklistModalState();
}

class _KioskSetupChecklistModalState extends ConsumerState<KioskSetupChecklistModal> {
  final TextEditingController _pinController = TextEditingController(text: '1234');
  bool _hasOverlay = false;
  bool _isChecking = true;
  bool _isLocking = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);
    final hasOverlay = await KioskEngineService.hasOverlayPermission();
    if (mounted) {
      setState(() {
        _hasOverlay = hasOverlay;
        _isChecking = false;
      });
    }
  }

  Future<void> _onLockPressed() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4 || pin.length > 8) {
      setState(() => _errorMessage = 'PIN Kasir harus 4 - 8 digit.');
      return;
    }

    setState(() {
      _isLocking = true;
      _errorMessage = null;
    });

    try {
      await ref.read(aodKioskControllerProvider.notifier).lockKiosk(
            pin: pin,
            config: widget.config,
            menuItems: widget.menuItems,
          );

      if (mounted) {
        Navigator.pop(context); // Tutup modal
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerAodMenuScreen(
              config: widget.config,
              initialMenuItems: widget.menuItems,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocking = false;
          _errorMessage = 'Gagal mengunci: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF262626), width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(CupertinoIcons.lock_shield_fill, color: Color(0xFFD4AF37), size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kiosk Lock & Auto-Boot Setup',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Mode Meja Kasir Single-Purpose (Business Tier)',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Item 1: Overlay Permission (BAL Exemption)
            _buildCheckItem(
              icon: CupertinoIcons.layers_alt_fill,
              title: 'Izin Overlay (Display Over Other Apps)',
              subtitle: 'Wajib agar aplikasi bisa auto-boot instan saat HP restart (Android 10-16).',
              isGranted: _hasOverlay,
              actionWidget: _isChecking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CupertinoActivityIndicator(color: Color(0xFFD4AF37)),
                    )
                  : _hasOverlay
                      ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 24)
                      : TextButton(
                          onPressed: () async {
                            await KioskEngineService.requestOverlayPermission();
                            await Future.delayed(const Duration(seconds: 1));
                            _checkPermissions();
                          },
                          child: const Text('Izinkan', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                        ),
            ),
            const SizedBox(height: 12),

            // Item 2: Dynamic Home Launcher
            _buildCheckItem(
              icon: CupertinoIcons.home,
              title: 'Home Launcher Hijack',
              subtitle: 'Menekan tombol Home fisik akan mengarahkan pelanggan kembali ke Coffee Labs.',
              isGranted: true,
              actionWidget: TextButton(
                onPressed: () => KioskEngineService.promptSelectHomeLauncher(),
                child: const Text('Uji Pilih', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 12),

            // Item 3: PIN Kasir
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PIN Buka Kunci Kasir (4 - 8 Digit)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PIN ini disimpan di Direct-Boot Storage terenkripsi lokal sehingga tetap bisa dibuka meski Wi-Fi mati.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 8,
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black38,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      hintText: 'PIN',
                      hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],

            const SizedBox(height: 20),

            // Button Kunci
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isLocking ? null : _onLockPressed,
                icon: _isLocking
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(CupertinoIcons.lock_fill, size: 20),
                label: Text(
                  _isLocking ? 'Mengunci Sistem...' : 'KUNCI DISPLAY KIOSK SEKARANG',
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
    required Widget actionWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: isGranted ? const Color(0xFF10B981) : const Color(0xFFF59E0B), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          actionWidget,
        ],
      ),
    );
  }
}
